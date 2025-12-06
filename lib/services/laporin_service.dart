import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laporin_app/models/laporin_model.dart';

class LaporinService {
  final String baseUrl = "http://192.168.1.2:8080";
  final dio = Dio();

  Future<void> submitLaporan(LaporinModel data) async {
    try {
      await dio.post(
        "$baseUrl/laporin",
        data: data.toJson(),
        options: Options(headers: {"Content-Type": "application/json"}),
      );
    } catch (e) {
      throw Exception("Gagal kirim laporan");
    }
  }

  Future<Map<String, dynamic>> uploadImageToServer(XFile image) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(image.path, filename: image.name),
    });

    final response = await dio.post(
      "$baseUrl/media/upload",
      data: formData,
      options: Options(headers: {"Content-Type": "multipart/form-data"}),
    );

    return response.data; // ✅ langsung JSON
  }

  Future<Map<String, dynamic>> deleteImageFromServer(String publicId) async {
    final response = await dio.delete(
      "$baseUrl/media/delete",
      data: {'public_id': publicId},
      options: Options(headers: {"Content-Type": "application/json"}),
    );

    return response.data;
  }

  Future<List<dynamic>> getJenisLaporan() async {
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
