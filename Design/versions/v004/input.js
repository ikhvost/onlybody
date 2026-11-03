/* Model values remain committed while a pristine zero is replaced in the field. */
(() => {
  const isTextInput = element => element instanceof Element && !!element.closest('input,textarea,[contenteditable="true"]');
  document.addEventListener('pointerdown', event => {
    if (!isTextInput(event.target) && isTextInput(document.activeElement)) document.activeElement.blur();
  }, true);
  document.addEventListener('focusin', event => {
    const input = event.target;
    if (input.matches('[data-field="weight"]') && input.value === '0' && input.getAttribute('aria-invalid') !== 'true') {
      input.dataset.initialZero = 'true';
      input.value = '';
    }
  });
  document.addEventListener('input', event => {
    if (event.target.matches('[data-field="weight"]')) delete event.target.dataset.initialZero;
  }, true);
  document.addEventListener('focusout', event => {
    if (event.target.dataset?.initialZero === 'true') {
      event.target.value = '0';
      delete event.target.dataset.initialZero;
    }
  });
})();
