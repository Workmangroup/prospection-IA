<?php
declare(strict_types=1);
// Included after authentication, company context and CSRF checks in index.php.
if($action==='crm.profile'&&$method==='GET'){
 $id=num($_GET['id']??0,1);lead($u,$id);
 out(['contacts'=>run('SELECT * FROM wm_crm_contacts WHERE org_id=? AND lead_id=? ORDER BY active DESC,full_name,id',[$u['org_id'],$id])->fetchAll(),
 'workwear'=>run('SELECT * FROM wm_workwear_profiles WHERE org_id=? AND lead_id=?',[$u['org_id'],$id])->fetch()?:null]);
}
if($action==='crm.contact'&&in_array($method,['POST','PUT'],true)){
 $b=body();$leadId=num($b['lead_id']??0,1);lead($u,$leadId);
 $values=[text($b['full_name']??'',200,true),text($b['role_text']??'',200),email($b['email']??''),text($b['phone']??'',60),text($b['notes']??'',5000),num($b['active']??1,0,1)];
 db()->beginTransaction();
 // Lock parent so contacts cannot be inserted while the lead is deleted.
 if(!run('SELECT id FROM wm_leads WHERE id=? AND org_id=? FOR UPDATE',[$leadId,$u['org_id']])->fetch()){db()->rollBack();out(['error'=>'Prospect introuvable'],404);}
 if($method==='POST'){
  run('INSERT INTO wm_crm_contacts(org_id,lead_id,full_name,role_text,email,phone,notes,active) VALUES(?,?,?,?,?,?,?,?)',array_merge([$u['org_id'],$leadId],$values));$id=(int)db()->lastInsertId();
 }else{
  $id=num($b['id']??0,1);$version=num($b['version']??0,1);
  if(!run('UPDATE wm_crm_contacts SET full_name=?,role_text=?,email=?,phone=?,notes=?,active=?,version=version+1 WHERE org_id=? AND lead_id=? AND id=? AND version=?',array_merge($values,[$u['org_id'],$leadId,$id,$version]))->rowCount()){
   db()->rollBack();out(['error'=>'Contact modifié ou introuvable. Rechargez la fiche.'],409);
  }
 }
 audit($u,'crm.contact.saved',$id);db()->commit();out(['ok'=>true],$method==='POST'?201:200);
}
if($action==='crm.workwear'&&$method==='PUT'){
 $b=body();$id=num($b['lead_id']??0,1);lead($u,$id);$version=num($b['version']??0);
 $count=$b['wearer_count']??'';$values=[$count===''||$count===null?null:num($count,0,10000000)];
 foreach(['garments','ppe','standards','sizing','branding','renewal','supplier','constraints_text'] as $key)$values[]=text($b[$key]??'',5000);
 db()->beginTransaction();
 if(!run('SELECT id FROM wm_leads WHERE id=? AND org_id=? FOR UPDATE',[$id,$u['org_id']])->fetch()){db()->rollBack();out(['error'=>'Prospect introuvable'],404);}
 if($version===0){
  if(run('SELECT lead_id FROM wm_workwear_profiles WHERE org_id=? AND lead_id=?',[$u['org_id'],$id])->fetch()){db()->rollBack();out(['error'=>'Fiche créée entre-temps. Rechargez-la.'],409);}
  run('INSERT INTO wm_workwear_profiles(org_id,lead_id,wearer_count,garments,ppe,standards,sizing,branding,renewal,supplier,constraints_text) VALUES(?,?,?,?,?,?,?,?,?,?,?)',array_merge([$u['org_id'],$id],$values));
 }else{
  if(!run('UPDATE wm_workwear_profiles SET wearer_count=?,garments=?,ppe=?,standards=?,sizing=?,branding=?,renewal=?,supplier=?,constraints_text=?,version=version+1 WHERE org_id=? AND lead_id=? AND version=?',array_merge($values,[$u['org_id'],$id,$version]))->rowCount()){
   db()->rollBack();out(['error'=>'Fiche modifiée. Rechargez-la avant de sauvegarder.'],409);
  }
 }
 audit($u,'crm.workwear.saved',$id);db()->commit();out(['ok'=>true]);
}
// Preserve the commercial record once the new CRM is used. Archive contacts instead.
if($action==='lead'&&$method==='DELETE'){
 $id=num(body()['id']??0,1);lead($u,$id);
 if(b2bHasRecords($u,$id)||run('SELECT id FROM wm_crm_contacts WHERE org_id=? AND lead_id=? LIMIT 1',[$u['org_id'],$id])->fetch()||run('SELECT lead_id FROM wm_workwear_profiles WHERE org_id=? AND lead_id=?',[$u['org_id'],$id])->fetch())out(['error'=>'Cette entreprise possède une fiche CRM. Conservez son historique ; utilisez le statut Perdu ou Opposition selon le cas.'],409);
}
