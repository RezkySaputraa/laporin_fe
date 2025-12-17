/// Model untuk data laporan yang diterima dari endpoint penindak
/// Includes nested data from users, jenis_laporan, and tindak_lanjut tables
class PenindakLaporanModel {
  final int id;
  final int pelapor;
  final int jenisLaporanId;
  final String alamat;
  final DateTime waktu;
  final String bukti;
  final int? hasilTindak;
  final String catatanPelapor;
  final int status; // 0 = Belum ditindak, 1 = Sedang diproses, 2 = Selesai

  // Nested data
  final UserData? users;
  final JenisData? jenis;
  final TindakData? tindak;

  PenindakLaporanModel({
    required this.id,
    required this.pelapor,
    required this.jenisLaporanId,
    required this.alamat,
    required this.waktu,
    required this.bukti,
    this.hasilTindak,
    required this.catatanPelapor,
    required this.status,
    this.users,
    this.jenis,
    this.tindak,
  });

  factory PenindakLaporanModel.fromJson(Map<String, dynamic> json) {
    // Handle jenis_laporan yang bisa berupa int atau Map/object
    int jenisId = 0;
    JenisData? jenisData;

    final jenisField = json['jenis_laporan'];
    if (jenisField is int) {
      jenisId = jenisField;
    } else if (jenisField is Map<String, dynamic>) {
      // Jika jenis_laporan adalah object dengan 'nama' field
      jenisId = jenisField['id'] ?? 0;
      jenisData = JenisData.fromJson(jenisField);
    }

    // Jika ada field 'jenis' terpisah, gunakan itu
    if (json['jenis'] != null) {
      jenisData = JenisData.fromJson(json['jenis']);
    }

    return PenindakLaporanModel(
      id: json['id'] ?? 0,
      pelapor: json['pelapor'] ?? 0,
      jenisLaporanId: jenisId,
      alamat: json['alamat'] ?? '',
      waktu: DateTime.tryParse(json['waktu'] ?? '') ?? DateTime.now(),
      bukti: json['bukti'] ?? '',
      hasilTindak: json['hasil_tindak'] is int ? json['hasil_tindak'] : null,
      catatanPelapor: json['catatan_pelapor'] ?? '',
      status: json['status'] ?? 0,
      users: json['users'] != null ? UserData.fromJson(json['users']) : null,
      jenis: jenisData,
      tindak: json['tindak'] != null
          ? TindakData.fromJson(json['tindak'])
          : (json['tindak_lanjut'] != null
                ? TindakData.fromJson(json['tindak_lanjut'])
                : null),
    );
  }

  String get statusText {
    switch (status) {
      case 0:
        return 'Belum ditindak';
      case 1:
        return 'Sedang diproses';
      case 2:
        return 'Selesai';
      default:
        return 'Unknown';
    }
  }

  String get formattedDate {
    return '${waktu.day.toString().padLeft(2, '0')}-${waktu.month.toString().padLeft(2, '0')}-${waktu.year}';
  }

  String get pelaporName => users?.username ?? 'Unknown';
  String get jenisLaporanName => jenis?.nama ?? 'Unknown';
}

class UserData {
  final String username;
  final String email;

  UserData({required this.username, required this.email});

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class JenisData {
  final String nama;

  JenisData({required this.nama});

  factory JenisData.fromJson(Map<String, dynamic> json) {
    return JenisData(nama: json['nama'] ?? '');
  }
}

class TindakData {
  final String? hasil;
  final String? catatanPenindak;
  final int? penindak;

  TindakData({this.hasil, this.catatanPenindak, this.penindak});

  factory TindakData.fromJson(Map<String, dynamic> json) {
    return TindakData(
      hasil: json['hasil'],
      catatanPenindak: json['catatan_penindak'],
      penindak: json['penindak'],
    );
  }
}
