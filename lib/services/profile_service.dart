import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laporin_app/models/laporin_model.dart';

class LaporinService {
  final String baseUrl = "http://192.168.1.2:8080";
  final dio = Dio();

  Future<List<dynamic>> getProfile() async {
    try {
      final response = await dio.get(
        "$baseUrl/laporin/jenis",
        options: Options(headers: {"Content-Type": "application/json"}),
      );
      return response.data as List<dynamic>;
    } catch (e) {
      throw Exception("Gagal mendapatkan jenis laporan");
    }
  }
}
