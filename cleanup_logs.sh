#!/bin/bash

# Проверка количества аргументов
if [ "$#" -ne 3 ]; then
    echo "Использование: \$0 <путь к логам> <порог в процентах> <количество файлов для архивирования>"
    exit 1
fi

# Присваивание аргументов переменным
LOG_DIR="$1" #путь к логам
LIMIT="$2" #порог заполненности в процентах
N="$3" #количество файлов для архивирования
BACKUP_DIR="/backup" #папка для архива

# Проверка существования папки
if [ ! -d "$LOG_DIR" ]; then
    echo "Ошибка: Папка $LOG_DIR не существует."
    exit 1
fi

# Получение информации о заполнении папки (число)
USAGE=$(df "$LOG_DIR" | tail -1 | awk '{print $5}' | sed 's/%//')

# Проверка заполнения
if [ "$USAGE" -gt "$LIMIT" ]; then
    echo "Заполнение папки $LOG_DIR: ${USAGE}%. Архивируем старые файлы..."

    # Архивирование N самых старых файлов
    OLD_FILES=$(find "$LOG_DIR" -type f -printf '%T+ %p\n' | sort | head -n "$N" | cut -d' ' -f2-)
    # Проверка на отсутствие файлов для архивирования
    if [ -z "$OLD_FILES" ]; then
        echo "Нет файлов для архивирования."
        exit 0
    fi

    # Создание папки для резервного копирования, если её нет
    mkdir -p "$BACKUP_DIR"

    # Создание архива
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    ARCHIVE_NAME="$BACKUP_DIR/log_backup_$TIMESTAMP.tar.gz"
    tar -czf "$ARCHIVE_NAME" -C "$LOG_DIR" $OLD_FILES

    # Удаление архивированных файлов
    for file in $OLD_FILES; do rm "$file"
    done

    echo "Файлы успешно заархивированы в $ARCHIVE_NAME и удалены из $LOG_DIR."
else
    echo "Заполнение папки $LOG_DIR: ${USAGE}%. Архивирование не требуется."
fi