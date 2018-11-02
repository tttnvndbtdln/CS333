#ifdef CS333_P2
#include "types.h"
#include "user.h"
int
main(int argc, char * argv[])
{
  int start_time = 0;
  int end_time = 0;
  int sec, mili, num;

  start_time = uptime();

  if(argc == 1)
  {
    printf(2, "Ran in 0.00 seconds.\n\n");
    exit();
  }

  num = fork();
  
  if (num)
    wait();

  else
  {
    if(exec(argv[1], argv+1) == 0)
    {
      printf(2, "Error. Test failed.\n");
      exit();
    }
  }

  end_time = uptime() - start_time;
  
  sec = end_time / 1000;
  mili = end_time % 1000;

  printf(2, "%s ran in %d.%d seconds.\n\n", argv[1], sec, mili);

  exit();
}

#endif

