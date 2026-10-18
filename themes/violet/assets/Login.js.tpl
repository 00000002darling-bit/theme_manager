/*!
 * Violet 紫罗兰开机主题 — 模板版(主题模块渲染时烘焙参数)
 * 动画: dsh-violet-boot (Hee105), 画像 base64 内联, 零外部依赖。
 */
import{r as h,o as E,b as x,aO as R,aP as U,az as k,aH as M,aI as a}from"./vendor.js";
import{u as _auth}from"./index.js";

const THEME = (typeof __THEME_PARAMS_JSON__ !== "undefined") ? __THEME_PARAMS_JSON__ : {};
function _p(key, dflt) { var v = THEME[key]; return (v !== undefined && v !== null && v !== "") ? v : dflt; }
const SEAL = _p('seal', 'true') === 'true';
const BOOT_URL = '/web/assets/violet/boot.html?seal=' + (SEAL ? '1' : '0');

const CSS = `
.vlt-root{position:fixed;inset:0;z-index:9999;background:#fff;overflow:hidden;font-family:"SF Mono",Menlo,Monaco,Consolas,"Courier New",monospace;touch-action:manipulation;-webkit-tap-highlight-color:transparent}
.vlt-root *{box-sizing:border-box;margin:0;padding:0}
.vlt-frame{position:fixed;inset:0;width:100%;height:100%;border:0;background:#fff}
.vlt-hint{position:fixed;left:0;right:0;bottom:20px;z-index:4;text-align:center;font-size:11px;letter-spacing:.22em;color:rgba(109,90,168,.6);text-transform:uppercase;pointer-events:none}
.vlt-skip{position:fixed;inset:0;z-index:2;display:block;cursor:pointer;touch-action:manipulation;-webkit-tap-highlight-color:transparent}
.vlt-screen{position:fixed;inset:0;z-index:6;display:none;align-items:center;justify-content:center;background:rgba(255,255,255,.55);backdrop-filter:blur(3px)}
.vlt-root[data-state="login"] .vlt-screen{display:flex}
.vlt-shell{width:min(400px,88vw);background:rgba(255,252,246,.96);border:1px solid rgba(138,120,190,.5);box-shadow:0 10px 44px rgba(120,100,170,.18);padding:28px 28px 20px}
.vlt-logo{font-size:15px;letter-spacing:.28em;color:#6d5aa8;font-weight:700;text-transform:uppercase}
.vlt-sub{margin-top:6px;font-size:11px;color:#8a7ba8;letter-spacing:.08em;line-height:1.7}
.vlt-shell form{margin-top:20px}
.vlt-pwd{width:100%;background:#fff;border:1px solid rgba(138,120,190,.45);color:#3a3450;font-family:inherit;font-size:14px;letter-spacing:.18em;padding:10px 12px;outline:none;caret-color:#6d5aa8}
.vlt-pwd:focus{border-color:#6d5aa8;box-shadow:0 0 0 1px rgba(109,90,168,.3)}
.vlt-pwd::placeholder{color:#b9aed4;letter-spacing:.22em}
.vlt-btn{margin-top:14px;width:100%;background:transparent;border:1px solid #6d5aa8;color:#6d5aa8;font-family:inherit;font-size:13px;letter-spacing:.3em;padding:11px 0;cursor:pointer;text-transform:uppercase;transition:background .18s,color .18s}
.vlt-btn:hover:not(:disabled){background:#6d5aa8;color:#fff}
.vlt-btn:disabled{opacity:.5;cursor:wait}
.vlt-msg{margin-top:12px;font-size:11px;letter-spacing:.04em;min-height:16px;color:#c2544e}
.vlt-msg.ok{color:#5a9e6f}
.vlt-foot{margin-top:16px;text-align:center;font-size:10px;letter-spacing:.16em;color:#b9aed4;text-transform:uppercase}
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
      var root = document.querySelector(".vlt-root");
      if (root) root.setAttribute("data-state", "login");
      setTimeout(function () { try { pwdEl && pwdEl.focus(); } catch (e) {} }, 80);
    }

    function onSubmit(e) {
      e.preventDefault();
      if (!pwdEl.value) return;
      msgEl.textContent = ""; msgEl.className = "vlt-msg";
      btnEl.disabled = true; btnEl.textContent = "验证中 …";
      authStore.login(pwdEl.value).then(function () {
        msgEl.className = "vlt-msg ok";
        msgEl.textContent = "已登录 · 正在进入面板 …";
        btnEl.textContent = "已登录";
        setTimeout(function () {
          var target = route.query.redirect || "/";
          try { var pr = router.push(target); if (pr && pr.catch) pr.catch(function () { window.location.href = "/web/"; }); }
          catch (err) { window.location.href = "/web/"; }
        }, 500);
      }).catch(function (err) {
        btnEl.disabled = false; btnEl.textContent = "登 录";
        msgEl.className = "vlt-msg";
        msgEl.textContent = "✕ " + ((err && err.message) || "登录失败");
        pwdEl.value = "";
        try { pwdEl.focus(); } catch (e) {}
      });
    }

    function onMessage(ev) {
      if (ev.data === "violet-done" && ev.source === frame && frame.contentWindow) showLogin();
    }

    function buildDOM(host) {
      styleEl = document.createElement("style");
      styleEl.id = "vlt-style";
      styleEl.textContent = CSS;
      document.head.appendChild(styleEl);

      frame = document.createElement("iframe");
      frame.className = "vlt-frame";
      frame.src = BOOT_URL;
      frame.setAttribute("title", "Violet Boot");
      host.appendChild(frame);

      /* 双击跳过层(单击不跳, 双击/Esc 进登录) */
      var skip = document.createElement("div");
      skip.className = "vlt-skip";
      var _tapT = 0, _tapX = 0, _tapY = 0;
      skip.addEventListener("pointerup", function (e) {
        var now = Date.now(), dx = (e.clientX || 0) - _tapX, dy = (e.clientY || 0) - _tapY, dt = now - _tapT;
        _tapT = now; _tapX = e.clientX || 0; _tapY = e.clientY || 0;
        if (dt > 0 && dt < 400 && Math.abs(dx) < 80 && Math.abs(dy) < 80) showLogin();
      });
      host.appendChild(skip);
      var hint = document.createElement("div");
      hint.className = "vlt-hint";
      hint.textContent = "— 双击跳过 —";
      host.appendChild(hint);
      document.addEventListener("keydown", function (e) { if (e.key === "Escape") showLogin(); });

      var screen = document.createElement("div");
      screen.className = "vlt-screen";
      screen.innerHTML =
        '<div class="vlt-shell">' +
          '<div class="vlt-logo">Violet</div>' +
          '<div class="vlt-sub">自动手记人偶 · 请输入管理口令进入面板</div>' +
          '<form id="vltForm" autocomplete="off">' +
            '<input class="vlt-pwd" id="vltPwd" type="password" placeholder="口令 / PASSWORD" autocomplete="current-password">' +
            '<button class="vlt-btn" id="vltBtn" type="submit">登 录</button>' +
          '</form>' +
          '<div class="vlt-msg" id="vltMsg"></div>' +
          '<div class="vlt-foot">ELAINABOT · VIOLET</div>' +
        '</div>';
      host.appendChild(screen);

      document.getElementById("vltForm").addEventListener("submit", onSubmit);
      pwdEl = document.getElementById("vltPwd");
      msgEl = document.getElementById("vltMsg");
      btnEl = document.getElementById("vltBtn");
    }

    E(function () {
      var host = document.querySelector(".vlt-root");
      if (!host) return;
      try {
        if (authStore && authStore.isLoggedIn) { router.replace(route.query.redirect || "/"); return; }
      } catch (e) {}
      buildDOM(host);
      window.addEventListener("message", onMessage);
      setTimeout(function () { if (!done) showLogin(); }, 30000);
    });
    x(function () {
      if (styleEl) styleEl.remove();
      window.removeEventListener("message", onMessage);
    });

    return function (s, e) { return (k(), M("div", { class: "vlt-root" })); };
  }
};
export default _component;
