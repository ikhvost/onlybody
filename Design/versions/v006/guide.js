/* Independent picker actions and a video-first exercise guide. */
(() => {
  if (new URLSearchParams(location.search).get('version') !== 'v006') return;
  const copy = {
    add: ['Додати вправу','Add exercise','Dodaj ćwiczenie','Übung hinzufügen','Ajouter l’exercice'],
    title: ['Як виконувати вправу','See how it’s done','Jak wykonać ćwiczenie','So geht die Übung','Comment faire le mouvement'],
    summary: [
      'Відео з YouTube. Google обробляє дані пристрою й переглядів та може використовувати cookies для відтворення, аналітики й реклами.',
      'Videos from YouTube. Google processes device and viewing data and may use cookies for playback, analytics and ads.',
      'Filmy z YouTube. Google przetwarza dane urządzenia i oglądania oraz może używać cookies do odtwarzania, analityki i reklam.',
      'Videos von YouTube. Google verarbeitet Geräte- und Wiedergabedaten und kann Cookies für Wiedergabe, Analysen und Werbung verwenden.',
      'Vidéos YouTube. Google traite les données de l’appareil et de visionnage et peut utiliser des cookies pour la lecture, les analyses et la publicité.'
    ],
    setup: ['Дивитися тут','Watch in app','Oglądaj w aplikacji','In der App ansehen','Regarder dans l’application'],
    privacy: ['Конфіденційність Google','Google Privacy','Prywatność Google','Google-Datenschutz','Confidentialité Google'],
    terms: ['Умови YouTube','YouTube Terms','Warunki YouTube','YouTube-Bedingungen','Conditions YouTube'],
    details: ['Про дані та дозволи','About data and permissions','Dane i uprawnienia','Daten und Berechtigungen','Données et autorisations'],
    external: ['Відстеження вимкнено. Відео можна відкрити на YouTube за посиланням нижче.','Tracking is off. You can watch on YouTube using the link below.','Śledzenie jest wyłączone. Film możesz obejrzeć w YouTube przez link poniżej.','Tracking ist deaktiviert. Über den Link unten kannst du das Video auf YouTube ansehen.','Le suivi est désactivé. Regardez la vidéo sur YouTube grâce au lien ci-dessous.']
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
    if (card && youtube) {
      const denied = state().tracking === 'denied';
      const disclosure = card.querySelector('p').innerHTML;
      const legal = `<div class="legal-links"><a href="https://policies.google.com/privacy" target="_blank" rel="noopener">${E(text('privacy'))}</a><a href="https://www.youtube.com/t/terms" target="_blank" rel="noopener">${E(text('terms'))}</a></div>`;
      card.innerHTML = `<strong>${E(text('title'))}</strong><p>${E(text(denied?'external':'summary'))}</p><details class="video-disclosure"><summary>${E(text('details'))}</summary><p>${disclosure}</p><p>${tr('uiYouCanTurnVideosOffInSettings')}</p>${denied?'':btn(E(text('setup')),'videoPermission','secondary in-app-video')}</details>${legal}`;
      youtube.classList.add('primary','permission-button');
      youtube.removeAttribute('style');
      card.querySelector('.video-disclosure').before(youtube);
    }
    return template.innerHTML;
  };

  action = value => {
    const s = state(), [name,index] = value.split(':');
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
