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

class FailUpdateHarga implements HargaState{
  String message = 'Gagal mengubah data data';
}

class SuccessCreateHarga implements HargaState{
  String message = 'Berhasil membuat data harga';
}

class FailCreateHarga implements HargaState{
  String message = 'Gagal membuat data harga';
}

class SuccessDeleteHarga implements HargaState{
  String message = 'Berhasil menghapus data harga';
}

class FailDeleteHarga implements HargaState{
  String message = 'Gagal menghapus data harga';
}
