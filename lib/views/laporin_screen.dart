import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laporin_app/controllers/laporin_controller.dart';
import 'package:laporin_app/models/laporin_jenis_model.dart';
import 'package:laporin_app/views/login_screen.dart';

class LaporinScreen extends StatelessWidget {
  final LaporinController controller = Get.put(LaporinController());
  LaporinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Text(
          "Laporin Kejadian",
          style: GoogleFonts.inter(
            color: Color(0xFF0F55C7),
            fontWeight: FontWeight.w600,
            fontSize: 25,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey),
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingJenis.value) {
          return Center(child: CircularProgressIndicator());
        } else {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 5),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Alamat Kejadian",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4C4B4B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: controller.alamatController,
                      textAlign: TextAlign.start,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Alamat wajib diisi';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "Alamat...",
                        hintStyle: TextStyle(
                          color: Color(0xFF4C4B4B).withValues(alpha: 0.5),
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 6,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Color(0xFF0F55C7)),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.location_on_rounded,
                            color: Color(0xFF4C4B4B).withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      style: const TextStyle(
                        color: Color(0xFF4C4B4B),
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Jenis Laporan",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4C4B4B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Obx(
                      () => DropdownButtonFormField<LaporinJenisModel>(
                        initialValue: controller.selectedJenis.value,
                        validator: (value) {
                          if (value == null) {
                            return "Jenis laporan wajib dipilih";
                          }
                          return null;
                        },
                        hint: Text(
                          "Pilih Jenis Laporan",
                          style: TextStyle(
                            color: Color(0xFF4C4B4B).withValues(alpha: 0.5),
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        items: controller.jenisList.map((item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(item.nama),
                          );
                        }).toList(),
                        onChanged: (value) {
                          controller.selectedJenis.value = value;
                        },
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 6,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Color(0xFF0F55C7)),
                          ),
                        ),
                        style: const TextStyle(
                          color: Color(0xFF4C4B4B),
                          fontSize: 14,
                        ),
                      ),
                    ),

                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Tanggal",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4C4B4B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: controller.tanggalController,
                      readOnly: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Tanggal wajib diisi";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "dd/mm/yyyy",
                        hintStyle: TextStyle(
                          color: Color(0xFF4C4B4B).withValues(alpha: 0.5),
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 6,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Color(0xFF0F55C7)),
                        ),
                        suffixIcon: Icon(Icons.calendar_today, size: 20),
                      ),
                      onTap: () async {
                        await controller.pickDateTime(context);
                      },
                      style: const TextStyle(
                        color: Color(0xFF4C4B4B),
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Keterangan",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4C4B4B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      maxLines: 5,
                      minLines: 3,
                      controller: controller.keteranganController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Keterangan wajib diisi";
                        }
                        return null;
                      },
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        hintText: "Tulis Keterangan...",
                        hintStyle: TextStyle(
                          color: Color(0xFF4C4B4B).withValues(alpha: 0.5),
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 6,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Color(0xFF0F55C7)),
                        ),
                      ),
                      style: const TextStyle(
                        color: Color(0xFF4C4B4B),
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Foto",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4C4B4B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    InkWell(
                      onTap: controller.pickedImage.value != null
                          ? null
                          : () async {
                              await controller.pickImage(context);
                            },
                      child: Container(
                        height: 150, // tinggi form
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: controller.imageError.value
                                ? Colors.red
                                : Color(0xFF4C4B4B),
                            width: 1,
                          ),
                        ),
                        child: controller.pickedImage.value == null
                            ? Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center, // tengah vertikal
                                crossAxisAlignment: CrossAxisAlignment
                                    .center, // tengah horizontal
                                children: [
                                  Icon(
                                    Icons.camera_alt_outlined,
                                    size: 60,
                                    color: Color.fromARGB(255, 216, 216, 216),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Unggah Foto",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF4C4B4B).withAlpha(128),
                                    ),
                                  ),
                                ],
                              )
                            : controller.isLoading.value != true
                            ? Stack(
                                children: [
                                  Center(
                                    child: Image.file(
                                      File(controller.pickedImage.value!.path),
                                      fit: BoxFit.contain,
                                      height: 120,
                                    ),
                                  ),
                                  Positioned(
                                    top: 6,
                                    right: 6,
                                    child: InkWell(
                                      onTap: () async {
                                        await controller.deleteImage();
                                        controller.isAgree.value = false;
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: 0.5,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Center(child: CircularProgressIndicator()),
                      ),
                    ),
                    AnimatedOpacity(
                      duration: Duration(milliseconds: 200),
                      opacity: controller.imageError.value ? 1 : 0,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          'Foto wajib diunggah',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    controller.pickedImage.value != null
                        ? Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Transform.scale(
                                    scale: 1.2,
                                    child: Checkbox(
                                      value: controller.isAgree.value,
                                      activeColor: Color(0xFF0F55C7),
                                      onChanged: (value) {
                                        controller.isAgree.value = value!;
                                      },
                                      side: const BorderSide(
                                        width: 1,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: RichText(
                                      textAlign: TextAlign.justify,
                                      text: TextSpan(
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF4C4B4B),
                                        ),
                                        children: [
                                          const TextSpan(
                                            text:
                                                "Saya bersedia menerima sanksi sesuai ",
                                          ),
                                          TextSpan(
                                            text:
                                                "peraturan perundang-undangan",
                                            style: const TextStyle(
                                              color: Color(0xFF0F55C7),
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {},
                                          ),
                                          const TextSpan(
                                            text:
                                                " apabila memberikan laporan palsu.",
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                            ],
                          )
                        : Container(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.isSubmitting.value
                            ? null
                            : () async {
                                final success = await controller
                                    .insertLaporin();

                                if (success) {
                                  showSuccessDialog(context);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 32,
                          ),
                          backgroundColor: controller.isAgree.value
                              ? Color(0xFF0F55C7)
                              : Color(0xFFDFDFDF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 1,
                        ),
                        child: controller.isSubmitting.value
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                "LAPORIN !!!",
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      }),
    );
  }

  void showSuccessDialog(context) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Color(0xFF0F55C7).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF0F55C7),
                  size: 50,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "Berhasil!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F55C7),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Laporan kamu berhasil dikirim dan akan segera diproses.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF4C4B4B)),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F55C7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();

                    controller.resetForm();

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: const Text(
                    "OK",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
