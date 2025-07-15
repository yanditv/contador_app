import 'dart:convert';
import 'package:contador_app/models/SensorData.dart';
import 'package:http/http.dart' as http;

class SensorDataService {
  Future<SensorData> obtenerDatos() async {
    final url = Uri.parse("https://sistemas-biomedicos.vercel.app/data");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return SensorData.fromJson(data);
    } else {
      throw Exception("Error al obtener los datos del sensor");
    }
  }
}
