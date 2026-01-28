# 🍄 Super Mario Console Adventure

A text-mode **Super Mario** game implemented in **x86 MASM** using **Kip Irvine’s Irvine32 library**.  
Built as a **COAL (Computer Organization and Assembly Language)** course project, this console-based platformer features **four levels** and a **final boss fight** against Bowser.

---

## 📌 Overview

**Super Mario Console Adventure** recreates classic Mario gameplay in a **console (text-based) environment** using ASCII graphics.  
The game renders Mario, enemies, platforms, and collectibles using characters like:

- `$` → Coins  
- `*` → Power-ups  
- ASCII sprites → Mario, enemies, and environment

The project leverages the **Irvine32 library** for console input/output, timing, and Windows API integration (such as sound playback).  
Each level introduces new challenges, hazards, and enemies, culminating in a final showdown with **Bowser**.

---

## 🎮 Gameplay Mechanics

### 🔹 Controls
| Key | Action |
|----|-------|
| `W` | Move Up |
| `A` | Move Left |
| `D` | Move Right |
| `SPACE` | Jump (Double Jump supported) |
| `F` | Shoot Fireball |

> Mario can perform a **double jump** by pressing `SPACE` again while airborne.

---

### 🔹 Projectiles
- Press `F` to launch a fireball in Mario’s facing direction.
- Fireballs travel until they hit an enemy or wall.
- Standard enemies are defeated on contact.

---

### 🔹 Enemies
The game includes classic Mario enemies:
- **Goombas** – Ground-walking enemies  
- **Koopa Troopas** – Turtle enemies  
- **Paragoombas** – Flying enemies  
- **Bowser** – Final boss (Level 4) with projectile attacks  

Enemy AI uses simple walking and attack patterns, while Bowser has enhanced behavior.

---

### 🔹 Power-ups & Collectibles
- `*` **Star Power-ups**: Enable Fire Mario mode
- `$` **Coins**: Increase score
- ⚠️ **Hazards**: Spikes, lava pools, pits (instant death)

---

### 🔹 Levels
- **4 total levels**
- Features include:
  - Static platforms
  - Pipes
  - Pits and lava traps
  - Fireball hazards
- Difficulty increases with each level
- Level 4 takes place in **Bowser’s Castle**
- Reach the **flagpole** to complete a level

---

### 🔹 Timer & Scoring
- Each level has a **countdown timer**
- Points awarded for:
  - Collecting coins
  - Defeating enemies
  - Completing levels
- Score and remaining time are displayed on-screen
- Scores are checked against the high-score table on completion or game over

---

### 🔹 High Scores
- Players can enter their **name** when achieving a high score
- Scores are:
  - Stored
  - Sorted
  - Displayed on the leaderboard

---

## 🏆 Win Condition
- Defeat **Bowser** in the final level
- Touch the **end flag** after Bowser is defeated
- Triggers the **Victory screen**

---

## 💀 Lose Conditions
- Falling into pits or lava
- Fatal enemy collisions
- Timer reaching zero
- Losing all available lives results in **Game Over**

---

## 🎨 Visual & Sound Elements

### 🔹 ASCII Graphics
- Retro ASCII-art visuals for:
  - Title screen
  - Levels
  - Characters
  - Victory & Game Over screens

### 🔹 Title & End Screens
- Custom ASCII **“Super Mario”** title screen
- Menu system
- Victory and Game Over ASCII art displays

### 🔹 Audio
- Sound effects and background music played using:
  - `PlaySound` from **winmm.dll**
- WAV files triggered through Windows API calls

---

## 🛠️ Technologies Used
- **x86 Assembly (MASM)**
- **Irvine32 Library**
- **Windows API (PlaySound)**
- **ASCII-based rendering**

---

## 🙏 Acknowledgments
- **Kip Irvine’s Irvine32 Library**  
  From *Assembly Language for x86 Processors*, providing essential routines for:
  - Console I/O
  - Timing
  - System interaction  

- Developed as part of the **COAL (Computer Organization and Assembly Language)** course  
  Special thanks to course instructors and provided materials for guidance.

---

## 📄 License
This project was developed for educational purposes as a university course project.

---

🎮 *A retro console adventure—Mario, assembly, and ASCII magic combined!*


