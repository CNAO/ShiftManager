# ShiftManager
A series of tools for managing shifts

## `splitCalendar.m`
A first version of a calendar splitter.

The splitter parses the calendar released by the OP responsible and creates a `.csv` file for a given shifter with the list of shifts.
The `.csv` file has the format requested by google calendar for import.
The parser is in a very preliminary stage, i.e. it does not take into account notes and comments in the original spreadsheet.
