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
  
  CameraController? cameraController;
  List<CameraDescription>? cameras;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
        child: DataList(height: height, width: width)
      )
    );
  }
}


class DataList extends StatefulWidget {
  DataList({
    super.key,
    required this.height,
    required this.width,
  });

  final double height;
  final double width;
  @override
  State<DataList> createState() => _DataListState();
}

class _DataListState extends State<DataList> with TickerProviderStateMixin {
  List<LeleModel>? dataYolo;
  List<LeleModel>? dataKnn;
  late TabController tabController;
  LeleBloc leleBloc = LeleBloc();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    leleBloc.add(FetchDataLele());
    leleBloc.add(FetchDataLeleKnn());
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return BlocProvider(
      create: (context) => leleBloc,
      child: BlocListener<LeleBloc, LeleState>(
          listener: (context, state) {
            if (state is SuccessFetchLeleData) {
              dataYolo = state.data;
            }
            if (state is SuccessFetchLeleDataKnn) {
              dataKnn = state.data;
            }
            if (state is SuccessDeleteData) {
              leleBloc.add(FetchDataLele());
            }
          },
          child: BlocBuilder<LeleBloc, LeleState>(
              builder: (context, state) {
    
                return Column(
                  children: [ 
                    Container(
                      height: height * 0.07,
                      child: TabBar(
                        dividerColor: Colors.transparent,
                        controller: tabController,
                        tabs: [
                          Row(
                            children: [ 
                              Icon(Icons.data_saver_off_sharp),
                              Text('Perhitungan Yolo')
                            ],
                          ),
                          Row(
                            children: [ 
                              Icon(Icons.data_saver_off_sharp),
                              Text('Perhitungan Knn')
                            ],
                          ),
                        ]
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: tabController,
                        children: [
                          YoloList(leleBloc: leleBloc, dataYolo: dataYolo, widget: widget),
                          KnnList(leleBloc: leleBloc, dataKnn: dataKnn, widget: widget)
                        ]
                      )
                    )
                  ],
                );
              },
            ),
        ),
    );
  }
}

class KnnList extends StatelessWidget {
  const KnnList({
    super.key,
    required this.leleBloc,
    required this.dataKnn,
    required this.widget,
  });

  final LeleBloc leleBloc;
  final List<LeleModel>? dataKnn;
  final DataList widget;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        leleBloc.add(FetchDataLeleKnn());
      },
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: dataKnn?.length??0,
        itemBuilder: (context, index) {
          if (dataKnn != null) {
            LeleModel item = dataKnn![index];
            DateTime date = DateFormat("EEE, dd MMM yyyy HH:mm").parse(item.created_at);
            String formattedDate = DateFormat("EEE, dd MMM yyyy HH:mm").format(date);
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
                                      video_url_knn: item.video_url_knn,
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
                        ),
                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context, 
                              builder: (context) {
                                return AlertDialog(
                                  content: Text('Apakah ingin menghapus data?', style: Theme.of(context).textTheme.titleLarge,),
                                  actions: [ 
                                    FilledButton(
                                      style: ButtonStyle( 
                                        backgroundColor: WidgetStatePropertyAll(Colors.red.shade600)
                                      ),
                                      onPressed: () {
                                        leleBloc.add(DeleteRiwayat(id: item.id));
                                        Navigator.of(context).pop();
                                        
                                      }, 
                                      child: Text('Hapus data')
                                    ),
                                    FilledButton(
                                      style: ButtonStyle( 
                                        backgroundColor: WidgetStatePropertyAll(Colors.transparent),
                                        side: WidgetStatePropertyAll(BorderSide(
                                            color: Colors.grey,
                                            width: 1.0,
                                            style: BorderStyle.solid
                                            )
                                          )
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      }, 
                                      child: Text('Batal', style: TextStyle(
                                        color: Colors.grey
                                      ),)
                                    )
                                  ],
                                );
                              },
                            );
                          },
                          child: Container( 
                            decoration: BoxDecoration( 
                              color: Colors.red.shade600,
                              borderRadius: BorderRadius.circular(8)
                            ),
                            padding: EdgeInsets.all(8),
                            child: Icon(Icons.delete,color: Colors.white,),
                          ),
                        ),
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
  }
}

class YoloList extends StatelessWidget {
  const YoloList({
    super.key,
    required this.leleBloc,
    required this.dataYolo,
    required this.widget,
  });

  final LeleBloc leleBloc;
  final List<LeleModel>? dataYolo;
  final DataList widget;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        leleBloc.add(FetchDataLele());
      },
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: dataYolo?.length??0,
        itemBuilder: (context, index) {
          if (dataYolo != null) {
            LeleModel item = dataYolo![index];
            DateTime date = DateFormat("EEE, dd MMM yyyy HH:mm").parse(item.created_at);
            String formattedDate = DateFormat("EEE, dd MMM yyyy HH:mm").format(date);
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
                                print(item.video_url);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VideoPlayerWidget(
                                      video_url: item.video_url,
                                      video_url_knn: item.video_url_knn,
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
                        ),
                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context, 
                              builder: (context) {
                                return AlertDialog(
                                  content: Text('Apakah ingin menghapus data?', style: Theme.of(context).textTheme.titleLarge,),
                                  actions: [ 
                                    FilledButton(
                                      style: ButtonStyle( 
                                        backgroundColor: WidgetStatePropertyAll(Colors.red.shade600)
                                      ),
                                      onPressed: () {
                                        leleBloc.add(DeleteRiwayat(id: item.id));
                                        Navigator.of(context).pop();
                                        
                                      }, 
                                      child: Text('Hapus data')
                                    ),
                                    FilledButton(
                                      style: ButtonStyle( 
                                        backgroundColor: WidgetStatePropertyAll(Colors.transparent),
                                        side: WidgetStatePropertyAll(BorderSide(
                                            color: Colors.grey,
                                            width: 1.0,
                                            style: BorderStyle.solid
                                            )
                                          )
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      }, 
                                      child: Text('Batal', style: TextStyle(
                                        color: Colors.grey
                                      ),)
                                    )
                                  ],
                                );
                              },
                            );
                          },
                          child: Container( 
                            decoration: BoxDecoration( 
                              color: Colors.red.shade600,
                              borderRadius: BorderRadius.circular(8)
                            ),
                            padding: EdgeInsets.all(8),
                            child: Icon(Icons.delete,color: Colors.white,),
                          ),
                        ),
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
  }
}