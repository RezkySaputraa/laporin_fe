import 'package:dio/dio.dart';
import 'package:laporin_app/models/login_google_model.dart';
import 'package:laporin_app/models/login_model.dart';

class LoginService {
  final String baseUrl = "https://laporin-be-724441751884.asia-southeast2.run.app";
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

  Future<List<dynamic>> loginFromGoogle(LoginGoogleModel data) async {
    try {
      final response = await dio.post(
        "$baseUrl/auth/login/google",
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
}
