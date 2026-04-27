# ClipNest 开发计划

## 项目概述
ClipNest - macOS 菜单栏剪切板历史管理工具

## 目标
开发一个纯菜单栏应用的剪切板历史管理器，支持全局快捷键、数据持久化、设置管理和首次引导。

## 版本规划
- [x] v0.0.1 - 初始开发版本
- [x] v1.0.0 - 正式版（功能验证完成后）
- [x] v1.1.0 - 追加功能（Esc 隐藏 + 回车置顶 + 鼠标点击置顶修复 + 鼠标点击粘贴失效修复 + 默认50条）
- [x] v1.1.1 - 版本号统一管理

## 阶段

### 阶段 1: 项目初始化 ✅
- [x] 创建项目结构
- [x] 配置 XcodeGen
- [x] 添加 HotKey 依赖
- [x] 生成 Xcode 项目
- [x] 初始化 git 仓库
- [x] 创建 tag v0.0.1

### 阶段 2: 核心功能实现 ✅
- [x] 数据模型 (ClipboardItem, AppSettings)
- [x] 存储服务 (StorageService)
- [x] 剪切板监控 (ClipboardManager)
- [x] 全局快捷键 (HotkeyManager)
- [x] 菜单栏 UI
- [x] 剪切板历史弹出窗口
- [x] 设置窗口
- [x] 首次引导界面

### 阶段 3: 功能测试 ✅
- [x] 运行应用测试剪切板监控
- [x] 测试全局快捷键 Option+V (显示/隐藏切换)
- [x] 测试键盘上下键导航
- [x] 测试回车键快速粘贴
- [x] 测试数据持久化（重启后恢复）
- [x] 测试快捷键自定义
- [x] 测试最大记录数调整
- [x] 测试清空历史
- [x] 测试引导流程

### 阶段 4: 正式版发布 ✅
- [x] 功能验证完成
- [x] 创建 v1.0.0 tag
- [x] GitHub 提交

### 阶段 5: v1.1.0 更新 ✅
- [x] Esc 键隐藏 UI
- [x] 回车粘贴置顶
- [x] 鼠标点击置顶（bug 修复）
- [x] 鼠标点击粘贴失效（bug 修复）
- [x] 默认保存条数改为 50
- [x] 创建 v1.1.0 tag
- [x] 打包 DMG (ClipNest-v1.1.0.dmg, 849KB)

## 遇到的问题

| 问题 | 解决方案 |
|------|---------|
| Carbon 常量名称错误 (OptionKey vs optionKey) | 修改为正确的 lowercase 版本 |
| Key(carbonKeyCode:) 返回可选类型 | 添加 guard let 解包 |
| Info.plist 未生成 | 设置 GENERATE_INFOPLIST_FILE: YES |
| 快捷键回调未连接 | 添加 `onHotkeyPressed` 回调连接 `showClipboard()` |
| 快捷键只显示不隐藏 | 修改 `showClipboard()` 实现切换功能 |
| 弹窗抢夺输入焦点 | 移除 `NSApp.activate` 和 `makeKey()` 保持光标位置 |
| 键盘导航不工作 | 使用 CGEvent.tapCreate 实现全局键盘拦截，拦截上下键和回车键 |

## 关键文件

| 文件 | 说明 |
|------|------|
| Sources/ClipNest/main.swift | 应用入口 |
| Sources/ClipNest/App/AppDelegate.swift | AppDelegate + 菜单栏 |
| Sources/ClipNest/Models/ClipboardItem.swift | 剪切板条目 |
| Sources/ClipNest/Models/AppSettings.swift | 应用设置 |
| Sources/ClipNest/Services/StorageService.swift | JSON 存储 |
| Sources/ClipNest/Services/ClipboardManager.swift | 剪切板监控 |
| Sources/ClipNest/Services/HotkeyManager.swift | 快捷键管理 |
| Sources/ClipNest/Services/KeyboardInterceptor.swift | 全局键盘事件拦截 |
| Sources/ClipNest/Services/ClipboardPopoverState.swift | 弹窗状态共享 |
| Sources/ClipNest/Views/ClipboardPopoverView.swift | 历史列表 |
| Sources/ClipNest/Views/SettingsView.swift | 设置窗口 |
| Sources/ClipNest/Views/OnboardingView.swift | 引导界面 |

## 运行方式
```bash
open ClipNest.xcodeproj
# Cmd+R 运行
```
