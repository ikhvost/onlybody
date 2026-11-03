/* v004 owns this adapter; earlier design versions remain frozen. */
(() => {
 if(new URLSearchParams(location.search).get('version')!=='v004')return;
 const style=document.createElement('link');style.rel='stylesheet';style.href='../v002/styles.css';document.head.append(style);
 // Copy is loaded synchronously by the runner before this extension.
 const extraCopy={planningHint:['Оцінка: 3 с на повтор + відпочинок після кожного підходу.','Estimate: 3 seconds per rep + rest after every set.','Szacunek: 3 s na powtórzenie + odpoczynek po każdej serii.','Schätzung: 3 s pro Wiederholung + Pause nach jedem Satz.','Estimation : 3 s par répétition + repos après chaque série.']};
 const c=key=>(extraCopy[key]??window.DESIGN_COPY[key])[['uk','en','pl','de','fr'].indexOf(language)];
 const ce=key=>E(c(key));
 const review=key=>window.WORKOUT_REVIEW_COPY[key][['uk','en','pl','de','fr'].indexOf(language)];
 const old={action,render,renderOverlay,direct,movementView,logView,saveCompleted,saveBuilder,start,makeBuilder,historyView,sessionView};
 routes.push(['creation','16','Спосіб створення','СТВОРЕННЯ'],['statistics','17','Статистика','ІСТОРІЯ'],['workout','18','Огляд тренування','ТРЕНУВАННЯ']);
 const header=(title,subtitle='')=>`<div class="page-heading">${subtitle?`<p class="eyebrow">${E(subtitle)}</p>`:''}<h1>${E(title)}</h1></div>`;
 const footer=content=>`<div class="sticky-actions">${content}</div>`;
 const secondary=(text,act)=>btn(E(text),act,'secondary');
 const primary=(text,act)=>btn(E(text),act,'primary');
 function creation(){return nav(t('uiNewSession'))+`<div class="scroll pad"><h1>${ce('choose')}</h1><div class="choice-list">${btn(`<span class="choice-icon">${icon('edit',28)}</span><strong>${ce('manual')}</strong><span>${ce('manualHint')}</span>`,'buildManual','choice-card')}${btn(`<span class="choice-icon">${icon('train',28)}</span><strong>${ce('smart')}</strong><span>${ce('smartHint')}</span>`,'chooseSmart','choice-card')}</div></div>`}
 bottom=()=>`<nav class="bottom-nav">${['train','log','library'].map(tab=>btn(icon(tab,24)+`<span>${ce(tab==='library'?'exercises':tab)}</span>`,'tab:'+tab,'tab '+(state().tab===tab?'selected':''),state().tab===tab?'aria-current="page"':'')).join('')}</nav>`;
 train=(empty=false)=>{
  const workouts=empty?[]:state().workouts,today=workouts.filter(w=>w.days.includes('Sat')),other=workouts.filter(w=>!w.days.includes('Sat'));
  const card=w=>`<article class="workout-card">${btn(`<div class="grow"><h2>${E(workoutName(w))}</h2><span class="meta">${E(t('uiWorkoutSummary',w.days.length?w.days.map(label).join(' · '):t('uiUnscheduled'),w.items.length))}</span></div>${icon('chevron',20)}`,'workout:'+w.id,'workout-open',`aria-label="${E(review('preview')+': '+workoutName(w))}"`)}<div class="card-actions">${secondary(c('edit'),'edit:'+w.id)}${btn(E(c('start'))+icon('play',18),'start:'+w.id,w.days.includes('Sat')?'primary':'secondary')}</div></article>`;
  return `<div class="home-heading"><div><p class="eyebrow">${product} / 31.10.2026</p><h1>${ce('train')}</h1></div><div class="home-actions">${btn(icon('settings',24),'settings','icon-button',`aria-label="${E(t('uiSettings'))}"`)}${btn(icon('plus',24),'create','icon-button create-top',`aria-label="${E(c('create'))}" title="${E(c('create'))}"`)}</div></div><div class="scroll pad home-content">${!workouts.length?`<div class="empty-state"><div class="empty-mark">${icon('train',40)}</div><h2>${tr('uiNoWorkoutsYet')}</h2><p>${ce('emptyHint')}</p>${primary(c('create'),'create')}</div>`:`<div class="section-heading"><h2>${tr('uiToday')}</h2></div>${today.length?today.map(card).join(''):`<div class="rest-day">${tr('uiRestDay')}</div>`}${other.length?`<div class="section-heading"><h2>${ce('other')}</h2></div>${other.map(card).join('')}`:''}`}</div>`;
 };
 const smartConfigurations=new WeakMap();
 const seconds=m=>Math.max(0,m.sets)*(Math.max(0,m.reps)*3+Math.max(0,m.rest));
 function fitBudget(items,minutes){let total=0;return items.filter(m=>{const duration=seconds(m);if(duration<=0||duration>minutes*60-total)return false;total+=duration;return true})}
 function refreshSmartPlan(b){
  if(b.mode==='manual'){b.duration=null;return}
  b.duration??=30;
  const config=JSON.stringify([b.targets,b.duration,b.rest]),previous=smartConfigurations.get(b);
  if(previous===undefined&&b.items.length){smartConfigurations.set(b,config)}
  else if(previous!==config){
   const upper=['Chest','Back','Shoulders','Biceps','Triceps','Forearms','Serratus','Core'];
   const lower=['Quads','Glutes','Hamstrings','Calves','Hip Flexors','Adductors'];
   const targets=b.targets.flatMap(g=>g==='Full Body'?muscles:g==='Upper'?upper:g==='Lower'?lower:g==='Arms'?['Biceps','Triceps','Forearms']:[g]);
   let pool=D.products[product].exercises.filter(e=>!targets.length||[...(e.primaryMuscles??[e.primaryMuscle]),...(e.secondaryMuscles??[])].some(g=>targets.includes(g)));
   const movements=list=>fitBudget(list.map(e=>({uid:crypto.randomUUID(),name:e.name,sets:3,reps:product==='OnlyWeights'?10:12,rest:b.rest})),b.duration);
   b.items=movements(pool);
   if(product==='OnlyBody'&&b.items.length<2)b.items=movements(pool.filter(e=>e.equipment.includes('None')));
   smartConfigurations.set(b,config);
  }
  if(state().overlay?.kind!=='movementEdit')b.items=fitBudget(b.items,b.duration);
 }
 builder=()=>{
  const s=state(),b=s.builder??(s.builder=structuredClone(freshState().workouts[0]));
  refreshSmartPlan(b);b.items.forEach(m=>m.uid??=crypto.randomUUID());
  return nav(t(b.id?'uiEditSession':'uiNewSession'),'builderBack')+`<div class="scroll pad builder-content"><label class="field-label" for="builder-name">${tr('uiSessionName')}</label><input class="text-field" id="builder-name" placeholder="${E(t('uiEGFullBody'))}" value="${E(workoutName(b))}" autocomplete="off"><div class="section-heading"><h2>${tr('uiMovements')}</h2>${b.mode==='manual'?btn(icon('plus',20)+tr('uiAdd'),'pickExercise','secondary'):''}</div>${b.mode==='manual'?(b.items.length?b.items.map(movementCard).join(''):`<div class="dashed-empty">${tr('uiNoMovementsYet')}</div>`):`<div class="info-card"><h2>${ce('smart')}</h2><p>${E(b.targets.map(label).join(', '))}</p>${secondary(c('targets'),'editTargets')}<p class="meta">${ce('simulation')}</p></div><div class="timing-grid">${btn(`<span>${tr('uiDuration')}</span><strong>${tr('uiMinutesCount',b.duration)}</strong>`,'timing:duration','timing-card')}${btn(`<span>${tr('uiSetRest')}</span><strong>${tr('uiSecondsCount',b.rest)}</strong>`,'timing:rest','timing-card')}</div>`}<details class="options" ${s.optionsOpen?'open':''}><summary>${ce('schedule')}</summary><div class="options-content"><p class="field-label">${ce('mode')}</p><div class="mode-buttons">${chip(c('manual'),'mode:manual',b.mode==='manual')}${chip(c('smart'),'mode:smart',b.mode==='smart')}</div>${b.mode==='manual'?`<div class="timing-grid rest-only">${btn(`<span>${tr('uiSetRest')}</span><strong>${tr('uiSecondsCount',b.rest)}</strong>`,'timing:rest','timing-card')}</div>`:''}<p class="field-label">${tr('uiTrainingDays')}</p><div class="days-grid">${days.map(d=>chip(label(d),'day:'+d,b.days.includes(d))).join('')}</div>${b.id?btn(tr('uiDeleteWorkout'),'delete','danger-button full'):''}</div></details>${b.items.length?`<div class="estimate"><span>${tr('uiEstDuration')}</span><strong>${tr('uiEstimatedMinutes',Math.max(1,Math.ceil(b.items.reduce((n,m)=>n+seconds(m),0)/60)))}</strong></div><p class="hint planning-hint">${ce('planningHint')}</p>`:''}</div>`+footer(primary(c('save'),'save'));
 };
 movementCard=(m,i)=>btn(`<div class="grow"><strong>${E(exName(m.name))}</strong><span class="meta">${E(t('uiMovementSummary',m.sets,m.reps,m.rest))}</span></div>${icon('chevron',20)}`,'editMovement:'+i,'movement-card',`aria-label="${E(exName(m.name)+'. '+c('editHint'))}"`);
 function numeric(key,value,kind,index=''){
  const labelText=key==='uiAddedWeight'?t(key,state().unit):t(key),min=kind==='rest'?15:kind.startsWith('active')?0:1;
  return `<div class="number-card"><label for="number-${kind}-${index}">${E(labelText)}</label><div class="number-control">${btn('−',`numberStep:${kind}:${index}:-1`,'number-step',`aria-label="${E(t('uiDecrease',labelText))}" ${value<=min?'disabled':''}`)}<input id="number-${kind}-${index}" data-number="${kind}" data-index="${index}" aria-label="${E(labelText)}" inputmode="${kind==='activeWeight'?'decimal':'numeric'}" value="${E(value)}" autocomplete="off">${btn('+',`numberStep:${kind}:${index}:1`,'number-step',`aria-label="${E(t('uiIncrease',labelText))}"`)}</div><p class="number-error" role="alert" hidden></p></div>`;
 }
 activeView=()=>{
  const s=state(),a=s.active;if(!a){start(s.workouts[0]??freshState().workouts[0],true);return activeView()}
  const m=a.workout.items[a.index],next=a.workout.items[a.index+1],showWeight=product==='OnlyWeights'||a.weight>0||a.showWeight;
  return `<div class="active-top"><div><span class="meta">${a.index+1} / ${a.workout.items.length}</span><span class="clock" data-timer="elapsed">${clock(a.elapsed)}</span></div>${btn(ce('end'),'endWorkout','end-button')}</div><div class="progress-bar"><i style="width:${a.index/a.workout.items.length*100}%"></i></div><div class="scroll pad active-content"><h1 class="active-title">${E(exName(m.name))}</h1><div class="set-progress">${tr('uiSetProgress',a.set+1,m.sets)}<span>${tr('uiTargetReps',m.reps)}</span></div><div class="active-numbers">${numeric('uiReps',a.reps,'activeReps')}${showWeight?numeric('uiAddedWeight',a.weight,'activeWeight'):secondary(c('addWeight'),'showWeight')}</div><div class="guide-actions">${btn(icon('library',20)+ce('technique'),'activeGuide')}${btn(icon('log',20)+ce('history'),'activeHistory')}</div><div class="active-navigation">${a.index?secondary(t('uiPrev'),'previousExercise'):''}${next?secondary(t('uiSkip'),'skipExercise'):''}</div></div><div class="active-bottom">${next?`<div class="active-up-next"><span>${tr('uiUpNext')}</span><strong>${E(exName(next.name))}</strong></div>`:''}${primary(t('uiMarkSetDone'),'markDone')}</div>`;
 };
 restView=()=>{const a=state().active,m=a.workout.items[a.index];return `<div class="rest-content"><div class="rest-heading">${icon('log',28)}<h1>${ce('rest')}</h1></div><div class="rest-time" data-timer="rest">${clock(a.restRemaining)}</div><div class="next-card"><p class="meta">${tr('uiSetProgress',a.set+1,m.sets)}</p><h2>${E(exName(m.name))}</h2><p>${tr('uiTargetReps',m.reps)}</p></div></div>`+footer(primary(t('uiSkipRest'),'skipRest'))};
 completeView=()=>{const a=state().active,sets=a?.completed.length??0;return `<div class="scroll pad complete-content"><div class="success-mark">✓</div><h1>${tr('uiSessionComplete')}</h1><div class="complete-time">${clock(a?.elapsed??0)}</div><div class="result-card"><span>${ce('sets')}</span><strong>${sets}</strong></div><p class="save-status ${a?.saveError?'error':''}" role="status">${E(a?.saveError?c('saveError'):sets?c('saved'):c('noSets'))}</p></div>`+footer(a?.saveError?primary(c('retry'),'retrySave'):primary(t('uiClose'),'closeWorkout'))};
 catalog=(picker=false)=>{
  const s=state(),query=picker?s.pickerSearch:s.search,f=picker?s.pickerFilter:s.filter,d=s[picker?'pickerEquipment':'equipment'],count=(f!=='All'?1:0)+(d?1:0);
  return (picker?nav(t('uiAddMovement'),'closePicker'):header(c('exercises')))+`<div class="catalog-controls"><div class="search-box">${icon('search',22)}<input id="catalog-search" aria-label="${E(t('uiSearch'))}" placeholder="${E(t('uiSearch'))}" value="${E(query)}" data-picker="${picker}" autocomplete="off"></div>${btn(ce('filters')+`<span class="filter-count">${count}</span>`,'openFilters:'+picker,'filter-button')}${count?`<p class="selected-filters">${E([f!=='All'?label(f):'',d?label(d):''].filter(Boolean).join(' · '))}</p>`:''}</div><div class="scroll" id="catalog-results">${catalogRows(picker)}</div>`;
 };
 filtered=(picker=false)=>{
  const s=state(),query=s[picker?'pickerSearch':'search'],group=s[picker?'pickerFilter':'filter'],equipment=s[picker?'pickerEquipment':'equipment'];
  return D.products[product].exercises.filter(e=>(!equipment||e.equipment.includes(equipment))&&(group==='All'||(e.primaryMuscles??[e.primaryMuscle]).includes(group)||e.primaryMuscle===group)&&(exName(e)+' '+e.name+' '+label(e.primaryMuscle)+' '+e.equipment.map(label).join(' ')).toLocaleLowerCase(locale()).includes(query.toLocaleLowerCase(locale()))).sort((a,b)=>exName(a).localeCompare(exName(b),locale()));
 };
 catalogRows=picker=>{const list=filtered(picker);return list.length?list.map(e=>btn(`<div class="grow"><strong>${E(exName(e))}</strong><span class="meta">${E(label(e.primaryMuscle)+' · '+e.equipment.map(label).join(', '))}</span></div>${icon(picker?'plus':'chevron',20)}`,`${picker?'addExercise':'movement'}:${D.products[product].exercises.indexOf(e)}`,'exercise-row')).join(''):`<div class="empty-state"><h2>${tr('uiNoMovementsFound')}</h2>${secondary(c('clear'),'resetFilters:'+picker)}</div>`};
 movementView=()=>{
  // Reorder existing content without rewriting any consent, link, or attribution.
  const template=document.createElement('template');template.innerHTML=old.movementView();
  const scroll=template.content.querySelector('.scroll'),title=scroll.querySelector('.movement-title'),equipment=scroll.querySelector('.equipment'),anatomy=scroll.querySelector('.anatomy');
  let primaryLabel=[...scroll.children].find(n=>n.classList.contains('mono')&&n.textContent===t('uiPrimaryMuscles'));
  const pieces=[];if(primaryLabel){let n=primaryLabel;while(n){const next=n.nextElementSibling;pieces.push(n);if(n===anatomy)break;n=next}}
  let anchor=title;for(const el of [equipment,...pieces].filter(Boolean)){anchor.after(el);anchor=el}
  return template.innerHTML;
 };
 logView=()=>{
  const template=document.createElement('template');template.innerHTML=old.logView();
  const scroll=template.content.querySelector('.scroll');scroll.classList.add('log-with-statistics');
  scroll.querySelector('.page-heading').outerHTML=header(c('log'));
  scroll.querySelectorAll('.stat .mono').forEach((label,index)=>{label.textContent=review(['streak','best','sessions'][index])});
  return template.innerHTML;
 };
 function workoutOverview(){
  const workout=state().workouts.find(item=>item.id===state().workoutId);
  if(!workout)return nav(review('overview'))+`<div class="empty-state"><p>${E(review('unavailable'))}</p></div>`;
  const catalog=D.products[product].exercises;
  const summary=summarizeWorkoutMuscles(workout,catalog);
  const maximum=summary.ranked[0]?.sets??1;
  const anatomy={primaryMuscles:summary.ranked.map(item=>item.muscle),secondaryMuscles:summary.secondary};
  const muscles=summary.ranked.length?`
   <div class="muscle-ranking">${summary.ranked.map(({muscle,sets})=>`<div class="muscle-rank"><div><span>${E(label(muscle))}</span><strong>${sets}</strong></div><div class="rank-track" aria-hidden="true"><span style="width:${sets/maximum*100}%"></span></div></div>`).join('')}</div>
   <p class="meta ranking-basis">${E(review('basis'))}</p>
   <div class="anatomy"><div class="anatomy-labels">${mono(t('uiFront'))}${mono(t('uiRearView'))}</div><div class="anatomy-picture"><img src="assets/muscle-anatomy.png" alt="${E(t('uiMuscleGroupsFrontAndBackViews'))}">${muscleSVG(anatomy)}</div><div class="anatomy-legend"><span><i class="marker"></i> ${E(review('included'))}</span><span><i class="marker secondary"></i> ${E(review('assisting'))}</span></div></div>`:`<p class="hint">${E(review('noMuscles'))}</p>`;
  const items=workout.items.map((item,index)=>{
   const exercise=catalog.find(ex=>ex.name===item.name);
   const primary=exercise?(exercise.primaryMuscles?.length?exercise.primaryMuscles:[exercise.primaryMuscle]).filter(Boolean):[];
   const content=`<span class="workout-order">${index+1}</span><div class="grow"><strong>${E(exercise?exName(exercise):item.name)}</strong><span class="meta">${E(t('uiMovementSummary',item.sets,item.reps,item.rest))}</span><span class="exercise-muscles">${E(primary.map(label).join(' · '))}</span></div>${exercise?icon('chevron',20):''}`;
   return exercise?btn(content,'movement:'+catalog.indexOf(exercise),'overview-exercise'):`<div class="overview-exercise">${content}</div>`;
  }).join('');
  return nav(review('overview'))+`<div class="scroll pad workout-overview"><h1>${E(workoutName(workout))}</h1><p class="meta">${E(t('uiWorkoutSummary',workout.days.length?workout.days.map(label).join(' · '):t('uiUnscheduled'),workout.items.length))}</p>${summary.ranked.length?`<div class="overview-focus"><span>${E(review('focus'))}</span><strong>${E(summary.ranked.filter(item=>item.sets===maximum).map(item=>label(item.muscle)).join(' · '))}</strong></div>`:''}<div class="overview-count"><span>${E(review('plannedSets'))}</span><strong>${summary.totalSets}</strong></div><div class="section-heading"><h2>${E(review('plan'))}</h2></div><div class="overview-exercises">${items||`<p class="hint">${tr('uiNoMovementsYet')}</p>`}</div><div class="section-heading"><h2>${E(review('focus'))}</h2><span class="meta">${E(review('plannedSets'))}</span></div>${muscles}${summary.missing?`<p class="hint">${E(review('unknown'))}</p>`:''}</div>`+footer(`<div class="overview-actions">${secondary(c('edit'),'edit:'+workout.id)}${btn(E(c('start'))+icon('play',18),'start:'+workout.id,'primary',workout.items.length?'':'disabled')}</div>`);
 }
 function statistics(){const template=document.createElement('template');template.innerHTML=old.logView();return nav(c('statistics'))+`<div class="scroll statistics">${template.content.querySelector('.log-stats').outerHTML}${template.content.querySelector('.heatmap-block').outerHTML}</div>`}
 render=function(preserve=false){
  if(['creation','statistics','workout'].includes(state().route)){
   $('#app').innerHTML=state().route==='creation'?creation():state().route==='workout'?workoutOverview():statistics();renderOverlay();renderMap();
  }else old.render(preserve);
  document.documentElement.lang=language;
  const options=document.querySelector('details.options');if(options)options.addEventListener('toggle',()=>{state().optionsOpen=options.open});
 };
 renderOverlay=function(){
  const s=state(),o=s.overlay;
  if(!o||!['movementEdit','filters'].includes(o.kind)){old.renderOverlay();isolateModal();return}
  let content='';
  if(o.kind==='movementEdit'){
   const m=s.builder.items[o.index];content=nav(exName(m.name),'closeOverlay')+`<div class="scroll pad">${numeric('uiSets',m.sets,'sets',o.index)}${numeric('uiReps',m.reps,'reps',o.index)}${numeric('uiRest',m.rest,'rest',o.index)}${btn(ce('remove'),'removeMovement:'+o.index,'danger-button full')}</div>`+footer(primary(t('uiDone'),'closeOverlay'));
  }else{
   const picker=o.picker,f=picker?s.pickerFilter:s.filter,d=s[picker?'pickerEquipment':'equipment'];
   content=nav(c('filters'),'closeFilters')+`<div class="scroll pad"><h2>${ce('muscles')}</h2><div class="chip-wrap">${['All',...muscles].map(m=>chip(label(m),`filter:${picker}:${m}`,f===m)).join('')}</div><h2>${tr('uiEquipment')}</h2><div class="chip-wrap">${chip(label('All'),`equipment:${picker}:all`,!d)}${[...new Set(D.products[product].exercises.flatMap(e=>e.equipment))].sort((a,b)=>label(a).localeCompare(label(b),locale())).map(equipment=>chip(label(equipment),`equipment:${picker}:${equipment}`,d===equipment)).join('')}</div>${secondary(c('clear'),'resetFilters:'+picker)}</div>`+footer(primary(c('apply'),'closeFilters'));
  }
  $('#overlay').innerHTML=`<div class="device-overlay"><section class="sheet design-sheet" role="dialog" aria-modal="true" aria-label="${E(o.kind==='filters'?c('filters'):exName(s.builder.items[o.index].name))}"><div class="sheet-handle"></div>${content}</section></div>`;isolateModal();
 };
 function isolateModal(){const modal=!!state().overlay;$('#app').inert=modal;document.querySelector('.home-indicator').style.visibility=modal?'hidden':'';const dialog=$('#overlay [role]');if(dialog){dialog.setAttribute('aria-modal','true');if(!dialog.contains(document.activeElement))dialog.querySelector('button,input')?.focus({preventScroll:true})}}
 function commitNumber(input){
  const kind=input.dataset.number,index=Number(input.dataset.index),raw=input.value.trim().replace(',','.'),value=Number(raw),min=kind==='rest'?15:kind.startsWith('active')?0:1;
  const valid=/^\d+(\.\d{1,2})?$/.test(raw)&&Number.isFinite(value)&&value>=min&&(kind==='activeWeight'||Number.isSafeInteger(value));
  input.setAttribute('aria-invalid',String(!valid));const error=input.closest('.number-card').querySelector('.number-error');error.hidden=valid;error.textContent=valid?'':c('numberError')+(min?` (≥ ${min})`:'');
  if(!valid)return false;
  if(kind==='activeReps')state().active.reps=value;else if(kind==='activeWeight')state().active.weight=value;else{if(state().builder.items[index][kind]!==value){state().builder.items[index][kind]=value;state().dirty=true}}
  return true;
 }
 function commitVisible(){return [...document.querySelectorAll('[data-number]')].map(commitNumber).every(Boolean)}
 action=function(value){
  const s=state(),[name,...parts]=value.split(':');
  if(['markDone','closeOverlay','save','endWorkout','skipExercise','previousExercise','activeGuide','activeHistory'].includes(name)&&!commitVisible())return;
  switch(name){
   case 'mode':s.builder.mode=parts[0];refreshSmartPlan(s.builder);s.dirty=true;render(true);return;
   case 'setTiming':{const field=s.overlay.field;if(field==='duration'&&s.builder.mode==='manual')return;s.builder[field]=Number(parts[0]);if(field==='rest')s.builder.items.forEach(m=>m.rest=s.builder.rest);refreshSmartPlan(s.builder);s.dirty=true;renderOverlay();return}
   case 'equipment':s[parts[0]==='true'?'pickerEquipment':'equipment']=parts.slice(1).join(':')==='all'?null:parts.slice(1).join(':');renderOverlay();return;
   case 'closeOverlay':s.overlay=null;render(true);return;
   case 'pickExercise':s.pickerEquipment=null;break;
   case 'workout':open('workout',{workoutId:parts[0]});return;
   case 'create':if(s.route==='train-empty'){s.workouts=[];s.sessions=[]}s.muscles=[];open('creation');return;
   case 'chooseSmart':open('musclePicker');return;
   case 'editTargets':s.muscles=[...s.builder.targets];s.editingTargets=true;open('musclePicker');return;
   case 'buildSmart':if(s.editingTargets){s.builder.targets=[...s.muscles];s.editingTargets=false;s.dirty=true;back();return}break;
   case 'buildManual':s.muscles=[];s.editingTargets=false;break;
   case 'editMovement':s.overlay={kind:'movementEdit',index:Number(parts[0])};renderOverlay();return;
   case 'removeMovement':alertOverlay(c('remove'),c('removeQuestion'),[{label:c('remove'),action:'confirmRemove:'+parts[0],danger:true},{label:t('uiCancel'),action:'editMovement:'+parts[0]}]);return;
   case 'confirmRemove':s.builder.items.splice(Number(parts[0]),1);s.dirty=true;s.overlay=null;render(true);return;
   case 'showWeight':s.active.showWeight=true;render(true);return;
   case 'numberStep':{
    if(!commitVisible())return;const [kind,index,sign]=parts;const item=kind.startsWith('active')?s.active:s.builder.items[Number(index)];const key=kind==='activeReps'?'reps':kind==='activeWeight'?'weight':kind;const min=kind==='rest'?15:kind.startsWith('active')?0:1;const step=kind==='rest'?15:kind==='activeWeight'?(s.unit==='lb'?5:2.5):1;
    item[key]=Math.round(Math.max(min,item[key]+Number(sign)*step)*100)/100;if(!kind.startsWith('active'))s.dirty=true;if(s.overlay)renderOverlay();else render(true);return;
   }
   case 'openFilters':s.overlay={kind:'filters',picker:parts[0]==='true',returnPicker:s.overlay?.kind==='exercisePicker'};renderOverlay();return;
   case 'closeFilters':{const returnPicker=s.overlay?.returnPicker,returnReplacement=s.overlay?.returnReplacement;s.overlay=returnReplacement??(returnPicker?{kind:'exercisePicker'}:null);render(true);return}
   case 'resetFilters':{const picker=parts[0]==='true';s[picker?'pickerFilter':'filter']='All';s[picker?'pickerEquipment':'equipment']=null;s[picker?'pickerSearch':'search']='';if(s.overlay?.returnReplacement)s.overlay.returnReplacement.query='';render(true);return}
   case 'statistics':open('statistics');return;
   case 'retrySave':s.failSave=false;saveCompleted();render();return;
   case 'saveAndEnd':saveCompleted();s.overlay=null;s.route='complete';render();return;
   case 'markDone':{
    const a=s.active;const existing=a.completed.findIndex(x=>x.index===a.index&&x.set===a.set);const entry={index:a.index,set:a.set,reps:a.reps,weight:a.weight};if(existing>=0)a.completed.splice(existing,1);a.completed.push(entry);a.set++;
    if(a.set>=a.workout.items[a.index].sets)finishExercise();else{a.restRemaining=a.workout.items[a.index].rest;s.route='rest';render()}return;
   }
   case 'setUnit':{
    const unit=parts[0];if(unit!==s.unit){const factor=unit==='lb'?2.2046226218:1/2.2046226218;const cv=v=>Math.round(v*factor*100)/100;if(s.active){s.active.weight=cv(s.active.weight);s.active.completed.forEach(x=>x.weight=cv(x.weight))}s.sessions.forEach(session=>session.items.forEach(m=>{m.weight=cv(m.weight||0);if(m.setWeights)m.setWeights=m.setWeights.map(cv)}));s.unit=unit}s.overlay=null;render(true);return;
   }
  }
  old.action(value);
 };
 saveCompleted=function(){const s=state(),a=s.active;if(!a||a.saved)return;if(!a.completed.length){a.saveError=false;return}if(s.failSave){a.saveError=true;return}a.saveError=false;old.saveCompleted();if(a.saved){for(const item of s.sessions[0].items){const index=a.workout.items.findIndex(m=>m.name===item.name);item.setWeights=a.completed.filter(x=>x.index===index).map(x=>x.weight)}}};
 start=function(workout,preview=false){old.start(workout,preview);if(preview){const a=state().active;a.completed=[{index:0,set:0,reps:a.reps,weight:0}]}};
 direct=function(route){
  if(route==='workout')state().workoutId=state().workouts[0]?.id;
  old.direct(route);
  if(route==='complete'){
   const a=state().active;
   a.completed=a.workout.items.flatMap((m,index)=>Array.from({length:m.sets},(_,set)=>({index,set,reps:m.reps,weight:product==='OnlyWeights'?50:0})));
   saveCompleted();render();
  }
 };
 // Preserve the established simulations, but make prototype validation errors localized.
 saveBuilder=function(){const s=state();if(!workoutName(s.builder).trim()){alertOverlay(t('uiSessionName'),t('uiEGFullBody'),[{label:t('uiDone'),action:'closeOverlay'}]);return}refreshSmartPlan(s.builder);if(s.builder.mode==='smart'&&!s.builder.items.length){alertOverlay(t('uiMovements'),t('uiNoMovementsFound'),[{label:t('uiClose'),action:'closeOverlay'}]);return}old.saveBuilder()};
 for(const host of [$('#app'),$('#overlay')]){
  host.addEventListener('change',event=>{if(event.target.matches('[data-number]'))commitNumber(event.target)});
  host.addEventListener('keydown',event=>{if(event.key==='Enter'&&event.target.matches('[data-number]')){commitNumber(event.target);event.target.blur()}});
 }
 document.addEventListener('keydown',event=>{
  if(event.key==='Tab'&&state().overlay){const nodes=[...$('#overlay').querySelectorAll('button:not(:disabled),input,a[href],summary')];const first=nodes[0],last=nodes.at(-1);if(event.shiftKey&&document.activeElement===first){event.preventDefault();last?.focus()}else if(!event.shiftKey&&document.activeElement===last){event.preventDefault();first?.focus()}}
 },true);
 render();
})();
