
class WhoAmIStore {
  static final WhoAmIStore _instance = WhoAmIStore._();

  factory WhoAmIStore() => _instance;

  int? accountId;
  String? username;
  String? publicKey;

  WhoAmIStore._();
}
