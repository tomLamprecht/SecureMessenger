
import 'dart:convert';
import 'dart:developer';
import '../custom_http_client.dart';
import '../models/account.dart';
import 'api/api_config.dart';

class AccountService {
  Future<Account?> getAccountbyUsername(String username) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/accounts/by-username/$username');
    final headers = {'Content-Type': 'application/json'};
    final response = await CustomHttpClient().get(url, headers: headers);

    if (response.statusCode == 200) {
      final dynamic jsonAcc = json.decode(response.body);
      return Account.fromJson(jsonAcc);

    } else {
      log("Keinen Account gefunden bei GET-Request");
      return null;
    }
  }
}
