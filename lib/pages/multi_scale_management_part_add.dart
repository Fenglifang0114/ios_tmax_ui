// ignore_for_file: invalid_use_of_protected_member
part of 'multi_scale_management_page.dart';

extension MultiScaleManagementAddExt on MultiScaleManagementState {
//增加秤时显示
  Widget showAddScaleInfo(double maxWidth) {
    return Column(children: [
      if (addScaleType == "bt")
        Row(
          children: [
            Expanded(
              child: subTitleInfo(
                  context,
                  maxWidth - headWidthPadding,
                  (localizedStrings?.gBtnAdd ?? "gBtnAdd"),
                  (localizedStrings?.gTipScaleMgrPageHelp ?? "gTipScaleMgrPageHelp")),
            ),
            if (!isBtSearching)
              TextButton(
                onPressed: () {
                  debugPrint("BT: 点击刷新/开始搜索");
                  PublicFunctions.getBtList();
                  setState(() {
                    btInfoList.clear();
                    selectBtInfo = BtInfo();
                    isBtSearching = true;
                  });
                },
                child: Text((localizedStrings?.gMsgRefresh ?? "gMsgRefresh"),
                    style: Theme.of(context).textTheme.bodySmall!.apply(
                          color: Theme.of(context).colorScheme.primary,
                        )),
              ),
          ],
        ),
      if (addScaleType != "bt")
        subTitleInfo(context, maxWidth - headWidthPadding,
            (localizedStrings?.gBtnAdd ?? "gBtnAdd"), (localizedStrings?.gTipScaleMgrPageHelp ?? "gTipScaleMgrPageHelp")),
      Expanded(
        child: addScaleType == "com"
            ? showAddComScaleInfo()
            : addScaleType == "wifi"
                ? showAddNetScaleInfo()
                : showAddBtScaleInfo(),
      ),
    ]);
  }

  Widget showAddComScaleInfo() {
    return ListView(
      children: [
        SizedBox(
          height: regularPadding,
        ),
        buildItemInfo(
            showItemNameWithStar(context, (localizedStrings?.gSerialPort ?? "gSerialPort"), false),
            showDropDownButton(
              context,
              "",
              comPortCtl,
              usingComLists,
              (value) {
                setState(() {
                  if (value != null && comLists.contains(value)) {
                    comPortCtl.text = value;
                  } else {
                    // 若选择的值不在 comLists 中，清空输入框
                    comPortCtl.clear();
                  }
                  usingComLists = List<String>.from(comLists);
                });
              },
              onTap: () {
                PublicFunctions.getPortList();
                if (comLists.isEmpty && comPortCtl.text.isNotEmpty) {
                  comPortCtl.clear();
                }
              },
            ),
            showItemNameWithStar(context, (localizedStrings?.gBaudRate ?? "gBaudRate"), false),
            showDropDownButton(context, '', baudRateCtl, baudRateList, (value) {
              setState(() {
                if (baudRateList.contains(value)) {
                  baudRateCtl.text = value!;
                }
              });
            })),
        buildItemInfo(
            showItemNameWithStar(
                context, (localizedStrings?.gSerialParity ?? "gSerialParity"), false),
            showDropDownButton(context, '', protocolCtl, checkBitsList,
                (value) {
              setState(() {
                if (checkBitsList.contains(value)) {
                  protocolCtl.text = value!;
                }
              });
            }),
            showItemNameWithStar(context, (localizedStrings?.gStopBits ?? "gStopBits"), false),
            showDropDownButton(context, '', stopBitCtl, stopBitsList, (value) {
              setState(() {
                if (stopBitsList.contains(value)) {
                  stopBitCtl.text = value!;
                }
              });
            })),
        buildItemInfo(
          showItemNameWithStar(context, (localizedStrings?.gDataBits ?? "gDataBits"), false),
          showDropDownButton(context, '', dataBitCtl, dataBitsList, (value) {
            setState(() {
              if (dataBitsList.contains(value)) {
                dataBitCtl.text = value!;
              }
            });
          }),
          showItemNameWithStar(context, (localizedStrings?.commonApp ?? "commonApp"), false),
          Container(
            width: inputWidth,
            alignment: Alignment.centerLeft,
            child: Checkbox(
              value: isDC500,
              onChanged: (bool? newValue) {
                setState(() {
                  isDC500 = newValue ?? false;
                });
              },
            ),
          ),
        ),
        SizedBox(
          height: regularPadding,
        ),
        SizedBox(
          height: regularPadding,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            showTextButton(
                context,
                btnHeight,
                (localizedStrings?.gBtnConfirm ?? "gBtnConfirm"),
                comPortCtl.text.isNotEmpty
                    ? () {
                        for (var scale in myAllScalesList) {
                          if (scale.tMedia == comScaleType) {
                            final serialConfig =
                                scale.mediaConfig as SerialMediaConfig;
                            if (serialConfig.devPath == comPortCtl.text) {
                              showTipInfo(
                                  (localizedStrings?.gTipPortInUsed ?? "gTipPortInUsed") +
                                      scale.scaleName,
                                  context);
                              return;
                            }
                          }
                        }
                        isAddScale = false;
                        isRename = false;
                        addScaleType = '';

                        addComScale();
                      }
                    : null,
                Theme.of(context).colorScheme.onPrimary,
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.onPrimary),
            const SizedBox(width: regularPadding),
            showTextButton(context, btnHeight, (localizedStrings?.gBtnCancel ?? "gBtnCancel"), () {
              setState(() {
                isAddScale = false;
                isRename = false;
                addScaleType = '';
                selScaleId = -1;
                if (isComSetting) {
                  isComSetting = false;
                }
              });
            },
                Theme.of(context).colorScheme.onPrimary,
                Theme.of(context).colorScheme.onSurfaceVariant,
                Theme.of(context).colorScheme.onPrimary),
          ],
        )
      ],
    );
  }

  Widget showAddBtScaleInfo() {
    if (isBtSearching) {
      return ListView(
        padding: const EdgeInsets.symmetric(vertical: regularPadding),
        children: [
          const SizedBox(height: 60),
          Center(
            child: SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(),
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              (localizedStrings?.gSearchingBtDevices ?? "gSearchingBtDevices"),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(height: 80),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: regularPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                showTextButton(context, btnHeight, (localizedStrings?.gBtnCancel ?? "gBtnCancel"),
                    () {
                  setState(() {
                    isBtSearching = false;
                    isBtSearched = false;
                  });
                },
                    Theme.of(context).colorScheme.onPrimary,
                    Theme.of(context).colorScheme.onSurfaceVariant,
                    Theme.of(context).colorScheme.onPrimary),
              ],
            ),
          ),
        ],
      );
    } else if (isBtSearched) {
      return Column(
        children: [
          // 设备列表
          Expanded(
            child: btInfoList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bluetooth_disabled,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          (localizedStrings?.noBluetoothDevicesFound ?? "noBluetoothDevicesFound"),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          (localizedStrings?.ensureBluetoothIsEnabled ?? "ensureBluetoothIsEnabled"),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : BtInfoListWidget(
                    devices: btInfoList,
                    onRefresh: () {
                      PublicFunctions.getBtList();
                      setState(() {
                        btInfoList.clear();
                        selectBtInfo = BtInfo();
                        isBtSearching = true;
                      });
                    },
                    onDeviceTap: (device) {
                      setState(() {
                        selectBtInfo = device;
                      });
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(regularPadding),
            child: Wrap(
              spacing: regularPadding,
              runSpacing: regularPadding,
              alignment: WrapAlignment.center,
              children: [
                showTextButton(
                    context,
                    btnHeight,
                    (localizedStrings?.gBtnConfirm ?? "gBtnConfirm"),
                    selectBtInfo.mac != null
                        ? () {
                            isAddScale = false;
                            isRename = false;
                            addScaleType = '';
                            isBtSearching = false;
                            isBtSearched = false;
                            addBtScale();
                          }
                        : null,
                    Theme.of(context).colorScheme.onPrimary,
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.onPrimary),
                showTextButton(context, btnHeight, (localizedStrings?.gBtnCancel ?? "gBtnCancel"),
                    () {
                  setState(() {
                    isAddScale = false;
                    isRename = false;
                    addScaleType = '';
                    selScaleId = -1;
                    selectBtInfo = BtInfo();
                    btInfoList.clear();
                    isBtSearching = false;
                    isBtSearched = false;
                    if (isComSetting) isComSetting = false;
                  });
                },
                    Theme.of(context).colorScheme.onPrimary,
                    Theme.of(context).colorScheme.onSurfaceVariant,
                    Theme.of(context).colorScheme.onPrimary),
              ],
            ),
          ),
        ],
      );
    } else {
      return ListView(
        padding: const EdgeInsets.symmetric(vertical: regularPadding),
        children: [
          const SizedBox(height: 60),
          LayoutBuilder(builder: (context, constraints) {
            return Image.asset(
              'assets/images/bt_tips.png',
              width: constraints.maxWidth * 0.9,
              height: 100,
              fit: BoxFit.scaleDown,
            );
          }),
          const SizedBox(height: regularPadding),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 300,
                child: showTextButton(context, btnHeight,
                    (localizedStrings?.startSearchBluetoothDevices ?? "startSearchBluetoothDevices"), () {
                  debugPrint("BT: 点击开始搜索");
                  PublicFunctions.getBtList();
                  setState(() {
                    isBtSearching = true;
                  });
                },
                    Theme.of(context).colorScheme.onPrimary,
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.onPrimary),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: regularPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                showTextButton(context, btnHeight, (localizedStrings?.gBtnCancel ?? "gBtnCancel"),
                    () {
                  setState(() {
                    isAddScale = false;
                    isRename = false;
                    addScaleType = '';
                    selScaleId = -1;
                    if (isComSetting) isComSetting = false;
                  });
                },
                    Theme.of(context).colorScheme.onPrimary,
                    Theme.of(context).colorScheme.onSurfaceVariant,
                    Theme.of(context).colorScheme.onPrimary),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget showAddNetScaleInfo() {
    return ListView(
      children: [
        SizedBox(
          height: regularPadding,
        ),
        buildItemInfo(
            showItemNameWithStar(context, (localizedStrings?.gIpAddress ?? "gIpAddress"), false),
            showInputBox(context, ipCtl, '', (value) {
              setState(() {});
            }, true),
            showItemNameWithStar(context, (localizedStrings?.gTipPort ?? "gTipPort"), false),
            Container(
              height: inputHeight,
              padding: const EdgeInsets.only(left: 16, right: 20),
              decoration: BoxDecoration(
                border: Border.all(
                    color:
                        Theme.of(context).colorScheme.outlineVariant), // 设置边框颜色
                borderRadius: BorderRadius.circular(0), // 设置圆角
              ),
              child: TextField(
                controller: portCtl,
                decoration: InputDecoration(
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface, // 设置提示文本颜色
                  ),
                  border: InputBorder.none, // 移除默认边框
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(5),
                  FilteringTextInputFormatter.allow(RegExp(
                      r'^([1-9]|[1-9]\d|[1-9]\d{2}|[1-9]\d{3}|[1-5]\d{4}|6[0-4]\d{3}|65[0-4]\d{2}|655[0-2]\d|6553[0-5])$')), // 允许输入数字
                ],
                style: Theme.of(context).textTheme.bodySmall!.apply(
                      color:
                          Theme.of(context).colorScheme.onSurface, // 设置输入文本颜色
                    ),
                onChanged: (value) {
                  setState(() {});
                }, // 监听文本变化,
              ),
            )),
        SizedBox(
          height: regularPadding,
        ),
        SizedBox(
          height: regularPadding,
        ),
        SizedBox(
          height: regularPadding,
        ),
        SizedBox(
          height: regularPadding,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            showTextButton(
                context,
                btnHeight,
                (localizedStrings?.gBtnConfirm ?? "gBtnConfirm"),
                portCtl.text.isNotEmpty && _isValidIP
                    ? () {
                        isAddScale = false;
                        isRename = false;
                        addScaleType = '';

                        addNetScale();
                      }
                    : null,
                Theme.of(context).colorScheme.onPrimary,
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.onPrimary),
            const SizedBox(width: regularPadding),
            showTextButton(context, btnHeight, (localizedStrings?.gBtnCancel ?? "gBtnCancel"), () {
              setState(() {
                isAddScale = false;
                isRename = false;
                addScaleType = '';
                selScaleId = -1;

                if (isComSetting) {
                  isComSetting = false;
                }
              });
            },
                Theme.of(context).colorScheme.onPrimary,
                Theme.of(context).colorScheme.onSurfaceVariant,
                Theme.of(context).colorScheme.onPrimary),
          ],
        )
      ],
    );
  }

}
