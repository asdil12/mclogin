<?php

include('functions.php');

$user = $_GET['user'];
$serverid = $_GET['serverId'];

$uarray = get_user($user);
if($uarray and $uarray['server'] == sanitize($serverid) and ($uarray['keepalive'] + 600) >= time())
	echo "YES";
else
	echo "NO";

?>
