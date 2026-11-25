const TILE = 64;
const SRC = 32; // source tiles in the packed sheets are 32x32

const LEVEL = [
  "####################",
  "#.....#......#.....#",
  "#..P..#......#.....#",
  "#.....#......#.....#",
  "#..................#",
  "#.....#......#.....D",
  "#.....#......#.....#",
  "#.....#......#.....#",
  "#.....#......#.....#",
  "#.....#......#.....#",
  "####################",
];

const PROPS = [
  { x: 1, y: 8, kind: "chest" },
  { x: 12, y: 1, kind: "crate" },
  { x: 18, y: 8, kind: "chest" },
];

const PROP_RECTS = {
  chest: [128, 0],
  crate: [256, 0],
};

const canvas = document.getElementById('map');
canvas.width = LEVEL[0].length * TILE;
canvas.height = LEVEL.length * TILE;

const ctx = canvas.getContext('2d');
ctx.imageSmoothingEnabled = false;

// Crop rectangles verified against the packed sheets.
const FLOOR = [16, 96];
const WALL = [160, 0];
const DOOR = [0, 32];

const sheets = {
  tiles: 'assets/Building/walls_floor.png',
  doors: 'assets/Building/doors_lever_chest_animation.png',
  objects: 'assets/Building/Objects.png',
};

const images = {};
let loaded = 0;

for (const [name, src] of Object.entries(sheets)) {
  const img = new Image();
  img.onload = () => {
    if (++loaded === Object.keys(sheets).length) draw();
  };
  img.src = src;
  images[name] = img;
}

function draw() {
  for (let y = 0; y < LEVEL.length; y++) {
    for (let x = 0; x < LEVEL[y].length; x++) {
      const tile = LEVEL[y][x];
      const [fx, fy] = tile === '#' ? WALL : FLOOR;
      ctx.drawImage(images.tiles, fx, fy, SRC, SRC, x * TILE, y * TILE, TILE, TILE);
      if (tile === 'D') {
        ctx.drawImage(images.doors, DOOR[0], DOOR[1], SRC, SRC, x * TILE, y * TILE, TILE, TILE);
      }
    }
  }

  for (const prop of PROPS) {
    const [px, py] = PROP_RECTS[prop.kind];
    ctx.drawImage(images.objects, px, py, SRC, SRC, prop.x * TILE, prop.y * TILE, TILE, TILE);
  }
}

function propAt(tx, ty) {
  return PROPS.some((p) => p.x === tx && p.y === ty);
}

function isWalkable(tx, ty) {
  const row = LEVEL[ty];
  if (!row) return false;
  const tile = row[tx];
  return (tile === '.' || tile === 'P' || tile === 'D') && !propAt(tx, ty);
}

function findSpawn() {
  for (let y = 0; y < LEVEL.length; y++) {
    const x = LEVEL[y].indexOf('P');
    if (x !== -1) return { x, y };
  }
  return { x: 1, y: 1 };
}

function fitLevel() {
  const scale = Math.min(1, innerWidth / canvas.width, innerHeight / canvas.height);
  document.getElementById('level').style.transform =
    `translate(-50%, -50%) scale(${scale})`;
}

addEventListener('resize', fitLevel);
fitLevel();
