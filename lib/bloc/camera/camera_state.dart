part of 'CameraBloc.dart';

abstract class CameraState {}
class CameraInitState implements CameraState{}
class SuccessStartCamera implements CameraState{
  final CameraController controller;
  SuccessStartCamera({
    required this.controller
  });
}

class FailStartCamera implements CameraState{
  final String message = 'Fail start camera';
}