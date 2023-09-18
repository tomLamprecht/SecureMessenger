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
    print("inside cache method");
    if (cachedPicAccounts.containsKey(accountName)) {
      print("Found value for $accountName");
      return cachedPicAccounts[accountName];
    }
    print("requesting pic for $accountName");
    var accountInformation = await AccountService().getAccountByUsername(accountName);
    if (accountInformation == null) {
      throw Exception("Got empty account.");
    }
    if (accountInformation.encodedProfilePic != null) {
      print("Got a pic for $accountName caching it...");
      final imageDataBytes = Uint8List.fromList(base64Decode(accountInformation.encodedProfilePic!));
      cachedPicAccounts.putIfAbsent(accountName, () => imageDataBytes);
      print("cached pics: ${cachedPicAccounts.length}");
      return imageDataBytes;
    } else {
      print("had no pic for $accountName");
      cachedPicAccounts.putIfAbsent(accountName, () => null);
      print("cached pics: ${cachedPicAccounts.length}");
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
