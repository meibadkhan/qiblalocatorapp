
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'helper_widget.dart';

class QiblahCompassWidget extends StatefulWidget {
  @override
  _QiblahCompassWidgetState createState() => _QiblahCompassWidgetState();
}

class _QiblahCompassWidgetState extends State<QiblahCompassWidget>
    with SingleTickerProviderStateMixin {
  final Widget _compassSvg = SvgPicture.asset('assets/compass.svg');
  final Widget _needleSvg = SvgPicture.asset(
    'assets/needle.svg',
    fit: BoxFit.contain,
    height: 300,
    alignment: Alignment.center,
  );

  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Scale-in animation for compass
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.8,
      upperBound: 1.0,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOut,
    );
    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: 0.4,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/masjid.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 250, left: 14, right: 14),
          child: StreamBuilder<QiblahDirection>(
            stream: FlutterQiblah.qiblahStream,
            builder: (_, AsyncSnapshot<QiblahDirection> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return LoadingIndicator();
              }
              if (!snapshot.hasData) {
                return const Center(child: Text("Error: Unable to fetch Qibla direction"));
              }

              final qiblahDirection = snapshot.data!;

              return ScaleTransition(
                scale: _scaleAnimation,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Transform.rotate(
                      angle: (-qiblahDirection.direction * (pi / 180)),
                      child: _compassSvg,
                    ),
                    AnimatedRotation(
                      turns: -qiblahDirection.qiblah / 360,
                      duration: const Duration(milliseconds: 500),
                      child: _needleSvg,
                    ),
                    Positioned(
                      bottom: 8,
                      child: Text("${qiblahDirection.offset.toStringAsFixed(3)}°"),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
