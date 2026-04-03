import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/api_link.dart';
import '../../../core/service/serviecs.dart';
import '../../../core/constant/theme/colors.dart';
import '../data/medical_files_data.dart';
import '../model/medical_file_model.dart';

class MedicalFilesController extends GetxController {
  final MedicalFilesData data = MedicalFilesData(Get.find());
  final MyServices myServices = Get.find();

  final statusRequest = Rx<StatusRequest>(StatusRequest.loading);
  final RxList<MedicalFileModel> files = <MedicalFileModel>[].obs;
  int currentPage = 1;
  int lastPage = 1;
  bool hasMore = true;
  bool _isLoadingMore = false;
  bool _isLoading = false;
  DateTime? _lastRateLimitAt;

  bool get isLoadingMore => _isLoadingMore;
  String? get token => myServices.token;

  @override
  void onInit() {
    super.onInit();
    loadFiles(first: true);
  }

  Future<void> loadFiles({bool first = false}) async {
    if (_isLoading) return;
    if (first && _lastRateLimitAt != null) {
      final elapsed = DateTime.now().difference(_lastRateLimitAt!);
      if (elapsed.inSeconds < 60) return;
    }

    _isLoading = true;
    if (first) {
      currentPage = 1;
      hasMore = true;
      files.clear();
      _isLoadingMore = false;
      statusRequest.value = StatusRequest.loading;
    } else {
      _isLoadingMore = true;
    }

    try {
      final res = await data.getMedicalFiles(token: token, page: currentPage);
      _isLoadingMore = false;

      res.fold((l) {
        if (l == StatusRequest.rateLimit) _lastRateLimitAt = DateTime.now();
        statusRequest.value = l;
      }, (r) {
        _lastRateLimitAt = null;
        final dataRaw = r["data"];
        final list = dataRaw is List ? dataRaw : <dynamic>[];
        for (final e in list) {
          if (e is Map) {
            try {
              files.add(MedicalFileModel.fromJson(Map<String, dynamic>.from(e)));
            } catch (_) {}
          }
        }
        lastPage = (r["last_page"] is int)
            ? r["last_page"] as int
            : int.tryParse("${r["last_page"]}") ?? 1;
        hasMore = currentPage < lastPage;
        statusRequest.value = StatusRequest.success;
      });
    } catch (e) {
      _isLoadingMore = false;
      statusRequest.value = StatusRequest.serverFailure;
    } finally {
      _isLoading = false;
    }
  }

  /// True if we recently hit rate limit and should wait before retrying
  bool get isRateLimitCooldown {
    if (_lastRateLimitAt == null) return false;
    return DateTime.now().difference(_lastRateLimitAt!).inSeconds < 60;
  }

  Future<void> refresh() async {
    if (_isLoading) return;
    if (isRateLimitCooldown) {
      Get.snackbar("", "tooManyRequests".tr);
      return;
    }
    if (statusRequest == StatusRequest.loading && files.isEmpty) return;
    await loadFiles(first: true);
  }

  void loadMore() {
    if (!hasMore || statusRequest == StatusRequest.loading || _isLoadingMore) return;
    currentPage++;
    loadFiles(first: false);
  }

  /// Download file and save to device, returns saved path or null
  Future<String?> downloadFile(MedicalFileModel file) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${dir.path}/downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final fileName = file.fileName.contains('.')
          ? file.fileName
          : '${file.fileName}.${file.fileType}';
      final savePath = '${downloadsDir.path}/$fileName';

      List<int>? bytes;
      for (final url in file.downloadUrls) {
        if (url.contains('/api/')) {
          bytes = await data.downloadFileBytes(url, token: token);
        } else {
          final headers = <String, String>{
            'Accept': 'application/octet-stream,*/*',
            if (token != null && token!.isNotEmpty)
              'Authorization': 'Bearer $token',
          };
          final response = await http.get(Uri.parse(url), headers: headers);
          if (response.statusCode == 200) {
            bytes = response.bodyBytes;
          }
        }
        // Backend may return 200 with JSON like {"message": "..."} instead of file bytes - skip it
        if (bytes != null && bytes.isNotEmpty && !_isJsonResponse(bytes)) {
          break;
        }
        bytes = null; // try next URL
      }

      if (bytes == null || bytes.isEmpty) {
        _showDownloadFailedWithFallback(file);
        return null;
      }

      final fileOut = File(savePath);
      await fileOut.writeAsBytes(bytes);

      return savePath;
    } catch (e) {
      Get.snackbar("error".tr, "downloadFailed".tr);
      return null;
    }
  }

  /// Backend sometimes returns 200 with JSON (e.g. {"message": "..."}) instead of file bytes.
  /// Treat that as failure so we try the next URL or show the fallback dialog.
  bool _isJsonResponse(List<int> bytes) {
    if (bytes.isEmpty) return true;
    int i = 0;
    while (i < bytes.length &&
        (bytes[i] == 32 || bytes[i] == 9 || bytes[i] == 10 || bytes[i] == 13)) {
      i++;
    }
    if (i >= bytes.length) return true;
    final b = bytes[i];
    return b == 0x7b || b == 0x5b; // '{' or '['
  }

  void _showDownloadFailedWithFallback(MedicalFileModel file) {
    Get.dialog(
      AlertDialog(
        title: Text("downloadFailed".tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("downloadFailedTryBrowser".tr),
            const SizedBox(height: 12),
            ...file.downloadUrls.take(3).map((url) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () async {
                  try {
                    final uri = Uri.parse(url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  } catch (_) {}
                },
                child: Text(
                  url,
                  style: const TextStyle(fontSize: 11, color: Colors.blue, decoration: TextDecoration.underline),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )),
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

  Future<void> downloadAndShow(MedicalFileModel file) async {
    final path = await downloadFile(file);
    if (path != null) {
      final result = await OpenFilex.open(path);
      if (result.type == ResultType.done) {
        Get.snackbar("success".tr, "downloadSuccess".tr);
      } else {
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
  }
}
