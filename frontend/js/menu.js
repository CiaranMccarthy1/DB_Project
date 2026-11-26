const select = document.getElementById('character');
const token = localStorage.getItem('token');
if (!token) location.href = 'index.html';

function apply() {
  const option = select.selectedOptions[0];
  localStorage.setItem('character_id', option.value);
  localStorage.setItem('character', option.dataset.sprite);
}

fetch(`${API_BASE}/characters`, { headers: { Authorization: `Bearer ${token}` } })
  .then((response) => {
    if (!response.ok) throw new Error();
    return response.json();
  })
  .then((characters) => {
    if (!characters.length) {
      location.href = 'create.html';
      return;
    }
    select.innerHTML = characters
      .map((c) => `<option value="${c.character_id}" data-sprite="${SPRITES[c.class_id]}">${c.character_name}</option>`)
      .join('');

    const saved = localStorage.getItem('character_id');
    if (characters.some((c) => String(c.character_id) === saved)) select.value = saved;
    apply();
  })
  .catch(() => {});

select.addEventListener('change', apply);
