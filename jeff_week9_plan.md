# 🗓 Week 9 Plan – Expense App (Reports & Summaries)

**Sprint 2 Theme:** Budgets, Charts, and Reports  
**Focus:** Generate Reports and Summaries for User Insights  
**Duration:** ~5 hours  

---

## 📊 Current State Assessment

### ✅ Already Implemented
- **Report Model** (`lib/model/report.dart`) – Complete with all fields (totals, averages, budget performance, recurring impact, category breakdown)
- **AnalyticsService.generateReport()** – Method exists and can generate Report objects with full metrics
- **Charts & Visualizations** (Week 8) – Pie charts, bar charts, and budget progress charts are complete and reusable
- **BudgetService** – Full CRUD operations and budget calculation methods available
- **Data Integration** – AnalyticsService integrates with BudgetService and transaction data

### 🔨 Needs Implementation
- **ReportService** – Service layer for saving/retrieving reports from Firestore
- **Report UI Views** – `report_list.dart` and `report_detail.dart` for displaying reports
- **Report Generation UI** – User interface for generating reports with date range selection
- **Chart Integration in Reports** – Embed Week 8 charts into report detail views
- **Unit Tests** – Test report generation logic and data accuracy

---

## 🎯 Week 9 Objectives

1. **Create ReportService for Persistence**
   - Implement service layer for saving generated reports to Firestore
   - Add methods to retrieve saved reports (by date range, by ID, all reports)
   - Support report update and deletion if needed
   - Integrate with existing Report model serialization

2. **Develop Report UI Components**
   - Build `report_list.dart` – Screen showing list of generated/saved reports
   - Build `report_detail.dart` – Detailed report view with all metrics and visualizations
   - Create report generation screen with date range selection (weekly, monthly, custom)
   - Include filters and navigation between reports

3. **Integrate Charts into Reports**
   - Embed Week 8 chart widgets (pie charts, bar charts, budget progress) into report detail views
   - Ensure charts display data consistent with report metrics
   - Reuse existing chart components from `charts_overview.dart`

4. **Unit Testing for Report Logic**
   - Test AnalyticsService.generateReport() method (if not already covered)
   - Test ReportService CRUD operations
   - Validate report data accuracy against analytics and budget calculations
   - Test edge cases (empty data, date boundaries, overlapping budgets)

---

## 📋 Implementation Breakdown

| Component | Task | Est. Hours | Dependency | Status |
|------------|------|------------|-------------|--------|
| **ReportService** | Implement service for saving/retrieving reports from Firestore | 1.0 | Report model ✅, AnalyticsService ✅ | 🔨 To Do |
| **Report Generation UI** | Build UI for generating reports with date range selection | 1.0 | ReportService, AnalyticsService ✅ | 🔨 To Do |
| **Report List View** | Build report_list.dart to display saved reports | 0.75 | ReportService | 🔨 To Do |
| **Report Detail View** | Build report_detail.dart with metrics and charts | 1.25 | ReportService, Week 8 charts ✅ | 🔨 To Do |
| **Chart Integration** | Embed charts into report detail views | 0.5 | Week 8 charts ✅, Report detail view | 🔨 To Do |
| **Unit Testing** | Write tests for ReportService and report generation | 0.5 | ReportService, AnalyticsService ✅ | 🔨 To Do |

---

## 🧩 Technical Goals

- **Report Persistence:** Save generated reports to Firestore for later viewing and comparison
- **Comprehensive Reporting:** Summaries provide meaningful insight into spending habits and budget performance
- **Data Integrity:** Ensure consistent results across reports, analytics, and budgets
- **Chart Reusability:** Leverage existing Week 8 chart components in report views
- **User Clarity:** Reports display financial information in clear, digestible formats with visualizations
- **Scalability:** Design report service to support export features in Week 10 (PDF/CSV)

---

## 🧪 Unit Testing Plan

| Test Group | Description | Coverage Goals | Notes |
|-------------|--------------|----------------|-------|
| **ReportService Tests** | Test CRUD operations (create, read, update, delete reports) | ≥85% | New tests needed |
| **Report Generation Tests** | Verify AnalyticsService.generateReport() produces correct metrics | ≥85% | May already be partially covered |
| **Date Range Tests** | Validate weekly, monthly, and custom range filtering in UI | ≥85% | Integration with AnalyticsService |
| **Budget & Analytics Alignment** | Confirm report data consistency with BudgetService and AnalyticsService | ≥85% | Cross-service validation |
| **Edge Cases** | Empty data sets, overlapping budgets, leap months, invalid date ranges | ≥85% | Error handling and validation |
| **Report Model Tests** | Test Report model serialization (toMap/fromMap) | ≥85% | May already exist |

*All tests remain unit-based, focusing on data accuracy, service operations, and aggregation correctness.*

---

## 📈 Success Criteria

- ✅ **ReportService Implemented** – Users can save and retrieve generated reports from Firestore
- ✅ **Report Generation UI** – Users can generate reports for weekly, monthly, or custom date ranges
- ✅ **Report List View** – Users can view a list of all saved reports with key metrics
- ✅ **Report Detail View** – Users can view detailed reports with all metrics, charts, and visualizations
- ✅ **Chart Integration** – Week 8 charts (pie, bar, budget progress) are embedded in report detail views
- ✅ **Data Accuracy** – Reports integrate budget and analytics data accurately with consistent calculations
- ✅ **Unit Testing** – ReportService and report generation logic verified through unit testing (≥85% coverage)
- ✅ **Navigation** – Reports accessible from main app navigation (e.g., app bar menu item)
- ✅ **Export Ready** – Report structure supports Week 10 export functionality (PDF/CSV)

---

## 📋 Alignment with Sprint 2 Plan

### Sprint 2 Requirements (Feature 3: Reports)
From `docs/jeff_weekly_reports/jeff_sprint2_plan.md`:

1. **Generate Reports** ✅ (Week 9 Focus)
   - Generate periodic reports (weekly, monthly, custom) – **To implement**
   - Include totals, averages, and budget performance – **AnalyticsService.generateReport() already provides this**
   - Integrate report summaries with chart visuals – **To implement (embed Week 8 charts)**

2. **Export or Share Reports** 🔜 (Week 10)
   - Provide export or share functionality (PDF or CSV optional) – **Deferred to Week 10 per Sprint 2 plan**

### Sprint 2 Progress Status
- **Feature 1: Budgets** – ✅ Complete (Week 7) – Edit/delete already implemented
- **Feature 2: Charts & Visualizations** – ✅ Complete (Week 8)
- **Feature 3: Reports & Summaries** – 🔨 In Progress (Week 9)
  - Generate Reports requirement – 🔨 To implement
  - Export or Share Reports requirement – 🔜 Week 10 (optional)

### Notes
- Budget editing and deletion are already implemented (Week 7), so Week 10 can focus on polish
- Export functionality is explicitly marked as optional in Sprint 2 plan and deferred to Week 10
- Week 9 focuses on core report generation and display functionality

---

## 📁 Files to Create/Update

### New Files
- `lib/service/report_service.dart` – Service for report persistence (save, retrieve, delete reports)
- `lib/view/report_list.dart` – Screen showing list of saved reports
- `lib/view/report_detail.dart` – Detailed report view with metrics and charts
- `lib/view/generate_report.dart` – Screen for generating new reports with date range selection
- `test/service/report_service_test.dart` – Unit tests for ReportService

### Files to Update
- `lib/main.dart` – Add navigation to reports screen (e.g., app bar menu)
- `test/service/analytics_service_test.dart` – Add tests for report generation if not already covered

### Files to Reference/Reuse
- `lib/model/report.dart` – Report model (already complete) ✅
- `lib/service/analytics_service.dart` – Report generation method (already exists) ✅
- `lib/view/charts_overview.dart` – Chart components to embed in reports ✅
- `lib/view/chart_pie.dart` – Pie chart widget ✅
- `lib/service/budget_service.dart` – Budget data integration ✅

---

## 🔮 Preview of Week 10

Week 10 will focus on **Polish and Finalization**, refining all Sprint 2 features. Tasks will include:
- **Export Functionality** – Implement PDF or CSV export for reports (optional requirement from Sprint 2 plan)
- **Budget Management** – Allow users to edit or delete budgets (if not already implemented)
- **Chart Enhancements** – Refine chart responsiveness and visual clarity
- **Report Improvements** – Enhance report readability and formatting
- **Final Testing** – Comprehensive testing, bug fixes, and documentation updates
- **Sprint 2 Closure** – Complete documentation for handoff and Sprint 2 closure
