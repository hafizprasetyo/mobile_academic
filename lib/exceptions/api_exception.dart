class APIException implements Exception {
  final int statusCode;
  final String error;
  final Map<String, dynamic> messages;

  APIException(this.statusCode, this.error, this.messages);

  String toString() {
    return "$statusCode | $error | $messages";
  }
}
