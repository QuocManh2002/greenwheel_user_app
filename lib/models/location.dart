// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:greenwheel_user_app/models/tag.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class LocationModel {
  LocationModel(
      {required this.id,
      required this.description,
      required this.imageUrl,
      required this.name,
      required this.numberOfRating,
      required this.rating, 
      required this.tags,
      required this.hotlineNumber,
      required this.lifeGuardNumber,
      required this.lifeGuardAddress,
      required this.clinicNumber,
      required this.clinicAddress,
      required this.locationLatLng});

  final String id;
  final String name;
  final double rating;
  final String imageUrl;
  final int numberOfRating;
  final String description;
  final List<Tag> tags;
  final String hotlineNumber;
  final String lifeGuardNumber;
  final String lifeGuardAddress;
  final String clinicNumber;
  final String clinicAddress;
  final LatLng locationLatLng;
}
