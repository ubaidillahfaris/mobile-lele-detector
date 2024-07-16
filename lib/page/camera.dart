// ignore_for_file: deprecated_member_use, must_be_immutable

import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:object_detector_lele/bloc/Penyortiran/PenyortiranBloc.dart';
import 'package:video_player/video_player.dart';

class VideoStreamPage extends StatefulWidget {
  CameraController cameraController;

  VideoStreamPage({
    required this.cameraController
  });

  @override
  _VideoStreamPageState createState() => _VideoStreamPageState();
}

class _VideoStreamPageState extends State<VideoStreamPage> {
  File? video_path;
  late VideoPlayerController videoPlayerController;
  bool isFrontCamera = true;
  bool isStreaming = false;
  bool? isLoading = false;
  late CameraController cameraController;
  Timer? streamingTimer;
  XFile? videoFile;
  PenyortiranBloc penyortiranBloc = PenyortiranBloc();
  FlashMode flashState = FlashMode.off;

  @override
  void initState() {
    super.initState();
    cameraController = widget.cameraController;
    cameraController.initialize();
    setState(() {});
  }

 
  /// Mengatur streaming video dan mulai timer untuk merekam setiap 10 detik
  void streamingSetting() async {
    
    try {
      penyortiranBloc.add(RecordEvent());
      await cameraController.prepareForVideoRecording();
      await cameraController.startVideoRecording();

    } catch (e) {
      penyortiranBloc.add(StopRecordEvent());
    }
  }

  /**
   * set flash state
   */
  void flashStateHandler(){
    switch (flashState) {
      case FlashMode.off:
          setState(() {
            flashState = FlashMode.torch;
          });
        break;
      case FlashMode.torch:
          setState(() {
            flashState = FlashMode.off;
          });
        break;
      default:
    }

    cameraController.setFlashMode(flashState);
  }

  /// Menghentikan rekaman video dan mengirimkan file video ke server
  void onStopButtonPressed() {
    penyortiranBloc.add(StopRecordEvent());
    stopVideoRecording().then((XFile? file) {
      if (mounted) {
        setState(() {});
      }
      if (file != null) {
        videoFile = file;
        sendVideo(context, file.path);
      }
    });
  }

  /// Menghentikan rekaman video dan mengembalikan file video
  Future<XFile?> stopVideoRecording() async {
    
    try {
      return await cameraController.stopVideoRecording();
    } on CameraException catch (e) {
      return null;
    }
  }

  /// Memilih video dari galeri dan menampilkan di pemutar video
  Future<void> _pickVideo() async {
    final pickedFile = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        video_path = File(pickedFile.path);
        videoPlayerController = VideoPlayerController.file(video_path!)
          ..initialize().then((_) {
            setState(() {});
            videoPlayerController.play();
          });
      });
    }
  }

   /// Mengirimkan video yang direkam atau dipilih ke server
  /// [filePath] adalah jalur file video yang akan dikirim
  /// [fromStorage] menentukan apakah video berasal dari penyimpanan lokal
  void sendVideo(BuildContext context, String filePath, [bool fromStorage = false]) async {
    try {
      penyortiranBloc.add(UploadVideo(filePath: filePath, fromStorage: fromStorage));
    } catch (e) {
      print(e);
    }
  }


  void _showProcessingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Processing'),
          content: Text('Video sedang diproses'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context)..pop()..pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

   @override
  void dispose() {
    penyortiranBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: BlocProvider(
        create: (context) => penyortiranBloc,
        child: BlocListener<PenyortiranBloc, PenyortiranState>(
          listener: (context, state) {
            if (state is SuccessUploadFile) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Berhasil mengupload video')));
            }
            if (state is ErrorUploadFile) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengupload video')));
            }
            if (state is OnLoadingUploadFile){
              
            }
          },
          child: BlocBuilder<PenyortiranBloc, PenyortiranState>(
                  builder: (context, state) {
                    return Stack(
                      children: [ 
                        if(video_path != null)...{
                          Container(
                            height: height,
                            width: width,
                            child: AspectRatio(
                              aspectRatio: videoPlayerController.value.aspectRatio,
                              child: VideoPlayer(videoPlayerController),
                            ),
                          )
                        },
                        if(video_path == null)...{
                          Container(
                            height: height,
                            width: width,
                            child: AspectRatio(
                            aspectRatio: cameraController.value.aspectRatio,
                            child: CameraPreview(cameraController),
                                                      ),
                          ),
                        },
                        Positioned(
                          top: 0,
                          child: SafeArea(
                            child: InkWell(
                              onTap:() {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration( 
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(12))
                                ),
                                margin: EdgeInsets.only(left: width * 0.05),
                                child: Icon(Icons.arrow_back_ios_new),
                              ),
                            ),
                          ),
                        ),
                        if(state is! OnLoadingUploadFile)
                        Positioned(
                          bottom: height * 0.05,
                          child: Container(
                            width: width,
                            height: height * 0.1,
                            child: Row( 
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [ 
                                  InkWell(
                                    onTap: () {
                                      flashStateHandler();
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration( 
                                        borderRadius: BorderRadius.all(Radius.circular(12)),
                                        color: Colors.grey.shade400.withOpacity(0.6)
                                      ),
                                      child: Icon(
                                        flashState == FlashMode.off ? Icons.flash_off_rounded : Icons.flash_on_rounded,
                                        color: Colors.white,
                                        size: 36,
                                      ),
                                    ),
                                  ),

                                if(video_path != null)...{
                                    ElevatedButton.icon(
                                      style: ButtonStyle(
                                          padding: WidgetStatePropertyAll(EdgeInsets.all(8)),
                                          elevation: WidgetStatePropertyAll(0),
                                          backgroundColor: WidgetStatePropertyAll(Colors.grey.shade900.withOpacity(0.8))
                                      ),
                                      icon: Icon(
                                        Icons.file_upload_outlined,
                                        color: Colors.white,
                                      ),
                                      onPressed: (){
                                        if (video_path != null) {
                                          sendVideo(context, video_path?.path??'',true);
                                        }
                                      },
                                      label: Text(
                                        'Upload Video',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    )
                                },

                                if (video_path == null && state is! OnRecordState) ...{

                                  FilledButton(
                                    style: ButtonStyle(
                                        elevation: WidgetStatePropertyAll(0),
                                        backgroundColor: WidgetStatePropertyAll(
                                            Colors.grey.shade400.withOpacity(0.4))),
                                    onPressed: (){
                                      streamingSetting();
                                    },
                                    child: Icon(
                                      Icons.fiber_manual_record_sharp,
                                      size: 56,
                                      color: Colors.red,
                                    ),
                                  ),
                                },

                                if (video_path == null && state is OnRecordState) ...{
                                  FilledButton(
                                    style: ButtonStyle(
                                        elevation: WidgetStatePropertyAll(0),
                                        backgroundColor: WidgetStatePropertyAll(
                                            Colors.grey.shade400.withOpacity(0.4))),
                                    onPressed: () {
                                      onStopButtonPressed();
                                    },
                                    child: Icon(
                                      Icons.stop,
                                      size: 56,
                                      color: Colors.red,
                                    ),
                                  ),
                                },
                                InkWell(
                                  onTap: () {
                                    _pickVideo();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration( 
                                      borderRadius: BorderRadius.all(Radius.circular(12)),
                                      color: Colors.grey.shade400.withOpacity(0.6)
                                    ),
                                    child: Icon(
                                      Icons.cloud_upload,
                                      color: Colors.white,
                                      size: 36,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ),
                        
                        if(state is OnLoadingUploadFile)...{
                          Center( 
                            child: LoadingAnimationWidget.flickr(
                              leftDotColor: const Color(0xFF1A1A3F),
                              rightDotColor: const Color(0xFFEA3799),
                              size: 50,
                            ),
                          )
                        }
                      ],
                    );
                  },
                ),
        ),
      ),
    );
  }
}
