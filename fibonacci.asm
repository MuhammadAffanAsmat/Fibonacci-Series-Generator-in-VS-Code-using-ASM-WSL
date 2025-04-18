section .data                            ; Section for initialized data (constants)
    prompt db "Enter number of terms (max 20): ", 0 ; Message shown to the user
    newline db 0xA, 0                    ; Newline character for clean output
    buffer resb 4                        ; Reserve 4 bytes for storing user input

section .bss                             ; Section for uninitialized variables
    n resd 1                             ; Variable to store user input number (n)
    a resd 1                             ; First term in Fibonacci series (a)
    b resd 1                             ; Second term in Fibonacci series (b)
    temp resd 1                          ; Temporary variable to hold a + b
    count resd 1                         ; Counter for loop iteration

section .text                            ; Code section starts here
    global _start                        ; Define the program entry point

_start:
    ; ---------------- Display prompt ----------------
    mov eax, 4                           ; syscall number for write
    mov ebx, 1                           ; file descriptor 1 (stdout)
    mov ecx, prompt                      ; address of the prompt message
    mov edx, 31                          ; length of the prompt message
    int 0x80                             ; interrupt to execute syscall (write)

    ; ---------------- Read input ----------------
    mov eax, 3                           ; syscall number for read
    mov ebx, 0                           ; file descriptor 0 (stdin)
    mov ecx, buffer                      ; where to store the input
    mov edx, 4                           ; number of bytes to read
    int 0x80                             ; interrupt to execute syscall (read)

    ; ---------------- Convert input string to integer ----------------
    mov ecx, buffer                      ; pointer to the input string
    call str_to_int                      ; call function to convert string to integer
    mov [n], eax                         ; store result in variable n

    ; ---------------- Initialize variables ----------------
    mov dword [a], 0                     ; first Fibonacci number (a = 0)
    mov dword [b], 1                     ; second Fibonacci number (b = 1)
    mov dword [count], 0                ; initialize count = 0

fibonacci_loop:
    ; ---------------- Check if count >= n ----------------
    mov eax, [count]                    ; load current count
    cmp eax, [n]                        ; compare with n
    jge end_program                     ; if count >= n, jump to end

    ; ---------------- Print current Fibonacci number (a) ----------------
    mov eax, [a]                        ; move current value of a into eax
    call print_int                      ; print it
    call print_newline                  ; print newline for spacing

    ; ---------------- Calculate next Fibonacci term ----------------
    mov eax, [a]                        ; move a into eax
    add eax, [b]                        ; eax = a + b
    mov [temp], eax                     ; store result in temp

    mov eax, [b]                        ; move b into eax
    mov [a], eax                        ; a = b

    mov eax, [temp]                     ; load temp (a+b)
    mov [b], eax                        ; b = temp

    ; ---------------- Increment counter and loop ----------------
    inc dword [count]                   ; count++
    jmp fibonacci_loop                  ; repeat loop

end_program:
    ; ---------------- Exit the program ----------------
    mov eax, 1                          ; syscall: exit
    xor ebx, ebx                        ; exit code 0
    int 0x80                            ; interrupt to exit

; ---------------------------------------------------
; Converts a string in ECX to integer in EAX
str_to_int:
    xor eax, eax                        ; clear EAX (will hold final number)
    xor ebx, ebx                        ; clear EBX (used to load digits)

.next_char:
    mov bl, byte [ecx]                 ; load one character from string
    cmp bl, 10                         ; check if it's newline (ASCII 10)
    je .done                           ; if yes, done
    cmp bl, 0                          ; or if null terminator
    je .done
    sub bl, '0'                        ; convert ASCII to digit (e.g., '5' to 5)
    imul eax, eax, 10                  ; multiply current result by 10
    add eax, ebx                       ; add new digit to result
    inc ecx                            ; move to next character
    jmp .next_char                     ; repeat

.done:
    ret                                ; return result in EAX

; ---------------------------------------------------
; Prints number in EAX to screen
print_int:
    mov ecx, 10                         ; base 10 for division
    xor ebx, ebx                        ; clear EBX (will store 0)
    push ebx                            ; push null as marker on stack

.next_digit:
    xor edx, edx                        ; clear remainder
    div ecx                             ; divide EAX by 10 → quotient in EAX, remainder in EDX
    add dl, '0'                         ; convert digit to ASCII
    push edx                            ; push ASCII digit onto stack
    test eax, eax                       ; check if quotient is 0
    jnz .next_digit                     ; repeat if not 0

.print_digits:
    pop eax                             ; pop ASCII digit into EAX
    test eax, eax                       ; check if null (end)
    jz .done
    mov [buffer], al                    ; move digit into buffer
    mov eax, 4                          ; syscall: write
    mov ebx, 1                          ; file descriptor: stdout
    mov ecx, buffer                     ; pointer to digit
    mov edx, 1                          ; one byte to write
    int 0x80                            ; print digit
    jmp .print_digits                   ; repeat for next digit

.done:
    ret                                 ; return to caller

; ---------------------------------------------------
; Prints a newline character
print_newline:
    mov eax, 4                          ; syscall: write
    mov ebx, 1                          ; stdout
    mov ecx, newline                    ; address of newline character
    mov edx, 1                          ; one byte
    int 0x80                            ; print newline
    ret                                 ; return