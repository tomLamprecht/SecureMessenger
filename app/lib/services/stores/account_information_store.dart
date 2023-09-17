
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:my_flutter_test/services/account_service.dart';

import '../../models/account.dart';

class AccountInformationStore {
  static final AccountInformationStore _instance = AccountInformationStore._();

  factory AccountInformationStore() => _instance;

  Map<String, Account> cachedAccounts = {};

  Map<MemoryImage, Account> cachedPicAccounts = {};

  AccountInformationStore._();

  Future<Account?> getPublicInformationByUsername(String accountName) async {
    if (cachedAccounts.containsKey(accountName)) {
      return cachedAccounts[accountName]!;
    } else {
      var accountInformation = await AccountService().getAccountByUsername(accountName);
      if (accountInformation == null) {
        // throw Exception("Got empty account.");
        return null;
      }
      cachedAccounts.putIfAbsent(accountName, () => accountInformation);
      return accountInformation;
    }
  }

  Future<MemoryImage?> getPubDecode(String accountName) async {
    Uint8List bytes = Uint8List.fromList([
      255, 0, 0, 255, // Rot
      0, 0, 0, 255,   // Transparent
      0, 0, 0, 255,   // Transparent
      255, 0, 0, 255, // Rot
    ]);
    if (cachedPicAccounts.containsValue(accountName)) {
      MemoryImage image = MemoryImage(bytes);
      cachedPicAccounts.forEach((pic, acc) {
        if(acc.userName == accountName){
          image = pic;
        }
      });
      return image;
    } else {
      var accountInformation = await AccountService().getAccountByUsername(accountName);
      if (accountInformation == null) {
        throw Exception("Got empty account.");
      }
      if(accountInformation.encodedProfilePic != null){
        final imageDataBytes = Uint8List.fromList(base64Decode(accountInformation.encodedProfilePic!));
        cachedPicAccounts.putIfAbsent(MemoryImage(imageDataBytes), () => accountInformation);
        return MemoryImage(imageDataBytes);
      } else {
        return null;
      }
    }
  }


  void updatePublicInformation(Account account) {
    cachedAccounts[account.userName] = account;
  }
  void invalidateCache() {
    cachedAccounts = {};
  }
}
