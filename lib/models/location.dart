class Location {
  final String id;
  final String name;
  final double rating;
  final String? imageUrl;
  final String? description;

  Location({
    required this.id,
    required this.name,
    this.rating = 0.0,
    this.imageUrl,
    this.description,
  });

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      id: map['id'],
      name: map['name'],
      rating: map['rating'],
      imageUrl: map['image_url'],
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'rating': rating,
      'image_url': imageUrl,
      'description': description,
    };
  }
}
