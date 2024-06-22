import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
part 'camera_state.dart';
part 'camera_event.dart';
class CameraBloc extends Bloc<CameraEvent, CameraState>{
  CameraBloc():super(CameraInitState()){
    on<StartCamera>(_cameraStart);
  }

  void _cameraStart(StartCamera event, Emitter<CameraState> emit) async {
    try {
      late List<CameraDescription> _cameras;
      _cameras = await availableCameras();
      
      late CameraController controller;
      controller = CameraController(_cameras[0], ResolutionPreset.max);
      emit(SuccessStartCamera(controller: controller));
    } catch (e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            emit(FailStartCamera());
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    }
  }
}