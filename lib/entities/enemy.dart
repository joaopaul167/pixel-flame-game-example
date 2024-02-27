import 'package:flame/components.dart';

enum EnemyState { idle, running, hit }

class Enemy extends SpriteAnimationGroupComponent {
  Enemy({super.position, super.size, this.offNeg = 0, this.offPos = 0});
  
  final double offNeg;
  final double offPos;

  @override
  Future<void> onLoad() async {
    debugMode = true;

    _loadAllAnimations();
    return super.onLoad();
  }
  
  void _loadAllAnimations() {

  }
}