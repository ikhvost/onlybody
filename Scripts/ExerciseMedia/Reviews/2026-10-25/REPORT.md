# OnlyWeights: 60 вправ і 60 відео в Debug та Release

Дата: **2026-10-25**, Europe/Warsaw. Рецензент: **Codex**. База коду: `ce22791` плюс поточні зміни каталогу й тестів. Каталог вправ готовий; **відеочастина не завершена й не є допуском до App Review**.

## Результат

- OnlyWeights розширено з 16 до **60 вправ**. Старі назви збережено; додано 44 погоджені вправи, метадані м’язів/складності, обладнання й оновлений seed SQLite. Перелік і редакційні правила: [каталог вправ](../../../StoreGenerator/OnlyWeights/README.md).
- Для кожної з 60 вправ підібрано окремий YouTube-кандидат: [реєстр](CATALOG.md), [повні записи L/P/A](onlyweights-candidates.json). Точні назви, автори та URL каналів отримано з публічного YouTube oEmbed.
- **60/60 фінальних кандидатів: Share → Embed PASS.** Для кожного відкрито повний опис, потім Share → Embed і перевірено відповідність ID в iframe. Збережено 120 скриншотів фінальних кандидатів та текстові витяги. Докази відхилених альтернатив також залишено як історію добору. [Браузерні спостереження](evidence/browser-observations.json), [контрольні суми](evidence.sha256).
- **Ліцензії 60/60: UNCONFIRMED.** У повних описах явної позначки Standard чи CC BY не отримано. Назви рекомендованих відео зі словом «license» не є ліцензійними доказами. Відсутність CC не використовується як підтвердження Standard.
- **60 відео в Debug і Release.** За прямим проханням користувача записи перенесено до `Scripts/ExerciseMedia/onlyweights.json` зі статусом `partial-review-user-deferred`. Один Swift-каталог використовується обома конфігураціями; окремої DEBUG-гілки немає. Авторинг JSON, скриншоти й звіт не потрапляють у застосунок; runtime JSON немає. [Рішення та межі перевірки](#release-enablement).
- Каталог, seed та відео OnlyBody не змінено. Під час повної перевірки його seed генерувався лише в тимчасовій директорії.

## Межі перевірки контенту

Це огляд метаданих, повних описів, посилань на джерела, вибіркових прев’ю та доступності Share → Embed. **Повний перегляд кожного ролика зі звуком не проводився.** Немає твердження про відсутність сторонньої музики/матеріалів чи наявність прав на них. Повна відповідність техніки, обладнання й ракурсів залишається `UNCONFIRMED` до аудіовізуального огляду.

Виявлені невідповідності виправлено на рівні добору: сторінка PureGym для Seated Cable Row посилалася на Incline Dumbbell Row; підібрано окремий ролик тяги сидячи. Для Dumbbell Reverse Fly відхилено варіант сидячи, для Dumbbell Goblet Squat — прев’ю з гирею, для EZ-Bar Skull Crusher — прев’ю з гантелями на підлозі. Нові кандидати показують відповідне обладнання на прев’ю або описують саме потрібний варіант; це не заміняє повний перегляд.

Посилання з офіційних сторінок PureGym і Live Lean TV зіставлено з oEmbed-авторами; де такого джерела немає, записано пряму сторінку YouTube. Додатково відкрито About усіх 7 каналів і збережено `evidence/channel-*.png` та `.txt`. Для PureGym, Live Lean TV, OPEX Fitness, OriGym і ScottHermanFitness зіставлено опис/посилання каналу з офіційними сайтами: **L2 PASS для 58 кандидатів** у межах походження каналу. Для Kade Howell та OPEX Abbotsford незалежне підтвердження зв’язку з каналом лишається **UNCONFIRMED (2)**. Витяг посилань сайтів: [official-site-channel-links.json](evidence/official-site-channel-links.json). L2 не підтверджує права на всі фрагменти чи музику; L3 відкритий.

## Спільна технічна перевірка

PASS нижче обмежений кодом, конфігурацією й автоматизованими тестами. Він не означає фізичне відтворення кожного кандидата.

| Пункти | Статус і доказ |
| --- | --- |
| P1 | Share → Embed PASS 60/60; фізичний iPhone UNCONFIRMED. Підписана Debug-збірка з кандидатами успішна. Спроба встановлення на paired iPhone 15 Pro / iOS 26.6 через локальну мережу завершилася до запуску: CoreDevice error 4000, connection reset by peer (54). Після цього користувач попросив перевіряти на iPhone 17 Simulator; фізичне відтворення не виконано. Приватні ідентифікатори й журнали підписування не додавалися до репозиторію. |
| P2 | PASS — `YouTubeEmbedDocument` створює офіційний `YT.Player`, `YouTubePlayerView` використовує WKWebView. |
| P3 | PASS — `loadHTMLString(document.html, baseURL: document.baseURL)`, origin і `strict-origin-when-cross-origin`; hosted `YouTubeIntegrationTests` перевіряє `https://ikhvost.onlyweights` та окрему OnlyBody identity. Фактичний HTTP Referer фізичного пристрою не перевірено. |
| P4 | PASS — конфігурація viewport, min width 200, height 240; shared test проходить. Перевірка вузького фізичного екрана й орієнтацій залишається відкритою. |
| P5 | PASS — стандартні controls, branding, links; у спільному коді немає перекриття плеєра чи фільтрації реклами. Реальний показ реклами окремо не перевірявся. |
| P6 | PASS — стандартна атрибуція плеєра та `Video by …` збережені. |
| P7 | PASS — жодних відеофайлів, витягування потоків або офлайн-копій. Звичайна буферизація YouTube не є офлайн-функцією застосунку. |
| P8 | PASS — shared tests обох schemes для 100/101/150/153; OnlyBody playback/state regression tests також пройшли. Мережеві помилки/timeout мають recoverable state; live-сценарії для кожного кандидата не виконано. |
| A1 | PASS у межах коду — доступ до відео не продається; зовнішні комерційні налаштування не аудитовано. |
| A2 | **FAIL** — `SettingsView` показує Privacy Policy та Terms of Use через `SettingsRow`, але це disabled-кнопки «Soon / Coming soon» без URL. Доступних документів із YouTube API Services, Google Privacy Policy та YouTube Terms у застосунку не підтверджено. Плеєр звертається до мережі при створенні WKWebView, до Play. `.nonPersistent()` не означає відсутність передачі даних. |
| A3 | UNCONFIRMED — частковий пакет доказів, без повного L/P/A sign-off та без гарантії схвалення Apple. |

## Ліцензійне правило

Для офіційного вбудовування не потрібно автоматично вимагати CC BY, придбання ліцензії або індивідуального дозволу лише через Standard YouTube License. Standard-відео може бути придатним за дозволеного embed і дотримання умов YouTube. Це не дозволяє витягувати, змінювати чи перевидавати відеофайл і не гарантує правомірності завантаження автором. Якщо покладаємося на CC BY, виконуються її атрибуційні умови.

Невідомий тип ліцензії не прирівнюється до заборони embed. Користувач прямо попросив додати ці відео також у Release та відкласти решту перевірок. L2/L3 та фізичний P1 залишаються незавершеними в зазначеному вище обсязі; A2 зберігає FAIL. Це рішення про конфігурацію збірки, а не повне схвалення контенту чи App Review.

Офіційні джерела звірено 2026-10-25:

- [Типи ліцензій YouTube](https://support.google.com/youtube/answer/2797468?hl=en).
- [YouTube Terms](https://www.youtube.com/t/terms).
- [Required Minimum Functionality](https://developers.google.com/youtube/terms/required-minimum-functionality).
- [Developer Policies](https://developers.google.com/youtube/terms/developer-policies).
- [Обов’язковий чекліст репозиторію](../../CHECKLIST.md).

## Початкова валідація каталогу вправ

Xcode **27.1**, Swift **6.4**; iPhone 17 Simulator / iOS 26.4. Повний `Scripts/validate.sh` пройшов:

- OnlyBody: **241 Swift Testing test**, усі **5 E2E** journeys, Release build.
- OnlyWeights: **215 Swift Testing tests**, усі **5 E2E** journeys, Release build.
- `GymCatalogTests` перевіряє 60 унікальних записів, метадані, обладнання, м’язові діаграми, комбіновані фільтри/пошук, нову вправу після reopening і окрему no-video fixture.
- `GymCatalogUpgradeTests` перевіряє перехід зі старого 16-entry file store: усі старі UUID, workout/item references, історію з вагою по підходах, відсутність bulk-insert під час читання, atomic materialization однієї нової вправи та повторне відкриття.
- SwiftLint: **0 violations**; architecture boundaries, обидва каталоги, bundle identity/resource isolation та тимчасова генерація **65/60** вправ пройшли.
- Тимчасові артефакти: `/tmp/onlyweights-60-validation/`; log: `/tmp/onlyweights-60-validation.log`. Їхні шляхи не є довготривалим сховищем; підсумок збережено тут.

## Відкладені перевірки

1. Завершити перевірку походження та повний перегляд кожного кандидата зі звуком; записати таймкоди й результати, за потреби замінити кандидатів.
2. Підтвердити типи ліцензій доступними доказами або явно зберегти UNCONFIRMED із поясненням; не вигадувати Standard/CC.
3. Опублікувати й підключити реальні privacy/terms з потрібними посиланнями та механізмом ознайомлення/згоди; перевірити момент першого мережевого запиту.
4. Провести живе відтворення кожного відео на фізичному iPhone в OnlyWeights та записати фактичний обсяг перевірки, модель/iOS/версію застосунку/мережу без приватних ідентифікаторів.
5. Після завершення огляду оновити фактичні статуси в реєстрі та `onlyweights.json`; повторити перевірку доступності перед публікацією.


## Історія: початкова інтеграція лише в Debug

Нижче — історичний стан до прохання ввімкнути Release. За проханням користувача продовжено підключення відео; публікацію політики/умов відкладено, перевірку пристрою перенесено на симулятор. Жоден відкритий пункт через це не позначався PASS.

- `generate.py --review-candidates Reviews/2026-10-25/onlyweights-candidates.json` генерує тільки DEBUG-кандидатів поряд з окремим Release-каталогом. Дублікати, невідомі вправи, невалідні ID та невирішені контентні/технічні FAIL відхиляються. A2 дозволений лише для цієї тестової гілки.
- `GymCatalogTests.debugReviewVideosCoverCatalogAndReachMovementDetails` перевіряє всі 60 валідних кандидатів, точну відповідність вправам і отримання плеєром identity `https://ikhvost.onlyweights`.
- П’ятий E2E OnlyWeights тепер перевіряє той самий локальний WebKit fixture, що OnlyBody, включно з play/pause і навігацією поверх плеєра. Це офлайн-тест UI, а не живий YouTube.
- `check-app-bundles.py` додатково перевіряє відсутність ID непідтверджених кандидатів у Release executable та бібліотеках та відсутність реєстру у bundle.
- Підписана збірка для фізичного iPhone успішна; встановлення заблоковане з’єднанням. Debug-збірка встановлена й запущена на iPhone 17 Pro Simulator; за уточненням користувача живий огляд виконано на iPhone 17 Simulator, iOS 26.4.1, OnlyWeights 1.0 (1).

Усі етапи повторної перевірки завершені успішно; докладний підсумок нижче.


### Живий плеєр: iPhone 17 Simulator

Дата: 2026-10-25; рецензент Codex; OnlyWeights 1.0 (1) DEBUG, база `ce22791` + зміни робочого дерева; iOS 26.4.1; мережа Mac через Simulator. SHA-256 головного executable тестової збірки: `a7c59fe22954907570eda7e182485900be3e12cbd428531ca7de0a7a5516fa4a` (Debug-логіка також міститься в `onlyweights.debug.dylib`; хеш не є хешем усього bundle).

| Вправа | Спостереження | Доказ |
| --- | --- | --- |
| Barbell Bench Press | Live iframe завантажився; Play, завершення 0:15/0:15 та повторний запуск. Підпис автора й контролери видимі. | [Завершення](evidence/simulator-CjHIKDQ4RQo-playback.png), [повторний запуск](evidence/simulator-CjHIKDQ4RQo-replay.png) |
| Dumbbell Bench Press | Live iframe завантажився; Play і завершення 0:15/0:15, стандартні контролери. | [Завершення](evidence/simulator-AduT4Eq-iP0-playback.png) |
| Weighted Dips | Play; тривалість плеєра 0:40; рухомий фрагмент з поясом і диском на паралельних брусах. Посилання кінцевого екрана відкрило YouTube у Safari; повернення до OnlyWeights працювало. | [Відтворення](evidence/simulator-hVVVEPB2ntw-playback.png), [зовнішнє посилання](evidence/simulator-hVVVEPB2ntw-external-link.png) |

Це **3 вибіркові живі simulator-перевірки**, не 60 повних переглядів і не фізичний iPhone. Інструмент дає кадри та UI, але не аудіо для слухового аудиту; факт увімкненого звуку в плеєрі не є переглядом звукової доріжки рецензентом. L3 лишається UNCONFIRMED для всіх 60. Пауза/повторна спроба/помилки мають окремі автоматизовані перевірки, які не підміняють live-перевірки кожного кандидата.


### Повторна автоматизована перевірка

`Scripts/validate.sh` виконав OnlyBody: 241 Swift Testing test, 5 E2E, Release build. На компіляції нового OnlyWeights-тесту виявлено несумісність макроса `#expect` з key-path аргументом `allSatisfy`; виправлено явним closure. Також виправлено розташування doc comment у згенерованому Debug-каталозі. Пройдені перевірки OnlyBody не повторювалися без змін його поведінки.

Решту команд того самого workflow виконано повторно для OnlyWeights: **216 Swift Testing tests**, включно з `YouTubeIntegrationTests`, і **всі 5 E2E** пройшли. Разом: **457 unit/integration tests і 10 E2E**. OnlyBody зберігає `ExerciseDemonstrationTests` та `MovementDemonstrationTests` у своєму пройденому наборі.

Журнали: `/tmp/onlyweights-video-validation.log`, `/tmp/onlyweights-video-validation-resume.log`; xcresult і збірки: `/tmp/onlyweights-video-validation/`. Сирі журнали підписування/пристрою не включені до репозиторію.


**Фінальний результат перевірки: PASS.** Обидві Release-збірки успішні; identity/resource isolation, відсутність Debug-кандидатів у Release binaries, architecture boundaries, `check-catalogs.py`, SwiftLint (0 violations) і тимчасова seed-генерація 65/60 пройшли. Завершальний процес повернув exit code 0. Зміни OnlyBody catalog/seed/media відсутні. [Короткий журнал результатів](evidence/validation-summary.txt).

Підсумок цього історичного етапу: 60 Debug-кандидатів, 60 Embed PASS, 58 provenance PASS / 2 UNCONFIRMED, 3 live simulator samples. **0 Release-відео**, 60 невиконаних повних аудіовізуальних оглядів і 60 непідтверджених фізичних playback-перевірок. Privacy/terms відкладено користувачем; жодного повного допуску до релізу не заявлено.

<a id="release-enablement"></a>

## Підключення Release за проханням користувача

2026-10-25 користувач прямо вказав: «Додай ці відео і в Release, решту перевірок зробимо пізніше.» Усі 60 наявних відео з тими самими ID, авторами та стартовими позиціями перенесено до `onlyweights.json`; згенерований Swift-каталог тепер єдиний для Debug і Release. Тимчасову DEBUG-гілку генератора прибрано. Зміни плеєра, схеми даних чи каталогу OnlyBody не потрібні.

У реєстрі кожного відео збережено попередні докази й результати чекліста; додано рішення користувача та статус `RELEASE_ENABLED_REVIEW_INCOMPLETE`. Жоден невиконаний пункт не став PASS. Повний аудіовізуальний огляд, перевірки на фізичному iPhone та опубліковані privacy/terms залишаються відкладеними. Ця зміна не публікує застосунок в App Store.

### Перевірка зміни Release

Після перенесення відео пройшли **25 цільових тестів**: OnlyBody — 17 (`YouTubeIntegrationTests`, `ExerciseDemonstrationTests`, `MovementDemonstrationTests`); OnlyWeights — 8 (`YouTubeIntegrationTests`, `GymCatalogTests`, `GymCatalogUpgradeTests`). Обидві Release simulator-збірки успішні. Перевірка зібраного OnlyWeights підтвердила наявність усіх **60 ID** у Release binaries і відсутність реєстру в bundle. SwiftLint — 0 violations; `check-catalogs.py`, architecture boundaries та перевірка незмінності OnlyBody catalog/media/seed — PASS.

Повний `validate.sh` і E2E для цього окремого перенесення в Release не повторювалися; попередній повний workflow задокументовано вище. Нового живого чи фізичного перегляду не виконано. [Результати цієї перевірки](evidence/release-validation-summary.txt). Тимчасові логи та xcresult: `/tmp/onlyweights-release-videos-check/`.
