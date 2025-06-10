import 'package:flutter/material.dart'; // Importo el paquete fundamental de Flutter para construir interfaces de usuario.
import 'package:flutter_localizations/flutter_localizations.dart'; // Estoy importando este paquete para habilitar las funcionalidades de localización en mi aplicación.
import 'package:intl/date_symbol_data_local.dart'; // Importo este paquete para cargar los datos de símbolos de fecha y hora para diferentes localizaciones.

// Importo aquí todas las pantallas que voy a usar en mi aplicación.
import 'screens/home_screen.dart'; // Importo la pantalla de inicio.
import 'screens/configure_cycles_screen.dart'; // Importo la pantalla para configurar los ciclos.
import 'screens/select_sound_screen.dart'; // Importo la pantalla para seleccionar sonidos.
import 'screens/active_timer_screen.dart'; // Importo la pantalla del temporizador activo.
import 'screens/cycle_notification_screen.dart'; // Importo la pantalla de notificación de ciclo.
import 'screens/statistics_screen.dart'; // Importo la pantalla de estadísticas.

void main() async { // Defino la función principal de mi aplicación, `main`, y la hago asíncrona porque voy a realizar operaciones que requieren esperar.
  WidgetsFlutterBinding.ensureInitialized(); // Aquí me aseguro de que los servicios de Flutter estén inicializados antes de ejecutar cualquier otra cosa.
  await initializeDateFormatting('es', null); // Estoy inicializando los datos de formato de fecha y hora para el idioma español ('es'). Esto me permite mostrar fechas y horas correctamente localizadas.
  runApp(const OnFocusApp()); // Inicio mi aplicación Flutter, ejecutando el widget raíz `OnFocusApp`.
}

class OnFocusApp extends StatelessWidget { // Defino mi widget principal `OnFocusApp`, que es un `StatelessWidget` porque su estado no cambia.
  const OnFocusApp({Key? key}) : super(key: key); // Este es el constructor de mi widget, que recibe una clave opcional.

  @override
  Widget build(BuildContext context) { // Sobrescribo el método `build` para describir la parte de la interfaz de usuario que este widget representa.
    return MaterialApp( // Estoy regresando un `MaterialApp`, que es el widget raíz de una aplicación Flutter que usa Material Design.
      title: 'OnFocus', // Le doy un título a mi aplicación, que se usa en el administrador de tareas del dispositivo.
      theme: ThemeData( // Defino el tema visual de mi aplicación.
        primarySwatch: Colors.teal, // Establezco el color principal de la aplicación a un tono de azul verdoso (teal).
      ),
      // Defino la ruta inicial de la aplicación.
      initialRoute: HomeScreen.routeName, // Cuando la aplicación inicia, la primera pantalla que se mostrará será la `HomeScreen`.

      // Añado la configuración de localizaciones para la aplicación.
      localizationsDelegates: const [ // Proporciono una lista de delegados para cargar los recursos localizados para Material Design, Widgets y Cupertino.
        GlobalMaterialLocalizations.delegate, // Este delegado es para los textos y direcciones de Material Design.
        GlobalWidgetsLocalizations.delegate, // Este delegado es para los widgets básicos de Flutter.
        GlobalCupertinoLocalizations.delegate, // Este delegado es para los widgets de estilo iOS (Cupertino).
      ],
      supportedLocales: const [ // Especifico los idiomas que mi aplicación soporta.
        Locale('en', ''), // La aplicación soporta el inglés.
        Locale('es', ''), // Y también soporta el español.
      ],
      locale: const Locale('es', ''), // Estoy estableciendo el español como el idioma predeterminado de la aplicación si el sistema no detecta otra preferencia.

      // Defino un mapa de rutas nombradas a cada una de las pantallas. Esto me permite navegar entre ellas usando sus nombres.
      routes: {
        HomeScreen.routeName: (context) => const HomeScreen(), // La ruta para la pantalla de inicio.
        ConfigureCyclesScreen.routeName: (context) => const ConfigureCyclesScreen(), // La ruta para la pantalla de configuración de ciclos.
        SelectSoundScreen.routeName: (context) => const SelectSoundScreen(), // La ruta para la pantalla de selección de sonido.
        ActiveTimerScreen.routeName: (context) => const ActiveTimerScreen(), // La ruta para la pantalla del temporizador activo.
        CycleNotificationScreen.routeName: (context) => const CycleNotificationScreen(), // La ruta para la pantalla de notificación de ciclo.
        StatisticsScreen.routeName: (context) => const StatisticsScreen(), // La ruta para la pantalla de estadísticas.
      },
    );
  }
}