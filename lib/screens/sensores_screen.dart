import 'package:contador_app/services/SensorDataServices.dart';
import 'package:flutter/material.dart';

class SensoresScreen extends StatefulWidget {
  const SensoresScreen({super.key});

  @override
  State<SensoresScreen> createState() => _SensoresScreenState();
}

class _SensoresScreenState extends State<SensoresScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: SensorDataService().obtenerDatos(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error al obtener los datos"));
            } else if (snapshot.hasData) {
              final data = snapshot.data;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: size.width,
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Datos del Sensor",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text("ECG: ${data?.ecg}"),
                          Text("BPM: ${data?.bpm}"),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: size.width,
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Ubicación",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text("Latitud: ${data?.latitud}"),
                          Text("Longitud: ${data?.longitud}"),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: size.width,
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Datos de Navegación",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text("Velocidad: ${data?.velocidad} km/h"),
                          Text("Satelites: ${data?.satelites}"),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Center(child: Text("No hay datos"));
            }
          },
        ),
      ),
    );
  }
}
