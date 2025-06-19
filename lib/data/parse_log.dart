import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

const String myLogName = 'operation.log';
const String myIpConfig = 'server_ip.config';
const String myIpListName = 'wifi\\ip_list.txt';
const String myLogDir = 'records';
const String myImportDir = 'import';
const String myPrnFormatDir = 'prnFormat';
const String myFirmwareDir = 'firmware';
const String mySerialOutput = 'serialOutput';
const String myLastRecName = 'records.txt';
const String myImportLogName = 'operation.log';
const String mySelectedPageJson = 'page.json';

List<Map<String, dynamic>> parseLog(String contentStr, String targetStr) {
  RegExp regExp = RegExp(r'(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d+){(.+)}');

  List<Map<String, dynamic>> jsonDataList = [];
  Set<String> uniqueReqSet = {};
  List<String> lines =
      LineSplitter.split(contentStr).toList().reversed.toList();

  for (String line in lines) {
    if (jsonDataList.length == 13) {
      return jsonDataList;
    }
    Match? match = regExp.firstMatch(line);
    if (match != null) {
      String jsonText = '{${match.group(2)}}';
      Map<String, dynamic> jsonData = json.decode(jsonText);
      String req = jsonData['Req'];

      // 如果 jsonDataList 中已经存在相同的 "Req" 值，则跳过存储
      if (uniqueReqSet.contains(req) ||
          (req == 'set_wifi_static_ip' &&
              uniqueReqSet.contains('set_wifi_dynamic_ip')) ||
          (req == 'set_wifi_dynamic_ip' &&
              uniqueReqSet.contains('set_wifi_static_ip'))) {
        continue;
      }
      uniqueReqSet.add(req); // 将新的 "Req" 值添加到集合中
      jsonDataList.add(jsonData);
    }
  }
  return jsonDataList;
}

String getBtNameFromLog(List<Map<String, dynamic>> jsonDataList) {
  for (Map<String, dynamic> jsonData in jsonDataList) {
    String req = jsonData['Req'];
    String reqData = jsonData['ReqData'];
    if (req == 'modify_bt_name') {
      return reqData;
    }
  }
  return '';
}

String getFirmwarePathFromLog(List<Map<String, dynamic>> jsonDataList) {
  for (Map<String, dynamic> jsonData in jsonDataList) {
    String req = jsonData['Req'];
    String reqData = jsonData['ReqData'];
    if (req == 'update_firmware') {
      return reqData;
    }
  }
  return '';
}

String getWifiNameFromLog(List<Map<String, dynamic>> jsonDataList) {
  for (Map<String, dynamic> jsonData in jsonDataList) {
    String req = jsonData['Req'];
    String reqData = jsonData['ReqData'];
    if (req == 'connect_ap') {
      try {
        Map<String, dynamic> parsedJson = jsonDecode(reqData);
        return parsedJson['ssid'];
      } catch (e) {
        return '';
      }
    }
  }
  return '';
}

String getIpAddrFromLog(List<Map<String, dynamic>> jsonDataList) {
  for (Map<String, dynamic> jsonData in jsonDataList) {
    String req = jsonData['Req'];
    String reqData = jsonData['ReqData'];
    if (req == 'set_wifi_static_ip') {
      try {
        Map<String, dynamic> parsedJson = jsonDecode(reqData);
        return parsedJson['ip'];
      } catch (e) {
        return '';
      }
    }
  }
  return '';
}

List<String> getPrintFmtFromLog(List<Map<String, dynamic>> jsonDataList) {
  List<String> fmtPaths = [];
  for (Map<String, dynamic> jsonData in jsonDataList) {
    String req = jsonData['Req'];
    String reqData = jsonData['ReqData'];
    if (req == 'down_print_format_to_scale') {
      try {
        Map<String, dynamic> parsedJson = jsonDecode(reqData);
        fmtPaths = parsedJson['FilePaths'].cast<String>();
        return fmtPaths;
      } catch (e) {
        return fmtPaths;
      }
    }
  }
  return fmtPaths;
}

List<String> getSerialOutputFromLog(List<Map<String, dynamic>> jsonDataList) {
  List<String> outPaths = [];
  for (Map<String, dynamic> jsonData in jsonDataList) {
    String req = jsonData['Req'];
    String reqData = jsonData['ReqData'];
    if (req == 'set_output_format') {
      try {
        Map<String, dynamic> parsedJson = jsonDecode(reqData);
        outPaths = parsedJson['FilePath'].cast<String>();
        return outPaths;
      } catch (e) {
        return outPaths;
      }
    }
  }
  return outPaths;
}

Future<String> getAppFilePath(String fileName) async {
  String appDirectory = Platform.resolvedExecutable;
  var directory = p.dirname(appDirectory);
  directory = '$directory\\$myLogDir';
  final formatfilePath = Directory('$directory\\$fileName');
  return formatfilePath.path;
}

Future<String> getAppImportPath(String fileName) async {
  String appDirectory = Platform.resolvedExecutable;
  var directory = p.dirname(appDirectory);
  directory = '$directory\\$myImportDir';
  final formatfilePath = Directory('$directory\\$fileName');
  return formatfilePath.path;
}

/// 将选择的 pageId 列表写入 JSON 文件
/// [configPageList] 配置页面的 pageId 列表
/// [appPagedList] 应用页面的 pageId 列表
/// [defaultPageId] 默认页面的 pageId
Future<void> writePageIdsToJson(
    Set<int> configPageList, Set<int> appPagedList, String routeName) async {
  // 将 Set 转换为 List，确保可以正确进行 JSON 编码
  final data = {
    'configPageList': configPageList.toList(),
    'appPagedList': appPagedList.toList(),
    'defaultPageId': routeName,
  };

  // 将 Map 转换为 JSON 字符串
  final jsonString = jsonEncode(data);

  // 获取应用目录
  String appDirectory = Platform.resolvedExecutable;
  var directory = p.dirname(appDirectory);
  directory = '$directory\\$myLogDir';

  // 确保目录存在
  await Directory(directory).create(recursive: true);

  // 构建文件路径
  final filePath = '$directory\\$mySelectedPageJson';

  // 将 JSON 字符串写入文件
  await File(filePath).writeAsString(jsonString);
}

Future<Map<String, dynamic>> readPageIdsFromJsonReversed() async {
  // 获取应用目录
  String appDirectory = Platform.resolvedExecutable;
  var directory = p.dirname(appDirectory);
  directory = '$directory\\$myLogDir';

  // 构建文件路径
  final filePath = '$directory\\$mySelectedPageJson';
  final file = File(filePath);

  // 检查文件是否存在
  if (await file.exists()) {
    // 读取文件内容
    final jsonString = await file.readAsString();
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    // 倒序处理列表
    data['configPageList'] = (data['configPageList'] as List).toList();
    data['appPagedList'] = (data['appPagedList'] as List).toList();

    return data;
  }
  return {};
}
