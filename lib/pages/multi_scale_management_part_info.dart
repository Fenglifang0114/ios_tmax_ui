// ignore_for_file: invalid_use_of_protected_member
part of 'multi_scale_management_page.dart';

extension MultiScaleManagementInfoExt on MultiScaleManagementState {

  Widget showNetworkScaleInfo() {
    return Expanded(
        child: SizedBox(
            width: double.infinity,
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              return ListView(
                children: [
                  const SizedBox(
                    height: regularPadding,
                  ),
                  buildItemInfo(
                      showItemNameWithStar(
                          context, (localizedStrings?.gScaleName ?? "gScaleName"), false),
                      showScaleNameInputBox(
                          context,
                          scaleNameCtl,
                          '',
                          IconButton(
                            icon: Icon(Icons.edit_outlined), // 清除按钮图标
                            onPressed: () {
                              setState(() {
                                isRename = true;
                              });
                            },
                          ), (value) {
                        setState(() {});
                      }, isRename),
                      showItemNameWithStar(
                          context, (localizedStrings?.gModelName ?? "gModelName"), false),
                      showInputBox(context, scaleModelCtl, '', (value) {
                        setState(() {});
                      }, false)),
                  const SizedBox(
                    height: regularPadding,
                  ),
                  buildItemInfo(
                      showItemNameWithStar(
                          context, (localizedStrings?.gScaleSn ?? "gScaleSn"), false),
                      showInputBox(context, snCtl, '', (value) {
                        setState(() {});
                      }, false),
                      showItemNameWithStar(
                          context, (localizedStrings?.gTipPort ?? "gTipPort"), false),
                      showInputBox(context, portCtl, '', (value) {
                        setState(() {});
                      }, false)),
                  const SizedBox(
                    height: regularPadding,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                                width: inputWidth,
                                child: showItemNameWithStar(context,
                                    (localizedStrings?.gIpAddress ?? "gIpAddress"), false)),
                            SizedBox(
                                width: inputWidth,
                                child:
                                    showInputBox(context, ipCtl, '', (value) {
                                  setState(() {});
                                }, false))
                          ]),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: inputWidth,
                            ),
                            SizedBox(
                              width: inputWidth,
                            )
                          ])
                    ],
                  ),
                  const SizedBox(
                    height: regularPadding,
                  ),
                  const SizedBox(
                    height: regularPadding,
                  ),
                  isRename
                      ? showRenameConfirmBtn()
                      : buttonRow(showModify: true),
                ],
              );
            })));
  }

  Widget showBluetoothScaleInfo() {
    return Expanded(
        child: SizedBox(
            width: double.infinity,
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              return ListView(
                children: [
                  const SizedBox(
                    height: regularPadding,
                  ),
                  buildItemInfo(
                      showItemNameWithStar(
                          context, (localizedStrings?.gScaleName ?? "gScaleName"), false),
                      showScaleNameInputBox(
                          context,
                          scaleNameCtl,
                          '',
                          IconButton(
                            icon: Icon(Icons.edit_outlined), // 清除按钮图标
                            onPressed: () {
                              setState(() {
                                isRename = true;
                              });
                            },
                          ), (value) {
                        setState(() {});
                      }, isRename),
                      showItemNameWithStar(
                          context, (localizedStrings?.gModelName ?? "gModelName"), false),
                      showInputBox(context, scaleModelCtl, '', (value) {
                        setState(() {});
                      }, false)),
                  const SizedBox(
                    height: regularPadding,
                  ),
                  buildItemInfo(
                      showItemNameWithStar(
                          context, (localizedStrings?.gScaleSn ?? "gScaleSn"), false),
                      showInputBox(context, snCtl, '', (value) {
                        setState(() {});
                      }, false),
                      showItemNameWithStar(
                          context, (localizedStrings?.bluetoothName ?? "bluetoothName"), false),
                      showInputBox(context, btNameCtl, '', (value) {
                        setState(() {});
                      }, false)),
                  const SizedBox(
                    height: regularPadding,
                  ),
                  buildItemInfo(
                      showItemNameWithStar(
                          context, (localizedStrings?.bluetoothAddress ?? "bluetoothAddress"), false),
                      showInputBox(context, macCtl, '', (value) {
                        setState(() {});
                      }, false),
                      const SizedBox(),
                      const SizedBox()),
                  const SizedBox(
                    height: regularPadding,
                  ),
                  const SizedBox(
                    height: regularPadding,
                  ),
                  isRename ? showRenameConfirmBtn() : buttonRow(),
                ],
              );
            })));
  }


  Widget showRenameConfirmBtn() {
    return isRename
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              showTextButton(
                  context,
                  btnHeight,
                  (localizedStrings?.gBtnConfirm ?? "gBtnConfirm"),
                  scaleNameCtl.text.isNotEmpty && _isModifyName
                      ? () {
                          modifyScaleName();
                          isEditing = true;
                        }
                      : null,
                  Theme.of(context).colorScheme.onPrimary,
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.onPrimary),
              const SizedBox(width: regularPadding),
              showTextButton(context, btnHeight, (localizedStrings?.gBtnCancel ?? "gBtnCancel"),
                  () {
                setState(() {
                  isAddScale = false;
                  isRename = false;
                  for (var scale in myAllScalesList) {
                    if (scale.scaleId == selScaleId) {
                      scaleNameCtl.text = scale.scaleName;
                    }
                  }

                  if (isRename) {
                    isRename = false;
                  }
                });
              },
                  Theme.of(context).colorScheme.onPrimary,
                  Theme.of(context).colorScheme.onSurfaceVariant,
                  Theme.of(context).colorScheme.onPrimary),
            ],
          )
        : const SizedBox();
  }

  Widget buttonRow({bool showModify = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        showTextButton(
            context,
            btnHeight,
            (localizedStrings?.gBtnTestConnect ?? "gBtnTestConnect"),
            !isAddScale && !isTesting && !isDel
                ? () {
                    int scaleType = getScaleType();
                    if (scaleType == btScaleType) {
                      showConnectionProgressDialog(context, btScaleType, selScaleId, mac: macCtl.text);
                    } else {
                      // 网络秤或串口秤：不弹窗，直接显示 Tip 并发送指令
                      setState(() {
                        isTesting = true;
                      });
                      showTipInfo((localizedStrings?.gTipConnecting ?? "gTipConnecting"), context);
                      PublicFunctions.checkSerialPort(selScaleId);
                    }
                  }
                : null,
            Theme.of(context).colorScheme.onPrimary,
            Theme.of(context).colorScheme.onTertiaryFixedVariant,
            Theme.of(context).colorScheme.onPrimary),
        const SizedBox(width: regularPadding),
        showTextButton(
            context,
            btnHeight,
            (localizedStrings?.gBtnDelete ?? "gBtnDelete"),
            !isAddScale && !isTesting && !isRename
                ? () {
                    setState(() {
                      isDel = true;
                      // 删除前先停止连续发送
                      PublicFunctions.stopWeight(selScaleId);
                      delScale();
                      selScaleId = -1;
                    });
                  }
                : null,
            Theme.of(context).colorScheme.onPrimary,
            Theme.of(context).colorScheme.error,
            Theme.of(context).colorScheme.onPrimary),
        if (showModify) ...[
          const SizedBox(width: regularPadding),
          showTextButton(
              context,
              btnHeight,
              (localizedStrings?.gBtnModify ?? "gBtnModify"),
              !isAddScale && !isTesting && !isDel
                  ? () {
                      setState(() {
                        editWifiInfo = true;
                      });
                    }
                  : null,
              Theme.of(context).colorScheme.onPrimary,
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.onPrimary),
        ]
      ],
    );
  }

  void showConnectionProgressDialog(BuildContext context, int type, int scaleId, {String? mac}) {
    List<String> logs = [];
    bool isDone = false;
    bool isSuccess = false;
    StreamSubscription? subscription;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // 开始连接（仅执行一次）
            if (logs.isEmpty) {
              if (type == btScaleType) {
                logs.add("${DateTime.now().toString().split(' ')[1].substring(0, 8)}: 准备连接蓝牙设备...");
                bluetoothManager.connectToDevice(
                  mac ?? "", 
                  scaleId: scaleId,
                  onStatusUpdate: (status) {
                    setDialogState(() {
                      logs.add("${DateTime.now().toString().split(' ')[1].substring(0, 8)}: $status");
                    });
                  }
                ).then((success) {
                  setDialogState(() {
                    isDone = true;
                    isSuccess = success;
                  });
                });
              } else {
                // 网络连接或串口连接
                String typeStr = type == netScaleType ? "网络" : "串口";
                logs.add("${DateTime.now().toString().split(' ')[1].substring(0, 8)}: 准备发起$typeStr连接测试...");
                
                subscription = eventBus.on<EventRespCheckNetScale>().listen((event) {
                  OnlineInfo info = event.obj;
                  if (info.scaleId == scaleId) {
                    setDialogState(() {
                      isDone = true;
                      isSuccess = info.factInfo?.modelName != null && info.factInfo!.modelName!.isNotEmpty;
                      logs.add("${DateTime.now().toString().split(' ')[1].substring(0, 8)}: $typeStr测试完成，结果：${isSuccess ? "成功" : "失败"}");
                    });
                    subscription?.cancel();
                  }
                });

                // 发送后端测试指令
                PublicFunctions.checkSerialPort(scaleId);
                setState(() {
                   isTesting = true;
                });
              }
            }

            String titleText = "";
            if (type == btScaleType) {
              titleText = isDone ? (isSuccess ? "蓝牙连接成功" : "蓝牙连接失败") : "正在连接蓝牙...";
            } else {
              String typeStr = type == netScaleType ? "网络" : "串口";
              titleText = isDone ? (isSuccess ? "$typeStr连接成功" : "$typeStr连接失败") : "正在测试$typeStr连接...";
            }

            return AlertDialog(
              title: Row(
                children: [
                  if (!isDone)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  if (!isDone) SizedBox(width: 12),
                  Text(titleText),
                ],
              ),
              content: SizedBox(
                width: 400,
                height: 300,
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ListView.builder(
                          itemCount: logs.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                logs[index],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                  color: logs[index].contains("错误") || logs[index].contains("异常") || logs[index].contains("失败")
                                    ? Colors.red 
                                    : (logs[index].contains("成功") ? Colors.green : Colors.black87),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                if (isDone)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isTesting = false;
                      });
                      Navigator.of(context).pop();
                    },
                    child: Text("确定"),
                  ),
              ],
            );
          },
        );
      },
    ).then((_) {
      subscription?.cancel();
      if (isTesting) {
        setState(() {
          isTesting = false;
        });
      }
    });
  }
}
