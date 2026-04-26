# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

ClipNest 是 macOS 菜单栏剪切板历史管理工具，使用 SwiftUI 开发，支持全局快捷键、键盘导航和自动粘贴。

## 常用命令

### 构建
```bash
xcodebuild -project ClipNest.xcodeproj -scheme ClipNest -configuration Release build
```

### 打包 DMG
```bash
create-dmg --volname "ClipNest" --window-pos 200 200 --window-size 600 400 --icon-size 100 --icon "ClipNest.app" 250 150 --app-drop-link 150 150 --hide-extension "ClipNest.app" ClipNest-v1.0.0.dmg /path/to/ClipNest.app
```

### XcodeGen 重新生成项目
```bash
xcodegen generate
```

## 架构

### 核心服务
- **ClipboardManager** - 监控 NSPasteboard，检测新内容，去重，持久化
- **HotkeyManager** - 使用 HotKey SPM 注册全局快捷键（默认 Option+V）
- **KeyboardInterceptor** - CGEvent Tap 拦截键盘事件，实现弹窗内的纯键盘操作
- **AccessibilityManager** - 管理辅助功能权限状态，发布 `isAuthorized` 变化通知

### 状态共享
- **ClipboardPopoverState** - ObservableObject，共享弹窗显示状态和键盘处理逻辑
- 弹窗每次打开/关闭时安装/卸载 KeyboardInterceptor

### UI 层级
AppDelegate → 菜单栏 NSStatusItem → NSPopover → ClipboardPopoverView (SwiftUI)

### 权限要求
- 辅助功能权限（快捷键和自动粘贴必需）
- 屏幕录制权限（CGEvent 模拟粘贴必需）
- 权限基于代码签名工作，重新编译后需重新授权

## 快捷键流程

1. HotkeyManager 检测 Option+V
2. AppDelegate.showClipboard() 切换弹窗显示
3. KeyboardInterceptor 在弹窗显示时拦截上下键/回车
4. ClipboardPopoverState 处理按键，回车触发 CGEvent 模拟 Cmd+V
