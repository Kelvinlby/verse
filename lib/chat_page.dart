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
  final List<Map<String, String>> _chats = [];
  bool _prompting = true;

  @override
  void initState() {
    super.initState();
    ProcessManager.stop();
    ProcessManager.start(widget.interpreterPath, widget.scriptPath, widget.env, listener: _listener, finish: _quit, error: _alert);
  }

  @override
  void dispose() {
    ProcessManager.stop();
    super.dispose();
  }
  
  Widget _promptField() {
    return Row(
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
          onPressed: _submit,
          child: const Icon(Icons.send_rounded),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
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
                final prompt = _chats[index].keys.first;
                final response = _chats[index].values.first;

                return Column(
                  children: [

                    const SizedBox(height: 16),
                    Card.outlined(
                      color: Theme.of(context).colorScheme.onSecondaryFixed,
                      margin: EdgeInsets.zero,
                      child: Column(
                        children: [
                          Card(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            margin: EdgeInsets.zero,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                prompt,
                                style: const TextStyle(
                                  fontFamily: 'Ubuntu',
                                  fontSize: 18,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              response,
                              style: const TextStyle(
                                fontFamily: 'Ubuntu',
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      )
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16.0),
          _prompting ? _promptField() : Container()
        ],
      ),
    ),
  );

  void _submit() {
    String prompt = promptController.text;

    if (prompt.isEmpty) return;

    prompt = prompt.trim();
    promptController.clear();

    // TODO get model response
    setState(() {
      _chats.add({prompt: 'ans'});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    });
    
    // _prompting = false;
  }

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
}
