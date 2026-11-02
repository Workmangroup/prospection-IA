<?php
declare(strict_types=1);
if($action==='quote.ai'&&$method==='POST'){
 $b=body();$l=lead($u,num($b['lead_id']??0,1));$rows=run('SELECT id AS product_id,sku,name,description,unit,price_'.strtolower($l['currency']).' AS catalog_price,vat_bps FROM wm_products WHERE org_id=? AND active=1 AND price_'.strtolower($l['currency']).' IS NOT NULL ORDER BY name LIMIT 100',[$u['org_id']])->fetchAll();
 $proposal=aiQuoteProposal($u,$l,$rows,$b);audit($u,'quote.ai_proposed',(int)$l['id']);out(['proposal'=>$proposal]);
}
if($action==='b2b.admin'&&$method==='GET'){
 $id=num($_GET['id']??0,1);$l=lead($u,$id);
 $accounts=$u['role']==='owner'?run('SELECT id,login_code,email,full_name,active,must_change,auth_version,created_at FROM wm_b2b_accounts WHERE org_id=? AND lead_id=? ORDER BY id',[$u['org_id'],$id])->fetchAll():[];
 out(['lead'=>['id'=>$l['id'],'name'=>$l['name']],'accounts'=>$accounts,'orders'=>run('SELECT * FROM wm_b2b_orders WHERE org_id=? AND lead_id=? ORDER BY id DESC LIMIT 200',[$u['org_id'],$id])->fetchAll(),'documents'=>b2bDocuments($u,$id),'threads'=>b2bThreads($u,$id),'decisions'=>run('SELECT d.document_id,d.decision,d.sha256,d.note,d.created_at,a.full_name,a.email FROM wm_b2b_bat_decisions d JOIN wm_b2b_accounts a ON a.id=d.account_id AND a.org_id=d.org_id WHERE d.org_id=? AND d.lead_id=? ORDER BY d.id DESC LIMIT 200',[$u['org_id'],$id])->fetchAll(),'quotes'=>run('SELECT q.id,q.number,q.title,q.status,q.currency,q.total,q.version,s.quote_id AS shared FROM wm_quotes q LEFT JOIN wm_b2b_quotes s ON s.org_id=q.org_id AND s.quote_id=q.id WHERE q.org_id=? AND q.lead_id=? ORDER BY q.id DESC LIMIT 200',[$u['org_id'],$id])->fetchAll()]);
}
if($action==='b2b.account'&&in_array($method,['POST','PUT'],true)){
 owner($u);$b=body();$leadId=num($b['lead_id']??0,1);lead($u,$leadId);$name=text($b['full_name']??'',200,true);$e=email($b['email']??'',true);$active=num($b['active']??1,0,1);$password=$b['password']??'';$hash=$password!==''?password_hash(passwordValue($password),PASSWORD_DEFAULT):null;
 if($method==='POST'&&!$hash)out(['error'=>'Mot de passe initial requis'],422);
 db()->beginTransaction();b2bLockLead($u,$leadId);
 $id=$method==='PUT'?num($b['id']??0,1):0;
 if(run('SELECT id FROM wm_b2b_accounts WHERE org_id=? AND lead_id=? AND email=? AND id<>?',[$u['org_id'],$leadId,$e,$id])->fetch()){db()->rollBack();out(['error'=>'Ce contact dispose déjà d’un accès.'],409);}
 if($id){$old=run('SELECT * FROM wm_b2b_accounts WHERE org_id=? AND lead_id=? AND id=? FOR UPDATE',[$u['org_id'],$leadId,$id])->fetch();if(!$old||(int)$old['auth_version']!==num($b['auth_version']??0,1)){db()->rollBack();out(['error'=>'Accès modifié ou introuvable. Rechargez.'],409);}
 run('UPDATE wm_b2b_accounts SET email=?,full_name=?,active=?,password_hash=?,must_change=?,auth_version=auth_version+1 WHERE org_id=? AND lead_id=? AND id=?',[$e,$name,$active,$hash??$old['password_hash'],$hash?1:$old['must_change'],$u['org_id'],$leadId,$id]);
 }else{run('INSERT INTO wm_b2b_accounts(org_id,lead_id,login_code,email,full_name,password_hash,active) VALUES(?,?,?,?,?,?,?)',[$u['org_id'],$leadId,bin2hex(random_bytes(8)),$e,$name,$hash,$active]);$id=(int)db()->lastInsertId();}
 audit($u,'b2b.account.saved',$id);db()->commit();out(['ok'=>true],$method==='POST'?201:200);
}
if($action==='b2b.order'&&in_array($method,['POST','PUT'],true)){
 $b=body();$leadId=num($b['lead_id']??0,1);lead($u,$leadId);$status=text($b['status']??'confirmed',20);if(!in_array($status,['confirmed','production','quality','ready','shipped','delivered','cancelled'],true))out(['error'=>'Statut invalide'],422);
 $values=[text($b['reference']??'',80,true),text($b['title']??'',200,true),$status,text($b['production_note']??'',5000),text($b['shipment_note']??'',5000),text($b['carrier']??'',150),text($b['tracking_ref']??'',200),dateValue($b['estimated_delivery']??'')];
 db()->beginTransaction();b2bLockLead($u,$leadId);$id=$method==='PUT'?num($b['id']??0,1):0;
 if(run('SELECT id FROM wm_b2b_orders WHERE org_id=? AND reference=? AND id<>?',[$u['org_id'],$values[0],$id])->fetch()){db()->rollBack();out(['error'=>'Référence de commande déjà utilisée'],409);}
 if($id){if(!run('UPDATE wm_b2b_orders SET reference=?,title=?,status=?,production_note=?,shipment_note=?,carrier=?,tracking_ref=?,estimated_delivery=?,version=version+1 WHERE org_id=? AND lead_id=? AND id=? AND version=?',array_merge($values,[$u['org_id'],$leadId,$id,num($b['version']??0,1)]))->rowCount()){db()->rollBack();out(['error'=>'Commande modifiée ou introuvable'],409);}}
 else{run('INSERT INTO wm_b2b_orders(reference,title,status,production_note,shipment_note,carrier,tracking_ref,estimated_delivery,org_id,lead_id) VALUES(?,?,?,?,?,?,?,?,?,?)',array_merge($values,[$u['org_id'],$leadId]));$id=(int)db()->lastInsertId();}
 sampleOrderOrigin($u,$id,$b);audit($u,'b2b.order.saved',$id);db()->commit();out(['ok'=>true],$method==='POST'?201:200);
}
if($action==='b2b.document'&&$method==='POST'){
 $b=body();$leadId=num($b['lead_id']??0,1);lead($u,$leadId);$kind=text($b['kind']??'',20);if(!in_array($kind,['bat','invoice','other'],true))out(['error'=>'Type de document invalide'],422);
 $title=text($b['title']??'',200,true);$name=text($b['file_name']??'',200,true);$encoded=text($b['pdf_base64']??'',1500000,true);$raw=base64_decode($encoded,true);
 if($raw===false||strlen($raw)>1048576||!str_starts_with($raw,'%PDF-')||!str_contains(substr($raw,-2048),'%%EOF'))out(['error'=>'PDF valide de 1 Mo maximum requis'],422);
 $order=empty($b['order_id'])?null:num($b['order_id'],1);$replaces=empty($b['replaces_id'])?null:num($b['replaces_id'],1);
 db()->beginTransaction();b2bLockLead($u,$leadId);
 if($order&&!run('SELECT id FROM wm_b2b_orders WHERE org_id=? AND lead_id=? AND id=?',[$u['org_id'],$leadId,$order])->fetch()){db()->rollBack();out(['error'=>'Commande introuvable pour ce client'],404);}
 if($replaces){$old=run('SELECT * FROM wm_b2b_documents WHERE org_id=? AND lead_id=? AND id=? FOR UPDATE',[$u['org_id'],$leadId,$replaces])->fetch();if(!$old||$old['kind']!==$kind||(string)$old['order_id']!==(string)$order){db()->rollBack();out(['error'=>'Révision incohérente : même client, type et commande requis'],422);}if(run('SELECT id FROM wm_b2b_documents WHERE org_id=? AND replaces_id=?',[$u['org_id'],$replaces])->fetch()){db()->rollBack();out(['error'=>'Une révision plus récente existe déjà'],409);}if($old['bat_status']==='pending')run("UPDATE wm_b2b_documents SET bat_status='superseded',version=version+1 WHERE id=? AND org_id=?",[$replaces,$u['org_id']]);}
 run('INSERT INTO wm_b2b_documents(org_id,lead_id,order_id,kind,title,file_name,pdf_base64,sha256,bat_status,replaces_id,created_by) VALUES(?,?,?,?,?,?,?,?,?,?,?)',[$u['org_id'],$leadId,$order,$kind,$title,$name,base64_encode($raw),hash('sha256',$raw),$kind==='bat'?'pending':'not_bat',$replaces,$u['id']]);$id=(int)db()->lastInsertId();audit($u,'b2b.document.published',$id);db()->commit();out(['ok'=>true],201);
}
if($action==='b2b.document.visibility'&&$method==='PUT'){
 $b=body();$leadId=num($b['lead_id']??0,1);lead($u,$leadId);$id=num($b['id']??0,1);$visible=num($b['visible']??0,0,1);
 db()->beginTransaction();b2bLockLead($u,$leadId);if(!run('UPDATE wm_b2b_documents SET visible=?,version=version+1 WHERE org_id=? AND lead_id=? AND id=? AND version=?',[$visible,$u['org_id'],$leadId,$id,num($b['version']??0,1)])->rowCount()){db()->rollBack();out(['error'=>'Document modifié ou introuvable'],409);}audit($u,'b2b.document.visibility',$id);db()->commit();out(['ok'=>true]);
}
if($action==='b2b.document.pdf'&&$method==='GET'){$leadId=num($_GET['lead_id']??0,1);lead($u,$leadId);b2bDocumentDownload($u,$leadId,num($_GET['id']??0,1),false);}
if($action==='b2b.quote.share'&&$method==='PUT'){
 $b=body();$leadId=num($b['lead_id']??0,1);lead($u,$leadId);$id=num($b['id']??0,1);$shared=num($b['shared']??0,0,1);
 db()->beginTransaction();b2bLockLead($u,$leadId);$q=run('SELECT * FROM wm_quotes WHERE id=? AND org_id=? AND lead_id=? FOR UPDATE',[$id,$u['org_id'],$leadId])->fetch();if(!$q||$q['status']==='draft'){db()->rollBack();out(['error'=>'Seul un devis émis de ce client peut être partagé'],409);}
 if($shared)run('INSERT IGNORE INTO wm_b2b_quotes(org_id,lead_id,quote_id) VALUES(?,?,?)',[$u['org_id'],$leadId,$id]);else run('DELETE FROM wm_b2b_quotes WHERE org_id=? AND lead_id=? AND quote_id=?',[$u['org_id'],$leadId,$id]);audit($u,'b2b.quote.sharing',$id);db()->commit();out(['ok'=>true]);
}
if($action==='b2b.message'&&$method==='POST'){$b=body();$id=num($b['lead_id']??0,1);lead($u,$id);b2bMessage($u,$id,$b,null);out(['ok'=>true],201);}
if($action==='b2b.thread'&&$method==='PUT'){
 $b=body();$leadId=num($b['lead_id']??0,1);lead($u,$leadId);$id=num($b['id']??0,1);$status=text($b['status']??'',20);if(!in_array($status,['open','resolved'],true))out(['error'=>'Statut invalide'],422);db()->beginTransaction();b2bLockLead($u,$leadId);
 if(!run('UPDATE wm_b2b_threads SET status=?,version=version+1 WHERE org_id=? AND lead_id=? AND id=? AND version=?',[$status,$u['org_id'],$leadId,$id,num($b['version']??0,1)])->rowCount()){db()->rollBack();out(['error'=>'Conversation modifiée ou introuvable'],409);}audit($u,'b2b.thread.updated',$id);db()->commit();out(['ok'=>true]);
}
