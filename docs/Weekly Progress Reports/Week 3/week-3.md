---
marp: true
size: 4:3
paginate: true
title: Pocket Protectors Week /# Progress Report
---

# Week # Progress Report

## (M/D/2025 - M/D/2025)

> Team: Pocket Protectors
>
> - Anna Dinius, Jeff Perdue, Cody King, Dillon Carpenter

---

## Milestones Completed

✅ Scheduled payments can be made
✅ The database now stores all occurrences of recurring payments
✅ Implement Category model in code
✅ Seed app with default categories
✅ Add category dropdown to NewTransaction form
✅ Save selected category with new transactions

---

## Carryover Items

- Create UI and functionality for users to create new profiles and edit their basic information (name, email, etc.)
- Connect user profile forms to the database to save changes reliably
- Start working on UI for profile summary
- Ensure that only transaction data for the specific profile logged in is showing

---

## LoC Summary

### Cody's branch:

- **Total**: 566
- **Counting rules**: Excludes empty lines and comment-only lines. Inline comments on code lines are still counted.
- **Files scanned**: All files under lib and its subdirectories.

---

- ## Breakdown:

- `root\lib\firebase_options.dart`: 70
- `root\lib\main.dart`: 137
- `root\lib\model\transaction.dart`: 20
- `root\lib\model\user.dart`: 12
- `root\lib\theme\main_theme.dart`: 35
- `root\lib\view\chart.dart`: 57
- `root\lib\view\chart_bar.dart`: 51
- `root\lib\view\new_transaction.dart`: 103
- `root\lib\view\transaction_list.dart`: 67

---

## LoC Summary (2/3)

### Jeff's branch:

- **Total**: 841
- **Counting rules**: Excludes empty lines and comment-only lines. Inline comments on code lines are still counted.
- **Files scanned**: All files under lib and its subdirectories.

---

- ## Breakdown:

- `root\lib\firebase_options.dart`: 70
- `root\lib\main.dart`: 147
- `root\lib\model\category.dart`: 106
- `root\lib\model\transaction.dart`: 87
- `root\lib\theme\main_theme.dart`: 35
- `root\lib\view\chart.dart`: 57
- `root\lib\view\chart_bar.dart`: 51
- `root\lib\view\new_transaction.dart`: 153
- `root\lib\view\transaction_list.dart`: 121

---

## LoC Summary (3/3)

### Dillon's branch:

- **Total**: 894
- **Counting rules**: Excludes empty lines and comment-only lines. Inline comments on code lines are still counted.
- **Files scanned**: All files under lib and its subdirectories.

---

- ## Breakdown:

Files scanned:

- `root\lib\firebase_options.dart`: 70
- `root\lib\main.dart`: 151
- `root\lib\model\category.dart`: 106
- `root\lib\model\transaction.dart`: 108
- `root\lib\theme\main_theme.dart`: 35
- `root\lib\view\chart.dart`: 57
- `root\lib\view\chart_bar.dart`: 51
- `root\lib\view\new_transaction.dart`: 181
- `root\lib\view\transaction_list.dart`: 121
- `root\test\widget_test.dart`: 14

---

## 🔥 Burn down rate

- 6/9 Week 3 milestones completed
  - ~67% total
  - ~9.5% per day
- 15/32 Sprint 1 milestones completed
  - ~47% total
  - ~23% per week
  - ~2% per day
