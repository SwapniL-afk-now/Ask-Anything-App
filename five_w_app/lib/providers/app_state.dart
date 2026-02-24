import 'package:flutter/material.dart';
import '../models/five_w_model.dart';
import '../services/api_interface.dart';

class AppState extends ChangeNotifier {
  final ApiInterface apiService;

  AppState({required this.apiService});

  String _selectedProfession = '';
  String _topic = '';
  bool _isLoading = false;
  AnalyzeResponse? _currentResult;
  String? _errorMessage;

  String get selectedProfession => _selectedProfession;
  String get topic => _topic;
  bool get isLoading => _isLoading;
  AnalyzeResponse? get currentResult => _currentResult;
  String? get errorMessage => _errorMessage;

  void setProfession(String profession) {
    _selectedProfession = profession;
    notifyListeners();
  }

  void setTopic(String topic) {
    _topic = topic;
    notifyListeners();
  }

  void reset() {
    _selectedProfession = '';
    _topic = '';
    _currentResult = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> analyzeCurrentTopic() async {
    if (_selectedProfession.isEmpty || _topic.isEmpty) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentResult = await apiService.analyzeTopic(_selectedProfession, _topic);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
