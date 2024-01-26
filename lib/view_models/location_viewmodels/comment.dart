class CommentViewModel{
  const CommentViewModel({required this.id, required this.customerName, required this.content, required this.date, required this.imgUrl});
  final int id;
  final String customerName;
  final String imgUrl;
  final DateTime date;
  final String content;
}