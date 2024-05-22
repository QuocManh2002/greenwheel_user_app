class AnnouncementViewModel {
  int id;
  int travelerId;
  String title;
  String body;
  String? imageUrl;
  String type;
  int? planId;
  int? orderId;
  DateTime? createdAt;
  bool? isRead;
  String? level;

  AnnouncementViewModel(
      {required this.body,
      required this.id,
      required this.travelerId,
      required this.title,
      required this.type,
      this.planId,
      this.orderId,
      this.createdAt,
      this.isRead,
      this.level,
      this.imageUrl});

  factory AnnouncementViewModel.fromJson(Map<String, dynamic> json) =>
      AnnouncementViewModel(
          body: json['body'],
          id: json['id'],
          travelerId: json['accountId'],
          title: json['title'],
          type: json['type'],
          planId: json['planId'],
          isRead: json['isRead'],
          createdAt: DateTime.parse(json['createdAt']),
          orderId: json['orderId'],
          level: json['level'],
          imageUrl: json['imageUrl']);
}
