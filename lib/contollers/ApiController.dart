import 'dart:convert';

import 'package:alarm_app/api/Urls.dart';
import 'package:alarm_app/models/WeatherModel.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ApiController extends GetxController{

  // Position? position;
  var isFetchingWeather=false.obs;

  setIsFetchingWeather(bool isLoading){
    isFetchingWeather.value=isLoading;
  }


  Future<WeatherModel> getCurrentWeather(double latitude,double longitude) async {

    WeatherModel weatherModel=WeatherModel();

    try {
      String locationUrl=Urls.locationUrl+'&query='+latitude.toString()+","+longitude.toString();

      var response = await http.get(Uri.parse(locationUrl));
      var jsonObject = jsonDecode(response.body);
      weatherModel=WeatherModel.fromJson(jsonObject['location']);


    } catch (_) {

    }

    return weatherModel;


  }

}