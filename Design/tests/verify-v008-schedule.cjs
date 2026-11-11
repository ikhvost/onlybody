/* Smart and manual cards must share one calendar-based grouping. */
const {chromium}=require('playwright');
const assert=require('node:assert/strict');
const fs=require('node:fs');
const path=require('node:path');
const origin=process.env.DESIGN_URL||'http://127.0.0.1:8772';
const output=path.resolve(__dirname,'../versions/v008');
(async()=>{
 const browser=await chromium.launch({channel:'chrome',headless:true});
 const report={scope:'v008 shared schedule grouping',products:[],issues:[]};
 try {
  for(const product of ['OnlyBody','OnlyWeights']){
   const page=await browser.newPage({viewport:{width:393,height:852},timezoneId:'Europe/Warsaw'});
   page.on('pageerror',error=>report.issues.push(error.message));
   await page.clock.setFixedTime(new Date('2026-11-06T12:00:00Z'));
   await page.goto(`${origin}/runner.html?version=v008&product=${product}&language=en&screen=train`);
   await page.evaluate(()=>v008Ready);
   const act=value=>page.evaluate(value=>mock.act(value),value);
   const group=()=>page.locator('.smart-home-card').evaluate(card=>{let sibling=card.previousElementSibling;while(sibling&&!sibling.matches('.section-heading'))sibling=sibling.previousElementSibling;return sibling?.textContent.trim();});
   assert.equal(await group(),'Today');
   assert.equal(await page.locator('.smart-home-card [data-action="smartOpen"].primary').innerText(),'Start');
   assert.equal(await page.locator('.home-content > :first-child').evaluate(el=>el.matches('.section-heading')),true);
   // On Saturday, the manual Saturday fixtures are in Today and Smart moves to Other.
   await act('smartNextDay');assert.notEqual(await group(),'Today');
   assert.equal(await page.locator('.smart-home-card [data-action="smartOpen"].primary').count(),0);
   assert.equal(await page.locator('.rest-day').count(),0);
   // Changing the saved schedule takes effect on the home screen immediately.
   await act('smartOpen');await act('smartSchedule');await act('smartDay:Sat');await act('smartScheduleApply');await act('smartExit');
   assert.equal(await group(),'Today');
   await page.reload();await page.evaluate(()=>v008Ready);assert.equal(await group(),'Today');
   const dir=path.join(output,'screenshots',product);fs.mkdirSync(dir,{recursive:true});
   await page.screenshot({path:path.join(dir,'smart-scheduled-home.png')});
   // Only Smart is scheduled: it replaces the rest-day placeholder.
   await page.evaluate(()=>{mock.state().workouts=[];mock.render();});
   assert.equal(await group(),'Today');assert.equal(await page.locator('.rest-day,.empty-state').count(),0);
   // Unscheduled Smart remains accessible in Other and leaves Today as a rest day.
   await act('smartOpen');await act('smartSchedule');
   for(const day of ['Mon','Wed','Fri','Sat'])await act('smartDay:'+day);
   await act('smartScheduleApply');await act('smartExit');assert.notEqual(await group(),'Today');assert.equal(await page.locator('.rest-day').count(),1);
   // Returning to today preserves the user's saved workout preferences.
   const savedConfig=await page.evaluate(()=>smartDemo.config());
   await act('smartResetDay');
   assert.equal(await page.evaluate(()=>smartDemo.model().offset),0);
   assert.deepEqual(await page.evaluate(()=>smartDemo.config()),savedConfig);
   // Explicit empty fixtures still hide the Smart demo.
   await page.goto(`${origin}/runner.html?version=v008&product=${product}&language=en&screen=train&scenario=empty`);await page.evaluate(()=>v008Ready);
   assert.equal(await page.locator('.smart-home-card').count(),0);assert.equal(await page.locator('.empty-state').count(),1);
   report.products.push({product,status:'PASS',checks:['scheduled Today','unscheduled Other','same day for manual and Smart','schedule edit and reload','Smart-only Today','rest-day placeholder','reset demo date preserves settings','empty scenario']});
   await page.close();
  }
  assert.deepEqual(report.issues,[]);report.status='PASS';
 }catch(error){report.status='FAIL';report.issues.push(error.stack);}finally{await browser.close();fs.writeFileSync(path.join(output,'schedule-verification.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify(report,null,2));if(report.status!=='PASS')process.exitCode=1;}
})();
