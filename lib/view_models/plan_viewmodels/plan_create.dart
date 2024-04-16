import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class PlanCreate {
  int? locationId;
  String? locationName;
  PointLatLng? departCoordinate;
  String? departAddress;
  DateTime? departAt;
  DateTime? endDate;
  DateTime? closeRegDate;
  DateTime? startDate;
  int? maxMemberCount;
  String? name;
  String? schedule;
  String? savedContacts;
  List<dynamic>? surcharges;
  int? numOfExpPeriod;
  String? travelDuration;
  String? note;
  int? maxMemberWeight;
  List<String>? savedContactIds;
  DateTime? arrivedAt;

  PlanCreate(
      {this.locationId,
      this.departAddress,
      this.departCoordinate,
      this.locationName,
      this.departAt,
      this.surcharges,
      this.startDate,
      this.endDate,
      this.closeRegDate,
      this.maxMemberCount,
      this.name,
      this.schedule,
      this.numOfExpPeriod,
      this.travelDuration,
      this.note,
      this.maxMemberWeight,
      this.savedContactIds,
      this.arrivedAt,
      this.savedContacts});
}
