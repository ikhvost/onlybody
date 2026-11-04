/* Local design QA; requires host Playwright + Chrome, no app dependencies. */
const { chromium } = require('playwright');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const root = path.resolve(__dirname, '..');
const output = path.join(root, 'versions/v007');
const origin = process.env.DESIGN_URL || 'http://127.0.0.1:8772';
const screens = ['train','train-empty','musclePicker','builder','exercisePicker','active','rest','complete','exerciseHistory','log','session','library','movement','settings','notifications','creation','statistics','workout'];
const products = ['OnlyBody', 'OnlyWeights'];
const languages = ['uk','en','pl','de','fr'];
const sizes = [[375,812],[393,852],[440,956]];
const report = { date: process.env.DESIGN_REVIEW_DATE || new Date().toLocaleDateString('en-CA', {timeZone:'Europe/Warsaw'}), scope: 'v007 desktop Chrome; browser approximation of Liquid Glass', matrix: 0, panels: 0, flows: [], issues: [], physicalIPhone: 'UNCONFIRMED', nativeVoiceOver: 'UNCONFIRMED', nativeLiquidGlass: 'NOT_TESTED' };

function verifyFrozenVersions() {
  const hashes = JSON.parse(fs.readFileSync(path.join(output, 'baseline-checksums.json')));
  for (const [file, hash] of Object.entries(hashes)) {
    assert.equal(crypto.createHash('sha256').update(fs.readFileSync(path.join(root, file))).digest('hex'), hash, file);
  }
  report.frozenFiles = Object.keys(hashes).length;
}

async function audit(page, label) {
  const issues = await page.evaluate(() => {
    const problems = [];
    const device = document.querySelector('.device').getBoundingClientRect();
    for (const control of document.querySelectorAll('.search-box,.item-replace,.picker-add')) {
      const bounds = control.getBoundingClientRect(), icon = control.querySelector('.icon')?.getBoundingClientRect();
      if (!bounds.width || !icon) continue;
      if (Math.abs(bounds.top + bounds.bottom - icon.top - icon.bottom) > 1) problems.push(`${control.className}: icon not vertically centered`);
      if (!control.matches('.search-box') && Math.abs(bounds.left + bounds.right - icon.left - icon.right) > 1) problems.push(`${control.className}: icon not horizontally centered`);
      const iconSize = control.matches('.item-replace') ? 24 : 22;
      if (Math.abs(icon.width - iconSize) > 0.1 || Math.abs(icon.height - iconSize) > 0.1) problems.push(`${control.className}: icon size`);
    }
    for (const el of document.querySelectorAll('#app *, #overlay *')) {
      const rect = el.getBoundingClientRect(), style = getComputedStyle(el);
      if (!rect.width || !rect.height || style.visibility === 'hidden') continue;
      if (rect.left < device.left - 1 || rect.right > device.right + 1) problems.push(`${el.className}: horizontal overflow`);
      if (el.matches('button,input,a,summary') && !el.closest('[inert]') && !el.disabled && (rect.width < 43.9 || rect.height < 43.9)) problems.push(`${el.className}: small target ${rect.width} × ${rect.height}`);
    }
    for (const title of document.querySelectorAll('.nav-bar-title')) {
      const bounds = title.getBoundingClientRect();
      const header = title.closest('.nav-bar').getBoundingClientRect();
      if (Math.abs(bounds.left + bounds.width / 2 - header.left - header.width / 2) > 1) problems.push('off-center navigation title');
    }
    if (document.querySelector('.builder-content details.options')) problems.push('collapsed builder options');
    const nav = document.querySelector('.bottom-nav');
    if (nav) {
      const bounds = nav.getBoundingClientRect();
      if (bounds.bottom > device.bottom - 20 || bounds.height > 80) problems.push('floating navigation geometry');
      const scroll = document.querySelector('#app > .scroll');
      if (scroll) {
        scroll.scrollTop = scroll.scrollHeight;
        const children = [...scroll.children].filter(el => el.getBoundingClientRect().height);
        const last = children.at(-1);
        if (last && last.getBoundingClientRect().bottom > bounds.top) problems.push('last content hidden under navigation');
        scroll.scrollTop = 0;
      }
    }
    if ([...document.querySelectorAll('.device button,.device input')].some(el => getComputedStyle(el).fontFamily.includes('DM '))) problems.push('legacy font');
    return problems;
  });
  assert.deepEqual(issues, [], label);
}

async function capture(page, product, screen) {
  const dir = path.join(output, 'screenshots', product);
  fs.mkdirSync(dir, { recursive: true });
  await page.screenshot({ path: path.join(dir, `${screen}.png`) });
}

function contrast(foreground, background) {
  const luminance = rgb => rgb.map(v => v / 255).map(v => v <= .04045 ? v / 12.92 : ((v + .055) / 1.055) ** 2.4).reduce((sum, v, i) => sum + v * [.2126,.7152,.0722][i], 0);
  const values = [luminance(foreground), luminance(background)].sort((a,b) => a-b);
  return (values[1] + .05) / (values[0] + .05);
}

(async () => {
  const browser = await chromium.launch({ channel: 'chrome', headless: true });
  const page = await browser.newPage({ viewport: {width:393,height:852}, timezoneId:'Europe/Warsaw' });
  page.on('pageerror', error => report.issues.push(error.message));
  await page.route('**/*', route => {
    const url = new URL(route.request().url());
    return url.origin === origin || url.protocol === 'data:' ? route.continue() : route.abort();
  });
  const go = async (options = {}) => {
    const query = new URLSearchParams({version:'v007', ...options});
    await page.goto(`${origin}/runner.html?${query}`);
    await page.evaluate(() => window.v007Ready);
    await page.evaluate(() => document.fonts.ready);
  };
  const act = value => page.evaluate(value => mock.act(value), value);
  const configure = options => page.evaluate(options => mock.configure(options), options);
  try {
    verifyFrozenVersions();
    await go();
    for (const product of products) for (const language of languages) for (const [width,height] of sizes) {
      await page.setViewportSize({width,height});
      for (const screen of screens) {
        await configure({product,language,screen});
        await audit(page, `${product}/${language}/${width}/${screen}`);
        report.matrix++;
        if (width === 393 && language === 'uk') await capture(page,product,screen);
      }
      for (const panel of ['edit','filters','replacement','replacementFilters']) {
        await configure({product,language,screen:panel === 'edit' ? 'builder' : panel === 'filters' ? 'library' : 'workout'});
        await act(panel === 'edit' ? 'editMovement:0' : panel === 'filters' ? 'openFilters:false' : 'replaceItem:session:0');
        if (panel === 'replacementFilters') await act('replacementFilters');
        await page.waitForTimeout(260);
        await audit(page, `${product}/${language}/${width}/${panel}`);
        assert.equal(await page.locator('#app').evaluate(el => el.inert),true);
        assert.ok(await page.locator('#overlay [aria-modal="true"]').count());
        report.panels++;
        if (width === 393 && language === 'uk') await capture(page,product,panel);
      }
    }
    console.log(`Matrix: ${report.matrix} screens, ${report.panels} panels`);

    await page.setViewportSize({width:393,height:852});
    for (const product of products) {
      await go({product});
      const count = await page.evaluate(() => mock.state().workouts.length);
      await page.locator('[data-action="create"]').click();
      await page.locator('[data-action="buildManual"]').click();
      await page.locator('#builder-name').fill('Liquid Glass QA');
      await act('pickExercise');
      await page.locator('#catalog-search').fill(product === 'OnlyBody' ? 'Bird Dog' : 'Lat Pulldown');
      await page.locator('[data-action^="addExercise:"]').first().click();
      await act('editMovement:0');
      await page.locator('[data-number="sets"]').fill('2');
      await page.locator('[data-number="reps"]').fill('8');
      await act('closeOverlay');
      await page.locator('[data-action="save"]').click();
      assert.equal(await page.evaluate(() => mock.state().workouts.length),count+1);
      const id = await page.evaluate(() => mock.state().workouts.at(-1).id);
      await act('edit:'+id);
      assert.equal(await page.locator('[data-action^="mode:"]').count(),0);
      assert.equal(await page.locator('details.options').count(),0);
      assert.equal(await page.locator('[data-action^="day:"]').count(),7);
      const savedMode = await page.evaluate(() => mock.state().builder.mode);
      await act('mode:smart');
      assert.equal(await page.evaluate(() => mock.state().builder.mode),savedMode);
      await page.locator('#builder-name').fill('Edited QA');
      await act('save');
      assert.equal(await page.evaluate(() => mock.state().workouts.at(-1).name),'Edited QA');
      await act('start:'+id);
      await act('beginSession');
      await page.locator('[data-field="reps"]').first().fill('9');
      await page.locator('.set-check').first().click();
      await act('endWorkout');
      await act('saveAndEnd');
      assert.equal(await page.evaluate(() => mock.state().sessions[0].items[0].setReps[0]),9);
      await act('closeWorkout');
      await page.locator('[data-action="tab:log"]').click();
      await page.locator('[data-action^="session:"]').first().click();
      assert.match(await page.locator('#app').innerText(),/Edited QA/);
      assert.equal(await page.locator('.bottom-nav').count(),0);
      report.flows.push(`${product}: click create, edit, complete, history; nested navigation has no tab bar`);
      for (const scenario of ['multiple','rest-day','empty','long','save-error']) {
        await go({product,scenario,screen:scenario==='save-error'?'complete':'train'});
        await audit(page,`${product}/${scenario}`);
        await capture(page,product,scenario);
      }
    }

    for (const mode of ['', 'reduce-motion', 'reduce-transparency', 'no-blur']) {
      const flags = mode ? {[mode]:'true'} : {};
      for (const screen of ['train','rest','library','builder']) {
        await go({...flags,screen});
        await audit(page,`${mode || 'normal'}/${screen}`);
        if (screen === 'builder') { await act('editMovement:0'); await page.waitForTimeout(260); await audit(page,`${mode}/sheet`); }
        if (['reduce-transparency','no-blur'].includes(mode)) {
          const surface = page.locator('.bottom-nav,.rest-strip,.sheet').first();
          assert.equal(await surface.evaluate(el => getComputedStyle(el).backdropFilter),'none');
        }
        if (mode === 'reduce-motion') assert.equal(await page.locator('.device').evaluate(el => el.getAnimations({subtree:true}).length),0);
      }
      report.flows.push(`${mode || 'normal'} material/motion mode: root, timer, library, sheet`);
    }
    await page.emulateMedia({reducedMotion:'reduce'});
    await go({screen:'builder'});await act('editMovement:0');
    assert.equal(await page.locator('.sheet').evaluate(el=>getComputedStyle(el).animationName),'none');
    await page.emulateMedia({reducedMotion:'no-preference'});

    // Calculate actual token contrast. White behind glass is the brightest possible backdrop.
    await go();
    const colors = await page.evaluate(() => {
      const style=getComputedStyle(document.documentElement);
      return Object.fromEntries(['text','text2','text3','accent','danger','bg','surface','surface2','glass-fill','glass-highlight','glass-solid'].map(name=>[name,style.getPropertyValue('--'+name).trim()]));
    });
    const rgb = hex => hex.slice(1).match(/../g).map(value=>parseInt(value,16));
    const composite = (front,back) => front.slice(0,3).map((channel,i)=>channel*(front[3]/255)+back[i]*(1-front[3]/255));
    const glass = composite(rgb(colors['glass-highlight']),composite(rgb(colors['glass-fill']),[255,255,255]));
    report.contrast=[];
    for (const text of ['text','text2','text3','accent','danger']) for (const background of ['bg','surface','surface2']) {
      const ratio=contrast(rgb(colors[text]),rgb(colors[background]));
      assert.ok(ratio>=4.5,`${text}/${background}: ${ratio}`);
      report.contrast.push({text,background,ratio:+ratio.toFixed(2)});
    }
    for (const text of ['text','text2','accent']) {
      const ratio=contrast(rgb(colors[text]),glass);
      assert.ok(ratio>=4.5,`${text}/glass over white: ${ratio}`);
      report.contrast.push({text,background:'glass over white',ratio:+ratio.toFixed(2)});
    }
    const primaryContrast=contrast(rgb(colors.bg),rgb(colors.accent));
    assert.ok(primaryContrast>=4.5);
    report.contrast.push({text:'bg',background:'accent',ratio:+primaryContrast.toFixed(2)});
    await page.keyboard.press('Tab');
    assert.ok(await page.evaluate(()=>{const el=document.activeElement,s=getComputedStyle(el);return el.matches('button')&&s.outlineStyle==='solid'&&parseFloat(s.outlineWidth)>=2}));
    report.flows.push('Contrast: solid surfaces, primary button and bounded white backdrop under glass; keyboard focus visible');

    await page.setViewportSize({width:1440,height:1100});
    await page.goto(origin);
    assert.equal(await page.locator('#version').inputValue(),'v007');
    assert.equal(await page.locator('#compare-base').inputValue(),'v006');
    await page.locator('#compare').check();
    await page.waitForFunction(()=>[...document.querySelectorAll('iframe')].every(frame=>frame.contentWindow.mock));
    assert.equal(await page.locator('iframe').count(),2);
    await page.locator('#reduce-motion').check();await page.locator('#reduce-transparency').check();
    await page.waitForFunction(()=>[...document.querySelectorAll('iframe')].every(frame=>frame.contentWindow.mock));
    assert.match(page.url(),/reduce-transparency=true/);
    await page.reload();
    assert.equal(await page.locator('#reduce-motion').isChecked(),true);
    assert.equal(await page.locator('#reduce-transparency').isChecked(),true);
    const preview=page.frameLocator('iframe[title="v007 OnlyBody"]');
    assert.equal(await preview.locator('.bottom-nav').evaluate(el=>getComputedStyle(el).backdropFilter),'none');
    await page.locator('#reduce-motion').uncheck();await page.locator('#reduce-transparency').uncheck();
    await page.waitForFunction(()=>[...document.querySelectorAll('iframe')].every(frame=>frame.contentWindow.mock));
    await page.waitForTimeout(300);
    await page.screenshot({path:path.join(output,'studio.png')});
    report.flows.push('Studio defaults, v006/v007 comparison, preference URL round-trip');
    await go({version:'v006',screen:'builder'});
    await page.evaluate(() => window.v006Ready);
    assert.equal(await page.locator('details.options').count(),1);
    assert.equal(await page.locator('[data-action^="mode:"]').count(),2);
    report.flows.push('Frozen v006 still exposes its original editor and accordion');
    verifyFrozenVersions();
    assert.deepEqual(report.issues,[]);
    report.status='PASS';
  } catch (error) { report.status='FAIL';report.issues.push(error.stack); }
  finally {
    await browser.close();
    fs.writeFileSync(process.env.DESIGN_REPORT || path.join(output,'verification.json'),JSON.stringify(report,null,2)+'\n');
    console.log(JSON.stringify(report,null,2));
    if (report.status!=='PASS') process.exitCode=1;
  }
})();
