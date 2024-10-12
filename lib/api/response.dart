class ApiResponse<T> {
  final SuccessResponse<T>? success;
  final FailResponse? fail;

  ApiResponse({this.success, this.fail});

  bool get isSuccess => success != null;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    if (json['status'] == 'success') {
      return ApiResponse(
        success: SuccessResponse.fromJson(json, fromJsonT),
      );
    } else {
      return ApiResponse(fail: FailResponse.fromJson(json));
    }
  }
}

class SuccessResponse<T> {
  final String status;
  final String message;
  final T payload;

  SuccessResponse({
    required this.status,
    required this.message,
    required this.payload,
  });

  factory SuccessResponse.fromJson(
      Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return SuccessResponse(
        status: json['status'],
        message: json['message'],
        payload: fromJsonT(json['payload']));
  }
}

class FailResponse {
  final String status;
  final String message;
  final List<ValidationErrorResponse>? errors;

  FailResponse({required this.status, required this.message, this.errors});

  factory FailResponse.fromJson(Map<String, dynamic> json) {
    return FailResponse(
      status: json['status'],
      message: json['messaage'],
      errors: json.containsKey('errors')
          ? (json['errors'] as List)
              .map((error) => ValidationErrorResponse.fromJson(error))
              .toList()
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
        message: json['message'], rule: json['rule'], field: json['field']);
  }
}
