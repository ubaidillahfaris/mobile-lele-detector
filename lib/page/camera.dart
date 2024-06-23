import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
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
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  VideoPlayerController? videoPlayerController;
  MediaStream? _localStream;
  bool isFrontCamera = true;
  bool isStreaming = false;
  Timer? _streamingTimer;
  String? _temporaryVideoPath;
  File? _temporaryVideoFile;
  IOSink? _videoFileSink;
  bool?  isLoading = false;

  @override
  void initState() {
    super.initState();
    initRenderers();
    startVideoStream();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _localStream?.dispose();
    _streamingTimer?.cancel();
    _videoFileSink?.close();
    super.dispose();
  }


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

  void uploadVideo(){
    if (video_path != null) {
      sendVideo(video_path!.path, true);
    }
  }

  Future<void> initRenderers() async {
    await _localRenderer.initialize();
  }

  Future<void> startVideoStream() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': false,
      'video': {
        'mandatory': {
          'minWidth': '640',
          'minHeight': '480',
          'minFrameRate': '30',
        },
        'facingMode': isFrontCamera ? 'user' : 'environment',
        'optional': [],
      }
    };

    try {
      MediaStream stream =
          await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _localRenderer.srcObject = stream;
      _localStream = stream;

      setState(() {});
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> switchCamera() async {
    if (_localStream == null) return;
    final track = _localStream!.getVideoTracks().first;
    await track.switchCamera();
    isFrontCamera = !isFrontCamera;
    setState(() {});
  }

  Future<void> startStreaming() async {
    if (_localStream == null) return;
    print('Start Stream');

    final directory = await getApplicationDocumentsDirectory();
    _temporaryVideoPath = '${directory.path}/temporary_video.mp4';

    _temporaryVideoFile = File(_temporaryVideoPath!);
    _videoFileSink = _temporaryVideoFile!.openWrite();

    setState(() {
      isStreaming = true;
    });

    _streamingTimer = Timer.periodic(Duration(milliseconds: 1000), (timer) async {
      if (!isStreaming) {
        timer.cancel();
        return;
      }

      final track = _localStream!.getVideoTracks().first;
      var frame = await track.captureFrame();
      await saveFrameToFile(frame);
    });

    Timer(Duration(seconds: 20), () {
      stopStreaming();
    });
  }

  Future<void> saveFrameToFile(ByteBuffer frameBuffer) async {
    Uint8List frame = frameBuffer.asUint8List();
    _videoFileSink!.add(frame);
  }

  Future<void> stopStreaming() async {
    if (!isStreaming) return;
    
    setState(() {
      isStreaming = false;
    });
    _streamingTimer?.cancel();
    await _videoFileSink?.close();
    await sendVideo(_temporaryVideoPath!);
  }

  Future<void> sendVideo(String filePath, [bool fromStorage = false]) async {

    if (fromStorage == false) {
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ConfigApp.baseUrl}/process_video'),
      );
      request.files.add(
        await http.MultipartFile.fromPath('file', filePath),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        print('Video berhasil dikirim');
        // Hapus file video sementara jika pengiriman berhasil
        File temporaryFile = File(filePath);
        await temporaryFile.delete();
        startStreaming();
      } else {
        print('Gagal mengirim video: ${response.statusCode}');
      }
    }else{
      setState(() {
        isLoading = true;
      });
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ConfigApp.baseUrl}/process_video'),
      );
      request.files.add(
        await http.MultipartFile.fromPath('file', filePath),
      );
      
      var response = await request.send().then((result) {
        Navigator.pop(context);
      });
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
            child: Stack(children: [
              if(video_path == null) ...{
                RTCVideoView(_localRenderer),
                if(isStreaming == true)...{
                    Container(
                    width: width,
                    padding: EdgeInsets.only(right: 10,top: 20),
                    child: Text('recording',
                      textAlign: TextAlign.end,
                      style: TextStyle( 
                        color: Colors.red.shade500,
                        fontSize: 18
                      ),
                    ),
                  )
                }
              },
              if(video_path != null) ...{
                Container( 
                  width: width,
                  child:  AspectRatio(
                    aspectRatio: videoPlayerController!.value.aspectRatio,
                    child: VideoPlayer(videoPlayerController!),
                  ),
                )
              }
            ]),
          ),
          if(isLoading == false)...{

            Container(
              height: height * 0.25,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if(isStreaming == false)...{
                    FilledButton(
                      style: ButtonStyle( 
                        elevation: WidgetStatePropertyAll(0),
                        backgroundColor: WidgetStatePropertyAll( 
                          Colors.grey.shade400
                        )
                      ),
                      onPressed: startStreaming,
                      child: Icon(
                        Icons.fiber_manual_record_sharp,
                        size: 56,
                        color: Colors.red,
                      ),
                    ),
                  },
                  if(isStreaming == true)...{
                    FilledButton(
                      style: ButtonStyle( 
                        elevation: WidgetStatePropertyAll(0),
                        backgroundColor: WidgetStatePropertyAll( 
                          Colors.grey.shade400
                        )
                      ),
                      onPressed: stopStreaming,
                      child: Icon(
                        Icons.stop,
                        size: 56,
                        color: Colors.red,
                      ),
                    ),
                  },
                  SizedBox(height: height * 0.03,),
                  Column( 
                    children: [ 
                      Text(
                        'atau unggah video',
                        style: TextStyle( 
                          color: Colors.grey.shade500
                        ),
                      ),
                      SizedBox(height: height * 0.01,),
                      if(video_path == null) ...{
                        ElevatedButton.icon(
                            style: ButtonStyle( 
                              elevation: WidgetStatePropertyAll(0),
                              backgroundColor: WidgetStatePropertyAll(
                                ConfigApp.colors['primary']
                              )
                            ),
                            icon: Icon(
                              Icons.phone_iphone_sharp,
                              color: Colors.white,
                            ),
                            onPressed: _pickVideo,
                            label: Text(
                              'Pilih video dari galeri',
                              style: TextStyle( 
                                color: Colors.white
                              ),
                            ),
                        ),
                      },
                      if(video_path != null) ...{
                        ElevatedButton.icon(
                          style: ButtonStyle( 
                              elevation: WidgetStatePropertyAll(0),
                              backgroundColor: WidgetStatePropertyAll(
                                ConfigApp.colors['primary']
                              )
                            ),
                            icon: Icon(
                              Icons.file_upload_outlined,
                              color: Colors.white,
                          ),
                          onPressed: uploadVideo,
                          label: Text(
                            'Upload Video',
                            style: TextStyle( 
                              color: Colors.white
                            ),
                          ),
                        )
                      },
                    ],
                  ),
                ],
              ),
            ),
          },
          if(isLoading == true) ...{
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
