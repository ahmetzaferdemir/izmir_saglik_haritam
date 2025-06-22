import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'hospital_list_page.dart';
import 'pharmacy_list_page.dart';
import 'all_hospitals_map_page.dart';
import 'all_pharmacies_map_page.dart';
import 'duty_pharmacy_list_page.dart';
import 'login_page.dart';
import '../services/duty_pharmacy_service.dart';
import 'package:geolocator/geolocator.dart';
import '../models/duty_pharmacy.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final Animation<double> _logoAnimation;

  Future<void> _findNearestDutyPharmacy() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Konum izni reddedildi');
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<DutyPharmacy> pharmacies =
          await DutyPharmacyService.fetchDutyPharmacies();

      DutyPharmacy? nearest;
      double minDistance = double.infinity;

      for (var pharmacy in pharmacies) {
        if (pharmacy.lokasyonY != null && pharmacy.lokasyonX != null) {
          double distance = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            pharmacy.lokasyonX!,
            pharmacy.lokasyonY!,
          );
          if (distance < minDistance) {
            minDistance = distance;
            nearest = pharmacy;
          }
        }
      }

      if (nearest != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('En yakın nöbetçi eczane: ${nearest.adi}')),
        );

        _openPharmacyMap(nearest);
      } else {
        throw 'Nöbetçi eczane bulunamadı';
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _openPharmacyMap(DutyPharmacy pharmacy) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => Scaffold(
              appBar: AppBar(title: Text(pharmacy.adi)),
              body: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(pharmacy.lokasyonX!, pharmacy.lokasyonY!),
                  zoom: 16,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('pharmacy_marker'),
                    position: LatLng(pharmacy.lokasyonX!, pharmacy.lokasyonY!),
                    infoWindow: InfoWindow(title: pharmacy.adi),
                  ),
                },
              ),
            ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    );
    _logoController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(227, 23, 36, 1),
        elevation: 2,
        centerTitle: true,
        toolbarHeight: 80,
        title: Image.asset(
          'assets/logo_1.png',
          height: 110,
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.22,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FadeTransition(
                opacity: _logoAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(height: 10),
                    Text(
                      'İzmir Sağlık Haritam\'a Hoş Geldin',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'İzmir\'deki tüm hastaneler ve eczaneler bir tık uzağınızda!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildMenuCard(
                  icon: Icons.local_hospital,
                  label: 'Hastaneleri Görüntüle',
                  page: const HospitalListPage(),
                ),
                const SizedBox(height: 20),
                _buildMenuCard(
                  icon: Icons.local_pharmacy,
                  label: 'Eczaneleri Görüntüle',
                  page: const PharmacyListPage(),
                ),
                const SizedBox(height: 20),
                _buildMenuCard(
                  icon: Icons.map,
                  label: 'Tüm Hastane Konumları',
                  page: const AllHospitalsMapPage(),
                ),
                const SizedBox(height: 20),
                _buildMenuCard(
                  icon: Icons.location_on,
                  label: 'Tüm Eczane Konumları',
                  page: const AllPharmaciesMapPage(),
                ),
                const SizedBox(height: 20),
                _buildMenuCard(
                  icon: Icons.medical_services,
                  label: 'Nöbetçi Eczaneleri Görüntüle',
                  page: const DutyPharmacyListPage(),
                ),
                const SizedBox(height: 20),
                _buildNearestPharmacyCard(),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String label,
    required Widget page,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFFF9F9F9), Colors.white],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: Colors.red.shade700),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 22,
              color: Colors.black54,
            ),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildNearestPharmacyCard() {
    return GestureDetector(
      onTap: _findNearestDutyPharmacy,
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFFF9F9F9), Colors.white],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_pharmacy,
                size: 40,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(width: 24),
            const Expanded(
              child: Text(
                'En Yakın Eczaneye Git',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 22,
              color: Colors.black54,
            ),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }
}
