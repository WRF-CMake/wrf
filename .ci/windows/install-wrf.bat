@echo off
rem Copyright 2018 M. Riechert and D. Meyer. Licensed under the MIT License.

set THIS_FOLDER=%~dp0

bash -l "%THIS_FOLDER%install-wrf.sh" || goto :error

goto :EOF

:error
exit /b %errorlevel%