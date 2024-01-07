class SearchStartLocationResult {
  String placeId;
  String name;
  double lat;
  double lng;
  String address;

  SearchStartLocationResult(
      {required this.name,
      required this.lat,
      required this.lng,
      required this.address,
      required this.placeId});

  factory SearchStartLocationResult.fromJson(Map<String, dynamic> json) =>
      SearchStartLocationResult(
          placeId: json['place_id'],
          lat: json['geometry']['location']['lat'],
          lng: json['geometry']['location']['lng'],
          name: json['name'],
          address: json['address']
          );
}
