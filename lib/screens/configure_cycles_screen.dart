import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigureCyclesScreen extends StatefulWidget {
  const ConfigureCyclesScreen({Key? key}) : super(key: key);

  static const String routeName = '/configure-cycles';

  @override
  State<ConfigureCyclesScreen> createState() => _ConfigureCyclesScreenState();
}

class _ConfigureCyclesScreenState extends State<ConfigureCyclesScreen> {
  final TextEditingController _workController = TextEditingController();
  final TextEditingController _shortBreakController = TextEditingController();
  final TextEditingController _longBreakController = TextEditingController();

  bool _useLongCycles = false;

  // Keys para SharedPreferences
  static const String _keyWork = 'work_duration';
  static const String _keyShort = 'short_break_duration';
  static const String _keyLong = 'long_break_duration';
  static const String _keyUseLong = 'use_long_cycles';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  void dispose() {
    _workController.dispose();
    _shortBreakController.dispose();
    _longBreakController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final int work = prefs.getInt(_keyWork) ?? 25;    // minutos
    final int shortB = prefs.getInt(_keyShort) ?? 5;  // minutos
    final int longB = prefs.getInt(_keyLong) ?? 15;   // minutos
    final bool useLong = prefs.getBool(_keyUseLong) ?? false;

    _workController.text = work.toString();
    _shortBreakController.text = shortB.toString();
    _longBreakController.text = longB.toString();
    setState(() {
      _useLongCycles = useLong;
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final int work = int.tryParse(_workController.text) ?? 0;
    final int shortB = int.tryParse(_shortBreakController.text) ?? 0;
    final int longB = int.tryParse(_longBreakController.text) ?? 0;

    await prefs.setInt(_keyWork, work);
    await prefs.setInt(_keyShort, shortB);
    await prefs.setInt(_keyLong, longB);
    await prefs.setBool(_keyUseLong, _useLongCycles);
  }

  void _onSavePressed() async {
    await _savePreferences();

    // Diálogo personalizado con colores de la app
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF19332E), // mismo color que el AppBar
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '¡Configuración guardada!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Ya puedes iniciar una sesión de OnFocus.',
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
                    backgroundColor: const Color(0xFF19E5C2), // botón principal
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop(); // Cerrar diálogo
                    Navigator.of(context).pop(); // Volver a Home
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF12211F), // texto oscuro sobre botón claro
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
          'Configurar Ciclos',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Duración Trabajo (minutos)',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _workController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF244740),
                  hintText: 'Ej. 25',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Descanso Corto (minutos)',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _shortBreakController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF244740),
                  hintText: 'Ej. 5',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Descanso Largo (minutos)',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _longBreakController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF244740),
                  hintText: 'Ej. 15',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ciclos largos cada 4 pomodoros',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Switch(
                    activeColor: const Color(0xFF19E5C2),
                    inactiveTrackColor: Colors.grey.shade700,
                    value: _useLongCycles,
                    onChanged: (bool newValue) {
                      setState(() {
                        _useLongCycles = newValue;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF19E5C2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _onSavePressed,
                  child: const Text(
                    'Guardar',
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