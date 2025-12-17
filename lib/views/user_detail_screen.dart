import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:laporin_app/services/laporin_service.dart';

class UserDetailScreen extends StatefulWidget {
  final int laporanId;

  const UserDetailScreen({super.key, required this.laporanId});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final LaporinService _laporinService = LaporinService();
  bool isLoading = true;
  Map<String, dynamic>? laporan;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final data = await _laporinService.getDetailLaporan(widget.laporanId);

      setState(() {
        laporan = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
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
          'Detail Laporin',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F55C7),
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0F55C7)),
            )
          : laporan == null
          ? Center(
              child: Text(
                errorMessage.isNotEmpty
                    ? errorMessage
                    : 'Laporan tidak ditemukan',
                style: GoogleFonts.inter(color: Colors.red),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and Status Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDate(laporan!['waktu'] ?? ''),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      _buildStatusBadge(laporan!['status'] ?? 0),
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
                        imageUrl: laporan!['bukti'] ?? '',
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
                              style: GoogleFonts.inter(
                                color: Colors.grey.shade400,
                              ),
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
                              style: GoogleFonts.inter(
                                color: Colors.grey.shade400,
                              ),
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
                          laporan!['alamat'] ?? '',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        _getJenisLaporan(),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF0F55C7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Keterangan
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
                      laporan!['catatan_pelapor'] ?? '',
                      style: GoogleFonts.inter(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Catatan Petugas (Read-only)
                  Text(
                    'Catatan Petugas',
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
                      _getCatatanPetugas(),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color:
                            _getCatatanPetugas() !=
                                'Belum ada catatan dari petugas'
                            ? Colors.black
                            : Colors.grey.shade400,
                      ),
                    ),
                  ),

                  // Hasil Tindak (Foto dari Petugas)
                  if (_getHasilTindak() != null) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Hasil Tindak Lanjut',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
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
                          imageUrl: _getHasilTindak()!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Memuat hasil...',
                                style: GoogleFonts.inter(
                                  color: Colors.grey.shade400,
                                ),
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
                                style: GoogleFonts.inter(
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  String _getJenisLaporan() {
    // Try new format first (jenis_laporan_nama)
    if (laporan!['jenis_laporan_nama'] != null &&
        laporan!['jenis_laporan_nama'].toString().isNotEmpty) {
      return laporan!['jenis_laporan_nama'];
    }

    // Fallback to nested format (jenis_laporan.nama)
    if (laporan!['jenis_laporan'] != null &&
        laporan!['jenis_laporan'] is Map &&
        laporan!['jenis_laporan']['nama'] != null) {
      return laporan!['jenis_laporan']['nama'];
    }

    return 'N/A';
  }

  String _getCatatanPetugas() {
    // Try new format first (catatan_dari_petugas)
    if (laporan!['catatan_dari_petugas'] != null &&
        laporan!['catatan_dari_petugas'].toString().isNotEmpty) {
      return laporan!['catatan_dari_petugas'];
    }

    // Fallback to old format (tindak_lanjut.catatan_penindak)
    if (laporan!['tindak_lanjut'] != null &&
        laporan!['tindak_lanjut'] is Map &&
        laporan!['tindak_lanjut']['catatan_penindak'] != null &&
        laporan!['tindak_lanjut']['catatan_penindak'].toString().isNotEmpty) {
      return laporan!['tindak_lanjut']['catatan_penindak'];
    }

    return 'Belum ada catatan dari petugas';
  }

  String? _getHasilTindak() {
    // Try new format first (hasil_tindak_bukti)
    if (laporan!['hasil_tindak_bukti'] != null &&
        laporan!['hasil_tindak_bukti'].toString().isNotEmpty) {
      return laporan!['hasil_tindak_bukti'];
    }

    // Fallback to old format (tindak_lanjut.hasil)
    if (laporan!['tindak_lanjut'] != null &&
        laporan!['tindak_lanjut'] is Map &&
        laporan!['tindak_lanjut']['hasil'] != null &&
        laporan!['tindak_lanjut']['hasil'].toString().isNotEmpty) {
      return laporan!['tindak_lanjut']['hasil'];
    }

    return null;
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    } catch (e) {
      return dateStr;
    }
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
}
