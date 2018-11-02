#ifdef CS333_P3P4
#include "types.h"
#include "user.h"
#include "param.h"

int main(int argc, char * argv[])
{
  if(argv[1] == 0)
  {
    printf(2, "Incorrect argument.");
    exit();
  }
  if(argv[2] == 0)
  {
    printf(2, "Incorrect argument.");
    exit();
  }
  
  int pid = atoi(argv[1]);
  int priority = atoi(argv[2]);
  int rc;

  if(pid < 0)
  {
    printf(2, "Incorrect PID.");
    exit();
  }
  if(priority < 0 || priority > (MAX+1))
  {
    printf(2, "Incorrect priority.");
    exit();
  }

  rc = setpriority(pid, priority);
  if(rc == -1)
  {
    printf(2, "Error setting priority.");
    exit();
  }

  exit();
}

#endif
