import 'dart:async';
import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:t_max/common/web_socket_mgr.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/data/btinfodata.dart';
import 'package:t_max/data/scalecmd_data.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:t_max/data/language.dart';
import 'dart:convert';

class BluetoothManager {
  static final BluetoothManager _instance = BluetoothManager._internal();
  factory BluetoothManager() => _instance;
  BluetoothManager._internal();

  // 参考 test_bt 的配置
  static const String targetServiceUUID = "A002";
  static const String charReadUUID = "C305";
  static const String charWriteUUID = "C304";

  BluetoothDevice? _device;
  BluetoothCharacteristic? _readChar;
  BluetoothCharacteristic? _writeChar;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSub;
  StreamSubscription<List<int>>? _lastNotificationSub;

  bool isConnecting = false;
  bool _isScanning = false;
  int? currentScaleId;

  // 权限请求逻辑 (同步 test_bt)
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();

      bool allGranted = statuses.values.every((status) => status.isGranted);
      return allGranted;
    }
    return true;
  }

  // 连接逻辑 (完全参考 test_bt 的 RK3288 优化版)
  Future<bool> connectToDevice(String mac, {int? scaleId, Function(String)? onStatusUpdate}) async {
    currentScaleId = scaleId;
    if (isConnecting) return false;
    isConnecting = true;

    void update(String msg) {
      debugPrint("BLE: $msg");
      // if (onStatusUpdate != null) onStatusUpdate(msg);
    }

    void finalUpdate(bool success, {String? reason}) {
      if (onStatusUpdate != null) {
        if (success) {
          onStatusUpdate(localizedStrings?.success ?? "Success");
        } else {
          String failStr = localizedStrings?.failure ?? "Failure";
          if (reason != null && reason.isNotEmpty) {
            onStatusUpdate("$failStr: $reason");
          } else {
            onStatusUpdate(failStr);
          }
        }
      }
    }

    // 3. 极速重连优化：如果物理链路已通，直接发起握手测试
    if (_device != null && 
        _device!.remoteId.str.replaceAll(':', '').toUpperCase() == mac.replaceAll(':', '').toUpperCase() &&
        FlutterBluePlus.connectedDevices.any((d) => d.remoteId == _device!.remoteId)) {
      update("物理链路在线，正在激活查询...");
      currentScaleId = scaleId;
      
      // 强制发指令给 Go 激活机种名查询
      debugPrint("BLE: [测试连接] 物理在线，强制发起型号查询...");
      
      ScaleCmd cmdInfo = ScaleCmd("get_factory_info", "");
      if (!WebSocketScaleManager().isConnected(currentScaleId!)) {
        WebSocketScaleManager().connect(currentScaleId!, "ws://127.0.0.1:7878/tmax?scaleid=$currentScaleId");
        await Future.delayed(const Duration(milliseconds: 800));
      }
      
      // 连发三次确保 Go 收到
      for(int i=0; i<3; i++) {
        WebSocketScaleManager().sendMessage(currentScaleId!, jsonEncode(cmdInfo.toJson()));
        await Future.delayed(const Duration(milliseconds: 300));
      }
      
      update("连接已激活，型号查询已发出");
      isConnecting = false;
      finalUpdate(true);
      return true; 
    }

    update("开始新连接流程 ($mac)...");

    try {
      // 1. 权限检查
      update("检查系统权限...");
      if (!await requestPermissions()) {
        update("错误: 缺少必要权限");
        isConnecting = false;
        finalUpdate(false, reason: localizedStrings?.btErrNoPermission);
        return false;
      }

      // 2. 确保蓝牙开启
      update("检查蓝牙状态...");
      if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
        update("错误: 蓝牙未开启");
        isConnecting = false;
        finalUpdate(false, reason: localizedStrings?.btErrNotEnabled);
        return false;
      }

      // 3. 停止扫描并准备
      update("清理旧连接并准备硬件...");
      List<BluetoothDevice> connected = FlutterBluePlus.connectedDevices;
      for (var d in connected) {
        try {
          await d.disconnect();
        } catch (_) {}
      }
      await stopScan();
      await Future.delayed(const Duration(seconds: 1));

      // 4. 开始连接
      update("正在寻找设备 ($mac)...");
      Completer<BluetoothDevice> deviceCompleter = Completer();
      
      var scanSub = FlutterBluePlus.onScanResults.listen((results) {
        for (ScanResult r in results) {
          if (r.device.remoteId.str.replaceAll(':', '').toUpperCase() == 
              mac.replaceAll(':', '').toUpperCase()) {
            if (!deviceCompleter.isCompleted) {
              deviceCompleter.complete(r.device);
            }
          }
        }
      });

      FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

      try {
        _device = await deviceCompleter.future.timeout(const Duration(seconds: 10));
      } catch (e) {
        update("错误: 扫描超时，未找到设备");
        isConnecting = false;
        finalUpdate(false, reason: localizedStrings?.btErrScanTimeout);
        return false;
      } finally {
        await FlutterBluePlus.stopScan();
        await scanSub.cancel();
      }

      // 5. 执行连接 (直接冷重连)
      update("正在连接设备...");
      try {
        await _device!.connect(
          timeout: const Duration(seconds: 15),
          autoConnect: false,
          mtu: null,
        );
      } catch (e) {
        update("初次连接失败，尝试强制重连...");
        try {
          await _device!.disconnect();
        } catch (_) {}
        await Future.delayed(const Duration(seconds: 1));
        await _device!.connect(
          timeout: const Duration(seconds: 15),
          autoConnect: false,
          mtu: null,
        );
      }

      // 6. 链路稳定期
      update("物理链路已挂载，正在稳定连接...");
      await Future.delayed(const Duration(seconds: 3));

      // 7. 发现服务
      update("正在发现秤端服务...");
      List<BluetoothService> services = await _device!.discoverServices();
      
      BluetoothService? targetService;
      for (var s in services) {
        if (s.uuid.toString().toUpperCase().contains(targetServiceUUID)) {
          targetService = s;
          break;
        }
      }

      if (targetService == null) {
        update("错误: 未找到目标服务 $targetServiceUUID");
        isConnecting = false;
        finalUpdate(false, reason: localizedStrings?.btErrNoService);
        return false;
      }

      // 8. 查找特征
      update("配置通信通道...");
      _readChar = null;
      _writeChar = null;
      for (var c in targetService.characteristics) {
        String cUUID = c.uuid.toString().toUpperCase();
        if (cUUID.contains(charReadUUID)) {
          _readChar = c;
        } else if (cUUID.contains(charWriteUUID)) {
          _writeChar = c;
        }
      }

      if (_readChar == null) {
        update("错误: 未找到数据读取通道，连接无效");
        await _device!.disconnect();
        isConnecting = false;
        finalUpdate(false, reason: localizedStrings?.btErrNoReadChannel);
        return false;
      }

      // 9. 开启通知
      update("开启数据监听...");
      currentScaleId = scaleId;
      
      _lastNotificationSub?.cancel();
      _lastNotificationSub = _readChar!.onValueReceived.listen((value) {
        _onDataReceived(value);
      });
      
      try {
        await _readChar!.setNotifyValue(true);
        // 给一点时间让通知生效
        await Future.delayed(const Duration(milliseconds: 600));
        
        // 10. 请求大 MTU (RK3288 兼容：请求 247 确保长数据包不被切碎)
        try {
          update("优化通信带宽...");
          await _device!.requestMtu(247);
          await Future.delayed(const Duration(milliseconds: 300));
        } catch (e) {
          debugPrint("BLE: MTU 请求失败 (可能不支持): $e");
        }
      } catch (e) {
        update("错误: 开启监听失败: $e");
        await _device!.disconnect();
        isConnecting = false;
        finalUpdate(false, reason: localizedStrings?.btErrListenFail);
        return false;
      }

      update("连接成功！");
      isConnecting = false;
      
      // 触发握手：连发 5 次指令确保 Go 后端收到并激活
      if (currentScaleId != null) {
        debugPrint("BLE: 开始 [连发握手] 激活通信 - ScaleId $currentScaleId");
        for (int i = 0; i < 5; i++) {
          Future.delayed(Duration(milliseconds: 600 + (i * 600)), () {
            if (_device == null) return;
            
            // 1. 请求工厂信息
            debugPrint("BLE -> Go (Shot ${i+1}): 发起 [get_factory_info]");
            
            if (!WebSocketScaleManager().isConnected(currentScaleId!)) {
              WebSocketScaleManager().connect(currentScaleId!, "ws://127.0.0.1:7878/tmax?scaleid=$currentScaleId");
            }

            ScaleCmd cmdInfo = ScaleCmd("get_factory_info", "");
            WebSocketScaleManager().sendMessage(currentScaleId!, jsonEncode(cmdInfo.toJson()));
            
            // 2. 开启称重数据推送
            ScaleCmd cmdWeight = ScaleCmd("reg_weight_data", "");
            WebSocketScaleManager().sendMessage(currentScaleId!, jsonEncode(cmdWeight.toJson()));
            
            // 3. 触发 UI 刷新
            eventBus.fire(EventRespScaleOnline(true));
          });
        }
      }
      
      finalUpdate(true);
      return true;
    } catch (e) {
        update("连接异常: $e");
        isConnecting = false;
        finalUpdate(false, reason: localizedStrings?.btErrException);
        return false;
    }
  }

  // 扫描逻辑
  Future<void> startScan() async {
    if (_isScanning) {
      debugPrint("BLE: 正在扫描中，忽略重复请求");
      return;
    }
    _isScanning = true;

    if (!await requestPermissions()) {
      debugPrint("BLE: 缺少扫描权限");
      _isScanning = false;
      return;
    }

    // 确保蓝牙开启
    if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
      debugPrint("BLE: 蓝牙未开启，无法扫描");
      return;
    }

    try {
      debugPrint("BLE: 开始扫描...");
      await FlutterBluePlus.stopScan();
      
      List<BtInfo> foundDevices = [];
      StreamSubscription? scanSub;
      
      scanSub = FlutterBluePlus.scanResults.listen((results) {
        if (results.isEmpty) return; // 忽略空结果
        
        foundDevices.clear();
        for (ScanResult r in results) {
          String name = r.device.platformName;
          if (name.isEmpty) {
            name = r.advertisementData.advName;
          }
          if (name.isEmpty) {
            name = "Unknown (${r.device.remoteId.str})"; // 即使没名字也显示，防止空白
          }
          
          foundDevices.add(BtInfo(
            name: name,
            mac: r.device.remoteId.str,
            rssi: r.rssi,
          ));
        }
        
        debugPrint("BLE: 发现 ${foundDevices.length} 个设备");
        String jsonStr = jsonEncode(foundDevices.map((e) => e.toJson()).toList());
        eventBus.fire(EventBtInfoList(jsonStr));
      });

      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
        androidUsesFineLocation: true,
      );

      // 等待扫描停止
      await FlutterBluePlus.isScanning.where((scanning) => !scanning).first;
      
      debugPrint("BLE: 扫描结束");
      await scanSub.cancel();
      
      // 扫描结束后，如果依然没设备，发送一个空列表以通知 UI 停止加载状态
      if (foundDevices.isEmpty) {
        eventBus.fire(EventBtInfoList("[]"));
      }
    } catch (e) {
      debugPrint("BLE: 扫描出错: $e");
      eventBus.fire(EventBtInfoList("fail"));
    } finally {
      _isScanning = false;
    }
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  // 发送数据 (RK3288 兼容：强制 withoutResponse=true)
  // 将字节数组转为 16 进制字符串用于调试
  String _toHex(List<int> data) {
    return data.map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join(' ');
  }

  // 向蓝牙设备发送数据
  void sendData(List<int> data) async {
    if (_device == null || _writeChar == null) {
      debugPrint("BLE: 发送失败 - 设备未连接或写特征不可用");
      return;
    }

    String hex = _toHex(data);
    try {
      // 实时调试：显示发送的具体指令内容 (已移除高频 Toast 以防崩溃)
      
      // 尝试写入（RK3288 及普通安卓兼容处理）
      await _writeChar!.write(data, withoutResponse: true).timeout(Duration(seconds: 2));
      debugPrint("BLE <- Go: 已写入 $hex");
    } catch (e) {
      debugPrint("BLE: 写入数据异常: $e");
      // 如果 withoutResponse 失败，尝试带响应写入
      try {
        await _writeChar!.write(data, withoutResponse: false);
        debugPrint("BLE <- Go (兼容模式): 已写入 $hex");
      } catch (e2) {
        debugPrint("写入秤失败: $e2 内容: $hex");
      }
    }
  }

  // 处理接收到的数据并转发给 Go
  void _onDataReceived(List<int> data) {
    if (data.isEmpty) return;
    
    String hex = _toHex(data);
    // 实时调试：显示接收的具体数据内容 (已移除高频 Toast 以防崩溃)
    
    _forwardDataToGo(data);
  }

  // 断开连接
  Future<void> disconnect() async {
    if (_device != null) {
      try {
        await _device!.disconnect();
      } catch (e) {
        debugPrint("BLE: 断开连接异常: $e");
      }
    }
    _cleanupConnection();
  }

  void _cleanupConnection() {
    _lastNotificationSub?.cancel();
    _lastNotificationSub = null;
    _readChar = null;
    _writeChar = null;
    currentScaleId = null; 
  }

  // 转发原始数据给 Go 解析
  void _forwardDataToGo(List<int> data) {
    if (currentScaleId == null) return;
    
    // 根据 Go 后端 svc/srvproto.go 定义：
    // SREQ_VIRTUAL_SERIAL_READ = "virtual_serial_read"
    // 后端预期 ReqData 直接就是 base64 字符串
    ScaleCmd cmd = ScaleCmd(
      "virtual_serial_read", 
      base64Encode(data)
    );

    // 关键：必须通过对应的秤通道发送数据
    debugPrint("BLE -> Go [$currentScaleId]: ${cmd.cmdData!.length} chars base64");
    
    if (!WebSocketScaleManager().isConnected(currentScaleId!)) {
      WebSocketScaleManager().connect(currentScaleId!, "ws://127.0.0.1:7878/tmax?scaleid=$currentScaleId");
    }

    WebSocketScaleManager().sendMessage(currentScaleId!, jsonEncode(cmd.toJson()));
  }
}

final bluetoothManager = BluetoothManager();
