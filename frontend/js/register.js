const form = document.getElementById('register-form');
const errorBox = document.getElementById('register-error');

form.addEventListener('submit', async (event) => {
  event.preventDefault();
  errorBox.textContent = '';

  const data = new FormData(form);

  try {
    const response = await fetch(`${API_BASE}/auth/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        username: data.get('username'),
        email: data.get('email'),
        password: data.get('password'),
      }),
    });
    const result = await response.json().catch(() => ({}));

    if (!response.ok) throw new Error(result.detail || 'Registration failed');
    if (!result.token) throw new Error('No token returned');

    // a new account must not inherit the previous session's character
    localStorage.removeItem('character_id');
    localStorage.removeItem('character');
    localStorage.removeItem('stats');
    localStorage.setItem('token', result.token);
    location.href = 'create.html';
  } catch (error) {
    errorBox.textContent = error.message;
  }
});
