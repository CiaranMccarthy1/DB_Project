const STEP_MS = 120;

const DIRECTIONS = {
  ArrowLeft: [-1, 0], a: [-1, 0],
  ArrowRight: [1, 0], d: [1, 0],
  ArrowUp: [0, -1], w: [0, -1],
  ArrowDown: [0, 1], s: [0, 1],
};

class Player {
  constructor() {
    const spawn = findSpawn();
    this.tx = spawn.x;
    this.ty = spawn.y;
    this.moving = false;
    this.place();

    addEventListener('keydown', (e) => this.onDown(e));
  }

  place() {
    moveSprite(this.tx * TILE, this.ty * TILE);
  }

  onDown(e) {
    const dir = DIRECTIONS[e.key];
    if (!dir) return;
    e.preventDefault();
    if (this.moving || battleActive()) return;

    if (dir[0] < 0) faceSprite('left');
    if (dir[0] > 0) faceSprite('right');

    const tx = this.tx + dir[0];
    const ty = this.ty + dir[1];

    const enemy = enemyAt(tx, ty);
    if (enemy) {
      startBattle(enemy);
      return;
    }

    if (!isWalkable(tx, ty)) return;

    this.tx = tx;
    this.ty = ty;
    this.moving = true;
    this.place();

    setTimeout(() => {
      this.moving = false;
      if (LEVEL[this.ty][this.tx] === 'D') location.href = 'menu.html';
    }, STEP_MS);
  }
}

const gamePlayer = new Player();
