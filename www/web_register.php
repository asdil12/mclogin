<a href="/">Back</a>
<h3>Add Account</h3>
<?php

include('functions.php');

if(@$_POST['username']) {
	$uarray = array(
		'name' => $_POST['username'],
		'pass' => md5($_POST['password']),
	);
	if(!get_user($_POST['username'])) {
		if(add_user($uarray))
			echo "User added.";
		else
			echo "Error adding user.";
	}
	else
		echo "Username already taken.";
}

?>
<br /><br />
Valid characters in username: a-z, A-Z, 0-9<br />
<form method="post">
Username: <input type="text" name="username" /><br />
Password: <input type="password" name="password" /><br />
<input type="submit" value="create account" />
</form>
