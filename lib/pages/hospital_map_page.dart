import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/hospital.dart';
import 'package:location/location.dart';

class HospitalMapPage extends StatefulWidget {
  final Hospital hospital;

  const HospitalMapPage({required this.hospital, super.key});

  @override
  State<HospitalMapPage> createState() => _HospitalMapPageState();
}

class _HospitalMapPageState extends State<HospitalMapPage> {
  late LatLng hospitalLatLng;

  @override
  void initState() {
    super.initState();
    checkLocationPermission();
    hospitalLatLng = LatLng(
      widget.hospital.latitude,
      widget.hospital.longitude,
    );
    print(
      'Latitude: ${widget.hospital.latitude}, Longitude: ${widget.hospital.longitude}',
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
      appBar: AppBar(title: Text(widget.hospital.adi)),
      body: GoogleMap(
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onMapCreated: (controller) {
          print('Google Map oluşturuldu');
        },
        initialCameraPosition: CameraPosition(target: hospitalLatLng, zoom: 16),
        markers: {
          Marker(
            markerId: const MarkerId('selected_hospital'),
            position: hospitalLatLng,
            infoWindow: InfoWindow(
              title: widget.hospital.adi,
              snippet: widget.hospital.ilce,
            ),
          ),
        },
      ),
    );
  }
}
