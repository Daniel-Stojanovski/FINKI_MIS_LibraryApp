import 'package:flutter/material.dart';
import 'package:library_app/auth.dart';
import 'package:library_app/main.dart';
import 'package:library_app/pages/login_register.dart';

class WidgetTree extends StatefulWidget {
  final String? userEmail;

  const WidgetTree({Key? key, this.userEmail}) : super(key: key);

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return BooksLibraryApp(
            userEmail: widget.userEmail,
            books: [],
          );
        } else {
          return LoginPage();
        }
      },
    );
  }
}
