#  КОМАНДЫ ДЛЯ БЫСТРОГО ДОСТУПА

##  ОСНОВНЫЕ КОМАНДЫ

### Запуск программы

```powershell
.\daily-commit.ps1
```

### Переход в папку программы

```powershell
cd "C:\Users\AllayBro\Desktop\УЧЕБА\ПО ГИТ и ГИТХАБ\Практика\Что я выполнил сегодня"
```

##  НАСТРОЙКА GIT

### Проверка настроек Git

```powershell
git config user.name
git config user.email
```

### Настройка Git (если не настроен)

```powershell
git config --global user.name "AllayBro"
git config --global user.email "artemzotov007@inbox.ru"
```

##  РАБОТА С ФАЙЛАМИ

### Проверка текущей папки

```powershell
Get-Location
```

### Проверка файлов в папке

```powershell
dir
```

### Проверка файла программы

```powershell
Get-Content daily-commit.ps1 -Head 5
```

##  ПРОВЕРКА ИНТЕРНЕТА

```powershell
Test-Connection github.com -Count 1
```

##  ДИАГНОСТИКА

### Проверка статуса

```powershell
git status
```

### Добавление всех файлов

```powershell
git add .
```

### Создание коммита

```powershell
git commit -m "Progress: $(Get-Date -Format 'yyyy-MM-dd')  Описание изменений"
```

### Отправка в репозиторий

```powershell
git push
```

### Получение изменений с репозитория

```powershell
git pull
```

### Просмотр истории коммитов

```powershell
git log --oneline -5
```

##  ОТКРЫТИЕ ПАПОК

### Открытие папки в проводнике

```powershell
explorer .
```

### Открытие папки с журналами

```powershell
explorer journal
```

### Просмотр содержимого файла

```powershell
Get-Content "journal\2025\08\2025-08-30.md"
```

##  РЕШЕНИЕ ПРОБЛЕМ

### Если нет прав доступа

```powershell
Start-Process PowerShell -Verb RunAs
```

### Если файл не открывается

```powershell
notepad "journal\2025\08\2025-08-30.md"
```

### Если push не работает

```powershell
git pull
git push
```

##  ПОЛНЫЙ ЦИКЛ РАБОТЫ

```powershell
# 1. Запуск программы
.\daily-commit.ps1

# 2. Заполнение файла (откроется автоматически)

# 3. Возврат в PowerShell и ввод названия коммита

# 4. Автоматический коммит и push
```

##  ПРОВЕРКА ГОТОВНОСТИ К РАБОТЕ

```powershell
# Проверяем, что все файлы на месте
dir
git status
git remote -v
```
