# Category Feature Unit Test Plan

## Overview

This document outlines a comprehensive unit test plan for the Category feature implemented during Sprint 1 (Weeks 2-3). The Category feature enables users to organize their expenses by creating, managing, and assigning categories to transactions.

## Feature Scope Analysis

Based on the weekly reports and codebase analysis, the Category feature includes:

### Core Components
1. **Category Model** (`lib/model/category.dart`) - Data structure with validation
2. **CategoryService** (`lib/service/category_service.dart`) - CRUD operations and business logic  
3. **DefaultCategories** - Predefined category set with 7 default categories
4. **CategoryBadge** (`lib/view/widgets/category_badge.dart`) - Visual display component
5. **CategoryPicker** (`lib/view/widgets/category_picker.dart`) - Selection interface
6. **ManageCategoriesScreen** (`lib/view/manage_categories.dart`) - Management interface

### Key Features Implemented
- ✅ Category creation with custom colors and icons
- ✅ Category editing and deletion with transaction reassignment
- ✅ User-specific category storage in Firebase
- ✅ Default category seeding (7 predefined categories)
- ✅ Category validation and error handling
- ✅ Transaction-category integration
- ✅ Search and filtering capabilities
- ✅ Visual category indicators with badges

---

## Unit Test Categories

### 1. Category Model Tests (`test/model/category_test.dart`)

#### 1.1 Constructor Tests
- [ ] **test_category_constructor_required_fields** - Verify all required fields are properly set
- [ ] **test_category_constructor_null_handling** - Ensure proper handling of null values
- [ ] **test_category_constructor_default_values** - Test with various valid inputs

#### 1.2 copyWith Method Tests
- [ ] **test_copyWith_no_parameters** - Should return identical category
- [ ] **test_copyWith_partial_update** - Should update only specified fields
- [ ] **test_copyWith_all_parameters** - Should update all fields
- [ ] **test_copyWith_null_parameters** - Should preserve original values when null passed

#### 1.3 JSON Serialization Tests
- [ ] **test_toJson_complete_data** - Verify all fields are serialized correctly
- [ ] **test_fromJson_complete_data** - Verify JSON deserialization works
- [ ] **test_json_roundtrip** - toJson → fromJson should preserve data
- [ ] **test_fromJson_missing_fields** - Handle missing JSON fields gracefully
- [ ] **test_fromJson_invalid_data** - Handle invalid JSON data types

#### 1.4 Firestore Serialization Tests
- [ ] **test_toMap_complete_data** - Verify Firestore map serialization
- [ ] **test_fromMap_complete_data** - Verify Firestore map deserialization
- [ ] **test_firestore_roundtrip** - toMap → fromMap should preserve data
- [ ] **test_fromMap_documentId_handling** - Proper document ID assignment

#### 1.5 Equality and Hash Tests
- [ ] **test_equality_identical_objects** - Same object reference should be equal
- [ ] **test_equality_same_data** - Objects with same data should be equal
- [ ] **test_equality_different_data** - Objects with different data should not be equal
- [ ] **test_hashCode_consistency** - Hash codes should be consistent
- [ ] **test_hashCode_equal_objects** - Equal objects should have same hash code

#### 1.6 toString Tests
- [ ] **test_toString_format** - Verify toString includes all fields
- [ ] **test_toString_readability** - Ensure output is human-readable

### 2. DefaultCategories Tests (`test/model/default_categories_test.dart`)

#### 2.1 Default Categories Structure Tests
- [ ] **test_default_categories_not_empty** - Should contain categories
- [ ] **test_default_categories_count** - Should have exactly 7 categories
- [ ] **test_default_categories_unique_ids** - All category IDs should be unique
- [ ] **test_default_categories_unique_titles** - All category titles should be unique
- [ ] **test_default_categories_required_categories** - Should include 'other' category

#### 2.2 Default Categories Content Tests
- [ ] **test_food_category_properties** - Verify Food category properties
- [ ] **test_transport_category_properties** - Verify Transport category properties
- [ ] **test_bills_category_properties** - Verify Bills category properties
- [ ] **test_entertainment_category_properties** - Verify Entertainment category properties
- [ ] **test_shopping_category_properties** - Verify Shopping category properties
- [ ] **test_health_category_properties** - Verify Health category properties
- [ ] **test_other_category_properties** - Verify Other category properties

#### 2.3 Default Categories Validation Tests
- [ ] **test_all_categories_valid_colors** - All categories should have valid colors
- [ ] **test_all_categories_valid_icons** - All categories should have valid icons
- [ ] **test_all_categories_valid_titles** - All titles should meet validation requirements

### 3. CategoryService Tests (`test/service/category_service_test.dart`)

#### 3.1 Setup and Mocking
- [ ] **setup_firebase_mocks** - Mock Firebase Firestore for testing
- [ ] **setup_test_data** - Create test categories and users
- [ ] **teardown_cleanup** - Clean up test data after tests

#### 3.2 CRUD Operation Tests

##### Create Category Tests
- [ ] **test_create_category_success** - Successful category creation
- [ ] **test_create_category_validation_failure** - Invalid data should fail
- [ ] **test_create_category_duplicate_name** - Duplicate names should fail
- [ ] **test_create_category_firebase_error** - Firebase errors should be handled
- [ ] **test_create_category_empty_title** - Empty title should fail
- [ ] **test_create_category_title_too_long** - Title > 50 chars should fail
- [ ] **test_create_category_invalid_characters** - Invalid characters should fail

##### Read Category Tests
- [ ] **test_get_all_categories_success** - Should return all user categories
- [ ] **test_get_all_categories_empty** - Should return empty list for new user
- [ ] **test_get_category_by_id_success** - Should return specific category
- [ ] **test_get_category_by_id_not_found** - Should return null for non-existent category
- [ ] **test_get_category_by_id_firebase_error** - Should handle Firebase errors

##### Update Category Tests
- [ ] **test_update_category_success** - Successful category update
- [ ] **test_update_category_not_found** - Non-existent category should fail
- [ ] **test_update_category_duplicate_name** - Duplicate names should fail
- [ ] **test_update_category_validation_failure** - Invalid data should fail
- [ ] **test_update_category_firebase_error** - Firebase errors should be handled

##### Delete Category Tests
- [ ] **test_delete_category_success** - Successful category deletion
- [ ] **test_delete_category_not_found** - Non-existent category should fail
- [ ] **test_delete_other_category_protected** - 'Other' category should be protected
- [ ] **test_delete_category_transaction_reassignment** - Transactions should be reassigned
- [ ] **test_delete_category_replacement_not_found** - Invalid replacement should fail
- [ ] **test_delete_category_fallback_to_other** - Should fallback to 'other' category

#### 3.3 Utility Method Tests

##### Seeding Tests
- [ ] **test_seed_default_categories_new_user** - Should create defaults for new user
- [ ] **test_seed_default_categories_existing_user** - Should not duplicate existing
- [ ] **test_force_reseed_categories** - Should clear and recreate all categories
- [ ] **test_seed_categories_firebase_error** - Should handle Firebase errors

##### Migration Tests
- [ ] **test_migrate_legacy_transactions** - Should assign 'other' to legacy transactions
- [ ] **test_migrate_no_legacy_transactions** - Should handle no legacy data gracefully
- [ ] **test_migrate_firebase_error** - Should handle Firebase errors

##### Transaction Count Tests
- [ ] **test_get_transaction_count_success** - Should return correct count
- [ ] **test_get_transaction_count_zero** - Should return 0 for unused categories
- [ ] **test_get_transaction_count_firebase_error** - Should handle Firebase errors

#### 3.4 Validation Tests
- [ ] **test_validate_category_valid_data** - Valid data should pass validation
- [ ] **test_validate_category_empty_title** - Empty title should fail
- [ ] **test_validate_category_title_too_short** - Title < 2 chars should fail
- [ ] **test_validate_category_title_too_long** - Title > 50 chars should fail
- [ ] **test_validate_category_invalid_characters** - Invalid chars should fail
- [ ] **test_validate_category_whitespace_only** - Whitespace-only should fail

### 4. CategoryBadge Widget Tests (`test/view/widgets/category_badge_test.dart`)

#### 4.1 Widget Rendering Tests
- [ ] **test_category_badge_renders** - Widget should render without errors
- [ ] **test_category_badge_with_icon** - Should display icon when showIcon is true
- [ ] **test_category_badge_without_icon** - Should hide icon when showIcon is false
- [ ] **test_category_badge_custom_font_size** - Should apply custom font size
- [ ] **test_category_badge_custom_padding** - Should apply custom padding

#### 4.2 Visual Properties Tests
- [ ] **test_category_badge_color_scheme** - Should use category color for styling
- [ ] **test_category_badge_icon_color** - Icon should match category color
- [ ] **test_category_badge_text_color** - Text should match category color
- [ ] **test_category_badge_background_color** - Background should use category color with alpha

#### 4.3 CategoryIconBadge Tests
- [ ] **test_category_icon_badge_renders** - Icon badge should render
- [ ] **test_category_icon_badge_custom_size** - Should apply custom size
- [ ] **test_category_icon_badge_circular_shape** - Should be circular
- [ ] **test_category_icon_badge_icon_sizing** - Icon should scale with badge size

### 5. CategoryPicker Widget Tests (`test/view/widgets/category_picker_test.dart`)

#### 5.1 Widget Initialization Tests
- [ ] **test_category_picker_initialization** - Widget should initialize properly
- [ ] **test_category_picker_with_selected_category** - Should show selected category
- [ ] **test_category_picker_without_selected_category** - Should show placeholder
- [ ] **test_category_picker_with_label** - Should display label when provided
- [ ] **test_category_picker_without_label** - Should not display label when null

#### 5.2 Category Selection Tests
- [ ] **test_category_picker_show_dialog** - Tapping should show selection dialog
- [ ] **test_category_picker_dialog_content** - Dialog should display categories list
- [ ] **test_category_picker_selection_callback** - Selection should trigger callback
- [ ] **test_category_picker_dialog_cancel** - Cancel should close dialog without selection

#### 5.3 Search Functionality Tests
- [ ] **test_category_picker_search_field** - Should display search field in dialog
- [ ] **test_category_picker_search_filtering** - Should filter categories by search term
- [ ] **test_category_picker_search_case_insensitive** - Search should be case insensitive
- [ ] **test_category_picker_search_clear** - Clear button should reset search
- [ ] **test_category_picker_search_no_results** - Should show "no results" message

#### 5.4 CategoryDropdownPicker Tests
- [ ] **test_dropdown_picker_renders** - Dropdown should render properly
- [ ] **test_dropdown_picker_items** - Should display all categories as dropdown items
- [ ] **test_dropdown_picker_selection** - Selection should trigger callback
- [ ] **test_dropdown_picker_expanded_property** - Should respect isExpanded property

### 6. Integration Tests (`test/integration/category_integration_test.dart`)

#### 6.1 Category-Transaction Integration Tests
- [ ] **test_transaction_with_category** - Transactions should store categoryId
- [ ] **test_transaction_without_category** - Should default to 'other' category
- [ ] **test_category_deletion_transaction_reassignment** - Deleted categories should reassign transactions
- [ ] **test_category_validation_in_transactions** - Invalid categories should be handled

#### 6.2 End-to-End Workflow Tests
- [ ] **test_category_lifecycle** - Create → Use → Edit → Delete workflow
- [ ] **test_default_categories_availability** - Default categories should be available on app start
- [ ] **test_category_management_ui_integration** - UI should reflect service changes
- [ ] **test_category_picker_integration** - Picker should work with real category data

### 7. Error Handling Tests (`test/error_handling/category_error_test.dart`)

#### 7.1 Network Error Tests
- [ ] **test_category_service_network_timeout** - Should handle network timeouts
- [ ] **test_category_service_connection_error** - Should handle connection failures
- [ ] **test_category_service_firebase_unavailable** - Should handle Firebase unavailability

#### 7.2 Data Corruption Tests
- [ ] **test_category_service_corrupted_data** - Should handle corrupted Firestore data
- [ ] **test_category_service_missing_fields** - Should handle missing required fields
- [ ] **test_category_service_invalid_field_types** - Should handle wrong data types

#### 7.3 Edge Case Tests
- [ ] **test_category_service_empty_user_id** - Should handle empty user ID
- [ ] **test_category_service_special_characters** - Should handle special characters in data
- [ ] **test_category_service_very_long_data** - Should handle extremely long strings

---

## Test Implementation Strategy

### 1. Test Environment Setup
```dart
// Mock Firebase dependencies
// Use flutter_test and mockito packages
// Set up test data fixtures
```

### 2. Test Data Management
- Create reusable test category fixtures
- Mock Firebase Firestore responses
- Use consistent test user IDs and category IDs

### 3. Test Organization
- Group tests by component (Model, Service, Widgets)
- Use descriptive test names following the pattern: `test_[component]_[scenario]_[expected_result]`
- Include both positive and negative test cases

### 4. Coverage Goals
- **Model Tests**: 100% line coverage
- **Service Tests**: 95% line coverage (excluding Firebase internals)
- **Widget Tests**: 90% line coverage
- **Integration Tests**: Cover all critical user workflows

### 5. Test Execution
- Unit tests should run independently
- Mock external dependencies (Firebase)
- Use test fixtures for consistent data
- Include performance tests for database operations

---

## Test Files Structure

```
test/
├── model/
│   ├── category_test.dart
│   └── default_categories_test.dart
├── service/
│   └── category_service_test.dart
├── view/widgets/
│   ├── category_badge_test.dart
│   └── category_picker_test.dart
├── integration/
│   └── category_integration_test.dart
├── error_handling/
│   └── category_error_test.dart
└── fixtures/
    └── category_test_data.dart
```

---

## Success Criteria

### Functional Coverage
- ✅ All CRUD operations tested
- ✅ All validation rules tested
- ✅ All UI components tested
- ✅ All error scenarios covered

### Quality Metrics
- ✅ Minimum 90% code coverage
- ✅ All tests pass consistently
- ✅ Tests run in under 30 seconds
- ✅ No flaky tests

### Documentation
- ✅ Clear test descriptions
- ✅ Well-organized test structure
- ✅ Comprehensive test plan documentation
- ✅ Easy to maintain and extend

---

## Implementation Priority

### Phase 1: Core Model Tests (Week 1)
1. Category model tests
2. DefaultCategories tests
3. Basic CategoryService CRUD tests

### Phase 2: Service Layer Tests (Week 2)
1. Complete CategoryService tests
2. Validation and error handling tests
3. Integration with Firebase tests

### Phase 3: Widget Tests (Week 3)
1. CategoryBadge widget tests
2. CategoryPicker widget tests
3. UI integration tests

### Phase 4: Integration & Edge Cases (Week 4)
1. End-to-end workflow tests
2. Error handling and edge cases
3. Performance and stress tests

---

## Notes

- Focus only on Category feature functionality
- Exclude User authentication and profile management tests
- Mock Firebase dependencies to ensure test isolation
- Use consistent test data patterns across all test files
- Prioritize critical user workflows and error scenarios
- Ensure tests are maintainable and well-documented
