# 小豆豆的游戏广场

一个本地游戏合集 + 统一入口页。所有游戏都是独立单文件 HTML，双击就能玩，不依赖服务器。

## 目录结构

| 路径 | 说明 |
| --- | --- |
| `index.html` | 入口页（游戏广场）：卡片式游戏墙，点击进游戏、随时返回广场 |
| `xiaodou.html` | 小豆闯关记 · 横版闯关（10 关） |
| `pvz.html` | 植物大战僵尸 · 塔防策略 |
| `stickman.html` | 火柴人勇闯恶魔岛 · 动作格斗（5 关，自动锁敌 + Z X C V 四技能） |
| `assets/covers/` | 各游戏封面，由自动截图脚本生成 |
| `docs/` | 游戏设计文档（单文件 HTML，入口 `docs/index.html`） |
| `tools/make-covers.ps1` | 封面批量截图脚本（调用本机 Chrome / Edge 无头模式） |
| `tools/make-covers.cmd` | 双击运行的入口（已带执行策略绕过） |

## 打开

双击 `index.html`。游戏在页面内的全屏舞台打开，顶栏常驻「返回广场」。

## 在线试玩

GitHub Pages 已上线整个广场，根路径就是入口页：

<https://huayizhe.github.io/xiaodoudou-game-playground/>

各游戏有独立地址，可直接打开或分享：

| 游戏 | 在线地址 |
| --- | --- |
| 小豆闯关记 | <https://huayizhe.github.io/xiaodoudou-game-playground/xiaodou.html> |
| 植物大战僵尸 | <https://huayizhe.github.io/xiaodoudou-game-playground/pvz.html> |
| 火柴人勇闯恶魔岛 | <https://huayizhe.github.io/xiaodoudou-game-playground/stickman.html> |

根路径的 `index.html` 就是广场页本体，改完直接提交推送即可，不需要复制副本。

## 文档

双击 `docs/index.html` 进入文档入口，再点开对应游戏。每份文档都是单文件 HTML，带左侧目录、深浅色切换，离线可看。

| 文档 | 对应游戏 |
| --- | --- |
| `docs/游戏设计文档-小豆闯关记.html` | 小豆闯关记（玩法、手感参数、十关数据、调参影响） |
| `docs/游戏设计文档-植物大战僵尸.html` | 植物大战僵尸（阳光经济、单位数值、波次公式、十关曲线） |
| `docs/游戏设计文档-火柴人勇闯恶魔岛.html` | 火柴人勇闯恶魔岛（自动锁敌口径、四技能数值、敌人 AI、波次与性能取舍） |

三款成品游戏均已有设计文档；新增或调整数值后，记得同步更新对应页面。

## 新增一款游戏

1. 把新的 `xxx.html` 放到项目根目录。
2. 在 `tools/make-covers.ps1` 的 `$Games` 名单里加一行：`File` 文件名、`Slug` 封面名、`Crop` 可选裁剪区域。
3. 双击 `tools\make-covers.cmd` 生成封面到 `assets/covers/`。
4. 在广场页复制一张卡片，改 `data-file`、`data-title`、`data-cat`、封面 `src` 和文案即可。

## 版本管理约定

- 提交前先看 `git status`、`git diff`，确认改的是想改的内容。
- **没做完的游戏照常提交**，提交信息前缀写 `WIP:`，完成后再补一次正常提交，历史里能看清哪一版还没收尾。
- 一版收尾后打标签，方便回退：`git tag v1.0`。
- 封面图属于产物，一起入库；临时截图（`_*.png`、`_pwtest/*.png`）已加入 `.gitignore`。
