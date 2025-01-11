import 'package:flutter/material.dart';
import 'package:verse/main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verse/process_manager.dart';
import 'package:verse/widgets/xla_controller.dart';
import 'package:verse/chat_page.dart';


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
        return Container();
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

  void _pickPath(String id, String extension) async {
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

  void _launch(String interpreterPath, String scriptPath) {
    Map<String, String> env = {'PYTHONUNBUFFERED': '1'};

    if (xlaPreAllocatingStatus) {
      env.addAll({'XLA_PYTHON_CLIENT_MEM_FRACTION': '.$preAllocationRatio'});
    }
    else {
      env.addAll({'XLA_PYTHON_CLIENT_ALLOCATOR': 'platform'});
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(param: [interpreterPath, scriptPath, env]),
      ),
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
        constraints: BoxConstraints(maxWidth: width, maxHeight: 350),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                          onPressed: () { _pickPath('Path to Interpreter', ''); },
                        ),
                      )
                    : interpreterPathEllipsis
                      ? InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Interpreter',
                          prefix: const Text('...', style: TextStyle(color: Colors.grey)),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.folder_outlined),
                            onPressed: () { _pickPath('Path to Interpreter', ''); },
                          ),
                        )
                      : InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'Interpreter',
                        suffixIcon: IconButton(
                            icon: const Icon(Icons.folder_outlined),
                            onPressed: () { _pickPath('Path to Interpreter', ''); },
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
                          onPressed: () { _pickPath('Path to Script', 'py'); },
                        ),
                      )
                    : InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'Script',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.folder_outlined),
                          onPressed: () { _pickPath('Path to Script', 'py'); },
                        ),
                      )
              ),
            ),
            arg.contains('-xla') ? XlaController() : const SizedBox(height: 8),
            const SizedBox(height: 8),
            FloatingActionButton.extended(
              icon: Icon(Icons.rocket_launch),
              label: const Text('Launch'),
              onPressed: () {
                if (interpreterPath == null || scriptPath == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Missing configuration!'),
                    ),
                  );
                }
                else {
                  _launch(interpreterPath, scriptPath);
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
