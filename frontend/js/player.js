class Player {
  constructor() {
    this.keys = new Set();
    this.speed = 200;
    this.last = 0;
    this.x = (innerWidth - SPRITE_SIZE) / 2;
    this.y = (innerHeight - SPRITE_SIZE) / 2;

    moveSprite(this.x, this.y);

    addEventListener('keydown', (e) => this.onDown(e));
    addEventListener('keyup', (e) => this.keys.delete(e.key));
    addEventListener('blur', () => this.keys.clear());

    requestAnimationFrame((now) => this.frame(now));
  }

  onDown(e) {
    if (!e.key.startsWith('Arrow') && !'wasd'.includes(e.key)) return;
    if (!this.keys.has(e.key)) {
      if (e.key === 'ArrowLeft' || e.key === 'a') faceSprite('left');
      else if (e.key === 'ArrowRight' || e.key === 'd') faceSprite('right');
    }
    this.keys.add(e.key);
    e.preventDefault();
  }

  frame(now) {
    const dt = this.last ? (now - this.last) / 1000 : 0;
    this.last = now;
    const k = this.keys;
    let dx = 0;
    let dy = 0;
    if (k.has('ArrowLeft') || k.has('a')) dx -= 1;
    if (k.has('ArrowRight') || k.has('d')) dx += 1;
    if (k.has('ArrowUp') || k.has('w')) dy -= 1;
    if (k.has('ArrowDown') || k.has('s')) dy += 1;
    if (dx || dy) {
      const step = this.speed * dt / Math.hypot(dx, dy);
      this.x += dx * step;
      this.y += dy * step;
      this.x = Math.max(0, Math.min(innerWidth - SPRITE_SIZE, this.x));
      this.y = Math.max(0, Math.min(innerHeight - SPRITE_SIZE, this.y));
      moveSprite(this.x, this.y);
    }
    requestAnimationFrame((t) => this.frame(t));
  }
}

new Player();
