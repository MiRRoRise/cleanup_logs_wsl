@echo off
setlocal enabledelayedexpansion

:: �஢�ઠ ������⢠ ����⮢
if "%~3"=="" (
    echo "�ᯮ�짮�����: %0 <���� � �����> <��ண � ��業��> <������⢮ 䠩��� ��� ��娢�஢����>"
    exit /b 1
)

:: ��ᢠ������ ��㬥�⮢ ��६����
set LOG_DIR=%~1
set /a LIMIT=%~2
set N=%~3
set "BACKUP_DIR=%LOG_DIR%\backup"

:: �஢�ઠ ����⢮����� �����
if not exist "%LOG_DIR%" (
	echo "�訡��: ����� %LOG_DIR% �� �������."
	exit /b 1
)

:: ����祭�� ���ଠ樨 � ���������� ����� (�᫮)
for /f "tokens=3" %%A in ('dir /-C "%LOG_DIR%" 2^>nul ^| find "���� ᢮�����"') do set FREE=%%A
:start
for /f "tokens=3" %%B in ('dir /-C "%LOG_DIR%" 2^>nul ^| find "����"') do (
	set NOTFREE=%%B
	goto end
)
:end

for /f "delims=" %%i in ('add.exe %FREE% %NOTFREE%') do set TOTAL=%%i
for /f "delims=" %%j in ('divide.exe %NOTFREE% %TOTAL%') do set /a USAGE=%%j

:: �஢�ઠ ���������� 
if %USAGE% lss %LIMIT% (
	echo "���������� ����� %LOG_DIR%: !USAGE!%%. ��娢�஢���� �� �ॡ����."
	exit /b 0
)

echo "���������� ����� %LOG_DIR%: %USAGE%%%. ��娢��㥬 ���� 䠩��..."

:: ��娢�஢���� N ᠬ�� ����� 䠩���
set "OLD_FILES="
set "count=0"
for /f "delims=" %%a in ('dir /b /a-d /od "%LOG_DIR%"') do (
	if !count! geq !N! (
		goto :endloop
	)
	set /a "count+=1"
	set "OLD_FILES=!OLD_FILES!"%%a" "
)
:endloop
:: �஢�ઠ �� ������⢨� 䠩��� ��� ��娢�஢����
if "!OLD_FILES!" == "" (
	echo "��� 䠩��� ��� ��娢�஢����."
	exit /b 0
)
:: ���ࠥ� ��譨� �஡��,,
if "!OLD_FILES:~-1!"==" " (
    set "OLD_FILES=!OLD_FILES:~0,-1!"
)

:: �������� ����� ��� १�ࢭ��� ����஢����, �᫨ �� ���
if not exist "%BACKUP_DIR%\" (
	mkdir "%BACKUP_DIR%\"
)

:: �������� ��娢�
set "TIMESTAMP=%date%%time%"
set "TIMESTAMP=%TIMESTAMP:.=_%"
set "TIMESTAMP=%TIMESTAMP:,=_%"
set "TIMESTAMP=%TIMESTAMP::=_%"
set "TIMESTAMP=%TIMESTAMP: =_%"
set "ARCHIVE_NAME=%BACKUP_DIR%\log_backup_!TIMESTAMP!.tar"
tar -cvf "%ARCHIVE_NAME%" -C "%LOG_DIR%" !OLD_FILES!

:: �������� ��娢�஢����� 䠩���
set "count=0"
for /f "delims=" %%a in ('dir /b /a-d /od "%LOG_DIR%"') do (
	if !count! geq !N! (
		goto :endloop
	)
	set /a "count+=1"
	del "%LOG_DIR%\%%a"
)
:endloop

echo "����� �ᯥ譮 ����娢�஢��� � %ARCHIVE_NAME% � 㤠���� �� %LOG_DIR%."
