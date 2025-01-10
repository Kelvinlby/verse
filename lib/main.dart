import 'package:flutter/material.dart';
import 'package:verse/process_manager.dart';
import 'package:verse/launcher.dart';
import 'package:verse/chat_page.dart';


late final List<String> arg;


void main(List<String> args) {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'verse',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ProcessManager.isRunning ? ChatPage() : Launcher()
    );
  }
}
