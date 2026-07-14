# ♟️ Chess Game in MASM32 Assembly

> A complete two-player Chess Game developed in **x86 Assembly Language (MASM32)** using **Microsoft Visual Studio** and the **Windows API**. The project demonstrates advanced assembly language programming by implementing official chess rules, graphical rendering, and interactive gameplay within a Windows desktop application.

---

# 📖 Overview

This project is a fully functional Chess Game created as part of the **Computer Organization & Assembly Language (COAL)** course. It combines low-level programming concepts with graphical user interface development to simulate a complete chess match between two players.

The game supports all major chess rules, validates every move according to official chess regulations, and updates the graphical board in real time. It showcases how Assembly Language can be used to build complex, logic-driven applications.

---

# ✨ Features

## ♟ Complete Chess Gameplay

- Two-player turn-based gameplay
- Interactive graphical chessboard
- Automatic turn switching
- Real-time board updates
- Move validation
- Piece capturing
- Invalid move detection

---

## ♜ Standard Chess Rules

All chess pieces follow their official movement rules:

- ♙ Pawn
- ♖ Rook
- ♘ Knight
- ♗ Bishop
- ♕ Queen
- ♔ King

---

## 🔁 Special Chess Moves

### 🏰 Castling

Supports both:

- Kingside Castling
- Queenside Castling

The game verifies:

- King and rook have not moved
- Path between them is clear
- King is not in check
- King does not move through check
- King does not end in check

---

### ♟ En Passant

Implements complete En Passant logic by:

- Detecting double pawn movement
- Allowing capture only on the immediate next turn
- Removing the captured pawn correctly

---

### 👑 Pawn Promotion

When a pawn reaches the final rank, players can promote it to:

- Queen
- Rook
- Bishop
- Knight

If an invalid option is entered, the pawn is automatically promoted to a Queen.

---

## ⚔️ Game State Detection

The game continuously checks for:

- ✔ Check
- ✔ Checkmate
- ✔ Stalemate

Every move is validated to ensure the game follows official chess rules.

---

# 🖥️ User Interface

The game provides a graphical interface built using the Windows API.

### Features

- 8 × 8 graphical chessboard
- Unicode chess pieces
- Board coordinates (A–H and 1–8)
- Dynamic board rendering
- Automatic board refresh after every move

---

# ⌨️ Player Input

Moves are entered using standard chess notation.

### Example

```
e2 e4
e7 e5
g1 f3
```

### Castling

```
O-O
```

or

```
O-O-O
```

The game validates every move before applying it to the board.

---

# 🛠️ Technologies Used

- x86 Assembly Language
- MASM32 SDK
- Microsoft Visual Studio
- Windows API
- Win32 Programming
- Windows GDI

---

# 📂 Project Structure

```
Chess-Game-MASM32/
│
├── ChessGame.asm
└── README.md
```

The complete game logic, rendering, move validation, and user interaction are implemented within the Assembly source code using modular procedures.

---

# 🚀 How to Build and Run

## Requirements

- Windows Operating System
- Microsoft Visual Studio
- MASM32 SDK
- Visual Studio configured for MASM32 Assembly projects

---

## Steps

1. Clone or download this repository.
2. Open the project in Microsoft Visual Studio.
3. Ensure the MASM32 SDK is installed and configured.
4. Build the solution.
5. Run the application.
6. Enter player moves through the console while the graphical chessboard is displayed.

---

# 🧩 Internal Modules

The project contains separate procedures responsible for:

- Board Initialization
- Chessboard Rendering
- Piece Drawing
- Move Validation
- Piece Movement
- Piece Capturing
- Turn Management
- Castling
- En Passant
- Pawn Promotion
- Check Detection
- Checkmate Detection
- Stalemate Detection
- User Input Handling
- Game State Management

---

# 🎓 Learning Outcomes

This project demonstrates practical implementation of:

- Assembly Language Programming
- Computer Organization Concepts
- Windows API Programming
- GUI Development
- Event Handling
- Memory Management
- Conditional Branching
- Procedures and Macros
- Algorithm Design
- Game Logic Implementation

---

# 🔮 Future Improvements

Potential enhancements include:

- 🤖 Single-player mode with AI
- 💾 Save and Load Game
- 🔄 Undo / Redo Moves
- 🔊 Sound Effects
- ⏱️ Chess Timer
- 🖱️ Mouse-based piece movement
- 🌐 Online Multiplayer
- 📜 Move History Panel
- 🎨 Enhanced graphical interface

---

# 👨‍💻 Team

Wasama Adal, Kisfa Javed, Iman Fatima, Leeza Qayyum

---

# 📄 Note

This project was developed for academic and educational purposes as part of the **Computer Organization & Assembly Language (COAL)** course.
