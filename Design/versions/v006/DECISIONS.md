# v006 — вибір вправ і відео

Дата: 2026-11-03. Статус: реалізовано у браузерному прототипі, готово до перегляду. База — v005. SwiftUI, Theme.swift, каталоги, відеоідентифікатори й нативний плеєр не змінювалися.

## Рішення

1. Пошук у бібліотеці, додаванні й заміні вправ явно центрує SVG та скидає старий `margin-top`. Текстові три крапки замінені трьома SVG-колами, розташованими по центру кнопки.
2. У додаванні вправ назва відкриває гайд, окремий `+` додає рівно одну вправу й повертає в редактор. Кнопки не вкладені одна в одну. Гайд не змінює склад тренування; Back повертає пошук, фільтри, прокрутку та фокус. Працює з окремого екрана й нижньої панелі.
3. Відеоблок розміщений одразу після назви вправи, перед м’язами та обладнанням.
4. Коротке пояснення називає YouTube/Google, дані пристрою й перегляду, cookies, аналітику й рекламу. Основна золота кнопка — «Дивитися на YouTube» / «Watch on YouTube»: це перенесене в картку зовнішнє посилання з незмінною адресою відео. Дубль унизу прибрано. Повне пояснення та додаткова дія «Дивитися тут» / «Watch in app» доступні в розкривному блоці; вона запускає попередній симульований дозвіл. Посилання Google Privacy / YouTube Terms й автор залишаються видимими.
5. Модель дозволів не змінена: симульована відмова залишає зовнішнє посилання, симульована згода показує макет плеєра. Це не реальний ATT-запит і не реальне відтворення. Кнопка не обіцяє автоматичної згоди.

Під час роботи звірено [Apple Privacy HIG](https://developer.apple.com/design/human-interface-guidelines/privacy), [Apple User Privacy and Data Use](https://developer.apple.com/app-store/user-privacy-and-data-use/) і [YouTube Developer Policies](https://developers.google.com/youtube/terms/developer-policies). Скорочення тексту не прибирає вибір або істотне повідомлення про дані. Це дизайн-рішення, а не висновок про юридичну відповідність чи готовність релізу.

## Перевірки

Команди з кореня репозиторію; потрібні локальні Playwright і Chrome, без залежностей у застосунках:

```sh
python3 -m http.server 8772 --bind 127.0.0.1 --directory Design
export NODE_PATH=/Users/ikhvost/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules
node Design/tests/verify-v006.cjs
node Design/tests/verify-v006-controls.cjs
node Design/tests/verify-v006-guide.cjs
DESIGN_VERSION=v006 DESIGN_REVIEW_DATE=2026-11-03 DESIGN_REPORT=Design/versions/v006/behavior-verification.json node Design/tests/verify-v003.cjs
DESIGN_REPORT=Design/versions/v006/v005-regression.json node Design/tests/verify-v005.cjs
```

Фактичні результати збережено в JSON поряд із цим файлом:

| Звіт | Результат |
|---|---|
| verification.json | PASS: 540 екранів, 120 панелей; геометрія, іконки 22 px по центру, цілі від 44 px, фокус, контраст, чотири режими матеріалу/руху |
| controls-verification.json | PASS: 60 меню, 30 панелей таймінгу, 8 груп сценаріїв |
| guide-verification.json | PASS: 60 сценаріїв додавання/повернення, 30 відеосценаріїв; 2 продукти × 5 мов × 3 ширини |
| behavior-verification.json | PASS: 360 комбінацій і 22 групи сценаріїв тренування |
| v005-regression.json | PASS: 540 екранів і 120 панелей попередньої версії |

JavaScript syntax, JSON, `git diff --check` і `swiftlint lint --no-cache --strict --quiet` — PASS. Візуально переглянуто бібліотеку й редактор OnlyWeights, додавання OnlyBody, гайди обох продуктів та порівняння v005/v006. Скриншоти — лише локальні, gitignored. Контрольні суми захищають 71 файл v000–v005. Нативні збірки, VoiceOver і фізичний iPhone не перевірялися в цій ітерації.

Обов’язковий [чекліст медіа](../../../Scripts/ExerciseMedia/CHECKLIST.md) прочитано. Локальний запис меж перевірки: `Scripts/ExerciseMedia/Reviews/2026-11-03/v006-presentation.md` (gitignored). Нових або замінених відео немає; цей запис не підтверджує ліцензії, реальний embed чи завершення медіарев’ю.

## Уточнення кнопки після відгуку — 2026-11-03

«Set up videos» прибрано. Основний CTA відкриває оригінальне посилання YouTube у новій вкладці; дозволи прототипу від нього не змінюються. Попередні JSON-звіти залишено історичними. Цільова перевірка після уточнення: `video-cta-verification.json` (30 відеосценаріїв, 2 продукти × 5 мов × 3 ширини). Команда:

```sh
DESIGN_VIDEO_ONLY=1 DESIGN_REPORT=Design/versions/v006/video-cta-verification.json node Design/tests/verify-v006-guide.cjs
```

За наступним відгуком шеврони в рядках додавання прибрано. Кнопка назви зберігає відкриття гайда; окремий `+` зберігає додавання.

Уточнення перевірені окремо: `video-cta-verification.json` — PASS, 30 комбінацій; `picker-refinement-verification.json` — PASS, обидва продукти, відсутність стрілок і збереження дій гайд → Back → додавання. Попередню повну матрицю після цих локальних правок не повторювали.
