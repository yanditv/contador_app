import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

// Widget simple para mostrar información de ubicación
class SimpleInfoCard extends StatelessWidget {
  final String title;
  final LatLng? position;
  final IconData icon;
  final Color color;
  final bool isLoading;

  const SimpleInfoCard({
    super.key,
    required this.title,
    required this.position,
    required this.icon,
    required this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          // Título con icono
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Información de ubicación
          if (isLoading)
            const Text('Cargando...')
          else if (position != null)
            Column(
              children: [
                Text('Lat: ${position!.latitude.toStringAsFixed(4)}'),
                Text('Lng: ${position!.longitude.toStringAsFixed(4)}'),
              ],
            )
          else
            const Text('No disponible'),
        ],
      ),
    );
  }
}
