class TopupRequestViewModel {
  int transactionId;
  String paymentUrl;

  TopupRequestViewModel({
    required this.transactionId,
    required this.paymentUrl,
  });

  factory TopupRequestViewModel.fromJson(Map<String, dynamic> json) =>
      TopupRequestViewModel(
        transactionId: json["transaction"]['id'],
        paymentUrl: json["paymentUrl"],
      );

  Map<String, dynamic> toJson() => {
        "transactionId": transactionId,
        "paymentUrl": paymentUrl,
      };
}
