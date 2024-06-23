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