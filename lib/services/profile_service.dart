import 'package:dio/dio.dart';

class ProfileService {
  final String baseUrl = "http://192.168.1.2:8080";
  final dio = Dio();

  Future<Map<String, dynamic>> getProfile(id) async {
    try {
      final response = await dio.get(
        "$baseUrl/profile/$id",
        options: Options(headers: {"Content-Type": "application/json"}),
      );
      return response.data;
    } catch (e) {
      throw Exception("Gagal profile user");
    }
  }
}
