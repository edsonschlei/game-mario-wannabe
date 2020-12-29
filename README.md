# game-mario-wannabe

This is the implementation following the steps of the
[Tracks Games - Mario](https://cs50.harvard.edu/x/2020/tracks/games/) activity

Each video is managed with in a new feature branch that is merged on the develop branch after done.

## Mario 0

+ Load the spritesheet.png image ![spritesheet.png](graphics/spritesheet.png).
+ Create and present the tiles from the map on the screen,

## Mario 1

+ Scroll the screen to the left

## Mario 2

+ Move map using w,a,s,d keys
+ Add map borders

## Mario 3

+ Create radom elements on the map

## Mario 4

+ Add the alien avatar
+ Add the player class to control the avatar

## Mario 5

+ Move the avatar to left and right
+ Move the map when necessary

## Mario 6

+ Animate the avatar movement
+ Walk to the left and to the right

## Mario 7

+ Add Jump behavior
+ Add gravity

## Mario 8

+ Collision detection
+ Change the hit block

## Mario 9

+ Fall in a gap
+ Collision at left and right
+ Jump on objects

## Mario 10

+ play sounds: background, jump, coin and hit

## Mario 11

+ Add a pyramid of blocks to the generated level.
+ Add a flag at the end of the level that either loads a new level or simply displays a victory message to the screen.
+ Add fall and lost
+ Add option to press return to restart the game

# Implementation

## [Lua](https://www.lua.org/manual/5.3/)
+ lua -v
+ Lua 5.3.3  Copyright (C) 1994-2016 Lua.org, PUC-Rio

## [Löve](https://love2d.org/)
+ love --version
+ LOVE 11.3 (Mysterious Mysteries)

# How to execute

+ checkout the git project
+ cd game-mario-wannabe
+ love .