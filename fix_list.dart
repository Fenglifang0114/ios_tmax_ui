import 'dart:io';

void main() {
  File file = File('lib/pages/multi_scale_management_part_list.dart');
  String content = file.readAsStringSync();
  
  content = content.replaceAll(
    '''            Container(\r\n              height: 50,\r\n              color: Theme.of(context).colorScheme.surface,\r\n              child: Row(''',
    '''            Container(\r\n              color: Theme.of(context).colorScheme.surface,\r\n              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),\r\n              child: SizedBox(\r\n                height: 50,\r\n                child: Row('''
  );
  
  content = content.replaceAll(
    '''                  SizedBox(width: 8),\r\n                ],\r\n              ),\r\n            ),''',
    '''                  SizedBox(width: 8),\r\n                ],\r\n              ),\r\n              ),\r\n            ),'''
  );
  
  file.writeAsStringSync(content);
}
