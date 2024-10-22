import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class SpoilerMaskImage extends StatelessWidget {
  final Widget child;

  SpoilerMaskImage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      print(constraints);
      return Stack(children: [
        child,
        SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: SpoilerMask(),
        )
      ]);
    });
  }
}

class SpoilerMask extends StatefulWidget {
  const SpoilerMask({super.key});

  @override
  State<SpoilerMask> createState() => _SpoilerMaskState();
}

class _SpoilerMaskState extends State<SpoilerMask>
    with SingleTickerProviderStateMixin {
  Offset? _tapPosition;
  double _waveRadius = 10.0;
  late AnimationController _controller =
      AnimationController(vsync: this, duration: Duration(milliseconds: 300))
        ..addListener(() {
          setState(() {
            // 动态设置波浪的半径
            _waveRadius = _controller.value * _maxRadius;
          });
        })
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _tapPosition = null;
          }
        });

  double _maxRadius = 0.0;

  void _onTapDown(TapDownDetails details) {
    print("Tap at: ${details.localPosition}");
    _tapPosition = details.localPosition;
    _waveRadius = 0.0;
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      child: LayoutBuilder(builder: (context, constraints) {
        // 计算最大半径，确保波浪可以覆盖整个Widget
        _maxRadius = max(constraints.maxWidth, constraints.maxHeight) * 1.5;

        if (_waveRadius == _maxRadius) {
          return SizedBox.shrink();
        }

        return ClipPath(
          clipper: CircleClipper(_tapPosition, _waveRadius),
          child: Stack(children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
            ParticleSimulation(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              particleCount: 500,
              maxParticleSize: 1,
              maxParticleSpeed: 0.7,
            ),
          ]),
        );
      }),
    );
  }
}

class CircleClipper extends CustomClipper<Path> {
  final Offset? tapPosition;
  final double radius;

  CircleClipper(this.tapPosition, this.radius);

  @override
  Path getClip(Size size) {
    if (tapPosition == null || radius == 0) {
      return Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    }
    // 定义一个覆盖整个区域的矩形
    Path path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // 在点击位置减去一个圆形区域
    path.addOval(Rect.fromCircle(center: tapPosition!, radius: radius));

    // 使用 `Path.fillType` 来裁剪外部区域
    path.fillType = PathFillType.evenOdd; // 保留圆圈外部的区域

    return path;
  }

  @override
  bool shouldReclip(CircleClipper oldClipper) {
    return oldClipper.tapPosition != tapPosition || oldClipper.radius != radius;
  }
}

class MaskParticle {
  Offset position;
  Offset velocity;
  double size;
  Color color;

  MaskParticle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.color,
  });

  void update() {
    position += velocity;
  }
}

class ParticlePainter extends CustomPainter {
  final List<MaskParticle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (var particle in particles) {
      paint.color = particle.color;
      canvas.drawCircle(particle.position, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class ParticleSimulation extends StatefulWidget {
  final int particleCount;

  final double maxParticleSize;
  final double minParticleSize;

  final double maxParticleSpeed;

  final double width;
  final double height;

  ParticleSimulation({
    Key? key,
    required this.width,
    required this.height,
    this.particleCount = 1000,
    this.maxParticleSize = 4,
    this.minParticleSize = 1,
    this.maxParticleSpeed = 0.5,
  }) : super(key: key);

  @override
  _ParticleSimulationState createState() => _ParticleSimulationState();
}

class _ParticleSimulationState extends State<ParticleSimulation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late List<MaskParticle> _particles;

  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300))
          ..addListener(_updateParticles)
          ..repeat();

    _particles = List.generate(widget.particleCount,
        (index) => _createParticle(widget.width, widget.height));
  }

  MaskParticle _createParticle(width, height) {
    return MaskParticle(
      position:
          Offset(_random.nextDouble() * width, _random.nextDouble() * height),
      velocity: Offset(
          widget.maxParticleSpeed * _random.nextDouble() -
              (widget.maxParticleSpeed) / 2,
          widget.maxParticleSpeed * _random.nextDouble() -
              (widget.maxParticleSpeed) / 2),
      // 粒子随机运动
      size: _random.nextDouble() * widget.maxParticleSize +
          widget.minParticleSize,
      // 粒子的大小
      color: Colors.white.withOpacity(_random.nextDouble()),
    );
  }

  // 更新粒子状态
  void _updateParticles() {
    setState(() {
      for (var particle in _particles) {
        particle.update();

        if (particle.position.dx < 0 || particle.position.dx > widget.width) {
          particle.velocity =
              Offset(-particle.velocity.dx, particle.velocity.dy);
        }
        if (particle.position.dy < 0 || particle.position.dy > widget.height) {
          particle.velocity =
              Offset(particle.velocity.dx, -particle.velocity.dy);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ParticlePainter(_particles),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
