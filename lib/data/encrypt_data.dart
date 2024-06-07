import 'dart:convert';

class FilePassword {
  String encryptCsv(String csv) {
    List<int> encryptedBytes = [];
    List<int> utf8Bytes = utf8.encode(csv);

    for (int byte in utf8Bytes) {
      int encryptedByte1 = (byte >> 4) + 3; // 取高4位加密
      int encryptedByte2 = (byte & 0x0F) + 3; // 取低4位加密
      encryptedBytes.addAll([encryptedByte1, encryptedByte2]);
    }

    return String.fromCharCodes(encryptedBytes);
  }

  String decryptCsv(String encryptedCsv) {
    List<String> utf8Bytes = [];
    List<int> encryptedBytes = encryptedCsv.codeUnits;

    for (int i = 0; i < encryptedBytes.length;) {
      int encryptedByte1 = encryptedBytes[i++];
      int encryptedByte2 = encryptedBytes[i++];

      int decryptByte = ((encryptedByte1 - 3) << 4) | (encryptedByte2 - 3);
      utf8Bytes.add(String.fromCharCode(decryptByte));
    }

    return utf8Bytes.join('');
  }
}

FilePassword myFilePassword = FilePassword();
