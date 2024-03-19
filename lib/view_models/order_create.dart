
class OrderCreateViewModel {
  final int? planId;
  final List<dynamic> servingDates;
  final String period;
  String? note;
  final List<Map> details;

  OrderCreateViewModel({
    this.planId,
    required this.servingDates,
    required this.period,
    this.note,
    required this.details,
  });
}
