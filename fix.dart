import 'dart:io';

void main() {
  File file = File('lib/pages/multi_scale_management_part_add.dart');
  String content = file.readAsStringSync();
  
  content = content.replaceAll(
    '''        Container(\r\n          height: 56,\r\n          color: Colors.white,\r\n          child: Row(''',
    '''        Container(\r\n          color: Colors.white,\r\n          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),\r\n          child: SizedBox(\r\n            height: 56,\r\n            child: Row('''
  );
  
  content = content.replaceAll(
    '''              ),\r\n            ],\r\n          ),\r\n        ),''',
    '''              ),\r\n            ],\r\n          ),\r\n          ),\r\n        ),'''
  );
  
  file.writeAsStringSync(content);
}
