#include "types.h"
#include "user.h"

int testuidgid(void);

int
main(int argc, char *argv[])
{
  int num = testuidgid();
  if (num == 1)
    printf(2, "Test failed.\n");
  else
    printf(2, "Test passed.\n");
  exit();
}

int
testuidgid(void)
{
  uint uid, gid, ppid;
  int i = 0;

  uid = getuid();
  printf(2, "Current UID is: %d\n", uid);
  printf(2, "Setting UID to 100\n");
  setuid(100);
  uid = getuid();
  if (uid == -1)
  {
    printf(2, "Invalid UID.\n");
    i = 1;
  }
  else
    printf(2, "Current UID is: %d\n", uid);

  gid = getgid();
  printf(2, "Current GID is: %d\n", gid);
  printf(2, "Setting GID to 100\n");
  setgid(100);
  gid = getgid();
  if (gid == -1)
  {
    printf(2, "Invalid GID.\n");
    i = 1;
  }
  else
    printf(2, "Current GID is: %d\n", gid);

  ppid = getppid();
  printf(2, "My parent's process is: %d\n", ppid);
  printf(2, "Done!\n");
  
  return i;
}
