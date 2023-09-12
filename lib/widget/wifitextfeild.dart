import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget buildCommonRow(
  String title,
  int maxlenth,
  RegExp regexp,
  bool errortextFlag,
  String errortext,
  Function(String) onchange,
  TextEditingController controller,
  bool readOnlyFlag,
) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const SizedBox(
        width: 20,
      ),
      SizedBox(
        height: 60,
        width: 100,
        child: Align(
          alignment: Alignment.topRight,
          child: Text(
            title,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
        ),
      ),
      const SizedBox(
        width: 20,
      ),
      SizedBox(
        width: 300,
        height: 68,
        child: TextField(
          controller: controller,
          readOnly: !readOnlyFlag,
          textAlign: TextAlign.start,
          textAlignVertical: TextAlignVertical.center,
          inputFormatters: [
            LengthLimitingTextInputFormatter(maxlenth),
            FilteringTextInputFormatter.allow(regexp), // 允许输入数字和点
          ],
          decoration: InputDecoration(
            isDense: true,
            errorText: errortextFlag ? null : errortext,
            errorStyle: const TextStyle(fontSize: 14.0),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
          ),
          onChanged: onchange,
        ),
      )
    ],
  );
}
