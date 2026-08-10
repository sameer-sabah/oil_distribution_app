class AppNotification {
  final String id;
  final String stationId;
  final String title;
  final String message;
  final String sender;
  final String createdAt;
  final bool read;

  AppNotification({
    required this.id,
    required this.stationId,
    required this.title,
    required this.message,
    required this.sender,
    required this.createdAt,
    required this.read,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "stationId": stationId,
      "title": title,
      "message": message,
      "sender": sender,
      "createdAt": createdAt,
      "read": read,
    };
  }

  factory AppNotification.fromMap(
      Map<dynamic, dynamic> map) {
    return AppNotification(
      id: map["id"] ?? "",
      stationId: map["stationId"] ?? "",
      title: map["title"] ?? "",
      message: map["message"] ?? "",
      sender: map["sender"] ?? "",
      createdAt: map["createdAt"] ?? "",
      read: map["read"] ?? false,
    );
  }
}