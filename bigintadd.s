//----------------------------------------------------------------------
// bigintadd.s
// Author: Charles Coppieters 't wallant
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
        beq    else1

        // lLarger = lLength1;
        ldr    x0, [sp, LLENGTH1]
        str    x0, [sp, LLARGER]

        // goto endif1;
        b    endif1

else1:
        // lLarger = lLength2;
        ldr    x0, [sp, LLENGTH2]
        str    x0, [sp, LLARGER]

        // goto endif1;
        b    endif1

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
            .equ BIGINT_ADD_STACK_BYTECOUNT, 16

bigint_add:

        // Prolog
        sub    sp, sp, BIGINT_ADD_STACK_BYTECOUNT
        str    x30, [sp]

        // unsigned long ulCarry;
        // unsigned long u1Sum;

        // Epilog and Return
        ldr    x30, [sp]
        add    sp, sp, BIGINT_ADD_STACK_BYTECOUNT
        ret

        .size bigint_add, (. - bigint_add)
