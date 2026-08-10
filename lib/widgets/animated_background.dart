import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedBackground extends StatelessWidget {
  const AnimatedBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

        Positioned(
          top: -120,
          right: -100,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.withOpacity(.08),
            ),
          )
              .animate(
            onPlay: (c) => c.repeat(reverse: true),
          )
              .moveY(
            begin: 0,
            end: -25,
            duration: 5.seconds,
          ),
        ),

        Positioned(
          bottom: -120,
          left: -80,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.amber.withOpacity(.08),
            ),
          )
              .animate(
            onPlay: (c) => c.repeat(reverse: true),
          )
              .moveY(
            begin: 0,
            end: 25,
            duration: 6.seconds,
          ),
        ),

      ],
    );
  }
}