class AuthData {
  // Private constructor
  AuthData._privateConstructor();

  String? publicKey;
  String? privateKey;

  // Single instance of the class
  static final AuthData _instance = AuthData._privateConstructor();

  // Factory method to provide access to the single instance
  factory AuthData() {
    return _instance;
  }

}