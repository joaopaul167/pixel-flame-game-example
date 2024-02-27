import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_game/components/background_tile.dart';
import 'package:pixel_game/components/collision_block.dart';
import 'package:pixel_game/entities/checkpoint.dart';
import 'package:pixel_game/entities/enemy.dart';
import 'package:pixel_game/entities/fruit.dart';
import 'package:pixel_game/entities/player.dart';
import 'package:pixel_game/entities/saw.dart';
import 'package:pixel_game/pixel_game.dart';

class Level extends World with HasGameRef<PixelGame>, DragCallbacks,
        TapCallbacks  {
  Level({required this.levelName, required this.player});
  final String levelName;
  late TiledComponent level;
  final Player player;
  List<CollisionBlock> collisionBlocks = [];

  @override
  Future<void> onLoad() async {
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));
    // debugMode = true;

    add(level);
    _scrollingBackground();
    _spawningObjects();
    _addCollisions();
    return super.onLoad();
  }

  void _scrollingBackground() {
    final backgroundLayer = level.tileMap.getLayer('Background');

    if (backgroundLayer != null) {
      final backgroundColor =
          backgroundLayer.properties.getValue("BackgroundColor");

      final backgroundTile = BackgroundTile(
        color: backgroundColor ?? "Gray",
        position: Vector2(0, 0),
      );
      add(backgroundTile);
    }
  }

  void _spawningObjects() {
    final spawnPointLayer = level.tileMap.getLayer<ObjectGroup>('SpawnPoints');

    if (spawnPointLayer != null) {
      for (final spawnPoint in spawnPointLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            player.scale.x = 1;
            add(player);
            break;
          case 'Fruit':
            final fruit = Fruit(
              fruit: spawnPoint.name,
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(fruit);
            break;
          case 'Saw':
            bool isVertical = spawnPoint.properties.getValue('isVertical');
            double offsetNeg = spawnPoint.properties.getValue('offsetNeg');
            double offsetPos = spawnPoint.properties.getValue('offsetPos');
            final saw = Saw(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              isVertical: isVertical,
              offNeg: offsetNeg,
              offPos: offsetPos,
            );
            add(saw);
            break;
          case "Checkpoint":
            final checkpoint = Checkpoint(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(checkpoint);
            break;
          case "Enemy":
            final enemy = Enemy(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              offNeg: spawnPoint.properties.getValue('offsetNeg'),
              offPos: spawnPoint.properties.getValue('offsetPos'),
            );
            add(enemy);
            break;
          default:
        }
      }
    }
  }

  void _addCollisions() {
    final collisionLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');
    if (collisionLayer != null) {
      for (final collision in collisionLayer.objects) {
        switch (collision.class_) {
          case 'Platform':
            final platform = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isPlatform: true,
            );
            collisionBlocks.add(platform);
            add(platform);
            break;
          default:
            final block = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
            );
            collisionBlocks.add(block);
            add(block);
            break;
        }
      }
    }

    player.collisionBlocks = collisionBlocks;
  }
}
