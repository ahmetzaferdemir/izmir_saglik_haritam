import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../models/pharmacy.dart';

class PharmacyMapPage extends StatefulWidget {
  final Pharmacy pharmacy;

  const PharmacyMapPage({required this.pharmacy, super.key});

  @override
  State<PharmacyMapPage> createState() => _PharmacyMapPageState();
}

class _PharmacyMapPageState extends State<PharmacyMapPage> {
  late LatLng pharmacyLatLng;

  @override
  void initState() {
    super.initState();
    checkLocationPermission();
    pharmacyLatLng = LatLng(
      widget.pharmacy.latitude,
      widget.pharmacy.longitude,
    );
    print(
      'Latitude: ${widget.pharmacy.latitude}, Longitude: ${widget.pharmacy.longitude}',
    );
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
      appBar: AppBar(title: Text(widget.pharmacy.adi)),
      body: GoogleMap(
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onMapCreated: (controller) {
          print('Google Map oluşturuldu');
        },
        initialCameraPosition: CameraPosition(target: pharmacyLatLng, zoom: 16),
        markers: {
          Marker(
            markerId: const MarkerId('selected_pharmacy'),
            position: pharmacyLatLng,
            infoWindow: InfoWindow(
              title: widget.pharmacy.adi,
              snippet: widget.pharmacy.adres,
            ),
          ),
        },
      ),
    );
  }
}
