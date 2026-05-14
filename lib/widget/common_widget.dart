//共用的组件  输入框，文本框，下拉框

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/home_page_common_data.dart';

//文本框
showItemNameWithStar(BuildContext context, String itemName, bool showFlag) {
  return Container(
    height: textContentHeight,
    alignment: Alignment.centerLeft,
    child: RichText(
      overflow: TextOverflow.ellipsis, // 超出部分显示省略号,
      text: TextSpan(
        children: [
          showFlag
              ? TextSpan(
                  text: '* ',
                  style: Theme.of(context).textTheme.bodyMedium?.apply(
                        color: Theme.of(context).colorScheme.error, // 设置输入文本颜色
                      ),
                )
              : TextSpan(
                  text: '',
                ),
          TextSpan(
            text: itemName,
            style: Theme.of(context).textTheme.bodySmall?.apply(
                  color: Theme.of(context).colorScheme.onSurface, // 设置输入文本颜色
                ),
          ),
        ],
      ),
    ),
  );
}

//输入框
showInputBox(BuildContext context, TextEditingController controller,
    String hintText, Function(String)? onChanged, bool isEnabled, {FocusNode? focusNode}) {
  return SizedBox(
    height: inputHeight,
    child: TextField(
      focusNode: focusNode,
      enabled: isEnabled, // 设置是否可编辑,
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(0.0))),
        hintText: hintText,
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface, // 设置提示文本颜色
        ),
      ),
      style: Theme.of(context).textTheme.bodySmall?.apply(
            color: isEnabled
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context)
                    .colorScheme
                    .surface, // 设置输入文本颜色
          ),
      onChanged: onChanged, // 监听文本变化,
    ),
  );
}

// //选择下拉列表框
// showDropDownButton(
//     BuildContext context,
//     String hintText,
//     TextEditingController valueCtl,
//     List<String> dropList,
//     void Function(String?) onChanged,
//     {Function()? onTap}) {
//   return Container(
//       height: inputHeight,
//       decoration: BoxDecoration(
//         border: Border.all(
//             color: Theme.of(context).colorScheme.outlineVariant), // 设置边框颜色
//         borderRadius: BorderRadius.circular(0), // 设置圆角
//       ),
//       child: DropdownButton(
//         padding: const EdgeInsets.only(left: 16, right: 20),
//         underline: SizedBox(),
//         isExpanded: true,
//         value: valueCtl.text == "" ? null : valueCtl.text,
//         items: dropList.isEmpty
//             ? [
//                 DropdownMenuItem<String>(
//                   value: null,
//                   child: Text(hintText),
//                 )
//               ]
//             : [
//                 ...dropList.map((String item) {
//                   return DropdownMenuItem<String>(
//                     value: item,
//                     child: Text(item),
//                   );
//                 })
//               ],
//         onChanged: onChanged,
//         onTap: onTap,
//         style: TextStyle(
//           color: Theme.of(context).colorScheme.onSurfaceVariant,
//           fontSize: 14,
//           fontWeight: FontWeight.normal,
//         ),
//       ));
// }

//button

showTextButton(BuildContext context, double btnHeight, String btnText,
    Function()? onPressed, Color textColor, Color bgColor, Color fColor) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      foregroundColor: fColor,
      backgroundColor: bgColor,
      fixedSize: Size(double.infinity, btnHeight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
    ),
    onPressed: onPressed,
    child: Text(
      btnText,
      style: Theme.of(context).textTheme.bodySmall?.apply(
            color: textColor,
          ),
      overflow: TextOverflow.ellipsis,
    ),
  );
}

//输入框 Scale Name
showScaleNameInputBox(
    BuildContext context,
    TextEditingController controller,
    String hintText,
    Widget suffixWidget,
    Function(String)? onChanged,
    bool isEnabled) {
  return Container(
    alignment: Alignment.centerLeft,
    height: inputHeight,
    padding: const EdgeInsets.only(left: 16, right: 20),
    decoration: BoxDecoration(
      border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant), // 设置边框颜色
      borderRadius: BorderRadius.circular(0), // 设置圆角
    ),
    child: TextField(
      readOnly: !isEnabled,
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface, // 设置提示文本颜色
        ),
        border: InputBorder.none, // 移除默认边框
        suffixIcon: suffixWidget,
      ),
      textAlignVertical: TextAlignVertical.center,
      maxLines: 1,
      inputFormatters: [
        LengthLimitingTextInputFormatter(30),
      ],
      style: Theme.of(context).textTheme.bodySmall?.apply(
            color: Theme.of(context).colorScheme.onSurface, // 设置输入文本颜色
          ),
      onChanged: onChanged, // 监听文本变化,
    ),
  );
}

//选择下拉列表框
showDropDownButton(
    BuildContext context,
    String hintText,
    TextEditingController valueCtl,
    List<String> dropList,
    void Function(String?) onChanged,
    {Function()? onTap}) {
  if (dropList.isNotEmpty && !dropList.contains(valueCtl.text)) {
    valueCtl.text = "";
  }
  return SizedBox(
      height: inputHeight,
      child: DropdownButtonFormField<String>(
        borderRadius: BorderRadius.circular(0),
        decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline, // 设置边框颜色
                  width: 1.0, // 设置边框宽度
                ),
                borderRadius: BorderRadius.all(Radius.circular(0.0))),
            border: OutlineInputBorder()),
        isExpanded: true,
        value: valueCtl.text == "" ? null : valueCtl.text,
        items: dropList.isEmpty
            ? [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text(hintText),
                )
              ]
            : [
                ...dropList.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                })
              ],
        onChanged: onChanged,
        onTap: onTap,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
      ));
}
