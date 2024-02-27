import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_game/components/hitbox.dart';
import 'package:pixel_game/pixel_game.dart';

class Saw extends SpriteAnimationComponent
    with HasGameRef<PixelGame>, CollisionCallbacks {
  
  final bool isVertical;
  final double offNeg;
  final double offPos;
  Saw({position, size, this.isVertical = false, this.offNeg = 0, this.offPos = 0})
      : super(position: position, size: size);

  final double stepTime = 0.03;
  final CustomHitbox _hitbox = CustomHitbox(
    x: 10,
    y: 10,
    width: 12,
    height: 12,
  );

  Vector2 startingPosition = Vector2.zero();
  static const speed = 50;
  static const tileSize = 16; 
  double moveDirection = 1;
  double rangeNeg = 0;
  double rangePos = 0;



  @override
  Future<void> onLoad() async {
    priority = -1;

    add(CircleHitbox());

    // debugMode = true;
    if (isVertical) {
      rangeNeg = y - offNeg * tileSize;
      rangePos = y + offPos * tileSize;
    } else {
      rangeNeg = x - offNeg * tileSize;
      rangePos = x + offPos * tileSize;
    }

    // debugMode = true;
    startingPosition = position.clone();
    add(RectangleHitbox(
      position: Vector2(_hitbox.x, _hitbox.y),
      size: Vector2(_hitbox.width, _hitbox.height),
    ));
    animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Traps/Saw/On (38x38).png'),
        SpriteAnimationData.sequenced(
          amount: 8,
          stepTime: stepTime,
          textureSize: Vector2.all(38),
        ));

    return super.onLoad();
  }

  void collidedWithPlayer() {
    // game.player.die();
    position = startingPosition.clone();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isVertical) {
      y += speed * moveDirection * dt;
      if (y < rangeNeg || y > rangePos) {
        moveDirection *= -1;
      }
    } else {
      x += speed * moveDirection * dt;
      if (x <= rangeNeg || x > rangePos) {
        moveDirection *= -1;
      }
    }
  }

  void _moveVertically(double dt) {
    if (y <= rangeNeg || y >= rangePos) {
      moveDirection = -1;
    }
    y += speed * moveDirection * dt;
    
  }
  void _moveHorizontally(double dt) {
    if (x < rangeNeg || x >= rangePos) {
      moveDirection = 1;
    }
    x += speed * moveDirection * dt;
    
  }  
}
