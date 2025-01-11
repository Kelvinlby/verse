import 'package:flutter/material.dart';
import 'package:verse/process_manager.dart';


class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.interpreterPath, required this.scriptPath, required this.env});
  final String interpreterPath;
  final String scriptPath;
  final Map<String, String> env;

  @override
  State<StatefulWidget> createState() => _ChatPageState();
}


class _ChatPageState extends State<ChatPage> {
  final TextEditingController promptController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final _chats = <List<String>, List<String>>{};

  void _submit() {
    String prompt = promptController.text;

    if (prompt.isEmpty) {
      return;
    }

    prompt = prompt.trim();
    promptController.clear();

    // TODO
    _chats[[prompt]] = ["ans-new", "img-new"];

    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: _getChatPageContent(Theme.of(context)),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
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

  void _listener(String answer) {

  }

  void _quit() {
    ProcessManager.stop();
    Navigator.of(context).pop();
  }

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
    ProcessManager.stop();
    ProcessManager.start(widget.interpreterPath, widget.scriptPath, widget.env, listener: _listener, finish: _quit, error: _alert);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Container(),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
        ),
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _chats.length,
                itemBuilder: (context, index) {
                  final groupKey = _chats.keys.elementAt(index);
                  final groupItems = _chats[groupKey];

                  return Column(
                    children: [
                      Builder(
                          key: ValueKey(Theme.of(context).brightness),
                          builder: (context) => Text(
                            groupKey.join(
                                ", "), // Combine group key elements (if String)
                            style: Theme.of(context).textTheme.bodyLarge,
                          )),
                      const Divider(), // Optional divider between groups
                      // Display items within the group
                      groupItems != null
                          ? ListView.builder(
                        shrinkWrap:
                        true, // Prevent inner list from overflowing
                        physics:
                        const NeverScrollableScrollPhysics(), // Disable scrolling for inner list
                        itemCount: groupItems.length,
                        itemBuilder: (context, innerIndex) {
                          final item = groupItems[innerIndex];
                          return Builder(
                              key: ValueKey(Theme.of(context).brightness),
                              builder: (context) => Text(item,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge) // Display each item
                          );
                        },
                      )
                          : const Text(
                        "[ERROR] GET NULL",
                        style: TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16.0),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    minLines: 1,
                    maxLines: 5,
                    controller: promptController,
                    obscureText: false,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Prompt',
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                FloatingActionButton(
                  heroTag: "SubmitButton",
                  onPressed: _submit,
                  child: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
