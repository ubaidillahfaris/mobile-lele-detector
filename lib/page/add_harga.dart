import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:object_detector_lele/bloc/Harga/HargaBloc.dart';
import 'package:object_detector_lele/config.dart';

class AddHargaPage extends StatefulWidget {
  const AddHargaPage({super.key});

  @override
  State<AddHargaPage> createState() => _AddHargaPageState();
}

class _AddHargaPageState extends State<AddHargaPage> {
  late TextEditingController gradeController = TextEditingController();
  late TextEditingController hargaController = TextEditingController();

  HargaBloc hargaBloc = HargaBloc();

  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold( 
      appBar: AppBar( 
        backgroundColor: ConfigApp.colors['primary'],
        title: Text('Isi Harga Lele', style: TextStyle(color: Colors.white),),
      ),
      body: BlocProvider(
        create: (context) => hargaBloc,
        child: BlocListener<HargaBloc, HargaState>(
          listener: (context, state) {
            if (state is SuccessCreateHarga) {
              Navigator.pop(context,true);
            }
          },
          child: Padding(
                  padding: EdgeInsets.all(16),
                  child: BlocBuilder<HargaBloc, HargaState>(
                    builder: (context, state) {
                      
                      return Column( 
                        children: [ 
                          TextField(
                              controller: gradeController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Nama Grade, ex: Grade A',
                              ),
                            ),
                            SizedBox(height: height * 0.03),
                            TextField(
                              controller: hargaController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Harga, ex: 100',
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
                                  hargaBloc.add(CreateHargaEvent(
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
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }
}