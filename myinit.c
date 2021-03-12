#include <stdlib.h>
#include <stdio.h>

int
main ()
{
    //printf ("\n");
    //printf ("Hello world from %s!\n", __FILE__);
    // https://unix.stackexchange.com/a/52744
    system("mount -t devtmpfs none /dev");
    system("/nomad agent -dev >/var/log/nomad.log 2>/var/log/nomad.err&&");
    system("/busybox ash");
    while (1) { }
    return 0;
}
