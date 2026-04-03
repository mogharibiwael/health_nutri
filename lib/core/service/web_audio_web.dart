import 'dart:html' as html;
import 'package:flutter/foundation.dart';

void playWebNotificationSound(String path) {
  try {
    html.AudioElement(path).play();
  } catch (e) {
    debugPrint("NotificationService: Web audio playback failed ($e)");
  }
}
