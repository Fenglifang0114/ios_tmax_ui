import 'package:flutter/material.dart';
import 'package:t_max/data/home_page_common_data.dart';

Widget buildDropdownButton({
  required String? value,
  required List items,
  required String hintText,
  required void Function(String) onSelect,
}) {
  return DropdownButton<String>(
    borderRadius: BorderRadius.circular(0),
    value: value,
    style: const TextStyle(
      color: Colors.black,
      fontSize: 14,
      fontWeight: FontWeight.normal,
    ),
    hint: Text(
      hintText,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    ),
    items: items
        .map(
          (entry) => DropdownMenuItem<String>(
            value: entry.toString(),
            child: Text(entry.toString()),
          ),
        )
        .toList(),
    onChanged: (String? newValue) {
      if (newValue != null) {
        onSelect(newValue);
      }
    },
  );
}

//选择下拉列表框
showDropDownButtonValue(BuildContext context, String value, List<String> items,
    String hintText, void Function(String) onSelect,
    {Function()? onTap}) {
  return SizedBox(
      height: inputHeight,
      child: DropdownButtonFormField<String>(
        borderRadius: BorderRadius.circular(0),
        decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant, // 设置边框颜色
                  width: 1.0, // 设置边框宽度
                ),
                borderRadius: BorderRadius.all(Radius.circular(0.0))),
            border: OutlineInputBorder()),
        isExpanded: true,
        value: value == "" ? null : value,
        items: items.isEmpty
            ? [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text(hintText),
                )
              ]
            : [
                ...items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                })
              ],
        onChanged: (String? newValue) {
          if (newValue != null) {
            onSelect(newValue);
          }
        },
        onTap: onTap,
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ));
}

//属性列表

Widget buildAttitudeText(BuildContext context, String text) {
  return Container(
      height: 54,
      padding: const EdgeInsets.only(right: largePadding),
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
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ]));
}

Widget buildTabOrderAndTyptText(
    BuildContext context, String title, String value) {
  return SizedBox(
      height: 42,
      child: Row(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodySmall!.apply(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          ),
          SizedBox(
            width: smallPadding,
          ),
          Expanded(
              child: Container(
                  height: 36,
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  alignment: Alignment.center,
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.bodySmall!.apply(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  )))
        ],
      ));
}

Widget showRightItemTitleText(BuildContext context, String title) {
  return Container(
    height: 42,
    alignment: Alignment.centerLeft,
    child: Text(title,
        textAlign: TextAlign.left,
        style: Theme.of(context).textTheme.bodySmall!.apply(
              color: Theme.of(context).colorScheme.onSurface,
            )),
  );
}
