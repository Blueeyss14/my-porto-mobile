class MessageModel {
  final int id;
  final String userName;
  final String message;

  MessageModel({
    required this.id,
    required this.userName,
    required this.message,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? 0,
      userName: json['user_name'] ?? '',
      message: json['message'] ?? '',
    );
  }
}
