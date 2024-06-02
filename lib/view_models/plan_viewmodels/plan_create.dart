import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:greenwheel_user_app/view_models/order.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/surcharge.dart';

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
  List<SurchargeViewModel>? surcharges;
  int? numOfExpPeriod;
  String? travelDuration;
  String? note;
  int? maxMemberWeight;
  List<String>? savedContactIds;
  DateTime? arrivedAt;
  List<OrderViewModel>? tempOrders;
  String? travelDurationText;
  String? travelDistanceText;
  double? travelDurationValue;
  double? travelDistanceValue;
  int? sourceId;

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
      this.tempOrders,
      this.travelDurationText,
      this.travelDistanceText,
      this.travelDistanceValue,
      this.travelDurationValue,
      this.sourceId,
      this.savedContacts});
}
