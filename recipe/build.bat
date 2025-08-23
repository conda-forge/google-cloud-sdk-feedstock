@echo off

setlocal

set "outdir=%PREFIX%\share\%PKG_NAME%-%PKG_VERSION%-%PKG_BUILDNUM%"
if not exist "%outdir%" mkdir "%outdir%"
if not exist "%PREFIX%\Scripts" mkdir "%PREFIX%\Scripts"

xcopy * "%outdir%\" /E /I /Q /Y

for %%F in (gcloud.cmd gsutil.cmd bq.cmd docker-credential-gcloud.cmd) do (
    echo Patching "%outdir%\bin\%%F"
    powershell -Command "(Get-Content '%outdir%\bin\%%F') -replace 'rem <cloud-sdk-cmd-preamble>', 'set CLOUDSDK_PYTHON=%PREFIX%\python.exe\r\nset CLOUDSDK_ROOT_DIR=%outdir%' | Set-Content '%outdir%\bin\%%F'"
    echo Linking "%PREFIX%\Scripts\%%F" to "%outdir%\bin\%%F"
    mklink /H "%PREFIX%\Scripts\%%F" "%outdir%\bin\%%F"
)

:: google-cloud-sdk starts from %outdir%\lib\googlecloudsdk\core\config.py and
:: searches for any directory containing .install to mark it as the SDK_ROOT
:: Empty directories are ignored by the packaging process in Conda, so add a
:: placeholder to force inclusion of that folder
if not exist "%outdir%\.install" mkdir "%outdir%\.install"
type nul > "%outdir%\.install\.conda"

endlocal