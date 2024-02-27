import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:pixel_game/components/collision_block.dart';
import 'package:pixel_game/components/hitbox.dart';
import 'package:pixel_game/entities/checkpoint.dart';
import 'package:pixel_game/entities/fruit.dart';
import 'package:pixel_game/entities/saw.dart';
import 'package:pixel_game/pixel_game.dart';
import 'package:pixel_game/utils/utils.dart';

enum PlayerState { idle, run, jump, fall, dead, appear, disappear }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelGame>, KeyboardHandler, CollisionCallbacks {
  Player({this.character = "Ninja Frog", Vector2? position})
      : super(position: position ?? Vector2.all(0));

  String character;
  List<CollisionBlock> collisionBlocks = [];
  late final SpriteAnimation fallAnimation;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation jumpAnimation;
  late final SpriteAnimation runAnimation;
  late final SpriteAnimation deadAnimation;
  late final SpriteAnimation appearAnimation;
  late final SpriteAnimation disappearAnimation;

  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;

  Vector2 startingPosition = Vector2.zero();
  double horizontalMovement = 0;
  bool isJumping = false;
  double moveSpeed = 100;
  final double stepTime = 0.05;
  Vector2 velocity = Vector2.zero();

  final double _gravity = 9.81;
  final double _jumpForce = 260;
  final double _terminalVelocity = 250;
  bool _isGrounded = false;
  bool _isDead = false;
  bool _reachedCheckPoint = false;

  CustomHitbox hitbox = CustomHitbox(
    x: 10,
    y: 4,
    width: 14,
    height: 28,
  );

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keys) {
    horizontalMovement = 0;
    final isLeftPressed = keys.contains(LogicalKeyboardKey.arrowLeft) ||
        keys.contains(LogicalKeyboardKey.keyA);
    final isRightPressed = keys.contains(LogicalKeyboardKey.arrowRight) ||
        keys.contains(LogicalKeyboardKey.keyD);
    horizontalMovement += isLeftPressed ? -1 : 0;
    horizontalMovement += isRightPressed ? 1 : 0;

    isJumping = keys.contains(LogicalKeyboardKey.space);

    return super.onKeyEvent(event, keys);
  }

  @override
  Future<void> onLoad() async {
    _loadAllAnimations();
    // debugMode = true;

    startingPosition = position.clone();

    add(RectangleHitbox(
        position: Vector2(hitbox.x, hitbox.y),
        size: Vector2(hitbox.width, hitbox.height)));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;
    while (accumulatedTime >= fixedDeltaTime) {
      if (!_isDead && !_reachedCheckPoint) {
        _updatePlayerMovement(fixedDeltaTime);
        _updatePlayerState();
        _checkHorizontalCollisions();
        _applyGravity(fixedDeltaTime);
        _checkVerticalCollisions();
      }
      accumulatedTime -= fixedDeltaTime;
    }

    super.update(fixedDeltaTime);
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation("Idle", 11, 32);
    runAnimation = _spriteAnimation("Run", 12, 32);
    jumpAnimation = _spriteAnimation("Jump", 1, 32);
    fallAnimation = _spriteAnimation("Fall", 1, 32);
    deadAnimation = _spriteAnimation("Hit", 7, 32)..loop = false;
    appearAnimation = _specialSpriteAnimation("Appearing", 7, 96);
    disappearAnimation = _specialSpriteAnimation("Disappearing", 7, 96);

    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.run: runAnimation,
      PlayerState.jump: jumpAnimation,
      PlayerState.fall: fallAnimation,
      PlayerState.dead: deadAnimation,
      PlayerState.appear: appearAnimation,
      PlayerState.disappear: disappearAnimation,
    };

    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(String animation, int amount, int size) {
    return SpriteAnimation.fromFrameData(
        game.images.fromCache(
            'Main Characters/$character/$animation (${size}x${size}).png'),
        SpriteAnimationData.sequenced(
          amount: amount,
          stepTime: stepTime,
          textureSize: Vector2.all(size.ceilToDouble()),
        ));
  }

  SpriteAnimation _specialSpriteAnimation(
      String animation, int amount, int size) {
    return SpriteAnimation.fromFrameData(
        game.images
            .fromCache('Main Characters/$animation (${size}x${size}).png'),
        SpriteAnimationData.sequenced(
          amount: amount,
          stepTime: stepTime,
          textureSize: Vector2.all(size.ceilToDouble()),
          loop: false,
        ));
  }

  void _updatePlayerMovement(double dt) {
    if (isJumping) _playerJump(dt);

    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;

    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    if (velocity.x != 0) {
      playerState = PlayerState.run;
    }

    if (isJumping) {
      playerState = PlayerState.jump;
    }

    if (velocity.y > _gravity) {
      playerState = PlayerState.fall;
    }

    current = playerState;
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      if (!block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitbox.x - hitbox.width;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitbox.width + hitbox.x;
          }
        }
      }
    }
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _checkVerticalCollisions() {
    for (final block in collisionBlocks) {
      if (block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.y;
            _isGrounded = true;
            isJumping = false;
          }
        }
      } else {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.y;
            _isGrounded = true;
            isJumping = false;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.y;
            _isGrounded = false;
          }
          break;
        }
      }
    }
  }

  void _playerJump(double dt) {
    if (_isGrounded) {
      if (game.playSounds)
        FlameAudio.play('jump.wav', volume: game.soundVolume);
      velocity.y = -_jumpForce;
      _isGrounded = false;
      position.y += velocity.y * dt;
      isJumping = true;
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!_reachedCheckPoint) {
      if (other is Fruit) {
        other.collidedWithPlayer();
      }
      if (other is Saw) {
        // other.collidedWithPlayer();
        _respawn();
      }
      if (other is Checkpoint) {
        _reachedCheckpoint();
      }
    }

    super.onCollisionStart(intersectionPoints, other);
  }

  void _respawn() async {
    if (game.playSounds) FlameAudio.play('hit.wav', volume: game.soundVolume);
    const delayDuration = Duration(milliseconds: 350);
    _isDead = true;
    current = PlayerState.dead;

    await animationTicker?.completed;
    animationTicker?.reset();

    scale.x = 1;
    position = startingPosition - Vector2.all(32);
    current = PlayerState.appear;

    await animationTicker?.completed;
    animationTicker?.reset();

    position = startingPosition;
    velocity = Vector2.zero();
    _updatePlayerState();

    await Future.delayed(delayDuration, () {
      _isDead = false;
    });
  }

  void _reachedCheckpoint() async {
    if (game.playSounds) {
      FlameAudio.play('disappearing.wav', volume: game.soundVolume);
    }
    _reachedCheckPoint = true;
    current = PlayerState.disappear;
    position = position - Vector2.all(32);
    scale.x = 1;

    await animationTicker?.completed;
    animationTicker?.reset();

    _reachedCheckPoint = false;
    position = Vector2.all(-640);

    game.loadNextLevel();
  }
}
