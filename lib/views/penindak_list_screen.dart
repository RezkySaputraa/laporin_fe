import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:laporin_app/controllers/penindak_list_controller.dart';
import 'package:laporin_app/models/penindak_laporan_model.dart';
import 'package:laporin_app/views/penindak_detail_screen.dart';

class PenindakListScreen extends StatefulWidget {
  const PenindakListScreen({super.key});

  @override
  State<PenindakListScreen> createState() => _PenindakListScreenState();
}

class _PenindakListScreenState extends State<PenindakListScreen> {
  late PenindakListController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<PenindakListController>()
        ? Get.find<PenindakListController>()
        : Get.put(PenindakListController());
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
          'List Laporin',
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
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF0F55C7)),
                );
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        controller.errorMessage.value,
                        style: GoogleFonts.inter(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: controller.loadLaporan,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                );
              }

              if (controller.laporanList.isEmpty) {
                return Center(
                  child: Text(
                    'Tidak ada laporan',
                    style: GoogleFonts.inter(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshData,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.laporanList.length,
                  itemBuilder: (context, index) {
                    return _buildLaporanCard(controller.laporanList[index]);
                  },
                ),
              );
            }),
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
            onPressed: controller.toggleSortOrder,
            icon: Obx(
              () => Icon(
                controller.isAscending.value
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                color: const Color(0xFF0F55C7),
              ),
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
              child: Obx(
                () => DropdownButtonHideUnderline(
                  child: DropdownButton<int?>(
                    value: controller.selectedJenisLaporan.value,
                    hint: Text(
                      'Jenis laporan',
                      style: GoogleFonts.inter(fontSize: 14),
                    ),
                    isExpanded: true,
                    items: [
                      DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Semua', style: GoogleFonts.inter()),
                      ),
                      ...controller.jenisLaporanList.map((jenis) {
                        return DropdownMenuItem<int?>(
                          value: jenis['id'],
                          child: Text(
                            jenis['nama'] ?? '',
                            style: GoogleFonts.inter(),
                          ),
                        );
                      }),
                    ],
                    onChanged: controller.onFilterByJenis,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Search Field
          Expanded(
            flex: 3,
            child: TextField(
              controller: controller.searchController,
              onSubmitted: controller.onSearch,
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: GoogleFonts.inter(fontSize: 14),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () =>
                      controller.onSearch(controller.searchController.text),
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

  Widget _buildLaporanCard(PenindakLaporanModel laporan) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PenindakDetailScreen(laporanId: laporan.id),
          ),
        );
        // Refresh list when returning from detail
        controller.refreshData();
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
                imageUrl: laporan.bukti,
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
                        laporan.pelaporName,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      _buildStatusBadge(laporan.status),
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
                        laporan.formattedDate,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    laporan.jenisLaporanName,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF0F55C7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
