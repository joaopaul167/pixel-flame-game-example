import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pixel_game/UI/joystick.dart';
import 'package:pixel_game/UI/jump_button.dart';
import 'package:pixel_game/entities/player.dart';
import 'package:pixel_game/levels/level.dart';

class PixelGame extends FlameGame
    with
        HasKeyboardHandlerComponents,
        HasCollisionDetection {
  @override
  Color backgroundColor() => const Color.fromRGBO(255, 255, 255, 0);
  late CameraComponent cam; 
  late final Player player = Player(character: "Ninja Frog");
  bool playSounds = false;
  double soundVolume = 0.3;
  int currentLevelIndex = 0;
  List<String> levelNames = [
    'level-01',
    'level-02',
  ];

  late Joystick joystick;
  late JumpButton jumpButton;
  bool showControls = false;
  @override
  Future<void> onLoad() async {
    // debugMode = true;
    await images.loadAllImages();
    _loadLevel();
    return super.onLoad();
  }
  void loadNextLevel() {
    removeWhere((component) => component is Level);
    if (currentLevelIndex < levelNames.length - 1) {
      currentLevelIndex++;
      _loadLevel();
    } else {
      currentLevelIndex = 0;
      _loadLevel();
    }
  }

  @override
  void update(double dt) {
    if (showControls) _updateJoystick();
    super.update(dt);
  }


  void _updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.upLeft:
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.upRight:
        player.horizontalMovement = 1;
        break;
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;
        break;
      case JoystickDirection.right:
        player.horizontalMovement = 1;
        break;
      case JoystickDirection.down:
        player.horizontalMovement = 0;
        break;
      case JoystickDirection.up:
        player.horizontalMovement = 0;
        break;
      case JoystickDirection.idle:
        player.horizontalMovement = 0;
        break;
      default:
        break;
    }
  }
  
  void _loadLevel() {
    Level world =
        Level(levelName: levelNames[currentLevelIndex], player: player);
    camera = CameraComponent.withFixedResolution(
        world: world, width: 640, height: 368);
    camera.viewfinder.anchor = Anchor.topLeft;
    if (showControls) {
      joystick = Joystick();
      jumpButton = JumpButton();
      addAll([world, joystick, jumpButton]);
    } else {
      add(world);
    }
  }
}
