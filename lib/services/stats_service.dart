// lib/services/stats_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../utils/constants.dart'; // Importa tus constantes

class StatsService {
  Future<List<DateTime>> _getCompletedCycleTimestamps() async {
    final prefs = await SharedPreferences.getInstance();
    final String? timestampsJson = prefs.getString(Constants.completedCyclesTimestampsKey);

    if (timestampsJson == null) {
      return [];
    }

    final List<dynamic> rawList = jsonDecode(timestampsJson);
    return rawList.map((ts) => DateTime.parse(ts)).toList();
  }

  Future<void> saveCompletedLongCycleTimestamp(DateTime timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    List<DateTime> currentTimestamps = await _getCompletedCycleTimestamps();
    currentTimestamps.add(timestamp);
    // Ordenar para mantener un historial cronológico (opcional, pero útil para depuración)
    currentTimestamps.sort((a, b) => a.compareTo(b));
    final List<String> timestampsStrings = currentTimestamps.map((dt) => dt.toIso8601String()).toList();
    await prefs.setString(Constants.completedCyclesTimestampsKey, jsonEncode(timestampsStrings));
  }

  Future<Map<String, int>> getCyclesByDay(DateTime now) async {
    final List<DateTime> timestamps = await _getCompletedCycleTimestamps();
    Map<String, int> dailyCounts = {};

    // Inicializar los últimos 7 días con 0
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      dailyCounts[DateFormat('EEE', 'es').format(date)] = 0; // 'Lun', 'Mar', etc.
    }

    for (var ts in timestamps) {
      // Filtrar para incluir solo los ciclos de los últimos 7 días completos
      if (ts.isAfter(now.subtract(const Duration(days: 7)).subtract(const Duration(milliseconds: 1)))) { // Considera hasta el inicio de hoy hace 7 días
        final day = DateFormat('EEE', 'es').format(ts);
        dailyCounts.update(day, (value) => value + 1, ifAbsent: () => 1);
      }
    }
    return dailyCounts;
  }

  Future<Map<String, int>> getCyclesByWeek(DateTime now) async {
    final List<DateTime> timestamps = await _getCompletedCycleTimestamps();
    Map<String, int> weeklyCounts = {};

    // Initialize last 5 weeks with 0.
    // Weeks are represented by their start date (e.g., 'May 27')
    // Get the start of the current week (Monday)
    DateTime startOfCurrentWeek = now.subtract(Duration(days: now.weekday - 1)); // -1 for Monday, assuming weekday starts with 1=Monday

    for (int i = 4; i >= 0; i--) { // Last 5 weeks including current partial week
      final startOfWeek = startOfCurrentWeek.subtract(Duration(days: i * 7));
      weeklyCounts[DateFormat('MMM d', 'es').format(startOfWeek)] = 0;
    }

    for (var ts in timestamps) {
      // Consider cycles from the last 5 full weeks from now
      if (ts.isAfter(now.subtract(const Duration(days: 5 * 7)).subtract(const Duration(milliseconds: 1)))) {
        // Adjust to Monday of the week the timestamp falls in
        final startOfWeek = ts.subtract(Duration(days: ts.weekday - 1));
        final weekKey = DateFormat('MMM d', 'es').format(startOfWeek);
        weeklyCounts.update(weekKey, (value) => value + 1, ifAbsent: () => 1);
      }
    }
    return weeklyCounts;
  }

  Future<Map<String, int>> getCyclesByMonth(DateTime now) async {
    final List<DateTime> timestamps = await _getCompletedCycleTimestamps();
    Map<String, int> monthlyCounts = {};

    // Inicializar los últimos 12 meses con 0
    for (int i = 11; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      monthlyCounts[DateFormat('MMM yyyy', 'es').format(date)] = 0; // E.g., 'May 2024'
    }

    for (var ts in timestamps) {
      // Cycles from the last 12 months including current partial month
      if (ts.isAfter(DateTime(now.year - 1, now.month, 1).subtract(const Duration(milliseconds: 1)))) {
        final month = DateFormat('MMM yyyy', 'es').format(ts);
        monthlyCounts.update(month, (value) => value + 1, ifAbsent: () => 1);
      }
    }
    return monthlyCounts;
  }

  Future<int> getTotalCompletedCycles() async {
    final List<DateTime> timestamps = await _getCompletedCycleTimestamps();
    return timestamps.length;
  }

  Future<int> getCyclesInLast7Days() async {
    final List<DateTime> timestamps = await _getCompletedCycleTimestamps();
    final now = DateTime.now();
    // Start of 7 days ago (e.g., if today is Fri, this is the start of previous Fri)
    final sevenDaysAgoStart = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7));
    return timestamps.where((ts) => ts.isAfter(sevenDaysAgoStart)).length;
  }

  Future<double> getPercentageIncreaseLast7Days() async {
    final now = DateTime.now();
    // Start of today
    final todayStart = DateTime(now.year, now.month, now.day);
    // Start of 7 days ago
    final sevenDaysAgoStart = todayStart.subtract(const Duration(days: 7));
    // Start of 14 days ago
    final fourteenDaysAgoStart = todayStart.subtract(const Duration(days: 14));

    final List<DateTime> timestamps = await _getCompletedCycleTimestamps();

    final int cyclesLast7Days = timestamps.where((ts) => ts.isAfter(sevenDaysAgoStart) && ts.isBefore(todayStart.add(const Duration(days: 1)))).length;
    final int cyclesPrevious7Days = timestamps.where((ts) => ts.isAfter(fourteenDaysAgoStart) && ts.isBefore(sevenDaysAgoStart.add(const Duration(days: 1)))).length;

    if (cyclesPrevious7Days == 0) {
      return cyclesLast7Days > 0 ? 100.0 : 0.0; // If no cycles before, and some now, it's 100% increase (or 0 if none)
    }
    return ((cyclesLast7Days - cyclesPrevious7Days) / cyclesPrevious7Days) * 100.0;
  }

  // Método para limpiar todos los datos (útil para pruebas)
  Future<void> clearAllStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(Constants.completedCyclesTimestampsKey);
    print('Estadísticas limpiadas.');
  }
}