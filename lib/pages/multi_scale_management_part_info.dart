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
                padding: const EdgeInsets.only(top: 8),
                children: [
                  buildItemInfo(
                      showItemNameWithStar(
                          context, (localizedStrings?.gScaleName ?? "Scale Name"), false),
                      showScaleNameInputBox(
                          context,
                          scaleNameCtl,
                          '',
                          IconButton(
                            icon: Icon(Icons.edit_outlined),
                            onPressed: () {
                              setState(() {
                                isRename = true;
                                _isModifyName = isValidScaleName(scaleNameCtl.text);
                              });
                              scaleNameFocusNode.requestFocus();
                            },
                          ), (value) {
                        setState(() {});
                      }, isRename, focusNode: scaleNameFocusNode, onTap: () {
                        setState(() {
                          isRename = true;
                          _isModifyName = isValidScaleName(scaleNameCtl.text);
                        });
                        scaleNameFocusNode.requestFocus();
                      }),
                      showItemNameWithStar(
                          context, (localizedStrings?.gModelName ?? "Model Name"), false),
                      showInputBox(context, scaleModelCtl, '', (value) {
                        setState(() {});
                      }, false)),
                  const SizedBox(
                    height: 8,
                  ),
                  buildItemInfo(
                      showItemNameWithStar(
                          context, (localizedStrings?.protocolName ?? "Protocol Name"), false),
                      showInputBox(context, protocolCtl, '', (value) {
                        setState(() {});
                      }, false),
                      showItemNameWithStar(
                          context, (localizedStrings?.gScaleSn ?? "SN"), false),
                      showInputBox(context, snCtl, '', (value) {
                        setState(() {});
                      }, false)),
                  const SizedBox(
                    height: 8,
                  ),
                  buildItemInfo(
                      showItemNameWithStar(
                          context, (localizedStrings?.gTipPort ?? "Port"), false),
                      showInputBox(context, portCtl, '', (value) {
                        setState(() {});
                      }, false),
                      showItemNameWithStar(
                          context, (localizedStrings?.gIpAddress ?? "IPv4"), false),
                      showInputBox(context, ipCtl, '', (value) {
                        setState(() {});
                      }, false)),
                  const SizedBox(
                    height: 16,
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
                padding: const EdgeInsets.only(top: 8),
                children: [
                  buildItemInfo(
                      showItemNameWithStar(
                          context, (localizedStrings?.gScaleName ?? "Scale Name"), false),
                      showScaleNameInputBox(
                          context,
                          scaleNameCtl,
                          '',
                          IconButton(
                            icon: Icon(Icons.edit_outlined),
                            onPressed: () {
                              setState(() {
                                isRename = true;
                                _isModifyName = isValidScaleName(scaleNameCtl.text);
                              });
                              scaleNameFocusNode.requestFocus();
                            },
                          ), (value) {
                        setState(() {});
                      }, isRename, focusNode: scaleNameFocusNode, onTap: () {
                        setState(() {
                          isRename = true;
                          _isModifyName = isValidScaleName(scaleNameCtl.text);
                        });
                        scaleNameFocusNode.requestFocus();
                      }),
                      showItemNameWithStar(
                          context, (localizedStrings?.gModelName ?? "Model Name"), false),
                      showInputBox(context, scaleModelCtl, '', (value) {
                        setState(() {});
                      }, false)),
                  const SizedBox(
                    height: 8,
                  ),
                  buildItemInfo(
                      showItemNameWithStar(
                          context, (localizedStrings?.protocolName ?? "Protocol Name"), false),
                      showInputBox(context, protocolCtl, '', (value) {
                        setState(() {});
                      }, false),
                      showItemNameWithStar(
                          context, (localizedStrings?.gScaleSn ?? "SN"), false),
                      showInputBox(context, snCtl, '', (value) {
                        setState(() {});
                      }, false)),
                  const SizedBox(
                    height: 8,
                  ),
                  buildItemInfo(
                      showItemNameWithStar(
                          context, (localizedStrings?.bluetoothName ?? "Bluetooth Name"), false),
                      showInputBox(context, btNameCtl, '', (value) {
                        setState(() {});
                      }, false),
                      showItemNameWithStar(
                          context, (localizedStrings?.bluetoothAddress ?? "MAC Address"), false),
                      showInputBox(context, macCtl, '', (value) {
                        setState(() {});
                      }, false)),
                  const SizedBox(
                    height: 16,
                  ),
                  isRename ? showRenameConfirmBtn() : buttonRow(),
                ],
              );
            })));
  }


  Widget showComScaleInfo() {
    return Expanded(
        child: SizedBox(
            width: double.infinity,
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              return ListView(
                padding: const EdgeInsets.only(top: 8),
                children: [
                  buildItemInfo(
                      showItemNameWithStar(
                          context, (localizedStrings?.gScaleName ?? "Scale Name"), false),
                      showScaleNameInputBox(
                          context,
                          scaleNameCtl,
                          '',
                          IconButton(
                            icon: Icon(Icons.edit_outlined),
                            onPressed: () {
                              setState(() {
                                isRename = true;
                                _isModifyName = isValidScaleName(scaleNameCtl.text);
                              });
                              scaleNameFocusNode.requestFocus();
                            },
                          ), (value) {
                        setState(() {});
                      }, isRename, focusNode: scaleNameFocusNode, onTap: () {
                        setState(() {
                          isRename = true;
                          _isModifyName = isValidScaleName(scaleNameCtl.text);
                        });
                        scaleNameFocusNode.requestFocus();
                      }),
                      showItemNameWithStar(
                          context, (localizedStrings?.gModelName ?? "Model Name"), false),
                      showInputBox(context, scaleModelCtl, '', (value) {
                        setState(() {});
                      }, false)),
                  const SizedBox(
                    height: 8,
                  ),
                  buildItemInfo(
                      showItemNameWithStar(
                          context, (localizedStrings?.protocolName ?? "Protocol Name"), false),
                      showInputBox(context, protocolCtl, '', (value) {
                        setState(() {});
                      }, false),
                      showItemNameWithStar(
                          context, (localizedStrings?.gScaleSn ?? "SN"), false),
                      showInputBox(context, snCtl, '', (value) {
                        setState(() {});
                      }, false)),
                  const SizedBox(
                    height: 8,
                  ),
                  buildItemInfo(
                      showItemNameWithStar(
                          context, (localizedStrings?.gTipPort ?? "Port"), false),
                      showInputBox(context, comPortCtl, '', (value) {
                        setState(() {});
                      }, false),
                      showItemNameWithStar(
                          context, (localizedStrings?.gBaudRate ?? "Baud Rate"), false),
                      showInputBox(context, baudRateCtl, '', (value) {
                        setState(() {});
                      }, false)),
                  const SizedBox(
                    height: 16,
                  ),
                  isRename ? showRenameConfirmBtn() : buttonRow(),
                ],
              );
            })));
  }



  Widget showRenameConfirmBtn() {
    return isRename
        ? Wrap(
            alignment: WrapAlignment.center,
            spacing: regularPadding,
            runSpacing: regularPadding,
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
              showTextButton(context, btnHeight, (localizedStrings?.gBtnCancel ?? "gBtnCancel"),
                  () {
                setState(() {
                  isAddScale = false; eventBus.fire(EventUiCmd('showScaffoldElements'));
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
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: regularPadding,
      runSpacing: regularPadding,
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
    Timer? timeoutTimer;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // 开始连接（仅执行一次）
            if (logs.isEmpty) {
              if (type == btScaleType) {
                logs.add("${DateTime.now().toString().split(' ')[1].substring(0, 8)}: ${localizedStrings?.gTipConnecting ?? 'Connecting'} ${localizedStrings?.bluetooth ?? 'Bluetooth'}...");
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
                String typeLabel = type == netScaleType ? "Network" : "Serial";
                String typeDisplay = type == netScaleType ? (localizedStrings?.gNetwork ?? "Network") : (localizedStrings?.gSerialPort ?? "Serial Port");
                logs.add("${DateTime.now().toString().split(' ')[1].substring(0, 8)}: [$typeLabel] ${localizedStrings?.gTipConnecting ?? 'Connecting'} ($typeDisplay)...");
                
                timeoutTimer = Timer(const Duration(seconds: 5), () {
                  if (!isDone) {
                    setDialogState(() {
                      isDone = true;
                      isSuccess = false;
                      logs.add("${DateTime.now().toString().split(' ')[1].substring(0, 8)}: [$typeLabel] ${localizedStrings?.gTipConnectFail ?? 'Connection timeout'}");
                    });
                    subscription?.cancel();
                    setState(() {
                      isTesting = false;
                    });
                  }
                });

                subscription = eventBus.on<EventRespCheckNetScale>().listen((event) {
                  OnlineInfo info = event.obj;
                  if (info.scaleId == scaleId) {
                    timeoutTimer?.cancel();
                    setDialogState(() {
                      isDone = true;
                      isSuccess = info.factInfo?.modelName != null && info.factInfo!.modelName!.isNotEmpty;
                      String resultLabel = isSuccess ? (localizedStrings?.success ?? "Success") : (localizedStrings?.failure ?? "Failure");
                      logs.add("${DateTime.now().toString().split(' ')[1].substring(0, 8)}: [$typeLabel] Test completed. Result: $resultLabel");
                    });
                    subscription?.cancel();
                    setState(() {
                      isTesting = false;
                    });
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
              titleText = isDone 
                ? (isSuccess 
                    ? "${localizedStrings?.bluetooth ?? 'Bluetooth'} ${localizedStrings?.success ?? 'Success'}" 
                    : "${localizedStrings?.bluetooth ?? 'Bluetooth'} ${localizedStrings?.failure ?? 'Failure'}") 
                : "${localizedStrings?.gTipConnecting ?? 'Connecting'} ${localizedStrings?.bluetooth ?? 'Bluetooth'}...";
            } else {
              String typeDisplay = type == netScaleType ? (localizedStrings?.gNetwork ?? "Network") : (localizedStrings?.gSerialPort ?? "Serial Port");
              titleText = isDone 
                ? (isSuccess ? "$typeDisplay ${localizedStrings?.success ?? 'Success'}" : "$typeDisplay ${localizedStrings?.failure ?? 'Failure'}") 
                : "${localizedStrings?.gTipConnecting ?? 'Connecting'} $typeDisplay...";
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
                                  color: logs[index].contains(localizedStrings?.failure ?? "Failure") || logs[index].contains("Error") || logs[index].contains("Fail") || logs[index].contains("澶辫触") || logs[index].contains("閿欒")
                                    ? Colors.red 
                                    : (logs[index].contains(localizedStrings?.success ?? "Success") || logs[index].contains("Success") || logs[index].contains("鎴愬姛") ? Colors.green : Colors.black87),
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
                    child: Text(localizedStrings?.gBtnConfirm ?? "Confirm"),
                  ),
              ],
            );
          },
        );
      },
    ).then((_) {
      timeoutTimer?.cancel();
      subscription?.cancel();
      if (isTesting) {
        setState(() {
          isTesting = false;
        });
      }
    });
  }
}
