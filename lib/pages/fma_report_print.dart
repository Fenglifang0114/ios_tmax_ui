import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:t_max/data/fma_rec_list_db_data.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/widget/dialog_head_style.dart';
import 'package:win32/win32.dart';

class FormulaReportPrint extends StatefulWidget {
  const FormulaReportPrint({super.key, required this.fmaData});
  final FmaRecFromDb fmaData;

  @override
  State<FormulaReportPrint> createState() => _FormulaReportPrintState();
}

class _FormulaReportPrintState extends State<FormulaReportPrint> {
  final GlobalKey boundaryKey = GlobalKey();
  Uint8List _imageBytes = Uint8List(0);

  double _contentWidth = 850;
  double _contentHeight = 300;
  String _operatorName = '';
  String _createTime = '';
  String _fmaTotalWgt = '';
  String _fmaActualWgt = '';
  String _id = '';
  String _orderNo = '';
  List<PrintField> fields = [];
  List<TableRowData> tableRows = [];

  bool showName = true;
  bool showId = true;
  bool showError = true;
  bool showPass = true;
  bool showWeight = true;
  bool showDeviceName = true;

  bool showFmaActualWgt = true;
  bool showFmaName = false;

  @override
  void initState() {
    super.initState();
    _operatorName = widget.fmaData.header!.headerOperator ?? '';
    _createTime = DateFormat('yyyy-MM-dd HH:mm:ss')
        .format(widget.fmaData.header!.recordSaveTime!);
    _fmaTotalWgt =
        "${widget.fmaData.header!.actualFmaTotalWgt} ${widget.fmaData.header!.totalWeightUnit}";
    _fmaActualWgt =
        "${widget.fmaData.header!.actualTotalWeight} ${widget.fmaData.header!.totalWeightUnit}";
    _id = widget.fmaData.header!.formulaId.toString();
    _orderNo = widget.fmaData.header!.recordId.toString();
    if (1 > 0) {
      // _contentWidth = 700;
    }

    if (rptPrintSetting.formulaName ?? true) {
      showFmaName = true;
    }

    if (rptPrintSetting.formulaId ?? true) {
      fields.add(PrintField(
          label: localizedStrings.fFmaIdLabel, value: _id, show: true));
    }
    if (rptPrintSetting.operator ?? true) {
      fields.add(PrintField(
          label: localizedStrings.operator, value: _operatorName, show: true));
    }
    if (rptPrintSetting.saveTime ?? true) {
      fields.add(PrintField(
          label: localizedStrings.fCreatedTimeCol,
          value: _createTime,
          show: true));
    }
    if (rptPrintSetting.orderId ?? true) {
      fields.add(PrintField(label: 'No.', value: _orderNo, show: true));
    }
    if (rptPrintSetting.fmaTotalWgt ?? true) {
      fields.add(PrintField(
          label: localizedStrings.fFormulaTotalWeight,
          value: _fmaTotalWgt,
          show: true));
    }

    if (rptPrintSetting.formulaBarcode ?? true) {
      fields.add(PrintField(
          label: localizedStrings.fFmaBarcode,
          value: widget.fmaData.header!.formulaBarcode ?? '',
          show: true));
    }

    if (rptPrintSetting.rawName ?? true) {
      showName = true;
    } else {
      showName = false;
    }

    if (rptPrintSetting.rawId ?? true) {
      showId = true;
    } else {
      showId = false;
    }
    if (rptPrintSetting.rawActualErr ?? true) {
      showError = true;
    } else {
      showError = false;
    }
    if (rptPrintSetting.pass ?? true) {
      showPass = true;
    } else {
      showPass = false;
    }
    if (rptPrintSetting.rawActualWgt ?? true) {
      showWeight = true;
    } else {
      showWeight = false;
    }
    if (rptPrintSetting.deviceName ?? true) {
      showDeviceName = true;
    } else {
      showDeviceName = false;
    }
    if (rptPrintSetting.actualTotalWgt ?? true) {
      showFmaActualWgt = true;
    } else {
      showFmaActualWgt = false;
    }

    for (var item in widget.fmaData.details!) {
      tableRows.add(TableRowData(
        name: item.materialName ?? '',
        id: item.materialId ?? '',
        error:
            "${item.actualErrorWgt} ${widget.fmaData.header!.totalWeightUnit}",
        pass: item.sequence == 0
            ? "-"
            : item.isQualified.toString() == "ok"
                ? localizedStrings.fQualified
                : localizedStrings.fUnqualified,
        weight:
            "${item.actualWeight} ${widget.fmaData.header!.totalWeightUnit}",
        deviceName: item.scaleName.toString(),
      ));
    }
  }

  TextStyle getTextStyle({Color? color}) {
    return Theme.of(context).textTheme.bodySmall!.apply(
          color: color ?? Theme.of(context).colorScheme.onSurface,
        );
  }

  TextStyle getContentFontStyle({Color? color}) {
    return Theme.of(context).textTheme.labelSmall!.apply(
          color: color ?? Theme.of(context).colorScheme.onSurface,
        );
  }

  Widget _buildRecipeNameRow(String title, String name) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 0),
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          text: '$title:  ',
          style: getTextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant),
          children: [
            TextSpan(
              text: name,
              style: getTextStyle(),
            ),
          ],
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  // 修改 _buildDynamicFields 返回 List<Widget>
  List<Widget> _buildDynamicFieldsList(List<PrintField> fields) {
    // 1. 过滤出需要显示的字段
    final visibleFields = fields.where((field) => field.show).toList();

    // 2. 分组逻辑：每2个字段一组
    final List<List<PrintField>> groupedFields = [];

    for (int i = 0; i < visibleFields.length; i += 2) {
      // 计算当前组的结束索引
      final endIndex =
          i + 2 < visibleFields.length ? i + 2 : visibleFields.length;

      // 获取当前组
      final group = visibleFields.sublist(i, endIndex);
      groupedFields.add(group);
    }

    // 3. 构建 Widget 列表
    return groupedFields.map((group) {
      // 判断当前组有几个字段
      if (group.length == 1) {
        // 只有一个字段：单独占一行，但显示在左侧
        return Padding(
          padding: const EdgeInsets.only(bottom: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // 左侧字段
              _buildFieldItem(group[0]),
            ],
          ),
        );
      } else {
        // 有两个字段：均匀分布在一行
        return Padding(
          padding: const EdgeInsets.only(bottom: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 左侧字段
              _buildFieldItem(group[0]),
              // 添加间距
              const SizedBox(width: 20),
              // 右侧字段
              _buildFieldItem(group[1]),
            ],
          ),
        );
      }
    }).toList();
  }

// 构建单个字段的 Widget
  Widget _buildFieldItem(PrintField field) {
    return Expanded(
      // 使用 Expanded 让字段自适应宽度
      flex: 1,
      child: Container(
        constraints: const BoxConstraints(minHeight: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${field.label}:  ',
              style: getTextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Expanded(
              child: Text(
                field.value,
                style: getTextStyle(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleTable({
    required List<TableRowData> data,
    required showName,
    required showId,
    required showError,
    required showPass,
    required showWeight,
    required showDeviceName,
  }) {
    // 收集需要显示的列，添加 flex 权重
    final List<Map<String, dynamic>> columns = [];

    if (showName) {
      columns.add({
        'title': localizedStrings.fMaterialNameCol,
        'key': 'name',
        'flex': 3
      });
    }
    if (showId) {
      columns.add(
          {'title': localizedStrings.fMaterialIdCol, 'key': 'id', 'flex': 2});
    }

    if (showWeight) {
      columns.add({'title': 'Actual Weight', 'key': 'weight', 'flex': 2});
    }
    if (showError) {
      columns.add(
          {'title': localizedStrings.fActualError, 'key': 'error', 'flex': 2});
    }
    if (showDeviceName) {
      columns.add({
        'title': localizedStrings.gDeviceName,
        'key': 'deviceName',
        'flex': 2
      });
    }
    if (showPass) {
      columns.add({
        'title': localizedStrings.fQualificationStatus,
        'key': 'pass',
        'flex': 1
      });
    }

    if (columns.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        // 表头
        Row(
          children: columns.map((col) {
            return Expanded(
              flex: col['flex'] ?? 1, // 使用 flex 参数
              child: Container(
                padding: const EdgeInsets.all(8),
                // color: Colors.grey.shade100,
                child: Text(
                  col['title'],
                  style: getTextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.left,
                ),
              ),
            );
          }).toList(),
        ),
        Divider(height: 1, color: Colors.grey.shade300),

        // 数据行
        ...data.map((row) {
          return Row(
            children: columns.map((col) {
              String value = '';
              switch (col['key']) {
                case 'name':
                  value = row.name;
                  break;
                case 'id':
                  value = row.id;
                  break;
                case 'error':
                  value = row.error;
                  break;
                case 'pass':
                  value = row.pass;
                  break;
                case 'weight':
                  value = row.weight;
                  break;
                case 'deviceName':
                  value = row.deviceName;
                  break;
              }

              return Expanded(
                flex: col['flex'] ?? 1, // 使用相同的 flex 参数
                child: Container(
                  padding: const EdgeInsets.all(5),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    border: Border(
                        // top: BorderSide(color: Colors.grey.shade200),
                        ),
                  ),
                  child: Text(
                    value,
                    style: getTextStyle(
                        color: value == localizedStrings.fQualified
                            ? Colors.green
                            : value == localizedStrings.fUnqualified
                                ? Colors.red
                                : null),
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(0)),
        ),
        child: Container(
          width: 860,
          height: 800,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(0),
          ),
          child: Column(children: [
            // 头部
            ...dialogHeadStyle(context, localizedStrings.fPrintFmaBtn, true),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Card(
                    elevation: 5,
                    child: RepaintBoundary(
                      key: boundaryKey,
                      child: Container(
                        width: _contentWidth,
                        constraints: BoxConstraints(
                          minHeight: _contentHeight,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(0),
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // 顶部内容
                            if (showFmaName)
                              _buildRecipeNameRow(
                                localizedStrings.fFmaNameLabel,
                                widget.fmaData.header!.formulaName ?? '',
                              ),

                            // 动态字段区
                            ..._buildDynamicFieldsList(fields),

                            // 分隔线
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Divider(
                                  height: 1, color: Colors.grey.shade300),
                            ),

                            // 表格
                            _buildSimpleTable(
                              data: tableRows,
                              showName: showName,
                              showId: showId,
                              showError: showError,
                              showPass: showPass,
                              showWeight: showWeight,
                              showDeviceName: showDeviceName,
                            ),
                            // 分隔线
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Divider(
                                  height: 1, color: Colors.grey.shade300),
                            ),
                            if (showFmaActualWgt)
                              _buildRecipeNameRow(
                                  localizedStrings.fActualTotalWeight,
                                  _fmaActualWgt),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  DateTime.now().toString().split('.')[0],
                                  style: getTextStyle(),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Wrap(
            //   spacing: 10,
            //   runSpacing: 10,
            //   alignment: WrapAlignment.center,
            //   children: [
            // ElevatedButton.icon(
            //   onPressed: _captureImage,
            //   icon: const Icon(Icons.camera_alt),
            //   label: const Text('截图'),
            //   style: ElevatedButton.styleFrom(
            //     padding: const EdgeInsets.symmetric(
            //       horizontal: 20,
            //       vertical: 12,
            //     ),
            //   ),
            // ),
            // ElevatedButton.icon(
            //   onPressed: () => _captureAndPrint(context),
            //   icon: const Icon(Icons.print),
            //   label: const Text('截图并打印'),
            //   style: ElevatedButton.styleFrom(
            //     padding: const EdgeInsets.symmetric(
            //       horizontal: 20,
            //       vertical: 12,
            //     ),
            //     backgroundColor: Colors.orange.shade600,
            //   ),
            // ),
            // ElevatedButton.icon(
            //   onPressed: _saveImage,
            //   icon: const Icon(Icons.save),
            //   label: const Text('保存到相册'),
            //   style: ElevatedButton.styleFrom(
            //     padding: const EdgeInsets.symmetric(
            //       horizontal: 20,
            //       vertical: 12,
            //     ),
            //     backgroundColor: Colors.green.shade600,
            //   ),
            // ),
            // OutlinedButton.icon(
            //   onPressed: _clearImage,
            //   icon: const Icon(Icons.clear),
            //   label: const Text('清除'),
            // ),
            //   ],
            // ),
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
                      onPressed: () => _captureAndPrint(context),
                      child: Text(
                        localizedStrings.gPrint,
                        style: getTextStyle(
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
                        style: getTextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ]),
        ));
  }

  // 截图函数
  Future<void> _captureImage() async {
    try {
      // setState(() {
      //   _statusMessage = '正在截图...';
      // });

      // 等待一帧以确保Widget渲染完成
      await Future.delayed(const Duration(milliseconds: 50));

      final boundary = boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        // setState(() {
        //   _statusMessage = '找不到要截图的Widget';
        // });
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        setState(() {
          _imageBytes = byteData.buffer.asUint8List();
          // _statusMessage = '截图成功！图片大小: ${_imageBytes.length} 字节';
        });
      }
    } catch (e) {
      // setState(() {
      //   _statusMessage = '截图失败: $e';
      // });
      // print('截图错误: $e');
      return;
    }
  }

  // 截图并打印函数
  Future<void> _captureAndPrint(BuildContext context) async {
    try {
      // setState(() {
      //   _statusMessage = '正在生成PDF...';
      // });

      // 先截图
      await _captureImage();

      if (_imageBytes.isEmpty) {
        // setState(() {
        //   _statusMessage = '请先截图成功再打印';
        // });
        return;
      }

      //根据图片宽度和高度创建一个PDf页面格式，PDf的宽度是210mm,高度最大是297mm，高度可以根据图片的高度来调整
      // 创建PDF文档
      final pdf = pw.Document();

      // final image = await decodeImageFromList(_imageBytes);

      PdfPageFormat pageFormat = PdfPageFormat.a4;

      pdf.addPage(
        pw.Page(
          build: (context) {
            return pw.Container(
              // 子Widget将自动在边距内布局
              child: pw.Image(
                pw.MemoryImage(_imageBytes),
                fit: pw.BoxFit.contain,
              ),
            );
          },
          pageTheme: pw.PageTheme(
            pageFormat: pageFormat,
            margin: const pw.EdgeInsets.all(10), // 统一设置页面边距
          ),
        ),
      );

      // 打印PDF
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
      //保存PDF到设备
      // final directory = await getApplicationDocumentsDirectory();
      // final filePath =
      //     '${directory.path}/${widget.fmaData.header!.recordId!}.pdf';
      // final file = File(filePath);

      // await file.writeAsBytes(await pdf.save());
    } catch (e) {
      // setState(() {
      //   _statusMessage = '打印失败: $e';
      // });
      return;
    }
  }

  // 保存图片到设备
  Future<void> _saveImage() async {
    if (_imageBytes.isEmpty) {
      // setState(() {
      //   _statusMessage = '请先截图再保存';
      // });
      return;
    }

    try {
      // setState(() {
      //   _statusMessage = '正在保存图片...';
      // });

      // 获取保存路径
      final directory = await getApplicationDocumentsDirectory();
      final filePath =
          '${directory.path}/widget_screenshot_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);

      await file.writeAsBytes(_imageBytes);

      // setState(() {
      //   _statusMessage = '图片已保存到: $filePath';
      // });
    } catch (e) {
      // setState(() {
      //   _statusMessage = '保存失败: $e';
      // });
      return;
    }
  }

  // 清除图片
  void _clearImage() {
    setState(() {
      _imageBytes = Uint8List(0);
    });
  }
}

///////////////////////////////////////////////////////////////////////////////
///
///

class PrintField {
  final String label;
  final String value;
  final bool show;

  PrintField({
    required this.label,
    required this.value,
    this.show = true,
  });
}

// 列表数据模型
class TableRowData {
  final String name;
  final String id;
  final String error;
  final String pass;
  final String weight;
  final String deviceName;

  TableRowData({
    required this.name,
    required this.id,
    required this.error,
    required this.pass,
    required this.weight,
    required this.deviceName,
  });
}

// 列配置类
class ColumnConfig {
  final String key;
  final String title;
  final bool show;
  final double width; // 列宽（可选）

  ColumnConfig({
    required this.key,
    required this.title,
    this.show = false,
    this.width = 80.0, // 默认宽度
  });
}
