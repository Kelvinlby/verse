import 'package:flutter/material.dart';
import 'package:verse/main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verse/process_manager.dart';


class Launcher extends StatefulWidget {
  const Launcher({super.key});

  @override
  State<StatefulWidget> createState() => _LauncherState();
}


class _LauncherState extends State<Launcher> {
  final width = 320.0;
  final overflowLength = 23;

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: _getLauncher(Theme.of(context)),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return snapshot.data!;
      }
      else if (snapshot.hasError) {
        return Column(
          children: [
            const Icon(Icons.error_outline),
            const SizedBox(height: 8),
            Text(
              'Error: ${snapshot.error}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                fontSize: 18,
              ),
            ),
          ],
        );
      }
      else {
        return snapshot.data!;
      }
    },
  );

  Widget _xlaController(ThemeData theme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const SizedBox(width: 4),
                Text(
                  'XLA Pre-Allocation',
                  style: const TextStyle(
                    fontFamily: 'JetBrains Mono Bold',
                    fontSize: 17,
                  ),
                ),
              ],
            ),
            Switch(
              value: xlaPreAllocatingStatus,
              activeColor: theme.colorScheme.primary,
              onChanged: (bool value) {
                setState(() {
                  xlaPreAllocatingStatus = value;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (xlaPreAllocatingStatus) Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Row(
                children: [
                  const SizedBox(width: 24),
                  Text(
                    'Allocation Ratio:  ${preAllocationRate.toString().padLeft(2, ' ')}%',
                    style: const TextStyle(
                      fontFamily: 'JetBrains Mono Bold',
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
              Slider(
                value: preAllocationRate.toDouble(),
                max: 99,
                label: preAllocationRate.toString(),
                onChanged: (double value) {
                  setState(() {
                    preAllocationRate = value.round();
                  });
                },
              ),
            ],
          )
        ),
      ],
    );
  }

  Future<Widget> _getLauncher(ThemeData theme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool isConda = false, interpreterPathEllipsis = false, scriptPathEllipsis = false;
    String? interpreterPath = prefs.getString('Path to Interpreter');
    String? scriptPath = prefs.getString('Path to Script');

    if(interpreterPath != null) {
      if(interpreterPath.contains('miniconda')) {
        isConda = true;
      }
      else if(interpreterPath.length >= overflowLength) {
        interpreterPathEllipsis = true;
      }
    }

    if(scriptPath != null) {
      if(scriptPath.length >= overflowLength) {
        scriptPathEllipsis = true;
      }
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 1),
            SizedBox(
              width: width,
              height: 56,
              child: TextFormField(
                readOnly: true,
                style: const TextStyle(fontFamily: 'JetBrains Mono'),
                initialValue: isConda
                    ? 'miniconda'
                    : interpreterPathEllipsis
                      ? interpreterPath!.substring(interpreterPath.length - overflowLength)
                      : interpreterPath,
                decoration: isConda
                    ? InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'Interpreter',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.folder_outlined),
                          onPressed: () { _pickPath('Path to Interpreter', '', setState); },
                        ),
                      )
                    : interpreterPathEllipsis
                      ? InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Interpreter',
                          prefix: const Text('...', style: TextStyle(color: Colors.grey)),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.folder_outlined),
                            onPressed: () { _pickPath('Path to Interpreter', '', setState); },
                          ),
                        )
                      : InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'Interpreter',
                        suffixIcon: IconButton(
                            icon: const Icon(Icons.folder_outlined),
                            onPressed: () { _pickPath('Path to Interpreter', '', setState); },
                          ),
                        )
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: width,
              height: 56,
              child: TextFormField(
                readOnly: true,
                style: const TextStyle(fontFamily: 'JetBrains Mono'),
                initialValue: scriptPathEllipsis ? scriptPath!.substring(scriptPath.length - overflowLength) : scriptPath,
                decoration: scriptPathEllipsis
                    ? InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'Script',
                        prefix: const Text('...', style: TextStyle(color: Colors.grey)),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.folder_outlined),
                          onPressed: () { _pickPath('Path to Script', 'py', setState); },
                        ),
                      )
                    : InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'Script',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.folder_outlined),
                          onPressed: () { _pickPath('Path to Script', 'py', setState); },
                        ),
                      )
              ),
            ),
            arg.contains('-xla') ? _xlaController(theme) : const SizedBox(height: 8),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}


void _pickPath(String id, String extension, Function setState) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [extension],
      dialogTitle: id
  );

  if(result != null) {
    setState(() {
      prefs.setString(id, result.files.first.path!);
    });
  }
}
