class DoctorModel {
  final int id;
  final String name;
  final String? specialization;
  final String? bio;
  final bool isVerified;
  final bool isAvailable;
  final String rating;
  final String? consultationFee;
  final int? yearsOfExperience;
  final int? userId;
  final String? email;
  final String? phone;
  final String? bankAccount;
  /// "male" | "female" from API - used for avatar image (male: doct.jpg, female: doc.png)
  final String? gender;

  DoctorModel({
    required this.id,
    required this.name,
    this.specialization,
    this.bio,
    required this.isVerified,
    required this.isAvailable,
    required this.rating,
    this.consultationFee,
    this.yearsOfExperience,
    this.userId,
    this.email,
    this.phone,
    this.bankAccount,
    this.gender,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic v) => v is int ? v : int.tryParse("$v") ?? 0;
    return DoctorModel(
      id: _toInt(json["id"]),
      userId: json["user_id"] is int ? json["user_id"] : int.tryParse("${json["user_id"]}"),
      name: (json["name"] ?? "-").toString(),
      specialization: json["specialization"]?.toString(),
      bio: json["bio"]?.toString(),
      isVerified: json["is_verified"] == true,
      isAvailable: json["is_available"] == true,
      rating: (json["rating"] ?? "0.00").toString(),
      consultationFee: json["consultation_fee"]?.toString(),
      yearsOfExperience: json["years_of_experience"] is int
          ? json["years_of_experience"]
          : int.tryParse((json["years_of_experience"] ?? "").toString()),
      email: json["email"]?.toString() ?? (json["user"] is Map ? (json["user"] as Map)["email"]?.toString() : null),
      phone: json["phone"]?.toString() ?? json["phone_number"]?.toString() ?? (json["user"] is Map ? (json["user"] as Map)["phone"]?.toString() : null),
      bankAccount: json["bank_account"]?.toString() ?? (json["user"] is Map ? (json["user"] as Map)["bank_account"]?.toString() : null),
      gender: (json["gender"] ?? (json["user"] is Map ? (json["user"] as Map)["gender"] : null))?.toString().toLowerCase(),
    );
  }

  /// Avatar image path: male -> doct.jpg, female/default -> doc.png
  String get avatarAsset =>
      (gender ?? "").toLowerCase() == "male"
          ? "assets/images/doct.jpg"
          : "assets/images/doc.png";

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "name": name,
    "specialization": specialization,
    "bio": bio,
    "is_verified": isVerified,
    "is_available": isAvailable,
    "rating": rating,
    "consultation_fee": consultationFee,
    "years_of_experience": yearsOfExperience,
    "email": email,
    "phone": phone,
    "bank_account": bankAccount,
    "gender": gender,
  };

}
