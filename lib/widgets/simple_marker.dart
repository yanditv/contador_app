import 'package:flutter/material.dart';

// Widget simple para mostrar un marcador en el mapa
class SimpleMarker extends StatelessWidget {
  final Color color;
  final IconData icon;

  const SimpleMarker({super.key, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Icon(icon, color: color, size: 30),
    );
  }
}
