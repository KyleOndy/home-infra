/* myinit.c
 * Build instructions:
 * ${CROSS_COMPILE}gcc -static init.c -o init
 * */

#include <stdlib.h>
#include <stdio.h>

int
main ()
{
    printf ("\n");
    printf ("Hello world from %s!\n", __FILE__);
    system("/nomad agent -dev >/var/log/nomad.log 2>/var/log/nomad.err&&");
    system("/busybox ash");
    while (1) { }
    return 0;
}
