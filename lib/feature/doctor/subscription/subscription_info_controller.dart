import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/routes/app_route.dart';
import '../../../core/service/serviecs.dart';
import '../../chat/data/patient_profile_data.dart';
import '../model/doctor_model.dart';

enum SubscriptionGender { male, female }

enum SubscriptionActivity { sedentary, light, moderate, active }

class SubscriptionInfoController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final MyServices myServices = Get.find();
  final PatientProfileData patientProfileData = PatientProfileData(Get.find());

  DateTime? dateOfBirth;
  int? heightCm;
  int? weightKg;
  SubscriptionGender gender = SubscriptionGender.male;
  SubscriptionActivity activity = SubscriptionActivity.sedentary;

  late DoctorModel doctor;
  bool isSubscribed = false;
  bool isApproved = false;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is Map<String, dynamic>) {
      doctor = DoctorModel.fromJson(arg['doctor'] as Map<String, dynamic>);
    } else {
      doctor = DoctorModel(
        id: 0,
        name: "-",
        isVerified: false,
        isAvailable: false,
        rating: "0",
      );
    }
    _refreshAndCheckStatus();
  }

  Future<void> _refreshAndCheckStatus() async {
    await myServices.syncSubscribedDoctorsFromBackend();
    isSubscribed = myServices.isSubscribedToDoctor(doctor.id);
    isApproved = myServices.isApprovedToDoctor(doctor.id);
    update();
  }

  String get dateOfBirthText {
    if (dateOfBirth == null) return "";
    return "${dateOfBirth!.year}-${dateOfBirth!.month.toString().padLeft(2, '0')}-${dateOfBirth!.day.toString().padLeft(2, '0')}";
  }

  String get heightText => heightCm != null ? "$heightCm cm" : "";
  String get weightText => weightKg != null ? "$weightKg kg" : "";

  void setDateOfBirth(DateTime d) {
    dateOfBirth = d;
    update();
  }

  void setHeight(int cm) {
    heightCm = cm;
    update();
  }

  void setWeight(int kg) {
    weightKg = kg;
    update();
  }

  void setGender(SubscriptionGender g) {
    gender = g;
    update();
  }

  void setActivity(SubscriptionActivity a) {
    activity = a;
    update();
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: dateOfBirth ?? DateTime(1990, 6, 12),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) setDateOfBirth(picked);
  }

  Future<void> pickHeight() async {
    final picked = await showDialog<int>(
      context: Get.context!,
      builder: (context) => _NumberPickerDialog(
        title: "selectHeight".tr,
        min: 100,
        max: 250,
        initial: heightCm ?? 170,
        unit: "cm",
      ),
    );
    if (picked != null) setHeight(picked);
  }

  Future<void> pickWeight() async {
    final picked = await showDialog<int>(
      context: Get.context!,
      builder: (context) => _NumberPickerDialog(
        title: "selectWeight".tr,
        min: 30,
        max: 250,
        initial: weightKg ?? 70,
        unit: "kg",
      ),
    );
    if (picked != null) setWeight(picked);
  }

  Future<void> goToPaymentInvoice() async {
    if (!formKey.currentState!.validate()) return;
    if (dateOfBirth == null) {
      Get.snackbar("fillFields".tr, "selectDateOfBirth".tr);
      return;
    }
    if (heightCm == null || weightKg == null) {
      Get.snackbar("fillFields".tr, "selectHeight".tr + " / " + "selectWeight".tr);
      return;
    }

    // Save profile right away from subscription form so doctor app can see initial values immediately.
    await _savePatientProfileFromForm();

    Get.toNamed(AppRoute.paymentInvoice, arguments: {
      "doctor": doctor.toJson(),
      "full_name": fullNameController.text.trim(),
      "phone": phoneController.text.trim(),
      "date_of_birth": dateOfBirthText,
      "height_cm": heightCm,
      "weight_kg": weightKg,
      "gender": gender == SubscriptionGender.male ? "male" : "female",
      "activity": activity.name,
    });
  }

  Future<void> _savePatientProfileFromForm() async {
    final token = myServices.token;
    if (token == null || token.trim().isEmpty) return;

    final body = <String, dynamic>{
      "gender": gender == SubscriptionGender.male ? "male" : "female",
      "date_of_birth": dateOfBirthText,
      "height": heightCm,
      "current_weight": weightKg,
      "physical_activity": activity.name,
      "medical_history": "",
    };

    try {
      final res = await patientProfileData.updateProfile(body, token: token);
      await res.fold((_) async {}, (response) async {
        final d = response["data"];
        final profile = d is Map ? Map<String, dynamic>.from(d) : null;
        if (profile == null) return;
        final u = myServices.user ?? <String, dynamic>{};
        final merged = <String, dynamic>{...u, "patient_profile": profile};
        await myServices.saveSession(
          token: token,
          type: myServices.type ?? "user",
          user: merged,
        );
      });
    } catch (_) {
      // Don't block flow if profile save fails here; subscription can still continue.
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}

class _NumberPickerDialog extends StatefulWidget {
  final String title;
  final int min;
  final int max;
  final int initial;
  final String unit;

  const _NumberPickerDialog({
    required this.title,
    required this.min,
    required this.max,
    required this.initial,
    required this.unit,
  });

  @override
  State<_NumberPickerDialog> createState() => _NumberPickerDialogState();
}

class _NumberPickerDialogState extends State<_NumberPickerDialog> {
  late int value;

  @override
  void initState() {
    super.initState();
    value = widget.initial.clamp(widget.min, widget.max);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: value > widget.min
                    ? () => setState(() => value--)
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "$value ${widget.unit}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: value < widget.max
                    ? () => setState(() => value++)
                    : null,
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("cancel".tr),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(value),
          style: ElevatedButton.styleFrom(backgroundColor: AppColor.primary),
          child: Text("ok".tr),
        ),
      ],
    );
  }
}
