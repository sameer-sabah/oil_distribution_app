class CommercialMessage {
  final String id;
  final String senderUid;
  final String senderRole;
  final String senderName;
  final String text;
  final String createdAt;
  final bool readByAdmin;
  final bool readByOwner;

  const CommercialMessage({
    required this.id,
    required this.senderUid,
    required this.senderRole,
    required this.senderName,
    required this.text,
    required this.createdAt,
    required this.readByAdmin,
    required this.readByOwner,
  });

  bool get isFromAdmin => senderRole == 'admin';

  factory CommercialMessage.fromMap(
    String id,
    Map<dynamic, dynamic> raw,
  ) {
    final map = Map<String, dynamic>.from(raw);
    return CommercialMessage(
      id: id,
      senderUid: map['senderUid']?.toString() ?? '',
      senderRole: map['senderRole']?.toString() ?? 'advertiser',
      senderName: map['senderName']?.toString() ?? '',
      text: map['text']?.toString() ?? '',
      createdAt: map['createdAt']?.toString() ?? '',
      readByAdmin: map['readByAdmin'] == true,
      readByOwner: map['readByOwner'] == true,
    );
  }
}
