import 'package:flutter/material.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  static const String routeName = '/statistics';

  @override
  Widget build(BuildContext context) {
    // Datos de ejemplo para la pestaña “Semana”:
    final List<int> weeklyData = [5, 6, 4, 7, 8, 3, 9]; // valores ficticios Lun–Dom
    final int totalWeeklyCycles = weeklyData.fold(0, (sum, item) => sum + item);
    final int previousWeekTotal = 10; // ejemplo de la semana anterior
    final double percentageChange = previousWeekTotal > 0
        ? ((totalWeeklyCycles - previousWeekTotal) / previousWeekTotal) * 100
        : 0;

    return DefaultTabController(
      length: 3, // Día, Semana, Mes
      child: Scaffold(
        backgroundColor: const Color(0xFF12211F),
        appBar: AppBar(
          backgroundColor: const Color(0xFF19332E),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Estadísticas',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF244740),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  indicator: BoxDecoration(
                    color: const Color(0xFF19332E),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  tabs: const [
                    Tab(text: 'Día'),
                    Tab(text: 'Semana'),
                    Tab(text: 'Mes'),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            // Pestaña “Día” (por ahora repetimos datos de “Semana” como placeholder)
            _buildStatisticsTab(
              context: context,
              labelList: const ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'],
              dataList: weeklyData,
              title: 'Ciclos pomodoro',
              totalCycles: totalWeeklyCycles,
              subtitle: 'Últimos 7 Días',
              percentage: percentageChange,
            ),
            // Pestaña “Semana”
            _buildStatisticsTab(
              context: context,
              labelList: const ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'],
              dataList: weeklyData,
              title: 'Ciclos pomodoro',
              totalCycles: totalWeeklyCycles,
              subtitle: 'Últimos 7 Días',
              percentage: percentageChange,
            ),
            // Pestaña “Mes” (datos de ejemplo: 12 meses)
            _buildStatisticsTab(
              context: context,
              labelList: const [
                'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
                'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
              ],
              dataList: [12, 15, 10, 18, 20, 5, 9, 14, 11, 19, 13, 22],
              title: 'Ciclos pomodoro',
              totalCycles: 168, // ejemplo de total mensual
              subtitle: 'Últimos 12 Meses',
              percentage: 5.0, // ejemplo
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsTab({
    required BuildContext context,
    required List<String> labelList,
    required List<int> dataList,
    required String title,
    required int totalCycles,
    required String subtitle,
    required double percentage,
  }) {
    // Calculo el valor máximo para escalar barras
    final int maxValue = dataList.isNotEmpty ? dataList.reduce((a, b) => a > b ? a : b) : 1;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título “Ciclos pomodoro” y total grande
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              totalCycles.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Subtítulo con porcentaje
            Row(
              children: [
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  (percentage >= 0 ? '+${percentage.toStringAsFixed(0)}%' : '${percentage.toStringAsFixed(0)}%'),
                  style: TextStyle(
                    color: percentage >= 0 ? Colors.greenAccent : Colors.redAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Gráfica de barras
            SizedBox(
              height: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(labelList.length, (index) {
                  final double heightFactor = maxValue > 0
                      ? (dataList[index] / maxValue)
                      : 0.0;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: FractionallySizedBox(
                              alignment: Alignment.bottomCenter,
                              heightFactor: heightFactor,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF244740),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            labelList[index],
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),
            // Resumen en tarjeta
            const Text(
              'Resumen',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF244740),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ciclos completados',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    totalCycles.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}