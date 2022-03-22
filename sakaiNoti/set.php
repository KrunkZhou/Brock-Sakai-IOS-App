<?php

include('kdb.class.php');
$db = new kdb();

$SAKAIID="";
$endpoint="";
$pushtoken=array();



if ($_GET['sakaiid']){ //通过get获取
	$SAKAIID=$_GET['sakaiid'];
}else if ($_POST['sakaiid']){ //通过post获取
	$SAKAIID=$_POST['sakaiid'];
}else{ //从app获取cookies
	$content=json_decode(file_get_contents('php://input'),1);
	if (is_array($content)){
		foreach ($content as $key => $value) {
			if ($value['Name']=="SAKAIID"){
				$SAKAIID=$value['Value'];
			}
		}
	}
}

if ($SAKAIID!=""){
	//获取userid来储存历史记录
	$c1 = curl_init('https://lms.brocku.ca/direct/session.json'); 
	curl_setopt($c1, CURLOPT_VERBOSE, 1); 
	curl_setopt($c1, CURLOPT_COOKIE, 'SAKAIID='.$SAKAIID); 
	curl_setopt($c1, CURLOPT_RETURNTRANSFER, 1); 
	$user_session = curl_exec($c1); 
	curl_close($c1);

	$user_id = json_decode($user_session,1)['session_collection'][0]['userEid'];

	$auser = $db->find_one('users',array('username' =>$user_id));
	if ($auser){
		$pushtoken=$auser[array_key_first($auser)]['pushtoken'];
	}
	if ($_GET['pushtoken']){ //通过get获取
		if (!in_array($_GET['pushtoken'], $pushtoken)&&$_GET['pushtoken']!=""){
			array_push($pushtoken, $_GET['pushtoken']);
		}
	}

	if ($user_id){
		$data = array(
			'username' => $user_id,
			'SAKAIID' => $SAKAIID,
			'enable' => true,
			'reset_noti_sent' => false,
			'pushtoken'=> $pushtoken
		);

		$auser = $db->find_one('users',array('username' =>$user_id));
		if ($auser){
			$db->update('users',$data,array_key_first($auser));
			echo "update";
			exit(0);
		}else{
			$data['endpoint']=$endpoint;
			$db->insert('users',$data);
			echo "set";
			exit(0);
		}
	}
}

echo "false"

?>