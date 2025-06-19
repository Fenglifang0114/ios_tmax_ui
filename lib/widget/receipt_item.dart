import 'package:flutter/material.dart';
import 'package:t_max/data/receipt_item.dart';
import '../../data/selectedcontrol.dart';
import '../../eventbus/eventbus.dart';
import 'line_painter.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'dart:math';

import 'rectangle_painter.dart';

const textHeight = 28.0;

class ReceiptItem extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables

  ReceiptItem({
    super.key,
    required this.index,
    required this.type,
    required this.xPos,
    required this.yPos,
    required this.width,
    required this.height,
    required this.fontSize,
    required this.fontWidthRatio,
    required this.fontHeightRatio,
    required this.alignment,
    required this.maxLength,
    required this.rotation,
    required this.style,
    required this.tabOrder,
    required this.varName,
    required this.content,
    required this.defaultValue,
    required this.varcontent,
    required this.barcodeName,
    required this.barcodeType,
    required this.hralignment,
    required this.x2Pos,
    required this.y2Pos,
    required this.lineWidth,
    required this.qrWidth,
    required this.qrcodeName,
    required this.qrcodeType,
    required this.fontBold,
    required this.fontReverse,
  });
  late int index;
  late String type;
  late int xPos;
  late int yPos;
  late int width;
  late int height;
  late int fontSize;
  late int fontWidthRatio;
  late int fontHeightRatio;
  late int style;
  late int rotation;
  late String varName;
  late String defaultValue;
  late int alignment;
  late int maxLength;
  late int tabOrder;
  late String content;
  late List<dynamic> varcontent;
  late String barcodeName;
  late String barcodeType;
  late String hralignment;
  late int x2Pos;
  late int y2Pos;
  late double lineWidth;
  late String qrWidth;
  late String qrcodeName;
  late String qrcodeType;
  late String fontBold;
  late String fontReverse;

  @override
  // ignore: no_logic_in_create_state
  State<ReceiptItem> createState() => ReceiptItemState();
}

class ReceiptItemState extends State<ReceiptItem> {
  ReceiptItemState({Key? key}) : super();
  dynamic _eventbus1;
  @override
  void initState() {
    super.initState();

    _eventbus1 = eventBus.on<EventRcpSelectedControl>().listen((event) {
      if (mounted) {
        setState(() {
          myReceiptSelCtl = event.obj;
        });
      }
    });
  }

  @override
  void dispose() {
    _eventbus1.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              myReceiptItemData.tabOrder = widget.index;
              myReceiptItemData.type = widget.type;
              myReceiptItemData.xPos = widget.xPos;
              myReceiptItemData.yPos = widget.yPos;
              myReceiptItemData.height = widget.height;
              myReceiptItemData.width = widget.width;
              myReceiptItemData.style = widget.style;
              myReceiptItemData.fontWidthRatio = widget.fontWidthRatio;
              myReceiptItemData.fontHeightRatio = widget.fontHeightRatio;
              myReceiptItemData.fontSize = widget.fontSize;
              myReceiptItemData.maxLength = widget.maxLength;
              myReceiptItemData.alignment = widget.alignment;
              myReceiptItemData.content = widget.content;
              myReceiptItemData.varcontent = widget.varcontent;
              myReceiptItemData.defaultValue = widget.defaultValue;
              myReceiptItemData.rotation = widget.rotation;
              myReceiptItemData.varName = widget.varName;
              myReceiptItemData.hralignment = widget.hralignment;
              myReceiptItemData.x2Pos = widget.x2Pos;
              myReceiptItemData.y2Pos = widget.y2Pos;
              myReceiptItemData.lineWidth = widget.lineWidth;
              myReceiptItemData.qrWidth = widget.qrWidth;
              myReceiptItemData.barcodeName = widget.barcodeName;
              myReceiptItemData.barcodeType = widget.barcodeType;
              myReceiptItemData.qrcodeName = widget.qrcodeName;
              myReceiptItemData.qrcodeType = widget.qrcodeType;
              myReceiptItemData.fontBold = widget.fontBold;
              myReceiptItemData.fontReverse = widget.fontReverse;
              eventBus.fire(EventRcpText(myReceiptItemData));
            });
          },
          child: _getWidget(),
        ),
      ],
    );
  }

  Widget _getWidget() {
    if (widget.type != 'BarCode') {
      // 非条码类型直接返回空容器
      if (widget.type == 'TEXT' || widget.type == 'DATA') {
        return Transform.rotate(
          angle: _getRotation(),
          child: Container(
              decoration: BoxDecoration(
                color: (widget.fontReverse == 'true')
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.surfaceTint,
                border: Border.all(
                    width: (widget.index == myReceiptSelCtl.selectid &&
                            myReceiptSelCtl.isSelect)
                        ? 1
                        : 0.5,
                    color: (widget.index == myReceiptSelCtl.selectid &&
                            myReceiptSelCtl.isSelect)
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface),
                borderRadius: const BorderRadius.all(Radius.circular(1)),
              ),
              child: SizedBox(
                  height: textHeight, // 设置SizedBox的高度，也可以根据需求调整
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(widget.content,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontFamily: "simsunb",
                            fontSize: (widget.fontSize > 0)
                                ? (widget.fontSize).toDouble()
                                : 19,
                            color: (widget.fontReverse == 'true')
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurface,
                            fontWeight: (widget.fontBold == 'true')
                                ? FontWeight.bold
                                : FontWeight.normal)),
                  ))),
        );
      } else if (widget.type == 'Qrcode') {
        return Container(
          decoration: _getBorderStyle(),
          // color: Colors.grey.shade200,
          child: BarcodeWidget(
            barcode: Barcode.qrCode(),
            data: widget.content,
            width: int.parse(widget.qrWidth) * 21,
            height: int.parse(widget.qrWidth) * 21,
          ),
        );
      } else if (widget.type == 'Line') {
        return buildLine();
      } else if (widget.type == 'Rectangle') {
        return buildRectangle();
      } else {
        // 对于其他情况直接返回空容器
        return Container();
      }
    } else {
      if (widget.hralignment.toString() == 'None' ||
          widget.hralignment.toString() == '0') {
        // 不带条码文字的情况
        return Container(
          decoration: _getBorderStyle(),
          child: _getBarcodeWidget(),
        );
      } else if (widget.hralignment.toString() == 'Bottom') {
        // 条码文字在下方的情况
        return Column(
          children: [
            Container(
              decoration: _getBorderStyle(),
              child: _getBarcodeWidget(),
            ),
          ],
        );
      } else if (widget.hralignment.toString() == 'Top') {
        // 条码文字在上方的情况
        // 'Code128',
        // 'Code39',
        // 'EAN13',
        // 'EAN8',
        // 'UPC-A',
        // 'UPC-E',
        // 'TTF',
        return Transform.rotate(
            angle: _getRotation(), //旋转角度  pi/2  90度
            child: Column(
              children: [
                Text(widget.content),
                const SizedBox(height: 5), // 调整文字与条码的间距
                Container(
                  decoration: _getBorderStyle(),
                  child: BarcodeWidget(
                    barcode: (widget.barcodeType == 'Code128')
                        ? Barcode.code128()
                        : (widget.barcodeType == 'EAN13')
                            ? Barcode.ean13()
                            : (widget.barcodeType == 'EAN8')
                                ? Barcode.ean8()
                                : (widget.barcodeType == 'Code93')
                                    ? Barcode.code93()
                                    : (widget.barcodeType == 'Code39')
                                        ? Barcode.code39()
                                        : (widget.barcodeType == 'UPC-A')
                                            ? Barcode.upcA()
                                            : (widget.barcodeType == 'UPC-E')
                                                ? Barcode.upcE()
                                                : Barcode.code128(),
                    data: widget.content,
                    drawText: (widget.hralignment == 'Bottom') ? true : false,
                    height: (widget.height > 0)
                        ? double.parse(widget.height.toString())
                        : 100,
                  ),
                ),
                // 调整文字与条码的间距
              ],
            ));
      } else {
        // 对于其他情况直接返回空容器
        return Container();
      }
    }
  }

  Widget buildLine() {
    // print('widget.x2Pos.toString()  ' + widget.x2Pos.toString());
    // print('widget.xPos.toString()  ' + widget.xPos.toString());
    return Transform.rotate(
        angle: 0, //degrees.abs(), //旋转角度  pi/2  90度
        child: Container(
          decoration: _getBorderStyle(),
          width: widget.x2Pos + 0, // 宽度等于线条长度
          height: widget.lineWidth + 1, // 高度等于线条宽度
          child: CustomPaint(
            painter: LinePainter(
              startPoint: Offset(
                  0,
                  widget.lineWidth / 2 +
                      1), //double.parse(widget.yPos.toString())),
              endPoint: Offset(
                  widget.x2Pos.toDouble(),
                  widget.lineWidth / 2 +
                      1), //Offset(double.parse(widget.x2Pos.toString()),                  double.parse((widget.y2Pos).toString())),
              // startPoint: Offset(30, 70),
              // endPoint: Offset(100, 100),
              lineColor: Theme.of(context).colorScheme.onSurface,
              lineWidth: widget.lineWidth,
            ),
          ),
        ));
  }

  Widget buildRectangle() {
    // final lineLength = sqrt(pow(
    //         double.parse(widget.x2Pos.toString()) -
    //             double.parse(widget.xPos.toString()),
    //         2) +
    //     pow(
    //         double.parse(widget.y2Pos.toString()) -
    //             double.parse(widget.yPos.toString()),
    //         2));
    return Container(
        decoration: _getBorderStyle(),
        // width: lineLength, // 宽度等于线条长度
        // height: widget.lineWidth, // 高度等于线条宽度
        child: SizedBox(
            width: 100,
            height: 200,
            child: CustomPaint(
              painter: RectanglePainter(
                startPoint: const Offset(0, 0),
                endPoint: const Offset(100, 200),
              ),
              // size: Size.infinite,
            ))

        // CustomPaint(
        //   painter: LinePainter(
        //       startPoint: Offset(10, 100),
        //       endPoint: Offset(10, 200),
        //       lineColor: Theme.of(context).colorScheme.onSurface,
        //       lineWidth: 100 //widget.lineWidth,
        //       ),
        // ),
        );
  }

  // 获取边框样式
  BoxDecoration _getBorderStyle() {
    return BoxDecoration(
      border: Border.all(
          color: (widget.index == myReceiptSelCtl.selectid &&
                  myReceiptSelCtl.isSelect)
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface),
      borderRadius: const BorderRadius.all(Radius.circular(1)),
    );
  }

  double _getRotation() {
    if (widget.rotation == 0) {
      return 0;
    } else if (widget.rotation == 90) {
      return pi / 2;
    } else if (widget.rotation == 180) {
      return pi;
    } else if (widget.rotation == 270) {
      return pi / 2 * 3;
    } else {
      return 0;
    }
  }

  // 获取条码部分的组件
  Transform _getBarcodeWidget() {
    return Transform.rotate(
      angle: _getRotation(), //旋转角度  pi/2  90度
      child: BarcodeWidget(
        barcode: (widget.barcodeType == 'Code128')
            ? Barcode.code128()
            : (widget.barcodeType == 'EAN13')
                ? Barcode.ean13()
                : (widget.barcodeType == 'EAN8')
                    ? Barcode.ean8()
                    : (widget.barcodeType == 'Code93')
                        ? Barcode.code93()
                        : (widget.barcodeType == 'Code39')
                            ? Barcode.code39()
                            : (widget.barcodeType == 'UPC-A')
                                ? Barcode.upcA()
                                : (widget.barcodeType == 'UPC-E')
                                    ? Barcode.upcE()
                                    : Barcode.code128(),
        data: widget.content,
        drawText: (widget.hralignment == 'Bottom') ? true : false,
        height:
            (widget.height > 0) ? double.parse(widget.height.toString()) : 100,
      ),
    );
  }
}
