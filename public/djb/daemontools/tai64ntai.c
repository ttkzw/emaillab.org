/* tai64ntai.c
 * Copyright 1999
 * D. J. Bernstein, djb@pobox.com
 * TAKIZAWA Takashi, taki@cyber.email.ne.jp
 *
 * This program converts TAI64N timestamps to TAI.
 * And it is originally tai64nlocal.c from DJB's daemontools-0.61 package. 
 * To make this program, unpack the daemontools package and compile the 
 * DJB's libraries:
 *   $ gzip -dc daemontools-0.61.tar.gz | tar xvf -
 *   $ cd daemontools-0.61
 *   $ make
 * Copy tai64nlocal.c to the daemontools source directory and compile it:
 *   $ cp downloadpath/tai64nlocal.c .
 *   $ ./compile tai64ntai.c
 *   $ ./load tai64ntai substdio.a error.a str.a fs.a
 * As root, install it.
 *   # cp tai64ntai /usr/local/bin/
 */
#include <sys/types.h>
#include "substdio.h"
#include "subfd.h"
#include "exit.h"
#include "fmt.h"

char num[FMT_ULONG];

void get(ch)
char *ch;
{
  int r;

  r = substdio_get(subfdin,ch,1);
  if (r == 1) return;
  if (r == 0) _exit(0);
  _exit(111);
}

void out(buf,len)
char *buf;
int len;
{
  if (substdio_put(subfdout,buf,len) == -1)
    _exit(111);
}

time_t secs;
unsigned long microsecs;
unsigned long nanosecs;
unsigned long u;

main()
{
  char ch;

  for (;;) {
    get(&ch);
    if (ch == '@') {
      secs = 0;
      nanosecs = 0;
      for (;;) {
        get(&ch);
        u = ch - '0';
        if (u >= 10) {
          u = ch - 'a';
          if (u >= 6) break;
          u += 10;
        }
        secs <<= 4;
        secs += nanosecs >> 28;
        nanosecs &= 0xfffffff;
        nanosecs <<= 4;
        nanosecs += u;
      }
      secs -= 4611686018427387914ULL;
      microsecs = nanosecs / 1000UL;
      out(num,fmt_uint(num,(unsigned int) secs,10));
      out(".",1);
      out(num,fmt_uint0(num,(unsigned int) microsecs,6));
    }
    for (;;) {
      out(&ch,1);
      if (ch == '\n') break;
      get(&ch);
    }
  }
}
