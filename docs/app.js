/* Observatorio de Desarrollo Humano: versión sin servidor para GitHub Pages.
 * Los datos provienen de las tres bases incluidas en el repositorio; no se interpolan.
 */
'use strict';
const REGIONS=['África','Asia','Europa','América del Norte','América del Sur','Oceanía'];
const COLOR={wine:'#611232',rose:'#9b2247',green:'#1e5b4f',darkgreen:'#002f2a',gold:'#a57f2c',sand:'#e6d194',gray:'#98989a',ink:'#161a1d'};
const COUNTRY_COLORS=['#611232','#1e5b4f','#a57f2c','#9b2247','#002f2a','#98989a','#786274','#bd8357'];
const state={indicator:'IDH',year:2023,region:'Todas',order:'desc',tab:'panorama',page:1,selected:['MEX','BRA','COL','IDN','ZAF']};
let raw=null,byYear={},byCountry={},countryMeta={},latestYears={},currentRanking=[],currentSelection=[];
const $=id=>document.getElementById(id);
const fmt=(v,d=3)=>Number.isFinite(v)?v.toLocaleString('en-US',{minimumFractionDigits:d,maximumFractionDigits:d}):'Sin dato';
const signed=(v,d=3)=>Number.isFinite(v)?`${v>0?'+':''}${fmt(v,d)}`:'—';
const norm=s=>(s||'').normalize('NFD').replace(/[\u0300-\u036f]/g,'').toLocaleLowerCase('es');
const sorted=(items,order='desc')=>items.slice().sort((a,b)=>order==='desc'?(b.v-a.v||a.name.localeCompare(b.name,'es')):(a.v-b.v||a.name.localeCompare(b.name,'es')));
const regionFilter=r=>state.region==='Todas'||r.region===state.region;
function readURL(){const p=new URLSearchParams(location.search);if(['IDH','IDH-D','AHDI'].includes(p.get('indice')))state.indicator=p.get('indice');if(/^\d{4}$/.test(p.get('anio')||''))state.year=Number(p.get('anio'));if(['Todas',...REGIONS].includes(p.get('region')))state.region=p.get('region');if(['asc','desc'].includes(p.get('orden')))state.order=p.get('orden');if(['panorama','mapa','clasificacion','comparador','evolucion','seleccion','fuentes'].includes(p.get('vista')))state.tab=p.get('vista');}
function pageURL(){const u=new URL(location.href);[['indice',state.indicator],['anio',state.year],['region',state.region],['orden',state.order],['vista',state.tab]].forEach(([k,v])=>u.searchParams.set(k,v));return u.href;}
function saveURL(){history.replaceState(null,'',pageURL());}
async function init(){try{
 readURL();const r=await fetch('data/indices.json',{cache:'default'});if(!r.ok)throw Error(`Error al abrir los datos (${r.status})`);raw=await r.json();if(!raw.records?.length)throw Error('No se encontraron observaciones.');
 if(typeof Plotly==='undefined')throw Error('La biblioteca de gráficos no cargó. Verifica la conexión a internet.');
 for(const c of raw.countries)countryMeta[c.c]=c;
 for(const [ind,code,year,v] of raw.records){const row={ind,c:code,y:year,v,name:countryMeta[code]?.n||code,region:countryMeta[code]?.r||''};
  (byYear[ind]??={})[year]??=[];byYear[ind][year].push(row);((byCountry[ind]??={})[code]??=[]).push(row);
 }
 for(const ind of Object.keys(raw.years)){latestYears[ind]=Math.max(...raw.years[ind]);for(const code in byCountry[ind])byCountry[ind][code].sort((a,b)=>a.y-b.y);}
 if(!raw.years[state.indicator].includes(state.year))state.year=latestYears[state.indicator];
 populateFilters();bindUI();$('loading').hidden=true;$('dashboard').hidden=false;activate(state.tab);render();
 }catch(e){$('loading').hidden=true;$('error').hidden=false;$('error').textContent=`No fue posible cargar el tablero: ${e.message}`;console.error(e);}}
function populateFilters(){
 $('indicator').value=state.indicator;$('year').innerHTML=raw.years[state.indicator].slice().reverse().map(y=>`<option value="${y}">${y}</option>`).join('');$('year').value=state.year;$('region').value=state.region;$('order').value=state.order;
 const options=Object.values(countryMeta).sort((a,b)=>a.n.localeCompare(b.n,'es'));$('countryAdd').innerHTML=options.map(c=>`<option value="${c.c}">${escapeHTML(c.n)}</option>`).join('');$('countryAdd').value='MEX';
}
function escapeHTML(s){return String(s).replace(/[&<>"']/g,m=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m]));}
function bindUI(){
 $('indicator').addEventListener('change',e=>{state.indicator=e.target.value;state.year=latestYears[state.indicator];state.page=1;populateFilters();render();});
 $('year').addEventListener('change',e=>{state.year=Number(e.target.value);state.page=1;render();});
 $('region').addEventListener('change',e=>{state.region=e.target.value;state.page=1;render();});
 $('order').addEventListener('change',e=>{state.order=e.target.value;state.page=1;render();});
 document.querySelectorAll('.nav-item').forEach(btn=>btn.addEventListener('click',()=>{activate(btn.dataset.tab);render();$('sidebar').classList.remove('open');window.scrollTo({top:0,behavior:'smooth'});}));
 $('menuBtn').addEventListener('click',()=>$('sidebar').classList.toggle('open'));
 $('shareBtn').addEventListener('click',async()=>{const str=pageURL();try{await navigator.clipboard.writeText(str);$('shareBtn').textContent='Enlace copiado';}catch{window.prompt('Copia el enlace de esta vista:',str);}setTimeout(()=>$('shareBtn').textContent='Compartir vista',2200);});
 $('mapMode').addEventListener('change',renderMap);
 $('searchCountry').addEventListener('input',()=>{state.page=1;renderRanking();});
 $('classFilter').addEventListener('change',()=>{state.page=1;renderRanking();});
 $('prevPage').addEventListener('click',()=>{state.page=Math.max(1,state.page-1);renderRanking();});
 $('nextPage').addEventListener('click',()=>{state.page++;renderRanking();});
 $('exportRanking').addEventListener('click',()=>exportRows(visibleRanking(),`clasificacion_${state.indicator}_${state.year}.csv`));
 $('exportSelection').addEventListener('click',()=>exportRows(currentSelection,`seleccion_30_${state.indicator}_${state.year}.csv`));
 $('searchSelection').addEventListener('input',renderSelectionTable);
 $('addCountry').addEventListener('click',()=>{const code=$('countryAdd').value;if(!state.selected.includes(code)&&state.selected.length<8){state.selected.push(code);render();}});
 $('clearCountries').addEventListener('click',()=>{state.selected=['MEX','BRA','COL','IDN','ZAF'];render();});
}
function activate(name){state.tab=name;document.querySelectorAll('.tab').forEach(el=>el.classList.toggle('active',el.id===`tab-${name}`));document.querySelectorAll('.nav-item').forEach(el=>el.classList.toggle('active',el.dataset.tab===name));saveURL();}
function yearRows(ind=state.indicator,year=state.year){return byYear[ind]?.[year]||[];}
function valueFor(ind,year,code){return yearRows(ind,year).find(row=>row.c===code)?.v??null;}
function mexicoValue(ind=state.indicator,year=state.year){return valueFor(ind,year,'MEX');}
function belowMexico(ind=state.indicator,year=state.year){const mx=mexicoValue(ind,year);return mx==null?[]:sorted(yearRows(ind,year).filter(r=>r.c!=='MEX'&&r.v<mx),'desc');}
function computeCurrent(){currentRanking=sorted(yearRows().filter(regionFilter),state.order);currentSelection=belowMexico().slice(0,30);}
function render(){computeCurrent();saveURL();
 ({panorama:renderOverview,mapa:renderMap,clasificacion:renderRanking,comparador:renderCompare,evolucion:renderHistory,seleccion:renderSelection,fuentes:()=>{}}[state.tab])();
}
function empty(div,message='No hay observaciones disponibles con estos filtros.'){Plotly.purge(div);div.innerHTML=`<div class="no-data">${escapeHTML(message)}</div>`;}
const baseLayout={paper_bgcolor:'rgba(0,0,0,0)',plot_bgcolor:'rgba(0,0,0,0)',font:{family:'Arial, sans-serif',color:'#323232',size:12},margin:{l:44,r:24,t:24,b:48},showlegend:false};
const plotConfig={responsive:true,displaylogo:false,modeBarButtonsToRemove:['lasso2d','select2d','toggleSpikelines']};
function plot(div,traces,layout={}){const el=$(div);return Plotly.react(el,traces,{...baseLayout,...layout,autosize:true},plotConfig);}
function renderOverview(){const all=yearRows(),filtered=all.filter(regionFilter),mx=mexicoValue();
 $('kpiMexico').textContent=fmt(mx);$('kpiMexicoNote').textContent=`${state.indicator} · ${state.year}`;$('kpiTotal').textContent=String(filtered.length);$('kpiLower').textContent=mx==null?'—':String(filtered.filter(r=>r.c!=='MEX'&&r.v<mx).length);$('kpiAverage').textContent=filtered.length?fmt(filtered.reduce((acc,r)=>acc+r.v,0)/filtered.length):'—';
 const regs=(state.region==='Todas'?REGIONS:[state.region]).map(name=>{const xs=all.filter(r=>r.region===name);return {name,val:xs.length?xs.reduce((s,r)=>s+r.v,0)/xs.length:null,count:xs.length}}).filter(x=>x.val!==null);
 if(!regs.length)empty($('chartRegion'));else plot('chartRegion',[{type:'bar',orientation:'h',x:regs.map(x=>x.val),y:regs.map(x=>x.name),marker:{color:regs.map((x,i)=>[COLOR.wine,COLOR.green,COLOR.gold,COLOR.rose,COLOR.darkgreen,COLOR.gray][REGIONS.indexOf(x.name)])},text:regs.map(x=>fmt(x.val)),textposition:'outside',hovertemplate:'%{y}: %{x:.3f}<extra></extra>'}],{margin:{l:128,r:45,t:20,b:35},xaxis:{range:[0,1],gridcolor:'#f1eeeb',tickformat:'.1f'},yaxis:{autorange:'reversed'}});
 const near=belowMexico().slice(0,10).reverse();if(!near.length)empty($('chartNear'));else plot('chartNear',[{type:'bar',orientation:'h',x:near.map(r=>r.v),y:near.map(r=>r.name),marker:{color:COLOR.green},text:near.map(r=>fmt(r.v)),textposition:'outside',hovertemplate:'%{y}: %{x:.3f}<extra></extra>'}],{margin:{l:125,r:55,t:22,b:36},xaxis:{range:[0,1],gridcolor:'#f1eeeb'},yaxis:{automargin:true}});
}
function lossRows(year=state.year){const h=yearRows('IDH',year),a=new Map(yearRows('IDH-D',year).map(r=>[r.c,r]));return h.filter(r=>a.has(r.c)&&r.v>0).map(r=>({...r,v:100*(r.v-a.get(r.c).v)/r.v,idh:r.v,ihdi:a.get(r.c).v}));}
function renderMap(){const mode=$('mapMode').value,all=yearRows().filter(regionFilter),mx=mexicoValue(),sel=new Set(currentSelection.map(x=>x.c));let data=[],note='',zmin,zmax,zmid,colorscale,geoScope='world';
 if(mode==='value'){data=all.map(r=>({...r,z:r.v}));zmin=0;zmax=1;colorscale=[[0,'#f4e7d7'],[.45,'#e6d194'],[.75,'#9b2247'],[1,'#611232']];note=`Valores del ${state.indicator} en ${state.year}. Un color más intenso indica un valor más alto.`;}
 if(mode==='gap'){data=all.map(r=>({...r,z:mx==null?NaN:r.v-mx}));const abs=Math.max(.01,...data.map(r=>Math.abs(r.z)).filter(Number.isFinite));zmin=-abs;zmax=abs;zmid=0;colorscale=[[0,'#9b2247'],[.5,'#f7f4f0'],[1,'#1e5b4f']];note='Diferencia con México: valores negativos indican índices inferiores; positivos, superiores.';}
 if(mode==='selection'){data=all.map(r=>({...r,z:r.c==='MEX'?2:(sel.has(r.c)?1:0)}));zmin=0;zmax=2;colorscale=[[0,'#eeeae5'],[.45,'#eeeae5'],[.5,'#9b2247'],[.95,'#9b2247'],[1,'#a57f2c']];note='Guinda: 30 casos seleccionados. Dorado: México. Gris: resto de países con datos.';}
 if(mode==='loss'){data=lossRows().filter(regionFilter).map(r=>({...r,z:r.v}));zmin=0;zmax=Math.max(35,...data.map(r=>r.z));colorscale=[[0,'#f5ead8'],[.5,'#a57f2c'],[1,'#611232']];note='Pérdida porcentual = 100 × (IDH − IDH-D) / IDH. Solo se muestra cuando ambas mediciones están disponibles en el mismo año.';}
 $('mapNote').textContent=note;
 if(!data.length||data.every(r=>!Number.isFinite(r.z)))return empty($('mapChart'),'No hay datos para representar esta variable en el año y región seleccionados.');
 const custom=data.map(r=>[r.name,r.region,r.v]);
 const hoverText=mode==='loss'?'%{customdata[0]}<br>%{customdata[1]}<br>Pérdida: %{z:.2f}%<extra></extra>':mode==='gap'?'%{customdata[0]}<br>%{customdata[1]}<br>Diferencia con México: %{z:+.3f}<extra></extra>':'%{customdata[0]}<br>%{customdata[1]}<br>Valor: %{customdata[2]:.3f}<extra></extra>';
 const traces=[{type:'choropleth',locationmode:'ISO-3',locations:data.map(r=>r.c),z:data.map(r=>r.z),customdata:custom,hovertemplate:hoverText,colorscale,showscale:mode!=='selection',zmin,zmax,zmid,marker:{line:{color:'#fff',width:.45}},colorbar:{thickness:11,len:.72,outlinewidth:0,tickfont:{size:10}}}];
 plot('mapChart',traces,{margin:{l:0,r:10,t:5,b:5},geo:{scope:geoScope,projection:{type:'natural earth'},showframe:false,showcoastlines:false,showland:true,landcolor:'#f0eeeb',oceancolor:'#fff',showocean:true,bgcolor:'rgba(0,0,0,0)',countrycolor:'#fff'}}).then(()=>{
 const el=$('mapChart');el.removeAllListeners?.('plotly_click');el.on('plotly_click',ev=>{
 const code=ev?.points?.[0]?.location;const r=data.find(r=>r.c===code);if(!r)return;
 const gap=mx===null?null:r.v-mx;
 $('countryDetail').innerHTML=`<strong>${escapeHTML(r.name)}</strong> · ${escapeHTML(r.region)} · ${escapeHTML(state.indicator)} ${state.year}<br>Valor: <strong>${fmt(mode==='loss'?r.idh:r.v)}</strong>${mode==='loss'?` · IDH-D: ${fmt(r.ihdi)} · Pérdida: ${fmt(r.z,2)}%`: ` · Diferencia frente a México: ${signed(gap)}`}`;
 });
 }).catch(e=>{console.error(e);empty($('mapChart'),'No fue posible desplegar el mapa. Revisa la conexión a los recursos geográficos.');});
}
function visibleRanking(){let rows=currentRanking.filter(r=>{const term=norm($('searchCountry').value);const mx=mexicoValue();if(term&&!norm(r.name).includes(term)&&!norm(r.c).includes(term))return false;const mode=$('classFilter').value;if(mode==='lower'&&!(mx!=null&&r.c!=='MEX'&&r.v<mx))return false;if(mode==='above'&&!(mx!=null&&r.c!=='MEX'&&r.v>mx))return false;return true});return rows;}
function renderRanking(){const rows=visibleRanking(),numPages=Math.max(1,Math.ceil(rows.length/25));state.page=Math.min(state.page,numPages);const page=rows.slice((state.page-1)*25,state.page*25),mx=mexicoValue();$('rankingCount').textContent=`${rows.length} países (de ${currentRanking.length} en el filtro regional)`;$('pageLabel').textContent=`Página ${state.page} de ${numPages}`;$('prevPage').disabled=state.page===1;$('nextPage').disabled=state.page===numPages;
 $('rankingBody').innerHTML=page.map((r,i)=>`<tr class="${r.c==='MEX'?'mx':''}"><td>${(state.page-1)*25+i+1}</td><td>${escapeHTML(r.name)}${r.c==='MEX'?' · referencia':''}</td><td>${escapeHTML(r.region)}</td><td>${fmt(r.v)}</td><td>${signed(mx==null?null:r.v-mx)}</td></tr>`).join('')||'<tr><td colspan="5">Sin países para estos filtros</td></tr>';
}
function renderChips(){$('selectedCountries').innerHTML=state.selected.map(c=>`<span class="chip">${escapeHTML(countryMeta[c]?.n||c)} <button type="button" aria-label="Quitar ${escapeHTML(c)}" data-code="${escapeHTML(c)}">×</button></span>`).join('');$('selectedCountries').querySelectorAll('button').forEach(el=>el.addEventListener('click',()=>{state.selected=state.selected.filter(c=>c!==el.dataset.code);render();}));}
function renderCompare(){renderChips();const s=state.selected.map(code=>({name:countryMeta[code]?.n||code,c:code,v:valueFor(state.indicator,state.year,code)}));const valid=s.filter(r=>r.v!=null);
 $('compareNote').textContent=`${state.indicator} · ${state.year}. Comparación independiente del filtro regional; se omiten los valores faltantes.`;
 if(!valid.length)empty($('compareChart'));else plot('compareChart',[{type:'bar',orientation:'h',x:valid.map(x=>x.v).reverse(),y:valid.map(x=>x.name).reverse(),text:valid.map(x=>fmt(x.v)).reverse(),textposition:'outside',marker:{color:valid.map(x=>x.c==='MEX'?COLOR.gold:COLOR.wine).reverse()},hovertemplate:'%{y}: %{x:.3f}<extra></extra>'}],{margin:{l:180,r:65,t:20,b:38},xaxis:{range:[0,1],gridcolor:'#f1eeeb'},yaxis:{automargin:true}});
 const los=lossRows().reduce((acc,r)=>(acc[r.c]=r,acc),{});
 $('inequalityBody').innerHTML=state.selected.map(c=>{const r=los[c];return `<tr><td>${escapeHTML(countryMeta[c]?.n||c)}</td><td>${r?fmt(r.idh):'—'}</td><td>${r?fmt(r.ihdi):'—'}</td><td>${r?fmt(r.v,2)+'%':'—'}</td></tr>`;}).join('');
}
function renderHistory(){const ind=state.indicator;const traces=state.selected.map((c,i)=>{const xs=byCountry[ind]?.[c]||[];return {type:'scatter',mode:'lines+markers',name:countryMeta[c]?.n||c,x:xs.map(x=>x.y),y:xs.map(x=>x.v),line:{color:COUNTRY_COLORS[i%COUNTRY_COLORS.length],width:c==='MEX'?4:2},marker:{size:5},hovertemplate:'%{fullData.name}<br>%{x}: %{y:.3f}<extra></extra>'};}).filter(x=>x.x.length>0);
 $('historyTitle').textContent=`Evolución histórica del ${ind}`;$('historyNote').textContent=ind==='AHDI'?'Datos históricos de frecuencia variable, 1870–2020. Incluye la dimensión de libertad.':'El año inicial de cada país puede ser posterior al año inicial de la base. No se interpolan datos faltantes.';
 if(!traces.length)empty($('historyChart'));else plot('historyChart',traces,{showlegend:true,legend:{orientation:'h',y:-.21,x:0,font:{size:11}},margin:{l:55,r:17,t:20,b:85},xaxis:{title:'Año',gridcolor:'#eeece9'},yaxis:{title:'Valor del índice',gridcolor:'#eeece9',range:[0,1]}});
}
function renderSelection(){const mx=mexicoValue();$('sel30').textContent=String(currentSelection.length);$('selTotal').textContent=String(belowMexico().length);$('selMexico').textContent=fmt(mx);renderSelectionTable();renderOverlap();}
function renderSelectionTable(){const term=norm($('searchSelection').value),mx=mexicoValue();const rows=currentSelection.filter(r=>!term||norm(r.name).includes(term)||norm(r.c).includes(term)).filter(regionFilter);
 $('selectionBody').innerHTML=rows.map(r=>`<tr><td>${currentSelection.indexOf(r)+1}</td><td>${escapeHTML(r.name)}</td><td>${escapeHTML(r.region)}</td><td>${fmt(r.v)}</td><td>${signed(mx==null?null:r.v-mx)}</td></tr>`).join('')||'<tr><td colspan="5">Sin casos para estos filtros</td></tr>';
}
function renderOverlap(){const first=belowMexico('IDH',2023).slice(0,30),second=belowMexico('IDH-D',2023).slice(0,30);const A=new Set(first.map(x=>x.c)),B=new Set(second.map(x=>x.c));const common=[...A].filter(c=>B.has(c));const onlyIDH=[...A].filter(c=>!B.has(c)),onlyIHDI=[...B].filter(c=>!A.has(c));
 $('selectionOverlap').innerHTML=`<strong>${common.length} de 30 países</strong> aparecen en ambas selecciones (${fmt(common.length/30*100,1)}%). Cambian ${onlyIDH.length} casos. El IDH-D tiene una cobertura de países distinta y puede modificar el umbral relativo de México.`;
 const names=arr=>arr.map(c=>countryMeta[c]?.n||c).sort((a,b)=>a.localeCompare(b,'es')).join('<br>');
 $('selectionOverlap').innerHTML+=`<details><summary>Ver países que cambian</summary><p><strong>Solo en IDH:</strong><br>${names(onlyIDH)}</p><p><strong>Solo en IDH-D:</strong><br>${names(onlyIHDI)}</p></details>`;
 plot('overlapChart',[{type:'bar',x:['En ambos','Solo IDH','Solo IDH-D'],y:[common.length,onlyIDH.length,onlyIHDI.length],marker:{color:[COLOR.green,COLOR.wine,COLOR.gold]},text:[common.length,onlyIDH.length,onlyIHDI.length],textposition:'outside'}],{yaxis:{range:[0,30],gridcolor:'#f1eeeb'},margin:{l:40,r:20,t:20,b:48}});
}
function exportRows(rows,file){const mx=mexicoValue(),esc=v=>`"${String(v==null?'':v).replaceAll('"','""')}"`,header=['País','Código ISO3','Continente','Indicador','Año','Valor','Diferencia respecto de México'];const lines=[header.map(esc).join(',')];for(const r of rows)lines.push([r.name,r.c,r.region,state.indicator,state.year,r.v,mx==null?'':(r.v-mx)].map(esc).join(','));const blob=new Blob(['\uFEFF',lines.join('\r\n')],{type:'text/csv;charset=utf-8;'});const url=URL.createObjectURL(blob),a=document.createElement('a');a.href=url;a.download=file;document.body.appendChild(a);a.click();a.remove();setTimeout(()=>URL.revokeObjectURL(url),1000);}
window.addEventListener('DOMContentLoaded',init);
