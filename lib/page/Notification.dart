import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:object_detector_lele/config.dart';
import 'package:object_detector_lele/page/riwayat_page.dart';

class NotificationWidget extends StatefulWidget {
  const NotificationWidget({super.key});

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {

  List<Map<String, dynamic>>? data;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  void fetchData() async {
    setState(() {
      data?.clear();
    });
    try {

      Dio dio = Dio();
      String url = '${await ConfigApp.baseUrl()}/log/show';
      var request = await dio.get(url);
      List<Map<String, dynamic>> response = List<Map<String, dynamic>>.from(
        request.data.map((item) => item as Map<String, dynamic>)
      );
      
      setState(() {
        data = response;
      });

    } catch (e, stackTrace) {
      print(e);
      print(stackTrace);
    }
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

    return Scaffold( 
      appBar: AppBar(
        title: Text('Notifikasi'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          fetchData();
        },
        child: ListView.separated(
          itemBuilder: (context, index) {
        
            Map<String, dynamic>? item = data?[index];
        
            return InkWell(
              onTap: () {
                Navigator.pushReplacement(
                  context, 
                  MaterialPageRoute(builder: (context) => RiwayatPage())
                );
              },
              child: Container(
                width: width,
                height: height * 0.16,
                margin: EdgeInsets.all(width * 0.02),
                padding: EdgeInsetsDirectional.all(30),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(width * 0.02)
                ),
                child: Column( 
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [ 
                    Icon(Icons.notifications_active,color: Colors.blue.shade700,),
                    SizedBox(height: height * 0.02,),
                    Flexible(
                      child: Text(
                        item?['keterangan']??'No data',
                        maxLines: 2,
                      )
                    ),
                  ],
                ),
              ),
            );
          },
          itemCount: data?.length??0,
          separatorBuilder: (context, index) {
            return SizedBox(height: height * 0.02,);
          },
        ),
      ),
    );
  }
}