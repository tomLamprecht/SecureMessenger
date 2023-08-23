
import 'dart:convert';
import 'dart:developer';
import '../custom_http_client.dart';
import '../models/account.dart';
import 'api/api_config.dart';

class AccountService {
  Future<Account?> getAccountByUsername(String username) async {
    try {
      final url = Uri.parse('${ApiConfig.httpBaseUrl}/accounts/by-username/$username');
      final response = await CustomHttpClient().get(url);
      if (response.statusCode == 200) {
        print("Im accService if 200");
        print(response.body);
        final dynamic jsonAcc = json.decode(response.body);
        return Account.fromJson(jsonAcc);

      } else {
        log("Keinen Account gefunden bei GET-Request");
        return null;
      }
    }
    catch (e) {
      print("Exption: $e");
    }
    return null;

  }
}
