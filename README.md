# MIPS-Sudoku-Validator
### Description
MIPS Sudoku Validator is a MIPS assembly program, that reads sudoku grid files and checks their validity according to the standart rules of Sudoku.
### Input format
Duw to the restrictive nature of the Assembly language, the MIPS Sudoku Validator has very strict input format:
- Exactly 10 test files must be present in the main directory: `te0.txt` through `te9.txt`
- Each file must contain exactly 89 characters (81 valid characters + 8 newline symbols)
- Valid characters represent sudoku sells, and include: digits `1-9` for filled cells, `x` for empty cells
- Format: 9 lines of 9 valid characters each, with the first 8 of them ending with a newline symbol
