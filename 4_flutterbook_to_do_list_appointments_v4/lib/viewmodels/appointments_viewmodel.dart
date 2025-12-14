import 'package:flutter/material.dart';
import '../models/appointment_model.dart';
import '../services/database_helper.dart';

class AppointmentsViewModel extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Appointment> _appointments = [];
  bool _isLoading = false;

  List<Appointment> get appointments => _appointments;
  bool get isLoading => _isLoading;

  AppointmentsViewModel() {
    loadAppointments();
  }

  Future<void> loadAppointments() async {
    _isLoading = true;
    notifyListeners();

    try {
      _appointments = await _dbHelper.getAllAppointments();
    } catch (e) {
      debugPrint('Error loading appointments: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Appointment>> getAppointmentsByDate(DateTime date) async {
    try {
      return await _dbHelper.getAppointmentsByDate(date);
    } catch (e) {
      debugPrint('Error loading appointments by date: $e');
      return [];
    }
  }

  List<DateTime> getDatesWithAppointments() {
    final dates = <DateTime>[];
    for (var appointment in _appointments) {
      final date = DateTime(
        appointment.date.year,
        appointment.date.month,
        appointment.date.day,
      );
      if (!dates.any(
        (d) =>
            d.year == date.year && d.month == date.month && d.day == date.day,
      )) {
        dates.add(date);
      }
    }
    return dates;
  }

  Future<void> addAppointment(Appointment appointment) async {
    try {
      await _dbHelper.insertAppointment(appointment);
      await loadAppointments();
    } catch (e) {
      debugPrint('Error adding appointment: $e');
    }
  }

  Future<void> updateAppointment(Appointment appointment) async {
    try {
      await _dbHelper.updateAppointment(appointment);
      await loadAppointments();
    } catch (e) {
      debugPrint('Error updating appointment: $e');
    }
  }

  Future<void> deleteAppointment(String id) async {
    try {
      await _dbHelper.deleteAppointment(id);
      await loadAppointments();
    } catch (e) {
      debugPrint('Error deleting appointment: $e');
    }
  }
}
