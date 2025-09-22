import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestPermission(bool fromCamera) async {
  if (fromCamera) {
    return (await Permission.camera.request()).isGranted;
  } else {
    if (Platform.isAndroid) {
      return (await Permission.storage.request()).isGranted;
    }
    return false;
  }
}
