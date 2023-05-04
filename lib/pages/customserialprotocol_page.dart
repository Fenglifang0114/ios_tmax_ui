import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/customserialprotocoltext_dart.dart';

class CustomSerialProtocol extends StatefulWidget {
  const CustomSerialProtocol({Key? key}) : super(key: key);

  @override
  State<CustomSerialProtocol> createState() => _CustomSerialProtocolState();
}

class _CustomSerialProtocolState extends State<CustomSerialProtocol> {
  List<SerialProtocolText> _textList = [];
  final textController = TextEditingController();
  final RegExp englishRegExp = RegExp(r'^[\x00-\x7F]*$');

  String _selectedAlignment = 'Right';
  List<String> alignments = ['Left', 'Right'];

  int count = 0;

  TextEditingController myContent =
      TextEditingController(text: mySerialProtocolText.content);
  TextEditingController myMaxLen =
      TextEditingController(text: mySerialProtocolText.maxLength.toString());

  TextEditingController myDefault1 =
      TextEditingController(text: mySerialProtocolText.default1);
  TextEditingController myDefault2 =
      TextEditingController(text: mySerialProtocolText.default2);
  final List<String> _buttonLabels = [
    'Text',
    'Net',
    'Gross',
    'Tare',
    'WeightUnit',
    'IsStable',
    'IsTare',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          height: 50,
          width: screenSize.width - 10,
          color: Colors.blue.shade900,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(
                width: 150,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // 设置按钮的背景色
                    elevation: 10, // 设置按钮的阴影
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // 设置按钮的圆角
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(
                          Icons.home,
                          color: Colors.blue.shade900,
                        ),
                        Text(
                          'Home',
                          style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              SizedBox(
                width: 150,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // 设置按钮的背景色
                    elevation: 10, // 设置按钮的阴影
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // 设置按钮的圆角
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(
                          Icons.download,
                          color: Colors.green.shade900,
                        ),
                        Text(
                          'Download',
                          style: TextStyle(
                              color: Colors.green.shade900,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  onPressed: () {
                    _sendToScale();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: _buttonLabels.length + 1, // +1是为了添加"Enter"按钮
              itemBuilder: (context, index) {
                if (index == _buttonLabels.length) {
                  // 最后一个是"Enter"按钮
                  return TextButton(
                    onPressed: () {
                      setState(() {
                        _addEnter();
                      });
                    },
                    child: const Text('Enter'),
                  );
                }
                final label = _buttonLabels[index];
                return TextButton(
                  onPressed: () {
                    setState(() {
                      if (label == 'Text') {
                        _addTextData();
                      } else {
                        _addVarData(label);
                      }
                    });
                  },
                  child: Text(label),
                );
              },
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              height: 1200,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(width: 0.2, color: Colors.black)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 5,
                    child: ListView(
                      children: [
                        SizedBox(
                          height: 50,
                          child: Center(
                            child: Text(
                              'Custom serial protocol:',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900),
                            ),
                          ),
                        ),
                        _buildTexts(),
                      ],
                    ),
                  ),
                  Divider(
                    height: 2,
                    color: Colors.blue.shade900,
                  ),
                  Expanded(
                    flex: 4,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            height: 30,
                            child: const Center(
                              child: Text(
                                'Serial port output preview',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            color: Colors.blue.shade900,
                          ),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              color: const Color.fromARGB(255, 223, 223, 223),
                              child: SingleChildScrollView(
                                child: Text(
                                  _getOutputData(),
                                  style:
                                      const TextStyle(fontSize: 16), // 设置文本样式
                                ),
                              ),
                            ),
                          ),
                        ]),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: ListView(
              children: (_textList.isNotEmpty &&
                      mySerialProtocolText.type == 'VARIABLE' &&
                      mySerialProtocolText.tabOrder != 9999 &&
                      (mySerialProtocolText.varName == 'IsStable' ||
                          mySerialProtocolText.varName == 'IsTare'))
                  ? _isStableTare()
                  : (_textList.isNotEmpty &&
                          mySerialProtocolText.type == 'TEXT' &&
                          mySerialProtocolText.tabOrder != 9999)
                      ? _textProperty()
                      : (_textList.isNotEmpty &&
                              mySerialProtocolText.type == 'VARIABLE' &&
                              mySerialProtocolText.tabOrder != 9999)
                          ? _varProperty()
                          : (_textList.isNotEmpty &&
                                  mySerialProtocolText.type == 'Enter')
                              ? _enterProperty()
                              : [],
            ),
          )
        ],
      ),
    );
  }

  void _addEnter() {
    _textList.add(SerialProtocolText(
        'Enter', '\\r\\n', '', 'Right', 0, ++count, '', '', '', '', '', false));
    setState(() {
      mySerialProtocolText = _textList[_textList.length - 1];
      _changeSelect(_textList.length - 1);
    });
  }

  void _sendToScale() {
    String json = jsonEncode(_textList);

    print(json);

    // final buffer = StringBuffer('SO');
    // for (final text in _textList) {
    //   if (text.type == 'TEXT') {
    //     buffer.write(',TEXT,${text.content}');
    //   } else if (text.type == 'VARIABLE') {
    //     final temp =
    //         '${text.varName},${text.default1},${text.default2},${text.default3},${text.default4},${text.default5},';
    //     buffer.write(
    //         ',VAR,$temp${text.alignment == 'Left' ? '1' : '3'},${text.maxLength}');
    //   }
    // }
    // final sendData = buffer.toString();
    // if (kDebugMode) {
    //   print(sendData);
    // }
  }

  String _getOutputData() {
    String res = '';
    for (var i = 0; i < _textList.length; i++) {
      if (_textList[i].type == 'TEXT') {
        res = res + _textList[i].content;
      } else if (_textList[i].type == 'VARIABLE') {
        if (_textList[i].varName == 'IsStable' ||
            _textList[i].varName == 'IsTare') {
          res = res + _textList[i].default1;
        } else {
          res = res + _textList[i].content;
        }
      } else if (_textList[i].type == 'Enter') {
        res = res + '\r\n';
      }
    }
    return res;
  }

  _isStableTare() {
    return [
      Container(
        height: 40,
        color: Colors.yellow.shade900,
        child: const Center(
          child: Text(
            'Text Property',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
      ),
      const SizedBox(
        height: 20,
      ),
      Text(
        'Type:    ${mySerialProtocolText.type}',
        style: TextStyle(color: Colors.blue.shade900),
      ),
      const SizedBox(
        height: 20,
      ),
      Text(
        (mySerialProtocolText.varName == 'IsStable')
            ? 'Stable Text:'
            : 'Gross Text',
        style: TextStyle(color: Colors.blue.shade900),
      ),
      TextField(
        controller: myDefault1,
        onChanged: (value) {
          setState(() {
            _changedDefault(mySerialProtocolText.tabOrder, value, 1);
          });
        },
        textAlignVertical: TextAlignVertical.top,
        inputFormatters: [
          FilteringTextInputFormatter.allow(englishRegExp), // 传入正则表达式
        ],
        decoration: const InputDecoration(),
      ),
      const SizedBox(
        height: 20,
      ),
      Text(
        (mySerialProtocolText.varName == 'IsStable')
            ? 'Unstable Text:'
            : 'Net Text',
        style: TextStyle(color: Colors.blue.shade900),
      ),
      TextField(
        controller: myDefault2,
        onChanged: (value) {
          setState(() {
            _changedDefault(mySerialProtocolText.tabOrder, value, 2);
          });
        },
        textAlignVertical: TextAlignVertical.top,
        inputFormatters: [
          FilteringTextInputFormatter.allow(englishRegExp), // 传入正则表达式
        ],
        decoration: const InputDecoration(),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(
            width: 50,
          ),
          IconButton(
              onPressed: () {
                setState(() {
                  _itemBack(mySerialProtocolText.tabOrder);
                });
              },
              icon: Icon(
                  size: 40, Icons.arrow_back, color: Colors.blue.shade900)),
          const SizedBox(
            width: 50,
          ),
          IconButton(
              onPressed: () {
                setState(() {
                  _itemForward(mySerialProtocolText.tabOrder);
                });
              },
              icon: Icon(
                  size: 40, Icons.arrow_forward, color: Colors.blue.shade900)),
          const SizedBox(
            width: 50,
          ),
        ],
      ),
      const SizedBox(
        height: 15,
      ),
      ElevatedButton(
          onPressed: () {
            setState(() {
              _deleteItem();
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade900, // 设置按钮的背景色
            elevation: 10, // 设置按钮的阴影
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // 设置按钮的圆角
            ),
          ),
          child: const Text('Delete',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ))),
      const SizedBox(
        height: 50,
      ),
      const SizedBox(
        height: 50,
      ),
    ];
  }

  void _changedDefault(int index, String data, int defaultIndex) {
    for (var i = 0; i < _textList.length; i++) {
      if (_textList[i].tabOrder == index) {
        if (defaultIndex == 1) {
          _textList[i].default1 = data;
        } else {
          _textList[i].default2 = data;
        }

        break;
      }
    }
  }

  _enterProperty() {
    return [
      Container(
        height: 40,
        color: Colors.yellow.shade900,
        child: const Center(
          child: Text(
            'Enter Property',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
      ),
      const SizedBox(
        height: 20,
      ),
      Text(
        'Type:    ${mySerialProtocolText.type}',
        style: TextStyle(color: Colors.blue.shade900),
      ),
      const SizedBox(
        height: 20,
      ),
      Text(
        'Content:    \\r\\n',
        style: TextStyle(color: Colors.blue.shade900),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(
            width: 50,
          ),
          IconButton(
              onPressed: () {
                setState(() {
                  _itemBack(mySerialProtocolText.tabOrder);
                });
              },
              icon: Icon(
                  size: 40, Icons.arrow_back, color: Colors.blue.shade900)),
          const SizedBox(
            width: 50,
          ),
          IconButton(
              onPressed: () {
                setState(() {
                  _itemForward(mySerialProtocolText.tabOrder);
                });
              },
              icon: Icon(
                  size: 40, Icons.arrow_forward, color: Colors.blue.shade900)),
          const SizedBox(
            width: 50,
          ),
        ],
      ),
      const SizedBox(
        height: 15,
      ),
      ElevatedButton(
          onPressed: () {
            setState(() {
              _deleteItem();
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade900, // 设置按钮的背景色
            elevation: 10, // 设置按钮的阴影
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // 设置按钮的圆角
            ),
          ),
          child: const Text('Delete',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ))),
    ];
  }

  _textProperty() {
    return [
      Container(
        height: 40,
        color: Colors.yellow.shade900,
        child: const Center(
          child: Text(
            'Text Property',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
      ),
      const SizedBox(
        height: 20,
      ),
      Text(
        'Type:    ${mySerialProtocolText.type}',
        style: TextStyle(color: Colors.blue.shade900),
      ),
      const SizedBox(
        height: 20,
      ),
      Text(
        'Content:',
        style: TextStyle(color: Colors.blue.shade900),
      ),
      TextField(
        controller: myContent,
        onChanged: (value) {
          setState(() {
            _changedContent(value);
          });
        },
        textAlignVertical: TextAlignVertical.top,
        inputFormatters: [
          FilteringTextInputFormatter.allow(englishRegExp), // 传入正则表达式
        ],
        decoration: const InputDecoration(),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(
            width: 50,
          ),
          IconButton(
              onPressed: () {
                setState(() {
                  _itemBack(mySerialProtocolText.tabOrder);
                });
              },
              icon: Icon(
                  size: 40, Icons.arrow_back, color: Colors.blue.shade900)),
          const SizedBox(
            width: 50,
          ),
          IconButton(
              onPressed: () {
                setState(() {
                  _itemForward(mySerialProtocolText.tabOrder);
                });
              },
              icon: Icon(
                  size: 40, Icons.arrow_forward, color: Colors.blue.shade900)),
          const SizedBox(
            width: 50,
          ),
        ],
      ),
      const SizedBox(
        height: 15,
      ),
      ElevatedButton(
          onPressed: () {
            setState(() {
              _deleteItem();
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade900, // 设置按钮的背景色
            elevation: 10, // 设置按钮的阴影
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // 设置按钮的圆角
            ),
          ),
          child: const Text('Delete',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ))),
    ];
  }

  _changedContent(String data) {
    for (var i = 0; i < _textList.length; i++) {
      if (_textList[i].tabOrder == mySerialProtocolText.tabOrder) {
        _textList[i].content = data;
        break;
      }
    }
  }

  _changedAlignment(String data) {
    for (var i = 0; i < _textList.length; i++) {
      if (_textList[i].tabOrder == mySerialProtocolText.tabOrder) {
        _textList[i].alignment = data;
        if (_textList[i].varName == 'WeightUnit') {
          if (_textList[i].maxLength == 0) {
            _textList[i].content = 'kg';
          } else {
            _textList[i].content = '';
            String space = ' ';

            for (var j = 1; j <= _textList[i].maxLength; j++) {
              if (j == 1) {
                _textList[i].content = 'g';
              } else if (j == 2) {
                _textList[i].content = 'kg';
              } else {
                if (_textList[i].alignment == 'Left') {
                  _textList[i].content = _textList[i].content + space;
                } else {
                  _textList[i].content = space + _textList[i].content;
                }
              }
            }
          }
        }
        break;
      }
    }
  }

  _changedMaxLength(String data) {
    if (data == '') {
      data = '0';
    }
    for (var i = 0; i < _textList.length; i++) {
      if (_textList[i].tabOrder == mySerialProtocolText.tabOrder) {
        _textList[i].maxLength = int.parse(data);
        if (_textList[i].maxLength == 0) {
          if (_textList[i].varName == 'WeightUnit') {
            _textList[i].content = 'kg';
          } else {
            _textList[i].content = '000.000';
          }

          myContent.text = _textList[i].content;
        } else {
          _textList[i].content = '';
          String space = ' ';
          if (_textList[i].varName == 'WeightUnit') {
            for (var j = 1; j <= _textList[i].maxLength; j++) {
              if (j == 1) {
                _textList[i].content = 'g';
              } else if (j == 2) {
                _textList[i].content = 'kg';
              } else {
                if (_textList[i].alignment == 'Left') {
                  _textList[i].content = _textList[i].content + space;
                } else {
                  _textList[i].content = space + _textList[i].content;
                }
              }
            }
          } else {
            for (var j = 0; j < _textList[i].maxLength; j++) {
              if (j < 10) {
                _textList[i].content = _textList[i].content + j.toString();
              } else if (j < 20) {
                _textList[i].content =
                    _textList[i].content + (j - 10).toString();
              } else {
                _textList[i].content =
                    _textList[i].content + (j - 20).toString();
              }
            }
          }

          myContent.text = _textList[i].content;
        }
        break;
      }
    }
  }

  _varProperty() {
    return [
      Container(
        height: 40,
        color: Colors.yellow.shade900,
        child: const Center(
          child: Text(
            'Variable Property',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
      ),
      const SizedBox(
        height: 20,
      ),
      Text(
        'Type:    ${mySerialProtocolText.type}',
        style: TextStyle(color: Colors.blue.shade900),
      ),
      const SizedBox(
        height: 20,
      ),
      Text(
        'Alignment:',
        style: TextStyle(color: Colors.blue.shade900),
      ),
      DropdownButton<String>(
        dropdownColor: Colors.grey[400],
        style: const TextStyle(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.normal),
        hint: const Text(
          'Alignment:',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        value: _selectedAlignment,
        items: alignments
            .map((String value) => DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                ))
            .toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedAlignment = newValue!;
            _changedAlignment(_selectedAlignment);
            myContent.text = mySerialProtocolText.content;
          });
        },
      ),
      Text(
        'Max Length:',
        style: TextStyle(color: Colors.blue.shade900),
      ),
      TextField(
        controller: myMaxLen,
        onChanged: (value) {
          setState(() {
            _changedMaxLength(value);
          });
        },
        textAlignVertical: TextAlignVertical.top,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(
            RegExp(r'^([0-9]|1[0-9]|20)$'),
          ), // 传入正则表达式
        ],
        decoration: const InputDecoration(),
      ),
      Text(
        'Default Value:',
        style: TextStyle(color: Colors.blue.shade900),
      ),
      TextField(
        readOnly: true,
        controller: myContent,
        onChanged: (value) {
          setState(() {
            _changedContent(value);
          });
        },
        textAlignVertical: TextAlignVertical.top,
        inputFormatters: [
          FilteringTextInputFormatter.allow(englishRegExp), // 传入正则表达式
        ],
        decoration: const InputDecoration(),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(
            width: 50,
          ),
          IconButton(
              onPressed: () {
                setState(() {
                  _itemBack(mySerialProtocolText.tabOrder);
                });
              },
              icon: Icon(
                  size: 40, Icons.arrow_back, color: Colors.blue.shade900)),
          const SizedBox(
            width: 50,
          ),
          IconButton(
              onPressed: () {
                setState(() {
                  _itemForward(mySerialProtocolText.tabOrder);
                });
              },
              icon: Icon(
                  size: 40, Icons.arrow_forward, color: Colors.blue.shade900)),
          const SizedBox(
            width: 50,
          ),
        ],
      ),
      const SizedBox(
        height: 15,
      ),
      ElevatedButton(
          onPressed: () {
            setState(() {
              _deleteItem();
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade900, // 设置按钮的背景色
            elevation: 10, // 设置按钮的阴影
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // 设置按钮的圆角
            ),
          ),
          child: const Text('Delete',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ))),
      const SizedBox(
        height: 50,
      ),
      const SizedBox(
        height: 50,
      ),
    ];
  }

  void _itemBack(int index) {
    SerialProtocolText tempData = SerialProtocolText('TEXT', 'Text', '',
        'Right', 0, _textList.length, '', '', '', '', '', false);

    for (var i = 0; i < _textList.length; i++) {
      if (_textList[i].tabOrder == index) {
        tempData = _textList[i];
        if (i != 0) {
          _textList[i] = _textList[i - 1];
          _textList[i - 1] = tempData;
        }
        break;
      }
    }
  }

  void _itemForward(int index) {
    SerialProtocolText tempData = SerialProtocolText('TEXT', 'Text', '',
        'Right', 0, _textList.length, '', '', '', '', '', false);

    for (var i = 0; i < _textList.length; i++) {
      if (_textList[i].tabOrder == index) {
        tempData = _textList[i];
        if (i + 1 < _textList.length) {
          _textList[i] = _textList[i + 1];
          _textList[i + 1] = tempData;
        }
        break;
      }
    }
  }

  Widget _buildTexts() {
    return Wrap(
      alignment: WrapAlignment.start,
      runAlignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: [
        for (var i = 0; i < _textList.length; i++)
          _buildTextContent(_textList[i]),
      ],
    );
  }

  void _deleteItem() {
    for (var i = 0; i < _textList.length; i++) {
      if (_textList[i].tabOrder == mySerialProtocolText.tabOrder) {
        _textList.removeAt(i);
        mySerialProtocolText.tabOrder = 9999;
        break;
      }
    }
  }

  void _addTextData() {
    _textList.add(SerialProtocolText(
        'TEXT', 'Text', '', 'Right', 0, ++count, '', '', '', '', '', false));
    setState(() {
      mySerialProtocolText = _textList[_textList.length - 1];
      myContent.text = mySerialProtocolText.content;
      _changeSelect(_textList.length - 1);
    });
  }

  _changeSelect(int index) {
    for (var i = 0; i < _textList.length; i++) {
      _textList[i].isSelect = false;
    }
    _textList[index].isSelect = true;
  }

  void _addVarData(String varname) {
    if (varname == 'WeightUnit') {
      _textList.add(SerialProtocolText('VARIABLE', ' kg', varname, 'Right', 3,
          ++count, '', '', '', '', '', false));
    } else if (varname == 'IsStable') {
      _textList.add(SerialProtocolText('VARIABLE', ' kg', varname, 'Right', 3,
          ++count, 'US', 'ST', '', '', '', false));
    } else if (varname == 'IsTare') {
      _textList.add(SerialProtocolText('VARIABLE', ' kg', varname, 'Right', 3,
          ++count, 'GS', 'NT', '', '', '', false));
    } else {
      _textList.add(SerialProtocolText('VARIABLE', '0123456', varname, 'Right',
          7, ++count, '', '', '', '', '', false));
    }
    setState(() {
      mySerialProtocolText = _textList[_textList.length - 1];
      myContent.text = mySerialProtocolText.content;
      myMaxLen.text = mySerialProtocolText.maxLength.toString();
      myDefault1.text = mySerialProtocolText.default1;
      myDefault2.text = mySerialProtocolText.default2;

      _changeSelect(_textList.length - 1);
    });
  }

  Widget _buildTextContent(SerialProtocolText textData) {
    return Container(
      height: 30,
      width: 100,
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.blue.shade900),
      ),
      child: TextButton(
        style: ButtonStyle(
            backgroundColor: (textData.isSelect)
                ? MaterialStateProperty.all(Colors.blue.shade900)
                : null),
        onPressed: () {
          setState(() {
            mySerialProtocolText = textData;
            myContent.text = mySerialProtocolText.content;
            myMaxLen.text = mySerialProtocolText.maxLength.toString();
            _selectedAlignment = mySerialProtocolText.alignment;
            myDefault1.text = mySerialProtocolText.default1;
            myDefault2.text = mySerialProtocolText.default2;
            for (var i = 0; i < _textList.length; i++) {
              if (_textList[i].tabOrder == textData.tabOrder) {
                _changeSelect(i);
                break;
              }
            }
          });
        },
        child: Text(
          (textData.type == 'VARIABLE') ? textData.varName : textData.content,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: (textData.isSelect) ? Colors.white : Colors.blue.shade900),
        ),
      ),
    );
  }
}
