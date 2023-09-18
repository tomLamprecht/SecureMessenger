import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:securemessenger/services/account_service.dart';

import '../../models/account.dart';

class AccountInformationStore {
  static final AccountInformationStore _instance = AccountInformationStore._();

  factory AccountInformationStore() => _instance;

  Map<String, Account> cachedAccounts = {};

  Map<String, Uint8List?> cachedPicAccounts = {};

  AccountInformationStore._();

  Future<Account?> getPublicInformationByUsername(String accountName) async {
    if (cachedAccounts.containsKey(accountName)) {
      return cachedAccounts[accountName]!;
    } else {
      var accountInformation =
          await AccountService().getAccountByUsername(accountName);
      if (accountInformation == null) {
        return null;
      }
      cachedAccounts.putIfAbsent(accountName, () => accountInformation);
      return accountInformation;
    }
  }

  Future<Uint8List?> getProfilePicByUsername(String accountName) async {
    if (cachedPicAccounts.containsKey(accountName)) {
      return cachedPicAccounts[accountName];
    }
    var accountInformation = await AccountService().getAccountByUsername(accountName);
    if (accountInformation == null) {
      throw Exception("Got empty account.");
    }
    if (accountInformation.encodedProfilePic != null) {
      final imageDataBytes = Uint8List.fromList(base64Decode(accountInformation.encodedProfilePic!));
      cachedPicAccounts.putIfAbsent(accountName, () => imageDataBytes);
      return imageDataBytes;
    } else {
      cachedPicAccounts.putIfAbsent(accountName, () => null);
      return null;
    }
  }

  void updatePublicInformation(Account account) {
    cachedAccounts[account.userName] = account;
  }

  void invalidateCache() {
    cachedAccounts = {};
  }

  void invalidateForUsername(String s) {
    cachedAccounts.remove(s);
    cachedPicAccounts.remove(s);
  }
}
