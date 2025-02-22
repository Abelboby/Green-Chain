import 'package:flutter/material.dart';
import '../../../core/services/contract_service.dart';
import '../models/report_data.dart';

class ReportsProvider extends ChangeNotifier {
  final ContractService _contractService;
  
  List<ReportData> _reports = [];
  List<ReportData> _userReports = [];
  bool _isLoading = false;
  bool _isLoadingUserReports = false;
  String? _error;

  ReportsProvider(this._contractService) {
    _loadReports();
  }

  List<ReportData> get reports => _reports;
  List<ReportData> get userReports => _userReports;
  bool get isLoading => _isLoading;
  bool get isLoadingUserReports => _isLoadingUserReports;
  String? get error => _error;

  Future<void> _loadReports() async {
    if (_isLoading) return;
    
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _reports = await _contractService.getVisibleReports();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshReports() async {
    await _loadReports();
  }

  Future<void> loadUserReports(String address) async {
    if (_isLoadingUserReports) return;
    
    try {
      _isLoadingUserReports = true;
      _error = null;
      notifyListeners();

      final reports = await _contractService.getReportsByAddress(address);
      
      // Sort reports by timestamp (newest first)
      reports.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      _userReports = reports;
    } catch (e) {
      _error = e.toString();
      _userReports = [];
    } finally {
      _isLoadingUserReports = false;
      notifyListeners();
    }
  }

  Future<void> refreshUserReports(String address) async {
    await loadUserReports(address);
  }

  void clearUserReports() {
    _userReports = [];
    _error = null;
    notifyListeners();
  }
} 