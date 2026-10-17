import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../models/earthquake_model.dart';
import '../utils/helper_functions.dart';

class AppDataProvider with ChangeNotifier {
  final Uri _baseUrl =
      Uri.parse('https://earthquake.usgs.gov/fdsnws/event/1/query');
  final Map<String, dynamic> _queryParams = {};
  double _maxRadiusKm = 500.0;
  double _latitude = 0.0;
  double _longitude = 0.0;
  String _startTime = '';
  String _endTime = '';
  String _orderBy = 'time'; // predvolené triedenie podľa času
  String? _currentCity;
  final double _maxRadiusThreshold = 20001.6; // max. hodnota podľa dokumentácie
  final double _nearbyRadiusKm = 300.0; // polomer pri zapnutej polohe
  bool _shouldUseLocation = false;
  EarthquakeModel? _earthquakeModel;

  Uri get baseUrl => _baseUrl;
  Map<String, dynamic> get queryParams => _queryParams;
  double get maxRadiusKm => _maxRadiusKm;
  double get latitude => _latitude;
  double get longitude => _longitude;
  String get startTime => _startTime;
  String get endTime => _endTime;
  String get orderBy => _orderBy;
  String? get currentCity => _currentCity;
  double get maxRadiusThreshold => _maxRadiusThreshold;
  bool get shouldUseLocation => _shouldUseLocation;
  EarthquakeModel? get earthquakeModel => _earthquakeModel;

  bool get hasDataLoaded => _earthquakeModel != null;

  void init() {
    final now = DateTime.now();
    final earlier = now.subtract(const Duration(days: 10));
    _startTime = getFormattedDateTime(earlier.millisecondsSinceEpoch);
    _endTime = getFormattedDateTime(now.millisecondsSinceEpoch);
    _maxRadiusKm = _maxRadiusThreshold;
    _setQueryParams();
    getEarthquakeData();
  }

  void _setQueryParams() {
    _queryParams.clear();
    _queryParams['format'] = 'geojson';
    _queryParams['starttime'] = _startTime;
    _queryParams['endtime'] = _endTime;
    _queryParams['minmagnitude'] = '4';
    _queryParams['orderby'] = _orderBy;
    _queryParams['limit'] = '500';
    if (_shouldUseLocation) {
      _queryParams['latitude'] = '$_latitude';
      _queryParams['longitude'] = '$_longitude';
      _queryParams['maxradiuskm'] = '$_maxRadiusKm';
    }
  }

  Future<void> getEarthquakeData() async {
    final uri = Uri.https(_baseUrl.authority, _baseUrl.path, _queryParams.map(
      (key, value) => MapEntry(key, value.toString()),
    ));
    EasyLoading.show(status: 'Loading...');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        _earthquakeModel = EarthquakeModel.fromJson(json);
        EasyLoading.dismiss();
        notifyListeners();
      } else {
        EasyLoading.showError('Error ${response.statusCode}');
      }
    } catch (error) {
      EasyLoading.showError('Network error');
      debugPrint(error.toString());
    }
  }

  Color getAlertColor(String color) {
    return switch (color) {
      'green' => Colors.green,
      'yellow' => Colors.yellow,
      'orange' => Colors.orange,
      _ => Colors.red,
    };
  }

  // Triedenie: time, time-asc, magnitude, magnitude-asc
  void setOrder(String value) {
    _orderBy = value;
    notifyListeners();
    _setQueryParams();
    getEarthquakeData();
  }

  void setStartTime(String date) {
    _startTime = date;
    _setQueryParams();
    notifyListeners();
  }

  void setEndTime(String date) {
    _endTime = date;
    _setQueryParams();
    notifyListeners();
  }

  // Zapne/vypne filtrovanie podľa polohy (300 km). Vráti chybovú správu alebo null.
  Future<String?> setLocation(bool value) async {
    if (!value) {
      _shouldUseLocation = false;
      _currentCity = null;
      _maxRadiusKm = _maxRadiusThreshold;
      _setQueryParams();
      notifyListeners();
      getEarthquakeData();
      return null;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return 'Location service is disabled';
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return 'Location permission denied';
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      _latitude = position.latitude;
      _longitude = position.longitude;
      _maxRadiusKm = _nearbyRadiusKm;
      _shouldUseLocation = true;
      await _setCity();
      _setQueryParams();
      notifyListeners();
      getEarthquakeData();
      return null;
    } catch (error) {
      return 'Could not get location';
    }
  }

  Future<void> _setCity() async {
    try {
      final placemarks = await placemarkFromCoordinates(_latitude, _longitude);
      if (placemarks.isNotEmpty) {
        _currentCity = placemarks.first.locality;
      }
    } catch (_) {
      _currentCity = null;
    }
  }
}
