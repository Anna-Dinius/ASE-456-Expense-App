---
marp: true
size: 4:3
paginate: true
title: Pocket Protectors Week 4 Progress Report
---

# Week 4 Progress Report

## (9/29/2025 - 10/5/2025)

> Team: Pocket Protectors
>
> - Anna Dinius, Jeff Perdue, Cody King, Dillon Carpenter

---

## Week 4 Milestones Completed (6/6)

✅ The user should be able to cancel/delete scheduled and recurring payments
✅ Develop UI to display summary of user profile. (completed in week 3)
✅ Ensure data from the database is correctly fetched and displayed in the UI
✅ Display category name/color in TransactionList. (completed in week 3)
✅ Add ability for users to create new categories. (completed in week 3)
✅ Ensure transactions update correctly with categories. (completed in week 3)

---

## Completed Carryover Items (3/3)

✅ Create UI and functionality for users to create new profiles and edit their basic information (name, email, etc.).
✅ Connect user profile forms to the database to save changes reliably.
✅ Start working on UI for profile summary.

---

## Surplus Delivery

✅ Implement edit/delete for categories.

---

## LoC Summary

### Cody's branch

- **Total**: 2730
- **Counting rules**: Excludes empty lines and comment-only lines. Inline comments on code lines are still counted.
- **Files scanned**: All files under `lib` and `test` and their subdirectories.

---

- ## Breakdown (1/3)

  - `lib\firebase_options.dart`: 70
  - `lib\main.dart`: 242
  - `lib\model\category.dart`: 121
  - `lib\model\transaction.dart`: 144
  - `lib\model\user.dart`: 12
  - `lib\service\auth_service.dart`: 29
  - `lib\service\category_service.dart`: 290
  - `lib\service\user_service.dart`: 32
  - `lib\theme\main_theme.dart`: 34

---

- ## Breakdown (2/3)

  - `lib\view\chart.dart`: 57
  - `lib\view\chart_bar.dart`: 51
  - `lib\view\manage_categories.dart`: 579
  - `lib\view\new_transaction.dart`: 228
  - `lib\view\profile_creation.dart`: 120
  - `lib\view\profile_editing.dart`: 92
  - `lib\view\profile_summary.dart`: 74
  - `lib\view\sign_in.dart`: 75
  - `lib\view\transaction_list.dart`: 112

---

- ## Breakdown (3/3)

  - `lib\view\widgets\category_badge.dart`: 79
  - `lib\view\widgets\category_picker.dart`: 275
  - `test\widget_test.dart`: 14

---

## LoC Summary (2/3)

### Jeff's branch:

- **Total**: 2613
- **Counting rules**: Excludes empty lines and comment-only lines. Inline comments on code lines are still counted.
- **Files scanned**: All files under lib and its subdirectories.

---

- ## Breakdown (1/3)

  - `lib\firebase_options.dart`: 70
  - `lib\main.dart`: 236
  - `lib\model\category.dart`: 121
  - `lib\model\transaction.dart`: 108
  - `lib\model\user.dart`: 12
  - `lib\service\auth_service.dart`: 29
  - `lib\service\category_service.dart`: 290
  - `lib\service\user_service.dart`: 32
  - `lib\theme\main_theme.dart`: 34

---

- ## Breakdown (2/3)

  - `lib\view\chart.dart`: 57
  - `lib\view\chart_bar.dart`: 51
  - `lib\view\manage_categories.dart`: 579
  - `lib\view\new_transaction.dart`: 154
  - `lib\view\profile_creation.dart`: 119
  - `lib\view\profile_editing.dart`: 92
  - `lib\view\profile_summary.dart`: 74
  - `lib\view\sign_in.dart`: 75
  - `lib\view\transaction_list.dart`: 112

---

- ## Breakdown (3/3)

  - `lib\view\widgets\category_badge.dart`: 79
  - `lib\view\widgets\category_picker.dart`: 275
  - `test\widget_test.dart`: 14

---

## LoC Summary (3/3)

### Dillon's branch:

- **Total**: 2315
- **Counting rules**: Excludes empty lines and comment-only lines. Inline comments on code lines are still counted.
- **Files scanned**: All files under lib and its subdirectories.

---

- ## Breakdown (1/2):

  - `lib\firebase_options.dart`: 70
  - `lib\main.dart`: 248
  - `lib\model\category.dart`: 121
  - `lib\model\transaction.dart`: 144
  - `lib\model\user.dart`: 12
  - `lib\service\category_service.dart`: 290
  - `lib\theme\main_theme.dart`: 35
  - `lib\view\chart.dart`: 57
  - `lib\view\chart_bar.dart`: 51

---

- ## Breakdown (2/2):

  - `lib\view\manage_categories.dart`: 579
  - `lib\view\new_transaction.dart`: 228
  - `lib\view\transaction_list.dart`: 112
  - `lib\view\widgets\category_badge.dart`: 79
  - `lib\view\widgets\category_picker.dart`: 275
  - `test\widget_test.dart`: 14

---

## 🔥 Burn down rate

- 6/6 Week 4 milestones completed
  - 100% total
  - ~14% per day
- 3/3 Week 3 carryover items completed
  - 100% total
  - ~14% per day
- 26/32 Sprint 1 milestones completed
  - ~81% total
  - ~27% per week
  - ~3.9% per day
