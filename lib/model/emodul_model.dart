class EmodulModel {
  final String id;
  final String imgUrl;
  final String pdfUrl;
  final String namaBuku;
  final String kelasId;

  EmodulModel({
    required this.id,
    required this.imgUrl,
    required this.pdfUrl,
    required this.namaBuku,
    required this.kelasId,
  });

  Map<dynamic, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imgUrl,
      'pdfUrl': pdfUrl,
      'title': namaBuku,
      'kelasId': kelasId,
    };
  }

  factory EmodulModel.fromJson(String key, Map<dynamic, dynamic> json) {
    return EmodulModel(
      id: key,
      imgUrl: json['imageUrl'],
      pdfUrl: json['pdfUrl'],
      namaBuku: json['title'],
      kelasId: json['kelasId'],
    );
  }
}
