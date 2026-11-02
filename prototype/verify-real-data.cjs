'use strict';
// SPEC: Verification of real source snapshot versus the prototype's computation model.
// Reads only; never changes source workbooks, actions or prototype state on disk.
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const assert = require('node:assert/strict');
const {validateSnapshot} = require('./build-prototype.cjs');
const dir=__dirname;
const snapshot=validateSnapshot(JSON.parse(fs.readFileSync(path.join(dir,'data-snapshot.json'),'utf8').replace(/^\uFEFF/,'')));
const html=fs.readFileSync(path.join(dir,'index.html'),'utf8');
const script=html.match(/<script>([\s\S]*?)<\/script>/)[1];
const context={window:{}};
vm.runInNewContext(script,context);
const model=context.window.demoApi;
assert.ok(model,'Real snapshot must be embedded before verification');
assert.equal(JSON.stringify(model.getSnapshot()),JSON.stringify(snapshot),'Embedded snapshot matches extracted JSON');
let checks=0;
function test(name,fn){fn();checks++;console.log('PASS '+name);}
function near(actual,expected){assert.ok(Math.abs(actual-expected)<1e-8,actual+' != '+expected);}
const avg=values=>values.length?values.reduce((a,b)=>a+b,0)/values.length:null;
function independent(project,cap,month){return avg(project.rows.filter(r=>r.capId===cap).map(r=>typeof r.values[month]==='number'&&r.values[month]>=0&&r.values[month]<=r.max?r.values[month]/r.max*100:null).filter(v=>v!==null));}
test('8 accounts, 9 new source projects and 2 FedPat absences',()=>{
 assert.equal(new Set(snapshot.projects.map(p=>p.account)).size,8);
 assert.equal(snapshot.projects.filter(p=>p.hasNew).length,9);
 assert.equal(snapshot.projects.length,11);
 for(const p of snapshot.projects.filter(p=>p.hasNew)) assert.equal(p.rows.length,23);
 for(const id of ['fedpat-pnc','fedpat-pc']) assert.equal(snapshot.projects.find(p=>p.id===id).hasNew,false);
});
test('12 actual actions; IDs unique; only suggested initial links',()=>{
 assert.equal(snapshot.actions.length,12);
 assert.equal(new Set(snapshot.actions.map(a=>a.id)).size,12);
 assert.ok(snapshot.actions.every(a=>a.links.every(l=>l.confidence==='suggested')));
 assert.ok(snapshot.actions.every(a=>a.url===null));
});
test('Unknown action origins remain unassigned, without guessing FluxIT',()=>{
 for(const id of ['40077','40075','39224']) {
  const a=snapshot.actions.find(a=>a.id===id);assert.equal(a.projectId,null);assert.equal(a.links.length,0);
 }
});
test('Dates preserved; unknown years not inferred from filenames; Jorge excluded',()=>{
 const rig=snapshot.projects.find(p=>p.id==='rig-website');
 assert.ok(rig.periodSources.every(s=>s.yearConfirmed));
 assert.ok(rig.periodSources.some(s=>s.month==='09'&&s.date==='2026-09-01'));
 assert.ok(snapshot.projects.find(p=>p.id==='tecplata-l3').periodSources.some(s=>s.month==='10'&&s.date==='2026-10-02'));
 const mars=snapshot.projects.find(p=>p.id==='fedpat-mars');
 assert.ok(mars.periodSources.every(s=>!s.yearConfirmed));
 assert.ok(mars.periodSources.every(s=>s.header!=='Jorge'));
});
test('All 165 project-capacity-month averages match independent calculation',()=>{
 for(const month of snapshot.months) for(const project of snapshot.projects) for(const cap of snapshot.capacities){
  const expected=independent(project,cap.id,month.id);
  const actual=model.summarize(project.id,month.id).capacities.find(c=>c.id===cap.id).avg;
  if(expected===null)assert.equal(actual,null);else near(actual,expected);
 }
});
test('Macro gives equal weight to valid projects, not indicator count',()=>{
 for(const month of snapshot.months) for(const cap of snapshot.capacities){
  const values=snapshot.projects.map(p=>independent(p,cap.id,month.id)).filter(v=>v!==null);
  const expected=avg(values),actual=model.summaries(month.id,'all').capacities.find(c=>c.id===cap.id);
  assert.equal(actual.total,11);assert.equal(actual.valid,values.length);
  if(expected===null)assert.equal(actual.avg,null);else near(actual.avg,expected);
 }
});
test('FedPat September pilot maintained exactly',()=>{
 const crm=model.summarize('fedpat-crm','09'),mars=model.summarize('fedpat-mars','09');
 near(crm.global,33.39506172839506);near(mars.global,68.85802469135803);
 near(crm.capacities[0].avg,18.51851851851852);near(mars.capacities[1].avg,86.66666666666666);
 assert.equal(crm.coverage.total,21);assert.equal(mars.coverage.total,13);
});
test('September has 193 valid numbers, 14 N/A; empty October/November never carried',()=>{
 const september=snapshot.projects.filter(p=>p.hasNew).flatMap(p=>p.rows.map(r=>r.values['09']));
 assert.equal(september.filter(v=>typeof v==='number').length,193);
 assert.equal(september.filter(v=>v==='N/A').length,14);
 for(const id of ['fertisa','tenpo-migracion'])assert.equal(model.summarize(id,'10').avg,null);
 assert.ok(model.summaries('11','all').capacities.every(c=>c.avg===null&&c.valid===0));
});
test('Real MARS candidate confirmation covers one alert, status simulation does not change score',()=>{
 model.setState({month:'09'});
 assert.equal(model.summarize('fedpat-mars').coverage.covered,0);
 const action=model.getActions().find(a=>a.id==='39883'),index=action.links.findIndex(l=>l.projectId==='fedpat-mars'&&l.indicatorId===18);
 assert.ok(index>=0);const before=model.score('fedpat-mars',18);
 model.confirmLink('39883',index);assert.equal(model.summarize('fedpat-mars').coverage.covered,1);
 model.setStatus('39883','Done');assert.equal(model.summarize('fedpat-mars').coverage.covered,0);
 assert.equal(model.score('fedpat-mars',18),before);model.reset();
});
test('Cancelled dependencies action stays visible but never covers an alert',()=>{
 const action=model.getActions().find(a=>a.id==='39270');assert.equal(action.status,'Cancelled');
 assert.ok(action.links.some(l=>l.projectId==='medife-portal'&&l.indicatorId===12));
 const index=action.links.findIndex(l=>l.indicatorId===12);model.confirmLink('39270',index);
 assert.equal(model.candidates('medife-portal',12).find(c=>c.action.id==='39270').active,false);
 assert.equal(model.summarize('medife-portal').coverage.covered,0);model.reset();
});
test('Indicator display filters do not change aggregate computations',()=>{
 const before=JSON.stringify(model.summaries());
 model.setState({indicatorFilter:'red'});assert.equal(JSON.stringify(model.summaries()),before);
 model.setState({indicatorFilter:'all'});
});
console.log('\n'+checks+' real-data checks PASS.');
console.log('September departmental capacities (mean of project means):');
for(const c of model.summaries('09','all').capacities) console.log(c.id+' | '+c.avg.toFixed(4)+'% | '+c.valid+'/'+c.total+' projects | alerts='+c.coverage.total);
