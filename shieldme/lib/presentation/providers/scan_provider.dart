import 'package:flutter/material.dart';

class ScanProvider extends ChangeNotifier {
  int _totalScans = 47;
  bool _isScanning = false;
  List<Map<String, dynamic>> _scanHistory = [];

  int get totalScans => _totalScans;
  bool get isScanning => _isScanning;
  List<Map<String, dynamic>> get scanHistory => _scanHistory;

  void incrementScans() {
    _totalScans++;
    notifyListeners();
  }

  void setScanning(bool scanning) {
    _isScanning = scanning;
    notifyListeners();
  }

  void addScanResult(Map<String, dynamic> result) {
    _scanHistory.insert(0, result);
    _totalScans++;
    notifyListeners();
  }

  void clearHistory() {
    _scanHistory.clear();
    _totalScans = 0;
    notifyListeners();
  }
}