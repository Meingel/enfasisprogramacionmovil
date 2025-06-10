import 'dart:convert'; // Importo 'dart:convert' para poder codificar y decodificar datos JSON. Lo necesito para guardar y leer mis timestamps.
import 'package:shared_preferences/shared_preferences.dart'; // Importo `shared_preferences` para almacenar y recuperar datos persistentes en el dispositivo.
import 'package:intl/intl.dart'; // Importo `intl` para formatear fechas y horas según la localización.
import '../utils/constants.dart'; // Importo mis `Constants` personalizados para acceder a las claves de almacenamiento.

class StatsService { // Defino la clase `StatsService`, la cual se encargará de gestionar las estadísticas de los ciclos completados.

  // Este método asíncrono me permite obtener la lista de timestamps (fechas y horas) de los ciclos completados.
  Future<List<DateTime>> _getCompletedCycleTimestamps() async {
    final prefs = await SharedPreferences.getInstance(); // Obtengo una instancia de `SharedPreferences` para interactuar con el almacenamiento.
    final String? timestampsJson = prefs.getString(Constants.completedCyclesTimestampsKey); // Intento obtener la cadena JSON de los timestamps usando mi clave definida en `Constants`.

    if (timestampsJson == null) { // Si no encuentro ningún JSON (es decir, no hay datos guardados aún),
      return []; // Devuelvo una lista vacía de `DateTime`.
    }

    final List<dynamic> rawList = jsonDecode(timestampsJson); // Si hay datos, decodifico la cadena JSON en una lista dinámica.
    return rawList.map((ts) => DateTime.parse(ts)).toList(); // Transformo cada elemento de la lista (que son cadenas de fecha) en objetos `DateTime` y los devuelvo como una lista.
  }

  // Este método asíncrono me permite guardar el timestamp de un ciclo largo completado.
  Future<void> saveCompletedLongCycleTimestamp(DateTime timestamp) async {
    final prefs = await SharedPreferences.getInstance(); // Obtengo la instancia de `SharedPreferences`.
    List<DateTime> currentTimestamps = await _getCompletedCycleTimestamps(); // Recupero la lista actual de timestamps guardados.
    currentTimestamps.add(timestamp); // Añado el nuevo timestamp a mi lista.
    // Ordeno la lista para mantener un historial cronológico; esto es opcional pero me ayuda a depurar y visualizar los datos mejor.
    currentTimestamps.sort((a, b) => a.compareTo(b));
    final List<String> timestampsStrings = currentTimestamps.map((dt) => dt.toIso8601String()).toList(); // Convierto cada `DateTime` a su formato de cadena ISO 8601.
    await prefs.setString(Constants.completedCyclesTimestampsKey, jsonEncode(timestampsStrings)); // Codifico la lista de cadenas a JSON y la guardo en `SharedPreferences`.
  }

  // Este método asíncrono me devuelve un mapa con el conteo de ciclos por día para los últimos 7 días.
  Future<Map<String, int>> getCyclesByDay(DateTime now) async {
    final List<DateTime> timestamps = await _getCompletedCycleTimestamps(); // Obtengo todos los timestamps de los ciclos completados.
    Map<String, int> dailyCounts = {}; // Inicializo un mapa para almacenar el conteo de ciclos por día.

    // Inicializo el conteo de los últimos 7 días a 0 para asegurarme de que todos los días estén presentes en el mapa, incluso si no tienen ciclos.
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i)); // Calculo la fecha para cada uno de los últimos 7 días.
      dailyCounts[DateFormat('EEE', 'es').format(date)] = 0; // Uso el formato de día de la semana abreviado en español ('Lun', 'Mar', etc.) como clave y lo inicializo a 0.
    }

    for (var ts in timestamps) { // Itero sobre cada timestamp de ciclo completado.
      // Filtro para incluir solo los ciclos que ocurrieron en los últimos 7 días completos desde `now`.
      if (ts.isAfter(now.subtract(const Duration(days: 7)).subtract(const Duration(milliseconds: 1)))) { // Verifico si el timestamp es posterior al inicio de hace 7 días.
        final day = DateFormat('EEE', 'es').format(ts); // Obtengo el día de la semana abreviado del timestamp.
        dailyCounts.update(day, (value) => value + 1, ifAbsent: () => 1); // Incremento el contador para ese día; si el día no existe, lo añado con 1.
      }
    }
    return dailyCounts; // Devuelvo el mapa con los conteos diarios.
  }

  // Este método asíncrono me devuelve un mapa con el conteo de ciclos por semana para las últimas 5 semanas.
  Future<Map<String, int>> getCyclesByWeek(DateTime now) async {
    final List<DateTime> timestamps = await _getCompletedCycleTimestamps(); // Obtengo todos los timestamps de los ciclos completados.
    Map<String, int> weeklyCounts = {}; // Inicializo un mapa para almacenar el conteo de ciclos por semana.

    // Inicializo las últimas 5 semanas con 0.
    // Las semanas se representan por su fecha de inicio (ej. 'Mayo 27').
    // Primero, obtengo el inicio de la semana actual (lunes).
    DateTime startOfCurrentWeek = now.subtract(Duration(days: now.weekday - 1)); // Calculo el lunes de la semana actual (asumiendo que `weekday` 1 es lunes).

    for (int i = 4; i >= 0; i--) { // Itero para las últimas 5 semanas, incluyendo la semana parcial actual.
      final startOfWeek = startOfCurrentWeek.subtract(Duration(days: i * 7)); // Calculo la fecha de inicio de cada semana.
      weeklyCounts[DateFormat('MMM d', 'es').format(startOfWeek)] = 0; // Uso el formato de mes y día abreviado en español como clave y lo inicializo a 0.
    }

    for (var ts in timestamps) { // Itero sobre cada timestamp de ciclo completado.
      // Considero los ciclos de las últimas 5 semanas completas desde `now`.
      if (ts.isAfter(now.subtract(const Duration(days: 5 * 7)).subtract(const Duration(milliseconds: 1)))) {
        // Ajusto el timestamp al lunes de la semana en la que cae.
        final startOfWeek = ts.subtract(Duration(days: ts.weekday - 1));
        final weekKey = DateFormat('MMM d', 'es').format(startOfWeek); // Obtengo la clave de la semana.
        weeklyCounts.update(weekKey, (value) => value + 1, ifAbsent: () => 1); // Incremento el contador para esa semana.
      }
    }
    return weeklyCounts; // Devuelvo el mapa con los conteos semanales.
  }

  // Este método asíncrono me devuelve un mapa con el conteo de ciclos por mes para los últimos 12 meses.
  Future<Map<String, int>> getCyclesByMonth(DateTime now) async {
    final List<DateTime> timestamps = await _getCompletedCycleTimestamps(); // Obtengo todos los timestamps de los ciclos completados.
    Map<String, int> monthlyCounts = {}; // Inicializo un mapa para almacenar el conteo de ciclos por mes.

    // Inicializo el conteo de los últimos 12 meses con 0.
    for (int i = 11; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1); // Calculo el primer día de cada uno de los últimos 12 meses.
      monthlyCounts[DateFormat('MMM y', 'es').format(date)] = 0; // Uso el formato de mes y año abreviado en español (ej. 'May 2024') como clave y lo inicializo a 0.
    }

    for (var ts in timestamps) { // Itero sobre cada timestamp de ciclo completado.
      // Considero los ciclos de los últimos 12 meses, incluyendo el mes parcial actual.
      if (ts.isAfter(DateTime(now.year - 1, now.month, 1).subtract(const Duration(milliseconds: 1)))) {
        final month = DateFormat('MMM y', 'es').format(ts); // Obtengo la clave del mes y año.
        monthlyCounts.update(month, (value) => value + 1, ifAbsent: () => 1); // Incremento el contador para ese mes.
      }
    }
    return monthlyCounts; // Devuelvo el mapa con los conteos mensuales.
  }

  // Este método asíncrono me devuelve el número total de ciclos completados.
  Future<int> getTotalCompletedCycles() async {
    final List<DateTime> timestamps = await _getCompletedCycleTimestamps(); // Obtengo todos los timestamps.
    return timestamps.length; // Devuelvo la cantidad de timestamps en la lista, que es el total de ciclos.
  }

  // Este método asíncrono me devuelve el número de ciclos completados en los últimos 7 días.
  Future<int> getCyclesInLast7Days() async {
    final List<DateTime> timestamps = await _getCompletedCycleTimestamps(); // Obtengo todos los timestamps.
    final now = DateTime.now(); // Obtengo la fecha y hora actual.
    // Calculo el inicio de hace 7 días (por ejemplo, si hoy es viernes, será el inicio del viernes anterior).
    final sevenDaysAgoStart = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7));
    return timestamps.where((ts) => ts.isAfter(sevenDaysAgoStart)).length; // Cuento los timestamps que son posteriores a ese punto.
  }

  // Este método asíncrono me devuelve el porcentaje de aumento de ciclos en los últimos 7 días comparado con los 7 días anteriores.
  Future<double> getPercentageIncreaseLast7Days() async {
    final now = DateTime.now(); // Obtengo la fecha y hora actual.
    // Calculo el inicio de hoy.
    final todayStart = DateTime(now.year, now.month, now.day);
    // Calculo el inicio de hace 7 días.
    final sevenDaysAgoStart = todayStart.subtract(const Duration(days: 7));
    // Calculo el inicio de hace 14 días.
    final fourteenDaysAgoStart = todayStart.subtract(const Duration(days: 14));

    final List<DateTime> timestamps = await _getCompletedCycleTimestamps(); // Obtengo todos los timestamps.

    // Cuento los ciclos que ocurrieron en los últimos 7 días (desde hace 7 días hasta el final de hoy).
    final int cyclesLast7Days = timestamps.where((ts) => ts.isAfter(sevenDaysAgoStart) && ts.isBefore(todayStart.add(const Duration(days: 1)))).length;
    // Cuento los ciclos que ocurrieron en los 7 días anteriores a esos (desde hace 14 días hasta el final de hace 7 días).
    final int cyclesPrevious7Days = timestamps.where((ts) => ts.isAfter(fourteenDaysAgoStart) && ts.isBefore(sevenDaysAgoStart.add(const Duration(days: 1)))).length;

    if (cyclesPrevious7Days == 0) { // Si no hubo ciclos en los 7 días anteriores,
      return cyclesLast7Days > 0 ? 100.0 : 0.0; // devuelvo 100% de aumento si hay ciclos ahora, o 0% si tampoco los hay.
    }
    // Si hubo ciclos en los 7 días anteriores, calculo el porcentaje de aumento.
    return ((cyclesLast7Days - cyclesPrevious7Days) / cyclesPrevious7Days) * 100.0;
  }

  // Este método asíncrono me permite limpiar todos los datos de estadísticas guardados (muy útil para pruebas).
  Future<void> clearAllStats() async {
    final prefs = await SharedPreferences.getInstance(); // Obtengo la instancia de `SharedPreferences`.
    await prefs.remove(Constants.completedCyclesTimestampsKey); // Elimino el valor asociado a la clave de los timestamps.
    print('Estadísticas limpiadas.'); // Imprimo un mensaje en la consola para confirmar que las estadísticas han sido limpiadas.
  }
}