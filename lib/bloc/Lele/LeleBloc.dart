import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:object_detector_lele/config.dart';
import 'package:object_detector_lele/model/Lele.dart';
part 'lele_state.dart';
part 'lele_event.dart';

class LeleBloc extends Bloc<LeleEvent, LeleState>{
  LeleBloc(): super(LeleInitState()){
    on<FetchDataLele>(_fetchDataLeleHandler);
  }

  void _fetchDataLeleHandler(FetchDataLele event, Emitter<LeleState> emit) async{
    try {
      Dio dio = Dio();
      var request = await dio.get('${ConfigApp.baseUrl}/perhitungan/show');
      List<LeleModel> response = request.data.map<LeleModel>((item) {
        return LeleModel.fromJson(item);
      }).toList();
      
      emit(SuccessFetchLeleData(data: response));
    } catch (e) {
      emit(ErrorFetchLeleData());
    }
  }
}