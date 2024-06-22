import 'package:flutter/material.dart';
import 'package:object_detector_lele/config.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String video_url;
  const VideoPlayerWidget({
    Key? key,
    required this.video_url
  }) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController controller;
  late bool videoStatus;
  late bool canLoadVideo;
  @override
  void initState() {
    super.initState();
    
   try {
     controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.video_url)
    );
  
    controller.addListener(() {
      setState(() {});
    });
      controller.setLooping(false);
      controller.initialize().then((_) => setState(() {}));
      controller.play();
      videoStatus = true;
      canLoadVideo = true;
   } catch (e) {
      canLoadVideo = false;
     print('ERROR');
   }
   print(canLoadVideo);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(),
      body:Column(
        children: [
          if(canLoadVideo == true)...{

            Stack(
              children: [ 
                Container(
                  width: width,
                  height: height * 0.5,
                  child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: VideoPlayer(controller),
                  ),
                ),
                if(videoStatus == false) ...{
                  Container(
                    width: width,
                    height: height * 0.5,
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: Text(
                        'Paused',
                        style: TextStyle( 
                          color: Colors.white,
                          fontSize: 24
                        ),
                      ),
                    ),
                  )
                }
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: height * 0.03),
              child: Row( 
                mainAxisAlignment: MainAxisAlignment.center,
                children: [ 

                  if(videoStatus == false)...{

                    InkWell(
                      onTap:  (){
                        controller.play();
                        setState(() {
                          videoStatus = true;
                        });
                      }, 
                      child: Container( 
                        child: Icon(
                          Icons.play_circle_fill,
                          color: Colors.black,
                          size: 56,
                        ),
                      ),
                    ),
                  },
                  if(videoStatus == true)...{

                    InkWell(
                      onTap:  (){
                        controller.pause();
                        setState(() {
                          videoStatus = false;
                        });
                      }, 
                      child: Container( 
                        child: Icon(
                          Icons.pause,
                          color: Colors.grey.shade500,
                          size: 56,
                        ),
                      ),
                    ),
                  }

                ],
              ),
            )
          },
          if(canLoadVideo == false)...{
            Center(
              child: Text('Video Error'),
            )
          }
        ],
      ) 
      // Center(
      //   child: InkWell(
      //     onTap: () {
      //       if (controller.value.isPlaying) {
      //         controller.pause();
      //       } else {
      //         controller.play();
      //       }
      //     },
      //     child: AspectRatio(
      //       aspectRatio: controller.value.aspectRatio,
      //       child: VideoPlayer(controller),
      //     ),
      //   ),
      // ),
    );
  }
}
