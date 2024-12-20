import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_todo/pages/home/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return const MaterialApp(
      title: 'Todo App',
      debugShowCheckedModeBanner: false,
      home: HomeS(),
    );
  }
}