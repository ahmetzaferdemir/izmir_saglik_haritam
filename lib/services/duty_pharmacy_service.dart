import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/duty_pharmacy.dart';

class DutyPharmacyService {
  static Future<List<DutyPharmacy>> fetchDutyPharmacies() async {
    const url = 'https://openapi.izmir.bel.tr/api/ibb/nobetcieczaneler';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => DutyPharmacy.fromJson(json)).toList();
    } else {
      throw Exception('Nöbetçi eczane verileri alınamadı');
    }
  }
}
