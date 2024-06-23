import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:object_detector_lele/config.dart';
import 'package:object_detector_lele/model/Harga.dart';
part 'harga_state.dart';
part 'harga_event.dart';

class HargaBloc extends Bloc<HargaEvent, HargaState>{
  HargaBloc() :super(InitHargaState()){
    on<FetchHargaEvent>(fectHargaHandler);
    on<UpdateHargaEvent>(updateHargaHandler);
  }

  void fectHargaHandler(FetchHargaEvent event, Emitter<HargaState> emit) async{
    
    Dio dio = Dio();

    try {
      var request = await dio.get(
        '${ConfigApp.baseUrl}/harga/show'
      );

      List<dynamic> response = request.data;
      List<HargaModel> data = response.map<HargaModel>((item) {
        return HargaModel(id: item['id'], grade: item['grade'], harga: double.parse(item['harga']));
      }).toList();

      emit(SuccessFetchHarga(data: data));
    } catch (e) {
      emit(FailFetchHarga());
    }
  }

  void updateHargaHandler(UpdateHargaEvent event, Emitter<HargaState> emit) async {
    emit(OnLoadingProcess());
    Dio dio = Dio();
    int id = event.id;

    var data = FormData.fromMap({
      'grade' : event.grade,
      'harga' : event.harga
    });

    try {
      
      var request = await dio.request(
        '${ConfigApp.baseUrl}/harga/update/${id}',
        options: Options(
          method: 'PUT',
        ),
        data: data
      );

      Map<String, dynamic> response = request.data;
      emit(SuccessUpdateHarga());

    } catch (e) {
      throw e;
    }
  }

}