class ApiResponse<T> {
  final SuccessResponse<T>? success;
  final FailResponse? fail;

  ApiResponse({this.success, this.fail});

  bool get isSuccess => success != null;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    if (json['status'] == 'success') {
      return ApiResponse(
          success: fromJsonT != null
              ? SuccessResponse.fromJson(json, fromJsonT)
              : SuccessResponse.fromJsonWithoutPayload(json));
    } else {
      return ApiResponse(fail: FailResponse.fromJson(json));
    }
  }
}

class SuccessResponse<T> {
  final String status;
  final String message;
  final T? payload;

  SuccessResponse({
    required this.status,
    required this.message,
    this.payload,
  });

  factory SuccessResponse.fromJson(
      Map<String, dynamic> json, T Function(dynamic)? fromJsonT) {
    return SuccessResponse(
        status: json['status'] as String,
        message: json['message'] as String,
        payload: json.containsKey('payload') && fromJsonT != null
            ? fromJsonT(json['payload'])
            : null);
  }

  factory SuccessResponse.fromJsonWithoutPayload(Map<String, dynamic> json) {
    return SuccessResponse(
        status: json['status'] as String,
        message: json['message'] as String,
        payload: null);
  }
}

class FailResponse {
  final String status;
  final String message;
  final Map<String, ValidationErrorResponse>? errors;

  FailResponse({required this.status, required this.message, this.errors});

  factory FailResponse.fromJson(Map<String, dynamic> json) {
    return FailResponse(
      status: json['status'] ?? 'fail',
      message: json['messaage'] ?? 'Unknown error',
      errors: json.containsKey('errors')
          ? (json['errors'] as List)
              .fold<Map<String, ValidationErrorResponse>>({}, (acc, error) {
              final validatonError = ValidationErrorResponse.fromJson(error);
              acc[validatonError.field] = validatonError;
              return acc;
            })
          : null,
    );
  }
}

class ValidationErrorResponse {
  final String message;
  final String rule;
  final String field;

  ValidationErrorResponse({
    required this.message,
    required this.rule,
    required this.field,
  });

  factory ValidationErrorResponse.fromJson(Map<String, dynamic> json) {
    return ValidationErrorResponse(
        message: json['message'] ?? 'No message',
        rule: json['rule'] ?? 'No rule',
        field: json['field'] ?? 'No field');
  }
}
