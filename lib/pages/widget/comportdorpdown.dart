import 'package:flutter/material.dart';
import 'package:t_max/data/cominfoslist_data.dart';
import 'package:t_max/data/currentport_data.dart';
import '../../data/dialog_data.dart';
import '../../eventbus/eventbus.dart';
import '../dialog/showComPort_dialog.dart';

// ignore: must_be_immutable
class ComPortDropdown extends StatefulWidget {
  ComPortDropdown(this.index, this.dropDownList, this.defaultValue, {Key? key})
      : super(key: key);
  late int index;
  late List<String> dropDownList = [];
  late var defaultValue = '';
  @override
  State<ComPortDropdown> createState() => DropdownState();
}

class DropdownState extends State<ComPortDropdown> {
  // var defaultValue;
  // DropdownState( {Key? key}) : super();

  @override
  Widget build(BuildContext context) {
    List<String> dropDownList = widget.dropDownList;
    return Container(
      height: 53,
      width: 200,
      padding: EdgeInsets.all(0),
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        // decoration: const InputDecoration(border: OutlineInputBorder()),
        // 设置默认值

        value: (widget.defaultValue != '')
            ? widget.defaultValue
            : widget.dropDownList[0],
        // 选择回调
        onChanged: (String? newPosition) {
          myDialogData.msg = newPosition.toString();
          currentValue(widget.index, newPosition.toString());
          // print(myDialogData.msg);
          // setState(() {
          //   eventBus.fire(EventDialogData(myDialogData));
          // });
        },
        // 传入可选的数组
        items: dropDownList.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem(value: value, child: Text(value));
        }).toList(),
      ),
    );
  }
}

void currentValue(int index, String newValue) {
  if (index == 1) //数据位
  {
    tempCurrentPort.dataBits = int.parse(newValue);
  } else if (index == 2) //停止位
  {
    switch (newValue) {
      case "1":
        tempCurrentPort.stopBits = 0;
        break;
      case "1.5":
        tempCurrentPort.stopBits = 1;
        break;
      case "2":
        tempCurrentPort.stopBits = 2;
        break;
      default:
        tempCurrentPort.stopBits = 0;
        break;
    }
  } else if (index == 3) //波特率
  {
    tempCurrentPort.baud = int.parse(newValue);
  } else if (index == 4) //校验位
  {
    switch (newValue) {
      case "None":
        tempCurrentPort.parity = 0;
        break;
      case "Odd":
        tempCurrentPort.parity = 1;
        break;
      case "Even":
        tempCurrentPort.parity = 2;
        break;
      default:
        tempCurrentPort.parity = 0;
        break;
    }
  }
}
