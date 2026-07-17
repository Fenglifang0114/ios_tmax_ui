import 'package:flutter/material.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/sys_user_req.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';

class MobileChangePasswordPage extends StatefulWidget {
  const MobileChangePasswordPage({super.key});

  @override
  State<MobileChangePasswordPage> createState() => _MobileChangePasswordPageState();
}

class _MobileChangePasswordPageState extends State<MobileChangePasswordPage> {
  final TextEditingController pwd1Controller = TextEditingController();
  final TextEditingController pwd2Controller = TextEditingController();

  @override
  void dispose() {
    pwd1Controller.dispose();
    pwd2Controller.dispose();
    super.dispose();
  }

  void _onConfirm() {
    if (pwd1Controller.text != pwd2Controller.text) {
      showTipInfo(localizedStrings?.tipPasswordNotSame ?? "Passwords do not match", context);
      return;
    }
    ReqModifyPwd reqModifyPwd = ReqModifyPwd(
      userId: mySysUser.userId,
      newPassword: pwd1Controller.text,
    );
    String jsonData = reqModifyPwdToJson(reqModifyPwd);
    PublicFunctions.modifyPwd(jsonData);
    
    // Show success tip
    showTipInfo((localizedStrings?.fSuccessMsg ?? "Success"), context);
    Navigator.pop(context);
  }

  Widget _buildField(String title, TextEditingController controller) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Text('* ', style: TextStyle(color: Colors.red, fontSize: 16)),
          Text(title, style: const TextStyle(fontSize: 16, color: Colors.black87)),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: true,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: localizedStrings?.fSearchHint ?? "Please enter",
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
                border: InputBorder.none,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }

  bool _isSaveEnabled() {
    return pwd1Controller.text.isNotEmpty && pwd2Controller.text.isNotEmpty;
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          localizedStrings?.titleChangePassword ?? "Change password",
          style: const TextStyle(color: Colors.black87, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  _buildField(localizedStrings?.userNewPassword ?? "New password", pwd1Controller),
                  _buildField(localizedStrings?.userConfirmPassword ?? "Confirm password", pwd2Controller),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSaveEnabled() ? Theme.of(context).colorScheme.primary : Colors.grey[300], 
                    foregroundColor: _isSaveEnabled() ? Theme.of(context).colorScheme.onPrimary : Colors.white70,
                    elevation: 0,
                  ),
                  onPressed: _isSaveEnabled() ? _onConfirm : null,
                  child: Text(
                    localizedStrings?.gBtnConfirm ?? "Confirm",
                    style: const TextStyle(fontSize: 16),
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
