import 'package:flutter/material.dart';
import '../models/bus_api_models.dart';
import '../services/bus_api_service.dart';

/// Bus Controller managing live API states for Cities, Routes, Schedules & Details
class BusController extends ChangeNotifier {
  List<String> _cities = ['Delhi', 'Jaipur', 'Lucknow'];
  List<BusRouteModel> _routes = [];
  List<BusScheduleModel> _schedules = [];
  BusDetailsModel? _selectedBusDetails;

  String _fromCity = 'Delhi';
  String _toCity = 'Lucknow';
  DateTime _journeyDate = DateTime.now();

  bool _isLoadingCities = false;
  bool _isLoadingRoutes = false;
  bool _isLoadingSchedules = false;
  bool _isLoadingDetails = false;
  String? _errorMessage;

  String _selectedFilter = 'All'; // 'All', 'AC', 'Sleeper', 'Seater', 'Electric / Club'

  List<String> get cities => _cities;
  List<BusRouteModel> get routes => _routes;
  List<BusScheduleModel> get schedules => _schedules;
  BusDetailsModel? get selectedBusDetails => _selectedBusDetails;

  String get fromCity => _fromCity;
  String get toCity => _toCity;
  DateTime get journeyDate => _journeyDate;

  bool get isLoadingCities => _isLoadingCities;
  bool get isLoadingRoutes => _isLoadingRoutes;
  bool get isLoadingSchedules => _isLoadingSchedules;
  bool get isLoadingDetails => _isLoadingDetails;
  String? get errorMessage => _errorMessage;
  String get selectedFilter => _selectedFilter;

  List<BusScheduleModel> get filteredSchedules {
    if (_selectedFilter == 'All') return _schedules;
    if (_selectedFilter == 'AC') {
      return _schedules.where((s) => s.bus.isAc).toList();
    }
    if (_selectedFilter == 'Sleeper') {
      return _schedules.where((s) => s.bus.seatingType.toLowerCase().contains('sleeper')).toList();
    }
    if (_selectedFilter == 'Seater') {
      return _schedules.where((s) => s.bus.seatingType.toLowerCase().contains('seater')).toList();
    }
    if (_selectedFilter == 'Single Deck') {
      return _schedules.where((s) => s.bus.deckType.toLowerCase() == 'single').toList();
    }
    if (_selectedFilter == 'Double Deck') {
      return _schedules.where((s) => s.bus.deckType.toLowerCase() == 'double').toList();
    }
    return _schedules;
  }

  /// Loads initial cities and routes from the live API
  Future<void> loadInitialData() async {
    _isLoadingCities = true;
    _isLoadingRoutes = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        BusApiService.instance.getCities(),
        BusApiService.instance.getRoutes(),
      ]);

      _cities = results[0] as List<String>;
      _routes = results[1] as List<BusRouteModel>;

      if (_cities.isNotEmpty) {
        if (!_cities.contains(_fromCity)) _fromCity = _cities.first;
        if (!_cities.contains(_toCity) && _cities.length > 1) {
          _toCity = _cities[1];
        }
      }
    } catch (e) {
      _errorMessage = 'Could not load routes/cities: $e';
    } finally {
      _isLoadingCities = false;
      _isLoadingRoutes = false;
      notifyListeners();
    }
  }

  void setFromCity(String city) {
    _fromCity = city;
    notifyListeners();
  }

  void setToCity(String city) {
    _toCity = city;
    notifyListeners();
  }

  void setJourneyDate(DateTime date) {
    _journeyDate = date;
    notifyListeners();
  }

  void swapCities() {
    final temp = _fromCity;
    _fromCity = _toCity;
    _toCity = temp;
    notifyListeners();
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  /// Searches for live bus schedules matching source and destination
  Future<void> searchSchedules({String? from, String? to, String? dateStr}) async {
    _isLoadingSchedules = true;
    _errorMessage = null;
    notifyListeners();

    final source = from ?? _fromCity;
    final dest = to ?? _toCity;

    try {
      final results = await BusApiService.instance.searchBuses(
        sourceCity: source,
        destinationCity: dest,
        date: dateStr,
      );
      _schedules = results;
    } catch (e) {
      _errorMessage = 'Failed to search buses: $e';
    } finally {
      _isLoadingSchedules = false;
      notifyListeners();
    }
  }

  /// Loads details for a specific bus
  Future<void> loadBusDetails(int busId) async {
    _isLoadingDetails = true;
    notifyListeners();

    try {
      _selectedBusDetails = await BusApiService.instance.getBusDetails(busId);
    } catch (_) {
      _selectedBusDetails = null;
    } finally {
      _isLoadingDetails = false;
      notifyListeners();
    }
  }
}
