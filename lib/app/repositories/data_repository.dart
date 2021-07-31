import 'package:coronavirus_rest_api_flutter_course/app/repositories/endpoints_data.dart';
import 'package:coronavirus_rest_api_flutter_course/app/services/api_service.dart';
import 'package:coronavirus_rest_api_flutter_course/app/services/api.dart';
import 'package:coronavirus_rest_api_flutter_course/app/services/data_cache_service.dart';
import 'package:coronavirus_rest_api_flutter_course/app/services/endpoint_data.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

class DataRepository {
  DataRepository({@required this.apiService, @required this.dataCacheService});
  final APIService apiService;
  final DataCacheService dataCacheService;

  String _accessToken;

  //Method for calling an specific endpoint
  Future<EndpointData> getEndpointData(Endpoint endpoint) async => 
    await _getDataRefreshingToken<EndpointData>(
      onGetData: () => apiService.getEndpointData(
        accessToken: _accessToken, 
        endpoint: endpoint)
    );

  EndpointsData getAllEndpointsCachedData() => dataCacheService.getData();

  //Method for calling all endpoints
  Future<EndpointsData> getAllEndpointData() async {
    final endpointsData = await _getDataRefreshingToken<EndpointsData>(
      // onGetData: () => _getAllEndpointsData(), The same as below as the two functions have the same signature. Short hand syntax used.
      onGetData: _getAllEndpointsData,
    );
    // Save to cache
    await dataCacheService.setData(endpointsData);
    return endpointsData;
  }

  //Method for validating the token in every endpoint request
  Future<T> _getDataRefreshingToken<T>({Future<T> Function() onGetData}) async {
    // Throw error to test Alert dialog message
    // throw 'error';
    try {
      if (_accessToken == null) {
        _accessToken = await apiService.getAccessToken();
      }
      return await onGetData();

    } on Response catch (response) {
      //If unathorized, get token again
      if (response.statusCode == 401) {
        _accessToken = await apiService.getAccessToken();
        return await onGetData();
      } 
      rethrow;
    }
  }

  //Method with all the needed endpoint request
  Future<EndpointsData> _getAllEndpointsData() async {
    //Future.wait to make parallel requests instead of sequential requests
    final values = await Future.wait([
      apiService.getEndpointData(
        accessToken: _accessToken, endpoint: Endpoint.cases),
      apiService.getEndpointData(
        accessToken: _accessToken, endpoint: Endpoint.casesSuspected),
      apiService.getEndpointData(
        accessToken: _accessToken, endpoint: Endpoint.casesConfirmed),
      apiService.getEndpointData(
        accessToken: _accessToken, endpoint: Endpoint.deaths),
      apiService.getEndpointData(
        accessToken: _accessToken, endpoint: Endpoint.recovered),
    ]);

    //Return EndpointsData object
    return EndpointsData(
      values: {
        Endpoint.cases: values[0],
        Endpoint.casesSuspected: values[1],
        Endpoint.casesConfirmed: values[2],
        Endpoint.deaths: values[3],
        Endpoint.recovered: values[4],
      }
    );

  }
}