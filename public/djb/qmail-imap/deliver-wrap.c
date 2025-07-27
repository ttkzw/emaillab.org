#include <stdlib.h>
#include <unistd.h>
#define DELIVER "/usr/cyrus/bin/deliver"

void main(void) {
  char *user, *ext;

  user = getenv("USER");
  ext = getenv("EXT");

  if( ext == '\0'){
    execl(DELIVER, DELIVER, "-a", user, user, NULL);
  }else{
    execl(DELIVER, DELIVER, "-m", ext, "-a", user, user, NULL);
  }
}


