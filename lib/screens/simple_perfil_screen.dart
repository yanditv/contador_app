import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import '../models/SensorData.dart';
import '../services/SensorDataServices.dart';
import '../widgets/simple_marker.dart';
import '../widgets/simple_info_card.dart';

class SimplePerfilScreen extends StatefulWidget {
  const SimplePerfilScreen({super.key});

  @override
  State<SimplePerfilScreen> createState() => _SimplePerfilScreenState();
}

class _SimplePerfilScreenState extends State<SimplePerfilScreen> {
  // Controladores
  final MapController _mapController = MapController();
  final SensorDataService _sensorService = SensorDataService();

  // Variables para ubicación
  LatLng? _myLocation;
  LatLng? _sensorLocation;

  // Variables para estados
  bool _isLoadingLocation = true;
  bool _isLoadingSensor = true;
  String? _errorMessage;

  // Datos del sensor
  SensorData? _sensorData;

  // Timer para actualizar datos
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _getMyLocation();
    _startGettingSensorData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Obtener mi ubicación
  Future<void> _getMyLocation() async {
    try {
      // Pedir permisos
      final permission = await Permission.location.request();
      if (permission != PermissionStatus.granted) {
        setState(() {
          _isLoadingLocation = false;
          _errorMessage = 'Necesito permisos de ubicación';
        });
        return;
      }

      // Obtener ubicación
      Position position = await Geolocator.getCurrentPosition();

      setState(() {
        _myLocation = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
        _errorMessage = null;
      });

      // Mover el mapa a mi ubicación
      _mapController.move(_myLocation!, 15.0);
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  // Obtener datos del sensor
  void _startGettingSensorData() {
    _getSensorData();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _getSensorData();
    });
  }

  Future<void> _getSensorData() async {
    try {
      final data = await _sensorService.obtenerDatos();
      setState(() {
        _sensorData = data;
        _sensorLocation = LatLng(data.latitud, data.longitud);
        _isLoadingSensor = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSensor = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Mapa
          Expanded(flex: 2, child: _buildMap()),

          // Información
          Expanded(flex: 1, child: _buildInfo()),
        ],
      ),
    );
  }

  Widget _buildMap() {
    // Si hay error, mostrar mensaje
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 50, color: Colors.red),
            Text(_errorMessage!),
            ElevatedButton(
              onPressed: _getMyLocation,
              child: const Text('Intentar de nuevo'),
            ),
          ],
        ),
      );
    }

    // Si está cargando, mostrar indicador
    if (_isLoadingLocation) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Obteniendo ubicación...'),
          ],
        ),
      );
    }

    // Mostrar el mapa
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _myLocation ?? const LatLng(0, 0),
        initialZoom: 15.0,
      ),
      children: [
        // Capa del mapa
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        ),

        // Marcadores
        MarkerLayer(
          markers: [
            // Mi ubicación
            if (_myLocation != null)
              Marker(
                point: _myLocation!,
                width: 60,
                height: 60,
                child: const SimpleMarker(
                  color: Colors.blue,
                  icon: Icons.person,
                ),
              ),

            // Ubicación del sensor
            if (_sensorLocation != null)
              Marker(
                point: _sensorLocation!,
                width: 60,
                height: 60,
                child: const SimpleMarker(
                  color: Colors.red,
                  icon: Icons.sensors,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfo() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Información de ubicaciones
          Row(
            children: [
              Expanded(
                child: SimpleInfoCard(
                  title: 'Mi Ubicación',
                  position: _myLocation,
                  icon: Icons.person,
                  color: Colors.blue,
                  isLoading: _isLoadingLocation,
                ),
              ),
              Expanded(
                child: SimpleInfoCard(
                  title: 'Sensor',
                  position: _sensorLocation,
                  icon: Icons.sensors,
                  color: Colors.red,
                  isLoading: _isLoadingSensor,
                ),
              ),
            ],
          ),

          // Datos del sensor
          if (_sensorData != null)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSensorInfo(
                    'BPM',
                    '${_sensorData!.bpm}',
                    Icons.favorite,
                    Colors.red,
                  ),
                  _buildSensorInfo(
                    'Velocidad',
                    '${_sensorData!.velocidad} km/h',
                    Icons.speed,
                    Colors.orange,
                  ),
                  _buildSensorInfo(
                    'Satélites',
                    '${_sensorData!.satelites}',
                    Icons.satellite,
                    Colors.purple,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSensorInfo(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
