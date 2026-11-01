# 🧮 Flex & Bison Scientific Calculator

![Language](https://img.shields.io/badge/Language-C-blue.svg)
![Tools](https://img.shields.io/badge/Tools-Flex%20%7C%20Bison-success.svg)
![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Linux%20%7C%20macOS-lightgrey.svg)
![Course](https://img.shields.io/badge/Course-CSE314%20Compiler%20Design-orange.svg)

A command-line scientific calculator with number-base conversion, built in C using **Flex** (lexical analysis) and **Bison** (parsing). It was created for the **Compiler Design (CSE314)** course at **Daffodil International University** to demonstrate how a real compiler front-end works: tokenizing input, parsing it with a grammar, evaluating it through semantic actions, and recovering from errors.


---

## 📑 Table of Contents
- [Features](#-features)
- [How It Works](#️-how-it-works)
- [Getting Started](#️-getting-started)
- [Usage & Examples](#️-usage--examples)
- [Error Handling](#️-error-handling)
- [Project Structure](#-project-structure)
- [Known Limitations](#️-known-limitations)
- [Future Improvements](#-future-improvements)
- [Contributors](#-contributors)

---

## 🚀 Features

- **Arithmetic:** `+`, `-`, `*`, `/`, `%` (modulo), `^` (power), unary minus, and parentheses
- **Scientific functions:** `sin`, `cos`, `tan` (arguments in **degrees**), `log` (base 10), `ln` (natural log), `exp`, `sqrt`
- **Constants:** `pi`, `e`
- **Base conversion:** `DEC2HEX`, `HEX2DEC`, `DEC2OCT`, `OCT2DEC`, `DEC2BIN`, `BIN2DEC`
- **Decimal and scientific notation** input, e.g. `3.14` or `1e-5`
- **Error recovery:** a bad input prints an error and the calculator keeps running
- **Input validation:** domain checks on `sqrt`/`log`/`ln`, and digit validation on `BIN2DEC`/`OCT2DEC`
- Type `quit` or `exit` to leave

---

## ⚙️ How It Works

```
 user input ──▶ Flex lexer ──▶ tokens ──▶ Bison parser ──▶ evaluated result
              (.l file)                   (.y file)
```

1. **Lexical analysis (Flex):** `calculator_with_conversion.l` turns the input text into tokens such as `NUMBER`, `SIN`, `SQRT`, `DEC2HEX`, and `STRING`.
2. **Parsing (Bison):** `calculator_with_conversion.y` defines the grammar and operator precedence, and builds the result through semantic actions as each rule is reduced.
3. **Error recovery:** an `error '\n'` rule lets the parser skip a bad line and continue with the next one.

**Operator precedence (lowest → highest):**

| Level | Operators | Associativity |
|-------|-----------|---------------|
| 1 | `+` `-` | left |
| 2 | `*` `/` `%` | left |
| 3 | unary `-` | — |
| 4 | `^` | right |

So `-2^2` evaluates to `-4`, and `2^3^2` evaluates to `512`.

---

## 🛠️ Getting Started

### Prerequisites
- **GCC**
- **Flex**
- **Bison**

Linux (Debian/Ubuntu):
```bash
sudo apt install gcc flex bison
```
Windows: install MinGW-w64 (GCC) plus Flex and Bison (for example via MSYS2 or WinFlexBison).

### Build & Run

```bash
bison -d calculator_with_conversion.y
flex calculator_with_conversion.l
gcc calculator_with_conversion.tab.c lex.yy.c -o calculator -lm
```

Run it:

```bash
# Windows (PowerShell)
.\calculator

# Linux / macOS
./calculator
```

> `bison` and `flex` generate `calculator_with_conversion.tab.c`, `calculator_with_conversion.tab.h`, and `lex.yy.c`. These are build outputs, so you don't need to commit them.

---

## 🖥️ Usage & Examples

Type an expression and press Enter. Function names are **case-sensitive**: math functions are lowercase (`sin`), conversion functions are uppercase (`DEC2HEX`).

| Input | Output |
|-------|--------|
| `5+3*2` | `Result: 11` |
| `(5+3)*2` | `Result: 16` |
| `2^10` | `Result: 1024` |
| `7 % 3` | `Result: 1` |
| `-5+3` | `Result: -2` |
| `-2^2` | `Result: -4` |
| `sqrt(49)` | `Result: 7` |
| `sin(90)` | `Result: 1` |
| `log(10)` | `Result: 1` |
| `ln(10)` | `Result: 2.30259` |
| `pi` | `Result: 3.14159` |
| `DEC2HEX(255)` | `Result: FF` |
| `DEC2BIN(200)` | `Result: 11001000` |
| `HEX2DEC("FF")` | `Result: 255` |
| `BIN2DEC("1010")` | `Result: 10` |

**Notes**
- `sin`, `cos`, `tan` take **degrees**, so use `sin(90)`, not `sin(pi/2)`.
- `log` is base 10; use `ln` for the natural logarithm.
- For `HEX2DEC`, `OCT2DEC`, and `BIN2DEC`, the value must be written **in quotes**, e.g. `HEX2DEC("FF")`.
- Results are printed with 6 significant digits.

---

## 🛡️ Error Handling

The calculator prints a message to the error stream and keeps running:

| Input | Message |
|-------|---------|
| `5++` | `Error: syntax error` |
| `sqrt(-4)` | `Error: sqrt of negative number` |
| `log(0)` | `Error: log of non-positive number` |
| `ln(-1)` | `Error: ln of non-positive number` |
| `BIN2DEC("1F")` | `Error: invalid binary digits` |
| `OCT2DEC("9")` | `Error: invalid octal digits` |

---

## 📂 Project Structure

```
.
├── calculator_with_conversion.l   # Flex lexer (tokens)
├── calculator_with_conversion.y   # Bison grammar, precedence, and semantic actions
├── Screenshot/
│   └── Screenshot.png             # Screenshot used in this README
└── README.md
```

---

## ⚠️ Known Limitations

- Division by zero returns `inf` instead of an error message.
- `DEC2HEX`, `DEC2OCT`, and `DEC2BIN` convert the integer part only (`DEC2HEX(3.7)` is treated as `3`) and use 32-bit integers.
- One expression per line; no variables or calculation history yet.

---

## 📌 Future Improvements

- Variable assignment and calculation history
- Explicit division-by-zero error
- Additional functions (`asin`, `acos`, `atan`, `abs`, `factorial`)
- A radians/degrees mode toggle
- A GUI frontend (GTK/Qt) on top of the same parser

---

## 👨‍💻 Contributors

- **Thasin Mahmud Rifat Bhuiyan** (ID: 242-15-695)


Department of Computer Science and Engineering, **Daffodil International University**, Dhaka, Bangladesh — *CSE314: Compiler Design*, August 2026.
