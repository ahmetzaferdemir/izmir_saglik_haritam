import 'package:flutter/material.dart';
import '../models/pharmacy.dart';
import '../services/pharmacy_service.dart';
import 'pharmacy_map_page.dart';

class PharmacyListPage extends StatefulWidget {
  const PharmacyListPage({super.key});

  @override
  State<PharmacyListPage> createState() => _PharmacyListPageState();
}

class _PharmacyListPageState extends State<PharmacyListPage> {
  late Future<List<Pharmacy>> _pharmaciesFuture;
  List<Pharmacy> _allPharmacies = [];
  List<Pharmacy> _filteredPharmacies = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pharmaciesFuture = PharmacyService.fetchPharmacies();
    _pharmaciesFuture.then((pharmacies) {
      setState(() {
        _allPharmacies = pharmacies;
        _filteredPharmacies = pharmacies;
      });
    });
    _searchController.addListener(_filterPharmacies);
  }

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

  void _filterPharmacies() {
    final query = normalizeTurkish(_searchController.text);
    setState(() {
      _filteredPharmacies =
          _allPharmacies.where((pharmacy) {
            final normalizedAdi = normalizeTurkish(pharmacy.adi);
            final normalizedAdres = normalizeTurkish(pharmacy.adres);
            return normalizedAdi.contains(query) ||
                normalizedAdres.contains(query);
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
      appBar: AppBar(title: const Text('İzmir Eczaneleri')),
      body: FutureBuilder<List<Pharmacy>>(
        future: _pharmaciesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Eczane verisi bulunamadı.'));
          } else {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Eczane veya Adres Ara',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredPharmacies.length,
                    itemBuilder: (context, index) {
                      final pharmacy = _filteredPharmacies[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(pharmacy.adi),
                          subtitle: Text(pharmacy.adres),
                          trailing: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          PharmacyMapPage(pharmacy: pharmacy),
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
