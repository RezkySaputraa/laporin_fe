import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laporin_app/models/penindak_laporan_model.dart';
import 'package:laporin_app/services/penindak_service.dart';

class PenindakListController extends GetxController {
  final PenindakService _service = PenindakService();

  // Data
  RxList<PenindakLaporanModel> laporanList = <PenindakLaporanModel>[].obs;
  RxList<Map<String, dynamic>> jenisLaporanList = <Map<String, dynamic>>[].obs;

  // Filter & Search
  final TextEditingController searchController = TextEditingController();
  Rx<int?> selectedJenisLaporan = Rx<int?>(null);
  RxBool isAscending = false.obs;

  // State
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadJenisLaporan();
    loadLaporan();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  /// Load jenis laporan for filter dropdown
  Future<void> loadJenisLaporan() async {
    try {
      final result = await _service.getJenisLaporan();
      jenisLaporanList.value = result;
    } catch (e) {
      // Ignore error, dropdown will just be empty
    }
  }

  /// Load laporan with current filters
  Future<void> loadLaporan() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _service.getAllLaporan(
        jenisLaporan: selectedJenisLaporan.value,
      );

      // Local filter by pelapor name if search is not empty
      List<PenindakLaporanModel> filteredResult = result;
      if (searchController.text.isNotEmpty) {
        final searchQuery = searchController.text.toLowerCase();
        filteredResult = result.where((laporan) {
          return laporan.pelaporName.toLowerCase().contains(searchQuery) ||
              laporan.alamat.toLowerCase().contains(searchQuery);
        }).toList();
      }

      // Sort by ID (default descending - newest first)
      if (isAscending.value) {
        filteredResult.sort((a, b) => a.id.compareTo(b.id));
      } else {
        filteredResult.sort((a, b) => b.id.compareTo(a.id));
      }

      laporanList.value = filteredResult;
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  /// Search laporan
  void onSearch(String query) {
    loadLaporan();
  }

  /// Filter by jenis laporan
  void onFilterByJenis(int? jenisId) {
    selectedJenisLaporan.value = jenisId;
    loadLaporan();
  }

  /// Toggle sort order
  void toggleSortOrder() {
    isAscending.value = !isAscending.value;
    loadLaporan();
  }

  /// Refresh data
  Future<void> refreshData() async {
    await loadLaporan();
  }

  /// Reset all filters
  void resetFilters() {
    searchController.clear();
    selectedJenisLaporan.value = null;
    isAscending.value = false;
    loadLaporan();
  }
}
