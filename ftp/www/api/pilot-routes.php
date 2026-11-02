<?php
declare(strict_types=1);
if($action==='pilot.permissions'&&$method==='GET'){$scopes=pilotScopes($u);out(['allowed'=>$scopes,'labels'=>PILOT_SCOPES,'permission_key'=>hash('sha256',implode('|',$scopes))]);}
if($action==='pilot.access'&&$method==='GET'){owner($u);out(['items'=>run('SELECT user_id,scope FROM wm_pilot_access WHERE org_id=? ORDER BY user_id,scope',[$u['org_id']])->fetchAll()]);}
if($action==='pilot.access'&&$method==='PUT'){
 owner($u);$b=body();$uid=num($b['user_id']??0,1);$scope=text($b['scope']??'',20);$enabled=num($b['enabled']??0,0,1);if(!in_array($scope,['finance','hr','executive'],true))out(['error'=>'Droit invalide'],422);
 if(!run('SELECT user_id FROM wm_company_memberships WHERE org_id=? AND user_id=? AND active=1',[$u['org_id'],$uid])->fetch())out(['error'=>'Membre absent de cette société'],404);
 db()->beginTransaction();if($enabled)run('INSERT IGNORE INTO wm_pilot_access(org_id,user_id,scope,granted_by) VALUES(?,?,?,?)',[$u['org_id'],$uid,$scope,$u['id']]);else run('DELETE FROM wm_pilot_access WHERE org_id=? AND user_id=? AND scope=?',[$u['org_id'],$uid,$scope]);audit($u,'pilot.access.updated',$uid);db()->commit();out(['ok'=>true]);
}
if($action==='pilot.dashboard'&&$method==='GET'){out(pilotSnapshot($u,text($_GET['scope']??'commercial',20)));}
if($action==='pilot.gpt'&&$method==='POST'){
 $b=body();$q=text($b['question']??'',1000,true);$history=$b['history']??[];if(!is_array($history)||!array_is_list($history)||count($history)>4)out(['error'=>'Historique de question invalide'],422);foreach($history as &$h)$h=text($h,1000,true);unset($h);$r=pilotAnswer($u,$q,$history);audit($u,'pilot.gpt.answered');out($r);
}
if($action==='pilot.insight'&&in_array($method,['GET','POST'],true)){
 $s=pilotSnapshot($u,'all');$selection=$method==='POST'?pilotAiSelection($u,$s,'Quels risques, anomalies et opportunités doivent être prioritaires ?',[]):['keys'=>[],'source'=>'Règles et indicateurs calculés','notice'=>'Analyse des seules sources disponibles ; les listes d’alertes sont bornées.'];
 if($selection['keys']){$rank=array_flip($selection['keys']);usort($s['alerts'],fn($a,$b)=>($rank[$a['key']]??999)<=>($rank[$b['key']]??999));}
 $allowed=pilotScopes($u);$marks=implode(',',array_fill(0,count($allowed),'?'));$actions=run('SELECT a.*,usr.email AS owner_email FROM wm_pilot_actions a LEFT JOIN wm_users usr ON usr.id=a.owner_id WHERE a.org_id=? AND a.scope IN ('.$marks.') ORDER BY a.status,a.due_date,a.id DESC LIMIT 200',array_merge([$u['org_id']],$allowed))->fetchAll();
 $coverage=[];foreach($s['sections'] as $scope=>$section)$coverage[]=['scope'=>$scope,'coverage'=>$section['coverage']??null,'notes'=>$section['notes']??[]];
 out(['as_of'=>$s['as_of'],'permission_key'=>$s['permission_key'],'allowed'=>$s['allowed'],'alerts'=>$s['alerts'],'actions'=>$actions,'coverage'=>$coverage,'source'=>$selection['source'],'notice'=>$selection['notice'],'limitations'=>$s['limitations']]);
}
if($action==='pilot.action'&&$method==='POST'){
 $b=body();$key=text($b['alert_key']??'',64,true);$s=pilotSnapshot($u,'all');$found=null;foreach($s['alerts'] as $a)if(hash_equals($a['key'],$key)){$found=$a;break;}if(!$found)out(['error'=>'Alerte absente, résolue ou hors de votre périmètre. Actualisez.'],409);
 db()->beginTransaction();run('INSERT IGNORE INTO wm_pilot_actions(org_id,alert_key,scope,entity_type,entity_id,title,next_action,created_by) VALUES(?,?,?,?,?,?,?,?)',[$u['org_id'],$key,$found['scope'],$found['entity_type'],$found['entity_id'],mb_strcut($found['title'],0,250,'UTF-8'),mb_strcut($found['recommendation'],0,1000,'UTF-8'),$u['id']]);audit($u,'pilot.action.created');db()->commit();out(['ok'=>true],201);
}
if($action==='pilot.action'&&$method==='PUT'){
 $b=body();$id=num($b['id']??0,1);$old=run('SELECT scope FROM wm_pilot_actions WHERE org_id=? AND id=?',[$u['org_id'],$id])->fetch();if(!$old)out(['error'=>'Action introuvable'],404);pilotRequire($u,$old['scope']);$status=text($b['status']??'',20);if(!in_array($status,['open','done','dismissed'],true))out(['error'=>'Statut invalide'],422);$owner=empty($b['owner_id'])?null:num($b['owner_id'],1);if($owner&&!run('SELECT user_id FROM wm_company_memberships WHERE org_id=? AND user_id=? AND active=1',[$u['org_id'],$owner])->fetch())out(['error'=>'Responsable absent de cette société'],422);
 $note=text($b['next_action']??'',1000,true);$date=dateValue($b['due_date']??'');db()->beginTransaction();if(!run('UPDATE wm_pilot_actions SET next_action=?,owner_id=?,due_date=?,status=?,version=version+1 WHERE org_id=? AND id=? AND version=?',[$note,$owner,$date,$status,$u['org_id'],$id,num($b['version']??0,1)])->rowCount()){db()->rollBack();out(['error'=>'Action modifiée. Actualisez.'],409);}audit($u,'pilot.action.updated',$id);db()->commit();out(['ok'=>true]);
}
if($action==='pilot.records'&&$method==='GET'){
 $kind=text($_GET['kind']??'',20);$search=text($_GET['q']??'',200);$scope=match($kind){'stock'=>'production','receivable'=>'finance','hr'=>'hr','client','opportunity'=>'commercial',default=>''};if(!$scope)out(['error'=>'Registre inconnu'],422);pilotRequire($u,$scope);
 $items=match($kind){
 'stock'=>run('SELECT * FROM wm_pilot_stock WHERE org_id=? ORDER BY updated_at DESC,id DESC LIMIT 200',[$u['org_id']])->fetchAll(),
 'receivable'=>run('SELECT * FROM wm_pilot_receivables WHERE org_id=? ORDER BY due_date,id DESC LIMIT 200',[$u['org_id']])->fetchAll(),
 'hr'=>run('SELECT * FROM wm_pilot_hr_snapshots WHERE org_id=? ORDER BY snapshot_date DESC,department LIMIT 200',[$u['org_id']])->fetchAll(),
 'client'=>run('SELECT l.id,l.name,l.country,l.city,m.channel,m.latitude,m.longitude,m.source_note,COALESCE(m.version,0) AS version FROM wm_leads l LEFT JOIN wm_pilot_client_meta m ON m.org_id=l.org_id AND m.lead_id=l.id WHERE l.org_id=? AND LOCATE(?,CONCAT(l.name,\' \',l.country,\' \',l.city))>0 ORDER BY l.name LIMIT 200',[$u['org_id'],$search])->fetchAll(),
 'opportunity'=>run('SELECT o.id,o.title,o.stage,o.currency,o.value_amount,o.expected_date,m.probability_bps,m.closed_date,m.source_note,COALESCE(m.version,0) AS version FROM wm_opportunities o LEFT JOIN wm_pilot_opportunity_meta m ON m.org_id=o.org_id AND m.opportunity_id=o.id WHERE o.org_id=? AND LOCATE(?,o.title)>0 ORDER BY o.updated_at DESC LIMIT 200',[$u['org_id'],$search])->fetchAll()};
 out(['items'=>$items,'kind'=>$kind,'limit'=>200,'business_day'=>businessDay()]);
}
if($action==='pilot.record'&&in_array($method,['POST','PUT'],true)){
 $b=body();$kind=text($b['kind']??'',20);$scope=match($kind){'stock'=>'production','receivable'=>'finance','hr'=>'hr','client','opportunity'=>'commercial',default=>''};if(!$scope)out(['error'=>'Registre inconnu'],422);pilotRequire($u,$scope);
 $id=empty($b['id'])?0:num($b['id'],1);$version=num($b['version']??0);$note=text($b['source_note']??'',1000,true);$day=businessDay();$table='';$values=[];
 if($kind==='client'){
  if(!$id)out(['error'=>'Client requis'],422);lead($u,$id);$channel=text($b['channel']??'unknown',20);if(!in_array($channel,['unknown','direct','distributor','partner'],true))out(['error'=>'Canal invalide'],422);
  $coords=[];foreach(['latitude'=>90,'longitude'=>180] as $key=>$max){$v=$b[$key]??'';if($v===''||$v===null){$coords[$key]=null;continue;}if(!(is_string($v)||is_int($v)||is_float($v))||!preg_match('/^-?\d{1,3}(?:\.\d{1,6})?$/D',(string)$v)||abs((float)$v)>$max)out(['error'=>'Coordonnées invalides'],422);$coords[$key]=(string)$v;}if(($coords['latitude']===null)!==($coords['longitude']===null))out(['error'=>'Renseignez latitude et longitude ensemble'],422);
  $values=['channel'=>$channel]+$coords+['source_note'=>$note];$table='wm_pilot_client_meta';
 }elseif($kind==='opportunity'){
  if(!$id)out(['error'=>'Opportunité requise'],422);$o=opportunityFor($u,$id);$p=$b['probability']??'';$p=$p===''||$p===null?null:percentBps($p);$closed=dateValue($b['closed_date']??'');if($closed&&($closed>$day||!in_array($o['stage'],['won','lost'],true)))out(['error'=>'La date de clôture exige une affaire gagnée/perdue et une date non future'],422);$values=['probability_bps'=>$p,'closed_date'=>$closed,'source_note'=>$note];$table='wm_pilot_opportunity_meta';
 }elseif($kind==='stock'){
  $qty=[];foreach(['quantity','reserved','reorder_point'] as $key){$v=$b[$key]??'';if(!(is_string($v)||is_int($v))||!preg_match('/^\d{1,10}(?:\.\d{1,3})?$/D',(string)$v))out(['error'=>'Quantité de stock invalide'],422);$qty[$key]=(string)$v;}$date=dateValue($b['counted_date']??'',false);if($date>$day)out(['error'=>'Comptage futur interdit'],422);
  $values=['sku'=>text($b['sku']??'',80,true),'warehouse'=>text($b['warehouse']??'',100,true),'unit'=>text($b['unit']??'',30,true)]+$qty+['counted_date'=>$date,'source_note'=>$note,'active'=>num($b['active']??1,0,1)];$table='wm_pilot_stock';
 }elseif($kind==='receivable'){
  $currency=text($b['currency']??'',3,true);$total=moneyUnits($b['total_amount']??'',$currency);$paid=moneyUnits($b['paid_amount']??'',$currency);if($total>99999999999999||$paid>$total)out(['error'=>'Montants incohérents ou trop élevés'],422);$lid=empty($b['lead_id'])?null:num($b['lead_id'],1);if($lid)lead($u,$lid);$issued=dateValue($b['invoice_date']??'',false);$due=dateValue($b['due_date']??'',false);if($issued>$day||$due<$issued)out(['error'=>'Dates de facture et échéance incohérentes'],422);
  $values=['lead_id'=>$lid,'reference'=>text($b['reference']??'',100,true),'currency'=>$currency,'total_amount'=>amountString($total,$currency),'paid_amount'=>amountString($paid,$currency),'invoice_date'=>$issued,'due_date'=>$due,'source_note'=>$note,'active'=>num($b['active']??1,0,1)];$table='wm_pilot_receivables';
 }else{
  $date=dateValue($b['snapshot_date']??'',false);$staff=num($b['staff_count']??0,0,1000000);$absent=num($b['absent_count']??0,0,$staff);if($date>$day)out(['error'=>'Relevé futur interdit'],422);$hours=[];foreach(['planned_hours','worked_hours','overtime_hours'] as $k){$v=$b[$k]??'';if(!(is_string($v)||is_int($v))||!preg_match('/^\d{1,9}(?:\.\d{1,2})?$/D',(string)$v))out(['error'=>'Heures invalides'],422);$hours[$k]=(string)$v;}$values=['snapshot_date'=>$date,'department'=>text($b['department']??'',100,true),'staff_count'=>$staff,'absent_count'=>$absent]+$hours+['source_note'=>$note];$table='wm_pilot_hr_snapshots';
 }
 db()->beginTransaction();
 try{
  if(in_array($kind,['client','opportunity'],true)){
   $fk=$kind==='client'?'lead_id':'opportunity_id';if($kind==='client')b2bLockLead($u,$id);else{b2bLockLead($u,(int)$o['lead_id']);if(!run('SELECT id FROM wm_opportunities WHERE id=? AND org_id=? FOR UPDATE',[$id,$u['org_id']])->fetch()){db()->rollBack();out(['error'=>'Opportunité introuvable'],404);}}
   $old=run("SELECT version FROM $table WHERE org_id=? AND $fk=? FOR UPDATE",[$u['org_id'],$id])->fetchColumn();if((int)$old!==$version){db()->rollBack();out(['error'=>'Données modifiées. Actualisez.'],409);}
   if($old){$sets=implode(',',array_map(fn($k)=>$k.'=?',array_keys($values)));run("UPDATE $table SET $sets,version=version+1 WHERE org_id=? AND $fk=?",array_merge(array_values($values),[$u['org_id'],$id]));}
   else{run("INSERT INTO $table(org_id,$fk,".implode(',',array_keys($values)).') VALUES('.implode(',',array_fill(0,count($values)+2,'?')).')',array_merge([$u['org_id'],$id],array_values($values)));}
  }else{
   if($kind==='stock'&&$id)sampleValidateStockEdit($u,$id,$values);
   if($kind==='receivable'&&$values['lead_id'])b2bLockLead($u,(int)$values['lead_id']);
   if($id){$sets=implode(',',array_map(fn($k)=>$k.'=?',array_keys($values)));if(!run("UPDATE $table SET $sets,version=version+1 WHERE org_id=? AND id=? AND version=?",array_merge(array_values($values),[$u['org_id'],$id,$version]))->rowCount()){db()->rollBack();out(['error'=>'Enregistrement modifié ou introuvable'],409);}}
   else{run("INSERT INTO $table(org_id,".implode(',',array_keys($values)).') VALUES('.implode(',',array_fill(0,count($values)+1,'?')).')',array_merge([$u['org_id']],array_values($values)));$id=(int)db()->lastInsertId();}
  }
 }catch(PDOException $e){db()->rollBack();if($e->getCode()==='23000')out(['error'=>'Référence déjà utilisée dans ce registre'],409);throw $e;}
 audit($u,'pilot.'.$kind.'.saved',$id);db()->commit();out(['ok'=>true]);
}
if($action==='pilot.source'&&$method==='GET'){
 $type=text($_GET['type']??'',30);$id=num($_GET['id']??0,1);$scope=match($type){'order','bat','stock'=>'production','receivable'=>'finance','hr'=>'hr',default=>'commercial'};pilotRequire($u,$scope);
 if(in_array($type,['order','bat'],true)){$t=$type==='order'?'wm_b2b_orders':'wm_b2b_documents';$leadId=run("SELECT lead_id FROM $t WHERE org_id=? AND id=?",[$u['org_id'],$id])->fetchColumn();if(!$leadId)out(['error'=>'Fiche introuvable'],404);out(['lead_id'=>$leadId]);}
 $t=match($type){'stock'=>'wm_pilot_stock','receivable'=>'wm_pilot_receivables','hr'=>'wm_pilot_hr_snapshots',default=>''};if(!$t)out(['error'=>'Source inconnue'],422);$r=run("SELECT * FROM $t WHERE org_id=? AND id=?",[$u['org_id'],$id])->fetch();if(!$r)out(['error'=>'Enregistrement introuvable'],404);out(['item'=>$r]);
}
