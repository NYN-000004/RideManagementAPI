import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  const ApiException({
    required this.message,
    this.statusCode,
    this.details,
  });

  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          message: 'Connection timed out. Please check if the backend server is running.',
          statusCode: 408,
        );

      case DioExceptionType.connectionError:
        return const ApiException(
          message: 'Cannot reach the backend server. Make sure ASP.NET Core API is running and check your base URL.',
          statusCode: 503,
        );

      case DioExceptionType.badResponse:
        final response = error.response;
        final statusCode = response?.statusCode;
        final data = response?.data;

        String extractedMessage = 'Request failed with status $statusCode.';

        if (data is Map) {
          // Check standard ASP.NET Core response fields
          if (data['message'] != null && data['message'].toString().isNotEmpty) {
            extractedMessage = data['message'].toString();
          } else if (data['title'] != null && data['title'].toString().isNotEmpty) {
            extractedMessage = data['title'].toString();
          } else if (data['errors'] != null) {
            // Validation errors: {"errors": {"PickupLocation": ["Required"]}}
            final errors = data['errors'];
            if (errors is Map) {
              final List<String> errorLines = [];
              errors.forEach((key, val) {
                if (val is List) {
                  errorLines.add('$key: ${val.join(", ")}');
                } else {
                  errorLines.add('$key: $val');
                }
              });
              if (errorLines.isNotEmpty) {
                extractedMessage = errorLines.join('\n');
              }
            }
          }
        } else if (data is String && data.isNotEmpty) {
          extractedMessage = data;
        }

        switch (statusCode) {
          case 400:
            return ApiException(
              message: extractedMessage,
              statusCode: 400,
              details: data,
            );
          case 401:
            return const ApiException(
              message: 'Session expired or unauthorized. Please log in again.',
              statusCode: 401,
            );
          case 403:
            return const ApiException(
              message: 'Access forbidden for this operation.',
              statusCode: 403,
            );
          case 404:
            return ApiException(
              message: extractedMessage.isNotEmpty ? extractedMessage : 'Requested resource not found.',
              statusCode: 404,
              details: data,
            );
          case 409:
            return ApiException(
              message: extractedMessage,
              statusCode: 409,
              details: data,
            );
          case 500:
            return ApiException(
              message: 'Internal server error. Please verify backend database connection.',
              statusCode: 500,
              details: data,
            );
          default:
            return ApiException(
              message: extractedMessage,
              statusCode: statusCode,
              details: data,
            );
        }

      case DioExceptionType.cancel:
        return const ApiException(
          message: 'Request was cancelled.',
          statusCode: null,
        );

      case DioExceptionType.unknown:
      default:
        return ApiException(
          message: error.message ?? 'An unexpected network error occurred.',
          statusCode: null,
        );
    }
  }

  @override
  String toString() => message;
}
