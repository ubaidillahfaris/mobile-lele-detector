part of 'LeleBloc.dart';
abstract class LeleState{}
class LeleInitState implements LeleState{}
class SuccessFetchLeleData implements LeleState{
  final List<LeleModel> data;
  SuccessFetchLeleData({
    required this.data
  });
}

class ErrorFetchLeleData implements LeleState{
  final String response = 'Gagal mendapatkan data';
}

class SuccessFetchLeleDataKnn implements LeleState{
  final List<LeleModel> data;
  SuccessFetchLeleDataKnn({
    required this.data
  });
}

class ErrorFetchLeleDataKnn implements LeleState{
  final String response = 'Gagal mendapatkan data';
}

class SuccessDeleteData implements LeleState{}
class FailDeleteData implements LeleState{}
