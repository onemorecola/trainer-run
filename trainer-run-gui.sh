#!/bin/bash
# Обёртка: запускает trainer-run в терминале и держит окно открытым
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$dir/trainer-run"
echo
read -rp "Нажми Enter, чтобы закрыть окно..."
