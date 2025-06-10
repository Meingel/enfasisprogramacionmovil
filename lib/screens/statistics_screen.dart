// lib/screens/statistics_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Importa fl_chart
import 'package:intl/intl.dart'; // Importa intl para formateo de fechas
import '../services/stats_service.dart'; // Importa tu StatsService

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);
  static const String routeName = '/statistics'; // Agrega la ruta si no la tienes

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final StatsService _statsService = StatsService();

  // Datos para la sección de resumen
  int _totalCompletedCycles = 0;
  double _percentageIncreaseLast7Days = 0.0;

  // Datos para los gráficos
  Map<String, int> _dailyStats = {};
  Map<String, int> _weeklyStats = {};
  Map<String, int> _monthlyStats = {};

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStats();
    // Añade un listener para recargar los datos cuando la pantalla es visible (útil al navegar de vuelta)
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _loadStats(); // Recarga los datos cada vez que cambia de pestaña
      }
    });
    // Agrega un listener al ciclo de vida del widget para recargar cuando la pantalla se enfoca
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadStats();
      }
    });
  }

  // Se podría usar un RouteObserver para detectar cuando la pantalla vuelve al foco
  // Si tu navegación es más compleja (por ejemplo, pushReplacement), puede que quieras
  // recargar los datos cuando la pantalla se "reanuda". Una forma sencilla es:
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Esto recargará los datos cada vez que la pantalla entre en el árbol de widgets
    // o sus dependencias cambien (incluyendo la navegación de vuelta).
    _loadStats();
  }


  Future<void> _loadStats() async {
    if (!mounted) return; // Evitar setState si el widget no está montado
    setState(() {
      _isLoading = true;
    });

    final now = DateTime.now();
    _totalCompletedCycles = await _statsService.getTotalCompletedCycles();
    _percentageIncreaseLast7Days = await _statsService.getPercentageIncreaseLast7Days();
    _dailyStats = await _statsService.getCyclesByDay(now);
    _weeklyStats = await _statsService.getCyclesByWeek(now);
    _monthlyStats = await _statsService.getCyclesByMonth(now);

    if (mounted) { // Asegúrate de que el widget aún esté montado antes de llamar a setState
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12211F), // Color de fondo uniforme
      appBar: AppBar(
        backgroundColor: const Color(0xFF19332E), // Color de la AppBar
        title: const Text('Estadísticas', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white), // Color de los íconos de la AppBar
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF19E5C2), // Color del texto de la pestaña seleccionada
          unselectedLabelColor: Colors.white70, // Color del texto de las pestañas no seleccionadas
          indicatorColor: const Color(0xFF19E5C2), // Color de la línea indicadora
          tabs: const [
            Tab(text: 'Día'),
            Tab(text: 'Semana'),
            Tab(text: 'Mes'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF19E5C2)))
          : RefreshIndicator( // Permite "tirar para recargar"
        onRefresh: _loadStats,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildDailyStatsTab(),
            _buildWeeklyStatsTab(),
            _buildMonthlyStatsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    String increaseText;
    Color increaseColor;

    if (_percentageIncreaseLast7Days >= 0) {
      increaseText = '+${_percentageIncreaseLast7Days.toStringAsFixed(0)}%';
      increaseColor = const Color(0xFF19E5C2); // Verde para aumento o cero
    } else {
      increaseText = '${_percentageIncreaseLast7Days.toStringAsFixed(0)}%';
      increaseColor = Colors.red.shade400; // Rojo para disminución
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ciclos pomodoro',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70),
        ),
        const SizedBox(height: 8),
        Text(
          '$_totalCompletedCycles',
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          'Últimos 7 Días $increaseText',
          style: TextStyle(fontSize: 16, color: increaseColor),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF244740), // Un tono más claro que el fondo pero oscuro
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Resumen',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ciclos completados',
                style: TextStyle(fontSize: 16, color: Colors.white60),
              ),
              Text(
                '$_totalCompletedCycles',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDailyStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummarySection(),
          const Text(
            'Ciclos por Día',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          _buildBarChart(_dailyStats),
        ],
      ),
    );
  }

  Widget _buildWeeklyStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummarySection(),
          const Text(
            'Ciclos por Semana',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          _buildBarChart(_weeklyStats),
        ],
      ),
    );
  }

  Widget _buildMonthlyStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummarySection(),
          const Text(
            'Ciclos por Mes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          _buildBarChart(_monthlyStats),
        ],
      ),
    );
  }

  Widget _buildBarChart(Map<String, int> data) {
    if (data.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'No hay datos disponibles para mostrar.',
            style: TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Convertir el mapa a una lista de BarChartGroupData
    List<BarChartGroupData> barGroups = [];
    List<String> labels = data.keys.toList();
    double maxY = 0;

    // Calcular el valor máximo para el eje Y
    data.values.forEach((value) {
      if (value > maxY) {
        maxY = value.toDouble();
      }
    });
    // Añadir un poco de margen al maxY para que la barra más alta no toque el tope
    maxY = (maxY + 2).toDouble();
    if (maxY == 2) maxY = 5; // Asegura un mínimo de 5 si todos son 0 o 1


    for (int i = 0; i < labels.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: data[labels[i]]!.toDouble(),
              color: const Color(0xFF19E5C2), // Color de las barras
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
          showingTooltipIndicators: [0], // Muestra el valor en la parte superior de la barra
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 1.6, // Relación de aspecto para el gráfico
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: const Color(0xFF244740), // Color de fondo del gráfico
        child: Padding(
          padding: const EdgeInsets.only(top: 16, right: 16, left: 6, bottom: 6),
          child: BarChart(
            BarChartData(
              maxY: maxY, // Establece el valor máximo del eje Y
              barGroups: barGroups,
              gridData: const FlGridData(show: false), // Oculta las líneas de la cuadrícula
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.white10, width: 1), // Borde del gráfico
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          labels[value.toInt()],
                          style: const TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                      );
                    },
                    reservedSize: 30, // Espacio reservado para las etiquetas inferiores
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) return const Text('', style: TextStyle(color: Colors.white70, fontSize: 10)); // No mostrar 0 en el eje
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(color: Colors.white70, fontSize: 10),
                      );
                    },
                    reservedSize: 28, // Espacio reservado para las etiquetas del eje Y
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.blueGrey,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    String label = labels[group.x.toInt()];
                    return BarTooltipItem(
                      '$label\n',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: rod.toY.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}