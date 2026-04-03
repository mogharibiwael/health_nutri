import 'package:get/get.dart';

class TipModel {
  final int id;
  final String describtion; // keep backend spelling
  final int? adminId;
  final int? categoryId;
  final String? date;
  final String? createdAt;
  final String? updatedAt;
  final TipCategory? category;

  TipModel({
    required this.id,
    required this.describtion,
    this.adminId,
    this.categoryId,
    this.date,
    this.createdAt,
    this.updatedAt,
    this.category,
  });

  factory TipModel.fromJson(Map<String, dynamic> json) {
    TipCategory? cat;
    if (json["category"] is Map) {
      try {
        cat = TipCategory.fromJson(json["category"] as Map<String, dynamic>);
      } catch (_) {}
    }
    return TipModel(
      id: _toInt(json["id"]),
      describtion: (json["describtion"] ?? "").toString(),
      adminId: _toInt(json["admin_id"]),
      categoryId: _toInt(json["category_id"]),
      date: json["date"]?.toString(),
      createdAt: json["created_at"]?.toString(),
      updatedAt: json["updated_at"]?.toString(),
      category: cat,
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse("$v") ?? 0;
  }
}

class TipCategory {
  final int id;
  final String? nameEn;
  final String? nameAr;

  TipCategory({
    required this.id,
    this.nameEn,
    this.nameAr,
  });

  factory TipCategory.fromJson(Map<String, dynamic> json) {
    return TipCategory(
      id: TipModel._toInt(json["id"]),
      nameEn: json["name_en"]?.toString(),
      nameAr: json["name_ar"]?.toString(),
    );
  }

  String get displayName {
    final isAr = Get.locale?.languageCode == 'ar';
    if (isAr && nameAr != null && nameAr!.isNotEmpty) return nameAr!;
    if (nameEn != null && nameEn!.isNotEmpty) return nameEn!;
    return nameAr ?? nameEn ?? "Category $id";
  }
}
