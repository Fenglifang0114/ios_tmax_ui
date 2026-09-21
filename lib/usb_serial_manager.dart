import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:usb_serial/usb_serial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/data/scale_info_from_db.dart';

class UsbSerialManager {
  static final UsbSerialManager _instance = UsbSerialManager._internal();
  factory UsbSerialManager() => _instance;
  UsbSerialManager._internal();

  UsbPort? _port;
  StreamSubscription<Uint8List>? _rawSubscription;
  RawDatagramSocket? _udpSocket;

  int _baudRate = 9600;
  bool _isConnected = false;

  int get baudRate => _baudRate;
  bool get isConnected => _isConnected;

  Future<void> init() async {
    if (!Platform.isAndroid) return;
    _updateBaudRateFromScaleList();

    // 监听多秤管理配置更新
    eventBus.on<EventRespAddScale>().listen((event) {
      _updateBaudRateFromScaleList();
    });
    eventBus.on<EventRespScaleModify>().listen((event) {
      _updateBaudRateFromScaleList();
    });
    
    // 初始化UDP socket，双向通信：接收Go的数据写入USB，以及将USB的数据发给Go
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 8082).then((socket) {
      _udpSocket = socket;
      _udpSocket?.listen((RawSocketEvent e) {
        if (e == RawSocketEvent.read) {
          Datagram? d = _udpSocket?.receive();
          if (d != null && _port != null && _isConnected) {
            debugPrint("Flutter UDP [RECV] -> USB: ${d.data.length} bytes");
            _port!.write(d.data);
          }
        }
      });
    });

    // 监听USB插拔事件
    UsbSerial.usbEventStream!.listen((UsbEvent event) {
      if (event.event == UsbEvent.ACTION_USB_ATTACHED) {
        connectToFirstAvailablePort();
      } else if (event.event == UsbEvent.ACTION_USB_DETACHED) {
        disconnect();
      }
    });

    connectToFirstAvailablePort();
  }

  void _updateBaudRateFromScaleList() {
    int targetBaudRate = 9600; // 默认9600
    for (var scale in myAllScalesList) {
      if (scale.mediaConfig is SerialMediaConfig) {
        final serialConfig = scale.mediaConfig as SerialMediaConfig;
        if (serialConfig.devPath == "USB") {
          targetBaudRate = serialConfig.baudRate;
          break;
        } else {
          if (targetBaudRate == 9600) {
            targetBaudRate = serialConfig.baudRate;
          }
        }
      }
    }

    if (_baudRate != targetBaudRate) {
      _baudRate = targetBaudRate;
      debugPrint("USB Serial Manager detected new baud rate: $_baudRate");
      if (_isConnected) {
        disconnect().then((_) => connectToFirstAvailablePort());
      }
    }
  }

  Future<void> changeBaudRate(int baudRate) async {
    if (!Platform.isAndroid) return;
    if (_baudRate != baudRate) {
      _baudRate = baudRate;
      debugPrint("USB Serial Manager manually changed baud rate to: $_baudRate");
      if (_isConnected) {
        await disconnect();
        await connectToFirstAvailablePort();
      }
    }
  }

  Future<void> restoreBaudRate() async {
    if (!Platform.isAndroid) return;
    // trigger a recalculation from the scale list to revert to the normal 115200 (or whatever is configured)
    int targetBaudRate = 9600; 
    for (var scale in myAllScalesList) {
      if (scale.mediaConfig is SerialMediaConfig) {
        final serialConfig = scale.mediaConfig as SerialMediaConfig;
        if (serialConfig.devPath == "USB") {
          targetBaudRate = serialConfig.baudRate;
          break;
        } else {
          if (targetBaudRate == 9600) {
            targetBaudRate = serialConfig.baudRate;
          }
        }
      }
    }

    if (_baudRate != targetBaudRate) {
      _baudRate = targetBaudRate;
      debugPrint("USB Serial Manager restored baud rate to: $_baudRate");
      if (_isConnected) {
        await disconnect();
        await connectToFirstAvailablePort();
      }
    }
  }

  void _showToast(String msg) {
    debugPrint(msg);
    Fluttertoast.showToast(msg: msg, toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.BOTTOM);
  }

  Future<void> connectToFirstAvailablePort() async {
    if (!Platform.isAndroid) return;
    if (_isConnected) return;
    
    List<UsbDevice> devices = await UsbSerial.listDevices(); 
    _showToast("USB Check: Found ${devices.length} devices.");
    if (devices.isEmpty) return;

    for (var device in devices) {
      try {
        UsbPort? port;
        try {
          port = await device.create();
        } catch (e) {
          _showToast("Auto-detect failed, trying fallback: ${e.toString()}");
          // 如果自动检测失败，尝试强制指定驱动类型
          List<String> types = [
            UsbSerial.CDC,
            UsbSerial.CH34x,
            UsbSerial.CP210x,
            UsbSerial.FTDI,
            UsbSerial.PL2303
          ];
          for (String type in types) {
            try {
              // 强制指定 interface 为 0，避免非标准 CDC 设备抛出 -1 索引越界异常
              port = await device.create(type, 0);
              if (port != null) {
                _showToast("Fallback success with: $type");
                break;
              }
            } catch (innerE) {
              debugPrint('Fallback $type failed: $innerE');
            }
          }
        }

        if (port == null) {
          _showToast("Failed to create port for ${device.deviceName}");
          continue;
        }

        bool openResult = await port.open();
        if (!openResult) {
          _showToast("Failed to open USB port");
          continue;
        }

        await port.setDTR(true);
        await port.setRTS(true);
        await port.setPortParameters(
            _baudRate, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

        _port = port;
        _isConnected = true;
        _showToast("USB Serial Connected at $_baudRate");

        // 监听数据并转发
        _rawSubscription = port.inputStream?.listen((Uint8List data) {
          if (_udpSocket != null) {
            debugPrint("Flutter USB -> [SEND] UDP: ${data.length} bytes");
            _udpSocket!.send(data, InternetAddress("127.0.0.1"), 8081);
          }
        });

        // 成功连接后直接退出循环
        return;
      } catch (e) {
        _showToast("Exception on ${device.deviceName}: $e");
        // 如果当前设备抛出异常（例如不是串口设备），继续尝试下一个
        continue;
      }
    }
    
    // 如果遍历完仍未连接成功
    _isConnected = false;
    _port = null;
    _showToast("USB Connect Finished, No valid port");
  }

  Future<void> disconnect() async {
    try {
      await _rawSubscription?.cancel();
      _rawSubscription = null;
      if (_port != null) {
        await _port?.close();
      }
    } catch (e) {
      debugPrint("USB Serial disconnect error: $e");
    } finally {
      _port = null;
      _isConnected = false;
      debugPrint("USB Serial Disconnected");
    }
  }
}
