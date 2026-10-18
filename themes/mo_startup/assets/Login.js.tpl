/*!
 * MO 开机画面登录主题 — 模板版(红警2心灵终结风格, 四阵营可切换)
 */
import{r as h,o as E,b as x,aO as R,aP as U,az as k,aH as M,aI as a}from"./vendor.js";
import{u as _auth}from"./index.js";

const THEME = (typeof __THEME_PARAMS_JSON__ !== "undefined") ? __THEME_PARAMS_JSON__ : {};
function _p(key, dflt) { var v = THEME[key]; return (v !== undefined && v !== null && v !== "") ? v : dflt; }
const FACTION = _p('faction', 'allied');
const COMMANDER = _p('commander', '指挥官');
const BOOT_URL = '/web/assets/mo/boot.html?faction=' + FACTION + '&cmd=' + encodeURIComponent(COMMANDER);

const CSS = `
.mo-root{position:fixed;inset:0;z-index:9999;background:#000;overflow:hidden;font-family:"SF Mono",Menlo,Monaco,Consolas,"Courier New",monospace;touch-action:manipulation;-webkit-tap-highlight-color:transparent}
.mo-root *{box-sizing:border-box;margin:0;padding:0}
.mo-frame{position:fixed;inset:0;width:100%;height:100%;border:0;background:#000}
.mo-skip{position:fixed;inset:0;z-index:2;display:block;pointer-events:none;touch-action:manipulation;-webkit-tap-highlight-color:transparent}
.mo-hint{position:fixed;left:0;right:0;bottom:20px;z-index:4;text-align:center;font-size:11px;letter-spacing:.22em;color:rgba(168,200,140,.6);text-transform:uppercase;pointer-events:none}
.mo-screen{position:fixed;inset:0;z-index:6;display:none;align-items:center;justify-content:center;background:rgba(6,10,8,.62);backdrop-filter:blur(4px)}
.mo-root[data-state="login"] .mo-screen{display:flex}
.mo-shell{width:min(400px,88vw);background:rgba(10,16,12,.95);border:1px solid rgba(140,180,120,.55);box-shadow:0 0 0 1px rgba(0,0,0,.6),0 0 40px rgba(120,160,100,.16);padding:26px 26px 18px}
.mo-logo{font-size:15px;letter-spacing:.24em;color:#9ac77e;font-weight:700;text-transform:uppercase}
.mo-sub{margin-top:6px;font-size:11px;color:rgba(190,210,175,.55);letter-spacing:.06em;line-height:1.7}
.mo-shell form{margin-top:20px}
.mo-pwd{width:100%;background:#0a120c;border:1px solid rgba(140,180,120,.4);color:#e4eeda;font-family:inherit;font-size:14px;letter-spacing:.18em;padding:10px 12px;outline:none;caret-color:#9ac77e}
.mo-pwd:focus{border-color:#9ac77e;box-shadow:0 0 0 1px rgba(154,199,126,.35)}
.mo-pwd::placeholder{color:rgba(160,190,140,.4);letter-spacing:.22em}
.mo-btn{margin-top:14px;width:100%;background:transparent;border:1px solid #9ac77e;color:#b5d99a;font-family:inherit;font-size:13px;letter-spacing:.3em;padding:11px 0;cursor:pointer;text-transform:uppercase;transition:background .18s}
.mo-btn:hover:not(:disabled){background:rgba(154,199,126,.14)}
.mo-btn:disabled{opacity:.5;cursor:wait}
.mo-msg{margin-top:12px;font-size:11px;letter-spacing:.04em;min-height:16px;color:#ff7a70}
.mo-msg.ok{color:#6ee7b7}
.mo-foot{margin-top:16px;text-align:center;font-size:10px;letter-spacing:.14em;color:rgba(170,190,150,.4);text-transform:uppercase}
`;

const _component = {
  __name: "Login",
  setup() {
    const router = R();
    const route = U();
    const authStore = _auth();
    let frame = null, pwdEl = null, msgEl = null, btnEl = null, styleEl = null;
    let done = false;

    function showLogin() {
      if (done) return;
      done = true;
      var root = document.querySelector(".mo-root");
      if (root) root.setAttribute("data-state", "login");
      setTimeout(function () { try { pwdEl && pwdEl.focus(); } catch (e) {} }, 80);
    }

    function onSubmit(e) {
      e.preventDefault();
      if (!pwdEl.value) return;
      msgEl.textContent = ""; msgEl.className = "mo-msg";
      btnEl.disabled = true; btnEl.textContent = "验证中 …";
      authStore.login(pwdEl.value).then(function () {
        msgEl.className = "mo-msg ok";
        msgEl.textContent = "已登录 · 正在进入面板 …";
        btnEl.textContent = "已登录";
        setTimeout(function () {
          var target = route.query.redirect || "/";
          try { var pr = router.push(target); if (pr && pr.catch) pr.catch(function () { window.location.href = "/web/"; }); }
          catch (err) { window.location.href = "/web/"; }
        }, 500);
      }).catch(function (err) {
        btnEl.disabled = false; btnEl.textContent = "登 录";
        msgEl.className = "mo-msg";
        msgEl.textContent = "✕ " + ((err && err.message) || "登录失败");
        pwdEl.value = "";
        try { pwdEl.focus(); } catch (e) {}
      });
    }

    function onMessage(ev) {
      if (ev.data === "mo-done" && ev.source === frame && frame.contentWindow) showLogin();
    }

    function buildDOM(host) {
      styleEl = document.createElement("style");
      styleEl.id = "mo-style";
      styleEl.textContent = CSS;
      document.head.appendChild(styleEl);

      frame = document.createElement("iframe");
      frame.className = "mo-frame";
      frame.src = BOOT_URL;
      frame.setAttribute("title", "MO Startup");
      host.appendChild(frame);

      var skip = document.createElement("div");
      skip.className = "mo-skip";
      var _tapT = 0, _tapX = 0, _tapY = 0;
      skip.addEventListener("pointerup", function (e) {
        var now = Date.now(), dx = (e.clientX || 0) - _tapX, dy = (e.clientY || 0) - _tapY, dt = now - _tapT;
        _tapT = now; _tapX = e.clientX || 0; _tapY = e.clientY || 0;
        if (dt > 0 && dt < 400 && Math.abs(dx) < 80 && Math.abs(dy) < 80) showLogin();
      });
      host.appendChild(skip);

      var hint = document.createElement("div");
      hint.className = "mo-hint";
      hint.textContent = "— 双击跳过 —";
      host.appendChild(hint);
      document.addEventListener("keydown", function (e) { if (e.key === "Escape") showLogin(); });

      var screen = document.createElement("div");
      screen.className = "mo-screen";
      screen.innerHTML =
        '<div class="mo-shell">' +
          '<div class="mo-logo">M.O. TERMINAL</div>' +
          '<div class="mo-sub">心灵终结 · 请输入管理口令进入面板</div>' +
          '<form id="moForm" autocomplete="off">' +
            '<input class="mo-pwd" id="moPwd" type="password" placeholder="口令 / PASSWORD" autocomplete="current-password">' +
            '<button class="mo-btn" id="moBtn" type="submit">登 录</button>' +
          '</form>' +
          '<div class="mo-msg" id="moMsg"></div>' +
          '<div class="mo-foot">ELAINABOT · MENTAL OMEGA</div>' +
        '</div>';
      host.appendChild(screen);

      document.getElementById("moForm").addEventListener("submit", onSubmit);
      pwdEl = document.getElementById("moPwd");
      msgEl = document.getElementById("moMsg");
      btnEl = document.getElementById("moBtn");
    }

    E(function () {
      var host = document.querySelector(".mo-root");
      if (!host) return;
      try {
        if (authStore && authStore.isLoggedIn) { router.replace(route.query.redirect || "/"); return; }
      } catch (e) {}
      buildDOM(host);
      window.addEventListener("message", onMessage);
      setTimeout(function () { if (!done) showLogin(); }, 45000);
    });
    x(function () {
      if (styleEl) styleEl.remove();
      window.removeEventListener("message", onMessage);
    });

    return function (s, e) { return (k(), M("div", { class: "mo-root" })); };
  }
};
export default _component;
