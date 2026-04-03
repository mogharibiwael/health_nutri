import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import 'package:nutri_guide/core/constant/api_header.dart';
import 'status_request.dart';
import '../function/check_internet.dart';

/// File field for multipart: path to local file and field name
class MultipartFileField {
  final String fieldName;
  final String filePath;
  final String? fileName;

  MultipartFileField({
    required this.fieldName,
    required this.filePath,
    this.fileName,
  });
}

class Crud {
  /// Change this one value and it affects all requests.
  static const Duration requestTimeout = Duration(seconds: 20);

  Future<Either<StatusRequest, Map<String, dynamic>>> postData(String url,
      Map<String, dynamic> data, {
        String? token,
      }) async {
    try {
      final hasInternet = await checkInternet();
      if (!hasInternet) return const Left(StatusRequest.offlineFailure);

      final uri = Uri.parse(url);

      final res = await http
          .post(
        uri,
        headers: getHeader(token),
        body: jsonEncode(data),
      )
          .timeout(requestTimeout);

      final body = res.body.isEmpty ? "{}" : res.body;

      print(body);
      print(res);

      Map<String, dynamic> json;
      try {
        json = jsonDecode(body) as Map<String, dynamic>;
      } catch (_) {
        // Not JSON? Still return something consistent
        json = {"message": body};
      }

      // ✅ Return all responses as Right so controllers can handle error messages from body
      return Right({...json, "_statusCode": res.statusCode});
    } on TimeoutException catch (e) {
      print("CRUD timeout: $e");
      // choose one: serverFailure or failure
      return const Left(StatusRequest.serverFailure);
    } on SocketException catch (e) {
      print("CRUD socket: $e");
      return const Left(StatusRequest.offlineFailure);
    } on http.ClientException catch (e) {
      print("CRUD client exception: $e");
      return const Left(StatusRequest.serverFailure);
    } catch (e, track) {
      print("CRUD postData exception: $e");
      print(track);
      return const Left(StatusRequest.serverFailure);
    }
  }

  /// POST multipart/form-data for file uploads (e.g. register with cv, degree)
  Future<Either<StatusRequest, Map<String, dynamic>>> postMultipart(
    String url, {
    required Map<String, String> fields,
    List<MultipartFileField>? files,
    String? token,
  }) async {
    try {
      final hasInternet = await checkInternet();
      if (!hasInternet) return const Left(StatusRequest.offlineFailure);

      final uri = Uri.parse(url);
      final request = http.MultipartRequest('POST', uri);

      final headers = getHeader(token);
      request.headers['Accept'] = headers['Accept'] ?? 'application/json';
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      // Do NOT set Content-Type for multipart - http package sets it with boundary

      for (final e in fields.entries) {
        request.fields[e.key] = e.value;
      }

      if (files != null) {
        for (final f in files) {
          final file = File(f.filePath);
          if (await file.exists()) {
            final fileName = f.fileName ?? file.path.split(RegExp(r'[/\\]')).last;
            request.files.add(await http.MultipartFile.fromPath(
              f.fieldName,
              f.filePath,
              filename: fileName,
            ));
          }
        }
      }

      final streamed = await request.send().timeout(requestTimeout);
      final res = await http.Response.fromStream(streamed);
      final body = res.body.isEmpty ? "{}" : res.body;

      Map<String, dynamic> json;
      try {
        json = jsonDecode(body) as Map<String, dynamic>;
      } catch (_) {
        json = {"message": body};
      }

      if (res.statusCode == 200 || res.statusCode == 201) return Right(json);
      if (res.statusCode == 422) return Right({...json, "_statusCode": res.statusCode});
      if (res.statusCode == 401 || res.statusCode == 403) return Right({...json, "_statusCode": res.statusCode});
      // 5xx etc.: return body so app can show server message in Awesome dialog
      return Right({...json, "_statusCode": res.statusCode});
    } on TimeoutException {
      return const Left(StatusRequest.serverFailure);
    } on SocketException {
      return const Left(StatusRequest.offlineFailure);
    } catch (e, st) {
      print("postMultipart error: $e $st");
      return const Left(StatusRequest.serverFailure);
    }
  }

  Future<Either<StatusRequest, Map<String, dynamic>>> getData(
      String url, {
        String? token,
        Map<String, dynamic>? query,
      }) async {
    try {
      final hasInternet = await checkInternet();
      if (!hasInternet) return const Left(StatusRequest.offlineFailure);

      Uri uri = Uri.parse(url);
      if (query != null && query.isNotEmpty) {
        uri = uri.replace(queryParameters: {
          ...uri.queryParameters,
          ...query.map((k, v) => MapEntry(k, v.toString())),
        });
      }

      print("GET => $uri");

      final res = await http
          .get(uri, headers: getHeader(token))
          .timeout(requestTimeout);

      print("GET status: ${res.statusCode}");

      final body = res.body.isEmpty ? "{}" : res.body;

      // Handle both JSON objects and arrays from backend
      Map<String, dynamic> json;
      try {
        final decoded = jsonDecode(body);
        json = (decoded is Map)
            ? Map<String, dynamic>.from(decoded)
            : {"data": decoded}; // wrap arrays in a "data" key
      } catch (_) {
        // Response is not valid JSON (e.g. HTML error page)
        print("GET JSON parse failed, body: ${body.length > 300 ? body.substring(0, 300) : body}");
        json = {"message": body};
      }

      // ✅ Return all responses as Right so controllers can handle error messages from body
      return Right({...json, "_statusCode": res.statusCode});
    } on TimeoutException catch (e) {
      print("GET timeout: $e");
      return const Left(StatusRequest.serverFailure);
    } on SocketException catch (e) {
      print("GET socket: $e");
      return const Left(StatusRequest.offlineFailure);
    } on http.ClientException catch (e) {
      print("GET client exception: $e");
      return const Left(StatusRequest.serverFailure);
    } catch (e, stack) {
      print("CRUD getData exception: $e");
      print(stack);
      return const Left(StatusRequest.serverFailure);
    }
  }

  /// GET raw bytes (for file download). Returns bytes on success, null on failure.
  Future<Uint8List?> getFileBytes(String url, {String? token}) async {
    try {
      final hasInternet = await checkInternet();
      if (!hasInternet) return null;

      final res = await http
          .get(Uri.parse(url), headers: getHeaderForFile(token))
          .timeout(const Duration(seconds: 60));

      if (res.statusCode == 200 || res.statusCode == 201) {
        return res.bodyBytes;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<Either<StatusRequest, Map<String, dynamic>>> putData(
      String url,
      Map<String, dynamic> data, {
        String? token,
      }) async {
    try {
      final hasInternet = await checkInternet();
      if (!hasInternet) return const Left(StatusRequest.offlineFailure);

      final res = await http.put(
        Uri.parse(url),
        headers: getHeader(token),
        body: jsonEncode(data),
      );

      final body = res.body.isEmpty ? "{}" : res.body;
      final Map<String, dynamic> json = jsonDecode(body);

      // غالباً Laravel يرجع 200
      if (res.statusCode == 200 || res.statusCode == 201) return Right(json);
      if (res.statusCode == 422) return Right(json);
      if (res.statusCode == 401) return const Left(StatusRequest.failure);

      // ✅ لو السيرفر رجع message مفيد مع 403/405... خلّه يوصل للكنترولر
      if (json.isNotEmpty) return Right(json);

      return const Left(StatusRequest.serverFailure);
    } catch (_) {
      return const Left(StatusRequest.serverFailure);
    }
  }

  Future<Either<StatusRequest, Map<String, dynamic>>> deleteData(
    String url, {
    String? token,
  }) async {
    try {
      final hasInternet = await checkInternet();
      if (!hasInternet) return const Left(StatusRequest.offlineFailure);

      final res = await http.delete(
        Uri.parse(url),
        headers: getHeader(token),
      ).timeout(requestTimeout);

      final body = res.body.isEmpty ? "{}" : res.body;
      Map<String, dynamic> json;
      try {
        json = jsonDecode(body) as Map<String, dynamic>;
      } catch (_) {
        json = {"message": body};
      }

      if (res.statusCode == 200 || res.statusCode == 201 || res.statusCode == 204) {
        return Right(json);
      }
      if (res.statusCode == 422) return Right(json);
      if (res.statusCode == 401 || res.statusCode == 403) return Right(json);
      return const Left(StatusRequest.serverFailure);
    } catch (_) {
      return const Left(StatusRequest.serverFailure);
    }
  }
}