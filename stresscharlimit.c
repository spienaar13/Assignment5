/*--------------------------------------------------------------------*/
/* stresscharlimit.c                                                  */
/* Author: Charles Coppieters and Stephane Pienaar                    */
/*--------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>

/* counts the number of chars printed to stdout currently */
int charCounter = 0;
/* the max amount of chars allowed by the stress test*/
int charLimit = 5000;

/* prints x to stdout 5000 times and returns 0 upon completion */
int main(void) {
   while(charCounter <= charLimit) {
      putchar('x');
      charCounter++;
   }
   return 0;
}
