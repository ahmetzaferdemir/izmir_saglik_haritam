import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/duty_pharmacy.dart';

class DutyPharmacyMapPage extends StatelessWidget {
  final DutyPharmacy pharmacy;

  const DutyPharmacyMapPage({super.key, required this.pharmacy});

  @override
  Widget build(BuildContext context) {
    final LatLng position = LatLng(
      pharmacy.lokasyonX ?? 0,
      pharmacy.lokasyonY ?? 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(pharmacy.adi),
        backgroundColor: const Color.fromRGBO(227, 23, 36, 1),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: position, zoom: 15),
        markers: {
          Marker(
            markerId: const MarkerId('duty_pharmacy'),
            position: position,
            infoWindow: InfoWindow(
              title: pharmacy.adi,
              snippet: pharmacy.adres,
            ),
          ),
        },
      ),
    );
  }
}
