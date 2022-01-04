Include Irvine32.inc
main	EQU start@0

cubeSize = 1
lineSize = 10
borderX = 119    
borderY = 30

.data
;==============================================================================;
;                                  For Menu /Start                             ;
;==============================================================================;
titleMSG BYTE "Rapid Roll", 0       
gameMSG0 BYTE "*****       *      ******   *****  *****      *****     *****   *     *    ", 0
gameMSG1 BYTE "*    *     *  *    *     *    *    *    *     *    *   *     *  *     *    ", 0
gameMSG2 BYTE "*****     ******   *****      *    *    *     *****   *       * *     *    ", 0
gameMSG3 BYTE "*    *   *      *  *          *    *    *     *    *   *     *  *     *    ", 0
gameMSG4 BYTE "*     * *        * *        *****  *****      *     *   *****   ***** *****", 0
gameMSGPosition COORD <20, 5>

instructionMSG BYTE "Press A & D to move", 0
instructionMSGPosition COORD <20, 15>

startMSG BYTE "Press any key to start", 0
startMSGPosition COORD <20, 20>
startMSGAttribute WORD LENGTHOF startMSG DUP(1001b)

exitMSG BYTE "Press ESC to exit", 0
exitMSGPosition COORD <20, 22>
exitMSGAttribute WORD LENGTHOF exitMSG DUP(1100b)

;"GAME OVER"
gameOverMSG0 BYTE "  ****       *     *       * ******       *****   *       * ****** *****  ", 0
gameOverMSG1 BYTE " *          * *    **     ** *           *     *   *     *  *      *    * ", 0
gameOverMSG2 BYTE "*   ****   *****   * *   * * ******     *       *   *   *   ****** *****  ", 0
gameOverMSG3 BYTE " *    **  *     *  *  * *  * *           *     *     * *    *      *    * ", 0
gameOverMSG4 BYTE "  **** * *       * *   *   * ******       *****       *     ****** *     *", 0
gameOverMSGPosition COORD <20, 5>
gameOverMSGAttribute WORD LENGTHOF gameOverMSG0 DUP(0100b)

returnMSG BYTE "Press any key to go back to the menu", 0
returnMSGPosition COORD <20, 20>
returnMSGAttribute WORD LENGTHOF returnMSG DUP(1001b)

scoreMSG BYTE "Score: ", 0
scoreMSGPosition COORD <20, 15>
scorePosition COORD <27 ,15>

outputHandle DWORD 0
bytesWritten DWORD 0
;==============================================================================;
;                                  For Menu /End                               ;
;==============================================================================;

;==============================================================================;
;                               For Game Loop / Start                          ;
;==============================================================================;
; Cube
cubeCurrentPosition COORD <50, 5>
cubePreviousPosition COORD <?, 5>
cubeBody BYTE ' '
; Line
line1 COORD <50, 15>
line1Previous COORD <>
line2 COORD <40,10>
line2Previous COORD <>
line3 COORD <60,20>
line3Previous COORD <>
line4 COORD <70,30>
line4Previous COORD <>
line5 COORD <75,40>
line5Previous COORD <>
lineBody BYTE lineSize DUP('_')
removeLineBody BYTE lineSize DUP(' ')
lineLength DWORD lineSize
;Random Number
randomNum DWORD ?
; Score
score DWORD 0
startTime DWORD ?
; Game Tik
TICK DWORD 0
; Border
border COORD <100, 30>
isOut DWORD 0
; Ground
isOnTheGround DWORD 0
whichLine DWORD ?
;Draw
cellsWritten BYTE ?
;==============================================================================;
;                               For Game Loop /End                             ;
;==============================================================================;

.code

;======================================================;
;                Initialize the variables              ;
;======================================================;
initialize PROC USES eax
    mov ax, 50
    mov cubeCurrentPosition.X, ax
    mov line1.X, ax
    mov ax, 5
    mov cubeCurrentPosition.Y, ax
    mov cubePreviousPosition.Y, ax
    mov ax, 15
    mov line1.Y, ax
    mov ax, 40
    mov line2.X, ax
    mov ax, 10
    mov line2.Y, ax
    mov ax, 60
    mov line3.X, ax
    mov ax, 20
    mov line3.Y, ax
    mov ax, 70
    mov line4.X, ax
    mov ax, 30
    mov line4.Y, ax
    mov ax, 75
    mov line5.X, ax
    mov ax, 40
    mov line5.Y, ax 

    xor eax, eax
    mov score, eax
    mov isOut, eax
    mov TICK, eax
    mov isOnTheGround, eax
    ret
initialize ENDP

;===================================================;
;                     Move Cube                     ;
;===================================================;
; Left
cubeMoveLeft PROC USES ax bx
    .IF cubeCurrentPosition.X > 1
        mov ax, cubeCurrentPosition.X
        mov bx, cubeCurrentPosition.Y
        mov cubePreviousPosition.X, ax
        mov cubePreviousPosition.Y, bx
        sub cubeCurrentPosition.X, 1
    .ENDIF
    ret
cubeMoveLeft ENDP

; Right
cubeMoveRight PROC USES ax bx
    .IF cubeCurrentPosition.X < borderX
        mov ax, cubeCurrentPosition.X
        mov bx, cubeCurrentPosition.Y
        mov cubePreviousPosition.X, ax
        mov cubePreviousPosition.Y, bx
        add cubeCurrentPosition.X, 1
    .ENDIF
    ret
cubeMoveRight ENDP

; Up or Down
cubeMoveUp PROC USES ax bx

    mov ax, cubeCurrentPosition.X
    mov bx, cubeCurrentPosition.Y
    mov cubePreviousPosition.X, ax
    mov cubePreviousPosition.Y, bx
    .IF isOnTheGround == 1
        .IF whichLine == 1
            mov ax, line1.Y
            mov cubeCurrentPosition.Y, ax
        .ELSEIF whichLine == 2
            mov ax, line2.Y
            mov cubeCurrentPosition.Y, ax
        .ELSEIF whichLine == 3
            mov ax, line3.Y
            mov cubeCurrentPosition.Y, ax
        .ELSEIF whichLine == 4
            mov ax, line4.Y
            mov cubeCurrentPosition.Y, ax
        .ELSEIF whichLine == 5
            mov ax, line5.Y
            mov cubeCurrentPosition.Y, ax
        .ENDIF
    .ELSE
        sub cubeCurrentPosition.Y, 1 
    .ENDIF
    
    ret
cubeMoveUp ENDP

cubeMoveDown PROC USES ax bx
    
    mov ax, cubeCurrentPosition.X
    mov bx, cubeCurrentPosition.Y
    mov cubePreviousPosition.X, ax
    mov cubePreviousPosition.Y, bx
    add cubeCurrentPosition.Y, 1
    
    ret
cubeMoveDown ENDP

;===================================================;
;                 Get Random Number                 ;
;===================================================;

getRandomNumber PROC USES eax ebx
    call Randomize
    mov eax, 1000000
    call RandomRange
    mov randomNum, eax
    ret
getRandomNumber ENDP


;===================================================;
;                     Move Line                     ;
;===================================================;

lineMoveUp PROC USES eax ebx ecx edx
    ; move line 1
    mov ax, line1.X
    mov bx, line1.Y
    mov line1Previous.X, ax
    mov line1Previous.Y, bx
    .IF line1.Y > 0
        dec line1.Y
    .ELSE
        invoke getRandomNumber
        xor edx, edx
        mov eax, randomNum
        mov ax, ax
        mov bx, 60
        div bx
        shl dx, 1
        mov line1.X, dx
        mov line1.Y, 30
    .ENDIF
    ; move line 2
    mov ax, line2.X
    mov bx, line2.Y
    mov line2Previous.X, ax
    mov line2Previous.Y, bx
    .IF line2.Y > 0
        dec line2.Y
    .ELSE
        invoke getRandomNumber
        xor edx, edx
        mov eax, randomNum
        mov ax, ax
        mov bx, 60
        div bx
        shl dx, 1
        mov line2.X, dx
        mov line2.Y, 30
    .ENDIF
    ; move line 3
    mov ax, line3.X
    mov bx, line3.Y
    mov line3Previous.X, ax
    mov line3Previous.Y, bx
    .IF line3.Y > 0
        dec line3.Y
    .ELSE
        invoke getRandomNumber
        xor edx, edx
        mov eax, randomNum
        mov ax, ax
        mov bx, 60
        div bx
        shl dx, 1
        mov line3.X, dx
        mov line3.Y, 30
    .ENDIF
    ; move line 4
    mov ax, line4.X
    mov bx, line4.Y
    mov line4Previous.X, ax
    mov line4Previous.Y, bx
    .IF line4.Y > 0
        dec line4.Y
    .ELSE
        invoke getRandomNumber
        xor edx, edx
        mov eax, randomNum
        mov ax, ax
        mov bx, 60
        div bx
        shl dx, 1
        mov line4.X, dx
        mov line4.Y, 30
    .ENDIF
    ; mov line 5
    mov ax, line5.X
    mov bx, line5.Y
    mov line5Previous.X, ax
    mov line5Previous.Y, bx
    .IF line5.Y > 0
        dec line5.Y
    .ELSE
        invoke getRandomNumber
        xor edx, edx
        mov eax, randomNum
        mov ax, ax
        mov bx, 60
        div bx
        shl dx, 1
        mov line5.X, dx
        mov line5.Y, 30
    .ENDIF
    ret
lineMoveUp ENDP

;===================================================;
;                     Draw Cube                     ;
;===================================================;

drawCube PROC USES eax
    ; Wipe up previous cube
    invoke SetConsoleCursorPosition, outputHandle, cubePreviousPosition ; Set cursor position to where text should be written
    mov eax, 15 + 0*16
    call SetTextColor   ; Set cube's color
    push eax
    mov al, cubeBody    ; Print the cube
    call WriteChar
    ; Draw new cube
    invoke SetConsoleCursorPosition, outputHandle, cubeCurrentPosition
    mov eax, 0 + 11*16
    call SetTextColor
    mov al, cubeBody
    call WriteChar
    ; Restore to default setting
    pop eax
    call SetTextColor
    ret
drawCube ENDP

;===================================================;
;                     Draw Line                     ;
;===================================================;

drawLine PROC
    invoke WriteConsoleOutputCharacter,
      outputHandle, 
      ADDR removeLineBody,
      lineLength,
      line1Previous,
      ADDR cellsWritten
 
    invoke WriteConsoleOutputCharacter,
      outputHandle, 
      ADDR removeLineBody,
      lineLength,
      line2Previous,
      ADDR cellsWritten
 
    invoke WriteConsoleOutputCharacter,
      outputHandle, 
      ADDR removeLineBody,
      lineLength,
      line3Previous,
      ADDR cellsWritten
    
    invoke WriteConsoleOutputCharacter,
      outputHandle, 
      ADDR removeLineBody,
      lineLength,
      line4Previous,
      ADDR cellsWritten

    invoke WriteConsoleOutputCharacter,
      outputHandle, 
      ADDR removeLineBody,
      lineLength,
      line5Previous,
      ADDR cellsWritten

    invoke WriteConsoleOutputCharacter, 
      outputHandle, 
      ADDR lineBody,
      lineLength,
      line1,
      ADDR cellsWritten

    invoke WriteConsoleOutputCharacter, 
      outputHandle, 
      ADDR lineBody,
      lineLength,
      line2,
      ADDR cellsWritten

    invoke WriteConsoleOutputCharacter, 
      outputHandle, 
      ADDR lineBody,
      lineLength,
      line3,
      ADDR cellsWritten

    invoke WriteConsoleOutputCharacter, 
      outputHandle, 
      ADDR lineBody,
      lineLength,
      line4,
      ADDR cellsWritten

    invoke WriteConsoleOutputCharacter, 
      outputHandle, 
      ADDR lineBody,
      lineLength,
      line5,
      ADDR cellsWritten
    ret
drawLine ENDP

;===================================================;
;          Check if object is out of border         ;
;===================================================;
isOutOfBorder PROC
    .IF cubeCurrentPosition.X >= borderX  
        mov isOut, 1
    .ELSEIF cubeCurrentPosition.X <= 1
        mov isOut, 1
    .ELSEIF cubeCurrentPosition.Y > borderY  
        mov isOut, 1
    .ELSEIF cubeCurrentPosition.Y < 1
        mov isOut, 1
    .ELSE
        mov isOut, 0
    .ENDIF
    ret
isOutOfBorder ENDP

;===================================================;
;            Check if object is grounded            ;
;===================================================;
isGrounded PROC USES eax ebx ecx edx
    ;TODO:Complete isGrounded procedure
    ; Check line 1
    mov ax, line1.X
    mov bx, ax
    mov cx, line1.Y
    mov dx, cx
    add ax, lineSize
    sub dx, 1
    .IF cubeCurrentPosition.X >= bx && cubeCurrentPosition.X <= ax && cubeCurrentPosition.Y >= dx  && cubeCurrentPosition.Y <= cx
        mov isOnTheGround, 1
        mov whichLine, 1
        jmp leave_proc
    .ENDIF
    ; Check Line 2
    mov ax, line2.X
    mov bx, ax
    mov cx, line2.Y
    mov dx, cx
    add ax, lineSize
    sub dx, 1
    .IF cubeCurrentPosition.X >= bx && cubeCurrentPosition.X <= ax && cubeCurrentPosition.Y >= dx  && cubeCurrentPosition.Y <= cx
        mov isOnTheGround, 1
        mov whichLine, 2
        jmp leave_proc
    .ENDIF
    ; Check Line 3
    mov ax, line3.X
    mov bx, ax
    mov cx, line3.Y
    mov dx, cx
    add ax, lineSize
    sub dx, 1
    .IF cubeCurrentPosition.X >= bx && cubeCurrentPosition.X <= ax && cubeCurrentPosition.Y >= dx  && cubeCurrentPosition.Y <= cx
        mov isOnTheGround, 1
        mov whichLine, 3
        jmp leave_proc
    .ENDIF
    ; Check Line 4
    mov ax, line4.X
    mov bx, ax
    mov cx, line4.Y
    mov dx, cx
    add ax, lineSize
    sub dx, 1
    .IF cubeCurrentPosition.X >= bx && cubeCurrentPosition.X <= ax && cubeCurrentPosition.Y >= dx  && cubeCurrentPosition.Y <= cx
        mov isOnTheGround, 1
        mov whichLine, 4
        jmp leave_proc
    .ENDIF
    ; Check Line 5
    mov ax, line5.X
    mov bx, ax
    mov cx, line5.Y
    mov dx, cx
    add ax, lineSize
    sub dx, 1
    .IF cubeCurrentPosition.X >= bx && cubeCurrentPosition.X <= ax && cubeCurrentPosition.Y >= dx  && cubeCurrentPosition.Y <= cx
        mov isOnTheGround, 1
        mov whichLine, 5
        jmp leave_proc
    .ENDIF
    mov isOnTheGround, 0
leave_proc:
    ret
isGrounded ENDP





;===================================================;
;                       Score                       ;
;===================================================;
get_score PROC USES eax
    call GetMseconds
    sub eax, startTime
    mov score, eax
    ret
get_score ENDP

;===================================================;
;                      GameLoop                     ;
;===================================================;
GameLoop PROC USES eax ebx ecx edx
    call Clrscr
    .WHILE TRUE
        invoke isGrounded
        call ReadKey
        .IF ax == 1E61h
            ;TODO: move cube left
            invoke cubeMoveLeft
            invoke isGrounded
        .ELSEIF ax == 2064h
            ;TODO: move cube right
            invoke cubeMoveRight
            invoke isGrounded
        .ENDIF
        ; Move Line & Cube Up
        xor edx, edx
        mov eax, TICK
        mov ebx, 375
        div ebx
        .IF edx == 0
            .IF isOnTheGround == 1
                invoke lineMoveUp
                invoke cubeMoveUp
            .ELSEIF isOnTheGround == 0
                 invoke lineMoveUp
                 invoke cubeMoveDown
            .ENDIF
            mov TICK, 0
        .ENDIF
        invoke drawLine
        invoke drawCube
        invoke isOutOfBorder
        .IF isOut == 1
            jmp leave_proc
        .ENDIF
        inc TICK
    .ENDW
    leave_proc:
    ret
GameLoop ENDP



;===================================================;
;                        Main                       ;
;===================================================;
main PROC
newGame:
    INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    mov outputHandle, eax
    CALL Clrscr

    INVOKE SetConsoleTitle, ADDR titleMSG

    INVOKE WriteConsoleOutputCharacter,
        outputHandle,
        ADDR gameMSG0,
        LENGTHOF gameMSG0,
        gameMSGPosition,
        ADDR bytesWritten
    
    inc gameMSGPosition.Y
    INVOKE WriteConsoleOutputCharacter,
        outputHandle,
        ADDR gameMSG1,
        LENGTHOF gameMSG1,
        gameMSGPosition,
        ADDR bytesWritten
    
    inc gameMSGPosition.Y
    INVOKE WriteConsoleOutputCharacter,
        outputHandle,
        ADDR gameMSG2,
        LENGTHOF gameMSG2,
        gameMSGPosition,
        ADDR bytesWritten
    
    inc gameMSGPosition.Y
    INVOKE WriteConsoleOutputCharacter,
        outputHandle,
        ADDR gameMSG3,
        LENGTHOF gameMSG3,
        gameMSGPosition,
        ADDR bytesWritten
    
    inc gameMSGPosition.Y
    INVOKE WriteConsoleOutputCharacter,
        outputHandle,
        ADDR gameMSG4,
        LENGTHOF gameMSG4,
        gameMSGPosition,
        ADDR bytesWritten
    sub gameMSGPosition.Y, 4

    INVOKE  WriteConsoleOutputCharacter,
        outputHandle,
        ADDR instructionMSG,
        LENGTHOF instructionMSG,
        instructionMSGPosition,
        ADDR bytesWritten

    INVOKE WriteConsoleOutputAttribute,
        outputHandle,
        ADDR startMSGAttribute,
        LENGTHOF startMSG,
        startMSGPosition,
        ADDR bytesWritten

    INVOKE WriteConsoleOutputCharacter,
        outputHandle,
        ADDR startMSG,
        LENGTHOF startMSG,
        startMSGPosition,
        ADDR bytesWritten

    INVOKE WriteConsoleOutputAttribute,
        outputHandle,
        ADDR exitMSGAttribute,
        LENGTHOF exitMSG,
        exitMSGPosition,
        ADDR bytesWritten

    INVOKE WriteConsoleOutputCharacter,
        outputHandle,
        ADDR exitMSG,
        LENGTHOF exitMSG,
        exitMSGPosition,
        ADDR bytesWritten

    xor ax, ax
waitForInput:
    CALL ReadChar
    CMP ax, 0       ;There is no key pressed
    JE waitForInput
    CMP ax, 011Bh   ;The user presses ESC
    JE exitGame

start:
;==============================================;
;             start the game loop              ;
;==============================================;
    push eax
    call GetMseconds ; get time to count score
    mov startTime, eax
    pop eax

    invoke GameLoop

gameOver:
    CALL Clrscr

    INVOKE WriteConsoleOutputAttribute,
        outputHandle,
        ADDR gameOverMSGAttribute,
        LENGTHOF gameOverMSG0,
        gameOverMSGPosition,
        ADDR bytesWritten

    INVOKE WriteConsoleOutputCharacter,
        outputHandle,
        ADDR gameOverMSG0,
        LENGTHOF gameOverMSG0,
        gameOverMSGPosition,
        ADDR bytesWritten
    
    inc gameOverMSGPosition.Y
    INVOKE WriteConsoleOutputAttribute,
        outputHandle,
        ADDR gameOverMSGAttribute,
        LENGTHOF gameOverMSG1,
        gameOverMSGPosition,
        ADDR bytesWritten

    INVOKE WriteConsoleOutputCharacter,
        outputHandle,
        ADDR gameOverMSG1,
        LENGTHOF gameOverMSG1,
        gameOverMSGPosition,
        ADDR bytesWritten

    inc gameOverMSGPosition.Y
    INVOKE WriteConsoleOutputAttribute,
        outputHandle,
        ADDR gameOverMSGAttribute,
        LENGTHOF gameOverMSG2,
        gameOverMSGPosition,
        ADDR bytesWritten

    INVOKE WriteConsoleOutputCharacter,
        outputHandle,
        ADDR gameOverMSG2,
        LENGTHOF gameOverMSG2,
        gameOverMSGPosition,
        ADDR bytesWritten
    
    inc gameOverMSGPosition.Y
    INVOKE WriteConsoleOutputAttribute,
        outputHandle,
        ADDR gameOverMSGAttribute,
        LENGTHOF gameOverMSG3,
        gameOverMSGPosition,
        ADDR bytesWritten

    INVOKE WriteConsoleOutputCharacter,
        outputHandle,
        ADDR gameOverMSG3,
        LENGTHOF gameOverMSG3,
        gameOverMSGPosition,
        ADDR bytesWritten

    inc gameOverMSGPosition.Y
    INVOKE WriteConsoleOutputAttribute,
        outputHandle,
        ADDR gameOverMSGAttribute,
        LENGTHOF gameOverMSG4,
        gameOverMSGPosition,
        ADDR bytesWritten

    INVOKE WriteConsoleOutputCharacter,
        outputHandle,
        ADDR gameOverMSG4,
        LENGTHOF gameOverMSG4,
        gameOverMSGPosition,
        ADDR bytesWritten
    sub gameOverMSGPosition.Y, 4

    INVOKE WriteConsoleOutputCharacter,
        outputHandle,
        ADDR scoreMSG,
        LENGTHOF scoreMSG,
        scoreMSGPosition,
        ADDR bytesWritten

    ;print the score
    INVOKE SetConsoleCursorPosition,
        outputHandle,
        scorePosition
     call get_score
     mov eax, score
     CALL WriteDec
    
    INVOKE WriteConsoleOutputAttribute,
        outputHandle,
        ADDR returnMSGAttribute,
        LENGTHOF returnMSG,
        returnMSGPosition,
        ADDR bytesWritten

    INVOKE WriteConsoleOutputCharacter,
        outputHandle,
        ADDR returnMSG,
        LENGTHOF returnMSG,
        returnMSGPosition,
        ADDR bytesWritten

    xor ax, ax
waitTillInput:
    CALL ReadChar
    CMP ax, 0
    JE waitTillInput
;================================================;
;                Reset the game                  ;
;      Reset the old variables if necessary      ;
;================================================;
    CALL initialize
    JMP newGame

exitGame:
main ENDP
END main