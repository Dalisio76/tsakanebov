import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/app_drawer.dart';

class MainLayoutView extends StatelessWidget {
  final Widget child;
  final String titulo;
  final List<Widget>? actions;

  const MainLayoutView({
    Key? key,
    required this.child,
    required this.titulo,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        actions: actions,
      ),
      drawer: AppDrawer(),
      body: child,
    );
  }
}
