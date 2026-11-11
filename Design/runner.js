'use strict';
const runnerParams=new URLSearchParams(location.search);
product=['OnlyBody','OnlyWeights'].includes(runnerParams.get('product'))?runnerParams.get('product'):'OnlyBody';
language=['uk','en','pl','de','fr'].includes(runnerParams.get('language'))?runnerParams.get('language'):'uk';
window.mockLive=runnerParams.get('live')==='true';
const fixture=state();
const fixtureDay=runnerParams.get('version')==='v008'?window.v008TrainingDay():'Sat';
const fixtureRestDay=days[(days.indexOf(fixtureDay)+1)%days.length];
switch(runnerParams.get('scenario')){
 case 'multiple':fixture.workouts.slice(0,3).forEach(w=>w.days=[fixtureDay]);break;
 case 'rest-day':fixture.workouts.forEach(w=>w.days=[runnerParams.get('version')==='v008'?fixtureRestDay:'Mon']);if(runnerParams.get('version')==='v008')fixture.smart.config.days=[fixtureRestDay];break;
 case 'empty':fixture.workouts=[];fixture.sessions=[];break;
 case 'long':fixture.workouts[0].nameKey=null;fixture.workouts[0].name='Тренування всього тіла з акцентом на плечі та стабілізацію корпусу';break;
 case 'save-error':fixture.failSave=true;break;
}
let requested=runnerParams.get('screen')||'train';
if(runnerParams.get('version')==='v000'&&['creation','statistics'].includes(requested))requested=requested==='creation'?'musclePicker':'log';
if(!['v002','v003','v004','v005','v006','v007','v008'].includes(runnerParams.get('version'))&&requested==='workout')requested='train';
if(runnerParams.get('version')!=='v008')requested=({smartSetup:'builder',smartOptions:'builder',smartToday:'workout'})[requested]??requested;
direct(requested);
// The adapter is also the narrow API used by reproducible prototype QA.
window.mock={configure(options){product=options.product??product;language=options.language??language;states={};direct(options.screen??'train')},state:()=>state(),navigate:route=>direct(route),act:value=>action(value),render:()=>render()};
addEventListener('message',event=>{if(event.origin===location.origin&&event.source===parent&&event.data?.type==='clock')window.mockLive=Boolean(event.data.live)});
