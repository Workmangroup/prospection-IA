<?php
declare(strict_types=1);
require_once __DIR__.'/commerce.php';
require_once __DIR__.'/b2b.php';
require_once __DIR__.'/quote-ai.php';
require_once __DIR__.'/samples.php';
function portalSession(): void {
 $https=($_SERVER['HTTPS']??'')==='on';if((cfg()['require_https']??true)&&!$https)out(['error'=>'HTTPS requis'],400);
 session_name('workman_portal_session');ini_set('session.use_strict_mode','1');ini_set('session.use_only_cookies','1');
 session_set_cookie_params(['lifetime'=>0,'path'=>'/','secure'=>$https,'httponly'=>true,'samesite'=>'Lax']);session_start();
 if(isset($_SESSION['last'])&&(time()-$_SESSION['last']>1800||time()-($_SESSION['started']??0)>43200)){$_SESSION=[];session_regenerate_id(true);}
 $_SESSION['last']=time();$_SESSION['started']??=time();$_SESSION['csrf']??=bin2hex(random_bytes(32));
}
function portalAccount(): ?array {
 if(empty($_SESSION['portal_id']))return null;
 $a=run('SELECT a.id,a.org_id,a.lead_id,a.email,a.full_name,a.auth_version,a.must_change,l.name AS company FROM wm_b2b_accounts a JOIN wm_leads l ON l.id=a.lead_id AND l.org_id=a.org_id WHERE a.id=? AND a.active=1',[$_SESSION['portal_id']])->fetch();
 if(!$a||(int)$a['auth_version']!==(int)($_SESSION['portal_version']??0))return null;return $a;
}
function portalAssertAccountLocked(int $id): void {
 $a=run('SELECT active,auth_version,must_change FROM wm_b2b_accounts WHERE id=? FOR UPDATE',[$id])->fetch();
 if(!$a||!(int)$a['active']||(int)$a['auth_version']!==(int)($_SESSION['portal_version']??0)||(int)$a['must_change']){db()->rollBack();out(['error'=>'Accès expiré. Reconnectez-vous.'],401);}
}
portalSession();$action=$_GET['action']??'session';if(!is_string($action))out(['error'=>'Action invalide'],400);$method=$_SERVER['REQUEST_METHOD'];if(!in_array($method,['GET','POST'],true))out(['error'=>'Méthode refusée'],405);
if($method==='POST')csrf();
if($action==='session'&&$method==='GET')out(['account'=>portalAccount(),'csrf'=>$_SESSION['csrf']]);
if($action==='login'&&$method==='POST'){
 $b=body();$code=strtolower(text($b['code']??'',16,true));$e=email($b['email']??'',true);$password=text($b['password']??'',1024,true);
 rate('portal-login-ip:'.($_SERVER['REMOTE_ADDR']??''),25,900);rate('portal-login:'.$code.':'.$e,10,900);
 $a=run('SELECT a.* FROM wm_b2b_accounts a JOIN wm_leads l ON l.id=a.lead_id AND l.org_id=a.org_id WHERE a.login_code=? AND a.email=? AND a.active=1',[$code,$e])->fetch();
 $valid=password_verify($password,$a['password_hash']??'$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2uheWG/igi');
 if(!$a||!$valid)out(['error'=>'Identifiants incorrects ou accès désactivé'],401);
 session_regenerate_id(true);$_SESSION=['portal_id'=>(int)$a['id'],'portal_version'=>(int)$a['auth_version'],'csrf'=>bin2hex(random_bytes(32)),'last'=>time(),'started'=>time()];out(['ok'=>true]);
}
$a=portalAccount();if(!$a)out(['error'=>'Connexion client requise'],401);
$u=['org_id'=>$a['org_id'],'id'=>null];$leadId=(int)$a['lead_id'];
if($action==='logout'&&$method==='POST'){$_SESSION=[];session_destroy();setcookie(session_name(),'',time()-3600,'/','',($_SERVER['HTTPS']??'')==='on',true);out(['ok'=>true]);}
if($action==='password'&&$method==='POST'){
 $b=body();$password=passwordValue($b['password']??'');$current=text($b['current']??'',1024,true);rate('portal-password:'.$a['id'],10,900);
 db()->beginTransaction();$old=run('SELECT * FROM wm_b2b_accounts WHERE id=? AND active=1 FOR UPDATE',[$a['id']])->fetch();if(!$old||(int)$old['auth_version']!==(int)$a['auth_version']||!password_verify($current,$old['password_hash'])){db()->rollBack();out(['error'=>'Mot de passe actuel incorrect ou accès expiré'],403);}if(password_verify($password,$old['password_hash'])){db()->rollBack();out(['error'=>'Choisissez un mot de passe différent du mot de passe temporaire.'],422);}
 run('UPDATE wm_b2b_accounts SET password_hash=?,must_change=0,auth_version=auth_version+1 WHERE id=?',[password_hash($password,PASSWORD_DEFAULT),$a['id']]);db()->commit();session_regenerate_id(true);$_SESSION['portal_version']=(int)$a['auth_version']+1;$_SESSION['csrf']=bin2hex(random_bytes(32));out(['ok'=>true]);
}
if((int)$a['must_change'])out(['error'=>'Modifiez votre mot de passe temporaire avant de consulter les documents.'],403);
if($action==='dashboard'&&$method==='GET'){
 $quotes=run("SELECT q.id,q.number,q.title,q.status,q.currency,q.subtotal,q.total_tax,q.total,q.valid_until FROM wm_quotes q JOIN wm_b2b_quotes s ON s.quote_id=q.id AND s.org_id=q.org_id AND s.lead_id=q.lead_id WHERE s.org_id=? AND s.lead_id=? AND q.status<>'draft' ORDER BY q.id DESC LIMIT 200",[$a['org_id'],$leadId])->fetchAll();
 out(['account'=>$a,'quotes'=>$quotes,'orders'=>run('SELECT id,reference,title,status,production_note,shipment_note,carrier,tracking_ref,estimated_delivery,updated_at FROM wm_b2b_orders WHERE org_id=? AND lead_id=? ORDER BY id DESC LIMIT 200',[$a['org_id'],$leadId])->fetchAll(),'documents'=>b2bDocuments($u,$leadId,true),'threads'=>b2bThreads($u,$leadId),'samples'=>samplePortalList($u,$leadId),'decisions'=>run('SELECT document_id,decision,sha256,note,created_at FROM wm_b2b_bat_decisions WHERE org_id=? AND lead_id=? ORDER BY id DESC LIMIT 200',[$a['org_id'],$leadId])->fetchAll()]);
}
if($action==='document.pdf'&&$method==='GET')b2bDocumentDownload($u,$leadId,num($_GET['id']??0,1),true);
if($action==='quote.pdf'&&$method==='GET'){
 $id=num($_GET['id']??0,1);if(!run("SELECT q.id FROM wm_quotes q JOIN wm_b2b_quotes s ON s.quote_id=q.id AND s.org_id=q.org_id AND s.lead_id=q.lead_id WHERE q.id=? AND s.org_id=? AND s.lead_id=? AND q.status<>'draft'",[$id,$a['org_id'],$leadId])->fetch())out(['error'=>'Devis introuvable'],404);
 require_once __DIR__.'/quote-pdf.php';sendQuotePdf($u,$id);
}
if($action==='bat.decision'&&$method==='POST'){
 $b=body();$id=num($b['id']??0,1);$decision=text($b['decision']??'',20);$sha=text($b['sha256']??'',64,true);$version=num($b['version']??0,1);$note=text($b['note']??'',3000,$decision==='rejected');
 if(!in_array($decision,['approved','rejected'],true)||($b['acknowledged']??false)!==true)out(['error'=>'Confirmez votre décision après consultation du PDF.'],422);
 db()->beginTransaction();b2bLockLead($u,$leadId);portalAssertAccountLocked((int)$a['id']);
 $d=run('SELECT * FROM wm_b2b_documents WHERE id=? AND org_id=? AND lead_id=? AND visible=1 FOR UPDATE',[$id,$a['org_id'],$leadId])->fetch();
 if(!$d){db()->rollBack();out(['error'=>'BAT introuvable'],404);}
 if($d['kind']!=='bat'||$d['bat_status']!=='pending'||(int)$d['version']!==$version||!hash_equals($d['sha256'],$sha)||run('SELECT id FROM wm_b2b_documents WHERE org_id=? AND replaces_id=?',[$a['org_id'],$id])->fetch()){db()->rollBack();out(['error'=>'BAT modifié, remplacé ou déjà traité. Rechargez la page.'],409);}
 run('INSERT INTO wm_b2b_bat_decisions(org_id,lead_id,document_id,account_id,decision,sha256,note) VALUES(?,?,?,?,?,?,?)',[$a['org_id'],$leadId,$id,$a['id'],$decision,$sha,$note]);run('UPDATE wm_b2b_documents SET bat_status=?,version=version+1 WHERE id=? AND org_id=?',[$decision,$id,$a['org_id']]);db()->commit();out(['ok'=>true]);
}
if($action==='sample.receive'&&$method==='POST'){$b=body();$id=num($b['id']??0,1);if(!run('SELECT id FROM wm_samples WHERE org_id=? AND lead_id=? AND id=?',[$a['org_id'],$leadId,$id])->fetch())out(['error'=>'Échantillon introuvable'],404);sampleReceive($u,$id,$b,$a);out(['ok'=>true]);}
if($action==='message'&&$method==='POST'){rate('portal-message:'.$a['id'],60,3600);b2bMessage($u,$leadId,body(),(int)$a['id']);out(['ok'=>true],201);}
out(['error'=>'Action introuvable'],404);
