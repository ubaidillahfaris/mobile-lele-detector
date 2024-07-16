part of 'PenyortiranBloc.dart';

abstract class PenyortiranState {}
class PenyortiranInitState implements PenyortiranState{}

class OnRecordState implements PenyortiranState{}
class OnStopRecordState implements PenyortiranState{}

class OnLoadingUploadFile implements PenyortiranState{}
class SuccessUploadFile implements PenyortiranState{}
class ErrorUploadFile implements PenyortiranState{}