/* Independent picker actions and a video-first exercise guide. */
(() => {
  if (new URLSearchParams(location.search).get('version') !== 'v006') return;
  const copy = {
    add: ['Додати вправу','Add exercise','Dodaj ćwiczenie','Übung hinzufügen','Ajouter l’exercice'],
    title: ['Як виконувати вправу','See how it’s done','Jak wykonać ćwiczenie','So geht die Übung','Comment faire le mouvement'],
    summary: [
      'Натискаючи «Дивитися відео», ви дозволяєте завантаження відео YouTube. Google обробляє дані пристрою й переглядів та може використовувати cookies для відтворення, аналітики й реклами.',
      'Tap Watch Video to allow YouTube videos to load. Google processes device and viewing data and may use cookies for playback, analytics and ads.',
      'Klikając „Obejrzyj film”, zezwalasz na ładowanie filmów YouTube. Google przetwarza dane urządzenia i oglądania oraz może używać cookies do odtwarzania, analityki i reklam.',
      'Mit „Video ansehen“ erlaubst du das Laden von YouTube-Videos. Google verarbeitet Geräte- und Wiedergabedaten und kann Cookies für Wiedergabe, Analysen und Werbung verwenden.',
      'En appuyant sur « Voir la vidéo », vous autorisez le chargement des vidéos YouTube. Google traite les données de l’appareil et de visionnage et peut utiliser des cookies pour la lecture, les analyses et la publicité.'
    ],
    preview: ['Цей HTML-прототип показує інтерфейс плеєра; реальне відтворення відео тут не підключене.','This HTML prototype previews the player interface; actual video playback is not connected.','Ten prototyp HTML pokazuje interfejs odtwarzacza; rzeczywiste odtwarzanie nie jest podłączone.','Dieser HTML-Prototyp zeigt die Player-Oberfläche; die Videowiedergabe ist hier nicht angebunden.','Ce prototype HTML présente l’interface du lecteur ; la lecture vidéo réelle n’est pas connectée.'],
    watch: ['Дивитися відео','Watch Video','Obejrzyj film','Video ansehen','Voir la vidéo'],
    privacy: ['Конфіденційність Google','Google Privacy','Prywatność Google','Google-Datenschutz','Confidentialité Google'],
    terms: ['Умови YouTube','YouTube Terms','Warunki YouTube','YouTube-Bedingungen','Conditions YouTube'],
    details: ['Про дані та дозволи','About data and permissions','Dane i uprawnienia','Daten und Berechtigungen','Données et autorisations']
  };
  const text = key => copy[key][['uk','en','pl','de','fr'].indexOf(language)];
  const previousRows = catalogRows, previousMovement = movementView, previousAction = action;
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
    if (card && state().videoConsent) {
      // This is a network-free preview. Video consent never changes ATT state.
      card.outerHTML = `<div class="player-placeholder">${btn(icon('play',24),'videoPlay','play')}<span>YouTube · HTML-мок</span></div>`;
    } else if (card) {
      const legal = `<div class="legal-links"><a href="https://policies.google.com/privacy" target="_blank" rel="noopener">${E(text('privacy'))}</a><a href="https://www.youtube.com/t/terms" target="_blank" rel="noopener">${E(text('terms'))}</a></div>`;
      card.innerHTML = `<strong>${E(text('title'))}</strong><p>${E(text('summary'))}</p>${btn(E(text('watch')),'videoPermission','primary permission-button')}<details class="video-disclosure"><summary>${E(text('details'))}</summary><p>${tr('uiYouCanTurnVideosOffInSettings')}</p>${legal}</details>`;
    }
    youtube?.remove();
    template.content.querySelector('[data-action="videoPlay"]')?.setAttribute('aria-label',text('watch'));
    return template.innerHTML;
  };

  action = value => {
    const s = state(), [name,index] = value.split(':');
    if (name === 'videoPlay') {
      alertOverlay('YouTube · HTML-мок',text('preview'),[{label:t('uiOkUppercase'),action:'closeOverlay'}]);
      return;
    }
    if (name === 'videoPermission') {
      if (s.route !== 'movement' || !video(s.exerciseName)) return;
      s.videoConsent = true;
      render(true);
      document.querySelector('[data-action="videoPlay"]')?.focus({preventScroll:true});
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
