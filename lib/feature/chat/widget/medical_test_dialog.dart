import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constant/theme/colors.dart';

/// Dialog for uploading a medical test (الفحص الطبي).
/// Shows when patient taps attach in chat - enter test name, pick file, send to api/medical-tests.
class MedicalTestDialog extends StatefulWidget {
  final int doctorId;
  final Future<void> Function({
    required String name,
    required String filePath,
    String? fileName,
  }) onSend;

  const MedicalTestDialog({
    super.key,
    required this.doctorId,
    required this.onSend,
  });

  static Future<void> show({
    required BuildContext context,
    required int doctorId,
    required Future<void> Function({
      required String name,
      required String filePath,
      String? fileName,
    }) onSend,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => MedicalTestDialog(
        doctorId: doctorId,
        onSend: onSend,
      ),
    );
  }

  @override
  State<MedicalTestDialog> createState() => _MedicalTestDialogState();
}

class _MedicalTestDialogState extends State<MedicalTestDialog> {
  final TextEditingController _nameController = TextEditingController();
  String? _filePath;
  String? _fileName;
  bool _isSending = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final xFile = await picker.pickImage(source: ImageSource.gallery);
      if (xFile != null) {
        setState(() {
          _filePath = xFile.path;
          _fileName = xFile.name;
        });
      }
    } catch (e) {
      Get.snackbar("error".tr, "Could not pick image");
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty) {
        final f = result.files.first;
        final path = f.path;
        if (path != null && path.isNotEmpty) {
          setState(() {
            _filePath = path;
            _fileName = f.name;
          });
        } else {
          Get.snackbar("error".tr, "File path not available");
        }
      }
    } catch (e) {
      Get.snackbar("error".tr, "Could not pick file");
    }
  }

  void _showPickOptions() {
    final isAr = Get.locale?.languageCode == 'ar';
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text("Photo"),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: const Text("File"),
              onTap: () {
                Navigator.pop(ctx);
                _pickFile();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _send() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar("error".tr, "enterTestName".tr);
      return;
    }
    if (_filePath == null || _filePath!.isEmpty) {
      Get.snackbar("error".tr, "selectFile".tr);
      return;
    }
    if (!File(_filePath!).existsSync()) {
      Get.snackbar("error".tr, "File not found");
      return;
    }

    setState(() => _isSending = true);
    try {
      await widget.onSend(
        name: name,
        filePath: _filePath!,
        fileName: _fileName,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      Get.snackbar("error".tr, "Failed to upload");
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "medicalTest".tr,
                style:  TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColor.primary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: "enterTestName".tr,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _isSending ? null : _showPickOptions,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _filePath != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.insert_drive_file, size: 40, color: AppColor.primary),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      _fileName ?? "file",
                                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: isAr ? null : 8,
                              left: isAr ? 8 : null,
                              child: IconButton(
                                icon: const Icon(Icons.close, size: 20),
                                onPressed: () => setState(() {
                                  _filePath = null;
                                  _fileName = null;
                                }),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined, size: 48, color: Colors.grey.shade500),
                            const SizedBox(height: 8),
                            Text(
                              "tapToUpload".tr,
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSending ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text("close".tr),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSending ? null : _send,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSending
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text("send".tr),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
