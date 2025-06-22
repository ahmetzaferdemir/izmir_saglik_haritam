import 'package:flutter/material.dart';
import '../models/duty_pharmacy.dart';
import '../services/duty_pharmacy_service.dart';
import 'duty_pharmacy_map_page.dart';

class DutyPharmacyListPage extends StatefulWidget {
  const DutyPharmacyListPage({super.key});

  @override
  State<DutyPharmacyListPage> createState() => _DutyPharmacyListPageState();
}

class _DutyPharmacyListPageState extends State<DutyPharmacyListPage> {
  late Future<List<DutyPharmacy>> _dutyPharmaciesFuture;
  List<DutyPharmacy> _allPharmacies = [];
  List<DutyPharmacy> _filteredPharmacies = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dutyPharmaciesFuture = DutyPharmacyService.fetchDutyPharmacies();
    _dutyPharmaciesFuture.then((pharmacies) {
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
            final bolge = normalizeTurkish(pharmacy.bolge ?? '');
            final adi = normalizeTurkish(pharmacy.adi);
            final adres = normalizeTurkish(pharmacy.adres);
            final bolgeAciklama = normalizeTurkish(
              pharmacy.bolgeAciklama ?? '',
            );

            return bolge.contains(query) ||
                adi.contains(query) ||
                adres.contains(query) ||
                bolgeAciklama.contains(query);
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
      appBar: AppBar(
        title: const Text('Nöbetçi Eczaneler'),
        backgroundColor: const Color.fromRGBO(227, 23, 36, 1),
      ),
      body: FutureBuilder<List<DutyPharmacy>>(
        future: _dutyPharmaciesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Veri bulunamadı.'));
          } else {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Bölgeye göre ara (örn: Karşıyaka)',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child:
                      _filteredPharmacies.isEmpty
                          ? const Center(
                            child: Text(
                              'Bölgeye göre eşleşen eczane bulunamadı.',
                            ),
                          )
                          : ListView.builder(
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
                                    backgroundColor: Colors.red,
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  title: Text(pharmacy.adi),
                                  subtitle: Text(pharmacy.adres),
                                  trailing: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromRGBO(
                                        227,
                                        23,
                                        36,
                                        1,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => DutyPharmacyMapPage(
                                                pharmacy: pharmacy,
                                              ),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Haritada Gör',
                                      style: TextStyle(color: Colors.white),
                                    ),
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
