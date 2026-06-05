@echo off
chcp 65001 >nul
echo ========================================================
echo   TMax 旧版安卓应用 (APK) 自动编译脚本
echo ========================================================

cd /d "%~dp0"
echo 正在执行 Flutter build apk --release...
echo 这个过程可能需要一到两分钟，请耐心等待...

call flutter build apk --release

if %errorlevel% neq 0 (
    echo.
    echo [错误] APK 编译失败！请检查错误日志。
    pause
    exit /b %errorlevel%
)

echo.
echo ========================================================
echo [成功] APK 编译完成！
echo 输出路径: build\app\outputs\flutter-apk\app-release.apk
echo ========================================================
pause
