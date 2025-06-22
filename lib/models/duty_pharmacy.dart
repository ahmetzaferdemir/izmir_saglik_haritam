class DutyPharmacy {
  final String adi;
  final String adres;
  final String? bolge;
  final String? bolgeAciklama;
  final double? lokasyonX;
  final double? lokasyonY;

  DutyPharmacy({
    required this.adi,
    required this.adres,
    required this.bolge,
    required this.bolgeAciklama,
    required this.lokasyonY,
    required this.lokasyonX,
  });

  factory DutyPharmacy.fromJson(Map<String, dynamic> json) {
    return DutyPharmacy(
      adi: json['Adi'] ?? '',
      adres: json['Adres'] ?? '',
      bolge: json['Bolge'],
      bolgeAciklama: json['BolgeAciklama'],

      lokasyonY:
          (json['LokasyonY'] is double)
              ? json['LokasyonY']
              : double.tryParse(json['LokasyonY'].toString()),
      lokasyonX:
          (json['LokasyonX'] is double)
              ? json['LokasyonX']
              : double.tryParse(json['LokasyonX'].toString()),
    );
  }
}
