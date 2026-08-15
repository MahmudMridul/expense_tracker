# expense_tracker

A minimal Android expense tracker built with Flutter. All amounts are in
BDT (৳). This project is vibecoded — built by prompting Claude Code
rather than writing the implementation by hand.

## Features

### Adding expenses

- Log an expense with a short text command in the form
  `<expense_type> <amount>`, e.g. `fare 60`.
- Submitting the same type again within the same period adds onto the
  existing entry instead of creating a duplicate (`fare 60` then
  `fare 100` becomes one `fare` entry of `160`).
- Amounts can be negative, to record adjustments/corrections against an
  existing type (e.g. `fare -10`).

### Current and previous periods

- Expenses always belong to the open "current" period.
- The `close` button on the Home page closes the current period (turning
  it into a "previous" period) and immediately starts a new, empty
  current period. It's disabled when the current period has no expenses.

### History page

- Shows the live current period (with its running total) and every
  previous period, each collapsible and showing its date range, expense
  count, and total.
- **Clear History**: deletes the *n* oldest previous periods (and their
  expenses) at once, after confirming how many to remove.

### Stats page

Computed across every period, current through oldest:

- Total expense amount for each period.
- Total expense amount for each expense type.
- Average expense amount per period for each expense type, rounded up
  to the nearest integer.
- Average total expense per period, across all periods.

### Export / Import (backup & restore)

Available from the ⋮ menu on the Home page.

- **Export CSV**: writes every period (current through oldest) and its
  expenses to a CSV file in the phone's Downloads folder.
- **Import CSV**: pick a CSV file (in the same format Export produces)
  and replace all current and previous expenses with its contents.
  Asks for confirmation first, since this can't be undone, and leaves
  existing data untouched if the file is malformed.

## Tech stack

- Flutter (managed via FVM — see [SETUP.md](SETUP.md))
- `sqflite` for local persistent storage (periods and expenses tables)
- `provider` for state management
- `intl` for currency and date formatting
- `csv` for export/import file parsing, `file_saver` to write the
  export to Downloads, `file_picker` to select a file to import

## Setup

See [SETUP.md](SETUP.md) for setting up the Flutter/Android toolchain
and running the app. See [SPEC.md](SPEC.md) for the original feature
spec this project was built from.
