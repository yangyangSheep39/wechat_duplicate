﻿#!/usr/bin/osascript

# Raycast metadata
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title WeChat_Duplicate
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName Raycast Script

# Documentation:
# @raycast.description 克隆 WeChat 为 Wechat2 用于双开，并更换自定义图标
# @raycast.author yangyangSheep
# @raycast.authorURL https://raycast.com/yangyangSheep

# Step 0: 如果已存在 WeChat2.app，则删除
try
	set checkExists to "if [ -d /Applications/WeChat2.app ]; then echo 'EXISTS'; fi"
	set result to do shell script checkExists
	
	if result is equal to "EXISTS" then
		display dialog "检测到已存在 WeChat2.app，将删除旧版本。" buttons {"继续"} default button 1
		do shell script "rm -rf /Applications/WeChat2.app" with administrator privileges
	end if
end try

# Step 1: 选择图标文件
set iconFile to choose file with prompt "请选择一个 .icns 图标文件"
set iconPath to POSIX path of iconFile

# Step 2: 定义命令列表
set copyCmd to "cp -R /Applications/WeChat.app /Applications/WeChat2.app"
set bundleCmd to "/usr/libexec/PlistBuddy -c \"Set :CFBundleIdentifier com.tencent.xinWeChat2\" /Applications/WeChat2.app/Contents/Info.plist"
set signCmd to "codesign --force --deep --sign - /Applications/WeChat2.app"
set replaceIconCmd to "cp \"" & iconPath & "\" \"/Applications/WeChat2.app/Contents/Resources/AppIcon.icns\""
set clearIconCacheCmd to "find /private/var/folders -name com.apple.dock.iconcache -exec rm {} \\; 2>/dev/null"
set clearIconServiceCmd to "find /private/var/folders -name com.apple.iconservices -exec rm -rf {} \\; 2>/dev/null"
set refreshIconCmd to "touch /Applications/WeChat2.app; killall Finder"
set killDockCmd to "killall Dock"

# Step 3: 执行命令（带管理员权限）
try
	display dialog "已获取管理员权限，即将开始克隆 WeChat 并替换图标，是否继续？" buttons {"取消", "继续"} default button "继续" cancel button "取消"
on error
	display dialog "❌ 已取消操作。" buttons {"OK"} default button 1
	return # 中断整个脚本
end try

-- Step 4: 执行命令
try
	do shell script copyCmd with administrator privileges
	do shell script bundleCmd with administrator privileges
	do shell script signCmd with administrator privileges
	do shell script replaceIconCmd with administrator privileges
	
	-- 清理图标缓存（包在 try 中防止出错终止）
	try
		do shell script refreshIconCmd
	end try
	
	-- 重启 Dock
	do shell script killDockCmd
	
	display dialog "✅ WeChat2 克隆成功，图标已替换并重新签名！" buttons {"好的"} default button 1
on error errMsg
	display dialog "❌ 出错了：" & errMsg buttons {"OK"} default button 1
end try
