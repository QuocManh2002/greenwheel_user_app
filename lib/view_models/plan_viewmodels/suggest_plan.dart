class SuggestPlanViewModel {
  int id;
  int? leaderId;
  String planName;
  int periodCount;
  int gcoinBudgetPerCapita;
  String locationName;

  SuggestPlanViewModel({
    required this.id,
    this.leaderId,
    required this.gcoinBudgetPerCapita,
    required this.periodCount,
    required this.planName,
    required this.locationName,
  });

  factory SuggestPlanViewModel.fromJson(Map<String, dynamic> json) =>
      SuggestPlanViewModel(
        id: json['id'],
        periodCount: json['periodCount'],
        gcoinBudgetPerCapita: json['gcoinBudgetPerCapita'],
        planName: json['name'],
        locationName: json['destination']['name']
      );
}
