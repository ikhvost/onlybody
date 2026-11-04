# Нативна перевірка v007

Дата: 5 листопада 2026. Джерело SwiftUI: `85aaed377696911817992571f3f6f396576e7bf4`, поверх Liquid Glass-коміту `e48a02e`.

## Фізичний iPhone

iPhone 15 Pro, iOS 27.2. Обидва продукти успішно зібрані в Debug для пристрою з локальним development-підписом, встановлені зі збереженням даних і запущені у звичайному режимі. Наприкінці відкрито OnlyWeights. Version / build залишаються 1.0 / 2; це оновлення development-збірок, не distribution archive.

| Продукт | Build | Install | Normal launch |
|---|---|---|---|
| OnlyBody | PASS | PASS | PASS |
| OnlyWeights | PASS | PASS | PASS |

Локальний знімок `references/physical-iphone/OnlyBody/train.png` (1179 × 2556) отримано через `devicectl device capture screenshot` з реального iPhone. На ньому лише fixture-дані; він показує системний таббар і верхні скляні кнопки. Особисті тренування в дизайн не копіювалися. Інші знімки в `screenshots/` — браузерні, їх не слід називати знімками з телефона.

Повна автоматизована Visual-матриця на фізичному iPhone не виконана: для `onlybodyUITests.xctrunner` немає development provisioning profile. Це не завадило збірці, встановленню або запуску самих застосунків. Профілі й налаштування підпису не змінювалися.

## Перевірки

- `Scripts/validate.sh quick`: PASS для обох продуктів, 509 тестів логіки та інтеграцій; SwiftLint — 0 порушень.
- `python3 Scripts/Validation/check-catalogs.py`: PASS, каталоги 99 / 105 вправ.
- Compact iPhone Simulator, 375 pt: Visual-матриця 20 екранів × 5 мов — PASS. Перевірено знімки створення, редагування та активного заняття, зокрема довгі українські й німецькі заголовки.
- Браузерний прототип: 540 комбінацій екранів, 120 панелей і поведінкові перевірки — PASS; див. `verification.json`. Це CSS-наближення системного матеріалу.

`Scripts/validate.sh full`: **PASS, exit 0** для обох продуктів. По 7 функціональних UI-тестів (усі 5 E2E-сценаріїв, локалізація, області натискання) без помилок, 509 тестів логіки та інтеграцій. Обидві Release Simulator-збірки, bundle-перевірки й тимчасова генерація seed stores 99 / 105 вправ — PASS.

Локальні журнали: `Release/Artifacts/2026-11-05-liquid-editor/`. Результати XCTest: `/tmp/onlybody-editor-verified/{onlybody,onlyweights}-Tests.xcresult`; компактна Visual-матриця — `/tmp/onlybody-editor-compact-fixed.xcresult`. Ці локальні артефакти не входять до Git.

Нове ручне приймання VoiceOver / Reduce Motion / Reduce Transparency на фізичному пристрої до цієї ітерації не входило. Системні налаштування телефона не змінювалися.
