/* v008: session-local draft and stable exercise / set identities. */
(() => {
 if(new URLSearchParams(location.search).get('version')!=='v008')return;
 const link=document.createElement('link');link.rel='stylesheet';link.href='../v008/layout.css';document.head.append(link);
 const words={
 today:['Сьогоднішнє заняття','Today’s session','Dzisiejsza sesja','Heutiges Training','Séance du jour'],
 start:['Почати','Start','Rozpocznij','Starten','Commencer'],resume:['Продовжити','Resume','Kontynuuj','Fortsetzen','Continuer'],
 current:['Поточна','Current','Bieżące','Aktuell','En cours'],done:['Виконано','Completed','Ukończone','Abgeschlossen','Terminée'],next:['Далі','Upcoming','Następne','Als Nächstes','À venir'],
 replace:['Замінити','Replace','Zamień','Ersetzen','Remplacer'],
 drag:['Змінити порядок','Reorder','Zmień kolejność','Reihenfolge ändern','Réorganiser'],
 locked:['Заміна доступна без виконаних підходів','Replace only before completing any sets','Zamiana przed wykonaniem serii','Ersetzen vor dem ersten erledigten Satz','Remplacement avant toute série terminée'],
 ready:['Усі підходи виконано. Перевір результати й заверши заняття.','All sets complete. Review your results and finish.','Wszystkie serie ukończone. Sprawdź wyniki i zakończ.','Alle Sätze erledigt. Ergebnisse prüfen und beenden.','Toutes les séries sont terminées. Vérifiez puis terminez.'],
 finish:['Завершити','Finish','Zakończ','Beenden','Terminer'],rest:['Відпочинок','Rest','Odpoczynek','Pause','Repos'],skip:['Пропустити','Skip','Pomiń','Überspringen','Passer'],
 add:['Додати вагу','Add weight','Dodaj ciężar','Gewicht hinzufügen','Ajouter une charge'],
 guide:['Гайд','Guide','Instrukcja','Anleitung','Guide'],history:['Історія','History','Historia','Verlauf','Historique'],
 set:['Підхід','Set','Seria','Satz','Série'],reps:['Повтори','Reps','Powtórzenia','Wdh.','Rép.'],
 local:['Зміни лише для цього заняття','Changes apply to this session only','Zmiany tylko w tej sesji','Änderungen nur für dieses Training','Modifications pour cette séance uniquement'],
 preview:['Перегляд · заняття ще не розпочато','Preview · session not started','Podgląd · sesja nierozpoczęta','Vorschau · Training noch nicht gestartet','Aperçu · séance non commencée'],
 mark:['Позначити виконаним','Mark complete','Oznacz jako ukończone','Als erledigt markieren','Marquer terminée'],undo:['Зняти галочку','Uncheck','Odznacz','Markierung entfernen','Décocher'],
 number:['Введи коректне невід’ємне число','Enter a valid nonnegative number','Wpisz poprawną liczbę nieujemną','Gültige nichtnegative Zahl eingeben','Saisissez un nombre positif ou nul'],
 historyError:['Не вдалося завантажити попередні результати.','Couldn’t load previous results.','Nie udało się wczytać poprzednich wyników.','Frühere Ergebnisse konnten nicht geladen werden.','Impossible de charger les résultats précédents.'],
 retry:['Спробувати знову','Try again','Spróbuj ponownie','Erneut versuchen','Réessayer'],
 recordedWeight:['Збережена вага вправи','Recorded exercise weight','Zapisany ciężar ćwiczenia','Gespeichertes Übungsgewicht','Charge enregistrée pour l’exercice']
 };
 const c=k=>words[k][['uk','en','pl','de','fr'].indexOf(language)],ce=k=>E(c(k));
 const old={action,render,renderOverlay,direct,historyView,sessionView,movementView,builder};
 const id=()=>crypto.randomUUID();
 const originalFreshState=freshState;
 function withPerSetFixtures(s){s.sessions.forEach(session=>session.items.forEach(m=>{m.setWeights=m.setReps.map((_,index)=>Math.max(0,m.weight-(product==='OnlyWeights'&&index===2?2.5:0)))}));return s}
 freshState=()=>withPerSetFixtures(originalFreshState());
 withPerSetFixtures(state());

 function previousPerformance(m){
  if(state().failHistory)return null;
  const sessions=[...state().sessions].sort((a,b)=>new Date(b.date)-new Date(a.date)||a.id.localeCompare(b.id));
  for(const session of sessions){const matches=session.items.filter(item=>item.name===m.name&&item.setReps?.length);if(matches.length)return matches[Math.min(m.occurrence??0,matches.length-1)]}
  return null;
 }
 function initialRow(m,index){
  const previous=previousPerformance(m),at=previous?Math.min(index,previous.setReps.length-1):0;
  return {reps:previous?.setReps[at]??m.reps,weight:previous?.setWeights?.[at]??previous?.weight??0};
 }
 function resetRows(m){
  m.rows=Array.from({length:m.sets},(_,index)=>({id:id(),...initialRow(m,index),done:false,edited:false}));
  m.showWeight=m.rows.some(r=>r.weight>0);
 }
 function prepare(workout,started=false){
  const copy=structuredClone(workout),occurrences=new Map();
  copy.items.forEach(m=>{m.uid=id();m.occurrence=occurrences.get(m.name)??0;occurrences.set(m.name,m.occurrence+1);resetRows(m)});
  state().active={workout:copy,started,currentId:copy.items[0]?.uid,viewId:copy.items[0]?.uid,elapsed:0,restRemaining:0,completed:[],index:0,historyError:!!state().failHistory};
 }
 const active=()=>state().active;
 const item=()=>active()?.workout.items.find(m=>m.uid===active().viewId);
 const complete=m=>m.rows.every(r=>r.done);
 const allDone=()=>active().workout.items.every(complete);
 function sync(){const a=active();a.index=a.workout.items.findIndex(m=>m.uid===a.viewId);a.completed=a.workout.items.flatMap((m,index)=>m.rows.flatMap((r,set)=>r.done?[{index,set,reps:r.reps,weight:r.weight}]:[]))}
 function rest(){const a=active();return a?.started&&a.restRemaining>0?`<div class="rest-strip" role="status"><div><span>${ce('rest')}</span><strong data-timer="rest">${clock(a.restRemaining)}</strong></div>${btn('+'+E(t('uiSecondsCount',15)),'restPlus','secondary',`aria-label="${E(t('uiRest'))} +15 s"`)}${btn(ce('skip'),'restSkip','secondary')}</div>`:''}
 function tools(m,scope){
  const locked=scope==='session'&&m.rows.some(row=>row.done);
  const arrows='<svg class="icon replace-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M7 19V5M3 9L7 5L11 9M17 5V19M13 15L17 19L21 15"/></svg>';
  return btn(arrows,`replaceExercise:${scope}:${m.uid}`,'item-replace',`aria-label="${ce('replace')}: ${E(exName(m.name))}" aria-haspopup="dialog" ${locked?`disabled aria-description="${ce('locked')}"`:''}`);
 }
 function reorderHandle(m,i,scope,list){
  const dots='<svg class="icon reorder-icon" viewBox="0 0 24 24" aria-hidden="true"><g fill="currentColor" stroke="none">'+[9,15].flatMap(x=>[6,12,18].map(y=>`<circle cx="${x}" cy="${y}" r="1"/>`)).join('')+'</g></svg>';
  return btn(dots,'noop','drag-handle',`draggable="false" data-drag="${scope}:${i}" role="spinbutton" aria-valuemin="1" aria-valuemax="${list.length}" aria-valuenow="${i+1}" aria-label="${ce('drag')}: ${E(exName(m.name))}"`);
 }
 function sessionView3(){
  const a=active();if(!a)return nav(t('uiWorkoutNotFound'),'leaveDraft')+`<div class="empty-state">${tr('uiWorkoutNotFound')}</div>`;
  return `<div class="session-header">${a.started?'<span></span>':btn(icon('back',20),'leaveDraft','icon-button nav-control',`data-navigation="back" aria-label="${E(t('uiBack'))}"`)}${btn(ce(a.started?'resume':'start'),a.started?'resumeSession':'beginSession','primary',allDone()||!a.workout.items.length?'disabled':'')}</div>${a.started?`<div class="session-elapsed" data-timer="elapsed">${clock(a.elapsed)}</div>`:''}${rest()}<div class="scroll pad session-list"><p class="eyebrow">${ce('today')}</p><h1>${E(workoutName(a.workout))}</h1><p class="meta session-note">${ce('local')}</p>${historyNotice()}${allDone()?`<p class="ready-banner" role="status">${ce('ready')}</p>`:''}<div class="session-items">${a.workout.items.map((m,i)=>`<article class="session-card" data-item="${i}" data-key="${m.uid}" data-scope="session"><div class="session-card-top">${reorderHandle(m,i,'session',a.workout.items)}${btn(`<span class="meta">${ce(complete(m)?'done':m.uid===a.currentId?'current':'next')}</span><strong>${E(exName(m.name))}</strong><span class="meta">${E(t('uiSetProgress',m.rows.filter(r=>r.done).length,m.sets))}</span>`,`viewItem:${m.uid}`,'session-item-open')}${tools(m,'session')}</div></article>`).join('')}</div></div>${a.started?`<div class="sticky-actions">${btn(E(t('uiEndWorkout')),'endWorkout','primary')}</div>`:''}`;
 }
 activeView=()=>{
  const a=active();if(!a){prepare(state().workouts[0]??freshState().workouts[0],true);return activeView()}
  const m=item(),weight=product==='OnlyWeights'||m.showWeight;
  return nav('', 'sessionList',a.started?`<span class="clock" data-timer="elapsed">${clock(a.elapsed)}</span>`:'')+rest()+`<div class="scroll pad set-content">${historyNotice()}<p class="eyebrow">${ce(!a.started?'preview':complete(m)?'done':m.uid===a.currentId?'current':'next')}</p><h1>${E(exName(m.name))}</h1><p class="meta">${E(t('uiTargetReps',m.reps))} · ${E(t('uiSecondsCount',m.rest))}</p><div class="guide-actions">${btn(icon('library',20)+ce('guide'),'activeGuide')}${btn(icon('log',20)+ce('history'),'activeHistory')}</div>${!weight?btn(ce('add'),'showRowWeight','secondary'):''}<div class="set-table ${weight?'with-weight':''}"><div class="set-head"><span>${ce('set')}</span><span>${ce('reps')}</span>${weight?`<span>${E(state().unit)}</span>`:''}<span class="completion-heading">${E(controlLabel('done'))}</span></div>${m.rows.map((r,i)=>`<div class="set-row ${r.done?'is-done':''}"><span>${i+1}</span><input data-row="${r.id}" data-field="reps" aria-label="${ce('reps')} ${i+1}" inputmode="numeric" value="${r.reps}">${weight?`<input data-row="${r.id}" data-field="weight" aria-label="${E(state().unit)} ${i+1}" inputmode="decimal" value="${r.weight}">`:''}${btn('<span aria-hidden="true">✓</span>',`toggleSet:${r.id}`,'set-check',`aria-label="${ce(r.done?'undo':'mark')} ${i+1}" aria-pressed="${r.done}" ${!a.started?'disabled':''}`)}</div>`).join('')}</div><p class="row-error" role="alert" hidden>${ce('number')}</p></div>`;
 };
 restView=activeView;
 movementCard=(m,i)=>`<article class="session-card" data-item="${i}" data-key="${m.uid}" data-scope="builder"><div class="session-card-top">${reorderHandle(m,i,'builder',state().builder.items)}${btn(`<strong>${E(exName(m.name))}</strong><span class="meta">${E(t('uiMovementSummary',m.sets,m.reps,m.rest))}</span>`,'editMovement:'+i,'session-item-open')}${tools(m,'builder')}</div></article>`;

 function historyNotice(){return active()?.historyError?`<div class="history-notice" role="status"><p>${ce('historyError')}</p>${btn(ce('retry'),'retryHistory','secondary')}</div>`:''}
 const weightText=value=>value===null||value===undefined?'—':new Intl.NumberFormat(locale(),{maximumFractionDigits:2}).format(value)+' '+state().unit;
 const legacyWeight=m=>!m.setWeights?.length&&m.weight!=null?`<p class="meta legacy-weight">${ce('recordedWeight')}: ${E(weightText(m.weight))}</p>`:'';
 const resultRows=m=>(m.setReps??[]).map((rep,index)=>`<div class="history-set"><span>${E(t('uiSetReps',index+1,rep))}</span><strong>${E(weightText(m.setWeights?.[index]))}</strong></div>`).join('')+legacyWeight(m);
 sessionView=()=>{
  const template=document.createElement('template');template.innerHTML=old.sessionView();
  const session=currentSession();template.content.querySelectorAll('.session-item').forEach((node,index)=>{const m=session.items[index];node.innerHTML=`<div class="row spread"><strong>${E(exName(m.name))}</strong>${mono(t('uiTotalReps',(m.setReps??[]).reduce((a,b)=>a+b,0)))}</div>${resultRows(m)}`});
  return template.innerHTML;
 };
 historyView=()=>{
  if(active())sync();const s=state(),name=active()?item().name:s.exerciseName;
  const entries=[...s.sessions].sort((a,b)=>new Date(b.date)-new Date(a.date)).flatMap(session=>session.items.filter(m=>m.name===name).map(item=>({session,item})));
  return nav('','back','',false,true)+`<div class="scroll pad"><h1 class="movement-title">${E(exName(name))}</h1>${entries.length?mono(t('uiSessions'),'muted'):`<strong>${tr('uiNoCompletedSetsYet')}</strong><p class="hint">${tr('uiAfterYouSaveAWorkoutWithThisExerciseItsDate')}</p>`}${entries.slice(0,20).map(({session,item})=>`<div class="history-entry">${mono(new Date(session.date).toLocaleDateString(locale(),{month:'short',day:'numeric',year:'numeric'}),'muted')}<h2>${E(workoutName(session))}</h2>${resultRows(item)}</div>`).join('')}</div>`;
 };
 movementView=()=>{const template=document.createElement('template');template.innerHTML=old.movementView();template.content.querySelector('.scroll>.badge')?.remove();return template.innerHTML};
 render=function(preserve=false){if(window.v008Reorder?.isDragging())return;if(state().route==='workout'){const scroll=$('#app .scroll')?.scrollTop??0;$('#app').innerHTML=sessionView3();renderOverlay();renderMap();if(preserve)$('#app .scroll').scrollTop=scroll;document.documentElement.lang=language}else old.render(preserve)};
 renderOverlay=function(){
  const o=state().overlay;if(o?.kind!=='replacement'){old.renderOverlay();return}
  const query=o.query??'',list=D.products[product].exercises;
  $('#overlay').innerHTML=`<div class="device-overlay"><section class="sheet replacement-sheet" role="dialog" aria-modal="true" aria-label="${ce('replace')}"><div class="sheet-handle"></div>${nav(c('replace'),'cancelReplace')}<div class="replacement-controls"><div class="search-box">${icon('search',22)}<input id="replace-search" aria-label="${E(t('uiSearch'))}" placeholder="${E(t('uiSearch'))}" value="${E(query)}"></div>${filterControl('replacementFilters',(state().pickerFilter!=='All'?1:0)+(state().pickerEquipment?1:0))}</div><div class="scroll" id="replace-results">${replacementRows(list,query)}</div></section></div>`;$('#app').inert=true;$('#replace-search').focus();
 };
 function replacementRows(list,q){return list.flatMap((e,i)=>(!state().pickerEquipment||e.equipment.includes(state().pickerEquipment))&&(state().pickerFilter==='All'||(e.primaryMuscles??[e.primaryMuscle]).includes(state().pickerFilter))&&(exName(e)+' '+e.name).toLocaleLowerCase(locale()).includes(q.toLocaleLowerCase(locale()))?[btn(`<strong>${E(exName(e))}</strong>`,'selectReplace:'+i,'exercise-row')]:[]).join('')||`<p class="hint">${tr('uiNoMovementsFound')}</p>`}
 function validRows(){let valid=true;document.querySelectorAll('[data-row]').forEach(input=>{const raw=input.dataset.initialZero==='true'?'0':input.value.trim().replace(',','.'),n=Number(raw),ok=/^\d+(\.\d{1,2})?$/.test(raw)&&Number.isFinite(n)&&n>=0&&(input.dataset.field==='weight'||Number.isSafeInteger(n));input.setAttribute('aria-invalid',!ok);if(ok){const r=item().rows.find(r=>r.id===input.dataset.row);if(r[input.dataset.field]!==n)r.edited=true;r[input.dataset.field]=n}else valid=false});const error=$('.row-error');if(error)error.hidden=valid;if(valid&&active())sync();return valid}
 action=function(value){
  const s=state(),[name,...p]=value.split(':'),a=active();
  if(document.querySelector('[data-row]')&&!validRows())return;
  switch(name){
   case 'noop':return;
   case 'retryHistory':s.failHistory=false;a.historyError=false;a.workout.items.forEach(m=>{m.rows.forEach((r,index)=>{if(!r.edited&&!r.done)Object.assign(r,initialRow(m,index))});m.showWeight=m.showWeight||m.rows.some(r=>r.weight>0)});sync();render(true);return;
   case 'setUnit':{
    const unit=p[0];if(unit!==s.unit){const factor=unit==='lb'?2.2046226218:1/2.2046226218,convert=value=>value==null?value:Math.round(value*factor*100)/100;
     a?.workout.items.forEach(m=>m.rows.forEach(r=>r.weight=convert(r.weight)));
     s.sessions.forEach(session=>session.items.forEach(m=>{m.weight=convert(m.weight);if(m.setWeights)m.setWeights=m.setWeights.map(convert)}));s.unit=unit;if(a)sync()
    }s.overlay=null;render(true);return;
   }
   case 'replacementFilters':s.overlay={kind:'filters',picker:true,returnReplacement:s.overlay};renderOverlay();return;
   case 'workout':case 'start':{const w=s.workouts.find(w=>w.id===p[0]);if(!w)return;prepare(w);s.stack=[];s.route='workout';render();return}
   case 'leaveDraft':s.active=null;s.route='train';render();return;
   case 'beginSession':if(!a.workout.items.length)return;a.started=true;a.currentId=a.workout.items[0].uid;a.viewId=a.currentId;s.stack=[];s.route='active';sync();render();return;
   case 'resumeSession':a.viewId=a.currentId;s.route='active';sync();render();return;
   case 'sessionList':s.route='workout';s.stack=[];render();return;
   case 'viewItem':a.viewId=p[0];s.route='active';sync();render();return;
   case 'showRowWeight':item().showWeight=true;render(true);return;
   case 'toggleSet':{
    if(!a.started)return;const m=item(),r=m.rows.find(r=>r.id===p[0]);r.done=!r.done;r.edited=true;
    if(r.done){a.restRemaining=m.rest;if(m.uid===a.currentId&&complete(m)){const index=a.workout.items.indexOf(m),ordered=[...a.workout.items.slice(index+1),...a.workout.items.slice(0,index)];const next=ordered.find(m=>!complete(m));a.currentId=next?.uid??null;if(next)a.viewId=next.uid}}
    if(!a.currentId&&!allDone())a.currentId=a.workout.items.find(m=>!complete(m)).uid;
    if(allDone())s.route='workout';sync();render(true);return;
   }
   case 'restPlus':a.restRemaining+=15;render(true);return;
   case 'restSkip':a.restRemaining=0;render(true);return;
   case 'moveItem':{
    const [scope,from,delta]=p,list=scope==='builder'?s.builder.items:a.workout.items,i=Number(from),to=i+Number(delta);if(to<0||to>=list.length)return;const before=window.v008Reorder?.measure();list.splice(to,0,list.splice(i,1)[0]);if(scope==='builder')s.dirty=true;else sync();render(true);window.v008Reorder?.animate(before);return;
   }
   case 'replaceItem':{const [scope,index]=p,m=(scope==='builder'?s.builder.items:a.workout.items)[Number(index)];if(scope==='session'&&m.rows.some(r=>r.done))return;s.pickerEquipment=null;s.pickerFilter='All';s.overlay={kind:'replacement',scope,index:Number(index),query:''};renderOverlay();return}
   case 'cancelReplace':s.overlay=null;renderOverlay();return;
   case 'selectReplace':{const o=s.overlay,list=o.scope==='builder'?s.builder.items:a.workout.items,m=list[o.index];m.name=D.products[product].exercises[Number(p[0])].name;if(o.scope==='builder')s.dirty=true;else{m.occurrence=list.slice(0,o.index).filter(other=>other.name===m.name).length;resetRows(m);sync()}s.overlay=null;render(true);return}
   case 'activeGuide':sync();open('movement',{exerciseName:item().name});return;
   case 'activeHistory':sync();open('exerciseHistory');return;
   case 'saveAndEnd':a.started=false;a.restRemaining=0;sync();break;
   case 'discardWorkout':case 'closeWorkout':s.stack=[];break;
   case 'back':if(s.route==='workout'&&a?.started)return;break;
  }
  old.action(value);
 };
 saveCompleted=function(){
  const s=state(),a=active();if(!a||a.saved)return;
  sync();if(!a.completed.length){a.saveError=false;return}if(s.failSave){a.saveError=true;return}
  const items=a.workout.items.flatMap(m=>{const rows=m.rows.filter(r=>r.done);return rows.length?[{name:m.name,sets:m.sets,reps:m.reps,rest:m.rest,setReps:rows.map(r=>r.reps),setWeights:rows.map(r=>r.weight),weight:rows[0].weight}]:[]});
  s.sessions.unshift({id:'session-'+id(),nameKey:a.workout.nameKey,name:a.workout.name,date:new Date().toISOString(),duration:Math.max(a.elapsed,1),items});a.saveError=false;a.saved=true;
 };
 direct=function(route){
  if(route==='workout'&&!state().workouts.length){state().active=null;state().route=route;render();return}

  if(['workout','active','rest','complete','exerciseHistory'].includes(route)){
   prepare(state().workouts[0]??freshState().workouts[0],route!=='workout');const a=active();if(route==='rest')a.restRemaining=45;
   if(route==='complete'){a.workout.items.forEach(m=>m.rows.forEach(r=>r.done=true));sync();a.started=false;saveCompleted()}
   state().route=route==='rest'?'active':route;state().overlay=null;state().stack=[];render();return;
  }old.direct(route);
 };
 for(const host of [$('#app'),$('#overlay')]){
  host.addEventListener('input',e=>{if(e.target.id==='replace-search'){const o=state().overlay;o.query=e.target.value;$('#replace-results').innerHTML=replacementRows(D.products[product].exercises,o.query)}});
  host.addEventListener('change',e=>{if(e.target.matches('[data-row]'))validRows()});
  host.addEventListener('input',e=>{if(e.target.matches('[data-row]')){const row=item().rows.find(r=>r.id===e.target.dataset.row);row.edited=true;validRows()}});

 }
 window.v008Ready=Promise.all(['reorder.js','input.js','navigation.js'].map(file=>new Promise((resolve,reject)=>{const script=document.createElement('script');script.src='../v008/'+file;script.onload=resolve;script.onerror=reject;document.head.append(script)})));
 setInterval(()=>{const a=active();if(!a)return;if(!a.started&&state().route!=='complete')a.elapsed=0;if(a.started&&a.restRemaining>0){a.restRemaining--;const n=$('[data-timer="rest"]');if(n)n.textContent=clock(a.restRemaining);if(!a.restRemaining)document.querySelector('.rest-strip')?.remove()}},1000);
})();
