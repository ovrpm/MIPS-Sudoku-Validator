# MIPS-Sudoku-Validator
## Description
MIPS Sudoku Validator is a MIPS assembly program, that reads sudoku grid files and checks their validity according to the standard rules of Sudoku.
## Features
- File I/O retrieval from .txt files
- Memory management between subroutines
- Nested loop algorithm for sudoku validation
## How to run
To run the program, fork this repository and run a MIPS simulator such as [MARS](https://dpetersanderson.github.io/) from the project directory.
Change contents of the .txt files to validate different sudoku grids
## I/O format
### Input format
Due to the restrictive nature of the Assembly language, the MIPS Sudoku Validator has very strict input format:
- Exactly 10 test files must be present in the main directory: `te0.txt` through `te9.txt`
- Each file must contain exactly 89 characters (81 valid characters + 8 newline symbols)
- Valid characters represent sudoku sells, and include: digits `1-9` for filled cells, `x` for empty cells
- Format: 9 lines of 9 valid characters each, with the first 8 of them ending with a newline symbol
### Output format
The program prints a message to the screen, which has a general structure of:
- The opening file message
- Sudoku grid retrieved from a file
- Validity message
Example:
```c
// the opening file message
Opening file: te1.txt
// Sudoku grid retrieved from the file
73xx4xxx7
2xx1958xx
x98xx2x4x
8xxx6x4x3
4xx8x3xx1
51xx2xxx6
x6xxxx28x
xxx419xx5
xxxx8xx79
// Validity message
not valid, because R('7' in [0,0] & '7' in [0,8])
```
The validity message is `valid` if the Sudoku grid is constructed following classic Sudoku rules.
In case a grid does not follow these rules, the program prints the first found inconsistency.
In the example above, the program prints `R` charachter to show that inconsistensy is found in a row, folowing the repeat values and their indecies in the 2D representation of the sudoku grid.
## Program Overview
The program consists of 3 main parts: 
1. Textfiles enumeration
2. Retrieval of files' contents into memory
3. Validating files' contents
### Textfiles enumeration
To access files from the directory, the program loops through the numbers from 0 to 9, and loads names of the text files by concatenating `te`, current number and `.txt`
### Retrieval of files' contents
After loading a filename into array we make syscalls to load its contents, (which is a sudoku grid) into array of size 89. Example of file contents:
```
53xx7xxxx
2xx1958xx
x98xx2x4x
8xxx6x4x3
4xx8x3xx1
71xx2xxx6
x6xxxx28x
xxx419xx5
xxxx8xx79
```
### Validating files' contents
The validating process consists of 3 main subroutines:
1. check_rows - subroutine that checks for repeat values in rows
2. check_columns - subroutine that checks for repeat values in columns
3. check_boxes - subroutine that checks for repeat values in 3x3 boxes
#### Validation logic:
**check_rows subroutine:**
```c
for (int i = 0; i < 90; i+=10){
    for (int j = i; j < i + 8; j++){
        int num1 = sudoku[j];
        for (int k = j + 1; k < i + 9; k++){
            int num2 = sudoku[k];
            if (num1 == num2) // invalid
        }
    }
}
```
**check_columns subroutine:**
```c
for (int i = 0; i < 9; i++){
    for (int j = i; j < 80; j+=10){
        int num1 = sudoku[j];
        for (int k = j + 10; k < 90; k+=10){
            int num2 = sudoku[k];
            if (num1 == num2) //invalid
        }
    }
}
```
**check_boxes subroutine:**

The check_boxes subroutine is more complex, and consists of 3 subroutines itself
1. from_box_to_array - subroutine that temporairly stores contents of 3x3 box in array
2. check_one_box - subroutine that goes through the array of charachers and checks for repeat values
3. check_boxes_main - subroutine that orchestrates validation process by calling from_box_to_array and check_one_box on every 3x3 box

check_boxes_main base logic:
```c
int s = 0; // index of the upper-left element in a 3x3 box
char box_array[] = from_box_to_array(s); // temporary storing of a 3x3 bog in contiguous memory
if (check_one_box(box_array) == -1) // validation (invalid)
...
```
s is an index that is representable of the leftmost upmost element of the 3x3 box, that is changed manually for practicality purposes
