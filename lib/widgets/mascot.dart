import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'mascot_painter.dart';

/// As expressões que o "Gênio do Campus" pode assumir.
enum MascotExpression {
  neutral,
  thinking,
  suspicious,
  confident,
  celebrating,
  sad,
}

/// O mascote do app: o "Gênio do Campus", desenhado inteiramente em código.
///
/// O widget cuida das animações (flutuação contínua, balanço da borla e
/// piscadas) e delega o desenho de fato ao [MascotPainter].
class Mascot extends StatefulWidget {
  final MascotExpression expression;

  /// Altura do mascote. A largura é proporcional (altura / 1.3).
  final double size;

  const Mascot({super.key, required this.expression, this.size = 220});

  @override
  State<Mascot> createState() => _MascotState();
}

class _MascotState extends State<Mascot> with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _blinkController;
  Timer? _blinkTimer;

  @override
  void initState() {
    super.initState();

    // Flutuação suave de sobe-e-desce, em loop infinito.
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Piscada: rápida, repetida a cada poucos segundos.
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _scheduleBlink();
  }

  void _scheduleBlink() {
    // Intervalo pseudoaleatório entre 3 e 5 segundos.
    final delay = 3000 + math.Random().nextInt(2000);
    _blinkTimer = Timer(Duration(milliseconds: delay), () {
      if (!mounted) return;
      _blinkController.forward().then((_) {
        if (mounted) _blinkController.reverse();
      });
      _scheduleBlink();
    });
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _floatController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.size / 1.3;
    return SizedBox(
      width: width,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_floatController, _blinkController]),
        builder: (context, _) {
          // ±8px no eixo Y, suavizados por uma curva senoidal.
          final t = Curves.easeInOut.transform(_floatController.value);
          final offsetY = (t - 0.5) * 16;
          final tilt = math.sin(_floatController.value * math.pi * 2) * 0.10;

          return Transform.translate(
            offset: Offset(0, offsetY),
            child: CustomPaint(
              painter: MascotPainter(
                expression: widget.expression,
                blink: _blinkController.value,
                tasselTilt: tilt,
                floatPhase: _floatController.value,
              ),
              size: Size(width, widget.size),
            ),
          );
        },
      ),
    );
  }
}
