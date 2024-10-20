#!/bin/bash

# Функция удаления тестовых файлов
cleanup(){
    LOG_DIR="$1"
    BACKUP_DIR="$2"
    if [ -d "$LOG_DIR" ]; then rm -rf $LOG_DIR/*
    fi
    if [ -d "$BACKUP_DIR" ]; then
    rm -rf $BACKUP_DIR/*
    rmdir "$BACKUP_DIR"
    fi
}

# Создание тестовой среды
LOG_DIR="/log"
BACKUP_DIR="/backup"

# Создание временных директорий
if [ ! -d "$LOG_DIR" ]; then mkdir -p "$LOG_DIR"
fi

# Монтирование временной файловой системы (для ограничения размера папки, 1гб)
sudo mount -o size=1G -t tmpfs none "$LOG_DIR"

# Тест 1: Проверка работы скрипта с заполнением > 70%
echo "Тест 1: Архивирование при заполнении > 70%"
# Заполнение папки
for i in {1..20}; do dd if=/dev/zero of="$LOG_DIR/test_file_$i.txt" bs=40M count=1
done
# Запуск скрипта для проверки
./cleanup_logs.sh "$LOG_DIR" 70 5
# Проверка наличия архива
if [ "$(ls -A $BACKUP_DIR)" ]; then echo "Тест 1 пройден: Архив создан."
else echo "Тест 1 не пройден: Архив не создан."
fi
# Удаление тестовых файлов
cleanup "$LOG_DIR" "$BACKUP_DIR"

# Тест 2: Проверка работы скрипта с заполнением < 70%
echo "Тест 2: Архивирование при заполнении < 70%"
# Заполнение папки
for i in {1..5}; do dd if=/dev/zero of="$LOG_DIR/test_file_$i.txt" bs=50M count=1
done
# Запуск скрипта для проверки
./cleanup_logs.sh "$LOG_DIR" 70 5
# Проверка отсутствия архива
if [ ! -d "$BACKUP_DIR" ]; then echo "Тест 2 пройден: Архив не создан, как и ожидалось."
else echo "Тест 2 не пройден: Архив создан, хотя не должен был."
fi

# Удаление тестовых файлов
cleanup "$LOG_DIR" "$BACKUP_DIR"

# Тест 3: Проверка работы скрипта с пустой папкой
echo "Тест 3: Архивирование в пустой папке"
# Запуск скрипта для проверки (без заполнения папки)
./cleanup_logs.sh "$LOG_DIR" 70 2
# Проверка отсутствия архива
if [ ! -d "$BACKUP_DIR" ]; then echo "Тест 3 пройден: Архив не создан, как и ожидалось."
else echo "Тест 3 не пройден: Архив создан, хотя не должен был."
fi

# Удаление тестовых файлов
cleanup "$LOG_DIR" "$BACKUP_DIR"

# Тест 4: Проверка работы скрипта при большем количестве файлов, чем есть в папке
echo "Тест 4: Архивирование при количестве файлов больше чем есть в папке"
for i in {1..3}; do dd if=/dev/zero of="$LOG_DIR/test_file_$i.txt" bs=10M count=1 # 10M на файл, 3 файла = 30M
done
./cleanup_logs.sh "$LOG_DIR" 2 5 # Запрашиваем архивирование 5 файлов, но есть только 3

# Проверка наличия архива
if [ -d "$BACKUP_DIR" ] && [ "$(ls -A "$BACKUP_DIR")" ]; then echo "Тест 4 пройден: Архив создан, все файлы заархивированы"
else echo "Тест 4 не пройден: Архив не создан"
fi

#Удаление тестовых файлов
cleanup "$LOG_DIR" "$BACKUP_DIR"

# Очистка
sudo umount "$LOG_DIR"
rmdir "$LOG_DIR"