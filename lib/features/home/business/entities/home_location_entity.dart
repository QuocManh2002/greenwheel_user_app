class HomeLocationEntity {
  int id;
  String name;
  String description;
  List<dynamic> imagePaths;
  int rating;

  HomeLocationEntity(
      {required this.description,
      required this.id,
      required this.imagePaths,
      required this.name,
      required this.rating});
}
