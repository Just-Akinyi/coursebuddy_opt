import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';

class LiquidDropletLoader extends StatelessWidget {
  final Animation<double> animation;
  final Path Function(Size size) buildDropletPath;

  const LiquidDropletLoader({
    Key? key,
    required this.animation,
    required this.buildDropletPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 250,
      child: ClipPath(
        clipper: _DropletClipper(),
        child: LiquidCustomProgressIndicator(
          value: animation.value,
          valueColor: const AlwaysStoppedAnimation(Colors.pink),
          backgroundColor: Colors.white,
          direction: Axis.vertical,
          shapePath: buildDropletPath(const Size(200, 250)),
          center: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Image.asset(
              'assets/images/coursebuddy_logo.png',
              width: 60,
              height: 60,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

class _DropletClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    final double w = size.width;
    final double h = size.height;

    path.moveTo(w * 0.5, 0);
    path.cubicTo(w * 0.9, h * 0.1, w, h * 0.5, w * 0.5, h);
    path.cubicTo(0, h * 0.5, w * 0.1, h * 0.1, w * 0.5, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
