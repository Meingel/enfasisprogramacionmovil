import 'package:flutter/material.dart';
import 'active_timer_screen.dart';

class CycleNotificationScreen extends StatelessWidget {
  const CycleNotificationScreen({Key? key}) : super(key: key);

  static const String routeName = '/cycle-notification';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fondo oscuro de la pantalla (mismo #12211F)
      backgroundColor: const Color(0xFF12211F),
      // No AppBar convencional; usaremos un close en la esquina superior izquierda
      body: SafeArea(
        child: Stack(
          children: [
            // Botón de cerrar en la parte superior izquierda
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),

            // Centro vacío (sólo para oscurecer el fondo)
            // No agregamos contenido arriba; el panel de notificación está abajo

            // Panel de notificación en la parte inferior
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                // Este container simula el modal emergente
                decoration: BoxDecoration(
                  color: const Color(0xFF19332E), // panel con color #19332E
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Línea decorativa superior del modal
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Título “Ciclo Completo”
                    const Text(
                      'Ciclo Completo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Mensaje descriptivo
                    const Text(
                      'Has completado un ciclo. ¿Qué sigue?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Botones “Detener” y “Continuar”
                    Row(
                      children: [
                        // Botón “Detener” (ancho flexible)
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF244740),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                // Cierra esta pantalla y regresa a Home
                                Navigator.popUntil(context, (route) {
                                  // Busca la ruta '/home' y navega hasta allí
                                  return route.settings.name == '/home';
                                });
                              },
                              child: const Text(
                                'Detener',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Botón “Continuar” (ancho flexible)
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF19E5C2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                // Cierra este modal y abre de nuevo ActiveTimerScreen
                                Navigator.pop(context); // cierra este modal
                                Navigator.pushNamed(
                                  context,
                                  ActiveTimerScreen.routeName,
                                );
                              },
                              child: const Text(
                                'Continuar',
                                style: TextStyle(
                                  color: Color(0xFF12211F),
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}