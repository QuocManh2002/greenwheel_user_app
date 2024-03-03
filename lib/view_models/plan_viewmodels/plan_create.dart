class PlanCreate {
  final int? locationId;
  final double? latitude;
  final double? longitude;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? closeRegDate;
  final int? memberLimit;
  final String? name;
  final String? schedule;
  String? savedContacts;
  int? numOfExpPeriod;
  final DateTime? departureDate;
  int? gcoinBudget;
  String? travelDuration;
  String? tempOrders;
  String? note;
  int? weight;

  PlanCreate(
      {this.locationId,
      this.startDate,
      this.endDate,
      this.latitude,
      this.closeRegDate,
      this.longitude,
      this.memberLimit,
      this.name,
      this.schedule,
      this.numOfExpPeriod,
      this.departureDate,
      this.gcoinBudget,
      this.travelDuration,
      this.tempOrders,
      this.note,
      this.weight,
      this.savedContacts});
}
