import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laporin_app/models/penindak_laporan_model.dart';
import 'package:laporin_app/models/tindak_lanjut_request_model.dart';
import 'package:laporin_app/services/penindak_service.dart';

class PenindakDetailController extends GetxController {
  final PenindakService _service = PenindakService();
  final ImagePicker _picker = ImagePicker();

  // Laporan data
  Rx<PenindakLaporanModel?> laporan = Rx<PenindakLaporanModel?>(null);

  // Form
  final TextEditingController catatanController = TextEditingController();

  // Image
  Rx<XFile?> selectedImage = Rx<XFile?>(null);
  RxString uploadedImageUrl = ''.obs;

  // State
  RxBool isLoading = false.obs;
  RxBool isSubmitting = false.obs;
  RxBool isUploading = false.obs;
  RxString errorMessage = ''.obs;
  RxString successMessage = ''.obs;

  // Penindak ID (should come from logged in user)
  int penindakId = 0;

  @override
  void onClose() {
    catatanController.dispose();
    super.onClose();
  }

  /// Load laporan detail by ID
  Future<void> loadDetail(int laporanId) async {
    // Reset form before loading new data
    resetForm();
    laporan.value = null;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _service.getDetailLaporan(laporanId);
      laporan.value = result;

      // Pre-fill catatan if exists
      if (result?.tindak?.catatanPenindak != null) {
        catatanController.text = result!.tindak!.catatanPenindak!;
      }

      // Pre-fill image URL if exists (from tindak.hasil)
      if (result?.tindak?.hasil != null && result!.tindak!.hasil!.isNotEmpty) {
        uploadedImageUrl.value = result.tindak!.hasil!;
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  /// Pick image from gallery
  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        selectedImage.value = image;
        await uploadImage();
      }
    } catch (e) {
      errorMessage.value = 'Gagal memilih gambar';
    }
  }

  /// Take photo from camera
  Future<void> takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        selectedImage.value = image;
        await uploadImage();
      }
    } catch (e) {
      errorMessage.value = 'Gagal mengambil foto';
    }
  }

  /// Upload image to Cloudinary
  Future<void> uploadImage() async {
    if (selectedImage.value == null) return;

    try {
      isUploading.value = true;
      errorMessage.value = '';

      final url = await _service.uploadImage(selectedImage.value!);
      uploadedImageUrl.value = url;
    } catch (e) {
      errorMessage.value = 'Gagal upload gambar';
      selectedImage.value = null;
    } finally {
      isUploading.value = false;
    }
  }

  /// Remove selected image
  void removeImage() {
    selectedImage.value = null;
    uploadedImageUrl.value = '';
  }

  /// Submit tindak lanjut
  /// Status akan berubah menjadi:
  /// - 1 (Sedang Diproses) jika hanya catatan
  /// - 2 (Selesai) jika catatan + gambar
  Future<bool> submitTindakLanjut() async {
    if (laporan.value == null) return false;
    if (catatanController.text.isEmpty) {
      errorMessage.value = 'Catatan wajib diisi';
      return false;
    }
    if (penindakId == 0) {
      errorMessage.value = 'Penindak ID tidak valid';
      return false;
    }

    try {
      isSubmitting.value = true;
      errorMessage.value = '';
      successMessage.value = '';

      final request = TindakLanjutRequest(
        penindakId: penindakId,
        catatanPenindak: catatanController.text,
        hasil: uploadedImageUrl.value.isNotEmpty
            ? uploadedImageUrl.value
            : null,
      );

      final result = await _service.tindakLanjut(laporan.value!.id, request);

      if (result != null) {
        laporan.value = result;

        if (uploadedImageUrl.value.isNotEmpty) {
          successMessage.value = 'Laporan telah diselesaikan';
        } else {
          successMessage.value = 'Laporan sedang diproses';
        }

        return true;
      }

      return false;
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Set penindak ID from logged in user
  void setPenindakId(int id) {
    penindakId = id;
  }

  /// Reset form
  void resetForm() {
    catatanController.clear();
    selectedImage.value = null;
    uploadedImageUrl.value = '';
    errorMessage.value = '';
    successMessage.value = '';
  }
}
