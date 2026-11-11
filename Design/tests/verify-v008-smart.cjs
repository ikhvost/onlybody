/* Interaction contracts for the design prototype, not production algorithm tests. */
const {chromium}=require('playwright');
const assert=require('node:assert/strict');
const fs=require('node:fs');
const path=require('node:path');
const origin=process.env.DESIGN_URL||'http://127.0.0.1:8772';
const output=path.resolve(__dirname,'../versions/v008');
const report={date:'2026-11-06',scope:'Smart v008 desktop Chrome interaction fixtures',flows:[],issues:[],panels:0};
(async()=>{
 const browser=await chromium.launch({channel:'chrome',headless:true});
 const page=await browser.newPage({viewport:{width:393,height:852},timezoneId:'Europe/Warsaw'});
 page.on('pageerror',e=>report.issues.push(e.stack));
 await page.route('**/*',r=>new URL(r.request().url()).origin===origin?r.continue():r.abort());
 const act=v=>page.evaluate(v=>mock.act(v),v);
 const click=v=>page.locator(`[data-action="${v}"]`).first().click();
 const config=()=>page.evaluate(()=>smartDemo.config());
 const plan=()=>page.evaluate(()=>smartDemo.plan());
 const go=async(product,screen='train',language='uk')=>{await page.goto(`${origin}/runner.html?version=v008&product=${product}&screen=${screen}&language=${language}`);await page.evaluate(()=>v008Ready);};
 async function audit(label){
  await page.waitForTimeout(250);
  const issues=await page.evaluate(()=>{
   const d=document.querySelector('.device').getBoundingClientRect(),out=[];
   for(const el of document.querySelectorAll('#app *,#overlay *')){const r=el.getBoundingClientRect();if(!r.width||!r.height)continue;if(r.left<d.left-1||r.right>d.right+1)out.push(el.className+' overflow');if(el.matches('button,input')&&!el.disabled&&!el.closest('[inert]')&&(r.width<43.9||r.height<43.9))out.push(el.className+' target');}
   return out;
  });assert.deepEqual(issues,[],label);
 }
 const capture=async(product,name)=>{await page.evaluate(()=>document.querySelectorAll('.scroll').forEach(el=>el.scrollTop=0));const dir=path.join(output,'screenshots',product);fs.mkdirSync(dir,{recursive:true});await page.screenshot({path:path.join(dir,'smart-'+name+'.png')});};
 try {
  for(const product of ['OnlyBody','OnlyWeights']){
   await go(product);await page.evaluate(()=>localStorage.clear());await page.reload();await page.evaluate(()=>v008Ready);
   assert.equal(await page.evaluate(()=>D.products[product].exercises.length),product==='OnlyBody'?91:103);
   await click('create');await click('chooseSmart');await click('muscle:Lower');await click('buildSmart');
   assert.equal((await config()).level,'beginner');await click('smartMinutes:30');await click('smartLevel:intermediate');await capture(product,'setup');
   await click('smartOptions');
   if(product==='OnlyWeights')await click('smartGym:false');
   await click('smartEquipmentPanel');await click('smartEquipmentDraft:'+(product==='OnlyBody'?'Pull-up Bar':'Dumbbells'));await page.keyboard.press('Escape');assert.deepEqual((await config()).equipment,[]);
   await click('smartEquipmentPanel');await click('smartEquipmentDraft:'+(product==='OnlyBody'?'Pull-up Bar':'Dumbbells'));await click('smartEquipmentApply');assert.equal((await config()).equipment.length,1);
   if(product==='OnlyWeights')await click('smartGym:true');
   const before=await config();await click('smartRegions');await click('smartArea:wrist');await click('smartLoad:palms');
   assert.deepEqual((await config()).loads,[]);await page.keyboard.press('Escape');assert.deepEqual((await config()).loads,[]);
   await click('smartRegions');await click('smartArea:shoulder');await click('smartLoad:overhead');await click('smartConfirmLoads');assert.deepEqual((await config()).loads,['overhead']);
   assert.deepEqual((await config()).equipment,before.equipment);assert.equal((await config()).gym,true);await capture(product,'options');
   await click('smartPreview');let p=await plan();assert.equal(p.gaps.length,0);assert.ok(p.items.every(e=>!e.loads.includes('overhead')));assert.ok(p.seconds<=30*60);
   await click('smartSave');assert.equal(await page.locator('[data-action="smartStart"]').count(),1);
   await capture(product,'today');const saved=await plan();await page.reload();await page.evaluate(()=>v008Ready);await click('smartOpen');assert.deepEqual(await plan(),saved);
   await click('smartEdit');await click('smartMinutes:60');await click('smartCancel');assert.equal((await config()).minutes,30);
   await click('smartSchedule');await page.locator('#smart-name').fill('Smart QA');await click('smartDay:Mon');await click('smartScheduleApply');assert.equal((await config()).name,'Smart QA');
   await click('smartReplace:0');await click('smartAlternatives:another');assert.ok(await page.locator('[data-action^="smartSelect:"]').count());
   const original=(await plan()).items[0].name;await page.locator('[data-action^="smartSelect:"]').first().click();assert.notEqual((await plan()).items[0].name,original);
   const revised=await plan();await page.reload();await page.evaluate(()=>v008Ready);await click('smartOpen');assert.deepEqual(await plan(),revised);
   await act('smartNextDay');const tomorrow=await plan();assert.equal(tomorrow.items[0].name,original);assert.notEqual(tomorrow.date,revised.date);
   await click('smartStart');const active=await page.evaluate(()=>structuredClone(mock.state().active.workout.items));
   await act('smartNextDay');assert.deepEqual(await page.evaluate(()=>mock.state().active.workout.items),active);
   await click('sessionList');await capture(product,'active-list');await click('smartReplace:0');await click('smartAlternatives:another');await page.locator('[data-action^="smartSelect:"]').first().click();
   assert.notEqual(await page.evaluate(()=>mock.state().active.workout.items[0].name),active[0].name);
   assert.equal((await config()).excluded.length,0);await act('resumeSession');await page.locator('.set-check').first().click();await click('sessionList');await click('endWorkout');await click('saveAndEnd');await click('closeWorkout');
   assert.equal(await page.evaluate(()=>mock.state().sessions[0].items[0].setReps.length),1);
   report.flows.push(product+': create → loads confirmed/cancelled → save → reload → cancel settings → schedule → local replacement → next day restores main → active session frozen → completion');

   // Explicit future exclusion is independent of a one-session replacement.
   await click('smartOpen');const excluded=(await plan()).items[0].name;await click('smartReplace:0');await click('smartPermanent');await click('smartConfirmPermanent');
   assert.ok((await config()).excluded.includes(excluded));await act('smartDismiss');await act('smartNextDay');assert.ok(!(await plan()).items.some(e=>e.name===excluded));
   await click('smartEdit');await click('smartOptions');await click('smartRestore:0');await click('smartPreview');await click('smartSave');assert.deepEqual((await config()).excluded,[]);
   report.flows.push(product+': separately confirmed future exclusion and restore');

   // Concrete load conflict. The region itself has no filtering effect.
   await click('smartEdit');await click('smartOptions');await click('smartRegions');await click('smartArea:knee');
   assert.deepEqual((await config()).loads,['overhead']);await click('smartLoad:standing');await click('smartConfirmLoads');await click('smartPreview');
   p=await plan();assert.ok(p.items.every(e=>!e.loads.includes('standing')));
   const index=p.items.findIndex(e=>e.movement===(product==='OnlyBody'?'hinge':'squat'));assert.ok(index>=0);
   await click('smartReplace:'+index);await click('smartAlternatives:another');await click('smartConflicts');await page.locator('[data-action^="smartSelect:"]').first().click();
   assert.ok(await page.locator('[data-action^="smartConfirmReplace:"]').count());await audit('conflict');await capture(product,'conflict');
   const restricted=await config();await page.locator('[data-action^="smartConfirmReplace:"]').click();assert.deepEqual((await config()).loads,restricted.loads);assert.ok((await plan()).items[index].loads.includes('standing'));
   report.flows.push(product+': manual load conflict requires explicit confirmation and keeps other exclusions');

   await go(product,'smartSetup');await click('smartBack');
   // Replace the selected Lower target with Full Body using the existing picker.
   await click('muscle:Lower');await click('muscle:Full Body');await click('buildSmart');await click('smartOptions');
   if(product==='OnlyWeights')await click('smartGym:false');await act('smartEquipmentPanel');for(const equipment of (await config()).equipment)await act('smartEquipmentDraft:'+equipment);await act('smartEquipmentApply');await click('smartPreview');assert.ok((await plan()).gaps.length);assert.equal(await page.locator('[data-action="smartSave"]').isDisabled(),true);await capture(product,'gap');
   report.flows.push(product+': uncovered needs shown; incomplete workout cannot be saved or started');
  }
  // All new panels across each product, language and supported width.
  for(const product of ['OnlyBody','OnlyWeights'])for(const language of ['uk','en','pl','de','fr'])for(const [width,height] of [[375,812],[393,852],[440,956]]){
   await page.setViewportSize({width,height});await go(product,'smartOptions',language);await act('smartEquipmentPanel');await audit('equipment');report.panels++;await act('smartDismiss');
   for(const area of ['wrist','shoulder']){await act('smartRegions');await audit('regions');report.panels++;await act('smartArea:'+area);await audit('loads');report.panels++;await act('smartDismiss');}
   await go(product,'smartToday',language);await act('smartReplace:0');await audit('replacement reason');report.panels++;await act('smartAlternatives:another');await audit('alternatives');report.panels++;await act('smartDismiss');await act('smartSchedule');await audit('schedule');report.panels++;await act('smartDismiss');
  }
  assert.deepEqual(report.issues,[]);report.status='PASS';
 }catch(e){report.status='FAIL';report.issues.push(e.stack);}finally{await browser.close();fs.writeFileSync(path.join(output,'smart-verification.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify(report,null,2));if(report.status!=='PASS')process.exitCode=1;}
})();
