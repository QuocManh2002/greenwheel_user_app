class Transaction {
  int? id;
  int? accountId;
  int? planMemberId;
  int? orderId;
  String? type;
  String? status;
  int? gcoinAmount;
  String? description;
  String? gateway;
  String? bankTransCode;
  DateTime? createdAt;
  int? providerId;

  Transaction({
    this.id,
    this.providerId,
    this.type,
    this.status,
    this.gcoinAmount,
    this.description,
    this.gateway,
    this.bankTransCode,
    this.createdAt,
    this.accountId,
    this.orderId,
    this.planMemberId
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json["id"],
        orderId: json['orderId'],
        planMemberId: json['planMemberId'],
        providerId: json["providerId"],
        type: json["type"],
        status: json["status"],
        gcoinAmount: json["gcoinAmount"].toInt(),
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
        "gcoinAmount": gcoinAmount,
        "description": description,
        "gateway": gateway,
        "bankTransCode": bankTransCode,
        "createdAt": createdAt,
        "accountId": accountId,
      };
}
