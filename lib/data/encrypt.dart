import 'package:encrypt/encrypt.dart';

class MyEncryptClass {
  final Key myKey;
  MyEncryptClass(this.myKey);

  encryptString(String plainText) {
    final encrypter = Encrypter(AES(myKey));
    final iv = IV.fromLength(16);
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    String encryptedText = '${iv.base64}${encrypted.base64}';
    return encryptedText;
  }

  addNewString(String newString, oldEncryptString) {
    final encrypter = Encrypter(AES(myKey));
    String ivString = oldEncryptString.substring(0, 24);
    final iv = IV.fromBase64(ivString);
    final firstStr = oldEncryptString.substring(24);
    final encrypted = Encrypted.fromBase64(firstStr);
    final decrypted = encrypter.decrypt(encrypted, iv: iv);
    final newEncrypted = encrypter.encrypt(decrypted + newString, iv: iv);
    String newEncryptedText = newEncrypted.base64;

    return ivString + newEncryptedText;
  }

  decryptString(String encryptedText) {
    final encrypter = Encrypter(AES(myKey));

    String ivString = encryptedText.substring(0, 24);
    final iv = IV.fromBase64(ivString);
    final encryptedStr = encryptedText.substring(24);
    final encrypted = Encrypted.fromBase64(encryptedStr);
    final decrypted = encrypter.decrypt(encrypted, iv: iv);
    return decrypted;
  }
}

final myKey = Key.fromBase64('TSCALE20231201lPU1RFUk5PTk9XU09STlZFUlNJT04=');
MyEncryptClass mykeyClass = MyEncryptClass(myKey);
