'use strict';
// SAMPLE: Synthetic computation-only fixtures. Never writes data-snapshot.json or index.html.
// SPEC: Verification has zero dependencies and does not inspect live extraction progress/data.
const fs=require('node:fs');
const path=require('node:path');
const vm=require('node:vm');
const assert=require('node:assert/strict');
const {validateSnapshot,injectSnapshot}=require('./build-prototype.cjs');
const html=fs.readFileSync(path.join(__dirname,'index.html'),'utf8');
let checks=0;
function test(name,run) {run();checks++;console.log('PASS '+name);}
function fixture() {
 const capacities=[1,2,3].map(id=>({id,name:'TEST capacidad '+id}));
 const criteria=Array.from({length:8},(_,n)=>({id:'test-'+n,capId:n<3?1:n<6?2:3,name:'TEST criterio '+n}));
 const indicators=Array.from({length:23},(_,n)=>{const c=criteria[n<10?(n<6?0:n<9?1:2):n<18?(n<14?3:n<17?4:5):(n<22?6:7)];return {id:n+1,criterionId:c.id,capId:c.capId,name:'TEST indicador '+(n+1),max:3,rubric:'TEST </script><img onerror="bad()"> $&',hint:'TEST'};});
 const projects=['a','b','c','absent'].map((id,n)=>({id,account:n===0?'TEST Cuenta A':'TEST Cuenta B',name:'TEST proyecto '+id,file:'TEST.xlsx',sheet:'TEST nuevo',hasNew:n!==3,periodSources:n===3?[]:[{month:'09',column:'L',header:'Septiembre',date:null,yearConfirmed:false}],rows:n===3?[]:indicators.map(i=>({...i,sourceRow:i.id+1,values:{'09':n===0?0:n===1?3:1.5},notes:[]}))}));
 const actions=[{id:'test-action',sourceProject:'TEST raw origin',status:'To Do',priority:'Normal',subject:'TEST acción',owner:'TEST owner',start:null,updated:null,file:'TEST-actions.xlsx',sheet:'Hoja 1',sourceRow:2,url:null,projectId:'a',projectMatch:'suggested',links:[{projectId:'a',indicatorId:1,confidence:'suggested',reason:'TEST semántico'},{projectId:'a',indicatorId:2,confidence:'suggested',reason:'TEST semántico'}]},{id:'test-orphan',sourceProject:'TEST unknown',status:'Doing',priority:'Normal',subject:'TEST sin asociación',owner:null,start:null,updated:null,file:'TEST-actions.xlsx',sheet:'Hoja 1',sourceRow:3,url:null,projectId:null,projectMatch:null,links:[]}];
 return {generatedAt:'2026-11-02',months:['07','08','09','10','11'].map(id=>({id,label:'TEST mes '+id})),capacities,criteria,indicators,projects,actions,warnings:[{kind:'mapping',projectId:null,message:'TEST advertencia'}]};
}
const script=html.match(/<script>([\s\S]*?)<\/script>/)?.[1];
assert.ok(script,'Script autocontenido encontrado');
const context={window:{}};
vm.createContext(context);vm.runInContext(script,context);
const model=data=>context.createDemoModel(data);
const almost=(actual,expected)=>assert.ok(Math.abs(actual-expected)<1e-9,actual+' != '+expected);

test('Sintaxis JavaScript y schema válido',()=>{assert.doesNotThrow(()=>validateSnapshot(fixture()));});
test('Sin dependencias/red/persistencia',()=>{assert.doesNotMatch(html,/<script\s+src|<link\s+[^>]*stylesheet|\bfetch\s*\(|\blocalStorage\b|\bsessionStorage\b|\bimport\s|\brequire\s*\(/i);});
test('CSS tokens; sin hex/px fuera de root',()=>{const css=html.match(/<style>([\s\S]*?)<\/style>/)[1].replace(/:root\s*\{[^}]*\}/,'');assert.doesNotMatch(css,/#[0-9a-f]{3,8}\b|\b\d+(?:\.\d+)?px\b/i);assert.match(css,/:focus-visible/);assert.match(css,/@media/);});
test('Cinco pantallas; exactamente un h1 por pantalla',()=>{const sections=[...html.matchAll(/<section class="screen" id="([^"]+)"[^>]*>([\s\S]*?)<\/section>/g)];assert.deepEqual(sections.map(s=>s[1]),['panorama','capacidad','proyecto','acciones','metodo']);for(const s of sections)assert.equal((s[2].match(/<h1\b/g)||[]).length,1);});
test('Rutas estáticas válidas y campos estáticos etiquetados',()=>{const ids=new Set([...html.matchAll(/\bid="([^"]+)"/g)].map(m=>m[1]));for(const m of html.matchAll(/href="#([^"]+)"/g))assert.ok(ids.has(m[1]),m[1]);for(const m of html.matchAll(/<(?:input|select) id="([^"]+)"/g))assert.ok(html.includes('for="'+m[1]+'"'),m[1]);});
test('Comentarios SPEC ASSUMPTION SAMPLE y null-data error',()=>{for(const tag of ['SPEC:','ASSUMPTION:','SAMPLE:'])assert.ok(html.includes(tag));assert.match(html,/Datos todavía no incrustados/);assert.match(html,/aria-live="polite"/);});
test('HTML de plantilla bajo 150KB (antes de inyección)',()=>{const template=html.replace(/(\/\* DATA_BEGIN \*\/)[\s\S]*?(\/\* DATA_END \*\/)/,'$1 null $2');assert.ok(Buffer.byteLength(template)<150*1024);});
test('Inyección idempotente; escape seguro y recuperación JSON exacta',()=>{const data=fixture(),first=injectSnapshot(html,data),second=injectSnapshot(first,data);assert.equal(first,second);const embedded=first.match(/\/\* DATA_BEGIN \*\/([\s\S]*?)\/\* DATA_END \*\//)[1];assert.ok(!embedded.includes('<'));assert.deepEqual(JSON.parse(embedded),data);const ctx={window:{}};vm.createContext(ctx);vm.runInContext(first.match(/<script>([\s\S]*?)<\/script>/)[1],ctx);assert.equal(ctx.window.demoApi.getSnapshot().projects.length,4);});
test('Schema/markers rechazados antes de escritura',()=>{const data=fixture();data.indicators[0].criterionId='missing';assert.throws(()=>validateSnapshot(data));assert.throws(()=>injectSnapshot('sin markers',fixture()));assert.throws(()=>injectSnapshot(html+html,fixture()));});
test('Cero válido, vacío N/A inválidos, finitos y escala',()=>{for(const [raw,expected] of [[0,0],[3,100],[null,null],[undefined,null],['N/A',null],['1',null],[-1,null],[4,null],[NaN,null],[Infinity,null]]){const data=fixture();data.projects[0].rows[0].values['09']=raw;assert.equal(model(data).score('a',1),expected);}});
test('Capacidad promedio directo indicadores, no criterios',()=>{const data=fixture();data.projects[0].rows.filter(r=>r.criterionId==='test-0').forEach(r=>r.values['09']=3);const s=model(data).summarize('a');almost(s.capacities[0].avg,60);almost(s.criteria[0].avg,100);almost(s.global,20);});
test('Global requiere tres capacidades con válidos',()=>{const data=fixture();data.projects[0].rows.filter(r=>r.capId===3).forEach(r=>r.values={});assert.equal(model(data).summarize('a').global,null);});
test('Macro peso igual por proyecto, sin peso por cuenta; cobertura ausentes',()=>{const m=model(fixture()),c=m.summaries().capacities[0];almost(c.avg,50);assert.equal(c.valid,3);assert.equal(c.total,4);assert.equal(m.summarize('absent').global,null);});
test('Criterio departamental promedio de criterios proyecto válidos',()=>{const m=model(fixture());almost(m.summaries().criteria[0].avg,50);assert.equal(m.summaries().criteria[0].valid,3);});
test('Scope cuenta cambia macro; búsqueda y estado solo tabla',()=>{const m=model(fixture());m.setState({account:'TEST Cuenta B'});almost(m.summaries().capacities[0].avg,75);assert.equal(m.summaries().capacities[0].total,3);m.setState({search:'no match',tableState:'red'});assert.equal(m.tableProjects().length,0);almost(m.summaries().capacities[0].avg,75);});
test('Mes nominal sin arrastre y default septiembre',()=>{const m=model(fixture());assert.equal(m.getState().month,'09');m.setState({month:'08'});assert.equal(m.summaries().capacities[0].avg,null);assert.equal(m.summarize('b').global,null);});
test('Sugeridos visibles pero nunca cubren alertas',()=>{const m=model(fixture());assert.equal(m.candidates('a',1).length,1);assert.equal(m.summarize('a').coverage.covered,0);});
test('Confirmar actualiza cobertura global/capacidad en memoria',()=>{const m=model(fixture());assert.equal(m.confirmLink('test-action',0),true);assert.equal(m.summarize('a').coverage.covered,1);assert.equal(m.summaries().capacities[0].coverage.covered,1);assert.equal(m.getSnapshot().actions[0].links[0].confidence,'suggested');});
test('Múltiples links por item sin duplicar conteo único',()=>{const m=model(fixture());m.confirmLink('test-action',0);m.confirmLink('test-action',1);m.addLink('test-action','c',11);const c=m.summaries().capacities[0].coverage;assert.equal(c.covered,2);assert.equal(c.actionCount,1);assert.equal(m.getActions().length,2);});
test('Done/Cancelled excluidos; New/To Do/Doing activos',()=>{const m=model(fixture());m.confirmLink('test-action',0);for(const status of ['Done','Cancelled','New','To Do','Doing']){m.setStatus('test-action',status);assert.equal(m.summarize('a').coverage.covered,['Done','Cancelled'].includes(status)?0:1);assert.equal(m.candidates('a',1).length,1);}});
test('Vinculación manual explícita, deduplicada; orphan sigue en lista',()=>{const m=model(fixture());m.setState({linkContext:{projectId:'a',indicatorId:3},actionId:null});assert.equal(m.getActions()[1].links.length,0);assert.equal(m.addLink('test-orphan','a',3),true);assert.equal(m.getActions()[1].links[0].confidence,'confirmed');m.addLink('test-orphan','a',3);assert.equal(m.getActions()[1].links.length,1);assert.equal(m.getSnapshot().actions[1].projectId,null);assert.equal(m.getActions().length,2);});
test('Desvincular/reset; scores permanecen inmutables',()=>{const m=model(fixture()),before=JSON.stringify(m.getSnapshot());m.confirmLink('test-action',0);m.setStatus('test-action','Done');m.unlink('test-action',0);m.reset();assert.equal(m.getActions()[0].links.length,2);assert.equal(m.getActions()[0].status,'To Do');assert.equal(m.getActions()[0].links[0].confidence,'suggested');assert.equal(JSON.stringify(m.getSnapshot()),before);});
test('API defensiva e IDs inválidos rechazados',()=>{const m=model(fixture()),d=m.getSnapshot();d.projects[0].rows[0].values['09']=3;m.getActions()[0].status='Done';m.getState().month='08';assert.equal(m.score('a',1),0);assert.equal(m.getActions()[0].status,'To Do');assert.equal(m.getState().month,'09');assert.equal(m.addLink('test-orphan','bad',1),false);assert.equal(m.addLink('test-orphan','a',99),false);assert.equal(m.setStatus('test-action','bad'),false);});
console.log('\n'+checks+' verificaciones PASS. No prueba renderizado ni datos reales; validación browser a cargo del padre.');
