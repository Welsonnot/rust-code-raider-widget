import 'dart:math';
import 'package:flutter/material.dart';

class ShakeWidget extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;
  final double maxOffset;

  const ShakeWidget({
    super.key,
    required this.child,
    required this.animation,
    this.maxOffset = 14.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        // Damped sine wave oscillation
        final double progress = animation.value;
        final double decay = 1.0 - progress;
        final double offset = sin(progress * pi * 4) * maxOffset * decay;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: child,
    );
  }
}
