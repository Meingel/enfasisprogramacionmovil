import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActiveTimerScreen extends StatefulWidget {
  const ActiveTimerScreen({Key? key}) : super(key: key);

  static const String routeName = '/active-timer';

  @override
  State<ActiveTimerScreen> createState() => _ActiveTimerScreenState();
}

class _ActiveTimerScreenState extends State<ActiveTimerScreen> {
  bool _isRunning = false;
  Timer? _timer;

  // --------------------------------------------------------------------------------
  // Duraciones en segundos (serán leídas de SharedPreferences en minutos y convertidas)
  int _workDuration = 0;
  int _shortBreakDuration = 0;
  int _longBreakDuration = 0;
  // --------------------------------------------------------------------------------

  int _remainingSeconds = 0;
  int _currentPhase = 0; // 0=Trabajo, 1=Descanso Corto, 2=Descanso Largo
  int _completedCycles = 0;

  final TextEditingController _taskNameController = TextEditingController();
  static const String _keyTaskName = 'task_name';

  // Llaves para SharedPreferences
  static const String _keyWork = 'work_duration';
  static const String _keyShort = 'short_break_duration';
  static const String _keyLong = 'long_break_duration';
  static const String _keyUseLong = 'use_long_cycles';

  @override
  void initState() {
    super.initState();
    _loadPreferencesAndInitialize();
    _loadTaskName();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _taskNameController.dispose();
    super.dispose();
  }

  // Cargar tareas guardadas
  Future<void> _loadTaskName() async {
    final prefs = await SharedPreferences.getInstance();
    final storedName = prefs.getString(_keyTaskName) ?? 'Nombre Tarea';
    _taskNameController.text = storedName;
  }

  Future<void> _saveTaskName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTaskName, name);
  }

  // Leer las duraciones configuradas, convertir a segundos y asignar estados iniciales
  Future<void> _loadPreferencesAndInitialize() async {
    final prefs = await SharedPreferences.getInstance();

    final int workMin = prefs.getInt(_keyWork) ?? 25;     // en minutos
    final int shortMin = prefs.getInt(_keyShort) ?? 5;    // en minutos
    final int longMin = prefs.getInt(_keyLong) ?? 15;     // en minutos

    setState(() {
      _workDuration = workMin * 60;           // convertir a segundos
      _shortBreakDuration = shortMin * 60;     // convertir a segundos
      _longBreakDuration = longMin * 60;       // convertir a segundos

      _currentPhase = 0;
      _remainingSeconds = _workDuration;
    });
  }

  void _toggleTimer() {
    if (!_isRunning) {
      // Al iniciar, guardamos el nombre de la tarea actual
      _saveTaskName(_taskNameController.text.trim());
    }

    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _timer?.cancel();
            _isRunning = false;
            _completedCycles++;

            if (_currentPhase == 0) {
              // Tras trabajo, decidir descanso
              if (_completedCycles % 4 == 0) {
                _currentPhase = 2;
                _remainingSeconds = _longBreakDuration;
              } else {
                _currentPhase = 1;
                _remainingSeconds = _shortBreakDuration;
              }
            } else {
              // Tras descanso, volver a trabajo
              _currentPhase = 0;
              _remainingSeconds = _workDuration;
            }

            // Notificar con SnackBar el cambio de fase
            final phaseName = (_currentPhase == 0)
                ? 'Trabajo'
                : (_currentPhase == 1 ? 'Descanso Corto' : 'Descanso Largo');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Ciclo completo. Inicia $phaseName.'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        });
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      if (_currentPhase == 0) {
        _remainingSeconds = _workDuration;
      } else if (_currentPhase == 1) {
        _remainingSeconds = _shortBreakDuration;
      } else {
        _remainingSeconds = _longBreakDuration;
      }
    });
  }

  void _stopSession() {
    _timer?.cancel();
    Navigator.pop(context);
  }

  String get _minutesStr {
    final minutes = _remainingSeconds ~/ 60;
    return minutes.toString().padLeft(2, '0');
  }

  String get _secondsStr {
    final seconds = _remainingSeconds % 60;
    return seconds.toString().padLeft(2, '0');
  }

  double get _linearProgress {
    int phaseDuration = (_currentPhase == 0)
        ? _workDuration
        : (_currentPhase == 1 ? _shortBreakDuration : _longBreakDuration);
    if (phaseDuration == 0) return 0;
    return (_remainingSeconds / phaseDuration);
  }

  @override
  Widget build(BuildContext context) {
    String phaseTitle = (_currentPhase == 0)
        ? 'Pomodoro'
        : (_currentPhase == 1 ? 'Descanso Corto' : 'Descanso Largo');

    return Scaffold(
      backgroundColor: const Color(0xFF12211F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF19332E),
        title: Text(
          phaseTitle,
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: _stopSession,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --------------------------------------------------
              // TextField para editar “Nombre Tarea”
              TextField(
                controller: _taskNameController,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF244740),
                  hintText: 'Nombre Tarea',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
              ),
              const SizedBox(height: 24),
              // --------------------------------------------------

              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _linearProgress,
                  minHeight: 8,
                  backgroundColor: const Color(0xFF244740),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF19E5C2)),
                ),
              ),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 100,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF244740),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        _minutesStr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF244740),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        _secondsStr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF244740),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _toggleTimer,
                  child: Text(
                    _isRunning ? 'Pausar' : 'Reanudar',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF244740),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _resetTimer,
                  child: const Text(
                    'Reiniciar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF19E5C2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _stopSession,
                  child: const Text(
                    'Detener',
                    style: TextStyle(
                      color: Color(0xFF12211F),
                      fontSize: 16,
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