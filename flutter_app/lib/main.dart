import 'package:exam_app/screens/HomeScreen.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp (
        title: "Exam App",
        theme: ThemeData(
            primarySwatch: Colors.blue
        ),
        home: HomeScreen()
    );
  }
}