/*!
 * DeepSeek 视频片头登录主题 — 模板版
 * 主题模块渲染时把 __THEME_PARAMS_JSON__ 烘焙为本主题参数。
 * 视频片段来自 dsh-boot-animation (NativeDog1), MIT。
 */
import{r as h,o as E,b as x,aO as R,aP as U,az as k,aH as M,aI as a}from"./vendor.js";
import{u as _auth}from"./index.js";

/* ===== 主题参数(缺省用内置默认) ===== */
const THEME = (typeof __THEME_PARAMS_JSON__ !== "undefined") ? __THEME_PARAMS_JSON__ : {};
function _p(key, dflt) {
  var v = THEME[key];
  return (v !== undefined && v !== null && v !== "") ? v : dflt;
}
const VIDEO  = _p('video', 'startup');            // startup | brand | cyberpunk | awakening
const LOOP   = _p('loop', 'false') === 'true';    // 是否循环
const MUTED  = _p('muted', 'true') !== 'false';   // 是否静音(移动端自动播放要求静音)
const VIDEO_URL = '/web/assets/dshtheme/videos/deepseek-' + VIDEO + '-intro.mp4';

const CSS = `
.dsv-root{position:fixed;inset:0;z-index:9999;background:#000;overflow:hidden;font-family:"SF Mono",Menlo,Monaco,Consolas,"Courier New",monospace;touch-action:manipulation;-webkit-tap-highlight-color:transparent}
.dsv-root *{box-sizing:border-box;margin:0;padding:0}
.dsv-video{position:fixed;inset:0;width:100%;height:100%;object-fit:cover;background:#000;cursor:pointer}
.dsv-veil{position:fixed;inset:0;z-index:2;pointer-events:none;background:radial-gradient(ellipse at center,transparent 55%,rgba(0,0,0,.75) 100%)}
.dsv-hint{position:fixed;left:0;right:0;bottom:18px;z-index:3;text-align:center;font-size:11px;letter-spacing:.25em;color:rgba(255,255,255,.55);text-transform:uppercase;pointer-events:none}
.dsv-screen{position:fixed;inset:0;z-index:5;display:none;align-items:center;justify-content:center;background:rgba(4,7,16,.82);backdrop-filter:blur(6px)}
.dsv-root[data-state="login"] .dsv-screen{display:flex}
.dsv-shell{width:min(400px,88vw);background:rgba(10,14,26,.92);border:1px solid rgba(77,107,254,.55);box-shadow:0 0 0 1px rgba(0,0,0,.6),0 0 40px rgba(77,107,254,.18);padding:26px 26px 18px;position:relative}
.dsv-logo{font-size:15px;letter-spacing:.26em;color:#4d6bfe;font-weight:700;text-transform:uppercase}
.dsv-sub{margin-top:6px;font-size:11px;color:rgba(214,220,236,.55);letter-spacing:.06em;line-height:1.7}
.dsv-shell form{margin-top:20px}
.dsv-pwd{width:100%;background:#0a0f1e;border:1px solid rgba(77,107,254,.4);color:#e6ebf8;font-family:inherit;font-size:14px;letter-spacing:.18em;padding:10px 12px;outline:none;caret-color:#4d6bfe}
.dsv-pwd:focus{border-color:#4d6bfe;box-shadow:0 0 0 1px rgba(77,107,254,.35)}
.dsv-pwd::placeholder{color:rgba(160,172,200,.4);letter-spacing:.22em}
.dsv-btn{margin-top:14px;width:100%;background:transparent;border:1px solid #4d6bfe;color:#7d94ff;font-family:inherit;font-size:13px;letter-spacing:.3em;padding:11px 0;cursor:pointer;text-transform:uppercase;transition:background .18s}
.dsv-btn:hover:not(:disabled){background:rgba(77,107,254,.14)}
.dsv-btn:disabled{opacity:.5;cursor:wait}
.dsv-msg{margin-top:12px;font-size:11px;letter-spacing:.04em;min-height:16px;color:#ff7a70}
.dsv-msg.ok{color:#6ee7b7}
.dsv-foot{margin-top:16px;text-align:center;font-size:10px;letter-spacing:.14em;color:rgba(160,172,200,.4);text-transform:uppercase}
@media (max-width:700px){.dsv-video{object-fit:contain}}
`;

const _component = {
  __name: "Login",
  setup() {
    const router = R();
    const route = U();
    const authStore = _auth();
    let videoEl = null, screen = null, pwdEl = null, msgEl = null, btnEl = null, styleEl = null;
    let done = false;

    function showLogin() {
      if (done) return;
      done = true;
      if (videoEl) { try { videoEl.pause(); } catch (e) {} }
      var root = document.querySelector(".dsv-root");
      if (root) root.setAttribute("data-state", "login");
      setTimeout(function () { try { pwdEl && pwdEl.focus(); } catch (e) {} }, 80);
    }

    function onSubmit(e) {
      e.preventDefault();
      if (!pwdEl.value) return;
      msgEl.textContent = ""; msgEl.className = "dsv-msg";
      btnEl.disabled = true; btnEl.textContent = "验证中 …";
      authStore.login(pwdEl.value).then(function () {
        msgEl.className = "dsv-msg ok";
        msgEl.textContent = "已登录 · 正在进入面板 …";
        btnEl.textContent = "已登录";
        setTimeout(function () {
          var target = route.query.redirect || "/";
          try {
            var pr = router.push(target);
            if (pr && pr.catch) pr.catch(function () { window.location.href = "/web/"; });
          } catch (err) { window.location.href = "/web/"; }
        }, 500);
      }).catch(function (err) {
        btnEl.disabled = false; btnEl.textContent = "登 录";
        msgEl.className = "dsv-msg";
        msgEl.textContent = "✕ " + ((err && err.message) || "登录失败");
        pwdEl.value = "";
        try { pwdEl.focus(); } catch (e) {}
      });
    }

    function onKey(e) {
      if (e.key === "Escape" && !document.querySelector(".dsv-root[data-state=\"login\"]")) showLogin();
    }

    function buildDOM(host) {
      styleEl = document.createElement("style");
      styleEl.id = "dsv-style";
      styleEl.textContent = CSS;
      document.head.appendChild(styleEl);

      videoEl = document.createElement("video");
      videoEl.className = "dsv-video";
      videoEl.src = VIDEO_URL;
      videoEl.autoplay = true;
      videoEl.muted = MUTED;
      videoEl.loop = LOOP;
      videoEl.playsInline = true;
      videoEl.setAttribute("playsinline", "");
      videoEl.setAttribute("webkit-playsinline", "");
      videoEl.setAttribute("preload", "auto");
      videoEl.addEventListener("ended", function () { if (!LOOP) showLogin(); });
      videoEl.addEventListener("click", function (e) { if (e.target === videoEl) showLogin(); });
      videoEl.addEventListener("error", function () { setTimeout(showLogin, 400); });
      host.appendChild(videoEl);

      var veil = document.createElement("div");
      veil.className = "dsv-veil";
      host.appendChild(veil);
      var hint = document.createElement("div");
      hint.className = "dsv-hint";
      hint.textContent = LOOP ? "— 轻点屏幕进入登录 —" : "— 轻点屏幕可跳过 —";
      host.appendChild(hint);

      screen = document.createElement("div");
      screen.className = "dsv-screen";
      screen.innerHTML =
        '<div class="dsv-shell">' +
          '<div class="dsv-logo">DeepSeek</div>' +
          '<div class="dsv-sub">DEEPSEEK BOOT · 请输入管理口令进入面板</div>' +
          '<form id="dsvForm" autocomplete="off">' +
            '<input class="dsv-pwd" id="dsvPwd" type="password" placeholder="口令 / PASSWORD" autocomplete="current-password">' +
            '<button class="dsv-btn" id="dsvBtn" type="submit">登 录</button>' +
          '</form>' +
          '<div class="dsv-msg" id="dsvMsg"></div>' +
          '<div class="dsv-foot">ELAINABOT · DEEPSEEK BOOT</div>' +
        '</div>';
      host.appendChild(screen);
      document.addEventListener("keydown", onKey);
      document.getElementById("dsvForm").addEventListener("submit", onSubmit);
      pwdEl = document.getElementById("dsvPwd");
      msgEl = document.getElementById("dsvMsg");
      btnEl = document.getElementById("dsvBtn");

      /* 纯自动播放: 按参数尝试有声, 浏览器拦截有声自动播时自动退回静音重试(全程无按钮) */
      videoEl.muted = !MUTED;
      var p0 = videoEl.play();
      if (p0 && p0.catch) p0.catch(function () {
        if (!videoEl.muted) {
          videoEl.muted = true;
          var p1 = videoEl.play();
          if (p1 && p1.catch) p1.catch(function () { /* 仍被拦: 静待用户触碰视频 */ });
        }
      });
    }

    E(function () {
      var host = document.querySelector(".dsv-root");
      if (!host) return;
      try {
        if (authStore && authStore.isLoggedIn) { router.replace(route.query.redirect || "/"); return; }
      } catch (e) {}
      buildDOM(host);
    });
    x(function () {
      if (styleEl) styleEl.remove();
      document.removeEventListener("keydown", onKey);
    });

    return function (s, e) { return (k(), M("div", { class: "dsv-root" })); };
  }
};
export default _component;
