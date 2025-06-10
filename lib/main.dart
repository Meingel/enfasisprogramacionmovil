import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Importa este paquete
import 'package:intl/date_symbol_data_local.dart'; // Importa este paquete

// Importamos aquí todas nuestras pantallas
import 'screens/home_screen.dart';
import 'screens/configure_cycles_screen.dart';
import 'screens/select_sound_screen.dart';
import 'screens/active_timer_screen.dart';
import 'screens/cycle_notification_screen.dart';
import 'screens/statistics_screen.dart';

void main() async { // <--- CAMBIO 1: Convertir main a async
  WidgetsFlutterBinding.ensureInitialized(); // <--- CAMBIO 2: Asegurar que Flutter esté inicializado
  await initializeDateFormatting('es', null); // <--- CAMBIO 3: Inicializar datos de localización para 'es'
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

      // Añadir la configuración de localizaciones
      localizationsDelegates: const [ // <--- CAMBIO 4: Delegados de localización
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [ // <--- CAMBIO 5: Idiomas soportados
        Locale('en', ''), // Inglés
        Locale('es', ''), // Español
      ],
      locale: const Locale('es', ''), // <--- CAMBIO 6: Establecer español como idioma predeterminado si no se detecta otro

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