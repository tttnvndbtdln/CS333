#include "types.h"
#include "user.h"

int main(void)
{ 
  int pid;
  
  for(int i = 0; i < 20; ++i)
  {
    pid = fork();
    if(!pid)
      for(;;);
  }

  if(pid)
  {
    for(int i = 0; i < 20; ++i)
      wait();
  }

  exit();
}
