import 'package:flutter/material.dart';

class CustomCard extends StatefulWidget {
  final GestureTapCallback onTap;
  final Color cardColor;
  final Color textColor;
  final String title;
  // final String image;

  const CustomCard({
    super.key,
    required this.onTap,
    required this.cardColor,
    required this.textColor,
    required this.title,
    // required this.image,
  });

  @override
  CustomCardState createState() => CustomCardState();
}

class CustomCardState extends State<CustomCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: 200,
      child: InkWell(
        splashColor: Theme.of(context).colorScheme.primary,
        onTap: widget.onTap,
        onHover: (value) {
          setState(() {
            isHovered = value;
          });
        },
        child: Card(
          elevation: 50,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 1.0,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(20), // 设置圆角半径
          ),
          color: isHovered
              ? Theme.of(context).colorScheme.primary
              : widget.cardColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // const SizedBox(height: 20),
              // Container(
              //   width: 64,
              //   height: 64,
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(20), // 设置圆角半径
              //     color: Theme.of(context).colorScheme.onPrimary, // 设置背景颜色
              //   ),
              //   child: Image.asset(widget.image),
              // ),
              // const SizedBox(height: 10),
              Text(
                widget.title,
                style: TextStyle(
                    fontSize: 14,
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
