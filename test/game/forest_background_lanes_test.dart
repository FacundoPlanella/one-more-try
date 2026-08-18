import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:one_more_try/core/constants/game_constants.dart';
import 'package:one_more_try/game/forest_background_lanes.dart';

/// Verifica contra el PNG real que los carriles del juego caen sobre los
/// senderos de tierra del fondo, no sobre los arbustos que los separan.
void main() {
  late ui.Image image;
  late ByteData pixels;

  setUpAll(() async {
    final bytes = await File(
      'assets/images/backgrounds/forest_bg.png',
    ).readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    image = (await codec.getNextFrame()).image;
    pixels = (await image.toByteData())!;
  });

  /// true si el píxel es tierra: cálido, con el rojo bien por encima del azul.
  /// Los arbustos y el pasto que separan los senderos son verdes (g > r).
  bool isDirt(int x, int y) {
    final offset = (y * image.width + x) * 4;
    if (offset < 0 || offset + 3 >= pixels.lengthInBytes) return false;
    final r = pixels.getUint8(offset);
    final g = pixels.getUint8(offset + 1);
    final b = pixels.getUint8(offset + 2);
    return r > g && g >= b && (r - b) > 25 && r > 80;
  }

  /// Fracción de píxeles de tierra en un parche centrado en (x, y). Se mide un
  /// parche y no un píxel porque sobre la tierra hay piedras y flores
  /// dibujadas: un único píxel sería una prueba frágil.
  double dirtRatioAround(double x, double y, {int radius = 12}) {
    var dirt = 0;
    var total = 0;
    for (var dy = -radius; dy <= radius; dy += 3) {
      for (var dx = -radius; dx <= radius; dx += 3) {
        total++;
        if (isDirt((x + dx).round(), (y + dy).round())) dirt++;
      }
    }
    return dirt / total;
  }

  /// Los tres centros de carril, en píxeles de la imagen, a la altura del
  /// jugador, para un canvas de juego de [canvas].
  ({List<double> centersX, double y}) laneCentersInImage(ui.Size canvas) {
    final playerY = canvas.height * GameConstants.playerYFactor;
    final geometry = ForestBackgroundLanes.resolve(
      imageWidth: image.width.toDouble(),
      imageHeight: image.height.toDouble(),
      canvas: canvas,
      playerY: playerY,
      laneCount: GameConstants.laneCount,
    );
    final src = ForestBackgroundLanes.coverSrcRect(
      srcWidth: image.width.toDouble(),
      srcHeight: image.height.toDouble(),
      dst: canvas,
    );
    final scale = canvas.width / src.width;
    return (
      centersX: [
        for (var lane = 0; lane < GameConstants.laneCount; lane++)
          (geometry.originX + (lane + 0.5) * geometry.laneWidth) / scale +
              src.left,
      ],
      y: src.top + (playerY / canvas.height) * src.height,
    );
  }

  // Alto útil aproximado del área jugable: el viewport menos el HUD.
  const canvases = <String, ui.Size>{
    'celular 360x640': ui.Size(360, 590),
    'celular alargado 393x873': ui.Size(393, 800),
    'tablet 800x1280': ui.Size(800, 1130),
    'tablet grande 1024x1366': ui.Size(1024, 1200),
    'viewport físico 2048x2732': ui.Size(2048, 2450),
  };

  canvases.forEach((name, canvas) {
    test('$name: los tres carriles caen sobre la tierra', () {
      final lanes = laneCentersInImage(canvas);
      for (var lane = 0; lane < lanes.centersX.length; lane++) {
        final ratio = dirtRatioAround(lanes.centersX[lane], lanes.y);
        expect(
          ratio,
          greaterThan(0.5),
          reason:
              'carril $lane en x=${lanes.centersX[lane].toStringAsFixed(1)}, '
              'y=${lanes.y.toStringAsFixed(1)} cae sobre vegetación '
              '(tierra=${(ratio * 100).round()}%)',
        );
      }
    });
  });

  test('el camino se angosta hacia el horizonte', () {
    // La convergencia deja de ser un número calibrado a ojo: sale de cuánto se
    // angosta el sendero entre el borde superior visible y la fila del jugador.
    final geometry = ForestBackgroundLanes.resolve(
      imageWidth: image.width.toDouble(),
      imageHeight: image.height.toDouble(),
      canvas: const ui.Size(1024, 1200),
      playerY: 1200 * GameConstants.playerYFactor,
      laneCount: GameConstants.laneCount,
    );
    expect(geometry.horizonSpread, inInclusiveRange(0.4, 0.95));
    expect(geometry.laneWidth, greaterThan(1024 * 0.24));
    expect(geometry.laneWidth, lessThan(1024 * 0.34));
  });
}
