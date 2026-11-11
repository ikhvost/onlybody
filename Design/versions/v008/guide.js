/* Independent picker actions and a video-first exercise guide. */
(() => {
  if (new URLSearchParams(location.search).get('version') !== 'v008') return;
  const copy = {
    add: ['Додати вправу','Add exercise','Dodaj ćwiczenie','Übung hinzufügen','Ajouter l’exercice'],
    preview: ['Цей HTML-прототип показує інтерфейс плеєра; реальне відтворення відео тут не підключене.','This HTML prototype previews the player interface; actual video playback is not connected.','Ten prototyp HTML pokazuje interfejs odtwarzacza; rzeczywiste odtwarzanie nie jest podłączone.','Dieser HTML-Prototyp zeigt die Player-Oberfläche; die Videowiedergabe ist hier nicht angebunden.','Ce prototype HTML présente l’interface du lecteur ; la lecture vidéo réelle n’est pas connectée.'],
    watch: ['Дивитися відео','Watch Video','Obejrzyj film','Video ansehen','Voir la vidéo']
  };
  const text = key => copy[key][['uk','en','pl','de','fr'].indexOf(language)];
  const previousRows = catalogRows, previousMovement = movementView, previousSettings = settingsView, previousAction = action;
  let pickerReturn = null;

  catalogRows = picker => {
    if (!picker || !filtered(true).length) return previousRows(picker);
    return filtered(true).map(ex => {
      const index = D.products[product].exercises.indexOf(ex);
      const description = `<div class="grow"><strong>${E(exName(ex))}</strong><span class="meta">${E(label(ex.primaryMuscle)+' · '+ex.equipment.map(label).join(', '))}</span></div>`;
      return `<div class="exercise-row picker-row">${btn(description,`pickerGuide:${index}`,'picker-guide')}${btn(icon('plus',22),`addExercise:${index}`,'picker-add',`aria-label="${E(text('add')+': '+exName(ex))}"`)}</div>`;
    }).join('');
  };

  movementView = () => {
    const template = document.createElement('template');
    template.innerHTML = previousMovement();
    const card = template.content.querySelector('.consent-card');
    const youtube = template.content.querySelector('.youtube-link');
    if (card) {
      // Always preview the ready player; native consent and local preference values stay untouched.
      card.outerHTML = `<div class="player-placeholder">${btn(icon('play',24),'videoPlay','play')}<span>YouTube · HTML-мок</span></div>`;
    }
    youtube?.remove();
    template.content.querySelector('[data-action="videoPlay"]')?.setAttribute('aria-label',text('watch'));
    return template.innerHTML;
  };

  settingsView = () => {
    const template = document.createElement('template');
    template.innerHTML = previousSettings();
    template.content.querySelector('.youtube-settings')?.closest('.settings-section')?.remove();
    return template.innerHTML;
  };

  action = value => {
    const s = state(), [name,index] = value.split(':');
    if (name === 'videoPlay') {
      alertOverlay('YouTube · HTML-мок',text('preview'),[{label:t('uiOkUppercase'),action:'closeOverlay'}]);
      return;
    }
    if (name === 'pickerGuide') {
      if (s.overlay?.kind !== 'exercisePicker' && s.route !== 'exercisePicker') return;
      if (!D.products[product].exercises[Number(index)]) return;
      const host = s.overlay ? '#overlay' : '#app';
      pickerReturn = {owner:s, overlay:s.overlay, host, scroll:document.querySelector(`${host} #catalog-results`).scrollTop, opener:value};
      previousAction(`movement:${index}`);
      document.querySelector('#app .nav-control')?.focus({preventScroll:true});
      return;
    }
    if (name === 'back' && s.route === 'movement' && pickerReturn?.owner === s) {
      const saved = pickerReturn;
      pickerReturn = null;
      previousAction(value);
      s.overlay = saved.overlay;
      if (saved.overlay) renderOverlay();
      const results = document.querySelector(`${saved.host} #catalog-results`);
      if (results) {
        results.scrollTop = saved.scroll;
        [...results.querySelectorAll('button')].find(button => button.dataset.action === saved.opener)?.focus({preventScroll:true});
      }
      return;
    }
    if (['tab','pickExercise','addExercise','closePicker'].includes(name)) pickerReturn = null;
    previousAction(value);
  };
})();
