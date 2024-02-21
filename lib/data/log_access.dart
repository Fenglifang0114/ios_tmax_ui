import 'dart:io';

import 'package:t_max/data/parse_log.dart';

class MyLogAccess {
  writeLog(String newLogStr) async {
    String logFilePath = await getAppFilePath(myLogName);
    // 检查文件是否
    bool fileExists = await File(logFilePath).exists();

    if (!fileExists) {
      await File(logFilePath).create(recursive: true);
    }
    File(logFilePath).writeAsStringSync(
        DateTime.now().toString() + newLogStr + '\r\n',
        mode: FileMode.append);
  }

  writeRecordsName(String newLogStr) async {
    String logFilePath = await getAppFilePath(myLastRecName);
    // 检查文件是否
    bool fileExists = await File(logFilePath).exists();

    if (!fileExists) {
      await File(logFilePath).create(recursive: true);
    }
    File(logFilePath)
        .writeAsStringSync(newLogStr + '\r\n', mode: FileMode.append);
  }

  clearRecordsName() async {
    String logFilePath = await getAppFilePath(myLastRecName);
    // 检查文件是否
    bool fileExists = await File(logFilePath).exists();

    if (fileExists) {
      File(logFilePath).writeAsStringSync('', flush: true);
    }
  }

  Future<String> readLog() async {
    String contentStr = '';
    String logFilePath = await getAppFilePath(myLogName);
    // 检查文件是否存在
    bool fileExists = await File(logFilePath).exists();
    if (!fileExists) {
      return contentStr;
    }
    // 追加写入日志
    String fileContent = await File(logFilePath).readAsString();
    return fileContent;
  }

  Future<String> readImportLog() async {
    String contentStr = '';
    String logFilePath = await getAppImportPath(myImportLogName);
    // 检查文件是否存在
    bool fileExists = await File(logFilePath).exists();
    if (!fileExists) {
      return contentStr;
    }
    // 追加写入日志
    String fileContent = await File(logFilePath).readAsString();
    return fileContent;
  }

  Future<String> readRecordName() async {
    String contentStr = '';
    String logFilePath = await getAppImportPath(myLastRecName);
    // 检查文件是否存在
    bool fileExists = await File(logFilePath).exists();
    if (!fileExists) {
      return contentStr;
    }
    // 追加写入日志
    String fileContent = await File(logFilePath).readAsString();
    return fileContent;
  }
}

MyLogAccess mylogFileAccess = MyLogAccess();
