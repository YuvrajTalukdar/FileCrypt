import 'package:encrypt/encrypt.dart';

import 'dart:convert';
import 'package:crypto/crypto.dart';

class aes
{
  String encrypt(String plainText,String pass)
  {
    var iv = sha256.convert(utf8.encode(pass)).toString().substring(0, 16);// Consider the first 16 bytes of all 64 bytes
    var key = sha256.convert(utf8.encode(pass)).toString().substring(0, 32);// Consider the first 32 bytes of all 64 bytes

    IV ivObj = IV.fromUtf8(iv);
    Key keyObj = Key.fromUtf8(key);
    final encrypter = Encrypter(AES(keyObj, mode: AESMode.cbc));// Apply CBC mode
    final encrypted = encrypter.encrypt(plainText,iv: ivObj);// Second Base64 decoding (during decryption)
    return encrypted.base64;
  }

  String decrypt(String payload,String pass)
  {
    try {
      var iv = sha256.convert(utf8.encode(pass)).toString().substring(0, 16); // Consider the first 16 bytes of all 64 bytes
      var key = sha256.convert(utf8.encode(pass)).toString().substring(0, 32); // Consider the first 32 bytes of all 64 bytes

      IV ivObj = IV.fromUtf8(iv);
      Key keyObj = Key.fromUtf8(key);
      final encrypter = Encrypter(AES(keyObj, mode: AESMode.cbc)); // Apply CBC mode
      final decrypted = encrypter.decrypt(Encrypted.fromBase64(payload),iv: ivObj); // First Base64 decoding (during decryption)
      return decrypted;
    }
    catch(excemption)
    { return "";}
  }
}