import 'package:my_flutter_test/services/auth_data.dart';

import 'encryption_service.dart';

AuthData ad = AuthData();
Map<String, String> authHeaders(String method, String path, String body) {
  final timestamp = DateTime.now();
  final signature = signMessage(ad.privateKey!, '$method#$path#$timestamp#$body');
  return {
    'x-public-key': ad.publicKey!,
    'x-auth-timestamp': timestamp.toIso8601String(),
    'x-auth-signature': signature,
  };
}