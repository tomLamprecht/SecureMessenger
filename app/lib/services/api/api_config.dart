class ApiConfig {
  static String httpBaseUrl = 'http://$baseUrl';
  static String websocketBaseUrl = 'ws://$baseUrl' ;
  static String baseUrl = Uri.base.origin;
}
