//百分比模式时，需要添加的配方总重量

// 定义新增配方重量弹框组件
import 'package:flutter/material.dart';
import 'package:t_max/widget/t_max_dialog.dart';

import 'package:t_max/data/fma_rec_list_db_data.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/home_page_common_data.dart';

import 'package:t_max/data/language.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/widget/dialog_head_style.dart';

class FmaServerSettingDialog extends StatefulWidget {
  final UploadServerInfo info;
  const FmaServerSettingDialog({super.key, required this.info});
  @override
  FmaServerSettingDialogState createState() => FmaServerSettingDialogState();
}

class FmaServerSettingDialogState extends State<FmaServerSettingDialog> {
  TextEditingController userNameCtl = TextEditingController();
  TextEditingController pwdCtl = TextEditingController();
  TextEditingController pathCtl = TextEditingController();

  bool isEnable = false;
  bool seePwd = false;

  showUnitDropDownButton(List<FormulaWgtUnit> items, String hintText,
      TextEditingController valueCtl) {
    return SizedBox(
        height: 48,
        child: DropdownButtonFormField<FormulaWgtUnit>(
            borderRadius: BorderRadius.circular(0),
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .outlineVariant, // 设置边框颜色
                      width: 1.0, // 设置边框宽度
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(0.0))),
                border: OutlineInputBorder()),
            isExpanded: true,
            value: items.firstWhere(
                (mode) => mode.toString().split('.').last == valueCtl.text,
                orElse: () => items[0]),
            hint: Text(hintText), // 设置提示文本

            items: items.map((FormulaWgtUnit item) {
              // 设置下拉列表项
              return DropdownMenuItem<FormulaWgtUnit>(
                value: item,
                child: Text(
                  item.name,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface, // 设置提示文本颜色
                    fontSize: 14,
                  ),
                ),
              );
            }).toList(),
            onChanged: (FormulaWgtUnit? newValue) {
              // 处理下拉列表项选择事件
              if (newValue != null) {
                // 在这里处理选择的值
                // print('Selected: ${newValue.toString().split('.').last}');
                setState(() {
                  valueCtl.text = newValue.name; // 更新 valueCtl 的值
                });
              }
            }));
  }

  @override
  initState() {
    super.initState();
    if (widget.info.enable == null) {
      isEnable = false;
      userNameCtl.text = '';
      pwdCtl.text = '';
      pathCtl.text = '';
    } else {
      isEnable = widget.info.enable!;
      userNameCtl.text = widget.info.username!;
      pwdCtl.text = widget.info.password!;
      pathCtl.text = "\\\\${widget.info.ip!}\\${widget.info.shareName!}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return TMaxDialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 610,
        height: 376,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          children: [
            // 头部
            ...dialogHeadStyle(context, (localizedStrings?.autoSync ?? "autoSync"), true),
            // 中部
            Expanded(
              child: Container(
                  padding: const EdgeInsets.only(
                      top: regularPadding,
                      left: regularPadding * 2,
                      right: regularPadding * 2),
                  child: Column(children: [
                    Row(children: [
                      Expanded(
                          flex: 1,
                          child: Column(children: [
                            SizedBox(
                              height: 42,
                              child: Row(children: [
                                IconButton(
                                    iconSize: 36,
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                    icon: Icon(isEnable
                                        ? Icons.toggle_on_outlined
                                        : Icons.toggle_off_outlined),
                                    color: isEnable
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onTertiaryFixedVariant
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                    onPressed: () {
                                      setState(() {
                                        isEnable = !isEnable;
                                      });
                                    }),
                                SizedBox(
                                  width: regularPadding,
                                ),
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      (localizedStrings?.enableRecordAutoSync ?? "enableRecordAutoSync"),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                          ])),
                    ]),
                    Row(children: [
                      Expanded(
                          flex: 1,
                          child: Column(children: [
                            SizedBox(
                              height: 42,
                              child: Row(children: [
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      (localizedStrings?.userUsername ?? "userUsername") + ":",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                            SizedBox(
                              height: 40,
                              child: Row(children: [
                                Expanded(
                                  child: Container(
                                      alignment: Alignment.centerLeft,
                                      child: TextField(
                                        enabled: isEnable,
                                        controller: userNameCtl,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(0.0),
                                            borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .outline,
                                              width: 1.0,
                                            ),
                                          ),
                                          hintText: '',
                                          suffixIconConstraints:
                                              BoxConstraints.tight(
                                                  Size(40, 40)),
                                        ),
                                        onChanged: (value) {
                                          setState(() {});
                                        },
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                        maxLines: 1,
                                      )),
                                ),
                              ]),
                            ),
                          ])),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                          flex: 1,
                          child: Column(children: [
                            SizedBox(
                              height: 42,
                              child: Row(children: [
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      (localizedStrings?.userPassword ?? "userPassword") + ":",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                            SizedBox(
                              height: 40,
                              child: Row(children: [
                                Expanded(
                                  child: Container(
                                      alignment: Alignment.centerLeft,
                                      child: TextField(
                                        enabled: isEnable,
                                        controller: pwdCtl,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(0.0),
                                            borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .outline,
                                              width: 1.0,
                                            ),
                                          ),
                                          hintText: '',
                                          suffixIconConstraints:
                                              BoxConstraints.tight(
                                                  Size(40, 40)),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              seePwd
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                seePwd = !seePwd;
                                              });
                                            },
                                          ),
                                        ),
                                        obscureText: !seePwd,
                                        obscuringCharacter: '*',
                                        onChanged: (value) {
                                          setState(() {});
                                        },
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                        maxLines: 1,
                                      )),
                                ),
                              ]),
                            ),
                          ])),
                    ]),
                    Row(children: [
                      Expanded(
                          flex: 1,
                          child: Column(children: [
                            SizedBox(
                              height: 42,
                              child: Row(children: [
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      (localizedStrings?.sharedFolderPath ?? "sharedFolderPath") + ":",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                            SizedBox(
                              height: 40,
                              child: Row(children: [
                                Expanded(
                                  child: Container(
                                      alignment: Alignment.centerLeft,
                                      child: TextField(
                                        enabled: isEnable,
                                        controller: pathCtl,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(0.0),
                                            borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .outline,
                                              width: 1.0,
                                            ),
                                          ),
                                          hintText:
                                              "eg: \\\\192.168.1.180\\csv",
                                          suffixIconConstraints:
                                              BoxConstraints.tight(
                                                  Size(40, 40)),
                                        ),
                                        onChanged: (value) {
                                          setState(() {});
                                        },
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                        maxLines: 1,
                                      )),
                                ),
                              ]),
                            ),
                          ])),
                      SizedBox(
                        width: 20,
                      ),
                    ]),
                  ])),
            ),

            // 底部
            Container(
              height: 96,
              width: 400,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        fixedSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: !isEnable
                          ? () {
                              UploadServerInfo uploadServerInfo =
                                  UploadServerInfo(
                                      recId: widget.info.enable == null ? 0 : 1,
                                      ip: widget.info.ip ?? '',
                                      shareName: widget.info.shareName ?? '',
                                      username: widget.info.username ?? '',
                                      password: widget.info.password ?? '',
                                      enable: false,
                                      updatedBy: mySysUser.nickName);

                              String jsonStr =
                                  uploadServerInfoToJson(uploadServerInfo);

                              PublicFunctions.editUploadServerConfig(jsonStr);
                              Navigator.pop(context, uploadServerInfo);
                            }
                          : isEnable &&
                                  pathCtl.text.isNotEmpty &&
                                  userNameCtl.text.isNotEmpty &&
                                  pwdCtl.text.isNotEmpty
                              ? () {
                                  bool isValid =
                                      isValidNetworkPathDetailed(pathCtl.text);
                                  if (!isValid) {
                                    showTipInfo(
                                        "请输入正确的网络路径：eg: \\\\192.168.1.180\\csv",
                                        context);
                                    return;
                                  }

                                  String path = pathCtl.text;

                                  final firstSlashAfterIP =
                                      path.indexOf('\\', 2);

                                  final ipPart =
                                      path.substring(2, firstSlashAfterIP);

                                  final pathPart =
                                      path.substring(firstSlashAfterIP + 1);

                                  UploadServerInfo uploadServerInfo =
                                      UploadServerInfo(
                                          recId: widget.info.enable == null
                                              ? 0
                                              : 1,
                                          ip: ipPart,
                                          shareName: pathPart,
                                          username: userNameCtl.text,
                                          password: pwdCtl.text,
                                          enable: true,
                                          updatedBy: mySysUser.nickName);

                                  String jsonStr =
                                      uploadServerInfoToJson(uploadServerInfo);

                                  PublicFunctions.editUploadServerConfig(
                                      jsonStr);
                                  Navigator.pop(context, uploadServerInfo);
                                }
                              : null,
                      child: Text(
                        (localizedStrings?.gBtnConfirm ?? "gBtnConfirm"),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onPrimary,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        fixedSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        (localizedStrings?.gBtnCancel ?? "gBtnCancel"),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onPrimary,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool isValidNetworkPathDetailed(String path) {
    // 1. 检查是否以两个反斜杠开头
    if (!path.startsWith('\\\\')) {
      return false;
    }

    // 2. 找到IP地址后的第一个反斜杠
    final firstSlashAfterIP = path.indexOf('\\', 2);
    if (firstSlashAfterIP == -1) {
      return false;
    }

    // 3. 提取IP地址部分
    final ipPart = path.substring(2, firstSlashAfterIP);

    // 4. 验证IP地址格式
    if (!isValidIPAddress(ipPart)) {
      return false;
    }

    // 5. 提取路径部分（IP后的所有内容）
    final pathPart = path.substring(firstSlashAfterIP + 1);

    // 6. 检查路径部分是否包含反斜杠
    if (pathPart.contains('\\')) {
      return false;
    }

    // 7. 检查路径部分是否为空
    if (pathPart.isEmpty) {
      return false;
    }

    return true;
  }

  bool isValidIPAddress(String ip) {
    // 正则表达式验证IP地址 (0.0.0.0 到 255.255.255.255)
    final ipRegex = RegExp(
        r'^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$');
    return ipRegex.hasMatch(ip);
  }

  @override
  void dispose() {
    userNameCtl.dispose();
    pwdCtl.dispose();
    pathCtl.dispose();
    super.dispose();
  }
}
