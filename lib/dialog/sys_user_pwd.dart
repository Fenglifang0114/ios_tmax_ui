import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/sys_user_req.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/widget/common_widget.dart';
import '../../generated/l10n.dart';

class ModifyPwdPage extends StatefulWidget {
  const ModifyPwdPage({super.key});

  @override
  ModifyPwdPageState createState() => ModifyPwdPageState();
}

class ModifyPwdPageState extends State<ModifyPwdPage> {
  dynamic localizedStrings;
  TextEditingController pwd1Controller = TextEditingController();
  TextEditingController pwd2Controller = TextEditingController();

  ColorScheme get colorScheme => Theme.of(context).colorScheme;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizedStrings = S.of(context);
  }

  void saveLanguageSetting(String language) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    pwd1Controller.dispose();
    pwd2Controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 610,
        height: 460,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          children: [
            ...getCustomDialogTitle(
                context, localizedStrings.titleChangePassword),
            Expanded(
                child: Container(
                    padding: EdgeInsets.all(40),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceTint),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        showItemName(localizedStrings.userNewPassword, false),
                        showInputPwdBox(
                          pwd1Controller,
                          '',
                        ),
                        SizedBox(
                          height: largePadding,
                        ),
                        showItemName(
                            localizedStrings.userConfirmPassword, false),
                        showInputPwdBox(
                          pwd2Controller,
                          '',
                        ),
                        const SizedBox(
                          height: regularPadding,
                        ),
                      ],
                    ))),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                showTextButton(
                    context,
                    btnHeight,
                    localizedStrings.gBtnConfirm,
                    pwd1Controller.text.isEmpty || pwd2Controller.text.isEmpty
                        ? null
                        : () {
                            if (pwd1Controller.text != pwd2Controller.text) {
                              showTipInfo(
                                  localizedStrings.tipPasswordNotSame, context);
                              return;
                            }
                            ReqModifyPwd reqModifyPwd = ReqModifyPwd(
                              userId: mySysUser.userId,
                              newPassword: pwd1Controller.text,
                            );
                            String jsonData = reqModifyPwdToJson(reqModifyPwd);
                            PublicFunctions.modifyPwd(jsonData);

                            Navigator.pop(context);
                          },
                    Theme.of(context).colorScheme.onPrimary,
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary),
                const SizedBox(width: regularPadding),
                showTextButton(context, btnHeight, localizedStrings.gBtnCancel,
                    () {
                  Navigator.pop(context);
                },
                    Theme.of(context).colorScheme.onPrimary,
                    Theme.of(context).colorScheme.onSurfaceVariant,
                    Theme.of(context).colorScheme.onPrimary),
              ],
            ),
            SizedBox(
              height: regularPadding * 2,
            )
          ],
        ),
      ),
    );
  }

  TextStyle getTextStyle({Color? color}) {
    return Theme.of(context).textTheme.bodySmall!.apply(
          color: color ?? colorScheme.onSurface,
        );
  }

  TextStyle getTitleBoldStyle({Color? color}) {
    return Theme.of(context).textTheme.labelMedium!.apply(
          color: color ?? colorScheme.onSurface,
        );
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
                style: Theme.of(context).textTheme.bodySmall!.apply(
                    color: colorScheme.onSurface,
                    overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }

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
}
