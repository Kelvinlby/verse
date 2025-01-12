import 'package:flutter/material.dart';
import 'package:verse/process_manager.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_markdown_latex/flutter_markdown_latex.dart';


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
  final List<Map<String, String?>> _chats = [];
  bool _prompting = true;
  String _response = '';

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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
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
                              child: _markdownRenderer(prompt),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            child: response == null
                              ? LinearProgressIndicator()
                              : _markdownRenderer(response),
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

  Widget _markdownRenderer(String text) => MarkdownBody(
    selectable: true,
    data: text,
    styleSheet: MarkdownStyleSheet(
      p: const TextStyle(fontSize: 18.0, fontFamily: 'Ubuntu'),
      h1: const TextStyle(fontSize: 26.0, fontFamily: 'Ubuntu Bold'),
      h2: const TextStyle(fontSize: 24.0, fontFamily: 'Ubuntu Bold'),
      h3: const TextStyle(fontSize: 22.0, fontFamily: 'Ubuntu Bold'),
      h4: const TextStyle(fontSize: 20.0, fontFamily: 'Ubuntu Bold'),
      code: const TextStyle(fontSize: 18.0, fontFamily: 'JetBrains Mono'),
    ),
    builders: {
      'latex': LatexElementBuilder(
        textStyle: const TextStyle(fontFamily: 'Ubuntu', fontSize: 18),
        textScaleFactor: 1.2,
      ),
    },
    extensionSet: md.ExtensionSet(
      [LatexBlockSyntax()],
      [LatexInlineSyntax()],
    ),
  );

  void _submit() {
    String prompt = promptController.text;

    if (prompt.isEmpty) return;

    prompt = prompt.trim();
    promptController.clear();

    setState(() {
      _prompting = false;
      _chats.add({prompt: null});
    });

    ProcessManager.input(prompt);
  }

  void _listener(String answer) {
    _response = _response + answer;

    if (answer.contains('\\end')) {
      _response = _response.replaceAll('\\end', '');

      setState(() {
        _chats.last = {_chats.last.keys.first: _response.trim()};
        _prompting = true;
      });

      _response = '';
    }
    else {
      setState(() {
        _chats.last = {_chats.last.keys.first: _response.trim()};
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    });
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
