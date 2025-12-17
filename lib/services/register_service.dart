import 'package:dio/dio.dart';
import 'package:laporin_app/models/register_model.dart';

class RegisterService {
  final String baseUrl =
      "https://laporin-be-724441751884.asia-southeast2.run.app";
  final dio = Dio();

  Future<dynamic> register(RegisterModel data) async {
    try {
      final response = await dio.post(
        "$baseUrl/auth/register",
        data: data.toJson(),
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response?.data;
        String errorMessage = "Registrasi gagal";

        if (errorData is Map) {
          errorMessage =
              errorData['error'] ??
              errorData['message'] ??
              errorData['messages']?.toString() ??
              "Registrasi gagal";
        } else if (errorData is String) {
          errorMessage = errorData;
        }

        // Handle specific error messages
        final lowerCaseError = errorMessage.toLowerCase();
        if (lowerCaseError.contains('email') &&
            (lowerCaseError.contains('exist') ||
                lowerCaseError.contains('already') ||
                lowerCaseError.contains('duplicate') ||
                lowerCaseError.contains('terdaftar'))) {
          throw Exception(
            "Email sudah terdaftar. Silakan gunakan email lain atau login.",
          );
        }

        throw Exception(errorMessage);
      } else {
        throw Exception("Server tidak bisa dijangkau");
      }
    }
  }
}
