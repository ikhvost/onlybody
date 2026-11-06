/* Smart Selection interaction prototype. Fixture rules are NOT the production generator. */
(() => {
  if (new URLSearchParams(location.search).get('version') !== 'v008') return;
  for(const [name,entries] of Object.entries(SMART_CATALOG.catalogs)) D.products[name].exercises=entries;
  Object.assign(D.catalogLabels,SMART_CATALOG.labels);
  for(const [lang,entries] of Object.entries(SMART_CATALOG.translations))Object.assign(D.strings[lang],entries);
  const old = {action, render, direct, train, settingsView, musclePicker};
  const copy = key => window.SMART_COPY[key][['uk','en','pl','de','fr'].indexOf(language)];
  const text = key => E(copy(key));
  const button = (key, actionName, style='secondary', extra='') => btn(text(key),actionName,style,extra);
  const levels = ['beginner','intermediate','advanced'];
  const areas = ['foot','knee','hip','back','shoulder','elbow','wrist'];
  const loads = ['jumps','palms','knees','overhead','standing'];
  const localKey = () => 'only-smart-v008:'+product;
  const pool = () => SMART_FIXTURES[product];
  const toggle = (values,value) => values.includes(value) ? values.filter(v=>v!==value) : [...values,value];
  const clone = value => structuredClone(value);
  const date = () => { const d=new Date();d.setDate(d.getDate()+model().offset);return [d.getFullYear(),String(d.getMonth()+1).padStart(2,'0'),String(d.getDate()).padStart(2,'0')].join('-'); };
  function defaults() { return {id:'smart-demo',name:'',targets:['Lower'],minutes:30,level:'beginner',equipment:[],gym:true,loads:[],excluded:[],days:['Mon','Wed','Fri'],revision:1}; }
  function model() {
    const s=state();
    if (!s.smart) {
      let stored=null;try { stored=JSON.parse(localStorage.getItem(localKey())); } catch {}
      s.smart=stored?.schema===1?stored:{schema:1,config:defaults(),plans:{},anchors:[],offset:0,level:'beginner'};
      s.smart.offset??=0;
    }
    return s.smart;
  }
  function persist() {try {localStorage.setItem(localKey(),JSON.stringify(model()));state().smartStorageError=false;return true;}catch {state().smartStorageError=true;return false;} }
  const config = () => state().smartDraft || model().config;
  const configName = c => c.name || c.targets.map(label).join(' · ');
  const expand = targets => targets.flatMap(g=>g==='Full Body'?['Chest','Back','Quads','Glutes','Core']:g==='Upper'?['Chest','Back','Shoulders']:g==='Lower'?['Quads','Glutes','Hamstrings','Calves']:g==='Arms'?['Biceps','Triceps','Forearms']:[g]);
  function requirements(c) {
    if(c.targets.includes('Full Body'))return ['push','pull','squat','hinge','core'];
    if(c.targets.includes('Upper'))return ['push','pull'];
    if(c.targets.includes('Lower'))return ['squat','hinge'];
    return expand(c.targets);
  }
  const covers = (e,need) => ['push','pull','squat','hinge','core'].includes(need)?e.movement===need:(e.primaryMuscles||[e.primaryMuscle]).includes(need);
  function eligible(e,c,ignoreLoads=false) {
    return levels.indexOf(e.difficulty)<=levels.indexOf(c.level) && !c.excluded.includes(e.name)
      && (product==='OnlyWeights'&&c.gym || e.equipment.every(item=>item==='None'||c.equipment.includes(item)))
      && (ignoreLoads || !e.loads.some(load=>c.loads.includes(load)));
  }
  function prescription(e,c) {
    const main=e.role==='main', beginner=c.level==='beginner';
    return {...clone(e),uid:crypto.randomUUID(),sets:main?(c.level==='advanced'?4:3):(beginner?2:3),reps:main?(beginner?10:8):12,rest:main?90:60,weight:0};
  }
  const seconds = e => e.transition + e.sets*(e.reps*e.repSeconds*(e.rule==='side'?2:1)+e.rest);
  function generate(c) {
    const candidates=pool().filter(e=>eligible(e,c));
    const selected=[], gaps=[], families=new Set();
    const needs=requirements(c);let total=0;
    for(const need of needs) {
      if(selected.some(e=>covers(e,need)))continue;
      const matches=candidates.filter(e=>covers(e,need)&&!families.has(e.family));
      matches.sort((a,b)=>(model().anchors.includes(b.name)?1:0)-(model().anchors.includes(a.name)?1:0)||(a.role==='main'?0:1)-(b.role==='main'?0:1));
      const e=matches.map(e=>prescription(e,c)).find(e=>total+seconds(e)<=c.minutes*60);
      if(!e){gaps.push(need);continue;}selected.push(e);families.add(e.family);total+=seconds(e);
    }
    const targetMuscles=expand(c.targets), extras=candidates.filter(e=>e.role==='accessory'&&(e.primaryMuscles||[e.primaryMuscle]).some(m=>targetMuscles.includes(m)));
    const rotation=extras.length?Number(date().replaceAll('-',''))%extras.length:0;
    for(const e of [...extras.slice(rotation),...extras.slice(0,rotation)]) {
      const item=prescription(e,c);if(families.has(e.family)||total+seconds(item)>c.minutes*60)continue;
      selected.push(item);families.add(e.family);total+=seconds(item);if(selected.length>=6)break;
    }
    selected.sort((a,b)=>(a.role==='main'?0:1)-(b.role==='main'?0:1));
    return {date:date(),revision:c.revision,items:selected,gaps,seconds:total};
  }
  const planKey = c => `${c.id}:${date()}:${c.revision}`;
  function plan() {
    const s=state(),c=config();
    if(s.smartDraft) return s.smartPreview??(s.smartPreview=generate(c));
    const m=model(),key=planKey(c);
    if(!m.plans[key]) {m.plans[key]=generate(c);m.anchors=m.plans[key].items.filter(e=>e.role==='main').map(e=>e.name);persist();}
    return m.plans[key];
  }
  function invalidate() {state().smartPreview=null;}
  function draft(existing=false) {
    const s=state();s.smartEditing=existing;s.smartDraft=existing?clone(model().config):{...defaults(),id:crypto.randomUUID(),targets:[...s.muscles],level:model().level,days:[]};
    invalidate();
  }
  function saveDraft() {
    const s=state();if(!s.smartDraft)return persist();
    const preview=clone(plan());const c=clone(s.smartDraft);c.revision=model().config.revision+1;
    model().config=c;model().level=c.level;preview.revision=c.revision;model().plans[planKey(c)]=preview;model().anchors=preview.items.filter(e=>e.role==='main').map(e=>e.name);
    s.smartDraft=null;s.smartPreview=null;s.smartEditing=false;return persist();
  }
  function shell(title,content,footer='',backAction='smartBack') {
    return nav(copy(title),backAction)+`<div class="scroll pad smart-content">${state().smartStorageError?`<div class="smart-warning" role="alert">${text('storageError')}${button('retry','smartSave')}</div>`:''}${content}</div>`+(footer?`<div class="sticky-actions smart-footer">${footer}</div>`:'');
  }
  const step = n => `<div class="smart-progress" aria-label="${n} / 3"><span class="eyebrow">SMART SELECTION</span><span>${n} / 3</span></div><div class="smart-progress-track" aria-hidden="true"><i style="width:${n/3*100}%"></i></div>`;
  const hint = key => `<p class="smart-hint">${text(key)}</p>`;
  const selectedLoads = c => c.loads.length?c.loads.map(copy).join(' · '):copy('none');
  function setup() {
    const c=config();return shell('setup',step(2)+`<h1>${text('setupHint')}</h1><p class="accent">${E(c.targets.map(label).join(' · '))}</p><section><h2>${text('duration')}</h2><div class="smart-durations">${[15,30,45,60].map(n=>chip(t('uiMinutesCount',n),'smartMinutes:'+n,c.minutes===n)).join('')}</div>${hint('timeHint')}</section><section><h2>${text('level')}</h2><div class="smart-levels">${levels.map((level,i)=>btn(`<span class="level-mark" aria-hidden="true">${'▮'.repeat(i+1)}</span><strong>${text(level)}</strong><span class="smart-radio" aria-hidden="true">${c.level===level?'●':'○'}</span>`,'smartLevel:'+level,'smart-option '+(c.level===level?'selected':''),`aria-pressed="${c.level===level}"`)).join('')}</div>${hint('levelHint')}</section>`,button('next','smartOptions','primary')+button('cancel','smartCancel','secondary full'));
  }
  function options() {
    const c=config();
    return shell('options',step(3)+`<h1>${text('options')}</h1><p class="meta">${text('optional')}</p><section><h2>${text('equipment')}</h2>${hint(product==='OnlyBody'?'bodyEquipment':'gymEquipment')}${product==='OnlyWeights'?`<div class="smart-equipment-mode">${chip(copy('gym'),'smartGym:true',c.gym)}${chip(copy('customEquipment'),'smartGym:false',!c.gym)}</div>`:''}${product==='OnlyBody'||!c.gym?btn(`<span><strong>${text('customEquipment')}</strong><span class="meta">${c.equipment.length?E(c.equipment.map(label).join(' · ')):text('none')}</span></span>${icon('chevron',20)}`,'smartEquipmentPanel','smart-summary'):''}</section><section><div class="section-heading"><h2>${text('restrictions')}</h2></div>${btn(`<span><strong>${text('regions')}</strong><span class="meta">${E(selectedLoads(c))}</span></span>${icon('chevron',20)}`,'smartRegions','smart-summary')}${hint('noSafety')}</section>${c.excluded.length?`<section><h2>${text('excluded')}</h2>${c.excluded.map((name,i)=>`<div class="smart-excluded"><span>${E(exName(name))}</span>${button('restore','smartRestore:'+i)}</div>`).join('')}</section>`:''}`,button('preview','smartPreview','primary'));
  }
  function card(e,i) {
    return `<article class="smart-exercise"><div class="smart-exercise-number">${String(i+1).padStart(2,'0')}</div><div class="grow">${btn(`<span class="smart-role ${e.role}">${text(e.role)}</span><strong>${E(exName(e.name))}</strong>`,'smartGuide:'+i,'smart-exercise-open')}<p class="meta">${e.sets} × ${e.reps}${e.rule==='side'?' '+text('eachSide'):e.rule==='cycle'?' '+text('cycle'):''} · ${E(t('uiSecondsCount',e.rest))}</p><p class="smart-muscles">${E((e.primaryMuscles||[e.primaryMuscle]).map(label).join(' · '))}</p></div>${btn('<svg class="icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M7 19V5M3 9l4-4 4 4M17 5v14m-4-4 4 4 4-4"/></svg>','smartReplace:'+i,'item-replace',`aria-label="${text('replace')}: ${E(exName(e.name))}"`)}</article>`;
  }
  function today() {
    const c=config(),p=plan(),gaps=p.gaps.length;
    const status=`<div class="smart-date"><span class="eyebrow">${text('today')}</span><span>${E(new Date(p.date+'T12:00:00').toLocaleDateString(locale(),{day:'numeric',month:'short'}))}</span></div>`;
    const summary=`<div class="smart-metrics"><div><strong>≈ ${Math.ceil(p.seconds/60)}</strong><span>${text('estimate')}<br>${text('budget')}: ${E(t('uiMinutesCount',c.minutes))}</span></div><div><strong>${p.items.length}</strong><span>${E(t('uiMovements'))}</span></div></div>`;
    const gap=gaps?`<div class="smart-warning" role="status"><h2>${text('gap')}</h2><p>${p.gaps.map(need=>E(SMART_COPY[need]?copy(need):label(need))).join(' · ')}</p>${hint('gapHint')}${button('change','smartEdit')}</div>`:'';
    return shell('smart',status+`<h1>${E(configName(c))}</h1><div class="smart-tags"><span>${text(c.level)}</span><span>${E(t('uiMinutesCount',c.minutes))}</span><span>${text('smart')}</span></div>${summary}${gap}<div class="smart-daily-note">${icon('log',20)}${hint('dailyHint')}</div><div class="section-heading"><h2>${E(t('uiMovements'))}</h2>${button('settings','smartEdit')}</div><div class="smart-exercises">${p.items.map(card).join('')}</div>${btn(`<span>${text('schedule')}</span>${icon('chevron',20)}`,'smartSchedule','smart-summary')}`,`${state().smartDraft?button('save','smartSave','primary',gaps?'disabled':''):button('start','smartStart','primary',gaps||!p.items.length?'disabled':'')}`,'smartExit');
  }
  function overlay(content,title,backAction='smartDismiss') {
    state().overlay={kind:'smart',backAction};$('#overlay').innerHTML=`<div class="device-overlay"><section class="sheet design-sheet smart-sheet glass-enter" role="dialog" aria-modal="true" aria-label="${text(title)}"><div class="sheet-handle"></div>${nav(copy(title),backAction)}${content}</section></div>`;$('#app').inert=true;$('#overlay button')?.focus({preventScroll:true});
  }
  function equipmentPanel() {
    const equipment=[...new Set(D.products[product].exercises.flatMap(e=>e.equipment))].filter(e=>e!=='None');
    overlay(`<div class="scroll pad smart-content">${hint(product==='OnlyBody'?'bodyEquipment':'gymEquipment')}<div class="chip-wrap">${equipment.map(e=>chip(label(e),'smartEquipmentDraft:'+e,state().equipmentDraft.includes(e))).join('')}</div></div><div class="sticky-actions">${button('apply','smartEquipmentApply','primary')}</div>`,'equipment');
  }
  function regions() {
    overlay(`<div class="scroll pad smart-content">${hint('regionHint')}<div class="smart-levels">${areas.map(a=>btn(`<strong>${text(a)}</strong>${icon('chevron',20)}`,'smartArea:'+a,'smart-option')).join('')}</div></div>`,'regions');
  }
  function loadPanel(area) {
    state().smartArea=area;
    state().loadDraft??=[...config().loads];
    overlay(`<div class="scroll pad smart-content"><h1>${text(area)}</h1>${hint('regionHint')}<div class="smart-levels">${loads.map(l=>btn(`<strong>${text(l)}</strong><span aria-hidden="true">${state().loadDraft.includes(l)?'✓':'○'}</span>`,'smartLoad:'+l,'smart-option '+(state().loadDraft.includes(l)?'selected':''),`aria-pressed="${state().loadDraft.includes(l)}"`)).join('')}</div>${hint('noSafety')}</div><div class="sticky-actions">${button('confirmLoads','smartConfirmLoads','primary')}</div>`,'restrictions','smartRegions');
  }
  function currentPlanItems() {return state().active?.smart ? state().active.workout.items : plan().items;}
  function replacementReason(index) {
    state().smartReplacement={index,active:!!state().active?.smart};
    overlay(`<div class="scroll pad smart-content"><h1>${E(exName(currentPlanItems()[index].name))}</h1><h2>${text('reason')}</h2><div class="smart-levels">${button('unavailable','smartAlternatives:equipment','smart-option')}${button('another','smartAlternatives:another','smart-option')}</div>${hint('local')}<div class="smart-divider"></div>${button('permanent','smartPermanent','danger-button full')}</div>`,'replace');
  }
  function alternatives(reason,showConflicts=false) {
    const s=state(),r=s.smartReplacement;r.reason=reason;const list=currentPlanItems(),item=list[r.index],c=s.active?.smart?s.active.smartConfig:config();
    const alternatives=pool().filter(e=>e.name!==item.name&&e.movement===item.movement&&!list.some(m=>m.name===e.name)&&eligible(e,c,showConflicts)&&(reason!=='equipment'||!e.equipment.some(eq=>eq!=='None'&&item.equipment.includes(eq)))&&(s.active?.started||list.reduce((sum,m)=>sum+seconds(m),0)-seconds(item)+seconds({...prescription(e,c),sets:item.sets,reps:item.reps,rest:item.rest})<=c.minutes*60));
    const rows=alternatives.map(e=>{const conflict=e.loads.filter(l=>c.loads.includes(l));return btn(`<span><strong>${E(exName(e.name))}</strong><span class="meta ${conflict.length?'conflict-text':''}">${conflict.length?text('conflict')+': '+conflict.map(copy).map(E).join(', '):E(e.equipment.map(label).join(' · '))}</span></span>${icon('chevron',20)}`,'smartSelect:'+pool().indexOf(e),'smart-option');}).join('');
    overlay(`<div class="scroll pad smart-content">${hint('local')}${rows||hint('noAlternatives')}${c.loads.length&&!showConflicts?button('conflicts','smartConflicts','secondary full'):''}</div>`,'alternatives','smartReplace:'+r.index);
  }
  function replace(index,confirmed=false) {
    const s=state(),e=pool()[index],c=s.active?.smart?s.active.smartConfig:config(),conflicts=e.loads.filter(l=>c.loads.includes(l));
    if(conflicts.length&&!confirmed) {overlay(`<div class="scroll pad smart-content"><h1>${E(exName(e.name))}</h1><div class="smart-warning"><h2>${text('conflict')}</h2><p>${conflicts.map(copy).map(E).join(' · ')}</p></div>${hint('conflictHint')}</div><div class="sticky-actions">${button('confirmConflict','smartConfirmReplace:'+index,'primary')}${button('cancel','smartConflicts','secondary full')}</div>`,'conflict','smartConflicts');return;}
    const r=s.smartReplacement,list=currentPlanItems(),original=list[r.index],item=prescription(e,c);item.role=original.role;item.sets=original.sets;item.reps=original.reps;item.rest=original.rest;
    const oldSeconds=list.reduce((sum,m)=>sum+seconds(m),0);
    if(oldSeconds-seconds(original)+seconds(item)>c.minutes*60&&!s.active?.started){alternatives(r.reason);return;}
    if(s.active?.smart){item.uid=original.uid;item.rows=Array.from({length:item.sets},()=>({id:crypto.randomUUID(),reps:item.reps,weight:0,done:false,edited:false}));item.showWeight=false;}
    list[r.index]=item;
    if(!s.active?.smart){plan().seconds=list.reduce((sum,m)=>sum+seconds(m),0);if(!s.smartDraft)persist();}
    dismiss();render(true);
  }
  function dismiss() {state().overlay=null;state().loadDraft=null;$('#overlay').innerHTML='';$('#app').inert=false;}
  function schedule() {
    state().scheduleDraft={name:config().name,days:[...config().days]};renderSchedule();
  }
  function renderSchedule() {
    const d=state().scheduleDraft;
    overlay(`<div class="scroll pad smart-content"><label class="field-label" for="smart-name">${E(t('uiSessionName'))}</label><input class="text-field" id="smart-name" value="${E(d.name)}" placeholder="${E(configName(config()))}"><section><h2>${E(t('uiTrainingDays'))}</h2><div class="chip-wrap">${days.map(day=>chip(label(day),'smartDay:'+day,d.days.includes(day))).join('')}</div></section></div><div class="sticky-actions">${button('apply','smartScheduleApply','primary')}</div>`,'schedule');
  }
  window.v008TrainingDay = () => days[new Date(date()+'T12:00:00').getDay()];
  window.v008SmartHomeWorkout = () => {
    if(new URLSearchParams(location.search).get('scenario')==='empty')return null;
    const c=model().config;
    return {days:c.days,renderCard:scheduled=>`<article class="workout-card smart-home-card"><p class="eyebrow">SMART SELECTION</p>${btn(`<div class="grow"><h2>${E(configName(c))}</h2><span class="meta">${E(t('uiMinutesCount',c.minutes))} · ${text(c.level)}</span></div>${icon('chevron',20)}`,'smartOpen','workout-open')}<div class="card-actions">${button('settings','smartEdit')}${button('start','smartOpen',scheduled?'primary':'secondary')}</div></article>`};
  };
  settingsView = () => { const template=document.createElement('template');template.innerHTML=old.settingsView();template.content.querySelector('[data-action="feedback"]').insertAdjacentHTML('afterend',btn(`<span>${text('rate')}</span>${icon('chevron',16)}`,'smartRate','settings-row'));return template.innerHTML; };
  musclePicker = () => {
    const template=document.createElement('template');template.innerHTML=old.musclePicker();
    if(!state().editingTargets){template.content.querySelector('.scroll').insertAdjacentHTML('afterbegin',step(1));template.content.querySelector('[data-action="buildSmart"]').innerHTML=text('next')+icon('chevron',20);template.content.querySelector('.skip-manual')?.remove();}
    return template.innerHTML;
  };
  render = preserve => {
    const route=state().route;
    if(['smartSetup','smartOptions','smartToday'].includes(route)) {
      const scroll=$('#app .scroll')?.scrollTop||0;$('#app').innerHTML=route==='smartSetup'?setup():route==='smartOptions'?options():today();$('#app').inert=false;document.documentElement.lang=language;
      if(preserve&&$('#app .scroll'))$('#app .scroll').scrollTop=scroll;
      if(!state().overlay)$('#overlay').innerHTML='';return;
    }
    old.render(preserve);
    const a=state().active;
    if(a?.smart&&['workout','active'].includes(route)) {
      const note=$('.session-note');if(note)note.textContent=copy(a.started?'frozen':'local');
      document.querySelectorAll('[data-action^="replaceExercise:session:"]').forEach(node=>{const index=a.workout.items.findIndex(e=>e.uid===node.dataset.action.split(':')[2]);node.dataset.action='smartReplace:'+index;});
      if(route==='active') {const item=a.workout.items.find(e=>e.uid===a.viewId);if(item?.rule!=='total')$('.set-content > .meta')?.insertAdjacentHTML('beforeend',' · '+text(item.rule==='side'?'eachSide':'cycle'));}
    }
  };
  direct = route => {
    if(route.startsWith('smart')) {
      const s=state();model();s.overlay=null;s.active=null;s.smartDraft=null;invalidate();
      if(route==='smartSetup'||route==='smartOptions'){s.muscles=['Lower'];draft(true);}
      if(new URLSearchParams(location.search).get('scenario')==='smart-gap'){draft(true);s.smartDraft.targets=['Full Body'];s.smartDraft.equipment=[];s.smartDraft.gym=false;}
      s.route=route;render();return;
    }
    old.direct(route);
  };
  action = value => {
    const s=state(),[name,...p]=value.split(':'),previousRoute=s.route;
    if(name==='chooseSmart'){s.smartDraft=null;s.smartEditing=false;s.editingTargets=false;}
    if(name==='buildSmart'&&!s.editingTargets){if(!s.muscles.length)return;if(s.smartEditing){s.smartDraft.targets=[...s.muscles];invalidate();}else draft();s.route='smartSetup';render();return;}
    if(!name.startsWith('smart')){old.action(value);if(name==='buildManual')old.action('pickExercise');return;}
    switch(name) {
      case 'smartCancel':s.smartDraft=null;invalidate();s.route=s.smartEditing?'smartToday':'creation';s.smartEditing=false;break;
      case 'smartOpen':s.smartDraft=null;s.active=null;s.route='smartToday';break;
      case 'smartMinutes':config().minutes=Number(p[0]);invalidate();break;
      case 'smartLevel':config().level=p[0];invalidate();break;
      case 'smartEquipmentPanel':s.equipmentDraft=[...config().equipment];equipmentPanel();return;
      case 'smartEquipmentDraft':{s.equipmentDraft=toggle(s.equipmentDraft,p.join(':'));const scroll=$('#overlay .scroll').scrollTop;equipmentPanel();$('#overlay .scroll').scrollTop=scroll;return;}
      case 'smartEquipmentApply':config().equipment=[...s.equipmentDraft];invalidate();dismiss();break;
      case 'smartEquipment':config().equipment=toggle(config().equipment,p.join(':'));invalidate();break;
      case 'smartGym':config().gym=p[0]==='true';invalidate();break;
      case 'smartOptions':s.route='smartOptions';break;
      case 'smartPreview':s.route='smartToday';break;
      case 'smartBack':if(s.route==='smartOptions')s.route='smartSetup';else {s.muscles=[...config().targets];s.smartEditing=true;s.route='musclePicker';}break;
      case 'smartExit':if(s.smartDraft){s.route='smartOptions';}else{s.route='train';s.active=null;}break;
      case 'smartEdit':if(!s.smartDraft)draft(true);s.active=null;s.route='smartSetup';break;
      case 'smartRegions':s.loadDraft=null;regions();return;
      case 'smartArea':loadPanel(p[0]);return;
      case 'smartLoad':s.loadDraft=toggle(s.loadDraft,p[0]);loadPanel(s.smartArea);return;
      case 'smartConfirmLoads':config().loads=[...s.loadDraft];invalidate();dismiss();break;
      case 'smartDismiss':dismiss();break;
      case 'smartRestore':config().excluded.splice(Number(p[0]),1);invalidate();break;
      case 'smartSave':if(plan().gaps.length)return;saveDraft();break;
      case 'smartStart':{
        if(plan().gaps.length||!plan().items.length)return;
        const c=clone(config()),items=clone(plan().items),id='smart-active';s.workouts=s.workouts.filter(w=>w.id!==id);s.workouts.push({id,mode:'smart',name:configName(c),targets:c.targets,days:c.days,items});
        old.action('start:'+id);s.workouts=s.workouts.filter(w=>w.id!==id);s.active.workout.items.forEach(item=>item.rows.forEach(row=>{row.reps=item.reps;row.weight=0;}));s.active.smart=true;s.active.smartConfig=c;s.active.smartDay=plan().date;old.action('beginSession');return;
      }
      case 'smartGuide':{const e=plan().items[Number(p[0])];old.action('movement:'+D.products[product].exercises.findIndex(item=>item.name===e.name));return;}
      case 'smartReplace':if(currentPlanItems()[Number(p[0])]?.rows?.some(r=>r.done))return;replacementReason(Number(p[0]));return;
      case 'smartAlternatives':alternatives(p[0]);return;
      case 'smartConflicts':alternatives(s.smartReplacement.reason,true);return;
      case 'smartSelect':replace(Number(p[0]));return;
      case 'smartConfirmReplace':replace(Number(p[0]),true);return;
      case 'smartPermanent':overlay(`<div class="scroll pad smart-content"><h1>${text('permanent')}</h1><p>${E(exName(currentPlanItems()[s.smartReplacement.index].name))}</p>${hint('permanentHint')}</div><div class="sticky-actions">${button('exclude','smartConfirmPermanent','primary')}${button('cancel','smartDismiss','secondary full')}</div>`,'permanent');return;
      case 'smartConfirmPermanent':{
        const name=currentPlanItems()[s.smartReplacement.index].name,c=s.active?.smart?model().config:config(),current=clone(plan());c.excluded=[...new Set([...c.excluded,name])];c.revision++;current.revision=c.revision;model().anchors=model().anchors.filter(e=>e!==name);if(s.smartDraft)s.smartPreview=current;else{model().plans[planKey(c)]=current;persist();}
        if(s.active?.smart)s.active.smartConfig.excluded=[...new Set([...s.active.smartConfig.excluded,name])];alternatives('another');return;
      }
      case 'smartSchedule':schedule();return;
      case 'smartDay':s.scheduleDraft.days=toggle(s.scheduleDraft.days,p[0]);s.scheduleDraft.name=$('#smart-name').value;renderSchedule();return;
      case 'smartScheduleApply':config().name=$('#smart-name').value.trim();config().days=[...s.scheduleDraft.days];if(!s.smartDraft)persist();dismiss();break;
      case 'smartNextDay':model().offset++;invalidate();persist();break;
      case 'smartRate':window.open(`https://apps.apple.com/app/id${product==='OnlyBody'?'6827692702':'6827693301'}?action=write-review`,'_blank','noopener');return;
    }
    render(s.route===previousRoute);
  };
  addEventListener('message',event=>{if(event.origin===location.origin&&event.source===parent&&event.data?.type==='smartNextDay')action('smartNextDay');});
  document.addEventListener('keydown',event=>{if(event.key==='Escape'&&state().overlay?.kind==='smart'){event.preventDefault();dismiss();render();}},true);
  // Read-only QA surface; changing the day uses the same visible demo action.
  window.smartDemo={config:()=>clone(config()),plan:()=>clone(plan()),model:()=>clone(model())};
  const style=document.createElement('link');style.rel='stylesheet';style.href='../v008/smart.css';
  window.v008Ready=Promise.all([window.v008Ready,new Promise((resolve,reject)=>{style.onload=resolve;style.onerror=reject;document.head.append(style);})]);
})();
