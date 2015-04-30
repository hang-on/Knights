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

Each frame of animation is understood and developed by the following concepts:

* The Image is a cropped and possibly color-edited .bmp image of the current 
  frame. The Image is taken from the scaled sprite sheet. The sprite is 
  arranged to fit into a grid of tiles (8x8 pixels).

* The Layout is an annotated version of The Image. Every non-transparent tile 
  is then indexed from 0 to .., along with 2D coordinates that specifies the 
  offset from a given reference point. This reference point is usually the top 
  left corner of the top left tile, even if this tile is transparent. The 
  Layout is used for the programmer's reference only. It is used to make The 
  Raw Tileblock and later the SATPackage.

  Each non-transparent tile on the Layout will be assigned to a hwsprite.

* The Raw Tileblock: The .bmp file with the tiles ordered according
  to the indexing done in the Layout. Ready to be processed by BMP2Tile. It is 
  made from The Image.

* The TileBlock: The .inc file made by BMP2Tile containing data in the
  32-bytes per tile format of the SMS VDP.

* The SATPackage is a data format for arranging the current frame of a
  big sprite in the SAT.
    - 1 byte: Amount of hwsprites to process for the given frame.
    - 2 bytes: x,y offset from the coordinates of the object represented
      by the sprite. This is the reference point.
    - First hwsprites' x,y offset from the reference point + 1 byte charcode.
    - Next hwsprites' x,y offset..., and so on, for all the hwsprites in the
      current frame.

Example elements of frame Arthur Standing:
* ArthurStanding_Image
* ArthurStanding_Layout
* ArthurStanding_RawTileBlock
* ArthurStanding_TileBlock
* ArthurStanding_SATPackage

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
