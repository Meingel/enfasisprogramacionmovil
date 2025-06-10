import 'package:flutter/material.dart'; // Importamos el paquete fundamental de Flutter para construir interfaces de usuario.
import 'active_timer_screen.dart'; // Importamos la pantalla del temporizador activo, a la que podemos regresar.

class CycleNotificationScreen extends StatelessWidget { // Definimos la clase `CycleNotificationScreen`, un widget sin estado mutable que muestra una notificación.
  const CycleNotificationScreen({Key? key}) : super(key: key); // Constructor de la clase `CycleNotificationScreen`.

  static const String routeName = '/cycle-notification'; // Definimos una constante estática `routeName` para identificar esta pantalla en la navegación.

  @override
  Widget build(BuildContext context) { // Construimos la interfaz de usuario de la pantalla de notificación de ciclo.
    return Scaffold( // Proporciona la estructura visual básica de la pantalla.
      // Establecemos el color de fondo oscuro de la pantalla.
      backgroundColor: const Color(0xFF12211F), // Usamos el color #12211F para el fondo.
      // No utilizamos un `AppBar` convencional; en su lugar, colocamos un botón de cierre directamente en el cuerpo.
      body: SafeArea( // Aseguramos que el contenido se muestre dentro de los límites seguros del dispositivo.
        child: Stack( // Usamos un `Stack` para superponer elementos (el botón de cerrar sobre el fondo y el panel de notificación).
          children: [
            // Botón de cerrar en la parte superior izquierda
            Positioned( // Posicionamos el botón de cerrar de forma absoluta.
              top: 16, // A 16 píxeles del borde superior.
              left: 16, // A 16 píxeles del borde izquierdo.
              child: IconButton( // Un botón de ícono para cerrar la pantalla.
                icon: const Icon(Icons.close, color: Colors.white, size: 28), // Ícono de cerrar en color blanco y tamaño 28.
                onPressed: () { // Acción al presionar el botón.
                  Navigator.pop(context); // Cerramos la pantalla actual.
                },
              ),
            ),

            // Centro vacío (sólo para oscurecer el fondo)
            // No agregamos contenido aquí; el panel de notificación se ubica en la parte inferior.

            // Panel de notificación en la parte inferior
            Align( // Alineamos el siguiente widget a la parte inferior central de la pantalla.
              alignment: Alignment.bottomCenter, // Alinear al centro inferior.
              child: Container( // Este contenedor simula el modal emergente o panel de notificación.
                decoration: BoxDecoration( // Decoración del contenedor.
                  color: const Color(0xFF19332E), // Establecemos el color de fondo del panel a #19332E.
                  borderRadius: const BorderRadius.only( // Definimos bordes redondeados solo en las esquinas superiores.
                    topLeft: Radius.circular(16), // Radio de 16 píxeles para la esquina superior izquierda.
                    topRight: Radius.circular(16), // Radio de 16 píxeles para la esquina superior derecha.
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32), // Relleno interno del panel (izquierda, arriba, derecha, abajo).
                child: Column( // Columna para organizar los elementos dentro del panel.
                  mainAxisSize: MainAxisSize.min, // El tamaño de la columna se ajusta al contenido mínimo.
                  children: [
                    // Línea decorativa superior del modal
                    Container( // Pequeña línea decorativa en la parte superior del panel, como un "mango".
                      width: 40, // Ancho de la línea.
                      height: 4, // Alto de la línea.
                      decoration: BoxDecoration( // Decoración de la línea.
                        color: Colors.grey.shade700, // Color gris oscuro.
                        borderRadius: BorderRadius.circular(2), // Bordes ligeramente redondeados.
                      ),
                    ),
                    const SizedBox(height: 16), // Espacio vertical.

                    // Título “Ciclo Completo”
                    const Text( // Texto del título principal.
                      'Ciclo Completo', // Mensaje del título.
                      style: TextStyle( // Estilo del texto.
                        color: Colors.white, // Color blanco.
                        fontSize: 20, // Tamaño de fuente.
                        fontWeight: FontWeight.bold, // Negrita.
                      ),
                    ),
                    const SizedBox(height: 8), // Espacio vertical.

                    // Mensaje descriptivo
                    const Text( // Texto descriptivo para el usuario.
                      'Has completado un ciclo. ¿Qué sigue?', // Pregunta al usuario sobre la próxima acción.
                      textAlign: TextAlign.center, // Alineación del texto al centro.
                      style: TextStyle( // Estilo del texto.
                        color: Colors.white70, // Color blanco con transparencia.
                        fontSize: 16, // Tamaño de fuente.
                      ),
                    ),
                    const SizedBox(height: 24), // Espacio vertical.

                    // Botones “Detener” y “Continuar”
                    Row( // Fila para organizar los dos botones de acción.
                      children: [
                        // Botón “Detener” (ancho flexible)
                        Expanded( // Permite que el botón ocupe todo el espacio disponible.
                          child: SizedBox( // Define un contenedor con una altura específica para el botón.
                            height: 48, // Altura del botón.
                            child: ElevatedButton( // Un botón elevado.
                              style: ElevatedButton.styleFrom( // Estilo del botón.
                                backgroundColor: const Color(0xFF244740), // Color de fondo del botón.
                                shape: RoundedRectangleBorder( // Forma del borde.
                                  borderRadius: BorderRadius.circular(8), // Bordes redondeados.
                                ),
                              ),
                              onPressed: () { // Acción al presionar el botón "Detener".
                                // Cierra esta pantalla y regresa a la pantalla de inicio (Home).
                                Navigator.popUntil(context, (route) { // Navega de vuelta hasta que la ruta cumpla una condición.
                                  // Busca la ruta con el nombre '/home' y navega hasta ella.
                                  return route.settings.name == '/home';
                                });
                              },
                              child: const Text( // Texto del botón.
                                'Detener', // Contenido del texto.
                                style: TextStyle( // Estilo del texto.
                                  color: Colors.white, // Color blanco.
                                  fontSize: 16, // Tamaño de fuente.
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16), // Espacio horizontal entre los botones.
                        // Botón “Continuar” (ancho flexible)
                        Expanded( // Permite que el botón ocupe todo el espacio disponible.
                          child: SizedBox( // Define un contenedor con una altura específica para el botón.
                            height: 48, // Altura del botón.
                            child: ElevatedButton( // Un botón elevado.
                              style: ElevatedButton.styleFrom( // Estilo del botón.
                                backgroundColor: const Color(0xFF19E5C2), // Color de fondo del botón (verde cian).
                                shape: RoundedRectangleBorder( // Forma del borde.
                                  borderRadius: BorderRadius.circular(8), // Bordes redondeados.
                                ),
                              ),
                              onPressed: () { // Acción al presionar el botón "Continuar".
                                Navigator.pop(context); // Cierra este modal (la pantalla actual de notificación).
                                Navigator.pushNamed( // Abre de nuevo la pantalla del temporizador activo.
                                  context,
                                  ActiveTimerScreen.routeName,
                                );
                              },
                              child: const Text( // Texto del botón.
                                'Continuar', // Contenido del texto.
                                style: TextStyle( // Estilo del texto.
                                  color: Color(0xFF12211F), // Color oscuro para contraste.
                                  fontSize: 16, // Tamaño de fuente.
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