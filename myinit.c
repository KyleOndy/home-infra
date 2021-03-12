/* myinit.c
 * Build instructions:
 * ${CROSS_COMPILE}gcc -static init.c -o init
 * */

#include <stdio.h>

int
main ()
{
    printf ("\n");
    printf ("Hello world from %s!\n", __FILE__);
    while (1) { }
    return 0;
}
