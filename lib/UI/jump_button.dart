import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:pixel_game/pixel_game.dart';

class JumpButton extends SpriteComponent
    with HasGameRef<PixelGame>, TapCallbacks {
  JumpButton();

  final margin = 64.0;
  final buttonSize = 128.0;
  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    sprite = Sprite(game.images.fromCache('HUD/jump_button.png'));
    position = Vector2(
      game.size.x ,
      game.size.y - buttonSize ,
    );
    priority = 10;
    size = Vector2(128, 128);
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.player.isJumping = true;
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.player.isJumping = false;
    super.onTapUp(event);
  }
}
