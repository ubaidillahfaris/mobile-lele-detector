import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:object_detector_lele/bloc/Harga/HargaBloc.dart';
import 'package:object_detector_lele/config.dart';
import 'package:object_detector_lele/model/Harga.dart';

class EditHargaPage extends StatefulWidget {
  const EditHargaPage({
    super.key,
    required this.data
  });

  final HargaModel data;

  @override
  State<EditHargaPage> createState() => _EditHargaPageState();
}

class _EditHargaPageState extends State<EditHargaPage> {

  late HargaModel data;
  late TextEditingController gradeController = TextEditingController();
  late TextEditingController hargaController = TextEditingController();

  HargaBloc hargaBloc = HargaBloc();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    data = widget.data;
    gradeController.text = data.grade;
    hargaController.text = data.harga.toInt().toString();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar( 
        backgroundColor: ConfigApp.colors['primary'],
        title: Text('Edit ${data.grade}', style: TextStyle(color: Colors.white),),
      ),
      body: BlocProvider(
        create: (context) => hargaBloc,
        child: BlocListener<HargaBloc, HargaState>(
          listener: (context, state) {
            if (state is SuccessUpdateHarga) {
              Navigator.pop(context, true);
            }
          },
          child: BlocBuilder<HargaBloc, HargaState>(
            builder: (context, state) {
              return Container(
                padding: EdgeInsetsDirectional.all(16),
                child: Column( 
                  children: [ 
                    TextField(
                      controller: gradeController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Nama Grade',
                      ),
                    ),
                    SizedBox(height: height * 0.03),
                    TextField(
                      controller: hargaController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Harga',
                      ),
                    ),
                    SizedBox(height: height * 0.03),

                    if(state is InitHargaState)...{

                      FilledButton.icon(
                        icon: Icon(Icons.check_circle_outline_outlined),
                        style: ButtonStyle( 
                          backgroundColor: WidgetStatePropertyAll(
                            ConfigApp.colors['primary']
                          )
                        ),
                        onPressed: () {
                          hargaBloc.add(UpdateHargaEvent(
                                id: data.id, 
                                grade: gradeController.text, 
                                harga: hargaController.text
                            )
                          );
                        },
                        label: Text('Simpan')
                      )
                    },
                    if(state is OnLoadingProcess)...{
                      Center(
                        child: CircularProgressIndicator(),
                      )
                    }
                  ],
                )
              );
            },
          ),
        ),
      ),
    );
  }
}