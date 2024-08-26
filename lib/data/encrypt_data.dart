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

  String decryptCsv(String encryptedStr) {
    List<int> encryptedBytes = encryptedStr.codeUnits;
    List<int> decryptedBytes = [];
    for (int i = 0; i < encryptedBytes.length; i += 2) {
      int decryptedByte1 = (encryptedBytes[i] - 3) << 4;
      int decryptedByte2 = (encryptedBytes[i + 1] - 3) & 0x0F;
      decryptedBytes.add(decryptedByte1 | decryptedByte2);
    }
    String utf8String = utf8.decode(decryptedBytes);
    return utf8String;
  }
}

FilePassword myFilePassword = FilePassword();
