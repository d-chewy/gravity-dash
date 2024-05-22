### Basic Overview

Verilog implementation of a simplified Geometry Dash. In other words, this is a simple platformer with gravity flipping mechanics that outputs to any 
VGA display and tracks the player's elapsed time (score) using the onboard seven-segment display. Everything is implemented using the Basys3 board from
Digilent with the Artix-7 by Xilinx.
This project was completed as part of UCLA CSM152A's open-ended project assignment. 
Project idea inspired by FPGADude's Bouncing Square. 

Demo link: https://drive.google.com/file/d/1cz4KUdeU9eg18cSQgtITo3Wnbp5YQQA5/view?usp=sharing



#### Self-defined Specifications: 
*Platforms Mechanics* - The game must randomly generate where blocks are produced such that the player has to change the direction of their gravity. 
These blocks will be displayed on screen, detect when the player collides, and behave as a physical obstacle to the player.

*VGA Output to Monitor* - The game must be displayed out to a monitor using a VGA cable/protocol.

*Player Physics/Mechanics* - The player will always be moving “right” on the screen and must be able to change their gravity such that their vertical 
movement is either upwards or downwards.

*Seven Segment Display for Score* - The seven segment display on the Basys 3 board will display the time elapsed since the start of the game. This 
will serve as the player’s score.

*Game Over/Game end screen* - If the player falls outside the bounds of the screen, the game will end and display “Game Over!”, prompting the player 
to reset the game.

*Reset Button* - The game must reset to a state similar or equal to that of when the user first played the game. Score will reset, and the user will 
move to the ‘beginning’.

*Button controls* - We must implement a button to allow the player movement to travel up and down between floor and ceiling in the game (change their 
gravity).
