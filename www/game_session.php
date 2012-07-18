<?php

include('functions.php');

$user = $_GET['name'];
$token = $_GET['session'];

$uarray = get_user($user);
if($uarray and $uarray['token'] == $token and ($uarray['keepalive'] + 600) >= time()) {
	$uarray['keepalive'] = time();
	if(del_user($user) and add_user($uarray))
		echo "--";
	else
		echo "ERROR"; // inofficial
}
else {
	// timeout
	echo "--";
}

?>
