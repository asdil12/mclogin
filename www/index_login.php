<?php

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

echo "1:deprecated:$user:$token";
# version:deprecated:user:token

?>
