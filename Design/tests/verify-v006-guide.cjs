/* Interaction regression: distinct add/guide targets, return context and video disclosure. */
const {chromium}=require('playwright');
const assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path');
const origin=process.env.DESIGN_URL||'http://127.0.0.1:8772';
const output=path.resolve(__dirname,'../versions/v006');
const report={date:new Date().toLocaleDateString('en-CA',{timeZone:'Europe/Warsaw'}),scope:'v006 browser picker and video presentation; no real video playback or system permission',pickerCases:0,videoCases:0,flows:[],issues:[]};
(async()=>{
 const browser=await chromium.launch({channel:'chrome'}),page=await browser.newPage();
 page.on('pageerror',error=>report.issues.push(error.message));
 const remoteMedia=[];
 page.on('request',request=>{if(/youtube|googlevideo|ytimg|doubleclick/.test(new URL(request.url()).hostname))remoteMedia.push(request.url())});
 const act=value=>page.evaluate(value=>mock.act(value),value);
 const data=()=>page.evaluate(()=>mock.state());
 async function go(product,language,width,screen){
  await page.setViewportSize({width,height:{375:812,393:852,440:956}[width]});
  await page.goto(`${origin}/runner.html?version=v006&product=${product}&language=${language}&screen=${screen}`);
  await page.evaluate(()=>v006Ready);
 }
 async function centered(selector){
  const offset=await page.locator(selector).first().evaluate(el=>{
   const a=el.getBoundingClientRect(),b=el.querySelector('.icon').getBoundingClientRect();
   return Math.abs((a.top+a.bottom-b.top-b.bottom)/2);
  });
  assert.ok(offset<1,`${selector}: vertical offset ${offset}`);
 }
 async function capture(product,name){
  const folder=path.join(output,'screenshots',product);fs.mkdirSync(folder,{recursive:true});
  await page.screenshot({path:path.join(folder,name+'.png')});
 }
 try{
  for(const product of ['OnlyBody','OnlyWeights'])for(const language of ['uk','en','pl','de','fr'])for(const width of [375,393,440]){
   if (!process.env.DESIGN_VIDEO_ONLY) {
   await go(product,language,width,'library');await centered('.search-box');
   await go(product,language,width,'workout');await act('replaceItem:session:0');await centered('.replacement-controls .search-box');
   for(const modal of [false,true]){
    await go(product,language,width,modal?'builder':'exercisePicker');
    if(modal){await centered('.item-more');await act('pickExercise')}
    const host=modal?'#overlay':'#app';
    await centered(`${host} .search-box`);
    const items=JSON.stringify((await data()).builder.items);
    await page.locator(`${host} #catalog-search`).fill('a');
    // The same query and selected filters must survive opening a guide.
    if(await page.locator(`${host} .picker-guide`).count()){
     await page.locator(`${host} .picker-guide`).first().click();
     assert.equal((await data()).route,'movement');
     assert.equal(JSON.stringify((await data()).builder.items),items);
     await page.locator('#app [data-navigation="back"]').click();
     assert.equal(await page.locator(`${host} #catalog-search`).inputValue(),'a');
    }
    await page.locator(`${host} #catalog-search`).fill('');
    await act('openFilters:true');
    await page.locator('[data-action^="filter:true:"]').nth(1).click();
    await act('closeFilters');
    const selected=(await data()).pickerFilter;
    assert.notEqual(selected,'All');
    await page.locator(`${host} .picker-guide`).first().click();
    await page.locator('#app [data-navigation="back"]').click();
    assert.equal((await data()).pickerFilter,selected);
    await act('resetFilters:true');
    await page.locator(`${host} #catalog-results`).evaluate(el=>el.scrollTop=240);
    const row=page.locator(`${host} .picker-guide`).nth(3);
    await row.scrollIntoViewIfNeeded();
    const opener=await row.getAttribute('data-action');
    const scroll=await page.locator(`${host} #catalog-results`).evaluate(el=>el.scrollTop);
    await row.click();
    assert.equal((await data()).route,'movement');
    assert.equal((await data()).overlay,null);
    assert.equal(await page.locator('#app').evaluate(el=>el.inert),false);
    assert.equal(JSON.stringify((await data()).builder.items),items);
    await page.locator('#app [data-navigation="back"]').press('Enter');
    assert.ok(Math.abs(await page.locator(`${host} #catalog-results`).evaluate(el=>el.scrollTop)-scroll)<1);
    assert.equal(await page.evaluate(()=>document.activeElement.dataset.action),opener);
    if(modal)assert.equal(await page.locator('#app').evaluate(el=>el.inert),true);
    const before=(await data()).builder.items.length;
    const index=opener.split(':')[1];
    await page.locator(`${host} [data-action="addExercise:${index}"]`).press('Enter');
    assert.equal((await data()).builder.items.length,before+1);
    assert.equal((await data()).route,'builder');
    assert.equal((await data()).overlay,null);
    report.pickerCases++;
   }
   }
   await go(product,language,width,'movement');
   assert.equal(await page.locator('.consent-card').count(),1);
   const geometry=await page.locator('.consent-card').evaluate(card=>[...card.querySelectorAll('*')].flatMap(el=>{const r=el.getBoundingClientRect();return r.width&&r.height&&(r.left<0||r.right>innerWidth||(el.matches('a,button,summary')&&(r.width<44||r.height<44)))?[el.className]:[]}));
   assert.deepEqual(geometry,[]);
   assert.ok(await page.locator('.consent-card').evaluate(el=>el.getBoundingClientRect().top<document.querySelector('.equipment').getBoundingClientRect().top));
   assert.equal(await page.locator('.video-disclosure').getAttribute('open'),null);
   assert.equal(await page.locator('.legal-links a').count(),2);
   assert.equal(await page.locator('.youtube-link').count(),1);
   assert.equal(await page.locator('.consent-card > .youtube-link.primary').count(),1);
   assert.match(await page.locator('.youtube-link').getAttribute('href'),/^https:\/\/www\.youtube\.com\/watch\?v=/);
   assert.equal(await page.locator('.youtube-link').getAttribute('target'),'_blank');
   assert.ok(await page.locator('.author').innerText());
   if(language==='en'&&width===393)await capture(product,'guide-video-first');
   await page.locator('.video-disclosure summary').click();
   assert.ok(await page.locator('.video-disclosure p').first().isVisible());
   await page.locator('[data-action="videoPermission"]').click();
   await page.locator('[data-action="denyTracking"]').click();
   assert.equal((await data()).tracking,'denied');
   assert.equal(await page.locator('.player-placeholder').count(),0);
   assert.equal(await page.locator('[data-action="videoPermission"]').count(),0);
   assert.ok(await page.locator('.youtube-link').isVisible());
   await go(product,language,width,'movement');
   await page.locator('.video-disclosure summary').click();
   await page.locator('[data-action="videoPermission"]').click();
   await page.locator('[data-action="allowTracking"]').click();
   assert.equal((await data()).tracking,'authorized');
   const player=await page.locator('.player-placeholder').boundingBox();
   assert.ok(player.width>=200&&player.height>=200);
   await page.locator('[data-action="videoPlay"]').click();
   assert.equal((await data()).overlay.kind,'alert');
   await act('closeOverlay');await act('withdrawVideo');
   assert.equal(await page.locator('.player-placeholder').count(),0);
   report.videoCases++;
  }
  assert.deepEqual(remoteMedia,[],'Mock must not contact YouTube or Google media services');
  if (!process.env.DESIGN_VIDEO_ONLY) report.flows.push('Search/menu icon centering; separate guide/add targets; direct and modal return preserves query, filters, scroll and focus; keyboard add exactly once');
  report.flows.push('Single primary Watch on YouTube link with original destination; optional in-app permission inside details; video above equipment; expandable disclosure and legal/author links; simulated allow/deny/withdraw; mock player at least 200 × 200; no remote media requests');
  assert.deepEqual(report.issues,[]);report.status='PASS';
 }catch(error){report.status='FAIL';report.issues.push(error.stack);process.exitCode=1}
 finally{fs.writeFileSync(process.env.DESIGN_REPORT || path.join(output,'guide-verification.json'),JSON.stringify(report,null,2)+'\n');await browser.close();console.log(JSON.stringify(report,null,2))}
})();
