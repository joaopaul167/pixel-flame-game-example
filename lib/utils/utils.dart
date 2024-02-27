bool checkCollision(player, block) {
  final hitbox = player.hitbox;
  final playerX = player.position.x + hitbox.x;
  final playerY = player.position.y + hitbox.y;
  final playerWidth = hitbox.width;
  final playerHeight = hitbox.height;
  final blockX = block.position.x;
  final blockY = block.position.y;
  final blockWidth = block.size.x;
  final blockHeight = block.size.y;

  final fixX = player.scale.x < 0 
    ? playerX - (hitbox.x * 2) - playerWidth 
    : playerX;
  final fixY = block.isPlatform ? playerY + playerHeight : playerY;
  return (fixX < blockX + blockWidth &&
      fixX + playerWidth > blockX &&
      fixY < blockY + blockHeight &&
      playerY + playerHeight > blockY);
}
