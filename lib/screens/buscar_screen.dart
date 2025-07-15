import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:async';
import '../models/SensorData.dart';
import '../services/SensorDataServices.dart';

class BuscarScreen extends StatefulWidget {
  const BuscarScreen({super.key});

  @override
  State<BuscarScreen> createState() => _BuscarScreenState();
}

class _BuscarScreenState extends State<BuscarScreen> {
  final SensorDataService _sensorService = SensorDataService();
  Timer? _timer;

  // Listas para almacenar datos históricos
  List<ECGData> ecgDataPoints = [];
  List<BPMData> bpmDataPoints = [];

  // Estado actual de los sensores
  SensorData? currentSensorData;
  bool isLoading = true;
  String? errorMessage;

  // Contador de tiempo para el eje X
  int timeIndex = 0;

  // Configuración de la ventana de datos (últimos 30 segundos para ECG, 60 para BPM)
  static const int maxECGDataPoints = 30;
  static const int maxBPMDataPoints = 60;

  @override
  void initState() {
    super.initState();
    _startDataUpdates();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startDataUpdates() {
    // Obtener datos iniciales
    _fetchSensorData();

    // Configurar timer para actualizar cada segundo
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _fetchSensorData();
    });
  }

  Future<void> _fetchSensorData() async {
    try {
      final data = await _sensorService.obtenerDatos();

      setState(() {
        currentSensorData = data;
        isLoading = false;
        errorMessage = null;

        // Agregar nuevos puntos de datos
        ecgDataPoints.add(ECGData(timeIndex, data.ecg));
        bpmDataPoints.add(BPMData(timeIndex, data.bpm.toDouble()));

        // Mantener solo los últimos N puntos
        if (ecgDataPoints.length > maxECGDataPoints) {
          ecgDataPoints.removeAt(0);
        }
        if (bpmDataPoints.length > maxBPMDataPoints) {
          bpmDataPoints.removeAt(0);
        }

        timeIndex++;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error al obtener datos: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Conectando con sensores médicos...'),
                ],
              ),
            )
          : errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text(
                    errorMessage!,
                    style: TextStyle(color: Colors.red[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isLoading = true;
                        errorMessage = null;
                      });
                      _fetchSensorData();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Indicadores vitales actuales
                  _buildVitalSignsCard(),
                  const SizedBox(height: 20),

                  // Gráfico ECG
                  _buildECGChart(),
                  const SizedBox(height: 20),

                  // Gráfico BPM
                  _buildBPMChart(),
                  const SizedBox(height: 20),

                  // Información adicional del sensor
                  _buildSensorInfoCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildVitalSignsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.favorite, color: Colors.red[600]),
                const SizedBox(width: 8),
                const Text(
                  'Signos Vitales',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildVitalIndicator(
                    'BPM',
                    '${currentSensorData?.bpm ?? 0}',
                    'latidos/min',
                    Colors.red[600]!,
                    Icons.favorite,
                  ),
                ),
                Expanded(
                  child: _buildVitalIndicator(
                    'ECG',
                    '${currentSensorData?.ecg.toStringAsFixed(2) ?? "0.00"}',
                    'mV',
                    Colors.blue[600]!,
                    Icons.monitor_heart,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalIndicator(
    String title,
    String value,
    String unit,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            unit,
            style: TextStyle(fontSize: 12, color: color.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildECGChart() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.monitor_heart, color: Colors.blue[600]),
                const SizedBox(width: 8),
                const Text(
                  'Electrocardiograma (ECG)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: SfCartesianChart(
                primaryXAxis: NumericAxis(
                  title: AxisTitle(text: 'Tiempo (segundos)'),
                  majorGridLines: const MajorGridLines(width: 0.5),
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(text: 'Amplitud (mV)'),
                  majorGridLines: const MajorGridLines(width: 0.5),
                ),
                plotAreaBorderWidth: 1,
                series: <CartesianSeries>[
                  LineSeries<ECGData, int>(
                    dataSource: ecgDataPoints,
                    xValueMapper: (ECGData data, _) => data.time,
                    yValueMapper: (ECGData data, _) => data.voltage,
                    name: 'ECG',
                    color: Colors.blue[600],
                    width: 2,
                    animationDuration: 0,
                  ),
                ],
                tooltipBehavior: TooltipBehavior(enable: true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBPMChart() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.favorite, color: Colors.red[600]),
                const SizedBox(width: 8),
                const Text(
                  'Frecuencia Cardíaca (BPM)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: SfCartesianChart(
                primaryXAxis: NumericAxis(
                  title: AxisTitle(text: 'Tiempo (segundos)'),
                  majorGridLines: const MajorGridLines(width: 0.5),
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(text: 'BPM'),
                  minimum: 50,
                  maximum: 120,
                  majorGridLines: const MajorGridLines(width: 0.5),
                ),
                plotAreaBorderWidth: 1,
                series: <CartesianSeries>[
                  LineSeries<BPMData, int>(
                    dataSource: bpmDataPoints,
                    xValueMapper: (BPMData data, _) => data.time,
                    yValueMapper: (BPMData data, _) => data.bpm,
                    name: 'BPM',
                    color: Colors.red[600],
                    width: 3,
                    animationDuration: 0,
                    markerSettings: const MarkerSettings(
                      isVisible: true,
                      height: 4,
                      width: 4,
                    ),
                  ),
                ],
                tooltipBehavior: TooltipBehavior(enable: true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorInfoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey[600]),
                const SizedBox(width: 8),
                const Text(
                  'Información del Sensor',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Ubicación',
                    '${currentSensorData?.latitud.toStringAsFixed(6)}, ${currentSensorData?.longitud.toStringAsFixed(6)}',
                    Icons.location_on,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Velocidad',
                    '${currentSensorData?.velocidad ?? 0} km/h',
                    Icons.speed,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Satélites',
                    '${currentSensorData?.satelites ?? 0}',
                    Icons.satellite,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// Clases de datos para los gráficos
class ECGData {
  final int time;
  final double voltage;

  ECGData(this.time, this.voltage);
}

class BPMData {
  final int time;
  final double bpm;

  BPMData(this.time, this.bpm);
}
