// eslint-disable-next-line no-unused-vars
function init(){
	var t = location.href.replace(/.*\?/, "").replace(/#.*/, "");
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
	var d = document;
	{
		let tr = d.getElementById("h");
		for (let h in j[0]) {
			let th = d.createElement("th");
			th.append(d.createTextNode(h));
			tr.append(th);
		}
	}
	var b = d.getElementById("b");
	for (let i in j) {
		let ok = true;
		let tr = d.createElement("tr");
		for (let h in j[0]) {
			if (! j[i][h]) {
				ok = false;
			}	
			let td = d.createElement("td");
			td.append(d.createTextNode(j[i][h]));
			tr.append(td);
		}
		if (ok) {
			b.append(tr);
		}
	}
	var thead = d.getElementsByTagName('thead')[0];
	addSort(thead);
	addFilter(thead);
}

/**
* @param {Element} t thead
*/
function addFilter(t) {
	//TODO
}

/**
* @param {Element} t thead
*/
function addSort(t) {
	var h = t.rows[0];
	var i;
	for (i = 0; i < h.cells.length; i++) {
		h.cells[i].innerHTML = h.cells[i].innerHTML + " <a href=\"#\" onclick=\"return sortTable(this, " + i + ", true);\">↑</a> <a href=\"#\" onclick=\"return sortTable(this, " + i + ", false);\">↓</a>";
	}
}

/**
* @param {Element} a
* @param {Number} col
* @param {Boolean} asc
*/
// eslint-disable-next-line no-unused-vars
function sortTable(a, col, asc) {
	var tbody = a.parentElement.parentElement.parentElement.parentElement;
	tbody = tbody.getElementsByTagName('tbody')[0];
	var i, shouldSwitch;
	var switching = true;
	while (switching) {
		switching = false;
		let rows = tbody.rows;
		for (i = 0; i < (rows.length - 1); i++) {
			shouldSwitch = false;
			let x = rows[i].getElementsByTagName("td")[col].innerHTML.toLowerCase();
			let y = rows[i + 1].getElementsByTagName("td")[col].innerHTML.toLowerCase();
			if (x.match("^[0-9.]+$") && y.match("^[0-9.]+$")) {
				x = parseFloat(x);
				y = parseFloat(y);
			}
			if (asc) {
				if (x > y) {
					shouldSwitch = true;
					break;
				}
			} else {
				if (x < y) {
					shouldSwitch = true;
					break;
				}
			}
		}
		if (shouldSwitch) {
			rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
			switching = true;
		}
	}
	return false;
}
