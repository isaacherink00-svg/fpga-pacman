# FPGA Pac-Man

This project recreates the classic **Pac-Man arcade game** on an FPGA
using **SystemVerilog**, **C**, and the **Urbana board**. It was
developed with **Vivado** and **Vitis**.

## Features

-   Hardware design written in SystemVerilog (game logic, VGA output,
    memory blocks).\
-   Software running on MicroBlaze (USB keyboard input, game control).\
-   HDMI output to display the game on a monitor.\
-   Score display on the left hex display.\
-   Current keyboard keycode on the right hex display.\
-   Reset button mapped to the right-most FPGA button.\
-   Controls: **WASD keys** for movement.

## Repository Structure

    fpga-pacman/
    ├── vivado/          # Hardware sources (HDL, constraints, block design TCL)
    ├── vitis/
    │   └── app/pac/     # Vitis application sources (C code, headers, linker script)
    └── .gitignore       # Ignore build and generated files

## Getting Started

### Requirements

-   Xilinx Vivado (tested on \[insert version you used\])\
-   Xilinx Vitis (tested on \[insert version you used\])\
-   Urbana FPGA board\
-   Micro-USB cable and HDMI display

### Building the Hardware

1.  Open Vivado.\

2.  Run the provided TCL script:

        source vivado/scripts/create_project.tcl

    This will recreate the project with all sources and block designs.

3.  Generate bitstream and export hardware (`.xsa`).

### Building the Software

1.  Launch Vitis.\
2.  Import the workspace from `vitis/`.\
3.  Build the project (`pac`).\
4.  Program the FPGA and run the application.

### Controls

-   **WASD** --- Move Pac-Man\
-   **Right-most board button** --- Reset game

## Demo

Here’s a screenshot of the game running on the FPGA board:

![Pac-Man running on FPGA](docs/screenshot.jgp)
