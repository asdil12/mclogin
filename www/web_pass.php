<a href="/">Back</a>
<h3>Change Password</h3>
<?php

include('functions.php');

if(@$_POST['username']) {
	$uarray = get_user($_POST['username']);
	if($uarray and $uarray['pass'] == md5($_POST['password'])) {
		$uarray['pass'] = md5($_POST['newpassword']);
		if(del_user($_POST['username']) and add_user($uarray))
			echo "Password changed.";
		else
			echo "Error changing password.";
	}
	else
		echo "Username or password wrong.";
}

?>
<br /><br />
<form method="post">
Username: <input type="text" name="username" /><br />
Old Password: <input type="password" name="password" /><br />
New Password: <input type="password" name="newpassword" /><br />
<input type="submit" value="change password" />
</form>
