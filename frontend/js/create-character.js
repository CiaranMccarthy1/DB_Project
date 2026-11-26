const token = localStorage.getItem('token');
if (!token) location.href = 'index.html';

const form = document.getElementById('character-form');
const errorBox = document.getElementById('character-error');

const SPRITES = {
  1: 'Soilder/Soldier_Idle.png',
  2: 'Knight/Knight_Idle.png',
  3: 'Templar/Knight Templar_Idle.png',
  4: 'Wizard/Wizard_Idle.png',
  5: 'Priest/Priest_Idle.png',
  6: 'Archer/Archer_Idle.png',
};

form.addEventListener('submit', async (event) => {
  event.preventDefault();
  errorBox.textContent = '';

  const data = new FormData(form);
  const classId = Number(data.get('class_id'));

  try {
    const response = await fetch(`${API_BASE}/characters`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify({
        character_name: data.get('name'),
        class_id: classId,
      }),
    });
    const result = await response.json().catch(() => ({}));

    if (!response.ok) {
      throw new Error(typeof result.detail === 'string' ? result.detail : 'Could not create character');
    }

    localStorage.setItem('character', SPRITES[classId]);
    localStorage.setItem('character_id', result.character_id);
    localStorage.setItem('stats', JSON.stringify({
      hp: result.hp,
      max_hp: result.max_hp,
      mana: result.mana,
      melee: result.melee,
      armor: result.armor,
    }));
    location.href = 'game.html';
  } catch (error) {
    errorBox.textContent = error.message;
  }
});
