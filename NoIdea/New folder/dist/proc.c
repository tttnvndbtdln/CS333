#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "x86.h"
#include "proc.h"
#include "spinlock.h"
#include "uproc.h"

#ifdef CS333_P3P4
struct StateLists {
  struct proc* ready[MAX+1];
  struct proc* free;
  struct proc* sleep;
  struct proc* zombie;
  struct proc* running;
  struct proc* embryo;
};
#endif

struct {
  struct spinlock lock;
  struct proc proc[NPROC];

#ifdef CS333_P3P4
  struct StateLists pLists;
  uint PromoteAtTime;
#endif

} ptable;

static struct proc *initproc;

int nextpid = 1;
extern void forkret(void);
extern void trapret(void);

static void wakeup1(void *chan);

#ifdef CS333_P3P4
static int
removeFromStateList(struct proc** sList, struct proc* p);

static void
assertState(struct proc* p, enum procstate state);

static int
addToStateListEnd(struct proc** sList, struct proc* p);

static int
addToStateListHead(struct proc** sList, struct proc* p);

static void
promoteAll();
#endif

void
pinit(void)
{
  initlock(&ptable.lock, "ptable");
}

// Look in the process table for an UNUSED proc.
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
  struct proc *p;
  char *sp;
  int rc;

  acquire(&ptable.lock);

#ifdef CS333_P3P4
  //If there's nothing in the list
  if(ptable.pLists.free == 0)
  {
    release(&ptable.lock);
    return 0;
  }

  //Set p to the first item in the free list
  p = ptable.pLists.free;

  goto found;

#else
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
  
  release(&ptable.lock);
  return 0;

#endif

found:
#ifdef CS333_P3P4
  assertState(p, UNUSED); //Check if p's state was really free
  
  //Free list now points to the next process after p
  //Effectively removing p from free list

  rc = removeFromStateList(&ptable.pLists.free, p);
  if(rc == -1)
    panic("Could not remove from free list.");
  p->state = EMBRYO;
  rc = addToStateListHead(&ptable.pLists.embryo, p);
  if(rc == -1)
    panic("Could not add process to embryo.");
  assertState(p, EMBRYO);
  p->pid = nextpid++;
#endif

  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    acquire(&ptable.lock);
#ifdef CS333_P3P4
    assertState(p, EMBRYO);
    rc = removeFromStateList(&ptable.pLists.embryo, p);
    if(rc == -1)
      panic("Could not remove from embryo list.");
#endif
    p->state = UNUSED;
#ifdef CS333_P3P4
    rc = addToStateListHead(&ptable.pLists.free, p);
    if(rc == -1)
      panic("Could not add to free list.");
#endif
    release(&ptable.lock);
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
  p->tf = (struct trapframe*)sp;
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
  p->context->eip = (uint)forkret;

#ifdef CS333_P1
  p->start_ticks = ticks;
#endif

#ifdef CS333_P2
  p->uid = DEFAULT_UID;
  p->gid = DEFAULT_GID;
  p->cpu_ticks_total = 0;
  p->cpu_ticks_in = 0;
#endif

#ifdef CS333_P3P4
  acquire(&ptable.lock);
  p->budget = BUDGET;
  p->priority = 0;
  release(&ptable.lock);
#endif

  return p;
}

// Set up first user process.
void
userinit(void)
{
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  int rc;

#ifdef CS333_P3P4
  acquire(&ptable.lock);

  ptable.PromoteAtTime = ticks + TICKS_TO_PROMOTE;
  //Initialize all 6 lists
  for(int i = 0; i < MAX; i++) //Set multi queue for MLFQ
    ptable.pLists.ready[i] = 0;
  ptable.pLists.free = 0;
  ptable.pLists.sleep = 0;
  ptable.pLists.zombie = 0;
  ptable.pLists.running = 0;
  ptable.pLists.embryo = 0;

  //Storing all 64 processes into the free list
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) 
  {
    rc = addToStateListHead(&ptable.pLists.free, p);
    if(rc == -1)
      panic("Could not add to free list.");
  }
  //All processes should be on the free list
  //ptable array is "still there" but processes will be managed by lists

  release(&ptable.lock);

#endif  

  p = allocproc();
  initproc = p;
  if((p->pgdir = setupkvm()) == 0)
    panic("userinit: out of memory?");
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
  p->sz = PGSIZE;
  memset(p->tf, 0, sizeof(*p->tf));
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
  p->tf->es = p->tf->ds;
  p->tf->ss = p->tf->ds;
  p->tf->eflags = FL_IF;
  p->tf->esp = PGSIZE;
  p->tf->eip = 0;  // beginning of initcode.S

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");
  
#ifdef CS333_P2
  p->uid = DEFAULT_UID;
  p->gid = DEFAULT_GID;
  p->parent = p;
#endif

#ifdef CS333_P3P4
  //After p becomes runnable, it needs to be put on the ready list
  acquire(&ptable.lock);

  p->budget = BUDGET;
  p->priority = 0;

  rc = removeFromStateList(&ptable.pLists.embryo, p);
  if(rc == -1)
    panic("Could not remove process from embryo list");
  assertState(p, EMBRYO);

  p->state = RUNNABLE;

  rc = addToStateListHead(&ptable.pLists.ready[0], p);
  if(rc == -1)
    panic("Could not add process to free list.");

  release(&ptable.lock);
#endif

}

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint sz;
  
  sz = proc->sz;
  if(n > 0){
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
      return -1;
  } else if(n < 0){
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
      return -1;
  }
  proc->sz = sz;
  switchuvm(proc);
  return 0;
}

// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
  int i, pid;
  struct proc *np;
#ifdef CS333_P3P4
  //struct proc *p;
  int rc;
#endif

  // Allocate process.
  if((np = allocproc()) == 0)
    return -1;

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
    kfree(np->kstack);
    np->kstack = 0;

#ifdef CS333_P3P4
    acquire(&ptable.lock);
    assertState(np, EMBRYO);
    rc = removeFromStateList(&ptable.pLists.embryo, np);
    if(rc == -1)
      panic("Could not remove from embryo list");
#endif
    np->state = UNUSED;
#ifdef CS333_P3P4
    rc = addToStateListHead(&ptable.pLists.free, np);
    if(rc == -1)
      panic("Could not add to free list.");
    release(&ptable.lock);
#endif
    return -1;
  }
  np->sz = proc->sz;
  np->parent = proc;
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);

  safestrcpy(np->name, proc->name, sizeof(proc->name));
 
  pid = np->pid;

#ifdef CS333_P2
  np->uid = proc->uid;
  np->gid = proc->gid;
#endif

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);

#ifdef CS333_P3P4
  //Remove the process from the embryo list
  assertState(np, EMBRYO);
  rc = removeFromStateList(&ptable.pLists.embryo, np);
  if(rc == -1)
    panic("Could not remove process from embryo.");
#endif
  np->state = RUNNABLE;

#ifdef CS333_P3P4
  //Add process to end of ready list
  assertState(np, RUNNABLE);
  rc = addToStateListEnd(&ptable.pLists.ready[0], np); //Add to end of highest queue
  if(rc == -1)
    panic("Could not add process to ready list.");
#endif

  release(&ptable.lock);
  
  return pid;
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
#ifndef CS333_P3P4
void
exit(void)
{
  struct proc *p;
  int fd;

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd]){
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(proc->cwd);
  end_op();
  proc->cwd = 0;

  acquire(&ptable.lock);

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == proc){
      p->parent = initproc;
      if(p->state == ZOMBIE)
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
  sched();
  panic("zombie exit");
}
#else
void
exit(void) //Project 3
{
  struct proc *p;
  int fd;
  int rc;

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd]){
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(proc->cwd);
  end_op();
  proc->cwd = 0;

  acquire(&ptable.lock);

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
 
  for(int i = 0; i < MAX; i++)
  { 
    p = ptable.pLists.ready[i];

    if(p)
    {
      while(p != 0)
      {
        if(p->parent == proc)
          p->parent = initproc;
        p = p->next;
      }
    }
  }

  p = ptable.pLists.sleep;

  if(p)
  {
    while(p != 0)
    {
      if(p->parent == proc)
        p->parent = initproc;
      p = p->next;
    }
  }

  p = ptable.pLists.embryo;

  if(p)
  {
    while(p != 0)
    {
      if(p->parent == proc)
        p->parent = initproc;
      p = p->next;
    }
  }

  p = ptable.pLists.running;

  if(p)
  {
    while(p != 0)
    {
      if(p->parent == proc)
        p->parent = initproc;
      p = p->next;
    }
  }

  p = ptable.pLists.zombie;

  if(p)
  {
    while(p != 0)
    {
      if(p->parent == proc)
      {
        p->parent = initproc;
        wakeup1(initproc);
      }
      p = p->next;
    }
  }

  // Jump into the scheduler, never to return.
  rc = removeFromStateList(&ptable.pLists.running, proc);
  if(rc == -1)
    panic("Could not remove from running list.");
  assertState(proc, RUNNING);

  proc->state = ZOMBIE;

  rc = addToStateListHead(&ptable.pLists.zombie, proc);
  if(rc == -1)
    panic("Could not add to zombie list.");
  //release(&ptable.lock);
  
  sched();
  panic("zombie exit");
}
#endif

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
#ifndef CS333_P3P4
int
wait(void)
{
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found one.
        pid = p->pid;
        kfree(p->kstack);
        p->kstack = 0;
        freevm(p->pgdir);
        p->state = UNUSED;
        p->pid = 0;
        p->parent = 0;
        p->name[0] = 0;
        p->killed = 0;
        release(&ptable.lock);
        return pid;
      }
    }

    
    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
  }
}
#else
int
wait(void) //Project 3
{
  //struct proc *p;
  struct proc *current;
  int havekids, pid;
  int rc;

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;

    for(int i = 0; i < MAX; i++)
    {
      current = ptable.pLists.ready[i];

      if(current)
      {
        while(current != 0)
        {
          if(current->parent == proc)
            havekids = 1;
          current = current->next;
        }
      }
    }

    current = ptable.pLists.sleep;

    if(current)
    {
      while(current != 0)
      {
        if(current->parent == proc)
          havekids = 1;
        current = current->next;
      }
    }
 
    current = ptable.pLists.embryo;

    if(current)
    {
      while(current != 0)
      {
        if(current->parent == proc)
          havekids = 1;
        current = current->next;
      }
    }

    current = ptable.pLists.running;

    if(current)
    {
      while(current != 0)
      {
        if(current->parent == proc)
          havekids = 1;
        current = current->next;
      }
    }

    current = ptable.pLists.zombie;

    if(current)
    {
      while(current != 0)
      {
        if(current->parent == proc)
          havekids = 1;

        rc = removeFromStateList(&ptable.pLists.zombie, current);
        if(rc == -1)
          panic("Could not remove from zombie list.");

        pid = current->pid;
        kfree(current->kstack);
        current->kstack = 0;
        freevm(current->pgdir);
        current->state = UNUSED;

        rc = addToStateListHead(&ptable.pLists.free, current);
        if(rc == -1)
          panic("Could not add to free list.");

        current->pid = 0;
        current->parent = 0;
        current->name[0] = 0;
        current->killed = 0;
        release(&ptable.lock);
        return pid;
        current = current->next;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
  }
}
#endif

// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
#ifndef CS333_P3P4
// original xv6 scheduler. Use if CS333_P3P4 NOT defined.
void
scheduler(void)
{
  struct proc *p;
  int idle;  // for checking if processor is idle

  for(;;){
    // Enable interrupts on this processor.
    sti();

    idle = 1;  // assume idle unless we schedule a process
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      idle = 0;  // not idle this timeslice
      proc = p;
      switchuvm(p);
      p->state = RUNNING;

#ifdef CS333_P2
      proc->cpu_ticks_in = ticks;
#endif

      swtch(&cpu->scheduler, proc->context);
      switchkvm();

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
    // if idle, wait for next interrupt
    if (idle) {
      sti();
      hlt();
    }
  }
}

#else //Scheduler for Project 4
void
scheduler(void)
{
  struct proc *p;
  int idle;  // for checking if processor is idle
  int rc;
  //int list = 0;  // for looping through the array of ready lists in MLFQ

  for (;;){
    // Enable interrupts on this processor.
    sti();
    
    idle = 1;  // assume idle unless we schedule a process

    acquire(&ptable.lock);

    if(ptable.PromoteAtTime <= ticks)
    {
      promoteAll(); 
      ptable.PromoteAtTime = ticks + TICKS_TO_PROMOTE;
    }

    for(int i = 0; i < MAX+1; i++)
    {
      p = ptable.pLists.ready[i];
      if(p)
        break;
      else
        p = 0;
    }

    if(p)
    {
      idle = 0;
      proc = p;
      switchuvm(p);

      rc = removeFromStateList(&ptable.pLists.ready[p->priority], p);
      if(rc == -1)
        panic("Could not remove from ready list.");
      assertState(p, RUNNABLE);
        
      p->state = RUNNING;

      //Put process on running list
      rc = addToStateListHead(&ptable.pLists.running, p);
      assertState(p, RUNNING);
      if(rc == -1)
        panic("Could not add to running list.");

#ifdef CS333_P2
      proc->cpu_ticks_in = ticks;
#endif

      swtch(&cpu->scheduler, proc->context);
      switchkvm();

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }

    release(&ptable.lock);
    // if idle, wait for next interrupt
    if (idle) {
      sti();
      hlt();
    }
  }
}
#endif

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
#ifndef CS333_P3P4
void
sched(void)
{
  int intena;

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(cpu->ncli != 1)
    panic("sched locks");
  if(proc->state == RUNNING)
    panic("sched running");
  if(readeflags()&FL_IF)
    panic("sched interruptible");
  intena = cpu->intena;

#ifdef CS333_P2 
  proc->cpu_ticks_total = ticks - proc->cpu_ticks_in;  
#endif

  swtch(&proc->context, cpu->scheduler);
  cpu->intena = intena;

}
#else
void
sched(void) //For Project 3
{
  int intena;

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(cpu->ncli != 1)
    panic("sched locks");
  if(proc->state == RUNNING)
    panic("sched running");
  if(readeflags()&FL_IF)
    panic("sched interruptible");
  intena = cpu->intena;

#ifdef CS333_P2 
  proc->cpu_ticks_total = ticks - proc->cpu_ticks_in;  
#endif

  swtch(&proc->context, cpu->scheduler);
  cpu->intena = intena;

}
#endif

// Give up the CPU for one scheduling round.
void
yield(void)
{
  int rc;
  int priority;
  acquire(&ptable.lock);  //DOC: yieldlock

#ifdef CS333_P3P4
  rc = removeFromStateList(&ptable.pLists.running, proc);
  if(rc == -1)
    panic("Could not remove from running list.");
  assertState(proc, RUNNING);
#endif  
  proc->state = RUNNABLE;

#ifdef CS333_P3P4
  /*Project 4*/
  proc->budget = proc->budget - (ticks - proc->cpu_ticks_in);
  if(proc->budget <= 0)
  {
    if(proc->priority < MAX)
    {
      ++(proc->priority);
      proc->budget = BUDGET;
    }
  }
  /*Project 4*/

  priority = proc->priority;
  rc = addToStateListEnd(&ptable.pLists.ready[priority], proc);
  if(rc == -1)
    panic("Could not add to ready list.");
#endif  

  sched();
  release(&ptable.lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);

  if (first) {
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }
  
  // Return to "caller", actually trapret (see allocproc).
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
// 2016/12/28: ticklock removed from xv6. sleep() changed to
// accept a NULL lock to accommodate.
void
sleep(void *chan, struct spinlock *lk)
{
  if(proc == 0)
    panic("sleep");

  // Must acquire ptable.lock in order to
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){
    acquire(&ptable.lock);
    if (lk) release(lk);
  }

#ifdef CS333_P3P4
  int rc = removeFromStateList(&ptable.pLists.running, proc);
  if(rc == -1)
    panic("Could not remove process from running list.");
  assertState(proc, RUNNING);
#endif
  // Go to sleep.
  proc->chan = chan;
  proc->state = SLEEPING;

#ifdef CS333_P3P4
  /*Project 4*/
  proc->budget = proc->budget - (ticks - proc->cpu_ticks_in);
  if(proc->budget <= 0)
  {
    if(proc->priority < MAX)
    {
      ++(proc->priority);
      proc->budget = BUDGET;
    }
  }
  /*Project 4*/
  rc = addToStateListHead(&ptable.pLists.sleep, proc);
  if(rc == -1)
    panic("Could not add to sleep list.");
#endif
  sched();

  // Tidy up.
  proc->chan = 0;

  // Reacquire original lock.
  if(lk != &ptable.lock){ 
    release(&ptable.lock);
    if (lk) acquire(lk);
  }
}

#ifndef CS333_P3P4
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
#else
static void
wakeup1(void *chan) //For Project 3
{
  struct proc *current;
  int rc;
  int priority;

  current = ptable.pLists.sleep;

  while(current != 0)
  {
    if(current->chan == chan)
    {
       rc = removeFromStateList(&ptable.pLists.sleep, current);
       if(rc == -1)
         panic("Could not remove process from sleep list.");
       assertState(current, SLEEPING);

       current->state = RUNNABLE;
       priority = current->priority;
  
       rc = addToStateListEnd(&ptable.pLists.ready[priority], current);
       if(rc == -1)
         panic("Could not add process to ready list."); 
    }
    current = current->next;
  }  
}
#endif

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
}

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
#ifndef CS333_P3P4
int
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}

#else
int
kill(int pid) //Project 3
{
  //struct proc *p;
  struct proc *current;
  int rc;

  acquire(&ptable.lock);
  
  current = ptable.pLists.running;

  while(current != 0)
  {
    if(current->pid == pid)
    {
      current->killed = 1;
      rc = removeFromStateList(&ptable.pLists.running, current);
      if(rc == -1)
        panic("Could not remove from running list.");
      release(&ptable.lock);
      return 0;
    } 
    current = current->next; 
  }

  current = ptable.pLists.sleep;

  while(current != 0)
  {
    if(current->pid == pid)
    {
      current->killed = 1;
      rc = removeFromStateList(&ptable.pLists.sleep, current);
      if(rc == -1)
        panic("Could not remove from sleep list.");
      release(&ptable.lock);
      return 0;
    }
    current = current->next; 
  }

  current = ptable.pLists.zombie;
  
  while(current != 0)
  {
    if(current->pid == pid)
    {
      current->killed = 1;
      rc = removeFromStateList(&ptable.pLists.zombie, current);
      if(rc == -1)
        panic("Could not remove from zombie list.");
      release(&ptable.lock);
      return 0;
    }
    current = current->next; 
  }

  current = ptable.pLists.embryo;

  while(current != 0)
  {
    if(current->pid == pid)
    {
      current->killed = 1;
      rc = removeFromStateList(&ptable.pLists.embryo, current);
      if(rc == -1)
        panic("Could not remove from embryo list.");
      release(&ptable.lock);
      return 0;
    }
    current = current->next; 
  }

  for(int i = 0; i < MAX; i++)
  {
    current = ptable.pLists.ready[i];

    while(current != 0)
    {
      if(current->pid == pid)
      {
        current->killed = 1;
        rc = removeFromStateList(&ptable.pLists.ready[i], current);
        if(rc == -1)
          panic("Could not remove from ready list.");
        return 0;
      }
      current = current->next; 
    }
  }
 
  release(&ptable.lock);
  return -1;
}
#endif

static char *states[] = {
  [UNUSED]    "unused",
  [EMBRYO]    "embryo",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
};

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

/*
#ifdef CS333_P1
  cprintf("PID     State    Name    Elapsed (s)     PCs\n");
#endif
*/
#ifdef CS333_P2 
  cprintf("\nPID\t Name\t\t Priority\t UID\t GID\t PPID\t Elapsed\t CPU\t State\t Size\t PCs\n");
#endif

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";

/*
#ifdef CS333_P1
    uint elapsed = ticks - p->start_ticks;
    uint sec = calcsec(elapsed);
    uint mili = calcmili(elapsed);
    cprintf("%d\t %s\t %s\t %d.%d\t\t", p->pid, state, p->name, sec, mili);
#else
    cprintf("%d %s %s", p->pid, state, p->name);
#endif
*/

#ifdef CS333_P2
  uint elapsed = ticks - p->start_ticks;
  uint sec = calcsec(elapsed);
  uint mili = calcmili(elapsed);

  uint cpu_sec = calcsec(p->cpu_ticks_total);
  uint cpu_mili = calcmili(p->cpu_ticks_total);

  cprintf("%d\t %s\t\t %d\t\t %d\t %d\t %d\t %d.%d\t\t %d.%d\t %s\t %d\t", p->pid, p->name, p->priority, p->uid, p->gid, p->parent->pid, sec, mili, cpu_sec, cpu_mili, state, p->sz);
#endif

    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}

#ifdef CS333_P1
//procdump's helper function
//calculating the seconds and miliseconds since a process has ran
uint
calcsec(uint num)
{
  uint sec = num / 1000;
  return sec;
}

uint
calcmili(uint num)
{
  uint mili = num % 1000;
  return mili;
}

#endif

#ifdef CS333_P2
int
getprocs(uint max, struct uproc *table)
{
  struct proc *p;
  int index = 0;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC] && index < max; p++)
  {
    if(p->state != EMBRYO && p->state != UNUSED)
    {
      table[index].pid = p->pid;
      table[index].uid = p->uid;
      table[index].gid = p->gid;
      table[index].priority = p->priority;
      table[index].ppid = p->parent->pid;
      table[index].elapsed_ticks = ticks - p->start_ticks;
      table[index].CPU_total_ticks = p->cpu_ticks_total;
      table[index].size = p->sz;

      safestrcpy(table[index].name, p->name, sizeof(table[index].name));

      if(p->state == RUNNING)
        safestrcpy(table[index].state, "RUNNING", sizeof(table[index].state));
      if(p->state == SLEEPING)
        safestrcpy(table[index].state, "SLEEPING", sizeof(table[index].state));
      if(p->state == RUNNABLE)
        safestrcpy(table[index].state, "RUNNABLE", sizeof(table[index].state));

      ++index;
    }
  }

  release(&ptable.lock);

  return index;
} 
#endif

#ifdef CS333_P3P4
//add holding locks check for all functions following
static void
promoteAll()
{
  struct proc *current;
  struct proc *hold;
  int rc;

  current = ptable.pLists.sleep;
  while(current)
  {
    if(current->priority > 0)
      --(current->priority);
    current = current->next;
  }
      
  current = ptable.pLists.running;
  while(current)
  {
    if(current->priority > 0)
      --(current->priority);
    current = current->next;
  }

  for(int i = 0; i < MAX + 1; i++)
  {
    current = ptable.pLists.ready[i];
    while(current)
    {
      hold = current->next;
      rc = removeFromStateList(&ptable.pLists.ready[i], current);
      if(rc == -1)
        panic("Could not remove from ready list.");
      assertState(current, RUNNABLE);

      if(current->priority > 0)
        --(current->priority);

      rc = addToStateListEnd(&ptable.pLists.ready[current->priority], current);
      if(rc == -1)
        panic("Could not add to ready list.");
          
      current = hold;
    }
  }
}

static int
removeFromStateList(struct proc** sList, struct proc* p)
{
  if (*sList == 0)
    return -1;

  else if(*sList == p)
  {
    struct proc *temp = *sList;
    *sList = temp->next;
    p->next = 0;
    return 0;
  }

  else
  {
    struct proc *previous = *sList;
    struct proc *current = previous->next;
    while(current != 0)
    {
      if(current == p)
      {
        previous->next = current->next;
        p->next = 0;
        return 0;
      }
      previous = current;
      current = current->next;
    }
  }
  
  return -1;
}

static void
assertState(struct proc* p, enum procstate state)
{
  if(p->state != state)
    panic("State does not match");
  else
    return;  
}

static int
addToStateListEnd(struct proc** sList, struct proc* p)
{
  if(*sList == 0)
  {
    *sList = p;
    p->next = 0;
    return 0;
  }

  else
  {
    struct proc* current = *sList;
  
    while(current != 0)
    { 
      if(current->next == 0)
      {
        current->next = p;
        p->next = 0;
        return 0;
      }
      current = current->next;
    }
  }
  return -1;
}

static int
addToStateListHead(struct proc ** sList, struct proc* p)
{
  if(p == 0)
    return -1;
  p->next = *sList;
  *sList = p;
  return 0;
}

void
doready(void)
{
  struct proc *current;

  cprintf("\nReady List Processes:\n");

  for(int list = 0; list < MAX + 1; list++)
  {
    current = ptable.pLists.ready[list];
    cprintf("\nReady list %d: ", list);
    while(current != 0)
    {
      assertState(current, RUNNABLE);
      cprintf("(%d, %d) -> ", current->pid, current->budget);
      current = current->next;
    }
  }

  cprintf("\n");
}

void
dofree(void)
{
  int count = 0;
  struct proc *current;
  
  current = ptable.pLists.free;
  if(current == 0)
  {
    cprintf("\nNo free processes.\n");
    return;
  }

  while(current != 0)
  {
    assertState(current, UNUSED);
    ++count;
    current = current->next;
  } 

  cprintf("\nFree List Size: %d processes.\n", count); 
}

void 
dosleep(void)
{
  struct proc *current;
  
  current = ptable.pLists.sleep;
  if(current == 0)
  {
    cprintf("\nNo sleeping processes.\n");
    return;
  }

  cprintf("\nSleep List Processes:\n");
  while(current != 0)
  {
    assertState(current, SLEEPING);
    cprintf("%d -> ", current->pid);
    current = current->next;
  }
  cprintf("\n");
}

void
dozombie(void)
{
  struct proc *current;
  
  current = ptable.pLists.zombie;
  if(current == 0)
  {
    cprintf("\nNo zombie processes.\n");
    return;
  }
  
  cprintf("\nZombie List Processes:\n");
  while(current != 0)
  {
    assertState(current, ZOMBIE);
    cprintf("(%d, %d) -> ", current->pid, current->parent->pid);
    current = current->next;
  }
}

int
setpriority(int pid, int priority)
{
  struct proc *current;
  int rc;

  current = ptable.pLists.sleep;  
  while(current)
  {
    if(current->pid == pid)
    {
      current->priority = priority;
      current->budget = BUDGET;
      return 0;
    }
    current = current->next;
  }

  current = ptable.pLists.running;
  while(current)
  {
    if(current->pid == pid)
    {
      current->priority = priority;
      current->budget = BUDGET;
      return 0;
    }
    current = current->next;
  } 

  for(int i = 0; i < MAX+1; i++)
  {
    current = ptable.pLists.ready[i];
    while(current)
    {
      if(current->pid == pid)
      {
        rc = removeFromStateList(&ptable.pLists.ready[i], current);
        if(rc == -1)
          panic("Could not remove from ready list.");
        assertState(current, RUNNABLE);

        current->priority = priority;
        current->budget = BUDGET;

        rc = addToStateListEnd(&ptable.pLists.ready[current->priority], current);
        if(rc == -1)
          panic("Could not add to ready list.");

        return 0;
      }
    }
    current = current->next;
  }

  return -1;
}
#endif
