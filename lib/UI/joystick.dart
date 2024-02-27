import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

class Joystick extends JoystickComponent {
  Joystick() : super(
          priority: 100,
          knob : CircleComponent(
            radius: 32,
            paint: BasicPalette.red.withAlpha(159).paint(),
          ),
          margin: const EdgeInsets.only(left: 64, bottom: 32),
          background: CircleComponent(
            radius: 64,
            paint: BasicPalette.black.withAlpha(100).paint(),
          ),
        );
}