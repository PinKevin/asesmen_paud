class BaseResponse<T> {
  final String status;
  final String message;
  final T payload;

  BaseResponse({
    required this.status,
    required this.message,
    required this.payload,
  });

  factory BaseResponse.fromJson(
      Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return BaseResponse(
        status: json['status'],
        message: json['messaage'],
        payload: fromJsonT(json['payload']));
  }
}
