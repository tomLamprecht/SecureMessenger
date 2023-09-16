class ApiConfig {
  static String httpBaseUrl = 'https://$baseUrl';
  static String websocketBaseUrl = 'wss://$baseUrl';
  static String baseUrl = Uri.base.origin.replaceAll("http://", "").replaceAll("https://", "");
}
