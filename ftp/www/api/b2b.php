<?php
declare(strict_types=1);
function b2bLockLead(array $u,int $id): void {if(!run('SELECT id FROM wm_leads WHERE org_id=? AND id=? FOR UPDATE',[$u['org_id'],$id])->fetch()){db()->rollBack();out(['error'=>'Client introuvable'],404);}}
function b2bHasRecords(array $u,int $id): bool {
 if(function_exists('pilotHasRecords')&&pilotHasRecords($u,$id))return true;
 foreach(['wm_samples','wm_b2b_accounts','wm_b2b_orders','wm_b2b_documents','wm_b2b_quotes','wm_b2b_threads'] as $t)if(run("SELECT lead_id FROM $t WHERE org_id=? AND lead_id=? LIMIT 1",[$u['org_id'],$id])->fetch())return true;return false;
}
function b2bDocuments(array $u,int $leadId,bool $client=false): array {
 return run('SELECT id,order_id,kind,title,file_name,sha256,visible,bat_status,replaces_id,version,created_at FROM wm_b2b_documents WHERE org_id=? AND lead_id=?'.($client?' AND visible=1':'').' ORDER BY id DESC LIMIT 200',[$u['org_id'],$leadId])->fetchAll();
}
function b2bThreads(array $u,int $leadId): array {
 $threads=run('SELECT id,kind,subject,status,version,created_at FROM wm_b2b_threads WHERE org_id=? AND lead_id=? ORDER BY id DESC LIMIT 100',[$u['org_id'],$leadId])->fetchAll();
 foreach($threads as &$t)$t['messages']=run("SELECT id,message,created_at,CASE WHEN account_id IS NULL THEN 'staff' ELSE 'client' END AS sender FROM wm_b2b_messages WHERE org_id=? AND lead_id=? AND thread_id=? ORDER BY id DESC LIMIT 200",[$u['org_id'],$leadId,$t['id']])->fetchAll();unset($t);return $threads;
}
function b2bDocumentDownload(array $u,int $leadId,int $id,bool $client): never {
 $d=run('SELECT file_name,pdf_base64 FROM wm_b2b_documents WHERE org_id=? AND lead_id=? AND id=?'.($client?' AND visible=1':''),[$u['org_id'],$leadId,$id])->fetch();if(!$d)out(['error'=>'Document introuvable'],404);
 $raw=base64_decode($d['pdf_base64'],true);if($raw===false||!str_starts_with($raw,'%PDF-'))out(['error'=>'Document indisponible'],503);
 header('Content-Type: application/pdf');header('Content-Disposition: attachment; filename="document-'.$id.'.pdf"');header('Content-Security-Policy: sandbox');header('Content-Length: '.strlen($raw));echo $raw;exit;
}
function b2bMessage(array $u,int $leadId,array $b,?int $accountId): void {
 $message=text($b['message']??'',5000,true);$id=empty($b['thread_id'])?null:num($b['thread_id'],1);$kind=text($b['kind']??'message',20);$subject=text($b['subject']??'',200,!$id);
 if(!in_array($kind,['message','complaint'],true))out(['error'=>'Type de conversation invalide'],422);
 db()->beginTransaction();b2bLockLead($u,$leadId);
 if($accountId)portalAssertAccountLocked($accountId);
 if($id){$t=run('SELECT status FROM wm_b2b_threads WHERE org_id=? AND lead_id=? AND id=? FOR UPDATE',[$u['org_id'],$leadId,$id])->fetch();if(!$t){db()->rollBack();out(['error'=>'Conversation introuvable'],404);}if($t['status']!=='open'){db()->rollBack();out(['error'=>'Conversation résolue. Ouvrez une nouvelle demande.'],409);}}
 else{run('INSERT INTO wm_b2b_threads(org_id,lead_id,kind,subject) VALUES(?,?,?,?)',[$u['org_id'],$leadId,$kind,$subject]);$id=(int)db()->lastInsertId();}
 run('INSERT INTO wm_b2b_messages(org_id,lead_id,thread_id,account_id,staff_id,message) VALUES(?,?,?,?,?,?)',[$u['org_id'],$leadId,$id,$accountId,$accountId?null:$u['id'],$message]);
 if(!$accountId)audit($u,'b2b.message.saved',$id);db()->commit();
}
