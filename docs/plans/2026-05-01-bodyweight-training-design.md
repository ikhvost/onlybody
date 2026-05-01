# OnlyBody — Design Spec

**Date:** 2026-05-01
**Platform:** iOS (SwiftUI)
**App Name:** OnlyBody
**Status:** MVP — Approved

---

## 1. Design Principles

1. **One thing on screen at a time** — no busy dashboards, no competing CTAs
2. **Custom typography** — DM Sans for UI text, DM Mono for numbers, labels, and metadata
3. **Single amber accent** — `#E8A23A`; everything else is dark monochrome
4. **Custom hand-crafted icons** — NOT SF Symbols; square stroke caps, miter joins
5. **Borders over whitespace** — thin `1px` semi-transparent borders separate sections
6. **Dark-only** — no light mode, no system color adaptation; fixed dark palette
7. **Monospaced uppercase labels** for all metadata (Mono component pattern)

---

## 2. Color Palette

| Role | Token | Value |
|------|-------|-------|
| Accent | `--accent` | `#E8A23A` (amber) |
| Accent dim | `--accent-dim` | `rgba(232,162,58,0.13)` |
| Accent dark (text on accent bg) | `--accent-dark` | `#0C0C0B` |
| Background | `--bg` | `#0C0C0B` |
| Surface (cards, inputs) | `--surface` | `#161614` |
| Surface 2 (steppers, toggles) | `--surface2` | `#1E1E1B` |
| Border | `--border` | `rgba(255,250,230,0.07)` |
| Border 2 | `--border2` | `rgba(255,250,230,0.13)` |
| Text primary | `--text` | `#F5F0E8` (warm white) |
| Text secondary | `--text2` | `rgba(245,240,232,0.5)` |
| Text tertiary | `--text3` | `rgba(245,240,232,0.24)` |
| Danger | `--danger` | `#E05A4E` |
| Success | `--success` | `#4CAF6E` |

---

## 3. Typography

| Role | Font | Size | Weight | Notes |
|------|------|------|--------|-------|
| Screen title ("OnlyBody", "Log", "Library") | DM Sans | 26px | 800 | `letter-spacing: -1` |
| Section heading ("What are you training?") | DM Sans | 24px | 800 | `letter-spacing: -0.8` |
| Exercise name (active session) | DM Sans | 38px | 800 | `letter-spacing: -1.5`, `line-height: 1.0` |
| Session complete timer | DM Mono | 72px | 500 | `letter-spacing: -3` |
| Rest countdown timer | DM Mono | 84px | 500 | `letter-spacing: -4` |
| Row title / movement name | DM Sans | 15px | 700 | |
| Sub-row title | DM Sans | 14px | 700 | |
| Body / secondary text | DM Sans | 13px | 400–600 | |
| Meta labels (Mono) | DM Mono | 9–11px | 400 | uppercase, `letter-spacing: 0.3–1.5` |
| Stepper values | DM Mono | 20px | 500 | |
| Stat card values | DM Mono | 26px | 500 | |
| NavBar title | DM Sans | 15px | 700 | `letter-spacing: -0.2` |
| Primary button | DM Sans | 15px | 700 | |
| Mono CTA (START →) | DM Mono | 11px | 500 | `letter-spacing: 1.2` |

---

## 4. Layout System

| Property | Value |
|----------|-------|
| Horizontal padding | 18px |
| Card border-radius | 4px |
| Chip border-radius | 3px |
| NavBar height | 46px min, `padding: 10px 18px` |
| Primary button height | ~46px (`padding: 15px 0`) |
| Standard chip | `padding: 8px 15px`, `font-size: 13px` |
| Small chip | `padding: 5px 10px`, `font-size: 11px` |
| Set tracker cell | 13×13px, `border-radius: 2px` (squares) |
| Set tracker gap | 7px |
| Date square (log) | 38×38px, `border-radius: 4px` |
| Bottom nav indicator | 16×2px bar, `border-radius: 1px` |

No shadows. No capsule shapes.

---

## 5. Components

### Mono
DM Mono, uppercase, configurable `letter-spacing` (default 1), color defaults to `--text3`. Used for all metadata, labels, and numeric captions.

### Primary Button
Full-width, `background: var(--accent)`, color `var(--accent-dark)`, `border-radius: 4px`, `font-weight: 700`.
Disabled: `background: var(--surface2)`, color `--text3`.

### Ghost Button
`padding: 8px 14px`, `border: 1px solid var(--border2)`, transparent background, color `--text2`, `font-size: 13px`.

### Back Button
Text link with leading `<` icon — amber color, no border/background, `font-weight: 600`.

### NavBar
Three-slot (left / center / right). `border-bottom: 1px solid var(--border)`.

### Chip
`border-radius: 3px`, `font-weight: 600`, `transition: all 0.12s`.
- **Active:** `background: var(--accent)`, `border: 1px solid var(--accent)`, color `--accent-dark`
- **Inactive:** `background: var(--surface2)`, `border: 1px solid var(--border2)`, color `--text2`

### Stepper
`−` button: 28×28px, `background: var(--surface2)`, `border: 1px solid var(--border2)`.
`+` button: 28×28px, `background: var(--accent)`, no border.
Value: DM Mono 20px centered, min-width 36px.

### Set Tracker (squares, not circles)
- **Completed:** `background: var(--accent)`
- **Current:** `background: var(--accent-dim)`, `border: 1.5px solid var(--accent)`
- **Pending:** `background: var(--surface2)`, `border: 1.5px solid var(--border2)`
- `transition: all 0.2s`

### Exercise Row
`padding: 13px 18px`. Leading: name (15px 700) + Mono caption `MUSCLE · EQUIPMENT`. Trailing: `+` icon in picker / chevron in library. `CUSTOM` badge: `background: var(--accent-dim)`, color `--accent`, `border-radius: 2px`, `font-size: 10px`, DM Mono.

---

## 6. Icons

Custom SVG, `strokeWidth: 1.8`, `strokeLinecap: "square"`, `strokeLinejoin: "miter"`. Rendered at 14–20px with color passed as prop.

| Name | Visual |
|------|--------|
| `train` | Two small rects top row + one wide rect below |
| `log` | Calendar rect with horizontal lines and date marks |
| `library` | Circle with inner `+` crosshair (search/explore) |
| `back` | Left chevron `‹` |
| `fwd` | Right chevron `›` |
| `plus` | `+` cross |
| `play` | Solid right-pointing triangle (fill, no stroke) |
| `edit` | Pencil path |
| `remove` | Square outline with `×` inside |
| `check` | Checkmark `✓` (`strokeWidth: 2.5`) |
| `search` | Circle + diagonal line |
| `chevron` | Single right chevron |
| `drag` | 6-dot 2×3 grid |

---

## 7. Bottom Navigation

Three tabs, `border-top: 1px solid var(--border)`, `background: var(--bg)`.

| Tab ID | Label | Icon |
|--------|-------|------|
| `workouts` | `TRAIN` | `train` |
| `history` | `LOG` | `log` |
| `exercises` | `LIBRARY` | `library` |

**Active:** amber icon + amber Mono label (9px) + 16×2px amber indicator bar.
**Inactive:** `rgba(245,240,232,0.28)` icon + `--text3` label.

Hidden when a sub-screen is shown (any `screen` state is non-null).

---

## 8. Screen Layouts

### Train Screen (Workouts Tab)

```
┌─────────────────────────────────┐
│ FRI, MAY 1          OnlyBody [+]│  ← Mono date · 26px 800 title · amber +
│                                  │
│ Sun  Mon  Tue  Wed  Thu  Fri  Sat│  ← day strip
│       ·         ·         ·   · │  ← dot = has workout; amber if today
│                 (amber underline today)
│                                  │
│ ▌ TODAY                         │  ← amber 2px left border callout
│   Full Body                     │
│                                  │
│ ▌ Full Body                     │  ← amber border = today's workout
│   MON · WED · FRI  ·  5 MVMTS  │
│                        [✎] START→│
│ ────────────────────────────────│
│   Upper Body                    │
│   TUE · THU  ·  4 MVMTS        │
│                        [✎] START→│
│ ────────────────────────────────│
│   Lower Body                    │
│   UNSCHEDULED  ·  4 MVMTS      │
│                        [✎] START→│
└─────────────────────────────────┘
```

**Features:**
- Header: Mono date top-left, "OnlyBody" (26px 800) below, amber `+` button (34×34px) top-right
- Day strip: 7 abbreviations; today has `2px solid var(--accent)` underline; 3×3px dot per scheduled day
- Today callout: `background: var(--accent-dim)`, `border-left: 2px solid var(--accent)` — shows workout names joined by ` · `, or "Rest day" with dim border
- Workout list: each row has name (15px 700), Mono days + MVMTS count, edit icon button, amber `START →` Mono button
- Today's workout rows highlighted with `border-left: 2px solid var(--accent)`

**Navigation from this screen:**
- `+` button → Muscle Picker Screen
- Edit icon → Session Builder (edit mode)
- `START →` → Active Session Screen

---

### Active Session Screen

```
┌─────────────────────────────────┐
│ 1/5              00:24    [End] │
│ ████░░░░░░░░░░░░░░░░░░░░░░░░░░ │  ← 2px amber progress bar
│                                  │
│ Push-Ups                         │  ← 38px 800
│ SET 2 OF 3  ·  TARGET 12 REPS  │  ← Mono
│                                  │
│ ■ ■ □                           │  ← set tracker squares
│                                  │
│ ┌────────────┐  ┌────────────┐  │
│ │ REPS        │  │ ADDED KG   │  │
│ │  − [12] +  │  │  − [0]  +  │  │
│ └────────────┘  └────────────┘  │
│                                  │
│ [← Prev]         [Skip →]       │  ← conditional ghost buttons
│                                  │
│ UP NEXT                         │  ← pushes to bottom via marginTop:auto
│ Pull-Ups                         │
│                                  │
│ [       Mark Set Done       ]   │
└─────────────────────────────────┘
```

**Features:**
- Top bar: `x/total` Mono (11px), DM Mono elapsed timer (15px), `End` ghost button
- Amber progress bar fills proportionally by exercise index (`(exIdx/total)*100%`)
- Exercise name 38px 800, Mono sub-caption `SET N OF M · TARGET N REPS` (or "max hold" for `reps=0`)
- Set tracker: squares per set count
- Reps stepper: pre-filled from plan, carries forward to next set automatically
- Added kg stepper: starts at 0, increments 2.5kg, displays one decimal if fractional
- Prev/Skip buttons shown conditionally (`exIdx > 0` / `exIdx < total-1`)
- "Up next" section anchored to bottom
- `Mark Set Done` primary button at very bottom

**Recovery Overlay** (absolute, `inset: 0`, z-index 20, `background: var(--bg)`):

```
┌─────────────────────────────────┐
│                                  │
│           RECOVERY              │  ← Mono label, letter-spacing: 3
│                                  │
│            00:45                │  ← 84px DM Mono amber
│                                  │
│       next — Pull-Ups           │  ← Mono 10px, shown if not last ex
│                                  │
│         [  Skip rest  ]         │  ← ghost button
│                                  │
└─────────────────────────────────┘
```

Auto-dismissed when `restTime` reaches 0.

**Session Complete Screen** (replaces session when all exercises done):
- Mono "Session complete"
- 72px DM Mono amber elapsed time
- Mono "N movements done"
- `Close` primary button (max-width 200px)

---

### Muscle Picker Screen

Entry point for "New Session" flow (tapping `+` on Train screen).

```
┌─────────────────────────────────┐
│ ← Back          New Session     │
│                                  │
│ What are you training?          │  ← 24px 800
│ SELECT MUSCLE GROUPS            │  ← Mono
│                                  │
│ [Chest] [Back] [Shoulders]      │
│ [Arms] [Core] [Quads]           │
│ [Glutes] [Hamstrings] [Calves]  │
│ [Full Body] [Upper] [Lower]     │
│                                  │
│ Chest + Back                    │  ← DM Mono 11px amber, selection summary
│                                  │
│ [     Build session →     ]     │  ← disabled until selection
│   Skip — pick movements myself  │  ← text button, color --text3
└─────────────────────────────────┘
```

12 chips (flex-wrap): Chest, Back, Shoulders, Arms, Core, Quads, Glutes, Hamstrings, Calves, Full Body, Upper, Lower.
"Build session →" disabled (`background: var(--surface2)`) until ≥1 selected.
"Skip" passes empty array → Session Builder (manual mode).

---

### Session Builder Screen

Used for both creating (via Muscle Picker) and editing (via edit icon on Train screen).

```
┌─────────────────────────────────┐
│ ← Back    New Session    [Save] │
│                                  │
│ TARGETS                         │  ← only if muscles were selected
│ [Chest] [Back]                  │  ← amber dim chip tags, read-only
│                                  │
│ SESSION NAME                    │
│ [Full Body.........................]│
│                                  │
│ SET STYLE                       │
│ [Smart pick]   [I choose]       │
│                                  │
│ — Smart pick mode: —            │
│ ┌──────────────────────────────┐ │
│ │ Auto-selected movements       │ │
│ │ Movements picked daily from   │ │
│ │ your targets. Switch to "I    │ │
│ │ choose" to build manually.    │ │
│ └──────────────────────────────┘ │
│                                  │
│ — "I choose" mode: —            │
│ MOVEMENTS              [+ Add]  │
│ ┌──────────────────────────────┐ │
│ │ ⠿  Push-Ups             [✕] │ │  ← drag handle, danger remove icon
│ │    3 SETS · 12 REPS · 45S   │ │
│ ├──────────────────────────────┤ │
│ │ Sets      Reps      Rest     │ │
│ │ −  3  +   − 12 +   − 45s + │ │  ← inline steppers (steps: 1/1/15s)
│ └──────────────────────────────┘ │
│                                  │
│ TRAINING DAYS                   │
│ [Sun][Mon][Tue][Wed][Thu][Fri][Sat]│  ← small chips
│                                  │
│ Est. duration             ~28 min│  ← amber Mono value
└─────────────────────────────────┘
```

**Features:**
- Target chips (amber dim bg, amber text, `border: 1px solid rgba(232,162,58,0.2)`) — read-only display
- Name input: `background: var(--surface)`, `border: 1px solid var(--border2)`
- Mode toggle: `Smart pick` / `I choose`
- `+ Add` opens Movement Picker; tapping there adds movement and returns
- Movement card: drag icon, name, Mono meta, remove button (`--danger`), inline steppers
- Rest step: 15s increments
- Training days: small day chips
- Duration estimate: `Σ(sets×30 + max(0, sets−1)×rest)` seconds → displayed in minutes
- `Save` button in NavBar right

---

### Movement Picker Screen

```
┌─────────────────────────────────┐
│ ← Back       Add Movement       │
│                                  │
│ [🔍 Search movements...       ] │
│ [All][Chest][Back][Quads]...    │  ← scrollable filter row
│                                  │
│ Push-Ups                    [+] │
│ CHEST · NONE                    │
│ ─────────────────────────────── │
│ Pull-Ups                    [+] │
│ BACK · PULL-UP BAR             │
│ ─────────────────────────────── │
│ Bulgarian Split Squats      [+] │
│ QUADS · NONE  [CUSTOM]         │
└─────────────────────────────────┘
```

Filter chips (scrollable `overflowX: auto`): All, Chest, Back, Quads, Glutes, Core, Shoulders, Triceps, Calves.
Search filters by name substring (case-insensitive).
Tapping a row immediately calls `onAdd(exercise)` and dismisses.

---

### Log Screen (History Tab)

```
┌─────────────────────────────────┐
│ TRAINING HISTORY                │  ← Mono 9px
│ Log                             │  ← 26px 800
│                                  │
│ MAY                             │  ← Mono 10px month header
│ ┌────┐                          │
│ │  1 │  Full Body          [›] │
│ └────┘  Friday · 24:10 · 102 kcal│
│                                  │
│ APRIL                           │
│ ┌────┐                          │
│ │ 25 │  Upper Body         [›] │
│ └────┘  Saturday · 36:18 · 140 kcal│
└─────────────────────────────────┘
```

Grouped by month (object keyed by month name, insertion order).
Date square: 38×38px, `background: var(--surface)`, `border: 1px solid var(--border2)`, DM Mono 16px 500.
Each row is a button → Session Detail Screen.

---

### Session Detail Screen

```
┌─────────────────────────────────┐
│ ← Back        Full Body         │
│                                  │
│ FRIDAY, MAY 1                   │  ← Mono 9px
│ 24:10 min      102 kcal         │  ← DM Mono 24px 500 amber + 12px text2
│                                  │
│ Push-Ups               36 REPS TOTAL│
│ SET 1 · 12 REPS                 │
│ SET 2 · 12 REPS                 │
│ SET 3 · 12 REPS                 │
│ ─────────────────────────────── │
│ Pull-Ups               24 REPS TOTAL│
│ SET 1 · 8 REPS                  │
│ ...                              │
│                                  │
│ [      Repeat this session      ]│  ← ghost button
└─────────────────────────────────┘
```

Duration in amber DM Mono 24px; cals in white DM Mono 24px.
Per-set Mono breakdown (9px). Total reps = `sets × reps` in Mono caption.

---

### Library Screen (Library Tab)

```
┌─────────────────────────────────┐
│ MOVEMENT CATALOG                │  ← Mono 9px
│ Library                    [+] │  ← 26px 800 · amber 32×32px + button
│                                  │
│ [🔍 Search...               ]   │
│ [All][Chest][Back][Quads]...    │
│                                  │
│ Push-Ups                    [›] │
│ CHEST · NONE                    │
│ ─────────────────────────────── │
│ Muscle-Ups                  [›] │
│ BACK · PULL-UP BAR             │
│ ─────────────────────────────── │
│ Bulgarian Split Squats      [›] │
│ QUADS · NONE  [CUSTOM]         │
└─────────────────────────────────┘
```

`+` button in header (32×32px amber) → add custom movement (not yet implemented in prototype).
Same filter/search as Movement Picker. Tapping row → Movement Detail Screen.

---

### Movement Detail Screen

```
┌─────────────────────────────────┐
│ ← Back         Movement         │
│                                  │
│ Bulgarian Split Squats          │  ← 26px 800
│ [CUSTOM]                        │  ← amber dim badge, only if custom
│                                  │
│ PRIMARY MUSCLE                  │
│ ■  Quads                        │  ← 8×8 amber square + 14px 600
│                                  │
│ SECONDARY                       │
│ □  Glutes                       │  ← 8×8 --border2 square + 13px text2
│ ┌─────────────────────────────┐ │
│ │      [ muscle diagram ]     │ │  ← 120px surface placeholder
│ └─────────────────────────────┘ │
│                                  │
│ Equipment                  None │  ← 13px label + 13px 700 mono value
│                                  │
│ INCLUDE IN SESSIONS             │
│ [More often][Less often][Exclude]│  ← 3-way toggle
└─────────────────────────────────┘
```

Frequency toggle active state: amber. 3 equal-width buttons.

---

### Streak Screen

Accessed from a non-tab route (not linked from bottom nav in current prototype — intended as a future link from settings or header).

```
┌─────────────────────────────────┐
│ ← Back            Streak        │
│                                  │
│ ┌──────────┐┌──────────┐┌────┐ │
│ │    0     ││    9     ││ 59 │ │
│ │ CURRENT  ││ LONGEST  ││TOTAL│ │
│ └──────────┘└──────────┘└────┘ │
│                                  │
│ ACTIVITY — LAST 20 WEEKS       │  ← Mono 10px
│ ┌─────────────────────────────┐ │
│ │ █ █ ░ █ █ ░ ░ █ ...        │ │  ← row 1 (Mon)
│ │ ░ █ █ ░ █ █ █ ░ ...        │ │  ← row 2 (Tue)
│ │ ...  (7 rows × 20 cols)     │ │
│ └─────────────────────────────┘ │
│                                  │
│    Manage streak in Settings    │  ← Mono 9px centered
└─────────────────────────────────┘
```

Stat cards (3, flex): `background: var(--surface)`, `border: 1px solid var(--border)`, `border-radius: 4px`, centered.
Current value in `--text3` (dim), Longest + Total in amber.
Heatmap: 7 rows × 20 cols, each cell 9px tall, `border-radius: 1px`, `gap: 3px`. Filled: `var(--accent)`. Empty: `var(--surface2)`.

---

## 9. Navigation Model

```
TrainScreen
  ├─ (+) → MusclePickerScreen → SessionBuilderScreen (new)
  ├─ (edit) → SessionBuilderScreen (edit existing)
  │     └─ (Add) → MovementPickerScreen
  └─ (START) → ActiveSessionScreen → (finish/end) → TrainScreen

LogScreen
  └─ (row) → SessionDetailScreen

LibraryScreen
  └─ (row) → MovementDetailScreen
```

Sub-screens hide the bottom nav. Back / End / Close always returns to root tab.

---

## 10. Motion

| Element | Transition |
|---------|-----------|
| Screen push/pop | Immediate state swap (no animation) |
| Recovery overlay | Absolute overlay, instant show/hide |
| Set tracker squares | `transition: all 0.2s` |
| Progress bar | `transition: width 0.4s` |
| Buttons / chips | `transition: all 0.12s–0.15s` |

No spring curves, no hero transitions, no matched geometry.
