# CSCEA342_SudokuProject

## Summary

FPGA Sudoku Game (SystemVerilog/Basys 3): Complete 9x9 game implementation with VGA rendering. Input via PS/2 keyboard (movement, entry, submit) and DIP switches for puzzle select. Features color-coded visual feedback (cell selection, correctness) and on-board 7-segment display mirroring.

---

# FPGA Sudoku Game

## Project Description

This project implements a fully functional 9x9 Sudoku game on the Digilent Basys 3 FPGA. The game logic, input handling, and video output are all written in **SystemVerilog**. The system uses a PS/2 keyboard for user interaction and a VGA monitor for the primary display.

## Core Features

### Target Hardware:
* **FPGA Board:** Digilent Basys 3
* **Language:** SystemVerilog (for all modules)

### Display & Input:
* **VGA:** Renders a constant 9x9 grid.
* **Input:** **PS/2 Keyboard** (Arrow keys for movement, 1-9 for entry, Enter for submit/reset).
* **Puzzle Selection:** **DIP switches** select from pre-loaded puzzle ROMs.

### Visual Feedback:
* **Cell Highlighting:** Cells are highlighted (Yellow/Grey) to show the cursor position.
* **Entry Colors:**
    * **Blue:** Initial user entry.
    * **Green:** Correct on submission.
    * **Red:** Incorrect on submission.
* **On-board Display:** The **7-segment display** mirrors the value of the currently selected cell.

## System Architecture (Pseudo-Code)

The system is broken down into three main cooperating modules: the low-level PS/2 receiver, the keyboard parser, and the central Sudoku engine.

### 1. PS/2 Receiver (Physical Layer)

This module handles the physical clock and data signals from the PS/2 keyboard to reliably capture a complete scancode byte.

```systemverilog
// PS2 Receiver (phys layer)
Loop:
  // Edge detection and synchronization
  Synchronize PS2_CLK and PS2_DATA to system clock (Double Flop)
  Detect Falling Edge of PS2_CLK
 
  // Data reception
  Shift Data Bit into Shift Register
  Count Bits
 
  // Scancode completion
  If Count == 11:
    Verify Parity/Stop Bit
    Output Byte (scancode)
    Pulse "Data Ready"
```

### 2. Keyboard Parser (Logical Layer)

The parser consumes the scancodes and converts them into abstract, game-specific commands (like 'UP', '5', 'ENTER').

```systemverilog
// Keyboard Parser
Wait for "Data Ready" from Receiver

Check Byte:
  If Byte == F0: State = Release_Next_Key
  If Byte == E0: State = Extended_Key (Used for arrows/function keys)
  Else:
    If State != Release_Next_Key:
      // Convert raw scancode to game command
      Convert Hex Code to Game Command (e.g., 0x1C -> 'A', 0x75 -> 'UP', 0x5A -> 'ENTER')
      Pulse "Command Valid"
    Reset State
```

### 3. Sudoku Engine (Game Logic & State Machine)

The central module manages the grid state, cursor position, and puzzle validation.

```systemverilog
// Sudoku Engine
Memory: 9x9 Grid [81 registers for user input]
Cursor: X, Y registers (representing selected cell)

Always @ Clock:
  If Command Valid:
    If Command == Arrow: Move Cursor X/Y (Wrap around edges)
    If Command == Number: Update Grid[X][Y] (Only if not a fixed pre-loaded cell)
   
    If Command == Enter: 
        Compare Grid vs Solution (Pre-loaded solution ROM)
        Set Win/Loss State (Controls final message and coloring)
```

## Setup and Usage

(Details on compilation and loading the bitstream will be added here.)
