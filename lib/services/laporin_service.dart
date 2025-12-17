import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laporin_app/models/laporin_model.dart';

class LaporinService {
  final String baseUrl = "https://laporin-be-724441751884.asia-southeast2.run.app";
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

  /// Get laporan by user ID (riwayat laporan user)
  Future<List<dynamic>> getUserLaporan({
    required int userId,
    int? jenisLaporan,
    String? search,
  }) async {
    try {
      Map<String, dynamic> queryParams = {};

      if (jenisLaporan != null) {
        queryParams['jenis_laporan'] = jenisLaporan;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await dio.get(
        "$baseUrl/laporin/riwayat/$userId",
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return response.data['data'] as List<dynamic>;
      }

      return [];
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response?.data;
        if (data is Map && data['error'] != null) {
          throw Exception(data['error']);
        }
      }
      throw Exception("Terjadi kesalahan jaringan");
    }
  }

  /// Get detail laporan for user
  Future<Map<String, dynamic>?> getDetailLaporan(int id) async {
    try {
      final response = await dio.get(
        "$baseUrl/laporin/detail/$id",
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return response.data['data'] as Map<String, dynamic>;
      }

      return null;
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response?.data;
        if (data is Map && data['error'] != null) {
          throw Exception(data['error']);
        }
      }
      throw Exception("Terjadi kesalahan jaringan");
    }
  }
}
