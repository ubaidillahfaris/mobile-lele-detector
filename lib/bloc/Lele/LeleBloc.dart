import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:object_detector_lele/config.dart';
import 'package:object_detector_lele/model/Lele.dart';
part 'lele_state.dart';
part 'lele_event.dart';

class LeleBloc extends Bloc<LeleEvent, LeleState>{
  LeleBloc(): super(LeleInitState()){
    on<FetchDataLele>(_fetchDataLeleHandler);
    on<FetchDataLeleKnn>(_fetchDataLeleKnnHandler);
    on<DeleteRiwayat>(_deleteRiwayat);
  }

  void _fetchDataLeleHandler(FetchDataLele event, Emitter<LeleState> emit) async{
    try {
      String baseUrl = await ConfigApp?.baseUrl()??'';

      Dio dio = Dio();
      var request = await dio.get('${baseUrl}/perhitungan/show/yolo');
      List<LeleModel> response = request.data.map<LeleModel>((item) {
        return LeleModel.fromJson(item);
      }).toList();
      
      emit(SuccessFetchLeleData(data: response));
    } catch (e) {
      emit(ErrorFetchLeleData());
    }
  }

  void _fetchDataLeleKnnHandler(FetchDataLeleKnn event, Emitter<LeleState> emit) async{
    try {
      String baseUrl = await ConfigApp?.baseUrl()??'';

      Dio dio = Dio();
      var request = await dio.get('${baseUrl}/perhitungan/show/knn');
      print(request);
      List<LeleModel> response = request.data.map<LeleModel>((item) {
        return LeleModel.fromJson(item);
      }).toList();
      
      emit(SuccessFetchLeleDataKnn(data: response));
    } 
    on DioException catch(e){
      emit(ErrorFetchLeleDataKnn());
    }
    catch (e) {
      emit(ErrorFetchLeleDataKnn());
    }
  }

  void _deleteRiwayat(DeleteRiwayat event, Emitter<LeleState> emit) async{
    try {
      Dio dio = Dio();
      String baseUrl = await ConfigApp?.baseUrl()??'';
      await dio.delete('${baseUrl}/perhitungan/delete/${event.id}');
      emit(SuccessDeleteData());
    } catch (e) {
      emit(FailDeleteData());
      
    }
  }
}