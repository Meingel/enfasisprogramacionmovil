// lib/screens/active_timer_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <--- Punto y coma añadido aquí
import 'package:audioplayers/audioplayers.dart';
import 'cycle_notification_screen.dart';
import '../services/stats_service.dart'; // Importa tu nuevo servicio de estadísticas

class ActiveTimerScreen extends StatefulWidget {
  const ActiveTimerScreen({Key? key}) : super(key: key);
  static const String routeName = '/active-timer';

  @override
  State<ActiveTimerScreen> createState() => _ActiveTimerScreenState();
}

class _ActiveTimerScreenState extends State<ActiveTimerScreen> {
  bool _isRunning = false;
  Timer? _timer;

  // Duraciones en segundos
  int _workDuration = 0;
  int _shortDuration = 0;
  int _longDuration = 0;
  bool _useLongCycles = false;

  // Estado actual
  int _remaining = 0;
  int _phase = 0; // 0=Trabajo,1=Descanso Corto,2=Descanso Largo
  int _workCount = 0; // cuenta cuantos ciclos de trabajo completados

  // Audio
  AudioPlayer? _player;
  String _soundName = 'Lluvia';
  double _soundVol = 0.5;

  // Tarea
  final _taskCtrl = TextEditingController();
  static const _kTask     = 'task_name';
  static const _kWork     = 'work_duration';
  static const _kShort    = 'short_break_duration';
  static const _kLong     = 'long_break_duration';
  static const _kUseLong  = 'use_long_cycles';
  static const _kSound    = 'sound_name';
  static const _kVol      = 'sound_volume';

  // Instancia del servicio de estadísticas
  final StatsService _statsService = StatsService();

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _loadPrefs();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _player?.stop();
    _player?.dispose();
    _taskCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _workDuration  = p.getInt(_kWork)  ?? 25 * 60;
      _shortDuration = p.getInt(_kShort) ?? 5 * 60;
      _longDuration  = p.getInt(_kLong)  ?? 15 * 60;
      _useLongCycles = p.getBool(_kUseLong) ?? false;
      _soundName     = p.getString(_kSound) ?? 'Lluvia';
      _soundVol      = (p.getInt(_kVol) ?? 50) / 100;
      _taskCtrl.text = p.getString(_kTask) ?? 'Nombre Tarea';

      _phase = 0;
      _remaining = _workDuration;
      _workCount = 0;
    });
  }

  Future<void> _saveTask(String name) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kTask, name);
  }

  Future<void> _playWorkSound() async {
    await _player?.stop();
    final asset =
        'sounds/${_soundName.toLowerCase().replaceAll(' ', '_')}.mp3';
    await _player!
        .setReleaseMode(ReleaseMode.loop)
        .then((_) => _player!.setVolume(_soundVol))
        .then((_) => _player!.play(AssetSource(asset)));
  }

  void _toggleTimer() {
    if (!_isRunning) {
      _saveTask(_taskCtrl.text.trim());
    }
    if (_isRunning) {
      // Pausar
      _timer?.cancel();
      if (_phase == 0) _player?.pause();
      setState(() => _isRunning = false);
    } else {
      // Iniciar / Reanudar
      setState(() => _isRunning = true);
      if (_phase == 0) {
        _playWorkSound();
      }
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_remaining > 0) {
            _remaining--;
          } else {
            // Al completar fase actual
            if (_phase == 2) {
              // Terminó descanso largo: fin de ciclo completo
              timer.cancel();
              _player?.stop();

              // === AQUI SE GUARDA EL TIMESTAMP DEL CICLO LARGO COMPLETO ===
              _statsService.saveCompletedLongCycleTimestamp(DateTime.now()).then((_) {
                // Una vez guardado, navega a la pantalla de notificación
                Navigator.pushReplacementNamed(
                  context,
                  CycleNotificationScreen.routeName,
                );
              });
              return;
            }

            // Si era fase de trabajo, detener sonido y contar ciclo
            if (_phase == 0) {
              _player?.stop();
              _workCount++;
              final needLong = _useLongCycles && _workCount % 4 == 0;
              _phase = needLong ? 2 : 1;
              _remaining =
              needLong ? _longDuration : _shortDuration;
            } else {
              // Terminó descanso corto
              _phase = 0;
              _remaining = _workDuration;
            }

            // Notificar inicio de nueva fase
            final names = ['Trabajo', 'Descanso Corto', 'Descanso Largo'];
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${names[_phase]} iniciado')),
            );

            // Si volvemos a Trabajo, reproducir sonido
            if (_phase == 0) {
              _playWorkSound();
            }
          }
        });
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    _player?.stop();
    setState(() {
      _isRunning = false;
      _remaining =
      [_workDuration, _shortDuration, _longDuration][_phase];
    });
  }

  void _stopSession() {
    _timer?.cancel();
    _player?.stop();
    Navigator.pop(context);
  }

  String get _minStr => (_remaining ~/ 60).toString().padLeft(2, '0');
  String get _secStr => (_remaining % 60).toString().padLeft(2, '0');

  double _progress(int total) =>
      total > 0 && _phaseMatches(total) ? _remaining / total : 0;

  bool _phaseMatches(int total) {
    if (_phase == 0 && total == _workDuration) return true;
    if (_phase == 1 && total == _shortDuration) return true;
    if (_phase == 2 && total == _longDuration) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['Pomodoro', 'Descanso Corto', 'Descanso Largo'];
    return Scaffold(
      backgroundColor: const Color(0xFF12211F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF19332E),
        title: Text(titles[_phase], style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: _stopSession,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Nombre de la tarea
            TextField(
              controller: _taskCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF244740),
                hintText: 'Nombre Tarea',
                hintStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Barras de progreso
            _buildProgressBar('Ciclo', _workDuration, _progress(_workDuration)),
            const SizedBox(height: 16),
            _buildProgressBar(
              'Descanso Corto $_workCount/4',
              _shortDuration,
              _progress(_shortDuration),
            ),
            const SizedBox(height: 16),
            _buildProgressBar(
              'Descanso Largo',
              _longDuration,
              _progress(_longDuration),
            ),

            const SizedBox(height: 32),
            // Reloj Digital
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _timeBox(_minStr),
                const SizedBox(width: 12),
                _timeBox(_secStr),
              ],
            ),

            const SizedBox(height: 32),
            // Controles
            _controlButton(
              _isRunning ? 'Pausar' : 'Iniciar',
              _toggleTimer,
            ),
            const SizedBox(height: 12),
            _controlButton('Reiniciar', _resetTimer),
            const SizedBox(height: 12),
            _controlButton(
              'Detener',
              _stopSession,
              background: const Color(0xFF19E5C2),
              textColor: const Color(0xFF12211F),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(String label, int total, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: const Color(0xFF244740),
            valueColor: const AlwaysStoppedAnimation(Color(0xFF19E5C2)),
          ),
        ),
      ],
    );
  }

  Widget _timeBox(String text) {
    return Container(
      width: 80,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF244740),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _controlButton(
      String label,
      VoidCallback onPressed, {
        Color background = const Color(0xFF244740),
        Color textColor = Colors.white,
      }) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label, style: TextStyle(color: textColor, fontSize: 16)),
      ),
    );
  }
}