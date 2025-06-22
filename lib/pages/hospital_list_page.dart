import 'package:flutter/material.dart';
import '../models/hospital.dart';
import '../services/hospital_service.dart';
import 'hospital_map_page.dart';

class HospitalListPage extends StatefulWidget {
  const HospitalListPage({super.key});

  @override
  State<HospitalListPage> createState() => _HospitalListPageState();
}

class _HospitalListPageState extends State<HospitalListPage> {
  late Future<List<Hospital>> _hospitalsFuture;
  List<Hospital> _allHospitals = [];
  List<Hospital> _filteredHospitals = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _hospitalsFuture = HospitalService.fetchHospitals();
    _hospitalsFuture.then((hospitals) {
      setState(() {
        _allHospitals = hospitals;
        _filteredHospitals = hospitals;
      });
    });
    _searchController.addListener(_filterHospitals);
  }

  // BURASI → Türkçe karakterleri normalize eden fonksiyon
  String normalizeTurkish(String text) {
    return text
        .toLowerCase()
        .replaceAll('ç', 'c')
        .replaceAll('ğ', 'g')
        .replaceAll('ı', 'i')
        .replaceAll('ö', 'o')
        .replaceAll('ş', 's')
        .replaceAll('ü', 'u');
  }

  void _filterHospitals() {
    final query = normalizeTurkish(_searchController.text);
    setState(() {
      _filteredHospitals =
          _allHospitals.where((hospital) {
            final normalizedAdi = normalizeTurkish(hospital.adi);
            final normalizedIlce = normalizeTurkish(hospital.ilce);
            return normalizedAdi.contains(query) ||
                normalizedIlce.contains(query);
          }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('İzmir Hastaneleri')),
      body: FutureBuilder<List<Hospital>>(
        future: _hospitalsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Hastane verisi bulunamadı.'));
          } else {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Hastane veya İlçe Ara',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredHospitals.length,
                    itemBuilder: (context, index) {
                      final hospital = _filteredHospitals[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(hospital.adi),
                          subtitle: Text('İlçe: ${hospital.ilce}'),
                          trailing: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          HospitalMapPage(hospital: hospital),
                                ),
                              );
                            },
                            child: const Text('Haritada Gör'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
