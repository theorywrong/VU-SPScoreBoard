var show = false;

function showScoreboard() {
	if (show == true) {
		show = false;
		document.getElementById("show").style.display = 'none';
	} else {
		show = true;
		document.getElementById("show").style.display = 'block';
	}
}

function updateScoreboard(json_data) {
	var data = JSON.parse(json_data);

	content = '';

	data.forEach(function(score){
		content += '<tr>';
		content += '<td>' + score['username'] + '</td>';
		content += '<td>' + score['score'] + '</td>';
		content += '</tr">';
	});

	document.getElementById("content").innerHTML = content;
}

function showMessage(title, message) {
	window.notificationService.notify({
		// title
		title: title,

		// notification message
		text: message,

		// 'success', 'warning', 'error'
		type: 'success',

		// 'top-right', 'bottom-right', 'top-left', 'bottom-left'
		position: 'top-right',

		// auto close
		autoClose: true,

		// 4 seconds
		duration: 4000,

		// shows close button
		showRemoveButton: false
	});
}