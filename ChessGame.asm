; Chess Game - MASM32
; Traditional colors: White pieces = white, Black pieces = black
; MODES: 1 = Solo (you vs AI), 2 = Duo (two players)
; Mode + color are now chosen ON THE GUI (not the console).
; Controls:
;   Menu screen : press 1 / 2 to choose
;   In game     : type moves in the console window
;   Game over   : press R to restart, ESC to exit
.386
.model flat, stdcall
option casemap:none
include C:\masm32\include\windows.inc
include C:\masm32\include\user32.inc
include C:\masm32\include\gdi32.inc
include C:\masm32\include\kernel32.inc
include C:\masm32\include\gdiplus.inc
include C:\masm32\include\masm32.inc
includelib C:\masm32\lib\user32.lib
includelib C:\masm32\lib\gdi32.lib
includelib C:\masm32\lib\kernel32.lib
includelib C:\masm32\lib\gdiplus.lib
includelib C:\masm32\lib\masm32.lib
.const
    SquareSizev equ 60
    BoardSizev equ SquareSizev*8
    MAX_INPUTv equ 128
    BorderSizev equ 30
    ; Game result constants
    GAME_ONGOINGv equ 0
    GAME_WHITE_WINSv equ 1
    GAME_BLACK_WINSv equ 2
    GAME_STALEMATEv equ 3
    ; Mode constants
    MODE_SOLOv equ 1
    MODE_DUOv  equ 2
    ; ----- GUI flow state constants -----
    STATE_MODEv  equ 0      ; choosing Solo / Duo
    STATE_COLORv equ 1      ; choosing White / Black (solo only)
    STATE_PLAYv  equ 2      ; game in progress
.data
    ClassNamev db "ChessGameClass", 0
    AppNamev db "Chess Game - MASM32", 0
    FontNamev db "Times New Roman", 0
    PromptTextv db 0Dh, 0Ah, "Enter move (e.g., 'e2 e4', 'O-O' or '0-0' for castling): ", 0
    InvalidMoveTextv db 0Dh, 0Ah, "Invalid move! Please try again.", 0Dh, 0Ah, 0
    CheckTextv db 0Dh, 0Ah, "Check!", 0Dh, 0Ah, 0
    CheckmateTextv db 0Dh, 0Ah, "Checkmate! Game over.", 0
    StalemateTextv db 0Dh, 0Ah, "Stalemate! It's a draw.", 0Dh, 0Ah, 0
    WhiteWinsTextv db 0Dh, 0Ah, "White wins!", 0Dh, 0Ah, 0
    BlackWinsTextv db 0Dh, 0Ah, "Black wins!", 0Dh, 0Ah, 0
    SeparatorTextv db "--------------------------------------------------", 0
    CmdWindowTitlev db 0Dh, 0Ah, "Chess Command Input", 0
    Player1MoveTextv db 0Dh, 0Ah, "White's move: ", 0
    Player2MoveTextv db 0Dh, 0Ah, "Black's move: ", 0
    PromoteTextv db 0Dh, 0Ah, "Pawn promotion! Enter piece (Q, R, B, N): ", 0
    PromotedTextv db 0Dh, 0Ah, "Pawn promoted to ", 0
    RankLabelsv db "12345678", 0
    FileLabelsv db "abcdefgh", 0
    ; ----- Console messages still used during play -----
    SoloChosenv     db 0Dh, 0Ah, "Solo mode selected.", 0Dh, 0Ah, 0
    DuoChosenv      db 0Dh, 0Ah, "Duo mode selected. Two players.", 0Dh, 0Ah, 0
    AIThinkingv     db 0Dh, 0Ah, "AI is thinking...", 0Dh, 0Ah, 0
    AIMovedv        db 0Dh, 0Ah, "AI played: ", 0
    AINoMovev       db 0Dh, 0Ah, "AI has no legal moves.", 0Dh, 0Ah, 0
    SpaceStrv       db " ", 0
    ; GUI Result Messages
    WhiteWinsGUIv db "WHITE WINS!", 0
    BlackWinsGUIv db "BLACK WINS!", 0
    StalemateGUIv db "STALEMATE!", 0
    GameOverGUIv db "GAME OVER", 0
    PressKeyGUIv db "Press R to restart, ESC to quit", 0
    RestartMsgv db 0Dh, 0Ah, "Game restarted!", 0Dh, 0Ah, 0
    ; ----- GUI menu strings -----
    MenuTitlev       db "CHESS GAME", 0
    MenuSubTitlev    db "Select Game Mode", 0
    MenuMode1v       db "Press  1   -   Solo Play  (You vs AI)", 0
    MenuMode2v       db "Press  2   -   Duo Play  (Two Players)", 0
    MenuColorTitlev  db "Choose Your Color", 0
    MenuColor1v      db "Press  1   -   Play as White  (you move first)", 0
    MenuColor2v      db "Press  2   -   Play as Black  (AI moves first)", 0
    MenuHintv        db "Moves are typed in the console window", 0
    ; Unicode chess symbols
    EmptySquarev dw 0
    InitialBoardv dw 2656h, 2658h, 2657h, 2655h, 2654h, 2657h, 2658h, 2656h
                 dw 2659h, 2659h, 2659h, 2659h, 2659h, 2659h, 2659h, 2659h
                 dw 8 dup(0)
                 dw 8 dup(0)
                 dw 8 dup(0)
                 dw 8 dup(0)
                 dw 265Fh, 265Fh, 265Fh, 265Fh, 265Fh, 265Fh, 265Fh, 265Fh
                 dw 265Ch, 265Eh, 265Dh, 265Bh, 265Ah, 265Dh, 265Eh, 265Ch
    WhiteLabelv db "White: ",0
    BlackLabelv db "Black: ",0
    KingInDangerv DWORD 0
    KingXv DWORD 0
    KingYv DWORD 0
.data?
    hInstv HINSTANCE ?
    hwndMainv HWND ?
    msgv MSG <>
    wcv WNDCLASSEX <>
    xCoordv dd ?
    yCoordv dd ?
    hFontv dd ?
    CurrentBoardv dw 64 dup(?)
    hInputv dd ?
    hOutputv dd ?
    InputBufferv db MAX_INPUTv dup(?)
    MoveFromXv db ?
    MoveFromYv db ?
    MoveToXv db ?
    MoveToYv db ?
    Turnv db ?  ; 0 = White, 1 = Black
    GameOverv db ?
    GameResultv db ?  ; 0=ongoing, 1=white wins, 2=black wins, 3=stalemate
    WhiteCanCastleKingsidev db ?
    WhiteCanCastleQueensidev db ?
    BlackCanCastleKingsidev db ?
    BlackCanCastleQueensidev db ?
    EnPassantTargetXv db ?
    EnPassantTargetYv db ?
    EnPassantAvailablev db ?
    ; ----- Mode / AI state -----
    GameModev       db ?   ; 1 = solo, 2 = duo
    AIColorv        db ?   ; 0 = white is AI, 1 = black is AI (only used in solo)
    GameStatev      db ?   ; 0 = mode select, 1 = color select, 2 = playing
    ModeBufferv     db 16 dup(?)
    AIMoveBufferv   db 16 dup(?)
    ClientRectLeft dd ?
    ClientRectTop dd ?
    ClientRectRight dd ?
    ClientRectBottom dd ?
    WindowWidthv dd ?
    WindowHeightv dd ?
    ScreenWidthv dd ?
    ScreenHeightv dd ?
    ScrollXv dd ?
    ScrollYv dd ?
    ClientWidthv dd ?
    ClientHeightv dd ?
    hInputThreadv dd ?
    hInputThreadIdv dd ?
    bRestartRequested db ?
    bExitRequested db ?
.code
; Forward declarations
InputThreadv proto
CreateChessFontv proto
DrawPiecev proto hdcv:HDC, xPosv:DWORD, yPosv:DWORD, piecev:WORD
InitializeBoardv proto
ResetGamev proto
GetPieceAtv proto xPosv:BYTE, yPosv:BYTE
SetPieceAtv proto xPosv:BYTE, yPosv:BYTE, piecev:WORD
ParseMovev proto
HandleCastlingv proto
HandleEnPassantv proto
HandlePawnPromotionv proto
GetUserMovev proto
IsValidMovev proto piecev:WORD, fromXv:BYTE, fromYv:BYTE, toXv:BYTE, toYv:BYTE
IsKingInCheckv proto isWhitev:BYTE
IsCheckmatev proto isWhitev:BYTE
IsStalematev proto isWhitev:BYTE
IsPathClearv proto fromXv:BYTE, fromYv:BYTE, toXv:BYTE, toYv:BYTE
ChooseAIMovev proto
EvaluateBoardv proto
PieceValuev proto piecev:WORD
ApplyMoveAndCheckEndv proto
DrawMenuv proto hdcv:HDC
; ============================================================================
; Reset Game - Restarts the entire game
; ============================================================================
ResetGamev proc
    ; Reset board to initial position
    mov esi, offset InitialBoardv
    mov edi, offset CurrentBoardv
    mov ecx, 64
    rep movsw
    ; Reset game state variables
    mov Turnv, 0
    mov GameOverv, 0
    mov GameResultv, GAME_ONGOINGv
    mov WhiteCanCastleKingsidev, 1
    mov WhiteCanCastleQueensidev, 1
    mov BlackCanCastleKingsidev, 1
    mov BlackCanCastleQueensidev, 1
    mov EnPassantAvailablev, 0
    mov EnPassantTargetXv, 0
    mov EnPassantTargetYv, 0
    ; Clear input buffer
    push ecx
    mov ecx, MAX_INPUTv
    mov edi, offset InputBufferv
    xor al, al
    rep stosb
    pop ecx
    ; Refresh the GUI
    invoke InvalidateRect, hwndMainv, NULL, TRUE
    invoke UpdateWindow, hwndMainv
    ; Print reset message to console
    invoke StdOut, addr SeparatorTextv
    invoke StdOut, addr RestartMsgv
    invoke StdOut, addr SeparatorTextv
    ret
ResetGamev endp
CreateChessFontv proc
    invoke CreateFont, SquareSizev/2, 0, 0, 0, FW_BOLD, FALSE, FALSE, FALSE,
                      DEFAULT_CHARSET, OUT_OUTLINE_PRECIS, CLIP_DEFAULT_PRECIS,
                      CLEARTYPE_QUALITY, VARIABLE_PITCH, addr FontNamev
    ret
CreateChessFontv endp
DrawPiecev proc hdcv:HDC, xPosv:DWORD, yPosv:DWORD, piecev:WORD
    LOCAL pieceRectv:RECT
    LOCAL oldFontv:HANDLE
    LOCAL wbufv[4]:BYTE
    cmp piecev, 0
    je @F
    mov ax, piecev
    mov word ptr wbufv[0], ax
    mov word ptr wbufv[2], 0
    mov eax, xPosv
    add eax, 2
    mov pieceRectv.left, eax
    mov eax, xPosv
    add eax, SquareSizev
    sub eax, 2
    mov pieceRectv.right, eax
    mov eax, yPosv
    add eax, 2
    mov pieceRectv.top, eax
    mov eax, yPosv
    add eax, SquareSizev
    sub eax, 2
    mov pieceRectv.bottom, eax
    .if piecev >= 265Ah && piecev <= 265Fh
        invoke SetTextColor, hdcv, 00000000h
    .else
        invoke SetTextColor, hdcv, 00FFFFFFh
    .endif
    invoke CreateFont, SquareSizev-4, 0, 0, 0, FW_NORMAL, FALSE, FALSE, FALSE,
                      DEFAULT_CHARSET, OUT_TT_PRECIS, CLIP_DEFAULT_PRECIS,
                      PROOF_QUALITY, DEFAULT_PITCH, addr FontNamev
    mov hFontv, eax
    invoke SelectObject, hdcv, hFontv
    mov oldFontv, eax
    invoke SetBkMode, hdcv, TRANSPARENT
    invoke DrawTextW, hdcv, addr wbufv, -1, addr pieceRectv, DT_CENTER or DT_VCENTER or DT_SINGLELINE
    invoke SelectObject, hdcv, oldFontv
    invoke DeleteObject, hFontv
@@:
    ret
DrawPiecev endp
InitializeBoardv proc
    mov esi, offset InitialBoardv
    mov edi, offset CurrentBoardv
    mov ecx, 64
    rep movsw
    mov Turnv, 0
    mov GameOverv, 0
    mov GameResultv, GAME_ONGOINGv
    mov WhiteCanCastleKingsidev, 1
    mov WhiteCanCastleQueensidev, 1
    mov BlackCanCastleKingsidev, 1
    mov BlackCanCastleQueensidev, 1
    mov EnPassantAvailablev, 0
    mov EnPassantTargetXv, 0
    mov EnPassantTargetYv, 0
    mov bRestartRequested, 0
    mov bExitRequested, 0
    ret
InitializeBoardv endp
GetPieceAtv proc xPosv:BYTE, yPosv:BYTE
    push ebx
    xor eax, eax
    mov al, yPosv
    shl eax, 3
    xor ebx, ebx
    mov bl, xPosv
    add eax, ebx
    mov ax, word ptr [CurrentBoardv + eax*2]
    pop ebx
    ret
GetPieceAtv endp
SetPieceAtv proc xPosv:BYTE, yPosv:BYTE, piecev:WORD
    push ebx
    xor eax, eax
    mov al, yPosv
    shl eax, 3
    xor ebx, ebx
    mov bl, xPosv
    add eax, ebx
    mov bx, piecev
    mov word ptr [CurrentBoardv + eax*2], bx
    pop ebx
    ret
SetPieceAtv endp
CheckKingDanger PROC uses eax ebx ecx edx esi edi
    mov KingInDangerv, 0
    mov esi, 0
RowLoop:
    mov edi, 0
ColLoop:
    mov ecx, esi
    mov edx, edi
    invoke GetPieceAtv, dl, cl
    ; TODO: attack logic here
    inc edi
    cmp edi, 8
    jl ColLoop
    inc esi
    cmp esi, 8
    jl RowLoop
    ret
CheckKingDanger ENDP
IsPathClearv proc fromXv:BYTE, fromYv:BYTE, toXv:BYTE, toYv:BYTE
    LOCAL deltaXv:BYTE, deltaYv:BYTE, currentXv:BYTE, currentYv:BYTE
    LOCAL stepXv:BYTE, stepYv:BYTE
    LOCAL absDeltaXv:BYTE, absDeltaYv:BYTE
    mov al, toXv
    sub al, fromXv
    mov deltaXv, al
    .if al >= 0
        mov absDeltaXv, al
    .else
        neg al
        mov absDeltaXv, al
    .endif
    mov al, toYv
    sub al, fromYv
    mov deltaYv, al
    .if al >= 0
        mov absDeltaYv, al
    .else
        neg al
        mov absDeltaYv, al
    .endif
    cmp deltaXv, 0
    jg @PositiveX
    jl @NegativeX
    mov stepXv, 0
    jmp @CheckY
@NegativeX:
    mov stepXv, 0FFh
    jmp @CheckY
@PositiveX:
    mov stepXv, 1
@CheckY:
    cmp deltaYv, 0
    jg @PositiveY
    jl @NegativeY
    mov stepYv, 0
    jmp @DoneSteps
@NegativeY:
    mov stepYv, 0FFh
    jmp @DoneSteps
@PositiveY:
    mov stepYv, 1
@DoneSteps:
    mov al, fromXv
    add al, stepXv
    mov currentXv, al
    mov al, fromYv
    add al, stepYv
    mov currentYv, al
@CheckLoop:
    mov al, currentXv
    cmp al, toXv
    jne @Continue
    mov al, currentYv
    cmp al, toYv
    je @PathClear
@Continue:
    invoke GetPieceAtv, currentXv, currentYv
    cmp ax, 0
    jne @PathBlocked
    mov al, currentXv
    add al, stepXv
    mov currentXv, al
    mov al, currentYv
    add al, stepYv
    mov currentYv, al
    jmp @CheckLoop
@PathBlocked:
    xor eax, eax
    ret
@PathClear:
    mov eax, 1
    ret
IsPathClearv endp
IsValidMovev proc uses ebx piecev:WORD, fromXv:BYTE, fromYv:BYTE, toXv:BYTE, toYv:BYTE
    LOCAL deltaXv:BYTE, deltaYv:BYTE
    LOCAL absDeltaXv:BYTE, absDeltaYv:BYTE
    LOCAL targetPiecev:WORD
    invoke GetPieceAtv, toXv, toYv
    mov targetPiecev, ax
    .if targetPiecev != 0
        mov ax, piecev
        .if (ax >= 265Ah && ax <= 265Fh && targetPiecev >= 265Ah && targetPiecev <= 265Fh) || \
            (ax < 265Ah && targetPiecev < 265Ah)
            xor eax, eax
            ret
        .endif
    .endif
    mov al, toXv
    sub al, fromXv
    mov deltaXv, al
    jns @AbsDeltaXPos
    neg al
@AbsDeltaXPos:
    mov absDeltaXv, al
    mov al, toYv
    sub al, fromYv
    mov deltaYv, al
    jns @AbsDeltaYPos
    neg al
@AbsDeltaYPos:
    mov absDeltaYv, al
    mov al, absDeltaXv
    or al, absDeltaYv
    jz @InvalidMove
    .if piecev == 2659h
        mov al, deltaXv
        cmp al, 0
        jne @CheckWhitePawnCapture
        mov al, deltaYv
        cmp al, 1
        je @WhitePawnSingle
        cmp al, 2
        jne @InvalidMove
        mov al, fromYv
        cmp al, 1
        jne @InvalidMove
        cmp targetPiecev, 0
        jne @InvalidMove
        mov al, fromYv
        inc al
        invoke GetPieceAtv, fromXv, al
        cmp ax, 0
        jne @InvalidMove
        mov eax, 1
        ret
@WhitePawnSingle:
        cmp targetPiecev, 0
        jne @InvalidMove
        mov eax, 1
        ret
@CheckWhitePawnCapture:
        mov al, absDeltaXv
        cmp al, 1
        jne @CheckWhiteEnPassant
        mov al, deltaYv
        cmp al, 1
        jne @InvalidMove
        cmp targetPiecev, 0
        je @CheckWhiteEnPassant
        mov ax, targetPiecev
        cmp ax, 265Ah
        jl @InvalidMove
        mov eax, 1
        ret
@CheckWhiteEnPassant:
        mov al, absDeltaXv
        cmp al, 1
        jne @InvalidMove
        mov al, deltaYv
        cmp al, 1
        jne @InvalidMove
        cmp EnPassantAvailablev, 1
        jne @InvalidMove
        mov al, toXv
        cmp al, EnPassantTargetXv
        jne @InvalidMove
        mov al, toYv
        cmp al, EnPassantTargetYv
        jne @InvalidMove
        mov eax, 1
        ret
    .elseif piecev == 265Fh
        mov al, deltaXv
        cmp al, 0
        jne @CheckBlackPawnCapture
        mov al, deltaYv
        cmp al, 0FFh
        je @BlackPawnSingle
        cmp al, 0FEh
        jne @InvalidMove
        mov al, fromYv
        cmp al, 6
        jne @InvalidMove
        cmp targetPiecev, 0
        jne @InvalidMove
        mov al, fromYv
        dec al
        invoke GetPieceAtv, fromXv, al
        cmp ax, 0
        jne @InvalidMove
        mov eax, 1
        ret
@BlackPawnSingle:
        cmp targetPiecev, 0
        jne @InvalidMove
        mov eax, 1
        ret
@CheckBlackPawnCapture:
        mov al, absDeltaXv
        cmp al, 1
        jne @CheckBlackEnPassant
        mov al, deltaYv
        cmp al, 0FFh
        jne @InvalidMove
        cmp targetPiecev, 0
        je @CheckBlackEnPassant
        mov ax, targetPiecev
        cmp ax, 265Ah
        jge @InvalidMove
        mov eax, 1
        ret
@CheckBlackEnPassant:
        mov al, absDeltaXv
        cmp al, 1
        jne @InvalidMove
        mov al, deltaYv
        cmp al, 0FFh
        jne @InvalidMove
        cmp EnPassantAvailablev, 1
        jne @InvalidMove
        mov al, toXv
        cmp al, EnPassantTargetXv
        jne @InvalidMove
        mov al, toYv
        cmp al, EnPassantTargetYv
        jne @InvalidMove
        mov eax, 1
        ret
    .elseif piecev == 2658h || piecev == 265Eh
        movzx eax, absDeltaXv
        movzx ebx, absDeltaYv
        cmp eax, 2
        jne @KnightCheck2
        cmp ebx, 1
        je @KnightValid
        jmp @InvalidMove
    @KnightCheck2:
        cmp eax, 1
        jne @InvalidMove
        cmp ebx, 2
        jne @InvalidMove
    @KnightValid:
        mov eax, 1
        ret
    .elseif piecev == 2657h || piecev == 265Dh
        mov al, absDeltaXv
        cmp al, absDeltaYv
        jne @InvalidMove
        invoke IsPathClearv, fromXv, fromYv, toXv, toYv
        cmp eax, 0
        je @InvalidMove
        mov eax, 1
        ret
    .elseif piecev == 2656h || piecev == 265Ch
        mov al, deltaXv
        cmp al, 0
        je @CheckRookPath
        mov al, deltaYv
        cmp al, 0
        je @CheckRookPath
        xor eax, eax
        ret
@CheckRookPath:
        invoke IsPathClearv, fromXv, fromYv, toXv, toYv
        cmp eax, 0
        je @InvalidMove
        mov eax, 1
        ret
    .elseif piecev == 2655h || piecev == 265Bh
        mov al, deltaXv
        cmp al, 0
        je @CheckQueenPath
        mov al, deltaYv
        cmp al, 0
        je @CheckQueenPath
        mov al, absDeltaXv
        cmp al, absDeltaYv
        jne @InvalidMove
@CheckQueenPath:
        invoke IsPathClearv, fromXv, fromYv, toXv, toYv
        cmp eax, 0
        je @InvalidMove
        mov eax, 1
        ret
    .elseif piecev == 2654h || piecev == 265Ah
        movzx eax, absDeltaXv
        movzx ebx, absDeltaYv
        add eax, ebx
        cmp eax, 0
        je @InvalidMove
        movzx eax, absDeltaXv
        cmp eax, 1
        jg @InvalidMove
        movzx eax, absDeltaYv
        cmp eax, 1
        jg @InvalidMove
        mov eax, 1
        ret
    .endif
@InvalidMove:
    xor eax, eax
    ret
IsValidMovev endp
IsKingInCheckv proc isWhitev:BYTE
    LOCAL kingXv:BYTE, kingYv:BYTE
    LOCAL currentXv:BYTE, currentYv:BYTE
    LOCAL piecev:WORD
    LOCAL isOpponentPiecev:BYTE
    mov isOpponentPiecev, 0
    .if isWhitev == 1
        mov isOpponentPiecev, 1
    .endif
    mov kingXv, 0FFh
    mov kingYv, 0FFh
    mov currentYv, 0
    .while currentYv < 8
        mov currentXv, 0
        .while currentXv < 8
            invoke GetPieceAtv, currentXv, currentYv
            mov piecev, ax
            .if isWhitev == 1 && piecev == 2654h
                mov al, currentXv
                mov kingXv, al
                mov al, currentYv
                mov kingYv, al
                jmp @FoundKing
            .elseif isWhitev == 0 && piecev == 265Ah
                mov al, currentXv
                mov kingXv, al
                mov al, currentYv
                mov kingYv, al
                jmp @FoundKing
            .endif
            inc currentXv
        .endw
        inc currentYv
    .endw
@FoundKing:
    cmp kingXv, 0FFh
    je @NoCheck
    cmp kingYv, 0FFh
    je @NoCheck
    mov currentYv, 0
    .while currentYv < 8
        mov currentXv, 0
        .while currentXv < 8
            invoke GetPieceAtv, currentXv, currentYv
            mov piecev, ax
            .if piecev != 0
                mov ax, piecev
                .if isOpponentPiecev == 1 && ax >= 265Ah && ax <= 265Fh
                    invoke IsValidMovev, piecev, currentXv, currentYv, kingXv, kingYv
                    .if eax == 1
                        mov eax, 1
                        ret
                    .endif
                .elseif isOpponentPiecev == 0 && ax < 265Ah
                    invoke IsValidMovev, piecev, currentXv, currentYv, kingXv, kingYv
                    .if eax == 1
                        mov eax, 1
                        ret
                    .endif
                .endif
            .endif
            inc currentXv
        .endw
        inc currentYv
    .endw
@NoCheck:
    xor eax, eax
    ret
IsKingInCheckv endp
IsCheckmatev proc isWhitev:BYTE
    LOCAL currentXv:BYTE, currentYv:BYTE, targetXv:BYTE, targetYv:BYTE
    LOCAL piecev:WORD
    LOCAL tempPiecev:WORD
    LOCAL originalPiecev:WORD
    invoke IsKingInCheckv, isWhitev
    cmp eax, 0
    je @NotCheckmate
    mov currentYv, 0
    .while currentYv < 8
        mov currentXv, 0
        .while currentXv < 8
            invoke GetPieceAtv, currentXv, currentYv
            mov piecev, ax
            .if piecev != 0
                .if (isWhitev == 1 && piecev < 265Ah) || (isWhitev == 0 && piecev >= 265Ah)
                    mov targetYv, 0
                    .while targetYv < 8
                        mov targetXv, 0
                        .while targetXv < 8
                            invoke IsValidMovev, piecev, currentXv, currentYv, targetXv, targetYv
                            .if eax == 1
                                invoke GetPieceAtv, targetXv, targetYv
                                mov tempPiecev, ax
                                invoke GetPieceAtv, currentXv, currentYv
                                mov originalPiecev, ax
                                invoke SetPieceAtv, targetXv, targetYv, originalPiecev
                                invoke SetPieceAtv, currentXv, currentYv, 0
                                invoke IsKingInCheckv, isWhitev
                                push eax
                                invoke SetPieceAtv, currentXv, currentYv, originalPiecev
                                invoke SetPieceAtv, targetXv, targetYv, tempPiecev
                                pop eax
                                cmp eax, 0
                                je @NotCheckmate
                            .endif
                            inc targetXv
                        .endw
                        inc targetYv
                    .endw
                .endif
            .endif
            inc currentXv
        .endw
        inc currentYv
    .endw
    mov eax, 1
    ret
@NotCheckmate:
    xor eax, eax
    ret
IsCheckmatev endp
IsStalematev proc isWhitev:BYTE
    LOCAL currentXv:BYTE, currentYv:BYTE, targetXv:BYTE, targetYv:BYTE
    LOCAL piecev:WORD
    LOCAL tempPiecev:WORD
    LOCAL originalPiecev:WORD
    invoke IsKingInCheckv, isWhitev
    cmp eax, 1
    je @NotStalemate
    mov currentYv, 0
    .while currentYv < 8
        mov currentXv, 0
        .while currentXv < 8
            invoke GetPieceAtv, currentXv, currentYv
            mov piecev, ax
            .if piecev != 0
                .if (isWhitev == 1 && piecev < 265Ah) || (isWhitev == 0 && piecev >= 265Ah)
                    mov targetYv, 0
                    .while targetYv < 8
                        mov targetXv, 0
                        .while targetXv < 8
                            invoke IsValidMovev, piecev, currentXv, currentYv, targetXv, targetYv
                            .if eax == 1
                                invoke GetPieceAtv, targetXv, targetYv
                                mov tempPiecev, ax
                                invoke GetPieceAtv, currentXv, currentYv
                                mov originalPiecev, ax
                                invoke SetPieceAtv, targetXv, targetYv, originalPiecev
                                invoke SetPieceAtv, currentXv, currentYv, 0
                                invoke IsKingInCheckv, isWhitev
                                push eax
                                invoke SetPieceAtv, currentXv, currentYv, originalPiecev
                                invoke SetPieceAtv, targetXv, targetYv, tempPiecev
                                pop eax
                                cmp eax, 0
                                je @NotStalemate
                            .endif
                            inc targetXv
                        .endw
                        inc targetYv
                    .endw
                .endif
            .endif
            inc currentXv
        .endw
        inc currentYv
    .endw
    mov eax, 1
    ret
@NotStalemate:
    xor eax, eax
    ret
IsStalematev endp
; ============================================================================
; PieceValuev - returns the material value of a piece (in EAX)
; ============================================================================
PieceValuev proc piecev:WORD
    mov ax, piecev
    .if ax == 2659h || ax == 265Fh
        mov eax, 10
    .elseif ax == 2658h || ax == 265Eh
        mov eax, 30
    .elseif ax == 2657h || ax == 265Dh
        mov eax, 30
    .elseif ax == 2656h || ax == 265Ch
        mov eax, 50
    .elseif ax == 2655h || ax == 265Bh
        mov eax, 90
    .elseif ax == 2654h || ax == 265Ah
        mov eax, 9000
    .else
        xor eax, eax
    .endif
    ret
PieceValuev endp
; ============================================================================
; EvaluateBoardv - material balance from WHITE's perspective.
; ============================================================================
EvaluateBoardv proc uses ebx esi
    LOCAL cxv:BYTE, cyv:BYTE
    LOCAL scorev:SDWORD
    mov scorev, 0
    mov cyv, 0
    .while cyv < 8
        mov cxv, 0
        .while cxv < 8
            invoke GetPieceAtv, cxv, cyv
            .if ax != 0
                push ax
                invoke PieceValuev, ax
                mov ebx, eax
                pop ax
                .if ax < 265Ah
                    add scorev, ebx
                .else
                    sub scorev, ebx
                .endif
            .endif
            inc cxv
        .endw
        inc cyv
    .endw
    mov eax, scorev
    ret
EvaluateBoardv endp
; ============================================================================
; ChooseAIMovev - picks the best legal move for the side to move.
; ============================================================================
ChooseAIMovev proc uses ebx esi edi
    LOCAL cxv:BYTE, cyv:BYTE, txv:BYTE, tyv:BYTE
    LOCAL piecev:WORD
    LOCAL capturedv:WORD
    LOCAL origv:WORD
    LOCAL bestScorev:SDWORD
    LOCAL curScorev:SDWORD
    LOCAL haveMovev:BYTE
    LOCAL aiIsWhitev:BYTE
    LOCAL bFromXv:BYTE, bFromYv:BYTE, bToXv:BYTE, bToYv:BYTE
    mov haveMovev, 0
    mov al, Turnv
    .if al == 0
        mov aiIsWhitev, 1
        mov bestScorev, -7FFFFFFFh
    .else
        mov aiIsWhitev, 0
        mov bestScorev, 7FFFFFFFh
    .endif
    mov cyv, 0
    .while cyv < 8
        mov cxv, 0
        .while cxv < 8
            invoke GetPieceAtv, cxv, cyv
            mov piecev, ax
            .if ax != 0
                .if (aiIsWhitev == 1 && piecev < 265Ah) || (aiIsWhitev == 0 && piecev >= 265Ah)
                    mov tyv, 0
                    .while tyv < 8
                        mov txv, 0
                        .while txv < 8
                            invoke IsValidMovev, piecev, cxv, cyv, txv, tyv
                            .if eax == 1
                                invoke GetPieceAtv, txv, tyv
                                mov capturedv, ax
                                invoke GetPieceAtv, cxv, cyv
                                mov origv, ax
                                invoke SetPieceAtv, txv, tyv, origv
                                invoke SetPieceAtv, cxv, cyv, 0
                                mov al, aiIsWhitev
                                invoke IsKingInCheckv, al
                                .if eax == 1
                                    invoke SetPieceAtv, cxv, cyv, origv
                                    invoke SetPieceAtv, txv, tyv, capturedv
                                .else
                                    invoke EvaluateBoardv
                                    mov curScorev, eax
                                    invoke SetPieceAtv, cxv, cyv, origv
                                    invoke SetPieceAtv, txv, tyv, capturedv
                                    mov eax, curScorev
                                    .if aiIsWhitev == 1
                                        .if eax > bestScorev || haveMovev == 0
                                            mov bestScorev, eax
                                            mov bl, cxv
                                            mov bFromXv, bl
                                            mov bl, cyv
                                            mov bFromYv, bl
                                            mov bl, txv
                                            mov bToXv, bl
                                            mov bl, tyv
                                            mov bToYv, bl
                                            mov haveMovev, 1
                                        .endif
                                    .else
                                        .if eax < bestScorev || haveMovev == 0
                                            mov bestScorev, eax
                                            mov bl, cxv
                                            mov bFromXv, bl
                                            mov bl, cyv
                                            mov bFromYv, bl
                                            mov bl, txv
                                            mov bToXv, bl
                                            mov bl, tyv
                                            mov bToYv, bl
                                            mov haveMovev, 1
                                        .endif
                                    .endif
                                .endif
                            .endif
                            inc txv
                        .endw
                        inc tyv
                    .endw
                .endif
            .endif
            inc cxv
        .endw
        inc cyv
    .endw
    .if haveMovev == 0
        xor eax, eax
        ret
    .endif
    mov al, bFromXv
    mov MoveFromXv, al
    mov al, bFromYv
    mov MoveFromYv, al
    mov al, bToXv
    mov MoveToXv, al
    mov al, bToYv
    mov MoveToYv, al
    mov eax, 1
    ret
ChooseAIMovev endp
; ============================================================================
; ApplyMoveAndCheckEndv - executes the AI move and checks for end of game.
; ============================================================================
ApplyMoveAndCheckEndv proc uses ebx
    LOCAL piecev:WORD
    invoke GetPieceAtv, MoveFromXv, MoveFromYv
    mov piecev, ax
    invoke SetPieceAtv, MoveToXv, MoveToYv, piecev
    invoke SetPieceAtv, MoveFromXv, MoveFromYv, 0
    .if piecev == 2659h || piecev == 265Fh
        mov al, MoveToXv
        cmp al, EnPassantTargetXv
        jne @NoEP
        mov al, MoveToYv
        cmp al, EnPassantTargetYv
        jne @NoEP
        cmp EnPassantAvailablev, 1
        jne @NoEP
        mov al, MoveToYv
        .if piecev == 2659h
            dec al
        .else
            inc al
        .endif
        invoke SetPieceAtv, MoveToXv, al, 0
@NoEP:
    .endif
    .if piecev == 2654h
        mov WhiteCanCastleKingsidev, 0
        mov WhiteCanCastleQueensidev, 0
    .elseif piecev == 265Ah
        mov BlackCanCastleKingsidev, 0
        mov BlackCanCastleQueensidev, 0
    .elseif piecev == 2656h
        mov al, MoveFromXv
        .if al == 0 && MoveFromYv == 0
            mov WhiteCanCastleQueensidev, 0
        .elseif al == 7 && MoveFromYv == 0
            mov WhiteCanCastleKingsidev, 0
        .endif
    .elseif piecev == 265Ch
        mov al, MoveFromXv
        .if al == 0 && MoveFromYv == 7
            mov BlackCanCastleQueensidev, 0
        .elseif al == 7 && MoveFromYv == 7
            mov BlackCanCastleKingsidev, 0
        .endif
    .endif
    invoke HandleEnPassantv
    invoke GetPieceAtv, MoveToXv, MoveToYv
    .if ax == 2659h && MoveToYv == 7
        invoke SetPieceAtv, MoveToXv, MoveToYv, 2655h
    .elseif ax == 265Fh && MoveToYv == 0
        invoke SetPieceAtv, MoveToXv, MoveToYv, 265Bh
    .endif
    mov al, Turnv
    xor al, 1
    invoke IsKingInCheckv, al
    .if eax == 1
        invoke StdOut, addr CheckTextv
        mov al, Turnv
        xor al, 1
        invoke IsCheckmatev, al
        .if eax == 1
            invoke StdOut, addr CheckmateTextv
            mov al, Turnv
            .if al == 0
                invoke StdOut, addr WhiteWinsTextv
                mov GameResultv, GAME_WHITE_WINSv
            .else
                invoke StdOut, addr BlackWinsTextv
                mov GameResultv, GAME_BLACK_WINSv
            .endif
            mov GameOverv, 1
        .endif
    .else
        mov al, Turnv
        xor al, 1
        invoke IsStalematev, al
        .if eax == 1
            invoke StdOut, addr StalemateTextv
            mov GameResultv, GAME_STALEMATEv
            mov GameOverv, 1
        .endif
    .endif
    xor Turnv, 1
    invoke InvalidateRect, hwndMainv, NULL, TRUE
    invoke UpdateWindow, hwndMainv
    invoke StdOut, addr SeparatorTextv
    ret
ApplyMoveAndCheckEndv endp
HandleCastlingv proc
    LOCAL isWhitev:BYTE
    mov bl, Turnv
    mov isWhitev, bl
    invoke lstrlen, addr InputBufferv
    .if eax == 3
        .if byte ptr [InputBufferv] == 'O' && byte ptr [InputBufferv+1] == '-' && byte ptr [InputBufferv+2] == 'O'
            .if isWhitev == 0
                .if WhiteCanCastleKingsidev == 0
                    jmp CastlingInvalid
                .endif
                invoke GetPieceAtv, 4, 0
                cmp ax, 2654h
                jne CastlingInvalid
                invoke GetPieceAtv, 7, 0
                cmp ax, 2656h
                jne CastlingInvalid
                invoke IsPathClearv, 4, 0, 6, 0
                cmp eax, 0
                je CastlingInvalid
                invoke IsKingInCheckv, 1
                cmp eax, 1
                je CastlingInvalid
                invoke SetPieceAtv, 5, 0, 2654h
                invoke SetPieceAtv, 4, 0, 0
                invoke IsKingInCheckv, 1
                push eax
                invoke SetPieceAtv, 4, 0, 2654h
                invoke SetPieceAtv, 5, 0, 0
                pop eax
                cmp eax, 1
                je CastlingInvalid
                invoke SetPieceAtv, 6, 0, 2654h
                invoke SetPieceAtv, 4, 0, 0
                invoke IsKingInCheckv, 1
                push eax
                invoke SetPieceAtv, 4, 0, 2654h
                invoke SetPieceAtv, 6, 0, 0
                pop eax
                cmp eax, 1
                je CastlingInvalid
                invoke SetPieceAtv, 6, 0, 2654h
                invoke SetPieceAtv, 5, 0, 2656h
                invoke SetPieceAtv, 4, 0, 0
                invoke SetPieceAtv, 7, 0, 0
                mov WhiteCanCastleKingsidev, 0
                mov WhiteCanCastleQueensidev, 0
            .else
                .if BlackCanCastleKingsidev == 0
                    jmp CastlingInvalid
                .endif
                invoke GetPieceAtv, 4, 7
                cmp ax, 265Ah
                jne CastlingInvalid
                invoke GetPieceAtv, 7, 7
                cmp ax, 265Ch
                jne CastlingInvalid
                invoke IsPathClearv, 4, 7, 6, 7
                cmp eax, 0
                je CastlingInvalid
                invoke IsKingInCheckv, 0
                cmp eax, 1
                je CastlingInvalid
                invoke SetPieceAtv, 5, 7, 265Ah
                invoke SetPieceAtv, 4, 7, 0
                invoke IsKingInCheckv, 0
                push eax
                invoke SetPieceAtv, 4, 7, 265Ah
                invoke SetPieceAtv, 5, 7, 0
                pop eax
                cmp eax, 1
                je CastlingInvalid
                invoke SetPieceAtv, 6, 7, 265Ah
                invoke SetPieceAtv, 4, 7, 0
                invoke IsKingInCheckv, 0
                push eax
                invoke SetPieceAtv, 4, 7, 265Ah
                invoke SetPieceAtv, 6, 7, 0
                pop eax
                cmp eax, 1
                je CastlingInvalid
                invoke SetPieceAtv, 6, 7, 265Ah
                invoke SetPieceAtv, 5, 7, 265Ch
                invoke SetPieceAtv, 4, 7, 0
                invoke SetPieceAtv, 7, 7, 0
                mov BlackCanCastleKingsidev, 0
                mov BlackCanCastleQueensidev, 0
            .endif
            mov eax, 1
            ret
        .endif
    .elseif eax == 5
        .if byte ptr [InputBufferv] == 'O' && byte ptr [InputBufferv+1] == '-' && byte ptr [InputBufferv+2] == 'O' && byte ptr [InputBufferv+3] == '-' && byte ptr [InputBufferv+4] == 'O'
            .if isWhitev == 0
                .if WhiteCanCastleQueensidev == 0
                    jmp CastlingInvalid
                .endif
                invoke GetPieceAtv, 4, 0
                cmp ax, 2654h
                jne CastlingInvalid
                invoke GetPieceAtv, 0, 0
                cmp ax, 2656h
                jne CastlingInvalid
                invoke IsPathClearv, 4, 0, 2, 0
                cmp eax, 0
                je CastlingInvalid
                invoke IsKingInCheckv, 1
                cmp eax, 1
                je CastlingInvalid
                invoke SetPieceAtv, 3, 0, 2654h
                invoke SetPieceAtv, 4, 0, 0
                invoke IsKingInCheckv, 1
                push eax
                invoke SetPieceAtv, 4, 0, 2654h
                invoke SetPieceAtv, 3, 0, 0
                pop eax
                cmp eax, 1
                je CastlingInvalid
                invoke SetPieceAtv, 2, 0, 2654h
                invoke SetPieceAtv, 4, 0, 0
                invoke IsKingInCheckv, 1
                push eax
                invoke SetPieceAtv, 4, 0, 2654h
                invoke SetPieceAtv, 2, 0, 0
                pop eax
                cmp eax, 1
                je CastlingInvalid
                invoke SetPieceAtv, 2, 0, 2654h
                invoke SetPieceAtv, 3, 0, 2656h
                invoke SetPieceAtv, 4, 0, 0
                invoke SetPieceAtv, 0, 0, 0
                mov WhiteCanCastleKingsidev, 0
                mov WhiteCanCastleQueensidev, 0
            .else
                .if BlackCanCastleQueensidev == 0
                    jmp CastlingInvalid
                .endif
                invoke GetPieceAtv, 4, 7
                cmp ax, 265Ah
                jne CastlingInvalid
                invoke GetPieceAtv, 0, 7
                cmp ax, 265Ch
                jne CastlingInvalid
                invoke IsPathClearv, 4, 7, 2, 7
                cmp eax, 0
                je CastlingInvalid
                invoke IsKingInCheckv, 0
                cmp eax, 1
                je CastlingInvalid
                invoke SetPieceAtv, 3, 7, 265Ah
                invoke SetPieceAtv, 4, 7, 0
                invoke IsKingInCheckv, 0
                push eax
                invoke SetPieceAtv, 4, 7, 265Ah
                invoke SetPieceAtv, 3, 7, 0
                pop eax
                cmp eax, 1
                je CastlingInvalid
                invoke SetPieceAtv, 2, 7, 265Ah
                invoke SetPieceAtv, 4, 7, 0
                invoke IsKingInCheckv, 0
                push eax
                invoke SetPieceAtv, 4, 7, 265Ah
                invoke SetPieceAtv, 2, 7, 0
                pop eax
                cmp eax, 1
                je CastlingInvalid
                invoke SetPieceAtv, 2, 7, 265Ah
                invoke SetPieceAtv, 3, 7, 265Ch
                invoke SetPieceAtv, 4, 7, 0
                invoke SetPieceAtv, 0, 7, 0
                mov BlackCanCastleKingsidev, 0
                mov BlackCanCastleQueensidev, 0
            .endif
            mov eax, 1
            ret
        .endif
    .endif
CastlingInvalid:
    xor eax, eax
    ret
HandleCastlingv endp
HandleEnPassantv proc
    mov EnPassantAvailablev, 0
    invoke GetPieceAtv, MoveFromXv, MoveFromYv
    .if ax == 2659h
        mov al, MoveToYv
        sub al, MoveFromYv
        cmp al, 2
        jne @NoEnPassant
        mov al, MoveFromYv
        cmp al, 1
        jne @NoEnPassant
        mov al, MoveToXv
        mov EnPassantTargetXv, al
        mov al, MoveToYv
        dec al
        mov EnPassantTargetYv, al
        mov EnPassantAvailablev, 1
        ret
    .elseif ax == 265Fh
        mov al, MoveFromYv
        sub al, MoveToYv
        cmp al, 2
        jne @NoEnPassant
        mov al, MoveFromYv
        cmp al, 6
        jne @NoEnPassant
        mov al, MoveToXv
        mov EnPassantTargetXv, al
        mov al, MoveToYv
        inc al
        mov EnPassantTargetYv, al
        mov EnPassantAvailablev, 1
        ret
    .endif
@NoEnPassant:
    ret
HandleEnPassantv endp
HandlePawnPromotionv proc
    LOCAL piecev:WORD
    LOCAL promoteBufferv[8]:BYTE
    invoke GetPieceAtv, MoveToXv, MoveToYv
    mov piecev, ax
    .if piecev == 2659h && MoveToYv == 7
        invoke StdOut, addr PromoteTextv
        invoke StdIn, addr promoteBufferv, 8
        mov al, byte ptr [promoteBufferv]
        .if al == 'Q' || al == 'q'
            invoke SetPieceAtv, MoveToXv, MoveToYv, 2655h
            invoke StdOut, addr PromotedTextv
            invoke StdOut, addr promoteBufferv
        .elseif al == 'R' || al == 'r'
            invoke SetPieceAtv, MoveToXv, MoveToYv, 2656h
            invoke StdOut, addr PromotedTextv
            invoke StdOut, addr promoteBufferv
        .elseif al == 'B' || al == 'b'
            invoke SetPieceAtv, MoveToXv, MoveToYv, 2657h
            invoke StdOut, addr PromotedTextv
            invoke StdOut, addr promoteBufferv
        .elseif al == 'N' || al == 'n'
            invoke SetPieceAtv, MoveToXv, MoveToYv, 2658h
            invoke StdOut, addr PromotedTextv
            invoke StdOut, addr promoteBufferv
        .else
            invoke SetPieceAtv, MoveToXv, MoveToYv, 2655h
            invoke StdOut, addr PromotedTextv
            mov byte ptr [promoteBufferv], 'Q'
            invoke StdOut, addr promoteBufferv
        .endif
    .elseif piecev == 265Fh && MoveToYv == 0
        invoke StdOut, addr PromoteTextv
        invoke StdIn, addr promoteBufferv, 8
        mov al, byte ptr [promoteBufferv]
        .if al == 'Q' || al == 'q'
            invoke SetPieceAtv, MoveToXv, MoveToYv, 265Bh
            invoke StdOut, addr PromotedTextv
            invoke StdOut, addr promoteBufferv
        .elseif al == 'R' || al == 'r'
            invoke SetPieceAtv, MoveToXv, MoveToYv, 265Ch
            invoke StdOut, addr PromotedTextv
            invoke StdOut, addr promoteBufferv
        .elseif al == 'B' || al == 'b'
            invoke SetPieceAtv, MoveToXv, MoveToYv, 265Dh
            invoke StdOut, addr PromotedTextv
            invoke StdOut, addr promoteBufferv
        .elseif al == 'N' || al == 'n'
            invoke SetPieceAtv, MoveToXv, MoveToYv, 265Eh
            invoke StdOut, addr PromotedTextv
            invoke StdOut, addr promoteBufferv
        .else
            invoke SetPieceAtv, MoveToXv, MoveToYv, 265Bh
            invoke StdOut, addr PromotedTextv
            mov byte ptr [promoteBufferv], 'Q'
            invoke StdOut, addr promoteBufferv
        .endif
    .endif
    invoke StdOut, addr SeparatorTextv
    ret
HandlePawnPromotionv endp
ParseMovev proc uses esi edi
    LOCAL tempPiecev:WORD
    LOCAL piecev:WORD
    LOCAL isWhitev:BYTE
    LOCAL inputLen:DWORD
    cmp GameOverv, 1
    jne @Continue
    xor eax, eax
    ret
@Continue:
    invoke HandleCastlingv
    cmp eax, 1
    jne @NotCastling
    mov al, Turnv
    invoke IsKingInCheckv, al
    .if eax == 1
        invoke StdOut, addr CheckTextv
        mov al, Turnv
        invoke IsCheckmatev, al
        .if eax == 1
            invoke StdOut, addr CheckmateTextv
            mov al, Turnv
            .if al == 0
                invoke StdOut, addr WhiteWinsTextv
                mov GameResultv, GAME_WHITE_WINSv
            .else
                invoke StdOut, addr BlackWinsTextv
                mov GameResultv, GAME_BLACK_WINSv
            .endif
            mov GameOverv, 1
            invoke InvalidateRect, hwndMainv, NULL, TRUE
            invoke UpdateWindow, hwndMainv
        .endif
    .else
        mov al, Turnv
        invoke IsStalematev, al
        .if eax == 1
            invoke StdOut, addr StalemateTextv
            mov GameResultv, GAME_STALEMATEv
            mov GameOverv, 1
            invoke InvalidateRect, hwndMainv, NULL, TRUE
            invoke UpdateWindow, hwndMainv
        .endif
    .endif
    xor Turnv, 1
    jmp MoveSuccessful
@NotCastling:
    invoke lstrlen, addr InputBufferv
    mov inputLen, eax
    cmp eax, 5
    jb InvalidMove
    cmp eax, MAX_INPUTv-1
    ja InvalidMove
    cmp eax, 5
    jne InvalidMove
    movzx eax, byte ptr [InputBufferv]
    .if al >= 'a' && al <= 'h'
        sub al, 'a'
    .elseif al >= 'A' && al <= 'H'
        sub al, 'A'
    .else
        jmp InvalidMove
    .endif
    mov MoveFromXv, al
    movzx eax, byte ptr [InputBufferv+1]
    sub al, '1'
    .if al < 0 || al > 7
        jmp InvalidMove
    .endif
    mov MoveFromYv, al
    .if byte ptr [InputBufferv+2] != ' '
        jmp InvalidMove
    .endif
    movzx eax, byte ptr [InputBufferv+3]
    .if al >= 'a' && al <= 'h'
        sub al, 'a'
    .elseif al >= 'A' && al <= 'H'
        sub al, 'A'
    .else
        jmp InvalidMove
    .endif
    mov MoveToXv, al
    movzx eax, byte ptr [InputBufferv+4]
    sub al, '1'
    .if al < 0 || al > 7
        jmp InvalidMove
    .endif
    mov MoveToYv, al
    cmp MoveFromXv, 7
    jg InvalidMove
    cmp MoveFromYv, 7
    jg InvalidMove
    cmp MoveToXv, 7
    jg InvalidMove
    cmp MoveToYv, 7
    jg InvalidMove
    invoke GetPieceAtv, MoveFromXv, MoveFromYv
    mov piecev, ax
    cmp ax, 0
    je InvalidMove
    mov bl, Turnv
    mov isWhitev, bl
    .if bl == 0
        cmp ax, 265Ah
        jge InvalidMove
    .else
        cmp ax, 265Ah
        jl InvalidMove
    .endif
    invoke IsValidMovev, piecev, MoveFromXv, MoveFromYv, MoveToXv, MoveToYv
    cmp eax, 0
    je InvalidMove
    invoke GetPieceAtv, MoveToXv, MoveToYv
    mov tempPiecev, ax
    invoke SetPieceAtv, MoveToXv, MoveToYv, piecev
    invoke SetPieceAtv, MoveFromXv, MoveFromYv, 0
    .if piecev == 2659h || piecev == 265Fh
        mov al, MoveToXv
        cmp al, EnPassantTargetXv
        jne @NoEnPassantCapture
        mov al, MoveToYv
        cmp al, EnPassantTargetYv
        jne @NoEnPassantCapture
        cmp EnPassantAvailablev, 1
        jne @NoEnPassantCapture
        mov al, MoveToYv
        .if piecev == 2659h
            dec al
        .else
            inc al
        .endif
        invoke SetPieceAtv, MoveToXv, al, 0
@NoEnPassantCapture:
    .endif
    mov bl, Turnv
    xor bl, 1
    invoke IsKingInCheckv, bl
    .if eax == 1
        invoke SetPieceAtv, MoveFromXv, MoveFromYv, piecev
        invoke SetPieceAtv, MoveToXv, MoveToYv, tempPiecev
        jmp InvalidMove
    .endif
    .if piecev == 2654h
        mov WhiteCanCastleKingsidev, 0
        mov WhiteCanCastleQueensidev, 0
    .elseif piecev == 265Ah
        mov BlackCanCastleKingsidev, 0
        mov BlackCanCastleQueensidev, 0
    .elseif piecev == 2656h
        mov al, MoveFromXv
        .if al == 0 && MoveFromYv == 0
            mov WhiteCanCastleQueensidev, 0
        .elseif al == 7 && MoveFromYv == 0
            mov WhiteCanCastleKingsidev, 0
        .endif
    .elseif piecev == 265Ch
        mov al, MoveFromXv
        .if al == 0 && MoveFromYv == 7
            mov BlackCanCastleQueensidev, 0
        .elseif al == 7 && MoveFromYv == 7
            mov BlackCanCastleKingsidev, 0
        .endif
    .endif
    invoke HandleEnPassantv
    invoke HandlePawnPromotionv
    mov al, Turnv
    invoke IsKingInCheckv, al
    .if eax == 1
        invoke StdOut, addr CheckTextv
        mov al, Turnv
        invoke IsCheckmatev, al
        .if eax == 1
            invoke StdOut, addr CheckmateTextv
            mov al, Turnv
            .if al == 0
                invoke StdOut, addr WhiteWinsTextv
                mov GameResultv, GAME_WHITE_WINSv
            .else
                invoke StdOut, addr BlackWinsTextv
                mov GameResultv, GAME_BLACK_WINSv
            .endif
            mov GameOverv, 1
            invoke InvalidateRect, hwndMainv, NULL, TRUE
            invoke UpdateWindow, hwndMainv
        .endif
    .else
        mov al, Turnv
        invoke IsStalematev, al
        .if eax == 1
            invoke StdOut, addr StalemateTextv
            mov GameResultv, GAME_STALEMATEv
            mov GameOverv, 1
            invoke InvalidateRect, hwndMainv, NULL, TRUE
            invoke UpdateWindow, hwndMainv
        .endif
    .endif
    xor Turnv, 1
MoveSuccessful:
    invoke InvalidateRect, hwndMainv, NULL, TRUE
    invoke UpdateWindow, hwndMainv
    invoke StdOut, addr SeparatorTextv
    mov eax, 1
    ret
InvalidMove:
    invoke StdOut, addr InvalidMoveTextv
    invoke StdOut, addr SeparatorTextv
    xor eax, eax
    ret
ParseMovev endp
GetUserMovev proc
    ; Do nothing while the GUI menu is up (mode/color not chosen yet)
    .if GameStatev != STATE_PLAYv
        invoke Sleep, 50
        xor eax, eax
        ret
    .endif
    .if GameOverv == 1
        ; When game is over, just check flags and return
        cmp bRestartRequested, 1
        jne @CheckExitFlag
        mov bRestartRequested, 0
        invoke ResetGamev
        xor eax, eax
        ret
    @CheckExitFlag:
        cmp bExitRequested, 1
        jne @NoAction
        invoke PostQuitMessage, 0
        xor eax, eax
        ret
    @NoAction:
        invoke Sleep, 50
        xor eax, eax
        ret
    .endif
    ; --- SOLO MODE: if it's the AI's turn, let the AI move ---
    .if GameModev == MODE_SOLOv
        mov al, Turnv
        .if al == AIColorv
            invoke StdOut, addr AIThinkingv
            invoke ChooseAIMovev
            .if eax == 0
                invoke StdOut, addr AINoMovev
                xor eax, eax
                ret
            .endif
            mov al, MoveFromXv
            add al, 'a'
            mov byte ptr [AIMoveBufferv+0], al
            mov al, MoveFromYv
            add al, '1'
            mov byte ptr [AIMoveBufferv+1], al
            mov byte ptr [AIMoveBufferv+2], ' '
            mov al, MoveToXv
            add al, 'a'
            mov byte ptr [AIMoveBufferv+3], al
            mov al, MoveToYv
            add al, '1'
            mov byte ptr [AIMoveBufferv+4], al
            mov byte ptr [AIMoveBufferv+5], 0
            invoke StdOut, addr AIMovedv
            invoke StdOut, addr AIMoveBufferv
            invoke ApplyMoveAndCheckEndv
            xor eax, eax
            ret
        .endif
    .endif
    ; --- Human's turn ---
    mov al, Turnv
    .if al == 0
        invoke StdOut, addr Player1MoveTextv
    .else
        invoke StdOut, addr Player2MoveTextv
    .endif
    invoke StdIn, addr InputBufferv, MAX_INPUTv
    invoke lstrlen, addr InputBufferv
    mov ecx, eax
    .while ecx > 0
        dec ecx
        movzx edx, byte ptr [InputBufferv + ecx]
        .if dl == 0Dh || dl == 0Ah
            mov byte ptr [InputBufferv + ecx], 0
        .else
            .break
        .endif
    .endw
    mov ecx, 0
@NormLoop:
    cmp ecx, 5
    jge @NormDone
    movzx edx, byte ptr [InputBufferv + ecx]
    cmp dl, '0'
    jne @NormNext
    mov byte ptr [InputBufferv + ecx], 'O'
@NormNext:
    inc ecx
    jmp @NormLoop
@NormDone:
    movzx edx, byte ptr [InputBufferv + 1]
    cmp dl, ' '
    jne @NormSpaceDone
    mov byte ptr [InputBufferv + 1], '-'
    movzx edx, byte ptr [InputBufferv + 3]
    cmp dl, ' '
    jne @NormSpaceDone
    mov byte ptr [InputBufferv + 3], '-'
@NormSpaceDone:
    invoke lstrlen, addr InputBufferv
    .if eax < 3
        invoke StdOut, addr InvalidMoveTextv
        invoke StdOut, addr SeparatorTextv
        xor eax, eax
        ret
    .endif
    invoke ParseMovev
    ret
GetUserMovev endp
; ==============================================================
; Timer format
; ==============================================================
FormatTime PROC uses eax ebx ecx edx esi edi,
    seconds:DWORD,
    buffer:DWORD
    mov eax, seconds
    mov ebx, 60
    xor edx, edx
    div ebx              ; eax = minutes, edx = seconds
    ; eax = minutes
    ; edx = seconds
    ; format MM
    mov ecx, eax         ; minutes
    mov esi, buffer
    ; tens of minutes
    mov eax, ecx
    xor edx, edx
    mov ebx, 10
    div ebx
    add al, '0'
    mov [esi], al
    inc esi
    ; ones of minutes
    mov eax, edx
    add al, '0'
    mov [esi], al
    inc esi
    mov byte ptr [esi], ':'
    inc esi
    ; seconds = original remainder stored in edx earlier is gone, recompute
    mov eax, seconds
    xor edx, edx
    div ebx              ; eax garbage, fix below
    mov eax, seconds
    mov ebx, 60
    xor edx, edx
    div ebx              ; edx = seconds
    ; tens seconds
    mov eax, edx
    xor edx, edx
    mov ebx, 10
    div ebx
    add al, '0'
    mov [esi], al
    inc esi
    ; ones seconds
    mov eax, edx
    add al, '0'
    mov [esi], al
    inc esi
    mov byte ptr [esi], 0
    ret
FormatTime ENDP
; ============================================================================
; DrawMenuv - draws the GUI mode/color selection screen
; ============================================================================
DrawMenuv proc hdcv:HDC
    LOCAL rectv:RECT
    LOCAL brushv:HBRUSH
    LOCAL fontv:HANDLE
    LOCAL oldFontv:HANDLE
    LOCAL fullDimv:DWORD
    LOCAL clearRectv:RECT
    
    mov eax, BoardSizev
    add eax, BorderSizev*2
    mov fullDimv, eax
    
    ; ============================================
    ; FORCE CLEAR the entire window with LIGHT BLUE
    ; This OVERRIDES any dark/peach background
    ; ============================================
    mov clearRectv.left, 0
    mov clearRectv.top, 0
    mov eax, fullDimv
    mov clearRectv.right, eax
    mov clearRectv.bottom, eax
    
    ; Bright light blue brush
    invoke CreateSolidBrush, 00DCC8A4h    
    mov brushv, eax
    invoke FillRect, hdcv, addr clearRectv, brushv
    invoke DeleteObject, brushv
    
    ; Optional: Add a second lighter layer for gradient effect
    mov clearRectv.bottom, 300
    invoke CreateSolidBrush, 00DCC8A4h     
    mov brushv, eax
    invoke FillRect, hdcv, addr clearRectv, brushv
    invoke DeleteObject, brushv
    
    invoke SetBkMode, hdcv, TRANSPARENT
    
    ; Draw title
    invoke CreateFont, 54, 0, 0, 0, FW_BOLD, FALSE, FALSE, FALSE,
                      DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
                      DEFAULT_QUALITY, DEFAULT_PITCH, addr FontNamev
    mov fontv, eax
    invoke SelectObject, hdcv, fontv
    mov oldFontv, eax
    invoke SetTextColor, hdcv, 00000080h  ; Maroon
    
    mov rectv.left, 0
    mov eax, fullDimv
    mov rectv.right, eax
    mov rectv.top, 70
    invoke DrawTextA, hdcv, addr MenuTitlev, -1, addr rectv, DT_CENTER or DT_SINGLELINE
    
    invoke SelectObject, hdcv, oldFontv
    invoke DeleteObject, fontv
    
    ; Draw subtitle
    invoke CreateFont, 32, 0, 0, 0, FW_BOLD, FALSE, FALSE, FALSE,
                      DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
                      DEFAULT_QUALITY, DEFAULT_PITCH, addr FontNamev
    mov fontv, eax
    invoke SelectObject, hdcv, fontv
    mov oldFontv, eax
    invoke SetTextColor, hdcv, 00008000h
    
    mov rectv.top, 170
    .if GameStatev == STATE_MODEv
        invoke DrawTextA, hdcv, addr MenuSubTitlev, -1, addr rectv, DT_CENTER or DT_SINGLELINE
    .else
        invoke DrawTextA, hdcv, addr MenuColorTitlev, -1, addr rectv, DT_CENTER or DT_SINGLELINE
    .endif
    
    invoke SelectObject, hdcv, oldFontv
    invoke DeleteObject, fontv
    
    ; Draw options
    invoke CreateFont, 24, 0, 0, 0, FW_NORMAL, FALSE, FALSE, FALSE,
                      DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
                      DEFAULT_QUALITY, DEFAULT_PITCH, addr FontNamev
    mov fontv, eax
    invoke SelectObject, hdcv, fontv
    mov oldFontv, eax
    invoke SetTextColor, hdcv, 00000000h  ; Black
    
    .if GameStatev == STATE_MODEv
        mov rectv.top, 280
        invoke DrawTextA, hdcv, addr MenuMode1v, -1, addr rectv, DT_CENTER or DT_SINGLELINE
        mov rectv.top, 340
        invoke DrawTextA, hdcv, addr MenuMode2v, -1, addr rectv, DT_CENTER or DT_SINGLELINE
    .else
        mov rectv.top, 280
        invoke DrawTextA, hdcv, addr MenuColor1v, -1, addr rectv, DT_CENTER or DT_SINGLELINE
        mov rectv.top, 340
        invoke DrawTextA, hdcv, addr MenuColor2v, -1, addr rectv, DT_CENTER or DT_SINGLELINE
    .endif
    
    invoke SelectObject, hdcv, oldFontv
    invoke DeleteObject, fontv
    
    ; Draw hint
    invoke CreateFont, 18, 0, 0, 0, FW_NORMAL, FALSE, FALSE, FALSE,
                      DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
                      DEFAULT_QUALITY, DEFAULT_PITCH, addr FontNamev
    mov fontv, eax
    invoke SelectObject, hdcv, fontv
    mov oldFontv, eax
    invoke SetTextColor, hdcv, 00001040h    ; Dark blue
    
    mov eax, fullDimv
    sub eax, 80
    mov rectv.top, eax
    invoke DrawTextA, hdcv, addr MenuHintv, -1, addr rectv, DT_CENTER or DT_SINGLELINE
    
    invoke SelectObject, hdcv, oldFontv
    invoke DeleteObject, fontv
    
    ret
DrawMenuv endp
WndProcv proc uses ebx edi esi hWndv:HWND, uMsgv:UINT, wParamv:WPARAM, lParamv:LPARAM
    LOCAL hdcv:HDC
    LOCAL psv:PAINTSTRUCT
    LOCAL brushv:HBRUSH
    LOCAL rectv:RECT
    LOCAL piecev:WORD
    LOCAL labelFontv:HANDLE
    LOCAL oldLabelFontv:HANDLE
    LOCAL labelRectv:RECT
    LOCAL labelCharBuf:WORD
    LOCAL bigFontv:HANDLE
    LOCAL oldBigFontv:HANDLE
    .if uMsgv == WM_DESTROY
        invoke PostQuitMessage, 0
        xor eax, eax
        ret
    .elseif uMsgv == WM_KEYDOWN
        mov eax, wParamv
        ; ----- Menu: choose game mode -----
        .if GameStatev == STATE_MODEv
            .if al == '1'
                mov GameModev, MODE_SOLOv
                mov GameStatev, STATE_COLORv
                invoke InvalidateRect, hWndv, NULL, TRUE
            .elseif al == '2'
                mov GameModev, MODE_DUOv
                mov AIColorv, 0FFh
                call InitializeBoardv
                mov GameStatev, STATE_PLAYv
                invoke StdOut, addr DuoChosenv
                invoke InvalidateRect, hWndv, NULL, TRUE
            .endif
            xor eax, eax
            ret
        ; ----- Menu: choose color (solo) -----
        .elseif GameStatev == STATE_COLORv
            .if al == '1'
                mov AIColorv, 1          ; human white, AI black
                call InitializeBoardv
                mov GameStatev, STATE_PLAYv
                invoke StdOut, addr SoloChosenv
                invoke InvalidateRect, hWndv, NULL, TRUE
            .elseif al == '2'
                mov AIColorv, 0          ; human black, AI white
                call InitializeBoardv
                mov GameStatev, STATE_PLAYv
                invoke StdOut, addr SoloChosenv
                invoke InvalidateRect, hWndv, NULL, TRUE
            .endif
            xor eax, eax
            ret
        ; ----- In game -----
        .else
            .if al == 'R' || al == 'r'
                mov bRestartRequested, 1
            .elseif al == VK_ESCAPE
                mov bExitRequested, 1
            .endif
            xor eax, eax
            ret
        .endif
       .elseif uMsgv == WM_SETFOCUS
        invoke SetFocus, hWndv
       .elseif uMsgv == WM_PAINT
        invoke BeginPaint, hWndv, addr psv
        mov hdcv, eax
        ; If we're still on the menu, draw it and stop here
        .if GameStatev != STATE_PLAYv
            invoke DrawMenuv, hdcv
            invoke EndPaint, hWndv, addr psv
            xor eax, eax
            ret
        .endif
        mov esi, 0
    DrawRow:
        mov edi, 0
    DrawCol:
        mov eax, 7
        sub eax, esi
        imul eax, SquareSizev
        add eax, BorderSizev
        mov yCoordv, eax
        mov eax, edi
        imul eax, SquareSizev
        add eax, BorderSizev
        mov xCoordv, eax
        mov eax, esi
        add eax, edi
        and eax, 1
        .if eax == 0
            invoke CreateSolidBrush, 00F0D9B5h
        .else
            invoke CreateSolidBrush, 00B58863h
        .endif
        mov brushv, eax
        mov eax, xCoordv
        mov rectv.left, eax
        add eax, SquareSizev
        mov rectv.right, eax
        mov eax, yCoordv
        mov rectv.top, eax
        add eax, SquareSizev
        mov rectv.bottom, eax
        invoke FillRect, hdcv, addr rectv, brushv
        invoke DeleteObject, brushv
        movzx edx, di
        movzx ecx, si
        invoke GetPieceAtv, dl, cl
        mov piecev, ax
        invoke DrawPiecev, hdcv, xCoordv, yCoordv, piecev
        inc edi
        cmp edi, 8
        jl DrawCol
        inc esi
        cmp esi, 8
        jl DrawRow
        invoke CheckKingDanger
        invoke CreateFont, SquareSizev*2/3, 0, 0, 0, FW_BOLD, FALSE, FALSE, FALSE,
                          DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
                          DEFAULT_QUALITY, DEFAULT_PITCH, addr FontNamev
        mov labelFontv, eax
        invoke SelectObject, hdcv, labelFontv
        mov oldLabelFontv, eax
        invoke SetTextColor, hdcv, 00000000h
        invoke SetBkMode, hdcv, TRANSPARENT
        mov esi, 0
    DrawRankLabel:
        cmp esi, 8
        jge DoneRankLabel
        mov labelRectv.left, 0
        mov eax, 7
        sub eax, esi
        imul eax, SquareSizev
        add eax, BorderSizev
        mov labelRectv.top, eax
        add eax, SquareSizev
        mov labelRectv.bottom, eax
        mov labelRectv.right, BorderSizev
        mov eax, esi
        add eax, '1'
        mov byte ptr [labelCharBuf], al
        mov byte ptr [labelCharBuf+1], 0
        invoke DrawTextA, hdcv, addr labelCharBuf, 1, addr labelRectv, DT_CENTER or DT_VCENTER or DT_SINGLELINE
        inc esi
        jmp DrawRankLabel
    DoneRankLabel:
        mov eax, 8
        imul eax, SquareSizev
        add eax, BorderSizev
        mov labelRectv.top, eax
        add eax, BorderSizev
        mov labelRectv.bottom, eax
        mov esi, 0
    DrawFileLabel:
        cmp esi, 8
        jge DoneFileLabel
        mov eax, esi
        imul eax, SquareSizev
        add eax, BorderSizev
        mov labelRectv.left, eax
        add eax, SquareSizev
        mov labelRectv.right, eax
        mov eax, esi
        add eax, 'a'
        mov byte ptr [labelCharBuf], al
        mov byte ptr [labelCharBuf+1], 0
        invoke DrawTextA, hdcv, addr labelCharBuf, 1, addr labelRectv, DT_CENTER or DT_VCENTER or DT_SINGLELINE
        inc esi
        jmp DrawFileLabel
    DoneFileLabel:
      ; ================= RESTORE FONT (IMPORTANT) =================
      invoke SelectObject, hdcv, oldLabelFontv
      invoke DeleteObject, labelFontv
        ; Draw game result if game is over
        .if GameOverv == 1
            invoke CreateSolidBrush, 0C0C0C0h
            mov brushv, eax
            mov eax, BorderSizev
            add eax, 100
            mov rectv.left, eax
            mov eax, BoardSizev
            add eax, BorderSizev
            sub eax, 100
            mov rectv.right, eax
            mov eax, BorderSizev
            add eax, 120
            mov rectv.top, eax
            mov eax, BoardSizev
            add eax, BorderSizev
            sub eax, 120
            mov rectv.bottom, eax
            invoke FillRect, hdcv, addr rectv, brushv
            mov eax, KingInDangerv
            cmp eax, 1
            jne NormalColor 
            invoke CreateSolidBrush, 000000FFh   ; RED
            jmp UseBrush
            NormalColor:
            .if eax == 0
               invoke CreateSolidBrush, 00F0D9B5h
            .else
               invoke CreateSolidBrush, 00B58863h
            .endif
            UseBrush:
            mov brushv, eax
            invoke DeleteObject, brushv
            invoke CreateFont, SquareSizev-10, 0, 0, 0, FW_BOLD, FALSE, FALSE, FALSE,
                              DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
                              DEFAULT_QUALITY, DEFAULT_PITCH, addr FontNamev
            mov bigFontv, eax
            invoke SelectObject, hdcv, bigFontv
            invoke DeleteObject, bigFontv
            .if GameResultv == GAME_WHITE_WINSv
                invoke SetTextColor, hdcv, 00FFFFFFh
                mov rectv.top, BorderSizev + 180
                invoke DrawTextA, hdcv, addr WhiteWinsGUIv, -1, addr rectv, DT_CENTER or DT_SINGLELINE
            .elseif GameResultv == GAME_BLACK_WINSv
                invoke SetTextColor, hdcv, 00000000h
                mov rectv.top, BorderSizev + 180
                invoke DrawTextA, hdcv, addr BlackWinsGUIv, -1, addr rectv, DT_CENTER or DT_SINGLELINE
            .else
                invoke SetTextColor, hdcv, 00000080h
                mov rectv.top, BorderSizev + 180
                invoke DrawTextA, hdcv, addr StalemateGUIv, -1, addr rectv, DT_CENTER or DT_SINGLELINE
            .endif
            invoke CreateFont, SquareSizev/2, 0, 0, 0, FW_BOLD, FALSE, FALSE, FALSE,
                              DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
                              DEFAULT_QUALITY, DEFAULT_PITCH, addr FontNamev
            mov bigFontv, eax
            invoke SelectObject, hdcv, bigFontv
            invoke DeleteObject, oldBigFontv
            invoke SetTextColor, hdcv, 00000000h
            mov rectv.top, BorderSizev + 230
            invoke DrawTextA, hdcv, addr GameOverGUIv, -1, addr rectv, DT_CENTER or DT_SINGLELINE
            invoke CreateFont, SquareSizev/3, 0, 0, 0, FW_NORMAL, FALSE, FALSE, FALSE,
                              DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
                              DEFAULT_QUALITY, DEFAULT_PITCH, addr FontNamev
            mov bigFontv, eax
            invoke SelectObject, hdcv, bigFontv
            invoke DeleteObject, oldBigFontv
            invoke SetTextColor, hdcv, 00404040h
            mov rectv.top, BorderSizev + 280
            invoke DrawTextA, hdcv, addr PressKeyGUIv, -1, addr rectv, DT_CENTER or DT_SINGLELINE
            invoke SelectObject, hdcv, oldBigFontv
            invoke DeleteObject, bigFontv
        .endif
        invoke EndPaint, hWndv, addr psv
        xor eax, eax
        ret
    .elseif uMsgv == WM_CREATE
        call InitializeBoardv
        mov GameStatev, STATE_MODEv     ; start on the GUI mode-select screen
        xor eax, eax
        ret
    .endif
    invoke DefWindowProc, hWndv, uMsgv, wParamv, lParamv
    ret
WndProcv endp
InputThreadv proc
InputLoop:
    call GetUserMovev
    invoke Sleep, 50
    jmp InputLoop
InputThreadv endp
start:
    invoke GetModuleHandle, NULL
    mov hInstv, eax
    invoke AllocConsole
    invoke GetStdHandle, STD_INPUT_HANDLE
    mov hInputv, eax
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov hOutputv, eax
    ; Mode/color are now chosen on the GUI menu, not the console.
    mov GameStatev, STATE_MODEv
    mov wcv.cbSize, SIZEOF WNDCLASSEX
    mov wcv.style, CS_HREDRAW or CS_VREDRAW
    mov wcv.lpfnWndProc, offset WndProcv
    mov wcv.cbClsExtra, 0
    mov wcv.cbWndExtra, 0
    mov eax, hInstv
    mov wcv.hInstance, eax
    invoke LoadIcon, NULL, IDI_APPLICATION
    mov wcv.hIcon, eax
    mov wcv.hIconSm, eax
    invoke LoadCursor, NULL, IDC_ARROW
    mov wcv.hCursor, eax
    mov wcv.hbrBackground, COLOR_WINDOW+1
    mov wcv.lpszMenuName, NULL
    mov wcv.lpszClassName, offset ClassNamev
    invoke RegisterClassEx, addr wcv
    mov eax, BoardSizev
    add eax, BorderSizev*2
    mov ecx, eax
    mov ClientRectLeft, 0
    mov ClientRectTop, 0
    mov ClientRectRight, ecx
    mov ClientRectBottom, ecx
    invoke AdjustWindowRect, addr ClientRectLeft, WS_OVERLAPPEDWINDOW, FALSE
    mov eax, ClientRectRight
    sub eax, ClientRectLeft
    mov WindowWidthv, eax
    mov eax, ClientRectBottom
    sub eax, ClientRectTop
    mov WindowHeightv, eax
    invoke SystemParametersInfo, SPI_GETWORKAREA, 0, addr ClientRectLeft, 0
    mov eax, ClientRectRight
    sub eax, ClientRectLeft
    mov ScreenWidthv, eax
    mov eax, ClientRectBottom
    sub eax, ClientRectTop
    mov ScreenHeightv, eax
    mov eax, WindowWidthv
    mov ebx, ScreenWidthv
    sub ebx, 50
    cmp eax, ebx
    jle @WidthOk
    mov WindowWidthv, ebx
@WidthOk:
    mov eax, WindowHeightv
    mov ebx, ScreenHeightv
    sub ebx, 80
    cmp eax, ebx
    jle @HeightOk
    mov WindowHeightv, ebx
@HeightOk:
    mov eax, ScreenWidthv
    sub eax, WindowWidthv
    sar eax, 1
    mov ecx, eax
    mov eax, ScreenHeightv
    sub eax, WindowHeightv
    sar eax, 1
    mov edx, eax
    invoke CreateWindowEx, 0, addr ClassNamev, addr AppNamev, \
        WS_OVERLAPPEDWINDOW or WS_HSCROLL or WS_VSCROLL, \
        ecx, edx, \
        WindowWidthv, WindowHeightv, \
        NULL, NULL, hInstv, NULL
    mov hwndMainv, eax
    .if eax == NULL
        invoke GetLastError
        invoke ExitProcess, eax
    .endif
    invoke ShowWindow, hwndMainv, SW_SHOW
    invoke UpdateWindow, hwndMainv
    invoke CreateThread, NULL, 0, offset InputThreadv, NULL, 0, addr hInputThreadIdv
    mov hInputThreadv, eax
    invoke GetClientRect, hwndMainv, addr ClientRectLeft
    mov eax, ClientRectRight
    sub eax, ClientRectLeft
    mov ClientWidthv, eax
    mov eax, ClientRectBottom
    sub eax, ClientRectTop
    mov ClientHeightv, eax
    mov eax, BoardSizev
    add eax, BorderSizev*2
    mov ebx, eax
    mov eax, ebx
    sub eax, ClientWidthv
    cmp eax, 0
    jl @HZero
    invoke SetScrollRange, hwndMainv, SB_HORZ, 0, eax, TRUE
    invoke ShowScrollBar, hwndMainv, SB_HORZ, TRUE
    jmp @HDone
@HZero:
    invoke SetScrollRange, hwndMainv, SB_HORZ, 0, 0, TRUE
    invoke ShowScrollBar, hwndMainv, SB_HORZ, FALSE
@HDone:
    mov eax, ebx
    sub eax, ClientHeightv
    cmp eax, 0
    jl @VZero
    invoke SetScrollRange, hwndMainv, SB_VERT, 0, eax, TRUE
    invoke ShowScrollBar, hwndMainv, SB_VERT, TRUE
    jmp @VDone
@VZero:
    invoke SetScrollRange, hwndMainv, SB_VERT, 0, 0, TRUE
    invoke ShowScrollBar, hwndMainv, SB_VERT, FALSE
@VDone:
    mov ScrollXv, 0
    mov ScrollYv, 0
MainLoop:
    invoke GetMessage, addr msgv, NULL, 0, 0
    cmp eax, 0
    je EndLoop
    invoke TranslateMessage, addr msgv
    invoke DispatchMessage, addr msgv
    jmp MainLoop
EndLoop:
    invoke ExitProcess, 0
end start