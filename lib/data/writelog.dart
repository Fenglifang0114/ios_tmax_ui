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
