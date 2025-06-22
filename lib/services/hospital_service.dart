import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/hospital.dart';

class HospitalService {
  static Future<List<Hospital>> fetchHospitals() async {
    final response = await http.get(
      Uri.parse('https://openapi.izmir.bel.tr/api/ibb/cbs/hastaneler'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonBody = json.decode(response.body);
      final List<dynamic> hospitalList = jsonBody['onemliyer'];

      return hospitalList.map((item) => Hospital.fromJson(item)).toList();
    } else {
      throw Exception('Hastane verisi alınamadı.');
    }
  }
}
