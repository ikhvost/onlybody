/* Horizontal edge swipes invoke the same action as the visible back button. */
(() => {
  let swipe = null;
  let pointerStart = null;
  let suppressClick = false;
  document.addEventListener('pointerdown', event => {
    swipe = null;
    suppressClick = false;
    pointerStart = event.isPrimary ? {x:event.clientX,y:event.clientY} : null;
    if (!event.isPrimary || event.button !== 0 || event.target.closest('input,textarea,[data-drag]')) return;
    const device = document.querySelector('.device').getBoundingClientRect();
    if (event.clientX < device.left || event.clientX > device.left + 44) return;
    const host = state().overlay ? document.querySelector('#overlay') : document.querySelector('#app');
    const back = [...host.querySelectorAll('button')].find(button => button.getAttribute('aria-label') === t('uiBack') && !button.disabled);
    if (back) swipe = { x: event.clientX, y: event.clientY, pointerId: event.pointerId, back, route: state().route, overlay: state().overlay };
  });
  document.addEventListener('pointermove', event => {
    if (pointerStart && Math.hypot(event.clientX-pointerStart.x,event.clientY-pointerStart.y)>10) suppressClick=true;
    if (swipe && event.pointerId === swipe.pointerId && Math.abs(event.clientY - swipe.y) > 40) swipe = null;
  });
  document.addEventListener('pointerup', event => {
    const gesture = swipe;
    swipe = null;
    if (!gesture || event.pointerId !== gesture.pointerId || !gesture.back.isConnected) return;
    if (event.clientX - gesture.x >= 70 && Math.abs(event.clientY - gesture.y) < 40 && state().route === gesture.route && state().overlay === gesture.overlay) {
      action(gesture.back.dataset.action);
    }
  });
  document.addEventListener('pointercancel', () => swipe = null);
  document.addEventListener('click', event => {
    if (suppressClick && event.detail>0) {
      suppressClick=false;event.preventDefault();event.stopImmediatePropagation();
    }
  },true);
})();
