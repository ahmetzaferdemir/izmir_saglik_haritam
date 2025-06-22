import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../models/pharmacy.dart';
import '../services/pharmacy_service.dart';

class AllPharmaciesMapPage extends StatefulWidget {
  const AllPharmaciesMapPage({super.key});

  @override
  State<AllPharmaciesMapPage> createState() => _AllPharmaciesMapPageState();
}

class _AllPharmaciesMapPageState extends State<AllPharmaciesMapPage> {
  late Future<List<Pharmacy>> _pharmaciesFuture;

  @override
  void initState() {
    super.initState();
    checkLocationPermission(); // ← Konum izni
    _pharmaciesFuture = PharmacyService.fetchPharmacies();
  }

  Future<void> checkLocationPermission() async {
    Location location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tüm Eczaneler - Harita')),
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
            final pharmacies = snapshot.data!;
            final markers =
                pharmacies.map((pharmacy) {
                  return Marker(
                    markerId: MarkerId(pharmacy.adi),
                    position: LatLng(pharmacy.latitude, pharmacy.longitude),
                    infoWindow: InfoWindow(
                      title: pharmacy.adi,
                      snippet: pharmacy.adres,
                    ),
                  );
                }).toSet();

            return GoogleMap(
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: (controller) {
                print('Google Map oluşturuldu');
              },
              initialCameraPosition: const CameraPosition(
                target: LatLng(38.4192, 27.1287), // İzmir merkez
                zoom: 10,
              ),
              markers: markers,
            );
          }
        },
      ),
    );
  }
}
