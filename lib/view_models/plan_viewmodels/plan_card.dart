class PlanCardViewModel {
  int id;
  String planName;
  int periodCount;
  int gcoinBudgetPerCapita;
  String locationName;
  String? status;
  DateTime? utcDepartAt;
  DateTime? utcEndAt;

  PlanCardViewModel(
      {required this.id,
      required this.gcoinBudgetPerCapita,
      required this.periodCount,
      required this.planName,
      required this.locationName,
      this.status,
      this.utcDepartAt,
      this.utcEndAt});

  factory PlanCardViewModel.fromJson(Map<String, dynamic> json) =>
      PlanCardViewModel(
          id: json['id'],
          periodCount: json['periodCount'],
          gcoinBudgetPerCapita: json['gcoinBudgetPerCapita'],
          planName: json['name'],
          locationName: json['destination']['name'],
          status: json['status'],
          utcDepartAt: json['utcDepartAt'] != null
              ? DateTime.parse(json['utcDepartAt'])
              : null,
          utcEndAt: json['utcEndAt'] != null
              ? DateTime.parse(json['utcEndAt'])
              : null);
}
