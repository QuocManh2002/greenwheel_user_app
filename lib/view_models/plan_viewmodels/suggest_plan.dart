class SuggestPlanViewModel {
  int id;
  int? leaderId;
  String? leaderName;
  String planName;
  DateTime startDate;
  DateTime departDate;
  DateTime endDate;

  SuggestPlanViewModel(
      {required this.endDate,
      required this.id,
      this.leaderId,
      this.leaderName,
      required this.departDate,
      required this.planName,
      required this.startDate});

  factory SuggestPlanViewModel.fromJson(Map<String, dynamic> json) =>
      SuggestPlanViewModel(
          endDate: DateTime.parse(json['endDate']),
          id: json['id'],
          departDate: DateTime.parse(json['utcDepartAt']),
          leaderName: json['account']['name'],
          planName: json['name'],
          startDate: DateTime.parse(json['startDate']));
}
