Sprint 2 (10/13 - 11/16)

Feature Count: 3
Requirement Count: 7
Total LoC: 


Milestones by Week
Week 6 (10/13 – 10/19): Requirements, Design, & Refactor
Finalize requirements for Budgets, Charts, and Reports.
Design models:
Budget (id, name, amount, startDate, endDate, categoryId)
Report (id, period, totalSpent, averageSpent, budgetPerformance)
Refactor Sprint 1 features using Software Design patterns.
Plan data integration between transactions, categories, and budgets.
Week 7 (10/20 – 10/26): Feature 1 – Budgets
Implement Budget model and logic.
Allow users to set budgets (overall or per category).
Link budgets to transaction data.
Display remaining balance and progress indicator.
Begin basic testing of budget creation and persistence.
Week 8 (10/27 – 11/2): Feature 2 – Charts & Visualizations
Implement charts summarizing expenses by category, timeframe, or budget.
Use pie charts, bar graphs, or line charts for visual clarity.
Ensure charts update dynamically as transactions change.
Maintain color consistency with category colors.
Conduct early usability feedback on visual clarity.
Week 9 (11/3 – 11/9): Feature 3 – Reports & Summaries
Generate periodic reports (weekly, monthly, custom).
Include totals, averages, and budget performance.
Provide export or share functionality (PDF or CSV optional).
Integrate report summaries with chart visuals.
Verify data accuracy across budgets, charts, and reports.
Week 10 (11/10 – 11/16): Manage & Polish
Allow users to edit or delete budgets.
Refine chart UI responsiveness.
Improve report readability and formatting.
Conduct final testing, bug fixes, and documentation updates.
Requirements
Epic Requirement
As a user,
I want to analyze and manage my spending through budgets, charts, and reports,
so that I can better control my finances and see where my money goes.

Feature 1: Budgets
Create and Manage Budgets
As a user,
I want to create, edit, and delete budgets for specific categories or time periods,
so that I can stay within my spending limits.

Track Budget Progress
As a user,
I want to see how much I have spent relative to my budget,
so that I know when I’m close to reaching it.

Feature 2: Charts & Visualizations
Visualize Spending Patterns
As a user,
I want to view charts of my expenses by category or time,
so that I can easily spot trends in my spending.

Dynamic Updates
As a user,
I want my charts to update automatically when I add or edit transactions,
so that I always have accurate, real-time insights.

Feature 3: Reports
Generate Reports
As a user,
I want to generate summaries of my spending for specific periods,
so that I can review my financial performance over time.

Export or Share Reports
As a user,
I want to save or share my reports (e.g., as PDF or CSV),
so that I can store them for records or discuss them with others.

