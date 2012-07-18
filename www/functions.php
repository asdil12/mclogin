<?php

function sanitize($string) {
	$string = str_replace('|', '', $string);
	$string = str_replace("\n", '', $string);
	$string = preg_replace("/[^a-zA-Z0-9]/", '', $string);
	return $string;
}

function parse_user($userline) {
	$userline = str_replace("\n", '', $userline);
	$uarray = explode('|', $userline);
	return array(
		'name' => @$uarray[0],
		'pass' => @$uarray[1],
		'token' => @$uarray[2],
		'keepalive' => @$uarray[3],
		'server' => @$uarray[4]
	);
}

function comp_user($uarray) {
	$suarray = array(
		sanitize(@$uarray['name']),
		sanitize(@$uarray['pass']),
		sanitize(@$uarray['token']),
		sanitize(@$uarray['keepalive']),
		sanitize(@$uarray['server'])
	);
	return implode('|', $suarray);
}

function get_user($username) {
	$username = sanitize($username);
	if($username) {
		$fp = fopen('../userdb.txt', 'r');
		while(!feof($fp)) {
			$line = fgets($fp);
			$user = parse_user($line);
			if($user['name'] == $username) {
				fclose($fp);
				return $user;
			}
		}
		fclose($fp);
	}
	return false;
}

function add_user($uarray) {
	if(sanitize(@$uarray['name'])) {
		$userline = comp_user($uarray);
		$fp = fopen('../userdb.txt', 'a');
		fwrite($fp, $userline."\n");
		fclose($fp);
		return true;
	}
	else
		return false;
}

function del_user($username) {
	$username = sanitize($username);
	if($username) {
		$content = file_get_contents('../userdb.txt');
		$content = preg_replace('/^'.$username.'\|.*\n/m', '', $content);
		$fp = fopen('../userdb.txt', 'w');
		fwrite($fp, "$content");
		fclose($fp);
		return true;
	}
	else
		return false;
}

?>
