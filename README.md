# Knights
Knights of the Round (Sega Master System)

This is an attempt at working with big sprites.

## Introduction
[fill me...]

##Graphics format
The player sprite is Arthur. The sprite buffer is currently 32 sprites wide.
The sprite buffer is then populated by loading a SATPackage into it. At vblank, 
the SATBuffer can be loaded into vram SAT.

The sprites are based on the SNES port. Ripped by Belial and downloaded from 
http://www.spriters-resource.com/snes/knightsround/.

The sprite sheet is resized to 80% in Photoshop, with the "Preserve hard
edges"-option. The colors are then tweaked to fit into the SMS color space.


##Arthur
Arthur is the object controlled with player 1's joystick.

Arthur_Status is 8 flags used by the Arthur object to communicate with the 
game elements.

| Bit   | Function                                                             |
| :---: | :------------------------------------------------------------------- |
| 0     | If set, the Loader will load tiles for a new frame into vram. This   |
          bit is reset by Arthur object every cycle in Game_State 1.

| 1     |                                                                      |

##Hub_GameState
The overall state of the game is controlled by the 1 byte variable
Hub_GameState. This variable is altered by the Hub object, and it is read by
each of the game objects during the main loop. A game object has a script for
each game state. This way each object adjusts its behavior depending on the
game state.

The numbering is not chronological. Instead the numbers reflect where in the
development process the corresponding states were implemented.

| Value | Comment                                                              |
| :---: | :------------------------------------------------------------------- |
| 0     | Initialize level 1                                                   |
| 1     | Run level 1                                                          |
