import 'dart:convert';

import 'package:encrypt/encrypt.dart';

class MyEncrypt {
  final key = Key.fromUtf8('my32lengthsupersecretnooneknows1');
  final iv = IV.fromLength(16);
  encrypt(dynamic plaintext) {
    final b64key = Key.fromUtf8(base64Url.encode(key.bytes));
    // if you need to use the ttl feature, you'll need to use APIs in the algorithm itself
    final fernet = Fernet(b64key);
    final encrypter = Encrypter(fernet);

    final encrypted = encrypter.encrypt(plaintext);
    final decrypted = encrypter.decrypt(encrypted);

    print(decrypted); // Lorem ipsum dolor sit amet, consectetur adipiscing elit
    print(encrypted.base64); // random cipher text
    print(fernet.extractTimestamp(encrypted.bytes)); // unix timestamp
  }
}
