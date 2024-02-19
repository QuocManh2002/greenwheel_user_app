class PlanCreate {
  final int locationId;
  final double latitude;
  final double longitude;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? closeRegDate;
  final int memberLimit;
  final String? name;
  final String schedule;
  String? savedContacts;
  int? numOfExpPeriod;
  final DateTime? departureDate;
  int? gcoinBudget;

  PlanCreate(
      {required this.locationId,
       this.startDate,
       this.endDate,
      required this.latitude,
      this.closeRegDate,
      required this.longitude,
      required this.memberLimit,
       this.name,
      required this.schedule,
      this.numOfExpPeriod,
       this.departureDate,
      this.gcoinBudget,
      this.savedContacts});
}
