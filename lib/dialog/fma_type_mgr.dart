// 配方类别管理弹框
import 'package:flutter/material.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/req_formula_data.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/widget/common_widget.dart';
import 'package:t_max/widget/dialog_head_style.dart';

//// 定义新增原料类型弹框组件
class FmaTypeMgrDialog extends StatefulWidget {
  const FmaTypeMgrDialog({super.key});
  @override
  FmaTypeMgrDialogState createState() => FmaTypeMgrDialogState();
}

class FmaTypeMgrDialogState extends State<FmaTypeMgrDialog> {
  TextEditingController fmaTypeCtl = TextEditingController();
  var searchFmaTypeCtl = TextEditingController();
  List<CategoryTypeList> searchFmaTypeList = [];

  dynamic _eventbus1;
  dynamic _eventbus2;

  // 显示新增配方类型对话框
  void showAddFormulaTypeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 点击对话框外部不关闭对话框
      builder: (BuildContext context) {
        return AddFormulaTypeDialog();
      },
    );
  }

  // 显示新增配方原料类型对话框
  void showEditFmaTypeDialog(CategoryTypeList categoryTypeInfo) {
    showDialog(
      context: context,
      barrierDismissible: false, // 点击对话框外部不关闭对话框
      builder: (BuildContext context) {
        return EditFormulaTypeDialog(categoryTypeInfo: categoryTypeInfo);
      },
    ).then((value) {
      setState(() {});
    });
  }

  void performSearch(String keyword) {
    searchFmaTypeList = formulaTypeList.where((fmaType) {
      final typeName = fmaType.categoryName.toLowerCase();
      return fmaType.categoryId != 0 && typeName.contains(keyword);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    performSearch('');
    _eventbus1 = eventBus.on<EventRespGetFormulaTypeList>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '') {
          setState(() {
            formulaTypeList = categoryTypeListFromJson(dataStr);
            performSearch('');
            searchFmaTypeCtl.clear();
          });
        } else {
          setState(() {
            formulaTypeList = [];
            performSearch('');
            searchFmaTypeCtl.clear();
          });
        }
      }
    });

    _eventbus2 = eventBus.on<EventRespAddFormulaType>().listen((event) {
      if (mounted) {
        PublicFunctions.getFormulaTypeList();
        showTipInfo(localizedStrings.fAddSuccessMsg, context);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _eventbus1.cancel();
    _eventbus2.cancel();
    searchFmaTypeCtl.dispose();
    fmaTypeCtl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 610,
        height: 590,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          children: [
            // 头部
            ...dialogHeadStyle(
              context,
              localizedStrings.fRawCategoryManagement,
              true,
              onClose: () {
                PublicFunctions.getFormulaTypeList(); // 刷新类型列表
                formulaDataList.clear();
                PublicFunctions.getFormulaList(); // 刷新配方类型列表
                Navigator.pop(context);
              },
            ),
            // 中部
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(
                    left: largePadding,
                    right: largePadding,
                    bottom: largePadding * 2),
                height: 150,
                // width: 500,
                child: Column(children: [
                  Container(
                    height: 68,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                              height: btnHeight,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: TextField(
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                    controller: searchFmaTypeCtl,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.search,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: const Icon(
                                          Icons.clear,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            searchFmaTypeCtl.clear();
                                            performSearch('');
                                          });
                                        },
                                      ),
                                      hintText: localizedStrings.fSearchHint,
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 10),
                                      hintStyle: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            // 设置提示文本样式
                                            fontSize: 12,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest,
                                          ),
                                      border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.zero,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        // 这里可以添加搜索逻辑

                                        performSearch(value);
                                      });
                                    }),
                              )),
                        ),
                        SizedBox(
                          width: largePadding,
                        ),
                        showTextButton(
                          context,
                          btnHeight,
                          localizedStrings.gBtnAdd,
                          () {
                            showAddFormulaTypeDialog();
                          },
                          Theme.of(context).colorScheme.onPrimary,
                          Theme.of(context).colorScheme.onTertiaryFixedVariant,
                          Theme.of(context).colorScheme.onPrimary,
                        )
                      ],
                    ),
                  ), //搜索框
                  Container(
                    height: 42,
                    color: Theme.of(context).colorScheme.surfaceDim,
                    padding: const EdgeInsets.symmetric(
                      horizontal: regularPadding,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(
                          localizedStrings.fRawMaterialTypeNameCol,
                          style: Theme.of(context).textTheme.bodySmall!.apply(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                          overflow: TextOverflow.ellipsis,
                        )),
                        SizedBox(
                            width: 80,
                            child: Text(localizedStrings.fTipOperation,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .apply(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                overflow: TextOverflow.ellipsis))
                      ],
                    ),
                  ),

                  searchFmaTypeList.isEmpty
                      ? Expanded(
                          child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            localizedStrings.fTipNoData,
                            style: Theme.of(context).textTheme.bodySmall!.apply(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                        ))
                      : Expanded(
                          child: ListView.builder(
                            itemCount: searchFmaTypeList.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: regularPadding,
                                        vertical: 0),
                                    // minVerticalPadding: 2,
                                    title: Text(
                                      searchFmaTypeList[index].categoryName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .apply(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                    ),
                                    trailing: SizedBox(
                                      width: 80,
                                      child: Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.edit_outlined,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                showEditFmaTypeDialog(
                                                    searchFmaTypeList[index]);
                                              });
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.delete_forever_outlined,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                            ),
                                            onPressed: () {
                                              //删除原料前，先判断是否有原料使用了这个类型
                                              for (var fma in formulaDataList) {
                                                if (fma.header!
                                                        .formulaCategoryName ==
                                                    searchFmaTypeList[index]
                                                        .categoryName) {
                                                  showTipInfo(
                                                      localizedStrings
                                                          .fFormulaInUseDeleteErrorMsg,
                                                      context);
                                                  return;
                                                }
                                              }

                                              setState(() {
                                                PublicFunctions.deleteFmaType(
                                                    searchFmaTypeList[index]
                                                        .categoryName);
                                              });
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  //添加分割线
                                  Divider(
                                    height: 1,
                                    thickness: 1,
                                    indent: 0,
                                    endIndent: 0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceDim,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 定义新增配方类型弹框组件
class AddFormulaTypeDialog extends StatefulWidget {
  const AddFormulaTypeDialog({super.key});
  @override
  AddFormulaTypeDialogState createState() => AddFormulaTypeDialogState();
}

class AddFormulaTypeDialogState extends State<AddFormulaTypeDialog> {
  TextEditingController formulaTypeCtl = TextEditingController();

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
            ...dialogHeadStyle(
              context,
              localizedStrings.fAddTypeBtn,
              true,
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
                            localizedStrings.fFmaCategoryCol,
                            style: Theme.of(context).textTheme.bodySmall!.apply(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ]),
                  ),
                  SizedBox(
                    child: Row(children: [
                      Expanded(
                        child: Container(
                            alignment: Alignment.centerLeft,
                            child: TextField(
                              onChanged: (value) {
                                setState(() {});
                              },
                              controller: formulaTypeCtl,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(0.0))),
                                hintText:
                                    localizedStrings.fInputFormulaTypeHint,
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
                                    formulaTypeCtl.clear(); // 清空文本
                                    setState(() {});
                                  },
                                ),
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .apply(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
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
                      onPressed: formulaTypeCtl.text.isEmpty
                          ? null
                          : () {
                              for (var item in formulaTypeList) {
                                if (item.categoryName == formulaTypeCtl.text) {
                                  showTipInfo(
                                      localizedStrings.fTypeExistsMsg, context);
                                  return;
                                }
                              }
                              PublicFunctions.addFormulaType(
                                  formulaTypeCtl.text);
                              Navigator.pop(context);
                            },
                      child: Text(
                        localizedStrings.gBtnConfirm,
                        style: Theme.of(context).textTheme.bodyMedium!.apply(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                        overflow: TextOverflow.ellipsis,
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
                        style: Theme.of(context).textTheme.bodyMedium!.apply(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                        overflow: TextOverflow.ellipsis,
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

// 定义编辑配方类型弹框组件
class EditFormulaTypeDialog extends StatefulWidget {
  final CategoryTypeList categoryTypeInfo;
  const EditFormulaTypeDialog({super.key, required this.categoryTypeInfo});
  @override
  EditFormulaTypeDialogState createState() => EditFormulaTypeDialogState();
}

class EditFormulaTypeDialogState extends State<EditFormulaTypeDialog> {
  TextEditingController formulaTypeCtl = TextEditingController();

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
            ...dialogHeadStyle(
              context,
              localizedStrings.fEditFormulaTypeBtn,
              true,
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
                            localizedStrings.fFmaCategoryCol,
                            style: Theme.of(context).textTheme.bodySmall!.apply(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ]),
                  ),
                  SizedBox(
                    child: Row(children: [
                      Expanded(
                        child: Container(
                            alignment: Alignment.centerLeft,
                            child: TextField(
                              onChanged: (value) {
                                setState(() {});
                              },
                              controller: formulaTypeCtl,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(0.0))),
                                hintText:
                                    localizedStrings.fInputFormulaTypeHint,
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
                                    formulaTypeCtl.clear(); // 清空文本
                                    setState(() {});
                                  },
                                ),
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .apply(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
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
                      onPressed: formulaTypeCtl.text.isEmpty
                          ? null
                          : () {
                              for (var item in formulaTypeList) {
                                if (item.categoryName == formulaTypeCtl.text) {
                                  showTipInfo(
                                      localizedStrings.fTypeExistsMsg, context);
                                  return;
                                }
                              }
                              PublicFunctions.editFmaType(formulaTypeCtl.text,
                                  widget.categoryTypeInfo.categoryId);
                              Navigator.pop(context);
                            },
                      child: Text(
                        localizedStrings.gBtnConfirm,
                        style: Theme.of(context).textTheme.bodyMedium!.apply(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                        overflow: TextOverflow.ellipsis,
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
                        style: Theme.of(context).textTheme.bodyMedium!.apply(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                        overflow: TextOverflow.ellipsis,
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
