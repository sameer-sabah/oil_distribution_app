class PaymentMethod {
  final String id;
  final String name;
  final String accountNumber;
  final String description;
  final double balance;
  final String createdAt;

  const PaymentMethod({
    required this.id,
    required this.name,
    required this.accountNumber,
    required this.description,
    required this.balance,
    required this.createdAt,
  });

  factory PaymentMethod.fromMap(String id, Map<dynamic, dynamic> raw) {
    final map = Map<String, dynamic>.from(raw);
    return PaymentMethod(
      id: id,
      name: map['name']?.toString() ?? '',
      accountNumber: map['accountNumber']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      balance: double.tryParse(map['balance']?.toString() ?? '0') ?? 0.0,
      createdAt: map['createdAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'accountNumber': accountNumber,
      'description': description,
      'balance': balance,
      'createdAt': createdAt,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentMethod && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class WalletTopUpRequest {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final double amount;
  final String method;
  final String referenceNumber;
  final String receiptImageUrl;
  final String status; // 'pending', 'approved', 'rejected'
  final String createdAt;
  final String confirmedAt;
  final String adminNote;

  const WalletTopUpRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.amount,
    required this.method,
    required this.referenceNumber,
    required this.receiptImageUrl,
    required this.status,
    required this.createdAt,
    required this.confirmedAt,
    required this.adminNote,
  });

  factory WalletTopUpRequest.fromMap(String id, Map<dynamic, dynamic> raw) {
    final map = Map<String, dynamic>.from(raw);
    return WalletTopUpRequest(
      id: id,
      userId: map['userId']?.toString() ?? '',
      userName: map['userName']?.toString() ?? '',
      userPhone: map['userPhone']?.toString() ?? '',
      amount: double.tryParse(map['amount']?.toString() ?? '0') ?? 0.0,
      method: map['method']?.toString() ?? '',
      referenceNumber: map['referenceNumber']?.toString() ?? '',
      receiptImageUrl: map['receiptImageUrl']?.toString() ?? '',
      status: map['status']?.toString() ?? 'pending',
      createdAt: map['createdAt']?.toString() ?? '',
      confirmedAt: map['confirmedAt']?.toString() ?? '',
      adminNote: map['adminNote']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'amount': amount,
      'method': method,
      'referenceNumber': referenceNumber,
      'receiptImageUrl': receiptImageUrl,
      'status': status,
      'createdAt': createdAt,
      'confirmedAt': confirmedAt,
      'adminNote': adminNote,
    };
  }
}
