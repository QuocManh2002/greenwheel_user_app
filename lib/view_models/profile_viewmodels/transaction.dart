class TransactionViewModel {
  int? id;
  int? accountId;
  int? planMemberId;
  int? orderId;
  String? type;
  String? status;
  int? amount;
  String? description;
  String? gateway;
  String? bankTransCode;
  DateTime? createdAt;
  int? providerId;

  TransactionViewModel({
    this.id,
    this.providerId,
    this.type,
    this.status,
    this.amount,
    this.description,
    this.gateway,
    this.bankTransCode,
    this.createdAt,
    this.accountId,
    this.orderId,
    this.planMemberId
  });

  factory TransactionViewModel.fromJson(Map<String, dynamic> json) => TransactionViewModel(
        id: json["id"],
        orderId: json['orderId'],
        planMemberId: json['planMemberId'],
        providerId: json["providerId"],
        type: json["type"],
        status: json["status"],
        amount: json["amount"].toInt(),
        description: json["description"],
        gateway: json["gateway"],
        bankTransCode: json["bankTransCode"],
        createdAt: DateTime.parse(json["createdAt"]),
        accountId: json["accountId"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "providerId": providerId,
        "type": type,
        "status": status,
        "amount": amount,
        "description": description,
        "gateway": gateway,
        "bankTransCode": bankTransCode,
        "createdAt": createdAt,
        "accountId": accountId,
      };
}
