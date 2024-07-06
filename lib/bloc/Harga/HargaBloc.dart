import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:object_detector_lele/config.dart';
import 'package:object_detector_lele/model/Harga.dart';
part 'harga_state.dart';
part 'harga_event.dart';

class HargaBloc extends Bloc<HargaEvent, HargaState>{
  HargaBloc() :super(InitHargaState()){
    on<FetchHargaEvent>(fectHargaHandler);
    on<CreateHargaEvent>(createHargaHanlder);
    on<UpdateHargaEvent>(updateHargaHandler);
    on<DeleteHargaEvent>(deleteHargaHandler);
  }

  void fectHargaHandler(FetchHargaEvent event, Emitter<HargaState> emit) async{
    
    Dio dio = Dio();

    try {

      String baseUrl = await ConfigApp?.baseUrl()??'';

      var request = await dio.get(
        '${baseUrl}/harga/show'
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

  void createHargaHanlder(CreateHargaEvent event, Emitter<HargaState> emit) async{
    emit(OnLoadingProcess());
    Dio dio = Dio();

    var data = FormData.fromMap({
      'grade' : event.grade,
      'harga' : event.harga
    });

    try {

      String baseUrl = await ConfigApp?.baseUrl()??'';

      var request = await dio.request(
        '${baseUrl}/harga/create',
        options: Options(
          method: 'POST',
        ),
        data: data
      );
      Map<String, dynamic> response = request.data;
      emit(SuccessCreateHarga());
    } catch (e) {
      emit(FailCreateHarga());
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

      String baseUrl = await ConfigApp?.baseUrl()??'';

      
      var request = await dio.request(
        '${baseUrl}/harga/update/${id}',
        options: Options(
          method: 'PUT',
        ),
        data: data
      );

      Map<String, dynamic> response = request.data;
      emit(SuccessUpdateHarga());

    } catch (e) {
      emit(FailUpdateHarga());
    }
  }

  void deleteHargaHandler(DeleteHargaEvent event, Emitter<HargaState> emit) async{

    Dio dio = Dio();
    int id = event.id;

    try {
      String baseUrl = await ConfigApp?.baseUrl()??'';
       var request = await dio.request(
        '${baseUrl}/harga/delete/${id}',
        options: Options(
          method: 'DELETE',
        )
      );
      emit(SuccessDeleteHarga());

    } catch (e) {
      emit(FailDeleteHarga());
    }
  }

}