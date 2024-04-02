class Transaction {
  int? id;
  int? receiverId;
  int? planMemberId;
  int? orderId;
  String? type;
  String? status;
  int? gcoinAmount;
  String? description;
  String? gateway;
  String? bankTransCode;
  DateTime? createdAt;
  int? senderId;

  Transaction({
    this.id,
    this.receiverId,
    this.type,
    this.status,
    this.gcoinAmount,
    this.description,
    this.gateway,
    this.bankTransCode,
    this.createdAt,
    this.senderId,
    this.orderId,
    this.planMemberId
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json["id"],
        orderId: json['orderId'],
        planMemberId: json['planMemberId'],
        receiverId: json["receiverId"],
        type: json["type"],
        status: json["status"],
        gcoinAmount: json["gcoinAmount"],
        description: json["description"],
        gateway: json["gateway"],
        bankTransCode: json["bankTransCode"],
        createdAt: DateTime.parse(json["createdAt"]),
        senderId: json["senderId"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "receiverId": receiverId,
        "type": type,
        "status": status,
        "gcoinAmount": gcoinAmount,
        "description": description,
        "gateway": gateway,
        "bankTransCode": bankTransCode,
        "createdAt": createdAt,
        "senderId": senderId,
      };
}
