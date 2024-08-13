part of 'LeleBloc.dart';
class LeleEvent{}
class FetchDataLele implements LeleEvent{}

class FetchDataLeleKnn implements LeleEvent{}

class DeleteRiwayat implements LeleEvent{
  int id;
  DeleteRiwayat({
    required this.id
  });
}
