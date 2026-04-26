# ClipNest

> A smart clipboard history manager for macOS — built with AI Vibe Coding

![Platform](https://img.shields.io/badge/platform-macOS%2012.0+-orange)![License](https://img.shields.io/badge/license-MIT-green)

## 项目简介

ClipNest 是一款专为 macOS 设计的菜单栏剪切板历史管理工具。它能够自动监控并保存您的剪切板内容，让您随时查看和复用之前的复制记录。

### 核心功能

- **全局快捷键** — 按 `Option + V` 随时呼出剪切板历史
- **历史记录** — 自动保存文本和图片，支持永久历史
- **键盘导航** — 上下键选择条目，回车键快速粘贴
- **数据持久化** — 重启后自动恢复历史记录
- **隐私安全** — 所有数据仅本地存储，不上传网络

## AI Vibe Coding

本项目采用 **AI Vibe Coding** 方式开发 — 利用 AI 助手辅助编程，边对话边开发，快速迭代功能。这种方式让开发者可以专注于产品构思，而将具体实现交给 AI，最终实现「说出需求，立刻可用」的高效开发体验。

## 系统要求

- macOS 12.0 或更高版本
- 支持 Apple Silicon 和 Intel 芯片

## 安装



## 权限说明

ClipNest 需要以下权限才能正常工作：

### 辅助功能权限（必需）

**用途**：实现全局快捷键和自动粘贴功能

**授权方式**：
1. 首次启动引导界面会提示授权
2. 或前往 **系统设置 → 隐私与安全性 → 辅助功能** 手动添加 ClipNest

> 注意：如果重新编译项目并使用新的 ad-hoc 签名，需要重新授予权限。这是因为 macOS 的辅助功能权限基于代码签名，不同签名被视为不同应用。

### 屏幕录制权限（自动粘贴功能需要）

**用途**：用于 CGEvent 模拟键盘输入实现自动粘贴

**授权方式**：
1. **系统设置 → 隐私与安全性 → 屏幕录制** 中添加 ClipNest
2. 或者当弹出提示时选择允许

## 使用方法

### 基本操作

1. **呼出剪切板历史** — 按 `Option + V`
2. **选择条目** — 使用上下箭头键导航
3. **粘贴内容** — 按回车键快速粘贴到当前光标位置
4. **关闭弹窗** — 按 `Escape` 或点击其他地方

### 删除条目

- **鼠标悬停** 在条目上时显示删除按钮，点击删除
- **右键点击** 条目选择"删除"

### 设置

点击菜单栏图标 → **设置**，可以：
- 自定义全局快捷键
- 调整最大保存条数（20-500条）
- 清空历史记录

## 技术架构

- **语言**：Swift 5.9
- **UI 框架**：SwiftUI
- **快捷键**：HotKey SPM
- **数据存储**：JSON 本地文件
- **键盘拦截**：CGEvent Tap

## 项目结构

```
ClipNest/
├── Sources/ClipNest/
│   ├── App/
│   │   └── AppDelegate.swift       # 应用入口、菜单栏管理
│   ├── Models/
│   │   ├── ClipboardItem.swift    # 剪切板数据模型
│   │   └── AppSettings.swift       # 应用设置模型
│   ├── Services/
│   │   ├── StorageService.swift    # JSON 存储服务
│   │   ├── ClipboardManager.swift  # 剪切板监控服务
│   │   ├── HotkeyManager.swift     # 快捷键管理
│   │   ├── KeyboardInterceptor.swift # 键盘事件拦截
│   │   ├── AccessibilityManager.swift # 辅助功能权限管理
│   │   └── ClipboardPopoverState.swift # 弹窗状态共享
│   └── Views/
│       ├── ClipboardPopoverView.swift # 剪切板历史列表
│       ├── SettingsView.swift      # 设置窗口
│       └── OnboardingView.swift    # 首次引导界面
└── Resources/
    └── Assets.xcassets/           # 应用图标资源
```
