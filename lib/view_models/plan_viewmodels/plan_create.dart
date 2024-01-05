class PlanCreate {
  final int locationId;
  final double latitude;
  final double longitude;
  final DateTime startDate;
  final DateTime endDate;
  final int memberLimit;
  final String name;
  final String schedule;
  String? savedContacts;

  PlanCreate(
      {required this.locationId,
      required this.startDate,
      required this.endDate,
      required this.latitude,
      required this.longitude,
      required this.memberLimit,
      required this.name,
      required this.schedule,
      this.savedContacts});
}
