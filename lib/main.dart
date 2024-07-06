import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:object_detector_lele/Helper/SharedPreferencesHelper.dart';
import 'package:object_detector_lele/bloc/Lele/LeleBloc.dart';
import 'package:object_detector_lele/bloc/camera/CameraBloc.dart';
import 'package:object_detector_lele/config.dart';
import 'package:object_detector_lele/page/camera.dart';
import 'package:object_detector_lele/page/informasi.dart';
import 'package:object_detector_lele/page/riwayat_page.dart';
import 'package:object_detector_lele/page/setting_harga.dart';


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
      home: const FirstPage(),
    );
  }
}


class FirstPage extends StatefulWidget {


  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {

  TextEditingController ipController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center( 
        child: Column( 
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Peternakan Lele', style: Theme.of(context).textTheme.titleLarge,),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02,),

             Image.asset(
              'assets/images/catfish.png',
              width: MediaQuery.of(context).size.width * 0.7,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02,),
            
            Padding(
              padding: EdgeInsets.all(16),
              child: TextField(
                controller: ipController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'alamat ip server',
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02,),
            
            FilledButton(
              onPressed: () async {
                 String newBaseUrl = ipController.text;
                await SharedPreferencesHelper.saveBaseUrl(newBaseUrl);
                  // Update baseUrl in Config
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => HomeWidget(),
                    )
                  );
              },
              child: Text('Start App')
            )
          ],
        ),
      ),
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

    List<Widget> menuList = [
      MenuCard(
        width: width,
        label: 'Penyortiran',
        image_path: 'assets/images/filters.png',
        ontap: () {
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) {
                  return VideoStreamPage();
              },
            )
          );
        },
      ),
      MenuCard(
        width: width,
        label: 'Riwayat',
        image_path: 'assets/images/history.png',
        ontap: () {
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) {
                  return RiwayatPage();
              },
            )
          );
        },
      ),
      MenuCard(
        width: width,
        label: 'Pengaturan',
        image_path: 'assets/images/settings.png',
        ontap: () {
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) {
                  return SettingHargaPage();
              },
            )
          );
        },
      ),
      MenuCard(
        width: width,
        label: 'Informasi',
        image_path: 'assets/images/info.png',
        ontap: () {
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) {
                  return InformasiPage();
              },
            )
          );
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar( 
        backgroundColor: ConfigApp.colors['primary'],
        title: Text('Peternakan Lele', style: TextStyle(color: Colors.white),),
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
                  // height: height * 0.18,
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
                        'Selamat Datang',
                        style: TextStyle( 
                          fontSize: 16,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                      Text(
                        'Peternak Lele',
                        style: TextStyle( 
                          fontSize: 24,
                          fontWeight: FontWeight.w700
                        ),
                      ),
                      Text(
                        'Apa yang akan anda lakukan hari ini?',
                        style: TextStyle( 
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade500
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(width * 0.10),
                  child: Column(
                    children: [
                       Image.asset(
                        'assets/images/catfish.png',
                        width: width * 0.5,
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: width * 0.03,
                          crossAxisSpacing: width * 0.03
                        ), 
                        itemBuilder: (context, index) {
                          return menuList[index];
                        },
                        itemCount: menuList.length,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // DataList(height: height, width: width, leleBloc: leleBloc)
          ],
        ),
      )
    );    
  }
}

class MenuCard extends StatelessWidget {
  const MenuCard({
    super.key,
    required this.width,
    required this.label,
    required this.image_path,
    required this.ontap
  });

  final double width;
  final String image_path;
  final String label;
  final void Function() ontap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ontap,
      child: Container(
            padding: EdgeInsets.all(16),
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
            child: Column( 
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [ 
                Image.asset(
                  image_path,
                  width: width * 0.2,
                ),
                Text(
                  label,
                  style: TextStyle( 
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700
                  ),
                )
              ],
            ),
        ),
    );
  }
}
