<?php

require __DIR__ . '/vendor/autoload.php';

use Pushok\AuthProvider;
use Pushok\Client;
use Pushok\Notification;
use Pushok\Payload;
use Pushok\Payload\Alert;

$options = [
	'key_id' => '', // The Key ID obtained from Apple developer account
	'team_id' => '', // The Team ID obtained from Apple developer account
	'app_bundle_id' => '', // The bundle ID for app obtained from Apple developer account
	'private_key_path' => __DIR__ . '/kdb/AuthKey.p8', // Path to private key
	'private_key_secret' => null // Private key secret
];

//发送通知
foreach ($noti_ready_to_send as $key => $value) {

	if ($value['event']=="asn.grade.submission"){
		$type="作业出分";
	}else if ($value['event']=="asn.new.assignment"){
		$type="新作业公布";
	}else if ($value['event']=="krunk.sakai.expire"){
		$type="Token 过期";
	}else if ($value['event']=="annc.new"){
		$type="新通知";
	}else if ($value['event']=="annc.revise.availability"){
		$type="新通知(已修改)";
	}else{
		$type=$value['event'];
	}

	$msg = $type."\n标题: ".$value['title']."\n来自: " . $value['fromDisplayName'];

	$authProvider = AuthProvider\Token::create($options);

	$alert = Alert::create()->setTitle($value['siteTitle']); //标题
	$alert = $alert->setBody($msg); //内容

	$payload = Payload::create()->setAlert($alert);
	$payload->setSound('default'); //set notification sound to default
	$payload->setCustomValue('key', 'value'); //add custom value to your notification, needs to be customized

	$deviceTokens = $value['pushtoken']; //获取发送目标

	$notifications = [];
	foreach ($deviceTokens as $deviceToken) {
	    $notifications[] = new Notification($payload,$deviceToken);
	}

	$client = new Client($authProvider, $production = true);
	$client->addNotifications($notifications);
	$responses = $client->push(); // returns an array of ApnsResponseInterface (one Response per Notification)

	//返回的信息
	// foreach ($responses as $response) {
	//     $response->getApnsId();
	//     $response->getStatusCode();
	//     $response->getReasonPhrase();
	//     $response->getErrorReason();
	//     $response->getErrorDescription();
	// }

}

?>