---
marp: true
size: 4:3
paginate: true
title: Pocket Protectors Week 9 Progress Report
---

# Week 9 Progress Report

## (11/10/2025 - 11/16/2025)

> Team: Pocket Protectors
>
> - Anna Dinius, Jeff Perdue, Cody King, Dillon Carpenter

---

## Milestones Completed - Jeff

✅ Generate periodic reports with totals, averages, and budget performance
✅ Export or share reports

- _Fulfills 2 requirements_

---

<div style="display: flex; gap: 10px;">
  <img src="./screenshots/reports-empty-screen.png" width="260px" />
  <img src="./screenshots/reports-generate.png" width="260px" />
  <img src="./screenshots/report-7-days.png" width="260px" />
</div>

---

<div style="display: flex; gap: 10px;">
  <img src="./screenshots/report-saved.png" width="260px" />
  <img src="./screenshots/report-view1.png" width="260px" />
  <img src="./screenshots/report-view2.png" width="260px" />
</div>

---

## Milestones Completed - Cody

✅ Added dashboard to show overall summary of savings goals vs. savings progress
✅ Conducted tests to ensure no existing savings goals features broke

- _Fulfills 2 requirements_

---

<div style="display: flex; gap: 10px;">
  <img src="./screenshots/dashboard-button.png" width="260px" />
  <img src="./screenshots/dashboard1.png" width="260px" />
  <img src="./screenshots/dashboard2.png" width="260px" />
</div>

---

## Milestones Completed - Dillon

✅ UI improvements
✅ More tests
✅ Tested current widgets at varying screen sizes

- _Fulfills 8 requirements_

---

![height:600px](./screenshots/ui-changes.png)

---

## LoC Summary

### Individual Contributions:

- Jeff: ~2,564
- Cody: ~547
- Dillon: ~83

### Codebase LoC Summary After Integration:

- **Total**: 14,630
- **Counting rules**: Excludes empty lines and comment-only lines. Inline comments on code lines are still counted.
- **Files scanned**: All files under `lib` and `test` and their subdirectories.

---

### Codebase LoC Breakdown:

High-level source files, models, and widgets:

- `lib\firebase_options.dart`: 70
- `lib\main.dart`: 331
- `lib\model\budget.dart`: 256
- `lib\model\category.dart`: 121
- `lib\model\report.dart`: 338
- `lib\model\savings_goal.dart`: 131
- `lib\model\transaction.dart`: 143

---

Services and theme:

- `lib\service\analytics_service.dart`: 275
- `lib\service\auth_service.dart`: 32
- `lib\service\budget_service.dart`: 415
- `lib\service\category_service.dart`: 290
- `lib\service\report_export_service.dart`: 528
- `lib\service\report_service.dart`: 197
- `lib\service\savings_goal_service.dart`: 73
- `lib\service\update_transaction_service.dart`: 44
- `lib\service\user_service.dart`: 60
- `lib\theme\main_theme.dart`: 35

---

Views:

- `lib\view\budgets_list.dart`: 403
- `lib\view\chart.dart`: 149
- `lib\view\chart_bar.dart`: 58
- `lib\view\chart_pie.dart`: 104
- `lib\view\charts_overview.dart`: 918
- `lib\view\edit_budget.dart`: 311
- `lib\view\edit_savings_goal.dart`: 192
- `lib\view\generate_report.dart`: 382
- `lib\view\manage_categories.dart`: 579
- `lib\view\new_budget.dart`: 309

---

Views (cont.):

- `lib\view\new_savings_goal.dart`: 157
- `lib\view\new_transaction.dart`: 232
- `lib\view\profile_creation.dart`: 121
- `lib\view\profile_editing.dart`: 233
- `lib\view\profile_summary.dart`: 74
- `lib\view\report_detail.dart`: 768
- `lib\view\report_list.dart`: 306
- `lib\view\savings_dashboard.dart`: 502
- `lib\view\savings_goals_list.dart`: 119
- `lib\view\savings_summary.dart`: 434

---

Views (cont.):

- `lib\view\search_bar_widget.dart`: 148
- `lib\view\sign_in.dart`: 77
- `lib\view\transaction_list.dart`: 112
- `lib\view\widgets\category_badge.dart`: 79
- `lib\view\widgets\category_picker.dart`: 275

---

Tests:

- `test\error_handling\category_error_test.dart`: 247
- `test\fixtures\category_test_data.dart`: 158
- `test\helpers\analytics_test_helpers.dart`: 112
- `test\helpers\test_helpers.dart`: 26
- `test\model\category_test.dart`: 228
- `test\model\default_categories_test.dart`: 105
- `test\model\savings_goal_test.dart`: 404
- `test\service\analytics_service_test.dart`: 311
- `test\service\budget_service_test.dart`: 282
- `test\service\category_service_test.dart`: 186

---

Tests (cont.):

- `test\service\category_service_working_test.dart`: 186
- `test\service\report_service_test.dart`: 406
- `test\service\savings_goal_service_test.dart`: 252
- `test\service\user_service_test.dart`: 112
- `test\transaction_test.dart`: 92
- `test\update_recurring_transactions_test.dart`: 52
- `test\view\profile_creation_test.dart`: 95
- `test\view\profile_editing_test.dart`: 46
- `test\view\profile_summary_test.dart`: 19
- `test\view\search_bar_widget_test.dart`: 157

---

Tests (cont.):

- `test\view\sign_in_test.dart`: 71
- `test\view\widgets\category_badge_test.dart`: 294
- `test\view\widgets\category_picker_test.dart`: 408

---

## Tests

- **Total number of test files**: 23
- **Total number of tests**: 279
- **Total LoC**: 4,249

---

## 🔥 Burndown rate

- 35/35 Sprint 2 requirements completed
  - 100% total
  - 25% per week
  - ~3.6% per day
