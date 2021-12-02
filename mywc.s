//----------------------------------------------------------------------
// mywc.s                                                             
// Author: Stephane Pienaar and Charles Coppieters 't wallant                                          
//----------------------------------------------------------------------

    .equ FALSE, 0
    .equ TRUE, 1

//----------------------------------------------------------------------

    .section .rodata

printfFormatStr:
    .string "%7ld %7ld %7ld\n"


//----------------------------------------------------------------------

    .section .data
lLineCount: .quad 0
lWordCount: .quad 0
lCharCount: .quad 0
iInWord: .word FALSE

//----------------------------------------------------------------------

    .section .bss
iChar: .skip 4

//----------------------------------------------------------------------

    .section .text

    //------------------------------------------------------------------
    // Write to stdout counts of how many lines, words, and characters
    // are in stdin. A word is a sequence of non-whitespace characters.
    // Whitespace is defined by the isspace() function. Return 0.
    //------------------------------------------------------------------

    // Must be a multiple of 16
    .equ MAIN_STACK_BYTECOUNT, 16
    .equ EOF, -1
    .equ newline, '\n'

    .global main 
 
main:
        // Prolog
        sub sp, sp, MAIN_STACK_BYTECOUNT
        str x30, [sp]

        // iChar = getchar();
        bl getchar
        adr x1, iChar
        str w0, [x1]


fileLoop:
        // if (iChar == EOF) goto fileLoopEnd
        adr x1, iChar
        ldr w0, [x1]
        cmp w0, EOF
        beq fileLoopEnd

        // lCharCount++;
        adr x0, lCharCount
        ldr x1, [x0]
        add x1, x1, 1
        str x1, [x0]

        // if (!isspace(iChar)) goto else1;
        adr x1, iChar
        ldr w0, [x1]
        bl isspace
        cmp w0, FALSE
        beq else1 

        // if(!iInWord) goto if2;
        adr x0, iInWord
        ldr w0, [x0]
        cmp w0, FALSE
        beq if2

        // lWordCount++;
        adr x0, lWordCount
        ldr x1, [x0]
        add x1, x1, 1
        str x1, [x0]

        // iInWord = FALSE;
        adr x0, iInWord
        mov w1, FALSE
        str w1, [x0] 

        // goto if2;
        b if2
else1:
        // if (iInWord) goto if2;
        adr x1, iInWord
        ldr w0, [x1]
        cmp w0, FALSE
        bne if2

        // iInWord = TRUE;
        adr x0, iInWord
        mov w1, TRUE
        str w1, [x0]

if2:
        // if (iChar != '\n') goto endif2;
        adr x0, iChar
        ldr w0, [x0]
        cmp w0, newline
        bne endif2

        // lLineCount++;
        adr x0, lLineCount
        ldr w1, [x0]
        add w1, w1, 1
        str w1, [x0]

endif2:
        // iChar = getchar();
        bl getchar
        adr x1, iChar
        str w0, [x1]

        // goto fileLoop;
        b fileLoop

fileLoopEnd:
        // if (!iInWord) goto endFile;
        adr x1, iInWord
        ldr w0, [x1]
        cmp w0, FALSE
        beq endFile

        // lWordCount++;
        adr x0, lWordCount
        ldr x1, [x0]
        add x1, x1, 1
        str x1, [x0]


endFile:
        // printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);
        adr x0, printfFormatStr
        adr x1, lLineCount
        ldr w1, [x1]
        adr x2, lWordCount
        ldr w2, [x2]
        adr x3, lCharCount
        ldr w3, [x3]
        bl printf

        // Epilog and return 0;   
        mov w0, 0
        ldr x30, [sp]
        add sp, sp, MAIN_STACK_BYTECOUNT
        ret

        .size main, (. - main)
