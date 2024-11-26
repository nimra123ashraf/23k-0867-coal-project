INCLUDE Irvine32.inc

.data
    introMsg BYTE "Welcome to the Random Number Guess Game!", 0
    promptPlayerCount BYTE "Enter the number of players: ", 0
    promptLevel BYTE "Choose difficulty level: (1) Easy, (2) Medium, (3) Hard: ", 0
    invalidInputMsg BYTE "Invalid input! Please enter a number within range.", 0
    guessPrompt BYTE "Enter your guess,player: ", 0
    highScoreMsg BYTE "Current High Score: ", 0
    tooLowMsg BYTE "Too low!", 0
    tooHighMsg BYTE "Too high!", 0
    correctMsg BYTE "Congratulations! Player ", 0
    correctMsg2 BYTE " guessed the correct number!", 0
    revealMsg BYTE "Sorry! The correct number was ", 0
    playAgainPrompt BYTE "Do you want to play again? (y/n): ", 0

    guess DWORD ?
    maxPlayers DWORD 10           ; Maximum allowed players
    playerCount DWORD ?           ; Number of players
    scores DWORD 10 DUP(0)        ; Array to store scores for each player
    highScore DWORD 9999          ; Initial high score set to a large value
    maxAttempts DWORD 5           ; Maximum attempts allowed per round
    attempts DWORD ?              ; Current attempts count
    secretNumber DWORD ?          ; Stores the randomly generated number
    difficulty DWORD ?            ; Stores the chosen difficulty level
    currentPlayer DWORD -1         ; Tracks whose turn it is

.code
main PROC
;mov currentPlayer,1
    call Clrscr
    call displayIntro

startGame:
    ; Get the number of players
    call PlayerCountprocedure
    call getPlayerCountInput

    ; Display difficulty selection and get difficulty level
    call displayDifficultyPrompt
    call getDifficultyInput

    ; Set the random range and max attempts based on difficulty
    call setDifficultyRange

    ; Generate the random number
    call generateRandomNumber

    ; Initialize attempts and scores
    mov attempts, 0
    call initializeScores

guessLoop:
    ; Check if maximum attempts reached
    mov eax, attempts         ; Load attempts into eax
    mov ebx, maxAttempts      ; Load maxAttempts into ebx
    cmp eax, ebx              ; Compare attempts with maxAttempts
    jge endGame               ; If attempts >= maxAttempts, go to endGame

    ; Switch turns between players
    call switchPlayer

    ; Prompt the current player for a guess
    call promptGuess
    call getGuessInput

    ; Increment attempts
    inc attempts

    ; Compare guess with the secret number
    call checkGuess
    mov eax, guess
    cmp eax, secretnUMBER
    je correctAnswer
    jmp guessLoop

correctAnswer:
    call updatePlayerScore   ; Increment the player's score
    jmp endRound             ; Skip remaining guesses and end the round

endRound:
    ; Reset attempts for the next round
    mov attempts, 0
    CALL DisplayScores
    call displayPlayAgainPrompt
    call getPlayAgainInput
    cmp al, 'y'
    je startGame
    EXIT

endGame:
    ; Display result and ask to play again
    call revealAnswer
    call displayScores
    call displayPlayAgainPrompt
    call getPlayAgainInput
    CALL CRLF
    cmp al, 'y'
    je startGame

    exit

main ENDP

displayIntro PROC
    mov edx, OFFSET introMsg
    call WriteString
    call Crlf
    ret
displayIntro ENDP

PlayerCountprocedure PROC
    mov edx, OFFSET promptPlayerCount
    call WriteString
    ret
PlayerCountprocedure ENDP

getPlayerCountInput PROC
enter 0, 0                   ; Set up stack frame
    push edx                      ; Save registers that might be modified
    push eax  
    call ReadInt
    mov playerCount, eax
    cmp eax, 1
    jl invalidPlayerInput
    cmp eax, maxPlayers
    jg invalidPlayerInput
    pop eax                       ; Restore eax
    pop edx                       ; Restore edx
    leave
    ret

invalidPlayerInput:
    mov edx, OFFSET invalidInputMsg
    invoke WriteString
    call Crlf
    jmp getPlayerCountInput
getPlayerCountInput ENDP

initializeScores PROC
    ; Initialize scores array to 0
    mov ecx, maxPlayers
    mov esi, OFFSET scores
initLoop:
    mov DWORD PTR [esi], 0
    add esi, 4
    loop initLoop
    ret
initializeScores ENDP

displayDifficultyPrompt PROC
    mov edx, OFFSET promptLevel
    call WriteString
    ret
displayDifficultyPrompt ENDP

getDifficultyInput PROC
    ; Get user input for difficulty and validate
    call ReadInt
    mov difficulty, eax
    cmp eax, 1
    je easyLevel
    cmp eax, 2
    je mediumLevel
    cmp eax, 3
    je hardLevel
    mov edx, OFFSET invalidInputMsg
    call WriteString
    call Crlf
    jmp getDifficultyInput

easyLevel:
    mov eax, 10       ; Easy range
    mov maxAttempts, 5
    ret
mediumLevel:
    mov eax, 50       ; Medium range
    mov maxAttempts, 5
    ret
hardLevel:
    mov eax, 100      ; Hard range
    mov maxAttempts, 5
    ret
getDifficultyInput ENDP

setDifficultyRange PROC
    ; Set the random number range according to difficulty level
    mov ecx, eax       ; Range is stored in ecx for RandomRange
    ret
setDifficultyRange ENDP

generateRandomNumber PROC
    ; Generate random number within selected range
    call RandomRange
    mov secretNumber, eax
    ret
generateRandomNumber ENDP

switchPlayer PROC
    ; Switch to the next player
    mov eax, currentPlayer
    inc eax
    cmp eax, playerCount
    jl validPlayer
    mov eax, 0         ; Reset to player 1 if exceeded player count
validPlayer:
    mov currentPlayer, eax
    ret
switchPlayer ENDP

promptGuess PROC
    mov edx, OFFSET guessPrompt
    call WriteString
    mov eax, currentPlayer
    call Writedec
    call Crlf
    ;add eax, 1         ; Display player number (1-based)
    ;call WriteInt
    ;call Crlf
    ret
promptGuess ENDP

getGuessInput PROC
    ; Get user's guess
    call ReadInt
    mov guess, eax
    ret
getGuessInput ENDP

checkGuess PROC
    ; Check if guess is correct, too high, or too low
    cmp eax, secretNumber
    jl tooLow
    jg tooHigh
    je correctGuess

tooLow:
    mov edx, OFFSET tooLowMsg
    call WriteString
    call Crlf
    ret

tooHigh:
    mov edx, OFFSET tooHighMsg
    call WriteString
    call Crlf
    ret

correctGuess:
    mov edx, OFFSET correctMsg
    call WriteString
    mov eax, currentPlayer
    add eax, 1
    call WriteInt
    mov edx, OFFSET correctMsg2
    call WriteString
    call Crlf
    ret
checkGuess ENDP

updatePlayerScore PROC
    ; Increment the current player's score
    mov eax, currentPlayer      ; Get the current player index
    ;dec eax                     ; Convert 1-based index to 0-based index if necessary
    mov ecx, eax
    mov eax, 4                  ; Size of each score (4 bytes)
    mul ecx                     ; eax = currentPlayer * 4
    add eax, OFFSET scores      ; Address of the current player's score
    inc DWORD PTR [eax]         ; Increment the score
    ret
updatePlayerScore ENDP


revealAnswer PROC
    ; Display the correct answer if attempts exhausted
    mov edx, OFFSET revealMsg
    call WriteString
    mov eax, secretNumber
    call WriteInt
    call Crlf
    ret
revealAnswer ENDP

displayScores PROC
    ; Display scores for all players
    mov ecx, playerCount
    mov esi, OFFSET scores
    mov edx, OFFSET highScoreMsg

    CALL writestring
scoreLoop:
    mov eax, [esi]
    call WriteInt
    call Crlf
    add esi, 4
    loop scoreLoop
    ret
displayScores ENDP

displayPlayAgainPrompt PROC
    mov edx, OFFSET playAgainPrompt
    call WriteString
    ret
displayPlayAgainPrompt ENDP

getPlayAgainInput PROC
    call ReadChar
    ret
getPlayAgainInput ENDP

END main
