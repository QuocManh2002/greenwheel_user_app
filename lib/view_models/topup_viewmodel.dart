class TopupViewModel {
  int id;
  String status;
  String gateway;
  String? description;
  String transactionCode;

  TopupViewModel({
    required this.id,
    required this.status,
    required this.gateway,
    this.description,
    required this.transactionCode,
  });

  factory TopupViewModel.fromJson(Map<String, dynamic> json) => TopupViewModel(
        id: json["id"],
        status: json["status"],
        gateway: json["gateway"],
        description: json["description"],
        transactionCode: json["transactionCode"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "status": status,
        "gateway": gateway,
        "description": description,
        "transactionCode": transactionCode,
      };
}
