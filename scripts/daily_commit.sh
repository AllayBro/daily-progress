#!/usr/bin/env bash
set -euo pipefail

# --- Setup ---
Y=$(date +%Y)
M=$(date +%m)
D=$(date +%F)
F=journal/$Y/$M/$D.md

# --- Create directory and file ---
mkdir -p journal/$Y/$M

if [ ! -f "$F" ]; then
  cat > "$F" <<END
# $D

## Done

- 

## Not done

- 
END
  echo "Создан файл: $F"
fi

# --- Check Git configuration ---
if ! git config user.name >/dev/null 2>&1 || ! git config user.email >/dev/null 2>&1; then
    echo "❌ Git не настроен! Настройте имя пользователя и email:"
    echo "git config --global user.name 'Ваше имя'"
    echo "git config --global user.email 'ваш@email.com'"
    exit 1
fi

# --- Git operations ---
git add -A

echo "Введи название коммита:"
read -r MSG

if git commit -m "$MSG"; then
    echo "✅ Коммит создан: $MSG"
else
    echo "ℹ️  Нет изменений для коммита"
    exit 0
fi

# Pull remote changes first
echo "Pulling remote changes..."
if ! git pull origin main; then
    echo "⚠️  Warning: Could not pull remote changes"
fi

if git push -u origin main; then
    echo "✅ Отправлено в репозиторий"
else
    echo "❌ Ошибка при отправке в репозиторий"
    exit 1
fi
