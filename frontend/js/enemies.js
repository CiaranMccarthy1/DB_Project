const ENEMY_TYPES = {
  orc: { id: 1, name: 'Orc', sprite: 'Orc/Orc_Idle.png', hp: 55, melee: 12, armor: 5 },
  slime: { id: 2, name: 'Slime', sprite: 'Slime/Slime_Idle.png', hp: 45, melee: 6, armor: 3 },
  archer: { id: 4, name: 'Skeleton Archer', sprite: 'SkeletonArcher/Skeleton Archer_Idle.png', hp: 50, melee: 6, armor: 3 },
  elite_orc: { id: 6, name: 'Elite Orc', sprite: 'EliteOrc/Elite Orc_Idle.png', hp: 140, melee: 20, armor: 10 },
  hell_bat: { id: 11, name: 'Hell Bat', sprite: 'HellBat/Hellbat_Flying.png', hp: 55, melee: 8, armor: 4 },
  hell_hound: { id: 10, name: 'Hell Hound', sprite: 'HellHound/Hellhound_Idle.png', hp: 85, melee: 16, armor: 8 },
  demon: { id: 8, name: 'Demon', sprite: 'Demon/Demon_A_Idle.png', hp: 75, melee: 14, armor: 7 },
  necromancer: { id: 7, name: 'Necromancer', sprite: 'Necromancer/Necromancer_Idle.png', hp: 120, melee: 8, armor: 8 },
  warlock: { id: 14, name: 'Warlock', sprite: 'Warlock/Warlock_Idle.png', hp: 180, melee: 10, armor: 10 },
  flame_golem: { id: 13, name: 'Flame Golem', sprite: 'FlameGolem/Flame Golem_Idle.png', hp: 240, melee: 20, armor: 20 },
};

const SPAWNS = {
  1: [
    { type: 'orc', x: 4, y: 7 },
    { type: 'slime', x: 9, y: 2 },
    { type: 'archer', x: 11, y: 7 },
    { type: 'orc', x: 16, y: 7 },
    { type: 'elite_orc', x: 18, y: 5 },
    { type: 'necromancer', x: 10, y: 4 },
  ],
  2: [
    { type: 'hell_bat', x: 4, y: 5 },
    { type: 'hell_hound', x: 15, y: 8 },
    { type: 'demon', x: 17, y: 5 },
    { type: 'warlock', x: 17, y: 1 },
    { type: 'flame_golem', x: 10, y: 8 },
  ],
};

const DEFAULT_STATS = { hp: 100, max_hp: 100, mana: 20, melee: 14, armor: 8 };

const enemies = [];

function spawnEnemies(levelId) {
  for (const enemy of enemies) enemy.el.remove();
  enemies.length = 0;
  for (const spawn of SPAWNS[levelId]) {
    const type = ENEMY_TYPES[spawn.type];
    const el = document.createElement('div');
    el.className = 'enemy';
    el.style.left = spawn.x * TILE + 'px';
    el.style.top = spawn.y * TILE + 'px';
    el.style.backgroundImage = `url('assets/Enemies/${type.sprite}')`;
    document.getElementById('level').append(el);
    enemies.push({
      ...type,
      x: spawn.x,
      y: spawn.y,
      maxHp: type.hp,
      el,
      graceUntil: 0,
    });
  }
}

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

async function combatRequest(path, method = 'GET', body = null) {
  const token = localStorage.getItem('token');
  const response = await fetch(`${API_BASE}${path}`, {
    method,
    headers: {
      Authorization: `Bearer ${token}`,
      ...(body ? { 'Content-Type': 'application/json' } : {}),
    },
    body: body ? JSON.stringify(body) : undefined,
  });
  const result = await response.json().catch(() => ({}));
  if (!response.ok) {
    throw new Error(typeof result.detail === 'string' ? result.detail : 'Battle failed');
  }
  return result;
}

async function getCharacterId() {
  const stored = localStorage.getItem('character_id');
  if (stored) return Number(stored);

  const characters = await combatRequest('/characters');
  if (!characters.length) throw new Error('No character found');
  localStorage.setItem('character_id', characters[0].character_id);
  return characters[0].character_id;
}

async function loadCharacter() {
  const character = await combatRequest(`/characters/${await getCharacterId()}`);
  const stats = loadStats();
  stats.hp = character.hp;
  stats.max_hp = character.max_hp;
  stats.mana = character.mana;
  stats.melee = character.melee;
  stats.armor = character.armor;
  saveStats(stats);
  return character;
}

function syncState(state) {
  const stats = loadStats();
  stats.hp = state.character_hp;
  stats.mana = state.character_mana;
  saveStats(stats);
  battle.enemy.hp = state.enemy_hp;

  if (state.finished) {
    if (state.outcome === 'win') winBattle(state);
    else if (state.outcome === 'loss') loseBattle();
  }
}

async function startBattle(enemy) {
  if (battle) return;
  battle = { enemy, battleId: null, busy: true, over: false };
  battleEl.hidden = false;
  setLog(`A ${enemy.name} attacks!`);
  renderBattle();

  try {
    const characterId = await getCharacterId();
    const state = await combatRequest('/combat/start', 'POST', {
      character_id: characterId,
      enemy_id: enemy.id,
    });
    battle.battleId = state.battle_id;
    syncState(state);
    battle.busy = false;
    renderBattle();
  } catch (error) {
    battle = null;
    battleEl.hidden = true;
    console.error(error);
  }
}

function closeBattle() {
  battleEl.hidden = true;
  battle = null;
}

async function playerAction(kind) {
  if (!battle || battle.busy || battle.over) return;
  battle.busy = true;
  renderBattle();

  const stats = loadStats();
  const hpBefore = stats.hp;
  const enemyBefore = battle.enemy.hp;

  try {
    const state = await combatRequest(`/combat/${battle.battleId}/action`, 'POST', { kind });
    syncState(state);
    if (state.finished) return;

    const dealt = Math.max(0, enemyBefore - state.enemy_hp);
    const taken = Math.max(0, hpBefore - state.character_hp);
    setLog(`You hit for ${dealt}. ${battle.enemy.name} hits you for ${taken}.`);
    battle.busy = false;
    renderBattle();
  } catch (error) {
    setLog(error.message);
    battle.busy = false;
    renderBattle();
  }
}

function winBattle(state) {
  battle.over = true;
  let text = `You defeated the ${battle.enemy.name}! +${state.xp_gained} XP`;
  if (state.drop) text += ` It dropped a ${state.drop}!`;
  if (state.level_up) {
    text += ' Level up!';
    loadCharacter(); // stats grew server-side; refresh the local copy
  }
  setLog(text);
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

async function fleeBattle() {
  if (!battle || battle.busy || battle.over) return;
  battle.busy = true;
  renderBattle();

  try {
    await combatRequest(`/combat/${battle.battleId}/flee`, 'POST');
    const enemy = battle.enemy;
    closeBattle();
    enemy.graceUntil = Date.now() + 3000;
  } catch (error) {
    setLog(error.message);
    battle.busy = false;
    renderBattle();
  }
}

async function useItem() {
  if (!battle || battle.busy || battle.over) return;
  battle.busy = true;
  renderBattle();

  try {
    const characterId = await getCharacterId();
    const items = await combatRequest(`/inventory?character_id=${characterId}`);
    if (!items.length) throw new Error('No items left');

    const state = await combatRequest(`/combat/${battle.battleId}/action`, 'POST', {
      kind: 'item',
      item_id: items[0].item_id,
    });
    syncState(state);
    if (state.finished) return;

    setLog(`You used ${items[0].item_name}. ${battle.enemy.name} strikes back.`);
    battle.busy = false;
    renderBattle();
  } catch (error) {
    setLog(error.message);
    battle.busy = false;
    renderBattle();
  }
}

battleEl.addEventListener('click', (event) => {
  const action = event.target.dataset.action;
  if (!action || !battle || battle.busy || battle.over) return;
  if (action === 'attack') playerAction('attack_a');
  else if (action === 'heavy') playerAction('attack_b');
  else if (action === 'item') useItem();
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
  if (battle || !LEVEL || !gamePlayer) return;
  for (const enemy of enemies) {
    if (Date.now() < enemy.graceUntil) continue;
    stepEnemy(enemy);
    if (Math.abs(enemy.x - gamePlayer.tx) + Math.abs(enemy.y - gamePlayer.ty) === 1) {
      startBattle(enemy);
      break;
    }
  }
}, 900);
