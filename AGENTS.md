# AGENTS.md · 小豆豆的游戏广场

本仓库是三款单文件 HTML 小游戏 + 一个入口广场，规则细节见 `README.md` 与 `docs/`。

## 发布：每次改动都要走完

1. `git status` / `git diff` 核对，只 `git add` 本次改过的文件。
2. `git commit`：一次改动一条，说明写清改了什么；未收尾的用 `WIP:` 前缀。
3. `git push origin main`。
4. 等 GitHub Pages 构建（通常 20–60 秒），用线上地址校验新版确实生效后再回报。

- 线上地址：<https://huayizhe.github.io/xiaodoudou-game-playground/>
- 不提交 `.ohmygame/`、`node_modules/`、临时截图（`_*.png`、`_pwtest/*.png`）。
- 推送或构建失败时如实说明错误与进度，不许谎报「已上线」。
