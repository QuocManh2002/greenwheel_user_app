class Location {
  Location(
      {required this.id,
      required this.description,
      required this.imageUrl,
      required this.name,
      required this.numberOfRating,
      required this.rating});

  final String id;
  final String name;
  final double rating;
  final String imageUrl;
  final int numberOfRating;
  final String description;
}
