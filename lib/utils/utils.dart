import 'package:flutter/foundation.dart' show kIsWeb;

bool isOnWeb() {
  if (kIsWeb) {
    return true;
  }
  return false;
}
