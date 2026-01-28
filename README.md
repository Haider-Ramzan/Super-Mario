Super Mario Console Adventure
A text-mode Super Mario game implemented in x86 MASM using Kip Irvine’s Irvine32 library. Built as a COAL (Computer Organization and Assembly Language) course project, this console-based platformer spans four levels and a final boss fight. The player controls Mario through ASCII-art environments, aiming to collect coins and power-ups, defeat Bowser, and reach the goal flag.
Overview
This project recreates classic Super Mario gameplay in a console (text) environment. The game uses ASCII characters to draw Mario, enemies, and the world (e.g. $ for coins, * for powerups). It leverages the Irvine32 library for easy console I/O and Windows API calls (for example, sound). Each level has themed elements (platforms, pipes, pits, fireball hazards) and increasing difficulty. The ultimate goal is to navigate all four levels and defeat Bowser in level 4 to win the game. Along the way, the player collects coins and stars, and can input their name for high-score tracking.
Gameplay Mechanics
•	Controls: Use W, A, D keys to move Mario (up, left, right respectively), SPACE to jump, and F to shoot a fireball. Mario can perform a double jump by pressing SPACE again while airborne.
•	Projectiles: Pressing F launches a fireball in Mario’s forward direction. Fireballs travel across the screen until they hit an enemy or wall, defeating standard enemies on contact.
•	Enemies: The game features classic Mario foes – Goombas (ground walkers), Koopa Troopas (turtle enemies), Paragoombas (flying Goombas), and finally Bowser as the level-4 boss. Enemy AI is simple (walking patterns), with the final boss having projectile attack pattern.
•	Power-ups & Collectibles: Collect * (star power-ups) to become fire Mario to shoot Projectile. Gather $ coins for points. Avoid deadly hazards like spikes and pools of lava, which cause instant death.
•	Levels: There are 4 levels, each with static platforms, pipes, pits, and oncoming fireballs. Levels increase in complexity; the fourth level includes Bowser’s castle and fire-pit traps. Finishing a level requires reaching the end-of-level flagpole.
•	Timer & Scoring: Each level has a countdown timer. Players earn points for collecting coins, defeating enemies, and finishing levels. The current score and time are displayed on-screen. On level completion or game over, the score is compared against a high-score list.
•	High Scores: The game records high scores and allows the player to enter their name when a new high score is achieved. The highest scores are sorted and displayed.
Win Condition
•	The player wins by defeating Bowser in the final level and reaching the end flag. Touching the flagpole after Bowser falls triggers a victory.
Lose Conditions
•	The player loses a life by falling into a pit or lava, or by taking fatal damage from enemies. If the timer runs out, Mario also loses a life. Losing all available lives ends the game (Game Over).
Visual and Sound Elements
•	ASCII Graphics: The title screen, levels, and end screens use ASCII-art for a retro look. For example, on startup a stylized “Super Mario” logo is drawn with text characters. Level layouts and sprites (Mario, enemies, items) are all rendered using console characters.
•	Title and End Screens: A custom ASCII title screen welcomes the player, followed by a main menu. If the player wins or loses, a “Victory” or “Game Over” ASCII-art screen is shown.
•	Audio: Background music and effects are played using the Windows API PlaySound function (from winmm.dll). For example, MASM code can call PlaySound to play a WAV file while the game runs. 
Acknowledgments
•	This game was built using Kip Irvine’s Irvine32 library (from Assembly Language for x86 Processors), which provides convenient macros and routines for console I/O and timing. The Irvine32.inc and Irvine32.lib files were instrumental in handling text output and input.
•	The project was developed as part of a COAL (Computer Organization and Assembly Language) course. Special thanks to the course instructors and materials for guidance on MASM programming.

