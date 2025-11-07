---
marp: true
size: 4:3
paginate: true
title: Pocket Protectors Week 7 Progress Report
---

# Week 7 Progress Report

## (10/27/2025 - 11/2/2025)

> Team: Pocket Protectors
>
> - Anna Dinius, Jeff Perdue, Cody King, Dillon Carpenter

---

## Milestones Completed - Jeff

✅ Budget Creation UI
✅ Budget List & Management UI
✅ Budget Progress Visualization
✅ Integration & Navigation

- _Fulfills 2 requirements_

---

## Milestones Completed - Cody

✅ Polishing & bug fixing for saving goals feature
✅ More manual testing to find any bugs and ensure functionality working
✅ Created more unit tests for savings goals

- _Fulfills 1 requirement_

---

## Milestones Completed - Dillon

✅ Finalized the layout of SearchBarWidget
✅ Separated option to filter by category
✅ Added dropdown buttons for additional features (to be implemented next week)

- _Fulfills 1 requirement_
- _Fulfills parts of 6 other requirements_

---

## LoC Summary

### Individual Contributions:

- Cody: ~735
- Jeff: ~1,050
- Dillon: ~68

### Codebase LoC Summary After Integration:

- **Total**: 9,403
- **Counting rules**: Excludes empty lines and comment-only lines. Inline comments on code lines are still counted.
- **Files scanned**: All files under `lib` and `test` and their subdirectories.

---

### Codebase LoC Breakdown:

High-level source files, models, and widgets:

- `lib\firebase_options.dart`: 70
- `lib\main.dart`: 309
- `lib\model\budget.dart`: 256
- `lib\model\category.dart`: 121
- `lib\model\report.dart`: 338
- `lib\model\savings_goal.dart`: 87
- `lib\model\transaction.dart`: 143
- `lib\search_bar_widget.dart`: 129

---

Services and theme:

- `lib\service\analytics_service.dart`: 275
- `lib\service\auth_service.dart`: 32
- `lib\service\budget_service.dart`: 415
- `lib\service\category_service.dart`: 290
- `lib\service\savings_goal_service.dart`: 73
- `lib\service\update_transaction_service.dart`: 44
- `lib\service\user_service.dart`: 60
- `lib\theme\main_theme.dart`: 35

---

Views:

- `lib\view\budgets_list.dart`: 403
- `lib\view\chart.dart`: 57
- `lib\view\chart_bar.dart`: 51
- `lib\view\edit_budget.dart`: 311
- `lib\view\edit_savings_goal.dart`: 191
- `lib\view\manage_categories.dart`: 579
- `lib\view\new_budget.dart`: 309
- `lib\view\new_savings_goal.dart`: 157
- `lib\view\new_transaction.dart`: 232
- `lib\view\profile_creation.dart`: 121

---

Views (cont.):

- `lib\view\profile_editing.dart`: 233
- `lib\view\profile_summary.dart`: 74
- `lib\view\savings_goals_list.dart`: 119
- `lib\view\savings_summary.dart`: 204
- `lib\view\sign_in.dart`: 77
- `lib\view\transaction_list.dart`: 112
- `lib\view\widgets\category_badge.dart`: 79
- `lib\view\widgets\category_picker.dart`: 275

---

Tests:

- `test\error_handling\category_error_test.dart`: 247
- `test\fixtures\category_test_data.dart`: 158
- `test\helpers\test_helpers.dart`: 26
- `test\model\category_test.dart`: 228
- `test\model\default_categories_test.dart`: 105
- `test\model\savings_goal_test.dart`: 286
- `test\service\budget_service_test.dart`: 279
- `test\service\category_service_test.dart`: 186
- `test\service\category_service_working_test.dart`: 186

---

Tests (cont.):

- `test\service\savings_goal_service_test.dart`: 252
- `test\service\user_service_test.dart`: 112
- `test\transaction_test.dart`: 92
- `test\update_recurring_transactions_test.dart`: 52
- `test\view\profile_creation_test.dart`: 95
- `test\view\profile_editing_test.dart`: 46
- `test\view\profile_summary_test.dart`: 19
- `test\view\sign_in_test.dart`: 71
- `test\view\widgets\category_badge_test.dart`: 294
- `test\view\widgets\category_picker_test.dart`: 408

---

## 🔥 Burndown rate

- 12/35 Sprint 2 requirements completed
  - ~34% total
  - ~17% per week
  - ~2.4% per day
