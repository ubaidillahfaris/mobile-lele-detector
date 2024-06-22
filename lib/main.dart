import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:object_detector_lele/bloc/Lele/LeleBloc.dart';
import 'package:object_detector_lele/bloc/camera/CameraBloc.dart';
import 'package:object_detector_lele/config.dart';
import 'package:object_detector_lele/model/Lele.dart';
import 'package:object_detector_lele/page/camera.dart';
import 'package:object_detector_lele/page/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Lele',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeWidget(),
    );
  }
}


class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {

  CameraBloc cameraBloc = CameraBloc();
  CameraController? cameraController;
  List<CameraDescription>? cameras;
  LeleBloc leleBloc = LeleBloc();
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    availableCameraHandler();
    leleBloc.add(FetchDataLele());
  }

  void availableCameraHandler() async {
    cameras = await availableCameras();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    cameraController!.dispose();
  }

  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar( 
        backgroundColor: ConfigApp.colors['primary'],
        title: Text('Penghitung Lele', style: TextStyle(color: Colors.white),),
      ),
      body: BlocProvider(
        create: (context) => leleBloc,
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: height * 0.08,
                  decoration: BoxDecoration( 
                    color: ConfigApp.colors['primary'],
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(50))
                  ),
                ),
                Container(
                  width: width,
                  height: height * 0.18,
                  decoration: BoxDecoration( 
                    color: Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  margin: EdgeInsets.only(top: height * 0.02, left: width * 0.10, right: width * 0.10),
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kirim video lele untuk diproses',
                        style: TextStyle( 
                          fontSize: 16,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                      Center(
                        child: FilledButton.icon(
                          icon: Icon(Icons.camera_alt_outlined),
                          onPressed:() {
                            try {
                              Navigator.push(
                                context, 
                                MaterialPageRoute(
                                  builder: (context) {
                                      return VideoStreamPage();
                                  },
                                )
                              );
                            } catch (e) {
                              print(e);
                            }
                            return;
                            
                          }, 
                          style: ButtonStyle( 
                            backgroundColor: WidgetStatePropertyAll(ConfigApp.colors['secondary'])
                          ),
                          label: Text('Ambil video lele')
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            DataList(height: height, width: width, leleBloc: leleBloc)
          ],
        ),
      )
    );
  }
}

class DataList extends StatefulWidget {
  DataList({
    super.key,
    required this.height,
    required this.width,
    required this.leleBloc,
  });

  final double height;
  final double width;
  final LeleBloc leleBloc;

  @override
  State<DataList> createState() => _DataListState();
}

class _DataListState extends State<DataList> {
  List<LeleModel>? data;

  @override
  Widget build(BuildContext context) {
    return BlocListener<LeleBloc, LeleState>(
      listener: (context, state) {
        if (state is SuccessFetchLeleData) {
          data = state.data;
        }
      },
      child: BlocBuilder<LeleBloc, LeleState>(
          builder: (context, state) {

            return Expanded(
              child: Container(
                margin: EdgeInsets.only(top: widget.height * 0.03),
                padding: EdgeInsets.symmetric(horizontal: widget.width * 0.1),
                width: widget.width,
                child: RefreshIndicator(
                  onRefresh: () async {
                    widget.leleBloc.add(FetchDataLele());
                  },
                  child: ListView.builder(
                    itemCount: data?.length??0,
                    itemBuilder: (context, index) {
                      if (data != null) {
                        LeleModel item = data![index];
                        DateTime date = DateFormat("EEE, dd MMM yyyy").parse(item.tanggal);
                        String formattedDate = DateFormat("EEE, dd MMM yyyy").format(date);
                        return Card(
                          color: Colors.white,
                          child: Container(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => VideoPlayerWidget(
                                                  video_url: item.video_url,
                                                ),
                                              )
                                            );
                                          },
                                          child: Icon(
                                            Icons.play_circle_filled_rounded,
                                            color: ConfigApp.colors['primary'],
                                            size: widget.width * 0.10,
                                          ),
                                        ),
                                        SizedBox(width: widget.width * 0.03,),
                                        Column( 
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [ 
                                            Text(
                                              item.grade,
                                              style: TextStyle( 
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold
                                              ),
                                            ),
                                            Text(
                                              formattedDate,
                                              style: TextStyle( 
                                                color: Colors.grey.shade500
                                              ),
                                              maxLines: 1,
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Center( 
                                      child: Text('${item.jumlah} Lele'),
                                    )
                                  ],
                                ),
                                Divider(),
                                Text(
                                  'Rp. ${item.total_harga}',
                                  style: TextStyle(
                                    color: Colors.grey.shade800,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold
                                  ),
                                )
                              ],
                            )
                          ),
                        );
                      }



                    },
                  ),
                ),
              ),
            );
          },
        ),
    );
  }
}