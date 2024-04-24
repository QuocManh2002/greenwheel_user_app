class SuggestPlanViewModel {
  int id;
  int? leaderId;
  String planName;
  int periodCount;
  int gcoinBudgetPerCapita;

  SuggestPlanViewModel({
    required this.id,
    this.leaderId,
    required this.gcoinBudgetPerCapita,
    required this.periodCount,
    required this.planName,
  });

  factory SuggestPlanViewModel.fromJson(Map<String, dynamic> json) =>
      SuggestPlanViewModel(
        id: json['id'],
        periodCount: json['periodCount'],
        gcoinBudgetPerCapita: json['gcoinBudgetPerCapita'],
        planName: json['name'],
      );
}
