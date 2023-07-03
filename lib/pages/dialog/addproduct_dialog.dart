import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/productrec.dart';
import 'package:t_max/eventbus/eventbus.dart';
import '../../data/productlist_data.dart';
import '../../data/scalecmd_data.dart';
import '../../main.dart';

TextEditingController productName = TextEditingController(
    text: ((myProductRecInfo.product == null) ? "" : myProductRecInfo.product));
TextEditingController productID = TextEditingController(
    text: ((myProductRecInfo.id == null) ? "" : myProductRecInfo.id));
TextEditingController model = TextEditingController();
TextEditingController description = TextEditingController();
TextEditingController preTare = TextEditingController(
    text: ((myProductRecInfo.pretare == null) ? "" : myProductRecInfo.pretare));
TextEditingController productRemark = TextEditingController(
    text: ((myProductRecInfo.remarks == null) ? "" : myProductRecInfo.remarks));
TextEditingController errorText = TextEditingController();

bool? isPresetTare = ((myProductRecInfo.withPretare == null) ? false : true);

addProductDialog(BuildContext context) {
  productName.text =
      ((myProductRecInfo.product == null) ? "" : myProductRecInfo.product)!;
  productID.text = ((myProductRecInfo.id == null) ? "" : myProductRecInfo.id)!;
  preTare.text =
      ((myProductRecInfo.pretare == null) ? "" : myProductRecInfo.pretare)!;
  productRemark.text =
      ((myProductRecInfo.remarks == null) ? "" : myProductRecInfo.remarks)!;
  isPresetTare = ((myProductRecInfo.withPretare == null)
      ? false
      : myProductRecInfo.withPretare);

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
                    Icon(Icons.feed, color: Colors.white),
                    Text("Product Information",
                        style: TextStyle(color: Colors.white))
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
                                const Text("PLU:"),
                                SizedBox(
                                  width: 200,
                                  height: 30,
                                  child: TextField(
                                    controller: productID,
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
                                      errorText.text = '';
                                    },
                                  ),
                                ),
                                const SizedBox(height: 5),
                                const Text("PLU Name:"),
                                SizedBox(
                                  width: 400,
                                  height: 30,
                                  child: TextField(
                                    controller: productName,
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
                                      errorText.text = '';
                                    },
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Checkbox(
                                        checkColor: Colors.white,
                                        activeColor: Colors.blue.shade900,
                                        value: isPresetTare,
                                        onChanged: (value) {
                                          setState(() {
                                            errorText.text = '';
                                            isPresetTare = value!;
                                            if (!isPresetTare!) {
                                              preTare.text = "";
                                            }
                                          });
                                        }),
                                    const Text("PreTare:"),
                                  ],
                                ),
                                SizedBox(
                                  width: 400,
                                  height: 30,
                                  child: TextField(
                                    enabled:
                                        (isPresetTare == false) ? false : true,
                                    controller: preTare,
                                    maxLength: 20,
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
                                      if (kDebugMode) {
                                        print(value);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(height: 5),
                                const Text("PLu Remarks:"),
                                SizedBox(
                                  width: 400,
                                  height: 120,
                                  child: TextField(
                                    controller: productRemark,
                                    maxLength: 300,
                                    maxLengthEnforcement:
                                        MaxLengthEnforcement.enforced,
                                    maxLines: 10,
                                    textAlignVertical: TextAlignVertical.top,
                                    decoration: const InputDecoration(
                                      counterText: "",
                                      // hintText: "请输入机种类型，如：ztp",
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      errorText.text = '';
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
                                      errorText.text = '';
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
                        getProductList();
                        addProductRec();
                        getProductList();
                        // Navigator.of(context).pop(connectionType);
                      }),
                  const SizedBox(width: 20),
                  OutlinedButton(
                      child: const Text("Edit"),
                      onPressed: () {
                        errorText.text = '';
                        getProductList();
                        getProductList();
                        editProductRec();
                        getProductList();
                        // Navigator.of(context).pop(connectionType);
                      }),
                  const SizedBox(width: 20),
                  OutlinedButton(
                      child: const Text("Delete"),
                      onPressed: () {
                        if (productID.text.isNotEmpty ||
                            productName.text.isNotEmpty) {
                          errorText.text = '';
                          getProductList();
                          getProductList();
                          delProductRec();
                          getProductList();
                        } else {
                          errorText.text =
                              'Product ID or product name cannot be empty';
                        }

                        // Navigator.of(context).pop(connectionType);
                      }),
                  const SizedBox(width: 20),
                  OutlinedButton(
                      child: const Text("Exit"),
                      onPressed: () {
                        getProductList();
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

void getProductList() {
  myScaleCmd.cmdMode = "get_product_list";
  myScaleCmd.cmdData = "";
  MyApp.webchannel.sendMessage(jsonEncode(myScaleCmd));
}

void addProductRec() {
  bool result = true;
  if (productID.text.isEmpty || productName.text.isEmpty) {
    errorText.text = "Product ID or product name cannot be empty";
    return;
  }
  if (isPresetTare!) {
    if (preTare.text.isEmpty) {
      errorText.text = "Product ID or product name cannot be empty";
      return;
    }
  }
  if (myProductRecList.productRecInfo!.isNotEmpty) {
    String? name;
    String? id;
    for (var i = 0; i < myProductRecList.productRecInfo!.length; i++) {
      name = myProductRecList.productRecInfo![i].product;
      id = myProductRecList.productRecInfo![i].id;
      name ??= "";
      id ??= "";
      if (name == productName.text || id == productID.text) {
        errorText.text = "Product ID or product name already exists";
        return;
      }
    }
  }
  if (result) {
    myProductRec.id = productID.text;
    myProductRec.product = productName.text;
    myProductRec.withPretare = isPresetTare!;
    myProductRec.remarks = productRemark.text;
    myProductRec.pretare = preTare.text;
    myScaleCmd.cmdMode = "add_product";
    myScaleCmd.cmdData = jsonEncode(myProductRec);
    MyApp.webchannel.sendMessage(jsonEncode(myScaleCmd));
    if (kDebugMode) {
      print(jsonEncode(myScaleCmd));
    }
    errorText.text = "Success!";

    productID.text = '';
    productName.text = '';
    productRemark.text = '';
    preTare.text = '';
  }
}

void editProductRec() {
  if (productID.text.isEmpty || productName.text.isEmpty) {
    errorText.text = "Product ID or product name cannot be empty";
    return;
  }
  if (isPresetTare!) {
    if (preTare.text.isEmpty) {
      errorText.text = "Product ID or product name cannot be empty";
      return;
    }
  }
  if (myProductRecList.productRecInfo!.isNotEmpty) {
    String? name;
    String? id;
    int recid = 0;
    bool isFind = false;
    for (var i = 0; i < myProductRecList.productRecInfo!.length; i++) {
      name = myProductRecList.productRecInfo![i].product;
      id = myProductRecList.productRecInfo![i].id;
      name ??= "";
      id ??= "";
      if (name == productName.text || id == productID.text) {
        recid = myProductRecList.productRecInfo![i].recId!;
        isFind = true;
        break;
      }
    }
    if (isFind && recid != 0) {
      myProductRecEdit.recId = recid;
      myProductRecEdit.id = productID.text;
      myProductRecEdit.product = productName.text;
      myProductRecEdit.withPretare = isPresetTare!;
      myProductRecEdit.remarks = productRemark.text;
      myProductRecEdit.pretare = preTare.text;
      myScaleCmd.cmdMode = "modify_product";
      myScaleCmd.cmdData = jsonEncode(myProductRecEdit);
      MyApp.webchannel.sendMessage(jsonEncode(myScaleCmd));
      if (kDebugMode) {
        print(jsonEncode(myScaleCmd));
      }
      errorText.text = "Success!";
    } else {
      errorText.text = "Record was not found";
    }
  }
}

void delProductRec() {
  if (productID.text.isEmpty || productName.text.isEmpty) {
    errorText.text = "Product ID or product name cannot be empty";
    return;
  }
  if (myProductRecList.productRecInfo!.isNotEmpty) {
    String? name;
    String? id;
    int recid = 0;
    bool isFind = false;
    for (var i = 0; i < myProductRecList.productRecInfo!.length; i++) {
      name = myProductRecList.productRecInfo![i].product;
      id = myProductRecList.productRecInfo![i].id;
      name ??= "";
      id ??= "";
      if (name == productName.text || id == productID.text) {
        recid = myProductRecList.productRecInfo![i].recId!;
        isFind = true;
        break;
      }
    }
    if (isFind && recid != 0) {
      myProductRecDel.recId = recid;

      myScaleCmd.cmdMode = "del_product";
      myScaleCmd.cmdData = jsonEncode(myProductRecDel);
      MyApp.webchannel.sendMessage(jsonEncode(myScaleCmd));
      if (kDebugMode) {
        print(jsonEncode(myScaleCmd));
      }
      if (recid == myProductRecInfo.recId) {
        myProductRecInfo.id = "";
        myProductRecInfo.product = "";
        myProductRecInfo.pretare = "";
        myProductRecInfo.remarks = "";
        eventBus.fire(EventProductRecInfo(myProductRecInfo));
      }
      errorText.text = "Success!";
      productID.text = "";
      productName.text = "";
      productName.text = "";
      isPresetTare = false;
      preTare.text = '';
      productRemark.text = '';
    } else {
      errorText.text = "Record was not found";
    }
  }
}
