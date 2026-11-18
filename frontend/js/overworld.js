const keys = new Set();
const speed = 200;
let last = 0;
let x = (innerWidth - SPRITE_SIZE) / 2;
let y = (innerHeight - SPRITE_SIZE) / 2;

moveSprite(x, y);

addEventListener('keydown', (e) => {
  if (e.key.startsWith('Arrow') || 'wasd'.includes(e.key)) {
    if (!keys.has(e.key)) {
      if (e.key === 'ArrowLeft' || e.key === 'a') faceSprite('left');
      else if (e.key === 'ArrowRight' || e.key === 'd') faceSprite('right');
    }
    keys.add(e.key);
    e.preventDefault();
  }
});
addEventListener('keyup', (e) => keys.delete(e.key));
addEventListener('blur', () => keys.clear());

function frame(now) {
  const dt = last ? (now - last) / 1000 : 0;
  last = now;
  let moved = false;
  if (keys.has('ArrowLeft') || keys.has('a')) { x -= speed * dt; moved = true; }
  if (keys.has('ArrowRight') || keys.has('d')) { x += speed * dt; moved = true; }
  if (keys.has('ArrowUp') || keys.has('w')) { y -= speed * dt; moved = true; }
  if (keys.has('ArrowDown') || keys.has('s')) { y += speed * dt; moved = true; }
  if (moved) {
    x = Math.max(0, Math.min(innerWidth - SPRITE_SIZE, x));
    y = Math.max(0, Math.min(innerHeight - SPRITE_SIZE, y));
    moveSprite(x, y);
  }
  requestAnimationFrame(frame);
}
requestAnimationFrame(frame);
