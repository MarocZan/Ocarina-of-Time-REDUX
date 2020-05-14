This is the source code for the Better Ocarina of Time hack (link) by Maroc. This project is based off Roman971's fork of OoT-Randomizer (https://github.com/Roman971/OoT-Randomizer)

NB: To select the 2x text speed version instead of the 3x, rename the `patch2xtext.bps` file to `patch.bps` inside the `patch` directory, overwriting the previous one. The default `patch.bps` is the one with 3x text speed.

Instructions:

- Download the armips assembler: <https://github.com/Kingcom/armips>, build it or download the precompiled version, and put the executable in the `tools` directory, or somewhere in your PATH
- Download the armips assembler: <https://github.com/Alcaro/Flips>, build it or download the binary, and put the executable in the `tools` directory, or somewhere in your PATH
- Put the ROM you want to patch at `roms/base.z64`. This needs to be an uncompressed ROM;
- Run `python build.py`, which will create the ROM into the `/Output_ROM` directory

To recompile the C modules, use the `--compile-c` option. This requires the N64 development tools to be installed: <https://github.com/glankk/n64>

To generate symbols for the Project 64 debugger, use the `--pj64sym` option:

    python build.py --pj64sym 'path_to_pj64/Saves/THE LEGEND OF ZELDA.sym'
	
To use the 32-bit compressor, use the `--compress32` option.
