class HttpException implements Exception {
  final String message;

  HttpException(this.message);

  @override
  String toString() {
    return message;
  }
}
class VerificationException implements Exception {
  final String message;
  final String auth;
  VerificationException(this.message,this.auth);

  @override
  String toString() {
    return message;
  }
}