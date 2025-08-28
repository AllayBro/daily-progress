#!/usr/bin/env bash
set -euo pipefail

Y=$(date +%Y); M=$(date +%m); D=$(date +%F)
mkdir -p journal/$Y/$M
F=journal/$Y/$M/$D.md

if [ ! -f "$F" ]; then
  cat > "$F" <<END
# $D

Что сделано:
- 

Что не сделано:
- 
END
fi

git add -A
echo "Введи название коммита:"
read MSG
git commit -m "$MSG" || echo "Нет изменений для коммита"
git push -u origin main
