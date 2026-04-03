import 'package:flutter/foundation.dart';
import 'dart:io';

Future<bool> checkInternet() async {
  if (kIsWeb) return true; // InternetAddress.lookup fails on Web
  try {
    var result = await InternetAddress.lookup("google.com");
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    }
    return false;
  } on SocketException catch (_) {
    return false;
  } catch (_) {
    return false;
  }
}
