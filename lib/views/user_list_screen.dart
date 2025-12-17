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
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> laporanList = [];
  List<Map<String, dynamic>> jenisLaporanList = [];
  int? selectedJenisLaporan;
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
    searchController.dispose();
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
        search: searchController.text.isNotEmpty ? searchController.text : null,
      );

      // Sort by waktu
      result.sort((a, b) {
        final dateA = DateTime.parse(a['waktu']);
        final dateB = DateTime.parse(b['waktu']);
        return isAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
      });

      setState(() {
        laporanList = result
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

          // Search Field
          Expanded(
            flex: 3,
            child: TextField(
              controller: searchController,
              onSubmitted: (_) => _loadLaporan(),
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: GoogleFonts.inter(fontSize: 14),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _loadLaporan,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
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
                      Text(
                        laporan['jenis_laporan_nama'] ?? 'Tidak ada jenis',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
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
        text = 'belum ditindak';
        break;
      case 1:
        bgColor = const Color(0xFF00BCD4); // Cyan/Teal color
        text = 'sedang diproses';
        break;
      case 2:
        bgColor = const Color(0xFF0F55C7); // Blue color
        text = 'selesai';
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
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Beranda (disabled)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.home_outlined, color: Colors.grey.shade400),
                  Text(
                    'Beranda',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),

              // Camera (active indicator - disabled functionally)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F55C7),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F55C7).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),

              // Riwayat (disabled)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, color: Colors.grey.shade400),
                  Text(
                    'Riwayat',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
