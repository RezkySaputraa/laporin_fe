import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:laporin_app/controllers/penindak_detail_controller.dart';
import 'package:laporin_app/services/shared_preference/auth_shared_preferences.dart';

class PenindakDetailScreen extends StatefulWidget {
  final int laporanId;

  const PenindakDetailScreen({super.key, required this.laporanId});

  @override
  State<PenindakDetailScreen> createState() => _PenindakDetailScreenState();
}

class _PenindakDetailScreenState extends State<PenindakDetailScreen> {
  late PenindakDetailController controller;
  final AuthSharedPreferences _authPrefs = AuthSharedPreferences();

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<PenindakDetailController>()
        ? Get.find<PenindakDetailController>()
        : Get.put(PenindakDetailController());

    _initController();
  }

  Future<void> _initController() async {
    // Get penindak ID from logged in user
    final userId = await _authPrefs.getUserId();
    if (userId != null) {
      controller.setPenindakId(userId);
    }
    controller.loadDetail(widget.laporanId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Tindak Laporin',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F55C7),
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF0F55C7)),
          );
        }

        if (controller.laporan.value == null) {
          return Center(
            child: Text(
              controller.errorMessage.value.isNotEmpty
                  ? controller.errorMessage.value
                  : 'Laporan tidak ditemukan',
              style: GoogleFonts.inter(color: Colors.red),
            ),
          );
        }

        final laporan = controller.laporan.value!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date and Status Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    laporan.formattedDate,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  _buildStatusBadge(laporan.status),
                ],
              ),
              const SizedBox(height: 16),

              // Bukti Image
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: laporan.bukti,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Laporan masyarakat',
                          style: GoogleFonts.inter(color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                    errorWidget: (context, url, error) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Gagal memuat gambar',
                          style: GoogleFonts.inter(color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Alamat and Jenis Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      laporan.alamat,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    laporan.jenisLaporanName,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF0F55C7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Keterangan Masyarakat
              Text(
                'Keterangan',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  laporan.catatanPelapor,
                  style: GoogleFonts.inter(fontSize: 14),
                ),
              ),
              const SizedBox(height: 24),

              // Catatan Petugas
              Text(
                'Catatan Petugas',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller.catatanController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Masukkan catatan...',
                  hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF0F55C7)),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Upload Bukti Tindakan
              Text(
                'Bukti Tindakan (Opsional)',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              _buildImageUploadSection(),
              const SizedBox(height: 8),
              Text(
                '* Upload bukti untuk menyelesaikan laporan',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 24),

              // Error Message
              Obx(() {
                if (controller.errorMessage.value.isNotEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      controller.errorMessage.value,
                      style: GoogleFonts.inter(color: Colors.red),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),

              // Success Message
              Obx(() {
                if (controller.successMessage.value.isNotEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      controller.successMessage.value,
                      style: GoogleFonts.inter(color: Colors.green),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),

              // Submit Button
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : () async {
                            final result = await controller
                                .submitTindakLanjut();
                            if (result && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    controller.successMessage.value,
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F55C7),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isSubmitting.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'SIMPAN',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatusBadge(int status) {
    Color bgColor;
    String text;

    switch (status) {
      case 0:
        bgColor = Colors.red;
        text = 'Belum ditindak';
        break;
      case 1:
        bgColor = Colors.orange;
        text = 'Sedang diproses';
        break;
      case 2:
        bgColor = Colors.green;
        text = 'Selesai';
        break;
      default:
        bgColor = Colors.grey;
        text = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Obx(() {
      // If image is uploading
      if (controller.isUploading.value) {
        return Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Color(0xFF0F55C7)),
                SizedBox(height: 8),
                Text('Mengupload gambar...'),
              ],
            ),
          ),
        );
      }

      // If image is selected
      if (controller.selectedImage.value != null) {
        return Stack(
          children: [
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(controller.selectedImage.value!.path),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: controller.removeImage,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
            if (controller.uploadedImageUrl.value.isNotEmpty)
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Uploaded',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      }

      // Default - show upload buttons
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Gallery Button
            GestureDetector(
              onTap: controller.pickImage,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F55C7).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.photo_library_outlined,
                      color: Color(0xFF0F55C7),
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Galeri',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Camera Button
            GestureDetector(
              onTap: controller.takePhoto,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F55C7).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: Color(0xFF0F55C7),
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kamera',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
