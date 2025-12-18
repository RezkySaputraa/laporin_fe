import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laporin_app/models/penindak_laporan_model.dart';
import 'package:laporin_app/models/tindak_lanjut_request_model.dart';

class PenindakService {
  final String baseUrl =
      "https://laporin-be-724441751884.asia-southeast2.run.app";
  final dio = Dio();

  /// Get all laporan for penindak with optional filters
  /// [status] - 0: Belum ditindak, 1: Sedang diproses, 2: Selesai
  /// [jenisLaporan] - ID jenis laporan
  /// [search] - Search query for alamat/catatan
  Future<List<PenindakLaporanModel>> getAllLaporan({
    int? status,
    int? jenisLaporan,
    String? search,
  }) async {
    try {
      Map<String, dynamic> queryParams = {};

      if (status != null) {
        queryParams['status'] = status;
      }
      if (jenisLaporan != null) {
        queryParams['jenis_laporan'] = jenisLaporan;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await dio.get(
        "$baseUrl/penindak/laporin",
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final List<dynamic> dataList = response.data['data'];
        return dataList
            .map((json) => PenindakLaporanModel.fromJson(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Get detail laporan by ID
  Future<PenindakLaporanModel?> getDetailLaporan(int id) async {
    try {
      final response = await dio.get(
        "$baseUrl/penindak/laporin/detail/$id",
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return PenindakLaporanModel.fromJson(response.data['data']);
      }

      return null;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Tindak lanjut laporan
  /// Status akan berubah menjadi:
  /// - 1 (Sedang Diproses) jika hanya catatan
  /// - 2 (Selesai) jika catatan + gambar
  Future<PenindakLaporanModel?> tindakLanjut(
    int laporanId,
    TindakLanjutRequest request,
  ) async {
    try {
      final response = await dio.put(
        "$baseUrl/penindak/laporin/tindak/$laporanId",
        data: request.toJson(),
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return PenindakLaporanModel.fromJson(response.data['data']);
      }

      return null;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Upload image to Cloudinary
  /// Returns Map with 'url' and 'public_id'
  Future<Map<String, dynamic>> uploadImage(XFile image) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(image.path, filename: image.name),
      });

      final response = await dio.post(
        "$baseUrl/media/upload",
        data: formData,
        options: Options(headers: {"Content-Type": "multipart/form-data"}),
      );

      return {
        'url': response.data['url'] ?? '',
        'public_id': response.data['public_id'] ?? '',
      };
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Get jenis laporan for filter dropdown
  Future<List<Map<String, dynamic>>> getJenisLaporan() async {
    try {
      final response = await dio.get(
        "$baseUrl/laporin/jenis",
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }

      return [];
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Delete image from Cloudinary/server
  Future<Map<String, dynamic>> deleteImageFromServer(String publicId) async {
    try {
      final response = await dio.delete(
        "$baseUrl/media/delete",
        data: {'public_id': publicId},
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      return response.data;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map && data['error'] != null) {
        return data['error'];
      }
    }
    return "Terjadi kesalahan jaringan";
  }
}
