import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutri_guide/core/class/status_request.dart';
import 'package:nutri_guide/core/function/handel_data.dart';
import 'package:nutri_guide/core/function/show_dialog.dart';
import 'package:nutri_guide/core/routes/app_route.dart';
import '../../../core/helper/extract_massege.dart';
import '../data/register_data.dart';

class SignupController extends GetxController {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  late TextEditingController dietPriceController;
  late TextEditingController bankAccountController;

  final SignupData signupData = SignupData(Get.find());

  StatusRequest statusRequest = StatusRequest.success;

  String selectedType = "user";
  String? selectedRole = "patient";
  String? selectedGender;

  bool isPasswordHidden = true;
  bool isConfirmPasswordHidden = true;

  String? degreeFilePath;
  String? degreeFileName;
  String? cvFilePath;
  String? cvFileName;

  /// Pick degree: PDF, DOC, DOCX, or images
  Future<void> pickDegreeFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );
      if (result != null && result.files.single.path != null) {
        degreeFilePath = result.files.single.path;
        degreeFileName = result.files.single.name;
        update();
      }
    } catch (e) {
      showAwesomeDialog(
        type: DialogType.error,
        title: "Error",
        desc: "Could not pick file: $e",
      );
    }
  }

  /// Pick CV: PDF, DOC, DOCX only (backend requirement)
  Future<void> pickCvFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
      );
      if (result != null && result.files.single.path != null) {
        cvFilePath = result.files.single.path;
        cvFileName = result.files.single.name;
        update();
      }
    } catch (e) {
      showAwesomeDialog(
        type: DialogType.error,
        title: "Error",
        desc: "Could not pick file. CV must be PDF, DOC, or DOCX.",
      );
    }
  }

  void clearDegreeFile() {
    degreeFilePath = null;
    degreeFileName = null;
    update();
  }

  void clearCvFile() {
    cvFilePath = null;
    cvFileName = null;
    update();
  }

  void togglePassword() {
    isPasswordHidden = !isPasswordHidden;
    update();
  }

  void toggleConfirmPassword() {
    isConfirmPasswordHidden = !isConfirmPasswordHidden;
    update();
  }// null means not sending role

  // You can change these lists based on what you allow in UI
  // final List<String> typeItems = const ["user", "payed"];
  final List<String> roleItems = const ["patient", "doctor"];

  goToLogin() => Get.offNamed(AppRoute.login);

  Future<void> register() async {
    if (statusRequest == StatusRequest.loading) return; // منع ضغط متكرر

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final pass = passwordController.text.trim();
    final confirm = confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      showAwesomeDialog(
        type: DialogType.warning,
        title: "Validation",
        desc: "Name, Email, and Password are required",
      );
      return;
    }

    if (pass.length < 8) {
      showAwesomeDialog(
        type: DialogType.warning,
        title: "Validation",
        desc: "Password must be at least 8 characters",
      );
      return;
    }

    if (confirm.isEmpty || pass != confirm) {
      showAwesomeDialog(
        type: DialogType.warning,
        title: "Validation",
        desc: "Confirm password does not match",
      );
      return;
    }

    statusRequest = StatusRequest.loading;
    update();

    try {
      double? consultationFee;
      if (selectedType == "doctor") {
        final feeStr = dietPriceController.text.trim();
        if (feeStr.isNotEmpty) consultationFee = double.tryParse(feeStr);
      }

      if (selectedType == "doctor") {
        if (cvFilePath == null || cvFilePath!.isEmpty) {
          showAwesomeDialog(
            type: DialogType.warning,
            title: "Validation",
            desc: "CV is required for doctor registration. Please upload a PDF, DOC, or DOCX file.",
          );
          statusRequest = StatusRequest.success;
          update();
          return;
        }
      }

      final res = await signupData.register(
        name: name,
        email: email,
        password: pass,
        passwordConfirmation: confirm,
        phone: phone.isEmpty ? null : phone,
        type: selectedType,
        gender: selectedGender,
        degreeFilePath: selectedType == "doctor" ? degreeFilePath : null,
        cvFilePath: selectedType == "doctor" ? cvFilePath : null,
        consultationFee: consultationFee,
        bankAccount: selectedType == "doctor" ? bankAccountController.text.trim() : null,
      );

      print(res);
      if (res is StatusRequest) {
        final msg = res == StatusRequest.offlineFailure
            ? "No internet connection"
            : "Server error";
        showAwesomeDialog(
          type: DialogType.error,
          title: "Register Failed",
          desc: msg,
        );
        statusRequest = StatusRequest.failure;
        update();
        return;
      }

      // Server returned a body (Map): show actual message for 4xx/5xx or validation errors
      if (res is Map) {
        final statusCode = res["_statusCode"];
        final hasErrorStatus = statusCode != null && (statusCode is int && statusCode >= 400);
        final hasErrors = res["errors"] != null;
        if (hasErrorStatus || hasErrors) {
          final msg = extractLaravelError(Map<String, dynamic>.from(res));
          showAwesomeDialog(
            type: DialogType.error,
            title: "Register Failed",
            desc: msg,
          );
          statusRequest = StatusRequest.failure;
          update();
          return;
        }
      }

      statusRequest = handelData(res);

      if (statusRequest != StatusRequest.success) {
        showAwesomeDialog(
          type: DialogType.error,
          title: "Register Failed",
          desc: "Try again",
        );
        update();
        return;
      }

      // Go directly to verify email - code is sent to user's email by backend
      Get.offAllNamed(AppRoute.verifyEmail, arguments: {'email': email});
    } finally {
      // رجّع الحالة لو ما انتقلت للصفحة
      if (Get.currentRoute.contains("signup")) {
        statusRequest = StatusRequest.success;
        update();
      }
    }
  }


  @override
  void onInit() {
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    dietPriceController = TextEditingController();
    bankAccountController = TextEditingController();
    _applyRoleFromRoute();
    super.onInit();
  }

  void _applyRoleFromRoute() {
    final args = Get.arguments;
    if (args is Map && args['role'] != null) {
      selectedRole = args['role'] as String;
      selectedType = selectedRole == 'doctor' ? 'doctor' : 'user';
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    dietPriceController.dispose();
    bankAccountController.dispose();
    super.onClose();
  }
}
