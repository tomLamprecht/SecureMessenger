import 'package:flutter/material.dart';
import 'package:my_flutter_test/screens/chat_overview_screen.dart';
import 'package:my_flutter_test/screens/chat_screen.dart';
import 'package:my_flutter_test/screens/login_screen.dart';
import 'package:my_flutter_test/services/stores/rsa_key_store.dart';

void main() {
  var ec = getP256();
  var priv = ec.generatePrivateKey();
  var pub = priv.publicKey;
  print(priv);
  print(pub);

}