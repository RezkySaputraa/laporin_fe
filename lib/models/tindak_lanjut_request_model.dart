/// Model untuk request tindak lanjut laporan
class TindakLanjutRequest {
  final int penindakId;
  final String catatanPenindak;
  final String? hasil; // URL gambar bukti tindakan (optional)

  TindakLanjutRequest({
    required this.penindakId,
    required this.catatanPenindak,
    this.hasil,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'penindak_id': penindakId,
      'catatan_penindak': catatanPenindak,
    };

    if (hasil != null && hasil!.isNotEmpty) {
      data['hasil'] = hasil;
    }

    return data;
  }
}
