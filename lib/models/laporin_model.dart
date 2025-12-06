class LaporinModel {
  final int pelapor;
  final String alamat;
  final int jenisLaporan;
  final String waktu;
  final String catatanPelapor;
  final String bukti;
  final int status;

  LaporinModel({
    required this.pelapor,
    required this.alamat,
    required this.jenisLaporan,
    required this.waktu,
    required this.catatanPelapor,
    required this.bukti,
    required this.status,
  });

  factory LaporinModel.fromJson(Map<String, dynamic> json) => LaporinModel(
    pelapor: json["pelapor"],
    alamat: json["alamat"],
    jenisLaporan: json["jenis_laporan"],
    waktu: json["waktu"],
    catatanPelapor: json["catatan_pelapor"],
    bukti: json["bukti"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "pelapor": pelapor,
    "alamat": alamat,
    "jenis_laporan": jenisLaporan,
    "waktu": waktu,
    "catatan_pelapor": catatanPelapor,
    "bukti": bukti,
    "status": status,
  };
}
