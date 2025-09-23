import 'package:flutter/material.dart';
// import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();

    // Navigate after 2s (replace with your init logic)
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return; 
      Navigator.pushReplacementNamed(context, '/auth'); 
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: 160,
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              RotationTransition(
                turns: _controller,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [Colors.orange, Colors.lightBlue],
                    ),
                  ),
                ),
              ),
              Image.asset(
                'assets/images/coursebuddy_logo.png',
                width: 100,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
