@echo off
setlocal
if not exist build mkdir build
set "BF4_VS_ROOT=%VSINSTALLDIR%"
if defined BF4_VS_ROOT goto configure_visual_studio
set "BF4_VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%BF4_VSWHERE%" (
    echo ERROR: Install Visual Studio C++ x86 tools or run from a Developer Command Prompt. 1>&2
    exit /b 1
)
for /f "usebackq tokens=*" %%I in (`"%BF4_VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do set "BF4_VS_ROOT=%%I\"
if not defined BF4_VS_ROOT (
    echo ERROR: Visual Studio C++ x86 tools were not found. 1>&2
    exit /b 1
)
:configure_visual_studio
call "%BF4_VS_ROOT%Common7\Tools\VsDevCmd.bat" -arch=x86 -host_arch=x86 >nul
if errorlevel 1 exit /b 1
cl /nologo /EHsc /std:c++14 /DHAVE_STDINT_H /DPAWN_CELL_SIZE=32 /DAMX_NODYNALOAD /I..\amxmodx\compiler\amxxpc tools\pawn_test_runner.cpp ..\amxmodx\compiler\amxxpc\amx.cpp /Febuild\pawn_test_runner.exe /Fobuild\ /link /INCREMENTAL:NO
exit /b %errorlevel%
