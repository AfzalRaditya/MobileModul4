// lib/app/modules/katalog/rotating_logo.dart

import 'package:flutter/material.dart';

class RotatingLogo extends StatefulWidget {
  const RotatingLogo({super.key});

  @override
  RotatingLogoState createState() => RotatingLogoState();
}

class RotatingLogoState extends State<RotatingLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller; 

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(); // Kontrol manual: repeat
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Icon(
        Icons.inventory_2, 
        size: 80, 
        color: Colors.brown[700],
      ),
    );
  }
}