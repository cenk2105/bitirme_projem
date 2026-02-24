import 'package:borsauygulamasi/screens/user_process/login_page.dart';
import 'package:flutter/material.dart';

void main(List<String> args) {
  runApp(Uygulama());
}

class Uygulama extends StatelessWidget {
  const Uygulama({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: LoginPage());
  }
}
