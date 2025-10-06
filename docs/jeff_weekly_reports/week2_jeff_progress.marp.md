---
marp: true
html: true
size: 4:3
paginate: true
---

<!-- _class: lead -->
<!-- _class: frontpage -->
<!-- _paginate: skip -->

# 📋 Categories Feature  
## Week 2 – What I’ve Done

**Expense categorization functionality**  
Helping users organize their spending by categories like Food, Bills, Transport, etc.

---

## ✅ Completed Features

### 1. Data Models
- **Category Model** (`lib/model/category.dart`)  
  - Stores: ID, title, color, icon  
  - 7 default categories (Food, Transport, Bills, Entertainment, Shopping, Health, Other)  
  - JSON serialization + helper methods  

- **Transaction Model** (`lib/model/transaction.dart`)  
  - Added `categoryId` field  
  - Updated constructor + JSON serialization  
  - Preserved all existing functionality  

---

## ✅ Completed Features (cont.)

### 2. User Interface
- **Add Transaction Form** (`lib/view/new_transaction.dart`)  
  - Category dropdown with icons & colors  
  - Validation requires category selection  
  - Fixed validation crashes  

- **Transaction List** (`lib/view/transaction_list.dart`)  
  - Shows category icon & color  
  - Displays category name badges  
  - Improved layout & spacing  

---

## ✅ Completed Features (cont.)

### 3. App Integration
- **Main App** (`lib/main.dart`)  
  - Categories list added to app state  
  - Passes categories to child widgets  
  - Transaction creation updated with category  
  - Firebase integration enhanced  

### 4. Code Quality
- Comprehensive comments and docs  
- “NEW:” labels for easy identification  
- Usage examples included  

---

## 🎨 Visual Improvements

**Category Selection**  
- Dropdown with icons + matching colors  
- Intuitive selection process  
- Visual feedback for chosen category  

**Transaction Display**  
- Colored avatars with icons  
- Category badges with colors  
- Better card layout and spacing  

---

## 🚀 How to Test

1. Add a new transaction (+ button)  
2. Fill in title and amount  
3. Select a category (required)  
4. Choose a date and submit  
5. View categorized transactions in list  

✔ Verify category icons, colors, and badges  
✔ Try all 7 default categories  
✔ Ensure category selection is required  

---

## 📁 Files Modified

| File | Changes Made |
|------|--------------|
| `lib/model/category.dart` | ✨ NEW – Category model |
| `lib/model/transaction.dart` | ➕ Added `categoryId` + methods |
| `lib/main.dart` | ➕ Added categories list & signatures |
| `lib/view/new_transaction.dart` | ➕ Added dropdown & validation |
| `lib/view/transaction_list.dart` | ➕ Added category display & layout |

---

## 🔧 Technical Details

**Default Categories**  
- Food 🍽️ (Orange)  
- Transport 🚗 (Blue)  
- Bills 📄 (Red)  
- Entertainment 🎬 (Purple)  
- Shopping 🛍️ (Green)  
- Health 🏥 (Teal)  
- Other 📂 (Grey)  

---

**Data Structure**  
```dart
Transaction {
  String id;
  String title;
  double amount;
  DateTime date;
  String categoryId; // NEW
}

Category {
  String id;
  String title;
  Color color;
  IconData icon;
}
