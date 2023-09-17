
import 'dart:convert';
import '../custom_http_client.dart';
import '../models/account.dart';
import 'api/api_config.dart';

class AccountService {

  Future<Account?> getAccountByUsername(String username) async {
    try {
      final url = Uri.parse('${ApiConfig.httpBaseUrl}/accounts/by-username/$username');
      final response = await CustomHttpClient().get(url);
      if (response.statusCode == 200) {
        final dynamic jsonAcc = json.decode(response.body);
        return Account.fromJson(jsonAcc);

      } else {
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

    final response = await CustomHttpClient().put(url, headers: headers, body: body);

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
