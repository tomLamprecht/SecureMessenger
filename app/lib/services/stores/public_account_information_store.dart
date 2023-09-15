
import 'package:my_flutter_test/services/account_service.dart';

import '../../models/account.dart';

class AccountInformationStore {
  static final AccountInformationStore _instance = AccountInformationStore._();

  factory AccountInformationStore() => _instance;

  Map<String, Account> cachedAccounts = {};

  AccountInformationStore._();

  Future<Account> getPublicInformationByUsername(String accountName) async {
    if (cachedAccounts.containsKey(accountName)) {
      return cachedAccounts[accountName]!;
    } else {
      var accountInformation = await AccountService().getAccountByUsername(accountName);
      if (accountInformation == null) {
        throw Exception("Got empty account.");
      }
      cachedAccounts.putIfAbsent(accountName, () => accountInformation);
      return accountInformation;
    }
  }
}
