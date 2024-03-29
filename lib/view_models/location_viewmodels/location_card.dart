class LocationCardViewModel {
  int id;
  String name;
  String description;
  List<dynamic> imagePaths;
  int rating;

  LocationCardViewModel(
      {required this.description,
      required this.id,
      required this.name,
      required this.imagePaths,
      required this.rating});

  factory LocationCardViewModel.fromJson(Map<String, dynamic> json) =>
      LocationCardViewModel(
          id: json['id'],
          name: json['name'],
          description: json['description'],
          imagePaths: json['imagePaths'],
          rating: json['rating'] ?? 0);
}
