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
                    showConnectionProgressDialog(context, macCtl.text, selScaleId);
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

  void showConnectionProgressDialog(BuildContext context, String mac, int scaleId) {
    List<String> logs = [];
    bool isDone = false;
    bool isSuccess = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // 开始连接（仅执行一次）
            if (logs.isEmpty) {
              bluetoothManager.connectToDevice(
                mac, 
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
                  Text(isDone ? (isSuccess ? "连接成功" : "连接失败") : "正在连接蓝牙..."),
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
                          color: Colors.black.withValues(alpha: 0.05),
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
                                  color: logs[index].contains("错误") || logs[index].contains("异常") 
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
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("确定"),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
