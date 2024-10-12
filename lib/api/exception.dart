import 'package:asesmen_paud/api/response.dart';

class ValidationException implements Exception {
  final Map<String, ValidationErrorResponse> errors;

  ValidationException(this.errors);
}

class BadRequestException implements Exception {
  final String message;

  BadRequestException(this.message);

  @override
  String toString() => message;
}
