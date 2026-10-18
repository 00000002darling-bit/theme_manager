# Theme Manager 模块

登录主题管理模块。启用后可在 Web 后台自由切换、编辑、重置登录主题，内置「原版登录」兜底主题，任何主题都能一键切回。

## 功能

- 主题列表 + 缩略图，点击进入编辑
- 启用主题：把主题部署到 `web/dist/assets/Login.js`（及主题资源目录）
- 保存编辑：按主题独立保存参数（姓名、二维码内容、配音、照片等）
- 重置：恢复该主题的初始默认参数
- 恢复原版：切回框架出厂登录页
- 模块禁用时自动恢复原版登录

## 目录结构

```
theme_manager/
├── main.py              # 模块入口，声明 __module_meta__
├── README.md
├── web/
│   └── panel.html       # Web 管理面板
├── data/
│   └── themes_state.json  # 当前激活主题与各主题参数
└── themes/
    └── <theme_id>/
        ├── theme.json     # 主题配置
        ├── thumbnail.png  # 缩略图（可选）
        └── assets/        # 模板、脚本、音视频等资源
```

## 内置主题

| id | 名称 | 参数 |
| --- | --- | --- |
| `default` | 原版登录 | 无（兜底主题） |
| `ueg550c` | 550C · UEG 授权 | `name`、`qr`、`voice`、`photo` |
| `deepseek_video` | DeepSeek 视频片头 | `video`、`loop`、`muted` |
| `violet` | Violet 紫罗兰开机 | `seal` |
| `z1ro2` | Z1ro2 霓虹开屏 | 无 |
| `mo_startup` | MO 红警开机 | `faction`、`commander` |
| `boot_suite` | 六幕冷启动 | `identity` |

主题按 `order` 升序排列，`order` 相同时按 `id` 排序。

## theme.json 字段

| 字段 | 必填 | 说明 |
| --- | --- | --- |
| `id` | 否 | 主题 id，缺省取目录名 |
| `name` | 是 | 显示名称 |
| `description` | 否 | 描述 |
| `order` | 否 | 排序，默认 `999` |
| `builtin` | 否 | 是否内置主题标记 |
| `thumbnail` | 否 | 缩略图相对路径 |
| `template` | 二选一 | 带 `__THEME_PARAMS_JSON__` 占位的模板文件，参数会注入该占位 |
| `login` | 二选一 | 直接复制的成品 `Login.js`，无参数注入 |
| `assets_dir` | 否 | 主题资源目录，部署时整目录复制到 `web/dist/assets/` |
| `params` | 否 | 参数定义数组 |

### params 参数定义

```json
{
  "key": "name",
  "label": "操作员姓名",
  "type": "text",
  "default": "刘培强",
  "hint": "显示在身份卡上的姓名"
}
```

- `key`：参数名，保存时只接受 `params` 中声明的 key
- `label`：面板显示名
- `type`：`text` / `select` / `image` 等
- `options`：`select` 类型的候选项，元素为 `{"value": ..., "label": ...}`
- `default`：初始默认值
- `hint`：输入提示

## 安装

1. 在插件市场安装本模块，或把本仓库放入 `modules/theme_manager/`
2. 在框架中启用模块
3. 进入 Web 后台的「主题模块」页面管理主题

模块依赖框架的 `aiohttp` 与 `core.plugin.web_pages`，无需额外 pip 依赖。

## Web API

统一前缀 `/api/ext/theme`。

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| `GET` | `/list` | 主题列表、当前激活主题、各主题生效参数 |
| `POST` | `/save` | 保存指定主题参数，body `{"id": ..., "params": {...}}` |
| `POST` | `/reset` | 重置指定主题参数为默认值，body `{"id": ...}` |
| `POST` | `/apply` | 应用指定主题，body `{"id": ...}` |
| `GET` | `/thumb/*` | 主题缩略图，路径为 `theme/thumb/<theme_id>` |

所有接口返回 `{"success": bool, ...}`，失败时附带 `message`。

## 部署行为

应用主题时：

1. 读取主题配置与参数（默认值 + 已保存值合并）
2. 若声明 `template`，用参数 JSON 替换模板中的 `__THEME_PARAMS_JSON__` 后写入 `web/dist/assets/Login.js`
3. 若声明 `login`，直接复制到 `web/dist/assets/Login.js`
4. 若声明 `assets_dir`，先清空同名目标目录，再整目录复制到 `web/dist/assets/<assets_dir 目录名>`
5. 记录当前激活主题到 `data/themes_state.json`

`web/dist/assets` 不存在时应用会报错，请确认框架前端已构建。

## 添加自定义主题

1. 新建 `themes/<theme_id>/` 目录
2. 编写 `theme.json`，声明 `name`、`template` 或 `login`、`params` 等字段
3. 把模板、脚本、音视频等资源放入该目录（建议集中在 `assets/` 下）
4. 可选：放一张 `thumbnail.png` 并写入 `thumbnail` 字段
5. 重启模块或重新加载后即可在面板看到新主题

模板文件中必须包含 `__THEME_PARAMS_JSON__` 占位符，否则应用时报错。

## 说明

- 主题文件替换的是框架前端已构建产物，框架重新构建前端后需重新应用主题
- 参数只保存在 `data/themes_state.json`，升级模块时请保留该文件
- 各主题资源目录相互独立，切换主题不会互相覆盖
