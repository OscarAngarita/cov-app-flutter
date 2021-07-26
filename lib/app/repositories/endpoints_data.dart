import 'package:coronavirus_rest_api_flutter_course/app/services/api.dart';
import 'package:flutter/foundation.dart';

class EndpointsData {
  EndpointsData({@required this.values});
  final Map<Endpoint, int> values;

  int get cases => values[Endpoint.cases];
  int get casesSuspected => values[Endpoint.casesSuspected];
  int get casesConfirmed => values[Endpoint.casesConfirmed];
  int get deaths => values[Endpoint.deaths];
  int get recovered => values[Endpoint.recovered];

  @override
  String toString() {
    return 'Cases: $cases, '
    'Suspected: $casesSuspected, '
    'Confirmed: $casesConfirmed, '
    'Deaths: $deaths, '
    'Recovered: $recovered';
  }
}