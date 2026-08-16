import 'package:flutter/material.dart';

/// Paleta de marca — aventura de selva: madera tallada, oro y hoja,
/// a tono con el arte pixel de fondo/criaturas y los carteles de madera
/// de la UI (boton_*.png, contenedor_contador.png).
///
/// `Lane` y `Obstacle` son exclusivos del canvas de Flame (no los usan
/// las pantallas de menú) y se dejan intactos a propósito.
class AppColors {
  AppColors._();

  static const Color darkBg0 = Color(0xFF13160F);
  static const Color darkBg1 = Color(0xFF241A12);
  static const Color darkText0 = Color(0xFFF5E9D3);
  static const Color darkText1 = Color(0xFFB8A587);
  static const Color darkAccent = Color(0xFFE8B54A);
  static const Color darkLane = Color(0xFF1F2933);
  static const Color darkDanger = Color(0xFFE0553A);
  static const Color darkSuccess = Color(0xFF7CC24B);
  static const Color darkObstacle = Color(0xFF2A3441);
}
