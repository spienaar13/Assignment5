/*--------------------------------------------------------------------*/
/* stresslinelimit.c                                                  */
/* Author: Charles Coppieters and Stephane Pienaar                    */
/*--------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>

/* counts the number of new lines currently printed to std out */
int newLineCounter = 0;
/* the maximum amount of newlines allowed by the stress test */
const int newLineLimit = 1000;

/* prints x and a newline to stdout until 5000 newlines
   have been printed. Returns 0 upon completion */
int main(void) {
   while(newLineCounter <= newLineLimit) {
      putchar('x');
      putchar('\n');
      newLineCounter++;
   }
   return 0;
}
