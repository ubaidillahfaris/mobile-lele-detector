import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:object_detector_lele/bloc/Lele/LeleBloc.dart';
import 'package:object_detector_lele/config.dart';
import 'package:object_detector_lele/model/Lele.dart';
import 'package:object_detector_lele/page/video_player.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  LeleBloc leleBloc = LeleBloc();
  CameraController? cameraController;
  List<CameraDescription>? cameras;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    leleBloc.add(FetchDataLele());
  }

  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar( 
        backgroundColor: ConfigApp.colors['primary'],
        title: Text('Riwayat sortir', style: TextStyle(color: Colors.white),),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: DataList(height: height, width: width, leleBloc: leleBloc)
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
    return BlocProvider(
      create: (context) => widget.leleBloc,
      child: BlocListener<LeleBloc, LeleState>(
          listener: (context, state) {
            if (state is SuccessFetchLeleData) {
              data = state.data;
            }
          },
          child: BlocBuilder<LeleBloc, LeleState>(
              builder: (context, state) {
    
                return RefreshIndicator(
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
                        return Container(
                          margin: EdgeInsets.only(bottom: widget.height * 0.02),
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
                );
              },
            ),
        ),
    );
  }
}