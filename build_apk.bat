@echo off
set PATH=%LOCALAPPDATA%\flutter\bin;%PATH%
cd /d "%~dp0"
echo Building One more try. APK...
flutter pub get
flutter build apk --release
echo.
echo APK:
dir /b build\app\outputs\flutter-apk\*.apk 2>nul
pause
