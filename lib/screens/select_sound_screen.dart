import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class SelectSoundScreen extends StatefulWidget {
  const SelectSoundScreen({Key? key}) : super(key: key);

  static const String routeName = '/select-sound';

  @override
  State<SelectSoundScreen> createState() => _SelectSoundScreenState();
}

class _SelectSoundScreenState extends State<SelectSoundScreen> {
  final List<Map<String, String>> _sounds = [
    {
      'name': 'Lluvia',
      'description': 'Lluvia suave cayendo',
      'image': 'assets/images/lluvia.jpg',
      'audio': 'assets/sounds/lluvia.mp3',
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

  String _selectedSound = 'Lluvia';
  double _volume = 50;
  AudioPlayer? _previewPlayer;

  static const String _keySoundName = 'sound_name';
  static const String _keyVolume = 'sound_volume';

  @override
  void initState() {
    super.initState();
    _previewPlayer = AudioPlayer();

    // DEBUGGING: Escuchar todos los cambios de estado
    _previewPlayer?.onPlayerStateChanged.listen((PlayerState state) {
      print('DEBUG Player state changed: $state');
      // Si el estado es 'stopped' y no es por stop() manual, es problema del loop o archivo
      if (state == PlayerState.stopped && !_isStoppingManually) {
        print('DEBUG: Player stopped unexpectedly. Audio file might be too short or loop failed.');
      }
    });

    // DEBUGGING: Escuchar cuando la reproducción se completa (incluso en loop)
    _previewPlayer?.onPlayerComplete.listen((_) {
      print('DEBUG Playback completed. (This will fire repeatedly if looping)');
      // Si esto se repite, significa que el loop está funcionando pero no se percibe
      // Si solo se dispara una vez y luego PlayerState.stopped, el loop no está funcionando.
    });

    // DEBUGGING: Logs internos de audioplayers
    _previewPlayer?.onLog.listen((event) {
      print('DEBUG AudioPlayer Log: $event');
    });

    _loadSoundPreferences();
  }

  // Bandera para diferenciar un stop manual de un stop automático por fin de archivo
  bool _isStoppingManually = false;

  @override
  void dispose() {
    _previewPlayer?.stop(); // Siempre detener al salir
    _previewPlayer?.dispose();
    super.dispose();
  }

  Future<void> _loadSoundPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final String soundName = prefs.getString(_keySoundName) ?? 'Lluvia';
    final int vol = prefs.getInt(_keyVolume) ?? 50;

    setState(() {
      _selectedSound = soundName;
      _volume = vol.toDouble();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 100));
      _playPreview(_selectedSound, _volume / 100);
    });
  }

  Future<void> _saveSoundPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySoundName, _selectedSound);
    await prefs.setInt(_keyVolume, _volume.toInt());
  }

  Future<void> _playPreview(String soundName, double volume) async {
    _isStoppingManually = true; // Indicar que el stop() es intencional
    if (_previewPlayer != null) {
      await _previewPlayer!.stop();
    }
    _isStoppingManually = false; // Resetear la bandera

    final soundMap = _sounds.firstWhere((s) => s['name'] == soundName);
    final audioPath = soundMap['audio']!;

    if (_previewPlayer != null) {
      // DEBUG: Asegurar que el modo loop se aplica antes de reproducir
      await _previewPlayer!.setReleaseMode(ReleaseMode.loop);
      await _previewPlayer!.setVolume(volume);
      final assetRelative = audioPath.replaceFirst('assets/', '');

      try {
        await _previewPlayer!.play(AssetSource(assetRelative));
        print('Playing: $assetRelative at volume $volume'); // DEJAR ESTE PRINT
      } catch (e) {
        print('Error playing audio: $e'); // DEJAR ESTE PRINT
      }
    }
  }

  Future<void> _stopPreview() async {
    _isStoppingManually = true; // Indicar que el stop() es intencional
    await _previewPlayer?.stop();
    _isStoppingManually = false; // Resetear la bandera
  }

  void _onDonePressed() async {
    await _stopPreview();
    await _saveSoundPreferences();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF19332E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '¡Sonido configurado!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'El paisaje sonoro se aplicará en tus ciclos OnFocus.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF19E5C2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF12211F),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12211F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF19332E),
        title: const Text(
          'Sonidos',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            _stopPreview();
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Paisajes sonoros',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: _sounds.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final sound = _sounds[index];
                    final isSelected = sound['name'] == _selectedSound;

                    return InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        setState(() {
                          _selectedSound = sound['name']!;
                        });
                        _playPreview(_selectedSound, _volume / 100);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF19E5C2).withOpacity(0.4)
                              : const Color(0xFF244740),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    sound['name']!,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.grey[200],
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    sound['description']!,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white70 : Colors.grey[400],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.asset(
                                sound['image']!,
                                width: 64,
                                height: 48,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    'Volumen',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const Spacer(),
                  Text(
                    _volume.toInt().toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _volume,
                min: 0,
                max: 100,
                divisions: 100,
                onChanged: (double newValue) {
                  setState(() {
                    _volume = newValue;
                  });
                  _previewPlayer?.setVolume(_volume / 100);
                },
                activeColor: const Color(0xFF19E5C2),
                inactiveColor: Colors.grey.shade700,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF19E5C2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _onDonePressed,
                  child: const Text(
                    'Listo',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF12211F),
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