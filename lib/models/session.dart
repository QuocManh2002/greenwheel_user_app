class Session {
  const Session({
    required this.name,
    required this.range,
    required this.image,
    required this.enumName,
    required this.from,
    required this.to
  });

  final String name;
  final String range;
  final String image;
  final String enumName;
  final int from;
  final int to;
}
