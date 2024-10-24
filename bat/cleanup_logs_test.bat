@echo off
setlocal enableextensions

:: �������� ��⮢�� �।�
set "LOG_DIR=L:\log"
set "BACKUP_DIR=%LOG_DIR%\backup"

:: �������� �६����� ��४�਩
call make_folder.bat

:: ���� 1: �஢�ઠ ࠡ��� �ਯ� � ����������� > 70%
echo "���� 1: ��娢�஢���� �� ���������� > 70%"
:: ���������� �����
for /L %%i in (1, 1, 20) do (
    fsutil file createnew "%LOG_DIR%\test_file_%%i.txt" 41943040
)
:: ����� �ਯ� ��� �஢�ન
call cleanup_logs.bat "%LOG_DIR%" 70 5
:: �஢�ઠ ������ ��娢�
if exist "%BACKUP_DIR%\*.tar" (
	echo "���� 1 �ன���: ��娢 ᮧ���."
) else (
	echo "���� 1 �� �ன���: ��娢 �� ᮧ���."
)
:: �������� ��⮢�� 䠩���
call cleanup.bat %LOG_DIR%

:: ���� 2: �஢�ઠ ࠡ��� �ਯ� � ����������� < 70%
echo "���� 2: ��娢�஢���� �� ���������� < 70%"
:: ���������� �����
for /L %%i in (1, 1, 5) do (
    fsutil file createnew "%LOG_DIR%\test_file_%%i.txt" 52428800
)
:: ����� �ਯ� ��� �஢�ન
call cleanup_logs.bat "%LOG_DIR%" 70 5
:: �஢�ઠ ������⢨� ��娢�
if not exist "%BACKUP_DIR%\*.tar" (
	echo "���� 2 �ன���: ��娢 �� ᮧ���, ��� � ���������."
) else (
	echo "���� 2 �� �ன���: ��娢 ᮧ���, ��� �� ������ ��."
)
:: �������� ��⮢�� 䠩���
call cleanup.bat %LOG_DIR%

:: ���� 3: �஢�ઠ ࠡ��� �ਯ� � ���⮩ ������
echo "���� 3: ��娢�஢���� � ���⮩ �����"
:: ����� �ਯ� ��� �஢�ન (��� ���������� �����)
call cleanup_logs.bat "%LOG_DIR%" 50 2
:: �஢�ઠ ������⢨� ��娢�
if not exist "%BACKUP_DIR%\*.tar" (
	echo "���� 3 �ன���: ��娢 �� ᮧ���, ��� � ���������."
) else (
	echo "���� 3 �� �ன���: ��娢 ᮧ���, ��� �� ������ ��."
)
:: �������� ��⮢�� 䠩���
call cleanup.bat %LOG_DIR%

:: ���� 4: �஢�ઠ ࠡ��� �ਯ� �� ����襬 ������⢥ 䠩���, 祬 ���� � �����
echo "���� 4: ��娢�஢���� �� ������⢥ 䠩��� ����� 祬 ���� � �����"
:: ���������� �����
for /L %%i in (1, 1, 3) do (
    fsutil file createnew "%LOG_DIR%\test_file_%%i.txt" 52428800
)
:: ����� �ਯ� ��� �஢�ન, ����訢��� ��娢�஢���� 5 䠩���, �� ���� ⮫쪮 3
call cleanup_logs.bat "%LOG_DIR%" 5 5
:: �஢�ઠ ������ ��娢�
if exist "%BACKUP_DIR%\*.tar" (
	echo "���� 4 �ன���: ��娢 ᮧ���."
) else (
	echo "���� 4 �� �ன���: ��娢 �� ᮧ���."
)
:: �������� ��⮢�� 䠩���
call cleanup.bat %LOG_DIR%

::���⪠
rmdir "%LOG_DIR%"