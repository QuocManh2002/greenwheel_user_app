class Comment{
  const Comment({required this.id, required this.customerName, required this.content, required this.rating, required this.date, required this.imgUrl});
  final int id;
  final String customerName;
  final String imgUrl;
  final int rating;
  final String date;
  final String content;
}