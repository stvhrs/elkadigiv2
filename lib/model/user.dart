enum Jenjang { SD, SMP, SMA }
enum UserType { GURU, SISWA, ADMIN }

class UserData {
  final String id;
  final String email;
  final String kelasId;
  final String phoneNumber;
  final String name;
  final String npsn;
  final String kodekabupaten;
  final Jenjang jenjang; // Akan di-auto-correct jika tidak sesuai kelasId
  final UserType userType;

  UserData({
    required this.id,
    required this.email,
    required this.kelasId,
    required this.phoneNumber,
    required this.name,
    required this.npsn,
    required this.kodekabupaten,
    Jenjang? jenjang, // Diubah menjadi optional
    required this.userType,
  }) : jenjang = jenjang ?? _determineJenjang(kelasId); // Auto-correct jika null/tidak sesuai

  // Factory constructor untuk JSON
  factory UserData.fromJson(Map<dynamic, dynamic> json) {
    return UserData(
      id: json['id'] as String,
      email: json['email'] as String,
      kelasId: json['kelas_id'] as String,
      phoneNumber: json['phone_number'] as String,
      name: json['name'] as String,
      npsn: json['npsn'] as String,
      kodekabupaten: json['kodekabupaten'] as String,
      jenjang: _determineJenjang( json['kelas_id'] ), // Tetap parsing dari JSON
      userType: _parseUserType(json['usertype']),
    );
  }

  // Deteksi jenjang berdasarkan kelasId
  static Jenjang _determineJenjang(String kelasId) {
    final kelasNumber = int.tryParse(kelasId.split('_').last) ?? 0;
    return switch (kelasNumber) {
      1 || 2 || 3 || 4 || 5 || 6 => Jenjang.SD,
      7 || 8 || 9 => Jenjang.SMP,
      10 || 11 || 12 => Jenjang.SMA,
      _ => Jenjang.SMP, // Default fallback
    };
  }

  // Parse Jenjang dari string
  static Jenjang _parseJenjang(String jenjangStr) {
    return Jenjang.values.firstWhere(
      (e) => e.toString().split('.').last == jenjangStr,
      orElse: () => _determineJenjang('kelas_7'), // Fallback ke SMP
    );
  }

  // Parse UserType
  static UserType _parseUserType(String userTypeStr) {
    return UserType.values.firstWhere(
      (e) => e.toString().split('.').last == userTypeStr,
      orElse: () => UserType.SISWA,
    );
  }


  // Convert ke Map
  Map<dynamic, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'kelas_id': kelasId,
      'phone_number': phoneNumber,
      'name': name,
      'npsn': npsn,
      'kodekabupaten': kodekabupaten,
      'jenjang': jenjang.name,
      'usertype': userType.name,
    };
  }

  // CopyWith method
  UserData copyWith({
    String? id,
    String? email,
    String? kelasId,
    String? phoneNumber,
    String? name,
    String? npsn,
    String? kodekabupaten,
    Jenjang? jenjang,
    UserType? userType,
  }) {
    return UserData(
      id: id ?? this.id,
      email: email ?? this.email,
      kelasId: kelasId ?? this.kelasId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      npsn: npsn ?? this.npsn,
      kodekabupaten: kodekabupaten ?? this.kodekabupaten,
      jenjang: _determineJenjang(kelasId!) ?? this.jenjang,
      userType: userType ?? this.userType,
    );
  }

  @override
  String toString() {
    return 'UserData(id: $id, email: $email, kelasId: $kelasId, '
        'jenjang: $jenjang, userType: $userType)';
  }

  // Method lainnya (toMap, copyWith, toString) tetap sama...
}
  // CopyWith method