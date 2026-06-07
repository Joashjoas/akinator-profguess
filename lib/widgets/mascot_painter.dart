import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'mascot.dart';

/// Desenha o "Gênio do Campus" usando apenas primitivas vetoriais.
///
/// Todas as coordenadas são relativas ao tamanho do canvas, então o mascote
/// escala sem distorção em qualquer tela. A expressão muda olhos, sobrancelhas,
/// boca e a pose dos braços.
class MascotPainter extends CustomPainter {
  final MascotExpression expression;

  /// 0 = olhos abertos, 1 = olhos fechados (piscada).
  final double blink;

  /// Inclinação atual da borla do capelo, em radianos.
  final double tasselTilt;

  /// Fase da animação de flutuação (0..1), usada nos confetes da comemoração.
  final double floatPhase;

  MascotPainter({
    required this.expression,
    required this.blink,
    required this.tasselTilt,
    required this.floatPhase,
  });

  // Cores (espelham a paleta do tema).
  static const _bodyTop = Color(0xFF7C73F0);
  static const _bodyBottom = Color(0xFF4F46E5);
  static const _smoke = Color(0xFFA5B4FC);
  static const _skin = Color(0xFFF4C58A);
  static const _ink = Color(0xFF1F2937);
  static const _gold = Color(0xFFFBBF24);
  static const _goatee = Color(0xFF312E81);
  static const _mouth = Color(0xFF7C2D12);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    _drawSmoke(canvas, w, h, cx);
    _drawBody(canvas, w, h, cx);
    _drawArms(canvas, w, h, cx);

    final headCenter = Offset(cx, h * 0.34);
    final headRadius = w * 0.30;
    _drawHead(canvas, headCenter, headRadius);
    _drawFace(canvas, headCenter, headRadius);
    _drawCap(canvas, headCenter, headRadius, w);

    if (expression == MascotExpression.celebrating) {
      _drawConfetti(canvas, w, h);
    }
  }

  void _drawSmoke(Canvas canvas, double w, double h, double cx) {
    final paint = Paint();
    final rows = <List<double>>[
      [h * 0.86, w * 0.34, 0.6],
      [h * 0.92, w * 0.24, 0.45],
      [h * 0.97, w * 0.15, 0.32],
    ];
    for (final r in rows) {
      paint.color = _smoke.withValues(alpha: r[2]);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, r[0]),
          width: r[1],
          height: r[1] * 0.45,
        ),
        paint,
      );
    }
  }

  void _drawBody(Canvas canvas, double w, double h, double cx) {
    // Corpo em gota invertida: largo em cima (sob a cabeça) e afunilando para
    // a fumaça embaixo.
    final top = h * 0.42;
    final bottom = h * 0.84;
    final halfWidth = w * 0.34;

    final path = Path()
      ..moveTo(cx, top)
      ..cubicTo(
        cx + halfWidth, top,
        cx + halfWidth * 0.9, bottom - h * 0.10,
        cx, bottom,
      )
      ..cubicTo(
        cx - halfWidth * 0.9, bottom - h * 0.10,
        cx - halfWidth, top,
        cx, top,
      )
      ..close();

    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_bodyTop, _bodyBottom],
      ).createShader(Rect.fromLTWH(cx - halfWidth, top, halfWidth * 2, bottom - top));
    canvas.drawPath(path, paint);
  }

  void _drawArms(Canvas canvas, double w, double h, double cx) {
    final paint = Paint()
      ..color = _bodyBottom
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.07
      ..strokeCap = StrokeCap.round;

    final shoulderY = h * 0.52;
    final left = Offset(cx - w * 0.26, shoulderY);
    final right = Offset(cx + w * 0.26, shoulderY);

    switch (expression) {
      case MascotExpression.celebrating:
        // Dois braços para cima.
        _arm(canvas, paint, left, Offset(cx - w * 0.40, h * 0.34));
        _arm(canvas, paint, right, Offset(cx + w * 0.40, h * 0.34));
        break;
      case MascotExpression.confident:
        // Um braço apontando para a frente.
        _arm(canvas, paint, right, Offset(cx + w * 0.46, shoulderY + h * 0.02));
        _arm(canvas, paint, left, Offset(cx - w * 0.30, h * 0.62));
        break;
      case MascotExpression.thinking:
        // Mão no queixo.
        _arm(canvas, paint, right, Offset(cx + w * 0.10, h * 0.40));
        _arm(canvas, paint, left, Offset(cx - w * 0.34, h * 0.62));
        break;
      case MascotExpression.suspicious:
        // Braços cruzados à frente.
        _arm(canvas, paint, left, Offset(cx + w * 0.12, h * 0.58));
        _arm(canvas, paint, right, Offset(cx - w * 0.12, h * 0.58));
        break;
      case MascotExpression.sad:
        // Braços caídos.
        _arm(canvas, paint, left, Offset(cx - w * 0.30, h * 0.70));
        _arm(canvas, paint, right, Offset(cx + w * 0.30, h * 0.70));
        break;
      case MascotExpression.neutral:
        // Um braço dobrado à frente, outro relaxado.
        _arm(canvas, paint, left, Offset(cx - w * 0.10, h * 0.58));
        _arm(canvas, paint, right, Offset(cx + w * 0.30, h * 0.64));
        break;
    }
  }

  void _arm(Canvas canvas, Paint paint, Offset from, Offset to) {
    final mid = Offset(
      (from.dx + to.dx) / 2 + (to.dx - from.dx) * 0.1,
      (from.dy + to.dy) / 2 - 6,
    );
    final path = Path()
      ..moveTo(from.dx, from.dy)
      ..quadraticBezierTo(mid.dx, mid.dy, to.dx, to.dy);
    canvas.drawPath(path, paint);
    // Mãozinha na ponta.
    canvas.drawCircle(to, paint.strokeWidth * 0.55,
        Paint()..color = _skin);
  }

  void _drawHead(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(center, radius, Paint()..color = _skin);
    // Brincos dourados nas laterais.
    final earPaint = Paint()..color = _gold;
    canvas.drawCircle(
        Offset(center.dx - radius, center.dy + radius * 0.1), radius * 0.10, earPaint);
    canvas.drawCircle(
        Offset(center.dx + radius, center.dy + radius * 0.1), radius * 0.10, earPaint);
  }

  void _drawFace(Canvas canvas, Offset c, double r) {
    final eyeY = c.dy - r * 0.05;
    final eyeDx = r * 0.42;
    final eyeRadius = r * 0.22;

    _drawEye(canvas, Offset(c.dx - eyeDx, eyeY), eyeRadius);
    _drawEye(canvas, Offset(c.dx + eyeDx, eyeY), eyeRadius);

    _drawEyebrows(canvas, c, r, eyeY, eyeDx);
    _drawMouth(canvas, c, r);
    _drawGoatee(canvas, c, r);
  }

  void _drawEye(Canvas canvas, Offset center, double radius) {
    // "celebrating" usa olhos fechados felizes em forma de arco (∩).
    if (expression == MascotExpression.celebrating) {
      final paint = Paint()
        ..color = _ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.30
        ..strokeCap = StrokeCap.round;
      final rect = Rect.fromCenter(
          center: center.translate(0, radius * 0.1),
          width: radius * 1.6,
          height: radius * 1.4);
      canvas.drawArc(rect, math.pi, math.pi, false, paint);
      return;
    }

    // Branco do olho (mais achatado quando desconfiado), com piscada.
    final squint = expression == MascotExpression.suspicious ? 0.55 : 1.0;
    final openness = (1 - blink) * squint;
    final whiteRect = Rect.fromCenter(
      center: center,
      width: radius * 1.7,
      height: radius * 1.7 * openness.clamp(0.05, 1.0),
    );
    canvas.drawOval(whiteRect, Paint()..color = Colors.white);

    if (openness < 0.12) return; // praticamente fechado: não desenha pupila

    // Direção do olhar conforme a expressão.
    Offset look;
    switch (expression) {
      case MascotExpression.thinking:
        look = Offset(radius * 0.35, -radius * 0.35); // cima-direita
        break;
      case MascotExpression.sad:
        look = Offset(0, radius * 0.35); // caído
        break;
      default:
        look = Offset.zero;
    }

    final pupil = center + look;
    final pupilRadius = radius * (expression == MascotExpression.sad ? 0.55 : 0.45);
    canvas.drawCircle(pupil, pupilRadius, Paint()..color = _ink);

    // Brilho do olhar confiante.
    if (expression == MascotExpression.confident) {
      canvas.drawCircle(pupil.translate(pupilRadius * 0.4, -pupilRadius * 0.4),
          pupilRadius * 0.35, Paint()..color = Colors.white);
    }

    // Lágrima na tristeza (só no olho direito).
    if (expression == MascotExpression.sad && center.dx > whiteRect.center.dx) {
      final tear = Paint()..color = const Color(0xFF60A5FA);
      canvas.drawCircle(center.translate(radius * 0.3, radius * 1.1),
          radius * 0.28, tear);
    }
  }

  void _drawEyebrows(
      Canvas canvas, Offset c, double r, double eyeY, double eyeDx) {
    final paint = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.10
      ..strokeCap = StrokeCap.round;
    final browY = eyeY - r * 0.42;
    final len = r * 0.34;

    final left = c.dx - eyeDx;
    final right = c.dx + eyeDx;

    switch (expression) {
      case MascotExpression.suspicious:
        // Ambas baixas e inclinadas para dentro.
        canvas.drawLine(Offset(left - len, browY + r * 0.05),
            Offset(left + len, browY + r * 0.20), paint);
        canvas.drawLine(Offset(right - len, browY + r * 0.20),
            Offset(right + len, browY + r * 0.05), paint);
        break;
      case MascotExpression.thinking:
        // Uma erguida.
        canvas.drawLine(Offset(left - len, browY),
            Offset(left + len, browY), paint);
        canvas.drawLine(Offset(right - len, browY - r * 0.15),
            Offset(right + len, browY - r * 0.22), paint);
        break;
      case MascotExpression.confident:
      case MascotExpression.celebrating:
        // Erguidas e simétricas.
        canvas.drawLine(Offset(left - len, browY - r * 0.10),
            Offset(left + len, browY - r * 0.18), paint);
        canvas.drawLine(Offset(right - len, browY - r * 0.18),
            Offset(right + len, browY - r * 0.10), paint);
        break;
      case MascotExpression.sad:
        // Inclinadas para cima no centro (cantos internos altos).
        canvas.drawLine(Offset(left - len, browY + r * 0.12),
            Offset(left + len, browY - r * 0.10), paint);
        canvas.drawLine(Offset(right - len, browY - r * 0.10),
            Offset(right + len, browY + r * 0.12), paint);
        break;
      case MascotExpression.neutral:
        canvas.drawLine(Offset(left - len, browY), Offset(left + len, browY), paint);
        canvas.drawLine(Offset(right - len, browY), Offset(right + len, browY), paint);
        break;
    }
  }

  void _drawMouth(Canvas canvas, Offset c, double r) {
    final paint = Paint()
      ..color = _mouth
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.10
      ..strokeCap = StrokeCap.round;
    final mouthY = c.dy + r * 0.50;
    final width = r * 0.9;

    Rect arc(double height) => Rect.fromCenter(
        center: Offset(c.dx, mouthY), width: width, height: height);

    switch (expression) {
      case MascotExpression.celebrating:
        // Sorriso máximo, preenchido.
        final fill = Paint()..color = _mouth;
        final rect = arc(r * 0.9);
        canvas.drawArc(rect, 0, math.pi, false, fill);
        break;
      case MascotExpression.confident:
        canvas.drawArc(arc(r * 0.7), 0.1, math.pi - 0.2, false, paint);
        break;
      case MascotExpression.neutral:
        canvas.drawArc(arc(r * 0.35), 0.2, math.pi - 0.4, false, paint);
        break;
      case MascotExpression.suspicious:
        // Sorrisinho de canto (linha levemente curva e deslocada).
        final path = Path()
          ..moveTo(c.dx - width * 0.3, mouthY)
          ..quadraticBezierTo(
              c.dx + width * 0.1, mouthY + r * 0.08,
              c.dx + width * 0.45, mouthY - r * 0.12);
        canvas.drawPath(path, paint);
        break;
      case MascotExpression.thinking:
        // Boca pequena torcida para um lado.
        final path = Path()
          ..moveTo(c.dx - width * 0.2, mouthY)
          ..quadraticBezierTo(
              c.dx, mouthY - r * 0.05, c.dx + width * 0.2, mouthY + r * 0.04);
        canvas.drawPath(path, paint);
        break;
      case MascotExpression.sad:
        // Arco invertido.
        canvas.drawArc(
            arc(r * 0.5).translate(0, r * 0.2), math.pi, math.pi, false, paint);
        break;
    }
  }

  void _drawGoatee(Canvas canvas, Offset c, double r) {
    final path = Path()
      ..moveTo(c.dx - r * 0.18, c.dy + r * 0.78)
      ..quadraticBezierTo(
          c.dx, c.dy + r * 1.10, c.dx + r * 0.18, c.dy + r * 0.78)
      ..quadraticBezierTo(c.dx, c.dy + r * 0.92, c.dx - r * 0.18, c.dy + r * 0.78)
      ..close();
    canvas.drawPath(path, Paint()..color = _goatee);
  }

  void _drawCap(Canvas canvas, Offset head, double headRadius, double w) {
    final capY = head.dy - headRadius * 0.85;

    // Faixa que apoia o capelo na cabeça.
    final band = Rect.fromCenter(
        center: Offset(head.dx, capY + headRadius * 0.12),
        width: headRadius * 1.5,
        height: headRadius * 0.30);
    canvas.drawRRect(
        RRect.fromRectAndRadius(band, Radius.circular(headRadius * 0.1)),
        Paint()..color = _ink);

    // Tábua do capelo: losango (quadrado rotacionado e achatado).
    final boardCenter = Offset(head.dx, capY);
    final half = headRadius * 1.15;
    final board = Path()
      ..moveTo(boardCenter.dx, boardCenter.dy - headRadius * 0.28)
      ..lineTo(boardCenter.dx + half, boardCenter.dy)
      ..lineTo(boardCenter.dx, boardCenter.dy + headRadius * 0.28)
      ..lineTo(boardCenter.dx - half, boardCenter.dy)
      ..close();
    canvas.drawPath(board, Paint()..color = _ink);
    canvas.drawPath(
        board,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.12)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);

    // Botão central.
    canvas.drawCircle(boardCenter, headRadius * 0.07, Paint()..color = _gold);

    // Borla: fio que sai do centro e balança, com a bola dourada na ponta.
    final length = headRadius * 1.0;
    final end = Offset(
      boardCenter.dx + math.sin(tasselTilt) * length,
      boardCenter.dy + math.cos(tasselTilt) * length,
    );
    canvas.drawLine(
        boardCenter,
        end,
        Paint()
          ..color = _gold
          ..strokeWidth = headRadius * 0.05
          ..strokeCap = StrokeCap.round);
    canvas.drawCircle(end, headRadius * 0.12, Paint()..color = _gold);
  }

  void _drawConfetti(Canvas canvas, double w, double h) {
    final colors = [_gold, _bodyTop, const Color(0xFFEF4444), const Color(0xFF34D399)];
    for (var i = 0; i < 12; i++) {
      // Posições determinísticas (variam com a fase para dar movimento).
      final x = (w * ((i * 37) % 100) / 100);
      final base = ((i * 53) % 100) / 100;
      final y = ((base + floatPhase) % 1.0) * h * 0.6;
      final paint = Paint()..color = colors[i % colors.length];
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(i * 0.7 + floatPhase * 6);
      canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: w * 0.05, height: w * 0.03),
          paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant MascotPainter old) {
    return old.expression != expression ||
        old.blink != blink ||
        old.tasselTilt != tasselTilt ||
        old.floatPhase != floatPhase;
  }
}
