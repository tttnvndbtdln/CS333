#ifdef CS333_P2
#include "types.h"
#include "user.h"
#include "uproc.h"

int
main(void)
{
  int num = 0;
  int MAX = 72;
  int sec, mili, cpu_sec, cpu_mili;
  struct uproc *table;

  table = (struct uproc*)malloc(sizeof(struct uproc) * MAX);

  num = getprocs(MAX, table);

  if (num == -1)
    printf(2, "Error. ps Test failed.\n");
  else
    printf(2, "Number of entries: %d\n\n", num);

  printf(2, "PID\t Name\t UID\t GID\t PPID\t Elapsed\t CPU\t State\t\t Size\n"); 
  
  for(int i = 0; i<num; i++)
  {
    sec = table[i].elapsed_ticks / 1000;
    mili = table[i].elapsed_ticks % 1000;

    cpu_sec = table[i].CPU_total_ticks / 1000;
    cpu_mili = table[i].CPU_total_ticks % 1000;

    printf(2, "%d\t %s\t %d\t %d\t %d\t %d.%d\t\t %d.%d\t %s\t  %d\n", table[i].pid, table[i].name, table[i].uid, table[i].gid, table[i].ppid, sec, mili, cpu_sec, cpu_mili, table[i].state, table[i].size);
  }

  free(table);
  
  exit();
}
#endif
