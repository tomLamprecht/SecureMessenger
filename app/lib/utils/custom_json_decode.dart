import 'dart:convert';

dynamic customDecode(String jsonStr) {
  return json.decode(jsonStr, reviver: (key, value) {
    if (value is int) {
      if (value.truncateToDouble() == value) {
        return value;
      }
    }
    return value;
  });
}