const knight = document.getElementById('knight');
const SPRITE_SIZE = knight.offsetWidth;

function moveSprite(x, y) {
  knight.style.left = x + 'px';
  knight.style.top = y + 'px';
}

function faceSprite(dir) {
  knight.style.transform = dir === 'left' ? 'scaleX(-1)' : '';
}
