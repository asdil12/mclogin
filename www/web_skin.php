<html>
	<head>
		<script src="minecraft_skin.js" type="text/javascript"></script>
		<script type="text/javascript">
			var lastuser = '';
			function display_skin(username) {
				if(!username) { username = 'default';  }
				if(username  == lastuser) { return true; }
				lastuser = username;
				document.getElementById('view').src = '/MinecraftSkins/' + username + '.png';
				//draw_hat('player_hat', username, 15);
				//draw_head('player_head', username, 15);
				draw_model('player_model', 'player_scratch', username, 6, true);
				draw_model_back('player_model_back', 'player_scratch_back', username, 6, true);
			}
			var loadskin = 'default';
			window.onload = function() {
				display_skin(loadskin);
			}
		</script>
		<style type="text/css">
			.minecraft_head .head {
			    display:none;
			}
			.minecraft_head:hover .hat {
			    display:none;
			}
			.minecraft_head:hover .head {
			    display:inline-block;
			}
			.scratch {
			    display:none;
			}
		</style>
	</head>
	<body>
		<a href="/">Back</a>
		<h3>Change Skin</h3>
		<?php

		include('functions.php');

		if(@$_POST['username']) {
			$uarray = get_user($_POST['username']);
			if($uarray and $uarray['pass'] == md5($_POST['password'])) {
				if($_FILES['skin']) {
					list($width, $height, $type, $attr) = getimagesize($_FILES['skin']['tmp_name']);
					if($width == 64 and $height == 32) {
						if(copy($_FILES['skin']['tmp_name'], 'MinecraftSkins/'.$uarray['name'].'.png')) {
							echo "Skin changed.";
							echo "<script type='text/javascript'>loadskin = '" . $uarray['name'] . "';</script>";
						}
						else
							echo "Error changing skin.";
					}
					else
						echo "Wrong image size - need 64x32px.";
				}
				else
					echo "No file found.";
			}
			else
				echo "Username or password wrong.";
		}

		?>
		<br /><br />
		<form method="post" enctype="multipart/form-data">
			<table border="0">
				<tr>
					<td>Username:</td>
					<td>
						<input type="text" name="username" id="username" onkeyup="display_skin(this.value);" />
						<button type='button' onclick="lastuser=''; display_skin(document.getElementById('username').value);">&#10227;</button>
					</td>
				</tr>
				<tr>
					<td>Password:</td>
					<td><input type="password" name="password" /></td>
				</tr>
				<tr>
					<td>New Skin:</td>
					<td><input type="file" name="skin" /></td>
				</tr>
				<tr>
					<td colspan="2"><input type="submit" value="change skin" /></td>
				</tr>
			</table>
		</form>
		<br />
		<div style="position: relative; width: 384px; height: 192px; border: 1px solid black;">
			<img width="384" height="192" id="view" src="data:image/gif;base64,R0lGODlhAQABAIAAAP///wAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw==" style="position: absolute; left: 0; top: 0; z-index: 3; opacity: 0;" />
			<img width="384" height="192" src="skinoverlay.png" style="position: absolute; left: 0; top: 0; z-index: 2;" />
			<canvas id="player_scratch" style="position: absolute; left: 0; top: 0; z-index: 1;"></canvas>
		</div>
		<h4>Preview</h4>

		<noscript>Enable JavaScript to avoid failing!<br /></noscript>
		<!--
		<div class="minecraft_head" id="head">
		    <canvas class="hat" id="player_hat"></canvas><canvas class="head" id="player_head"></canvas>
		    <script type="text/javascript">
			draw_hat('player_hat','default',15);
			draw_head('player_head','default',15);
		    </script>
		</div>
		-->

		<div class="minecraft_model" id="model" style="float: left; margin-right: 2em;">
		    <canvas class="model" id="player_model"></canvas>
		</div>
		<div class="minecraft_model" id="model_back">
		    <canvas class="scratch" id="player_scratch_back"></canvas><canvas class="model" id="player_model_back"></canvas>
		</div>
	</body>
</html>
