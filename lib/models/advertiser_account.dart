class AdvertiserAccount {
  final String id;
  final String fullName;
  final String businessName;
  final String email;
  final String phone;
  final String whatsapp;
  final String status;
  final double balance;
  final String masterCardNumber;
  final String createdAt;
  final String updatedAt;
  final String lastLoginAt;

  const AdvertiserAccount({
    required this.id,
    required this.fullName,
    required this.businessName,
    required this.email,
    required this.phone,
    required this.whatsapp,
    required this.status,
    required this.balance,
    required this.masterCardNumber,
    required this.createdAt,
    required this.updatedAt,
    required this.lastLoginAt,
  });

  bool get isActive => status == 'active';

  factory AdvertiserAccount.fromMap(
      String id,
      Map<dynamic, dynamic> raw,
      ) {
    final map = Map<String, dynamic>.from(raw);

    return AdvertiserAccount(
      id: id,
      fullName: map['fullName']?.toString() ?? '',
      businessName: map['businessName']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      whatsapp: map['whatsapp']?.toString() ?? '',
      status: map['status']?.toString() ?? 'active',
      balance: double.tryParse(map['balance']?.toString() ?? '0') ?? 0.0,
      masterCardNumber: map['masterCardNumber']?.toString() ?? '',
      createdAt: map['createdAt']?.toString() ?? '',
      updatedAt: map['updatedAt']?.toString() ?? '',
      lastLoginAt: map['lastLoginAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'businessName': businessName,
      'email': email,
      'phone': phone,
      'whatsapp': whatsapp,
      'status': status,
      'balance': balance,
      'masterCardNumber': masterCardNumber,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'lastLoginAt': lastLoginAt,
    };
  }
}
