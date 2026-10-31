'use strict';
const screens = [['train','Головний екран'],['train-empty','Порожній стан'],['musclePicker','Вибір м’язів'],['builder','Редактор тренування'],['exercisePicker','Додати вправу'],['active','Активне тренування'],['rest','Відпочинок'],['complete','Завершення'],['exerciseHistory','Історія вправи'],['log','Журнал'],['session','Деталі заняття'],['library','Бібліотека'],['movement','Деталі вправи'],['settings','Налаштування'],['notifications','Нагадування'],['creation','Спосіб створення'],['statistics','Статистика']];
const get = id => document.getElementById(id);
let selected = 'train';
const params = new URLSearchParams(location.search);
for(const id of ['version','product','language','size','scenario','zoom']) if(params.has(id)&&[...get(id).options].some(o=>o.value===params.get(id))) get(id).value=params.get(id);
if(screens.some(([id])=>id===params.get('screen'))) selected=params.get('screen');
get('compare').checked=params.get('compare')==='true';
function redraw(){
  const compare=get('compare').checked, baseline=get('version').value==='v000';
  get('size').disabled=compare||baseline;
  if(compare||baseline)get('size').value='440';
  const width=compare||baseline?440:Number(get('size').value),height={375:812,393:852,440:956}[width];
  const versions=compare?['v000','v001']:[get('version').value];
  get('title').textContent=screens.find(([id])=>id===selected)[1];
  document.querySelector('.status').textContent=baseline&&!compare?'v000 · Зафіксована база':'v001 · Запропоновано';
  get('screens').innerHTML=screens.map(([id,label],i)=>`<button data-route="${id}" class="${id===selected?'selected':''}" ${id===selected?'aria-current="page"':''}><span>${String(i+1).padStart(2,'0')}</span>${label}</button>`).join('');
  const args=new URLSearchParams({product:get('product').value,language:get('language').value,screen:selected,scenario:get('scenario').value,live:String(get('live').checked)});
  get('stage').innerHTML=versions.map(v=>`<section class="preview"><h3>${v==='v000'?'v000 · Початковий стан':'v001 · М’який спортивний'}<span>${width} × ${height}</span></h3><div class="frame-space"><iframe title="${v} ${get('product').value}" src="runner.html?${args}&version=${v}" width="${width}" height="${height}"></iframe></div></section>`).join('');
  get('phone-link').href=`runner.html?${args}&version=${get('version').value}`;
  const url=new URLSearchParams({version:get('version').value,product:get('product').value,language:get('language').value,size:get('size').value,screen:selected,scenario:get('scenario').value,zoom:get('zoom').value,compare:String(compare)});
  history.replaceState(null,'','?'+url);
  fit();
}
function fit(){
 const frames=[...document.querySelectorAll('iframe')],width=Number(frames[0]?.width)||393,height=Number(frames[0]?.height)||852;
 const room=Math.max(300,get('stage').clientWidth-64-(frames.length-1)*28);
 const scale=get('zoom').value==='100'?1:Math.min(1,room/(width*frames.length),Math.max(480,innerHeight-get('stage').getBoundingClientRect().top-64)/height);
 for(const frame of frames){frame.style.transform=`scale(${scale})`;frame.parentElement.style.width=width*scale+'px';frame.parentElement.style.height=height*scale+'px'}
 get('scale-note').textContent=`${Math.round(scale*100)}% · ${get('compare').checked?'Порівняння на 440 pt':'1 CSS px = 1 pt до масштабування'}`;
}
get('screens').addEventListener('click',e=>{const b=e.target.closest('[data-route]');if(b){selected=b.dataset.route;redraw()}});
for(const id of ['version','product','language','size','compare','scenario']) get(id).addEventListener('change',redraw);
get('zoom').addEventListener('change',fit);
get('reset').addEventListener('click',redraw);
get('live').addEventListener('change',()=>{for(const f of document.querySelectorAll('iframe'))f.contentWindow.postMessage({type:'clock',live:get('live').checked},location.origin)});
addEventListener('resize',fit);
redraw();
