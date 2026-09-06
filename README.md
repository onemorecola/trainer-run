# trainer-run

Универсальный запуск FLiNG-трейнеров для Steam-игр под Proton (Linux).

Скрипт сканирует папку с загрузками на `.exe`-файлы, показывает их списком,
ты выбираешь нужный цифрой — а игру (App ID) скрипт подбирает сам, по имени
файла трейнера, и запускает трейнер в правильном Wine-префиксе через
`protontricks-launch`.

## Как это работает

1. **Сканирование** — обходит папку (по умолчанию `/mnt/Files/Загрузки`)
   рекурсивно и собирает все `.exe`. По умолчанию в меню показывает только
   файлы со словом `trainer` в имени; остальное прячется за пунктом
   «показать остальные .exe».
2. **Подбор игры** — App ID берётся **локально**, из `appmanifest_*.acf`
   всех Steam-библиотек (никаких онлайн-баз). Имя файла трейнера нечётко
   сравнивается с названиями игр (пересечение значимых слов + похожесть
   строк), выдаётся топ-6 кандидатов. Если ничего не нашлось — App ID можно
   ввести вручную.
3. **Запуск** — `protontricks-launch --appid <ID> <путь к трейнеру>`.
   Игра при этом должна быть запущена, иначе трейнер напишет
   `game not found`.

## Зависимости

- Python 3 (стандартная библиотека)
- [protontricks](https://github.com/Matoking/protontricks) (даёт `protontricks-launch`)
- Steam с установленными играми

## Установка

```sh
install -m755 trainer-run ~/.local/bin/trainer-run
# либо симлинк, чтобы правки подхватывались сразу:
ln -s "$(pwd)/trainer-run" ~/.local/bin/trainer-run
```

## Использование

```sh
trainer-run              # сканировать папку по умолчанию и показать меню
trainer-run /путь/к/папке
trainer-run --list       # просто показать найденное и подобранные игры
trainer-run --fix-dotnet # поставить .NET 4.0 в префикс игры (чинит новые FLiNG)
```

> **`--fix-dotnet`**: FLiNG-трейнеры, выпущенные после июля 2023, собраны под
> .NET Framework и молча падают в префиксе, где есть только Wine Mono.
> Режим подбирает игру так же, как обычный запуск, но вместо запуска
> трейнера ставит в её префикс `dotnet40` (один раз на игру). После этого
> трейнер запускается и через trainer-run, и через CheatDeck/launch options.
> Если не помогло — попробуйте вручную `protontricks <App ID> dotnet48`.

Пример меню:

```
Что запускаем:
   1) Dead Space Remake v1.0 Plus 17 Trainer.exe
   2) PRAGMATA Plus 10 Trainer.exe
   3) (показать остальные .exe — без «trainer» в имени)
   4) отмена
Выбор: 1

Похоже, трейнер для игры:
   1) Dead Space  [App ID 1693980]
   2) ...
Выбор: 1

Запускаю трейнер в префиксе игры 1693980...
```

## Настройка

Пути по умолчанию заданы в начале скрипта и переопределяются
переменными окружения:

| Переменная          | Что задаёт                          | По умолчанию             |
|---------------------|-------------------------------------|--------------------------|
| `TRAINER_RUN_FOLDER`| папка со скачанными трейнерами     | `/mnt/Files/Загрузки`    |
| `STEAM_ROOT`        | корень Steam (папка с `steamapps`)  | `~/.local/share/Steam`   |
| `PROTONTRICKS_LAUNCH` | команда запуска exe в префиксе   | `protontricks-launch`    |
| `PROTONTRICKS`      | команда winetricks-действий         | `protontricks`           |

```sh
TRAINER_RUN_FOLDER=/home/user/Загрузки trainer-run
```

## Steam Deck

Работает и на Steam Deck (SteamOS — это Arch). Корень Steam там тот же —
`~/.local/share/Steam`, так что подбор App ID работает из коробки.
Нужны только protontricks и правильные переменные.

1. **Desktop Mode** → поставь из Discover flatpak-версию protontricks
   (`com.github.Matoking.protontricks`).
2. Пропиши команды для flatpak (или положи в `~/.bashrc`):

   ```sh
   export PROTONTRICKS_LAUNCH="flatpak run com.github.Matoking.protontricks launch --no-bwrap"
   export PROTONTRICKS="flatpak run com.github.Matoking.protontricks --no-bwrap"
   ```

3. Запускай с папкой загрузок Дека:

   ```sh
   TRAINER_RUN_FOLDER=/home/deck/Downloads trainer-run
   ```

4. Если новые FLiNG-трейнеры молча не стартуют (типичная беда CheatDeck) —
   один раз на игру прогони фикс .NET:

   ```sh
   trainer-run --fix-dotnet /home/deck/Downloads/имя_трейнера.exe
   ```

   После этого CheatDeck / launch options в Gaming Mode подхватят трейнер
   штатно. В самом Gaming Mode текстовое меню неудобно — trainer-run
   рассчитан на Desktop Mode либо на запуск «рядом» с CheatDeck.

## Ярлык в меню приложений (GNOME)

Рядом лежит `trainer-run-gui.sh` — обёртка, которая запускает скрипт
и держит окно терминала открытым. Пример `.desktop`-файла:

```ini
[Desktop Entry]
Name=Trainer Run
Comment=Запуск FLiNG-трейнеров для Steam-игр
Exec=ptyxis -x /полный/путь/trainer-run-gui.sh
Icon=applications-games
Terminal=false
Type=Application
Categories=Game;Utility;
```

Положите его в `~/.local/share/applications/`.

## Лицензия

MIT.
