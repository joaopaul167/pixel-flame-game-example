import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_game/components/hitbox.dart';
import 'package:pixel_game/entities/player.dart';
import 'package:pixel_game/pixel_game.dart';

class Checkpoint extends SpriteAnimationComponent
    with HasGameRef<PixelGame>, CollisionCallbacks {
  Checkpoint({position, size}) : super(position: position, size: size);

  double stepTime = 0.05;
  final CustomHitbox _hitbox = CustomHitbox(
    x: 18,
    y: 20,
    width: 12,
    height: 50,
  );

  @override
  Future<void> onLoad() async {
    priority = -1;
    // debugMode = true;
    add(RectangleHitbox(
      position: Vector2(_hitbox.x, _hitbox.y),
      size: Vector2(_hitbox.width, _hitbox.height),
      collisionType: CollisionType.passive,
    ));
    animation = SpriteAnimation.fromFrameData(
        game.images
            .fromCache('Items/Checkpoints/Checkpoint/Checkpoint (No Flag).png'),
        SpriteAnimationData.sequenced(
          amount: 1,
          stepTime: 1,
          textureSize: Vector2.all(64),
        ));

    return super.onLoad();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      _reachedCheckpoint();
    }

    super.onCollisionStart(intersectionPoints, other);
  }

  void _reachedCheckpoint() async {
    animation = SpriteAnimation.fromFrameData(
        game.images.fromCache(
            'Items/Checkpoints/Checkpoint/Checkpoint (Flag Out) (64x64).png'),
        SpriteAnimationData.sequenced(
          amount: 26,
          stepTime: stepTime,
          textureSize: Vector2.all(64),
          loop: false,
        ));

    await animationTicker?.completed;
    animationTicker?.reset();
    animation = SpriteAnimation.fromFrameData(
        game.images.fromCache(
            'Items/Checkpoints/Checkpoint/Checkpoint (Flag Idle) (64x64).png'),
        SpriteAnimationData.sequenced(
          amount: 10,
          stepTime: stepTime,
          textureSize: Vector2.all(64),
        ));
  }
}
