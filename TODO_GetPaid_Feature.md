# TODO: Add "Get Paid" feature for marking completed shifts as paid

## Overview
Modify the `_addManualEarning()` method to allow users to select completed shifts and mark them as paid.

## Changes Required

### 1. Modify `_addManualEarning()` function
- [ ] Add "Income Type" dropdown with options:
  - "Other Income" (default - current manual entry)
  - "Get Paid" (for marking shifts as paid)
- [ ] Add job dropdown for shift selection
- [ ] Show list of pending shifts (completed but not paid)
- [ ] Allow multi-selection of shifts
- [ ] Display calculated total from selected shifts
- [ ] Update save logic to:
  - Create earning with status "paid"
  - Update selected shifts status from "completed" to "paid"

### 2. Add helper method to get pending shifts
- [ ] Query shifts with status "completed" that don't have corresponding paid earnings
- [ ] Filter by selected job if job is selected

### 3. UI Updates
- [ ] Income type selector UI
- [ ] Shift selection list with checkboxes
- [ ] Total amount display for selected shifts
- [ ] Visual feedback for selected shifts

## Implementation Details

### Data Flow:
1. User selects "Get Paid" as income type
2. User selects a job (optional - if not selected, show all pending shifts)
3. App shows list of completed but unpaid shifts for that job
4. User selects one or more shifts
5. App calculates total: sum of (shift duration × job pay rate)
6. User clicks SAVE
7. App creates earning with calculated amount and status "paid"
8. App updates selected shifts status to "paid"

## Files to Modify:
- lib/screen/earning.dart

## Testing:
- [ ] Test "Other Income" flow still works
- [ ] Test "Get Paid" flow with single shift
- [ ] Test "Get Paid" flow with multiple shifts
- [ ] Test job filtering
- [ ] Test shift deletion after marking as paid

