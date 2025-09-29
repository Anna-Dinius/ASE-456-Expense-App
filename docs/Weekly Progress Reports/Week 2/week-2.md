---
marp: true
size: 4:3
paginate: true
title: Pocket Protectors Week 2 Progress Report
---

# Week 2 Progress Report

## (9/15/2025 - 9/21/2025)

> Team: Pocket Protectors
>
> - Anna Dinius, Jeff Perdue, Cody King, Dillon Carpenter

---

## Milestones Completed (1/3)

### Cody

✅ Finalize requirements for database and user profiles features.
✅ Set up database and give other team members access.
✅ Design transaction and user profile model.
✅ Implement database logic into already existing code.

---

## Milestones Completed (2/3)

### Jeff

✅ Finalize requirements for categories.
✅ Design `Category` model (id, title, color/icon).
✅ Update `Transaction` model to include `categoryId`.
✅ Integrate category feature.

---

## Milestones Completed (3/3)

### Dillon

✅ Toggle recurring payments & select interval
✅ Added functionality to `Transactions` (now they store intervals & whether a payment is recurring).
✅ Feature documentation.

---

## Carryover Items

- Ensure that only transaction data for the specific profile logged in is showing.

---

## LoC Summary (1/3)

### Cody's branch:

- **Total**: 591
- **Counting rules**: Excludes empty lines and comment-only lines. Inline comments on code lines are still counted.
- **Files scanned**: All files under lib and its subdirectories.

---

- Breakdown:
  - `lib/main.dart`: 132 lines
  - `lib/model/transaction.dart`: 21 lines
  - `lib/model/user.dart`: 12 lines
  - `lib/view/chart.dart`: 57 lines
  - `lib/view/chart_bar.dart`: 51 lines
  - `lib/view/new_transaction.dart`: 103 lines
  - `lib/view/transaction_list.dart`: 106 lines
  - `lib/theme/main_theme.dart`: 35 lines
  - `lib/firebase_options.dart`: 74 lines

---

## LoC Summary (2/3)

### Jeff's branch:

- **Total**: 829
- **Counting rules**: Excludes empty lines and comment-only lines. Inline comments on code lines are still counted.
- **Files scanned**: All files under lib and its subdirectories.

---

- Breakdown:
  - `lib/main.dart`: 146 lines
  - `lib/model/transaction.dart`: 87 lines
  - `lib/model/category.dart`: 106 lines
  - `lib/view/chart.dart`: 57 lines
  - `lib/view/chart_bar.dart`: 48 lines
  - `lib/view/new_transaction.dart`: 154 lines
  - `lib/view/transaction_list.dart`: 122 lines
  - `lib/theme/main_theme.dart`: 35 lines
  - `lib/firebase_options.dart`: 74 lines

---

## LoC Summary (3/3)

### Dillon's branch:

- **Total**: 858 lines
- **Counting rules**: Excludes empty lines and comment-only lines. Inline comments on code lines are still counted.
- **Files scanned**: All files under lib and its subdirectories.

---

- Breakdown:
  - `lib/main.dart`: 151 lines
  - `lib/model/transaction.dart`: 108 lines
  - `lib/model/category.dart`: 106 lines
  - `lib/view/chart.dart`: 57 lines
  - `lib/view/chart_bar.dart`: 51 lines
  - `lib/view/new_transaction.dart`: 154 lines
  - `lib/view/transaction_list.dart`: 122 lines
  - `lib/theme/main_theme.dart`: 35 lines
  - `lib/firebase_options.dart`: 74 lines

---

## 🔥 Burndown rate

- 9/10 week 2 milestones completed
  - 90% per week
  - ~13% per day
- 9/32 Sprint 1 milestones completed
  - ~28% per week
  - ~4% per day
