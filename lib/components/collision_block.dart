import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class CollisionBlock extends PositionComponent {
  bool isPlatform;
  CollisionBlock({position, size, this.isPlatform = false}) : super(position: position, size: size) {
    // debugMode = true;
    if (isPlatform) {
      debugColor = const Color(0xFFFFD700);
    }
  }
}