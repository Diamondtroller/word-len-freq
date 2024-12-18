.386
.model flat, stdcall
option casemap:none

include     \masm32\include\windows.inc
include     \masm32\include\kernel32.inc
includelib  \masm32\lib\kernel32.lib

.stack   4096

.const
delims   byte " .,!",13,10
IFDEF  EN
labels   byte 13,10,"Length     | Amount   ",13,10
prompt   byte "Enter path to the file: "
fail     byte "Faild to read the file!",13,10
ELSE
labels   byte 13,10,"Garums     | Daudzums ",13,10
prompt   byte "Ievadi celu uz nolasamo datni: "
fail     byte "Neizdevas nolasit datni!",13,10
ENDIF

countslen equ 64
numlen   equ 10
fnlen    equ 128

.data
counts   dword countslen dup (0)
numstr   byte numlen dup(' ')," | ",numlen dup(' '),13,10

num1e    equ  numstr+numlen-1
num2s    equ  num1e+3
num2e    equ  num2s+numlen

buflen   equ 4096

.data?
hIn      HANDLE ?
hOut     HANDLE ?
hFile    HANDLE ?
rBytes   dword  ?
wBytes   dword  ?
filename byte   fnlen dup (?)
buffer   byte   buflen dup (?)

.code
NumtoStr proc near  bufstart, bufend
        mov  ebx, 10
        mov  edi, bufend
dodiv:  xor  edx, edx
        div  ebx
        add  dl, '0'
        mov  [edi], dl
        dec  edi
        cmp  edi, bufstart ; used entire buffer
        je   mend
        cmp  eax, 0 ; stop dividing
        jne  dodiv

fill:   mov  [edi], byte ptr ' '
        dec  edi
        cmp  edi, bufstart 
        jge  fill
mend:
        ret
NumtoStr endp

start   proc
; Handles for console buffer output and text file input
        invoke GetStdHandle, STD_INPUT_HANDLE
        mov hIn, eax

        invoke GetStdHandle, STD_OUTPUT_HANDLE
        mov hOut, eax

        invoke WriteFile, hOut, addr prompt, lengthof prompt, addr wBytes, NULL
        invoke ReadFile, hIn, addr filename, fnlen, addr rBytes, NULL
        mov ebx, rBytes
        mov filename[ebx-1], byte ptr 0
        cmp filename[ebx-2], 13
        jne  letter
        mov filename[ebx-2], byte ptr 0
letter:
        invoke WriteFile, hOut, addr labels, 2, addr wBytes, NULL ; newline
        invoke CreateFileA, addr filename, GENERIC_READ, NULL, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL OR FILE_FLAG_NO_BUFFERING,NULL
        cmp eax, -1
        jne exists
        invoke WriteFile, hOut, addr fail, lengthof fail, addr wBytes, NULL
        jmp pend
exists: mov hFile, eax

        push es
        push ds
        pop  es

        push 0 ; edx init value of cur word length
read:   invoke ReadFile, hFile, addr buffer, buflen, addr rBytes, NULL
        cmp rBytes, 0
        je done 

;;;;;;;;;; Counting ;;;;;;;;;;
; Check if the character is a delimter,
; if it, is increment the entry in 
;  word frequency array

; al  letter val
; ebx letter ptr
; ecx string length,
; edx word length
; edi delim ptr
        mov  ecx, rBytes
        mov  ebx, offset buffer
        pop  edx
wordscan:
        mov  al, [ebx]
        push ecx

;;;;;;;;;;; delim_scan
        mov  ecx, lengthof delims
        mov  edi, offset delims
        cld
        repne scasb
        je   save
;;;;;;;;;;; delim_scan

        add  edx, type counts ; is a letter, increment letter count
        jmp  skipsave
save:
        inc  counts[edx]
        xor  edx, edx
skipsave:
        pop  ecx
        inc  ebx
        loop wordscan
        push edx
;;;;;;;;;;; wordscan end
;;;;;;;;;; Counting ;;;;;;;;;;

        invoke WriteFile, hOut, addr buffer, rBytes, addr wBytes, NULL
        mov eax, rBytes
        cmp eax, wBytes
        jne done

        jmp read
done:   
        pop  edx
        inc  counts[edx]
        pop es

        ;;; Table printing
        invoke WriteFile, hOut, addr labels, lengthof labels, addr wBytes, NULL

        mov ecx, countslen-1
        mov esi, 1
entry:  
        mov eax, counts[esi*type counts]
        cmp eax, 0
        jz  skip
        invoke NumtoStr, offset num2s, offset num2e
        mov eax, esi
        invoke NumtoStr, offset numstr, offset num1e
        
        mov edi, ecx
        invoke WriteFile, hOut, addr numstr, numlen+3+numlen+2, addr wBytes, NULL
        mov ecx, edi
skip:
        inc esi
        loop entry

        invoke CloseHandle, hFile
pend:   
        invoke CloseHandle, hOut 
        invoke CloseHandle, hIn 

        invoke ExitProcess, 0
start   endp
        end start
