import 'package:greenwheel_user_app/main.dart';

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
  bool? isJoinedPlan;
  bool? isOwnedPlan;

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
      this.isJoinedPlan,
      this.isOwnedPlan,
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
        imageUrl: json['imageUrl'],
        isJoinedPlan: json['plan'] == null
            ? null
            : json['plan']['members'].any(
                (e) => e['accountId'] == sharedPreferences.getInt('userId') && e['status'] == 'JOINED'),
        isOwnedPlan: json['plan'] == null
            ? null
            : json['plan']['accountId'] == sharedPreferences.getInt('userId'),
      );
}
