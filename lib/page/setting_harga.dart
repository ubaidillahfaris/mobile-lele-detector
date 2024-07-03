import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:object_detector_lele/bloc/Harga/HargaBloc.dart';
import 'package:object_detector_lele/config.dart';
import 'package:object_detector_lele/model/Harga.dart';
import 'package:object_detector_lele/page/add_harga.dart';
import 'package:object_detector_lele/page/edit_harga.dart';

class SettingHargaPage extends StatefulWidget {
  const SettingHargaPage({super.key});

  @override
  State<SettingHargaPage> createState() => _SettingHargaPageState();
}

class _SettingHargaPageState extends State<SettingHargaPage> {

  HargaBloc hargaBloc = HargaBloc();

  List<HargaModel>? listHarga;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    hargaBloc.add(FetchHargaEvent());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    hargaBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;


  
    return Scaffold(
      appBar: AppBar( 
        backgroundColor: ConfigApp.colors['primary'],
        title: Text('Pengaturan Harga Lele', style: TextStyle(color: Colors.white),),
      ),
      body: BlocProvider(
        create: (context) => hargaBloc,
        child: BlocListener<HargaBloc, HargaState>(
          listener: (context, state) {
            if (state is SuccessFetchHarga) {
              listHarga = state.data;
            }
            if (state is SuccessDeleteHarga) {
              hargaBloc.add(FetchHargaEvent());
            }
          },
          child: BlocBuilder<HargaBloc, HargaState>(
            builder: (context, state) {
          
              if (listHarga != null) {
                
                return RefreshIndicator(
                   onRefresh: () async {
                      hargaBloc.add(FetchHargaEvent());
                  },
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Container(
                      width: width,
                      height: height,
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          HargaModel item = listHarga![index];
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context, 
                                MaterialPageRoute(
                                  builder: (context) => EditHargaPage(
                                    data: item,
                                  ),
                                )
                              ).then((result) {
                                if (result == true) {
                                  hargaBloc.add(FetchHargaEvent());
                                }
                              });
                            },
                            onLongPress: () {
                              
                              showModalBottomSheet(
                                useRootNavigator: true,
                                elevation: 2,
                                context: context, 
                                builder: (context) {
                                  return Container(
                                    height: height * 0.20,
                                    child: Center( 
                                      child: Container(
                                        padding: EdgeInsets.all(width * 0.05),
                                        width: width,
                                        child: FilledButton.icon(
                                          style: ButtonStyle( 
                                            backgroundColor: WidgetStatePropertyAll(ConfigApp.colors['secondary'])
                                          ),
                                          icon: Icon(Icons.delete),
                                          onPressed: () {
                                            hargaBloc.add(DeleteHargaEvent(id: item.id));
                                            Navigator.pop(context);
                                          },
                                          label: Text('Hapus')
                                        ),
                                      ),
                                    ),
                                  );  
                                },
                              );
                            },
                            child: Container(
                              width: width,
                              padding: EdgeInsets.symmetric(vertical: height * 0.02),
                              margin: EdgeInsets.only(bottom: height * 0.02),
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
                                            SizedBox(width: width * 0.03,),
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
                                              ],
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'Rp. ${item.harga}',
                                              style: TextStyle(
                                                color: Colors.grey.shade800,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold
                                              ),
                                            ),
                                            SizedBox(width: width * 0.05,),
                                            Container( 
                                                decoration: BoxDecoration( 
                                                  color: Colors.blue,
                                                  borderRadius: BorderRadius.circular(8)
                                                ),
                                                padding: EdgeInsets.all(8),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.edit,color: Colors.white,),
                                                    Text('Edit',style: TextStyle(color: Colors.white),)
                                                  ],
                                                ),
                                            ),
                                            SizedBox(width: width * 0.05,),
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
                                                            hargaBloc.add(DeleteHargaEvent(id: item.id));
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
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                )
                              ),
                            ),
                          );
                        },
                        itemCount: listHarga!.length,
                      ),
                    ),
                  ),
                );
              }
              return Center( 
                child: Text('No data'),
              );
            },
          ),
        ),
      ),
      floatingActionButton:FloatingActionButton(
        backgroundColor: ConfigApp.colors['secondary'],
        child: Icon(Icons.add_circle_outlined, color: Colors.white,),
        onPressed: () {
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => AddHargaPage(),
            )
          ).then((result) {
            if (result == true) {
              hargaBloc.add(FetchHargaEvent());
            }
          });
        },
      ),
    );
  }
}