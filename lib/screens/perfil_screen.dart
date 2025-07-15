import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import '../models/SensorData.dart';
import '../services/SensorDataServices.dart';
import '../widgets/map_widget.dart';
import '../widgets/loading_error_widget.dart';
import '../widgets/info_panel.dart';

class PerilScreen extends StatefulWidget {
  const PerilScreen({super.key});

  @override
  State<PerilScreen> createState() => _PerilScreenState();
}

class _PerilScreenState extends State<PerilScreen> {
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
  bool _isMapReady =
      false; // Nueva variable para controlar cuándo el mapa está listo

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

      // Mover el mapa a mi ubicación solo si el mapa está listo
      _moveMapToMyLocation();
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

  // Mover el mapa a mi ubicación de forma segura
  void _moveMapToMyLocation() {
    if (_myLocation != null && _isMapReady) {
      try {
        _mapController.move(_myLocation!, 15.0);
      } catch (e) {
        print('Error al mover el mapa: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      return LoadingErrorWidget(
        isLoading: false,
        errorMessage: _errorMessage!,
        onRetry: _getMyLocation,
      );
    }

    // Si está cargando, mostrar indicador
    if (_isLoadingLocation) {
      return const LoadingErrorWidget(
        isLoading: true,
        loadingText: 'Obteniendo ubicación...',
      );
    }

    // Mostrar el mapa usando el widget
    return MapWidget(
      mapController: _mapController,
      currentPosition: _myLocation,
      sensorPosition: _sensorLocation,
      isMapReady: _isMapReady,
      onMapReady: () {
        setState(() {
          _isMapReady = true;
        });
        // Mover el mapa a mi ubicación cuando esté listo
        _moveMapToMyLocation();
      },
      onCenterLocation: _moveMapToMyLocation,
    );
  }

  Widget _buildInfo() {
    return InfoPanel(
      currentPosition: _myLocation,
      sensorPosition: _sensorLocation,
      isLoadingLocation: _isLoadingLocation,
      isLoadingSensorData: _isLoadingSensor,
      sensorData: _sensorData,
    );
  }
}
