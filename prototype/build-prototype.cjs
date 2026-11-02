'use strict';
// SPEC: Reproducible, offline preparation step. The shipped HTML then opens without Node.
// Reads only index.html and data-snapshot.json; never writes the snapshot or source workbooks.
const fs = require('node:fs');
const path = require('node:path');
const assert = require('node:assert/strict');

function validateSnapshot(data) {
 const check = (condition, message) => assert.ok(condition, 'Snapshot inválido: '+message);
 const object = value => value !== null && typeof value === 'object' && !Array.isArray(value);
 const text = value => typeof value === 'string';
 const id = value => text(value) && value.length > 0;
 const integer = value => Number.isInteger(value) && value > 0;
 const nullableText = value => value === null || text(value);
 check(object(data), 'se esperaba un objeto raíz');
 check(text(data.generatedAt) && /^\d{4}-\d{2}-\d{2}$/.test(data.generatedAt), 'generatedAt debe ser fecha ISO');
 for (const key of ['months','capacities','criteria','indicators','projects','actions','warnings']) check(Array.isArray(data[key]), key+' debe ser array');
 function unique(items, key, name) { const ids=items.map(item=>item[key]);check(new Set(ids).size===ids.length, name+' tiene IDs duplicados'); }
 for(const key of ['months','capacities','criteria','indicators','projects','actions']) {check(data[key].every(object),key+' debe contener objetos');unique(data[key],'id',key);}
 check(data.months.length > 0 && data.months.some(m=>m.id==='09'), 'months debe incluir septiembre nominal 09');
 for(const m of data.months) check(id(m.id)&&/^(07|08|09|10|11)$/.test(m.id)&&id(m.label),'mes nominal/label inválido');
 check(data.capacities.length===3, 'se requieren tres capacidades');
 for(const c of data.capacities) check(integer(c.id)&&id(c.name),'capacidad inválida');
 const capIds = new Set(data.capacities.map(c=>c.id));
 check(data.criteria.length===8, 'se requieren ocho criterios');
 for(const c of data.criteria) check(id(c.id)&&capIds.has(c.capId)&&id(c.name),'criterio inválido');
 const criteria = new Map(data.criteria.map(c=>[c.id,c]));
 check(data.indicators.length===23,'se requieren 23 indicadores');
 for(const i of data.indicators) check(integer(i.id)&&criteria.has(i.criterionId)&&criteria.get(i.criterionId).capId===i.capId&&id(i.name)&&Number.isFinite(i.max)&&i.max>0&&text(i.rubric)&&text(i.hint),'indicador inválido');
 const indicators = new Map(data.indicators.map(i=>[i.id,i]));
 const months = new Set(data.months.map(m=>m.id));
 check(data.projects.length>0, 'projects no debe estar vacío');
 for(const p of data.projects) {
  check(id(p.id)&&id(p.account)&&id(p.name)&&nullableText(p.file)&&nullableText(p.sheet)&&typeof p.hasNew==='boolean'&&Array.isArray(p.periodSources)&&Array.isArray(p.rows),'proyecto inválido: '+p.id);
  check(p.rows.every(object),'rows debe contener objetos');unique(p.rows,'id','rows de '+p.id);
  check(p.periodSources.every(object),'periodSources debe contener objetos');unique(p.periodSources,'month','periodSources de '+p.id);
  for(const s of p.periodSources) check(months.has(s.month)&&id(s.column)&&text(s.header)&&nullableText(s.date)&&typeof s.yearConfirmed==='boolean','periodSource inválido: '+p.id);
  for(const r of p.rows) {
   const i=indicators.get(r.id);
   check(i&&i.capId===r.capId&&i.criterionId===r.criterionId&&id(r.name)&&r.max===i.max&&integer(r.sourceRow)&&object(r.values)&&Array.isArray(r.notes),'fila de indicador inválida: '+p.id+' / '+r.id);
   // SPEC: Invalid numeric scores/string N/A are legitimate raw extraction evidence. Keep them;
   // computation rejects them rather than coerces to zero. JSON itself cannot contain NaN/Infinity.
   for(const [month,value] of Object.entries(r.values)) check(months.has(month)&&(value===null||text(value)||typeof value==='number'),'valor bruto/mes inválido: '+p.id+' / '+r.id);
   for(const n of r.notes) check(object(n)&&text(n.column)&&text(n.text),'nota inválida: '+p.id);
  }
 }
 const projectIds=new Set(data.projects.map(p=>p.id));
 for(const a of data.actions) {
  check(id(a.id)&&text(a.sourceProject)&&id(a.status)&&text(a.priority)&&text(a.subject)&&nullableText(a.owner)&&nullableText(a.start)&&nullableText(a.updated)&&id(a.file)&&id(a.sheet)&&integer(a.sourceRow)&&nullableText(a.url)&&Array.isArray(a.links),'acción inválida: '+a.id);
  check(a.projectId===null||projectIds.has(a.projectId),'acción con proyecto inexistente: '+a.id);
  check(text(a.projectMatch)||a.projectMatch===null,'projectMatch inválido: '+a.id);
  const links=new Set();
  for(const l of a.links) {
   check(object(l)&&projectIds.has(l.projectId)&&indicators.has(l.indicatorId)&&['suggested','confirmed'].includes(l.confidence)&&text(l.reason),'vínculo inválido: '+a.id);
   const key=l.projectId+'::'+l.indicatorId;check(!links.has(key),'vínculo duplicado: '+a.id);links.add(key);
  }
 }
 for(const w of data.warnings) check(object(w)&&['period','mapping','source'].includes(w.kind)&&(w.projectId===null||projectIds.has(w.projectId))&&text(w.message),'advertencia inválida');
 return data;
}

function injectSnapshot(html, data) {
 validateSnapshot(data);
 const pattern = /(const snapshot = \/\* DATA_BEGIN \*\/)[\s\S]*?(\/\* DATA_END \*\/;)/g;
 const matches = [...html.matchAll(pattern)];
 assert.equal(matches.length, 1, 'Debe existir exactamente un segmento const snapshot DATA_BEGIN / DATA_END');
 // SPEC: Escaping '<' prevents source cells from terminating the script tag. Dollar sequences
 // cannot be interpreted as replacement directives because replacement uses a callback.
 const json=JSON.stringify(data).replace(/</g,'\\u003c').replace(/\u2028/g,'\\u2028').replace(/\u2029/g,'\\u2029');
 return html.replace(pattern, (_match,start,end)=>start+' '+json+' '+end);
}

function build(directory=__dirname) {
 const index=path.join(directory,'index.html'), snapshot=path.join(directory,'data-snapshot.json');
 if(!fs.existsSync(snapshot)) throw new Error('Pendiente de inyección: falta '+snapshot+'. Ejecutá este script después de finalizar la extracción.');
 const data=JSON.parse(fs.readFileSync(snapshot,'utf8').replace(/^\uFEFF/,''));
 const html=fs.readFileSync(index,'utf8');
 const output=injectSnapshot(html,data);
 // SPEC: Write only after all validations and marker checks pass. Re-runs are byte-identical.
 fs.writeFileSync(index,output,'utf8');
 console.log('Snapshot incrustado: '+data.projects.length+' proyectos, '+data.actions.length+' acciones. HTML: '+Buffer.byteLength(output)+' bytes.');
 if(Buffer.byteLength(output)>250*1024) console.warn('Advertencia: HTML supera 250 KB; revisar tamaño antes de distribuir.');
 return output;
}
module.exports={validateSnapshot,injectSnapshot,build};
if(require.main===module) {
 try {if(process.argv.length>2)throw new Error('Uso: node prototype/build-prototype.cjs (sin argumentos)');build();}
 catch(error) {console.error(error.message);process.exitCode=1;}
}
