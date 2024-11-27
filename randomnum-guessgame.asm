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
    maxPlayers DWORD 10           
    playerCount DWORD ?           
    scores DWORD 10 DUP(0)       
    highScore DWORD 9999          
    maxAttempts DWORD 5           
    attempts DWORD ?              
    secretNumber DWORD ?          
    difficulty DWORD ?            
    currentPlayer DWORD -1         

.code
main PROC
    call Clrscr
    mov eax, 10
    call setTextColor
    call displayIntro

startGame:
;To get the number of players
    mov eax, 11                 
    call setTextColor
    call PlayerCountprocedure
    mov eax, 14
    call setTextColor
    call getPlayerCountInput

;To select and get difficulty level
    mov eax, 11
    call setTextColor
    call displayDifficultyPrompt
    mov eax, 14
    call setTextColor
    call getDifficultyInput

;To set random range and max attempts based on difficulty
    call setDifficultyRange

;To generate the random number
    call generateRandomNumber

;To initialize attempts and scores
    mov attempts, 0
    call initializeScores

guessLoop:
;To check if max attempts reached or not
    push eax
    push ebx
    mov eax, attempts       
    mov ebx, maxAttempts
    cmp eax, ebx            
    pop ebx
    pop eax
    jge endGame              

;To switch turns between players
    call switchPlayer
    mov eax, 11
    call setTextColor

;To get current player for guess
    call promptGuess
    mov eax, 7
    call setTextColor
    call getGuessInput

    inc attempts

;To compare guess with the secret num
    call checkGuess
    mov eax, guess
    cmp eax, secretnUMBER
    je correctAnswer
    jmp guessLoop

correctAnswer:
    call updatePlayerScore   
    mov eax, 15                  
    call setTextColor
    jmp endRound            

endRound:
;To reset attempts for next round
    mov attempts, 0
    CALL DisplayScores
    call displayPlayAgainPrompt
    call getPlayAgainInput
    cmp al, 'y'
    je startGame
    EXIT

endGame:
;To display result and ask to play again
    mov eax, 12                  
    call setTextColor
    call revealAnswer
    call displayScores
    mov eax, 11                  
    call setTextColor
    call displayPlayAgainPrompt
    call getPlayAgainInput
    CALL CRLF
    cmp al, 'y'
    je startGame

    exit

main ENDP

displayIntro PROC
    pushfd
    push edx
    mov eax, 10                  
    call setTextColor
    mov edx, OFFSET introMsg
    invoke WriteString
    call Crlf
    pop edx
    popfd
    ret
displayIntro ENDP

PlayerCountprocedure PROC
    push edx
    mov edx, OFFSET promptPlayerCount
    invoke WriteString
    pop edx
    ret
PlayerCountprocedure ENDP

getPlayerCountInput PROC
  enter 0, 0                   
    push edx                      
    push eax                     
    call ReadInt
    mov playerCount, eax
    cmp eax, 1
    jl invalidPlayerInput
    cmp eax, maxPlayers
    jg invalidPlayerInput
    pop eax                       
    pop edx                      
    leave                         
    ret

invalidPlayerInput:
    mov eax, 12                  
    call setTextColor
    mov edx, OFFSET invalidInputMsg
    invoke WriteString
    call Crlf
    jmp getPlayerCountInput
getPlayerCountInput ENDP

initializeScores PROC
;To initialize scores to 0
    push esi
    push ecx
    mov ecx, maxPlayers
    mov esi, OFFSET scores
initLoop:
    mov DWORD PTR [esi], 0
    add esi, 4
    loop initLoop
    pop ecx
    pop esi
    ret
initializeScores ENDP

displayDifficultyPrompt PROC
    push edx
    mov edx, OFFSET promptLevel
    invoke WriteString
    pop edx
    ret
displayDifficultyPrompt ENDP

getDifficultyInput PROC
;To get user input for difficulty 
    enter 0, 0                
    call ReadInt             
    mov difficulty, eax       

    cmp eax, 1               
    je easyLevel
    cmp eax, 2                
    je mediumLevel
    cmp eax, 3                
    je hardLevel

invalidInput:
    push edx                  
    mov edx, OFFSET invalidInputMsg
    call WriteString         
    call Crlf
    pop edx                   
    jmp getDifficultyInput    

easyLevel:
    mov eax, 1                
    shl eax, 3               
    add eax, 2               
    mov ecx, eax
    mov maxAttempts, 5       
    jmp exitProcedure

mediumLevel:
    mov eax, 3                
    shl eax, 4                
    add eax, 2                
    mov ecx, eax
    mov maxAttempts, 5        
    jmp exitProcedure

hardLevel:
    mov eax, 6                
    ror eax, 1              
    shl eax, 5               
    add eax, 4                
    mov ecx, eax
    mov maxAttempts, 5        
    jmp exitProcedure

exitProcedure:
    leave                    
    ret                       
getDifficultyInput ENDP

setDifficultyRange PROC
;To set the random num range according to diffi level
    mov ecx, eax      
    ret
setDifficultyRange ENDP

generateRandomNumber PROC
;To generate random num within range
    call RandomRange
    mov secretNumber, eax
    ret
generateRandomNumber ENDP

switchPlayer PROC
;To switch to the next player
    push eax
    mov eax, currentPlayer
    inc eax
    cmp eax, playerCount
    jl validPlayer
    mov eax, 0         
validPlayer:
    mov currentPlayer, eax
    pop eax
    ret
switchPlayer ENDP

promptGuess PROC
    push edx
    mov eax, 13                  
    call setTextColor
    mov edx, OFFSET guessPrompt
    call WriteString
    mov eax, currentPlayer
    call Writedec
    call Crlf
    pop edx
    ret
promptGuess ENDP

getGuessInput PROC
;To get user's guess
    call ReadInt
    mov guess, eax
    ret
getGuessInput ENDP

checkGuess PROC
;To Check if guess is correct, too high, or too low
    push edx
    push eax
    cmp eax, secretNumber
    jl tooLow
    jg tooHigh
    je correctGuess

tooLow:
    mov edx, OFFSET tooLowMsg
    call WriteString
    call Crlf
    POP eax                   
    POP edx                    
    ret

tooHigh:
    mov edx, OFFSET tooHighMsg
    call WriteString
    call Crlf
    POP eax                   
    POP edx                    
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
    POP eax                    
    POP edx                    
    ret
checkGuess ENDP

updatePlayerScore PROC
;To increment current player's score
    mov eax, currentPlayer                         
    mov ecx, eax
    mov eax, 4                 
    mul ecx                     
    add eax, OFFSET scores     
    inc DWORD PTR [eax]         
    ret
updatePlayerScore ENDP


revealAnswer PROC
    enter 0, 0               
    push eax                 
    push edx

;To display the reveal message
    lea edx, revealMsg       
    call WriteString        

;To display the secret num
    mov eax, secretNumber    
    imul eax, 1              
    mov ecx, 10
    cdq                   
    idiv ecx                 
                             
    add eax, edx             
    call WriteInt         
    call Crlf                

;To Clean space and return
    pop edx                  
    pop eax
    leave                   
    ret
revealAnswer ENDP


displayScores PROC
;To display scores for all players
    mov eax, 15                  
    call setTextColor
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

end main                        
