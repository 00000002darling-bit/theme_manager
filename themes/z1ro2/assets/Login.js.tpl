/*!
 * Z1ro2 霓虹开屏登录主题 — 模板版
 * 动画: DSH Neon Splash v3 (wsy304450907-boop), 播完进入登录。
 */
import{r as h,o as E,b as x,aO as R,aP as U,az as k,aH as M,aI as a}from"./vendor.js";
import{u as _auth}from"./index.js";

const THEME = (typeof __THEME_PARAMS_JSON__ !== "undefined") ? __THEME_PARAMS_JSON__ : {};
function _p(key, dflt) { var v = THEME[key]; return (v !== undefined && v !== null && v !== "") ? v : dflt; }

const BOOT_URL = '/web/assets/z1ro2/boot.html';

const CSS = `
.z2-root{position:fixed;inset:0;z-index:9999;background:#000;overflow:hidden;font-family:"SF Mono",Menlo,Monaco,Consolas,"Courier New",monospace;touch-action:manipulation;-webkit-tap-highlight-color:transparent}
.z2-root *{box-sizing:border-box;margin:0;padding:0}
.z2-frame{position:fixed;inset:0;width:100%;height:100%;border:0;background:#000}
.z2-skip{position:fixed;inset:0;z-index:2;display:block;cursor:pointer;touch-action:manipulation;-webkit-tap-highlight-color:transparent}
.z2-hint{position:fixed;left:0;right:0;bottom:20px;z-index:4;text-align:center;font-size:11px;letter-spacing:.22em;color:rgba(255,61,132,.65);text-transform:uppercase;pointer-events:none}
.z2-screen{position:fixed;inset:0;z-index:6;display:none;align-items:center;justify-content:center;background:rgba(8,6,10,.6);backdrop-filter:blur(4px)}
.z2-root[data-state="login"] .z2-screen{display:flex}
.z2-shell{width:min(400px,88vw);background:rgba(14,10,16,.94);border:1px solid rgba(255,61,132,.55);box-shadow:0 0 0 1px rgba(0,0,0,.6),0 0 40px rgba(255,61,132,.18);padding:26px 26px 18px}
.z2-logo{font-size:15px;letter-spacing:.26em;color:#ff3d84;font-weight:700;text-transform:uppercase}
.z2-sub{margin-top:6px;font-size:11px;color:rgba(214,196,208,.55);letter-spacing:.06em;line-height:1.7}
.z2-shell form{margin-top:20px}
.z2-pwd{width:100%;background:#0d0810;border:1px solid rgba(255,61,132,.4);color:#f2dfe8;font-family:inherit;font-size:14px;letter-spacing:.18em;padding:10px 12px;outline:none;caret-color:#ff3d84}
.z2-pwd:focus{border-color:#ff3d84;box-shadow:0 0 0 1px rgba(255,61,132,.35)}
.z2-pwd::placeholder{color:rgba(200,160,180,.4);letter-spacing:.22em}
.z2-btn{margin-top:14px;width:100%;background:transparent;border:1px solid #ff3d84;color:#ff6ba8;font-family:inherit;font-size:13px;letter-spacing:.3em;padding:11px 0;cursor:pointer;text-transform:uppercase;transition:background .18s}
.z2-btn:hover:not(:disabled){background:rgba(255,61,132,.14)}
.z2-btn:disabled{opacity:.5;cursor:wait}
.z2-msg{margin-top:12px;font-size:11px;letter-spacing:.04em;min-height:16px;color:#ff7a70}
.z2-msg.ok{color:#6ee7b7}
.z2-foot{margin-top:16px;text-align:center;font-size:10px;letter-spacing:.14em;color:rgba(200,160,180,.4);text-transform:uppercase}
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
      var root = document.querySelector(".z2-root");
      if (root) root.setAttribute("data-state", "login");
      setTimeout(function () { try { pwdEl && pwdEl.focus(); } catch (e) {} }, 80);
    }

    function onSubmit(e) {
      e.preventDefault();
      if (!pwdEl.value) return;
      msgEl.textContent = ""; msgEl.className = "z2-msg";
      btnEl.disabled = true; btnEl.textContent = "验证中 …";
      authStore.login(pwdEl.value).then(function () {
        msgEl.className = "z2-msg ok";
        msgEl.textContent = "已登录 · 正在进入面板 …";
        btnEl.textContent = "已登录";
        setTimeout(function () {
          var target = route.query.redirect || "/";
          try { var pr = router.push(target); if (pr && pr.catch) pr.catch(function () { window.location.href = "/web/"; }); }
          catch (err) { window.location.href = "/web/"; }
        }, 500);
      }).catch(function (err) {
        btnEl.disabled = false; btnEl.textContent = "登 录";
        msgEl.className = "z2-msg";
        msgEl.textContent = "✕ " + ((err && err.message) || "登录失败");
        pwdEl.value = "";
        try { pwdEl.focus(); } catch (e) {}
      });
    }

    function onMessage(ev) {
      if (ev.data === "z1ro2-done" && ev.source === frame && frame.contentWindow) showLogin();
    }

    function buildDOM(host) {
      styleEl = document.createElement("style");
      styleEl.id = "z2-style";
      styleEl.textContent = CSS;
      document.head.appendChild(styleEl);

      frame = document.createElement("iframe");
      frame.className = "z2-frame";
      frame.src = BOOT_URL;
      frame.setAttribute("title", "Z1ro2 Splash");
      host.appendChild(frame);

      var skip = document.createElement("div");
      skip.className = "z2-skip";
      var _tapT = 0, _tapX = 0, _tapY = 0;
      skip.addEventListener("pointerup", function (e) {
        var now = Date.now(), dx = (e.clientX || 0) - _tapX, dy = (e.clientY || 0) - _tapY, dt = now - _tapT;
        _tapT = now; _tapX = e.clientX || 0; _tapY = e.clientY || 0;
        if (dt > 0 && dt < 400 && Math.abs(dx) < 80 && Math.abs(dy) < 80) showLogin();
      });
      host.appendChild(skip);

      var hint = document.createElement("div");
      hint.className = "z2-hint";
      hint.textContent = "— 双击跳过 —";
      host.appendChild(hint);
      document.addEventListener("keydown", function (e) { if (e.key === "Escape") showLogin(); });

      var screen = document.createElement("div");
      screen.className = "z2-screen";
      screen.innerHTML =
        '<div class="z2-shell">' +
          '<div class="z2-logo">Z1ro2</div>' +
          '<div class="z2-sub">NEON SPLASH · 请输入管理口令进入面板</div>' +
          '<form id="z2Form" autocomplete="off">' +
            '<input class="z2-pwd" id="z2Pwd" type="password" placeholder="口令 / PASSWORD" autocomplete="current-password">' +
            '<button class="z2-btn" id="z2Btn" type="submit">登 录</button>' +
          '</form>' +
          '<div class="z2-msg" id="z2Msg"></div>' +
          '<div class="z2-foot">ELAINABOT · Z1RO2</div>' +
        '</div>';
      host.appendChild(screen);

      document.getElementById("z2Form").addEventListener("submit", onSubmit);
      pwdEl = document.getElementById("z2Pwd");
      msgEl = document.getElementById("z2Msg");
      btnEl = document.getElementById("z2Btn");
    }

    E(function () {
      var host = document.querySelector(".z2-root");
      if (!host) return;
      try {
        if (authStore && authStore.isLoggedIn) { router.replace(route.query.redirect || "/"); return; }
      } catch (e) {}
      buildDOM(host);
      window.addEventListener("message", onMessage);
      setTimeout(function () { if (!done) showLogin(); }, 25000);
    });
    x(function () {
      if (styleEl) styleEl.remove();
      window.removeEventListener("message", onMessage);
    });

    return function (s, e) { return (k(), M("div", { class: "z2-root" })); };
  }
};
export default _component;
