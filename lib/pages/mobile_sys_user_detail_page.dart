import 'package:flutter/material.dart';
import 'package:t_max/data/sys_user_from_db.dart';
import 'package:t_max/data/sys_user_req.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/pages/mobile_add_sys_user_page.dart';
import 'package:intl/intl.dart';

class MobileSysUserDetailPage extends StatefulWidget {
  final SysUserFromDb user;
  final List<SysUserFromDb> sysUserList;

  const MobileSysUserDetailPage({
    super.key,
    required this.user,
    required this.sysUserList,
  });

  @override
  State<MobileSysUserDetailPage> createState() => _MobileSysUserDetailPageState();
}

class _MobileSysUserDetailPageState extends State<MobileSysUserDetailPage> {
  late SysUserFromDb _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }

  void _onEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MobileAddSysUserPage(
          sysUserList: widget.sysUserList,
          initUserInfo: _currentUser,
          type: 2, // edit
          isSuperAccount: _currentUser.userId == 1,
        ),
      ),
    ).then((saved) {
      if (!mounted) return;
      if (saved == true) {
        // Return to user list so it fetches latest data
        Navigator.pop(context);
      }
    });
  }

  void _onToggleEnable(bool value) {
    if (_currentUser.userId == 1) return;
    
    ReqEnableSysUser req = ReqEnableSysUser(
      userId: _currentUser.userId,
      isEnabled: value,
    );
    PublicFunctions.enableSysUser(reqEnableSysUserToJson(req));
    setState(() {
      _currentUser.isEnabled = value;
    });
  }

  void _onDelete() {
    if (_currentUser.userId == 1) return;
    
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(localizedStrings?.tipTitle ?? "Tip"),
          content: Text(localizedStrings?.tipDeleteSysUser ?? "Are you sure to delete this user?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(localizedStrings?.gBtnCancel ?? "Cancel", style: const TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                ReqDelSysUsers req = ReqDelSysUsers(userIds: [_currentUser.userId!]);
                PublicFunctions.deleteSysUser(reqDelSysUsersToJson(req));
                Navigator.pop(context);
              },
              child: Text(localizedStrings?.gBtnConfirm ?? "Confirm", style: const TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRow(String label, String value) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.black54, fontSize: 16)),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFEEEEEE)),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "-";
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    String roleName = '';
    if (_currentUser.roleId == 1) {
      roleName = localizedStrings?.superAdmin ?? "Super Admin";
    } else if (_currentUser.roleId == 2) {
      roleName = localizedStrings?.admin ?? "Admin";
    } else {
      roleName = localizedStrings?.operator ?? "Operator";
    }

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
          localizedStrings?.details ?? "Details",
          style: const TextStyle(color: Colors.black87, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.black87),
            onPressed: _onEdit,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildRow(localizedStrings?.userAccount ?? "Account", _currentUser.userName ?? "-"),
                  _buildRow(localizedStrings?.userName ?? "User name", _currentUser.nickName ?? "-"),
                  _buildRow(localizedStrings?.userRole ?? "Role", roleName),
                  _buildRow(localizedStrings?.userPhone ?? "Phone number", _currentUser.phone ?? "-"),
                  _buildRow(localizedStrings?.userEmail ?? "Email", _currentUser.email ?? "-"),
                  _buildRow(localizedStrings?.createdTime ?? "Create Time", _formatDate(_currentUser.createdTime)),
                  _buildRow(localizedStrings?.updatedTime ?? "Update Time", _formatDate(_currentUser.updatedTime)),
                  
                  // Enabled Switch
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(localizedStrings?.userEnabled ?? "Enabled", style: const TextStyle(color: Colors.black54, fontSize: 16)),
                        Switch(
                          value: _currentUser.isEnabled ?? true,
                          activeColor: const Color(0xFF1ABC9C),
                          onChanged: _currentUser.userId == 1 ? null : _onToggleEnable,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                ],
              ),
            ),
          ),
          
          if (_currentUser.userId != 1)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF03E3E), // Red color for delete
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    onPressed: _onDelete,
                    child: Text(
                      localizedStrings?.gBtnDelete ?? "Delete",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
