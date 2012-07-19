<script type="text/javascript">
	function checkpass(pf) {
		if(pf.newpassword.value == pf.repnewpassword.value) {
			return true;
		}
		else {
			alert("passwords do not match");
			return false;
		}
	}
</script>
<a href="/">Back</a>
<h3>Change Password</h3>
<?php

include('functions.php');

if(@$_POST['username']) {
	$uarray = get_user($_POST['username']);
	if($uarray and $uarray['pass'] == md5($_POST['password'])) {
		if($_POST['newpassword'] == $_POST['repnewpassword'])  {
			$uarray['pass'] = md5($_POST['newpassword']);
			if(del_user($_POST['username']) and add_user($uarray))
				echo "Password changed.";
			else
				echo "Error changing password.";
		}
		else
			echo "Passwords do not match.";
	}
	else
		echo "Username or password wrong.";
}

?>
<br /><br />
<form method="post" onsubmit="return checkpass(this);">
	<table border="0">
		<tr>
			<td>Username:</td>
			<td><input type="text" name="username" /></td>
		</tr>
		<tr>
			<td>Old Password:</td>
			<td><input type="password" name="password" /></td>
		</tr>
		<tr>
			<td>New Password:</td>
			<td><input type="password" name="newpassword" /></td>
		</tr>
		<tr>
			<td>Repeat Pass:</td>
			<td><input type="password" name="repnewpassword" /></td>
		</tr>
		<tr>
			<td colspan="2"><input type="submit" value="change password" /></td>
		</tr>
	</table>
</form>
