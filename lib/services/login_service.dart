import 'package:dio/dio.dart';
import 'package:laporin_app/models/login_model.dart';

class LoginService {
  final String baseUrl = "http://192.168.1.2:8080";
  final dio = Dio();

  Future<Map<String, dynamic>> login(LoginModel data) async {
    try {
      final response = await dio.post(
        "$baseUrl/auth/login",
        data: data.toJson(),
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['error'] ?? "Login gagal");
      } else {
        throw Exception("Server tidak bisa dijangkau");
      }
    }
  }

  Future<void> logout(String publicId) async {
    final response = await dio.delete(
      "$baseUrl/media/delete",
      data: {'public_id': publicId},
      options: Options(headers: {"Content-Type": "application/json"}),
    );

    return response.data;
  }
}
