@echo off
setlocal EnableExtensions
rem ============================================================================
rem  Colin McRae Rally recomp - Windows one-click build.
rem  Double-click it, or drag your disc folder / .cue / .bin onto this file.
rem  Installs MSYS2 with winget if you do not have it, installs the build tools,
rem  then runs tools\msys2_build.sh (which runs tools\setup_and_build.py).
rem  Set MSYS2_ROOT first if MSYS2 is not in C:\msys64.
rem ============================================================================
cd /d "%~dp0"
title Colin McRae Rally recomp - build

set "HERE=%CD%"
if not "%HERE%"=="%HERE: =%" goto :spaces

if not defined MSYS2_ROOT set "MSYS2_ROOT=C:\msys64"
if exist "%MSYS2_ROOT%\usr\bin\bash.exe" goto :have_msys

echo MSYS2 was not found in %MSYS2_ROOT%.
where winget >nul 2>nul
if errorlevel 1 goto :no_winget
echo Installing MSYS2 with winget ...
winget install --id MSYS2.MSYS2 -e --accept-package-agreements --accept-source-agreements
if exist "%MSYS2_ROOT%\usr\bin\bash.exe" goto :have_msys

:no_winget
echo.
echo Install MSYS2 from https://www.msys2.org (default folder C:\msys64) and run this again.
echo If it is somewhere else, set MSYS2_ROOT to that folder first.
goto :fail

:have_msys
set "CMRR_DISC=%~1"
if defined CMRR_DISC goto :run
if exist "%HERE%\disc\game.cue" goto :run
echo.
echo Enter the path to your disc dump: a folder, or a .cue or .bin file.
set /p "CMRR_DISC=Disc path: "
if defined CMRR_DISC set "CMRR_DISC=%CMRR_DISC:"=%"
if not defined CMRR_DISC goto :nodisc

:run
set "MSYSTEM=MINGW64"
set "CHERE_INVOKING=1"
"%MSYS2_ROOT%\usr\bin\bash.exe" -l "%HERE:\=/%/tools/msys2_build.sh"
if errorlevel 1 goto :fail
echo.
echo Done. Run build-release\ColinMcRaeRally_Recompiled.exe
pause
exit /b 0

:spaces
echo The project folder path contains spaces:
echo   %HERE%
echo Move the folder to a path without spaces, for example C:\cmrr, and run this again.
goto :fail

:nodisc
echo No disc path given.
goto :fail

:fail
echo.
echo The build did not finish. Scroll up to see why.
pause
exit /b 1
