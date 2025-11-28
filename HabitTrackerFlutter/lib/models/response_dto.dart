class ResponseDto<T> {
  final T? data;
  final int statusCode;
  final String? message;
  final List<String>? errors;

  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  ResponseDto({
    this.data,
    required this.statusCode,
    this.message,
    this.errors,
  });

  factory ResponseDto.fromJson(Map<String, dynamic> json, T Function(Object? json)? fromJsonT) {
    T? dataValue;
    if (json['data'] != null && fromJsonT != null) {
      dataValue = fromJsonT(json['data']);
    }
    else
      json['data'] = null;
    return ResponseDto<T>(
      data: dataValue,
      statusCode: json['statusCode'] as int,
      message: json['message'] as String?,
      errors: (json['errors'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }
}