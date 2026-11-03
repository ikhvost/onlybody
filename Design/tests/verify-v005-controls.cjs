const {chromium}=require('playwright');
const assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path');
const origin=process.env.DESIGN_URL||'http://127.0.0.1:8772';
const output=path.resolve(__dirname,'../versions/v005');
const report={date:new Date().toLocaleDateString('en-CA',{timeZone:'Europe/Warsaw'}),scope:'v005 browser control semantics, not native accessibility',menus:0,timingPanels:0,flows:[],issues:[]};
(async()=>{
 const browser=await chromium.launch({channel:'chrome'}),page=await browser.newPage({viewport:{width:393,height:852}});
 page.on('pageerror',e=>report.issues.push(e.message));
 const go=async(product,screen,language='en',width=393)=>{
  await page.setViewportSize({width,height:{375:812,393:852,440:956}[width]});
  await page.goto(`${origin}/runner.html?version=v005&product=${product}&screen=${screen}&language=${language}`);
  await page.evaluate(()=>v005Ready);
 };
 const act=value=>page.evaluate(value=>mock.act(value),value);
 const data=()=>page.evaluate(()=>mock.state());
 const screenshot=async(product,name)=>{const dir=path.join(output,'screenshots',product);fs.mkdirSync(dir,{recursive:true});await page.screenshot({path:path.join(dir,name+'.png')})};
 try {
  for(const product of ['OnlyBody','OnlyWeights'])for(const language of ['uk','en','pl','de','fr'])for(const width of [375,393,440])for(const screen of ['workout','builder']){
   await go(product,screen,language,width);
   await page.locator('.item-more').first().click();
   assert.ok(await page.locator('#app').evaluate(el=>el.inert));
   const problems=await page.locator('.item-actions').evaluate(el=>[...el.querySelectorAll('*')].flatMap(node=>{const b=node.getBoundingClientRect();return b.width&&b.height&&(b.left<0||b.right>innerWidth||(node.matches('button')&&(b.width<44||b.height<44)))?[node.className]:[]}));
   assert.deepEqual(problems,[],`${product}/${language}/${width}/${screen}`);
   assert.equal(await page.locator('[data-action="menuMove:-1"]').isDisabled(),true);
   if(language==='en'&&width===393)await screenshot(product,screen+'-actions');
   report.menus++;
   if(screen==='builder'){
    await page.keyboard.press('Escape');await act('timing:rest');
    const problems=await page.locator('#overlay .sheet').evaluate(el=>[...el.querySelectorAll('*')].flatMap(node=>{const b=node.getBoundingClientRect();return b.width&&b.height&&(b.left<0||b.right>innerWidth||(node.matches('button')&&(b.width<44||b.height<44)))?[node.className]:[]}));
    assert.deepEqual(problems,[],`${product}/${language}/${width}/timing`);
    assert.equal(await page.locator('#overlay .nav-control').getAttribute('data-navigation'),'close');
    report.timingPanels++;
   }
  }
  for(const product of ['OnlyBody','OnlyWeights']){
   for(const screen of ['movement','exerciseHistory','builder','settings']){
    await go(product,screen);
    const button=page.locator('.nav-control').first();
    assert.equal(await button.innerText(),'');
    assert.equal(await button.getAttribute('data-navigation'),'back');
    const bounds=await button.boundingBox();assert.equal(bounds.width,44);assert.equal(bounds.height,44);
   }
   await go(product,'workout');
   const original=(await data()).workouts[0],uid=(await data()).active.workout.items[0].uid;
   const opener=`itemActions:session:${uid}`;
   await page.locator('.item-more').first().focus();await page.keyboard.press('Enter');
   await page.keyboard.press('Escape');
   assert.equal(await page.evaluate(()=>document.activeElement.dataset.action),opener);
   await page.keyboard.press('Enter');
   await page.locator('[data-action="menuMove:1"]').click();
   assert.equal((await data()).active.workout.items[1].uid,uid);
   assert.deepEqual((await data()).workouts[0],original);
   assert.equal(await page.evaluate(()=>document.activeElement.dataset.action),opener);
   await page.keyboard.press('Enter');await page.locator('[data-action="menuReplace"]').click();
   assert.equal((await data()).overlay.kind,'replacement');
   await page.locator('#overlay [data-navigation="close"]').click();
   assert.equal(await page.evaluate(()=>document.activeElement.dataset.action),opener);
   await page.locator('.item-more').last().click();assert.equal(await page.locator('[data-action="menuMove:1"]').isDisabled(),true);await page.keyboard.press('Escape');
   report.flows.push(product+': icon-only back; keyboard menu, Escape, focus return, stable-identity move, replacement, boundary controls');

   await go(product,'library');assert.equal(await page.locator('.filter-count').count(),0);
   const before=(await data()).filter;
   await page.locator('.filter-button').click();await act('filter:false:Back');
   await page.locator('#overlay [data-navigation="close"]').click();assert.equal((await data()).filter,before);
   await page.locator('.filter-button').click();await act('filter:false:Back');await page.locator('[data-action="closeFilters"]').click();
   assert.equal((await data()).filter,'Back');assert.equal(await page.locator('.filter-count').innerText(),'1');assert.equal(await page.locator('.selected-filter').innerText(),'Back');
   await screenshot(product,'library-filtered');
   await page.locator('.filter-button').click();await act('filter:false:Chest');await page.keyboard.press('Escape');assert.equal((await data()).filter,'Back');
   await go(product,'workout');await act('replaceItem:session:0');await page.locator('.filter-button').click();
   assert.equal(await page.locator('#overlay .nav-control').getAttribute('data-navigation'),'back');
   await act('filter:true:Back');await page.locator('#overlay .nav-control').click();assert.equal((await data()).overlay.kind,'replacement');assert.equal((await data()).pickerFilter,'Back');
   await page.locator('.filter-button').click();await act('filter:true:Chest');await page.keyboard.press('Escape');assert.equal((await data()).overlay.kind,'replacement');assert.equal((await data()).pickerFilter,'Back');
   report.flows.push(product+': filter cancel/apply/Escape, nonzero badge, chips, nested Back returns to replacement');

   await go(product,'builder');let beforeBuilder=structuredClone((await data()).builder),dirty=(await data()).dirty;
   await act('editMovement:0');await page.locator('[data-number="sets"]').fill('6');await page.locator('#overlay .nav-control').click();
   assert.deepEqual((await data()).builder,beforeBuilder);assert.equal((await data()).dirty,dirty);
   await act('editMovement:0');await page.locator('[data-number="sets"]').fill('6');await page.locator('[data-action="closeOverlay"]').click();assert.equal((await data()).builder.items[0].sets,6);
   await act('editMovement:0');await page.locator('[data-number="sets"]').fill('invalid');await page.keyboard.press('Escape');assert.equal((await data()).builder.items[0].sets,6);assert.equal((await data()).overlay,null);
   beforeBuilder=structuredClone((await data()).builder);await act('timing:rest');await act('setTiming:120');await page.locator('#overlay .nav-control').click();assert.deepEqual((await data()).builder,beforeBuilder);
   report.flows.push(product+': numeric panel cancel/apply/invalid Escape, timing rollback preserves builder and dirty state');

   await go(product,'active');const check=page.locator('.set-check').first();
   assert.equal(await check.innerText(),'✓');assert.equal(await check.getAttribute('aria-pressed'),'false');
   await check.click();assert.equal(await page.locator('.set-check').first().getAttribute('aria-pressed'),'true');
   await act('sessionList');await page.locator('.item-more').first().click();assert.equal(await page.locator('[data-action="menuReplace"]').isDisabled(),true);assert.equal(await page.locator('#replacement-lock').count(),1);
   await screenshot(product,'locked-actions');await page.keyboard.press('Escape');
   await go(product,'workout');await page.locator('.session-item-open').first().click();assert.equal(await page.locator('.set-check').first().isDisabled(),true);
   report.flows.push(product+': visible completion glyph, pressed semantics, completed replacement lock, pre-start controls disabled');
  }
  assert.deepEqual(report.issues,[]);report.status='PASS';
 }catch(e){report.status='FAIL';report.issues.push(e.stack)}finally{await browser.close();fs.writeFileSync(path.join(output,'controls-verification.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify(report,null,2));if(report.status!=='PASS')process.exitCode=1}
})();
