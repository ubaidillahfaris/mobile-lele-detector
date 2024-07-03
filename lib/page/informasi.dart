import 'package:flutter/material.dart';
import 'package:object_detector_lele/config.dart';

class InformasiPage extends StatelessWidget {
  const InformasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( 
        backgroundColor: ConfigApp.colors['primary'],
        title: Text('Informasi Aplikasi88l;]', style: TextStyle(color: Colors.white),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(64),
        child: Center( 
          child: Column( 
            mainAxisAlignment: MainAxisAlignment.center,
            children: [ 
              Text('Selamat Datang di Aplikasi Penyortiran Bibit Ikan Lele',textAlign: TextAlign.center,style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold
              ),),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02,),
              Text('Aplikasi ini adalah riset dosen yang dilakukan oleh Dr. Ulla Delfana Rosiani, ST., MT., dengan topik bibit ikan lele. Dan penelitian ini dilakukan oleh mahasiswa yang bernama Daffa Setya Nugraha dengan NIM. 1941720164.',textAlign: TextAlign.center,),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02,),
              Text('Objek yang digunakan dalam penelitian ini adalah bibit ikan lele, dengan ukuran 2 – 3 cm (Grade A), ukuran 4 – 5 cm (Grade B) dan ukuran 6 – 8 cm (Grade C).',textAlign: TextAlign.center,),
            ],
          ),
        ),
      ),
    );
  }
}