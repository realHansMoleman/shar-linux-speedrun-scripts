# SHAR speedrunning setup scripts for Linux
**\*\*CURRENTLY WIP\*\***

This is a repository containing scripts for setting up some stuff for speedrunning SHAR (The Simpsons: Hit & Run) for Linux **but will not install SHAR specifically**. Non-speedrunners may also get some use out of these scripts.

While these scripts won't install SHAR, they can be used to set up Wine prefixes for SHAR speedrunning, as well as creating .desktop files and shell scripts to launch [LiveSplit](https://github.com/LiveSplit)/[Lucas's Mod Launcher](https://donutteam.com/downloads/4/).

I plan to implement LiveSplit installation at some point.

## Basic script
- Creates prefix with corefonts, GDI+, DXVK and .NET 4.6.1
- Optional prefix install to ~/.local/share/wineprefixes (or $XDG_DATA_HOME/wineprefixes)

## Advanced script
- Creates prefix optionally (and recommended) with corefonts, GDI+, DXVK and .NET 4.6.1
- Customisable Wine prefix location
- Generates desktop files and shell scripts for launching LiveSplit and Lucas' Mod Launcher

## To do
- Download and install LiveSplit
- Possibly facilitate SHAR installation (unlikely)
- Facilitate installing Lucas' Mod Launcher
- Consolidate into 1 script and ask user if they want basic or advanced setup
