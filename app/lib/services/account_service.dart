
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

  Future<Account?> getAccountProfilPic() async {
    try {
      final url = Uri.parse('${ApiConfig.httpBaseUrl}/accounts/whoami');
      final response = await CustomHttpClient().get(url);
      if (response.statusCode == 200) {

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


  Future<bool> updateProfilPic(String encodedGroupPic) async{
    final url = Uri.parse('${ApiConfig.httpBaseUrl}/accounts/update-profil-pic');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({"encodedGroupPic": encodedGroupPic});

    print("Hier in Methode Update ");

    final response = await CustomHttpClient().put(url, headers: headers, body: body);
    print("Hier in Methode Update ${response.statusCode}"); //TODO 404 als Response

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> deleteProfilPic() async {
    final url = Uri.parse('${ApiConfig.httpBaseUrl}/accounts/delete-profil-pic');
    final headers = {'Content-Type': 'application/json'};
    final response = await CustomHttpClient().delete(url, headers: headers);
    if (response.statusCode == 204) {
      return true;
    } else {
      return false;
    }
  }
}
