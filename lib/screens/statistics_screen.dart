import 'package:flutter/material.dart'; // Importamos el paquete fundamental de Flutter para la interfaz de usuario.
import 'package:fl_chart/fl_chart.dart'; // Importamos `fl_chart` para construir gráficos.
import 'package:intl/intl.dart'; // Importamos `intl` para formatear fechas y horas.
import '../services/stats_service.dart'; // Importamos nuestro `StatsService` para obtener datos estadísticos.

class StatisticsScreen extends StatefulWidget { // Definimos la clase `StatisticsScreen`, un widget con estado para mostrar estadísticas.
  const StatisticsScreen({Key? key}) : super(key: key); // Constructor de la clase `StatisticsScreen`.
  static const String routeName = '/statistics'; // Definimos la ruta estática para esta pantalla.

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState(); // Creamos y devolvemos el estado mutable para esta pantalla.
}

class _StatisticsScreenState extends State<StatisticsScreen> with SingleTickerProviderStateMixin { // Definimos el estado asociado a `StatisticsScreen`.
  late TabController _tabController; // Controlador para las pestañas de la interfaz.
  final StatsService _statsService = StatsService(); // Creamos una instancia de nuestro servicio de estadísticas.

  // Variables para los datos de la sección de resumen
  int _totalCompletedCycles = 0; // Almacena el total de ciclos completados.
  double _percentageIncreaseLast7Days = 0.0; // Almacena el porcentaje de aumento en los últimos 7 días.

  // Variables para los datos de los gráficos (mapas de fechas a conteos de ciclos)
  Map<String, int> _dailyStats = {}; // Estadísticas diarias.
  Map<String, int> _weeklyStats = {}; // Estadísticas semanales.
  Map<String, int> _monthlyStats = {}; // Estadísticas mensuales.

  bool _isLoading = true; // Bandera para indicar si los datos están siendo cargados.

  @override
  void initState() { // Se llama una vez cuando el estado se inserta en el árbol de widgets.
    super.initState(); // Llamamos al método `initState` de la superclase.
    _tabController = TabController(length: 3, vsync: this); // Inicializamos el `TabController` con 3 pestañas.
    _loadStats(); // Cargamos las estadísticas iniciales.
    // Añadimos un listener para recargar los datos cuando la pestaña cambia.
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) { // Verificamos que el cambio de índice no sea intermedio.
        _loadStats(); // Recargamos los datos cada vez que cambiamos de pestaña.
      }
    });
    // Agregamos un listener al ciclo de vida del widget para recargar cuando la pantalla se enfoca.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) { // Nos aseguramos de que el widget esté montado antes de actualizar.
        _loadStats(); // Cargamos las estadísticas.
      }
    });
  }

  // Usamos `didChangeDependencies` para recargar datos cuando la pantalla vuelve al foco.
  // Esto es útil si la navegación es compleja y la pantalla se "reanuda".
  @override
  void didChangeDependencies() {
    super.didChangeDependencies(); // Llamamos al método `didChangeDependencies` de la superclase.
    _loadStats(); // Recargamos los datos cada vez que las dependencias del widget cambian (incluida la navegación de vuelta).
  }

  // Método asíncrono para cargar todas las estadísticas.
  Future<void> _loadStats() async {
    if (!mounted) return; // Evitamos llamar a `setState` si el widget no está montado.
    setState(() { // Indicamos que estamos cargando los datos.
      _isLoading = true;
    });

    final now = DateTime.now(); // Obtenemos la fecha y hora actuales.
    _totalCompletedCycles = await _statsService.getTotalCompletedCycles(); // Obtenemos el total de ciclos completados.
    _percentageIncreaseLast7Days = await _statsService.getPercentageIncreaseLast7Days(); // Obtenemos el porcentaje de aumento.
    _dailyStats = await _statsService.getCyclesByDay(now); // Obtenemos ciclos por día.
    _weeklyStats = await _statsService.getCyclesByWeek(now); // Obtenemos ciclos por semana.
    _monthlyStats = await _statsService.getCyclesByMonth(now); // Obtenemos ciclos por mes.

    if (mounted) { // Nos aseguramos de que el widget aún esté montado antes de llamar a `setState`.
      setState(() { // Indicamos que la carga de datos ha finalizado.
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() { // Se llama cuando este objeto de estado se elimina permanentemente del árbol de widgets.
    _tabController.dispose(); // Liberamos los recursos del `TabController`.
    super.dispose(); // Llamamos al método `dispose` de la superclase.
  }

  @override
  Widget build(BuildContext context) { // Construimos la interfaz de usuario de la pantalla de estadísticas.
    return Scaffold( // Proporcionamos la estructura visual básica de la pantalla.
      backgroundColor: const Color(0xFF12211F), // Establecemos el color de fondo uniforme.
      appBar: AppBar( // Definimos la barra superior de la aplicación.
        backgroundColor: const Color(0xFF19332E), // Color de fondo del `AppBar`.
        title: const Text('Estadísticas', style: TextStyle(color: Colors.white)), // Título del `AppBar` en color blanco.
        centerTitle: true, // Centramos el título.
        iconTheme: const IconThemeData(color: Colors.white), // Color de los íconos de la `AppBar`.
        bottom: TabBar( // Pestañas en la parte inferior del `AppBar`.
          controller: _tabController, // Asignamos el `TabController`.
          labelColor: const Color(0xFF19E5C2), // Color del texto de la pestaña seleccionada.
          unselectedLabelColor: Colors.white70, // Color del texto de las pestañas no seleccionadas.
          indicatorColor: const Color(0xFF19E5C2), // Color de la línea indicadora de la pestaña.
          tabs: const [ // Definimos las tres pestañas.
            Tab(text: 'Día'), // Pestaña para estadísticas diarias.
            Tab(text: 'Semana'), // Pestaña para estadísticas semanales.
            Tab(text: 'Mes'), // Pestaña para estadísticas mensuales.
          ],
        ),
      ),
      body: _isLoading // Si estamos cargando, mostramos un indicador de progreso.
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF19E5C2))) // Indicador de carga de color verde cian.
          : RefreshIndicator( // Permite "tirar para recargar" los datos.
        onRefresh: _loadStats, // Función que se llama al tirar para recargar.
        child: TabBarView( // Contenido de las pestañas.
          controller: _tabController, // Asignamos el `TabController`.
          children: [ // Los widgets correspondientes a cada pestaña.
            _buildDailyStatsTab(), // Pestaña de estadísticas diarias.
            _buildWeeklyStatsTab(), // Pestaña de estadísticas semanales.
            _buildMonthlyStatsTab(), // Pestaña de estadísticas mensuales.
          ],
        ),
      ),
    );
  }

  // Widget para construir la sección de resumen de estadísticas.
  Widget _buildSummarySection() {
    String increaseText; // Texto para mostrar el porcentaje de aumento/disminución.
    Color increaseColor; // Color para el texto del porcentaje.

    if (_percentageIncreaseLast7Days >= 0) { // Si el porcentaje es positivo o cero, es un aumento.
      increaseText = '+${_percentageIncreaseLast7Days.toStringAsFixed(0)}%'; // Formateamos con '+' y sin decimales.
      increaseColor = const Color(0xFF19E5C2); // Color verde cian.
    } else { // Si el porcentaje es negativo, es una disminución.
      increaseText = '${_percentageIncreaseLast7Days.toStringAsFixed(0)}%'; // Formateamos sin '+' y sin decimales.
      increaseColor = Colors.red.shade400; // Color rojo.
    }

    return Column( // Columna para organizar los elementos del resumen.
      crossAxisAlignment: CrossAxisAlignment.start, // Alineamos los elementos al inicio.
      children: [
        const Text( // Título de la sección.
          'Ciclos pomodoro',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70), // Estilo del texto.
        ),
        const SizedBox(height: 8), // Espacio vertical.
        Text( // Muestra el total de ciclos completados.
          '$_totalCompletedCycles',
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white), // Estilo del texto.
        ),
        Text( // Muestra el cambio porcentual en los últimos 7 días.
          'Últimos 7 Días $increaseText',
          style: TextStyle(fontSize: 16, color: increaseColor), // Estilo y color dinámico.
        ),
        const SizedBox(height: 20), // Espacio vertical.
        Container( // Contenedor para el resumen detallado.
          padding: const EdgeInsets.all(16), // Relleno interno.
          decoration: BoxDecoration( // Decoración del contenedor.
            color: const Color(0xFF244740), // Color de fondo (un tono más claro).
            borderRadius: BorderRadius.circular(10), // Bordes redondeados.
          ),
          child: Column( // Columna para los elementos del resumen detallado.
            crossAxisAlignment: CrossAxisAlignment.start, // Alineamos al inicio.
            children: [
              const Text( // Título del resumen.
                'Resumen',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70), // Estilo.
              ),
              const SizedBox(height: 8), // Espacio vertical.
              const Text( // Etiqueta de ciclos completados.
                'Ciclos completados',
                style: TextStyle(fontSize: 16, color: Colors.white60), // Estilo.
              ),
              Text( // Muestra el total de ciclos completados.
                '$_totalCompletedCycles',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white), // Estilo.
              ),
            ],
          ),
        ),
        const SizedBox(height: 20), // Espacio vertical.
      ],
    );
  }

  // Widget para construir la pestaña de estadísticas diarias.
  Widget _buildDailyStatsTab() {
    return SingleChildScrollView( // Permite el desplazamiento si el contenido es demasiado grande.
      padding: const EdgeInsets.all(16.0), // Relleno alrededor del contenido.
      child: Column( // Columna para organizar las secciones.
        crossAxisAlignment: CrossAxisAlignment.start, // Alineamos al inicio.
        children: [
          _buildSummarySection(), // Incluimos la sección de resumen.
          const Text( // Título de la sección de gráficos diarios.
            'Ciclos por Día',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70), // Estilo.
          ),
          const SizedBox(height: 16), // Espacio vertical.
          _buildBarChart(_dailyStats), // Construimos el gráfico de barras con datos diarios.
        ],
      ),
    );
  }

  // Widget para construir la pestaña de estadísticas semanales.
  Widget _buildWeeklyStatsTab() {
    return SingleChildScrollView( // Permite el desplazamiento.
      padding: const EdgeInsets.all(16.0), // Relleno.
      child: Column( // Columna para organizar las secciones.
        crossAxisAlignment: CrossAxisAlignment.start, // Alineamos al inicio.
        children: [
          _buildSummarySection(), // Incluimos la sección de resumen.
          const Text( // Título de la sección de gráficos semanales.
            'Ciclos por Semana',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70), // Estilo.
          ),
          const SizedBox(height: 16), // Espacio vertical.
          _buildBarChart(_weeklyStats), // Construimos el gráfico de barras con datos semanales.
        ],
      ),
    );
  }

  // Widget para construir la pestaña de estadísticas mensuales.
  Widget _buildMonthlyStatsTab() {
    return SingleChildScrollView( // Permite el desplazamiento.
      padding: const EdgeInsets.all(16.0), // Relleno.
      child: Column( // Columna para organizar las secciones.
        crossAxisAlignment: CrossAxisAlignment.start, // Alineamos al inicio.
        children: [
          _buildSummarySection(), // Incluimos la sección de resumen.
          const Text( // Título de la sección de gráficos mensuales.
            'Ciclos por Mes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70), // Estilo.
          ),
          const SizedBox(height: 16), // Espacio vertical.
          _buildBarChart(_monthlyStats), // Construimos el gráfico de barras con datos mensuales.
        ],
      ),
    );
  }

  // Widget para construir un gráfico de barras reutilizable.
  Widget _buildBarChart(Map<String, int> data) {
    if (data.isEmpty) { // Si no hay datos, mostramos un mensaje.
      return const Center( // Centramos el mensaje.
        child: Padding( // Relleno alrededor del texto.
          padding: EdgeInsets.all(32.0),
          child: Text(
            'No hay datos disponibles para mostrar.',
            style: TextStyle(color: Colors.white70, fontSize: 16), // Estilo del texto.
            textAlign: TextAlign.center, // Alineación del texto.
          ),
        ),
      );
    }

    // Convertimos el mapa de datos a una lista de `BarChartGroupData` para `fl_chart`.
    List<BarChartGroupData> barGroups = [];
    List<String> labels = data.keys.toList(); // Obtenemos las etiquetas del eje X.
    double maxY = 0; // Inicializamos el valor máximo para el eje Y.

    // Calculamos el valor máximo para el eje Y del gráfico.
    data.values.forEach((value) {
      if (value > maxY) {
        maxY = value.toDouble(); // Actualizamos `maxY` si encontramos un valor más grande.
      }
    });
    // Añadimos un poco de margen al `maxY` para que la barra más alta no toque el tope del gráfico.
    maxY = (maxY + 2).toDouble();
    if (maxY == 2) maxY = 5; // Aseguramos un mínimo de 5 si todos los valores son 0 o 1 para una mejor visualización.


    // Creamos los `BarChartGroupData` para cada punto de datos.
    for (int i = 0; i < labels.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i, // Posición en el eje X.
          barRods: [ // Definimos las barras para este grupo.
            BarChartRodData(
              toY: data[labels[i]]!.toDouble(), // Altura de la barra.
              color: const Color(0xFF19E5C2), // Color de las barras (verde cian).
              width: 16, // Ancho de la barra.
              borderRadius: BorderRadius.circular(4), // Bordes redondeados de la barra.
            ),
          ],
          showingTooltipIndicators: [0], // Indicamos que se muestre el valor en la parte superior de la barra.
        ),
      );
    }

    return AspectRatio( // Aseguramos una relación de aspecto para el gráfico.
      aspectRatio: 1.6, // Relación de aspecto 1.6 (ancho/alto).
      child: Card( // Tarjeta que contiene el gráfico.
        elevation: 0, // Sin sombra.
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Bordes redondeados.
        color: const Color(0xFF244740), // Color de fondo del gráfico.
        child: Padding( // Relleno interno de la tarjeta.
          padding: const EdgeInsets.only(top: 16, right: 16, left: 6, bottom: 6),
          child: BarChart( // El widget de gráfico de barras de `fl_chart`.
            BarChartData( // Datos y configuración del gráfico de barras.
              maxY: maxY, // Establecemos el valor máximo del eje Y.
              barGroups: barGroups, // Asignamos los grupos de barras.
              gridData: const FlGridData(show: false), // Ocultamos las líneas de la cuadrícula.
              borderData: FlBorderData( // Datos del borde del gráfico.
                show: true, // Mostrar borde.
                border: Border.all(color: Colors.white10, width: 1), // Borde blanco tenue.
              ),
              titlesData: FlTitlesData( // Configuración de los títulos de los ejes.
                show: true, // Mostrar títulos.
                bottomTitles: AxisTitles( // Títulos del eje inferior (X).
                  sideTitles: SideTitles(
                    showTitles: true, // Mostrar títulos.
                    getTitlesWidget: (value, meta) { // Constructor de widgets para las etiquetas.
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          labels[value.toInt()], // La etiqueta de la barra actual.
                          style: const TextStyle(color: Colors.white70, fontSize: 10), // Estilo del texto.
                        ),
                      );
                    },
                    reservedSize: 30, // Espacio reservado para las etiquetas inferiores.
                  ),
                ),
                leftTitles: AxisTitles( // Títulos del eje izquierdo (Y).
                  sideTitles: SideTitles(
                    showTitles: true, // Mostrar títulos.
                    getTitlesWidget: (value, meta) { // Constructor de widgets para las etiquetas.
                      if (value == 0) return const Text('', style: TextStyle(color: Colors.white70, fontSize: 10)); // No mostramos '0' en el eje Y.
                      return Text(
                        value.toInt().toString(), // El valor de la etiqueta como entero.
                        style: const TextStyle(color: Colors.white70, fontSize: 10), // Estilo del texto.
                      );
                    },
                    reservedSize: 28, // Espacio reservado para las etiquetas del eje Y.
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), // No mostramos títulos en el eje superior.
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), // No mostramos títulos en el eje derecho.
              ),
              barTouchData: BarTouchData( // Configuración de la interacción al tocar las barras.
                touchTooltipData: BarTouchTooltipData( // Datos del tooltip al tocar.
                  tooltipBgColor: Colors.blueGrey, // Color de fondo del tooltip.
                  getTooltipItem: (group, groupIndex, rod, rodIndex) { // Constructor del contenido del tooltip.
                    String label = labels[group.x.toInt()]; // Obtenemos la etiqueta de la barra.
                    return BarTooltipItem( // Contenido del tooltip.
                      '$label\n', // Muestra la etiqueta y un salto de línea.
                      const TextStyle( // Estilo del texto principal del tooltip.
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      children: <TextSpan>[ // Otros elementos de texto en el tooltip.
                        TextSpan(
                          text: rod.toY.toInt().toString(), // Muestra el valor de la barra.
                          style: const TextStyle( // Estilo del valor.
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