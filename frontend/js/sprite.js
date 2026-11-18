const player = document.getElementById('player');
const sheet = localStorage.getItem('character') || 'Knight/Knight_Idle.png';
player.style.backgroundImage = `url('assets/CharacterClasses/${sheet}')`;
const SPRITE_SIZE = player.offsetWidth;

function moveSprite(x, y) {
  player.style.left = x + 'px';
  player.style.top = y + 'px';
}

function faceSprite(dir) {
  player.style.transform = dir === 'left' ? 'scaleX(-1)' : '';
}
