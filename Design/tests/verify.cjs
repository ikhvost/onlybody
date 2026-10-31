/* Run against the local Design server. Requires Playwright supplied by the host. */
const {chromium}=require('playwright');
const assert=require('node:assert/strict');
const fs=require('node:fs');
const path=require('node:path');
const crypto=require('node:crypto');
const root=path.resolve(__dirname,'..');
const origin=process.env.DESIGN_URL||'http://127.0.0.1:8772';
const routes=['train','train-empty','musclePicker','builder','exercisePicker','active','rest','complete','exerciseHistory','log','session','library','movement','settings','notifications','creation','statistics'];
const products=['OnlyBody','OnlyWeights'],languages=['uk','en','pl','de','fr'];
const report={date:'2026-10-31',scope:'HTML prototype / desktop Chromium; no native or physical-device validation',matrix:0,flows:[],issues:[],screenshots:[],physicalPhone:'UNCONFIRMED',nativeAccessibility:'UNCONFIRMED'};
function contrastChecks(){
 function luminance(hex){const c=hex.match(/../g).map(x=>parseInt(x,16)/255).map(v=>v<=.04045?v/12.92:((v+.055)/1.055)**2.4);return c[0]*.2126+c[1]*.7152+c[2]*.0722}
 const pairs=[];for(const foreground of ['F5F0E8','B9B6AE','96938B','E8A23A','FF9689'])for(const background of ['10110F','1B1D19','242720']){const [a,b]=[luminance(foreground),luminance(background)].sort((a,b)=>a-b),ratio=(b+.05)/(a+.05);assert.ok(ratio>=4.5,foreground+'/'+background);pairs.push({foreground,background,ratio:Number(ratio.toFixed(2))})}report.contrast=pairs;
}
function checkBaseline(){const checks=JSON.parse(fs.readFileSync(path.join(root,'baseline-checksums.json')));for(const [file,expected]of Object.entries(checks))assert.equal(crypto.createHash('sha256').update(fs.readFileSync(path.join(root,'versions/v000',file))).digest('hex'),expected,file);report.baselineFiles=Object.keys(checks).length}
async function audit(page,label){
 const issues=await page.evaluate(()=>{
  const problems=[];const app=document.querySelector('.device'),limit=app.getBoundingClientRect();
  for(const el of document.querySelectorAll('#app *,#overlay *')){
   const r=el.getBoundingClientRect(),s=getComputedStyle(el);if(!r.width||!r.height||s.visibility==='hidden'||s.display==='none')continue;
   // Scroll content may extend vertically; no app element should require horizontal panning.
   if(r.left<limit.left-1||r.right>limit.right+1)problems.push({kind:'horizontal-overflow',tag:el.tagName,cls:el.className,text:el.textContent.slice(0,60),left:r.left,right:r.right});
   if(el.matches('button,input,a,summary')&&!el.closest('[inert]')&&!el.disabled&&r.bottom>0&&r.top<innerHeight){
    if(r.height<43.9||r.width<43.9)problems.push({kind:'small-target',tag:el.tagName,text:el.textContent.slice(0,60),width:r.width,height:r.height});
   }
  }
  return problems;
 });
 report.issues.push(...issues.map(issue=>({label,...issue})));
}
async function click(page,action){await page.locator(`[data-action="${action}"]`).last().click()}
async function navigate(page,route){await page.evaluate(r=>mock.navigate(r),route)}
async function screenshot(page,product,route){const name=`versions/v001/screenshots/${product}/uk/${route}.png`;fs.mkdirSync(path.dirname(path.join(root,name)),{recursive:true});await page.waitForTimeout(100);await page.screenshot({path:path.join(root,name)});report.screenshots.push(name)}
(async()=>{
 checkBaseline();contrastChecks();
 const browser=await chromium.launch({channel:'chrome',headless:true});
 try{
 const context=await browser.newContext({viewport:{width:393,height:852},timezoneId:'Europe/Warsaw'});
 await context.route('**/*',route=>{const u=new URL(route.request().url());if(u.origin===origin||u.protocol==='data:')return route.continue();return route.abort()});
 const page=await context.newPage();
 page.on('pageerror',e=>report.issues.push({kind:'javascript',message:e.message}));
 page.on('console',e=>{if(e.type()==='warning')report.issues.push({kind:'console-warning',message:e.text()})});
 await page.goto(origin+'/runner.html?version=v001');await page.evaluate(()=>document.fonts.ready);
 for(const product of products)for(const language of languages)for(const [width,height]of [[375,812],[393,852],[440,956]]){
  await page.setViewportSize({width,height});
  for(const screen of routes){
   await page.evaluate(o=>mock.configure(o),{product,language,screen});
   await audit(page,`${product}/${language}/${width}/${screen}`);report.matrix++;
   if(language==='uk'&&width===393)await screenshot(page,product,screen);
   if(['builder','library','exercisePicker'].includes(screen)){
    await page.evaluate(s=>mock.act(s==='builder'?'editMovement:0':'openFilters:'+(s==='exercisePicker')),screen);
    await audit(page,`${product}/${language}/${width}/${screen}/panel`);report.matrix++;
   }
  }
 }
 console.log('Matrix',report.matrix,'issues',report.issues.length);
 await page.setViewportSize({width:393,height:852});
 for(const product of products){
  await page.evaluate(p=>mock.configure({product:p,language:'uk',screen:'train'}),product);
  const originalCount=await page.evaluate(()=>mock.state().workouts.length);
  await click(page,'create');await click(page,'buildManual');
  await page.locator('#builder-name').fill('QA workout');
  await click(page,'pickExercise');await page.locator('#catalog-search').fill(product==='OnlyBody'?'Bird Dog':'Lat Pulldown');
  await page.locator('[data-action^="addExercise:"]').first().click();
  await click(page,'editMovement:0');
  await page.locator('[data-number="sets"]').fill('2');await page.locator('[data-number="reps"]').fill('8');
  await click(page,'closeOverlay');
  assert.equal(await page.evaluate(()=>mock.state().builder.items[0].sets),2);
  await click(page,'save');assert.equal(await page.evaluate(()=>mock.state().workouts.length),originalCount+1);
  const id=await page.evaluate(()=>mock.state().workouts.at(-1).id);
  await click(page,'edit:'+id);await page.locator('#builder-name').fill('QA changed');await click(page,'builderBack');
  assert.equal(await page.locator('[role="alertdialog"]').count(),1);await click(page,'discardBuilder');
  await click(page,'edit:'+id);await click(page,'editMovement:0');await click(page,'removeMovement:0');await click(page,'editMovement:0');assert.equal(await page.evaluate(()=>mock.state().builder.items.length),1);
  await click(page,'closeOverlay');await click(page,'builderBack');
  await click(page,'start:'+id);
  if(product==='OnlyBody')await click(page,'showWeight');
  await page.locator('[data-number="activeReps"]').fill('bad');await click(page,'markDone');assert.equal(await page.evaluate(()=>mock.state().active.completed.length),0);assert.equal(await page.locator('[aria-invalid="true"]').count(),1);
  await page.locator('[data-number="activeReps"]').fill('9');await page.locator('[data-number="activeWeight"]').fill('12,5');await click(page,'markDone');
  assert.equal(await page.evaluate(()=>mock.state().route),'rest');await click(page,'skipRest');
  await page.locator('[data-number="activeReps"]').fill('7');await click(page,'markDone');
  assert.equal(await page.evaluate(()=>mock.state().route),'complete');
  assert.deepEqual(await page.evaluate(()=>mock.state().sessions[0].items[0].setReps),[9,7]);
  assert.deepEqual(await page.evaluate(()=>mock.state().sessions[0].items[0].setWeights),[12.5,12.5]);
  await click(page,'closeWorkout');await click(page,'tab:log');await page.locator('[data-action^="session:"]').first().click();assert.match(await page.locator('#app').innerText(),/QA workout/);
  report.flows.push(product+': create → edit/cancel → number validation → two sets → rest → complete → log/detail');

  await navigate(page,'train');await click(page,'create');await click(page,'chooseSmart');await click(page,'muscle:Back');await click(page,'buildSmart');await page.locator('#builder-name').fill('QA Smart');await click(page,'save');assert.equal(await page.evaluate(()=>mock.state().workouts.at(-1).mode),'smart');
  report.flows.push(product+': smart selection');

  await navigate(page,'active');await click(page,'endWorkout');await click(page,'discardWorkout');assert.equal(await page.evaluate(()=>mock.state().route),'train');
  await navigate(page,'active');await page.evaluate(()=>{mock.state().failSave=true});await click(page,'endWorkout');await click(page,'saveAndEnd');
  assert.equal(await page.evaluate(()=>mock.state().active.saved),undefined);assert.equal(await page.locator('[data-action="retrySave"]').count(),1);await screenshot(page,product,'save-error');
  const count=await page.evaluate(()=>mock.state().sessions.length);await click(page,'retrySave');assert.equal(await page.evaluate(()=>mock.state().sessions.length),count+1);await page.evaluate(()=>mock.act('retrySave'));assert.equal(await page.evaluate(()=>mock.state().sessions.length),count+1);
  report.flows.push(product+': early discard, early save failure, retry once');

  await navigate(page,'library');await click(page,'openFilters:false');await click(page,'filter:false:Back');await click(page,'difficulty:false:beginner');await audit(page,product+'/filters');await screenshot(page,product,'filters');await click(page,'closeFilters');
  assert.equal(await page.evaluate(()=>mock.state().filter),'Back');await page.locator('#catalog-search').fill('zzzzzzzz');assert.equal(await page.locator('.exercise-row').count(),0);await click(page,'resetFilters:false');assert.ok(await page.locator('.exercise-row').count()>0);
  await navigate(page,'builder');await click(page,'editMovement:0');await audit(page,product+'/movement-panel');await screenshot(page,product,'movement-panel');await click(page,'closeOverlay');
  await click(page,'pickExercise');await click(page,'openFilters:true');await click(page,'filter:true:Back');await click(page,'closeFilters');assert.equal(await page.locator('[data-action^="addExercise:"]').count()>0,true);await click(page,'closePicker');
  await navigate(page,'settings');await click(page,'unit');await click(page,'setUnit:lb');assert.equal(await page.evaluate(()=>mock.state().unit),'lb');
  await navigate(page,'notifications');await click(page,'notificationTime:15:30');assert.equal(await page.evaluate(()=>mock.state().notificationTime),'15:30');
  await navigate(page,'movement');await click(page,'videoPermission');await click(page,'denyTracking');assert.equal(await page.locator('.player-placeholder').count(),0);
  await page.evaluate(()=>{mock.state().tracking='notDetermined';mock.render()});await click(page,'videoPermission');await click(page,'allowTracking');assert.equal(await page.locator('.player-placeholder').count(),1);
  const player=await page.locator('.player-placeholder').boundingBox();assert.ok(player.width>=200&&player.height>=200);
  report.flows.push(product+': library/picker filters, empty search, panels, units, reminders, simulated video denial');
 }
 // Frozen timer and fixture scenarios.
 await page.goto(origin+'/runner.html?version=v001&screen=active');const elapsed=await page.evaluate(()=>mock.state().active.elapsed);await page.waitForTimeout(1100);assert.equal(await page.evaluate(()=>mock.state().active.elapsed),elapsed);
 for(const scenario of ['multiple','rest-day','empty','long']){
  await page.goto(origin+`/runner.html?version=v001&scenario=${scenario}`);await audit(page,'scenario/'+scenario);
  if(scenario==='multiple')assert.equal(await page.locator('.workout-card').count(),4);
  if(scenario==='empty')assert.equal(await page.locator('[data-action="create"]').count(),1);
 }
 await page.goto(origin+'/?compare=true&screen=active');await page.waitForSelector('iframe');await page.waitForFunction(()=>[...document.querySelectorAll('iframe')].every(f=>f.contentWindow.mock));assert.equal(await page.locator('iframe').count(),2);
 assert.deepEqual(await page.evaluate(()=>[...document.querySelectorAll('iframe')].map(f=>f.contentWindow.mock.state().active.reps)),[12,12]);
 report.flows.push('Frozen clock, fixture scenarios and 440pt comparison');
 await page.setViewportSize({width:1440,height:1120});await page.waitForTimeout(300);await page.screenshot({path:path.join(root,'studio.png')});
 report.status=report.issues.length?'FAIL':'PASS';
 }catch(error){report.status='FAIL';report.issues.push({kind:'test-failure',message:error.stack});console.error(error)}finally{
  fs.writeFileSync(path.join(root,'versions/v001/verification.json'),JSON.stringify(report,null,2)+'\n');await browser.close();
 }
 console.log(JSON.stringify({status:report.status,matrix:report.matrix,flows:report.flows.length,issues:report.issues.slice(0,15)},null,2));
 if(report.status!=='PASS')process.exitCode=1;
})();
