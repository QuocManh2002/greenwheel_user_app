class NotificationViewModel {
  int id;
  int travelerId;
  String title;
  String body;
  String? imageUrl;
  String type;
  int? planId;
  int? orderId;
  DateTime? createdAt;

  NotificationViewModel(
      {required this.body,
      required this.id,
      required this.travelerId,
      required this.title,
      required this.type,
      this.planId,
      this.orderId,
      this.createdAt,
      this.imageUrl});

  factory NotificationViewModel.fromJson(Map<String, dynamic> json) =>
      NotificationViewModel(
          body: json['body'],
          id: json['id'],
          travelerId: json['accountId'],
          title: json['title'],
          type: json['type'],
          planId: json['planId'],
          createdAt: DateTime.parse(json['createdAt']),
          orderId: json['orderId'],
          imageUrl: json['imageUrl']);
}
