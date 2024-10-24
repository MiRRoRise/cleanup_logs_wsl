echo @off

set "LOG_DIR=%1"
set "BACKUP_DIR=%LOG_DIR%\backup"
if exist "%BACKUP_DIR%" (
rmdir /s /q "%BACKUP_DIR%"
)
if exist "%LOG_DIR%" (
del /q "%LOG_DIR%\*.*"
)

exit /b 0


