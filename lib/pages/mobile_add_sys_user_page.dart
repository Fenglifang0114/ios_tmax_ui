import 'package:flutter/material.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/data/sys_user_from_db.dart';
import 'package:t_max/data/sys_user_req.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/pages/mobile_permission_settings_page.dart';
import 'package:t_max/eventbus/eventbus.dart';

class MobileAddSysUserPage extends StatefulWidget {
  final List<SysUserFromDb> sysUserList;
  final SysUserFromDb initUserInfo;
  final int type; // 1: add, 2: edit
  final bool isSuperAccount;

  const MobileAddSysUserPage({
    super.key,
    required this.sysUserList,
    required this.initUserInfo,
    required this.type,
    required this.isSuperAccount,
  });

  @override
  State<MobileAddSysUserPage> createState() => _MobileAddSysUserPageState();
}

class _MobileAddSysUserPageState extends State<MobileAddSysUserPage> {
  final _userNameCtl = TextEditingController();
  final _nickNameCtl = TextEditingController();
  final _pwdCtl = TextEditingController();
  final _pwdConfirmCtl = TextEditingController();
  final _phoneCtl = TextEditingController();
  final _emailCtl = TextEditingController();

  int _roleId = 3; // default operator
  Set<int> _selectedPermissions = {};
  int? _initialPageId;
  dynamic _eventbus2;

  @override
  void initState() {
    super.initState();
    if (widget.type == 2) {
      if (widget.isSuperAccount && widget.initUserInfo.isChanged == false) {
        _userNameCtl.text = widget.initUserInfo.userName ?? "Super Admin";
        _nickNameCtl.text = widget.initUserInfo.nickName ?? "Super Admin";
      } else {
        _userNameCtl.text = widget.initUserInfo.userName ?? "";
        _nickNameCtl.text = widget.initUserInfo.nickName ?? "";
        _phoneCtl.text = widget.initUserInfo.phone ?? "";
        _emailCtl.text = widget.initUserInfo.email ?? "";
      }
      _roleId = widget.initUserInfo.roleId ?? 3;
      
      // Load details for edit
      if (widget.initUserInfo.userName != null && widget.initUserInfo.userName!.isNotEmpty) {
        PublicFunctions.getUserInfo(widget.initUserInfo.userName!);
      }
    }
    
    if (widget.isSuperAccount) {
      _roleId = 1;
      _selectedPermissions = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20};
      _initialPageId = 1;
    }

    _eventbus2 = eventBus.on<EventRespGetUserDetail>().listen((event) {
      if (mounted) {
        setState(() {
          try {
            SysUserDetailFromDb tempUserDetail = sysUserDetailFromDbFromJson(event.obj);
            if (tempUserDetail.pageIdList != null) {
              _selectedPermissions = Set.from(tempUserDetail.pageIdList!);
            }
            _initialPageId = tempUserDetail.initialPageId;
          } catch (e) {
            // Error handling
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _userNameCtl.dispose();
    _nickNameCtl.dispose();
    _pwdCtl.dispose();
    _pwdConfirmCtl.dispose();
    _phoneCtl.dispose();
    _emailCtl.dispose();
    _eventbus2?.cancel();
    super.dispose();
  }

  void _save() {
    bool isFirstSuperAdminSetup = widget.type == 2 && widget.isSuperAccount && widget.initUserInfo.isChanged == false;

    if (_userNameCtl.text.isEmpty) {
      showTipInfo((localizedStrings?.userAccount ?? "Account cannot be empty"), context);
      return;
    }

    if (widget.type == 1 || isFirstSuperAdminSetup) {
      if (_pwdCtl.text.isEmpty) {
        showTipInfo((localizedStrings?.userPassword ?? "Password cannot be empty"), context);
        return;
      }
    }

    if (_pwdCtl.text.isNotEmpty || _pwdConfirmCtl.text.isNotEmpty) {
      if (_pwdCtl.text != _pwdConfirmCtl.text) {
        showTipInfo((localizedStrings?.tipPasswordNotSame ?? "Passwords do not match"), context);
        return;
      }
    }
    
    if (widget.type == 1) {
      for (var u in widget.sysUserList) {
        if (u.userName == _userNameCtl.text) {
          showTipInfo((localizedStrings?.tipAccountExist ?? "Account already exists"), context);
          return;
        }
      }
    }

    if (widget.type == 1) {
      ReqAddSysUser req = ReqAddSysUser(
        userName: _userNameCtl.text,
        nickName: _nickNameCtl.text,
        password: _pwdCtl.text,
        roleId: _roleId,
        isEnabled: true,
        pagesId: _roleId == 3 ? _selectedPermissions.toList() : [],
        initialPageId: _roleId == 3 ? (_initialPageId ?? 0) : 0,
        email: _emailCtl.text,
        phone: _phoneCtl.text,
        createdBy: mySysUser.userId ?? 1,
        updatedBy: mySysUser.userId ?? 1,
        remark: "",
      );
      PublicFunctions.addSysUser(reqAddSysUserToJson(req));
    } else {
      UpdateUser tempUser = UpdateUser(
        userId: widget.initUserInfo.userId ?? (widget.isSuperAccount ? 1 : null),
        userName: _userNameCtl.text,
        nickName: _nickNameCtl.text,
        roleId: _roleId,
        isEnabled: true,
        initialPageId: _roleId == 3 ? _initialPageId : 0,
        email: _emailCtl.text,
        phone: _phoneCtl.text,
        updatedBy: mySysUser.userId ?? 1,
        password: _pwdCtl.text.isNotEmpty ? _pwdCtl.text : widget.initUserInfo.password,
      );

      ReqUpdateSysUser req = ReqUpdateSysUser(
        updateUser: tempUser,
        pagesId: _roleId == 3 ? _selectedPermissions.toList() : [],
      );
      PublicFunctions.updateSysUser(reqUpdateSysUserToJson(req));
    }

    if (widget.isSuperAccount) {
      mySysUser.isChanged = true;
      mySysUser.userName = _userNameCtl.text;
      mySysUser.nickName = _nickNameCtl.text;
    }

    Navigator.pop(context, true);
  }

  Widget _buildRowField(String label, {required Widget child, bool isRequired = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              if (isRequired)
                const Text("* ", style: TextStyle(color: Colors.red, fontSize: 16)),
              Text(
                label,
                style: const TextStyle(color: Colors.black87, fontSize: 16),
              ),
              const SizedBox(width: 16),
              Expanded(child: child),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFEEEEEE)),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController ctl, {bool isPassword = false, bool readOnly = false, bool isRequired = false}) {
    return _buildRowField(
      label,
      isRequired: isRequired,
      child: TextField(
        controller: ctl,
        obscureText: isPassword,
        readOnly: readOnly,
        textAlign: TextAlign.right,
        style: TextStyle(color: readOnly ? Colors.grey : Colors.black87, fontSize: 16),
        decoration: InputDecoration(
          hintText: localizedStrings?.gTipPleaseInputKeyWord ?? "Please enter",
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEditingSuper = widget.type == 2 && widget.initUserInfo.roleId == 1;
    bool isFirstSuperAdminSetup = widget.type == 2 && widget.isSuperAccount && widget.initUserInfo.isChanged == false;
    bool accountReadOnly = widget.type == 2 && !isFirstSuperAdminSetup;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isFirstSuperAdminSetup 
              ? (localizedStrings?.pleaseSetSuperAdmin ?? "Set Super Admin Account")
              : (widget.type == 1 ? (localizedStrings?.userAdd ?? "Add User") : (localizedStrings?.userUpdate ?? "Edit User")),
          style: const TextStyle(color: Colors.black87, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                localizedStrings?.userBasicInfo ?? "Basic information",
                style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            _buildTextField(localizedStrings?.userAccount ?? "Account", _userNameCtl, readOnly: accountReadOnly, isRequired: true),
            _buildTextField(localizedStrings?.userUsername ?? "User name", _nickNameCtl, isRequired: true),
            
            // Role Selection
            _buildRowField(
              localizedStrings?.userRole ?? "Role",
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _roleId,
                  isExpanded: true,
                  icon: const SizedBox.shrink(), // hide icon
                  alignment: Alignment.centerRight,
                  style: TextStyle(color: (widget.isSuperAccount || isEditingSuper) ? Colors.red : Colors.grey[700], fontSize: 16),
                  items: [
                    DropdownMenuItem(value: 1, child: Align(alignment: Alignment.centerRight, child: Text(localizedStrings?.superAdmin ?? "Super Admin"))),
                    DropdownMenuItem(value: 2, child: Align(alignment: Alignment.centerRight, child: Text(localizedStrings?.admin ?? "Admin"))),
                    DropdownMenuItem(value: 3, child: Align(alignment: Alignment.centerRight, child: Text(localizedStrings?.operator ?? "Operator"))),
                  ],
                  onChanged: (widget.isSuperAccount || isEditingSuper) ? null : (val) {
                    setState(() => _roleId = val ?? 3);
                  },
                ),
              ),
            ),
            
            _buildTextField(localizedStrings?.userPhone ?? "Phone number", _phoneCtl),
            _buildTextField(localizedStrings?.userEmail ?? "Email", _emailCtl),

            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                localizedStrings?.userPassword ?? "Password",
                style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            _buildTextField(localizedStrings?.userPassword ?? "Password", _pwdCtl, isPassword: true, isRequired: widget.type == 1 || isFirstSuperAdminSetup),
            _buildTextField(localizedStrings?.userConfirmPassword ?? "Confirm password", _pwdConfirmCtl, isPassword: true, isRequired: widget.type == 1 || isFirstSuperAdminSetup),

            // Permission Settings
            if (_roleId == 3)
              _buildRowField(
                localizedStrings?.userConfigPermissions ?? "Permission Settings",
                child: InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => MobilePermissionSettingsPage(
                        selectedPermissions: _selectedPermissions,
                        initialPageId: _initialPageId,
                        onSaved: (perms, initId) {
                          setState(() {
                            _selectedPermissions = perms;
                            _initialPageId = initId;
                          });
                        },
                      ),
                    ));
                  },
                  child: const Align(
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.chevron_right, color: Colors.grey),
                  ),
                ),
              ),

            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1ABC9C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  onPressed: _save,
                  child: Text(localizedStrings?.gBtnConfirm ?? "Confirm", style: const TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
