<?php

include('functions.php');

$user = $_GET['user'];
$token = $_GET['sessionId'];
$serverid = $_GET['serverId'];

$uarray = get_user($user);
if($uarray and $uarray['token'] == $token and ($uarray['keepalive'] + 600) >= time()) {
	$uarray['server'] = $serverid;
	if(del_user($user) and add_user($uarray))
		echo "OK";
	else
		echo "ERROR"; // inofficial
}
else
	echo "Bad Login";

?>
