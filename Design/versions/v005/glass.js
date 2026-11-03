/* Visual adapter only. The version-owned v003 behavior is preserved in app.js. */
(() => {
  const params = new URLSearchParams(location.search);
  if (params.get('version') !== 'v005') return;
  const root = document.documentElement;
  root.dataset.design = 'v005';
  root.dataset.reduceMotion = String(params.get('reduce-motion') === 'true');
  root.dataset.reduceTransparency = String(params.get('reduce-transparency') === 'true');
  // A deterministic QA switch exercises the same solid material as unsupported browsers.
  root.dataset.noBlur = String(params.get('no-blur') === 'true');
  const style = document.createElement('link');
  style.rel = 'stylesheet';
  style.href = '../v005/styles.css';
  const stylesReady = new Promise((resolve, reject) => {
    style.onload = resolve;
    style.onerror = reject;
  });
  document.head.append(style);
  window.v005Ready = Promise.all([window.v005Ready, stylesReady]);

  const originalTrain = train;
  train = (empty = false) => {
    const template = document.createElement('template');
    template.innerHTML = originalTrain(empty);
    // Keep the product identity without displaying the historical fixture date as today.
    template.content.querySelector('.eyebrow').textContent = product;
    return template.innerHTML;
  };

  const originalOverlay = renderOverlay;
  let lastOverlay = null;
  renderOverlay = () => {
    const overlay = state().overlay;
    const key = overlay ? `${overlay.kind}:${overlay.index ?? ''}` : null;
    originalOverlay();
    const panel = document.querySelector('#overlay .sheet, #overlay .alert-card');
    // Input edits can re-render a sheet; animate only its initial presentation.
    if (panel && key !== lastOverlay) panel.classList.add('glass-enter');
    lastOverlay = key;
  };
})();
