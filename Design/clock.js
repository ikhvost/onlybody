// Keep reference timers deterministic without changing the frozen baseline.
window.mockLive = false;
const nativeInterval = window.setInterval.bind(window);
window.setInterval = (callback, delay, ...args) => nativeInterval(() => {
  if (window.mockLive) callback(...args);
}, delay);
