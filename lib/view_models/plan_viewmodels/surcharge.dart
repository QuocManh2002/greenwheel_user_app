class SurchargeViewModel {
  int id;
  bool alreadyDivided;
  String? imagePath;
  int gcoinAmount;
  String note;
  SurchargeViewModel({
    required this.alreadyDivided,
    required this.id,
    this.imagePath,
    required this.gcoinAmount, 
    required this.note});

  factory SurchargeViewModel.fromJson(Map<String, dynamic> json) =>
      SurchargeViewModel(
        id: json['id'],
        imagePath: json['imagePath'],
        alreadyDivided: json['alreadyDivided'],
        gcoinAmount: json['gcoinAmount'], 
        note: json['note']);
}
