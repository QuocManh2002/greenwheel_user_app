
class CommentViewModel {
  const CommentViewModel(
      {required this.id,
      required this.customerName,
      required this.content,
      required this.date,
      required this.imgUrl});
  final int id;
  final String customerName;
  final String imgUrl;
  final DateTime date;
  final String content;

  factory CommentViewModel.fromJson(Map<String, dynamic> json) =>
      CommentViewModel(
          id: json['id'],
          customerName: json['account']['name'],
          content: json['comment'],
          date: DateTime.parse(json['createdAt']),
          imgUrl: json['account']['avatarPath']);
}
