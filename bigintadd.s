//----------------------------------------------------------------------
// bigintadd.s
// Author: Charles Coppieters 't wallant
//----------------------------------------------------------------------

        .equ FALSE, 0
        .equ TRUE, 1
        .equ MAX_DIGITS, 32768
        .equ SIZEOFULONG, 8

//----------------------------------------------------------------------        
        
        .section .rodata

//----------------------------------------------------------------------

        .section .data

//----------------------------------------------------------------------

        .section .bss

//----------------------------------------------------------------------

        .section .text

        
        //--------------------------------------------------------------
        // Return the larger of 1Length1 and 1Length2.
        //--------------------------------------------------------------

        // Must be a multiple of 16
        .equ BIGINT_LARGER_STACK_BYTECOUNT, 32

        // Local variable stack offsets:
        .equ    LLARGER, 8

        // Parameter stack offsets:
        .equ    LLENGTH1, 16
        .equ    LLENGTH2, 24

bigint_larger:

        // Prolog
        sub    sp, sp, BIGINT_LARGER_STACK_BYTECOUNT
        str    x30, [sp]

        // long lLarger

        // if (lLength1 <= lLength2) goto else1;
        ldr    x0, [sp, LLENGTH1]
        ldr    x1, [sp, LLENGTH2]
        cmp    x0, x1
        ble    else1

        // lLarger = lLength1;
        ldr    x0, [sp, LLENGTH1]
        str    x0, [sp, LLARGER]

        // goto endif1;
        b    endif1

else1:
        // lLarger = lLength2;
        ldr    x0, [sp, LLENGTH2]
        str    x0, [sp, LLARGER]

endif1:
        // Epilog and return llarger
        ldr    x30, [sp, LLARGER]
        add    sp, sp, BIGINT_LARGER_STACK_BYTECOUNT
        ret

        .size bigint_larger, (. - bigint_larger)

        //--------------------------------------------------------------
        // Assign the sum of oAddend1 and oAddend2 to oSum. oSum should
        // be distinct from oAddend1 and oAddend2. Return 0 (FALSE) if
        // an overflow occurred, and 1 (TRUE) otherwise
        //--------------------------------------------------------------

        // Must be a multiple of 16
            .equ BIGINT_ADD_STACK_BYTECOUNT, 64

        // Local variable stack offsets:
            .equ ulCarry, 8
            .equ u1Sum, 16
            .equ lIndex, 24
            .equ lSumLength, 32

        // Parameter stack offsets
            .equ oAddend1, 40
            .equ oAddend2, 48
            .equ oSum, 56

bigint_add:

        // Prolog
        sub    sp, sp, BIGINT_ADD_STACK_BYTECOUNT
        str    x30, [sp]

        // unsigned long ulCarry;
        // unsigned long u1Sum;
        // long lIndex;
        // long lSumLength;

        // lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength);
        ldr    x0, [sp, oAddend1]
        ldr    x1, [sp, oAddend2]
        bl     BigInt_larger
        str    x0, [sp, lSumLength]

        // if (oSum->lLength <= lSumLength) goto endif2;
        ldr    x0, [sp, oSum]
        ldr    x1, [sp, lSumLength]
        cmp    x0, x1
        ble    endif2

        // memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));
        ldr    x0, [sp, oSum]
        add    x0, x0, 8
        mov    x1, 0
        mov    x2, MAX_DIGITS
        ldr    x3, SIZEOFULONG
        mul    x2, x2, x3
        bl    memset

endif2:
        // ulCarry = 0;
        str xzr, [sp, ulCarry]

        // lIndex = 0;
        str xzr, [sp, lIndex]

        // goto Loop1;
        b Loop1

Loop1:
        // if(lIndex >= lSumLength) goto endLoop1;
        ldr    x0, [sp, lIndex]
        ldr    x1, [sp, lSumLength]
        cmp    x0, x1
        bge    endLoop1
    
        // ulSum = ulCarry;
        ldr x0, [sp, ulCarry]
        str x0, [sp, ulCarry]

        // ulCarry = 0;
        str xzr, [sp, ulCarry]

        // ulSum += oAddend1->aulDigits[lIndex];

        // if (ulSum >= oAddend1->aulDigits[lIndex]) goto if3;
        ldr    x0, [sp, ulSum]
        ldr    x1, [sp, oAddend1]
        add    x1, x1, 8
        ldr    x3, [sp, lIndex]
        mov    x2, x3
        ldr    x1, [x1, x2, lsl 3]
        cmp    x0, x1
        bge    if3

        // ulCarry = 1;
        mov x0, 1
        str x0, [sp, ulCarry]
if3:
        // ulSum += oAddend2->aulDigits[lIndex];
        // if (ulSum >= oAddend2->aulDigits[lIndex]) goto if4;/* Check for overflow. */
        
        // ulCarry = 1;
        mov x0, 1
        str x0, [sp, ulCarry]
if4:
        // oSum->aulDigits[lIndex] = ulSum;
        ldr x0, [sp, oSum]
        add x0, x0, 8
        ldr x3, [sp, ulSum]
        ldr x1, [sp, lIndex]
        str x3, [x0,x1, lsl 3]
        
        // lIndex++;
        ldr x0, [sp, lIndex]
        add x0, x0, 1
        str x0, [sp, lIndex]

        // goto Loop1;
        b Loop1

endLoop1:
        // if (ulCarry != 1) goto if5;
        ldr x0, [sp, ulCarry]
        cmp x0, 1
        bne if5
        
        // if (lSumLength != MAX_DIGITS) goto endif5;
        ldr x0, [sp, lSumLength]
        cmp x0, MAX_DIGITS
        bne endif5

        // Epilog and return FALSE;
        mov w0, FALSE 
        ldr x30, [sp]
        add sp, sp, BIGINT_ADD_STACK_BYTECOUNT
        ret
        
endif5:
        // oSum->aulDigits[lSumLength] = 1;
        ldr    x0, [sp, oSum]
        add    x0, x0, 8
        mov    x1, 2
        ldr    x2, [sp, lSumLength]
        ldr    x0, [x0, x1, lsl x2]
        mov    x1, 1
        str    x1, x0

        // lSumLength++;
        ldr x0, [sp, lSumLength]
        add x0, x0, 1
        str x0, [sp, lSumLength]
if5:
        // oSum->lLength = lSumLength;
        ldr x0, [sp, lSumLength]
        str x0, [sp, oSum]
        
        // Epilog and return TRUE;
        mov w0, TRUE 
        ldr x30, [sp]
        add    sp, sp, BIGINT_ADD_STACK_BYTECOUNT
        ret

        .size bigint_add, (. - bigint_add)
