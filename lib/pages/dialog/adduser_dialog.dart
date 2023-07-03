import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/userinfo_data.dart';
import 'package:t_max/eventbus/eventbus.dart';
import '../../data/scalecmd_data.dart';
import '../../main.dart';

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
            title: Container(
                color: Colors.blue.shade900,
                child: Row(
                  children: const [
                    Icon(Icons.verified_user, color: Colors.white),
                    Text("UserInfo", style: TextStyle(color: Colors.white))
                  ],
                )),
            content: Container(
              height: 400,
              decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 233, 232, 232)),
              child: Column(
                children: [
                  const SizedBox(height: 2),
                  Container(
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Column(
                      children: [
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("User ID:"),
                                SizedBox(
                                  width: 200,
                                  height: 30,
                                  child: TextField(
                                    controller: userId,
                                    maxLength: 20,
                                    maxLengthEnforcement:
                                        MaxLengthEnforcement.enforced,
                                    maxLines: 1,
                                    textAlignVertical: TextAlignVertical.bottom,
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
                                const Text("User Name:"),
                                SizedBox(
                                  width: 400,
                                  height: 30,
                                  child: TextField(
                                    controller: userName,
                                    maxLength: 100,
                                    maxLengthEnforcement:
                                        MaxLengthEnforcement.enforced,
                                    maxLines: 1,
                                    textAlignVertical: TextAlignVertical.bottom,
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
                                    const SizedBox(
                                        width: 100, child: Text("Sex:")),
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
                                    const Text("Female"),
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
                                    const Text("Male"),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                const SizedBox(height: 5),
                                const Text("Phone:"),
                                SizedBox(
                                  width: 400,
                                  height: 30,
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
                                    textAlignVertical: TextAlignVertical.bottom,
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
                                const Text("UserRemarks:"),
                                SizedBox(
                                  width: 400,
                                  height: 88,
                                  child: TextField(
                                    controller: userRemark,
                                    maxLength: 100,
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
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: 400,
                                  height: 30,
                                  child: TextField(
                                    enabled: false,
                                    controller: errorText,
                                    maxLength: 100,
                                    style: const TextStyle(color: Colors.red),
                                    maxLengthEnforcement:
                                        MaxLengthEnforcement.enforced,
                                    maxLines: 1,
                                    textAlignVertical: TextAlignVertical.bottom,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide.none),
                                      counterText: "",
                                      focusColor: Colors
                                          .red, // hintText: "请输入机种类型，如：ztp",
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
                        const SizedBox(height: 10),
                      ],
                    ),
                  )
                ],
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                      child: const Text("Add"),
                      onPressed: () {
                        errorText.text = '';
                        getUserList();
                        addUser();
                        getUserList();
                        // Navigator.of(context).pop(connectionType);
                      }),
                  const SizedBox(width: 20),
                  OutlinedButton(
                      child: const Text("Edit"),
                      onPressed: () {
                        errorText.text = '';
                        getUserList();
                        getUserList();
                        editUser();
                        getUserList();
                        // Navigator.of(context).pop(connectionType);
                      }),
                  const SizedBox(width: 20),
                  OutlinedButton(
                      child: const Text("Delete"),
                      onPressed: () {
                        if (userId.text.isNotEmpty ||
                            userName.text.isNotEmpty) {
                          errorText.text = '';
                          getUserList();
                          getUserList();
                          delUser();
                          getUserList();
                        } else {
                          errorText.text =
                              'The user id and user name can not be null !';
                        }
                        // Navigator.of(context).pop(connectionType);
                      }),
                  const SizedBox(width: 20),
                  OutlinedButton(
                      child: const Text("Exit"),
                      onPressed: () {
                        getUserList();
                        Navigator.of(context)
                            .pop(); // to go back to screen after submitting
                      })
                ],
              )
            ],
          );
        }));
      });
}

void getUserList() {
  myScaleCmd.cmdMode = "get_user_list";
  myScaleCmd.cmdData = "";
  MyApp.webchannel.sendMessage(jsonEncode(myScaleCmd));
}

void addUser() {
  bool result = true;
  if (userId.text.isEmpty || userName.text.isEmpty) {
    errorText.text = "User ID and user Name can not be null";
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
        errorText.text = "User ID or user name can not be repeated";
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
    myScaleCmd.cmdMode = "add_user";
    myScaleCmd.cmdData = jsonEncode(myCurrUserInfo);
    MyApp.webchannel.sendMessage(jsonEncode(myScaleCmd));
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
    errorText.text = "UserId and User Name could not null";
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
      myScaleCmd.cmdMode = "modify_user";
      myScaleCmd.cmdData = jsonEncode(myCurrUserInfo);
      MyApp.webchannel.sendMessage(jsonEncode(myScaleCmd));
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
      errorText.text = "The user record was not found !";
    }
  }
}

void delUser() {
  if (userId.text.isEmpty || userName.text.isEmpty) {
    errorText.text = "产品ID 或者产品名字不能为空";
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

      myScaleCmd.cmdMode = "del_user";
      myScaleCmd.cmdData = jsonEncode(myUserRecDel);
      MyApp.webchannel.sendMessage(jsonEncode(myScaleCmd));
      print(jsonEncode(myScaleCmd));
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
      errorText.text = "没有找到记录";
    }
  }
}
