INCLUDE Irvine32.inc
INCLUDELIB winmm.lib 

; Windows API Prototype for Sound
Beep PROTO, dwFreq:DWORD, dwDuration:DWORD
PlaySoundA PROTO, pszSound:PTR BYTE, hmod:DWORD, fdwSound:DWORD

.data
    ; Screen dimensions
    SCREEN_WIDTH EQU 120
    SCREEN_HEIGHT EQU 25

    ;music constants
    SND_ASYNC EQU 1
    SND_LOOP  EQU 8
    SND_FILENAME  EQU 20000h
    musicFile BYTE "bgm.wav", 0  ;
    
    ; --- Game Flow ---
    currentLevel BYTE 1   
    gameRunning BYTE 1
    levelResult BYTE 0    ; 1=Win, 0=Lose
    
    ; --- File I/O ---
     ; Player Name
    playerName BYTE 20 DUP(0)
    savedPlayerName BYTE 20 DUP(0)  ; Name from file
    namePrompt BYTE "Enter your name (max 15 chars): ", 0
    welcomeMsg BYTE "Welcome, ", 0

    playerDataFile BYTE "playerdata.txt", 0
    fileHandle   DWORD ?
    highScore    DWORD 0
    scoreBuffer  BYTE 16 DUP(0)
    
    ; --- Rendering Globals ---
    currentBgColor DWORD 144    ; Default Light Blue
    currentGroundColor DWORD 2  ; Default Green
    
    ; --- Mario properties ---
    marioX BYTE 10
    marioY BYTE 20
    marioVelY SDWORD 0
    marioVelX SDWORD 0
    onGround BYTE 0
    prevMarioX BYTE 10
    prevMarioY BYTE 20
    jumpCounter BYTE 0
    maxJumpHeight BYTE 10
    doubleJumpUsed BYTE 0
    marioState BYTE 0 
    
    ; --- Mario Projectiles ---
    MAX_PROJECTILES EQU 2
    projectileActive BYTE MAX_PROJECTILES DUP(0)
    projectileX BYTE MAX_PROJECTILES DUP(0)
    projectileY BYTE MAX_PROJECTILES DUP(0)
    projectileVelX SDWORD MAX_PROJECTILES DUP(0)
    projectileVelY SDWORD MAX_PROJECTILES DUP(0)
    prevProjectileX BYTE MAX_PROJECTILES DUP(0)
    prevProjectileY BYTE MAX_PROJECTILES DUP(0)
    projectileColorType BYTE MAX_PROJECTILES DUP(0)
    
    ; --- BOSS Projectiles ---
    MAX_BOSS_PROJ EQU 2
    bossProjActive BYTE MAX_BOSS_PROJ DUP(0)
    bossProjX BYTE MAX_BOSS_PROJ DUP(0)
    bossProjY BYTE MAX_BOSS_PROJ DUP(0)
    bossProjVelX SDWORD MAX_BOSS_PROJ DUP(0)
    bossProjVelY SDWORD MAX_BOSS_PROJ DUP(0)
    bossProjPrevX BYTE MAX_BOSS_PROJ DUP(0)
    bossProjPrevY BYTE MAX_BOSS_PROJ DUP(0)

    isBossActive BYTE 1
    
    ; Level map
    levelMap BYTE SCREEN_WIDTH * SCREEN_HEIGHT DUP(0)
    
    ; Colors
    BG_BLUE EQU 144
    BG_CYAN EQU 48
    COLOR_MARIO EQU 10 + BG_BLUE
    COLOR_MARIO_STAR EQU 15 + BG_BLUE
    COLOR_GROUND EQU 2 + BG_BLUE
    COLOR_PLATFORM EQU 6 + BG_BLUE
    COLOR_PIPE EQU 10 + BG_BLUE
    COLOR_FLAG EQU 14 + BG_BLUE
    COLOR_PROJECTILE EQU 13 + BG_BLUE
    COLOR_FIREBALL EQU 12 + BG_BLUE
    COLOR_FLOOR EQU 6 + BG_BLUE
    COLOR_COIN EQU 14 + BG_BLUE
    COLOR_SPIKE EQU 12 + BG_BLUE
    COLOR_GOOMBA EQU 6 + BG_BLUE
    COLOR_KOOPA EQU 10 + BG_BLUE
    COLOR_PARAGOOMBA EQU 11 + BG_BLUE
    COLOR_BOSS EQU 12 + BG_BLUE
    COLOR_BOSS_PROJ EQU 12 + BG_BLUE
    COLOR_TIME EQU 15 + BG_BLUE
    COLOR_SKY EQU 0 + BG_BLUE
    COLOR_STAR EQU 12 + BG_BLUE
    COLOR_LAVA EQU 12        
    
    ; Background Constants
    BG_BLUE_VAL EQU 144
    BG_BLACK_VAL EQU 0
    BG_RED_VAL EQU 64
    BG_CYAN_VAL EQU 48
    
    ; Characters
    COIN_CHAR EQU '$'
    STAR_CHAR EQU '*'
    PARAGOOMBA_CHAR EQU 'W'
    BOSS_CHAR EQU 'B'
    LAVA_CHAR EQU 178
    TILE_PIPE EQU 10
    
    ; Game state
    gameWon BYTE 0
    gameOver BYTE 0
    needsFullRedraw BYTE 1
    scoreCount DWORD 0
    livesCount DWORD 10
    
    ; Timer
    timerCount SDWORD 300
    lastTick DWORD 0
    
    ; Enemy properties
    MAX_ENEMIES EQU 10
    enemyX BYTE MAX_ENEMIES DUP(0)
    enemyY BYTE MAX_ENEMIES DUP(0)
    prevEnemyX BYTE MAX_ENEMIES DUP(0)
    prevEnemyY BYTE MAX_ENEMIES DUP(0)
    enemyVelX SDWORD MAX_ENEMIES DUP(0)
    enemyVelY SDWORD MAX_ENEMIES DUP(0)
    enemyType BYTE MAX_ENEMIES DUP(0)   
    enemyState BYTE MAX_ENEMIES DUP(0)
    enemyOnGround BYTE MAX_ENEMIES DUP(0)
    enemyHealth BYTE MAX_ENEMIES DUP(1)
    enemyActionTimer BYTE MAX_ENEMIES DUP(0) 
    
    ; Enemy states
    STATE_NORMAL EQU 0
    STATE_SHELL EQU 1
    STATE_SHELL_MOVING EQU 2
    STATE_DEAD EQU 3
    
    ; --- MENU STRINGS ---
    ; ASCII Art Title
    marioArt1    BYTE "   _____                       __  __            _       ", 0
    marioArt2    BYTE "  / ____|                     |  \/  |          (_)      ", 0
    marioArt3    BYTE " | (___  _   _ _ __   ___ _ __| \  / | __ _ _ __ _  ___  ", 0
    marioArt4    BYTE "  \___ \| | | | '_ \ / _ \ '__| |\/| |/ _` | '__| |/ _ \ ", 0
    marioArt5    BYTE "  ____) | |_| | |_) |  __/ |  | |  | | (_| | |  | | (_) |", 0
    marioArt6    BYTE " |_____/ \__,_| .__/ \___|_|  |_|  |_|\__,_|_|  |_|\___/ ", 0
    marioArt7    BYTE "              | |                                        ", 0
    marioArt8    BYTE "              |_|                                        ", 0
    marioArt9	 BYTE "                       24I-0647  CS-D                    ", 0

    menuOpt1     BYTE "1. Start Game", 0
    menuOpt2     BYTE "2. Instructions", 0
    menuExit     BYTE "X. Exit Game", 0
    menuPrompt   BYTE "Select an option: ", 0
    menuHiScore  BYTE "High Score: ", 0

    ;;;;;;;;;;;;end screen
    ;gameOver ASCII Art

    gameOver1 BYTE "| ____                                       _____                           |",0
    gameOver2 BYTE "|/\  _`\                                    /\  __`\                         |",0
    gameOver3 BYTE "|\ \ \L\_\     __      ___ ___      __      \ \ \/\ \  __  __     __   _ __  |",0
    gameOver4 BYTE "| \ \ \L_L   /'__`\  /' __` __`\  /'__`\     \ \ \ \ \/\ \/\ \  /'__`\/\`'__\|",0
    gameOver5 BYTE "|  \ \ \/, \/\ \L\.\_/\ \/\ \/\ \/\  __/      \ \ \_\ \ \ \_/ |/\  __/\ \ \/ |",0
    gameOver6 BYTE "|   \ \____/\ \__/.\_\ \_\ \_\ \_\ \____\      \ \_____\ \___/ \ \____\\ \_\ |",0
    gameOver7 BYTE "|    \/___/  \/__/\/_/\/_/\/_/\/_/\/____/       \/_____/\/__/   \/____/ \/_/ |",0
    

    skullMsg  BYTE "      GAME OVER      ", 0
    skullMsg2 BYTE "      YOU  DIED      ", 0

    ; --- VICTORY TROPHY ART ---
    ; Note: We use double quotes " " to wrap strings containing single quotes '
    trophyL1 BYTE "              .-=========-.              ", 0
    trophyL2 BYTE "              \'-=======-'/              ", 0
    trophyL3 BYTE "              _|   .=.   |_              ", 0
    trophyL4 BYTE "             ((|  {{1}}  |))             ", 0
    trophyL5 BYTE "              \|   /|\   |/              ", 0
    trophyL6 BYTE "               \__ '`' __/               ", 0
    trophyL7 BYTE "                 _`) (`_                 ", 0
    trophyL8 BYTE "               _/_______\_               ", 0
    trophyL9 BYTE "              /___________\              ", 0
    
    winMsg1  BYTE "      CONGRATULATIONS!       ", 0
    winMsg2  BYTE "   YOU DEFEATED BOWSER!      ", 0
    
    ; --- INSTRUCTION SCREEN STRINGS ---
    instTitle    BYTE "=== HOW TO PLAY ===", 0
    instMove     BYTE "Movement:   W, A, S, D", 0
    instJump     BYTE "Jump:       SPACE BAR (Double jump available)", 0
    instShoot    BYTE "Shoot:      F (Fireballs)", 0
    instPause    BYTE "Pause:      P", 0
    instBack     BYTE "Press Any Key to Return to Menu...", 0

    ; --- Fire Pit Fireballs ---
    MAX_FIRE_PITS EQU 2
    firePitX BYTE MAX_FIRE_PITS DUP(0)        ; X position of fire pit
    firePitTimer BYTE MAX_FIRE_PITS DUP(0)    ; Timer for shooting
    fireballActive BYTE MAX_FIRE_PITS DUP(0)  ; Is fireball active
    fireballX BYTE MAX_FIRE_PITS DUP(0)       ; Current X position
    fireballY BYTE MAX_FIRE_PITS DUP(0)       ; Current Y position
    fireballVelY SDWORD MAX_FIRE_PITS DUP(0)  ; Y velocity (negative = up)
    fireballPrevX BYTE MAX_FIRE_PITS DUP(0)   ; Previous X for erasing
    fireballPrevY BYTE MAX_FIRE_PITS DUP(0)   ; Previous Y for erasing
    fireballStartY BYTE MAX_FIRE_PITS DUP(0)  ; Starting Y position
    fireballPeakReached BYTE MAX_FIRE_PITS DUP(0)  ; Has it reached peak?
    
    ; In-Game Messages
    titleMsg BYTE "WASD:Move SPACE:Jump F:Shoot P:Pause X:Exit", 0
    winMsg BYTE "LEVEL COMPLETE!", 0
    timeBonusMsg BYTE "Time Bonus: ", 0
    totalScoreMsg BYTE "Total Score: ", 0
    nextLevelMsg BYTE "Press Any Key for Next Level...", 0

    victoryLossMsg BYTE "YOU Didn't DEFEATED BOWSER and ran away! Princess Hates you!", 0
    
    gameOverMsg BYTE "GAME OVER. Press Any Key...", 0
    pauseMsg BYTE "PAUSED - R:Resume, M:Menu", 0
    scoreMsg BYTE "Score: ", 0
    hiScoreMsg BYTE "HI: ", 0
    livesMsg BYTE "Lives: ", 0
    timeMsg BYTE "Time: ", 0
    modeMsg BYTE "Mode: ", 0
    modeS BYTE "S", 0
    modeB BYTE "B", 0
    modeF BYTE "R", 0
    
    bossNameMsg BYTE "LEVEL 4: BOWSER'S CASTLE", 0

.code
main PROC
    
    INVOKE PlaySoundA, ADDR musicFile, NULL, SND_ASYNC OR SND_LOOP OR SND_FILENAME
    
    mov currentBgColor, BG_BLUE_VAL
    mov eax, currentBgColor
    call SetTextColor
    call LoadPlayerData  
    
    
    call GetPlayerName

Menu_Loop:
    ; CHECKERBOARD BACKGROUND
    call DrawCheckerboardMenuBg
    
    call DrawMenuHeader

    mov eax, 0 + (15 * 16) 
    mov eax, 15 ; White on Black
    call SetTextColor

    mov dh, 13
    mov dl, 40
    call Gotoxy
    mov edx, OFFSET menuOpt1
    call WriteString
    
    mov dh, 15
    mov dl, 40
    call Gotoxy
    mov edx, OFFSET menuOpt2
    call WriteString
    
    mov dh, 17
    mov dl, 40
    call Gotoxy
    mov edx, OFFSET menuExit
    call WriteString
    
    mov dh, 19
    mov dl, 40
    call Gotoxy
    mov edx, OFFSET menuPrompt
    call WriteString
    
    call ReadChar
    cmp al, '1'
    je Start_New_Game
    cmp al, '2'
    je Show_Instructions
    cmp al, 'x'
    je Exit_App
    cmp al, 'X'
    je Exit_App
    jmp Menu_Loop

Show_Instructions:
    call Clrscr
    
    ; 1. Draw Background (Blue)
    mov eax, 1 + (1 * 16)  ; Blue on Blue
    call SetTextColor
    call Clrscr            ; Fill screen

    ; 2. Draw "Dialog Box" using Standard ASCII (+, -, |)
    ; Box dimensions: Left=30, Top=5, Right=90, Bottom=20
    
    ; --- Top Border ---
    mov dh, 5
    mov dl, 30
    call Gotoxy
    mov eax, 12 + (0 * 16) ; Light Red on Black
    call SetTextColor
    
    mov al, '+'            ; Top-Left corner
    call WriteChar
    
    mov ecx, 58            ; Width of box
    mov al, '-'            ; Horizontal line
L_Top:
    call WriteChar
    loop L_Top
    
    mov al, '+'            ; Top-Right corner
    call WriteChar

    ; --- Side Walls ---
    mov dh, 6
L_Sides:
    cmp dh, 20
    jge L_Bottom
    
    ; Left Wall
    mov dl, 30
    call Gotoxy
    mov eax, 12 + (0 * 16) ; Red on Black
    call SetTextColor
    mov al, '|'            ; Vertical line
    call WriteChar
    
    ; Fill Black Space inside
    mov eax, 15 + (0 * 16) ; White text on Black background
    call SetTextColor
    mov ecx, 58
    mov al, ' '
L_Fill:
    call WriteChar
    loop L_Fill
    
    ; Right Wall
    mov eax, 12 + (0 * 16) ; Red on Black
    call SetTextColor
    mov al, '|'            ; Vertical line
    call WriteChar
    
    inc dh
    jmp L_Sides

L_Bottom:
    ; --- Bottom Border ---
    mov dl, 30
    call Gotoxy
    mov eax, 12 + (0 * 16) ; Red on Black
    call SetTextColor
    
    mov al, '+'            ; Bottom-Left corner
    call WriteChar
    
    mov ecx, 58
    mov al, '-'            ; Horizontal line
L_BotLoop:
    call WriteChar
    loop L_BotLoop
    
    mov al, '+'            ; Bottom-Right corner
    call WriteChar

    ; 3. Draw Title (Yellow on Black)
    mov dh, 7
    mov dl, 50             ; Centered
    call Gotoxy
    mov eax, 14 + (0 * 16) ; Yellow on Black
    call SetTextColor
    mov edx, OFFSET instTitle
    call WriteString

    ; 4. Draw Instructions (White on Black)
    mov eax, 15 + (0 * 16) ; Bright White on Black
    call SetTextColor

    mov dh, 9
    mov dl, 35
    call Gotoxy
    mov edx, OFFSET instMove
    call WriteString

    mov dh, 11
    mov dl, 35
    call Gotoxy
    mov edx, OFFSET instJump
    call WriteString

    mov dh, 13
    mov dl, 35
    call Gotoxy
    mov edx, OFFSET instShoot
    call WriteString
    
    mov dh, 15
    mov dl, 35
    call Gotoxy
    mov edx, OFFSET instPause
    call WriteString

    ; 5. Footer (Green on Black)
    mov dh, 18
    mov dl, 42
    call Gotoxy
    mov eax, 10 + (0 * 16) ; Light Green on Black
    call SetTextColor
    mov edx, OFFSET instBack
    call WriteString

    ; Wait for input
    call ReadChar
    
    ; Restore Menu Background color (Blue)
    mov eax, 1 + (1 * 16) 
    call SetTextColor
    call Clrscr
    
    jmp Menu_Loop

Start_New_Game:
    call ResetMatch 
    call RunGameManager
    mov eax, scoreCount
    cmp eax, highScore
    jle no_new_hiscore
    mov highScore, eax
    call SavePlayerData
no_new_hiscore:
    jmp Menu_Loop

Exit_App:
    exit
main ENDP


ShowVictoryScreen PROC

    call Clrscr
    
    ; 1. Set Background to Blue (Nice contrast for Gold trophy)
    mov eax, 1 + (1 * 16)    ; Blue Text on Blue Background
    call SetTextColor
    call Clrscr              ; Fill screen with blue

    ; 2. Draw the Trophy in GOLD (Yellow on Blue)
    mov eax, 14 + (1 * 16)   ; Bright Yellow on Blue
    call SetTextColor

                   ; Start Row
    
    ; Print Line 1
    mov dl, 40               ; Center X (Adjusted for trophy width)
    mov dh, 6 
    call Gotoxy
    mov edx, OFFSET trophyL1
    call WriteString
    inc dh
    
    ; Print Line 2
    mov dl, 40
    mov dh, 7
    call Gotoxy
    mov edx, OFFSET trophyL2
    call WriteString
    inc dh

    ; Print Line 3
    mov dl, 40
    mov dh, 8 
    call Gotoxy
    mov edx, OFFSET trophyL3
    call WriteString
    inc dh

    ; Print Line 4
    mov dl, 40
    mov dh, 9
    call Gotoxy
    mov edx, OFFSET trophyL4
    call WriteString
    inc dh

    ; Print Line 5
    mov dl, 40
    mov dh, 10
    call Gotoxy
    mov edx, OFFSET trophyL5
    call WriteString
    inc dh

    ; Print Line 6
    mov dl, 40
    mov dh, 11
    call Gotoxy
    mov edx, OFFSET trophyL6
    call WriteString
    inc dh

    ; Print Line 7
    mov dl, 40
    mov dh, 12
    call Gotoxy
    mov edx, OFFSET trophyL7
    call WriteString
    inc dh

    ; Print Line 8
    mov dl, 40
    mov dh, 13
    call Gotoxy
    mov edx, OFFSET trophyL8
    call WriteString
    inc dh

    ; Print Line 9
    mov dl, 40
    mov dh, 14
    call Gotoxy
    mov edx, OFFSET trophyL9
    call WriteString
    inc dh

    ; 3. Play Victory Fanfare (Tada!)
    INVOKE Beep, 523, 150    ; C
    INVOKE Beep, 659, 150    ; E
    INVOKE Beep, 784, 150    ; G
    INVOKE Beep, 1046, 600   ; High C (Long Hold)

    ; 4. Draw Victory Text (White on Blue)
    mov eax, 15 + (1 * 16)   ; Bright White on Blue
    call SetTextColor
    
    mov dh, 17
    mov dl, 48
    call Gotoxy
    mov edx, OFFSET winMsg1  ; "CONGRATULATIONS!"
    call WriteString
    
    mov dh, 19
    mov dl, 47
    call Gotoxy
    mov edx, OFFSET winMsg2  ; "YOU DEFEATED BOWSER!"
    call WriteString

    ; 5. Wait for user input
    call ReadChar
    
    ; Restore colors and return
    mov eax, 15              ; White on Black
    call SetTextColor
    call Clrscr
    ret

ShowVictoryScreen ENDP

;-----------------------------------------------------------
; GetPlayerName - Ask player for their name
;-----------------------------------------------------------
GetPlayerName PROC
    pushad
    
    call Clrscr
    mov eax, 15  ; White text
    call SetTextColor
    
    mov dh, 10
    mov dl, 35
    call Gotoxy
    mov edx, OFFSET namePrompt
    call WriteString
    
    ; Read the player name
    mov edx, OFFSET playerName
    mov ecx, 15  ; Max 15 characters
    call ReadString
    
    ; Display welcome message
    mov dh, 12
    mov dl, 35
    call Gotoxy
    mov edx, OFFSET welcomeMsg
    call WriteString
    mov edx, OFFSET playerName
    call WriteString
    
    mov eax, 1000
    call Delay
    
    popad
    ret
GetPlayerName ENDP
;-----------------------------------------------------------
; DrawCheckerboardMenuBg
;-----------------------------------------------------------
DrawCheckerboardMenuBg PROC
    pushad
    mov dh, 0 ; Row
row_loop_bg:
    cmp dh, SCREEN_HEIGHT
    jge bg_done
    mov dl, 0 ; Col
col_loop_bg:
    cmp dl, SCREEN_WIDTH
    jge next_row_bg

    ; Checkerboard logic: (Row + Col) & 1
    mov al, dh
    add al, dl
    and al, 1
    cmp al, 0
    je bg_black
    mov eax, 8 ; Dark Grey
    jmp set_bg
bg_black:
    mov eax, 0 ; Black
set_bg:
    shl eax, 4 ; Move to background nibble
    call SetTextColor

    call Gotoxy
    mov al, ' '
    call WriteChar

    inc dl
    jmp col_loop_bg
next_row_bg:
    inc dh
    jmp row_loop_bg
bg_done:
    popad
    ret
DrawCheckerboardMenuBg ENDP

;-----------------------------------------------------------
; DrawMenuHeader
;-----------------------------------------------------------
DrawMenuHeader PROC
    ; Red Text on Transparent/Black
    mov eax, 12 ; Red text, Black BG
    call SetTextColor

    mov dl, 30
    mov dh, 2
    call Gotoxy
    mov edx, OFFSET marioArt1
    call WriteString

    mov dl, 30
    mov dh, 3
    call Gotoxy
    mov edx, OFFSET marioArt2
    call WriteString

    mov dl, 30
    mov dh, 4
    call Gotoxy
    mov edx, OFFSET marioArt3
    call WriteString

    mov dl, 30
    mov dh, 5
    call Gotoxy
    mov edx, OFFSET marioArt4
    call WriteString

    mov dl, 30
    mov dh, 6
    call Gotoxy
    mov edx, OFFSET marioArt5
    call WriteString
    
    mov dl, 30
    mov dh, 7
    call Gotoxy
    mov edx, OFFSET marioArt6
    call WriteString

    mov dl, 30
    mov dh, 8
    call Gotoxy
    mov edx, OFFSET marioArt7
    call WriteString

    mov dl, 30
    mov dh, 9
    call Gotoxy
    mov edx, OFFSET marioArt8
    call WriteString

    mov dl, 30
    mov dh, 10
    call Gotoxy
    mov edx, OFFSET marioArt9
    call WriteString
    
    ; Display high score with holder's name
    mov eax, 14 ; Yellow for high score
    call SetTextColor
    
    mov dh, 11
    mov dl, 45
    call Gotoxy
    mov edx, OFFSET menuHiScore
    call WriteString
    mov eax, highScore
    call WriteDec
    
    ; Show who has the high score (if anyone)
    mov al, BYTE PTR [savedPlayerName]
    cmp al, 0
    je no_saved_name
    
    mov al, ' '
    call WriteChar
    mov al, '('
    call WriteChar
    mov edx, OFFSET savedPlayerName
    call WriteString
    mov al, ')'
    call WriteChar
    
no_saved_name:
    ret
DrawMenuHeader ENDP

;-----------------------------------------------------------
; File I/O Procedures
;-----------------------------------------------------------
;-----------------------------------------------------------
; SavePlayerData - Save player name and their score (ONLY if high score)
;-----------------------------------------------------------
SavePlayerData PROC
    pushad
    
    mov edx, OFFSET playerDataFile
    call CreateOutputFile
    mov fileHandle, eax
    cmp eax, INVALID_HANDLE_VALUE
    je save_player_done
    
    ; Write current player name (who got the high score)
    mov eax, fileHandle
    mov edx, OFFSET playerName  ; Current player's name
    mov ecx, 20
    call WriteToFile
    
    ; Write high score (4 bytes)
    mov eax, fileHandle
    mov edx, OFFSET highScore
    mov ecx, 4
    call WriteToFile
    
    mov eax, fileHandle
    call CloseFile
    
save_player_done:
    popad
    ret
SavePlayerData ENDP

;-----------------------------------------------------------
; LoadPlayerData - Load saved high score holder's name and score
;-----------------------------------------------------------
LoadPlayerData PROC
    pushad
    
    mov edx, OFFSET playerDataFile
    call OpenInputFile
    mov fileHandle, eax
    cmp eax, INVALID_HANDLE_VALUE
    je load_player_default
    
    ; Read saved player name (20 bytes) - the high score holder
    mov eax, fileHandle
    mov edx, OFFSET savedPlayerName
    mov ecx, 20
    call ReadFromFile
    
    ; Read high score (4 bytes)
    mov eax, fileHandle
    mov edx, OFFSET highScore
    mov ecx, 4
    call ReadFromFile
    
    mov eax, fileHandle
    call CloseFile
    jmp load_player_done
    
load_player_default:
    ; Set default values
    mov highScore, 0
    mov BYTE PTR [savedPlayerName], 0  ; Empty name
    
load_player_done:
    popad
    ret
LoadPlayerData ENDP

;-----------------------------------------------------------
; RunGameManager
;-----------------------------------------------------------
RunGameManager PROC

Level_Start:
    call ResetLevel
    call InitializeLevel
    call InitializeEnemies
    call InitializeFirePits
    
    mov eax, currentBgColor
    call SetTextColor
    call Clrscr
    call DrawFullScreen
    
    call GetMseconds
    mov lastTick, eax
    
    mov gameRunning, 1
    mov levelResult, 0
    call GameLoop
    
    xor eax, eax
    mov al, levelResult
    cmp al, 1
    jne Game_Ended 
    
    inc currentLevel
    cmp currentLevel, 4 
    jle Level_Start 
    
    ; Victory
    call Clrscr
    mov dh, 12
    mov dl, 40
    call Gotoxy
    mov eax, COLOR_FLAG
    add eax, BG_BLUE_VAL
    call SetTextColor

    cmp isBossActive, 0;
    jne boss_not_defeated
    call ShowVictoryScreen
    jmp display_ending
    boss_not_defeated:
    mov edx, OFFSET victoryLossMsg
    display_ending:
    call WriteString
    mov dh, 14
    mov dl, 45
    call Gotoxy
    mov edx, OFFSET totalScoreMsg
    call WriteString
    mov eax, scoreCount
    call WriteDec
    call ReadChar
    
Game_Ended:
    ret
RunGameManager ENDP

;-----------------------------------------------------------
; Reset Procedures
;-----------------------------------------------------------
ResetMatch PROC
    mov scoreCount, 0
    mov livesCount, 10
    mov currentLevel, 1
    ret
ResetMatch ENDP

ResetLevel PROC
    mov marioX, 10
    mov marioY, 20
    mov marioVelX, 0
    mov marioVelY, 0
    mov onGround, 1
    mov jumpCounter, 0
    mov doubleJumpUsed, 0
    mov timerCount, 300
    mov gameWon, 0
    mov gameOver, 0
    mov needsFullRedraw, 1
    mov levelResult, 0
    
    mov ecx, MAX_PROJECTILES
    mov esi, 0
clear_proj_loop:
    mov projectileActive[esi], 0
    mov prevProjectileX[esi], 0
    inc esi
    loop clear_proj_loop
    
    ; Clear Boss Projectiles
    mov ecx, MAX_BOSS_PROJ
    mov esi, 0
clear_boss_proj:
    mov bossProjActive[esi], 0
    mov bossProjPrevX[esi], 0
    inc esi
    loop clear_boss_proj

    mov ecx, MAX_FIRE_PITS
    mov esi, 0
clear_fireballs:
    mov fireballActive[esi], 0
    mov firePitTimer[esi], 0
    mov fireballPrevX[esi], 0
    mov fireballPeakReached[esi], 0
    inc esi
    loop clear_fireballs
    
    ret
ResetLevel ENDP

;-----------------------------------------------------------
; InitializeLevel
;-----------------------------------------------------------
InitializeLevel PROC
    pushad
    
    mov ecx, SCREEN_WIDTH * SCREEN_HEIGHT
    mov edi, OFFSET levelMap
    xor al, al
    rep stosb
    
    mov al, currentLevel
    cmp al, 1
    je load_level_1
    cmp al, 2
    je load_level_2
    cmp al, 3
    je load_level_3
    cmp al, 4
    je load_level_4
    
load_level_1:
    mov currentBgColor, BG_BLUE_VAL
    mov currentGroundColor, 2 ; Green Ground/Blocks
    call SetupLevel1
    jmp init_done
load_level_2:
    mov currentBgColor, 0 ; Pure Black Background
    mov currentGroundColor, 11 ; Grey Ground/Blocks
    call SetupLevel2
    jmp init_done
load_level_3:
    mov currentBgColor, 176
    mov currentGroundColor, 6 
    call SetupLevel3
    jmp init_done
load_level_4:
    mov currentBgColor, BG_BLACK_VAL
    mov currentGroundColor, 8 
    call SetupLevel4
    jmp init_done
    
init_done:
    mov ebx, 0
floor_loop:
    cmp ebx, SCREEN_WIDTH
    jge floor_done
    
    ; Index calc without movzx instruction logic
    xor eax, eax
    mov eax, SCREEN_HEIGHT - 1
    imul eax, SCREEN_WIDTH
    add eax, ebx
    
    cmp BYTE PTR [levelMap + eax], 8
    je floor_next
    mov BYTE PTR [levelMap + eax], 3
floor_next:
    inc ebx
    jmp floor_loop
floor_done:

    popad
    ret
InitializeLevel ENDP

;-----------------------------------------------------------
; SetupLevels
;-----------------------------------------------------------
SetupLevel1 PROC
    mov ebx, 0
l1_ground:
    cmp ebx, SCREEN_WIDTH
    jge l1_pits
    mov ecx, SCREEN_HEIGHT - 3
    mov eax, ecx
    imul eax, SCREEN_WIDTH
    add eax, ebx
    mov BYTE PTR [levelMap + eax], 1
    mov ecx, SCREEN_HEIGHT - 2
    mov eax, ecx
    imul eax, SCREEN_WIDTH
    add eax, ebx
    mov BYTE PTR [levelMap + eax], 1
    inc ebx
    jmp l1_ground
l1_pits:
    push 35
    push 30
    call CreatePit
    push 55
    push 50
    call CreatePit
    push 75
    push 70
    call CreatePit
    push 8
    push 18
    push 12
    call CreatePlatform
    push 10
    push 15
    push 28
    call CreatePlatform
    push 7
    push 19
    push 45
    call CreatePlatform
    push 10
    push 10
    push 38
    call CreatePlatform
    push 12
    push 7
    push 65
    call CreatePlatform
    push 5
    push 8
    push 113
    call CreatePlatform 
    push 3
    push 21
    push 22
    call CreatePipe
    push 4
    push 21
    push 62
    call CreatePipe
    push 4
    push 19
    push 40
    call CreateWall

    push 7
    push 113
    call PlaceCoin

    push 17
    push 12
    call PlaceCoin
    push 17
    push 13
    call PlaceCoin
    push 17
    push 14
    call PlaceCoin
    push 17
    push 15
    call PlaceCoin
    push 35
    push 30
    call CreateSpikes
    push 55
    push 50
    call CreateSpikes
    push 21
    push 25
    call PlaceStar
    push 14
    push 84
    call PlaceStar
    ret
SetupLevel1 ENDP

SetupLevel2 PROC
    mov ebx, 0
l2_ground:
    cmp ebx, 20
    jge l2_middle
    mov ecx, SCREEN_HEIGHT - 3
    mov eax, ecx
    imul eax, SCREEN_WIDTH
    add eax, ebx
    mov BYTE PTR [levelMap + eax], 1
    mov ecx, SCREEN_HEIGHT - 2
    mov eax, ecx
    imul eax, SCREEN_WIDTH
    add eax, ebx
    mov BYTE PTR [levelMap + eax], 1
    inc ebx
    jmp l2_ground
l2_middle:
    mov ebx, 50
l2_mid_loop:
    cmp ebx, 70
    jge l2_end
    mov ecx, SCREEN_HEIGHT - 3
    mov eax, ecx
    imul eax, SCREEN_WIDTH
    add eax, ebx
    mov BYTE PTR [levelMap + eax], 1
    mov ecx, SCREEN_HEIGHT - 2
    mov eax, ecx
    imul eax, SCREEN_WIDTH
    add eax, ebx
    mov BYTE PTR [levelMap + eax], 1
    inc ebx
    jmp l2_mid_loop
l2_end:
    mov ebx, 100
l2_end_loop:
    cmp ebx, 120
    jge l2_objects
    mov ecx, SCREEN_HEIGHT - 3
    mov eax, ecx
    imul eax, SCREEN_WIDTH
    add eax, ebx
    mov BYTE PTR [levelMap + eax], 1
    mov ecx, SCREEN_HEIGHT - 2
    mov eax, ecx
    imul eax, SCREEN_WIDTH
    add eax, ebx
    mov BYTE PTR [levelMap + eax], 1
    inc ebx
    jmp l2_end_loop
l2_objects:

    ; Pit 1 (Gap from 20 to 50)
    push 50      ; End X
    push 20      ; Start X
    call CreateLavaPit

    ; Pit 2 (Gap from 70 to 100)
    push 100     ; End X
    push 70      ; Start X
    call CreateLavaPit
    push 10
    push 18
    push 25
    call CreatePlatform
    push 5
    push 14
    push 38
    call CreatePlatform
    push 8
    push 10
    push 75
    call CreatePlatform
    push 5
    push 15
    push 90
    call CreatePlatform
    push 5
    push 8
    push 113
    call CreatePlatform
    push 3
    push 21
    push 15
    call CreatePipe
    push 12
    push 28
    call PlaceCoin
    push 12
    push 30
    call PlaceCoin
    push 8
    push 77
    call PlaceCoin
    push 8
    push 79
    call PlaceCoin
    push 12
    push 39
    call PlaceStar
    ret
SetupLevel2 ENDP

SetupLevel3 PROC
    mov ebx, 0
l3_ground_loop:
    cmp ebx, SCREEN_WIDTH
    jge l3_objs
    cmp ebx, 40
    jl l3_draw_g
    cmp ebx, 45
    jl l3_next 
    cmp ebx, 80
    jl l3_draw_g
    cmp ebx, 85
    jl l3_next 
l3_draw_g:
    mov ecx, SCREEN_HEIGHT - 3
    mov eax, ecx
    imul eax, SCREEN_WIDTH
    add eax, ebx
    mov BYTE PTR [levelMap + eax], 1
    mov ecx, SCREEN_HEIGHT - 2
    mov eax, ecx
    imul eax, SCREEN_WIDTH
    add eax, ebx
    mov BYTE PTR [levelMap + eax], 1
l3_next:
    inc ebx
    jmp l3_ground_loop
l3_objs:
    push 5
    push 8
    push 113
    call CreatePlatform
    push 6
    push 16
    push 39 
    call CreatePlatform
    push 6
    push 16
    push 79 
    call CreatePlatform
    push 45
    push 40
    call CreateSpikes
    push 85
    push 80
    call CreateSpikes
    push 14
    push 60
    call PlaceStar
    
    ; --- FAKE HILL GENERATION ---
    ; Loop X from 60 to 79
    mov ebx, 60 
hill_loop:
    cmp ebx, 80
    jge hill_done
    
    mov ecx, 0
hill_height_loop:
    cmp ecx, 6
    jge next_hill_col
    
    ; Calculate index: (SCREEN_HEIGHT - 4 - ecx) * WIDTH + ebx
    mov eax, SCREEN_HEIGHT - 4
    sub eax, ecx
    imul eax, SCREEN_WIDTH
    add eax, ebx
    
    ; Determine Tile Type
    ; Top (ecx=5) -> Fake (6)
    cmp ecx, 5
    je set_solid
    
    ; Walls (ebx=60 or ebx=79) -> Solid (1)
    cmp ebx, 60
    je set_fake
    cmp ebx, 79
    je set_solid
    
    ; Floor (ecx=0) -> Solid (1)
    cmp ecx, 0
    je set_solid
    
    ; Inside -> Coin (4)
    mov BYTE PTR [levelMap + eax], 4
    jmp hill_next_iter

set_fake:
    mov BYTE PTR [levelMap + eax], 6
    jmp hill_next_iter
set_solid:
    mov BYTE PTR [levelMap + eax], 1
    jmp hill_next_iter

hill_next_iter:
    inc ecx
    jmp hill_height_loop
    
next_hill_col:
    inc ebx
    jmp hill_loop
hill_done:
    
    ret
SetupLevel3 ENDP

SetupLevel4 PROC
    mov ebx, 0
l4_ground:
    cmp ebx, SCREEN_WIDTH
    jge l4_objs
    mov ecx, SCREEN_HEIGHT - 3
    mov eax, ecx
    imul eax, SCREEN_WIDTH
    add eax, ebx
    mov BYTE PTR [levelMap + eax], 1
    mov ecx, SCREEN_HEIGHT - 2
    mov eax, ecx
    imul eax, SCREEN_WIDTH
    add eax, ebx
    mov BYTE PTR [levelMap + eax], 1
    inc ebx
    jmp l4_ground
l4_objs:
    push 45
    push 35
    call CreateLavaPit
    push 80
    push 75
    call CreateLavaPit
    push 6
    push 17
    push 37
    call CreatePlatform
    push 6
    push 17
    push 77
    call CreatePlatform
    push 5
    push 8
    push 113
    call CreatePlatform
    push 5
    push 19
    push 20
    call CreateWall
    push 5
    push 19
    push 80
    call CreateWall
    push 5
    push 19
    push 81
    call CreateWall
    push 14
    push 39
    call PlaceStar
    
    ret
SetupLevel4 ENDP

CreateLavaPit PROC
    push ebp
    mov ebp, esp
    pushad
    mov ebx, [ebp + 8]  
    mov edx, [ebp + 12] 
pit_loop_l:
    cmp ebx, edx
    jg pit_done_l
    mov ecx, SCREEN_HEIGHT - 3
    mov eax, ecx
    imul eax, SCREEN_WIDTH
    add eax, ebx
    mov BYTE PTR [levelMap + eax], 0
    mov ecx, SCREEN_HEIGHT - 2
    mov eax, ecx
    imul eax, SCREEN_WIDTH
    add eax, ebx
    mov BYTE PTR [levelMap + eax], 0
    mov ecx, SCREEN_HEIGHT - 1
    mov eax, ecx
    imul eax, SCREEN_WIDTH
    add eax, ebx
    mov BYTE PTR [levelMap + eax], 8
    mov ecx, SCREEN_HEIGHT - 4
    mov eax, ecx
    imul eax, SCREEN_WIDTH
    add eax, ebx
    mov BYTE PTR [levelMap + eax], 5
    inc ebx
    jmp pit_loop_l
pit_done_l:
    popad
    pop ebp
    ret 8
CreateLavaPit ENDP

;-----------------------------------------------------------
; Helper Procedures (Standard)
;-----------------------------------------------------------
PlaceStar PROC
    push ebp
    mov ebp, esp
    pushad
    mov eax, [ebp + 12]
    imul eax, SCREEN_WIDTH
    add eax, [ebp + 8]
    cmp eax, SCREEN_WIDTH * SCREEN_HEIGHT
    jge place_star_skip
    mov BYTE PTR [levelMap + eax], 7 
place_star_skip:
    popad
    pop ebp
    ret 8
PlaceStar ENDP

PlaceCoins PROC
    pushad
    popad
    ret
PlaceCoins ENDP

PlaceCoin PROC
    push ebp
    mov ebp, esp
    pushad
    mov eax, [ebp + 12]
    imul eax, SCREEN_WIDTH
    add eax, [ebp + 8]
    cmp eax, SCREEN_WIDTH * SCREEN_HEIGHT
    jge place_coin_skip
    mov BYTE PTR [levelMap + eax], 4
place_coin_skip:
    popad
    pop ebp
    ret 8
PlaceCoin ENDP

CreatePit PROC
    push ebp
    mov ebp, esp
    pushad
    mov ebx, [ebp + 8]
pit_loop:
    cmp ebx, [ebp + 12]
    jg pit_done
    mov ecx, SCREEN_HEIGHT - 3
    mov eax, ecx
    imul eax, SCREEN_WIDTH
    add eax, ebx
    mov BYTE PTR [levelMap + eax], 0
    mov ecx, SCREEN_HEIGHT - 2
    mov eax, ecx
    imul eax, SCREEN_WIDTH
    add eax, ebx
    mov BYTE PTR [levelMap + eax], 0
    inc ebx
    jmp pit_loop
pit_done:
    popad
    pop ebp
    ret 8
CreatePit ENDP

CreatePlatform PROC
    push ebp
    mov ebp, esp
    pushad
    mov ebx, 0
plat_loop:
    cmp ebx, [ebp + 16]
    jge plat_done
    mov eax, [ebp + 12]
    imul eax, SCREEN_WIDTH
    add eax, [ebp + 8]
    add eax, ebx
    cmp eax, SCREEN_WIDTH * SCREEN_HEIGHT
    jge plat_skip
    mov BYTE PTR [levelMap + eax], 2
plat_skip:
    inc ebx
    jmp plat_loop
plat_done:
    popad
    pop ebp
    ret 12
CreatePlatform ENDP

CreatePipe PROC
    push ebp
    mov ebp, esp
    pushad
    mov ecx, 0
pipe_loop:
    cmp ecx, [ebp + 16]
    jge pipe_done
    mov eax, [ebp + 12]
    sub eax, ecx
    cmp eax, 0
    jl pipe_skip
    cmp eax, SCREEN_HEIGHT
    jge pipe_skip
    imul eax, SCREEN_WIDTH
    add eax, [ebp + 8]
    cmp eax, SCREEN_WIDTH * SCREEN_HEIGHT
    jge pipe_skip
    mov BYTE PTR [levelMap + eax], 10    ; First block
    mov edx, eax
    inc edx
    cmp edx, SCREEN_WIDTH * SCREEN_HEIGHT
    jge pipe_skip
    mov BYTE PTR [levelMap + edx], 10    ; Second block

pipe_skip:
    inc ecx
    jmp pipe_loop
pipe_done:
    popad
    pop ebp
    ret 12
CreatePipe ENDP

CreateWall PROC
    push ebp
    mov ebp, esp
    pushad
    mov ecx, 0
wall_loop:
    cmp ecx, [ebp + 16]
    jge wall_done
    mov eax, [ebp + 12]
    add eax, ecx
    cmp eax, SCREEN_HEIGHT
    jge wall_skip
    imul eax, SCREEN_WIDTH
    add eax, [ebp + 8]
    cmp eax, SCREEN_WIDTH * SCREEN_HEIGHT
    jge wall_skip
    mov BYTE PTR [levelMap + eax], 1
wall_skip:
    inc ecx
    jmp wall_loop
wall_done:
    popad
    pop ebp
    ret 12
CreateWall ENDP

CreateSpikes PROC
    push ebp
    mov ebp, esp
    pushad
    mov ebx, [ebp + 8]
spike_loop:
    cmp ebx, [ebp + 12]
    jg spike_done
    mov eax, SCREEN_HEIGHT - 4
    imul eax, SCREEN_WIDTH
    add eax, ebx
    cmp eax, SCREEN_WIDTH * SCREEN_HEIGHT
    jge spike_skip
    mov BYTE PTR [levelMap + eax], 5
spike_skip:
    inc ebx
    jmp spike_loop
spike_done:
    popad
    pop ebp
    ret 8
CreateSpikes ENDP

;-----------------------------------------------------------
; UpdateFirePits - Update fire pit fireballs
;-----------------------------------------------------------

UpdateFirePits PROC
    pushad
    
    ; Only active in Level 4
    mov al, currentLevel
    cmp al, 4
    jne fire_pit_done
    
    mov esi, 0
fire_pit_loop:
    cmp esi, MAX_FIRE_PITS
    jge fire_pit_done
    
    ; Update timer
    inc firePitTimer[esi]
    
    ; Check if should spawn new fireball (every 60 frames - FASTER FOR TESTING)
    xor eax, eax
    mov al, firePitTimer[esi]
    cmp al, 60
    jl fire_check_active
    
    ; Reset timer and spawn fireball
    mov firePitTimer[esi], 0
    
    xor eax, eax
    mov al, fireballActive[esi]
    cmp al, 0
    jne fire_check_active  ; Don't spawn if one already active
    
    ; Spawn fireball
    INVOKE Beep, 500, 20
    mov fireballActive[esi], 1
    
    xor eax, eax
    mov al, firePitX[esi]
    mov fireballX[esi], al
    mov fireballY[esi], 21  ; Start just above lava
    mov fireballStartY[esi], 21
    mov fireballVelY[esi*4], -1  ; Move upward
    mov fireballPeakReached[esi], 0
    
fire_check_active:
    ; Update active fireball
    xor eax, eax
    mov al, fireballActive[esi]
    cmp al, 0
    je fire_next_pit
    
    ; Store previous position
    xor eax, eax
    mov al, fireballX[esi]
    mov fireballPrevX[esi], al
    xor eax, eax
    mov al, fireballY[esi]
    mov fireballPrevY[esi], al
    
    ; Check if reached peak 
    xor eax, eax
    mov al, fireballStartY[esi]
    xor ebx, ebx
    mov bl, fireballY[esi]
    sub eax, ebx  ; Distance traveled upward
    
    cmp eax, 10  ;
    jl fire_continue_up
    
    ; Start going down
    mov fireballPeakReached[esi], 1
    mov fireballVelY[esi*4], 1  ; Change to downward
    
fire_continue_up:
    ; Update Y position
    xor ebx, ebx
    mov bl, fireballY[esi]
    mov eax, fireballVelY[esi*4]
    add ebx, eax
    
    ; Check if returned to start position (going down)
    xor eax, eax
    mov al, fireballPeakReached[esi]
    cmp al, 1
    jne fire_check_bounds
    
    xor eax, eax
    mov al, fireballStartY[esi]
    cmp bl, al
    jge fire_deactivate  ; Reached bottom, deactivate
    
fire_check_bounds:
    ; Check bounds
    cmp ebx, 0
    jl fire_deactivate
    cmp ebx, SCREEN_HEIGHT
    jge fire_deactivate
    
    ; Update position (no collision check with terrain)
    mov fireballY[esi], bl
    
    ; Check collision with Mario
    xor eax, eax
    mov al, fireballX[esi]
    xor ebx, ebx
    mov bl, marioX
    sub al, bl
    ; Absolute value
    cmp al, 0
    jge fire_abs_done
    neg al
fire_abs_done:
    cmp al, 1
    jg fire_next_pit
    
    ; Check Y collision
    xor eax, eax
    mov al, fireballY[esi]
    xor ebx, ebx
    mov bl, marioY
    sub al, bl
    cmp al, 0
    jge fire_y_abs
    neg al
fire_y_abs:
    cmp al, 2
    jg fire_next_pit
    
    ; Hit Mario!
    xor eax, eax
    mov al, marioState
    cmp al, 2  ; Check if Mario has star power
    je fire_ignore_hit
    
    call LoseLife
    
fire_ignore_hit:
    mov fireballActive[esi], 0
    jmp fire_next_pit
    
fire_deactivate:
    mov fireballActive[esi], 0
    
fire_next_pit:
    inc esi
    jmp fire_pit_loop
    
fire_pit_done:
    popad
    ret
UpdateFirePits ENDP

;-----------------------------------------------------------
; EraseFireballs - Erase previous fireball positions
;-----------------------------------------------------------
EraseFireballs PROC
    pushad
    
    mov al, currentLevel
    cmp al, 4
    jne erase_fire_done
    
    mov esi, 0
erase_fire_loop:
    cmp esi, MAX_FIRE_PITS
    jge erase_fire_done
    
    xor eax, eax
    mov al, fireballPrevX[esi]
    cmp al, 0
    jl erase_fire_next
    cmp al, SCREEN_WIDTH
    jge erase_fire_next
    
    mov dl, al
    mov dh, fireballPrevY[esi]
    call Gotoxy
    
    ; Check what's at previous position and redraw it
    xor eax, eax
    mov al, fireballPrevX[esi]
    xor ebx, ebx
    mov bl, fireballPrevY[esi]
    push ebx
    push eax
    call CheckCollision
    cmp eax, 0
    je erase_fire_empty
    
    ; Check map tile type
    xor eax, eax
    mov al, fireballPrevY[esi]
    imul eax, SCREEN_WIDTH
    xor ebx, ebx
    mov bl, fireballPrevX[esi]
    add eax, ebx
    
    xor ecx, ecx
    mov cl, BYTE PTR [levelMap + eax]
    cmp cl, 1
    je erase_fire_ground
    cmp cl, 8
    je erase_fire_lava
    
erase_fire_empty:
    mov eax, currentBgColor
    call SetTextColor
    mov al, ' '
    call WriteChar
    jmp erase_fire_next

erase_fire_ground:
    mov eax, currentGroundColor
    add eax, currentBgColor
    call SetTextColor
    mov al, 219
    call WriteChar
    jmp erase_fire_next
    
erase_fire_lava:
    mov eax, BG_RED_VAL
    add eax, COLOR_LAVA
    call SetTextColor
    mov al, LAVA_CHAR
    call WriteChar
    jmp erase_fire_next
    
erase_fire_next:
    inc esi
    jmp erase_fire_loop
    
erase_fire_done:
    popad
    ret
EraseFireballs ENDP

;-----------------------------------------------------------
; DrawFireballs - Draw active fireballs
;-----------------------------------------------------------
DrawFireballs PROC
    pushad
    
    mov al, currentLevel
    cmp al, 4
    jne draw_fire_done
    
    mov esi, 0
draw_fire_loop:
    cmp esi, MAX_FIRE_PITS
    jge draw_fire_done
    
    xor eax, eax
    mov al, fireballActive[esi]
    cmp al, 0
    je draw_fire_next
    
    xor eax, eax
    mov al, fireballX[esi]
    mov dl, al
    xor eax, eax
    mov al, fireballY[esi]
    mov dh, al
    call Gotoxy
    
    ; Use BRIGHT YELLOW (14) on current background
    mov eax, 14  ; Bright Yellow
    add eax, currentBgColor
    call SetTextColor
    mov al, '0'  ; Star character
    call WriteChar
    
draw_fire_next:
    inc esi
    jmp draw_fire_loop
    
draw_fire_done:
    popad
    ret
DrawFireballs ENDP

;-----------------------------------------------------------
; InitializeEnemies
;-----------------------------------------------------------
InitializeEnemies PROC
    pushad
    mov ecx, MAX_ENEMIES
    mov esi, 0
reset_enem:
    mov enemyType[esi], 0
    mov enemyActionTimer[esi], 0
    inc esi
    loop reset_enem
    
    mov al, currentLevel
    cmp al, 1
    je init_l1_enemies
    cmp al, 2
    je init_l2_enemies
    cmp al, 3
    je init_l3_enemies
    cmp al, 4
    je init_l4_enemies
    jmp init_enem_done

init_l1_enemies:
    mov enemyType[0], 1 
    mov enemyX[0], 18
    mov enemyY[0], 21
    mov enemyVelX[0*4], -1
    mov enemyState[0], STATE_NORMAL
    mov enemyType[1], 2
    mov enemyX[1], 35
    mov enemyY[1], 14
    mov enemyVelX[1*4], 1
    mov enemyState[1], STATE_NORMAL
    mov enemyType[2], 3
    mov enemyX[2], 50
    mov enemyY[2], 10
    mov enemyVelX[2*4], 1
    mov enemyState[2], STATE_NORMAL
    jmp init_enem_done

init_l2_enemies:
    mov enemyType[0], 3
    mov enemyX[0], 30
    mov enemyY[0], 8
    mov enemyVelX[0*4], 1
    mov enemyState[0], STATE_NORMAL
    mov enemyType[1], 3
    mov enemyX[1], 80
    mov enemyY[1], 6
    mov enemyVelX[1*4], -1
    mov enemyState[1], STATE_NORMAL
    mov enemyType[2], 2
    mov enemyX[2], 60
    mov enemyY[2], 21
    mov enemyVelX[2*4], 1
    mov enemyState[2], STATE_NORMAL
    jmp init_enem_done

init_l3_enemies:
    mov enemyType[0], 3 
    mov enemyX[0], 30
    mov enemyY[0], 10
    mov enemyVelX[0*4], 1
    mov enemyState[0], STATE_NORMAL
    mov enemyType[1], 2 
    mov enemyX[1], 60
    mov enemyY[1], 21
    mov enemyVelX[1*4], -1
    mov enemyState[1], STATE_NORMAL
    mov enemyType[2], 1 
    mov enemyX[2], 90
    mov enemyY[2], 21
    mov enemyVelX[2*4], 1
    mov enemyState[2], STATE_NORMAL
    jmp init_enem_done

init_l4_enemies:
    ; BOSS
    mov enemyType[0], 4 
    mov enemyX[0], 100
    mov enemyY[0], 21
    mov enemyVelX[0*4], -1
    mov enemyState[0], STATE_NORMAL
    mov enemyHealth[0], 5   ; boss health is here 
    mov enemyActionTimer[0], 0
    
    ; Minions
    mov enemyType[1], 3
    mov enemyX[1], 50
    mov enemyY[1], 10
    mov enemyVelX[1*4], 1
    mov enemyState[1], STATE_NORMAL
    jmp init_enem_done

init_enem_done:
    popad
    ret
InitializeEnemies ENDP

;-----------------------------------------------------------
; InitializeFirePits - Initialize fire pit data for Level 4
;-----------------------------------------------------------
InitializeFirePits PROC
    pushad
    

    mov al, currentLevel
    cmp al, 4
    jne init_fire_skip
    
    ; Initialize Fire Pit 1 (first lava pit: columns 35-45)
    mov firePitX[0], 40    ; Center of first lava pit
    mov firePitTimer[0], 0
    mov fireballActive[0], 0
    mov fireballPeakReached[0], 0
    mov fireballPrevX[0], 0
    mov fireballPrevY[0], 0
    
    ; Initialize Fire Pit 2 (second lava pit: columns 75-80)
    mov firePitX[1], 77    ; Center of second lava pit
    mov firePitTimer[1], 45  ; Offset timing
    mov fireballActive[1], 0
    mov fireballPeakReached[1], 0
    mov fireballPrevX[1], 0
    mov fireballPrevY[1], 0
    
init_fire_skip:
    popad
    ret
InitializeFirePits ENDP

;-----------------------------------------------------------
; CheckCollision
;-----------------------------------------------------------
;-----------------------------------------------------------
; CheckCollision
;-----------------------------------------------------------
CheckCollision PROC
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    mov eax, [ebp + 8]
    cmp eax, 0
    jl collision_yes
    cmp eax, SCREEN_WIDTH
    jge collision_yes
    mov eax, [ebp + 12]
    cmp eax, 0
    jl collision_yes
    cmp eax, SCREEN_HEIGHT
    jge collision_yes
    
    ; Index calc with mov/xor
    xor eax, eax
    mov eax, [ebp + 12]
    imul eax, SCREEN_WIDTH
    add eax, [ebp + 8]
    
    xor ecx, ecx
    mov cl, BYTE PTR [levelMap + eax]
    
    cmp cl, 4
    je collision_no
    cmp cl, 5
    je collision_no
    cmp cl, 6 ; Fake Wall is Passable
    je collision_no
    cmp cl, 7
    je collision_no
    cmp cl, 8 
    je collision_no
    cmp cl, 9 ; Princess
    je collision_no
    cmp cl, 0
    je collision_no
collision_yes:
    mov eax, 1
    jmp collision_end
collision_no:
    xor eax, eax
collision_end:
    pop ecx
    pop ebx
    pop ebp
    ret 8
CheckCollision ENDP

;-----------------------------------------------------------
; CheckBossProjectileCollision
;-----------------------------------------------------------
CheckBossProjectileCollision PROC
    pushad
    ; ESI is passed in as index
    
    xor eax, eax
    mov al, bossProjX[esi]
    xor ebx, ebx
    mov bl, marioX
    sub eax, ebx
    
    ; Absolute check
    cdq
    xor eax, edx
    sub eax, edx
    
    cmp eax, 1
    jg check_bp_fail ; Distance > 1 means no hit
    
    ; Y check
    xor eax, eax
    mov al, bossProjY[esi]
    xor ebx, ebx
    mov bl, marioY
    sub eax, ebx
    cdq
    xor eax, edx
    sub eax, edx
    
    cmp eax, 2
    jg check_bp_fail
    
    ; Hit!
    call LoseLife
    mov bossProjActive[esi], 0 
    
check_bp_fail:
    popad
    ret
CheckBossProjectileCollision ENDP

;-----------------------------------------------------------
; BossShootProjectile
;-----------------------------------------------------------
BossShootProjectile PROC
    pushad
    mov edi, 0
find_bp_slot:
    cmp edi, MAX_BOSS_PROJ
    jge bp_shoot_end
    mov al, bossProjActive[edi]
    cmp al, 0
    je spawn_bp
    inc edi
    jmp find_bp_slot
spawn_bp:
    mov bossProjActive[edi], 1
    mov al, enemyX[esi]
    mov bossProjX[edi], al
    mov al, enemyY[esi]
    mov bossProjY[edi], al
    
    mov al, marioX
    mov bl, enemyX[esi]
    cmp al, bl
    jl fire_left
    mov bossProjVelX[edi*4], 2
    jmp set_bp_y
fire_left:
    mov bossProjVelX[edi*4], -2
set_bp_y:
    mov bossProjVelY[edi*4], 0
    INVOKE Beep, 1000, 20
bp_shoot_end:
    popad
    ret
BossShootProjectile ENDP

UpdateBossProjectiles PROC
    pushad
    mov esi, 0
bp_loop:
    cmp esi, MAX_BOSS_PROJ
    jge bp_done
    mov al, bossProjActive[esi]
    cmp al, 0
    je bp_next
    mov al, bossProjX[esi]
    mov bossProjPrevX[esi], al
    mov al, bossProjY[esi]
    mov bossProjPrevY[esi], al
    
    xor ebx, ebx
    mov bl, bossProjX[esi]
    mov eax, bossProjVelX[esi*4]
    add ebx, eax
    cmp ebx, 0
    jl kill_bp
    cmp ebx, SCREEN_WIDTH
    jge kill_bp
    
    xor eax, eax
    mov al, bossProjY[esi]
    push eax
    push ebx
    call CheckCollision
    cmp eax, 1
    je kill_bp
    mov al, bl
    mov bossProjX[esi], al
    call CheckBossProjectileCollision
    jmp bp_next
kill_bp:
    mov bossProjActive[esi], 0
bp_next:
    inc esi
    jmp bp_loop
bp_done:
    popad
    ret
UpdateBossProjectiles ENDP

EraseBossProjectiles PROC
    pushad
    mov esi, 0
ebp_loop:
    cmp esi, MAX_BOSS_PROJ
    jge ebp_done
    
    xor eax, eax
    mov al, bossProjPrevX[esi]
    cmp al, 0 
    
    cmp eax, SCREEN_WIDTH
    jge ebp_next
    mov dl, al
    mov dh, bossProjPrevY[esi]
    call Gotoxy
    mov eax, currentBgColor
    call SetTextColor
    mov al, ' '
    call WriteChar
ebp_next:
    inc esi
    jmp ebp_loop
ebp_done:
    popad
    ret
EraseBossProjectiles ENDP

DrawBossProjectiles PROC
    pushad
    mov esi, 0
dbp_loop:
    cmp esi, MAX_BOSS_PROJ
    jge dbp_done
    mov al, bossProjActive[esi]
    cmp al, 0
    je dbp_next
    mov dl, bossProjX[esi]
    mov dh, bossProjY[esi]
    call Gotoxy
    mov eax, COLOR_BOSS_PROJ
    add eax, currentBgColor
    call SetTextColor
    mov al, '*'
    call WriteChar
dbp_next:
    inc esi
    jmp dbp_loop
dbp_done:
    popad
    ret
DrawBossProjectiles ENDP

;-----------------------------------------------------------
; DrawFullScreen
;-----------------------------------------------------------
DrawFullScreen PROC
    pushad
    mov dh, 0
    mov dl, 5
    call Gotoxy
    mov eax, COLOR_FLAG
    add eax, currentBgColor
    call SetTextColor
    mov edx, OFFSET titleMsg
    call WriteString
    call DrawUI
    
    mov al, currentLevel
    cmp al, 4
    je draw_boss_name
    jmp draw_map_start

draw_boss_name:
    mov dh, 2
    mov dl, 50
    call Gotoxy
    mov eax, COLOR_BOSS
    add eax, currentBgColor
    call SetTextColor
    mov edx, OFFSET bossNameMsg
    call WriteString
    jmp draw_map_start
    
draw_map_start:
    mov edx, 1
draw_row:
    cmp edx, SCREEN_HEIGHT
    jge draw_done
    mov ebx, 0
draw_col:
    cmp ebx, SCREEN_WIDTH
    jge draw_row_done
    push ebx
    push edx
    mov ecx, edx
    imul ecx, SCREEN_WIDTH
    add ecx, ebx
    
    xor eax, eax
    mov al, BYTE PTR [levelMap + ecx]
    pop edx
    pop ebx
    push edx
    push ebx
    mov dh, dl
    mov dl, bl
    call Gotoxy
    pop ebx
    pop edx
    
    cmp al, 0
    je draw_empty
    cmp al, 1
    je draw_ground_tile
    cmp al, 2
    je draw_platform_tile
    cmp al, 3
    je draw_floor_tile
    cmp al, 4
    je draw_coin_tile
    cmp al, 5
    je draw_spike_tile
    cmp al, 6
    je draw_fake_wall
    cmp al, 7
    je draw_star_tile
    cmp al, 8
    je draw_lava_tile
    cmp al, 10              ; NEW: Check for pipe
    je draw_pipe_tile       ; NEW: Jump to pipe drawing
    jmp draw_next_col
    
draw_pipe_tile:
    mov eax, COLOR_PIPE
    add eax, currentBgColor
    call SetTextColor
    mov al, 219              ; 
    call WriteChar
    jmp draw_next_col

draw_ground_tile:
    mov eax, currentGroundColor
    add eax, currentBgColor
    call SetTextColor
    mov al, 219
    call WriteChar
    jmp draw_next_col
draw_fake_wall:
    mov eax, currentGroundColor ; Same color as ground
    add eax, currentBgColor
    call SetTextColor
    mov al, 219 ; Same char as ground
    call WriteChar
    jmp draw_next_col
draw_platform_tile:
    mov eax, COLOR_PLATFORM
    add eax, currentBgColor
    call SetTextColor
    mov al, '='
    call WriteChar
    jmp draw_next_col
draw_floor_tile:
    mov eax, COLOR_FLOOR
    add eax, currentBgColor
    call SetTextColor
    mov al, '='
    call WriteChar
    jmp draw_next_col
draw_coin_tile:
    mov eax, COLOR_COIN
    add eax, currentBgColor
    call SetTextColor
    mov al, COIN_CHAR
    call WriteChar
    jmp draw_next_col
draw_spike_tile:
    mov eax, COLOR_SPIKE
    add eax, currentBgColor
    call SetTextColor
    mov al, '^'
    call WriteChar
    jmp draw_next_col
draw_star_tile:
    mov eax, COLOR_STAR
    add eax, currentBgColor
    call SetTextColor
    mov al, STAR_CHAR
    call WriteChar
    jmp draw_next_col
draw_lava_tile:
    mov eax, BG_RED_VAL ; Full Red Background
    add eax, COLOR_LAVA ; Red Foreground
    call SetTextColor
    mov al, LAVA_CHAR
    call WriteChar
    jmp draw_next_col
draw_empty:
    mov eax, currentBgColor
    call SetTextColor
    mov al, ' '
    call WriteChar
    jmp draw_next_col

draw_next_col:
    inc ebx
    jmp draw_col
draw_row_done:
    inc edx
    jmp draw_row
draw_done:
    call DrawFlag
    call DrawMario
    call DrawProjectile
    call DrawFireballs 
    call DrawEnemies
    call DrawBossProjectiles
    popad
    ret
DrawFullScreen ENDP

;-----------------------------------------------------------
; DrawFlag
;-----------------------------------------------------------
DrawFlag PROC
    pushad
    mov dl, 115
    mov dh, 6
    call Gotoxy
    mov eax, COLOR_FLAG
    add eax, currentBgColor
    call SetTextColor
    mov al, 'F'
    call WriteChar
    mov dl, 116
    mov dh, 6
    call Gotoxy
    mov al, '>'
    call WriteChar
    popad
    ret
DrawFlag ENDP

;-----------------------------------------------------------
; DrawUI
;-----------------------------------------------------------
DrawUI PROC
    pushad
    mov dh, 0
    mov dl, 105
    call Gotoxy
    mov eax, COLOR_TIME
    add eax, currentBgColor
    call SetTextColor
    mov edx, OFFSET hiScoreMsg
    call WriteString
    mov eax, highScore
    call WriteDec
    
    mov dh, 0
    mov dl, 90
    call Gotoxy
    mov eax, COLOR_TIME
    add eax, currentBgColor
    call SetTextColor
    mov edx, OFFSET timeMsg
    call WriteString
    mov eax, timerCount
    call WriteDec
    mov al, ' '
    call WriteChar
    
    mov dh, 0
    mov dl, 50
    call Gotoxy
    mov eax, COLOR_MARIO
    add eax, currentBgColor
    call SetTextColor
    mov edx, OFFSET livesMsg
    call WriteString
    mov eax, livesCount
    call WriteDec
    mov al, ' '
    call WriteChar
    
    mov dh, 0
    mov dl, 65
    call Gotoxy
    mov eax, COLOR_COIN
    add eax, currentBgColor
    call SetTextColor
    mov edx, OFFSET scoreMsg
    call WriteString
    mov eax, scoreCount
    call WriteDec
    mov al, ' '
    call WriteChar
    
    mov dh, 0
    mov dl, 80
    call Gotoxy
    mov eax, COLOR_TIME
    add eax, currentBgColor
    call SetTextColor
    mov edx, OFFSET modeMsg
    call WriteString
    mov al, marioState
    cmp al, 0
    je show_mode_s
    cmp al, 1
    je show_mode_b
    cmp al, 2
    je show_mode_f
    jmp draw_ui_done
show_mode_s:
    mov edx, OFFSET modeS
    call WriteString
    jmp draw_ui_done
show_mode_b:
    mov edx, OFFSET modeB
    call WriteString
    jmp draw_ui_done
show_mode_f:
    mov edx, OFFSET modeF
    call WriteString
draw_ui_done:
    popad
    ret
DrawUI ENDP

;-----------------------------------------------------------
; UpdateTimer
;-----------------------------------------------------------
UpdateTimer PROC
    pushad
    call GetMseconds
    sub eax, lastTick
    cmp eax, 1000
    jl timer_skip
    call GetMseconds
    mov lastTick, eax
    dec timerCount
    call DrawUI
    cmp timerCount, 0
    jg timer_skip
    call LoseLife
timer_skip:
    popad
    ret
UpdateTimer ENDP

;-----------------------------------------------------------
; EraseMario
;-----------------------------------------------------------
EraseMario PROC
    pushad
    xor eax, eax
    mov al, prevMarioX
    cmp al, 0
    jl erase_skip
    cmp al, SCREEN_WIDTH
    jge erase_skip
    mov dl, al
    mov dh, prevMarioY
    call Gotoxy
    
    xor eax, eax
    mov al, prevMarioX
    xor ebx, ebx
    mov bl, prevMarioY
    push ebx
    push eax
    call CheckCollision
    cmp eax, 0
    je erase_empty
    
    xor eax, eax
    mov al, prevMarioY
    imul eax, SCREEN_WIDTH
    xor ebx, ebx
    mov bl, prevMarioX
    add eax, ebx
    
    xor ecx, ecx
    mov cl, BYTE PTR [levelMap + eax]
    cmp cl, 1
    je erase_ground
    cmp cl, 2
    je erase_platform
    cmp cl, 3
    je erase_floor
    cmp cl, 4
    je erase_coin
    cmp cl, 5
    je erase_spike
    cmp cl, 6
    je erase_fake_wall
    cmp cl, 7
    je erase_star
    cmp cl, 8
    je erase_lava
erase_empty:
    mov eax, currentBgColor
    call SetTextColor
    mov al, ' '
    call WriteChar
    jmp erase_skip

erase_ground:
    mov eax, currentGroundColor
    add eax, currentBgColor
    call SetTextColor
    mov al, 219
    call WriteChar
    jmp erase_skip
erase_fake_wall:
    mov eax, currentGroundColor
    add eax, currentBgColor
    call SetTextColor
    mov al, 219
    call WriteChar
    jmp erase_skip
erase_platform:
    mov eax, COLOR_PLATFORM
    add eax, currentBgColor
    call SetTextColor
    mov al, '='
    call WriteChar
    jmp erase_skip
erase_floor:
    mov eax, COLOR_FLOOR
    add eax, currentBgColor
    call SetTextColor
    mov al, '='
    call WriteChar
    jmp erase_skip
erase_coin:
    mov eax, COLOR_COIN
    add eax, currentBgColor
    call SetTextColor
    mov al, COIN_CHAR
    call WriteChar
    jmp erase_skip
erase_spike:
    mov eax, COLOR_SPIKE
    add eax, currentBgColor
    call SetTextColor
    mov al, '^'
    call WriteChar
    jmp erase_skip
erase_star:
    mov eax, COLOR_STAR
    add eax, currentBgColor
    call SetTextColor
    mov al, STAR_CHAR
    call WriteChar
    jmp erase_skip
erase_lava:
    mov eax, BG_RED_VAL
    add eax, COLOR_LAVA
    call SetTextColor
    mov al, LAVA_CHAR
    call WriteChar
    jmp erase_skip
erase_skip:
    popad
    ret
EraseMario ENDP

;-----------------------------------------------------------
; DrawMario
;-----------------------------------------------------------
DrawMario PROC
    pushad
    xor eax, eax
    mov al, marioX
    cmp al, 0
    jl mario_skip
    cmp al, SCREEN_WIDTH
    jge mario_skip
    mov dl, al
    mov dh, marioY
    call Gotoxy
    
    mov al, marioState
    cmp al, 2
    je draw_red_star_mario
    mov eax, COLOR_MARIO
    add eax, currentBgColor
    jmp do_draw_mario
draw_red_star_mario:
    mov eax, COLOR_MARIO_STAR
    add eax, currentBgColor
do_draw_mario:
    call SetTextColor
    mov al, 'M'
    call WriteChar
mario_skip:
    popad
    ret
DrawMario ENDP

;-----------------------------------------------------------
; ShootProjectile
;-----------------------------------------------------------
ShootProjectile PROC
    pushad
    mov al, marioState
    cmp al, 1
    jl shoot_skip
    mov esi, 0
shoot_find_loop:
    cmp esi, MAX_PROJECTILES
    jge shoot_skip
    mov al, projectileActive[esi]
    cmp al, 0
    je found_slot
    inc esi
    jmp shoot_find_loop
found_slot:
    INVOKE Beep, 2000, 20
    mov projectileActive[esi], 1
    mov al, marioX
    add al, 1
    mov projectileX[esi], al
    mov al, marioY
    mov projectileY[esi], al
    mov projectileVelX[esi*4], 2
    mov projectileVelY[esi*4], 0
    mov al, marioState
    mov projectileColorType[esi], al
shoot_skip:
    popad
    ret
ShootProjectile ENDP

;-----------------------------------------------------------
; UpdateProjectile
;-----------------------------------------------------------
UpdateProjectile PROC
    pushad
    mov esi, 0
proj_loop:
    cmp esi, MAX_PROJECTILES
    jge proj_done
    mov al, projectileActive[esi]
    cmp al, 0
    je proj_next
    mov al, projectileX[esi]
    mov prevProjectileX[esi], al
    mov al, projectileY[esi]
    mov prevProjectileY[esi], al
    
    xor ebx, ebx
    mov bl, projectileX[esi]
    mov eax, projectileVelX[esi*4]
    add ebx, eax
    cmp ebx, 0
    jl deactivate_proj
    cmp ebx, SCREEN_WIDTH
    jge deactivate_proj
    
    xor eax, eax
    mov al, projectileY[esi]
    push eax
    push ebx
    call CheckCollision
    cmp eax, 1
    je deactivate_proj
    mov al, bl
    mov projectileX[esi], al
    call CheckProjectileCollisions
    jmp proj_next
deactivate_proj:
    mov projectileActive[esi], 0
proj_next:
    inc esi
    jmp proj_loop
proj_done:
    popad
    ret
UpdateProjectile ENDP

;-----------------------------------------------------------
; EraseProjectile
;-----------------------------------------------------------
EraseProjectile PROC
    pushad
    mov esi, 0
erase_proj_loop:
    cmp esi, MAX_PROJECTILES
    jge erase_proj_done
    
    xor eax, eax
    mov al, prevProjectileX[esi]
    cmp al, 0
    jl erase_proj_next
    cmp al, SCREEN_WIDTH
    jge erase_proj_next
    mov dl, al
    mov dh, prevProjectileY[esi]
    call Gotoxy
    
    xor eax, eax
    mov al, prevProjectileX[esi]
    xor ebx, ebx
    mov bl, prevProjectileY[esi]
    push ebx
    push eax
    call CheckCollision
    cmp eax, 0
    je erase_proj_empty
    
    xor eax, eax
    mov al, prevProjectileY[esi]
    imul eax, SCREEN_WIDTH
    xor ebx, ebx
    mov bl, prevProjectileX[esi]
    add eax, ebx
    
    xor ecx, ecx
    mov cl, BYTE PTR [levelMap + eax]
    cmp cl, 1
    je erase_proj_ground
    cmp cl, 2
    je erase_proj_platform
    cmp cl, 3
    je erase_proj_floor
    cmp cl, 4
    je erase_proj_coin
    cmp cl, 5
    je erase_proj_spike
    cmp cl, 7
    je erase_proj_star
    cmp cl, 8
    je erase_proj_lava
erase_proj_empty:
    mov eax, currentBgColor
    call SetTextColor
    mov al, ' '
    call WriteChar
    jmp erase_proj_reset

erase_proj_ground:
    mov eax, currentGroundColor
    add eax, currentBgColor
    call SetTextColor
    mov al, 219
    call WriteChar
    jmp erase_proj_reset
erase_proj_platform:
    mov eax, COLOR_PLATFORM
    add eax, currentBgColor
    call SetTextColor
    mov al, '='
    call WriteChar
    jmp erase_proj_reset
erase_proj_floor:
    mov eax, COLOR_FLOOR
    add eax, currentBgColor
    call SetTextColor
    mov al, '='
    call WriteChar
    jmp erase_proj_reset
erase_proj_coin:
    mov eax, COLOR_COIN
    add eax, currentBgColor
    call SetTextColor
    mov al, COIN_CHAR
    call WriteChar
    jmp erase_proj_reset
erase_proj_spike:
    mov eax, COLOR_SPIKE
    add eax, currentBgColor
    call SetTextColor
    mov al, '^'
    call WriteChar
    jmp erase_proj_reset
erase_proj_star:
    mov eax, COLOR_STAR
    add eax, currentBgColor
    call SetTextColor
    mov al, STAR_CHAR
    call WriteChar
    jmp erase_proj_reset
erase_proj_lava:
    mov eax, BG_RED_VAL
    add eax, COLOR_LAVA
    call SetTextColor
    mov al, LAVA_CHAR
    call WriteChar
    jmp erase_proj_reset
erase_proj_reset:
    mov prevProjectileX[esi], -1 
erase_proj_next:
    inc esi
    jmp erase_proj_loop
erase_proj_done:
    popad
    ret
EraseProjectile ENDP

;-----------------------------------------------------------
; DrawProjectile
;-----------------------------------------------------------
DrawProjectile PROC
    pushad
    mov esi, 0
draw_proj_loop:
    cmp esi, MAX_PROJECTILES
    jge draw_proj_done
    mov al, projectileActive[esi]
    cmp al, 0
    je draw_proj_next
    mov al, projectileX[esi]
    cmp al, 0
    jl draw_proj_next
    cmp al, SCREEN_WIDTH
    jge draw_proj_next
    mov dl, al
    mov dh, projectileY[esi]
    call Gotoxy
    mov al, projectileColorType[esi]
    cmp al, 2
    je draw_red_proj
    mov eax, COLOR_PROJECTILE
    jmp do_draw_proj
draw_red_proj:
    mov eax, COLOR_FIREBALL
do_draw_proj:
    add eax, currentBgColor
    call SetTextColor
    mov al, 'o'
    call WriteChar
draw_proj_next:
    inc esi
    jmp draw_proj_loop
draw_proj_done:
    popad
    ret
DrawProjectile ENDP

;-----------------------------------------------------------
; EraseEnemies
;-----------------------------------------------------------
EraseEnemies PROC
    pushad
    mov esi, 0
erase_enemy_loop:
    cmp esi, MAX_ENEMIES
    jge erase_enemy_done
    mov al, enemyType[esi]
    cmp al, 0
    je erase_enemy_next
    mov al, enemyState[esi]
    cmp al, STATE_DEAD
    je erase_enemy_next
    
    xor eax, eax
    mov al, prevEnemyX[esi]
    xor ebx, ebx
    mov bl, prevEnemyY[esi]
    cmp al, 0
    jl erase_enemy_next
    cmp al, SCREEN_WIDTH
    jge erase_enemy_next
    mov dl, al
    mov dh, bl
    call Gotoxy
    push ebx
    push eax
    call CheckCollision
    cmp eax, 0
    je erase_enemy_empty
    
    xor eax, eax
    mov al, prevEnemyY[esi]
    imul eax, SCREEN_WIDTH
    xor ebx, ebx
    mov bl, prevEnemyX[esi]
    add eax, ebx
    
    xor ecx, ecx
    mov cl, BYTE PTR [levelMap + eax]
    cmp cl, 1
    je erase_enemy_ground
    cmp cl, 2
    je erase_enemy_platform
    cmp cl, 3
    je erase_enemy_floor
    cmp cl, 4
    je erase_enemy_coin
    cmp cl, 5
    je erase_enemy_spike
    cmp cl, 7
    je erase_enemy_star
    cmp cl, 8
    je erase_enemy_lava
erase_enemy_empty:
    mov eax, currentBgColor
    call SetTextColor
    mov al, ' '
    call WriteChar
    jmp erase_enemy_next

erase_enemy_ground:
    mov eax, currentGroundColor
    add eax, currentBgColor
    call SetTextColor
    mov al, 219
    call WriteChar
    jmp erase_enemy_next
erase_enemy_platform:
    mov eax, COLOR_PLATFORM
    add eax, currentBgColor
    call SetTextColor
    mov al, '='
    call WriteChar
    jmp erase_enemy_next
erase_enemy_floor:
    mov eax, COLOR_FLOOR
    add eax, currentBgColor
    call SetTextColor
    mov al, '='
    call WriteChar
    jmp erase_enemy_next
erase_enemy_coin:
    mov eax, COLOR_COIN
    add eax, currentBgColor
    call SetTextColor
    mov al, COIN_CHAR
    call WriteChar
    jmp erase_enemy_next
erase_enemy_spike:
    mov eax, COLOR_SPIKE
    add eax, currentBgColor
    call SetTextColor
    mov al, '^'
    call WriteChar
    jmp erase_enemy_next
erase_enemy_star:
    mov eax, COLOR_STAR
    add eax, currentBgColor
    call SetTextColor
    mov al, STAR_CHAR
    call WriteChar
    jmp erase_enemy_next
erase_enemy_lava:
    mov eax, BG_RED_VAL
    add eax, COLOR_LAVA
    call SetTextColor
    mov al, LAVA_CHAR
    call WriteChar
    jmp erase_enemy_next
erase_enemy_next:
    inc esi
    jmp erase_enemy_loop
erase_enemy_done:
    popad
    ret
EraseEnemies ENDP

;-----------------------------------------------------------
; DrawEnemies
;-----------------------------------------------------------
DrawEnemies PROC
    pushad
    mov esi, 0
draw_enemy_loop:
    cmp esi, MAX_ENEMIES
    jge draw_enemy_done
    mov al, enemyType[esi]
    cmp al, 0
    je draw_enemy_next
    mov al, enemyState[esi]
    cmp al, STATE_DEAD
    je draw_enemy_next
    
    xor eax, eax
    mov al, enemyX[esi]
    xor ebx, ebx
    mov bl, enemyY[esi]
    cmp al, 0
    jl draw_enemy_next
    cmp al, SCREEN_WIDTH
    jge draw_enemy_next
    mov dl, al
    mov dh, bl
    call Gotoxy
    
    mov cl, enemyState[esi]
    cmp cl, STATE_NORMAL
    je draw_enemy_normal
    cmp cl, STATE_SHELL
    je draw_enemy_shell
    cmp cl, STATE_SHELL_MOVING
    je draw_enemy_shell
    jmp draw_enemy_next
draw_enemy_shell:
    mov eax, COLOR_KOOPA
    add eax, currentBgColor
    call SetTextColor
    mov al, 'O'
    call WriteChar
    jmp draw_enemy_next
draw_enemy_normal:
    mov cl, enemyType[esi]
    cmp cl, 1
    je draw_goomba
    cmp cl, 2
    je draw_koopa
    cmp cl, 3
    je draw_paragoomba
    cmp cl, 4
    je draw_boss
    jmp draw_enemy_next
draw_goomba:
    mov eax, COLOR_GOOMBA
    add eax, currentBgColor
    call SetTextColor
    mov al, 'g'
    call WriteChar
    jmp draw_enemy_next
draw_koopa:
    mov eax, COLOR_KOOPA
    add eax, currentBgColor
    call SetTextColor
    mov al, 't'
    call WriteChar
    jmp draw_enemy_next
draw_paragoomba:
    mov eax, COLOR_PARAGOOMBA
    add eax, currentBgColor
    call SetTextColor
    mov al, PARAGOOMBA_CHAR
    call WriteChar
    jmp draw_enemy_next
draw_boss:
    mov eax, COLOR_BOSS
    add eax, currentBgColor
    call SetTextColor
    mov al, BOSS_CHAR
    call WriteChar
    jmp draw_enemy_next
draw_enemy_next:
    inc esi
    jmp draw_enemy_loop
draw_enemy_done:
    popad
    ret
DrawEnemies ENDP

;-----------------------------------------------------------
; UpdateEnemies
;-----------------------------------------------------------
UpdateEnemies PROC
    pushad
    mov esi, 0
enemy_update_loop:
    cmp esi, MAX_ENEMIES
    jge enemy_update_done
    mov al, enemyType[esi]
    cmp al, 0
    je enemy_update_next
    mov al, enemyState[esi]
    cmp al, STATE_DEAD
    je enemy_update_next
    mov al, enemyX[esi]
    mov prevEnemyX[esi], al
    mov al, enemyY[esi]
    mov prevEnemyY[esi], al
    
    xor eax, eax
    mov al, enemyX[esi]
    xor ebx, ebx
    mov bl, enemyY[esi]
    
    mov cl, enemyType[esi]
    cmp cl, 3
    je enemy_fly_movement
    cmp cl, 4
    je enemy_boss_logic
    
    inc ebx
    push ebx
    push eax
    call CheckCollision
    cmp eax, 1
    je enemy_on_ground
    mov enemyOnGround[esi], 0
    mov al, enemyY[esi]
    inc al
    mov enemyY[esi], al
    jmp enemy_apply_movement
enemy_on_ground:
    mov enemyOnGround[esi], 1
    mov al, enemyState[esi]
    cmp al, STATE_SHELL
    je enemy_update_next
    
enemy_fly_movement:
    mov eax, enemyVelX[esi*4]
    xor ebx, ebx
    mov bl, enemyX[esi]
    xor ecx, ecx
    mov cl, enemyY[esi]
    mov edx, ebx 
    cmp eax, 0
    jg check_right
    jl check_left
    jmp enemy_apply_movement 
check_right:
    inc edx
    jmp check_collision_point
check_left:
    dec edx
check_collision_point:
    push ecx
    push edx
    call CheckCollision
    cmp eax, 1
    je enemy_hit_wall
    
    mov al, enemyType[esi]
    cmp al, 3
    je no_pit_check
    cmp al, 4
    je no_pit_check
    
    inc ecx
    push ecx
    push edx
    call CheckCollision
    cmp eax, 0
    je enemy_hit_wall 
    
no_pit_check:
    xor ebx, ebx
    mov bl, enemyX[esi]
    mov eax, enemyVelX[esi*4]
    add ebx, eax
    cmp ebx, 0
    jl enemy_hit_wall
    cmp ebx, SCREEN_WIDTH - 1
    jge enemy_hit_wall
    mov al, bl
    mov enemyX[esi], al
    jmp enemy_apply_movement
    
enemy_boss_logic:
    ; 1. Update Action Timer
    inc enemyActionTimer[esi]
    
    ; 2. Check Jump (Every 32 frames)
    xor eax, eax
    mov al, enemyActionTimer[esi]
    and al, 31 ; Modulo 32
    cmp al, 0
    jne boss_check_shoot
    ; Do Jump
    mov enemyVelY[esi*4], -2 
    
boss_check_shoot:
    ; 3. Check Shoot (Every 64 frames)
    xor eax, eax
    mov al, enemyActionTimer[esi]
    and al, 63 ; Modulo 64
    cmp al, 0
    jne boss_move_normal
    call BossShootProjectile
    
boss_move_normal:
    jmp enemy_fly_movement ; Reuse patrol logic

enemy_hit_wall:
    mov eax, enemyVelX[esi*4]
    neg eax
    mov enemyVelX[esi*4], eax
enemy_apply_movement:
enemy_update_next:
    inc esi
    jmp enemy_update_loop
enemy_update_done:
    popad
    ret
UpdateEnemies ENDP

;-----------------------------------------------------------
; ApplyGravity - Apply gravity to Mario
;-----------------------------------------------------------
ApplyGravity PROC
    pushad
    xor eax, eax
    mov al, marioX
    xor ebx, ebx
    mov bl, marioY
    inc ebx
    push ebx
    push eax
    call CheckCollision
    cmp eax, 1
    je on_solid_ground
    mov onGround, 0
    mov eax, marioVelY
    cmp eax, 0
    jl keep_velocity
    inc eax
    cmp eax, 3
    jle keep_velocity
    mov eax, 3
keep_velocity:
    mov marioVelY, eax
    cmp eax, 0
    jle gravity_done
    mov ecx, eax
    cmp ecx, 3
    jle fall_loop
    mov ecx, 3
fall_loop:
    push ecx
    xor eax, eax
    mov al, marioX
    xor ebx, ebx
    mov bl, marioY
    inc ebx
    push ebx
    push eax
    call CheckCollision
    pop ecx
    cmp eax, 1
    je landed_on_ground
    inc marioY
    loop fall_loop
    jmp gravity_done
landed_on_ground:
    mov marioVelY, 0
    ; marioVelX is NOT cleared here for momentum
    mov onGround, 1
    mov jumpCounter, 0
    mov doubleJumpUsed, 0
    jmp gravity_done
on_solid_ground:
    mov onGround, 1
    ; marioVelX is NOT cleared here for momentum
    mov jumpCounter, 0
    mov eax, marioVelY
    cmp eax, 0
    jle gravity_done
    mov marioVelY, 0
    mov doubleJumpUsed, 0
gravity_done:
    mov al, marioY
    cmp al, SCREEN_HEIGHT - 1
    jl no_reset
    call LoseLife
no_reset:
    popad
    ret
ApplyGravity ENDP

;-----------------------------------------------------------
; LoseLife
;-----------------------------------------------------------
LoseLife PROC
    pushad
    mov al, gameOver
    cmp al, 1
    je lose_life_done
    
    INVOKE Beep, 150, 200

    dec livesCount
    mov marioState, 0
    call DrawUI
    mov eax, livesCount
    cmp eax, 0
    jg reset_mario_pos
    mov gameOver, 1
    
    ; Save High Score on Game Over
    mov eax, scoreCount
    cmp eax, highScore
    jle save_skip_lose
    mov highScore, eax
     call SavePlayerData 
save_skip_lose:
    jmp lose_life_done
    
reset_mario_pos:
    call ResetLevel 
    call InitializeLevel
    call InitializeEnemies
    mov needsFullRedraw, 1
lose_life_done:
    popad
    ret
LoseLife ENDP

;-----------------------------------------------------------
; CheckWin
;-----------------------------------------------------------
CheckWin PROC
    pushad
    mov al, marioX
    cmp al, 113  
    jl not_won
    cmp al, 117  
    jg not_won
    mov al, marioY
    cmp al, 8
    jg not_won
    mov gameWon, 1
not_won:
    popad
    ret
CheckWin ENDP

;-----------------------------------------------------------
; CheckCoinCollision
;-----------------------------------------------------------
CheckCoinCollision PROC
    pushad
    xor eax, eax
    mov al, marioY
    imul eax, SCREEN_WIDTH
    xor ebx, ebx
    mov bl, marioX
    add eax, ebx
    mov edi, OFFSET levelMap
    add edi, eax
    cmp BYTE PTR [edi], 4
    jne ccc_done
    
    INVOKE Beep, 1000, 50

    mov BYTE PTR [edi], 0
    add scoreCount, 10
    call DrawUI
ccc_done:
    popad
    ret
CheckCoinCollision ENDP

;-----------------------------------------------------------
; CheckPowerUpCollision
;-----------------------------------------------------------
CheckPowerUpCollision PROC
    pushad
    xor eax, eax
    mov al, marioY
    imul eax, SCREEN_WIDTH
    xor ebx, ebx
    mov bl, marioX
    add eax, ebx
    mov edi, OFFSET levelMap
    add edi, eax
    cmp BYTE PTR [edi], 7
    jne cpu_done
    
    mov BYTE PTR [edi], 0
    add scoreCount, 1000
    
    mov marioState, 2
    call DrawUI
    
cpu_done:
    popad
    ret
CheckPowerUpCollision ENDP

;-----------------------------------------------------------
; CheckSpikeCollision
;-----------------------------------------------------------
CheckSpikeCollision PROC
    pushad
    xor eax, eax
    mov al, marioY
    imul eax, SCREEN_WIDTH
    xor ebx, ebx
    mov bl, marioX
    add eax, ebx
    mov edi, OFFSET levelMap
    add edi, eax
    cmp BYTE PTR [edi], 5
    jne csc_done
    call LoseLife
csc_done:
    popad
    ret
CheckSpikeCollision ENDP

;-----------------------------------------------------------
; CheckProjectileCollisions
;-----------------------------------------------------------
CheckProjectileCollisions PROC
    pushad
    mov edi, 0 
cpc_loop:
    cmp edi, MAX_ENEMIES
    jge cpc_done
    mov al, enemyType[edi]
    cmp al, 0
    je cpc_next
    mov al, enemyState[edi]
    cmp al, STATE_DEAD
    je cpc_next
    
    mov al, projectileX[esi]
    mov bl, enemyX[edi]
    cmp al, bl
    jne cpc_next
    
    mov al, projectileY[esi]
    mov bl, enemyY[edi]
    cmp al, bl
    jne cpc_next
    
    mov al, projectileX[esi]
    mov bl, enemyX[edi]
    sub al, bl
    movsx eax, al
    cmp eax, 0
    je cpc_hit
    cmp eax, 1
    je cpc_hit
    cmp eax, -1
    je cpc_hit
    
    jmp cpc_next
    
cpc_hit:
    INVOKE Beep, 200, 50
    
    ; Check if Boss (Type 4)
    mov al, enemyType[edi]
    cmp al, 4
    je cpc_hit_boss
    
    mov enemyState[edi], STATE_DEAD
    add scoreCount, 100
    jmp cpc_cleanup
    
cpc_hit_boss:
    dec enemyHealth[edi]
    cmp enemyHealth[edi], 0
    jg cpc_cleanup ; Boss still alive
    mov enemyState[edi], STATE_DEAD
    add scoreCount, 5000 ; Big points for Boss
    mov isBossActive, 0; Boss defeated
    
cpc_cleanup:
    call DrawUI
    mov projectileActive[esi], 0
    jmp cpc_done 
    
cpc_next:
    inc edi
    jmp cpc_loop
cpc_done:
    popad
    ret
CheckProjectileCollisions ENDP

;-----------------------------------------------------------
; CheckEnemyCollisions
;-----------------------------------------------------------
CheckEnemyCollisions PROC
    pushad
    mov esi, 0
cec_loop:
    cmp esi, MAX_ENEMIES
    jge cec_done
    mov al, enemyType[esi]
    cmp al, 0
    je cec_next
    mov al, enemyState[esi]
    cmp al, STATE_DEAD
    je cec_next
    
    mov al, marioX
    mov bl, enemyX[esi]
    cmp al, bl
    jne cec_next
    mov al, marioY
    mov bl, enemyY[esi]
    cmp al, bl
    jne cec_next
    
    mov eax, marioVelY
    cmp eax, 0
    jle cec_mario_hurt
    mov marioVelY, -1
    mov doubleJumpUsed, 0
    mov al, enemyState[esi]
    cmp al, STATE_NORMAL
    je cec_stomp_normal
    cmp al, STATE_SHELL
    je cec_stomp_shell
    cmp al, STATE_SHELL_MOVING
    je cec_stomp_shell
    jmp cec_next
cec_stomp_normal:
    mov al, enemyType[esi]
    cmp al, 1
    je cec_stomp_goomba
    cmp al, 2
    je cec_stomp_koopa
    cmp al, 3
    je cec_stomp_paragoomba
    cmp al, 4
    je cec_stomp_boss
    jmp cec_next
cec_stomp_goomba:
    INVOKE Beep, 200, 50
    mov enemyState[esi], STATE_DEAD
    add scoreCount, 100
    call DrawUI
    jmp cec_next
cec_stomp_koopa:
    INVOKE Beep, 200, 50
    mov enemyState[esi], STATE_SHELL
    mov enemyVelX[esi*4], 0
    add scoreCount, 100
    call DrawUI
    jmp cec_next
cec_stomp_paragoomba:
    INVOKE Beep, 200, 50
    mov enemyType[esi], 1 
    jmp cec_next
cec_stomp_boss:
    ; Boss takes damage from stomp too? Sure.
    INVOKE Beep, 100, 100
    dec enemyHealth[esi]
    cmp enemyHealth[esi], 0
    jg cec_next ; Boss lives
    mov enemyState[esi], STATE_DEAD
    add scoreCount, 5000
    call DrawUI
    jmp cec_next
cec_stomp_shell:
    mov enemyState[esi], STATE_SHELL
    mov enemyVelX[esi*4], 0
    jmp cec_next
cec_mario_hurt:
    mov al, enemyState[esi]
    cmp al, STATE_SHELL_MOVING
    je cec_lose_life
    cmp al, STATE_NORMAL
    je cec_lose_life
    cmp al, STATE_SHELL
    je cec_kick_shell
    jmp cec_next
cec_kick_shell:
    mov enemyState[esi], STATE_SHELL_MOVING
    mov al, marioX
    mov bl, enemyX[esi]
    cmp al, bl
    jge kick_left
kick_right:
    mov enemyVelX[esi*4], 2
    jmp cec_next
kick_left:
    mov enemyVelX[esi*4], -2
    jmp cec_next
cec_lose_life:
    call LoseLife
    jmp cec_done
cec_next:
    inc esi
    jmp cec_loop
cec_done:
    popad
    ret
CheckEnemyCollisions ENDP

;-----------------------------------------------------------
; GameLoop
;-----------------------------------------------------------
GameLoop PROC
    pushad
game_start:
    mov al, gameWon
    cmp al, 1
    je level_complete_trigger
    
    mov al, gameOver
    cmp al, 0
    jne game_over_screen
    
    mov al, gameRunning
    cmp al, 0
    je game_exit_to_menu
    
    mov al, marioX
    mov prevMarioX, al
    mov al, marioY
    mov prevMarioY, al
    
    call UpdateEnemies
    call UpdateFirePits
    call UpdateBossProjectiles
    call UpdateProjectile
    call ApplyGravity
    call UpdateTimer
    
    call CheckSpikeCollision
    call CheckCoinCollision
    call CheckPowerUpCollision
    call CheckEnemyCollisions
    
    call ReadKey
    jz no_input
    
    cmp al, 'p'
    je pause_game
    cmp al, 'P'
    je pause_game
    
    cmp al, 'x'
    je game_exit_to_menu
    cmp al, 'X'
    je game_exit_to_menu
    
    cmp al, 'd'
    je move_right
    cmp al, 'D'
    jne check_left
move_right:
    xor eax, eax
    mov al, marioX
    inc al
    xor ebx, ebx
    mov bl, marioY
    push ebx
    push eax
    call CheckCollision
    cmp eax, 0
    jne check_left
    inc marioX
    mov al, onGround
    cmp al, 0
    jne check_left
    mov marioVelX, 1
    jmp check_left
check_left:
    cmp al, 'a'
    je do_move_left
    cmp al, 'A'
    je do_move_left
    jmp check_jump

do_move_left:
    xor eax, eax
    mov al, marioX
    dec al
    xor ebx, ebx
    mov bl, marioY
    push ebx
    push eax
    call CheckCollision
    cmp eax, 0
    jne check_jump
    dec marioX
    mov al, onGround
    cmp al, 0
    jne check_jump
    mov marioVelX, -1
    jmp check_jump

check_jump:
    cmp al, 'w'
    je do_jump
    cmp al, 'W'
    je do_jump
    cmp al, ' '
    je do_jump
    cmp al, 'f'
    je do_shoot
    cmp al, 'F'
    jne no_input
do_shoot:
    call ShootProjectile
    jmp no_input
do_jump:
    mov al, onGround
    cmp al, 1
    je do_first_jump
    mov al, doubleJumpUsed
    cmp al, 0
    je do_double_jump
    jmp no_input
do_first_jump:
    INVOKE Beep, 600, 30
    mov marioVelY, -2
    mov onGround, 0
    mov jumpCounter, 0
    jmp no_input
do_double_jump:
    INVOKE Beep, 800, 30
    mov marioVelY, -2
    mov jumpCounter, 0
    mov doubleJumpUsed, 1
    jmp no_input
no_input:
    mov eax, marioVelX
    cmp eax, 0
    je skip_horizontal_movement
    
    xor ebx, ebx
    mov bl, marioX
    add ebx, eax
    
    cmp ebx, 0
    jl reset_horizontal_vel
    cmp ebx, SCREEN_WIDTH - 1
    jge reset_horizontal_vel
    
    xor ecx, ecx
    mov cl, marioY
    push ecx
    push ebx
    call CheckCollision
    cmp eax, 1
    je reset_horizontal_vel
    mov marioX, bl
    
    ; CHECK GROUND FRICTION
    mov al, onGround
    cmp al, 1
    je reset_horizontal_vel ; If on ground, stop (step movement)
    
    jmp skip_horizontal_movement

reset_horizontal_vel:
    mov marioVelX, 0
skip_horizontal_movement:
    mov eax, marioVelY
    cmp eax, 0
    jge skip_jump_movement
    xor eax, eax
    mov al, jumpCounter
    xor ebx, ebx
    mov bl, maxJumpHeight
    cmp al, bl
    jge stop_jumping_up
    xor eax, eax
    mov al, marioX
    xor ebx, ebx
    mov bl, marioY
    dec ebx
    push ebx
    push eax
    call CheckCollision
    cmp eax, 1
    je hit_ceiling
    dec marioY
    inc jumpCounter
    jmp skip_jump_movement
stop_jumping_up:
    mov marioVelY, 0
    jmp skip_jump_movement
hit_ceiling:
    mov marioVelY, 1
skip_jump_movement:
    call CheckWin
    mov al, needsFullRedraw
    cmp al, 0
    je partial_redraw
    call Clrscr
    call DrawFullScreen
    mov needsFullRedraw, 0
    jmp render_done
partial_redraw:
    call EraseMario
    call EraseProjectile
    call EraseBossProjectiles
    call EraseFireballs
    call EraseEnemies
    call DrawMario
    call DrawProjectile
    call DrawFireballs
    call DrawBossProjectiles
    call DrawEnemies
render_done:
    mov eax, 50
    call Delay
    jmp game_start

pause_game:
    call Clrscr
    mov dh, 12
    mov dl, 20
    call Gotoxy
    mov eax, COLOR_FLAG
    add eax, currentBgColor
    call SetTextColor
    mov edx, OFFSET pauseMsg
    call WriteString
    
pause_loop:
    call ReadKey
    jz pause_loop
    
    cmp al, 'r'
    je resume_game
    cmp al, 'R'
    je resume_game
    
    cmp al, 'm'
    je game_exit_to_menu
    cmp al, 'M'
    je game_exit_to_menu
    
    jmp pause_loop

resume_game:
    call GetMseconds
    mov lastTick, eax
    mov needsFullRedraw, 1
    jmp game_start

level_complete_trigger:
    ; Calculate Time Bonus
    mov eax, timerCount
    add scoreCount, eax
    
    call Clrscr
    mov dh, 10
    mov dl, 40
    call Gotoxy
    mov eax, COLOR_FLAG
    add eax, BG_BLUE_VAL
    call SetTextColor
    mov edx, OFFSET winMsg
    call WriteString
    
    mov dh, 12
    mov dl, 40
    call Gotoxy
    mov edx, OFFSET timeBonusMsg
    call WriteString
    mov eax, timerCount
    call WriteDec
    
    mov dh, 13
    mov dl, 40
    call Gotoxy
    mov edx, OFFSET totalScoreMsg
    call WriteString
    mov eax, scoreCount
    call WriteDec
    
    mov dh, 15
    mov dl, 40
    call Gotoxy
    mov edx, OFFSET nextLevelMsg
    call WriteString
    
    call ReadChar 
    mov levelResult, 1
    popad
    ret

game_over_screen:
    call Clrscr
    
    ; 1. Draw the Skull (White on Black)
    mov eax, 15 + (0 * 16)   ; Bright White text on Black
    call SetTextColor

    mov dh, 6                ; Start Row
    
    ; Print Line 1
    mov dl, 25               ; Center X (Adjust if needed)
    mov dh, 6;
    call Gotoxy
    mov edx, OFFSET gameOver1
    call WriteString
    
    
    ; Print Line 2
    mov dl, 25
    mov dh, 7;
    call Gotoxy
    mov edx, OFFSET gameOver2
    call WriteString

    
    ; Print Line 3
    mov dl, 25
    mov dh, 8;
    call Gotoxy
    mov edx, OFFSET gameOver3
    call WriteString

    
    ; Print Line 4
    mov dl, 25
    mov dh, 9;
    call Gotoxy
    mov edx, OFFSET gameOver4
    call WriteString
    inc dh
    
    ; Print Line 5
    mov dl, 25
    mov dh, 10;
    call Gotoxy
    mov edx, OFFSET gameOver5
    call WriteString
    inc dh

    ; Print Line 6
    mov dl, 25
    mov dh, 11;
    call Gotoxy
    mov edx, OFFSET gameOver6
    call WriteString

    ; Print Line 7
    mov dl, 25
    mov dh, 12;
    call Gotoxy
    mov edx, OFFSET gameOver7
    call WriteString
    inc dh



    
    mov eax, 12 + (0 * 16)   ; Light Red
    call SetTextColor
    
    mov dh, 14
    mov dl, 50
    call Gotoxy
    mov edx, OFFSET skullMsg ; "GAME OVER"
    call WriteString
    
    mov dh, 16
    mov dl, 50
    call Gotoxy
    mov edx, OFFSET skullMsg2 ; "YOU DIED"
    call WriteString

    ; 4. Wait for user input
    call ReadChar
    
    ; Restore standard colors and return
    mov eax, 15              ; White
    call SetTextColor
    call Clrscr
    ret

game_exit_to_menu:
    mov gameRunning, 0
    mov levelResult, 0 
    popad
    ret
GameLoop ENDP

END main