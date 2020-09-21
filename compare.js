function init(){
	var t = location.href.replace(/.*\?/, "");
	document.getElementById("t").innerHTML += " - " + t;
	var r = new XMLHttpRequest();
	r.onreadystatechange = function() {
		if (this.readyState == 4 && this.status == 200) {
			onData(JSON.parse(this.responseText));
		}
	};
	var url = t + ".json";
	r.open("GET", url, true);
	r.send();
}
/**
* @param {JSON} j
*/
function onData(j){
	alert(1);
}
