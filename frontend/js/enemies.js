const ENEMY_TYPES = {
  orc: { name: 'Orc', sprite: 'Orc/Orc_Idle.png', hp: 55, melee: 12, armor: 5 },
  slime: { name: 'Slime', sprite: 'Slime/Slime_Idle.png', hp: 45, melee: 6, armor: 3 },
  archer: { name: 'Skeleton Archer', sprite: 'SkeletonArcher/Skeleton Archer_Idle.png', hp: 50, melee: 6, armor: 3 },
};

const SPAWNS = [
  { type: 'orc', x: 4, y: 7 },
  { type: 'slime', x: 9, y: 2 },
  { type: 'archer', x: 11, y: 7 },
  { type: 'orc', x: 16, y: 7 },
];

const DEFAULT_STATS = { hp: 100, max_hp: 100, mana: 20, melee: 14, armor: 8 };

const enemies = SPAWNS.map((spawn) => {
  const type = ENEMY_TYPES[spawn.type];
  const el = document.createElement('div');
  el.className = 'enemy';
  el.style.left = spawn.x * TILE + 'px';
  el.style.top = spawn.y * TILE + 'px';
  el.style.backgroundImage = `url('assets/Enemies/${type.sprite}')`;
  document.getElementById('level').append(el);
  return {
    ...type,
    x: spawn.x,
    y: spawn.y,
    maxHp: type.hp,
    el,
    graceUntil: 0,
  };
});

const battleEl = document.getElementById('battle');
const battleTitle = document.getElementById('battle-title');
const battleStats = document.getElementById('battle-stats');
const battleLog = document.getElementById('battle-log');

let battle = null;

function battleActive() {
  return battle !== null;
}

function enemyAt(tx, ty) {
  return enemies.find((e) => e.x === tx && e.y === ty);
}

function loadStats() {
  try {
    return { ...DEFAULT_STATS, ...JSON.parse(localStorage.getItem('stats')) };
  } catch {
    return { ...DEFAULT_STATS };
  }
}

function saveStats(stats) {
  localStorage.setItem('stats', JSON.stringify(stats));
}

function rand(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function setLog(text) {
  battleLog.textContent = text;
}

function renderBattle() {
  if (!battle) return;
  const stats = loadStats();
  battleTitle.textContent = `${battle.enemy.name}  (${Math.max(0, battle.enemy.hp)} HP)`;
  battleStats.textContent = `You: ${stats.hp}/${stats.max_hp} HP   ${stats.mana} mana`;
  for (const button of battleEl.querySelectorAll('button')) {
    button.disabled = battle.busy || battle.over;
  }
}

function startBattle(enemy) {
  if (battle) return;
  battle = { enemy, busy: false, over: false };
  battleEl.hidden = false;
  setLog(`A ${enemy.name} attacks!`);
  renderBattle();
}

function closeBattle() {
  battleEl.hidden = true;
  battle = null;
}

function playerAttack(multiplier, manaCost) {
  const stats = loadStats();
  if (manaCost) {
    if (stats.mana < manaCost) {
      setLog('Not enough mana.');
      return;
    }
    stats.mana -= manaCost;
    saveStats(stats);
  }

  const damage = Math.max(
    1,
    Math.round(stats.melee * multiplier) - Math.floor(battle.enemy.armor / 2) + rand(-2, 2),
  );
  battle.enemy.hp -= damage;
  setLog(`You hit ${battle.enemy.name} for ${damage}.`);
  renderBattle();

  if (battle.enemy.hp <= 0) {
    winBattle();
    return;
  }

  battle.busy = true;
  renderBattle();
  setTimeout(enemyTurn, 450);
}

function enemyTurn() {
  if (!battle || battle.over) return;
  const stats = loadStats();
  const damage = Math.max(
    1,
    battle.enemy.melee - Math.floor(stats.armor / 2) + rand(-2, 2),
  );
  stats.hp -= damage;
  saveStats(stats);
  setLog(`${battle.enemy.name} hits you for ${damage}.`);
  renderBattle();

  if (stats.hp <= 0) {
    loseBattle();
    return;
  }

  battle.busy = false;
  renderBattle();
}

function winBattle() {
  battle.over = true;
  setLog(`You defeated the ${battle.enemy.name}!`);
  renderBattle();

  const enemy = battle.enemy;
  enemies.splice(enemies.indexOf(enemy), 1);
  enemy.el.remove();

  setTimeout(closeBattle, 900);
}

function loseBattle() {
  battle.over = true;
  setLog('You died.');
  renderBattle();

  const stats = loadStats();
  stats.hp = stats.max_hp;
  saveStats(stats);

  setTimeout(() => { location.href = 'menu.html'; }, 1400);
}

function fleeBattle() {
  const enemy = battle.enemy;
  closeBattle();
  enemy.graceUntil = Date.now() + 3000;
}

battleEl.addEventListener('click', (event) => {
  const action = event.target.dataset.action;
  if (!action || !battle || battle.busy || battle.over) return;
  if (action === 'attack') playerAttack(1, 0);
  else if (action === 'heavy') playerAttack(1.6, 5);
  else if (action === 'flee') fleeBattle();
});

function canStand(tx, ty) {
  if (!isWalkable(tx, ty)) return false;
  if (enemyAt(tx, ty)) return false;
  if (gamePlayer.tx === tx && gamePlayer.ty === ty) return false;
  return true;
}

function stepEnemy(enemy) {
  const directions = [[0, -1], [0, 1], [-1, 0], [1, 0]];
  const options = directions.filter(([dx, dy]) => canStand(enemy.x + dx, enemy.y + dy));
  if (!options.length) return;

  let choice = options[rand(0, options.length - 1)];
  const dx = gamePlayer.tx - enemy.x;
  const dy = gamePlayer.ty - enemy.y;

  if (Math.abs(dx) + Math.abs(dy) <= 5 && Math.random() < 0.6) {
    const chase = Math.abs(dx) >= Math.abs(dy) ? [Math.sign(dx), 0] : [0, Math.sign(dy)];
    if (options.some(([ox, oy]) => ox === chase[0] && oy === chase[1])) choice = chase;
  }

  enemy.x += choice[0];
  enemy.y += choice[1];
  enemy.el.style.left = enemy.x * TILE + 'px';
  enemy.el.style.top = enemy.y * TILE + 'px';
}

setInterval(() => {
  if (battle) return;
  for (const enemy of enemies) {
    if (Date.now() < enemy.graceUntil) continue;
    stepEnemy(enemy);
    if (Math.abs(enemy.x - gamePlayer.tx) + Math.abs(enemy.y - gamePlayer.ty) === 1) {
      startBattle(enemy);
      break;
    }
  }
}, 900);
