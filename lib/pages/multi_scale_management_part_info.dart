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
                            icon: Icon(Icons.edit_outlined), // 娓呴櫎鎸夐挳鍥炬爣
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
                            icon: Icon(Icons.edit_outlined), // 娓呴櫎鎸夐挳鍥炬爣
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
                      // 缃戠粶绉ゆ垨涓插彛绉わ細涓嶅脊绐楋紝鐩存帴鏄剧ず Tip 骞跺彂閫佹寚浠?
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
                      // 鍒犻櫎鍓嶅厛鍋滄杩炵画鍙戦€?
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
            // 寮€濮嬭繛鎺ワ紙浠呮墽琛屼竴娆★級
            if (logs.isEmpty) {
              if (type == btScaleType) {
                logs.add("${DateTime.now().toString().split(' ')[1].substring(0, 8)}: 鍑嗗杩炴帴钃濈墮璁惧...");
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
                // 缃戠粶杩炴帴鎴栦覆鍙ｈ繛鎺?
                String typeStr = type == netScaleType ? "缃戠粶" : "涓插彛";
                logs.add("${DateTime.now().toString().split(' ')[1].substring(0, 8)}: 鍑嗗鍙戣捣$typeStr杩炴帴娴嬭瘯...");
                
                subscription = eventBus.on<EventRespCheckNetScale>().listen((event) {
                  OnlineInfo info = event.obj;
                  if (info.scaleId == scaleId) {
                    setDialogState(() {
                      isDone = true;
                      isSuccess = info.factInfo?.modelName != null && info.factInfo!.modelName!.isNotEmpty;
                      logs.add("${DateTime.now().toString().split(' ')[1].substring(0, 8)}: $typeStr娴嬭瘯瀹屾垚锛岀粨鏋滐細${isSuccess ? "鎴愬姛" : "澶辫触"}");
                    });
                    subscription?.cancel();
                  }
                });

                // 鍙戦€佸悗绔祴璇曟寚浠?
                PublicFunctions.checkSerialPort(scaleId);
                setState(() {
                   isTesting = true;
                });
              }
            }

            String titleText = "";
            if (type == btScaleType) {
              titleText = isDone ? (isSuccess ? "钃濈墮杩炴帴鎴愬姛" : "钃濈墮杩炴帴澶辫触") : "姝ｅ湪杩炴帴钃濈墮...";
            } else {
              String typeStr = type == netScaleType ? "缃戠粶" : "涓插彛";
              titleText = isDone ? (isSuccess ? "$typeStr杩炴帴鎴愬姛" : "$typeStr杩炴帴澶辫触") : "姝ｅ湪娴嬭瘯$typeStr杩炴帴...";
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
                                  color: logs[index].contains("閿欒") || logs[index].contains("寮傚父") || logs[index].contains("澶辫触")
                                    ? Colors.red 
                                    : (logs[index].contains("鎴愬姛") ? Colors.green : Colors.black87),
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
                    child: Text("纭畾"),
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
