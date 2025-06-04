import 'package:flutter/material.dart';

// Importamos aquí todas nuestras pantallas
import 'screens/home_screen.dart';
import 'screens/configure_cycles_screen.dart';
import 'screens/select_sound_screen.dart';
import 'screens/active_timer_screen.dart';
import 'screens/cycle_notification_screen.dart';
import 'screens/statistics_screen.dart';

void main() {
  runApp(const OnFocusApp());
}

class OnFocusApp extends StatelessWidget {
  const OnFocusApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OnFocus',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      // Definimos la ruta inicial
      initialRoute: HomeScreen.routeName,

      // Mapa de rutas nombradas a cada pantalla
      routes: {
        HomeScreen.routeName: (context) => const HomeScreen(),
        ConfigureCyclesScreen.routeName: (context) => const ConfigureCyclesScreen(),
        SelectSoundScreen.routeName: (context) => const SelectSoundScreen(),
        ActiveTimerScreen.routeName: (context) => const ActiveTimerScreen(),
        CycleNotificationScreen.routeName: (context) => const CycleNotificationScreen(),
        StatisticsScreen.routeName: (context) => const StatisticsScreen(),
      },
    );
  }
}
