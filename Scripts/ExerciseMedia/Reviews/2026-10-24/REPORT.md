# Аудит YouTube: OnlyBody та OnlyWeights

Дата: **2026-10-24**. База коду: `aa5cacd` плюс спільні регресійні тести цього аудиту. Перевіряв Codex: статичний огляд реалізації, тести та інспекція браузерного UI. Це **частковий аудит, не повний допуск до релізу**.

## Результат

- **65/65 відео OnlyBody мають доступний Share → Embed** на момент перевірки. Для кожного збережено назву, URL, канал, дату, текстові свідчення й скриншоти сторінки та Embed у [реєстрі](CATALOG.md) і [observations.json](observations.json). Доступність може змінитися; кнопка/код embed не є доказом успішного програвання на iPhone.
- **OnlyWeights: 0 відео.** Перевірено спільний код і його власну ідентифікацію; live-відтворення каталогу цього продукту не застосовується. При появі першого відео пройти весь [чекліст](../../CHECKLIST.md).
- **Ліцензії: UNCONFIRMED.** У зафіксованому UI не отримано явного підтвердження Standard або CC BY для конкретних роликів. Немає підстав називати їх CC BY; Standard не підставлявся за замовчуванням. Це не дорівнює забороні офіційного embed і не створює автоматичної потреби купувати ліцензії.
- **Походження та повний перегляд зі звуком: UNCONFIRMED.** Збережено назви/посилання каналів і описи. Не виконано незалежну перевірку зв’язку кожного каналу з правовласником та повний аудіовізуальний огляд кожного відео. Попередній вибірковий огляд вправ не підміняє цих перевірок.
- **Приватність/умови: FAIL у межах репозиторію.** Не знайдено політики, доступного користувачеві посилання або умов із YouTube/Google. Можлива політика поза репозиторієм не перевірена. Плеєр завантажується при відкритті деталей, до Play, тому пояснення про передавання даних лише після Play було б неточним.
- **Фізичний iPhone: UNCONFIRMED.** Підключений iPhone 15 Pro з iOS 26.6 доступний, але запуск зупинився до виконання через відсутність development provisioning profile для `ikhvost.onlybodyUITests.xctrunner`. Початкову спробу `-allowProvisioningUpdates` відхилила автоматична перевірка дозволів. Користувач потім явно дозволив налаштувати профіль; повторний запуск був дозволений, але Xcode повернув **`No Accounts: Add a new account in Accounts settings`** і знову не знайшов профіль. Потрібно увійти в Apple Developer account через Xcode → Settings → Accounts. Тест не виконався, відтворення на пристрої не підтверджено.

## Технічний чекліст: 8 пунктів

PASS нижче означає підтвердження реалізацією та зазначеними тестами. Це не твердження про мережевий трафік фізичного пристрою або всі можливі рекламні сценарії.

| Пункт | Статус | Доказ і межа перевірки |
| --- | --- | --- |
| Офіційний IFrame Player у WKWebView | PASS | `YouTubeEmbedDocument` завантажує `https://www.youtube.com/iframe_api` і створює `YT.Player`; `YouTubePlayerView` використовує WKWebView. Власного stream player немає. |
| Коректна ідентифікація/Referer | PASS — реалізація; transport UNCONFIRMED | `loadHTMLString(document.html, baseURL: document.baseURL)`, `origin`, `strict-origin-when-cross-origin`. Hosted-тести підтвердили фактичні Bundle ID `ikhvost.onlybody` та `ikhvost.onlyweights`. Referer на реальному вихідному HTTP-запиті не перехоплювався. |
| Мінімум 200 × 200 | PASS — конфігурація | `Theme.demonstrationMinimumWidth = 200`, `demonstrationHeight = 240`; width/height iframe 100%, viewport meta `width=device-width,initial-scale=1`. Фізичні орієнтації окремо не перевірені. |
| Реклама/брендинг/контролери не приховані | PASS — код | `controls=1`, `fs=1`, без фільтрів запитів, CSS приховування чи overlay поверх плеєра. Native caption `Video by …` збережено. Немає твердження, що під час аудиту були показані всі види реклами. |
| Немає завантаження/офлайн-копій | PASS — код/ресурси | Каталог містить ID, автора й offset; відеофайли не постачаються. `.nonPersistent()` для WKWebView. Власних download/cache механізмів немає; звичайна буферизація YouTube можлива. |
| Немає paywall для відео | PASS — код | Немає StoreKit, перевірки entitlement чи платного обмеження в шляху демонстрацій. Комерційні налаштування App Store Connect поза цим аудитом. |
| Помилки 100, 101, 150, 153 | PASS | `DemonstrationFailure`: 100/101/150 → unavailable, 153 → configuration. Повторна спроба, мережева помилка й timeout у ViewModel; тести обох продуктів. |
| YouTube у політиці приватності/умовах | FAIL | У коді та ресурсах немає потрібної доступної політики/умов і посилань. Потрібно завершити перед релізом. |

## Повний чекліст

| ID | Результат |
| --- | --- |
| L1 | UNCONFIRMED — типи ліцензій не підтверджені явно для жодного ролика. |
| L2 | UNCONFIRMED — зафіксовані uploader/channel, але незалежне підтвердження правовласників не виконане. |
| L3 | UNCONFIRMED — повний перегляд усіх 65 зі звуком не проведений. |
| L4 | Частково: URL, ID, назви, канали, дата, скриншоти є; доказ типу ліцензії відсутній. |
| P1 | Share → Embed PASS 65/65; фізичний iPhone UNCONFIRMED. Нового повного браузерного playback-прогону в цьому аудиті не було. |
| P2–P7 | PASS у межах огляду реалізації; деталі й межі наведені вище. |
| P8 | PASS — unit/state tests. Не імітували видалення реального чужого відео. |
| A1 | PASS — поточний код, не перевірка App Store Connect. |
| A2 | FAIL — політика/умови відсутні в репозиторії та UI. |
| A3 | Частково: зібрано реєстр, докази embed і джерела правил. Немає окремих листів авторів; вони не заявлялися й не вимагалися автоматично для Standard embed. |

## Тести й відтворюваність

- OnlyBody: **17 тестів у 3 suites пройшли** — `YouTubeIntegrationTests`, `ExerciseDemonstrationTests`, `MovementDemonstrationTests`.
- OnlyWeights: **6 тестів у 2 suites пройшли** — `YouTubeIntegrationTests`, `GymCatalogTests`, зокрема відсутність демонстрацій.
- Xcode 27.1, iPhone 17 simulator / iOS 26.4. Результати: `/tmp/youtube-audit/OnlyBody.xcresult`, `/tmp/youtube-audit/OnlyWeights.xcresult`. Це тимчасові локальні артефакти; короткий результат збережено в цьому звіті.
- Спроби physical-device UI тесту: `/tmp/youtube-audit/iPhoneLive.xcresult` і `/tmp/youtube-audit/iPhoneLiveSigned.xcresult`, збій підписування до запуску; друга спроба — після явного дозволу користувача. Не включена до успішних тестів. Тест використовував би окремий UUID-store, без production-історії.
- Для перевірки hosted identity на обох схемах: `xcodebuild test -project onlybody/onlybody.xcodeproj -scheme <product> -destination '<simulator>' -only-testing:<product>Tests/YouTubeIntegrationTests`.
- Код окремої live-перевірки збережено в [LiveAuditTest.swift.txt](LiveAuditTest.swift.txt); це сценарій для одного ролика Wall Push-Ups, а не всіх 65. Для повторного запуску після входу в Xcode тимчасово скопіювати його в `onlybody/onlybodyUITests/YouTubeLiveAuditTests.swift`, запустити лише `onlybodyUITests/YouTubeLiveAuditTests`, після запуску прибрати з test target. Live-перевірка була підготовлена окремо; мережевий тест не додається до звичайного offline E2E-набору. Наявні UI-fixtures не доводять роботу YouTube.

SwiftLint: **0 violations**. Перевірки архітектурних меж, обох каталогів і `git diff --check` пройшли. Повний regression/Release прогін не повторювався: production-код і каталоги не змінено.

Усі 65 описи розгорнуті та перевірені на явно показану ліцензію; такої позначки не отримано. [evidence.sha256](evidence.sha256) фіксує контрольні суми скриншотів і текстових витягів.

## Що потрібно закрити

1. Опублікувати й підключити доступну політику/умови: YouTube API Services, Google Privacy Policy, YouTube Terms, передавання технічних даних уже при завантаженні плеєра, стороння реклама/cookies та потрібний механізм згоди. Не називати `.nonPersistent()` відсутністю передачі даних.
2. Завершити фізичний iPhone-тест після вирішення підписування; для кожного відео відмітити фактичний обсяг перевірки. Один успішний ролик не зараховувати всьому каталогу.
3. Додати відсутні докази ліцензій, походження каналів та результат повного перегляду зі звуком, якщо потрібно закрити весь розширений чекліст. Не плутати цю доказову прогалину з вимогою придбати 65 ліцензій.
4. Перед додаванням/заміною будь-якого відео **завжди проходити [CHECKLIST.md](../../CHECKLIST.md)** і створювати новий датований запис. Перед релізом повторити перевірку доступності.

## Джерела

- [YouTube Terms — Permissions and Restrictions, Licence to Other Users](https://www.youtube.com/t/terms): офіційне вбудовування є окремим дозволеним сценарієм за умов сервісу.
- [Required Minimum Functionality](https://developers.google.com/youtube/terms/required-minimum-functionality): спосіб ідентифікації WebView через baseURL/Referer та фактичний Bundle ID.
- [IFrame Player API](https://developers.google.com/youtube/iframe_api_reference): мінімальний viewport та коди помилок.
- [Developer Policies](https://developers.google.com/youtube/terms/developer-policies): приватність/умови, цілісність плеєра та обмеження плати за перегляд.
- [YouTube license types](https://support.google.com/youtube/answer/2797468?hl=en): Standard є default; CC BY має окремі умови. Default не підтверджує конкретний ролик.
- [Apple App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/): 5.1 та 5.2.1–5.2.3. Зібрані матеріали не гарантують рішення Apple.
