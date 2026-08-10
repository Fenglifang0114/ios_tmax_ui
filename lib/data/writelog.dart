import 'dart:io';
import 'log_access.dart';

void writelog(String dataStr) async {
  print("[TMAX_LOG] $dataStr");
  try {
    if (Platform.isAndroid) {
      final file = File('/sdcard/Download/tmax_debug.log');
      await file.writeAsString(
        '${DateTime.now()} $dataStr\r\n',
        mode: FileMode.append,
        flush: true,
      );
    }
    await mylogFileAccess.writeLog(dataStr);
  } catch (error) {
    return;
  }
}

Future<String> readlog() async {
  try {
    return await mylogFileAccess.readLog();
  } catch (error) {
    return '';
  }
}

Future<void> delRecordsName() async {
  try {
    await mylogFileAccess.clearRecordsName();
  } catch (error) {
    return;
  }
}

Future<void> writeRecordsName(String dataStr) async {
  try {
    await mylogFileAccess.writeRecordsName(dataStr);
  } catch (error) {
    return;
  }
}

Future<String> readRecName() async {
  try {
    return await mylogFileAccess.readRecordName();
  } catch (error) {
    return '';
  }
}

Future<String> readImportlog() async {
  try {
    return await mylogFileAccess.readImportLog();
  } catch (error) {
    return '';
  }
}
