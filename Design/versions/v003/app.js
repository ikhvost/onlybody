/* v003: session-local draft and stable exercise / set identities. */
(() => {
 if(new URLSearchParams(location.search).get('version')!=='v003')return;
 const link=document.createElement('link');link.rel='stylesheet';link.href='../v003/styles.css';document.head.append(link);
 const words={
 today:['Сьогоднішнє заняття','Today’s session','Dzisiejsza sesja','Heutiges Training','Séance du jour'],
 start:['Почати','Start','Rozpocznij','Starten','Commencer'],resume:['Продовжити','Resume','Kontynuuj','Fortsetzen','Continuer'],
 current:['Поточна','Current','Bieżące','Aktuell','En cours'],done:['Виконано','Completed','Ukończone','Abgeschlossen','Terminée'],next:['Далі','Upcoming','Następne','Als Nächstes','À venir'],
 replace:['Замінити','Replace','Zamień','Ersetzen','Remplacer'],up:['Вище','Move up','W górę','Nach oben','Monter'],down:['Нижче','Move down','W dół','Nach unten','Descendre'],
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
 reorderHint:['Перетягни ручку або скористайся стрілками','Drag the handle or use the arrows','Przeciągnij uchwyt lub użyj strzałek','Griff ziehen oder Pfeile nutzen','Faites glisser la poignée ou utilisez les flèches']
 };
 const c=k=>words[k][['uk','en','pl','de','fr'].indexOf(language)],ce=k=>E(c(k));
 const old={action,render,renderOverlay,direct,historyView,builder};
 const id=()=>crypto.randomUUID();
 function prepare(workout,started=false){
  const copy=structuredClone(workout);copy.items.forEach(m=>{m.uid=id();m.rows=Array.from({length:m.sets},()=>({id:id(),reps:m.reps,weight:0,done:false}));m.showWeight=false});
  state().active={workout:copy,started,currentId:copy.items[0]?.uid,viewId:copy.items[0]?.uid,elapsed:0,restRemaining:0,completed:[],index:0};
 }
 const active=()=>state().active;
 const item=()=>active()?.workout.items.find(m=>m.uid===active().viewId);
 const complete=m=>m.rows.every(r=>r.done);
 const allDone=()=>active().workout.items.every(complete);
 function sync(){const a=active();a.index=a.workout.items.findIndex(m=>m.uid===a.viewId);a.completed=a.workout.items.flatMap((m,index)=>m.rows.flatMap((r,set)=>r.done?[{index,set,reps:r.reps,weight:r.weight}]:[]))}
 function rest(){const a=active();return a?.started&&a.restRemaining>0?`<div class="rest-strip" role="status"><div><span>${ce('rest')}</span><strong data-timer="rest">${clock(a.restRemaining)}</strong></div>${btn('+'+E(t('uiSecondsCount',15)),'restPlus','secondary',`aria-label="${E(t('uiRest'))} +15 s"`)}${btn(ce('skip'),'restSkip','secondary')}</div>`:''}
 function tools(m,i,scope,list){const locked=scope==='session'&&m.rows.some(r=>r.done);return `<div class="exercise-tools">${btn('↑',`moveItem:${scope}:${i}:-1`,'tool',`aria-label="${ce('up')}: ${E(exName(m.name))}" ${i===0?'disabled':''}`)}${btn('↓',`moveItem:${scope}:${i}:1`,'tool',`aria-label="${ce('down')}: ${E(exName(m.name))}" ${i===list.length-1?'disabled':''}`)}${btn(ce('replace'),`replaceItem:${scope}:${i}`,'secondary',locked?'disabled':'')}</div>${locked?`<p class="lock-reason">${ce('locked')}</p>`:''}`}
 function sessionView3(){
  const a=active();if(!a)return nav(t('uiWorkoutNotFound'),'leaveDraft')+`<div class="empty-state">${tr('uiWorkoutNotFound')}</div>`;
  const count=a.completed.length;
  return `<div class="session-header"><div>${a.started?`<span class="clock" data-timer="elapsed">${clock(a.elapsed)}</span>`:btn(icon('back',20),'leaveDraft','icon-button',`aria-label="${E(t('uiBack'))}"`)}<span class="meta">${ce('today')}</span></div>${btn(ce(a.started?'resume':'start'),a.started?'resumeSession':'beginSession','primary',allDone()||!a.workout.items.length?'disabled':'')}</div>${rest()}<div class="scroll pad session-list"><h1>${E(workoutName(a.workout))}</h1><p class="hint">${ce('local')}</p><p class="meta">${ce('reorderHint')}</p>${allDone()?`<p class="ready-banner" role="status">${ce('ready')}</p>`:''}<div class="session-items">${a.workout.items.map((m,i)=>`<article class="session-card ${a.started&&m.uid===a.currentId?'is-current':''}" data-item="${i}" data-scope="session"><div class="session-card-top">${btn('⠿','noop','drag-handle',`draggable="true" data-drag="session:${i}" aria-label="${ce('drag')}: ${E(exName(m.name))}"`)}${btn(`<span class="meta">${i+1} · ${ce(complete(m)?'done':m.uid===a.currentId&&a.started?'current':'next')}</span><strong>${E(exName(m.name))}</strong><span class="meta">${m.rows.filter(r=>r.done).length} / ${m.sets} · ${E(t('uiTargetReps',m.reps))}</span>`,`viewItem:${m.uid}`,'session-item-open')}</div>${tools(m,i,'session',a.workout.items)}</article>`).join('')}</div></div>${a.started?`<div class="sticky-actions">${btn(ce('finish')+` · ${count}`,'endWorkout','primary')}</div>`:''}`;
 }
 activeView=()=>{
  const a=active();if(!a){prepare(state().workouts[0]??freshState().workouts[0],true);return activeView()}
  const m=item(),weight=product==='OnlyWeights'||m.showWeight;
  return nav('', 'sessionList',`<span class="clock" data-timer="elapsed">${clock(a.elapsed)}</span>`)+rest()+`<div class="scroll pad set-content"><p class="eyebrow">${ce(!a.started?'preview':complete(m)?'done':m.uid===a.currentId?'current':'next')}</p><h1>${E(exName(m.name))}</h1><p class="meta">${E(t('uiTargetReps',m.reps))} · ${E(t('uiSecondsCount',m.rest))}</p><div class="guide-actions">${btn(icon('library',20)+ce('guide'),'activeGuide')}${btn(icon('log',20)+ce('history'),'activeHistory')}</div>${!weight?btn(ce('add'),'showRowWeight','secondary'):''}<div class="set-table ${weight?'with-weight':''}"><div class="set-head"><span>${ce('set')}</span><span>${ce('reps')}</span>${weight?`<span>${E(state().unit)}</span>`:''}<span>✓</span></div>${m.rows.map((r,i)=>`<div class="set-row ${r.done?'is-done':''}"><span>${i+1}</span><input data-row="${r.id}" data-field="reps" aria-label="${ce('reps')} ${i+1}" inputmode="numeric" value="${r.reps}">${weight?`<input data-row="${r.id}" data-field="weight" aria-label="${E(state().unit)} ${i+1}" inputmode="decimal" value="${r.weight}">`:''}${btn(r.done?'✓':'',`toggleSet:${r.id}`,'set-check',`aria-label="${ce(r.done?'undo':'mark')} ${i+1}" aria-pressed="${r.done}" ${!a.started?'disabled':''}`)}</div>`).join('')}</div><p class="row-error" role="alert" hidden>${ce('number')}</p></div>`;
 };
 restView=activeView;
 movementCard=(m,i)=>`<article class="session-card" data-item="${i}" data-scope="builder"><div class="session-card-top">${btn('⠿','noop','drag-handle',`draggable="true" data-drag="builder:${i}" aria-label="${ce('drag')}: ${E(exName(m.name))}"`)}${btn(`<strong>${E(exName(m.name))}</strong><span class="meta">${E(t('uiMovementSummary',m.sets,m.reps,m.rest))}</span>`,'editMovement:'+i,'session-item-open')}</div>${tools(m,i,'builder',state().builder.items)}</article>`;
 builder=()=>{const html=old.builder(),b=state().builder;if(b.mode==='manual'||!b.items.length)return html;const template=document.createElement('template');template.innerHTML=html;const info=template.content.querySelector('.info-card');if(info)info.insertAdjacentHTML('beforebegin',b.items.map(movementCard).join(''));return template.innerHTML};
 historyView=()=>{if(active())sync();return old.historyView()};
 render=function(preserve=false){if(state().route==='workout'){const scroll=$('#app .scroll')?.scrollTop??0;$('#app').innerHTML=sessionView3();renderOverlay();renderMap();if(preserve)$('#app .scroll').scrollTop=scroll;document.documentElement.lang=language}else old.render(preserve)};
 renderOverlay=function(){
  const o=state().overlay;if(o?.kind!=='replacement'){old.renderOverlay();return}
  const query=o.query??'',list=D.products[product].exercises;
  $('#overlay').innerHTML=`<div class="device-overlay"><section class="sheet replacement-sheet" role="dialog" aria-modal="true" aria-label="${ce('replace')}"><div class="sheet-handle"></div>${nav(c('replace'),'cancelReplace')}<div class="search-box"><input id="replace-search" aria-label="${E(t('uiSearch'))}" placeholder="${E(t('uiSearch'))}" value="${E(query)}"></div><div class="scroll" id="replace-results">${replacementRows(list,query)}</div></section></div>`;$('#app').inert=true;$('#replace-search').focus();
 };
 function replacementRows(list,q){return list.flatMap((e,i)=>exName(e).toLocaleLowerCase().includes(q.toLocaleLowerCase())?[btn(`<strong>${E(exName(e))}</strong>`,'selectReplace:'+i,'exercise-row')]:[]).join('')||`<p class="hint">${tr('uiNoMovementsFound')}</p>`}
 function validRows(){let valid=true;document.querySelectorAll('[data-row]').forEach(input=>{const raw=input.value.trim().replace(',','.'),n=Number(raw),ok=/^\d+(\.\d{1,2})?$/.test(raw)&&Number.isFinite(n)&&n>=0&&(input.dataset.field==='weight'||Number.isSafeInteger(n));input.setAttribute('aria-invalid',!ok);if(ok){const r=item().rows.find(r=>r.id===input.dataset.row);r[input.dataset.field]=n}else valid=false});const error=$('.row-error');if(error)error.hidden=valid;if(valid&&active())sync();return valid}
 action=function(value){
  const s=state(),[name,...p]=value.split(':'),a=active();
  if(document.querySelector('[data-row]')&&!validRows())return;
  switch(name){
   case 'noop':return;
   case 'workout':case 'start':{const w=s.workouts.find(w=>w.id===p[0]);if(!w)return;prepare(w);s.stack=[];s.route='workout';render();return}
   case 'leaveDraft':s.active=null;s.route='train';render();return;
   case 'beginSession':if(!a.workout.items.length)return;a.started=true;a.currentId=a.workout.items[0].uid;a.viewId=a.currentId;s.stack=[];s.route='active';sync();render();return;
   case 'resumeSession':a.viewId=a.currentId;s.route='active';sync();render();return;
   case 'sessionList':s.route='workout';s.stack=[];render();return;
   case 'viewItem':a.viewId=p[0];s.route='active';sync();render();return;
   case 'showRowWeight':item().showWeight=true;render(true);return;
   case 'toggleSet':{
    if(!a.started)return;const m=item(),r=m.rows.find(r=>r.id===p[0]);r.done=!r.done;
    if(r.done){a.restRemaining=m.rest;if(m.uid===a.currentId&&complete(m)){const index=a.workout.items.indexOf(m),ordered=[...a.workout.items.slice(index+1),...a.workout.items.slice(0,index)];const next=ordered.find(m=>!complete(m));a.currentId=next?.uid??null;if(next)a.viewId=next.uid}}
    if(!a.currentId&&!allDone())a.currentId=a.workout.items.find(m=>!complete(m)).uid;
    if(allDone())s.route='workout';sync();render(true);return;
   }
   case 'restPlus':a.restRemaining+=15;render(true);return;
   case 'restSkip':a.restRemaining=0;render(true);return;
   case 'moveItem':{
    const [scope,from,delta]=p,list=scope==='builder'?s.builder.items:a.workout.items,i=Number(from),to=i+Number(delta);if(to<0||to>=list.length)return;list.splice(to,0,list.splice(i,1)[0]);if(scope==='builder')s.dirty=true;else sync();render(true);return;
   }
   case 'replaceItem':{const [scope,index]=p,m=(scope==='builder'?s.builder.items:a.workout.items)[Number(index)];if(scope==='session'&&m.rows.some(r=>r.done))return;s.overlay={kind:'replacement',scope,index:Number(index),query:''};renderOverlay();return}
   case 'cancelReplace':s.overlay=null;renderOverlay();return;
   case 'selectReplace':{const o=s.overlay,list=o.scope==='builder'?s.builder.items:a.workout.items,m=list[o.index];m.name=D.products[product].exercises[Number(p[0])].name;if(o.scope==='builder')s.dirty=true;else{m.rows.forEach(r=>{r.reps=m.reps;r.weight=0;r.done=false});m.showWeight=false;sync()}s.overlay=null;render(true);return}
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
 let touchDrag=null;
 document.addEventListener('pointerdown',e=>{const handle=e.target.closest('[data-drag]');if(handle&&e.pointerType==='touch'){touchDrag={source:handle.dataset.drag,x:e.clientX,y:e.clientY};handle.setPointerCapture(e.pointerId)}});
 document.addEventListener('pointermove',e=>{if(!touchDrag)return;const scroll=$('#app .scroll');if(scroll){const r=scroll.getBoundingClientRect();if(e.clientY>r.bottom-60)scroll.scrollTop+=12;if(e.clientY<r.top+60)scroll.scrollTop-=12}});
 document.addEventListener('pointerup',e=>{if(!touchDrag)return;const drag=touchDrag;touchDrag=null;const target=document.elementFromPoint(e.clientX,e.clientY)?.closest('[data-item]'),[scope,from]=drag.source.split(':');if(target&&target.dataset.scope===scope&&Math.hypot(e.clientX-drag.x,e.clientY-drag.y)>10)action(`moveItem:${scope}:${from}:${Number(target.dataset.item)-Number(from)}`)});
 document.addEventListener('pointercancel',()=>touchDrag=null);
 for(const host of [$('#app'),$('#overlay')]){
  host.addEventListener('input',e=>{if(e.target.id==='replace-search'){const o=state().overlay;o.query=e.target.value;$('#replace-results').innerHTML=replacementRows(D.products[product].exercises,o.query)}});
  host.addEventListener('change',e=>{if(e.target.matches('[data-row]'))validRows()});
  host.addEventListener('dragstart',e=>{const handle=e.target.closest('[data-drag]');if(handle)e.dataTransfer.setData('text/plain',handle.dataset.drag);else e.preventDefault()});
  host.addEventListener('dragover',e=>{if(e.target.closest('[data-item]'))e.preventDefault()});
  host.addEventListener('drop',e=>{const target=e.target.closest('[data-item]');if(!target)return;e.preventDefault();const [scope,from]=e.dataTransfer.getData('text/plain').split(':');if(scope===target.dataset.scope)action(`moveItem:${scope}:${from}:${Number(target.dataset.item)-Number(from)}`)});
 }
 setInterval(()=>{const a=active();if(!a)return;if(!a.started&&state().route!=='complete')a.elapsed=0;if(a.started&&a.restRemaining>0){a.restRemaining--;const n=$('[data-timer="rest"]');if(n)n.textContent=clock(a.restRemaining);if(!a.restRemaining&&['active','workout'].includes(state().route))render(true)}},1000);
})();
