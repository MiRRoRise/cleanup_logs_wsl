@echo off
setlocal enabledelayedexpansion

:: Проверка количества элементов
if "%~3"=="" (
    echo "Использование: %0 <путь к логам> <порог в процентах> <количество файлов для архивирования>"
    exit /b 1
)

:: Присваивание аргументов переменным
set LOG_DIR=%~1
set /a LIMIT=%~2
set N=%~3
set "BACKUP_DIR=%LOG_DIR%\backup"

:: Проверка существования папки
if not exist "%LOG_DIR%" (
	echo "Ошибка: Папка %LOG_DIR% не существует."
	exit /b 1
)

:: Получение информации о заполнении папки (число)
for /f "tokens=3" %%A in ('dir /-C "%LOG_DIR%" 2^>nul ^| find "байт свободно"') do set FREE=%%A
:start
for /f "tokens=3" %%B in ('dir /-C "%LOG_DIR%" 2^>nul ^| find "байт"') do (
	set NOTFREE=%%B
	goto end
)
:end

for /f "delims=" %%i in ('add.exe %FREE% %NOTFREE%') do set TOTAL=%%i
for /f "delims=" %%j in ('divide.exe %NOTFREE% %TOTAL%') do set /a USAGE=%%j

:: Проверка заполнения 
if %USAGE% lss %LIMIT% (
	echo "Заполнение папки %LOG_DIR%: !USAGE!%%. Архивирование не требуется."
	exit /b 0
)

echo "Заполнение папки %LOG_DIR%: %USAGE%%%. Архивируем старые файлы..."

:: Архивирование N самых старых файлов
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
:: Проверка на отсутствие файлов для архивирования
if "!OLD_FILES!" == "" (
	echo "Нет файлов для архивирования."
	exit /b 0
)
:: Убираем лишний пробел,,
if "!OLD_FILES:~-1!"==" " (
    set "OLD_FILES=!OLD_FILES:~0,-1!"
)

:: Создание папки для резервного копирования, если её нет
if not exist "%BACKUP_DIR%\" (
	mkdir "%BACKUP_DIR%\"
)

:: Создание архива
set "TIMESTAMP=%date%%time%"
set "TIMESTAMP=%TIMESTAMP:.=_%"
set "TIMESTAMP=%TIMESTAMP:,=_%"
set "TIMESTAMP=%TIMESTAMP::=_%"
set "TIMESTAMP=%TIMESTAMP: =_%"
set "ARCHIVE_NAME=%BACKUP_DIR%\log_backup_!TIMESTAMP!.tar"
tar -cvf "%ARCHIVE_NAME%" -C "%LOG_DIR%" !OLD_FILES!

:: Удаление архивированных файлов
set "count=0"
for /f "delims=" %%a in ('dir /b /a-d /od "%LOG_DIR%"') do (
	if !count! geq !N! (
		goto :endloop
	)
	set /a "count+=1"
	del "%LOG_DIR%\%%a"
)
:endloop

echo "Файлы успешно заархивированы в %ARCHIVE_NAME% и удалены из %LOG_DIR%."
