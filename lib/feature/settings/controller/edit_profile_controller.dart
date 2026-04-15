import 'package:awesome_dialog/awesome_dialog.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/class/crud.dart';
import '../../../core/constant/api_link.dart';
import '../../../core/function/show_dialog.dart';
import '../../../core/service/serviecs.dart';

class EditProfileController extends GetxController {
  final MyServices myServices = Get.find();
  final Crud crud = Get.find();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  bool isPasswordHidden = true;
  bool isConfirmPasswordHidden = true;
  bool isLoading = false;

  Uint8List? profileImageBytes;
  String? profileImagePath;

  @override
  void onInit() {
    super.onInit();
    final u = myServices.user;
    nameController = TextEditingController(text: u?["name"]?.toString() ?? "");
    emailController = TextEditingController(text: u?["email"]?.toString() ?? "");
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  Future<void> pickProfileImageFromGallery() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file == null) return;

      profileImagePath = file.path;
      profileImageBytes = await file.readAsBytes();
      update();
    } catch (e) {
      showAwesomeDialog(
        type: DialogType.error,
        title: "Error",
        desc: "Could not pick image: $e",
      );
    }
  }

  void removePickedImage() {
    profileImageBytes = null;
    profileImagePath = null;
    update();
  }

  void togglePassword() {
    isPasswordHidden = !isPasswordHidden;
    update();
  }

  void toggleConfirmPassword() {
    isConfirmPasswordHidden = !isConfirmPasswordHidden;
    update();
  }

  Future<void> save() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final pass = passwordController.text.trim();
    final confirm = confirmPasswordController.text.trim();

    if (name.isEmpty) {
      showAwesomeDialog(
        type: DialogType.warning,
        title: "Validation",
        desc: "enterName".tr,
      );
      return;
    }
    if (email.isEmpty) {
      showAwesomeDialog(
        type: DialogType.warning,
        title: "Validation",
        desc: "enterPersonalEmail".tr,
      );
      return;
    }
    if (pass.isNotEmpty && pass.length < 8) {
      showAwesomeDialog(
        type: DialogType.warning,
        title: "Validation",
        desc: "passwordHint".tr,
      );
      return;
    }
    if (pass != confirm) {
      showAwesomeDialog(
        type: DialogType.warning,
        title: "Validation",
        desc: "confirmPasswordHint".tr,
      );
      return;
    }

    // Get user ID
    final userId = myServices.user?["id"];
    if (userId == null) {
      showAwesomeDialog(
        type: DialogType.error,
        title: "error".tr,
        desc: "sessionExpired".tr,
      );
      return;
    }

    isLoading = true;
    update();

    final token = myServices.token;
    final url = ApiLinks.updateUser(userId is int ? userId : int.parse(userId.toString()));

    final hasNewImage = profileImageBytes != null && profileImageBytes!.isNotEmpty;

    final res = hasNewImage
        ? await crud.postMultipart(
            url,
            token: token,
            fields: <String, String>{
              "_method": "PUT",
              "name": name,
              "email": email,
              if (pass.isNotEmpty) "password": pass,
              if (pass.isNotEmpty) "password_confirmation": confirm,
            },
            files: [
              MultipartFileField(
                fieldName: "profile_image",
                bytes: profileImageBytes,
                fileName: "profile.jpg",
              ),
            ],
          )
        : await crud.putData(
            url,
            <String, dynamic>{
              "name": name,
              "email": email,
              if (pass.isNotEmpty) "password": pass,
            },
            token: token,
          );

    isLoading = false;
    update();

    res.fold((l) {
      showAwesomeDialog(
        type: DialogType.error,
        title: "error".tr,
        desc: "serverError".tr,
      );
    }, (r) async {
      // Update local session with new data
      final returnedUser = r["user"];
      final updatedUser = returnedUser is Map
          ? <String, dynamic>{...Map<String, dynamic>.from(returnedUser)}
          : <String, dynamic>{
              ...?myServices.user,
              "name": name,
              "email": email,
            };
      await myServices.saveSession(
        token: token ?? "",
        type: myServices.type ?? "user",
        user: updatedUser,
      );

      showAwesomeDialog(
        type: DialogType.success,
        title: "success".tr,
        desc: "profileSaved".tr,
        onOk: () => Get.back(),
      );
    });
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}

