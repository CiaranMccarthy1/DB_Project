const form = document.getElementById('login-form');
const errorBox = document.getElementById('login-error');

form.addEventListener('submit', async (event) => {
  event.preventDefault();
  errorBox.textContent = '';

  const data = new FormData(form);

  try {
    const response = await fetch(`${API_BASE}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        username: data.get('username'),
        password: data.get('password'),
      }),
    });
    const result = await response.json().catch(() => ({}));

    if (!response.ok) throw new Error(result.detail || 'Login failed');
    if (!result.token) throw new Error('No token returned');

    // a new account must not inherit the previous session's character
    localStorage.removeItem('character_id');
    localStorage.removeItem('character');
    localStorage.removeItem('stats');
    localStorage.setItem('token', result.token);
    location.href = 'menu.html';
  } catch (error) {
    errorBox.textContent = error.message;
  }
});
