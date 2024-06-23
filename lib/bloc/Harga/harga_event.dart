part of 'HargaBloc.dart';
class HargaEvent{}
class FetchHargaEvent implements HargaEvent{}
class UpdateHargaEvent implements HargaEvent{
  final int id;
  final String grade;
  final String harga;

  UpdateHargaEvent({
    required this.id,
    required this.grade,
    required this.harga
  });
}

class CreateHargaEvent implements HargaEvent{
  final String grade;
  final String harga;

  CreateHargaEvent({
    required this.grade,
    required this.harga
  });
}

class DeleteHargaEvent implements HargaEvent{
  final int id;
  DeleteHargaEvent({
    required this.id
  });
}