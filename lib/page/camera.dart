// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:object_detector_lele/config.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

class VideoStreamPage extends StatefulWidget {
  @override
  _VideoStreamPageState createState() => _VideoStreamPageState();
}

class _VideoStreamPageState extends State<VideoStreamPage> {
  File? video_path;
  VideoPlayerController? videoPlayerController;
  MediaStream? _localStream;
  bool isFrontCamera = true;
  bool isStreaming = false;
  bool? isLoading = false;
  CameraController? _cameraController;
  String? _videoPath;
  Timer? _streamingTimer;
  XFile? videoFile;


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if(_streamingTimer != null){
      _streamingTimer?.cancel();
    }
    if (isStreaming == true) {
      stopVideoRecording();
    }
    if (_cameraController != null) {
      _cameraController?.dispose();
    }
  }
  
  void streamingSetting() async {
    
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _cameraController = CameraController(firstCamera, ResolutionPreset.high);

    await _cameraController!.initialize();

    final appDir = await getApplicationDocumentsDirectory();
    _videoPath = '${appDir.path}/video.mp4';
    setState(() {
      isStreaming = true;
    });
    _streamingTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      onVideoRecordButtonPressed();
      Timer(Duration(seconds: 10), () {
        onStopButtonPressed();
      });
    });

  }

    void onVideoRecordButtonPressed() {
      startVideoRecording().then((_) {
        if (mounted) {
         setState(() {
            
          });
        }
      });
    }


    Future<void> startVideoRecording() async {

      final CameraController? cameraController = _cameraController;

      if (cameraController == null || !cameraController.value.isInitialized) {
        print('Error: select a camera first.');
        return;
      }

      if (cameraController.value.isRecordingVideo) {
        // A recording is already started, do nothing.
        return;
      }

      try {
        await cameraController.startVideoRecording();
      } on CameraException catch (e) {
        print(e);
        return;
      }
    }

    
    void onStopButtonPressed() {
      stopVideoRecording().then((XFile? file) {
        if (mounted) {
          setState(() {});
        }
        if (file != null) {
          print('Video recorded to ${file.path}');
          videoFile = file;
          sendVideo(file.path);
          // _startVideoPlayer();
        }
      });
    }

   Future<XFile?> stopVideoRecording() async {

    final CameraController? cameraController = _cameraController;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      return cameraController.stopVideoRecording();
    } on CameraException catch (e) {
      print(e);
      return null;
    }
  }

  // upload video from local storage
  Future<void> _pickVideo() async {
    final pickedFile = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        video_path = File(pickedFile.path);
        videoPlayerController = VideoPlayerController.file(video_path!)
          ..initialize().then((_) {
            setState(() {});
            videoPlayerController!.play();
          });
      });
    }
  }
  
  // switch camera
  Future<void> switchCamera() async {
    if (_localStream == null) return;
    final track = _localStream!.getVideoTracks().first;
    await track.switchCamera();
    isFrontCamera = !isFrontCamera;
    setState(() {});
  }

  // upload video to api
  Future<void> sendVideo(String filePath, [bool fromStorage = false]) async {
    String baseUrl = await ConfigApp.baseUrl()??'';

    try {
      
          if (fromStorage == false) {

            var request = http.MultipartRequest(
              'POST',
              Uri.parse('${baseUrl}/process_video'),
            );

            final file = File(filePath);
            final length = await file.length();

            if (length == 0) {
              print('Error: File size is zero bytes');
              return;
            } else {
              print('File size: $length bytes');
            }

            request.files.add(
              await http.MultipartFile.fromPath('file', filePath),
            );

            var response = await request.send();
            if (response.statusCode == 200) {
              print('Video sent successfully');
            } else {
              print('Failed to send video: ${response.statusCode}');
            }

            File temporaryFile = File(filePath);
            await temporaryFile.delete();

          } else {
            setState(() {
              isLoading = true;
            });

            var request = http.MultipartRequest(
              'POST',
              Uri.parse('${baseUrl}/process_video'),
            );

            final file = File(filePath);
            final length = await file.length();

            if (length == 0) {
              print('Error: File size is zero bytes');
              return;
            } else {
              print('File size: $length bytes');
            }

            request.files.add(
              await http.MultipartFile.fromPath('file', filePath),
            );

            var response = await request.send().then((result) {
              Navigator.pop(context);
            });

            if (response.statusCode == 200) {
              print('Video sent successfully');
            } else {
              print('Failed to send video: ${response.statusCode}');
            }
          }
    } catch (e) {
      throw e;
    }
  
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Stream'),
        actions: [
          IconButton(
            icon: Icon(Icons.switch_camera),
            onPressed: switchCamera,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                if (video_path != null) ...{
                    Container(
                      width: width,
                      child: AspectRatio(
                        aspectRatio: videoPlayerController!.value.aspectRatio,
                        child: VideoPlayer(videoPlayerController!),
                      ),
                    )
                  },
                  if (isStreaming == true && _cameraController != null) ...{
                    Container(
                      width: width,
                      height: height * 0.5,
                      child: AspectRatio(
                        aspectRatio: _cameraController!.value.aspectRatio,
                        child: CameraPreview(_cameraController!),
                      ),
                    )
                  }
                ],
                
                
            ),
          ),
          if (isLoading == false) ...{
            Container(
              height: height * 0.25,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isStreaming == false) ...{
                    FilledButton(
                      style: ButtonStyle(
                          elevation: WidgetStatePropertyAll(0),
                          backgroundColor: WidgetStatePropertyAll(
                              Colors.grey.shade400)),
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
                  if (isStreaming == true) ...{
                    FilledButton(
                      style: ButtonStyle(
                          elevation: WidgetStatePropertyAll(0),
                          backgroundColor: WidgetStatePropertyAll(
                              Colors.grey.shade400)),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.stop,
                        size: 56,
                        color: Colors.red,
                      ),
                    ),
                  },
                  SizedBox(
                    height: height * 0.03,
                  ),
                  Column(
                    children: [
                      Text(
                        'atau unggah video',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                      SizedBox(
                        height: height * 0.01,
                      ),
                      if (video_path == null) ...{
                        ElevatedButton.icon(
                          style: ButtonStyle(
                              elevation: WidgetStatePropertyAll(0),
                              backgroundColor: WidgetStatePropertyAll(
                                  ConfigApp.colors['primary'])),
                          icon: Icon(
                            Icons.phone_iphone_sharp,
                            color: Colors.white,
                          ),
                          onPressed: _pickVideo,
                          label: Text(
                            'Pilih video dari galeri',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      },
                      if (video_path != null) ...{
                        ElevatedButton.icon(
                          style: ButtonStyle(
                              elevation: WidgetStatePropertyAll(0),
                              backgroundColor: WidgetStatePropertyAll(
                                  ConfigApp.colors['primary'])),
                          icon: Icon(
                            Icons.file_upload_outlined,
                            color: Colors.white,
                          ),
                          onPressed: (){
                            if (video_path != null) {
                              sendVideo(video_path?.path??'',true);
                            }
                          },
                          label: Text(
                            'Upload Video',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      },
                    ],
                  ),
                ],
              ),
            ),
          },
          if (isLoading == true) ...{
            Container(
              height: height * 0.25,
              child: Center(child: CircularProgressIndicator()),
            )
          }
        ],
      ),
    );
  }
}
