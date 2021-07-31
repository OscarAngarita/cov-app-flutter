import 'dart:io';

import 'package:coronavirus_rest_api_flutter_course/app/repositories/data_repository.dart';
import 'package:coronavirus_rest_api_flutter_course/app/repositories/endpoints_data.dart';
import 'package:coronavirus_rest_api_flutter_course/app/services/api.dart';
import 'package:coronavirus_rest_api_flutter_course/app/ui/endpoint_card.dart';
import 'package:coronavirus_rest_api_flutter_course/app/ui/last_updated_status_text.dart';
import 'package:coronavirus_rest_api_flutter_course/app/ui/show_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({ Key key }) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  EndpointsData _endpointsData;

  @override
  initState(){
    super.initState();
    _updateData();
  }

  //Context can always be used inside a State method.
  //Listen: false to avoid register Dashboard as a listener 
  Future<void> _updateData() async {
    try {
      final dataRepository = Provider.of<DataRepository>(context, listen: false);
      final endpointsData = await dataRepository.getAllEndpointData();
      setState(() => _endpointsData = endpointsData);
    } on SocketException catch (_) {
      // print(e);
      //As showAlertDialog is a Future an await ca be added to first dismiss the dialog the procces with any other action
      await showAlertDialog(
        context: context, 
        title: 'Connection Error', 
        content: 'Could not retrieve data. Please try again later',
        defaultActionText: 'OK'
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    final formatter = LastUpdateDateFormatter(
      lastUpdated: _endpointsData!= null 
        ? _endpointsData.values[Endpoint.cases].date 
        : null
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Coronavirus Tracker'),
      ),
      body: RefreshIndicator(
        onRefresh: _updateData,
        child: ListView(
          children: <Widget>[
            LastUpdatedStatusText(
              text: formatter.lastUpdatedStatusString(),
              // text: _endpointsData!= null 
              // // ? as a conditional access operator. Safely access members of objects that are not initialized. return null.
              // ? _endpointsData.values[Endpoint.cases].date?.toString() ?? ''
              // : ''
            ),
            for (var endpoint in Endpoint.values)
            EndpointCard(
              endpoint: endpoint,
              value: _endpointsData!= null 
              ? _endpointsData.values[endpoint].value 
              : null,
            ),
          ],
        ),
      ),
    );
  }
}