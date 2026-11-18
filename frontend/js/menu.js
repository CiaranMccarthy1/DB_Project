const select = document.getElementById('character');
const saved = localStorage.getItem('character');
if (saved) select.value = saved;
select.addEventListener('change', () => localStorage.setItem('character', select.value));
