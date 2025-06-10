import 'package:flutter/material.dart'; // Importa el paquete fundamental de Flutter para construir interfaces de usuario.
import 'package:shared_preferences/shared_preferences.dart'; // Importa el paquete `shared_preferences` para almacenar y recuperar datos persistentes en el dispositivo.
import 'package:flutter/services.dart'; // Importo el paquete `flutter/services.dart` para interactuar con los servicios de plataforma, como los formateadores de entrada.

class ConfigureCyclesScreen extends StatefulWidget { // Defino la clase `ConfigureCyclesScreen`, un widget con estado mutable que permite configurar los ciclos.
  const ConfigureCyclesScreen({Key? key}) : super(key: key); // Constructor de la clase `ConfigureCyclesScreen`.

  static const String routeName = '/configure-cycles'; // Defino una constante estática `routeName` para identificar esta pantalla en la navegación.

  @override
  State<ConfigureCyclesScreen> createState() => _ConfigureCyclesScreenState(); // Creo y devuelvo el estado mutable para esta pantalla.
}

class _ConfigureCyclesScreenState extends State<ConfigureCyclesScreen> { // Defino el estado asociado a `ConfigureCyclesScreen`.
  final TextEditingController _workController = TextEditingController(); // Controlador para el campo de texto de duración del trabajo.
  final TextEditingController _shortBreakController = TextEditingController(); // Controlador para el campo de texto de duración del descanso corto.
  final TextEditingController _longBreakController = TextEditingController(); // Controlador para el campo de texto de duración del descanso largo.
  bool _useLongCycles = false; // Variable booleana para controlar si se usan ciclos largos.

  // Claves para SharedPreferences (todos los valores se almacenan en segundos)
  static const String _keyWork    = 'work_duration';    // Clave para la duración del trabajo.
  static const String _keyShort   = 'short_break_duration'; // Clave para la duración del descanso corto.
  static const String _keyLong    = 'long_break_duration';  // Clave para la duración del descanso largo.
  static const String _keyUseLong = 'use_long_cycles';  // Clave para la configuración de uso de ciclos largos.

  @override
  void initState() { // Lo llamo una vez cuando el estado se inserta en el árbol de widgets.
    super.initState(); // Llamo al método `initState` de la superclase.
    _loadPreferences(); // Cargo las preferencias guardadas al iniciar la pantalla.
  }

  @override
  void dispose() { // Lo llamo cuando este objeto de estado se elimina permanentemente del árbol de widgets.
    _workController.dispose(); // Libero los recursos del controlador de texto de trabajo.
    _shortBreakController.dispose(); // Libero los recursos del controlador de texto de descanso corto.
    _longBreakController.dispose(); // Libero los recursos del controlador de texto de descanso largo.
    super.dispose(); // Llamo al método `dispose` de la superclase.
  }

  // Método asíncrono para cargar las preferencias de SharedPreferences.
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance(); // Obtengo una instancia de `SharedPreferences`.
    final int workSec   = prefs.getInt(_keyWork)  ?? 1500;  // Obtengo la duración de trabajo guardada o usa 1500 segundos (25 minutos) como valor predeterminado.
    final int shortSec  = prefs.getInt(_keyShort) ?? 300;   // Obtengo la duración de descanso corto o usa 300 segundos (5 minutos) como valor predeterminado.
    final int longSec   = prefs.getInt(_keyLong)  ?? 900;   // Obtengo la duración de descanso largo o usa 900 segundos (15 minutos) como valor predeterminado.
    final bool useLong  = prefs.getBool(_keyUseLong) ?? false; // Obtengo la configuración de uso de ciclos largos o uso `false` como valor predeterminado.

    _workController.text       = _formatDuration(workSec); // Formateo la duración de trabajo y la asigno al controlador de texto.
    _shortBreakController.text = _formatDuration(shortSec); // Formateo la duración de descanso corto y la asigno al controlador de texto.
    _longBreakController.text  = _formatDuration(longSec);  // Formateo la duración de descanso largo y la asigno al controlador de texto.
    setState(() => _useLongCycles = useLong); // Actualiza el estado del widget para reflejar la configuración de ciclos largos.
  }

  // Método asíncrono para guardar las preferencias en SharedPreferences.
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance(); // Obtengo una instancia de `SharedPreferences`.
    final int workSec  = _parseDuration(_workController.text);   // Parseo la duración de trabajo del texto a segundos.
    final int shortSec = _parseDuration(_shortBreakController.text); // Parseo la duración de descanso corto del texto a segundos.
    final int longSec  = _parseDuration(_longBreakController.text);  // Parseo la duración de descanso largo del texto a segundos.

    await prefs.setInt(_keyWork, workSec);    // Guardo la duración de trabajo en segundos.
    await prefs.setInt(_keyShort, shortSec);  // Guardo la duración de descanso corto en segundos.
    await prefs.setInt(_keyLong, longSec);    // Guardo la duración de descanso largo en segundos.
    await prefs.setBool(_keyUseLong, _useLongCycles); // Guardo la configuración de uso de ciclos largos.
  }

  // Método que se llama cuando se presiona el botón "Guardar".
  void _onSavePressed() async {
    await _savePreferences(); // Guardo las preferencias.
    showDialog( // Muestro un cuadro de diálogo al usuario.
      context: context, // El contexto para el diálogo.
      barrierDismissible: false, // Evita que el diálogo se cierre al tocar fuera de él.
      builder: (ctx) => Dialog( // Constructor del contenido del diálogo.
        backgroundColor: const Color(0xFF19332E), // Color de fondo del diálogo.
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Forma del diálogo con bordes redondeados.
        child: Padding( // Relleno dentro del diálogo.
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0), // Relleno horizontal y vertical.
          child: Column( // Columna para organizar los elementos dentro del diálogo.
            mainAxisSize: MainAxisSize.min, // El tamaño de la columna se ajusta al contenido mínimo.
            children: [
              const Text( // Texto de confirmación.
                '¡Configuración guardada!', // Mensaje principal.
                style: TextStyle( // Estilo del texto.
                  color: Colors.white, // Color del texto.
                  fontSize: 18, // Tamaño de fuente.
                  fontWeight: FontWeight.bold, // Negrita.
                ),
                textAlign: TextAlign.center, // Alineación del texto.
              ),
              const SizedBox(height: 12), // Espacio vertical.
              const Text( // Texto secundario informativo.
                'Ya puedes iniciar una sesión de OnFocus.', // Mensaje.
                style: TextStyle(color: Colors.white70, fontSize: 14), // Estilo del texto con transparencia.
                textAlign: TextAlign.center, // Alineación del texto.
              ),
              const SizedBox(height: 24), // Espacio vertical.
              SizedBox( // Contenedor para el botón "OK".
                width: double.infinity, // Ancho máximo.
                height: 44, // Altura fija.
                child: ElevatedButton( // Botón elevado.
                  style: ElevatedButton.styleFrom( // Estilo del botón.
                    backgroundColor: const Color(0xFF19E5C2), // Color de fondo del botón.
                    shape: RoundedRectangleBorder( // Forma del borde.
                      borderRadius: BorderRadius.circular(8), // Bordes redondeados.
                    ),
                  ),
                  onPressed: () { // Acción cuando se presiona el botón.
                    Navigator.of(ctx).pop(); // Cierro el diálogo actual.
                    Navigator.of(context).pop(); // Vuelvo a la pantalla anterior.
                  },
                  child: const Text( // Texto del botón.
                    'OK', // Contenido del texto.
                    style: TextStyle(fontSize: 16, color: Color(0xFF12211F)), // Estilo del texto.
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Función de ayuda: Formatea los segundos totales a un formato HH:MM:SS.
  String _formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600; // Calculo las horas.
    final minutes = (totalSeconds % 3600) ~/ 60; // Calculo los minutos restantes.
    final seconds = totalSeconds % 60; // Calculo los segundos restantes.
    final hStr = hours.toString().padLeft(2, '0'); // Formateo las horas con ceros a la izquierda.
    final mStr = minutes.toString().padLeft(2, '0'); // Formateo los minutos con ceros a la izquierda.
    final sStr = seconds.toString().padLeft(2, '0'); // Formateo los segundos con ceros a la izquierda.
    return '$hStr:$mStr:$sStr'; // Devuelvo la cadena formateada.
  }

  // Función de ayuda: Parseo una cadena HH:MM:SS a segundos totales.
  int _parseDuration(String input) {
    try {
      final parts = input.split(':'); // Divido la cadena por los dos puntos.
      if (parts.length != 3) return 0; // Si no tiene 3 partes (HH, MM, SS), devuelvo 0.
      final h = int.parse(parts[0]); // Parseo las horas.
      final m = int.parse(parts[1]); // Parseo los minutos.
      final s = int.parse(parts[2]); // Parseo los segundos.
      return h * 3600 + m * 60 + s; // Calculu y devuelvo el total de segundos.
    } catch (_) { // Capturo cualquier error de parseo.
      return 0; // En caso de error, devuelvo 0 segundos.
    }
  }

  // Widget de ayuda para construir un campo de entrada de texto con una etiqueta.
  Widget _buildField({
    required String label, // La etiqueta del campo.
    required TextEditingController controller, // El controlador de texto para el campo.
  }) {
    return Column( // Columna para la etiqueta y el campo de texto.
      crossAxisAlignment: CrossAxisAlignment.start, // Alineo los elementos al inicio horizontalmente.
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)), // Etiqueta del campo de texto.
        const SizedBox(height: 8), // Espacio vertical.
        TextField( // Campo de entrada de texto.
          controller: controller, // Asigna el controlador de texto.
          keyboardType: TextInputType.datetime, // Establezco el tipo de teclado para entrada de fecha y hora.
          inputFormatters: [ // Formateadores de entrada.
            FilteringTextInputFormatter.allow(RegExp(r'[\d:]')), // Permito solo dígitos y dos puntos.
          ],
          style: const TextStyle(color: Colors.white), // Estilo del texto de entrada.
          decoration: InputDecoration( // Decoración visual del campo de entrada.
            filled: true, // El campo está rellenado.
            fillColor: const Color(0xFF244740), // Color de relleno del campo.
            hintText: 'HH:MM:SS', // Texto de sugerencia.
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)), // Estilo del texto de sugerencia.
            border: OutlineInputBorder( // Define el borde del campo.
              borderRadius: BorderRadius.circular(8), // Bordes redondeados.
              borderSide: BorderSide.none, // Sin borde visible.
            ),
            contentPadding: // Relleno interno del contenido del campo.
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14), // Relleno horizontal y vertical.
          ),
        ),
        const SizedBox(height: 16), // Espacio vertical.
      ],
    );
  }

  @override
  Widget build(BuildContext context) { // Construyo la interfaz de usuario de la pantalla `ConfigureCyclesScreen`.
    return Scaffold( // Proporciono la estructura visual básica de la pantalla.
      backgroundColor: const Color(0xFF12211F), // Establezco el color de fondo de la pantalla.
      appBar: AppBar( // Defino la barra superior de la aplicación.
        backgroundColor: const Color(0xFF19332E), // Color de fondo del `AppBar`.
        title: const Text('Configurar Ciclos', // Título del `AppBar`.
            style: TextStyle(color: Colors.white)), // Estilo del título.
        centerTitle: true, // Centro el título.
        iconTheme: const IconThemeData(color: Colors.white), // Color de los íconos del `AppBar`.
        leading: IconButton( // Botón de retroceso en la parte izquierda del `AppBar`.
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Ícono de flecha hacia atrás.
          onPressed: () => Navigator.pop(context), // Cierro la pantalla actual al presionar.
        ),
      ),
      body: SafeArea( // Aseguro que el contenido se muestre dentro de los límites seguros del dispositivo.
        child: SingleChildScrollView( // Permito que el contenido sea desplazable si excede el espacio disponible.
          padding: // Relleno alrededor del contenido desplazable.
          const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0), // Relleno horizontal y vertical.
          child: Column( // Columna para organizar los campos de configuración y el botón.
            crossAxisAlignment: CrossAxisAlignment.stretch, // Estiro los hijos horizontalmente.
            children: [
              _buildField( // Construyo el campo de entrada para la duración del trabajo.
                label: 'Duración Trabajo (HH:MM:SS)', // Etiqueta del campo.
                controller: _workController, // Controlador asociado.
              ),
              _buildField( // Construyo el campo de entrada para la duración del descanso corto.
                label: 'Descanso Corto (HH:MM:SS)', // Etiqueta del campo.
                controller: _shortBreakController, // Controlador asociado.
              ),
              _buildField( // Construyo el campo de entrada para la duración del descanso largo.
                label: 'Descanso Largo (HH:MM:SS)', // Etiqueta del campo.
                controller: _longBreakController, // Controlador asociado.
              ),
              Row( // Fila para la opción de ciclos largos.
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribuyo los elementos a los extremos.
                children: [
                  const Expanded( // Expando el texto para que ocupe el espacio restante.
                    child: Text( // Texto descriptivo de la opción.
                      'Ciclos largos cada 4 pomodoros', // Mensaje.
                      style: TextStyle(color: Colors.white, fontSize: 16), // Estilo del texto.
                    ),
                  ),
                  Switch( // Interruptor para activar/desactivar ciclos largos.
                    activeColor: const Color(0xFF19E5C2), // Color del interruptor cuando está activo.
                    inactiveTrackColor: Colors.grey.shade700, // Color de la pista cuando está inactivo.
                    value: _useLongCycles, // Valor actual del interruptor.
                    onChanged: (v) => setState(() => _useLongCycles = v), // Actualizo el estado cuando el interruptor cambia.
                  ),
                ],
              ),
              const SizedBox(height: 32), // Espacio vertical.
              SizedBox( // Contenedor para el botón "Guardar".
                height: 48, // Altura fija.
                child: ElevatedButton( // Botón elevado para guardar la configuración.
                  style: ElevatedButton.styleFrom( // Estilo del botón.
                    backgroundColor: const Color(0xFF19E5C2), // Color de fondo del botón.
                    shape: RoundedRectangleBorder( // Forma del borde.
                        borderRadius: BorderRadius.circular(8)), // Bordes redondeados.
                  ),
                  onPressed: _onSavePressed, // Llamo a la función `_onSavePressed` al presionar.
                  child: const Text( // Texto del botón.
                    'Guardar', // Contenido del texto.
                    style: TextStyle(fontSize: 18, color: Color(0xFF12211F)), // Estilo del texto.
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}