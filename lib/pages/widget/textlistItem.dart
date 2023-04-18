import 'package:flutter/material.dart';
import 'package:t_max/pages/widget/rectanglepainter.dart';
import '../../data/text.dart';
import '../../eventbus/eventbus.dart';
import 'linepainter.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'dart:math';

class TextItem extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  TextItem({
    Key? key,
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
  }) : super(key: key);
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
  State<TextItem> createState() => TextItemState();
}

class TextItemState extends State<TextItem> {
  TextItemState({Key? key}) : super();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              myTextData.tabOrder = widget.index;
              myTextData.type = widget.type;
              myTextData.xPos = widget.xPos;
              myTextData.yPos = widget.yPos;
              myTextData.height = widget.height;
              myTextData.width = widget.width;
              myTextData.style = widget.style;
              myTextData.fontWidthRatio = widget.fontWidthRatio;
              myTextData.fontHeightRatio = widget.fontHeightRatio;
              myTextData.fontSize = widget.fontSize;
              myTextData.maxLength = widget.maxLength;
              myTextData.alignment = widget.alignment;
              myTextData.content = widget.content;
              myTextData.varcontent = widget.varcontent;
              myTextData.defaultValue = widget.defaultValue;
              myTextData.rotation = widget.rotation;
              myTextData.varName = widget.varName;
              myTextData.hralignment = widget.hralignment;
              myTextData.x2Pos = widget.x2Pos;
              myTextData.y2Pos = widget.y2Pos;
              myTextData.lineWidth = widget.lineWidth;
              myTextData.qrWidth = widget.qrWidth;
              myTextData.barcodeName = widget.barcodeName;
              myTextData.barcodeType = widget.barcodeType;
              myTextData.qrcodeName = widget.qrcodeName;
              myTextData.qrcodeType = widget.qrcodeType;
              myTextData.fontBold = widget.fontBold;
              myTextData.fontReverse = widget.fontReverse;
              eventBus.fire(EventText(myTextData));
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
                    ? Colors.black
                    : Colors.white,
                border: Border.all(color: Colors.blue.shade900),
                borderRadius: const BorderRadius.all(Radius.circular(1)),
              ),
              // color: Colors.grey.shade200,
              child: Text(widget.content,
                  style: TextStyle(
                      fontFamily: "simsunb",
                      fontSize: (widget.fontSize > 0)
                          ? (widget.fontSize).toDouble()
                          : 19,
                      color: (widget.fontReverse == 'true')
                          ? Colors.white
                          : Colors.black,
                      fontWeight: (widget.fontBold == 'true')
                          ? FontWeight.bold
                          : FontWeight.normal))),
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
    double dx = double.parse(widget.x2Pos.toString()) -
        double.parse(widget.xPos.toString());
    double dy = double.parse(widget.y2Pos.toString()) -
        double.parse(widget.yPos.toString());
    double radians = atan2(dy, dx);
    double degrees = radians * 180 / pi;
    final lineLength = sqrt(pow(dx, 2) + pow(dy, 2));

    double widthLength = dx.abs();

    double heightLength = dy.abs();
    return Transform.rotate(
        angle: 0, //degrees.abs(), //旋转角度  pi/2  90度
        child: Container(
          decoration: _getBorderStyle(),
          width: widthLength + 5, // 宽度等于线条长度
          height: heightLength + 5, // 高度等于线条宽度
          child: CustomPaint(
            painter: LinePainter(
              startPoint: Offset(0, double.parse(widget.yPos.toString())),
              endPoint: Offset(double.parse(widget.x2Pos.toString()),
                  double.parse(widget.y2Pos.toString())),
              // startPoint: Offset(30, 70),
              // endPoint: Offset(100, 100),
              lineColor: Colors.black,
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
                startPoint: Offset(0, 0),
                endPoint: Offset(100, 200),
              ),
              // size: Size.infinite,
            ))

        // CustomPaint(
        //   painter: LinePainter(
        //       startPoint: Offset(10, 100),
        //       endPoint: Offset(10, 200),
        //       lineColor: Colors.black,
        //       lineWidth: 100 //widget.lineWidth,
        //       ),
        // ),
        );
  }

  // 获取边框样式
  BoxDecoration _getBorderStyle() {
    return BoxDecoration(
      border: Border.all(color: Colors.blue.shade900),
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
                            : Barcode.code128(),
        data: widget.content,
        drawText: (widget.hralignment == 'Bottom') ? true : false,
        height:
            (widget.height > 0) ? double.parse(widget.height.toString()) : 100,
      ),
    );
  }
}
