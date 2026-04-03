class PatientModel {
  final int id;
  final String fullname;
  final String? gender;
  final double? height;
  final double? weight;
  final String? phoneNumber;
  final String? image;
  final String? birthdate;
  final String? physicalActivity;
  final String? medical;
  /// Carbohydrates (g per day) - set by doctor
  final double? carbohydrates;
  /// Fats (g per day) - set by doctor
  final double? fats;
   /// Protein (g per day) - set by doctor
  final double? protein;

  final bool isSubscribed;

  final int userId;
  final PatientUserModel? user;
  /// When API returns patient_id (e.g. from doctor/patients), use for diet-plans
  final int? patientIdForDiet;

  PatientModel({
    required this.id,
    required this.fullname,
    required this.userId,
    this.gender,
    this.height,
    this.weight,
    this.phoneNumber,
    this.image,
    this.birthdate,
    this.physicalActivity,
    this.medical,
    this.carbohydrates,
    this.fats,
     this.protein,
    this.isSubscribed = false,
    this.user,
    this.patientIdForDiet,
  });

  /// Map subscription/profile activity names to multiplier for BMR/TDEE
  static double _activityToMultiplier(String? activity) {
    if (activity == null || activity.isEmpty) return 1.3;
    final a = activity.toLowerCase();
    if (a == 'sedentary') return 1.2;
    if (a == 'light' || a == 'low') return 1.3;
    if (a == 'moderate') return 1.5;
    if (a == 'active') return 1.7;
    if (a == 'very_active') return 1.9;
    final num = double.tryParse(activity);
    return num ?? 1.3;
  }

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    double? _toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    int _toInt(dynamic v) {
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    // Merge nested subscription, profile, or patient (from doctor/patients) if present
    final sub = json["subscription"] is Map
        ? Map<String, dynamic>.from(json["subscription"] as Map)
        : null;
    final profile = json["profile"] is Map
        ? Map<String, dynamic>.from(json["profile"] as Map)
        : null;
    final nestedPatient = json["patient"] is Map
        ? Map<String, dynamic>.from(json["patient"] as Map)
        : null;
    var j = json;
    if (sub != null || profile != null || nestedPatient != null) {
      j = {...json, ...?sub, ...?profile, ...?nestedPatient};
    }

    // Prefer patient_id when present (doctor/patients may return it for diet-plans)
    final patientIdVal = _toInt(j["patient_id"]);
    final idVal = _toInt(j["id"]);
    final resolvedPatientIdForDiet = patientIdVal > 0 ? patientIdVal : null;
    // Some doctor patients list responses use `patient_id` instead of `id`.
    // Use it as the model `id` so PatientDetails can fetch `/api/patients/{id}` reliably.
    final resolvedId = idVal > 0 ? idVal : patientIdVal;

    // GET /api/patients/{id} returns: id, user_id, name, date_of_birth, current_weight, height, medical_history, physical_activity
    final height = _toDouble(j["height"]) ?? _toDouble(j["height_cm"]);
    final weight = _toDouble(j["weight"]) ?? _toDouble(j["weight_kg"]) ?? _toDouble(j["current_weight"]);
    final birthdate = j["birthdate"]?.toString() ?? j["date_of_birth"]?.toString();
    final physAct = j["physical_activity"]?.toString() ?? j["activity"]?.toString();
    final physActVal = physAct != null ? _activityToMultiplier(physAct).toString() : null;
    final fullnameRaw = (j["name"] ?? j["fullname"] ?? j["full_name"])?.toString();
    final fullname = (fullnameRaw != null && fullnameRaw.trim().isNotEmpty) ? fullnameRaw : "-";
    final medical = j["medical"]?.toString() ?? j["medical_history"]?.toString();
    final userMap = (j["user"] is Map) ? Map<String, dynamic>.from(j["user"] as Map) : null;

    String? phone = j["phone_number"]?.toString() ??
                   j["phone"]?.toString() ??
                   userMap?["phone"]?.toString();
    if (phone != null && phone.trim().isEmpty) phone = null;

    return PatientModel(
      id: resolvedId,
      fullname: fullname,
      gender: j["gender"]?.toString(),
      height: height,
      weight: weight,
      phoneNumber: phone,
      image: j["image"]?.toString(),
      birthdate: birthdate,
      physicalActivity: physActVal ?? physAct,
      medical: medical,
      carbohydrates: _toDouble(j["carbohydrates"]),
      fats: _toDouble(j["fats"]),
       protein: _toDouble(j["protein"]),
      isSubscribed: sub != null || j["is_subscribed"] == true || j["is_subscribed"] == 1,
      userId: _toInt(j["user_id"]),
      user: (j["user"] is Map)
          ? PatientUserModel.fromJson(Map<String, dynamic>.from(j["user"]))
          : null,
      patientIdForDiet: resolvedPatientIdForDiet,
    );
  }

  /// ID to send for diet-plans API - prefers patient_id from API when available
  int get effectivePatientId => (patientIdForDiet ?? id);

  PatientModel copyWith({
    int? id,
    int? userId,
    int? patientIdForDiet,
    String? fullname,
    String? gender,
    double? height,
    double? weight,
    String? phoneNumber,
    String? birthdate,
    String? physicalActivity,
    String? medical,
    double? carbohydrates,
    double? fats,
    double? protein,
    PatientUserModel? user,
  }) {
    return PatientModel(
      id: id ?? this.id,
      fullname: fullname ?? this.fullname,
      userId: userId ?? this.userId,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      image: image,
      birthdate: birthdate ?? this.birthdate,
      physicalActivity: physicalActivity ?? this.physicalActivity,
      medical: medical ?? this.medical,
      carbohydrates: carbohydrates ?? this.carbohydrates,
      fats: fats ?? this.fats,
       protein: protein ?? this.protein,
      isSubscribed: isSubscribed,
      user: user ?? this.user,
      patientIdForDiet: patientIdForDiet ?? this.patientIdForDiet,
    );
  }
}

class PatientUserModel {
  final int id;
  final String name;
  final String email;
  final String? role;

  PatientUserModel({
    required this.id,
    required this.name,
    required this.email,
    this.role,
  });

  factory PatientUserModel.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic v) {
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    return PatientUserModel(
      id: _toInt(json["id"]),
      name: (json["name"] ?? "-").toString(),
      email: (json["email"] ?? "-").toString(),
      role: json["role"]?.toString(),
    );
  }
}
