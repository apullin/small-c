# Small-C Compiler (1980) Code Guide

This is a guide-level walkthrough of how `SMALL-C.c` works. The source is
classic K&R-style C and implements a compact small-c compiler that emits
8080-style assembly. There is no separate lexer or AST; parsing and code
generation happen together as input is read.

## Big picture

The compiler follows a simple single-pass pipeline:

1) Read and preprocess input lines.
2) Parse top-level declarations, directives, and function definitions.
3) Parse statements and expressions with a recursive-descent parser.
4) Emit assembly as parsing proceeds.
5) Dump literal strings and static storage at the end.

## Entry point and top-level flow

`main()` initializes global state and runs these phases:

- `ask()` asks options (include C source in output comments, define globals,
  starting label number).
- `openout()` opens the output file (or uses stdout).
- `openin()` selects the first input file.
- `header()` emits a banner comment.
- `parse()` handles everything in the source.
- `dumplits()` emits the literal string pool.
- `dumpglbs()` emits storage for globals if requested.
- `errorsummary()` prints the error count.
- `trailer()` emits final assembly boilerplate (empty here).
- `closeout()` closes the output file.

## Core data structures

### Symbol table

Symbols are stored in a flat `char symtab[]` with fixed-size entries:

- `name` holds up to 8 characters plus NUL.
- `ident` says variable, array, pointer, or function.
- `type` says char or int.
- `storage` says static or stack-local.
- `offset` stores size or stack offset (two bytes).

Globals grow upward from `startglb`, locals grow upward from `startloc` in the
same array. `glbptr` and `locptr` mark the next free slots.

### Literal pool

String literals are stored in `litq[]` with `litptr` as the next index.
`dumplits()` writes them out as `DB` bytes at label `litlab`.

### While queue (break/continue support)

`wq[]` is a small stack that tracks active `while` loops:

- saved stack pointer (`wqsp`)
- saved local symbol pointer (`wqsym`)
- loop label (`wqloop`)
- exit label (`wqlab`)

`dobreak()` and `docont()` use the most recent entry to jump correctly.

### Input buffers

- `line[]` holds the current input line.
- `mline[]` is the preprocessor output buffer.
- `lptr` is the parse cursor within `line[]`.

## Input handling and preprocessing

### Line reading

`inline()` reads a line from the current input stream (`input` or `input2` for
includes). It strips the trailing newline, optionally echoes the line as a
comment when `ctext` is enabled, and resets `lptr`.

### Character access

- `ch()` returns the current character.
- `nch()` returns the next character.
- `gch()` consumes and returns the current character.
- `blanks()` skips whitespace and refills the line when needed.

### Preprocessor

`preprocess()` rewrites the line to:

- remove `/* ... */` comments
- expand simple object-like macros
- preserve string and character literals
- compress whitespace to single spaces

Macro expansion uses `#define` names stored in `macq[]`. There are no macro
arguments and no nested include stack.

## Top-level parsing

`parse()` loops until end of file and recognizes:

- `char` or `int` for global declarations (`declglb`)
- `#asm`, `#include`, `#define`
- otherwise, a function definition (`newfunc`)

## Declarations and the symbol table

### Global declarations

`declglb()` parses one or more global definitions:

- `*name` marks a pointer
- `name[const]` marks an array
- plain `name` is a scalar

The entry is added via `addglb()`, which stores the name and metadata into the
symbol table. Arrays store a size in `offset` (bytes), while scalars store `1`
or `2` depending on type.

### Local declarations

`declloc()` is similar but uses the stack:

- `sp` is a compiler-tracked stack pointer (bytes).
- Each local reduces `sp`, and `addloc()` stores the negative offset.

Local arrays allocate space by scaling size by 2 for int arrays.

## Functions and arguments

`newfunc()` declares or confirms a global function symbol, then parses the
argument list. Argument names are collected first (each adds 2 bytes to
`argstk`), then `getarg()` runs over the declarations to assign types and
create local symbol entries.

After arguments are processed:

- `locptr` is reset to the start of locals.
- `sp` starts at 0.
- A statement is parsed for the function body.
- If no return statement is seen, `ret()` is emitted.

## Statement parsing and control flow

`statement()` dispatches based on the next keyword:

- local declarations (`declloc`)
- compound blocks (`compound`)
- `if` via `doif()`
- `while` via `dowhile()`
- `return`, `break`, `continue`
- `#asm` to pass through assembly lines (`doasm()`)
- otherwise an expression statement

`doif()` and `dowhile()` use internal labels from `getlabel()` and emit jumps
via `jump()` and `testjump()`. `doasm()` temporarily disables preprocessing
and outputs raw lines until `#endasm`.

## Expressions and precedence

Expressions are parsed by a precedence ladder:

- `heir1` assignment (`=`)
- `heir2` bitwise OR (`|`)
- `heir3` XOR (`^`)
- `heir4` AND (`&`)
- `heir5` equality (`==`, `!=`)
- `heir6` relational (`<`, `<=`, `>`, `>=`)
- `heir7` shifts (`<<`, `>>`)
- `heir8` add/sub (`+`, `-`)
- `heir9` mul/div/mod (`*`, `/`, `%`)
- `heir10` unary (`++`, `--`, `-`, `*`, `&`)
- `heir11` postfix (`[]`, `()`)
- `primary` identifiers, literals, or parenthesized expressions

### Lvalues and rvalues

Expressions pass around a small `lval` array:

- `lval[0]` points to a symbol table entry (or 0).
- `lval[1]` indicates an indirect type when needed (0 means direct).

`rvalue()` loads either a direct symbol (`getmem`) or indirect reference
(`indirect`). `store()` writes to memory or through an address on the stack.

Pointer arithmetic scales by 2 for int pointers via `doublereg()`.

### Function calls

`callfunction()` evaluates arguments right-to-left, pushes them, then emits a
`CALL` for named functions or calls through the register if invoked via a
function pointer expression.

## Code generation model

The compiler emits assembly for an 8080-like target:

- Primary register is HL, secondary is DE.
- The runtime provides helpers like `ccsub`, `ccmult`, `ccdiv`, `ccgchar`,
  `ccpint`, and relational test routines.
- Labels are printed as `ccNNN`.
- `;` starts a comment line.
- Storage uses `DB`, `DW`, and `DS`.

Stack manipulation is centralized in `modstk()`, `push()`, `pop()`, and
`swapstk()`. `sp` tracks the compiler's idea of the stack depth and is kept
consistent on control-flow exits.

## Literal pool and globals

`dumplits()` emits the string literal pool at the end of compilation. Each
string is NUL-terminated. `dumpglbs()` emits `DS` declarations for global
storage when `glbflag` is enabled.

## Error handling

`error()` prints the current line, a caret under the error position, and a
message. It increments `errcnt`, which is reported by `errorsummary()`.

## Assumptions and limits

- Only `char` and `int` types exist.
- No structs, enums, or function prototypes.
- Macros are simple name replacements (no arguments).
- Line length is capped at 80 characters.
- Symbol names are limited to 8 characters.
- The target is 16-bit with 8080-style assembly.

These constraints are typical for a 1980 small-c compiler and explain many of
the fixed sizes and direct code-emission patterns in the source.
