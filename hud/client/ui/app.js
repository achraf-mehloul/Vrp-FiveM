// تحديث القيم
function updateBar(id, value) {
  const bar = document.getElementById(id);
  if (bar) bar.style.width = value + "%";
}

// مثال تحديث القيم (يمكن ربطها مع الأحداث الحقيقية)
setInterval(() => {
  updateBar("health-bar", Math.floor(Math.random() * 100));
  updateBar("armor-bar", Math.floor(Math.random() * 100));
  updateBar("hunger-bar", Math.floor(Math.random() * 100));
  updateBar("thirst-bar", Math.floor(Math.random() * 100));
}, 3000);

// إعدادات HUD
const settingsPanel = document.getElementById("hud-settings");
const openSettings = document.getElementById("open-settings");
const closeSettings = document.getElementById("close-settings");

openSettings.addEventListener("click", () => {
  settingsPanel.classList.remove("hidden");
});

closeSettings.addEventListener("click", () => {
  settingsPanel.classList.add("hidden");
});

// التبديل بين العناصر
document.getElementById("toggle-health").addEventListener("change", (e) => {
  document.querySelector(".health").style.display = e.target.checked ? "flex" : "none";
});
document.getElementById("toggle-armor").addEventListener("change", (e) => {
  document.querySelector(".armor").style.display = e.target.checked ? "flex" : "none";
});
document.getElementById("toggle-hunger").addEventListener("change", (e) => {
  document.querySelector(".hunger").style.display = e.target.checked ? "flex" : "none";
});
document.getElementById("toggle-thirst").addEventListener("change", (e) => {
  document.querySelector(".thirst").style.display = e.target.checked ? "flex" : "none";
});
