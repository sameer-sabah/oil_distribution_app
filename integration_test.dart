import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    onScreenshot: (
      String screenshotName,
      List<int> screenshotBytes, [
      Map<String, Object?>? args,
    ]) async {
      final directory = Directory('screenshots');
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }

      final file = File(
        '${directory.path}/$screenshotName.png',
      );

      await file.writeAsBytes(
        screenshotBytes,
        flush: true,
      );

     debugPrint('SAVED: ${file.path}');
      return true;
    },
  );
}
