import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verse/process_manager.dart';


class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.param});
  final List param;

  @override
  State<StatefulWidget> createState() => _ChatPageState();
}


class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: _getChatPageContent(Theme.of(context)),
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

  void _alert(String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                SelectableText(
                  message,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontFamily: 'JetBrains Mono',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              autofocus: true,
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<Widget> _getChatPageContent(ThemeData theme) async {
    return Scaffold(
      body: Center(
        child: Text(
          'Param: ${widget.param}',
          style: const TextStyle(
            fontFamily: 'JetBrains Mono Bold',
            fontSize: 17,
          ),
        ),
      ),
    );
  }
}
