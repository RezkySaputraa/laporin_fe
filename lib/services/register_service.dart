import 'package:dio/dio.dart';
import 'package:laporin_app/models/register_model.dart';

class RegisterService {
  final String baseUrl =
      "https://laporin-be-724441751884.asia-southeast2.run.app";
  final dio = Dio();

  Future<Map<String, dynamic>> register(RegisterModel data) async {
    try {
      final response = await dio.post(
        "$baseUrl/auth/register",
        data: data.toJson(),
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['error'] ?? "Registrasi gagal");
      } else {
        throw Exception("Server tidak bisa dijangkau");
      }
    }
  }
}
