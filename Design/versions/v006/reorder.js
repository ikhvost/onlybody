/* Handle-only hold and drag. Preview changes the DOM; release commits one move. */
(() => {
  const reducedMotion = () => document.documentElement.dataset.reduceMotion === 'true' || matchMedia('(prefers-reduced-motion: reduce)').matches;
  let pending = null;
  let drag = null;
  let frame = null;

  function measure() {
    return new Map([...document.querySelectorAll('[data-key]')].map(card => [card.dataset.key, card.getBoundingClientRect()]));
  }

  function animate(before, except) {
    if (!before || reducedMotion()) return;
    for (const card of document.querySelectorAll('[data-key]')) {
      if (card === except) continue;
      const previous = before.get(card.dataset.key);
      if (!previous) continue;
      card.getAnimations().forEach(animation => animation.cancel());
      const next = card.getBoundingClientRect();
      const dy = previous.top - next.top;
      if (Math.abs(dy) > 0.5) card.animate([{ transform: `translateY(${dy}px)` }, { transform: 'none' }], { duration: 350, easing: 'cubic-bezier(.2,.8,.2,1)' });
    }
  }

  function layoutTop(card) {
    const transform = new DOMMatrix(getComputedStyle(card).transform);
    return card.getBoundingClientRect().top - transform.m42 + (transform.d - 1) * card.offsetHeight / 2;
  }

  function position() {
    if (!drag) return;
    const top = drag.top + drag.y - drag.startY;
    drag.card.style.transform = `translateY(${top - layoutTop(drag.card)}px) scale(${reducedMotion() ? 1 : 1.025})`;
  }

  function preview() {
    if (!drag) return;
    const center = drag.top + drag.y - drag.startY + drag.height / 2;
    const siblings = [...drag.parent.querySelectorAll(':scope > [data-key]')].filter(card => card !== drag.card);
    const next = siblings.find(card => center < layoutTop(card) + card.offsetHeight / 2);
    if (drag.card.nextElementSibling !== (next ?? null)) {
      const before = measure();
      drag.parent.insertBefore(drag.card, next ?? null);
      position();
      animate(before, drag.card);
    }
    position();
  }

  function autoScroll() {
    if (!drag) return;
    const bounds = drag.scroll.getBoundingClientRect();
    const edge = 60;
    const speed = drag.y < bounds.top + edge ? -Math.min(12, (bounds.top + edge - drag.y) / 4)
      : drag.y > bounds.bottom - edge ? Math.min(12, (drag.y - bounds.bottom + edge) / 4) : 0;
    if (speed) { drag.scroll.scrollTop += speed; preview(); }
    frame = requestAnimationFrame(autoScroll);
  }

  function clearPending() {
    if (pending) clearTimeout(pending.timer);
    pending = null;
  }

  function lift() {
    if (!pending || !pending.card.isConnected) return clearPending();
    const { card, pointerId, y, scope, from } = pending;
    const bounds = card.getBoundingClientRect();
    drag = { card, pointerId, scope, from, y, startY: y, top: bounds.top, height: card.offsetHeight, parent: card.parentElement, scroll: card.closest('.scroll') };
    clearPending();
    card.classList.add('is-dragging');
    card.querySelector('[data-drag]').setAttribute('aria-pressed', 'true');
    document.querySelector('.device').classList.add('is-reordering');
    position();
    frame = requestAnimationFrame(autoScroll);
  }

  function finish(commit) {
    clearPending();
    if (!drag) return;
    const current = drag;
    const before = measure();
    const to = [...current.parent.querySelectorAll(':scope > [data-key]')].indexOf(current.card);
    drag = null;
    cancelAnimationFrame(frame);
    document.querySelector('.device').classList.remove('is-reordering');
    if (commit && to !== current.from) action(`moveItem:${current.scope}:${current.from}:${to - current.from}`);
    else { render(true); animate(before); }
  }

  document.addEventListener('pointerdown', event => {
    const handle = event.target.closest('[data-drag]');
    if (!handle || event.button !== 0 || !event.isPrimary) return;
    const [scope, from] = handle.dataset.drag.split(':');
    pending = { card: handle.closest('[data-key]'), pointerId: event.pointerId, scope, from: Number(from), x: event.clientX, y: event.clientY };
    pending.timer = setTimeout(lift, 250);
    document.querySelector('#app').setPointerCapture(event.pointerId);
    event.preventDefault();
  });
  document.addEventListener('pointermove', event => {
    if (pending && event.pointerId === pending.pointerId && Math.hypot(event.clientX - pending.x, event.clientY - pending.y) > 10) clearPending();
    if (!drag || event.pointerId !== drag.pointerId) return;
    drag.y = event.clientY;
    preview();
    event.preventDefault();
  });
  document.addEventListener('pointerup', event => {
    if (drag && event.pointerId !== drag.pointerId) return;
    finish(true);
  });
  document.addEventListener('pointercancel', () => finish(false));
  document.addEventListener('keydown', event => { if (event.key === 'Escape') finish(false); });
  window.addEventListener('blur', () => finish(false));
  document.addEventListener('dragstart', event => { if (event.target.closest('[data-drag]')) event.preventDefault(); });
  window.v006Reorder = { measure, animate, isDragging: () => !!drag };
})();
