//----------------------------------------------------------------------
// bigintaddopt.s
// Author: Stephane Pienaar and Charles Coppieters 't wallant 
//----------------------------------------------------------------------

        .equ FALSE, 0
        .equ TRUE, 1
        .equ MAX_DIGITS, 32768
        .equ SIZEOFULONG, 8
        .equ AULDIGITS, 8

//----------------------------------------------------------------------

        .section .rodata

//----------------------------------------------------------------------

        .section .data

//----------------------------------------------------------------------

        .section .bss

//----------------------------------------------------------------------

        .section .text

        //--------------------------------------------------------------
        // Assign the sum of oAddend1 and oAddend2 to oSum. oSum should
        // be distinct from oAddend1 and oAddend2. Return 0 (FALSE) if
        // an overflow occurred, and 1 (TRUE) otherwise
        //--------------------------------------------------------------

        // Must be a multiple of 16
        .equ BIGINT_ADD_STACK_BYTECOUNT, 64

        // Local variable stack offsets:
        ULCARRY .req x25
        ULSUM   .req x24
        LINDEX  .req x23
        LSUMLENGTH      .req x22

        // Parameter stack offsets
        OADDEND1        .req x21
        OADDEND2        .req x20
        OSUM    .req x19

        .global BigInt_add

BigInt_add:

        // Prolog
        sub    sp, sp, BIGINT_ADD_STACK_BYTECOUNT
        str    x30, [sp]
        str x19, [sp, 8]
        str x20, [sp, 16]
        str x21, [sp, 24]
        str x22, [sp, 32]
        str x23, [sp, 40]
        str x24, [sp, 48]
        str x25, [sp, 56]

        // Saving callee saved registers to stack
        mov     OADDEND1, x0
        mov     OADDEND2, x1
        mov     OSUM, x2

        // unsigned long ulCarry;
        // unsigned long u1Sum;
        // long lIndex;
        // long lSumLength;

        // lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength) 
        // inlined:
        ldr x0, [OADDEND1]
        ldr x1, [OADDEND2]
        
        // if (lLength1 <= lLength2) goto if1
        cmp x0, x1
        ble if1

if1:
        mov LSUMLENGTH, x1
        b continue

else1:
        mov LSUMLENGTH, x0

continue:
        // if (oSum->lLength <= lSumLength) goto endif2;
        ldr x0, [OSUM]
        cmp x0, LSUMLENGTH
        ble endif2

        // memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));
        add     x0, OSUM, AULDIGITS
        mov    x1, 0
        mov    x2, MAX_DIGITS*SIZEOFULONG
        bl    memset

endif2:
        // ulCarry = 0;
        mov ULCARRY, xzr

        // lIndex = 0;
        mov LINDEX, xzr

        // if(lIndex >= lSumLength) goto endLoop1;
        cmp LINDEX, LSUMLENGTH
        bge endLoop1
Loop1:
        // ulSum = ulCarry;
        mov ULSUM, ULCARRY

        // ulCarry = 0;
        mov ULCARRY, xzr

        // ulSum += oAddend1->aulDigits[lIndex];
        add x0, OADDEND1, AULDIGITS
        ldr x0, [x0, LINDEX, lsl 3]
        add ULSUM, ULSUM, x0

        // if (ulSum >= oAddend1->aulDigits[lIndex]) goto if3;
        add x0, OADDEND1, AULDIGITS
        ldr x0, [x0, LINDEX, lsl 3]
        cmp ULSUM, x0
        bhs if3

        // ulCarry = 1;
        mov ULCARRY, 1

if3:
        // ulSum += oAddend2->aulDigits[lIndex];
        add x0, OADDEND2, AULDIGITS
        ldr x0, [x0, LINDEX, lsl 3]
        add ULSUM, ULSUM, x0

        // if (ulSum >= oAddend2->aulDigits[lIndex]) goto if4;
        add x0, OADDEND2, AULDIGITS
        ldr x0, [x0, LINDEX, lsl 3]
        cmp ULSUM, x0
        bhs if4

        // ulCarry = 1;
        mov ULCARRY, 1

if4:
        // oSum->aulDigits[lIndex] = ulSum;
        add x0, OSUM, AULDIGITS
        str ULSUM, [x0, LINDEX, lsl 3]

        // lIndex++;
        add LINDEX, LINDEX, 1

        // if(lIndex < lSumLength) goto Loop1;
        cmp LINDEX, LSUMLENGTH
        blt Loop1

endLoop1:
        // if (ulCarry != 1) goto if5;
        cmp ULCARRY, 1
        bne if5

        // if (lSumLength != MAX_DIGITS) goto endif5;
        cmp LSUMLENGTH, MAX_DIGITS
        bne endif5

        // Epilog and return FALSE;
        mov w0, FALSE
        ldr x30, [sp]
        ldr x19, [sp, 8]
        ldr x20, [sp, 16]
        ldr x21, [sp, 24]
        ldr x22, [sp, 32]
        ldr x23, [sp, 40]
        ldr x24, [sp, 48]
        ldr x25, [sp, 56]
        add sp, sp, BIGINT_ADD_STACK_BYTECOUNT
        ret

endif5:
        // oSum->aulDigits[lSumLength] = 1;
        add x0, OSUM, AULDIGITS
        mov x2, 1
        str x2, [x0, LSUMLENGTH, lsl 3]

        // lSumLength++;
        add LSUMLENGTH, LSUMLENGTH, 1
if5:
        // oSum->lLength = lSumLength;
        str LSUMLENGTH, [OSUM]

        // Epilog and return TRUE;
        mov w0, TRUE
        ldr x30, [sp]
        ldr x19, [sp, 8]
        ldr x20, [sp, 16]
        ldr x21, [sp, 24]
        ldr x22, [sp, 32]
        ldr x23, [sp, 40]
        ldr x24, [sp, 48]
        ldr x25, [sp, 56]
        add    sp, sp, BIGINT_ADD_STACK_BYTECOUNT
        ret

        .size BigInt_add, (. - BigInt_add)
        
