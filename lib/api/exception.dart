import 'package:asesmen_paud/api/response.dart';

class ValidationException implements Exception {
  final Map<String, ValidationErrorResponse> errors;

  ValidationException(this.errors);
}

class ErrorException implements Exception {
  final String message;

  ErrorException(this.message);

  @override
  String toString() => message;
}
