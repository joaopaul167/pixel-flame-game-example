import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:pixel_game/components/hitbox.dart';
import 'package:pixel_game/pixel_game.dart';

class Fruit extends SpriteAnimationComponent
    with HasGameRef<PixelGame>, CollisionCallbacks {
  final String fruit;
  Fruit({this.fruit = "Apple", position, size})
      : super(position: position, size: size);

  final double stepTime = 0.05;
  final CustomHitbox _hitbox = CustomHitbox(
    x: 10,
    y: 10,
    width: 12,
    height: 12,
  );
  bool _collected = false;

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
        game.images.fromCache('Items/Fruits/$fruit.png'),
        SpriteAnimationData.sequenced(
          amount: 17,
          stepTime: stepTime,
          textureSize: Vector2.all(32),
        ));

    return super.onLoad();
  }

  void collidedWithPlayer() async {
    if (!_collected) {
      _collected = true;
      if (game.playSounds) {
        FlameAudio.play('pick_fruit.wav', volume: game.soundVolume);
      }
      animation = SpriteAnimation.fromFrameData(
          game.images.fromCache('Items/Fruits/Collected.png'),
          SpriteAnimationData.sequenced(
            amount: 6,
            stepTime: stepTime,
            textureSize: Vector2.all(32),
            loop: false,
          ));

      await animationTicker?.completed;
      animationTicker?.reset();
      removeFromParent();
    }
  }
}
