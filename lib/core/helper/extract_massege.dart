String extractLaravelError(Map<dynamic, dynamic> res) {
  if (res["message"] != null && res["errors"] == null) {
    return res["message"].toString();
  }

  final errors = res["errors"];
  if (errors is Map && errors.isNotEmpty) {
    final firstKey = errors.keys.first;
    final v = errors[firstKey];
    if (v is List && v.isNotEmpty) return v.first.toString();
    return v.toString();
  }

  return "Something went wrong";
}
