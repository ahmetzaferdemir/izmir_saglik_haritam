class Pharmacy {
  final String adi;
  final String adres;
  final double latitude;
  final double longitude;

  Pharmacy({
    required this.adi,
    required this.adres,
    required this.latitude,
    required this.longitude,
  });

  factory Pharmacy.fromJson(Map<String, dynamic> json) {
    return Pharmacy(
      adi: json['Adi'] ?? '',
      adres: json['Adres'] ?? '',
      latitude: double.tryParse(json['LokasyonX'] ?? '0') ?? 0.0,
      longitude: double.tryParse(json['LokasyonY'] ?? '0') ?? 0.0,
    );
  }
}
