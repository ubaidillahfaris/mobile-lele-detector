part of 'PenyortiranBloc.dart';

class PenyortiranEvent {}

class RecordEvent implements PenyortiranEvent{}
class StopRecordEvent implements PenyortiranEvent{}

class UploadVideo implements PenyortiranEvent{
  bool fromStorage;
  String filePath;

  UploadVideo({
    this.fromStorage = false,
    required this.filePath
  });
}