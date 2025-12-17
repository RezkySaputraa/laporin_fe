import 'package:dio/dio.dart';

class ProfileService {
  final String baseUrl =
      "https://laporin-be-724441751884.asia-southeast2.run.app";
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

  Future<bool> updateProfile(int id, Map<String, dynamic> data) async {
    try {
      final response = await dio.put(
        "$baseUrl/profile/$id",
        data: data,
        options: Options(headers: {"Content-Type": "application/json"}),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception("Gagal update profile user");
    }
  }
}
