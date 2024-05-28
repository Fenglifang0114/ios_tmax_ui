import 'package:flutter/material.dart';
import 'package:t_max/data/barcodetype.dart';

import '../../data/barcoderowdata.dart';
import '../../eventbus/eventbus.dart';

class RowDataWidget extends StatefulWidget {
  final BarCodeRowData rowData;
  final List<BarCodeRowData> rowDataList;

  const RowDataWidget(
      {Key? key, required this.rowData, required this.rowDataList})
      : super(key: key);

  @override
  RowDataWidgetState createState() => RowDataWidgetState();
}

class RowDataWidgetState extends State<RowDataWidget> {
  final List<String> _types = [
    'TEXT',
    'Gross',
    'Tare',
    'Net',
    'Pcs',
    'WeightUnit',
    'Percent',
  ];

  final List<String> _alignments = [
    '--',
    'Left',
    'Center',
    'Right',
  ];

  late String _selectedType;
  late String _selectedAlignment;

  late TextEditingController _textEditingController;
  late TextEditingController _defaultvalueController;
  late TextEditingController _maxLengthController;
  late TextEditingController _textMaxLengthController;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.rowData.type;
    _selectedAlignment = widget.rowData.alignment;
    _textEditingController =
        TextEditingController(text: widget.rowData.content);
    _defaultvalueController =
        TextEditingController(text: widget.rowData.defaultvalue);
    _maxLengthController =
        TextEditingController(text: widget.rowData.maxlength.toString());
    _textMaxLengthController = TextEditingController(text: '-');

    eventBus.on<EventBarcodetypedata>().listen((event) {
      if (mounted) {
        setState(() {
          myBarcodetypedata = event.obj;
        });
      }
    });
  }

  @override
  void dispose() {
    _defaultvalueController.dispose();
    _maxLengthController.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _selectedType = widget.rowData.type;
    _selectedAlignment = widget.rowData.alignment;
    _textEditingController =
        TextEditingController(text: widget.rowData.content);
    _defaultvalueController =
        TextEditingController(text: widget.rowData.defaultvalue);
    _maxLengthController =
        TextEditingController(text: widget.rowData.maxlength.toString());
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: DropdownButton<String>(
            value: _selectedType,
            underline: Container(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedType = newValue!;
                widget.rowData.type = _selectedType;
              });
            },
            items: _types.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: TextField(
            enabled: (_selectedType == 'TEXT') ? true : false,
            controller: _textEditingController,
            decoration: const InputDecoration(hintText: 'Enter text'),
            textAlign: TextAlign.center,
            onChanged: (value) {
              widget.rowData.content = value;
            },
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: TextField(
            enabled: (_selectedType == 'TEXT') ? false : true,
            controller: _defaultvalueController,
            decoration: const InputDecoration(
              hintText: 'default value',
            ),
            textAlign: TextAlign.center,
            onChanged: (value) {
              widget.rowData.defaultvalue = value;
            },
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: DropdownButton<String>(
            value: _selectedAlignment,
            underline: Container(),
            onChanged: (_selectedType == 'TEXT')
                ? null
                : (String? newValue) {
                    setState(() {
                      _selectedAlignment = newValue!;
                      widget.rowData.alignment = _selectedAlignment;
                    });
                  },
            items: _alignments.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: TextField(
            enabled: (_selectedType == 'TEXT') ? false : true,
            keyboardType: TextInputType.number,
            controller: (_selectedType == 'TEXT')
                ? _textMaxLengthController
                : _maxLengthController,
            decoration: const InputDecoration(hintText: 'Enter max length'),
            textAlign: TextAlign.center,
            onChanged: (value) {
              if (value.isNotEmpty) {
                RegExp regex = RegExp(r"^[1-9]$|^[1-4]\d$|^50$"); //1-50限制大小
                if (regex.hasMatch(value)) {
                  int tempvalue = int.parse(value.toString());
                  widget.rowData.maxlength = tempvalue;
                }
              }
            },
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        IconButton(
          icon: Icon(
            Icons.delete,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: widget.rowData.canDelete
              ? () {
                  setState(() {
                    widget.rowDataList
                        .removeWhere((rowData) => rowData == widget.rowData);
                    myBarCodeRowDataList.barCodeRowDataList =
                        widget.rowDataList;
                    eventBus.fire(
                        EventCurrentBarCodeRowDataList(myBarCodeRowDataList));
                    // widget.rowData.canDelete = false;
                    // widget.rowData.canDelete = false;
                  });
                }
              : null,
        ),
      ],
    );
  }
}
