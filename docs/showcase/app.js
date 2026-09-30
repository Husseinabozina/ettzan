const filterButtons = document.querySelectorAll('[data-filter]');
const figures = document.querySelectorAll('[data-category]');
filterButtons.forEach(button => button.addEventListener('click', () => {
  filterButtons.forEach(item => item.setAttribute('aria-pressed', String(item === button)));
  figures.forEach(figure => { figure.hidden = button.dataset.filter !== 'all' && figure.dataset.category !== button.dataset.filter; });
}));
const dialog = document.querySelector('#image-dialog');
const image = document.querySelector('#dialog-image');
let lastTrigger;
document.querySelectorAll('.screen-open').forEach(button => button.addEventListener('click', () => {
  lastTrigger = button;
  image.src = button.dataset.full;
  image.alt = button.querySelector('img').alt;
  document.querySelector('#image-title').textContent = button.closest('figure').querySelector('h3').textContent;
  dialog.showModal();
}));
document.querySelector('#close-dialog').addEventListener('click', () => dialog.close());
dialog.addEventListener('click', event => { if (event.target === dialog) { const r = dialog.getBoundingClientRect(); if (event.clientX < r.left || event.clientX > r.right || event.clientY < r.top || event.clientY > r.bottom) dialog.close(); } });
dialog.addEventListener('close', () => { image.removeAttribute('src'); lastTrigger?.focus(); });
