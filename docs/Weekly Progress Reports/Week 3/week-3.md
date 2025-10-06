---
marp: true
size: 4:3
paginate: true
title: Pocket Protectors Week 3 Progress Report
---

# Week 3 Progress Report

## (9/22/2025 - 9/28/2025)

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

## Surplus Delivery

✅ Display category name/color in TransactionList
✅ Add ability for users to create new categories
✅ Ensure transactions update correctly with categories
✅ Implement edit/delete for categories

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

- **Total**: 2156
- **Counting rules**: Excludes empty lines and comment-only lines. Inline comments on code lines are still counted.
- **Files scanned**: All files under lib and its subdirectories.

---

- ## Breakdown (1/2):

  - `root\lib\main.dart`: 199
  - `root\lib\model\category.dart`: 121
  - `root\lib\model\transaction.dart`: 108
  - `root\lib\model\user.dart`: 12
  - `root\lib\service\category_service.dart`: 290
  - `root\lib\theme\main_theme.dart`: 35
  - `root\lib\view\chart.dart`: 57
  - `root\lib\view\chart_bar.dart`: 51
  - `root\lib\view\manage_categories.dart`: 579

---

- ## Breakdown (2/2):

  - `root\lib\view\new_transaction.dart`: 154
  - `root\lib\view\transaction_list.dart`: 112
  - `root\lib\view\widgets\category_badge.dart`: 79
  - `root\lib\view\widgets\category_picker.dart`: 2751

---

## LoC Summary (3/3)

### Dillon's branch:

- **Total**: 998
- **Counting rules**: Excludes empty lines and comment-only lines. Inline comments on code lines are still counted.
- **Files scanned**: All files under lib and its subdirectories.

---

- ## Breakdown:

  - `root\lib\firebase_options.dart`: 70
  - `root\lib\main.dart`: 155
  - `root\lib\model\category.dart`: 106
  - `root\lib\model\transaction.dart`: 128
  - `root\lib\model\user.dart`: 12
  - `root\lib\theme\main_theme.dart`: 35
  - `root\lib\view\chart.dart`: 57
  - `root\lib\view\chart_bar.dart`: 51
  - `root\lib\view\new_transaction.dart`: 249
  - `root\lib\view\transaction_list.dart`: 121

---

## 🔥 Burn down rate

- 6/9 Week 3 milestones completed
  - ~67% total
  - ~9.5% per day
- 19/32 Sprint 1 milestones completed
  - ~59% total
  - ~30% per week
  - ~2% per day
