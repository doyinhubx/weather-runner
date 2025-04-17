function setText(selector, text) {
  document.querySelector(selector).textContent = text;
}

function appendList(selector, items) {
  const list = document.querySelector(selector);
  list.innerHTML = '';
  items.forEach(item => {
    const li = document.createElement('li');
    li.textContent = item;
    list.appendChild(li);
  });
}

module.exports = { setText, appendList };
