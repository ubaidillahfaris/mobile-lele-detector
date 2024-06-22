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