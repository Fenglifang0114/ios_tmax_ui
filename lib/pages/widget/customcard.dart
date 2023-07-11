import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomCard extends StatefulWidget {
  final GestureTapCallback onTap;
  final Color cardColor;
  final Color textColor;
  final String title;
  final String image;

  const CustomCard({
    Key? key,
    required this.onTap,
    required this.cardColor,
    required this.textColor,
    required this.title,
    required this.image,
  }) : super(key: key);

  @override
  _CustomCardState createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: 200,
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: widget.onTap,
        onHover: (value) {
          setState(() {
            isHovered = value;
          });
        },
        child: Card(
          elevation: 50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // 设置圆角半径
          ),
          color:
              isHovered ? Color.fromARGB(255, 105, 187, 255) : widget.cardColor,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20), // 设置圆角半径
                  color: Theme.of(context).colorScheme.onPrimary, // 设置背景颜色
                ),
                child: Image.asset(widget.image),
              ),
              const SizedBox(height: 10),
              Text(
                widget.title,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                    color: isHovered
                        ? Theme.of(context).colorScheme.onPrimary
                        : widget.textColor), // 设置文字颜色
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// GestureDetector(
        //   onTap: onTap,
        //   child: Card(
        //     margin: const EdgeInsets.all(10),
        //     elevation: 50,
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(20), // 设置圆角半径
        //     ),
        //     color: cardColor, // 设置卡片背景颜色
        //     child: Column(
        //       children: [
        //         const SizedBox(height: 20),
        //         Container(
        //           width: 64,
        //           height: 64,
        //           decoration: BoxDecoration(
        //             borderRadius: BorderRadius.circular(20), // 设置圆角半径
        //             color: Theme.of(context).colorScheme.onPrimary, // 设置背景颜色
        //           ),
        //           child: Image.asset(image),
        //         ),
        //         const SizedBox(height: 10),
        //         Text(
        //           title,
        //           style: TextStyle(
        //               fontSize: 20,
        //               fontWeight: FontWeight.normal,
        //               color: textColor), // 设置文字颜色
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
