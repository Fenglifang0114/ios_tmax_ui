import 'log_access.dart';

void writelog(String dataStr) async {
  try {
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
