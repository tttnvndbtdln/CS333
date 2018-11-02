#include "types.h"
#include "user.h"
#include "param.h"

int main(void)
{
  int pid;
  int priority = 0;
  for(int i = 0; i < 11; ++i)
  {
    pid = fork();
    if(!pid)
      for(;;);
  }
  
  if(pid)
  {
    sleep(1000);
    for(;;)
    {
      sleep(10000);
      printf(1, "Setting PID 4 to priority %d.\n", priority);
      if(setpriority(4, priority))
        printf(1, "Error setting PID 4 to priority %d.\n", priority);
      ++priority;
      
    }
  }
  exit();
}
