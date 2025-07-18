class SliderItem {
  final String imgUrl; // Image URL
  final String link; // Link for the slider item

  // Constructor
  SliderItem({required this.imgUrl, required this.link});

  // Factory method to create an instance from JSON (if needed)
  factory SliderItem.fromJson(Map<dynamic, dynamic> json) {
    return SliderItem(
      imgUrl: json['imgUrl'] as String,
      link: json['link'] as String,
    );
  }

  // Convert the object to a map (useful for saving to databases or APIs)
  Map<dynamic, dynamic> toMap() {
    return {'imgUrl': imgUrl, 'link': link};
  }
}
