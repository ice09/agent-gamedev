/* Kleine Helfer – die Seite funktioniert auch komplett ohne JavaScript. */
(function () {
  "use strict";

  // 1. Kopieren-Buttons für alle Codeblöcke
  var status = document.getElementById("copy-status");
  document.querySelectorAll("pre[data-copy]").forEach(function (pre) {
    var btn = document.createElement("button");
    btn.type = "button";
    btn.className = "copy-btn";
    btn.textContent = "Kopieren";
    btn.setAttribute("aria-label", "Befehl in die Zwischenablage kopieren");
    btn.addEventListener("click", function () {
      var text = pre.innerText.replace(/Kopieren\s*$/, "").trim();
      function done(ok) {
        btn.textContent = ok ? "Kopiert!" : "Fehler";
        if (status) status.textContent = ok ? "Befehl kopiert." : "Kopieren nicht möglich.";
        setTimeout(function () { btn.textContent = "Kopieren"; }, 1600);
      }
      if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(text).then(function () { done(true); }, function () { done(false); });
      } else {
        var ta = document.createElement("textarea");
        ta.value = text;
        document.body.appendChild(ta);
        ta.select();
        try { done(document.execCommand("copy")); } catch (e) { done(false); }
        document.body.removeChild(ta);
      }
    });
    pre.appendChild(btn);
  });

  // 2. Checkliste mit Fortschritt (wird lokal im Browser gespeichert)
  var KEY = "signal-infestation-checklist-v1";
  var boxes = Array.prototype.slice.call(document.querySelectorAll(".checklist input[type=checkbox]"));
  var progress = document.getElementById("checklist-progress");
  function render() {
    var done = boxes.filter(function (b) { return b.checked; }).length;
    boxes.forEach(function (b) {
      b.closest("li").classList.toggle("done", b.checked);
    });
    if (progress) progress.innerHTML = "<strong>" + done + " von " + boxes.length + "</strong> Schritten erledigt";
    try {
      var state = {};
      boxes.forEach(function (b, i) { state[i] = b.checked; });
      localStorage.setItem(KEY, JSON.stringify(state));
    } catch (e) { /* privater Modus etc. – egal */ }
  }
  try {
    var saved = JSON.parse(localStorage.getItem(KEY) || "{}");
    boxes.forEach(function (b, i) { b.checked = !!saved[i]; });
  } catch (e) { /* egal */ }
  boxes.forEach(function (b) { b.addEventListener("change", render); });
  render();

  // 3. Aktiven Menüpunkt beim Scrollen markieren
  var links = Array.prototype.slice.call(document.querySelectorAll(".main-nav a[href^='#']"));
  var sections = links
    .map(function (a) { return document.querySelector(a.getAttribute("href")); })
    .filter(Boolean);
  if ("IntersectionObserver" in window && sections.length) {
    var obs = new IntersectionObserver(function (entries) {
      entries.forEach(function (en) {
        if (en.isIntersecting) {
          links.forEach(function (a) {
            var on = a.getAttribute("href") === "#" + en.target.id;
            if (on) { a.setAttribute("aria-current", "true"); }
            else { a.removeAttribute("aria-current"); }
          });
        }
      });
    }, { rootMargin: "-40% 0px -55% 0px" });
    sections.forEach(function (s) { obs.observe(s); });
  }
})();
