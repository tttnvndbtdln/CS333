#ifdef CS333_P5
#include "types.h"
#include "user.h"
int
main(int argc, char * argv[])
{
  int uid;
  int rc;

  if(argc != 3)
  {
    printf(2, "\nIncorrect number of arguments.\n");
    exit();
  } 
  
  uid = atoi(argv[1]);

  rc = chown(argv[2], uid);
  if(rc != 0)
  {
    printf(2, "\nChange UID failed.\n");
    exit();
  }
  else
  {
    printf(2, "\nUID changed.\n");
    exit();
  }
}

#endif
