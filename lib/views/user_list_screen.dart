import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:laporin_app/services/laporin_service.dart';
import 'package:laporin_app/services/shared_preference/auth_shared_preferences.dart';
import 'package:laporin_app/views/user_detail_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final LaporinService _service = LaporinService();
  final AuthSharedPreferences _authPrefs = AuthSharedPreferences();

  List<Map<String, dynamic>> laporanList = [];
  List<Map<String, dynamic>> jenisLaporanList = [];
  int? selectedJenisLaporan;
  int? selectedStatus;
  bool isAscending = false;
  bool isLoading = false;
  String errorMessage = '';
  int? userId;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    userId = await _authPrefs.getUserId();
    await _loadJenisLaporan();
    await _loadLaporan();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadJenisLaporan() async {
    try {
      final result = await _service.getJenisLaporan();
      setState(() {
        jenisLaporanList = result
            .map((item) => {'id': item['id'], 'nama': item['nama']})
            .toList();
      });
    } catch (e) {
      // Ignore error, dropdown will just be empty
    }
  }

  Future<void> _loadLaporan() async {
    if (userId == null) return;

    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final result = await _service.getUserLaporan(
        userId: userId!,
        jenisLaporan: selectedJenisLaporan,
      );

      // Filter by status (frontend filtering)
      var filteredResult = result;
      if (selectedStatus != null) {
        filteredResult = result.where((item) {
          return item['status'] == selectedStatus;
        }).toList();
      }

      // Sort by waktu
      filteredResult.sort((a, b) {
        final dateA = DateTime.parse(a['waktu']);
        final dateB = DateTime.parse(b['waktu']);
        return isAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
      });

      setState(() {
        laporanList = filteredResult
            .map((item) => item as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
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
          'Riwayat Laporin',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F55C7),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter & Search Bar
          _buildFilterBar(),

          // Laporan List
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0F55C7)),
                  )
                : errorMessage.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          errorMessage,
                          style: GoogleFonts.inter(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadLaporan,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  )
                : laporanList.isEmpty
                ? Center(
                    child: Text(
                      'Tidak ada laporan',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadLaporan,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: laporanList.length,
                      itemBuilder: (context, index) {
                        return _buildLaporanCard(laporanList[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Sort Button
          IconButton(
            onPressed: () {
              setState(() {
                isAscending = !isAscending;
              });
              _loadLaporan();
            },
            icon: Icon(
              isAscending ? Icons.arrow_upward : Icons.arrow_downward,
              color: const Color(0xFF0F55C7),
            ),
          ),

          // Jenis Laporan Dropdown
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int?>(
                  value: selectedJenisLaporan,
                  hint: Text(
                    'Semua laporan',
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                  isExpanded: true,
                  items: [
                    DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Semua', style: GoogleFonts.inter()),
                    ),
                    ...jenisLaporanList.map((jenis) {
                      return DropdownMenuItem<int?>(
                        value: jenis['id'],
                        child: Text(
                          jenis['nama'] ?? '',
                          style: GoogleFonts.inter(),
                        ),
                      );
                    }),
                  ],
                  onChanged: (jenisId) {
                    setState(() {
                      selectedJenisLaporan = jenisId;
                    });
                    _loadLaporan();
                  },
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Status Filter Dropdown
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int?>(
                  value: selectedStatus,
                  hint: Text(
                    'Semua status',
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                  isExpanded: true,
                  items: [
                    DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Semua Status', style: GoogleFonts.inter()),
                    ),
                    DropdownMenuItem<int?>(
                      value: 0,
                      child: Text('Belum ditindak', style: GoogleFonts.inter()),
                    ),
                    DropdownMenuItem<int?>(
                      value: 1,
                      child: Text(
                        'Sedang diproses',
                        style: GoogleFonts.inter(),
                      ),
                    ),
                    DropdownMenuItem<int?>(
                      value: 2,
                      child: Text('Selesai', style: GoogleFonts.inter()),
                    ),
                  ],
                  onChanged: (statusId) {
                    setState(() {
                      selectedStatus = statusId;
                    });
                    _loadLaporan();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLaporanCard(Map<String, dynamic> laporan) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserDetailScreen(laporanId: laporan['id']),
          ),
        );
        // Refresh list when returning from detail
        _loadLaporan();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Bukti Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: laporan['bukti'] ?? '',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _getJenisLaporan(laporan),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _buildStatusBadge(laporan['status'] ?? 0),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(laporan['waktu']),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    laporan['alamat'] ?? '',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF0F55C7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getJenisLaporan(Map<String, dynamic> laporan) {
    // Try flat format (jenis_laporan_nama)
    if (laporan['jenis_laporan_nama'] != null &&
        laporan['jenis_laporan_nama'].toString().isNotEmpty) {
      return laporan['jenis_laporan_nama'];
    }

    // Try nested format (jenis_laporan.nama)
    if (laporan['jenis_laporan'] != null && laporan['jenis_laporan'] is Map) {
      final jenisLaporan = laporan['jenis_laporan'] as Map<String, dynamic>;
      if (jenisLaporan['nama'] != null) {
        return jenisLaporan['nama'];
      }
    }

    // Try tindak_lanjut nested format
    if (laporan['tindak_lanjut'] != null &&
        laporan['tindak_lanjut'] is Map &&
        laporan['tindak_lanjut']['jenis_laporan'] != null) {
      final tindakLanjut = laporan['tindak_lanjut'] as Map<String, dynamic>;
      if (tindakLanjut['jenis_laporan'] is Map &&
          tindakLanjut['jenis_laporan']['nama'] != null) {
        return tindakLanjut['jenis_laporan']['nama'];
      }
    }

    return 'N/A';
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'dd/mm/yy';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString().substring(2)}';
    } catch (e) {
      return 'dd/mm/yy';
    }
  }

  Widget _buildStatusBadge(int status) {
    Color bgColor;
    String text;

    switch (status) {
      case 0:
        bgColor = Colors.red;
        text = 'Belum Ditindak';
        break;
      case 1:
        bgColor = const Color(0xFF00BCD4); // Cyan/Teal color
        text = 'Sedang Diproses';
        break;
      case 2:
        bgColor = const Color(0xFF0F55C7); // Blue color
        text = 'Selesai';
        break;
      default:
        bgColor = Colors.grey;
        text = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Beranda
              _buildNavItem(
                icon: Icons.home_rounded,
                label: 'Beranda',
                isActive: false,
                onTap: () => Navigator.pop(context),
              ),

              // Camera (center button - decorative)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0F55C7), Color(0xFF3B7DE8)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F55C7).withValues(alpha: 0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),

              // Laporan (active)
              _buildNavItem(
                icon: Icons.assignment_rounded,
                label: 'Laporan',
                isActive: true,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF0F55C7).withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF0F55C7) : Colors.grey.shade400,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive
                    ? const Color(0xFF0F55C7)
                    : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
