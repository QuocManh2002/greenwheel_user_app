class NotificationViewModel {
  int id;
  int travelerId;
  String title;
  String body;
  String? imageUrl;
  String type;
  int? planId;
  DateTime? createdAt;
  String? targetGuid;

  NotificationViewModel(
      {required this.body,
      required this.id,
      required this.travelerId,
      required this.title,
      required this.type,
      this.planId,
      this.createdAt,
      this.targetGuid,
      this.imageUrl});

  factory NotificationViewModel.fromJson(Map<String, dynamic> json) =>
      NotificationViewModel(
          body: json['body'],
          id: json['id'],
          travelerId: json['accountId'],
          title: json['title'],
          type: json['type'],
          planId: json['planId'],
          createdAt: json['createdAt'],
          targetGuid: json['targetGuid'],
          imageUrl: json['imageUrl']);
}
