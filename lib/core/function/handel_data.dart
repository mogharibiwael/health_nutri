import 'package:nutri_guide/core/class/status_request.dart';

handelData(response) {
  if (response is StatusRequest) {
    return response;
  } else {
    return StatusRequest.success;
  }
}
