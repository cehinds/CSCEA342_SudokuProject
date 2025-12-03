# CI/CD Pipeline for VGA Sudoku Project

This directory contains the GitHub Actions workflow configuration for automated testing of the VGA Sudoku SystemVerilog project.

## Overview

The CI/CD pipeline performs automated syntax checking, smoke testing, and semantic analysis of all SystemVerilog files in the project. It runs automatically on:
- Push to `main` or `develop` branches
- Pull requests targeting `main` or `develop` branches

## Pipeline Stages

### 1. Syntax Check
**Tool:** Icarus Verilog (iverilog)
**Purpose:** Verify that all `.sv` files have valid SystemVerilog syntax
**Duration:** ~1-2 minutes

This stage scans all SystemVerilog files and checks for syntax errors using the SystemVerilog 2012 standard (`-g2012`).

### 2. Smoke Test
**Tool:** Icarus Verilog (iverilog)
**Purpose:** Verify that critical modules can be compiled independently
**Duration:** ~1-2 minutes
**Modules tested:**
- `clock_divider.sv` - Clock generation
- `vga_controller.sv` - VGA timing
- `ram.sv` - Memory module

### 3. Semantic Analysis
**Tool:** Verilator
**Purpose:** Perform deep linting and semantic analysis
**Duration:** ~2-3 minutes

Verilator checks for:
- Unused signals
- Combinational loops
- Blocking/non-blocking assignment issues
- Sensitivity list problems
- Other HDL best practice violations

### 4. Integration Test
**Tool:** Icarus Verilog (iverilog)
**Purpose:** Verify that modules can work together
**Duration:** ~1-2 minutes

Attempts to compile multiple modules together to catch integration issues.

### 5. Report Status
**Purpose:** Summarize results and mark build as pass/fail

## Setup Instructions

### Step 1: Create Directory Structure
In your GitHub repository, create the `.github/workflows` directory:
```bash
mkdir -p .github/workflows
```

### Step 2: Add Workflow File
Copy the `systemverilog-ci.yml` file into `.github/workflows/`:
```bash
cp systemverilog-ci.yml .github/workflows/
```

Your directory structure should look like this: