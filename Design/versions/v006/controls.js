/* v006 navigation semantics and exercise actions. No native or persisted data. */
(() => {
  if (new URLSearchParams(location.search).get('version') !== 'v006') return;
  const copy = {
    actions: ['Дії з вправою','Exercise actions','Opcje ćwiczenia','Übungsaktionen','Actions de l’exercice'],
    replace: ['Замінити вправу','Replace exercise','Zamień ćwiczenie','Übung ersetzen','Remplacer l’exercice'],
    up: ['Перемістити вище','Move up','Przenieś wyżej','Nach oben verschieben','Déplacer vers le haut'],
    down: ['Перемістити нижче','Move down','Przenieś niżej','Nach unten verschieben','Déplacer vers le bas'],
    locked: ['Замінити можна лише вправу без виконаних підходів.','Only exercises without completed sets can be replaced.','Można zamienić tylko ćwiczenie bez ukończonych serii.','Nur Übungen ohne abgeschlossene Sätze können ersetzt werden.','Seuls les exercices sans séries terminées peuvent être remplacés.'],
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
    const dismiss = ['closePicker','closeOverlay','cancelReplace','closeItemActions'].includes(back) || (back === 'closeFilters' && !nestedFilters);
    const cancel = dismiss && ['closeOverlay','closeFilters'].includes(back) && ['movementEdit','timing','filters'].includes(overlay?.kind);
    const target = cancel ? 'cancelPanel' : back;
    return `<div class="nav-bar">${btn(dismiss ? closeIcon() : icon('back',20), target, 'icon-button nav-control', `aria-label="${E(t(dismiss?'uiClose':'uiBack'))}" data-navigation="${dismiss?'close':'back'}"`)}${title ? `<div class="nav-bar-title">${E(title)}</div>` : '<div class="grow"></div>'}${trailing}</div>`;
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
    if (name === 'itemActions') {
      const [scope,uid] = parts;
      if (!items(scope)?.some(item => item.uid === uid)) return;
      opener = value;
      s.overlay = {kind:'itemActions',scope,uid};
      renderOverlay();return;
    }
    if (name === 'closeItemActions') { s.overlay=null;renderOverlay();restoreOpener();return; }
    if (name === 'cancelPanel') { dismissPanel();return; }
    if (name === 'menuMove' || name === 'menuReplace') {
      const overlay = s.overlay;
      if (overlay?.kind !== 'itemActions') return;
      const list=items(overlay.scope), index=list?.findIndex(item=>item.uid===overlay.uid);
      if (index == null || index < 0) return;
      if (name==='menuReplace' && overlay.scope==='session' && list[index].rows.some(row=>row.done)) return;
      const delta=Number(parts[0]);
      if (name==='menuMove' && (![-1,1].includes(delta) || index+delta<0 || index+delta>=list.length)) return;
      s.overlay=null;
      previousAction(name==='menuMove' ? `moveItem:${overlay.scope}:${index}:${delta}` : `replaceItem:${overlay.scope}:${index}`);
      if (name==='menuMove') restoreOpener();
      return;
    }
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
    if (overlay?.kind !== 'itemActions') {
      previousOverlay();
      if (overlay?.kind==='timing') {
        const header=document.querySelector('#overlay .sheet > .row');
        header.outerHTML=nav(t(overlay.field==='duration'?'uiDuration':'uiSetRest'),'closeOverlay',btn(E(t('uiDone')),'closeOverlay','done'));
        document.querySelector('#overlay .nav-control').focus({preventScroll:true});
      }
      return;
    }
    const list=items(overlay.scope),index=list.findIndex(item=>item.uid===overlay.uid),item=list[index];
    if (!item) { state().overlay=null;previousOverlay();restoreOpener();return; }
    const locked=overlay.scope==='session'&&item.rows.some(row=>row.done);
    document.querySelector('#overlay').innerHTML=`<div class="device-overlay"><section class="sheet item-actions" role="dialog" aria-modal="true" aria-label="${E(controlLabel('actions'))}"><div class="sheet-handle"></div>${nav(exName(item.name),'closeItemActions')}<div class="scroll pad"><div class="item-action-list">${btn(E(controlLabel('replace')),'menuReplace','item-action',locked?'disabled aria-describedby="replacement-lock"':'')}${btn(E(controlLabel('up')),'menuMove:-1','item-action',index===0?'disabled':'')}${btn(E(controlLabel('down')),'menuMove:1','item-action',index===list.length-1?'disabled':'')}</div>${locked?`<p id="replacement-lock" class="hint">${E(controlLabel('locked'))}</p>`:''}</div></section></div>`;
    document.querySelector('#app').inert=true;
    document.querySelector('.home-indicator').style.visibility='hidden';
    document.querySelector('.item-actions .nav-control').focus({preventScroll:true});
  };
  // Escape cancels the current panel and returns to its parent when nested.
  document.addEventListener('keydown', event => {
    const overlay=state().overlay;
    if (event.key!=='Escape'||!overlay||!['itemActions','filters','movementEdit','timing','replacement','exercisePicker'].includes(overlay.kind)) return;
    event.preventDefault();event.stopImmediatePropagation();
    if (overlay.kind==='itemActions') action('closeItemActions');
    else dismissPanel();
  },true);
  document.querySelector('#overlay').addEventListener('click', event => {
    if (event.target.classList.contains('device-overlay') && state().overlay?.kind==='itemActions') action('closeItemActions');
  });
})();
