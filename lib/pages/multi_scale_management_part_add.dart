// ignore_for_file: invalid_use_of_protected_member
part of 'multi_scale_management_page.dart';

extension MultiScaleManagementAddExt on MultiScaleManagementState {
//增加秤时显示
  Widget showAddScaleInfo(double maxWidth) {
    if (Adaptive.isMobile(context)) {
      return addScaleType == "com"
          ? showAddComScaleInfo()
          : addScaleType == "wifi"
              ? showAddNetScaleInfo()
              : showAddBtScaleInfo();
    }

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
                  debugPrint("BT: Refresh clicked / Starting search");
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
    if (Platform.isAndroid && !comLists.contains("USB")) {
      comLists.add("USB");
      usingComLists = List<String>.from(comLists);
      if (comPortCtl.text.isEmpty) comPortCtl.text = "USB";
    }
    
    if (Adaptive.isMobile(context)) {
      return _buildMobileSerialAdd();
    }
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
                    // 若选择的值不�?comLists 中，清空输入�?
                    comPortCtl.clear();
                  }
                  usingComLists = List<String>.from(comLists);
                });
              },
              onTap: () {
                PublicFunctions.getPortList();
                if (Platform.isAndroid && !comLists.contains("USB")) {
                  comLists.add("USB");
                }
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
                        setState(() {
                          isAddScale = false; eventBus.fire(EventUiCmd('showScaffoldElements'));
                          isRename = false;
                          addScaleType = '';
                        });

                        addComScale();
                      }
                    : null,
                Theme.of(context).colorScheme.onPrimary,
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.onPrimary),
            const SizedBox(width: regularPadding),
            showTextButton(context, btnHeight, (localizedStrings?.gBtnCancel ?? "gBtnCancel"), () {
              setState(() {
                isAddScale = false; eventBus.fire(EventUiCmd('showScaffoldElements'));
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

  void _showMobilePicker(String title, List<String> options, String currentValue, Function(String) onSelected) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        options[index], 
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: options[index] == currentValue ? const Color(0xFF0D558E) : Colors.black87,
                          fontWeight: options[index] == currentValue ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      onTap: () {
                        onSelected(options[index]);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileListTile(String title, String value, VoidCallback onTap) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: ListTile(
            title: Text(title, style: const TextStyle(color: Colors.black87, fontSize: 16)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
            onTap: onTap,
          ),
        ),
        const Divider(height: 1, color: Color(0xFFEEEEEE), indent: 16),
      ],
    );
  }

  Widget _buildMobileSerialAdd() {
    return Column(
      children: [
        // Fake App Bar
        Container(
          color: Colors.white,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: SizedBox(
            height: 56,
            child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  setState(() {
                    isAddScale = false; eventBus.fire(EventUiCmd('showScaffoldElements'));
                    addScaleType = '';
                  });
                },
              ),
              Expanded(
                child: Center(
                  child: Text(
                    localizedStrings?.gSerialPort ?? "Serial port",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.help_outline, color: Colors.black),
                onPressed: () {},
              ),
            ],
          ),
          ),
        ),
        // List items
        Expanded(
          child: Container(
            color: const Color(0xFFF5F5F5),
            child: ListView(
              children: [
                _buildMobileListTile(
                  localizedStrings?.gSerialPort ?? "Serial port",
                  comPortCtl.text.isEmpty ? "Please select" : comPortCtl.text,
                  () {
                    PublicFunctions.getPortList();
                    if (Platform.isAndroid && !comLists.contains("USB")) {
                      comLists.add("USB");
                    }
                    _showMobilePicker(localizedStrings?.gSerialPort ?? "Serial port", comLists, comPortCtl.text, (val) {
                      setState(() {
                        comPortCtl.text = val;
                      });
                    });
                  },
                ),
                _buildMobileListTile(
                  localizedStrings?.gBaudRate ?? "Baud rate",
                  baudRateCtl.text.isEmpty ? "115200" : baudRateCtl.text,
                  () {
                    _showMobilePicker(localizedStrings?.gBaudRate ?? "Baud rate", baudRateList, baudRateCtl.text, (val) {
                      setState(() => baudRateCtl.text = val);
                    });
                  },
                ),
                _buildMobileListTile(
                  localizedStrings?.gSerialParity ?? "Parity",
                  protocolCtl.text.isEmpty ? "None" : protocolCtl.text,
                  () {
                    _showMobilePicker(localizedStrings?.gSerialParity ?? "Parity", checkBitsList, protocolCtl.text, (val) {
                      setState(() => protocolCtl.text = val);
                    });
                  },
                ),
                _buildMobileListTile(
                  localizedStrings?.gStopBits ?? "Stop bits",
                  stopBitCtl.text.isEmpty ? "1" : stopBitCtl.text,
                  () {
                    _showMobilePicker(localizedStrings?.gStopBits ?? "Stop bits", stopBitsList, stopBitCtl.text, (val) {
                      setState(() => stopBitCtl.text = val);
                    });
                  },
                ),
                _buildMobileListTile(
                  localizedStrings?.gDataBits ?? "Data bits",
                  dataBitCtl.text.isEmpty ? "8" : dataBitCtl.text,
                  () {
                    _showMobilePicker(localizedStrings?.gDataBits ?? "Data bits", dataBitsList, dataBitCtl.text, (val) {
                      setState(() => dataBitCtl.text = val);
                    });
                  },
                ),
                // Common checkbox
                Container(
                  color: Colors.white,
                  child: ListTile(
                    title: Text(localizedStrings?.commonApp ?? "Common", style: const TextStyle(color: Colors.black87, fontSize: 16)),
                    trailing: Switch(
                      value: isDC500,
                      activeColor: const Color(0xFF0D558E),
                      onChanged: (val) => setState(() => isDC500 = val),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Bottom Confirm Button
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16.0),
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: comPortCtl.text.isNotEmpty ? () {
                  // check if in use
                  for (var scale in myAllScalesList) {
                    if (scale.tMedia == comScaleType) {
                      final serialConfig = scale.mediaConfig as SerialMediaConfig;
                      if (serialConfig.devPath == comPortCtl.text) {
                        showTipInfo((localizedStrings?.gTipPortInUsed ?? "gTipPortInUsed") + scale.scaleName, context);
                        return;
                      }
                    }
                  }
                  setState(() {
                    isAddScale = false; eventBus.fire(EventUiCmd('showScaffoldElements'));
                    isRename = false;
                    addScaleType = '';
                  });
                  addComScale();
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D558E),
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  elevation: 0,
                ),
                child: Text(
                  localizedStrings?.gBtnConfirm ?? "Confirm",
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileBtAdd() {
    return Column(
      children: [
        // Fake App Bar
        Container(
          color: Colors.white,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: SizedBox(
            height: 56,
            child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  setState(() {
                    isAddScale = false; eventBus.fire(EventUiCmd('showScaffoldElements'));
                    addScaleType = '';
                    isBtSearching = false;
                    isBtSearched = false;
                  });
                },
              ),
              Expanded(
                child: Center(
                  child: Text(
                    localizedStrings?.bluetooth ?? "Bluetooth",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.help_outline, color: Colors.black),
                onPressed: () {},
              ),
              if (!isBtSearching)
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.black),
                  onPressed: () {
                    PublicFunctions.getBtList();
                    setState(() {
                      btInfoList.clear();
                      selectBtInfo = BtInfo();
                      isBtSearching = true;
                    });
                  },
                )
              else
                const SizedBox(width: 48), // Place holder to keep title centered
            ],
          ),
          ),
        ),
        // Body
        Expanded(
          child: Container(
            color: const Color(0xFFF5F5F5),
            child: _buildMobileBtBody(),
          ),
        ),
        // Bottom Confirm Button
        if (isBtSearched)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: selectBtInfo.mac != null ? () {
                    setState(() {
                      isAddScale = false; eventBus.fire(EventUiCmd('showScaffoldElements'));
                      isRename = false;
                      addScaleType = '';
                      isBtSearching = false;
                      isBtSearched = false;
                    });
                    addBtScale();
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D558E),
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    elevation: 0,
                  ),
                  child: Text(
                    localizedStrings?.gBtnConfirm ?? "Confirm",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMobileBtBody() {
    if (isBtSearching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              localizedStrings?.gSearchingBtDevices ?? "Searching...",
              style: const TextStyle(fontSize: 16, color: Color(0xFF0D558E)),
            ),
          ],
        ),
      );
    } else if (isBtSearched) {
      if (btInfoList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bluetooth_disabled, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                localizedStrings?.noBluetoothDevicesFound ?? "No devices found",
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        );
      }
      return ListView.builder(
        itemCount: btInfoList.length,
        itemBuilder: (context, index) {
          final device = btInfoList[index];
          final isSelected = selectBtInfo.mac == device.mac;
          return Column(
            children: [
              Container(
                color: isSelected ? const Color(0xFF0D558E) : Colors.white,
                child: ListTile(
                  leading: Icon(Icons.scale, color: isSelected ? Colors.white : const Color(0xFF0D558E)),
                  title: Text(
                    device.name ?? "Unknown Device",
                    style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: Text(
                    "MAC: ${device.mac}",
                    style: TextStyle(color: isSelected ? Colors.white70 : Colors.grey, fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${device.rssi ?? -50}",
                        style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.signal_cellular_alt, size: 20, color: isSelected ? Colors.white : const Color(0xFF0D558E)),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      selectBtInfo = device;
                    });
                  },
                ),
              ),
              if (!isSelected) const Divider(height: 1, color: Color(0xFFEEEEEE), indent: 16),
            ],
          );
        },
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/bt_tips.png', width: 200, height: 100, fit: BoxFit.scaleDown),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  PublicFunctions.getBtList();
                  setState(() {
                    isBtSearching = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D558E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  elevation: 0,
                ),
                child: Text(
                  localizedStrings?.startSearchBluetoothDevices ?? "Start Search",
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget showAddBtScaleInfo() {
    if (Adaptive.isMobile(context)) {
      return _buildMobileBtAdd();
    }
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
                            setState(() {
                              isAddScale = false; eventBus.fire(EventUiCmd('showScaffoldElements'));
                              isRename = false;
                              addScaleType = '';
                              isBtSearching = false;
                              isBtSearched = false;
                            });
                            addBtScale();
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
                  debugPrint("BT: Start search clicked");
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
                    isAddScale = false; eventBus.fire(EventUiCmd('showScaffoldElements'));
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

  Widget _buildMobileInputTile(String title, TextEditingController controller, String hint, TextInputType keyboardType) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: ListTile(
            title: Row(
              children: [
                Text(title, style: const TextStyle(color: Colors.black87, fontSize: 16)),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: const TextStyle(color: Colors.black87, fontSize: 16),
                    onChanged: (val) {
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1, color: Color(0xFFEEEEEE), indent: 16),
      ],
    );
  }

  Widget _buildMobileNetAdd() {
    return Column(
      children: [
        // Fake App Bar
        Container(
          color: Colors.white,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: SizedBox(
            height: 56,
            child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  setState(() {
                    isAddScale = false; eventBus.fire(EventUiCmd('showScaffoldElements'));
                    addScaleType = '';
                  });
                },
              ),
              Expanded(
                child: Center(
                  child: Text(
                    localizedStrings?.gNetwork ?? "Network",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.help_outline, color: Colors.black),
                onPressed: () {},
              ),
            ],
          ),
          ),
        ),
        // List items
        Expanded(
          child: Container(
            color: const Color(0xFFF5F5F5),
            child: ListView(
              children: [
                _buildMobileInputTile(
                  localizedStrings?.gIpAddress ?? "IPv4",
                  ipCtl,
                  "", // removed localizedStrings?.gTipPleaseInput to prevent crash
                  const TextInputType.numberWithOptions(decimal: true),
                ),
                _buildMobileInputTile(
                  localizedStrings?.gTipPort ?? "Port",
                  portCtl,
                  "", // removed localizedStrings?.gTipPleaseInput to prevent crash
                  TextInputType.number,
                ),
              ],
            ),
          ),
        ),
        // Bottom Confirm Button
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16.0),
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: portCtl.text.isNotEmpty && _isValidIP ? () {
                  setState(() {
                    isAddScale = false; eventBus.fire(EventUiCmd('showScaffoldElements'));
                    isRename = false;
                    addScaleType = '';
                  });
                  addNetScale();
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D558E),
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  elevation: 0,
                ),
                child: Text(
                  localizedStrings?.gBtnConfirm ?? "Confirm",
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget showAddNetScaleInfo() {
    if (Adaptive.isMobile(context)) {
      return _buildMobileNetAdd();
    }
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
                        setState(() {
                          isAddScale = false; eventBus.fire(EventUiCmd('showScaffoldElements'));
                          isRename = false;
                          addScaleType = '';
                        });

                        addNetScale();
                      }
                    : null,
                Theme.of(context).colorScheme.onPrimary,
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.onPrimary),
            const SizedBox(width: regularPadding),
            showTextButton(context, btnHeight, (localizedStrings?.gBtnCancel ?? "gBtnCancel"), () {
              setState(() {
                isAddScale = false; eventBus.fire(EventUiCmd('showScaffoldElements'));
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

