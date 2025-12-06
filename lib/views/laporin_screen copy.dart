import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laporin_app/views/login_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class Laporin2Screen extends StatefulWidget {
  const Laporin2Screen({super.key});

  @override
  State<Laporin2Screen> createState() => _LaporinScreenState();
}

class _LaporinScreenState extends State<Laporin2Screen> {
  bool _isAgree = false;
  bool _imageError = false;

  String? isoTime;
  String? _jenisLaporan;

  String? _imageUrl;
  String? _publicIdImage;

  bool _isLoading = false;
  bool _isLoadingJenis = true;
  bool _isSubmitting = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();

  final Map<String, int> _jenisMap = {};
  late List<String> _jenisList;

  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;

  @override
  void initState() {
    super.initState();
    _jenisMapLaporan();
  }

  @override
  void dispose() {
    _alamatController.dispose();
    _keteranganController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(BuildContext context) async {
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
                  Navigator.of(context).pop(); // tutup bottom sheet
                  final picked = await _picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (picked != null) {
                    if (!mounted) return;
                    setState(() {
                      _pickedImage = picked;
                    });
                    await _uploadImageToServer();
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Galeri'),
                onTap: () async {
                  Navigator.of(context).pop(); // tutup bottom sheet
                  final picked = await _picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (picked != null) {
                    if (!mounted) return;
                    setState(() {
                      _pickedImage = picked;
                    });
                    await _uploadImageToServer();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitLaporan() async {
    final dio = Dio();

    final data = {
      "pelapor": 5,
      "alamat": _alamatController.text,
      "jenis_laporan": _jenisMap[_jenisLaporan],
      "waktu": isoTime ?? DateTime.now().toUtc().toIso8601String(),
      "catatan_pelapor": _keteranganController.text,
      "bukti": _imageUrl,
      "status": 0,
    };

    try {
      await dio.post(
        "http://192.168.1.2:8080/laporin",
        data: jsonEncode(data),
        options: Options(headers: {"Content-Type": "application/json"}),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal kirim laporan: $e")));
    }
  }

  Future<void> _jenisMapLaporan() async {
    final dio = Dio();

    try {
      final response = await dio.get(
        "http://192.168.1.2:8080/laporin/jenis",
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      final List data = response.data;
      for (var item in data) {
        _jenisMap[item['nama']] = item['id'];
      }

      setState(() {
        _jenisList = _jenisMap.keys.toList();
        _isLoadingJenis = false;
      });
    } catch (e) {
      setState(() => _isLoadingJenis = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mendapatkan jenis laporan")),
      );
    }
  }

  Future<void> _uploadImageToServer() async {
    if (_pickedImage == null) return;

    setState(() => _isLoading = true);

    try {
      final dio = Dio();

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          _pickedImage!.path,
          filename: _pickedImage!.name,
        ),
      });

      final response = await dio.post(
        "http://192.168.1.2:8080/media/upload",
        data: formData,
        options: Options(headers: {"Content-Type": "multipart/form-data"}),
      );

      // 🔹 Debug: lihat isi response
      print("Upload response: ${response.data}");

      // pastikan key yang dipakai sama dengan response server
      if (response.data != null && response.data['url'] != null) {
        setState(() {
          _imageUrl = response.data['url'];
          _publicIdImage = response.data['public_id'];
        });
      } else {
        // kalau server nggak return URL
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Upload foto gagal: server tidak mengembalikan URL"),
          ),
        );
        setState(() {
          _pickedImage = null; // reset supaya user tahu upload gagal
        });
      }
    } catch (e) {
      // 🔹 Debug error
      print("Upload error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Upload foto gagal")));
      setState(() {
        _pickedImage = null; // reset supaya user tahu upload gagal
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteImageFromServer() async {
    if (_imageUrl == null) return;

    setState(() => _isLoading = true);

    try {
      final dio = Dio();

      final response = await dio.delete(
        "http://192.168.1.2:8080/media/delete",
        data: {'public_id': _publicIdImage},
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      // pastikan key yang dipakai sama dengan response server
      if (response.data is Map && response.data['message'] != null) {
        setState(() {
          _imageUrl = null;
          _pickedImage = null;
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Hapus Foto Gagal")));
      }
    } catch (e) {
      // 🔹 Debug error
      print("Upload error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Hapus foto gagal")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
      body: _isLoadingJenis
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
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
                        controller: _alamatController,
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
                      DropdownButtonFormField<String>(
                        initialValue: _jenisLaporan,
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
                            decoration: TextDecoration.none,
                          ),
                        ),
                        items: _jenisList.map((item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _jenisLaporan = value;
                          });
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
                        controller: _tanggalController,
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
                          if (!mounted) return;

                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );

                          if (date == null) return;

                          if (!mounted) return;

                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );

                          if (time == null) return;

                          if (!mounted) return;

                          final selectedDateTime = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );

                          isoTime = selectedDateTime.toUtc().toIso8601String();

                          _tanggalController.text =
                              "${selectedDateTime.day.toString().padLeft(2, '0')}/"
                              "${selectedDateTime.month.toString().padLeft(2, '0')}/"
                              "${selectedDateTime.year} "
                              "${time.hour.toString().padLeft(2, '0')}:"
                              "${time.minute.toString().padLeft(2, '0')}";
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
                        controller: _keteranganController,
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
                        onTap: () {
                          _pickImage(context);
                        },
                        child: Container(
                          height: 150, // tinggi form
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Color.fromARGB(
                              255,
                              255,
                              255,
                              255,
                            ), // warna background
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _imageError
                                  ? Colors.red
                                  : Color(0xFF4C4B4B),
                              width: 1,
                            ),
                          ),
                          child: _pickedImage == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment
                                      .center, // tengah vertikal
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
                              : _isLoading != true
                              ? Stack(
                                  children: [
                                    Center(
                                      child: Image.file(
                                        File(_pickedImage!.path),
                                        fit: BoxFit.contain,
                                        height: 120,
                                      ),
                                    ),
                                    Positioned(
                                      top: 6,
                                      right: 6,
                                      child: InkWell(
                                        onTap: () async {
                                          await _deleteImageFromServer();
                                          setState(() {
                                            _isAgree = false;
                                          });
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
                        opacity: _imageError ? 1 : 0,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            'Foto wajib diunggah',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      _pickedImage != null
                          ? Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Transform.scale(
                                      scale: 1.2,
                                      child: Checkbox(
                                        value: _isAgree,
                                        activeColor: Color(0xFF0F55C7),
                                        onChanged: (value) {
                                          setState(() {
                                            _isAgree = value!;
                                          });
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
                          onPressed: _isSubmitting
                              ? null
                              : () async {
                                  final isFormValid = _formKey.currentState!
                                      .validate();

                                  setState(() {
                                    _imageError = _imageUrl == null;
                                  });

                                  if (!isFormValid || _imageError || !_isAgree)
                                    return;

                                  setState(() {
                                    _isSubmitting = true;
                                  });

                                  try {
                                    await _submitLaporan();
                                    _showSuccessDialog();
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Gagal mengirim laporan"),
                                      ),
                                    );
                                  } finally {
                                    if (mounted) {
                                      setState(() {
                                        _isSubmitting = false;
                                      });
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 32,
                            ),
                            backgroundColor: _isAgree
                                ? Color(0xFF0F55C7)
                                : Color(0xFFDFDFDF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 1,
                          ),
                          child: _isSubmitting
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
            ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      barrierDismissible: false,
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

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
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
