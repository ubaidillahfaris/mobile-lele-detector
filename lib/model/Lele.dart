class LeleModel {
  final int id;
  final String grade;
  final int jumlah;
  final String tanggal;
  final double total_harga;
  final String video_url;
  final String? video_url_knn;
  final String created_at;

  LeleModel({
    required this.id,
    required this.grade,
    required this.jumlah,
    required this.tanggal,
    required this.total_harga,
    required this.video_url,
    this.video_url_knn,
    required this.created_at
  });

  factory LeleModel.fromJson(Map<String, dynamic> json){
    return LeleModel(
      id: json['id'], 
      grade: json['grade'], 
      jumlah: json['jumlah'], 
      tanggal: json['tanggal'], 
      total_harga: double.parse(json['total_harga']), 
      video_url: json['video_url'],
      video_url_knn : json['video_url_knn'],
      created_at: json['created_at']
    );
  }
}