class CommercialAd {
  final String id;
  final String ownerUid;
  final String ownerName;
  final String ownerEmail;
  final String ownerPhone;
  final String ownerWhatsapp;
  final String title;
  final String businessName;
  final String description;
  final String category;
  final String phone;
  final String whatsapp;
  final String website;
  final String governorate;
  final String district;
  final String address;
  final double latitude;
  final double longitude;
  final List<String> imageUrls;
  final List<String> placements;
  final bool featured;
  final bool notificationPromotion;
  final String startAt;
  final String endAt;
  final int durationDays;
  final double requestedPrice;
  final double approvedPrice;
  final String paymentStatus;
  final String status;
  final String rejectionReason;
  final int views;
  final int clicks;
  final int calls;
  final int whatsappClicks;
  final int mapClicks;
  final String createdAt;
  final String approvedAt;
  final String publishedAt;

  const CommercialAd({
    required this.id,
    required this.ownerUid,
    required this.ownerName,
    required this.ownerEmail,
    required this.ownerPhone,
    required this.ownerWhatsapp,
    required this.title,
    required this.businessName,
    required this.description,
    required this.category,
    required this.phone,
    required this.whatsapp,
    required this.website,
    required this.governorate,
    required this.district,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.imageUrls,
    required this.placements,
    required this.featured,
    required this.notificationPromotion,
    required this.startAt,
    required this.endAt,
    required this.durationDays,
    required this.requestedPrice,
    required this.approvedPrice,
    required this.paymentStatus,
    required this.status,
    required this.rejectionReason,
    required this.views,
    required this.clicks,
    required this.calls,
    required this.whatsappClicks,
    required this.mapClicks,
    required this.createdAt,
    required this.approvedAt,
    required this.publishedAt,
  });

  factory CommercialAd.fromMap(String id, Map<dynamic, dynamic> raw) {
    final map = Map<String, dynamic>.from(raw);
    double number(dynamic value) =>
        double.tryParse(value?.toString() ?? '') ?? 0;
    int integer(dynamic value) =>
        int.tryParse(value?.toString() ?? '') ?? 0;
    List<String> strings(dynamic value) {
      if (value is List) return value.map((e) => e.toString()).toList();
      if (value is Map) return value.values.map((e) => e.toString()).toList();
      return [];
    }

    return CommercialAd(
      id: id,
      ownerUid: map['ownerUid']?.toString() ?? '',
      ownerName: map['ownerName']?.toString() ?? '',
      ownerEmail: map['ownerEmail']?.toString() ?? '',
      ownerPhone: map['ownerPhone']?.toString() ?? '',
      ownerWhatsapp: map['ownerWhatsapp']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      businessName: map['businessName']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      whatsapp: map['whatsapp']?.toString() ?? '',
      website: map['website']?.toString() ?? '',
      governorate: map['governorate']?.toString() ?? '',
      district: map['district']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      latitude: number(map['latitude']),
      longitude: number(map['longitude']),
      imageUrls: strings(map['imageUrls']),
      placements: strings(map['placements']),
      featured: map['featured'] == true,
      notificationPromotion: map['notificationPromotion'] == true,
      startAt: map['startAt']?.toString() ?? '',
      endAt: map['endAt']?.toString() ?? '',
      durationDays: integer(map['durationDays']),
      requestedPrice: number(map['requestedPrice']),
      approvedPrice: number(map['approvedPrice']),
      paymentStatus: map['paymentStatus']?.toString() ?? 'pending',
      status: map['status']?.toString() ?? 'pending',
      rejectionReason: map['rejectionReason']?.toString() ?? '',
      views: integer(map['views']),
      clicks: integer(map['clicks']),
      calls: integer(map['calls']),
      whatsappClicks: integer(map['whatsappClicks']),
      mapClicks: integer(map['mapClicks']),
      createdAt: map['createdAt']?.toString() ?? '',
      approvedAt: map['approvedAt']?.toString() ?? '',
      publishedAt: map['publishedAt']?.toString() ?? '',
    );
  }
}
