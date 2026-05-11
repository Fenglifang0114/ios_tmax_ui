import 'package:flutter/material.dart';
import 'package:t_max/data/formula_from_db_data.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';

import 'package:t_max/widget/dialog_head_style.dart';

class SearchFmaBarcodeDialog extends StatefulWidget {
  const SearchFmaBarcodeDialog({super.key});
  @override
  State<SearchFmaBarcodeDialog> createState() => _SearchFmaBarcodeDialogState();
}

class _SearchFmaBarcodeDialogState extends State<SearchFmaBarcodeDialog> {
  final TextEditingController fmaBarcodeCtl = TextEditingController();

  FocusNode checkCodeFocusNode = FocusNode();

  String errString = '';
  dynamic _eventbus1;

  @override
  void initState() {
    super.initState();

    // 在下一帧请求焦点，确保组件已构建完成
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkCodeFocusNode.requestFocus();
    });

    _eventbus1 = eventBus.on<EventRespFormulasListByBarcode>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '' && dataStr != 'null') {
          try {
            List<FormulaInfoDb> tempFmaDataList =
                formulaInfoDbFromJson(dataStr);
            if (tempFmaDataList.isNotEmpty) {
              Navigator.of(context).pop(tempFmaDataList[0]);
            }
          } catch (e) {
            setState(() {
              errString = (localizedStrings?.fNoFmaFound ?? "fNoFmaFound");
              checkCodeFocusNode.requestFocus();
              fmaBarcodeCtl.text = '';
            });
          }
        } else {
          setState(() {
            errString = (localizedStrings?.fNoFmaFound ?? "fNoFmaFound");
            checkCodeFocusNode.requestFocus();
            fmaBarcodeCtl.text = '';
          });
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    fmaBarcodeCtl.dispose();
    checkCodeFocusNode.dispose();
    _eventbus1?.cancel();
  }

  bool searchFmaBarcode(String barcode) {
    if (barcode.isEmpty) {
      return false;
    }
    // 搜索配方
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 500,
        height: 350,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          children: [
            // 头部
            ...dialogHeadStyle(
              context,
              (localizedStrings?.fFmaBarcode ?? "fFmaBarcode"),
              true,
              onClose: () {
                Navigator.of(context).pop();
              },
            ),
            // 中部
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(
                    left: largePadding,
                    right: largePadding,
                    bottom: largePadding * 2),
                child: Column(children: [
                  Container(
                    height: 40,
                    alignment: Alignment.centerLeft,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: 300,
                          height: inputHeight,
                          child: TextFormField(
                            focusNode: checkCodeFocusNode,
                            controller: fmaBarcodeCtl,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(0.0)),
                              ),
                              hintText: (localizedStrings?.fFmaBarcode ?? "fFmaBarcode"),
                              hintStyle: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                            style: Theme.of(context).textTheme.bodySmall!.apply(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                            onChanged: (value) {
                              setState(() {
                                errString = '';
                              });
                            },
                            onFieldSubmitted: (value) {
                              PublicFunctions.getFmaByBarcode(value);
                            },
                          ),
                        )
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          width: 300,
                          height: inputHeight,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            errString,
                            style: Theme.of(context).textTheme.bodySmall!.apply(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          ),
                        )
                      ]),
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
                      onPressed: fmaBarcodeCtl.text.isEmpty
                          ? null
                          : () {
                              PublicFunctions.getFmaByBarcode(
                                  fmaBarcodeCtl.text);
                            },
                      child: Text(
                        (localizedStrings?.gBtnConfirm ?? "gBtnConfirm"),
                        style: Theme.of(context).textTheme.bodySmall!.apply(
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
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        (localizedStrings?.gBtnCancel ?? "gBtnCancel"),
                        style: Theme.of(context).textTheme.bodySmall!.apply(
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
