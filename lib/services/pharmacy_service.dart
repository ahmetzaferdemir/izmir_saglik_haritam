import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pharmacy.dart';

class PharmacyService {
  static Future<List<Pharmacy>> fetchPharmacies() async {
    final response = await http.get(
      Uri.parse('https://openapi.izmir.bel.tr/api/ibb/eczaneler'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> pharmacyList = json.decode(response.body);
      return pharmacyList.map((item) => Pharmacy.fromJson(item)).toList();
    } else {
      throw Exception('Eczane verisi alınamadı.');
    }
  }
}
