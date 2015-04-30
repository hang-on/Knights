# Knights
Knights of the Round (Sega Master System)

This is an attempt at working with big sprites.

## Introduction
[fill me...]

##Graphics format
The player sprite is Arthur. The sprite buffer is currently 32 sprites wide.
The sprite layout grid is a rectangle of 8x8 tiles, containing the whole sprite.
The hardware sprites are aligned in this grid, with offest (x,y) from a ref.
point, and also a charcode offset, referring to how the sprite is stored in
vram.


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
