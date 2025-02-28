import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/userinfo_data.dart';
import 'package:t_max/eventbus/eventbus.dart';
import '../../data/scalecmd_data.dart';
import '../../functions/methods.dart';
import '../data/language.dart';
import '../widget/custom_button.dart';

TextEditingController userName = TextEditingController(
    text: ((myUserInfo.name == null) ? "" : myUserInfo.name));
TextEditingController userId =
    TextEditingController(text: ((myUserInfo.id == null) ? "" : myUserInfo.id));
TextEditingController model = TextEditingController();

TextEditingController phone = TextEditingController(
    text: ((myUserInfo.phone == null) ? "" : myUserInfo.phone));
TextEditingController userRemark = TextEditingController(
    text: ((myUserInfo.remarks == null) ? "" : myUserInfo.remarks));
TextEditingController errorText = TextEditingController();
int _checkFemale = 1;

addUserDialog(BuildContext context) {
  userName.text = ((myUserInfo.name == null) ? "" : myUserInfo.name)!;
  userId.text = ((myUserInfo.id == null) ? "" : myUserInfo.id)!;
  phone.text = ((myUserInfo.phone == null) ? "" : myUserInfo.phone)!;
  userRemark.text = ((myUserInfo.remarks == null) ? "" : myUserInfo.remarks)!;
  _checkFemale = ((myUserInfo.isFemale == null)
      ? 1
      : (myUserInfo.isFemale!)
          ? 1
          : 2);
  errorText.text = "";

  return showDialog(
      barrierDismissible: false, //设置为false，点击空白处弹窗不关闭
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: ((context, setState) {
          return AlertDialog(
            title: getDialogTitle(context, localizedStrings.gPluField,
                Icons.edit_note_outlined, 400),
            content: Container(
              height: 440,
              decoration:
                  BoxDecoration(color: Theme.of(context).colorScheme.onPrimary),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 2),
                    Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onPrimary),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 150,
                                        child: Text(
                                          localizedStrings.user_id,
                                          textAlign: TextAlign.left,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 200,
                                        child: TextField(
                                          controller: userId,
                                          maxLength: 20,
                                          maxLengthEnforcement:
                                              MaxLengthEnforcement.enforced,
                                          maxLines: 1,
                                          textAlign: TextAlign.center,
                                          decoration: const InputDecoration(
                                            counterText: "",
                                            // hintText: "请输入机种类型，如：ztp",
                                            // border: OutlineInputBorder(),
                                          ),
                                          onChanged: (value) {
                                            errorText.text = "";
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text(localizedStrings.user_name),
                                  SizedBox(
                                    width: 400,
                                    child: TextField(
                                      controller: userName,
                                      maxLength: 100,
                                      maxLengthEnforcement:
                                          MaxLengthEnforcement.enforced,
                                      maxLines: 1,
                                      textAlignVertical: TextAlignVertical.top,
                                      decoration: const InputDecoration(
                                        counterText: "",
                                        // hintText: "请输入机种类型，如：ztp",
                                        // border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        errorText.text = "";
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      SizedBox(
                                          width: 100,
                                          child:
                                              Text(localizedStrings.user_sex)),
                                      Radio(
                                          value: 1,
                                          groupValue: _checkFemale,
                                          onChanged: (value) {
                                            debugPrint(value.toString());
                                            setState(() {
                                              errorText.text = "";
                                              _checkFemale = 1;
                                            });
                                          }),
                                      const Text("Woman"),
                                      const SizedBox(width: 50),
                                      Radio(
                                          value: 2,
                                          groupValue: _checkFemale,
                                          onChanged: (value) {
                                            debugPrint(value.toString());
                                            setState(() {
                                              errorText.text = "";
                                              _checkFemale = 2;
                                            });
                                          }),
                                      const Text("Men"),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 150,
                                        child: Text(
                                          localizedStrings.user_phone,
                                          textAlign: TextAlign.left,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 200,
                                        child: TextField(
                                          controller: phone,
                                          maxLength: 11,
                                          maxLengthEnforcement:
                                              MaxLengthEnforcement.enforced,
                                          maxLines: 1,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp("[0-9.]"))
                                          ], //数字包括小数,
                                          textAlignVertical:
                                              TextAlignVertical.top,
                                          decoration: const InputDecoration(
                                            counterText: "",
                                            // hintText: "请输入机种类型，如：ztp",
                                            // border: OutlineInputBorder(),
                                          ),
                                          onChanged: (value) {
                                            errorText.text = "";
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(localizedStrings.user_remarks),
                                  SizedBox(
                                    width: 400,
                                    height: 80,
                                    child: TextField(
                                      controller: userRemark,
                                      maxLength: 200,
                                      maxLengthEnforcement:
                                          MaxLengthEnforcement.enforced,
                                      maxLines: 5,
                                      textAlignVertical: TextAlignVertical.top,
                                      decoration: const InputDecoration(
                                        counterText: "",
                                        // hintText: "请输入机种类型，如：ztp",
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        errorText.text = "";
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 400,
                                    height: 30,
                                    child: TextField(
                                      enabled: false,
                                      controller: errorText,
                                      maxLength: 100,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error),
                                      maxLengthEnforcement:
                                          MaxLengthEnforcement.enforced,
                                      maxLines: 1,
                                      textAlignVertical:
                                          TextAlignVertical.bottom,
                                      decoration: InputDecoration(
                                        border: const OutlineInputBorder(
                                            borderSide: BorderSide.none),
                                        counterText: "",
                                        focusColor: Theme.of(context)
                                            .colorScheme
                                            .error, // hintText: "请输入机种类型，如：ztp",
                                        // border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        errorText.text = "";
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomOutlinedButton(
                          btnWidth: 130,
                          btnHeight: 40,
                          icon: Icons.add,
                          text: localizedStrings.gBtnAdd,
                          onPressed: () {
                            errorText.text = '';
                            PublicFunctions.getUserList();
                            setState(() {
                              addUser();
                            });

                            PublicFunctions.getUserList();
                          },
                        ),
                        const SizedBox(width: 20),
                        CustomOutlinedButton(
                          btnWidth: 130,
                          btnHeight: 40,
                          icon: Icons.edit_outlined,
                          text: localizedStrings.gBtnEdit,
                          onPressed: () {
                            errorText.text = '';
                            PublicFunctions.getUserList();
                            PublicFunctions.getUserList();
                            editUser();
                            PublicFunctions.getUserList();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomOutlinedButton(
                          btnWidth: 130,
                          btnHeight: 40,
                          icon: Icons.delete,
                          text: localizedStrings.gBtnDelete,
                          onPressed: () {
                            if (userId.text.isNotEmpty ||
                                userName.text.isNotEmpty) {
                              errorText.text = '';
                              PublicFunctions.getUserList();
                              PublicFunctions.getUserList();
                              delUser();
                              PublicFunctions.getUserList();
                            } else {
                              errorText.text =
                                  localizedStrings.user_error_message1;
                            }
                          },
                        ),
                        const SizedBox(width: 20),
                        CustomOutlinedButton(
                          btnWidth: 130,
                          btnHeight: 40,
                          icon: Icons.exit_to_app,
                          text: localizedStrings.gBtnExit,
                          onPressed: () {
                            PublicFunctions.getUserList();
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        }));
      });
}

void addUser() {
  bool result = true;
  if (userId.text.isEmpty || userName.text.isEmpty) {
    errorText.text = localizedStrings.user_error_message1;
    return;
  }
  if (myUserInfoList.userInfo != null) {
    String? name;
    String? id;
    for (var i = 0; i < myUserInfoList.userInfo!.length; i++) {
      name = myUserInfoList.userInfo![i].name;
      id = myUserInfoList.userInfo![i].id;
      name ??= "";
      id ??= "";
      if (name == userName.text || id == userId.text) {
        errorText.text = localizedStrings.user_error_message2;
        return;
      }
    }
  }
  if (result) {
    myCurrUserInfo.id = userId.text;
    myCurrUserInfo.name = userName.text;
    myCurrUserInfo.isFemale = (_checkFemale == 1) ? true : false;
    myCurrUserInfo.remarks = userRemark.text;
    myCurrUserInfo.phone = phone.text;
    PublicFunctions.addUser(jsonEncode(myCurrUserInfo));
    errorText.text = "Success!";
    userId.text = "";
    userName.text = "";
    _checkFemale = 1;
    phone.text = '';
    userRemark.text = '';
  }
}

void editUser() {
  if (userId.text.isEmpty || userName.text.isEmpty) {
    errorText.text = localizedStrings.user_error_message1;
    return;
  }

  if (myUserInfoList.userInfo != null) {
    String? name;
    String? id;
    int recid = -1;
    bool isFind = false;
    for (var i = 0; i < myUserInfoList.userInfo!.length; i++) {
      name = myUserInfoList.userInfo![i].name;
      id = myUserInfoList.userInfo![i].id;
      name ??= "";
      id ??= "";
      if (name == userName.text || id == userId.text) {
        recid = myUserInfoList.userInfo![i].recId!;
        isFind = true;
        break;
      }
    }
    if (isFind && recid != -1) {
      myCurrUserInfo.recId = recid;
      myCurrUserInfo.id = userId.text;
      myCurrUserInfo.name = userName.text;
      myCurrUserInfo.isFemale = (_checkFemale == 1) ? true : false;
      myCurrUserInfo.remarks = userRemark.text;
      myCurrUserInfo.phone = phone.text;
      PublicFunctions.modifyUser(jsonEncode(myCurrUserInfo));
      if (kDebugMode) {
        print(jsonEncode(myScaleCmd));
      }
      errorText.text = "Success!";
      userId.text = "";
      userName.text = "";

      _checkFemale = 1;
      phone.text = '';
      userRemark.text = '';
    } else {
      errorText.text = localizedStrings.user_error_message3;
    }
  }
}

void delUser() {
  if (userId.text.isEmpty || userName.text.isEmpty) {
    errorText.text = localizedStrings.user_error_message1;
    return;
  }
  if (myUserInfoList.userInfo != null) {
    String? name;
    String? id;
    int recid = -1;
    bool isFind = false;
    for (var i = 0; i < myUserInfoList.userInfo!.length; i++) {
      name = myUserInfoList.userInfo![i].name;
      id = myUserInfoList.userInfo![i].id;
      name ??= "";
      id ??= "";
      if (name == userName.text || id == userId.text) {
        recid = myUserInfoList.userInfo![i].recId!;
        isFind = true;
        break;
      }
    }
    if (isFind && recid != -1) {
      myUserRecDel.recId = recid;
      PublicFunctions.delUser(jsonEncode(myUserRecDel));

      if (recid == myUserInfo.recId) {
        myUserInfo.id = "";
        myUserInfo.name = "";
        myUserInfo.phone = "";
        myUserInfo.remarks = "";
        eventBus.fire(EventUserInfo(myUserInfo));
      }
      errorText.text = "Success!";
      userId.text = "";
      userName.text = "";

      _checkFemale = 1;
      phone.text = '';
      userRemark.text = '';
    } else {
      errorText.text = localizedStrings.user_error_message3;
    }
  }
}
