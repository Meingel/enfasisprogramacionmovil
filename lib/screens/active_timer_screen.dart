import 'dart:async'; // Importamos `dart:async` para trabajar con operaciones asíncronas y temporizadores.
import 'package:flutter/material.dart'; // Importamos el paquete fundamental de Flutter para construir interfaces de usuario.
import 'package:shared_preferences/shared_preferences.dart'; // Importamos `shared_preferences` para almacenar y recuperar datos de forma persistente.
import 'package:audioplayers/audioplayers.dart'; // Importamos `audioplayers` para la reproducción de audio.
import 'cycle_notification_screen.dart'; // Importamos la pantalla de notificación de ciclo.
import '../services/stats_service.dart'; // Importamos nuestro servicio de estadísticas para registrar ciclos completados.

class ActiveTimerScreen extends StatefulWidget { // Definimos la clase `ActiveTimerScreen`, que es un widget con estado mutable para el temporizador activo.
  const ActiveTimerScreen({Key? key}) : super(key: key); // Constructor de la clase `ActiveTimerScreen`.
  static const String routeName = '/active-timer'; // Definimos una constante estática `routeName` para identificar esta pantalla en la navegación.

  @override
  State<ActiveTimerScreen> createState() => _ActiveTimerScreenState(); // Creamos y devolvemos el estado mutable para esta pantalla.
}

class _ActiveTimerScreenState extends State<ActiveTimerScreen> { // Definimos el estado asociado a `ActiveTimerScreen`.
  bool _isRunning = false; // Variable booleana para indicar si el temporizador está corriendo.
  Timer? _timer; // Instancia de `Timer` para controlar el conteo regresivo.

  // Duraciones en segundos, cargadas desde las preferencias del usuario.
  int _workDuration = 0; // Duración del período de trabajo.
  int _shortDuration = 0; // Duración del descanso corto.
  int _longDuration = 0; // Duración del descanso largo.
  bool _useLongCycles = false; // Indica si se deben usar ciclos de descanso largo.

  // Estado actual del temporizador.
  int _remaining = 0; // Segundos restantes en la fase actual.
  int _phase = 0; // Fase actual del ciclo: 0=Trabajo, 1=Descanso Corto, 2=Descanso Largo.
  int _workCount = 0; // Contador de ciclos de trabajo completados.

  // Audio
  AudioPlayer? _player; // Instancia de `AudioPlayer` para reproducir sonidos ambientales.
  String _soundName = 'Lluvia'; // Nombre del sonido ambiental seleccionado.
  double _soundVol = 0.5; // Volumen del sonido ambiental (0.0 a 1.0).

  // Tarea
  final _taskCtrl = TextEditingController(); // Controlador para el campo de texto de la tarea actual.
  // Claves para `SharedPreferences`.
  static const _kTask     = 'task_name';          // Clave para el nombre de la tarea.
  static const _kWork     = 'work_duration';      // Clave para la duración del trabajo.
  static const _kShort    = 'short_break_duration'; // Clave para la duración del descanso corto.
  static const _kLong     = 'long_break_duration';  // Clave para la duración del descanso largo.
  static const _kUseLong  = 'use_long_cycles';    // Clave para la opción de usar ciclos largos.
  static const _kSound    = 'sound_name';         // Clave para el nombre del sonido.
  static const _kVol      = 'sound_volume';       // Clave para el volumen del sonido.

  // Instancia del servicio de estadísticas
  final StatsService _statsService = StatsService(); // Creamos una instancia de `StatsService` para interactuar con las estadísticas.

  @override
  void initState() { // Se llama una vez cuando el estado se inserta en el árbol de widgets.
    super.initState(); // Llamamos al método `initState` de la superclase.
    _player = AudioPlayer(); // Inicializamos el reproductor de audio.
    _loadPrefs(); // Cargamos las preferencias guardadas por el usuario.
  }

  @override
  void dispose() { // Se llama cuando este objeto de estado se elimina permanentemente del árbol de widgets.
    _timer?.cancel(); // Cancelamos cualquier temporizador activo para evitar fugas de memoria.
    _player?.stop(); // Detenemos la reproducción de audio.
    _player?.dispose(); // Liberamos los recursos del reproductor de audio.
    _taskCtrl.dispose(); // Liberamos los recursos del controlador de texto de la tarea.
    super.dispose(); // Llamamos al método `dispose` de la superclase.
  }

  // Método asíncrono para cargar las preferencias de duración de ciclos y sonido.
  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance(); // Obtenemos una instancia de `SharedPreferences`.
    setState(() { // Actualizamos el estado del widget.
      _workDuration  = p.getInt(_kWork)  ?? 25 * 60; // Cargamos la duración de trabajo o usamos 25 minutos como predeterminado.
      _shortDuration = p.getInt(_kShort) ?? 5 * 60;  // Cargamos la duración de descanso corto o usamos 5 minutos como predeterminado.
      _longDuration  = p.getInt(_kLong)  ?? 15 * 60; // Cargamos la duración de descanso largo o usamos 15 minutos como predeterminado.
      _useLongCycles = p.getBool(_kUseLong) ?? false; // Cargamos la configuración de ciclos largos o usamos `false` como predeterminado.
      _soundName     = p.getString(_kSound) ?? 'Lluvia'; // Cargamos el nombre del sonido o 'Lluvia' como predeterminado.
      _soundVol      = (p.getInt(_kVol) ?? 50) / 100; // Cargamos el volumen o usamos 50 (convertido a 0.5) como predeterminado.
      _taskCtrl.text = p.getString(_kTask) ?? 'Nombre Tarea'; // Cargamos el nombre de la tarea o 'Nombre Tarea' como predeterminado.

      _phase = 0; // Inicializamos la fase a trabajo.
      _remaining = _workDuration; // Establecemos el tiempo restante a la duración del trabajo.
      _workCount = 0; // Reiniciamos el contador de ciclos de trabajo.
    });
  }

  // Método asíncrono para guardar el nombre de la tarea.
  Future<void> _saveTask(String name) async {
    final p = await SharedPreferences.getInstance(); // Obtenemos una instancia de `SharedPreferences`.
    await p.setString(_kTask, name); // Guardamos el nombre de la tarea.
  }

  // Método asíncrono para reproducir el sonido de trabajo.
  Future<void> _playWorkSound() async {
    await _player?.stop(); // Detenemos cualquier sonido que se esté reproduciendo.
    // Construimos la ruta del asset de audio a partir del nombre del sonido.
    final asset =
        'sounds/${_soundName.toLowerCase().replaceAll(' ', '_')}.mp3';
    // Configuramos el reproductor para que el sonido se repita en bucle, establecemos el volumen y lo reproducimos.
    await _player!
        .setReleaseMode(ReleaseMode.loop) // Establecemos el modo de liberación a `loop` para repetición.
        .then((_) => _player!.setVolume(_soundVol)) // Establecemos el volumen.
        .then((_) => _player!.play(AssetSource(asset))); // Reproducimos el sonido desde los assets.
  }

  // Método para iniciar o pausar el temporizador.
  void _toggleTimer() {
    if (!_isRunning) { // Si el temporizador no está corriendo (es decir, va a iniciar o reanudar),
      _saveTask(_taskCtrl.text.trim()); // guardamos el nombre de la tarea.
    }
    if (_isRunning) { // Si el temporizador está corriendo (es decir, se va a pausar),
      _timer?.cancel(); // Cancelamos el temporizador.
      if (_phase == 0) _player?.pause(); // Si estamos en fase de trabajo, pausamos el sonido.
      setState(() => _isRunning = false); // Actualizamos el estado a no corriendo.
    } else { // Si el temporizador no está corriendo (es decir, se va a iniciar o reanudar),
      setState(() => _isRunning = true); // Actualizamos el estado a corriendo.
      if (_phase == 0) { // Si la fase actual es trabajo,
        _playWorkSound(); // reproducimos el sonido de trabajo.
      }
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) { // Creamos un temporizador que se dispara cada segundo.
        setState(() { // Actualizamos el estado en cada tick del temporizador.
          if (_remaining > 0) { // Si aún queda tiempo en la fase actual,
            _remaining--; // decrementamos el tiempo restante.
          } else {
            // Si el tiempo restante llega a 0, significa que la fase actual ha terminado.
            if (_phase == 2) { // Si la fase actual era descanso largo,
              // Terminó el descanso largo: esto marca el fin de un ciclo completo (trabajo + 3 descansos cortos + 1 largo).
              timer.cancel(); // Cancelamos el temporizador.
              _player?.stop(); // Detenemos el sonido.

              // === AQUÍ GUARDAMOS EL TIMESTAMP DEL CICLO LARGO COMPLETO ===
              _statsService.saveCompletedLongCycleTimestamp(DateTime.now()).then((_) { // Guardamos el timestamp del ciclo largo completado.
                // Una vez guardado, navegamos a la pantalla de notificación de ciclo, reemplazando la pantalla actual.
                Navigator.pushReplacementNamed(
                  context,
                  CycleNotificationScreen.routeName,
                );
              });
              return; // Salimos de la función `setState` ya que la pantalla será reemplazada.
            }

            // Si la fase actual era trabajo, detenemos el sonido y contamos el ciclo.
            if (_phase == 0) {
              _player?.stop(); // Detenemos el sonido de trabajo.
              _workCount++; // Incrementamos el contador de ciclos de trabajo completados.
              // Determinamos si el próximo descanso debe ser largo (cada 4 ciclos de trabajo y si la opción está activada).
              final needLong = _useLongCycles && _workCount % 4 == 0;
              _phase = needLong ? 2 : 1; // Establecemos la próxima fase (descanso largo o corto).
              _remaining =
              needLong ? _longDuration : _shortDuration; // Establecemos el tiempo restante para la nueva fase.
            } else {
              // Si la fase actual era descanso corto, volvemos a la fase de trabajo.
              _phase = 0; // Establecemos la fase a trabajo.
              _remaining = _workDuration; // Establecemos el tiempo restante a la duración del trabajo.
            }

            // Notificamos el inicio de la nueva fase al usuario.
            final names = ['Trabajo', 'Descanso Corto', 'Descanso Largo']; // Nombres de las fases.
            ScaffoldMessenger.of(context).showSnackBar( // Mostramos un `SnackBar`.
              SnackBar(content: Text('${names[_phase]} iniciado')), // Mensaje del `SnackBar`.
            );

            // Si la nueva fase es Trabajo, reproducimos el sonido ambiental.
            if (_phase == 0) {
              _playWorkSound();
            }
          }
        });
      });
    }
  }

  // Método para reiniciar el temporizador a su estado inicial para la fase actual.
  void _resetTimer() {
    _timer?.cancel(); // Cancelamos el temporizador.
    _player?.stop(); // Detenemos el sonido.
    setState(() { // Actualizamos el estado.
      _isRunning = false; // El temporizador no está corriendo.
      // Establecemos el tiempo restante a la duración de la fase actual.
      _remaining =
      [_workDuration, _shortDuration, _longDuration][_phase];
    });
  }

  // Método para detener la sesión y volver a la pantalla anterior.
  void _stopSession() {
    _timer?.cancel(); // Cancelamos el temporizador.
    _player?.stop(); // Detenemos el sonido.
    Navigator.pop(context); // Cerramos la pantalla actual.
  }

  // Getter para obtener los minutos restantes formateados con dos dígitos.
  String get _minStr => (_remaining ~/ 60).toString().padLeft(2, '0');
  // Getter para obtener los segundos restantes formateados con dos dígitos.
  String get _secStr => (_remaining % 60).toString().padLeft(2, '0');

  // Calcula el progreso de la barra en función del tiempo restante y total de la fase actual.
  double _progress(int total) =>
      total > 0 && _phaseMatches(total) ? _remaining / total : 0;

  // Verifica si el tiempo total proporcionado coincide con la duración de la fase actual.
  bool _phaseMatches(int total) {
    if (_phase == 0 && total == _workDuration) return true; // Si es fase de trabajo y coincide con la duración de trabajo.
    if (_phase == 1 && total == _shortDuration) return true; // Si es fase de descanso corto y coincide con la duración de descanso corto.
    if (_phase == 2 && total == _longDuration) return true; // Si es fase de descanso largo y coincide con la duración de descanso largo.
    return false; // No coincide.
  }

  @override
  Widget build(BuildContext context) { // Construimos la interfaz de usuario de la pantalla `ActiveTimerScreen`.
    final titles = ['Pomodoro', 'Descanso Corto', 'Descanso Largo']; // Títulos para cada fase del temporizador.
    return Scaffold( // Proporciona la estructura visual básica de la pantalla.
      backgroundColor: const Color(0xFF12211F), // Establecemos el color de fondo de la pantalla.
      appBar: AppBar( // Definimos la barra superior de la aplicación.
        backgroundColor: const Color(0xFF19332E), // Color de fondo del `AppBar`.
        title: Text(titles[_phase], style: const TextStyle(color: Colors.white)), // Título del `AppBar` que cambia según la fase actual.
        centerTitle: true, // Centramos el título.
        leading: IconButton( // Botón a la izquierda del `AppBar` para detener la sesión.
          icon: const Icon(Icons.close, color: Colors.white), // Ícono de cerrar.
          onPressed: _stopSession, // Llama a la función `_stopSession` al presionar.
        ),
      ),
      body: Padding( // Añadimos un relleno alrededor del cuerpo de la pantalla.
        padding: const EdgeInsets.all(24), // Relleno de 24 píxeles en todos los lados.
        child: Column( // Columna para organizar los elementos verticalmente.
          crossAxisAlignment: CrossAxisAlignment.stretch, // Estiramos los hijos horizontalmente.
          children: [
            // Campo para el nombre de la tarea
            TextField( // Campo de entrada de texto para el nombre de la tarea.
              controller: _taskCtrl, // Controlador para el campo de texto.
              style: const TextStyle(color: Colors.white), // Estilo del texto de entrada.
              decoration: InputDecoration( // Decoración visual del campo de entrada.
                filled: true, // El campo está rellenado.
                fillColor: const Color(0xFF244740), // Color de relleno.
                hintText: 'Nombre Tarea', // Texto de sugerencia.
                hintStyle: const TextStyle(color: Colors.white70), // Estilo del texto de sugerencia.
                border: OutlineInputBorder( // Define el borde del campo.
                  borderRadius: BorderRadius.circular(8), // Bordes redondeados.
                  borderSide: BorderSide.none, // Sin borde visible.
                ),
              ),
            ),
            const SizedBox(height: 24), // Espacio vertical.

            // Barras de progreso
            _buildProgressBar('Ciclo', _workDuration, _progress(_workDuration)), // Barra de progreso para el ciclo de trabajo.
            const SizedBox(height: 16), // Espacio vertical.
            _buildProgressBar( // Barra de progreso para el descanso corto, mostrando el progreso de los ciclos de trabajo.
              'Descanso Corto $_workCount/4',
              _shortDuration,
              _progress(_shortDuration),
            ),
            const SizedBox(height: 16), // Espacio vertical.
            _buildProgressBar( // Barra de progreso para el descanso largo.
              'Descanso Largo',
              _longDuration,
              _progress(_longDuration),
            ),

            const SizedBox(height: 32), // Espacio vertical.
            // Reloj Digital
            Row( // Fila para mostrar el tiempo restante en formato digital.
              mainAxisAlignment: MainAxisAlignment.center, // Centramos los elementos horizontalmente.
              children: [
                _timeBox(_minStr), // Caja para mostrar los minutos.
                const SizedBox(width: 12), // Espacio horizontal entre los dígitos.
                _timeBox(_secStr), // Caja para mostrar los segundos.
              ],
            ),

            const SizedBox(height: 32), // Espacio vertical.
            // Controles (botones de acción)
            _controlButton( // Botón para iniciar/pausar el temporizador.
              _isRunning ? 'Pausar' : 'Iniciar', // Texto del botón cambia según si está corriendo o no.
              _toggleTimer, // Llama a `_toggleTimer` al presionar.
            ),
            const SizedBox(height: 12), // Espacio vertical.
            _controlButton('Reiniciar', _resetTimer), // Botón para reiniciar el temporizador.
            const SizedBox(height: 12), // Espacio vertical.
            _controlButton( // Botón para detener la sesión.
              'Detener', // Texto del botón.
              _stopSession, // Llama a `_stopSession` al presionar.
              background: const Color(0xFF19E5C2), // Color de fondo personalizado.
              textColor: const Color(0xFF12211F), // Color del texto personalizado.
            ),
          ],
        ),
      ),
    );
  }

  // Método para construir una barra de progreso visual.
  Widget _buildProgressBar(String label, int total, double value) {
    return Column( // Columna para la etiqueta y la barra de progreso.
      crossAxisAlignment: CrossAxisAlignment.start, // Alinea la etiqueta al inicio.
      children: [
        Text(label, style: const TextStyle(color: Colors.white)), // Etiqueta de la barra de progreso.
        const SizedBox(height: 4), // Espacio vertical.
        ClipRRect( // Recorta la barra de progreso con bordes redondeados.
          borderRadius: BorderRadius.circular(6), // Bordes redondeados.
          child: LinearProgressIndicator( // La barra de progreso lineal.
            value: value, // Valor actual del progreso (0.0 a 1.0).
            minHeight: 8, // Altura mínima de la barra.
            backgroundColor: const Color(0xFF244740), // Color de fondo de la barra (cuando no hay progreso).
            valueColor: const AlwaysStoppedAnimation(Color(0xFF19E5C2)), // Color de la barra de progreso.
          ),
        ),
      ],
    );
  }

  // Método para construir un cuadro que muestra los dígitos del tiempo (minutos o segundos).
  Widget _timeBox(String text) {
    return Container( // Contenedor para el dígito.
      width: 80, // Ancho fijo.
      height: 60, // Alto fijo.
      decoration: BoxDecoration( // Decoración del contenedor.
        color: const Color(0xFF244740), // Color de fondo del cuadro.
        borderRadius: BorderRadius.circular(8), // Bordes redondeados.
      ),
      child: Center( // Centra el texto dentro del cuadro.
        child: Text( // Texto que muestra los minutos o segundos.
          text, // El texto a mostrar.
          style: const TextStyle( // Estilo del texto.
            color: Colors.white, // Color del texto.
            fontSize: 32, // Tamaño de fuente grande.
            fontWeight: FontWeight.bold, // Negrita.
          ),
        ),
      ),
    );
  }

  // Método para construir un botón de control reutilizable.
  Widget _controlButton(
      String label, // Etiqueta del botón.
      VoidCallback onPressed, { // Función de callback que se ejecuta al presionar.
        Color background = const Color(0xFF244740), // Color de fondo predeterminado.
        Color textColor = Colors.white, // Color de texto predeterminado.
      }) {
    return SizedBox( // Contenedor con altura fija para el botón.
      height: 48, // Altura fija.
      child: ElevatedButton( // Botón elevado.
        onPressed: onPressed, // Asigna la función de callback.
        style: ElevatedButton.styleFrom( // Estilo del botón.
          backgroundColor: background, // Color de fondo del botón.
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Bordes redondeados.
        ),
        child: Text(label, style: TextStyle(color: textColor, fontSize: 16)), // Etiqueta del botón con estilo.
      ),
    );
  }
}