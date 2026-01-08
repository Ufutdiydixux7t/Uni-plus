import 'package:flutter/material.dart';
import 'app_drawer.dart';

class DrawerScaffold extends StatelessWidget {
  final Widget body;
  final Color backgroundColor;

  const DrawerScaffold({
    super.key,
    required this.body,
    this.backgroundColor = const Color(0xFFF6F7FB),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      drawerEnableOpenDragGesture: true,
      drawerEdgeDragWidth: 60, // تحسين السحب
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Builder(
          builder: (context) => body,
        ),
      ),
    );
  }
}