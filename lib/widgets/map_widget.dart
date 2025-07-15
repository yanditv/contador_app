import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapWidget extends StatelessWidget {
  final MapController mapController;
  final LatLng? currentPosition;
  final LatLng? sensorPosition;
  final bool isMapReady;
  final VoidCallback onMapReady;
  final VoidCallback? onCenterLocation;

  const MapWidget({
    super.key,
    required this.mapController,
    required this.currentPosition,
    required this.sensorPosition,
    required this.isMapReady,
    required this.onMapReady,
    this.onCenterLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: currentPosition ?? const LatLng(0, 0),
            initialZoom: 15.0,
            minZoom: 5.0,
            maxZoom: 18.0,
            onMapReady: onMapReady,
          ),
          children: [
            // Capa del mapa
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.contador_app',
              maxZoom: 19,
            ),

            // Marcadores
            MarkerLayer(
              markers: [
                // Marcador de posición actual del usuario
                if (currentPosition != null)
                  Marker(
                    point: currentPosition!,
                    width: 60,
                    height: 60,
                    child: _buildSimpleMarker(Colors.blue, Icons.person),
                  ),

                // Marcador de posición del sensor
                if (sensorPosition != null)
                  Marker(
                    point: sensorPosition!,
                    width: 60,
                    height: 60,
                    child: _buildSimpleMarker(Colors.red, Icons.sensors),
                  ),
              ],
            ),

            // Círculo de precisión alrededor de la posición actual
            if (currentPosition != null)
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: currentPosition!,
                    radius: 100,
                    useRadiusInMeter: true,
                    color: Colors.blue.withOpacity(0.1),
                    borderColor: Colors.blue.withOpacity(0.3),
                    borderStrokeWidth: 2,
                  ),
                ],
              ),
          ],
        ),

        // Botón para centrar en mi ubicación
        if (currentPosition != null && onCenterLocation != null)
          Positioned(
            right: 16,
            bottom: 20,
            child: FloatingActionButton(
              mini: true,
              onPressed: onCenterLocation,
              backgroundColor: Colors.blue,
              heroTag: "centerLocation",
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
      ],
    );
  }

  // Widget simple para mostrar un marcador
  Widget _buildSimpleMarker(Color color, IconData icon) {
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
