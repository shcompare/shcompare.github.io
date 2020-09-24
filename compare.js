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
	addSheet(j);
	addPivot(j);
}

/**
* @param {JSON} j
*/
function addSheet(j) {
	var d = document;
	{
		let tr = d.getElementById("h");
		for (let h in j.data[0]) {
			let th = d.createElement("th");
			th.append(d.createTextNode(h));
			tr.append(th);
		}
	}
	var b = d.getElementById("b");
	for (let i in j.data) {
		let ok = true;
		let tr = d.createElement("tr");
		for (let h in j.data[0]) {
			if (! j.data[i][h]) {
				ok = false;
			}	
			let td = d.createElement("td");
			td.append(d.createTextNode(j.data[i][h]));
			tr.append(td);
		}
		if (ok) {
			b.append(tr);
		}
	}
	var thead = d.getElementsByTagName('thead')[1];
	addSort(thead);
	addFilter(thead);
}

/**
* @param {JSON} j
*/
function addPivot(j) {
	if (!j.pivot) {
		return;
	}
	var d = document;
	j.pivot.titles = [] ;
	{
		let tr = d.getElementById("hp");
		for (let h in j.data[0]) {
			if (j.pivot.title == h || j.pivot.diff == h) {
				continue;
			}
			let th = d.createElement("th");
			th.append(d.createTextNode(h));
			tr.append(th);
		}
		for (let i in j.data) {
			let t = j.data[i][j.pivot.title];
			if (j.pivot.titles.includes(t)) {
				continue;
			}
			if (!t) {
				continue;
			}
			j.pivot.titles.push(t);
			let th = d.createElement("th");
			th.append(d.createTextNode(t));
			tr.append(th);
		}
	}
	j.pivot.diffs = {} ;
	for (let i in j.data) {
		let m = [];
		for (let h in j.data[0]) {
			if (j.pivot.title == h || j.pivot.diff == h) {
				continue;
			}
			let v = j.data[i][h];
			if (typeof v == "number") {
				v = ("" + v);
			}
			if (!v) {
				continue;
			}
			m.push(v);
		}
		if (m.length < 1) {
			continue;
		}
		let ms = JSON.stringify(m);
		if (!j.pivot.diffs[ms]) {
			j.pivot.diffs[ms] = {};
		}
		j.pivot.diffs[ms][j.data[i][j.pivot.title]] = j.data[i][j.pivot.diff];
	}
	var b = d.getElementById("bp");
	for (let m in j.pivot.diffs) {
		let tr = d.createElement("tr");
		let me = JSON.parse(m);
		for (let i in me) {
			let td = d.createElement("td");
			td.append(d.createTextNode(me[i]));
			tr.append(td);
		}
		for (let i in j.pivot.titles) {
			let td = d.createElement("td");
			let v = j.pivot.diffs[m][j.pivot.titles[i]];
			if (!v) {
				v = "";
			}
			td.append(d.createTextNode(v));
			tr.append(td);
		}
		b.append(tr);
	}
	var thead = d.getElementsByTagName('thead')[0];
	addSort(thead);
	addFilter(thead);
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
*/ // eslint-disable-next-line no-unused-vars
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

/**
* @param {Element} t thead
*/
function addFilter(t) {
	//TODO
}
