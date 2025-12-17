class LaporinJenisModel {
  final int id;
  final String nama;

  LaporinJenisModel({required this.id, required this.nama});

  factory LaporinJenisModel.fromJson(Map<String, dynamic> json) {
    return LaporinJenisModel(id: json['id'], nama: json['nama']);
  }
}
