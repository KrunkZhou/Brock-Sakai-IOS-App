<?php

include('kdb.class.php');
$db = new kdb();

$users = $db->find('users'); 

if ($users){
	foreach ($users as $key1 => $value) {

		$username=$value['username'];
		$SAKAIID=$value['SAKAIID']; //session
		
		$noti_history=array();
		$noti_ready_to_send=array();
		$reset_noti_sent=$value['reset_noti_sent'];
		$endpoint=$value['endpoint'];
		$pushtoken=$value['pushtoken'];

		if (is_array($value['noti'])){
			$noti_history=$value['noti'];
		}

		//获取userid来判断是否已经登陆
		$c1 = curl_init('https://lms.brocku.ca/direct/session.json'); 
		curl_setopt($c1, CURLOPT_VERBOSE, 1); 
		curl_setopt($c1, CURLOPT_COOKIE, 'SAKAIID='.$SAKAIID); 
		curl_setopt($c1, CURLOPT_RETURNTRANSFER, 1); 
		$user_session = curl_exec($c1); 
		curl_close($c1);

		$user_id = json_decode($user_session,1)['session_collection'][0]['userEid'];
		if ($user_id){
			$enable=true;
			$reset_noti_enable=false;
		
			//获取通知
			$c = curl_init('https://lms.brocku.ca/direct/portal/academicAlerts.json'); 
			curl_setopt($c, CURLOPT_VERBOSE, 1); 
			curl_setopt($c, CURLOPT_COOKIE, 'SAKAIID='.$SAKAIID); 
			curl_setopt($c, CURLOPT_RETURNTRANSFER, 1); 
			$page = curl_exec($c); 
			curl_close($c);

			if(json_decode($page,1)['message']=="NO_ALERTS"){
				echo substr($user_id,0,2)."**** NO_ALERTS <br> ";
				continue;
			}

			$noti=json_decode($page,1)['alerts'];

			
			$noti_ready_to_send=array();

			if(!$noti){
				echo substr($user_id,0,2)."**** NO_ALERTS 404 <br> ";
				continue;
			}

			foreach ($noti as $key => $value) {
				if (!in_array($value['id'], $noti_history)){
					array_push($noti_history, $value['id']); //历史
					$value['uid']=$user_id;
					$value['pushtoken']=$pushtoken;
					array_push($noti_ready_to_send, $value); //推送
				}
				
			}
			echo substr($user_id,0,2)."**** OK <br> ";
		}else{
			$enable=false;
			if($reset_noti_sent==false){
				array_push($noti_ready_to_send, array('title'=>'您的登录已过期，请打开SakaiAPP刷新',
								'siteTitle'=>"SakaiAPP",
      							"event"=> "krunk.sakai.expire",
								"fromDisplayName"=>'SakaiAPP',
								'uid'=>$username,
								'pushtoken'=>$pushtoken));
				$reset_noti_sent=true;
				echo "sent ";
			}
			echo substr($username,0,2)."**** Expire <br> ";
		}

		$update = array(
			'noti'	=> $noti_history,
			'enable' => $enable,
			'reset_noti_sent' => $reset_noti_sent
		);
		$db->update('users',$update,$key1);

		//发送通知 ifttt
		foreach ($noti_ready_to_send as $key => $value) {
			$url = $endpoint;
			if ($endpoint!=""){
				$myvars = 'value1=' . $value['title'] . '&value2=' . $value['siteTitle']. '&value3=' . $value['fromDisplayName']." ".$value['uid'];

				$ch = curl_init( $url );
				curl_setopt( $ch, CURLOPT_POST, 1);
				curl_setopt( $ch, CURLOPT_POSTFIELDS, $myvars);
				curl_setopt( $ch, CURLOPT_FOLLOWLOCATION, 1);
				curl_setopt( $ch, CURLOPT_HEADER, 0);
				curl_setopt( $ch, CURLOPT_RETURNTRANSFER, 1);

				$response = curl_exec( $ch );
			}
		}

		//apple推送 需要 $noti_ready_to_send
		include('applePush.php');
	}
}

?>