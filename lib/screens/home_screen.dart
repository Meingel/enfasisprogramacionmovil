import 'package:flutter/material.dart'; // Importo el paquete fundamental de Flutter para construir interfaces de usuario.
import 'configure_cycles_screen.dart'; // Importo la pantalla para configurar los ciclos.
import 'select_sound_screen.dart'; // Importo la pantalla para seleccionar sonidos.
import 'active_timer_screen.dart'; // Importo la pantalla del temporizador activo.
import 'statistics_screen.dart'; // Importo la pantalla de estadísticas.

class HomeScreen extends StatefulWidget { // Defino la clase `HomeScreen`, que es un widget con estado mutable.
  const HomeScreen({Key? key}) : super(key: key); // Constructor de la clase `HomeScreen`.

  static const String routeName = '/home'; // Defino una constante estática `routeName` para identificar esta pantalla en la navegación.

  @override
  State<HomeScreen> createState() => _HomeScreenState(); // Creo y devuelvo el estado mutable para esta pantalla.
}

class _HomeScreenState extends State<HomeScreen> { // Defino el estado asociado a `HomeScreen`.
  // Índice activo del BottomNavigationBar
  int _selectedIndex = 0; // Almaceno el índice del elemento seleccionado actualmente en la barra de navegación inferior.

  // Lista de rutas correspondientes a cada ícono del BottomNavigationBar
  static const List<String> _navRoutes = <String>[ // Defino una lista de rutas de navegación.
    HomeScreen.routeName, // La ruta para la pantalla de inicio.
    StatisticsScreen.routeName, // La ruta para la pantalla de estadísticas.
  ];

  void _onNavItemTapped(int index) { // Este método se llama cuando se toca un elemento del `BottomNavigationBar`.
    if (index == _selectedIndex) return; // Si el elemento tocado es el mismo que el ya seleccionado, no hace nada.

    setState(() { // Actualiza el estado del widget.
      _selectedIndex = index; // Asigno el nuevo índice seleccionado.
    });

    Navigator.pushNamed(context, _navRoutes[index]); // Navego a la ruta correspondiente al índice seleccionado.
  }

  @override
  Widget build(BuildContext context) { // Construyo la interfaz de usuario de la pantalla.
    return Scaffold( // Proporciono la estructura visual básica de la pantalla.
      // Agrego un AppBar con el título y el ícono de configuración, ambos en color blanco
      appBar: AppBar( // Defino la barra superior de la aplicación.
        backgroundColor: const Color(0xFF19332E), // Establezco el color de fondo del `AppBar`.
        title: const Text( // Defino el widget de texto para el título del `AppBar`.
          'Flujo de OnFocus', // El texto del título.
          style: TextStyle(color: Colors.white), // Establezco el color del texto del título a blanco.
        ),
        centerTitle: true, // Centra el título en el `AppBar`.
        iconTheme: const IconThemeData(color: Colors.white), // Establezco el color de los íconos en el `AppBar` a blanco.
        actions: [ // Defino una lista de widgets para acciones en el `AppBar` (normalmente íconos a la derecha).
          IconButton( // Un botón de ícono para la configuración.
            icon: const Icon(Icons.settings, color: Colors.white), // El ícono de configuración, en blanco.
            onPressed: () { // Defino la acción cuando se presiona el botón.
              Navigator.pushNamed( // Navego a una nueva pantalla.
                context, // El contexto de construcción actual.
                ConfigureCyclesScreen.routeName, // La ruta a la pantalla de configuración de ciclos.
              );
            },
          ),
        ],
      ),

      // Color de fondo: #12211F
      backgroundColor: const Color(0xFF12211F), // Establezco el color de fondo de la pantalla.
      body: SafeArea( // Aseguro que el contenido se muestre dentro de los límites seguros del dispositivo.
        child: Padding( // Añado un relleno alrededor del contenido.
          padding: const EdgeInsets.symmetric(horizontal: 24.0), // Relleno horizontal de 24.0 píxeles.
          child: Column( // Organizo los widgets hijos en una columna.
            mainAxisAlignment: MainAxisAlignment.center, // Centro los widgets hijos verticalmente.
            children: [
              const SizedBox(height: 24), // Proporciono un espacio vertical de 24 píxeles debajo del `AppBar`.

              // Botón principal (color #19E5C2)
              SizedBox( // Defino un contenedor con un tamaño específico.
                width: double.infinity, // Ancho máximo disponible.
                height: 56, // Altura de 56 píxeles.
                child: ElevatedButton( // Un botón elevado, que es el botón principal de la pantalla.
                  style: ElevatedButton.styleFrom( // Defino el estilo del botón elevado.
                    backgroundColor: const Color(0xFF19E5C2), // Color de fondo del botón.
                    shape: RoundedRectangleBorder( // Forma del borde del botón.
                      borderRadius: BorderRadius.circular(8), // Borde redondeado con radio de 8.
                    ),
                  ),
                  onPressed: () { // Defino la acción cuando se presiona el botón.
                    Navigator.pushNamed( // Navego a una nueva pantalla.
                      context, // El contexto de construcción actual.
                      ActiveTimerScreen.routeName, // La ruta a la pantalla del temporizador activo.
                    );
                  },
                  child: const Text( // El texto dentro del botón.
                    'Iniciar sesión de OnFocus', // Contenido del texto.
                    style: TextStyle( // Estilo del texto.
                      fontSize: 18, // Tamaño de fuente.
                      color: Color(0xFF12211F), // Color del texto.
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24), // Proporciono un espacio vertical de 24 píxeles.

              // Fila de botones secundarios: Estadísticas y Sonidos
              Row( // Organizo los widgets hijos en una fila.
                children: [
                  Expanded( // Permito que el widget hijo ocupe todo el espacio disponible en la fila.
                    child: SizedBox( // Defino un contenedor con un tamaño específico.
                      height: 48, // Altura de 48 píxeles.
                      child: OutlinedButton.icon( // Un botón con un ícono y un texto.
                        icon: const Icon( // El ícono del botón.
                          Icons.bar_chart, // El ícono de gráfico de barras.
                          color: Colors.white, // Color del ícono.
                        ),
                        label: const Text( // El texto del botón.
                          'Estadísticas', // Contenido del texto.
                          style: TextStyle( // Estilo del texto.
                            fontSize: 16, // Tamaño de fuente.
                            color: Colors.white, // Color del texto.
                          ),
                        ),
                        style: OutlinedButton.styleFrom( // Defino el estilo del botón.
                          backgroundColor: const Color(0xFF244740), // Color de fondo del botón.
                          side: BorderSide.none, // Sin borde.
                          shape: RoundedRectangleBorder( // Forma del borde.
                            borderRadius: BorderRadius.circular(8), // Borde redondeado.
                          ),
                        ),
                        onPressed: () { // Defino la acción cuando se presiona el botón.
                          Navigator.pushNamed( // Navego a una nueva pantalla.
                            context, // El contexto de construcción actual.
                            StatisticsScreen.routeName, // La ruta a la pantalla de estadísticas.
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16), // Proporciono un espacio horizontal de 16 píxeles.
                  Expanded( // Permito que el widget hijo ocupe todo el espacio disponible en la fila.
                    child: SizedBox( // Defino un contenedor con un tamaño específico.
                      height: 48, // Altura de 48 píxeles.
                      child: OutlinedButton.icon( // Un botón con un ícono y un texto.
                        icon: const Icon( // El ícono del botón.
                          Icons.volume_up, // El ícono de volumen.
                          color: Colors.white, // Color del ícono.
                        ),
                        label: const Text( // El texto del botón.
                          'Sonidos', // Contenido del texto.
                          style: TextStyle( // Estilo del texto.
                            fontSize: 16, // Tamaño de fuente.
                            color: Colors.white, // Color del texto.
                          ),
                        ),
                        style: OutlinedButton.styleFrom( // Defino el estilo del botón.
                          backgroundColor: const Color(0xFF244740), // Color de fondo del botón.
                          side: BorderSide.none, // Sin borde.
                          shape: RoundedRectangleBorder( // Forma del borde.
                            borderRadius: BorderRadius.circular(8), // Borde redondeado.
                          ),
                        ),
                        onPressed: () { // Defino la acción cuando se presiona el botón.
                          Navigator.pushNamed( // Navego a una nueva pantalla.
                            context, // El contexto de construcción actual.
                            SelectSoundScreen.routeName, // La ruta a la pantalla de selección de sonido.
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
      bottomNavigationBar: BottomNavigationBar( // Defino la barra de navegación en la parte inferior de la pantalla.
        backgroundColor: const Color(0xFF19332E), // Establezco el color de fondo de la barra de navegación.
        currentIndex: _selectedIndex, // El índice del elemento seleccionado actualmente.
        onTap: _onNavItemTapped, // La función que se llama cuando se toca un elemento.
        selectedItemColor: const Color(0xFF19E5C2), // El color del ícono y texto del elemento seleccionado.
        unselectedItemColor: Colors.grey.shade400, // El color del ícono y texto de los elementos no seleccionados.
        items: const [ // Los elementos que componen la barra de navegación.
          BottomNavigationBarItem( // Un elemento de la barra de navegación.
            icon: Icon(Icons.home, color: Colors.white), // El ícono de inicio.
            label: 'Inicio', // La etiqueta del elemento.
          ),
          BottomNavigationBarItem( // Otro elemento de la barra de navegación.
            icon: Icon(Icons.bar_chart, color: Colors.white), // El ícono de gráfico de barras.
            label: 'Estadísticas', // La etiqueta del elemento.
          ),
        ],
      ),
    );
  }
}