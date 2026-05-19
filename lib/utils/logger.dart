import 'package:flutter/foundation.dart';

class Log {
  static void d(Object? message) {
    if (kDebugMode) {
      print("DEBUG: $message");
    }
  }

  static void e(Object? message) {
    if (kDebugMode) {
      print("ERROR: $message");
    }
  }
}