import 'package:intl/intl.dart';

class MaterialCourse {
  final String? id; // Tambahkan property id sebagai nullable
  final String title;
  final String nspnKelasMapelId;
  final String sender;
  final List<Object?> content;
  final String publishedAt;
  final String nspn;

  MaterialCourse({
    this.id, // Tambahkan parameter id
    required this.title,
    required this.nspnKelasMapelId,
    required this.sender,
    required this.nspn,
    required this.content,
    required this.publishedAt,
  });

  // Factory constructor to create from controllers
  factory MaterialCourse.fromControllers({
    String? id, // Tambahkan parameter id
    required String title,
    required String nspnKelasMapelId,
    required String sender,
    required List<Object?> content,
    required String mapelId,
    required String npsn,
  }) {
    return MaterialCourse(
      id: id, // Sertakan id
      title: title,
      nspn: npsn,
      nspnKelasMapelId: nspnKelasMapelId,
      sender: sender,
      content: content,
      publishedAt: DateFormat('dd-MM-yyyy').format(DateTime.now()),
    );  
  }

  // Convert to Map for Firebase
  Map<dynamic, dynamic> toMap() {
    final map = {
      'title': title,
      "npsn": nspn,
      'nspnKelasMapelId': nspnKelasMapelId,
      'sender': sender,
      'content': content,
      'published_at': publishedAt,
    };
    
    // Hanya tambahkan id ke map jika tidak null
    if (id != null) {
      map['id'] = id??"";
    }
    
    return map;
  }

  // Create from Firebase Map
  factory MaterialCourse.fromMap(Map<dynamic, dynamic> map) {
    return MaterialCourse(
      id: map['id'], // Ambil id dari map
      title: map['title'] ?? '',
      nspn: map["npsn"] ?? '',
      nspnKelasMapelId: map['nspnKelasMapelId'] ?? '',
      sender: map['sender'] ?? '',
      content: map['content'] ?? [],
      publishedAt: map['published_at'] ?? '',
    );
  }

  // Method untuk membuat copy dengan nilai yang diupdate
  MaterialCourse copyWith({
    String? id,
    String? title,
    String? nspnKelasMapelId,
    String? sender,
    List<Object?>? content,
    String? publishedAt,
    String? nspn,
  }) {
    return MaterialCourse(
      id: id ?? this.id,
      title: title ?? this.title,
      nspnKelasMapelId: nspnKelasMapelId ?? this.nspnKelasMapelId,
      sender: sender ?? this.sender,
      content: content ?? this.content,
      publishedAt: publishedAt ?? this.publishedAt,
      nspn: nspn ?? this.nspn,
    );
  }
}