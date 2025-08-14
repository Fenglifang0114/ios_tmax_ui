import 'package:flutter/material.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/license_data.dart';
import 'package:t_max/data/routes_data.dart';
import 'package:t_max/data/sys_user_from_db.dart';
import 'package:t_max/data/sys_user_req.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/widget/page_head.dart';
import '../data/language.dart';

class AddSysUserPage extends StatefulWidget {
  final List<SysUserFromDb> sysUserList;
  final SysUserFromDb initUserInfo;
  final int type; // 1:添加 2:修改
  const AddSysUserPage(
      {super.key,
      required this.sysUserList,
      required this.initUserInfo,
      required this.type});

  @override
  State<AddSysUserPage> createState() => AddSysUserPageState();
}

class AddSysUserPageState extends State<AddSysUserPage> {
  TextEditingController userNameCtl = TextEditingController();
  TextEditingController phoneCtl = TextEditingController();
  TextEditingController emailCtl = TextEditingController();
  TextEditingController pwd1Ctl = TextEditingController();
  TextEditingController pwd2Ctl = TextEditingController();

  bool isEncrypted = false; // 保密初始值为 false
  bool needContainer = false; // 保密初始值为 false
  bool freeMode = false;

  dynamic _eventbus2;

  String? selectedRole = 'operator'; // 默认选中操作员
  int? initPageId;

  final ScrollController _scrollController = ScrollController();

  late List<RouteData> allConfigMenus = [];
  late List<RouteData> allAppsMenus = [];

  final Set<int> selectedConfigIds = {};
  final Set<int> selectedAppIds = {};

  ColorScheme get colorScheme => Theme.of(context).colorScheme;
  TextTheme get textTheme => Theme.of(context).textTheme;

  void initUser() {
    if (widget.type == 2) {
      PublicFunctions.getUserInfo(widget.initUserInfo.userName!);
      userNameCtl.text = widget.initUserInfo.userName!;
      phoneCtl.text = widget.initUserInfo.phone!;
      emailCtl.text = widget.initUserInfo.email!;

      int roleId = widget.initUserInfo.roleId!;
      if (roleId == 2) {
        selectedRole = 'admin';
      } else {
        selectedRole = 'operator';
      }
    }
  }

  @override
  void didChangeDependencies() {
    allConfigMenus = getAllConfigMenus();
    allAppsMenus = getAllAppsMenus();

    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    initUser();

    _eventbus2 = eventBus.on<EventRespGetUserDetail>().listen((event) {
      if (mounted) {
        setState(() {
          String dataString = event.obj;
          try {
            SysUserDetailFromDb tempUserDetail =
                sysUserDetailFromDbFromJson(dataString);
            getInitPagesId(tempUserDetail);
          } catch (e) {
            return;
          }
        });
      }
    });
  }

  void getInitPagesId(SysUserDetailFromDb tempUserDetail) {
    if (tempUserDetail.roleId == operatorRoleId &&
        tempUserDetail.pageIdList != null) {
      setState(() {
        initPageId = tempUserDetail.initialPageId;

        final configMenuIds = allConfigMenus.map((menu) => menu.id).toSet();
        final appMenuIds = allAppsMenus.map((app) => app.id).toSet();

        for (final pageId in tempUserDetail.pageIdList!) {
          if (configMenuIds.contains(pageId)) {
            selectedConfigIds.add(pageId);
          }
          if (appMenuIds.contains(pageId)) {
            selectedAppIds.add(pageId);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _eventbus2.cancel();
    userNameCtl.dispose();
    phoneCtl.dispose();
    emailCtl.dispose();
    pwd1Ctl.dispose();
    pwd2Ctl.dispose();
  }

  // 显示名称
  showItemName(String itemName, bool showFlag) {
    return Container(
      height: 42,
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          children: [
            !showFlag
                ? TextSpan(
                    text: '*', style: getTextStyle(color: colorScheme.error))
                : TextSpan(
                    text: '',
                  ),
            TextSpan(
                text: ' $itemName',
                style: textTheme.bodySmall!.apply(
                    color: colorScheme.onSurface,
                    overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }

  //输入框
  showInputBox(TextEditingController controller, String hintText) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: getTextStyle(
            color: colorScheme.surfaceContainerHighest, // 设置提示文本颜色
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(0.0))),
          counterText: '',
        ),
        maxLength: 40,
        style: getTextStyle(),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  //输入密码框

  showInputPwdBox(TextEditingController controller, String hintText) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: getTextStyle(
            color: colorScheme.surfaceContainerHighest, // 设置提示文本颜色
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(0.0))),
          counterText: '',
        ),
        maxLength: 15,
        obscureText: true,
        obscuringCharacter: '*',
        style: getTextStyle(),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  bool checkSaveBtn() {
    // 操作员必须选择初始页面
    if (initPageId == null && selectedRole == 'operator') {
      return false;
    }
    if (userNameCtl.text.isEmpty ||
        phoneCtl.text.isEmpty ||
        emailCtl.text.isEmpty) {
      return false;
    }
    //新增
    if (widget.type == 1) {
      if (pwd1Ctl.text == '' || pwd2Ctl.text == '') {
        return false;
      } else {
        return true;
      }
    }
    if ((pwd1Ctl.text.isEmpty && pwd2Ctl.text.isNotEmpty) ||
        (pwd1Ctl.text.isNotEmpty && pwd2Ctl.text.isEmpty)) {
      return false;
    }
    return true;
  }

  //保存功能  新增按钮
  void addNewUser() {
    ReqAddSysUser tempUser = ReqAddSysUser();
    List<int> tempAppIds = [];

    tempUser.userName = userNameCtl.text;
    tempUser.phone = phoneCtl.text;
    tempUser.email = emailCtl.text;
    tempUser.password = pwd1Ctl.text;
    if (selectedRole == "admin") {
      tempUser.roleId = 2;
      tempUser.pagesId = [];
      tempUser.initialPageId = 0;
    } else {
      tempUser.roleId = 3;
      for (var item in selectedConfigIds) {
        tempAppIds.add(item);
      }
      for (var item in selectedAppIds) {
        tempAppIds.add(item);
      }
      tempUser.pagesId = tempAppIds;
      tempUser.initialPageId = initPageId;
    }
    tempUser.isEnabled = true;

    tempUser.remark = '';
    tempUser.createdBy = mySysUser.userId;
    tempUser.updatedBy = mySysUser.userId;

    String jsonData = reqAddSysUserToJson(tempUser);

    PublicFunctions.addSysUser(jsonData);
  }

  //保存功能  修改按钮
  void updateUserInfo() {
    ReqUpdateSysUser updateSysUser = ReqUpdateSysUser();

    UpdateUser tempUser = UpdateUser();
    List<int> tempAppIds = [];

    tempUser.userId = widget.initUserInfo.userId;
    tempUser.userName = userNameCtl.text;
    tempUser.phone = phoneCtl.text;
    tempUser.email = emailCtl.text;
    tempUser.isEnabled = true;
    tempUser.createdBy = widget.initUserInfo.createdBy;
    tempUser.createdTime = widget.initUserInfo.createdTime;
    tempUser.password = widget.initUserInfo.password;

    if (pwd1Ctl.text.isNotEmpty && pwd2Ctl.text.isNotEmpty) {
      tempUser.password = pwd1Ctl.text;
    }

    if (selectedRole == "admin") {
      tempUser.roleId = 2;
      tempUser.initialPageId = 0;
    } else {
      tempUser.roleId = 3;
      for (var item in selectedConfigIds) {
        tempAppIds.add(item);
      }
      for (var item in selectedAppIds) {
        tempAppIds.add(item);
      }

      tempUser.initialPageId = initPageId;
    }

    tempUser.remark = '';
    tempUser.updatedBy = mySysUser.userId;
    updateSysUser.pagesId = tempAppIds;

    updateSysUser.updateUser = tempUser;
    String jsonData = reqUpdateSysUserToJson(updateSysUser);

    PublicFunctions.updateSysUser(jsonData);
  }

  TextStyle getTextStyle({Color? color}) {
    return textTheme.bodySmall!.apply(
      color: color ?? colorScheme.onSurface,
    );
  }

  TextStyle getTitleBoldStyle({Color? color}) {
    return textTheme.labelMedium!.apply(
      color: color ?? colorScheme.onSurface,
    );
  }

  Widget showBtnRow() {
    return SizedBox(
        height: 86,
        child: Center(
            child: SizedBox(
          width: 400,
          height: 48,
          child: Row(children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: colorScheme.onPrimary,
                  backgroundColor: colorScheme.primary,
                  fixedSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // 可以根据需要调整圆角
                  ),
                ),
                onPressed: checkSaveBtn()
                    ? () {
                        if (pwd1Ctl.text != pwd2Ctl.text) {
                          showTipInfo(
                              localizedStrings.tipPasswordNotSame, context);
                          return;
                        }

                        if (widget.type == 1) {
                          for (var item in widget.sysUserList) {
                            if (item.userName == userNameCtl.text) {
                              showTipInfo(
                                  localizedStrings.tipUserNameExist, context);
                              return;
                            }
                          }
                          addNewUser();
                          Navigator.pop(context);
                        } else {
                          for (var item in widget.sysUserList) {
                            if (item.userName == userNameCtl.text &&
                                item.userId != widget.initUserInfo.userId) {
                              showTipInfo(
                                  localizedStrings.tipUserNameExist, context);
                              return;
                            }
                          }
                          updateUserInfo();
                          Navigator.pop(context);
                        }
                      }
                    : null,
                child: Text(
                  localizedStrings.gBtnSave,
                  style: getTextStyle(
                    color: colorScheme.onPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: colorScheme.onSurfaceVariant,
                  backgroundColor: colorScheme.outline,
                  fixedSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // 可以根据需要调整圆角
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  localizedStrings.fBackBtn,
                  style: getTextStyle(),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ]),
        )));
  }

  Widget showMiddlePart(double widthFor3Item) {
    return Expanded(
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true, // 始终显示滚动条
        thickness: 8, // 设置滚动条的厚度
        radius: const Radius.circular(4), // 设置滚动条的圆角
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              showTitlePart(localizedStrings.userBasicInfo),
              Container(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 300,
                          height: 90,
                          child: Column(children: [
                            showItemName(
                                localizedStrings.userUsername + ' ', false),
                            showInputBox(userNameCtl, ''),
                          ]),
                        ),
                        SizedBox(
                          width: largePadding,
                        ),
                        SizedBox(
                          width: 300,
                          height: 90,
                          child: Column(children: [
                            showItemName(
                                localizedStrings.userPhone + ' ', false),
                            showInputBox(phoneCtl, ''),
                          ]),
                        ),
                        SizedBox(
                          width: largePadding,
                        ),
                        SizedBox(
                          width: 300,
                          height: 90,
                          child: Column(children: [
                            showItemName(
                                localizedStrings.userEmail + ' ', false),
                            showInputBox(emailCtl, ''),
                          ]),
                        ),
                      ])),
              showTitlePart(localizedStrings.userPassword),
              Container(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 300,
                          height: 90,
                          child: Column(children: [
                            showItemName(localizedStrings.userPassword + ' ',
                                widget.type == 2 ? true : false),
                            showInputPwdBox(pwd1Ctl, ''),
                          ]),
                        ),
                        SizedBox(
                          width: largePadding,
                        ),
                        SizedBox(
                          width: 300,
                          height: 90,
                          child: Column(children: [
                            showItemName(
                                localizedStrings.userConfirmPassword + ' ',
                                widget.type == 2 ? true : false),
                            showInputPwdBox(pwd2Ctl, ''),
                          ]),
                        ),
                      ])),
              showTitlePart(localizedStrings.userRole),
              Container(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // 管理员选项
                      if (mySysUser.roleId == superAdminRoleId)
                        Row(
                          children: [
                            Radio<String>(
                              value: 'admin',
                              groupValue: selectedRole,
                              onChanged: (value) {
                                setState(() {
                                  selectedRole = value;
                                });
                              },
                            ),
                            SizedBox(
                              width: 150,
                              child: Text(
                                localizedStrings.admin,
                                style: getTextStyle(),
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        ),
                      // 水平间距
                      if (mySysUser.roleId == superAdminRoleId)
                        SizedBox(width: 20),
                      // 操作员选项
                      Row(
                        children: [
                          Radio<String>(
                            value: 'operator',
                            groupValue: selectedRole,
                            onChanged: (value) {
                              setState(() {
                                selectedRole = value;
                              });
                            },
                          ),
                          SizedBox(
                            width: 150,
                            child: Text(
                              localizedStrings.operator,
                              style: getTextStyle(),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        ],
                      ),
                    ],
                  )),
              if (selectedRole == 'operator') ...operatorPart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget showTitlePart(String title) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 8, top: 8),
      height: 45,
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: getTitleBoldStyle(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  List<Widget> operatorPart() {
    return [
      showTitlePart(localizedStrings.userConfigPermissions),
      showConfigSettingWidget(),
      showTitlePart(localizedStrings.userAppPermissions),
      showAppSettingWidget(),
      showTitlePart(localizedStrings.userDefaultApp),
      showDefaultAppWidget(),
    ];
  }

  Widget showConfigSettingWidget() {
    // 添加间距常量，统一控制水平和垂直间距
    const double spacing = 20.0;
    return Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;

            final itemWidth = (availableWidth - (4 - 1) * spacing) / 4;

            return Wrap(
              spacing: spacing, // 使用统一的间距变量
              runSpacing: spacing, // 垂直间距也使用相同变量
              children: [
                for (var item in allConfigMenus)
                  SizedBox(
                    width: itemWidth, // 设置每个项目的宽度
                    child: buildConfigInfo(context, item.id),
                  ),
              ],
            );
          },
        ));
  }

  Widget showAppSettingWidget() {
    // 添加间距常量，统一控制水平和垂直间距
    const double spacing = 20.0;
    return Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;

            final itemWidth = (availableWidth - (4 - 1) * spacing) / 4;

            return Wrap(
              spacing: spacing, // 使用统一的间距变量
              runSpacing: spacing, // 垂直间距也使用相同变量
              children: [
                for (var item in allAppsMenus)
                  SizedBox(
                    width: itemWidth, // 设置每个项目的宽度
                    child: buildAppInfo(context, item.id),
                  ),
              ],
            );
          },
        ));
  }

  bool getIsAddedConfig(int id) {
    return selectedConfigPaidMenuIds.contains(id);
  }

  bool getIsAddedApp(int id) {
    return selectedAppsPaidMenuIds.contains(id);
  }

  Widget buildConfigInfo(BuildContext context, int id) {
    if (allConfigMenus.isEmpty) return SizedBox();
    RouteData tempApp =
        allConfigMenus.firstWhere((element) => element.id == id);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
      ),
      // padding: const EdgeInsets.all(regularPadding),
      child: Column(
        children: [
          SizedBox(
            height: 25,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // 添加复选框
                Checkbox(
                  value: selectedConfigIds.contains(id),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),

                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        selectedConfigIds.add(id);
                      } else {
                        selectedConfigIds.remove(id);
                      }
                      initPageId = null;
                    });
                  }, // 未认证时不可选
                ),

                Row(
                  children: [
                    Text(
                      tempApp.title,
                      style: textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAppInfo(BuildContext context, int id) {
    if (allAppsMenus.isEmpty) return SizedBox();

    RouteData tempApp = allAppsMenus.firstWhere((element) => element.id == id);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
      ),
      // padding: const EdgeInsets.all(regularPadding),
      child: Column(
        children: [
          SizedBox(
            height: 25,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // 添加复选框
                Checkbox(
                  value: selectedAppIds.contains(id),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),

                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        selectedAppIds.add(id);
                      } else {
                        selectedAppIds.remove(id);
                      }
                      initPageId = null;
                    });
                  }, // 未认证时不可选
                ),

                Row(
                  children: [
                    Text(
                      tempApp.title,
                      style: textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget showDefaultAppWidget() {
    List<int> pageIds = [];
    for (var item in selectedAppIds) {
      pageIds.add(item);
    }
    for (var item in selectedConfigIds) {
      pageIds.add(item);
    }
    Map<int, String> appNameMap = {};
    for (var item in pageIds) {
      appNameMap[item] = generateTitle(item);
    }
    // 关键修复：检查当前选中ID是否仍然有效
    if (initPageId != null && !pageIds.contains(initPageId)) {
      // 如果无效，重置为列表第一个元素或null
      initPageId = pageIds.isNotEmpty ? pageIds.first : null;
    } else if (initPageId == null && pageIds.isNotEmpty) {
      // 如果没有选中值但列表不为空，默认选中第一个
      initPageId = pageIds.first;
    }
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20),
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 360,
            child: DropdownButtonFormField<int>(
              value: initPageId,
              borderRadius: BorderRadius.circular(0),
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: colorScheme.surfaceDim, // 失去焦点时灰色边框
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(0.0))),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: colorScheme.surfaceDim, // 聚焦时蓝色边框
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(0.0))),
                border: OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
              ),
              onChanged: pageIds.isEmpty
                  ? null
                  : (int? newValue) {
                      setState(() {
                        if (newValue != null && pageIds.isNotEmpty) {
                          initPageId = newValue;
                        }
                      });
                    },
              items: pageIds.isEmpty
                  ? null
                  : appNameMap.entries.map((MapEntry<int, String> entry) {
                      return DropdownMenuItem<int>(
                        value: entry.key,
                        child: Text(entry.value, style: textTheme.bodySmall),
                      );
                    }).toList(),
              hint: Text(localizedStrings.tipNoPermission,
                  style: textTheme.bodySmall),
              style: textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final double widthFor3Item =
        (width - 300) / 3 > 380 ? 380 : (width - 300) / 3;
    return Scaffold(
        backgroundColor: colorScheme.surfaceContainerLow,
        body: Container(
          color: colorScheme.surface,
          child: Column(
            children: [
              pageHeadInfo(
                  context,
                  width - headWidthPadding,
                  widget.type == 1
                      ? localizedStrings.userAdd
                      : localizedStrings.userUpdate,
                  '',
                  showHelp: false),
              Divider(
                height: 1,
                color: colorScheme.surfaceDim,
              ),
              showMiddlePart(widthFor3Item),
              showBtnRow()
            ],
          ),
          // ),
        ));
  }
}
