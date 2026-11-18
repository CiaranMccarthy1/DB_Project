const player = document.getElementById('player');
const SPRITE_SIZE = player.offsetWidth;

function moveSprite(x, y) {
  player.style.left = x + 'px';
  player.style.top = y + 'px';
}

function faceSprite(dir) {
  player.style.transform = dir === 'left' ? 'scaleX(-1)' : '';
}
