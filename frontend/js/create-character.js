const token = localStorage.getItem('token');
if (!token) location.href = 'index.html';

const form = document.getElementById('character-form');
const errorBox = document.getElementById('character-error');

form.addEventListener('submit', async (event) => {
  event.preventDefault();
  errorBox.textContent = '';

  const data = new FormData(form);

  try {
    const response = await fetch(`${API_BASE}/characters`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify({
        name: data.get('name'),
        class_id: Number(data.get('class_id')),
      }),
    });
    const result = await response.json().catch(() => ({}));

    if (!response.ok) throw new Error(result.detail || 'Could not create character');

    location.href = 'menu.html';
  } catch (error) {
    errorBox.textContent = error.message;
  }
});
