const {chromium}=require('playwright');
const assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto');
const root=path.resolve(__dirname,'..'),origin=process.env.DESIGN_URL||'http://127.0.0.1:8772';
const version=process.env.DESIGN_VERSION||'v003';
assert.ok(['v003','v004'].includes(version));
const reportPath=process.env.DESIGN_REPORT||path.join(root,`versions/${version}/verification.json`);
const report={version,date:process.env.DESIGN_REVIEW_DATE||'2026-11-01',scope:'Desktop Chromium HTML prototype; native parity with d812d78',nativeKeyboard:'UNCONFIRMED',sourceRevision:'d812d78',flows:[],matrix:0,issues:[],physicalIPhone:'UNCONFIRMED',nativeVoiceOver:'UNCONFIRMED'};
(async()=>{const browser=await chromium.launch({channel:'chrome',headless:true,args:['--no-sandbox']});const page=await browser.newPage();page.on('pageerror',e=>report.issues.push(e.message));
const go=async(product='OnlyWeights',screen='train',language='uk',width=393,scenario='standard')=>{await page.setViewportSize({width,height:{375:812,393:852,440:956}[width]});await page.goto(`${origin}/runner.html?version=${version}&product=${product}&screen=${screen}&language=${language}&scenario=${scenario}`);await page.waitForFunction(()=>window.mock);await page.evaluate(v=>window[v+'Ready'],version)};
const act=async v=>page.evaluate(v=>mock.act(v),v),data=async()=>page.evaluate(()=>mock.state());
const holdDrag=async(scope,from,to,inspect=async()=>{})=>{
 const handle=page.locator(`[data-drag="${scope}:${from}"]`),card=page.locator(`[data-scope="${scope}"][data-item="${from}"]`),target=page.locator(`[data-scope="${scope}"][data-item="${to}"]`);
 await handle.scrollIntoViewIfNeeded();const h=await handle.boundingBox(),a=await card.boundingBox(),b=await target.boundingBox();
 await page.mouse.move(h.x+h.width/2,h.y+h.height/2);await page.mouse.down();await page.waitForTimeout(300);
 assert.equal(await page.locator('.session-card.is-dragging').count(),1,'whole card lifts on hold');
 await page.mouse.move(h.x+h.width/2,h.y+h.height/2+b.y+b.height/2-a.y-a.height/2+Math.sign(to-from)*12,{steps:10});await page.waitForTimeout(80);
 const moving=await card.boundingBox();assert.ok(Math.abs(moving.y-a.y)>40,'card follows before release');
 await inspect();await page.mouse.up();await page.waitForTimeout(380);
};
const swipeBack=async(vertical=false)=>{
 const bounds=await page.locator('.device').boundingBox();const x=bounds.x+8,y=bounds.y+470;
 await page.mouse.move(x,y);await page.mouse.down();await page.mouse.move(x+(vertical?8:150),y+(vertical?100:0),{steps:8});await page.mouse.up();
};
try{
 for(const version of ['v000','v001','v002']){const checks=JSON.parse(fs.readFileSync(path.join(root,version==='v000'?'baseline-checksums.json':version+'-checksums.json')));for(const [file,sum]of Object.entries(checks))assert.equal(crypto.createHash('sha256').update(fs.readFileSync(path.join(root,'versions',version,file))).digest('hex'),sum)}
 for(const product of ['OnlyBody','OnlyWeights']){
 await go(product);const original=(await data()).workouts[0];await act('start:'+original.id);assert.equal((await data()).route,'workout');assert.equal((await data()).active.started,false);
 await act('moveItem:session:0:1');assert.deepEqual((await data()).workouts[0],original);await act('replaceItem:session:0');await page.locator('#replace-search').fill('zzzzzz');assert.equal(await page.locator('#replace-results button').count(),0);await act('cancelReplace');await act('replaceItem:session:0');await act('selectReplace:0');assert.deepEqual((await data()).workouts[0],original);
 await act('beginSession');let a=(await data()).active,first=a.workout.items[0],second=a.workout.items[1];assert.equal(a.currentId,first.uid);
 await act('sessionList');await act('viewItem:'+second.uid);await act('activeGuide');await act('back');assert.equal((await data()).active.currentId,first.uid);await act('activeHistory');await act('back');
 await act('toggleSet:'+second.rows[0].id);assert.equal((await data()).active.currentId,first.uid);assert.equal((await data()).active.viewId,second.uid);assert.equal((await data()).active.restRemaining,second.rest);
 await act('showRowWeight');const weight=page.locator(`[data-row="${second.rows[0].id}"][data-field="weight"]`);await weight.fill('27,5');await weight.dispatchEvent('change');a=(await data()).active;assert.equal(a.workout.items[1].rows[0].weight,27.5);assert.equal(a.restRemaining,second.rest);
 await act('sessionList');assert.equal(await page.locator('[data-action="replaceItem:session:1"]').isDisabled(),true);await act('moveItem:session:1:-1');a=(await data()).active;assert.equal(a.currentId,first.uid);assert.equal(a.workout.items[0].rows[0].weight,27.5);
 await act('viewItem:'+second.uid);await act('toggleSet:'+second.rows[0].id);assert.equal((await data()).active.workout.items[0].rows[0].weight,27.5);await act('toggleSet:'+second.rows[0].id);
 await act('viewItem:'+first.uid);for(const r of first.rows)await act('toggleSet:'+r.id);a=(await data()).active;assert.notEqual(a.currentId,first.uid);
 // Complete every remaining row via arbitrary exercise navigation.
 for(const m of a.workout.items){await act('viewItem:'+m.uid);for(const r of m.rows)if(!r.done)await act('toggleSet:'+r.id)}
 assert.equal((await data()).route,'workout');assert.deepEqual((await data()).workouts[0],original);assert.equal((await data()).active.saved,undefined);
 await act('viewItem:'+second.uid);await act('showRowWeight');await page.locator(`[data-row="${second.rows[0].id}"][data-field="weight"]`).fill('31');await act('sessionList');assert.equal((await data()).active.workout.items[0].rows[0].weight,31);
 await page.evaluate(()=>mock.state().failSave=true);await act('endWorkout');await act('saveAndEnd');assert.equal((await data()).active.saveError,true);await act('retrySave');assert.equal((await data()).active.saved,true);assert.equal((await data()).sessions[0].items[0].setWeights[0],31);
 report.flows.push(product+': session draft, replacement, reorder, guide/history return, arbitrary sets, completed edits, auto progression, explicit finish, save retry');
 await go(product,'builder');const before=(await data()).workouts[0];await act('moveItem:builder:0:1');await act('replaceItem:builder:0');await act('selectReplace:0');assert.deepEqual((await data()).workouts[0],before);const expected=(await data()).builder.items.map(m=>m.name);await act('save');assert.deepEqual((await data()).workouts[0].items.map(m=>m.name),expected);report.flows.push(product+': editor saves order and replacement');
 await go(product,'rest');await page.evaluate(()=>window.mockLive=true);await page.waitForTimeout(2200);a=(await data()).active;assert.ok(a.restRemaining<45);assert.ok(a.elapsed>=2);const current=a.currentId;await act('sessionList');await act('restPlus');await act('restSkip');assert.equal((await data()).active.currentId,current);assert.equal((await data()).route,'workout');report.flows.push(product+': live rest, +15, skip, stable navigation');
 }
 await go('OnlyWeights','workout');let draft=(await data()).active;const firstId=draft.workout.items[0].uid;
 await holdDrag('session',0,1);assert.equal((await data()).active.workout.items[1].uid,firstId);
 await act('beginSession');let a=(await data()).active;const currentItem=a.workout.items[0],future=a.workout.items[1];await act('viewItem:'+future.uid);for(const r of future.rows)await act('toggleSet:'+r.id);await act('viewItem:'+currentItem.uid);for(const r of currentItem.rows)await act('toggleSet:'+r.id);assert.equal((await data()).active.currentId,a.workout.items[2].uid);
 const viewed=(await data()).active.viewId;await page.locator('[data-row][data-field="reps"]').first().fill('-2');await act('sessionList');assert.equal((await data()).route,'active');await page.locator('[data-row][data-field="reps"]').first().fill('12');await act('sessionList');
 await page.evaluate(()=>{mock.state().active.restRemaining=1;window.mockLive=true});await page.waitForTimeout(1200);assert.equal((await data()).route,'workout');assert.equal((await data()).active.viewId,viewed);assert.equal((await data()).active.restRemaining,0);assert.equal(await page.locator('.rest-strip').count(),0);
 await go('OnlyWeights','workout');await page.evaluate(()=>{const a=mock.state().active;a.workout.items[1].name=a.workout.items[0].name});await act('beginSession');a=(await data()).active;for(let index=0;index<2;index++){const m=a.workout.items[index];await act('viewItem:'+m.uid);await page.locator('[data-row][data-field="weight"]').first().fill(String(20+index*10));await act('toggleSet:'+m.rows[0].id)}await act('endWorkout');await act('saveAndEnd');const saved=(await data()).sessions[0];assert.equal(saved.items[0].setWeights[0],20);assert.equal(saved.items[1].setWeights[0],30);
 await go('OnlyBody','workout','uk',393,'empty');assert.equal(await page.locator('[data-action="beginSession"]').count(),0);
 report.flows.push('Duplicate exercise names retain independent saved weights; empty session has no start');
 report.flows.push('Desktop handle drag; skip completed future exercise; invalid input retains screen; rest expiration preserves navigation');
 for(const product of ['OnlyBody','OnlyWeights']){
  // Per-set history, an extra set, a different source template, and occurrence identity.
  await go(product);await page.evaluate(()=>{
   const s=mock.state(),m=s.workouts[0].items[0];m.sets=3;
   s.sessions.unshift({id:'qa-latest',name:'Another template',nameKey:null,date:'2026-11-02T10:00:00Z',duration:600,items:[{...m,setReps:[8,7],setWeights:[50,47.5],weight:50}]});
  });
  let template=(await data()).workouts[0];await act('start:'+template.id);await act('beginSession');let a=(await data()).active;
  assert.deepEqual(a.workout.items[0].rows.map(r=>r.reps),[8,7,7]);assert.deepEqual(a.workout.items[0].rows.map(r=>r.weight),[50,47.5,47.5]);assert.ok(a.workout.items[0].rows.every(r=>!r.done));
  assert.deepEqual((await data()).workouts[0],template);await act('activeHistory');assert.equal(await page.locator('.history-entry').first().locator('.history-set strong').nth(1).innerText(),'47,5 kg');await act('back');
  await page.evaluate(()=>mock.state().sessionId='qa-latest');await act('session:qa-latest');assert.equal(await page.locator('.session-item').first().locator('.history-set strong').nth(1).innerText(),'47,5 kg');
  await act('setUnit:lb');assert.match(await page.locator('.session-item .history-set strong').first().innerText(),/110,23 lb/);await act('setUnit:kg');
  await page.evaluate(()=>{mock.state().sessions[0].items[0].setWeights=[50];mock.render()});assert.equal(await page.locator('.history-set strong').nth(1).innerText(),'—');assert.equal(await page.locator('.legacy-weight').count(),0);
  await page.evaluate(()=>{delete mock.state().sessions[0].items[0].setWeights;mock.render()});assert.match(await page.locator('.legacy-weight').innerText(),/50 kg/);assert.equal(await page.locator('.history-set strong').first().innerText(),'—');
  report.flows.push(product+': latest per-set reps/weight across templates, repeated final result, log kg/lb, unknown and legacy weight');

  // A failed history read does not overwrite results entered before retry.
  await go(product,'workout');await page.evaluate(()=>{mock.state().failHistory=true;mock.navigate('workout')});assert.equal((await data()).active.historyError,true);await act('beginSession');await act('showRowWeight');
  await page.locator('[data-field="weight"]').first().fill('18');await act('retryHistory');assert.equal((await data()).active.workout.items[0].rows[0].weight,18);assert.equal((await data()).active.historyError,false);

  // Zero replacement, outside blur and interactive controls with an open field.
  await page.evaluate(()=>{mock.state().active.workout.items[0].rows[0].weight=0;mock.render()});
  let input=page.locator('[data-field="weight"]').first();await input.focus();assert.equal(await input.inputValue(),'');await page.locator('.set-content h1').click();assert.equal(await input.inputValue(),'0');
  await input.focus();await input.pressSequentially('50');assert.equal(await input.inputValue(),'50');await page.locator('.set-content h1').click();assert.equal(await input.evaluate(el=>el===document.activeElement),false);assert.equal((await data()).active.workout.items[0].rows[0].weight,50);
  const beforeRest=(await data()).active.restRemaining;await input.focus();await input.fill('51');await page.locator('.set-check').first().click();assert.equal((await data()).active.workout.items[0].rows[0].done,true);assert.equal((await data()).active.workout.items[0].rows[0].weight,51);
  const rest=(await data()).active.restRemaining;await page.locator('[data-field="weight"]').first().fill('52');await page.locator('.set-content h1').click();assert.equal((await data()).active.restRemaining,rest);await act('toggleSet:'+(await data()).active.workout.items[0].rows[0].id);assert.equal((await data()).active.restRemaining,rest);
  await act('sessionList');await act('replaceItem:session:0');await page.locator('#replace-search').fill('press');await page.locator('.replacement-sheet .nav-bar-title').click();assert.equal(await page.locator('#replace-search').evaluate(el=>el===document.activeElement),false);assert.equal(await page.locator('#replace-search').inputValue(),'press');await act('cancelReplace');
  report.flows.push(product+': history retry preserves edits; zero → 50, untouched zero restored, outside tap blurs without consuming check; edits/uncheck preserve rest');

  // Manual duration is derived; smart selection previews and saves within the budget.
  await go(product,'builder');await page.locator('details.options').evaluate(el=>el.open=true);assert.equal(await page.locator('[data-action="timing:duration"]').count(),0);assert.equal((await data()).builder.duration,null);
  await act('save');assert.equal((await data()).workouts[0].duration,null);
  await act('edit:'+template.id);await act('mode:smart');await act('timing:duration');await act('setTiming:60');await act('closeOverlay');const large=(await data()).builder.items.length;
  await act('timing:duration');await act('setTiming:15');await act('closeOverlay');let b=(await data()).builder;assert.ok(b.items.length<large);assert.ok(b.items.reduce((sum,m)=>sum+m.sets*(m.reps*3+m.rest),0)<=900);
  const retained=b.items[1]?.uid;await page.evaluate(()=>{mock.state().builder.items[0].sets=100});await act('save');const saved=(await data()).workouts[0];assert.ok(saved.items.every(m=>m.sets!==100));if(retained)assert.ok(saved.items.some(m=>m.uid===retained));assert.ok(saved.items.reduce((sum,m)=>sum+m.sets*(m.reps*3+m.rest),0)<=900);
  await act('edit:'+template.id);const savedCount=(await data()).workouts.length;await page.evaluate(()=>mock.state().builder.items.forEach(m=>m.sets=100));await act('save');assert.equal((await data()).route,'builder');assert.equal((await data()).workouts.length,savedCount);assert.equal(await page.locator('[role="alertdialog"]').count(),1);await act('closeOverlay');
  report.flows.push(product+': no manual target duration; smart 60 → 15 min visibly reduces cards; oversized edits trimmed on save with retained IDs; no-fit is recoverable');

  // Equipment composes with muscle group and localized search in the library and picker.
  await go(product,'library');const match=await page.evaluate(()=>{const e=D.products[product].exercises[0];return {name:exName(e),group:e.primaryMuscle,equipment:e.equipment[0]}});
  await act('openFilters:false');await act('equipment:false:'+match.equipment);await act('filter:false:'+match.group);await act('closeFilters');await page.locator('#catalog-search').fill(match.name);assert.ok(await page.locator('#catalog-results button').count()>0);assert.ok(await page.evaluate(()=>filtered().every(e=>e.equipment.includes(mock.state().equipment))));assert.equal(await page.locator('#catalog-results .badge').count(),0);
  await page.locator('#catalog-results button').first().click();assert.equal(await page.locator('.scroll>.badge').count(),0);
  await go(product,'builder');await act('pickExercise');await act('openFilters:true');await act('equipment:true:'+match.equipment);await act('closeFilters');assert.equal(await page.locator('[role="dialog"] #catalog-search').count(),1);assert.ok(await page.evaluate(()=>filtered(true).every(e=>e.equipment.includes(mock.state().pickerEquipment))));await act('resetFilters:true');assert.equal((await data()).pickerEquipment,null);await act('closeFilters');await act('closePicker');
  await go(product,'workout');await act('replaceItem:session:0');await act('replacementFilters');await act('equipment:true:'+match.equipment);await act('closeFilters');assert.equal(await page.locator('#replace-search').count(),1);assert.ok(await page.locator('#replace-results button').count()>0);await act('cancelReplace');
  report.flows.push(product+': equipment + muscle + search, no difficulty in library/guide/picker, replacement filtering and cancel');

  // Every visible back affordance shares the same edge-swipe behavior.
  await go(product,'workout');await swipeBack(true);assert.equal((await data()).route,'workout');await swipeBack();assert.equal((await data()).route,'train');
  await act('start:'+template.id);await act('beginSession');await swipeBack();assert.equal((await data()).route,'workout');assert.equal((await data()).active.started,true);await swipeBack();assert.equal((await data()).route,'workout');await act('resumeSession');await act('activeGuide');await swipeBack();assert.equal((await data()).route,'active');
  await go(product,'builder');await act('pickExercise');await swipeBack();assert.equal((await data()).overlay,null);await swipeBack();assert.equal((await data()).route,'train');
  await go(product,'workout');await act('replaceItem:session:0');await swipeBack();assert.equal((await data()).overlay,null);
  report.flows.push(product+': edge back in exercise, draft, guide, builder, picker and replacement; vertical movement and active list cannot dismiss session');

  // Verify lift, intermediate positions and neighbor gap before committing on both screens.
  for(const scope of ['builder','session']){
   await go(product,scope==='builder'?'builder':'workout');const list=scope==='builder'?(await data()).builder.items:(await data()).active.workout.items,ids=list.map(m=>m.uid);
   await holdDrag(scope,0,1,async()=>{assert.deepEqual((scope==='builder'?(await data()).builder.items:(await data()).active.workout.items).map(m=>m.uid),ids,'preview does not commit');assert.equal(await page.locator(`[data-scope="${scope}"]`).first().getAttribute('data-key'),ids[1],'neighbor moves before drop')});
   assert.equal((scope==='builder'?(await data()).builder.items:(await data()).active.workout.items)[1].uid,ids[0]);
   await holdDrag(scope,1,0);assert.deepEqual((scope==='builder'?(await data()).builder.items:(await data()).active.workout.items).map(m=>m.uid),ids);
  }
  // Duplicate occurrences and replacement use the new exercise's latest performance.
  await go(product,'workout');await page.evaluate(()=>{
   const s=mock.state(),name=s.workouts[0].items[0].name,other=s.workouts[0].items[1].name;
   s.workouts[0].items[1].name=name;
   s.sessions.unshift({id:'qa-duplicates',name:'Source',date:'2026-11-03',duration:300,items:[{name,setReps:[8],setWeights:[50]},{name,setReps:[6],setWeights:[30]},{name:other,setReps:[9],setWeights:[22]}]});mock.navigate('workout');
  });
  let duplicate=(await data()).active;assert.deepEqual(duplicate.workout.items.slice(0,2).map(m=>m.rows[0].weight),[50,30]);
  await act('moveItem:session:0:1');assert.deepEqual((await data()).active.workout.items.slice(0,2).map(m=>m.rows[0].weight),[30,50]);
  const replacementIndex=await page.evaluate(()=>D.products[product].exercises.findIndex(e=>e.name===mock.state().sessions[0].items[2].name));await act('replaceItem:session:0');await act('selectReplace:'+replacementIndex);assert.equal((await data()).active.workout.items[0].rows[0].weight,22);assert.equal((await data()).active.workout.items[0].rows[0].reps,9);

  for(const screen of ['creation','musclePicker','settings','notifications','session','statistics','exerciseHistory']){
   await go(product,screen);const backAction=await page.evaluate(()=>[...document.querySelectorAll('#app button')].find(button=>button.getAttribute('aria-label')===t('uiBack'))?.dataset.action);assert.ok(backAction,screen+' has a back button');await act(backAction);const expectedRoute=(await data()).route;
   await go(product,screen);await swipeBack();assert.equal((await data()).route,expectedRoute,screen+' swipe matches back');
  }
  await go(product,'builder');await page.locator('#builder-name').fill('Unsaved changes');await swipeBack();assert.equal(await page.locator('[role="alertdialog"]').count(),1,'swipe preserves unsaved-change confirmation');
  report.flows.push(product+': held card lifts and follows pointer in both directions, neighbors move before release, session/editor commit with stable identities');
 }
 for(const product of ['OnlyBody','OnlyWeights'])for(const language of ['uk','en','pl','de','fr'])for(const width of [375,393,440])for(const screen of ['workout','active','rest','builder','library','exercisePicker','movement','session','exerciseHistory']){
 await go(product,screen,language,width,'long');const issues=await page.evaluate(()=>{const limit=document.querySelector('.device').getBoundingClientRect();return [...document.querySelectorAll('#app *,#overlay *')].flatMap(el=>{const r=el.getBoundingClientRect();if(!r.width||!r.height)return [];if(r.left<limit.left-1||r.right>limit.right+1)return [el.className+' overflow'];if(el.matches('button,input')&&!el.disabled&&(r.width<43.9||r.height<43.9))return [el.className+' small target'];return []})});assert.deepEqual(issues,[],[product,language,width,screen].join('/'));report.matrix++;
 if(width===393&&language==='uk'){const dir=path.join(root,`versions/${version}/screenshots`,product);fs.mkdirSync(dir,{recursive:true});await page.screenshot({path:path.join(dir,screen+'.png')})}
 }
 // Real Chromium touch events, cancel, edge autoscroll and Reduce Motion.
 await go('OnlyWeights','workout');const touch=await page.context().newCDPSession(page);
 const touchPoint=async(type,x,y)=>touch.send('Input.dispatchTouchEvent',{type,touchPoints:type==='touchEnd'||type==='touchCancel'?[]:[{x,y,id:1}]});
 let h=await page.locator('[data-drag="session:0"]').boundingBox(),card=await page.locator('[data-item="0"]').boundingBox(),next=await page.locator('[data-item="1"]').boundingBox(),ids=(await data()).active.workout.items.map(m=>m.uid);
 await touchPoint('touchStart',h.x+h.width/2,h.y+h.height/2);await page.waitForTimeout(300);assert.equal(await page.locator('.is-dragging').count(),1);
 await touchPoint('touchMove',h.x+h.width/2,h.y+h.height/2+next.y-card.y+20);await page.waitForTimeout(80);assert.equal(await page.locator('[data-scope="session"]').first().getAttribute('data-key'),ids[1]);assert.deepEqual((await data()).active.workout.items.map(m=>m.uid),ids);await touchPoint('touchEnd');assert.equal((await data()).active.workout.items[1].uid,ids[0]);
 await go('OnlyWeights','workout');ids=(await data()).active.workout.items.map(m=>m.uid);h=await page.locator('[data-drag="session:0"]').boundingBox();await touchPoint('touchStart',h.x+h.width/2,h.y+h.height/2);await page.waitForTimeout(300);await touchPoint('touchMove',h.x+h.width/2,800);await page.waitForTimeout(450);assert.ok(await page.locator('.session-list').evaluate(el=>el.scrollTop)>0);await touchPoint('touchCancel');assert.deepEqual((await data()).active.workout.items.map(m=>m.uid),ids);
 await page.emulateMedia({reducedMotion:'reduce'});await go('OnlyWeights','builder');await holdDrag('builder',0,1,async()=>{assert.equal(await page.locator('.is-dragging').evaluate(el=>new DOMMatrix(getComputedStyle(el).transform).a),1);assert.equal(await page.locator('[data-key]').evaluateAll(nodes=>nodes.reduce((count,el)=>count+el.getAnimations().length,0)),0)});await page.emulateMedia({reducedMotion:'no-preference'});
 await go('OnlyWeights','active');await touchPoint('touchStart',8,470);await touchPoint('touchMove',160,470);await touchPoint('touchEnd');assert.equal((await data()).route,'workout','touch back invokes session list');
 await go('OnlyWeights','active');await page.evaluate(()=>{mock.state().active.restRemaining=1;window.mockLive=true;mock.render()});const focusedWeight=page.locator('[data-field="weight"]').first();await focusedWeight.fill('51');await page.waitForTimeout(1250);assert.equal(await focusedWeight.evaluate(el=>el===document.activeElement),true,'rest expiration preserves input focus');assert.equal((await data()).active.restRemaining,0);assert.equal((await data()).route,'active');await page.evaluate(()=>window.mockLive=false);
 await go('OnlyWeights','workout');await act('moveItem:session:0:1');assert.ok(await page.locator('[data-key]').evaluateAll(nodes=>nodes.some(el=>el.getAnimations().length>0)),'arrow actions animate neighboring cards');
 report.flows.push('Chromium touch: lift, live neighbor gap, commit, autoscroll and cancel; touch back; rest expiration preserves focus; arrow animation; Reduce Motion keeps direct dragging without scale or animation');

 // Expanded panels, planning and touch targets in every product/language/width.
 for(const product of ['OnlyBody','OnlyWeights'])for(const language of ['uk','en','pl','de','fr'])for(const width of [375,393,440])for(const panel of ['replacement','filters','smart']){
  await go(product,panel==='smart'?'builder':'workout',language,width,'long');
  if(panel==='smart'){await act('mode:smart')}else{await act('replaceItem:session:0');if(panel==='filters')await act('replacementFilters')}
  const issues=await page.evaluate(()=>{const bounds=document.querySelector('.device').getBoundingClientRect();return [...document.querySelectorAll('#app *,#overlay *')].flatMap(el=>{const r=el.getBoundingClientRect();if(!r.width||!r.height)return [];if(r.left<bounds.left-1||r.right>bounds.right+1)return [el.className+' overflow'];if(el.matches('button,input')&&!el.disabled&&(r.width<43.9||r.height<43.9))return [el.className+' small target'];return []})});assert.deepEqual(issues,[],[product,language,width,panel].join('/'));report.matrix++;
  if(width===393&&language==='uk'){const dir=path.join(root,`versions/${version}/screenshots`,product);await page.screenshot({path:path.join(dir,panel+'.png')})}
 }
 await page.setViewportSize({width:1440,height:1100});await page.goto(origin+`/?version=${version}&compare=true&compare-base=v002&screen=active`);await page.waitForFunction(()=>[...document.querySelectorAll('iframe')].every(f=>f.contentWindow.mock));assert.equal(await page.locator('iframe').count(),2);report.flows.push(`v002 / ${version} comparison`);
 report.status=report.issues.length?'FAIL':'PASS';
}catch(e){report.status='FAIL';report.issues.push(e.stack)}finally{await browser.close();fs.writeFileSync(reportPath,JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify(report,null,2));if(report.status!=='PASS')process.exitCode=1}
})();
