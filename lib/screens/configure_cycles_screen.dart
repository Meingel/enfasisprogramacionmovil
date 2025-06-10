import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

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

  // SharedPreferences keys (all values stored in seconds)
  static const String _keyWork    = 'work_duration';
  static const String _keyShort   = 'short_break_duration';
  static const String _keyLong    = 'long_break_duration';
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
    final int workSec   = prefs.getInt(_keyWork)  ?? 1500;  // default 25m
    final int shortSec  = prefs.getInt(_keyShort) ?? 300;   // default 5m
    final int longSec   = prefs.getInt(_keyLong)  ?? 900;   // default 15m
    final bool useLong  = prefs.getBool(_keyUseLong) ?? false;

    _workController.text       = _formatDuration(workSec);
    _shortBreakController.text = _formatDuration(shortSec);
    _longBreakController.text  = _formatDuration(longSec);
    setState(() => _useLongCycles = useLong);
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final int workSec  = _parseDuration(_workController.text);
    final int shortSec = _parseDuration(_shortBreakController.text);
    final int longSec  = _parseDuration(_longBreakController.text);

    await prefs.setInt(_keyWork, workSec);
    await prefs.setInt(_keyShort, shortSec);
    await prefs.setInt(_keyLong, longSec);
    await prefs.setBool(_keyUseLong, _useLongCycles);
  }

  void _onSavePressed() async {
    await _savePreferences();
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
                style: TextStyle(color: Colors.white70, fontSize: 14),
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
                    style: TextStyle(fontSize: 16, color: Color(0xFF12211F)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper: format seconds → HH:MM:SS
  String _formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    final hStr = hours.toString().padLeft(2, '0');
    final mStr = minutes.toString().padLeft(2, '0');
    final sStr = seconds.toString().padLeft(2, '0');
    return '$hStr:$mStr:$sStr';
  }

  // Helper: parse HH:MM:SS → seconds
  int _parseDuration(String input) {
    try {
      final parts = input.split(':');
      if (parts.length != 3) return 0;
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final s = int.parse(parts[2]);
      return h * 3600 + m * 60 + s;
    } catch (_) {
      return 0;
    }
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.datetime,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d:]')),
          ],
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF244740),
            hintText: 'HH:MM:SS',
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12211F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF19332E),
        title: const Text('Configurar Ciclos',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
          const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildField(
                label: 'Duración Trabajo (HH:MM:SS)',
                controller: _workController,
              ),
              _buildField(
                label: 'Descanso Corto (HH:MM:SS)',
                controller: _shortBreakController,
              ),
              _buildField(
                label: 'Descanso Largo (HH:MM:SS)',
                controller: _longBreakController,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Ciclos largos cada 4 pomodoros',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  Switch(
                    activeColor: const Color(0xFF19E5C2),
                    inactiveTrackColor: Colors.grey.shade700,
                    value: _useLongCycles,
                    onChanged: (v) => setState(() => _useLongCycles = v),
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
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _onSavePressed,
                  child: const Text(
                    'Guardar',
                    style: TextStyle(fontSize: 18, color: Color(0xFF12211F)),
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
