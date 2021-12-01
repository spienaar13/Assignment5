/*--------------------------------------------------------------------*/
/* stressrandchars.c                                                  */
/* Author: Charles Coppieters and Stephane Pienaar                    */
/*--------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>

/* counts the amount of new lines currently added to stdout */
int newLineCounter = 0;
/* max number of new lines allowed for stress test */
const int newLineLimit = 1000;
/* counts the amount of new chars currently added to stdout */
int charCounter = 0;
/* max number of new chars allowed for stress test */
const int charLimit = 50000;

/* generates a pseudo-random integer using rand() and
   mods the integer to be in the ASCII range. If the
   integer equals either a newline, tab, or valid 
   numberic/alphabet/symbol, the char is printed to
   stdout and the the relevant counter is incremented */
void generateInt() {
   int n;
   int mod = 0x7f;
   n = rand();
   n = n % mod;
   if (n == 0x09) {
      putchar(n);
      charCounter++;
   }
   else if (n>0x20 && n<0x7E) {
      putchar(n);
      charCounter++;
   }
   else if (n == 0x0A) {
      putchar(n);
      charCounter++;
      newLineCounter++;
   }
}

/* calls generateInt() until either the character limit or newline
   limit is reached. Returns 0 upon completion */
int main(void) {
   while(charCounter <= charLimit && newLineCounter <= newLineLimit) {
      generateInt();
   }
   return 0;
}
