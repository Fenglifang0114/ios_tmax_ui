import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../data/dialog_data.dart';
import '../../eventbus/eventbus.dart';

// ignore: must_be_immutable
class Dropdown extends StatefulWidget {
  Dropdown(this.dropDownList, {Key? key}) : super(key: key);
  late List dropDownList = [];
  @override
  State<Dropdown> createState() => DropdownState(dropDownList);
}

class DropdownState extends State<Dropdown> {
  var dropDownList;
  DropdownState(this.dropDownList, {Key? key}) : super();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 53,
      width: 200,
      padding: const EdgeInsets.all(0),
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        // decoration: const InputDecoration(border: OutlineInputBorder()),
        // 设置默认值
        value: dropDownList[0],
        // 选择回调
        onChanged: (String? newPosition) {
          myDialogData.msg = newPosition.toString();
          if (kDebugMode) {
            print(myDialogData.msg);
          }
          setState(() {
            eventBus.fire(EventDialogData(myDialogData));
          });
        },
        // 传入可选的数组
        items: dropDownList.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem(value: value, child: Text(value));
        }).toList(),
      ),
    );
  }
}
