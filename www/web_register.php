<script type="text/javascript">
	function checkpass(pf) {
		if(pf.password.value == pf.reppassword.value) {
			return true;
		}
		else {
			alert("passwords do not match");
			return false;
		}
	}
</script>
<a href="/">Back</a>
<h3>Add Account</h3>
<?php

include('functions.php');

if(@$_POST['username']) {
	$uarray = array(
		'name' => $_POST['username'],
		'pass' => md5($_POST['password']),
	);
	if($_POST['password'] == $_POST['reppassword']) {
		if(!get_user($_POST['username'])) {
			if(add_user($uarray)) {
				copy('MinecraftSkins/default.png', 'MinecraftSkins/'.sanitize($_POST['username']).'.png');
				echo "User added.";
			}
			else
				echo "Error adding user.";
		}
		else
			echo "Username already taken.";
	}
	else
		echo "Passwords do not match.";
}

?>
<br /><br />
Valid characters in username: a-z, A-Z, 0-9<br />
<form method="post" onsubmit="return checkpass(this);">
	<table border="0">
		<tr>
			<td>Username:</td>
			<td><input type="text" name="username" /></td>
		</tr>
		<tr>
			<td>Password:</td>
			<td><input type="password" name="password" /></td>
		</tr>
		<tr>
			<td>Repeat Pass:</td>
			<td><input type="password" name="reppassword" /></td>
		</tr>
		<tr>
			<td colspan="2"><input type="submit" value="create account" /></td>
		</tr>
	</table>
</form>
