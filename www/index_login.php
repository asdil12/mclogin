<?php

include('functions.php');

if(isset($_GET['user'])) {
	$user = $_GET['user'];
	$pass = $_GET['password'];
	$version = $_GET['version'];
}
elseif(isset($_POST['user'])) {
	$user = $_POST['user'];
	$pass = $_POST['password'];
	$version = $_POST['version'];
}
else {
	echo "Bad login";
	exit;
}

$token = substr(base_convert(md5($user.':'.$pass), 16, 10), 0, 20);

$uarray = get_user($user);
if($uarray and $uarray['pass'] == md5($pass)) {
	$uarray['token'] = substr(base_convert(md5( $user.':'.$pass.':'.rand(10000, 100000) ), 16, 10), 0, 20);
	$uarray['keepalive'] = time();
	if(del_user($user) and add_user($uarray)) {
		// version:deprecated:user:token
		$version = str_replace("\n", '', file_get_contents('../version.txt'));
		echo $version.':deprecated:'.$uarray['name'].':'.sanitize($uarray['token']);
	}
	else
		echo "ERROR"; // inofficial
}
else
	echo "Bad login";

?>
