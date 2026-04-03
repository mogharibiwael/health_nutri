class SplashModel {
  final int id;
  final String name;
  final String description;
  final String backgroundColor;
  final String imageUrl;
  final bool active;

  SplashModel({
    required this.id,
    required this.name,
    required this.description,
    required this.backgroundColor,
    required this.imageUrl,
    required this.active,
  });

  // Factory constructor to create a SplashModel from a JSON map
  factory SplashModel.fromJson(Map<String, dynamic> json) {
    return SplashModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      backgroundColor: json['background_color'] ?? '#FFFFFF',
      imageUrl: json['image'] ?? '',
      active: json['active'] ?? false,
    );
  }
}
