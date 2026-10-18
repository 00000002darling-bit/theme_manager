"""主题模块 — 登录主题管理器

后台(登录后)可自由管理登录主题:
- 主题列表 + 缩略图, 点击进入编辑(主题参数: 姓名/二维码内容/配音/照片等)
- 启用主题 / 保存编辑 / 重置(恢复该主题的初始默认参数) / 恢复原版
- 内置「原版登录」兜底主题, 任何主题都可切回
- 主题包: modules/theme_manager/themes/<id>/theme.json + 模板/成品 + 资源
"""

from __future__ import annotations

import json
import os
import shutil

from aiohttp import web

from core.base.logger import EXTENSION, get_logger
from core.plugin.web_pages import register_page, register_route, unregister_page, unregister_route

__module_meta__ = {
    'name': '主题模块',
    'description': '登录主题管理: 多主题启用/编辑/重置/恢复（内置原版兜底）',
    'version': '1.0.0',
    'author': 'ElainaBot',
}

log = get_logger(EXTENSION, '主题模块')

PREFIX = '/api/ext/theme'
PAGE_KEY = 'theme-manager'

_MOD_DIR = os.path.dirname(os.path.abspath(__file__))
_PROJECT = os.path.dirname(os.path.dirname(_MOD_DIR))
_WEB_ASSETS = os.path.join(_PROJECT, 'web', 'dist', 'assets')
_THEMES_DIR = os.path.join(_MOD_DIR, 'themes')
_STATE_FILE = os.path.join(_MOD_DIR, 'data', 'themes_state.json')

DST_LOGIN = os.path.join(_WEB_ASSETS, 'Login.js')
DST_THEME = os.path.join(_WEB_ASSETS, 'dsh550c')


# ==================== 主题包 ====================

def _load_themes() -> dict:
    out = {}
    if not os.path.isdir(_THEMES_DIR):
        return out
    for name in sorted(os.listdir(_THEMES_DIR)):
        tdir = os.path.join(_THEMES_DIR, name)
        if not os.path.isdir(tdir):
            continue
        cfg_path = os.path.join(tdir, 'theme.json')
        if not os.path.isfile(cfg_path):
            continue
        try:
            with open(cfg_path, encoding='utf-8') as f:
                cfg = json.load(f)
        except Exception as e:
            log.warning('主题 %s 配置读取失败: %s', name, e)
            continue
        cfg['id'] = cfg.get('id') or name
        cfg['dir'] = tdir
        out[cfg['id']] = cfg
    # 按主题 order 排序(默认 999, 相同按 id), 保证列表稳定(原版->550C->DeepSeek)
    ordered = sorted(out.values(), key=lambda p: (p.get('order', 999), p['id']))
    return {p['id']: p for p in ordered}


def _default_params(pkg: dict) -> dict:
    return {p['key']: p.get('default', '') for p in pkg.get('params', [])}


# ==================== 状态 ====================

def _state() -> dict:
    try:
        with open(_STATE_FILE, encoding='utf-8') as f:
            d = json.load(f)
        return {'active': d.get('active', ''), 'params': d.get('params', {})}
    except Exception:
        return {'active': '', 'params': {}}


def _save_state(state: dict) -> None:
    os.makedirs(os.path.dirname(_STATE_FILE), exist_ok=True)
    with open(_STATE_FILE, 'w', encoding='utf-8') as f:
        json.dump(state, f, ensure_ascii=False, indent=2)


def _effective_params(theme_id: str, pkg: dict) -> dict:
    st = _state()
    saved = st['params'].get(theme_id, {}) or {}
    merged = dict(_default_params(pkg))
    merged.update({k: v for k, v in saved.items() if k in merged})
    return merged


# ==================== 渲染 / 部署 ====================

def _deploy_theme(theme_id: str, pkg: dict, params: dict) -> None:
    if not os.path.isdir(_WEB_ASSETS):
        raise RuntimeError('web/dist/assets 不存在: %s' % _WEB_ASSETS)
    rel = pkg.get('template') or pkg.get('login')
    if not rel:
        raise RuntimeError('主题 %s 缺少 template/login 定义' % theme_id)
    src = os.path.join(pkg['dir'], rel)
    if not os.path.isfile(src):
        raise RuntimeError('主题 %s 源文件缺失: %s' % (theme_id, rel))
    if pkg.get('template'):
        with open(src, encoding='utf-8') as f:
            tpl = f.read()
        if '__THEME_PARAMS_JSON__' not in tpl:
            raise RuntimeError('主题 %s 模板缺少 __THEME_PARAMS_JSON__ 占位' % theme_id)
        out = tpl.replace('__THEME_PARAMS_JSON__',
                          json.dumps(params, ensure_ascii=False))
        with open(DST_LOGIN, 'w', encoding='utf-8') as f:
            f.write(out)
    else:
        shutil.copy2(src, DST_LOGIN)

    rel_assets = pkg.get('assets_dir')
    if rel_assets:
        src_assets = os.path.join(pkg['dir'], rel_assets)
        if os.path.isdir(src_assets):
            # 目标目录与源资产目录同名(按主题独立, 多主题资源不互踩)
            dst_assets = os.path.join(_WEB_ASSETS, os.path.basename(rel_assets))
            if os.path.isdir(dst_assets):
                shutil.rmtree(dst_assets, ignore_errors=True)
            shutil.copytree(src_assets, dst_assets)


def _apply(theme_id: str) -> None:
    themes = _load_themes()
    pkg = themes.get(theme_id)
    if not pkg:
        raise ValueError('主题不存在: %s' % theme_id)
    params = _effective_params(theme_id, pkg)
    _deploy_theme(theme_id, pkg, params)
    st = _state()
    st['active'] = theme_id
    _save_state(st)
    log.info('已应用登录主题: %s (%s)', pkg.get('name'), theme_id)


# ==================== Web API ====================

async def _list(request: web.Request):
    themes = _load_themes()
    st = _state()
    out = []
    for tid, pkg in themes.items():
        out.append({
            'id': tid,
            'name': pkg.get('name', tid),
            'description': pkg.get('description', ''),
            'builtin': bool(pkg.get('builtin')),
            'has_thumbnail': bool(pkg.get('thumbnail')),
            'params_def': pkg.get('params', []),
            'params': _effective_params(tid, pkg),
        })
    return web.json_response({'success': True, 'active': st.get('active', ''), 'themes': out})


async def _save(request: web.Request):
    try:
        body = await request.json()
    except Exception:
        body = {}
    theme_id = str(body.get('id', ''))
    incoming = body.get('params', {}) or {}
    themes = _load_themes()
    if theme_id not in themes:
        return web.json_response({'success': False, 'message': '主题不存在'}, status=404)
    allowed = {p['key'] for p in themes[theme_id].get('params', [])}
    cleaned = {k: v for k, v in incoming.items() if k in allowed}
    st = _state()
    st.setdefault('params', {})[theme_id] = cleaned
    _save_state(st)
    return web.json_response({'success': True, 'params': _effective_params(theme_id, themes[theme_id])})


async def _reset(request: web.Request):
    try:
        body = await request.json()
    except Exception:
        body = {}
    theme_id = str(body.get('id', ''))
    themes = _load_themes()
    pkg = themes.get(theme_id)
    if not pkg:
        return web.json_response({'success': False, 'message': '主题不存在'}, status=404)
    st = _state()
    st.setdefault('params', {}).pop(theme_id, None)
    _save_state(st)
    return web.json_response({'success': True, 'params': _default_params(pkg),
                              'message': '已重置为该主题的初始默认参数'})


async def _apply_api(request: web.Request):
    try:
        body = await request.json()
    except Exception:
        body = {}
    theme_id = str(body.get('id', ''))
    try:
        _apply(theme_id)
    except Exception as e:
        log.exception('应用主题失败')
        return web.json_response({'success': False, 'message': str(e)}, status=500)
    return web.json_response({'success': True, 'active': theme_id})


async def _thumbnail(request: web.Request):
    tail = request.match_info.get('tail', '') or ''
    theme_id = tail[len('theme/thumb/'):] if tail.startswith('theme/thumb/') else ''
    themes = _load_themes()
    pkg = themes.get(theme_id)
    if not pkg or not pkg.get('thumbnail'):
        return web.Response(text='Not Found', status=404)
    path = os.path.join(pkg['dir'], pkg['thumbnail'])
    if not os.path.isfile(path):
        return web.Response(text='Not Found', status=404)
    return web.FileResponse(path)


# ==================== 生命周期 ====================

async def setup(ctx) -> None:
    register_page(
        key=PAGE_KEY,
        label='主题模块',
        source='module',
        source_name='主题模块',
        html_file=os.path.join(_MOD_DIR, 'web', 'panel.html'),
    )
    register_route('GET', f'{PREFIX}/list', _list)
    register_route('POST', f'{PREFIX}/save', _save)
    register_route('POST', f'{PREFIX}/reset', _reset)
    register_route('POST', f'{PREFIX}/apply', _apply_api)
    register_route('GET', f'{PREFIX}/thumb/*', _thumbnail)
    log.info('主题模块已启用, 当前激活主题: %s', _state().get('active') or '(未设置)')


async def teardown() -> None:
    try:
        st = _state()
        if st.get('active') and st['active'] != 'default':
            themes = _load_themes()
            if themes.get('default'):
                _apply('default')
                log.info('主题模块禁用: 已恢复原版登录')
    except Exception:
        log.exception('teardown 恢复原版失败')
    unregister_page(PAGE_KEY)
    for method, path in (
        ('GET', f'{PREFIX}/list'),
        ('POST', f'{PREFIX}/save'),
        ('POST', f'{PREFIX}/reset'),
        ('POST', f'{PREFIX}/apply'),
        ('GET', f'{PREFIX}/thumb/*'),
    ):
        unregister_route(method, path)
