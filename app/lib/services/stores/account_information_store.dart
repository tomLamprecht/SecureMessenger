import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:my_flutter_test/services/account_service.dart';

import '../../models/account.dart';

class AccountInformationStore {
  static final AccountInformationStore _instance = AccountInformationStore._();

  factory AccountInformationStore() => _instance;

  Map<String, Account> cachedAccounts = {};

  Map<String, MemoryImage?> cachedPicAccounts = {};

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

  Future<MemoryImage?> getProfilePicByUsername(String accountName) async {
    if (cachedPicAccounts.containsKey(accountName)) {
      return cachedPicAccounts[accountName];
    }
    var accountInformation = await AccountService().getAccountByUsername(accountName);
    if (accountInformation == null) {
      throw Exception("Got empty account.");
    }
    if (accountInformation.encodedProfilePic != null) {
      final imageDataBytes = Uint8List.fromList(base64Decode(accountInformation.encodedProfilePic!));
      MemoryImage memoryImage = MemoryImage(imageDataBytes);
      cachedPicAccounts.putIfAbsent(accountName, () => memoryImage);
      return memoryImage;
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
}
