import 'package:flutter/material.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/formula_scale_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/req_formula_data.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';

////添加原料信息
///
///// 定义新增原料弹框组件
///
int getRawTypeId(String name) {
  for (var item in rawTypeList) {
    if (item.categoryName == name) {
      return item.categoryId;
    }
  }
  return -1;
}

class AddRawDialog extends StatefulWidget {
  const AddRawDialog({super.key});
  @override
  AddRawDialogState createState() => AddRawDialogState();
}

class AddRawDialogState extends State<AddRawDialog> {
  TextEditingController rawCodeCtl = TextEditingController();
  TextEditingController rawNameCtl = TextEditingController();
  TextEditingController rawRemarkCtl = TextEditingController();
  TextEditingController rawTypeCtl = TextEditingController();
  dynamic _eventbus1;

  @override
  void initState() {
    _eventbus1 = eventBus.on<EventRespGetRawTypeList>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '') {
          setState(() {
            rawTypeList = categoryTypeListFromJson(dataStr);
          });
        } else {
          setState(() {
            rawTypeList = [];
          });
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _eventbus1.cancel();
    rawCodeCtl.dispose();
    rawNameCtl.dispose();
    rawRemarkCtl.dispose();
    rawTypeCtl.dispose();

    super.dispose();
  }

  showTypeDropDownButton(String hintText, TextEditingController valueCtl) {
    return Container(
        height: 48,
        padding: const EdgeInsets.only(left: 5, right: 10),
        decoration: BoxDecoration(
          border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant), // 设置边框颜色
          borderRadius: BorderRadius.circular(0), // 设置圆角
        ),
        child: DropdownButton(
          underline: SizedBox(),
          isExpanded: true,
          value: rawTypeCtl.text == "" ? null : rawTypeCtl.text,
          items: rawTypeList.isEmpty
              ? [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text(localizedStrings.fPleaseSelectCategory),
                  )
                ]
              : [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text(localizedStrings.fPleaseSelectCategory),
                  ),
                  ...rawTypeList.map((CategoryTypeList item) {
                    return DropdownMenuItem<String>(
                      value: item.categoryName,
                      child: Text(item.categoryName),
                    );
                  })
                ],
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              rawTypeCtl.text = value.toString();
            });
          },
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        ));
  }

  // 显示新增配方类型对话框
  void showAddRawTypeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 点击对话框外部不关闭对话框
      builder: (BuildContext context) {
        return AddRawTypeDialog();
      },
    ).then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 610,
        height: 493,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          children: [
            // 头部
            Container(
                height: 54,
                padding: const EdgeInsets.only(left: 20, right: 20),
                alignment: Alignment.centerLeft,
                child: Row(children: [
                  Container(
                    width: 3,
                    height: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        localizedStrings.fAddRawMaterialBtn,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                      icon: Icon(
                        Icons.cancel,
                        size: 24,
                        color: Theme.of(context).colorScheme.secondaryFixed,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      })
                ])),
            // 分割线
            Divider(
              height: 1,
              color: Theme.of(context).colorScheme.outline,
            ),
            // 中部
            Expanded(
                child: Column(children: [
              SizedBox(
                // padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                height: 90,
                width: 582,
                child: Row(children: [
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
                                  localizedStrings.fMaterialIdCol,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ]),
                        ),
                        SizedBox(
                          height: 48,
                          child: Row(children: [
                            Expanded(
                              child: Container(
                                  alignment: Alignment.centerLeft,
                                  child: TextField(
                                    controller: rawCodeCtl,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(0.0))),
                                      hintText: localizedStrings
                                          .fInputRawMaterialIdHint,
                                      suffixIconConstraints:
                                          BoxConstraints.tight(Size(40, 40)),
                                    ),
                                    onChanged: (value) {
                                      // 处理输入变化事件
                                      // print('Input changed: $value');
                                      setState(() {});
                                    },
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      overflow: TextOverflow.ellipsis,
                                    ),
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
                                  localizedStrings.fMaterialNameCol,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ]),
                        ),
                        SizedBox(
                          height: 48,
                          child: Row(children: [
                            Expanded(
                              child: Container(
                                  alignment: Alignment.centerLeft,
                                  child: TextField(
                                    controller: rawNameCtl,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(0.0))),
                                      hintText: localizedStrings
                                          .fInputRawMaterialNameHint,
                                      suffixIconConstraints:
                                          BoxConstraints.tight(Size(40, 40)),
                                    ),
                                    onChanged: (value) {
                                      // 处理输入变化事件
                                      // print('Input changed: $value');
                                      setState(() {});
                                    },
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )),
                            ),
                          ]),
                        ),
                      ])),
                  SizedBox(
                    width: 20,
                  ),
                ]),
              ),
              SizedBox(
                height: 90,
                width: 582,
                child: Row(children: [
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
                                  localizedStrings.fFmaCategoryCol,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ]),
                        ),
                        showTypeDropDownButton(
                            localizedStrings.fPleaseSelectCategory, rawTypeCtl),
                      ])),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      flex: 1,
                      child: Column(children: [
                        Container(
                          height: 42,
                        ),
                        SizedBox(
                          height: 48,
                          child: Row(children: [
                            Tooltip(
                              message: localizedStrings.fAddTypeBtn, // 提示信息
                              child: IconButton(
                                iconSize: 24,
                                color: Theme.of(context).colorScheme.onPrimary,
                                style: IconButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.surface,
                                  focusColor: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.1),
                                  shape: RoundedRectangleBorder(
                                      // 设置为矩形形状
                                      borderRadius:
                                          BorderRadius.zero, // 没有圆角，即正方形
                                      side: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline, // 设置边框颜色
                                        width: 1, // 设置边框宽度
                                      )),
                                  fixedSize: const Size(48, 48), // 设置固定大小
                                ),
                                onPressed: () {
                                  showAddRawTypeDialog();
                                },
                                icon: Icon(
                                  Icons.add,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            Spacer(),
                          ]),
                        ),
                      ])),
                  SizedBox(
                    width: 20,
                  ),
                ]),
              ),
              SizedBox(
                height: 116,
                width: 582,
                child: Row(children: [
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
                                  localizedStrings.fIngredientRemark,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ]),
                        ),
                        SizedBox(
                          height: 74,
                          child: Row(children: [
                            Expanded(
                              child: Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline, // 设置边框颜色
                                      width: 1, // 设置边框宽度
                                    ),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  child: TextField(
                                    controller: rawRemarkCtl,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: localizedStrings
                                          .fInputIngredientDescHint,
                                      suffixIconConstraints:
                                          BoxConstraints.tight(Size(40, 40)),
                                    ),
                                    maxLines: 3,
                                    onChanged: (value) {
                                      // 处理输入变化事件
                                      // print('Input changed: $value');
                                      setState(() {});
                                    },
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )),
                            ),
                          ]),
                        ),
                      ])),
                  SizedBox(
                    width: 20,
                  ),
                ]),
              ),
            ])),

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
                      onPressed: (rawCodeCtl.text.isEmpty ||
                              rawNameCtl.text.isEmpty ||
                              rawTypeCtl.text.isEmpty)
                          ? null
                          : () {
                              // 检查原料是否已经存在
                              for (var item in rawDataList) {
                                if (item.rawMaterial.materialName ==
                                    rawNameCtl.text) {
                                  showTipInfo(localizedStrings.fRawIdDuplicate,
                                      context);
                                  return;
                                }
                                if (item.rawMaterial.materialId ==
                                    rawCodeCtl.text) {
                                  showTipInfo(
                                      localizedStrings.fRawNameDuplicate,
                                      context);
                                  return;
                                }
                              }

                              int typeId = getRawTypeId(rawTypeCtl.text);
                              if (typeId == -1) {
                                return;
                              }
                              AddRawData data = AddRawData(
                                materialId: rawCodeCtl.text,
                                materialName: rawNameCtl.text,
                                categoryId: typeId,
                                ingredient: rawRemarkCtl.text,
                                createdBy: "admin",
                                updatedBy: "admin",
                                remark: "",
                                remark1: "",
                              );
                              PublicFunctions.addRawData(data);
                              Navigator.pop(context);
                            },
                      child: Text(
                        localizedStrings.gBtnConfirm,
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
                        localizedStrings.gBtnCancel,
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
}

//// 定义新增原料类型弹框组件
class AddRawTypeDialog extends StatefulWidget {
  const AddRawTypeDialog({super.key});
  @override
  AddRawTypeDialogState createState() => AddRawTypeDialogState();
}

class AddRawTypeDialogState extends State<AddRawTypeDialog> {
  TextEditingController rawTypeCtl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
            Container(
                height: 54,
                padding: const EdgeInsets.only(left: 20, right: 20),
                alignment: Alignment.centerLeft,
                child: Row(children: [
                  Container(
                    width: 3,
                    height: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        localizedStrings.fAddRawMaterialTypeBtn,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                      icon: Icon(
                        Icons.cancel,
                        size: 24,
                        color: Theme.of(context).colorScheme.secondaryFixed,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      })
                ])),
            // 分割线
            Divider(
              height: 1,
              color: Theme.of(context).colorScheme.outline,
            ),
            // 中部
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(26),
                height: 150,
                width: 500,
                child: Column(children: [
                  SizedBox(
                    height: 42,
                    child: Row(children: [
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            localizedStrings.fRawMaterialTypeCol,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                  SizedBox(
                    // height: 48,

                    child: Row(children: [
                      Expanded(
                        child: Container(
                            padding: const EdgeInsets.only(left: 16, right: 20),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline, // 设置边框颜色
                                width: 1, // 设置边框宽度
                              ),
                            ),
                            alignment: Alignment.centerLeft,
                            child: TextField(
                              controller: rawTypeCtl,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText:
                                    localizedStrings.fInputRawMaterialTypeHint,
                                suffixIconConstraints:
                                    BoxConstraints.tight(Size(40, 40)),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                  onPressed: () {
                                    rawTypeCtl.clear(); // 清空文本
                                  },
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 5,
                              minLines: 1,
                            )),
                      ),
                    ]),
                  ),
                ]),
              ),
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
                      onPressed: () {
                        // 检查原料类型是否已经存在
                        for (var item in rawTypeList) {
                          if (item.categoryName == rawTypeCtl.text) {
                            showTipInfo(
                                localizedStrings.fTypeExistsMsg, context);
                            return;
                          }
                        }
                        PublicFunctions.addRawType(rawTypeCtl.text);
                        Navigator.pop(context);
                      },
                      child: Text(
                        localizedStrings.gBtnConfirm,
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
                        localizedStrings.gBtnCancel,
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
}

class EditRawDialog extends StatefulWidget {
  const EditRawDialog({super.key, required this.rawData});
  final RawDataInfo rawData;
  @override
  EditRawDialogState createState() => EditRawDialogState();
}

class EditRawDialogState extends State<EditRawDialog> {
  TextEditingController rawCodeCtl = TextEditingController();
  TextEditingController rawNameCtl = TextEditingController();
  TextEditingController rawRemarkCtl = TextEditingController();
  TextEditingController rawTypeCtl = TextEditingController();
  dynamic _eventbus1;

  @override
  void initState() {
    super.initState();
    rawCodeCtl.text = widget.rawData.rawMaterial.materialId;
    rawNameCtl.text = widget.rawData.rawMaterial.materialName;
    rawRemarkCtl.text = widget.rawData.rawMaterial.ingredient;
    rawTypeCtl.text = widget.rawData.rawCategoryName;
    _eventbus1 = eventBus.on<EventRespGetRawTypeList>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '') {
          setState(() {
            rawTypeList = categoryTypeListFromJson(dataStr);
          });
        } else {
          setState(() {
            rawTypeList = [];
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _eventbus1.cancel();
    rawCodeCtl.dispose();
    rawNameCtl.dispose();
    rawRemarkCtl.dispose();
    rawTypeCtl.dispose();

    super.dispose();
  }

  showTypeDropDownButton(String hintText, TextEditingController valueCtl) {
    return Container(
        height: 48,
        padding: const EdgeInsets.only(left: 5, right: 10),
        decoration: BoxDecoration(
          border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant), // 设置边框颜色
          borderRadius: BorderRadius.circular(0), // 设置圆角
        ),
        child: DropdownButton(
          underline: SizedBox(),
          isExpanded: true,
          value: rawTypeCtl.text == "" ? null : rawTypeCtl.text,
          items: rawTypeList.isEmpty
              ? [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text(localizedStrings.fPleaseSelectCategory),
                  )
                ]
              : [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text(localizedStrings.fPleaseSelectCategory),
                  ),
                  ...rawTypeList.map((CategoryTypeList item) {
                    return DropdownMenuItem<String>(
                      value: item.categoryName,
                      child: Text(item.categoryName),
                    );
                  })
                ],
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              rawTypeCtl.text = value.toString();
            });
          },
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        ));
  }

  // 显示新增配方类型对话框
  void showAddRawTypeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 点击对话框外部不关闭对话框
      builder: (BuildContext context) {
        return AddRawTypeDialog();
      },
    ).then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 610,
        height: 493,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          children: [
            // 头部
            Container(
                height: 54,
                padding: const EdgeInsets.only(left: 20, right: 20),
                alignment: Alignment.centerLeft,
                child: Row(children: [
                  Container(
                    width: 3,
                    height: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        localizedStrings.fEditMaterial,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                      icon: Icon(
                        Icons.cancel,
                        size: 24,
                        color: Theme.of(context).colorScheme.secondaryFixed,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      })
                ])),
            // 分割线
            Divider(
              height: 1,
              color: Theme.of(context).colorScheme.outline,
            ),
            // 中部
            Expanded(
                child: Column(children: [
              SizedBox(
                // padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                height: 90,
                width: 582,
                child: Row(children: [
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
                                  localizedStrings.fMaterialIdCol,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ]),
                        ),
                        SizedBox(
                          height: 48,
                          child: Row(children: [
                            Expanded(
                              child: Container(
                                  padding:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline, // 设置边框颜色
                                      width: 1, // 设置边框宽度
                                    ),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  child: TextField(
                                    enabled: false,
                                    controller: rawCodeCtl,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: localizedStrings
                                          .fInputRawMaterialIdHint,
                                      suffixIconConstraints:
                                          BoxConstraints.tight(Size(40, 40)),
                                    ),
                                    onChanged: (value) {
                                      // 处理输入变化事件
                                      // print('Input changed: $value');
                                      setState(() {});
                                    },
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      overflow: TextOverflow.ellipsis,
                                    ),
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
                                  localizedStrings.fMaterialNameCol,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ]),
                        ),
                        SizedBox(
                          height: 48,
                          child: Row(children: [
                            Expanded(
                              child: Container(
                                  padding:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline, // 设置边框颜色
                                      width: 1, // 设置边框宽度
                                    ),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  child: TextField(
                                    controller: rawNameCtl,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: localizedStrings
                                          .fInputRawMaterialNameHint,
                                      suffixIconConstraints:
                                          BoxConstraints.tight(Size(40, 40)),
                                    ),
                                    onChanged: (value) {
                                      // 处理输入变化事件
                                      // print('Input changed: $value');
                                      setState(() {});
                                    },
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )),
                            ),
                          ]),
                        ),
                      ])),
                  SizedBox(
                    width: 20,
                  ),
                ]),
              ),
              SizedBox(
                height: 90,
                width: 582,
                child: Row(children: [
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
                                  localizedStrings.fFmaCategoryCol,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ]),
                        ),
                        showTypeDropDownButton(
                            localizedStrings.fPleaseSelectCategory, rawTypeCtl),
                      ])),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      flex: 1,
                      child: Column(children: [
                        Container(
                          height: 42,
                        ),
                        SizedBox(
                          height: 48,
                          child: Row(children: [
                            Tooltip(
                              message: localizedStrings.fAddTypeBtn, // 提示信息
                              child: IconButton(
                                iconSize: 24,
                                color: Theme.of(context).colorScheme.onPrimary,
                                style: IconButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.surface,
                                  focusColor: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.1),
                                  shape: RoundedRectangleBorder(
                                      // 设置为矩形形状
                                      borderRadius:
                                          BorderRadius.zero, // 没有圆角，即正方形
                                      side: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline, // 设置边框颜色
                                        width: 1, // 设置边框宽度
                                      )),
                                  fixedSize: const Size(48, 48), // 设置固定大小
                                ),
                                onPressed: () {
                                  showAddRawTypeDialog();
                                },
                                icon: Icon(
                                  Icons.add,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            Spacer(),
                          ]),
                        ),
                      ])),
                  SizedBox(
                    width: 20,
                  ),
                ]),
              ),
              SizedBox(
                height: 116,
                width: 582,
                child: Row(children: [
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
                                  localizedStrings.fIngredientRemark,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ]),
                        ),
                        SizedBox(
                          height: 74,
                          child: Row(children: [
                            Expanded(
                              child: Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline, // 设置边框颜色
                                      width: 1, // 设置边框宽度
                                    ),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  child: TextField(
                                    controller: rawRemarkCtl,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: localizedStrings
                                          .fInputIngredientDescHint,
                                      suffixIconConstraints:
                                          BoxConstraints.tight(Size(40, 40)),
                                    ),
                                    maxLines: 3,
                                    onChanged: (value) {
                                      // 处理输入变化事件
                                      // print('Input changed: $value');
                                      setState(() {});
                                    },
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )),
                            ),
                          ]),
                        ),
                      ])),
                  SizedBox(
                    width: 20,
                  ),
                ]),
              ),
            ])),

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
                      onPressed: (rawCodeCtl.text.isEmpty ||
                              rawNameCtl.text.isEmpty ||
                              rawTypeCtl.text.isEmpty)
                          ? null
                          : () {
                              int typeId = getRawTypeId(rawTypeCtl.text);
                              if (typeId == -1) {
                                return;
                              }
                              EditRawData data = EditRawData(
                                recId: widget.rawData.rawMaterial.recId,
                                materialId: rawCodeCtl.text,
                                materialName: rawNameCtl.text,
                                categoryId: typeId,
                                ingredient: rawRemarkCtl.text,
                                createdBy: "admin",
                                updatedBy: "admin",
                                remark: "",
                                remark1: "",
                              );
                              PublicFunctions.editRawData(data);
                              Navigator.pop(context);
                            },
                      child: Text(
                        localizedStrings.gBtnConfirm,
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
                        localizedStrings.gBtnCancel,
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
}
