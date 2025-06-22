import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../models/hospital.dart';
import '../services/hospital_service.dart';

class AllHospitalsMapPage extends StatefulWidget {
  const AllHospitalsMapPage({super.key});

  @override
  State<AllHospitalsMapPage> createState() => _AllHospitalsMapPageState();
}

class _AllHospitalsMapPageState extends State<AllHospitalsMapPage> {
  late Future<List<Hospital>> _hospitalsFuture;

  @override
  void initState() {
    super.initState();
    checkLocationPermission(); // ← Konum izni iste
    _hospitalsFuture = HospitalService.fetchHospitals();
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
      appBar: AppBar(title: const Text('Tüm Hastaneler - Harita')),
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
            final hospitals = snapshot.data!;
            final markers =
                hospitals.map((hospital) {
                  return Marker(
                    markerId: MarkerId(hospital.adi),
                    position: LatLng(hospital.latitude, hospital.longitude),
                    infoWindow: InfoWindow(
                      title: hospital.adi,
                      snippet: hospital.ilce,
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
