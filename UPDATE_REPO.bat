@echo off
REM ============================================================
REM  Kace Kodi Repository - Update Script
REM  Regenerates zip files and addons.xml after addon changes
REM ============================================================

set REPO_DIR=%~dp0repo
set TMP_DIR=%~dp0_tmp_zip

echo ============================================
echo  Kace Kodi Repository - Update
echo ============================================

REM Clean temp
if exist "%TMP_DIR%" rmdir /s /q "%TMP_DIR%"
mkdir "%TMP_DIR%"

REM --- plugin.video.xship ---
echo.
echo [1/3] Packaging plugin.video.xship...

REM Read version from addon.xml
for /f "tokens=2 delims==" %%a in ('findstr /c:"version=" "%REPO_DIR%\plugin.video.xship\addon.xml" ^| findstr /c:"addon id"') do (
    for /f "tokens=1 delims= " %%b in ("%%a") do set XSHIP_VER=%%~b
)
echo       Version: %XSHIP_VER%

if exist "%REPO_DIR%\plugin.video.xship\plugin.video.xship-*.zip" del /q "%REPO_DIR%\plugin.video.xship\plugin.video.xship-*.zip"
mkdir "%TMP_DIR%\plugin.video.xship"
xcopy "%REPO_DIR%\..\plugin.video.xship" "%TMP_DIR%\plugin.video.xship" /s /e /q /exclude:%~dp0exclude.txt >nul 2>&1
powershell -Command "Compress-Archive -Path '%TMP_DIR%\plugin.video.xship' -DestinationPath '%REPO_DIR%\plugin.video.xship\plugin.video.xship-%XSHIP_VER%.zip' -Force"
echo       Done.

REM --- skin.osmc ---
echo.
echo [2/3] Packaging skin.osmc...
for /f "tokens=2 delims==" %%a in ('findstr /c:"version=" "%REPO_DIR%\skin.osmc\addon.xml" ^| findstr /c:"addon id"') do (
    for /f "tokens=1 delims= " %%b in ("%%a") do set SKIN_VER=%%~b
)
echo       Version: %SKIN_VER%

if exist "%REPO_DIR%\skin.osmc\skin.osmc-*.zip" del /q "%REPO_DIR%\skin.osmc\skin.osmc-*.zip"
mkdir "%TMP_DIR%\skin.osmc"
xcopy "%REPO_DIR%\..\skin.osmc" "%TMP_DIR%\skin.osmc" /s /e /q >nul 2>&1
powershell -Command "Compress-Archive -Path '%TMP_DIR%\skin.osmc' -DestinationPath '%REPO_DIR%\skin.osmc\skin.osmc-%SKIN_VER%.zip' -Force"
echo       Done.

REM --- repository.kace ---
echo.
echo [3/3] Packaging repository.kace...
if exist "%REPO_DIR%\repository.kace\repository.kace-*.zip" del /q "%REPO_DIR%\repository.kace\repository.kace-*.zip"
mkdir "%TMP_DIR%\repository.kace"
xcopy "%REPO_DIR%\repository.kace" "%TMP_DIR%\repository.kace" /s /e /q >nul 2>&1
REM Remove old zips from temp copy
if exist "%TMP_DIR%\repository.kace\repository.kace-*.zip" del /q "%TMP_DIR%\repository.kace\repository.kace-*.zip"
powershell -Command "Compress-Archive -Path '%TMP_DIR%\repository.kace' -DestinationPath '%REPO_DIR%\repository.kace\repository.kace-1.0.0.zip' -Force"
echo       Done.

REM --- Generate addons.xml ---
echo.
echo Generating addons.xml...
powershell -ExecutionPolicy Bypass -File "%~dp0generate_addons_xml.ps1"

REM Cleanup
if exist "%TMP_DIR%" rmdir /s /q "%TMP_DIR%"

echo.
echo ============================================
echo  Done! Now commit and push to GitHub.
echo ============================================
pause
