part of 'HargaBloc.dart';

abstract class HargaState{}
class InitHargaState implements HargaState{}
class SuccessFetchHarga implements HargaState{
  List<HargaModel> data;
  SuccessFetchHarga({
    required this.data
  });
}

class FailFetchHarga implements HargaState{
  String message = 'Gagal mengambil data';
}

class OnLoadingProcess implements HargaState{}

class SuccessUpdateHarga implements HargaState{
  String message = 'Berhasil mengubah data';
}
