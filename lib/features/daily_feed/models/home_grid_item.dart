import 'package:flutter/material.dart';

class HomeGridItem {
  final String title;
  final IconData icon;
  final String category;
  final VoidCallback? customOnTap;

  const HomeGridItem({
    required this.title,
    required this.icon,
    required this.category,
    this.customOnTap,
  });
}
