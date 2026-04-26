# ClipNest — 你的 MacOS 智能剪切板伙伴

![Platform](https://img.shields.io/badge/platform-macOS%2012.0+-orange)
![License](https://img.shields.io/badge/license-MIT-green)
![Made with Vibe Coding](https://img.shields.io/badge/made%20with-Vibe%20Coding-purple)

> 一个生活在菜单栏里的剪切板历史管家。  
> 自动记录你复制的一切，快捷键瞬间调取，像 Windows 一样顺手 —— 但更 Mac 味。

<p align="center">
  <img src="https://i.meee.com.tw/ZaqHMiZ.gif" alt="ClipNest 演示" width="600"/>
</p>

## 为什么又造一个剪切板工具？

因为大部分 macOS 剪切板工具要么太复杂，要么要收费，要么不够“原生”。  
而这次，我想用 **Vibe Coding** 的方式，把“写一个理想中的小工具”变成一次有趣的探索 —— **让 AI 当我的结对编程搭档，我口述需求，它生成代码，边聊边迭代，把这个工具从想法变成现实。**

如果你也在学习如何与 AI 高效协作开发，这个项目或许能给你一些启发。

---

## 🎯 核心功能

- **⚡️ 全局快捷键** — 默认 `Option + V`，随时呼出剪切板历史，像 Spotlight 一样快
- **📋 自动保存历史** — 静默记录文本、图片，重启不掉不丢
- **🧩 点击即粘贴** — 单击历史条目自动粘贴到当前光标位置，无需再 `Cmd+V`
- **⌨️ 纯键盘操作** — 上下键选择，回车粘贴，Esc 消失，高效不打断
- **🔢 可配置条数** — 默认 100 条，可在 20~500 之间调整
- **🔒 数据 100% 本地** — 所有剪切板内容仅存于你的 Mac，绝不联网
- **🌙 明暗模式自适应** — 跟随系统外观，无缝融入 macOS

---

## 🎬 快速预览

### UI界面

![UI界面](https://img.erpweb.eu.org/imgs/2026/04/94a6ffe3ba54db8b.png)

### 设置界面

![设置界面](https://img.erpweb.eu.org/imgs/2026/04/e6355e9ef67d7d4b.png)

---

## 💡 关于 Vibe Coding 与这个项目

**ClipNest 不是一行行手写的，而是“聊”出来的。**

整个开发过程遵循 **Vibe Coding** 理念：我负责描述产品形态、交互细节和边界情况，AI 助手（Claude Code）负责生成代码、排查错误、优化逻辑。我们就像真正的一对编程搭档，只不过我的搭档是 AI。

这个过程让我深刻体会到：

- **需求表达远比语法重要** —— 能把“想要什么”说清楚，AI 就能实现出 80%
- **迭代式对话** —— 先搭骨架，再补细节，逐步打磨

如果你对「如何用 AI 开发一个完整的 MacOS 应用」感兴趣，欢迎翻阅提交历史和代码结构，它记录了我们对话的每一步进化。

---

## 📦 安装

### 手动安装（推荐）
1. 从 [Releases](https://github.com/CodeChenYi/ClipNest/releases) 页面下载最新的 `.dmg` 压缩包
2. 后将 `ClipNest.app` 拖入 `Applications` 文件夹
3. 首次打开时，右键点击应用并选择「打开」以绕过公证（本项目未签名）

### 自行编译
```bash
git clone https://github.com/yourname/ClipNest.git
cd ClipNest
open ClipNest.xcodeproj
# 选择 Product > Archive 或直接 Run
