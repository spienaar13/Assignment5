/*--------------------------------------------------------------------*/
/* mywcflat.c                                                         */
/* Author: Stephane Pienaar                                           */
/*--------------------------------------------------------------------*/

#include <stdio.h>
#include <ctype.h>

/*--------------------------------------------------------------------*/

/* In lieu of a boolean data type. */
enum {FALSE, TRUE};

/*--------------------------------------------------------------------*/

static long lLineCount = 0;      /* Bad style. */
static long lWordCount = 0;      /* Bad style. */
static long lCharCount = 0;      /* Bad style. */
static int iChar;                /* Bad style. */
static int iInWord = FALSE;      /* Bad style. */

/*--------------------------------------------------------------------*/

/* Write to stdout counts of how many lines, words, and characters
   are in stdin. A word is a sequence of non-whitespace characters.
   Whitespace is defined by the isspace() function. Return 0. */

int main(void)
{
iChar = getchar();
fileLoop:
    if (iChar == EOF) goto fileLoopEnd;

    lCharCount++;

    if (!isspace(iChar)) goto else1;
    if(!iInWord) goto if2;
    lWordCount++;
    iInWord = FALSE;
    goto if2;
else1:
    if (iInWord) goto if2;
    iInWord = TRUE;
if2:
    if (iChar != '\n') goto endif2;
    lLineCount++;
endif2:
    iChar = getchar();
    goto fileLoop;
fileLoopEnd:
   if (!iInWord) goto endFile;
   lWordCount++;
endFile:
   printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);
   return 0;
}
