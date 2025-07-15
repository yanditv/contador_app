import 'dart:convert';

SensorData sersorDataFromJson(String str) =>
    SensorData.fromJson(json.decode(str));

String sersorDataToJson(SensorData data) => json.encode(data.toJson());

class SensorData {
  double ecg;
  int bpm;
  double latitud;
  double longitud;
  int velocidad;
  int satelites;

  SensorData({
    required this.ecg,
    required this.bpm,
    required this.latitud,
    required this.longitud,
    required this.velocidad,
    required this.satelites,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) => SensorData(
    ecg: json["ecg"]?.toDouble(),
    bpm: json["bpm"],
    latitud: json["latitud"]?.toDouble(),
    longitud: json["longitud"]?.toDouble(),
    velocidad: json["velocidad"],
    satelites: json["satelites"],
  );

  Map<String, dynamic> toJson() => {
    "ecg": ecg,
    "bpm": bpm,
    "latitud": latitud,
    "longitud": longitud,
    "velocidad": velocidad,
    "satelites": satelites,
  };
}
