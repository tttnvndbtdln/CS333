#define NPROC        64  // maximum number of processes
#define KSTACKSIZE 4096  // size of per-process kernel stack
#define NCPU          8  // maximum number of CPUs
#define NOFILE       16  // open files per process
#define NFILE       100  // open files per system
#define NINODE       50  // maximum number of active i-nodes
#define NDEV         10  // maximum major device number
#define ROOTDEV       1  // device number of file system root disk
#define MAXARG       32  // max exec arguments
#define MAXOPBLOCKS  10  // max # of blocks any FS op writes
#define LOGSIZE      (MAXOPBLOCKS*3)  // max data blocks in on-disk log
#define NBUF         (MAXOPBLOCKS*3)  // size of disk block cache
// #define FSSIZE       1000  // size of file system in blocks
#define FSSIZE       2000  // size of file system in blocks  // CS333 requires a larger FS.

#define DEFAULT_UID   0  // DEFAULT_UID is the default value for both the first process and files created by mkfs when the file system is created
#define DEFAULT_GID   0  // DEFAULT_GID is the default value for both the first process and files created by mkfs when the file system is created
#define TICKS_TO_PROMOTE    5000   //Ticks passed before all processes are promoted in MLF
#define BUDGET	   1000  // number of ticks a process can run before it's demoted in MLFQ 
#define MAX           6
#define DEFAULT_MODE  00755 // protection mode bits for inode, dinode, and stat
