import 'package:flutter/material.dart'; // Importamos el paquete fundamental de Flutter para construir interfaces de usuario.
import 'package:shared_preferences/shared_preferences.dart'; // Importamos `shared_preferences` para almacenar y recuperar datos persistentes.
import 'package:audioplayers/audioplayers.dart'; // Importamos `audioplayers` para la reproducción de audio.
import 'dart:async'; // Importamos `dart:async` para trabajar con operaciones asíncronas como `Future` y `Timer`.

class SelectSoundScreen extends StatefulWidget { // Definimos la clase `SelectSoundScreen`, que es un widget con estado mutable para la selección de sonidos.
  const SelectSoundScreen({Key? key}) : super(key: key); // Constructor de la clase `SelectSoundScreen`.

  static const String routeName = '/select-sound'; // Definimos una constante estática `routeName` para identificar esta pantalla en la navegación.

  @override
  State<SelectSoundScreen> createState() => _SelectSoundScreenState(); // Creamos y devolvemos el estado mutable para esta pantalla.
}

class _SelectSoundScreenState extends State<SelectSoundScreen> { // Definimos el estado asociado a `SelectSoundScreen`.
  final List<Map<String, String>> _sounds = [ // Creamos una lista de mapas, donde cada mapa representa un sonido ambiental con sus detalles.
    {
      'name': 'Lluvia', // Nombre del sonido.
      'description': 'Lluvia suave cayendo', // Descripción del sonido.
      'image': 'assets/images/lluvia.jpg', // Ruta de la imagen asociada al sonido.
      'audio': 'assets/sounds/lluvia.mp3', // Ruta del archivo de audio.
    },
    {
      'name': 'Bosque',
      'description': 'Pájaros cantando en un bosque',
      'image': 'assets/images/bosque.jpg',
      'audio': 'assets/sounds/bosque.mp3',
    },
    {
      'name': 'Café',
      'description': 'Charla ambiental de cafetería',
      'image': 'assets/images/cafeteria.jpg',
      'audio': 'assets/sounds/cafeteria.mp3',
    },
    {
      'name': 'Ruido Blanco',
      'description': 'Ruido blanco constante',
      'image': 'assets/images/ruido_blanco.jpg',
      'audio': 'assets/sounds/ruido_blanco.mp3',
    },
  ];

  String _selectedSound = 'Lluvia'; // Inicializamos la variable que guarda el nombre del sonido seleccionado, por defecto 'Lluvia'.
  double _volume = 50; // Inicializamos el volumen de reproducción de sonido, por defecto 50.
  AudioPlayer? _previewPlayer; // Declaramos una instancia de `AudioPlayer` para reproducir previsualizaciones de sonidos.

  static const String _keySoundName = 'sound_name'; // Clave para guardar el nombre del sonido seleccionado en `SharedPreferences`.
  static const String _keyVolume = 'sound_volume'; // Clave para guardar el volumen del sonido en `SharedPreferences`.

  @override
  void initState() { // Se llama una vez cuando el estado se inserta en el árbol de widgets.
    super.initState(); // Llamamos al método `initState` de la superclase.
    _previewPlayer = AudioPlayer(); // Inicializamos el reproductor de audio.

    // DEBUGGING: Escuchamos todos los cambios de estado del reproductor para depuración.
    _previewPlayer?.onPlayerStateChanged.listen((PlayerState state) {
      print('DEBUG Player state changed: $state');
      // Si el estado es 'stopped' y no es un `stop()` manual, indicamos un posible problema con el bucle o el archivo.
      if (state == PlayerState.stopped && !_isStoppingManually) {
        print('DEBUG: Player stopped unexpectedly. Audio file might be too short or loop failed.');
      }
    });

    // DEBUGGING: Escuchamos cuando la reproducción se completa (incluso en bucle) para depuración.
    _previewPlayer?.onPlayerComplete.listen((_) {
      print('DEBUG Playback completed. (This will fire repeatedly if looping)');
      // Si esto se repite, significa que el bucle funciona; si solo se dispara una vez y luego el estado es 'stopped', el bucle no está funcionando.
    });

    // DEBUGGING: Registramos los logs internos de `audioplayers` para depuración.
    _previewPlayer?.onLog.listen((event) {
      print('DEBUG AudioPlayer Log: $event');
    });

    _loadSoundPreferences(); // Cargamos las preferencias de sonido guardadas.
  }

  // Bandera para diferenciar un `stop()` manual de un `stop()` automático por fin de archivo.
  bool _isStoppingManually = false;

  @override
  void dispose() { // Se llama cuando este objeto de estado se elimina permanentemente del árbol de widgets.
    _previewPlayer?.stop(); // Siempre detenemos la reproducción de audio al salir de la pantalla.
    _previewPlayer?.dispose(); // Liberamos los recursos del reproductor de audio.
    super.dispose(); // Llamamos al método `dispose` de la superclase.
  }

  // Método asíncrono para cargar las preferencias de sonido desde `SharedPreferences`.
  Future<void> _loadSoundPreferences() async {
    final prefs = await SharedPreferences.getInstance(); // Obtenemos una instancia de `SharedPreferences`.
    final String soundName = prefs.getString(_keySoundName) ?? 'Lluvia'; // Obtenemos el nombre del sonido guardado o 'Lluvia' como valor predeterminado.
    final int vol = prefs.getInt(_keyVolume) ?? 50; // Obtenemos el volumen guardado o 50 como valor predeterminado.

    setState(() { // Actualizamos el estado del widget.
      _selectedSound = soundName; // Asignamos el nombre del sonido cargado.
      _volume = vol.toDouble(); // Asignamos el volumen cargado.
    });

    // Post-frame callback para asegurar que el widget se ha renderizado antes de intentar reproducir el sonido.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 100)); // Pequeño retraso para asegurar la inicialización completa.
      _playPreview(_selectedSound, _volume / 100); // Reproducimos la previsualización del sonido cargado.
    });
  }

  // Método asíncrono para guardar las preferencias de sonido en `SharedPreferences`.
  Future<void> _saveSoundPreferences() async {
    final prefs = await SharedPreferences.getInstance(); // Obtenemos una instancia de `SharedPreferences`.
    await prefs.setString(_keySoundName, _selectedSound); // Guardamos el nombre del sonido seleccionado.
    await prefs.setInt(_keyVolume, _volume.toInt()); // Guardamos el volumen actual (convertido a entero).
  }

  // Método asíncrono para reproducir una previsualización de un sonido.
  Future<void> _playPreview(String soundName, double volume) async {
    _isStoppingManually = true; // Indicamos que la siguiente llamada a `stop()` es intencional.
    if (_previewPlayer != null) { // Si el reproductor no es nulo,
      await _previewPlayer!.stop(); // lo detenemos para evitar múltiples reproducciones.
    }
    _isStoppingManually = false; // Reiniciamos la bandera de detención manual.

    final soundMap = _sounds.firstWhere((s) => s['name'] == soundName); // Encontramos el mapa del sonido por su nombre.
    final audioPath = soundMap['audio']!; // Obtenemos la ruta del archivo de audio.

    if (_previewPlayer != null) { // Si el reproductor no es nulo,
      // DEBUG: Nos aseguramos de que el modo de bucle se aplique antes de reproducir.
      await _previewPlayer!.setReleaseMode(ReleaseMode.loop); // Establecemos el modo de liberación a `loop` para que el sonido se repita.
      await _previewPlayer!.setVolume(volume); // Establecemos el volumen de reproducción.
      final assetRelative = audioPath.replaceFirst('assets/', ''); // Obtenemos la ruta relativa del asset.

      try {
        await _previewPlayer!.play(AssetSource(assetRelative)); // Intentamos reproducir el archivo de audio desde los assets.
        print('Playing: $assetRelative at volume $volume'); // Dejamos este `print` para depuración: muestra qué archivo se está reproduciendo y a qué volumen.
      } catch (e) {
        print('Error playing audio: $e'); // Dejamos este `print` para depuración: muestra si ocurre un error al reproducir el audio.
      }
    }
  }

  // Método asíncrono para detener la previsualización del sonido.
  Future<void> _stopPreview() async {
    _isStoppingManually = true; // Indicamos que la siguiente llamada a `stop()` es intencional.
    await _previewPlayer?.stop(); // Detenemos la reproducción del sonido.
    _isStoppingManually = false; // Reiniciamos la bandera de detención manual.
  }

  // Método que se llama cuando se presiona el botón "Listo".
  void _onDonePressed() async {
    await _stopPreview(); // Detenemos cualquier previsualización de sonido que esté activa.
    await _saveSoundPreferences(); // Guardamos las preferencias de sonido seleccionadas.
    showDialog( // Mostramos un cuadro de diálogo al usuario para confirmar la configuración.
      context: context, // El contexto para el diálogo.
      barrierDismissible: false, // Evitamos que el diálogo se cierre al tocar fuera de él.
      builder: (ctx) => Dialog( // Constructor del contenido del diálogo.
        backgroundColor: const Color(0xFF19332E), // Color de fondo del diálogo.
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Forma del diálogo con bordes redondeados.
        child: Padding( // Relleno dentro del diálogo.
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0), // Relleno horizontal y vertical.
          child: Column( // Columna para organizar los elementos dentro del diálogo.
            mainAxisSize: MainAxisSize.min, // El tamaño de la columna se ajusta al contenido mínimo.
            children: [
              const Text( // Texto de confirmación principal.
                '¡Sonido configurado!', // Mensaje principal.
                style: TextStyle( // Estilo del texto.
                  color: Colors.white, // Color del texto.
                  fontSize: 18, // Tamaño de fuente.
                  fontWeight: FontWeight.bold, // Negrita.
                ),
                textAlign: TextAlign.center, // Alineación del texto.
              ),
              const SizedBox(height: 12), // Espacio vertical.
              const Text( // Texto secundario informativo.
                'El paisaje sonoro se aplicará en tus ciclos OnFocus.', // Mensaje.
                style: TextStyle( // Estilo del texto con transparencia.
                  color: Colors.white70, // Color del texto.
                  fontSize: 14, // Tamaño de fuente.
                ),
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
                    Navigator.of(ctx).pop(); // Cierra el diálogo actual.
                    Navigator.of(context).pop(); // Regresa a la pantalla anterior.
                  },
                  child: const Text( // Texto del botón.
                    'OK', // Contenido del texto.
                    style: TextStyle( // Estilo del texto.
                      fontSize: 16, // Tamaño de fuente.
                      color: Color(0xFF12211F), // Color del texto.
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) { // Construimos la interfaz de usuario de la pantalla `SelectSoundScreen`.
    return Scaffold( // Proporciona la estructura visual básica de la pantalla.
      backgroundColor: const Color(0xFF12211F), // Establecemos el color de fondo de la pantalla.
      appBar: AppBar( // Definimos la barra superior de la aplicación.
        backgroundColor: const Color(0xFF19332E), // Color de fondo del `AppBar`.
        title: const Text( // Título del `AppBar`.
          'Sonidos', // Contenido del título.
          style: TextStyle(color: Colors.white), // Estilo del título.
        ),
        centerTitle: true, // Centramos el título.
        iconTheme: const IconThemeData(color: Colors.white), // Color de los íconos del `AppBar`.
        leading: IconButton( // Botón a la izquierda del `AppBar` para cerrar la pantalla.
          icon: const Icon(Icons.close, color: Colors.white), // Ícono de cerrar.
          onPressed: () { // Acción al presionar el botón.
            _stopPreview(); // Detenemos la previsualización del sonido.
            Navigator.pop(context); // Cerramos la pantalla actual.
          },
        ),
      ),
      body: SafeArea( // Aseguramos que el contenido se muestre dentro de los límites seguros del dispositivo.
        child: Padding( // Añadimos un relleno alrededor del contenido principal.
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0), // Relleno horizontal y vertical.
          child: Column( // Columna para organizar los elementos en el cuerpo de la pantalla.
            crossAxisAlignment: CrossAxisAlignment.stretch, // Estiramos los hijos horizontalmente.
            children: [
              const Text( // Título de la sección de paisajes sonoros.
                'Paisajes sonoros', // Contenido del texto.
                style: TextStyle( // Estilo del texto.
                  color: Colors.white, // Color del texto.
                  fontSize: 18, // Tamaño de fuente.
                  fontWeight: FontWeight.bold, // Negrita.
                ),
              ),
              const SizedBox(height: 16), // Espacio vertical.
              Expanded( // Expandimos la lista de sonidos para que ocupe el espacio restante.
                child: ListView.separated( // Creamos una lista desplazable con separadores entre los elementos.
                  itemCount: _sounds.length, // Número de elementos en la lista (basado en la cantidad de sonidos).
                  separatorBuilder: (_, __) => const SizedBox(height: 12), // Constructor para el separador entre elementos.
                  itemBuilder: (context, index) { // Constructor para cada elemento de la lista.
                    final sound = _sounds[index]; // Obtenemos el mapa del sonido actual.
                    final isSelected = sound['name'] == _selectedSound; // Verificamos si este sonido está seleccionado.

                    return InkWell( // Hacemos que el elemento sea interactivo y muestre un efecto de salpicadura al tocarlo.
                      borderRadius: BorderRadius.circular(8), // Bordes redondeados para el efecto de salpicadura.
                      onTap: () { // Acción al tocar el elemento.
                        setState(() { // Actualizamos el estado.
                          _selectedSound = sound['name']!; // Establecemos el sonido seleccionado.
                        });
                        _playPreview(_selectedSound, _volume / 100); // Reproducimos la previsualización del sonido recién seleccionado.
                      },
                      child: Container( // Contenedor para el diseño visual de cada elemento de sonido.
                        decoration: BoxDecoration( // Decoración del contenedor.
                          color: isSelected // Color de fondo basado en si el sonido está seleccionado.
                              ? const Color(0xFF19E5C2).withOpacity(0.4) // Verde cian con transparencia si está seleccionado.
                              : const Color(0xFF244740), // Tono de verde azulado si no está seleccionado.
                          borderRadius: BorderRadius.circular(8), // Bordes redondeados.
                        ),
                        padding: const EdgeInsets.all(12), // Relleno interno del contenedor.
                        child: Row( // Fila para organizar la imagen, texto y el ícono de selección.
                          children: [
                            Expanded( // Expande la columna de texto para que ocupe el espacio disponible.
                              child: Column( // Columna para el nombre y la descripción del sonido.
                                crossAxisAlignment: CrossAxisAlignment.start, // Alinea el texto al inicio.
                                children: [
                                  Text( // Texto del nombre del sonido.
                                    sound['name']!, // Nombre del sonido.
                                    style: TextStyle( // Estilo del texto.
                                      color: isSelected ? Colors.white : Colors.grey[200], // Color del texto según la selección.
                                      fontSize: 16, // Tamaño de fuente.
                                      fontWeight: FontWeight.w600, // Peso de la fuente.
                                    ),
                                  ),
                                  const SizedBox(height: 4), // Espacio vertical.
                                  Text( // Texto de la descripción del sonido.
                                    sound['description']!, // Descripción del sonido.
                                    style: TextStyle( // Estilo del texto.
                                      color: isSelected ? Colors.white70 : Colors.grey[400], // Color del texto según la selección.
                                      fontSize: 14, // Tamaño de fuente.
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8), // Espacio horizontal.
                            ClipRRect( // Recorta la imagen con bordes redondeados.
                              borderRadius: BorderRadius.circular(6), // Bordes redondeados de la imagen.
                              child: Image.asset( // Muestra la imagen del asset.
                                sound['image']!, // Ruta de la imagen.
                                width: 64, // Ancho de la imagen.
                                height: 48, // Alto de la imagen.
                                fit: BoxFit.cover, // Ajuste de la imagen.
                              ),
                            ),
                            const SizedBox(width: 8), // Espacio horizontal.
                            if (isSelected) // Si el sonido está seleccionado, mostramos un ícono de verificación.
                              const Icon( // Ícono de verificación.
                                Icons.check_circle, // Ícono de círculo con check.
                                color: Colors.white, // Color del ícono.
                                size: 24, // Tamaño del ícono.
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16), // Espacio vertical.
              Row( // Fila para el control de volumen.
                children: [
                  const Text( // Etiqueta "Volumen".
                    'Volumen', // Contenido del texto.
                    style: TextStyle(color: Colors.white, fontSize: 16), // Estilo del texto.
                  ),
                  const Spacer(), // Ocupa el espacio restante para empujar los elementos a los extremos.
                  Text( // Muestra el valor numérico del volumen.
                    _volume.toInt().toString(), // Valor del volumen como entero.
                    style: const TextStyle( // Estilo del texto.
                      color: Colors.white, // Color del texto.
                      fontSize: 16, // Tamaño de fuente.
                      fontWeight: FontWeight.w500, // Peso de la fuente.
                    ),
                  ),
                ],
              ),
              Slider( // Slider para ajustar el volumen.
                value: _volume, // Valor actual del slider.
                min: 0, // Valor mínimo del slider.
                max: 100, // Valor máximo del slider.
                divisions: 100, // Número de divisiones del slider.
                onChanged: (double newValue) { // Función que se llama cuando el valor del slider cambia.
                  setState(() { // Actualizamos el estado.
                    _volume = newValue; // Asignamos el nuevo valor del volumen.
                  });
                  _previewPlayer?.setVolume(_volume / 100); // Establecemos el volumen del reproductor de audio.
                },
                activeColor: const Color(0xFF19E5C2), // Color del slider cuando está activo.
                inactiveColor: Colors.grey.shade700, // Color del slider cuando está inactivo.
              ),
              const SizedBox(height: 24), // Espacio vertical.
              SizedBox( // Contenedor para el botón "Listo".
                height: 48, // Altura fija.
                child: ElevatedButton( // Botón elevado.
                  style: ElevatedButton.styleFrom( // Estilo del botón.
                    backgroundColor: const Color(0xFF19E5C2), // Color de fondo del botón.
                    shape: RoundedRectangleBorder( // Forma del borde.
                      borderRadius: BorderRadius.circular(8), // Bordes redondeados.
                    ),
                  ),
                  onPressed: _onDonePressed, // Llama a la función `_onDonePressed` al presionar.
                  child: const Text( // Texto del botón.
                    'Listo', // Contenido del texto.
                    style: TextStyle( // Estilo del texto.
                      fontSize: 18, // Tamaño de fuente.
                      color: Color(0xFF12211F), // Color del texto.
                    ),
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