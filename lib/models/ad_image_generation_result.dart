class AdImageGenerationResult {
  final bool success;
  final String imageUrl;
  final String message;

  const AdImageGenerationResult({
    required this.success,
    required this.imageUrl,
    required this.message,
  });

  factory AdImageGenerationResult.fromJson(
      Map<String, dynamic> json,
      ) {
    return AdImageGenerationResult(
      success: json['success'] == true,
      imageUrl:
      (json['imageUrl'] ?? '')
          .toString(),
      message:
      (json['message'] ?? '')
          .toString(),
    );
  }
}