#ifdef CS333_P5
#include "types.h"
#include "user.h"
int
main(int argc, char * argv[])
{
  int gid;
  int rc;

  if(argc != 3)
  {
    printf(2, "\nIncorrect number of arguments.\n");
    exit();
  }

  gid = atoi(argv[1]);

  rc = chgrp(argv[2], gid);
  if(rc != 0)
  {
    printf(2, "\nChange GID failed.\n");
    exit();
  }
  else
  {
    printf(2, "\nGID changed.\n");
    exit();
  }
}

#endif
