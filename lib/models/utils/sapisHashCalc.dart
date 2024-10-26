import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

Future<String> getSApiSidHash(String sapisid) async {
  // Get Unix seconds and round down
  int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  
  // Create the string to hash
  String dataToHash = '$timestamp $sapisid https://music.youtube.com';
  
  // Convert string to bytes
  List<int> bytes = utf8.encode(dataToHash);
  
  // Generate SHA-1 hash
  Digest digest = sha1.convert(bytes);
  
  // Get raw bytes from digest
  Uint8List hashBytes = Uint8List.fromList(digest.bytes);
  
  // Convert to hex string, ensuring each byte is padded to 2 digits
  String hexDigest = hashBytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('');
  
  // Return final hash in required format with _u suffix
  return '${timestamp}_${hexDigest}';
}
