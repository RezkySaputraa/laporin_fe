import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laporin_app/models/laporin_jenis_model.dart';
import 'package:laporin_app/models/laporin_model.dart';
import 'package:laporin_app/services/laporin_service.dart';

class LaporinController extends GetxController {
  final LaporinService laporinService = LaporinService();

  RxBool isAgree = false.obs;
  RxBool imageError = false.obs;

  var imageUrl = ''.obs;
  var publicIdImage = ''.obs;

  RxBool isLoading = false.obs;
  RxBool isLoadingJenis = true.obs;
  RxBool isSubmitting = false.obs;

  final ImagePicker picker = ImagePicker();
  Rxn<XFile> pickedImage = Rxn<XFile>();

  final formKey = GlobalKey<FormState>();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController keteranganController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();

  RxnString isoTime = RxnString();

  var jenisList = <LaporinJenisModel>[].obs;
  Rxn<LaporinJenisModel> selectedJenis = Rxn<LaporinJenisModel>();

  @override
  void onInit() {
    super.onInit();
    getAllJenisLaporan();
  }

  @override
  void onClose() {
    alamatController.dispose();
    keteranganController.dispose();
    tanggalController.dispose();
    super.onClose();
  }

  Future<void> pickImage(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Kamera'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final picked = await picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (picked != null) {
                    pickedImage.value = picked;
                    await _uploadImageFromPicked();
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Galeri'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final picked = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (picked != null) {
                    pickedImage.value = picked;
                    await _uploadImageFromPicked();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadImageFromPicked() async {
    final XFile? image = pickedImage.value;
    if (image == null) return;

    isLoading.value = true;
    try {
      final res = await laporinService.uploadImageToServer(image);
      final Map<String, dynamic> data = res;
      if (data['url'] != null) {
        imageUrl.value = data['url'];
        publicIdImage.value = data['public_id'];
        imageError.value = false;
      }
    } catch (e) {
      pickedImage.value = null;
      Get.snackbar('Error', 'Upload foto gagal');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteImage() async {
    final String pubId = publicIdImage.value;

    isLoading.value = true;
    try {
      final res = await laporinService.deleteImageFromServer(pubId);
      final Map<String, dynamic> data = res;
      if (data['message'] != null) {
        imageUrl.value = '';
        publicIdImage.value = '';
        pickedImage.value = null;
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus foto');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickDateTime(context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    final selectedDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    isoTime.value = selectedDateTime.toUtc().toIso8601String();
    tanggalController.text =
        "${selectedDateTime.day.toString().padLeft(2, '0')}/"
        "${selectedDateTime.month.toString().padLeft(2, '0')}/"
        "${selectedDateTime.year} "
        "${time.hour.toString().padLeft(2, '0')}:"
        "${time.minute.toString().padLeft(2, '0')}";
  }

  Future<void> getAllJenisLaporan() async {
    try {
      isLoadingJenis.value = true;
      final data = await laporinService.getJenisLaporan();
      final list = (data)
          .map((json) => LaporinJenisModel.fromJson(json))
          .toList();
      jenisList.value = list;
    } catch (e) {
      Get.snackbar('Error', 'Gagal mendapatkan jenis laporan');
    } finally {
      isLoadingJenis.value = false;
    }
  }

  Future<bool> insertLaporin() async {
    final isFormValid = formKey.currentState?.validate() ?? false;
    imageError.value = imageUrl.isEmpty;

    if (!isFormValid || imageError.value || !isAgree.value) return false;

    isSubmitting.value = true;
    try {
      final laporin = LaporinModel(
        pelapor: 5,
        alamat: alamatController.text,
        jenisLaporan: selectedJenis.value!.id,
        waktu: isoTime.value ?? DateTime.now().toUtc().toIso8601String(),
        catatanPelapor: keteranganController.text,
        bukti: imageUrl.value,
        status: 0,
      );

      await laporinService.submitLaporan(laporin);

      return true;
    } catch (e) {
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  void resetForm() {
    // Reset text controllers
    alamatController.text = '';
    keteranganController.text = '';
    tanggalController.text = '';

    // Reset Rx variables
    selectedJenis.value = null;
    pickedImage.value = null;
    imageUrl.value = '';
    publicIdImage.value = '';
    imageError.value = false;
    isAgree.value = false;
    isoTime.value = null;
  }
}
