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
    this.characterId = null;
    this.place();

    addEventListener('keydown', (e) => this.onDown(e));
  }

  place() {
    moveSprite(this.tx * TILE, this.ty * TILE);
  }

  savePosition() {
    if (!this.characterId) return;
    const pos = { level_id: LEVEL_ID, x: this.tx, y: this.ty };
    // chained so rapid saves can't land out of order
    this.saveChain = (this.saveChain ?? Promise.resolve())
      .then(() => combatRequest(`/characters/${this.characterId}/position`, 'PATCH', pos))
      .catch(() => {});
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
      if (LEVEL[this.ty][this.tx] === 'D') {
        // shortcut: doors are one-way progression, no return trip
        if (LEVEL_ID === 1) enterLevel(2);
        else location.href = 'menu.html';
      } else {
        this.savePosition();
      }
    }, STEP_MS);
  }
}

const gamePlayer = new Player();

function enterLevel(id) {
  const spawn = loadLevel(id);
  gamePlayer.tx = spawn.x;
  gamePlayer.ty = spawn.y;
  gamePlayer.place();
  spawnEnemies(id);
  gamePlayer.savePosition();
}

(async () => {
  try {
    const character = await loadCharacter();
    gamePlayer.characterId = character.character_id;
    if (LEVELS[character.current_level_id] && character.current_level_id !== LEVEL_ID) {
      enterLevel(character.current_level_id);
    }
    if (
      character.pos_x !== null &&
      character.pos_y !== null &&
      isWalkable(character.pos_x, character.pos_y)
    ) {
      gamePlayer.tx = character.pos_x;
      gamePlayer.ty = character.pos_y;
      gamePlayer.place();
    }
    // keep the DB in sync with wherever boot actually left the player
    gamePlayer.savePosition();
  } catch (error) {
    console.error(error);
  }
})();
