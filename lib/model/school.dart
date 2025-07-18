class School {
  final String kodeProp;
  final String propinsi;
  final String kodeKabKota;
  final String kabupatenKota;
  final String kodeKec;
  final String kecamatan;
  final String id;
  final String npsn;
  final String sekolah;
  final String bentuk;
  final String status;
  final String alamatJalan;
  final String lintang;
  final String bujur;
  final DateTime expiryDate;  // Added expiryDate property

  School({
    required this.kodeProp,
    required this.propinsi,
    required this.kodeKabKota,
    required this.kabupatenKota,
    required this.kodeKec,
    required this.kecamatan,
    required this.id,
    required this.npsn,
    required this.sekolah,
    required this.bentuk,
    required this.status,
    required this.alamatJalan,
    required this.lintang,
    required this.bujur,
    required this.expiryDate,  // Include expiryDate in the constructor
  });

  // Factory constructor to create School object from JSON
  factory School.fromJson(Map<dynamic, dynamic> json) {
    // Default expiry date is next year
    DateTime expiry = DateTime.now().add(Duration(days: 365));  // Next year

    return School(
      kodeProp: json['kode_prop'] ?? '',
      propinsi: json['propinsi'] ?? '',
      kodeKabKota: json['kode_kab_kota'] ?? '',
      kabupatenKota: json['kabupaten_kota'] ?? '',
      kodeKec: json['kode_kec'] ?? '',
      kecamatan: json['kecamatan'] ?? '',
      id: json['id'] ?? '',
      npsn: json['npsn'] ?? '',
      sekolah: json['sekolah'] ?? '',
      bentuk: json['bentuk'] ?? '',
      status: json['status'] ?? '',
      alamatJalan: json['alamat_jalan'] ?? '',
      lintang: json['lintang'] ?? '',
      bujur: json['bujur'] ?? '',
      expiryDate: expiry,  // Default to next year
    );
  }

  // Method to convert School object to a Map (for Firebase or other databases)
  Map<dynamic, dynamic> toMap() {
    return {
      'kode_prop': kodeProp,
      'propinsi': propinsi,
      'kode_kab_kota': kodeKabKota,
      'kabupaten_kota': kabupatenKota,
      'kode_kec': kodeKec,
      'kecamatan': kecamatan,
      'id': id,
      'npsn': npsn,
      'sekolah': sekolah,
      'bentuk': bentuk,
      'status': status,
      'alamat_jalan': alamatJalan,
      'lintang': lintang,
      'bujur': bujur,
      'expiry_date': expiryDate.toIso8601String(),  // Save expiry date as string
    };
  }

  // Helper function to check if the school data has expired
  bool isExpired() {
    return DateTime.now().isAfter(expiryDate);
  }
}
