class NotificationViewModel {
  int id;
  int travelerId;
  String title;
  String body;
  String? imageUrl;
  String type;
  int? targetId;

  NotificationViewModel(
      {required this.body,
      required this.id,
      required this.travelerId,
      required this.title,
      required this.type,
      this.targetId,
      this.imageUrl});

  factory NotificationViewModel.fromJson(Map<String, dynamic> json) =>
      NotificationViewModel(
          body: json['body'],
          id: json['id'],
          travelerId: json['accountId'],
          title: json['title'],
          type: json['type'],
          targetId: json['targetId'],
          imageUrl: json['imageUrl']);
}
