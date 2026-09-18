import 'package:flutter/material.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/sys_user_from_db.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/pages/mobile_add_sys_user_page.dart';
import 'package:t_max/pages/mobile_sys_user_detail_page.dart';

class MobileSysUserManagerPage extends StatefulWidget {
  final Function(String)? onNavigate;
  final String? lastRouteName;

  const MobileSysUserManagerPage({super.key, this.onNavigate, this.lastRouteName});

  @override
  State<MobileSysUserManagerPage> createState() => _MobileSysUserManagerPageState();
}

class _MobileSysUserManagerPageState extends State<MobileSysUserManagerPage> {
  final TextEditingController _searchUserNameCtl = TextEditingController();
  List<SysUserFromDb> searchUserList = [];
  List<SysUserFromDb> allUserList = [];
  SysUserFromDb? superAdminUser;
  dynamic _eventbus1;
  dynamic _eventbus2;
  dynamic _eventbus3;
  dynamic _eventbus4;

  @override
  void initState() {
    super.initState();
    PublicFunctions.getAllSysUsers();

    _eventbus1 = eventBus.on<EventRespGetAllUsers>().listen((event) {
      if (mounted) {
        try {
          String dataStr = event.obj?.toString() ?? '';
          allUserList = sysUserFromDbFromJson(dataStr);
          if (allUserList.length == 1 && allUserList[0].isChanged == false) {
            superAdminUser = allUserList[0];
            mySysUser.isChanged = false;
          } else {
            superAdminUser = null;
            if (mySysUser.roleId == superAdminRoleId) {
              for (var user in allUserList) {
                if (user.userId == mySysUser.userId) {
                  mySysUser.isChanged = user.isChanged ?? true;
                }
              }
            }
          }
          performSearch();
        } catch (e) {
          debugPrint("Error handling EventRespGetAllUsers: $e");
        }
      }
    });

    _eventbus2 = eventBus.on<EventRespAddSysUser>().listen((event) {
      if (mounted) {
        try {
          String dataStr = event.obj?.toString() ?? '';
          if (dataStr.startsWith("fail")) {
            showTipInfo(dataStr, context);
          } else {
            showTipInfo((localizedStrings?.fSuccessMsg ?? "Success"), context);
            PublicFunctions.getAllSysUsers();
          }
        } catch (e) {
          debugPrint("Error handling EventRespAddSysUser: $e");
        }
      }
    });

    _eventbus3 = eventBus.on<EventRespUpdateSysUser>().listen((event) {
      if (mounted) {
        try {
          String dataStr = event.obj?.toString() ?? '';
          if (dataStr.startsWith("fail")) {
            showTipInfo(dataStr, context);
          } else {
            showTipInfo((localizedStrings?.fSuccessMsg ?? "Success"), context);
            PublicFunctions.getAllSysUsers();
          }
        } catch (e) {
          debugPrint("Error handling EventRespUpdateSysUser: $e");
        }
      }
    });

    _eventbus4 = eventBus.on<EventRespDeleteSysUser>().listen((event) {
      if (mounted) {
        try {
          String dataStr = event.obj?.toString() ?? '';
          if (dataStr.startsWith("fail")) {
            showTipInfo(dataStr, context);
          } else {
            showTipInfo((localizedStrings?.fSuccessMsg ?? "Success"), context);
            PublicFunctions.getAllSysUsers();
          }
        } catch (e) {
          debugPrint("Error handling EventRespDeleteSysUser: $e");
        }
      }
    });
  }

  @override
  void dispose() {
    _searchUserNameCtl.dispose();
    _eventbus1?.cancel();
    _eventbus2?.cancel();
    _eventbus3?.cancel();
    _eventbus4?.cancel();
    super.dispose();
  }

  void performSearch() {
    final String keyword = _searchUserNameCtl.text.trim();
    setState(() {
      if (mySysUser.roleId != superAdminRoleId) {
        // filter out user id 1
        searchUserList = allUserList.where((u) => u.userId != 1).toList();
      } else {
        searchUserList = List.from(allUserList);
      }

      if (keyword.isNotEmpty) {
        searchUserList = searchUserList.where((user) {
          final userId = user.userId ?? 0;
          final userName = user.userName ?? '';
          return userId.toString().contains(keyword) ||
              userName.contains(keyword);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            if (widget.onNavigate != null) {
              widget.onNavigate!('/multiScaleManagement');
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          localizedStrings?.userManagement ?? "User management",
          style: const TextStyle(color: Colors.black87, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.black87),
            onPressed: () {
              bool isSuperUnset = (mySysUser.roleId == superAdminRoleId) &&
                  ((mySysUser.isChanged ?? false) == false);
              if (isSuperUnset) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MobileAddSysUserPage(
                      sysUserList: allUserList,
                      initUserInfo: superAdminUser ?? SysUserFromDb(userId: 1, userName: "Super Admin", roleId: 1, isChanged: false),
                      type: 2, // 2: edit
                      isSuperAccount: true,
                    ),
                  ),
                ).then((_) => PublicFunctions.getAllSysUsers());
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MobileAddSysUserPage(
                    sysUserList: allUserList,
                    initUserInfo: SysUserFromDb(),
                    type: 1, // 1: add
                    isSuperAccount: false,
                  ),
                ),
              ).then((_) => PublicFunctions.getAllSysUsers());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: TextField(
                controller: _searchUserNameCtl,
                onChanged: (value) => performSearch(),
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  isDense: true,
                  prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                  prefixIconConstraints: const BoxConstraints(minWidth: 36, maxHeight: 40),
                  hintText: localizedStrings?.fSearchHint ?? "Please enter",
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // User list
          Expanded(
            child: ListView.separated(
              itemCount: searchUserList.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
              itemBuilder: (context, index) {
                final user = searchUserList[index];
                String roleName = '';
                if (user.roleId == 1) {
                  roleName = (user.isChanged == false)
                      ? "${localizedStrings?.superAdmin ?? 'Super Admin'} (${localizedStrings?.pleaseSetSuperAdmin ?? 'Please set super admin'})"
                      : (localizedStrings?.superAdmin ?? "Super Admin");
                } else if (user.roleId == 2) {
                  roleName = localizedStrings?.admin ?? "Admin";
                } else {
                  roleName = localizedStrings?.operator ?? "Operator";
                }

                Widget avatar = CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  radius: 24,
                  child: Text(
                    user.userName != null && user.userName!.isNotEmpty 
                        ? user.userName![0].toUpperCase() 
                        : 'U',
                    style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                );

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: avatar,
                  title: Text(
                    user.userName ?? '',
                    style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    roleName,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    if (user.roleId == 1 && user.isChanged == false) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MobileAddSysUserPage(
                            sysUserList: allUserList,
                            initUserInfo: user,
                            type: 2, // edit
                            isSuperAccount: true,
                          ),
                        ),
                      ).then((_) => PublicFunctions.getAllSysUsers());
                      return;
                    }

                    // Go to user detail page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MobileSysUserDetailPage(
                          user: user,
                          sysUserList: allUserList,
                        ),
                      ),
                    ).then((_) => PublicFunctions.getAllSysUsers());
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
