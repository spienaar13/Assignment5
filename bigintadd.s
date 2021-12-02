//----------------------------------------------------------------------
// bigintadd.s
// Author: Charles Coppieters 't wallant and Stephane Pienaar
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
        // Return the larger of 1Length1 and 1Length2.
        //--------------------------------------------------------------

        // Must be a multiple of 16
        .equ BIGINT_LARGER_STACK_BYTECOUNT, 32

        // Local variable stack offsets:
        .equ    LLARGER, 8

        // Parameter stack offsets:
        .equ    LLENGTH1, 16
        .equ    LLENGTH2, 24

BigInt_larger:

        // Prolog
        sub    sp, sp, BIGINT_LARGER_STACK_BYTECOUNT
        str    x30, [sp]

        // long lLarger

        // if (lLength1 <= lLength2) goto else1;
        str    x0, [sp, LLENGTH1]       // store function parameter in stack
        str    x1, [sp, LLENGTH2]       // store function parameter in stack
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
        ldr    x0, [sp, LLARGER]
        ldr    x30, [sp]
        add    sp, sp, BIGINT_LARGER_STACK_BYTECOUNT
        ret

        .size BigInt_larger, (. - BigInt_larger)

        //--------------------------------------------------------------
        // Assign the sum of oAddend1 and oAddend2 to oSum. oSum should
        // be distinct from oAddend1 and oAddend2. Return 0 (FALSE) if
        // an overflow occurred, and 1 (TRUE) otherwise
        //--------------------------------------------------------------

        // Must be a multiple of 16
            .equ BIGINT_ADD_STACK_BYTECOUNT, 64

        // Local variable stack offsets:
            .equ ulCarry, 8
            .equ ulSum, 16
            .equ lIndex, 24
            .equ lSumLength, 32

        // Parameter stack offsets
            .equ oAddend1, 40
            .equ oAddend2, 48
            .equ oSum, 56
            
            .global BigInt_add

BigInt_add:

        // Prolog
        sub    sp, sp, BIGINT_ADD_STACK_BYTECOUNT
        str    x30, [sp]
        str     x0, [sp, oAddend1]
        str     x1, [sp, oAddend2]
        str     x2, [sp, oSum]

        // unsigned long ulCarry;
        // unsigned long u1Sum;
        // long lIndex;
        // long lSumLength;

        // lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength);
        ldr    x0, [sp, oAddend1]
        ldr    x0, [x0]
        ldr    x1, [sp, oAddend2]
        ldr    x1, [x1]
        bl     BigInt_larger
        str    x0, [sp, lSumLength]

        // if (oSum->lLength <= lSumLength) goto endif2;
        ldr    x0, [sp, oSum]
        ldr    x0, [x0]
        ldr    x1, [sp, lSumLength]
        cmp    x0, x1
        ble    endif2

        // memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));
        ldr    x0, [sp, oSum]
        add    x0, x0, AULDIGITS
        mov    x1, 0
        mov    x2, MAX_DIGITS
        mov    x3, SIZEOFULONG
        mul    x2, x2, x3
        bl    memset

endif2:
        // ulCarry = 0;
        str xzr, [sp, ulCarry]

        // lIndex = 0;
        str xzr, [sp, lIndex]

Loop1:
        // if(lIndex >= lSumLength) goto endLoop1;
        ldr    x0, [sp, lIndex]
        ldr    x1, [sp, lSumLength]
        cmp    x0, x1
        bge    endLoop1
    
        // ulSum = ulCarry;
        ldr x0, [sp, ulCarry]
        str x0, [sp, ulSum]

        // ulCarry = 0;
        str xzr, [sp, ulCarry]

        // ulSum += oAddend1->aulDigits[lIndex];
        ldr x0, [sp, oAddend1]
        add x0, x0, AULDIGITS
        ldr x1, [sp, lIndex]
        ldr x0, [x0, x1, lsl 3]
        ldr x2, [sp, ulSum]
        add x2, x2, x0
        str x2, [sp, ulSum]
        

        // if (ulSum >= oAddend1->aulDigits[lIndex]) goto if3;
        ldr    x2, [sp, ulSum]
        ldr    x0, [sp, oAddend1]
        add    x0, x0, AULDIGITS
        ldr    x1, [sp, lIndex]
        ldr    x0, [x0, x1, lsl 3]
        cmp    x2, x0
        bhs    if3

        // ulCarry = 1;
        mov x0, 1
        str x0, [sp, ulCarry]
if3:
        // ulSum += oAddend2->aulDigits[lIndex];
        ldr x0, [sp, oAddend2]
        add x0, x0, AULDIGITS
        ldr x1, [sp, lIndex]
        ldr x0, [x0, x1, lsl 3]
        ldr x2, [sp, ulSum]
        add x2, x2, x0
        str x2, [sp, ulSum]
        
        // if (ulSum >= oAddend2->aulDigits[lIndex]) goto if4;
        ldr    x2, [sp, ulSum]
        ldr    x0, [sp, oAddend2]
        add    x0, x0, AULDIGITS
        ldr    x1, [sp, lIndex]
        ldr    x0, [x0, x1, lsl 3]
        cmp    x2, x0
        bhs    if4
        
        // ulCarry = 1;
        mov x0, 1
        str x0, [sp, ulCarry]
if4:
        // oSum->aulDigits[lIndex] = ulSum;
        ldr x0, [sp, oSum]
        add x0, x0, AULDIGITS
        ldr x2, [sp, ulSum]
        ldr x1, [sp, lIndex]
        str x2, [x0,x1, lsl 3]
        
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
        ldr x0, [sp, oSum]
        add x0, x0, AULDIGITS
        mov x2, 1
        ldr x1, [sp, lSumLength]
        str x2, [x0, x1, lsl 3]

        // lSumLength++;
        ldr x0, [sp, lSumLength]
        add x0, x0, 1
        str x0, [sp, lSumLength]
if5:
        // oSum->lLength = lSumLength;
        ldr x0, [sp, lSumLength]
        ldr x1, [sp, oSum]
        str x0, [x1]
        
        // Epilog and return TRUE;
        mov w0, TRUE
        ldr x30, [sp]
        add    sp, sp, BIGINT_ADD_STACK_BYTECOUNT
        ret

        .size BigInt_add, (. - BigInt_add)
