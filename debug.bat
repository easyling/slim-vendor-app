setlocal EnableDelayedExpansion

SET PUB_PATH=C:\tools\dart-sdk\bin
SET CURR_DIR=%cd%

start cmd /c "cd %CURR_DIR%\client && %PUB_PATH%\pub.bat serve web --hostname 127.0.0.1 --port 7777"
cd %CURR_DIR%\server
set DART_PUB_SERVE=http://127.0.0.1:7777
%PUB_PATH%\pub.bat run bin\server.dart