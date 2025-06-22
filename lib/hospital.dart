class Hospital {
  final String adi;
  final String ilce;
  final double latitude;
  final double longitude;

  Hospital({
    required this.adi,
    required this.ilce,
    required this.latitude,
    required this.longitude,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      adi: json['ADI'] ?? '',
      ilce: json['ILCE'] ?? '',
      latitude: (json['ENLEM'] ?? 0).toDouble(),
      longitude: (json['BOYLAM'] ?? 0).toDouble(),
    );
  }
}
