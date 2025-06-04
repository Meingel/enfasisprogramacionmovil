import 'package:flutter/material.dart';
import 'configure_cycles_screen.dart';
import 'select_sound_screen.dart';
import 'active_timer_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const String routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Índice activo del BottomNavigationBar
  int _selectedIndex = 0;

  // Lista de rutas correspondientes a cada ícono del BottomNavigationBar
  static const List<String> _navRoutes = <String>[
    HomeScreen.routeName,
    StatisticsScreen.routeName,
  ];

  void _onNavItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    Navigator.pushNamed(context, _navRoutes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Agregamos un AppBar con el título y el ícono de configuración, ambos en color blanco
      appBar: AppBar(
        backgroundColor: const Color(0xFF19332E),
        title: const Text(
          'Flujo de OnFocus',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white), // Íconos en blanco
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(
                context,
                ConfigureCyclesScreen.routeName,
              );
            },
          ),
        ],
      ),

      // Color de fondo: #12211F
      backgroundColor: const Color(0xFF12211F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 24), // Espacio debajo del AppBar

              // Botón principal (color #19E5C2)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF19E5C2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      ActiveTimerScreen.routeName,
                    );
                  },
                  child: const Text(
                    'Iniciar sesión de OnFocus',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF12211F),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Fila de botones secundarios: Estadísticas y Sonidos
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        icon: const Icon(
                          Icons.bar_chart,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Estadísticas',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFF244740),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            StatisticsScreen.routeName,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        icon: const Icon(
                          Icons.volume_up,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Sonidos',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFF244740),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            SelectSoundScreen.routeName,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      // Barra de navegación inferior con fondo #19332E
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF19332E),
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
        selectedItemColor: const Color(0xFF19E5C2),
        unselectedItemColor: Colors.grey.shade400,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.white),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart, color: Colors.white),
            label: 'Estadísticas',
          ),
        ],
      ),
    );
  }
}