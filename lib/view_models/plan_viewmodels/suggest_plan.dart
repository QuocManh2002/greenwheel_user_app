class SuggestPlanViewModel {
  int id;
  int? leaderId;
  String? leaderName;
  String planName;
  DateTime utcStartAt;
  DateTime utcDepartAt;
  DateTime utcEndAt;

  SuggestPlanViewModel(
      {required this.utcEndAt,
      required this.id,
      this.leaderId,
      this.leaderName,
      required this.utcDepartAt,
      required this.planName,
      required this.utcStartAt});

  factory SuggestPlanViewModel.fromJson(Map<String, dynamic> json) =>
      SuggestPlanViewModel(
          utcEndAt: DateTime.parse(json['utcEndAt']),
          id: json['id'],
          utcDepartAt: DateTime.parse(json['utcDepartAt']),
          leaderName: json['account']['name'],
          planName: json['name'],
          utcStartAt: DateTime.parse(json['utcStartAt']));
}
