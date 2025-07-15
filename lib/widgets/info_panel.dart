import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/SensorData.dart';
import 'location_info_card.dart';
import 'medical_info_widget.dart';

class InfoPanel extends StatelessWidget {
  final LatLng? currentPosition;
  final LatLng? sensorPosition;
  final bool isLoadingLocation;
  final bool isLoadingSensorData;
  final SensorData? sensorData;

  const InfoPanel({
    super.key,
    required this.currentPosition,
    required this.sensorPosition,
    required this.isLoadingLocation,
    required this.isLoadingSensorData,
    this.sensorData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicador de arrastre
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          _buildLocationCards(),

          if (sensorData != null) ...[
            const SizedBox(height: 16),
            _buildMedicalInfo(),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationCards() {
    return Row(
      children: [
        // Información de ubicación actual
        Expanded(
          child: LocationInfoCard(
            title: 'Mi Ubicación',
            position: currentPosition,
            icon: Icons.my_location,
            color: Colors.blue,
            isLoading: isLoadingLocation,
          ),
        ),
        const SizedBox(width: 12),

        // Información del sensor
        Expanded(
          child: LocationInfoCard(
            title: 'Sensor',
            position: sensorPosition,
            icon: Icons.sensors,
            color: Colors.red,
            isLoading: isLoadingSensorData,
          ),
        ),
      ],
    );
  }

  Widget _buildMedicalInfo() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          MedicalInfoWidget(
            label: 'BPM',
            value: '${sensorData!.bpm}',
            icon: Icons.favorite,
            color: Colors.red,
          ),
          MedicalInfoWidget(
            label: 'Velocidad',
            value: '${sensorData!.velocidad} km/h',
            icon: Icons.speed,
            color: Colors.orange,
          ),
          MedicalInfoWidget(
            label: 'Satélites',
            value: '${sensorData!.satelites}',
            icon: Icons.satellite,
            color: Colors.purple,
          ),
        ],
      ),
    );
  }
}
