#ifdef CS333_P5
#include "types.h"
#include "user.h"
int
main(int argc, char * argv[])
{
  int mode;
  int rc;

  if(argc != 3)
  {
    printf(2, "\nIncorrect number of arguments.\n");
    exit();
  }
  if(strlen(argv[1]) != 4)
  {
    printf(2, "\nIncorrect mode.\n");
    exit();
  }

  mode = atoi(argv[1]);

  rc = chmod(argv[2], mode);
  if(rc != 0)
  {
    printf(2, "\nChange mode failed.\n");
    exit();
  }   
  else
  {
    printf(2, "\nMode changed.\n");
    exit();
  }
}

#endif
