class SurchargeViewModel {
  int gcoinAmount;
  String note;
  SurchargeViewModel({required this.gcoinAmount, required this.note});

  factory SurchargeViewModel.fromJson(Map<String, dynamic> json) =>
      SurchargeViewModel(gcoinAmount: json['amount'], note: json['note']);
}
