import 'dart:io';
import 'package:flutter/foundation.dart';

String platformName() {
  if (kIsWeb) return "Web";
  if (Platform.isAndroid) return "Android";
  if (Platform.isIOS) return "iOS";
  if (Platform.isWindows) return "Windows";
  if (Platform.isLinux) return "Linux";
  if (Platform.isMacOS) return "MacOS";
  return "Unknown";
}
