import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../data/dialog_data.dart';
import '../../eventbus/eventbus.dart';

// ignore: must_be_immutable
class Dropdown extends StatefulWidget {
  final List<String> dropDownList;

  const Dropdown(this.dropDownList, {super.key});

  @override
  State<Dropdown> createState() => DropdownState();
}

class DropdownState extends State<Dropdown> {
  late String selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.dropDownList.first;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 53,
      width: 200,
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        value: selectedValue,
        onChanged: (String? newValue) {
          setState(() {
            selectedValue = newValue!;
            myDialogData.msg = selectedValue;
            if (kDebugMode) {
              print(myDialogData.msg);
            }
            eventBus.fire(EventDialogData(myDialogData));
          });
        },
        items: widget.dropDownList
            .map<DropdownMenuItem<String>>(
              (String value) => DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              ),
            )
            .toList(),
      ),
    );
  }
}
