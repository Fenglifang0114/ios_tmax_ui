import 'dart:io';

void main() {
  File file = File('lib/pages/multi_scale_management_part_add.dart');
  String content = file.readAsStringSync();
  
  content = content.replaceAll(
    '''              ),\r\n            ],\r\n          ),\r\n        ),\r\n        // List items''',
    '''              ),\r\n            ],\r\n          ),\r\n          ),\r\n        ),\r\n        // List items'''
  );
  
  content = content.replaceAll(
    '''              else\r\n                const SizedBox(width: 48), // Place holder to keep title centered\r\n            ],\r\n          ),\r\n        ),\r\n        // Body''',
    '''              else\r\n                const SizedBox(width: 48), // Place holder to keep title centered\r\n            ],\r\n          ),\r\n          ),\r\n        ),\r\n        // Body'''
  );

  file.writeAsStringSync(content);
}
