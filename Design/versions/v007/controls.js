/* v007 navigation and direct replacement, synchronized with native 85aaed3. */
(() => {
  if (new URLSearchParams(location.search).get('version') !== 'v007') return;
  const copy = {
    done: ['Готово','Done','Gotowe','Fertig','Fait']
  };
  window.controlLabel = key => copy[key][['uk','en','pl','de','fr'].indexOf(language)];
  const svg = path => `<svg class="icon" viewBox="0 0 24 24" aria-hidden="true">${path}</svg>`;
  const closeIcon = () => svg('<path d="m6 6 12 12M18 6 6 18"/>');
  const filterIcon = () => svg('<path d="M4 7h5m4 0h7M4 17h9m4 0h3"/><circle cx="11" cy="7" r="2"/><circle cx="15" cy="17" r="2"/>');
  window.filterControl = (actionName, count) => btn(filterIcon() + (count ? `<span class="filter-count">${count}</span>` : ''), actionName, 'filter-button', `aria-label="${E(window.DESIGN_COPY.filters[['uk','en','pl','de','fr'].indexOf(language)])}${count ? ': '+count : ''}" aria-haspopup="dialog"`);

  nav = (title = '', back = 'back', trailing = '') => {
    const overlay = state().overlay;
    const nestedFilters = back === 'closeFilters' && (overlay?.returnReplacement || overlay?.returnPicker);
    const dismiss = ['closePicker','closeOverlay','cancelReplace'].includes(back) || (back === 'closeFilters' && !nestedFilters);
    const cancel = dismiss && ['closeOverlay','closeFilters'].includes(back) && ['movementEdit','timing','filters'].includes(overlay?.kind);
    const target = cancel ? 'cancelPanel' : back;
    return `<div class="nav-bar">${btn(dismiss ? closeIcon() : icon('back',20), target, 'icon-button nav-control', `aria-label="${E(t(dismiss?'uiClose':'uiBack'))}" data-navigation="${dismiss?'close':'back'}"`)}${title ? `<div class="nav-bar-title">${E(title)}</div>` : '<div class="grow"></div>'}<div class="nav-trailing">${trailing}</div></div>`;
  };

  const originalMusclePicker = musclePicker;
  musclePicker = () => {
    const template = document.createElement('template');
    template.innerHTML = originalMusclePicker();
    if (state().editingTargets) {
      template.content.querySelector('.picker-bottom').classList.add('glass-target-actions');
      template.content.querySelector('[data-action="buildSmart"]').textContent = controlLabel('done');
      template.content.querySelector('.skip-manual')?.remove();
    }
    return template.innerHTML;
  };

  const previousAction = action, previousOverlay = renderOverlay;
  let transaction = null;
  let opener = null;
  const items = scope => scope === 'builder' ? state().builder?.items : state().active?.workout.items;
  function restoreOpener() {
    if (!opener) return;
    const button = [...document.querySelectorAll('#app button')].find(el => el.dataset.action === opener);
    button?.focus({preventScroll:true});
    opener = null;
  }
  function dismissPanel() {
    const s = state(), overlay = s.overlay;
    if (!overlay) return;
    if (transaction?.owner === s) {
      if (transaction.builder) { s.builder = structuredClone(transaction.builder); s.dirty = transaction.dirty; }
      if (transaction.filters) {
        Object.assign(s, transaction.filters);
        if (overlay.returnReplacement) overlay.returnReplacement.query = transaction.query;
      }
    }
    transaction = null;
    if (overlay.kind === 'filters') previousAction('closeFilters');
    else if (overlay.kind === 'exercisePicker') previousAction('closePicker');
    else { s.overlay = null; render(true); }
    if (!s.overlay) restoreOpener();
  }
  action = value => {
    const s = state(), [name,...parts] = value.split(':');
    if (name === 'mode' && s.builder?.id) return;
    if (name === 'replaceExercise') {
      const [scope,uid] = parts, list = items(scope);
      const index = list?.findIndex(item => item.uid === uid);
      if (index == null || index < 0) return;
      if (scope === 'session' && list[index].rows.some(row => row.done)) return;
      opener = value;
      previousAction(`replaceItem:${scope}:${index}`);
      return;
    }
    if (name === 'cancelPanel') { dismissPanel();return; }
    if (['editMovement','timing'].includes(name)) {
      const returning = s.overlay?.kind==='alert' && transaction?.owner===s && transaction.key===value;
      if (!returning) transaction={owner:s,key:value,builder:structuredClone(s.builder),dirty:s.dirty};
    } else if (['openFilters','replacementFilters'].includes(name)) {
      const picker=name==='replacementFilters'||parts[0]==='true';
      const fields=picker?['pickerFilter','pickerEquipment','pickerSearch']:['filter','equipment','search'];
      transaction={owner:s,filters:Object.fromEntries(fields.map(key=>[key,s[key]])),query:s.overlay?.query};
    }
    previousAction(value);
    if (name==='closeFilters') transaction=null;
    if (!s.overlay) { transaction=null;restoreOpener(); }
  };
  renderOverlay = () => {
    const overlay=state().overlay;
    previousOverlay();
    if (overlay?.kind === 'movementEdit') document.querySelector('#overlay .sheet')?.classList.add('glass-action-panel');
    if (overlay?.kind==='timing') {
      const header=document.querySelector('#overlay .sheet > .row');
      header.outerHTML=nav(t(overlay.field==='duration'?'uiDuration':'uiSetRest'),'closeOverlay',btn(E(t('uiDone')),'closeOverlay','done'));
      document.querySelector('#overlay .nav-control').focus({preventScroll:true});
    }
  };
  // Escape cancels the current panel and returns to its parent when nested.
  document.addEventListener('keydown', event => {
    const overlay=state().overlay;
    if (event.key!=='Escape'||!overlay||!['filters','movementEdit','timing','replacement','exercisePicker'].includes(overlay.kind)) return;
    event.preventDefault();event.stopImmediatePropagation();
    dismissPanel();
  },true);
})();
