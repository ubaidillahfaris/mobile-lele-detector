import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:object_detector_lele/config.dart';

part 'PenyortiranEvent.dart';
part 'PenyortiranState.dart';

class PenyortiranBloc extends Bloc<PenyortiranEvent, PenyortiranState>{
  PenyortiranBloc():super(PenyortiranInitState()){
    on<UploadVideo>(uploadVideo);
    on<RecordEvent>(recordEvent);
    on<StopRecordEvent>(stopRecordEvent);
  }

  void recordEvent(RecordEvent event, Emitter<PenyortiranState> emit){
    emit(OnRecordState());
  }

  void stopRecordEvent(StopRecordEvent event, Emitter<PenyortiranState> emit){
    emit(OnStopRecordState());
  }

  void uploadVideo(UploadVideo event, Emitter<PenyortiranState> emit)async{
    emit(OnLoadingUploadFile());
    String baseUrl = await ConfigApp.baseUrl() ?? 'http://192.168.18.106:8000'; // Ganti dengan URL API Anda yang benar
    Dio dio = Dio();

    try {
      if (event.fromStorage) {
        emit(OnLoadingUploadFile());
        FormData formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(event.filePath),
        });

        Response response = await dio.post(
          '${baseUrl}/process_video',
          data: formData,
        );

      } else {
        FormData formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(event.filePath),
        });


        Response response = await dio.post(
          '${baseUrl}/process_video',
          data: formData,
        );

        File temporaryFile = File(event.filePath);
        await temporaryFile.delete();
        
      }

      emit(SuccessUploadFile());
    } catch (e) {
      print('Exception caught: $e');
      emit(ErrorUploadFile());
    }
  }
}