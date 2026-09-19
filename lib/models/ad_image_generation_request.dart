class AdImageGenerationRequest {
  final String category;
  final String businessName;
  final String description;
  final String location;
  final String style;
  final String aspectRatio;

  const AdImageGenerationRequest({
    required this.category,
    required this.businessName,
    required this.description,
    required this.location,
    required this.style,
    required this.aspectRatio,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'businessName': businessName,
      'description': description,
      'location': location,
      'style': style,
      'aspectRatio': aspectRatio,
    };
  }
}