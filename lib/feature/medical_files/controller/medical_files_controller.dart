import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/class/status_request.dart';
import '../../../core/constant/theme/colors.dart';
import '../model/medical_file_model.dart';

class MedicalFilesController extends GetxController {
  final statusRequest = Rx<StatusRequest>(StatusRequest.loading);
  final RxList<AssetMedicalFileModel> files = <AssetMedicalFileModel>[].obs;
  bool _isLoading = false;

  @override
  void onInit() {
    super.onInit();
    loadFiles();
  }

  Future<void> loadFiles() async {
    if (_isLoading) return;
    _isLoading = true;
    statusRequest.value = StatusRequest.loading;
    files.clear();

    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final pdfAssets = manifest
          .listAssets()
          .where((k) => k.startsWith('assets/files/') && k.toLowerCase().endsWith('.pdf'))
          .toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

      files.assignAll(pdfAssets.map((p) => AssetMedicalFileModel(assetPath: p)));
      statusRequest.value = StatusRequest.success;
    } catch (e) {
      debugPrint("[MedicalFiles] loadFiles assets failed: $e");
      statusRequest.value = StatusRequest.failure;
    } finally {
      _isLoading = false;
    }
  }

  Future<void> refresh() async {
    if (_isLoading) return;
    await loadFiles();
  }

  /// Copy asset PDF to app documents/downloads and return saved path.
  Future<String?> downloadFile(AssetMedicalFileModel file) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${dir.path}/downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final fileName = file.fileName.toLowerCase().endsWith('.pdf') ? file.fileName : '${file.fileName}.pdf';
      final savePath = '${downloadsDir.path}/$fileName';

      final bytes = await rootBundle.load(file.assetPath);
      final fileOut = File(savePath);
      await fileOut.writeAsBytes(bytes.buffer.asUint8List());

      return savePath;
    } catch (e) {
      debugPrint("[MedicalFiles] downloadFile(asset) unexpected exception: $e");
      Get.snackbar("error".tr, "downloadFailed".tr);
      return null;
    }
  }

  Future<void> downloadAndShow(AssetMedicalFileModel file) async {
    final path = await downloadFile(file);
    if (path == null) return;

    final result = await OpenFilex.open(path);
    if (result.type == ResultType.done) {
      Get.snackbar("success".tr, "downloadSuccess".tr);
      return;
    }

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColor.primary, size: 28),
            const SizedBox(width: 12),
            Text("downloadSuccess".tr),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("fileDownloadedTo".tr),
            const SizedBox(height: 8),
            SelectableText(
              path,
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("close".tr),
          ),
        ],
      ),
    );
  }
}
