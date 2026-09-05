// Автоматическая подстановка актуального года в футер
document.getElementById("year").textContent = new Date().getFullYear();

// ------------------------------------------------------------
// Модальное окно «Вход / Регистрация»
// ------------------------------------------------------------
const authOverlay = document.getElementById("auth-overlay");
const tabRegister = document.getElementById("tab-register");
const tabLogin = document.getElementById("tab-login");
const authSubmit = document.getElementById("auth-submit");
const authForm = document.getElementById("auth-form");
const authName = document.getElementById("auth-name");

function setAuthMode(mode) {
  authOverlay.dataset.mode = mode;
  tabRegister.classList.toggle("active", mode === "register");
  tabLogin.classList.toggle("active", mode === "login");
  authSubmit.textContent = mode === "register" ? "Создать аккаунт" : "Войти";
  authName.required = mode === "register";
}

function openAuth(mode) {
  setAuthMode(mode);
  authOverlay.classList.add("open");
  document.body.style.overflow = "hidden";
}

function closeAuth() {
  authOverlay.classList.remove("open");
  document.body.style.overflow = "";
}

document.getElementById("open-register").addEventListener("click", () => openAuth("register"));
document.getElementById("open-login").addEventListener("click", () => openAuth("login"));
document.getElementById("auth-close").addEventListener("click", closeAuth);
tabRegister.addEventListener("click", () => setAuthMode("register"));
tabLogin.addEventListener("click", () => setAuthMode("login"));

// Закрытие по клику на затемненный фон
authOverlay.addEventListener("click", (e) => {
  if (e.target === authOverlay) closeAuth();
});

// Закрытие по клавише Escape
document.addEventListener("keydown", (e) => {
  if (e.key === "Escape") closeAuth();
});

// Отправка формы авторизации
authForm.addEventListener("submit", function (e) {
  e.preventDefault();
  const mode = authOverlay.dataset.mode;
  const email = document.getElementById("auth-email").value;
  const name = authName.value;

  console.log(mode, { name, email });
  alert(mode === "register"
    ? "Аккаунт успешно создан. Он также будет активен в мобильном приложении!"
    : "Вы успешно вошли в аккаунт.");
  this.reset();
  closeAuth();
});

// ------------------------------------------------------------
// Донат: выбор способа оплаты
// ------------------------------------------------------------
document.getElementById("pay-method-btn").addEventListener("click", function () {
  this.classList.toggle("active");
});

document.getElementById("donate-submit").addEventListener("click", function () {
  const amountInput = document.getElementById("donate-amount");
  const amount = amountInput.value || amountInput.placeholder;
  
  if (Number(amount) < 20) {
    alert("Минимальная сумма пожертвования — 20 ₽");
    return;
  }
  
  console.log("Оплата доната:", amount, "RUB");
  alert(`Спасибо за вашу поддержку! Пожертвование на сумму ${amount} ₽ успешно отправлено.`);
});

// ------------------------------------------------------------
// Выпадающее меню скачивания приложения
// ------------------------------------------------------------
const downloadBtn = document.getElementById("download-btn");
const downloadMenu = document.getElementById("download-menu");

downloadBtn.addEventListener("click", (e) => {
  e.stopPropagation();
  downloadMenu.classList.toggle("open");
});

document.addEventListener("click", (e) => {
  if (!downloadMenu.contains(e.target) && e.target !== downloadBtn) {
    downloadMenu.classList.remove("open");
  }
});