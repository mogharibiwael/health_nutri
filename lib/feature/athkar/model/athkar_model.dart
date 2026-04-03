class AthkarModel {
  final int id;
  final String? category;
  final String? title;
  final String content;
  final int repetition;

  AthkarModel({
    required this.id,
    this.category,
    this.title,
    required this.content,
    this.repetition = 1,
  });

  factory AthkarModel.fromJson(Map<String, dynamic> json) {
    return AthkarModel(
      id: _toInt(json["id"]),
      category: json["category"]?.toString(),
      title: json["title"]?.toString(),
      content: (json["content"] ?? "").toString(),
      repetition: () {
        final r = _toInt(json["repetition"]);
        return r > 0 ? r : 1;
      }(),
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse("$v") ?? 0;
  }

  bool get isMorning => (category ?? "").contains("صباح") || (category ?? "").toLowerCase().contains("morning");
  bool get isEvening => (category ?? "").contains("مساء") || (category ?? "").toLowerCase().contains("evening");
}
