function sortPermissionRequestsTable(n) {
  var table, rows, switching, i, x, y, shouldSwitch, dir, switchcount = 0;
  table = document.getElementById("permission-requests-table");
  if (!table) return;
  switching = true;
  dir = "asc";
  while (switching) {
    switching = false;
    rows = table.rows;
    for (i = 1; i < (rows.length - 1); i++) {
      shouldSwitch = false;
      x = rows[i].getElementsByTagName("TD")[n];
      y = rows[i + 1].getElementsByTagName("TD")[n];
      if (dir == "asc") {
        if (x.innerText.toLowerCase() > y.innerText.toLowerCase()) {
          shouldSwitch = true;
          break;
        } else if (Number(x.innerText) > Number(y.innerText)) {
          shouldSwitch = true;
          break;
        }
      } else if (dir == "desc") {
        if (x.innerText.toLowerCase() < y.innerText.toLowerCase()) {
          shouldSwitch = true;
          break;
        } else if (Number(x.innerText) < Number(y.innerText)) {
          shouldSwitch = true;
          break;
        }
      }
    }
    if (shouldSwitch) {
      rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
      switching = true;
      switchcount++;
    } else {
      if (switchcount == 0 && dir == "asc") {
        dir = "desc";
        switching = true;
      }
    }
  }
}

function sortPermissionRequestsDate(n) {
  var table, rows, switching, i, x, y, shouldSwitch, dir, switchcount = 0;
  table = document.getElementById("permission-requests-table");
  if (!table) return;
  switching = true;
  dir = "asc";
  while (switching) {
    switching = false;
    rows = table.rows;
    for (i = 1; i < (rows.length - 1); i++) {
      shouldSwitch = false;
      x = rows[i].getElementsByTagName("TD")[n];
      y = rows[i + 1].getElementsByTagName("TD")[n];

      const x_arr = x.innerText.toLowerCase().split("/").reverse();
      const y_arr = y.innerText.toLowerCase().split("/").reverse();
      const index = [0, 2, 1];
      const x_output = index.map(i => x_arr[i]);
      const y_output = index.map(i => y_arr[i]);

      if (dir == "asc") {
        if (x_output.join("") > y_output.join("")) {
          shouldSwitch = true;
          break;
        } else if (Number(x_output.join("")) > Number(y_output.join(""))) {
          shouldSwitch = true;
          break;
        }
      } else if (dir == "desc") {
        if (x_output.join("") < y_output.join("")) {
          shouldSwitch = true;
          break;
        } else if (Number(x_output.join("")) < Number(y_output.join(""))) {
          shouldSwitch = true;
          break;
        }
      }
    }
    if (shouldSwitch) {
      rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
      switching = true;
      switchcount++;
    } else {
      if (switchcount == 0 && dir == "asc") {
        dir = "desc";
        switching = true;
      }
    }
  }
}

// Bind clicks on table headers via data attributes (replaces the inline onclick=
// handlers that were blocked by strict CSP).
$(document).on('turbolinks:load', function() {
  const headers = document.querySelectorAll('#permission-requests-table th[data-sort-column]');
  headers.forEach(function(th) {
    th.addEventListener('click', function() {
      const column = Number(th.dataset.sortColumn);
      if (th.dataset.sortType === 'date') {
        sortPermissionRequestsDate(column);
      } else {
        sortPermissionRequestsTable(column);
      }
    });
  });
});
