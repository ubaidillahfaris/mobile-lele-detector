class HargaModel {
  final int id;
  final String grade;
  final double harga;

  HargaModel({
    required this.id,
    required this.grade,
    required this.harga
  });

  factory HargaModel.fromJson(Map<String, dynamic> json) {
    return HargaModel(
      id: json['id'], 
      grade: json['grade'], 
      harga: json['harga'],
    );
  }

  Map<String, dynamic> toJson(HargaModel data){
    return {
      'grade' : data.grade,
      'harga' : data.harga
    };
  }
}