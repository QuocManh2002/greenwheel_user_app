class NotificationViewModel {
  int id;
  int travelerId;
  String title;
  String body;
  String? imageUrl;
  String type;
  int? targetId;
  DateTime? createdAt;
  String? targetGuid;

  NotificationViewModel(
      {required this.body,
      required this.id,
      required this.travelerId,
      required this.title,
      required this.type,
      this.targetId,
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
          targetId: json['targetId'],
          createdAt: json['createdAt'],
          targetGuid: json['targetGuid'],
          imageUrl: json['imageUrl']);
}
