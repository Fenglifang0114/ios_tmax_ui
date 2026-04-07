import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:t_max/labeldesign/label_formatdata.dart';

class LabelDesignResult {
  final List<FromateItemData> elements;
  final double labelWidth;
  final double labelHeight;
  final String printer;
  final String direction;

  LabelDesignResult({
    required this.elements,
    required this.labelWidth,
    required this.labelHeight,
    required this.printer,
    required this.direction,
  });
}

class DeepSeekService {
  final String apiKey;
  final String baseUrl = "https://api.deepseek.com/v1";
  final Dio _dio = Dio();

  DeepSeekService({required this.apiKey});

  Future<LabelDesignResult> generateLabelFormat(String userRequirement) async {
    final url = "$baseUrl/chat/completions";
    
    const systemPrompt = """
You are a professional label design expert for a Flutter-based label designer. Generate a label design in JSON format based on the following strict rules and capabilities of our system (from 'label_design_page.dart').

### OUTPUT FORMAT
Return a valid JSON object with:
- 'labelWidth': float (default 55, unit: mm)
- 'labelHeight': float (default 50, unit: mm)
- 'printer': string ('EPM205', 'ZEBRA', 'LP50', 'TSC'. Default: 'EPM205')
- 'direction': string ('0' for Forward, '1' for Reverse. Default: '0')
- 'elements': array of objects.

### COORDINATE SYSTEM
- The canvas uses a density of 8 pixels per mm.
- xPos, yPos: (0 to labelWidth*8) and (0 to labelHeight*8).
- For vertical alignment (columns), use the same 'xPos' across multiple rows.

### ELEMENT TYPES AND PROPERTIES
1. 'text': Static text.
   - Requires 'content': The string to display.
2. 'data': Dynamic variables. 
   - Requires 'varName': Mapping to a system variable.
   - MUST use one of these strict English 'varName' values: 'Gross', 'Tare', 'Net', 'PCS', 'WeightUnit', 'DATE', 'TIME', 'U.WGT', 'U.WU', 'UnitWeight', 'Percent', 'TotalWeight', 'TotalCount', 'TotalPcs', 'NO.'
   - TRANSLATION RULE: If the user asks for a variable in Chinese, you MUST map it to the exact English 'varName'. Example: "毛重" -> 'Gross', "净重" -> 'Net', "皮重" -> 'Tare', "重量单位" -> 'WeightUnit'. NEVER use Chinese in 'varName'.
3. 'barcode': Barcode element.
   - Requires 'barcodeName', 'barcodeType' (e.g., 'Code128'), and 'hralignment' ('0' for none, '1' for Bottom).
4. 'qrcode': QR Code element.
   - Requires 'qrcodeName' and 'qrWidth' (String, '3' to '10').
5. 'line': For drawing horizontal or vertical lines.
   - Set 'width' (length/thickness) and 'height' (thickness/length). Example: Horizontal line xPos=0, yPos=100, width=440, height=2.

### STYLE RULES
- fontSize: ALWAYS use 23 by default unless specified.
- width: Do NOT include a 'width' field for 'text' and 'data' elements (the system will calculate it automatically based on length). For other elements (like 'line'), provide an appropriate width.
- height: For 'text' and 'data', ALWAYS use 30.
- maxLength: For 'data' elements, default to 10 unless specified.
- alignment: 1 (Left), 2 (Center), 3 (Right).
- rotation: 0, 90, 180, 270.
- fontBold/fontReverse: Use strings "true" or "false".
- Row Spacing: Use a vertical increment (yPos) of approximately 50 for distinct rows.
- Alignment & Layout: Elements on the same row MUST share the exact same 'yPos'. If multiple elements are on the same row, distribute them evenly across the label's 'xPos' width (space-between / dispersed alignment) by default unless requested otherwise.
- Margin/Padding: Unless the user explicitly requests specific coordinates, all elements MUST maintain a distance of at least 10 from the top (yPos >= 10), bottom, left (xPos >= 10), and right boundaries of the label.
- Canvas Boundaries: Maximum xPos is labelWidth*8. Maximum yPos is labelHeight*8. Make sure elements fit entirely within the canvas (e.g. for a 40x40 label, max xPos and yPos is 320).

### DEFAULT REFERENCE DESIGN
If the user provides a very generic requirement (e.g., "Design a label", "设计个标签", "设计一个标签") without specifying detailed elements, ALWAYS use the following JSON as your base reference design:
{
  "labelWidth": 55,
  "labelHeight": 50,
  "printer": "LP50",
  "direction": "0",
  "elements": [
    {"type": "data", "xPos": 80, "yPos": 46, "varName": "DATE", "alignment": 1, "maxLength": 10},
    {"type": "data", "xPos": 232, "yPos": 46, "varName": "TIME", "alignment": 1, "maxLength": 10},
    {"type": "text", "xPos": 80, "yPos": 98, "content": "S/NO:"},
    {"type": "data", "xPos": 194, "yPos": 98, "varName": "NO.", "alignment": 1, "maxLength": 10},
    {"type": "text", "xPos": 80, "yPos": 146, "content": "GROSS:"},
    {"type": "data", "xPos": 194, "yPos": 146, "varName": "Gross", "alignment": 3, "maxLength": 7},
    {"type": "data", "xPos": 285, "yPos": 146, "varName": "WeightUnit", "alignment": 1, "maxLength": 4},
    {"type": "text", "xPos": 80, "yPos": 190, "content": "TARE:"},
    {"type": "data", "xPos": 194, "yPos": 190, "varName": "Tare", "alignment": 3, "maxLength": 7},
    {"type": "data", "xPos": 285, "yPos": 190, "varName": "WeightUnit", "alignment": 1, "maxLength": 4},
    {"type": "text", "xPos": 80, "yPos": 240, "content": "NET:"},
    {"type": "data", "xPos": 194, "yPos": 240, "varName": "Net", "alignment": 3, "maxLength": 7},
    {"type": "data", "xPos": 285, "yPos": 240, "varName": "WeightUnit", "alignment": 1, "maxLength": 4}
  ]
}

Example Requirement: "Print Net Weight (净重), Gross Weight (毛重), and a horizontal divider line below them. 55x50mm label for EPM205."
Return ONLY the raw JSON string. Do NOT wrap the JSON in Markdown code blocks (e.g., no ```json).
""";

    try {
      final response = await _dio.post(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
        ),
        data: {
          'model': 'deepseek-chat',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userRequirement},
          ],
          'response_format': {'type': 'json_object'},
          'temperature': 0.7,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final String content = data['choices'][0]['message']['content'];
        final Map<String, dynamic> jsonContent = jsonDecode(content);
        
        double labelWidth = (jsonContent['labelWidth'] ?? 55).toDouble();
        double labelHeight = (jsonContent['labelHeight'] ?? 50).toDouble();
        String printer = jsonContent['printer'] ?? 'EPM205';
        String direction = jsonContent['direction'] ?? '0';
        List<dynamic> elementsJson = jsonContent['elements'] ?? [];
        
        List<FromateItemData> elements = elementsJson.map((e) {
          String type = e['type'] ?? 'text';
          String varName = e['varName'] ?? '';
          String content = e['content'] ?? (type == 'data' ? (varName.isNotEmpty ? varName : "DATA") : '');
          int fontSize = e['fontSize'] ?? 23;
          
          double calculatedWidth = 0.0;
          if (type == 'data') {
            int maxLength = e['maxLength'] ?? 10;
            calculatedWidth = maxLength * 16.0;
          } else {
            String textToMeasure = type == 'text' ? content : (varName.isNotEmpty ? varName : "DATA");
            for (int i = 0; i < textToMeasure.length; i++) {
              if (textToMeasure.codeUnitAt(i) > 255) {
                calculatedWidth += 28; // Chinese
              } else {
                calculatedWidth += 16; // English/ASCII
              }
            }
          }
          
          double defaultWidth = (type == 'text' || type == 'data') ? calculatedWidth : (e['width']?.toDouble() ?? calculatedWidth);
          double defaultHeight = (type == 'text' || type == 'data') ? 30.0 : (e['height']?.toDouble() ?? 40.0);

          // Sanitize input to avoid null-safety issues with FromateItemData.fromJson
          Map<String, dynamic> safeMap = {
            'type': type,
            'xPos': e['xPos'] ?? 0,
            'yPos': e['yPos'] ?? 0,
            'width': defaultWidth,
            'height': defaultHeight,
            'fontSize': fontSize,
            'fontWidthRatio': e['fontWidthRatio'] ?? 1,
            'fontHeightRatio': e['fontHeightRatio'] ?? 1,
            'alignment': e['alignment'] ?? 1,
            'maxLength': e['maxLength'] ?? 20,
            'rotation': e['rotation'] ?? 0,
            'style': e['style'] ?? 0,
            'tabOrder': e['tabOrder'] ?? 0,
            'varName': varName,
            'content': content,
            'defaultValue': e['defaultValue'] ?? '',
            'varcontent': e['varcontent'] ?? [],
            'barcodeName': e['barcodeName'] ?? '',
            'barcodeType': e['barcodeType'] ?? 'Code128',
            'hralignment': e['hralignment'] ?? '1',
            'x2Pos': e['x2Pos'] ?? 0,
            'y2Pos': e['y2Pos'] ?? 0,
            'lineWidth': e['lineWidth']?.toDouble() ?? 1.0,
            'qrWidth': e['qrWidth']?.toString() ?? '5',
            'qrcodeName': e['qrcodeName'] ?? '',
            'qrcodeType': e['qrcodeType'] ?? 'QR_CODE',
            'fontBold': e['fontBold']?.toString() ?? '0',
            'fontReverse': e['fontReverse']?.toString() ?? '0',
          };
          return FromateItemData.fromJson(safeMap);
        }).toList();

        return LabelDesignResult(
          elements: elements,
          labelWidth: labelWidth,
          labelHeight: labelHeight,
          printer: printer,
          direction: direction,
        );
      } else {
        throw Exception("Failed to generate label: ${response.statusMessage}");
      }
    } catch (e) {
      rethrow;
    }
  }
}
