import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verse/process_manager.dart';


class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

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

  Future<Widget> _getChatPageContent(ThemeData theme) async {
    return Text('sss');
  }
}
