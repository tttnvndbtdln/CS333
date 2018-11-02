
_p5-test:     file format elf32-i386


Disassembly of section .text:

00000000 <canRun>:
#include "stat.h"
#include "p5-test.h"

static int
canRun(char *name)
{
       0:	55                   	push   %ebp
       1:	89 e5                	mov    %esp,%ebp
       3:	83 ec 38             	sub    $0x38,%esp
  int rc, uid, gid;
  struct stat st;

  uid = getuid();
       6:	e8 c9 14 00 00       	call   14d4 <getuid>
       b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  gid = getgid();
       e:	e8 c9 14 00 00       	call   14dc <getgid>
      13:	89 45 f0             	mov    %eax,-0x10(%ebp)
  check(stat(name, &st));
      16:	83 ec 08             	sub    $0x8,%esp
      19:	8d 45 d0             	lea    -0x30(%ebp),%eax
      1c:	50                   	push   %eax
      1d:	ff 75 08             	pushl  0x8(%ebp)
      20:	e8 4d 12 00 00       	call   1272 <stat>
      25:	83 c4 10             	add    $0x10,%esp
      28:	89 45 ec             	mov    %eax,-0x14(%ebp)
      2b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
      2f:	74 21                	je     52 <canRun+0x52>
      31:	83 ec 04             	sub    $0x4,%esp
      34:	68 b4 19 00 00       	push   $0x19b4
      39:	68 c4 19 00 00       	push   $0x19c4
      3e:	6a 02                	push   $0x2
      40:	e8 b6 15 00 00       	call   15fb <printf>
      45:	83 c4 10             	add    $0x10,%esp
      48:	b8 00 00 00 00       	mov    $0x0,%eax
      4d:	e9 97 00 00 00       	jmp    e9 <canRun+0xe9>
  if (uid == st.uid) {
      52:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
      56:	0f b7 c0             	movzwl %ax,%eax
      59:	3b 45 f4             	cmp    -0xc(%ebp),%eax
      5c:	75 2b                	jne    89 <canRun+0x89>
    if (st.mode.flags.u_x)
      5e:	0f b6 45 e8          	movzbl -0x18(%ebp),%eax
      62:	83 e0 40             	and    $0x40,%eax
      65:	84 c0                	test   %al,%al
      67:	74 07                	je     70 <canRun+0x70>
      return TRUE;
      69:	b8 01 00 00 00       	mov    $0x1,%eax
      6e:	eb 79                	jmp    e9 <canRun+0xe9>
    else {
      printf(2, "UID match. Execute permission for user not set.\n");
      70:	83 ec 08             	sub    $0x8,%esp
      73:	68 d8 19 00 00       	push   $0x19d8
      78:	6a 02                	push   $0x2
      7a:	e8 7c 15 00 00       	call   15fb <printf>
      7f:	83 c4 10             	add    $0x10,%esp
      return FALSE;
      82:	b8 00 00 00 00       	mov    $0x0,%eax
      87:	eb 60                	jmp    e9 <canRun+0xe9>
    }
  }
  if (gid == st.gid) {
      89:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
      8d:	0f b7 c0             	movzwl %ax,%eax
      90:	3b 45 f0             	cmp    -0x10(%ebp),%eax
      93:	75 2b                	jne    c0 <canRun+0xc0>
    if (st.mode.flags.g_x)
      95:	0f b6 45 e8          	movzbl -0x18(%ebp),%eax
      99:	83 e0 08             	and    $0x8,%eax
      9c:	84 c0                	test   %al,%al
      9e:	74 07                	je     a7 <canRun+0xa7>
      return TRUE;
      a0:	b8 01 00 00 00       	mov    $0x1,%eax
      a5:	eb 42                	jmp    e9 <canRun+0xe9>
    else {
      printf(2, "GID match. Execute permission for group not set.\n");
      a7:	83 ec 08             	sub    $0x8,%esp
      aa:	68 0c 1a 00 00       	push   $0x1a0c
      af:	6a 02                	push   $0x2
      b1:	e8 45 15 00 00       	call   15fb <printf>
      b6:	83 c4 10             	add    $0x10,%esp
      return FALSE;
      b9:	b8 00 00 00 00       	mov    $0x0,%eax
      be:	eb 29                	jmp    e9 <canRun+0xe9>
    }
  }
  if (st.mode.flags.o_x) {
      c0:	0f b6 45 e8          	movzbl -0x18(%ebp),%eax
      c4:	83 e0 01             	and    $0x1,%eax
      c7:	84 c0                	test   %al,%al
      c9:	74 07                	je     d2 <canRun+0xd2>
    return TRUE;
      cb:	b8 01 00 00 00       	mov    $0x1,%eax
      d0:	eb 17                	jmp    e9 <canRun+0xe9>
  }

  printf(2, "Execute permission for other not set.\n");
      d2:	83 ec 08             	sub    $0x8,%esp
      d5:	68 40 1a 00 00       	push   $0x1a40
      da:	6a 02                	push   $0x2
      dc:	e8 1a 15 00 00       	call   15fb <printf>
      e1:	83 c4 10             	add    $0x10,%esp
  return FALSE;  // failure. Can't run
      e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
      e9:	c9                   	leave  
      ea:	c3                   	ret    

000000eb <doSetuidTest>:

static int
doSetuidTest (char **cmd)
{
      eb:	55                   	push   %ebp
      ec:	89 e5                	mov    %esp,%ebp
      ee:	53                   	push   %ebx
      ef:	83 ec 24             	sub    $0x24,%esp
  int rc, i;
  char *test[] = {"UID match", "GID match", "Other", "Should Fail"};
      f2:	c7 45 e0 67 1a 00 00 	movl   $0x1a67,-0x20(%ebp)
      f9:	c7 45 e4 71 1a 00 00 	movl   $0x1a71,-0x1c(%ebp)
     100:	c7 45 e8 7b 1a 00 00 	movl   $0x1a7b,-0x18(%ebp)
     107:	c7 45 ec 81 1a 00 00 	movl   $0x1a81,-0x14(%ebp)

  printf(1, "\nTesting the set uid bit.\n\n");
     10e:	83 ec 08             	sub    $0x8,%esp
     111:	68 8d 1a 00 00       	push   $0x1a8d
     116:	6a 01                	push   $0x1
     118:	e8 de 14 00 00       	call   15fb <printf>
     11d:	83 c4 10             	add    $0x10,%esp

  for (i=0; i<NUMPERMSTOCHECK; i++) {
     120:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     127:	e9 71 02 00 00       	jmp    39d <doSetuidTest+0x2b2>
    printf(1, "Starting test: %s.\n", test[i]);
     12c:	8b 45 f4             	mov    -0xc(%ebp),%eax
     12f:	8b 44 85 e0          	mov    -0x20(%ebp,%eax,4),%eax
     133:	83 ec 04             	sub    $0x4,%esp
     136:	50                   	push   %eax
     137:	68 a9 1a 00 00       	push   $0x1aa9
     13c:	6a 01                	push   $0x1
     13e:	e8 b8 14 00 00       	call   15fb <printf>
     143:	83 c4 10             	add    $0x10,%esp
    check(setuid(testperms[i][procuid]));
     146:	8b 45 f4             	mov    -0xc(%ebp),%eax
     149:	c1 e0 04             	shl    $0x4,%eax
     14c:	05 80 26 00 00       	add    $0x2680,%eax
     151:	8b 00                	mov    (%eax),%eax
     153:	83 ec 0c             	sub    $0xc,%esp
     156:	50                   	push   %eax
     157:	e8 90 13 00 00       	call   14ec <setuid>
     15c:	83 c4 10             	add    $0x10,%esp
     15f:	89 45 f0             	mov    %eax,-0x10(%ebp)
     162:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     166:	74 21                	je     189 <doSetuidTest+0x9e>
     168:	83 ec 04             	sub    $0x4,%esp
     16b:	68 bd 1a 00 00       	push   $0x1abd
     170:	68 c4 19 00 00       	push   $0x19c4
     175:	6a 02                	push   $0x2
     177:	e8 7f 14 00 00       	call   15fb <printf>
     17c:	83 c4 10             	add    $0x10,%esp
     17f:	b8 00 00 00 00       	mov    $0x0,%eax
     184:	e9 4f 02 00 00       	jmp    3d8 <doSetuidTest+0x2ed>
    check(setgid(testperms[i][procgid]));
     189:	8b 45 f4             	mov    -0xc(%ebp),%eax
     18c:	c1 e0 04             	shl    $0x4,%eax
     18f:	05 84 26 00 00       	add    $0x2684,%eax
     194:	8b 00                	mov    (%eax),%eax
     196:	83 ec 0c             	sub    $0xc,%esp
     199:	50                   	push   %eax
     19a:	e8 55 13 00 00       	call   14f4 <setgid>
     19f:	83 c4 10             	add    $0x10,%esp
     1a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
     1a5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     1a9:	74 21                	je     1cc <doSetuidTest+0xe1>
     1ab:	83 ec 04             	sub    $0x4,%esp
     1ae:	68 db 1a 00 00       	push   $0x1adb
     1b3:	68 c4 19 00 00       	push   $0x19c4
     1b8:	6a 02                	push   $0x2
     1ba:	e8 3c 14 00 00       	call   15fb <printf>
     1bf:	83 c4 10             	add    $0x10,%esp
     1c2:	b8 00 00 00 00       	mov    $0x0,%eax
     1c7:	e9 0c 02 00 00       	jmp    3d8 <doSetuidTest+0x2ed>
    printf(1, "Process uid: %d, gid: %d\n", getuid(), getgid());
     1cc:	e8 0b 13 00 00       	call   14dc <getgid>
     1d1:	89 c3                	mov    %eax,%ebx
     1d3:	e8 fc 12 00 00       	call   14d4 <getuid>
     1d8:	53                   	push   %ebx
     1d9:	50                   	push   %eax
     1da:	68 f9 1a 00 00       	push   $0x1af9
     1df:	6a 01                	push   $0x1
     1e1:	e8 15 14 00 00       	call   15fb <printf>
     1e6:	83 c4 10             	add    $0x10,%esp
    check(chown(cmd[0], testperms[i][fileuid]));
     1e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
     1ec:	c1 e0 04             	shl    $0x4,%eax
     1ef:	05 88 26 00 00       	add    $0x2688,%eax
     1f4:	8b 10                	mov    (%eax),%edx
     1f6:	8b 45 08             	mov    0x8(%ebp),%eax
     1f9:	8b 00                	mov    (%eax),%eax
     1fb:	83 ec 08             	sub    $0x8,%esp
     1fe:	52                   	push   %edx
     1ff:	50                   	push   %eax
     200:	e8 0f 13 00 00       	call   1514 <chown>
     205:	83 c4 10             	add    $0x10,%esp
     208:	89 45 f0             	mov    %eax,-0x10(%ebp)
     20b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     20f:	74 21                	je     232 <doSetuidTest+0x147>
     211:	83 ec 04             	sub    $0x4,%esp
     214:	68 14 1b 00 00       	push   $0x1b14
     219:	68 c4 19 00 00       	push   $0x19c4
     21e:	6a 02                	push   $0x2
     220:	e8 d6 13 00 00       	call   15fb <printf>
     225:	83 c4 10             	add    $0x10,%esp
     228:	b8 00 00 00 00       	mov    $0x0,%eax
     22d:	e9 a6 01 00 00       	jmp    3d8 <doSetuidTest+0x2ed>
    check(chgrp(cmd[0], testperms[i][filegid]));
     232:	8b 45 f4             	mov    -0xc(%ebp),%eax
     235:	c1 e0 04             	shl    $0x4,%eax
     238:	05 8c 26 00 00       	add    $0x268c,%eax
     23d:	8b 10                	mov    (%eax),%edx
     23f:	8b 45 08             	mov    0x8(%ebp),%eax
     242:	8b 00                	mov    (%eax),%eax
     244:	83 ec 08             	sub    $0x8,%esp
     247:	52                   	push   %edx
     248:	50                   	push   %eax
     249:	e8 ce 12 00 00       	call   151c <chgrp>
     24e:	83 c4 10             	add    $0x10,%esp
     251:	89 45 f0             	mov    %eax,-0x10(%ebp)
     254:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     258:	74 21                	je     27b <doSetuidTest+0x190>
     25a:	83 ec 04             	sub    $0x4,%esp
     25d:	68 3c 1b 00 00       	push   $0x1b3c
     262:	68 c4 19 00 00       	push   $0x19c4
     267:	6a 02                	push   $0x2
     269:	e8 8d 13 00 00       	call   15fb <printf>
     26e:	83 c4 10             	add    $0x10,%esp
     271:	b8 00 00 00 00       	mov    $0x0,%eax
     276:	e9 5d 01 00 00       	jmp    3d8 <doSetuidTest+0x2ed>
    printf(1, "File uid: %d, gid: %d\n",
     27b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     27e:	c1 e0 04             	shl    $0x4,%eax
     281:	05 8c 26 00 00       	add    $0x268c,%eax
     286:	8b 10                	mov    (%eax),%edx
     288:	8b 45 f4             	mov    -0xc(%ebp),%eax
     28b:	c1 e0 04             	shl    $0x4,%eax
     28e:	05 88 26 00 00       	add    $0x2688,%eax
     293:	8b 00                	mov    (%eax),%eax
     295:	52                   	push   %edx
     296:	50                   	push   %eax
     297:	68 61 1b 00 00       	push   $0x1b61
     29c:	6a 01                	push   $0x1
     29e:	e8 58 13 00 00       	call   15fb <printf>
     2a3:	83 c4 10             	add    $0x10,%esp
		    testperms[i][fileuid], testperms[i][filegid]);
    check(chmod(cmd[0], perms[i]));
     2a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
     2a9:	8b 14 85 64 26 00 00 	mov    0x2664(,%eax,4),%edx
     2b0:	8b 45 08             	mov    0x8(%ebp),%eax
     2b3:	8b 00                	mov    (%eax),%eax
     2b5:	83 ec 08             	sub    $0x8,%esp
     2b8:	52                   	push   %edx
     2b9:	50                   	push   %eax
     2ba:	e8 4d 12 00 00       	call   150c <chmod>
     2bf:	83 c4 10             	add    $0x10,%esp
     2c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
     2c5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     2c9:	74 21                	je     2ec <doSetuidTest+0x201>
     2cb:	83 ec 04             	sub    $0x4,%esp
     2ce:	68 78 1b 00 00       	push   $0x1b78
     2d3:	68 c4 19 00 00       	push   $0x19c4
     2d8:	6a 02                	push   $0x2
     2da:	e8 1c 13 00 00       	call   15fb <printf>
     2df:	83 c4 10             	add    $0x10,%esp
     2e2:	b8 00 00 00 00       	mov    $0x0,%eax
     2e7:	e9 ec 00 00 00       	jmp    3d8 <doSetuidTest+0x2ed>
    printf(1, "perms set to %d for %s\n", perms[i], cmd[0]);
     2ec:	8b 45 08             	mov    0x8(%ebp),%eax
     2ef:	8b 10                	mov    (%eax),%edx
     2f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
     2f4:	8b 04 85 64 26 00 00 	mov    0x2664(,%eax,4),%eax
     2fb:	52                   	push   %edx
     2fc:	50                   	push   %eax
     2fd:	68 90 1b 00 00       	push   $0x1b90
     302:	6a 01                	push   $0x1
     304:	e8 f2 12 00 00       	call   15fb <printf>
     309:	83 c4 10             	add    $0x10,%esp

    rc = fork();
     30c:	e8 0b 11 00 00       	call   141c <fork>
     311:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (rc < 0) {    // fork failed
     314:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     318:	79 1c                	jns    336 <doSetuidTest+0x24b>
      printf(2, "The fork() system call failed. That's pretty catastrophic. Ending test\n");
     31a:	83 ec 08             	sub    $0x8,%esp
     31d:	68 a8 1b 00 00       	push   $0x1ba8
     322:	6a 02                	push   $0x2
     324:	e8 d2 12 00 00       	call   15fb <printf>
     329:	83 c4 10             	add    $0x10,%esp
      return NOPASS;
     32c:	b8 00 00 00 00       	mov    $0x0,%eax
     331:	e9 a2 00 00 00       	jmp    3d8 <doSetuidTest+0x2ed>
    }
    if (rc == 0) {   // child
     336:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     33a:	75 58                	jne    394 <doSetuidTest+0x2a9>
      exec(cmd[0], cmd);
     33c:	8b 45 08             	mov    0x8(%ebp),%eax
     33f:	8b 00                	mov    (%eax),%eax
     341:	83 ec 08             	sub    $0x8,%esp
     344:	ff 75 08             	pushl  0x8(%ebp)
     347:	50                   	push   %eax
     348:	e8 0f 11 00 00       	call   145c <exec>
     34d:	83 c4 10             	add    $0x10,%esp
      if (i != NUMPERMSTOCHECK-1) printf(2, "**** exec call for %s **FAILED**.\n",  cmd[0]);
     350:	a1 60 26 00 00       	mov    0x2660,%eax
     355:	83 e8 01             	sub    $0x1,%eax
     358:	3b 45 f4             	cmp    -0xc(%ebp),%eax
     35b:	74 1a                	je     377 <doSetuidTest+0x28c>
     35d:	8b 45 08             	mov    0x8(%ebp),%eax
     360:	8b 00                	mov    (%eax),%eax
     362:	83 ec 04             	sub    $0x4,%esp
     365:	50                   	push   %eax
     366:	68 f0 1b 00 00       	push   $0x1bf0
     36b:	6a 02                	push   $0x2
     36d:	e8 89 12 00 00       	call   15fb <printf>
     372:	83 c4 10             	add    $0x10,%esp
     375:	eb 18                	jmp    38f <doSetuidTest+0x2a4>
      else printf(2, "**** exec call for %s **FAILED as expected.\n", cmd[0]);
     377:	8b 45 08             	mov    0x8(%ebp),%eax
     37a:	8b 00                	mov    (%eax),%eax
     37c:	83 ec 04             	sub    $0x4,%esp
     37f:	50                   	push   %eax
     380:	68 14 1c 00 00       	push   $0x1c14
     385:	6a 02                	push   $0x2
     387:	e8 6f 12 00 00       	call   15fb <printf>
     38c:	83 c4 10             	add    $0x10,%esp
      exit();
     38f:	e8 90 10 00 00       	call   1424 <exit>
    }
    wait();
     394:	e8 93 10 00 00       	call   142c <wait>
  int rc, i;
  char *test[] = {"UID match", "GID match", "Other", "Should Fail"};

  printf(1, "\nTesting the set uid bit.\n\n");

  for (i=0; i<NUMPERMSTOCHECK; i++) {
     399:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     39d:	a1 60 26 00 00       	mov    0x2660,%eax
     3a2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
     3a5:	0f 8c 81 fd ff ff    	jl     12c <doSetuidTest+0x41>
      else printf(2, "**** exec call for %s **FAILED as expected.\n", cmd[0]);
      exit();
    }
    wait();
  }
  chmod(cmd[0], 00755);  // total hack but necessary. sigh
     3ab:	8b 45 08             	mov    0x8(%ebp),%eax
     3ae:	8b 00                	mov    (%eax),%eax
     3b0:	83 ec 08             	sub    $0x8,%esp
     3b3:	68 ed 01 00 00       	push   $0x1ed
     3b8:	50                   	push   %eax
     3b9:	e8 4e 11 00 00       	call   150c <chmod>
     3be:	83 c4 10             	add    $0x10,%esp
  printf(1, "Test Passed\n");
     3c1:	83 ec 08             	sub    $0x8,%esp
     3c4:	68 41 1c 00 00       	push   $0x1c41
     3c9:	6a 01                	push   $0x1
     3cb:	e8 2b 12 00 00       	call   15fb <printf>
     3d0:	83 c4 10             	add    $0x10,%esp
  return PASS;
     3d3:	b8 01 00 00 00       	mov    $0x1,%eax
}
     3d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
     3db:	c9                   	leave  
     3dc:	c3                   	ret    

000003dd <doUidTest>:

static int
doUidTest (char **cmd)
{
     3dd:	55                   	push   %ebp
     3de:	89 e5                	mov    %esp,%ebp
     3e0:	83 ec 38             	sub    $0x38,%esp
  int i, rc, uid, startuid, testuid, baduidcount = 3;
     3e3:	c7 45 f0 03 00 00 00 	movl   $0x3,-0x10(%ebp)
  int baduids[] = {32767+5, -41, ~0};  // 32767 is max value
     3ea:	c7 45 d4 04 80 00 00 	movl   $0x8004,-0x2c(%ebp)
     3f1:	c7 45 d8 d7 ff ff ff 	movl   $0xffffffd7,-0x28(%ebp)
     3f8:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)

  printf(1, "\nExecuting setuid() test.\n\n");
     3ff:	83 ec 08             	sub    $0x8,%esp
     402:	68 4e 1c 00 00       	push   $0x1c4e
     407:	6a 01                	push   $0x1
     409:	e8 ed 11 00 00       	call   15fb <printf>
     40e:	83 c4 10             	add    $0x10,%esp

  startuid = uid = getuid();
     411:	e8 be 10 00 00       	call   14d4 <getuid>
     416:	89 45 ec             	mov    %eax,-0x14(%ebp)
     419:	8b 45 ec             	mov    -0x14(%ebp),%eax
     41c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  testuid = ++uid;
     41f:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
     423:	8b 45 ec             	mov    -0x14(%ebp),%eax
     426:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  rc = setuid(testuid);
     429:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     42c:	83 ec 0c             	sub    $0xc,%esp
     42f:	50                   	push   %eax
     430:	e8 b7 10 00 00       	call   14ec <setuid>
     435:	83 c4 10             	add    $0x10,%esp
     438:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if (rc) {
     43b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
     43f:	74 1c                	je     45d <doUidTest+0x80>
    printf(2, "setuid system call reports an error.\n");
     441:	83 ec 08             	sub    $0x8,%esp
     444:	68 6c 1c 00 00       	push   $0x1c6c
     449:	6a 02                	push   $0x2
     44b:	e8 ab 11 00 00       	call   15fb <printf>
     450:	83 c4 10             	add    $0x10,%esp
    return NOPASS;
     453:	b8 00 00 00 00       	mov    $0x0,%eax
     458:	e9 07 01 00 00       	jmp    564 <doUidTest+0x187>
  }
  uid = getuid();
     45d:	e8 72 10 00 00       	call   14d4 <getuid>
     462:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if (uid != testuid) {
     465:	8b 45 ec             	mov    -0x14(%ebp),%eax
     468:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
     46b:	74 31                	je     49e <doUidTest+0xc1>
    printf(2, "ERROR! setuid claims to have worked but really didn't!\n");
     46d:	83 ec 08             	sub    $0x8,%esp
     470:	68 94 1c 00 00       	push   $0x1c94
     475:	6a 02                	push   $0x2
     477:	e8 7f 11 00 00       	call   15fb <printf>
     47c:	83 c4 10             	add    $0x10,%esp
    printf(2, "uid should be %d but is instead %d\n", testuid, uid);
     47f:	ff 75 ec             	pushl  -0x14(%ebp)
     482:	ff 75 e4             	pushl  -0x1c(%ebp)
     485:	68 cc 1c 00 00       	push   $0x1ccc
     48a:	6a 02                	push   $0x2
     48c:	e8 6a 11 00 00       	call   15fb <printf>
     491:	83 c4 10             	add    $0x10,%esp
    return NOPASS;
     494:	b8 00 00 00 00       	mov    $0x0,%eax
     499:	e9 c6 00 00 00       	jmp    564 <doUidTest+0x187>
  }
  for (i=0; i<baduidcount; i++) {
     49e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     4a5:	e9 88 00 00 00       	jmp    532 <doUidTest+0x155>
    rc = setuid(baduids[i]);
     4aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4ad:	8b 44 85 d4          	mov    -0x2c(%ebp,%eax,4),%eax
     4b1:	83 ec 0c             	sub    $0xc,%esp
     4b4:	50                   	push   %eax
     4b5:	e8 32 10 00 00       	call   14ec <setuid>
     4ba:	83 c4 10             	add    $0x10,%esp
     4bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if (rc == 0) {
     4c0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
     4c4:	75 21                	jne    4e7 <doUidTest+0x10a>
      printf(2, "Tried to set the uid to a bad value (%d) and setuid()failed to fail. rc == %d\n",
     4c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4c9:	8b 44 85 d4          	mov    -0x2c(%ebp,%eax,4),%eax
     4cd:	ff 75 e0             	pushl  -0x20(%ebp)
     4d0:	50                   	push   %eax
     4d1:	68 f0 1c 00 00       	push   $0x1cf0
     4d6:	6a 02                	push   $0x2
     4d8:	e8 1e 11 00 00       	call   15fb <printf>
     4dd:	83 c4 10             	add    $0x10,%esp
                      baduids[i], rc);
      return NOPASS;
     4e0:	b8 00 00 00 00       	mov    $0x0,%eax
     4e5:	eb 7d                	jmp    564 <doUidTest+0x187>
    }
    rc = getuid();
     4e7:	e8 e8 0f 00 00       	call   14d4 <getuid>
     4ec:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if (baduids[i] == rc) {
     4ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4f2:	8b 44 85 d4          	mov    -0x2c(%ebp,%eax,4),%eax
     4f6:	3b 45 e0             	cmp    -0x20(%ebp),%eax
     4f9:	75 33                	jne    52e <doUidTest+0x151>
      printf(2, "ERROR! Gave setuid() a bad value (%d) and it failed to fail. gid: %d\n",
     4fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4fe:	8b 44 85 d4          	mov    -0x2c(%ebp,%eax,4),%eax
     502:	ff 75 e0             	pushl  -0x20(%ebp)
     505:	50                   	push   %eax
     506:	68 40 1d 00 00       	push   $0x1d40
     50b:	6a 02                	push   $0x2
     50d:	e8 e9 10 00 00       	call   15fb <printf>
     512:	83 c4 10             	add    $0x10,%esp
		      baduids[i],rc);
      printf(2, "Valid UIDs are in the range [0, 32767] only!\n");
     515:	83 ec 08             	sub    $0x8,%esp
     518:	68 88 1d 00 00       	push   $0x1d88
     51d:	6a 02                	push   $0x2
     51f:	e8 d7 10 00 00       	call   15fb <printf>
     524:	83 c4 10             	add    $0x10,%esp
      return NOPASS;
     527:	b8 00 00 00 00       	mov    $0x0,%eax
     52c:	eb 36                	jmp    564 <doUidTest+0x187>
  if (uid != testuid) {
    printf(2, "ERROR! setuid claims to have worked but really didn't!\n");
    printf(2, "uid should be %d but is instead %d\n", testuid, uid);
    return NOPASS;
  }
  for (i=0; i<baduidcount; i++) {
     52e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     532:	8b 45 f4             	mov    -0xc(%ebp),%eax
     535:	3b 45 f0             	cmp    -0x10(%ebp),%eax
     538:	0f 8c 6c ff ff ff    	jl     4aa <doUidTest+0xcd>
		      baduids[i],rc);
      printf(2, "Valid UIDs are in the range [0, 32767] only!\n");
      return NOPASS;
    }
  }
  setuid(startuid);
     53e:	8b 45 e8             	mov    -0x18(%ebp),%eax
     541:	83 ec 0c             	sub    $0xc,%esp
     544:	50                   	push   %eax
     545:	e8 a2 0f 00 00       	call   14ec <setuid>
     54a:	83 c4 10             	add    $0x10,%esp
  printf(1, "Test Passed\n");
     54d:	83 ec 08             	sub    $0x8,%esp
     550:	68 41 1c 00 00       	push   $0x1c41
     555:	6a 01                	push   $0x1
     557:	e8 9f 10 00 00       	call   15fb <printf>
     55c:	83 c4 10             	add    $0x10,%esp
  return PASS;
     55f:	b8 01 00 00 00       	mov    $0x1,%eax
}
     564:	c9                   	leave  
     565:	c3                   	ret    

00000566 <doGidTest>:

static int
doGidTest (char **cmd)
{
     566:	55                   	push   %ebp
     567:	89 e5                	mov    %esp,%ebp
     569:	83 ec 38             	sub    $0x38,%esp
  int i, rc, gid, startgid, testgid, badgidcount = 3;
     56c:	c7 45 f0 03 00 00 00 	movl   $0x3,-0x10(%ebp)
  int badgids[] = {32767+5, -41, ~0};  // 32767 is max value
     573:	c7 45 d4 04 80 00 00 	movl   $0x8004,-0x2c(%ebp)
     57a:	c7 45 d8 d7 ff ff ff 	movl   $0xffffffd7,-0x28(%ebp)
     581:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)

  printf(1, "\nExecuting setgid() test.\n\n");
     588:	83 ec 08             	sub    $0x8,%esp
     58b:	68 b6 1d 00 00       	push   $0x1db6
     590:	6a 01                	push   $0x1
     592:	e8 64 10 00 00       	call   15fb <printf>
     597:	83 c4 10             	add    $0x10,%esp

  startgid = gid = getgid();
     59a:	e8 3d 0f 00 00       	call   14dc <getgid>
     59f:	89 45 ec             	mov    %eax,-0x14(%ebp)
     5a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
     5a5:	89 45 e8             	mov    %eax,-0x18(%ebp)
  testgid = ++gid;
     5a8:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
     5ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
     5af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  rc = setgid(testgid);
     5b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     5b5:	83 ec 0c             	sub    $0xc,%esp
     5b8:	50                   	push   %eax
     5b9:	e8 36 0f 00 00       	call   14f4 <setgid>
     5be:	83 c4 10             	add    $0x10,%esp
     5c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if (rc) {
     5c4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
     5c8:	74 1c                	je     5e6 <doGidTest+0x80>
    printf(2, "setgid system call reports an error.\n");
     5ca:	83 ec 08             	sub    $0x8,%esp
     5cd:	68 d4 1d 00 00       	push   $0x1dd4
     5d2:	6a 02                	push   $0x2
     5d4:	e8 22 10 00 00       	call   15fb <printf>
     5d9:	83 c4 10             	add    $0x10,%esp
    return NOPASS;
     5dc:	b8 00 00 00 00       	mov    $0x0,%eax
     5e1:	e9 07 01 00 00       	jmp    6ed <doGidTest+0x187>
  }
  gid = getgid();
     5e6:	e8 f1 0e 00 00       	call   14dc <getgid>
     5eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if (gid != testgid) {
     5ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
     5f1:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
     5f4:	74 31                	je     627 <doGidTest+0xc1>
    printf(2, "ERROR! setgid claims to have worked but really didn't!\n");
     5f6:	83 ec 08             	sub    $0x8,%esp
     5f9:	68 fc 1d 00 00       	push   $0x1dfc
     5fe:	6a 02                	push   $0x2
     600:	e8 f6 0f 00 00       	call   15fb <printf>
     605:	83 c4 10             	add    $0x10,%esp
    printf(2, "gid should be %d but is instead %d\n", testgid, gid);
     608:	ff 75 ec             	pushl  -0x14(%ebp)
     60b:	ff 75 e4             	pushl  -0x1c(%ebp)
     60e:	68 34 1e 00 00       	push   $0x1e34
     613:	6a 02                	push   $0x2
     615:	e8 e1 0f 00 00       	call   15fb <printf>
     61a:	83 c4 10             	add    $0x10,%esp
    return NOPASS;
     61d:	b8 00 00 00 00       	mov    $0x0,%eax
     622:	e9 c6 00 00 00       	jmp    6ed <doGidTest+0x187>
  }
  for (i=0; i<badgidcount; i++) {
     627:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     62e:	e9 88 00 00 00       	jmp    6bb <doGidTest+0x155>
    rc = setgid(badgids[i]); 
     633:	8b 45 f4             	mov    -0xc(%ebp),%eax
     636:	8b 44 85 d4          	mov    -0x2c(%ebp,%eax,4),%eax
     63a:	83 ec 0c             	sub    $0xc,%esp
     63d:	50                   	push   %eax
     63e:	e8 b1 0e 00 00       	call   14f4 <setgid>
     643:	83 c4 10             	add    $0x10,%esp
     646:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if (rc == 0) {
     649:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
     64d:	75 21                	jne    670 <doGidTest+0x10a>
      printf(2, "Tried to set the gid to a bad value (%d) and setgid()failed to fail. rc == %d\n",
     64f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     652:	8b 44 85 d4          	mov    -0x2c(%ebp,%eax,4),%eax
     656:	ff 75 e0             	pushl  -0x20(%ebp)
     659:	50                   	push   %eax
     65a:	68 58 1e 00 00       	push   $0x1e58
     65f:	6a 02                	push   $0x2
     661:	e8 95 0f 00 00       	call   15fb <printf>
     666:	83 c4 10             	add    $0x10,%esp
		      badgids[i], rc);
      return NOPASS;
     669:	b8 00 00 00 00       	mov    $0x0,%eax
     66e:	eb 7d                	jmp    6ed <doGidTest+0x187>
    }
    rc = getgid();
     670:	e8 67 0e 00 00       	call   14dc <getgid>
     675:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if (badgids[i] == rc) {
     678:	8b 45 f4             	mov    -0xc(%ebp),%eax
     67b:	8b 44 85 d4          	mov    -0x2c(%ebp,%eax,4),%eax
     67f:	3b 45 e0             	cmp    -0x20(%ebp),%eax
     682:	75 33                	jne    6b7 <doGidTest+0x151>
      printf(2, "ERROR! Gave setgid() a bad value (%d) and it failed to fail. gid: %d\n",
     684:	8b 45 f4             	mov    -0xc(%ebp),%eax
     687:	8b 44 85 d4          	mov    -0x2c(%ebp,%eax,4),%eax
     68b:	ff 75 e0             	pushl  -0x20(%ebp)
     68e:	50                   	push   %eax
     68f:	68 a8 1e 00 00       	push   $0x1ea8
     694:	6a 02                	push   $0x2
     696:	e8 60 0f 00 00       	call   15fb <printf>
     69b:	83 c4 10             	add    $0x10,%esp
		      badgids[i], rc);
      printf(2, "Valid GIDs are in the range [0, 32767] only!\n");
     69e:	83 ec 08             	sub    $0x8,%esp
     6a1:	68 f0 1e 00 00       	push   $0x1ef0
     6a6:	6a 02                	push   $0x2
     6a8:	e8 4e 0f 00 00       	call   15fb <printf>
     6ad:	83 c4 10             	add    $0x10,%esp
      return NOPASS;
     6b0:	b8 00 00 00 00       	mov    $0x0,%eax
     6b5:	eb 36                	jmp    6ed <doGidTest+0x187>
  if (gid != testgid) {
    printf(2, "ERROR! setgid claims to have worked but really didn't!\n");
    printf(2, "gid should be %d but is instead %d\n", testgid, gid);
    return NOPASS;
  }
  for (i=0; i<badgidcount; i++) {
     6b7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     6bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6be:	3b 45 f0             	cmp    -0x10(%ebp),%eax
     6c1:	0f 8c 6c ff ff ff    	jl     633 <doGidTest+0xcd>
		      badgids[i], rc);
      printf(2, "Valid GIDs are in the range [0, 32767] only!\n");
      return NOPASS;
    }
  }
  setgid(startgid);
     6c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
     6ca:	83 ec 0c             	sub    $0xc,%esp
     6cd:	50                   	push   %eax
     6ce:	e8 21 0e 00 00       	call   14f4 <setgid>
     6d3:	83 c4 10             	add    $0x10,%esp
  printf(1, "Test Passed\n");
     6d6:	83 ec 08             	sub    $0x8,%esp
     6d9:	68 41 1c 00 00       	push   $0x1c41
     6de:	6a 01                	push   $0x1
     6e0:	e8 16 0f 00 00       	call   15fb <printf>
     6e5:	83 c4 10             	add    $0x10,%esp
  return PASS;
     6e8:	b8 01 00 00 00       	mov    $0x1,%eax
}
     6ed:	c9                   	leave  
     6ee:	c3                   	ret    

000006ef <doChmodTest>:

static int
doChmodTest(char **cmd) 
{
     6ef:	55                   	push   %ebp
     6f0:	89 e5                	mov    %esp,%ebp
     6f2:	83 ec 38             	sub    $0x38,%esp
  int i, rc, mode, testmode;
  struct stat st;

  printf(1, "\nExecuting chmod() test.\n\n");
     6f5:	83 ec 08             	sub    $0x8,%esp
     6f8:	68 1e 1f 00 00       	push   $0x1f1e
     6fd:	6a 01                	push   $0x1
     6ff:	e8 f7 0e 00 00       	call   15fb <printf>
     704:	83 c4 10             	add    $0x10,%esp

  check(stat(cmd[0], &st));
     707:	8b 45 08             	mov    0x8(%ebp),%eax
     70a:	8b 00                	mov    (%eax),%eax
     70c:	83 ec 08             	sub    $0x8,%esp
     70f:	8d 55 cc             	lea    -0x34(%ebp),%edx
     712:	52                   	push   %edx
     713:	50                   	push   %eax
     714:	e8 59 0b 00 00       	call   1272 <stat>
     719:	83 c4 10             	add    $0x10,%esp
     71c:	89 45 f0             	mov    %eax,-0x10(%ebp)
     71f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     723:	74 21                	je     746 <doChmodTest+0x57>
     725:	83 ec 04             	sub    $0x4,%esp
     728:	68 39 1f 00 00       	push   $0x1f39
     72d:	68 c4 19 00 00       	push   $0x19c4
     732:	6a 02                	push   $0x2
     734:	e8 c2 0e 00 00       	call   15fb <printf>
     739:	83 c4 10             	add    $0x10,%esp
     73c:	b8 00 00 00 00       	mov    $0x0,%eax
     741:	e9 1e 01 00 00       	jmp    864 <doChmodTest+0x175>
  mode = st.mode.asInt;
     746:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     749:	89 45 ec             	mov    %eax,-0x14(%ebp)

  for (i=0; i<NUMPERMSTOCHECK; i++) {
     74c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     753:	e9 d1 00 00 00       	jmp    829 <doChmodTest+0x13a>
    check(chmod(cmd[0], perms[i]));
     758:	8b 45 f4             	mov    -0xc(%ebp),%eax
     75b:	8b 14 85 64 26 00 00 	mov    0x2664(,%eax,4),%edx
     762:	8b 45 08             	mov    0x8(%ebp),%eax
     765:	8b 00                	mov    (%eax),%eax
     767:	83 ec 08             	sub    $0x8,%esp
     76a:	52                   	push   %edx
     76b:	50                   	push   %eax
     76c:	e8 9b 0d 00 00       	call   150c <chmod>
     771:	83 c4 10             	add    $0x10,%esp
     774:	89 45 f0             	mov    %eax,-0x10(%ebp)
     777:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     77b:	74 21                	je     79e <doChmodTest+0xaf>
     77d:	83 ec 04             	sub    $0x4,%esp
     780:	68 78 1b 00 00       	push   $0x1b78
     785:	68 c4 19 00 00       	push   $0x19c4
     78a:	6a 02                	push   $0x2
     78c:	e8 6a 0e 00 00       	call   15fb <printf>
     791:	83 c4 10             	add    $0x10,%esp
     794:	b8 00 00 00 00       	mov    $0x0,%eax
     799:	e9 c6 00 00 00       	jmp    864 <doChmodTest+0x175>
    check(stat(cmd[0], &st));
     79e:	8b 45 08             	mov    0x8(%ebp),%eax
     7a1:	8b 00                	mov    (%eax),%eax
     7a3:	83 ec 08             	sub    $0x8,%esp
     7a6:	8d 55 cc             	lea    -0x34(%ebp),%edx
     7a9:	52                   	push   %edx
     7aa:	50                   	push   %eax
     7ab:	e8 c2 0a 00 00       	call   1272 <stat>
     7b0:	83 c4 10             	add    $0x10,%esp
     7b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
     7b6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     7ba:	74 21                	je     7dd <doChmodTest+0xee>
     7bc:	83 ec 04             	sub    $0x4,%esp
     7bf:	68 39 1f 00 00       	push   $0x1f39
     7c4:	68 c4 19 00 00       	push   $0x19c4
     7c9:	6a 02                	push   $0x2
     7cb:	e8 2b 0e 00 00       	call   15fb <printf>
     7d0:	83 c4 10             	add    $0x10,%esp
     7d3:	b8 00 00 00 00       	mov    $0x0,%eax
     7d8:	e9 87 00 00 00       	jmp    864 <doChmodTest+0x175>
    testmode = st.mode.asInt;
     7dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     7e0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if (mode == testmode) {
     7e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
     7e6:	3b 45 e8             	cmp    -0x18(%ebp),%eax
     7e9:	75 3a                	jne    825 <doChmodTest+0x136>
      printf(2, "Error! Unable to test.\n");
     7eb:	83 ec 08             	sub    $0x8,%esp
     7ee:	68 4b 1f 00 00       	push   $0x1f4b
     7f3:	6a 02                	push   $0x2
     7f5:	e8 01 0e 00 00       	call   15fb <printf>
     7fa:	83 c4 10             	add    $0x10,%esp
      printf(2, "\tfile mode (%d) == testmode (%d) for file (%s) in test %d\n",
     7fd:	8b 45 08             	mov    0x8(%ebp),%eax
     800:	8b 00                	mov    (%eax),%eax
     802:	83 ec 08             	sub    $0x8,%esp
     805:	ff 75 f4             	pushl  -0xc(%ebp)
     808:	50                   	push   %eax
     809:	ff 75 e8             	pushl  -0x18(%ebp)
     80c:	ff 75 ec             	pushl  -0x14(%ebp)
     80f:	68 64 1f 00 00       	push   $0x1f64
     814:	6a 02                	push   $0x2
     816:	e8 e0 0d 00 00       	call   15fb <printf>
     81b:	83 c4 20             	add    $0x20,%esp
		     mode, testmode, cmd[0], i);
      return NOPASS;
     81e:	b8 00 00 00 00       	mov    $0x0,%eax
     823:	eb 3f                	jmp    864 <doChmodTest+0x175>
  printf(1, "\nExecuting chmod() test.\n\n");

  check(stat(cmd[0], &st));
  mode = st.mode.asInt;

  for (i=0; i<NUMPERMSTOCHECK; i++) {
     825:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     829:	a1 60 26 00 00       	mov    0x2660,%eax
     82e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
     831:	0f 8c 21 ff ff ff    	jl     758 <doChmodTest+0x69>
      printf(2, "\tfile mode (%d) == testmode (%d) for file (%s) in test %d\n",
		     mode, testmode, cmd[0], i);
      return NOPASS;
    }
  }
  chmod(cmd[0], 00755); // hack
     837:	8b 45 08             	mov    0x8(%ebp),%eax
     83a:	8b 00                	mov    (%eax),%eax
     83c:	83 ec 08             	sub    $0x8,%esp
     83f:	68 ed 01 00 00       	push   $0x1ed
     844:	50                   	push   %eax
     845:	e8 c2 0c 00 00       	call   150c <chmod>
     84a:	83 c4 10             	add    $0x10,%esp
  printf(1, "Test Passed\n");
     84d:	83 ec 08             	sub    $0x8,%esp
     850:	68 41 1c 00 00       	push   $0x1c41
     855:	6a 01                	push   $0x1
     857:	e8 9f 0d 00 00       	call   15fb <printf>
     85c:	83 c4 10             	add    $0x10,%esp
  return PASS;
     85f:	b8 01 00 00 00       	mov    $0x1,%eax
}
     864:	c9                   	leave  
     865:	c3                   	ret    

00000866 <doChownTest>:

static int
doChownTest(char **cmd) 
{
     866:	55                   	push   %ebp
     867:	89 e5                	mov    %esp,%ebp
     869:	83 ec 38             	sub    $0x38,%esp
  int rc, uid1, uid2;
  struct stat st;

  printf(1, "\nExecuting chown test.\n\n");
     86c:	83 ec 08             	sub    $0x8,%esp
     86f:	68 9f 1f 00 00       	push   $0x1f9f
     874:	6a 01                	push   $0x1
     876:	e8 80 0d 00 00       	call   15fb <printf>
     87b:	83 c4 10             	add    $0x10,%esp

  stat(cmd[0], &st);
     87e:	8b 45 08             	mov    0x8(%ebp),%eax
     881:	8b 00                	mov    (%eax),%eax
     883:	83 ec 08             	sub    $0x8,%esp
     886:	8d 55 d0             	lea    -0x30(%ebp),%edx
     889:	52                   	push   %edx
     88a:	50                   	push   %eax
     88b:	e8 e2 09 00 00       	call   1272 <stat>
     890:	83 c4 10             	add    $0x10,%esp
  uid1 = st.uid;
     893:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
     897:	0f b7 c0             	movzwl %ax,%eax
     89a:	89 45 f4             	mov    %eax,-0xc(%ebp)

  rc = chown(cmd[0], uid1+1);
     89d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     8a0:	8d 50 01             	lea    0x1(%eax),%edx
     8a3:	8b 45 08             	mov    0x8(%ebp),%eax
     8a6:	8b 00                	mov    (%eax),%eax
     8a8:	83 ec 08             	sub    $0x8,%esp
     8ab:	52                   	push   %edx
     8ac:	50                   	push   %eax
     8ad:	e8 62 0c 00 00       	call   1514 <chown>
     8b2:	83 c4 10             	add    $0x10,%esp
     8b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  printf(2, "rc = %d\n.", rc);
     8b8:	83 ec 04             	sub    $0x4,%esp
     8bb:	ff 75 f0             	pushl  -0x10(%ebp)
     8be:	68 b8 1f 00 00       	push   $0x1fb8
     8c3:	6a 02                	push   $0x2
     8c5:	e8 31 0d 00 00       	call   15fb <printf>
     8ca:	83 c4 10             	add    $0x10,%esp
  if (rc != 0) {
     8cd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     8d1:	74 1c                	je     8ef <doChownTest+0x89>
    printf(2, "Error! chown() failed on setting new owner. %d as rc.\n", rc);
     8d3:	83 ec 04             	sub    $0x4,%esp
     8d6:	ff 75 f0             	pushl  -0x10(%ebp)
     8d9:	68 c4 1f 00 00       	push   $0x1fc4
     8de:	6a 02                	push   $0x2
     8e0:	e8 16 0d 00 00       	call   15fb <printf>
     8e5:	83 c4 10             	add    $0x10,%esp
    return NOPASS;
     8e8:	b8 00 00 00 00       	mov    $0x0,%eax
     8ed:	eb 6e                	jmp    95d <doChownTest+0xf7>
  }

  stat(cmd[0], &st);
     8ef:	8b 45 08             	mov    0x8(%ebp),%eax
     8f2:	8b 00                	mov    (%eax),%eax
     8f4:	83 ec 08             	sub    $0x8,%esp
     8f7:	8d 55 d0             	lea    -0x30(%ebp),%edx
     8fa:	52                   	push   %edx
     8fb:	50                   	push   %eax
     8fc:	e8 71 09 00 00       	call   1272 <stat>
     901:	83 c4 10             	add    $0x10,%esp
  uid2 = st.uid;
     904:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
     908:	0f b7 c0             	movzwl %ax,%eax
     90b:	89 45 ec             	mov    %eax,-0x14(%ebp)

  if (uid1 == uid2) {
     90e:	8b 45 f4             	mov    -0xc(%ebp),%eax
     911:	3b 45 ec             	cmp    -0x14(%ebp),%eax
     914:	75 1c                	jne    932 <doChownTest+0xcc>
    printf(2, "Error! test failed. Old uid: %d, new uid: %d, should differ\n",
     916:	ff 75 ec             	pushl  -0x14(%ebp)
     919:	ff 75 f4             	pushl  -0xc(%ebp)
     91c:	68 fc 1f 00 00       	push   $0x1ffc
     921:	6a 02                	push   $0x2
     923:	e8 d3 0c 00 00       	call   15fb <printf>
     928:	83 c4 10             	add    $0x10,%esp
		    uid1, uid2);
    return NOPASS;
     92b:	b8 00 00 00 00       	mov    $0x0,%eax
     930:	eb 2b                	jmp    95d <doChownTest+0xf7>
  }
  chown(cmd[0], uid1);  // put back the original
     932:	8b 45 08             	mov    0x8(%ebp),%eax
     935:	8b 00                	mov    (%eax),%eax
     937:	83 ec 08             	sub    $0x8,%esp
     93a:	ff 75 f4             	pushl  -0xc(%ebp)
     93d:	50                   	push   %eax
     93e:	e8 d1 0b 00 00       	call   1514 <chown>
     943:	83 c4 10             	add    $0x10,%esp
  printf(1, "Test Passed\n");
     946:	83 ec 08             	sub    $0x8,%esp
     949:	68 41 1c 00 00       	push   $0x1c41
     94e:	6a 01                	push   $0x1
     950:	e8 a6 0c 00 00       	call   15fb <printf>
     955:	83 c4 10             	add    $0x10,%esp
  return PASS;
     958:	b8 01 00 00 00       	mov    $0x1,%eax
}
     95d:	c9                   	leave  
     95e:	c3                   	ret    

0000095f <doChgrpTest>:

static int
doChgrpTest(char **cmd) 
{
     95f:	55                   	push   %ebp
     960:	89 e5                	mov    %esp,%ebp
     962:	83 ec 38             	sub    $0x38,%esp
  int rc, gid1, gid2;
  struct stat st;

  printf(1, "\nExecuting chgrp test.\n\n");
     965:	83 ec 08             	sub    $0x8,%esp
     968:	68 39 20 00 00       	push   $0x2039
     96d:	6a 01                	push   $0x1
     96f:	e8 87 0c 00 00       	call   15fb <printf>
     974:	83 c4 10             	add    $0x10,%esp

  stat(cmd[0], &st);
     977:	8b 45 08             	mov    0x8(%ebp),%eax
     97a:	8b 00                	mov    (%eax),%eax
     97c:	83 ec 08             	sub    $0x8,%esp
     97f:	8d 55 d0             	lea    -0x30(%ebp),%edx
     982:	52                   	push   %edx
     983:	50                   	push   %eax
     984:	e8 e9 08 00 00       	call   1272 <stat>
     989:	83 c4 10             	add    $0x10,%esp
  gid1 = st.gid;
     98c:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
     990:	0f b7 c0             	movzwl %ax,%eax
     993:	89 45 f4             	mov    %eax,-0xc(%ebp)

  rc = chgrp(cmd[0], gid1+1);
     996:	8b 45 f4             	mov    -0xc(%ebp),%eax
     999:	8d 50 01             	lea    0x1(%eax),%edx
     99c:	8b 45 08             	mov    0x8(%ebp),%eax
     99f:	8b 00                	mov    (%eax),%eax
     9a1:	83 ec 08             	sub    $0x8,%esp
     9a4:	52                   	push   %edx
     9a5:	50                   	push   %eax
     9a6:	e8 71 0b 00 00       	call   151c <chgrp>
     9ab:	83 c4 10             	add    $0x10,%esp
     9ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if (rc != 0) {
     9b1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     9b5:	74 19                	je     9d0 <doChgrpTest+0x71>
    printf(2, "Error! chgrp() failed on setting new group.\n");
     9b7:	83 ec 08             	sub    $0x8,%esp
     9ba:	68 54 20 00 00       	push   $0x2054
     9bf:	6a 02                	push   $0x2
     9c1:	e8 35 0c 00 00       	call   15fb <printf>
     9c6:	83 c4 10             	add    $0x10,%esp
    return NOPASS;
     9c9:	b8 00 00 00 00       	mov    $0x0,%eax
     9ce:	eb 6e                	jmp    a3e <doChgrpTest+0xdf>
  }

  stat(cmd[0], &st);
     9d0:	8b 45 08             	mov    0x8(%ebp),%eax
     9d3:	8b 00                	mov    (%eax),%eax
     9d5:	83 ec 08             	sub    $0x8,%esp
     9d8:	8d 55 d0             	lea    -0x30(%ebp),%edx
     9db:	52                   	push   %edx
     9dc:	50                   	push   %eax
     9dd:	e8 90 08 00 00       	call   1272 <stat>
     9e2:	83 c4 10             	add    $0x10,%esp
  gid2 = st.gid;
     9e5:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
     9e9:	0f b7 c0             	movzwl %ax,%eax
     9ec:	89 45 ec             	mov    %eax,-0x14(%ebp)

  if (gid1 == gid2) {
     9ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
     9f2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
     9f5:	75 1c                	jne    a13 <doChgrpTest+0xb4>
    printf(2, "Error! test failed. Old gid: %d, new gid: gid2, should differ\n",
     9f7:	ff 75 ec             	pushl  -0x14(%ebp)
     9fa:	ff 75 f4             	pushl  -0xc(%ebp)
     9fd:	68 84 20 00 00       	push   $0x2084
     a02:	6a 02                	push   $0x2
     a04:	e8 f2 0b 00 00       	call   15fb <printf>
     a09:	83 c4 10             	add    $0x10,%esp
                    gid1, gid2);
    return NOPASS;
     a0c:	b8 00 00 00 00       	mov    $0x0,%eax
     a11:	eb 2b                	jmp    a3e <doChgrpTest+0xdf>
  }
  chgrp(cmd[0], gid1);  // put back the original
     a13:	8b 45 08             	mov    0x8(%ebp),%eax
     a16:	8b 00                	mov    (%eax),%eax
     a18:	83 ec 08             	sub    $0x8,%esp
     a1b:	ff 75 f4             	pushl  -0xc(%ebp)
     a1e:	50                   	push   %eax
     a1f:	e8 f8 0a 00 00       	call   151c <chgrp>
     a24:	83 c4 10             	add    $0x10,%esp
  printf(1, "Test Passed\n");
     a27:	83 ec 08             	sub    $0x8,%esp
     a2a:	68 41 1c 00 00       	push   $0x1c41
     a2f:	6a 01                	push   $0x1
     a31:	e8 c5 0b 00 00       	call   15fb <printf>
     a36:	83 c4 10             	add    $0x10,%esp
  return PASS;
     a39:	b8 01 00 00 00       	mov    $0x1,%eax
}
     a3e:	c9                   	leave  
     a3f:	c3                   	ret    

00000a40 <doExecTest>:

static int
doExecTest(char **cmd) 
{
     a40:	55                   	push   %ebp
     a41:	89 e5                	mov    %esp,%ebp
     a43:	83 ec 38             	sub    $0x38,%esp
  int i, rc, uid, gid;
  struct stat st;

  printf(1, "\nExecuting exec test.\n\n");
     a46:	83 ec 08             	sub    $0x8,%esp
     a49:	68 c3 20 00 00       	push   $0x20c3
     a4e:	6a 01                	push   $0x1
     a50:	e8 a6 0b 00 00       	call   15fb <printf>
     a55:	83 c4 10             	add    $0x10,%esp

  if (!canRun(cmd[0])) {
     a58:	8b 45 08             	mov    0x8(%ebp),%eax
     a5b:	8b 00                	mov    (%eax),%eax
     a5d:	83 ec 0c             	sub    $0xc,%esp
     a60:	50                   	push   %eax
     a61:	e8 9a f5 ff ff       	call   0 <canRun>
     a66:	83 c4 10             	add    $0x10,%esp
     a69:	85 c0                	test   %eax,%eax
     a6b:	75 22                	jne    a8f <doExecTest+0x4f>
    printf(2, "Unable to run %s. test aborted.\n", cmd[0]);
     a6d:	8b 45 08             	mov    0x8(%ebp),%eax
     a70:	8b 00                	mov    (%eax),%eax
     a72:	83 ec 04             	sub    $0x4,%esp
     a75:	50                   	push   %eax
     a76:	68 dc 20 00 00       	push   $0x20dc
     a7b:	6a 02                	push   $0x2
     a7d:	e8 79 0b 00 00       	call   15fb <printf>
     a82:	83 c4 10             	add    $0x10,%esp
    return NOPASS;
     a85:	b8 00 00 00 00       	mov    $0x0,%eax
     a8a:	e9 e4 02 00 00       	jmp    d73 <doExecTest+0x333>
  }

  check(stat(cmd[0], &st));
     a8f:	8b 45 08             	mov    0x8(%ebp),%eax
     a92:	8b 00                	mov    (%eax),%eax
     a94:	83 ec 08             	sub    $0x8,%esp
     a97:	8d 55 cc             	lea    -0x34(%ebp),%edx
     a9a:	52                   	push   %edx
     a9b:	50                   	push   %eax
     a9c:	e8 d1 07 00 00       	call   1272 <stat>
     aa1:	83 c4 10             	add    $0x10,%esp
     aa4:	89 45 f0             	mov    %eax,-0x10(%ebp)
     aa7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     aab:	74 21                	je     ace <doExecTest+0x8e>
     aad:	83 ec 04             	sub    $0x4,%esp
     ab0:	68 39 1f 00 00       	push   $0x1f39
     ab5:	68 c4 19 00 00       	push   $0x19c4
     aba:	6a 02                	push   $0x2
     abc:	e8 3a 0b 00 00       	call   15fb <printf>
     ac1:	83 c4 10             	add    $0x10,%esp
     ac4:	b8 00 00 00 00       	mov    $0x0,%eax
     ac9:	e9 a5 02 00 00       	jmp    d73 <doExecTest+0x333>
  uid = st.uid;
     ace:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
     ad2:	0f b7 c0             	movzwl %ax,%eax
     ad5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  gid = st.gid;
     ad8:	0f b7 45 e2          	movzwl -0x1e(%ebp),%eax
     adc:	0f b7 c0             	movzwl %ax,%eax
     adf:	89 45 e8             	mov    %eax,-0x18(%ebp)

  for (i=0; i<NUMPERMSTOCHECK; i++) {
     ae2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     ae9:	e9 22 02 00 00       	jmp    d10 <doExecTest+0x2d0>
    check(setuid(testperms[i][procuid]));
     aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
     af1:	c1 e0 04             	shl    $0x4,%eax
     af4:	05 80 26 00 00       	add    $0x2680,%eax
     af9:	8b 00                	mov    (%eax),%eax
     afb:	83 ec 0c             	sub    $0xc,%esp
     afe:	50                   	push   %eax
     aff:	e8 e8 09 00 00       	call   14ec <setuid>
     b04:	83 c4 10             	add    $0x10,%esp
     b07:	89 45 f0             	mov    %eax,-0x10(%ebp)
     b0a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     b0e:	74 21                	je     b31 <doExecTest+0xf1>
     b10:	83 ec 04             	sub    $0x4,%esp
     b13:	68 bd 1a 00 00       	push   $0x1abd
     b18:	68 c4 19 00 00       	push   $0x19c4
     b1d:	6a 02                	push   $0x2
     b1f:	e8 d7 0a 00 00       	call   15fb <printf>
     b24:	83 c4 10             	add    $0x10,%esp
     b27:	b8 00 00 00 00       	mov    $0x0,%eax
     b2c:	e9 42 02 00 00       	jmp    d73 <doExecTest+0x333>
    check(setgid(testperms[i][procgid]));
     b31:	8b 45 f4             	mov    -0xc(%ebp),%eax
     b34:	c1 e0 04             	shl    $0x4,%eax
     b37:	05 84 26 00 00       	add    $0x2684,%eax
     b3c:	8b 00                	mov    (%eax),%eax
     b3e:	83 ec 0c             	sub    $0xc,%esp
     b41:	50                   	push   %eax
     b42:	e8 ad 09 00 00       	call   14f4 <setgid>
     b47:	83 c4 10             	add    $0x10,%esp
     b4a:	89 45 f0             	mov    %eax,-0x10(%ebp)
     b4d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     b51:	74 21                	je     b74 <doExecTest+0x134>
     b53:	83 ec 04             	sub    $0x4,%esp
     b56:	68 db 1a 00 00       	push   $0x1adb
     b5b:	68 c4 19 00 00       	push   $0x19c4
     b60:	6a 02                	push   $0x2
     b62:	e8 94 0a 00 00       	call   15fb <printf>
     b67:	83 c4 10             	add    $0x10,%esp
     b6a:	b8 00 00 00 00       	mov    $0x0,%eax
     b6f:	e9 ff 01 00 00       	jmp    d73 <doExecTest+0x333>
    check(chown(cmd[0], testperms[i][fileuid]));
     b74:	8b 45 f4             	mov    -0xc(%ebp),%eax
     b77:	c1 e0 04             	shl    $0x4,%eax
     b7a:	05 88 26 00 00       	add    $0x2688,%eax
     b7f:	8b 10                	mov    (%eax),%edx
     b81:	8b 45 08             	mov    0x8(%ebp),%eax
     b84:	8b 00                	mov    (%eax),%eax
     b86:	83 ec 08             	sub    $0x8,%esp
     b89:	52                   	push   %edx
     b8a:	50                   	push   %eax
     b8b:	e8 84 09 00 00       	call   1514 <chown>
     b90:	83 c4 10             	add    $0x10,%esp
     b93:	89 45 f0             	mov    %eax,-0x10(%ebp)
     b96:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     b9a:	74 21                	je     bbd <doExecTest+0x17d>
     b9c:	83 ec 04             	sub    $0x4,%esp
     b9f:	68 14 1b 00 00       	push   $0x1b14
     ba4:	68 c4 19 00 00       	push   $0x19c4
     ba9:	6a 02                	push   $0x2
     bab:	e8 4b 0a 00 00       	call   15fb <printf>
     bb0:	83 c4 10             	add    $0x10,%esp
     bb3:	b8 00 00 00 00       	mov    $0x0,%eax
     bb8:	e9 b6 01 00 00       	jmp    d73 <doExecTest+0x333>
    check(chgrp(cmd[0], testperms[i][filegid]));
     bbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
     bc0:	c1 e0 04             	shl    $0x4,%eax
     bc3:	05 8c 26 00 00       	add    $0x268c,%eax
     bc8:	8b 10                	mov    (%eax),%edx
     bca:	8b 45 08             	mov    0x8(%ebp),%eax
     bcd:	8b 00                	mov    (%eax),%eax
     bcf:	83 ec 08             	sub    $0x8,%esp
     bd2:	52                   	push   %edx
     bd3:	50                   	push   %eax
     bd4:	e8 43 09 00 00       	call   151c <chgrp>
     bd9:	83 c4 10             	add    $0x10,%esp
     bdc:	89 45 f0             	mov    %eax,-0x10(%ebp)
     bdf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     be3:	74 21                	je     c06 <doExecTest+0x1c6>
     be5:	83 ec 04             	sub    $0x4,%esp
     be8:	68 3c 1b 00 00       	push   $0x1b3c
     bed:	68 c4 19 00 00       	push   $0x19c4
     bf2:	6a 02                	push   $0x2
     bf4:	e8 02 0a 00 00       	call   15fb <printf>
     bf9:	83 c4 10             	add    $0x10,%esp
     bfc:	b8 00 00 00 00       	mov    $0x0,%eax
     c01:	e9 6d 01 00 00       	jmp    d73 <doExecTest+0x333>
    check(chmod(cmd[0], perms[i]));
     c06:	8b 45 f4             	mov    -0xc(%ebp),%eax
     c09:	8b 14 85 64 26 00 00 	mov    0x2664(,%eax,4),%edx
     c10:	8b 45 08             	mov    0x8(%ebp),%eax
     c13:	8b 00                	mov    (%eax),%eax
     c15:	83 ec 08             	sub    $0x8,%esp
     c18:	52                   	push   %edx
     c19:	50                   	push   %eax
     c1a:	e8 ed 08 00 00       	call   150c <chmod>
     c1f:	83 c4 10             	add    $0x10,%esp
     c22:	89 45 f0             	mov    %eax,-0x10(%ebp)
     c25:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     c29:	74 21                	je     c4c <doExecTest+0x20c>
     c2b:	83 ec 04             	sub    $0x4,%esp
     c2e:	68 78 1b 00 00       	push   $0x1b78
     c33:	68 c4 19 00 00       	push   $0x19c4
     c38:	6a 02                	push   $0x2
     c3a:	e8 bc 09 00 00       	call   15fb <printf>
     c3f:	83 c4 10             	add    $0x10,%esp
     c42:	b8 00 00 00 00       	mov    $0x0,%eax
     c47:	e9 27 01 00 00       	jmp    d73 <doExecTest+0x333>
    if (i != NUMPERMSTOCHECK-1)
     c4c:	a1 60 26 00 00       	mov    0x2660,%eax
     c51:	83 e8 01             	sub    $0x1,%eax
     c54:	3b 45 f4             	cmp    -0xc(%ebp),%eax
     c57:	74 14                	je     c6d <doExecTest+0x22d>
      printf(2, "The following test should not produce an error.\n");
     c59:	83 ec 08             	sub    $0x8,%esp
     c5c:	68 00 21 00 00       	push   $0x2100
     c61:	6a 02                	push   $0x2
     c63:	e8 93 09 00 00       	call   15fb <printf>
     c68:	83 c4 10             	add    $0x10,%esp
     c6b:	eb 12                	jmp    c7f <doExecTest+0x23f>
    else
      printf(2, "The following test should fail.\n");
     c6d:	83 ec 08             	sub    $0x8,%esp
     c70:	68 34 21 00 00       	push   $0x2134
     c75:	6a 02                	push   $0x2
     c77:	e8 7f 09 00 00       	call   15fb <printf>
     c7c:	83 c4 10             	add    $0x10,%esp
    rc = fork();
     c7f:	e8 98 07 00 00       	call   141c <fork>
     c84:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (rc < 0) {    // fork failed
     c87:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     c8b:	79 1c                	jns    ca9 <doExecTest+0x269>
      printf(2, "The fork() system call failed. That's pretty catastrophic. Ending test\n");
     c8d:	83 ec 08             	sub    $0x8,%esp
     c90:	68 a8 1b 00 00       	push   $0x1ba8
     c95:	6a 02                	push   $0x2
     c97:	e8 5f 09 00 00       	call   15fb <printf>
     c9c:	83 c4 10             	add    $0x10,%esp
      return NOPASS;
     c9f:	b8 00 00 00 00       	mov    $0x0,%eax
     ca4:	e9 ca 00 00 00       	jmp    d73 <doExecTest+0x333>
    }
    if (rc == 0) {   // child
     ca9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     cad:	75 58                	jne    d07 <doExecTest+0x2c7>
      exec(cmd[0], cmd);
     caf:	8b 45 08             	mov    0x8(%ebp),%eax
     cb2:	8b 00                	mov    (%eax),%eax
     cb4:	83 ec 08             	sub    $0x8,%esp
     cb7:	ff 75 08             	pushl  0x8(%ebp)
     cba:	50                   	push   %eax
     cbb:	e8 9c 07 00 00       	call   145c <exec>
     cc0:	83 c4 10             	add    $0x10,%esp
      if (i != NUMPERMSTOCHECK-1) printf(2, "**** exec call for %s **FAILED**.\n",  cmd[0]);
     cc3:	a1 60 26 00 00       	mov    0x2660,%eax
     cc8:	83 e8 01             	sub    $0x1,%eax
     ccb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
     cce:	74 1a                	je     cea <doExecTest+0x2aa>
     cd0:	8b 45 08             	mov    0x8(%ebp),%eax
     cd3:	8b 00                	mov    (%eax),%eax
     cd5:	83 ec 04             	sub    $0x4,%esp
     cd8:	50                   	push   %eax
     cd9:	68 f0 1b 00 00       	push   $0x1bf0
     cde:	6a 02                	push   $0x2
     ce0:	e8 16 09 00 00       	call   15fb <printf>
     ce5:	83 c4 10             	add    $0x10,%esp
     ce8:	eb 18                	jmp    d02 <doExecTest+0x2c2>
      else printf(2, "**** exec call for %s **FAILED as expected.\n", cmd[0]);
     cea:	8b 45 08             	mov    0x8(%ebp),%eax
     ced:	8b 00                	mov    (%eax),%eax
     cef:	83 ec 04             	sub    $0x4,%esp
     cf2:	50                   	push   %eax
     cf3:	68 14 1c 00 00       	push   $0x1c14
     cf8:	6a 02                	push   $0x2
     cfa:	e8 fc 08 00 00       	call   15fb <printf>
     cff:	83 c4 10             	add    $0x10,%esp
      exit();
     d02:	e8 1d 07 00 00       	call   1424 <exit>
    }
    wait();
     d07:	e8 20 07 00 00       	call   142c <wait>

  check(stat(cmd[0], &st));
  uid = st.uid;
  gid = st.gid;

  for (i=0; i<NUMPERMSTOCHECK; i++) {
     d0c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     d10:	a1 60 26 00 00       	mov    0x2660,%eax
     d15:	39 45 f4             	cmp    %eax,-0xc(%ebp)
     d18:	0f 8c d0 fd ff ff    	jl     aee <doExecTest+0xae>
      else printf(2, "**** exec call for %s **FAILED as expected.\n", cmd[0]);
      exit();
    }
    wait();
  }
  chown(cmd[0], uid);
     d1e:	8b 45 08             	mov    0x8(%ebp),%eax
     d21:	8b 00                	mov    (%eax),%eax
     d23:	83 ec 08             	sub    $0x8,%esp
     d26:	ff 75 ec             	pushl  -0x14(%ebp)
     d29:	50                   	push   %eax
     d2a:	e8 e5 07 00 00       	call   1514 <chown>
     d2f:	83 c4 10             	add    $0x10,%esp
  chgrp(cmd[0], gid);
     d32:	8b 45 08             	mov    0x8(%ebp),%eax
     d35:	8b 00                	mov    (%eax),%eax
     d37:	83 ec 08             	sub    $0x8,%esp
     d3a:	ff 75 e8             	pushl  -0x18(%ebp)
     d3d:	50                   	push   %eax
     d3e:	e8 d9 07 00 00       	call   151c <chgrp>
     d43:	83 c4 10             	add    $0x10,%esp
  chmod(cmd[0], 00755);
     d46:	8b 45 08             	mov    0x8(%ebp),%eax
     d49:	8b 00                	mov    (%eax),%eax
     d4b:	83 ec 08             	sub    $0x8,%esp
     d4e:	68 ed 01 00 00       	push   $0x1ed
     d53:	50                   	push   %eax
     d54:	e8 b3 07 00 00       	call   150c <chmod>
     d59:	83 c4 10             	add    $0x10,%esp
  printf(1, "Requires user visually confirms PASS/FAIL\n");
     d5c:	83 ec 08             	sub    $0x8,%esp
     d5f:	68 58 21 00 00       	push   $0x2158
     d64:	6a 01                	push   $0x1
     d66:	e8 90 08 00 00       	call   15fb <printf>
     d6b:	83 c4 10             	add    $0x10,%esp
  return PASS;
     d6e:	b8 01 00 00 00       	mov    $0x1,%eax
}
     d73:	c9                   	leave  
     d74:	c3                   	ret    

00000d75 <printMenu>:

void
printMenu(void)
{
     d75:	55                   	push   %ebp
     d76:	89 e5                	mov    %esp,%ebp
     d78:	83 ec 18             	sub    $0x18,%esp
  int i = 0;
     d7b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  printf(1, "\n");
     d82:	83 ec 08             	sub    $0x8,%esp
     d85:	68 83 21 00 00       	push   $0x2183
     d8a:	6a 01                	push   $0x1
     d8c:	e8 6a 08 00 00       	call   15fb <printf>
     d91:	83 c4 10             	add    $0x10,%esp
  printf(1, "%d. exit program\n", i++);
     d94:	8b 45 f4             	mov    -0xc(%ebp),%eax
     d97:	8d 50 01             	lea    0x1(%eax),%edx
     d9a:	89 55 f4             	mov    %edx,-0xc(%ebp)
     d9d:	83 ec 04             	sub    $0x4,%esp
     da0:	50                   	push   %eax
     da1:	68 85 21 00 00       	push   $0x2185
     da6:	6a 01                	push   $0x1
     da8:	e8 4e 08 00 00       	call   15fb <printf>
     dad:	83 c4 10             	add    $0x10,%esp
  printf(1, "%d. Proc UID\n", i++);
     db0:	8b 45 f4             	mov    -0xc(%ebp),%eax
     db3:	8d 50 01             	lea    0x1(%eax),%edx
     db6:	89 55 f4             	mov    %edx,-0xc(%ebp)
     db9:	83 ec 04             	sub    $0x4,%esp
     dbc:	50                   	push   %eax
     dbd:	68 97 21 00 00       	push   $0x2197
     dc2:	6a 01                	push   $0x1
     dc4:	e8 32 08 00 00       	call   15fb <printf>
     dc9:	83 c4 10             	add    $0x10,%esp
  printf(1, "%d. Proc GID\n", i++);
     dcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
     dcf:	8d 50 01             	lea    0x1(%eax),%edx
     dd2:	89 55 f4             	mov    %edx,-0xc(%ebp)
     dd5:	83 ec 04             	sub    $0x4,%esp
     dd8:	50                   	push   %eax
     dd9:	68 a5 21 00 00       	push   $0x21a5
     dde:	6a 01                	push   $0x1
     de0:	e8 16 08 00 00       	call   15fb <printf>
     de5:	83 c4 10             	add    $0x10,%esp
  printf(1, "%d. chmod()\n", i++);
     de8:	8b 45 f4             	mov    -0xc(%ebp),%eax
     deb:	8d 50 01             	lea    0x1(%eax),%edx
     dee:	89 55 f4             	mov    %edx,-0xc(%ebp)
     df1:	83 ec 04             	sub    $0x4,%esp
     df4:	50                   	push   %eax
     df5:	68 b3 21 00 00       	push   $0x21b3
     dfa:	6a 01                	push   $0x1
     dfc:	e8 fa 07 00 00       	call   15fb <printf>
     e01:	83 c4 10             	add    $0x10,%esp
  printf(1, "%d. chown()\n", i++);
     e04:	8b 45 f4             	mov    -0xc(%ebp),%eax
     e07:	8d 50 01             	lea    0x1(%eax),%edx
     e0a:	89 55 f4             	mov    %edx,-0xc(%ebp)
     e0d:	83 ec 04             	sub    $0x4,%esp
     e10:	50                   	push   %eax
     e11:	68 c0 21 00 00       	push   $0x21c0
     e16:	6a 01                	push   $0x1
     e18:	e8 de 07 00 00       	call   15fb <printf>
     e1d:	83 c4 10             	add    $0x10,%esp
  printf(1, "%d. chgrp()\n", i++);
     e20:	8b 45 f4             	mov    -0xc(%ebp),%eax
     e23:	8d 50 01             	lea    0x1(%eax),%edx
     e26:	89 55 f4             	mov    %edx,-0xc(%ebp)
     e29:	83 ec 04             	sub    $0x4,%esp
     e2c:	50                   	push   %eax
     e2d:	68 cd 21 00 00       	push   $0x21cd
     e32:	6a 01                	push   $0x1
     e34:	e8 c2 07 00 00       	call   15fb <printf>
     e39:	83 c4 10             	add    $0x10,%esp
  printf(1, "%d. exec()\n", i++);
     e3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
     e3f:	8d 50 01             	lea    0x1(%eax),%edx
     e42:	89 55 f4             	mov    %edx,-0xc(%ebp)
     e45:	83 ec 04             	sub    $0x4,%esp
     e48:	50                   	push   %eax
     e49:	68 da 21 00 00       	push   $0x21da
     e4e:	6a 01                	push   $0x1
     e50:	e8 a6 07 00 00       	call   15fb <printf>
     e55:	83 c4 10             	add    $0x10,%esp
  printf(1, "%d. setuid\n", i++);
     e58:	8b 45 f4             	mov    -0xc(%ebp),%eax
     e5b:	8d 50 01             	lea    0x1(%eax),%edx
     e5e:	89 55 f4             	mov    %edx,-0xc(%ebp)
     e61:	83 ec 04             	sub    $0x4,%esp
     e64:	50                   	push   %eax
     e65:	68 e6 21 00 00       	push   $0x21e6
     e6a:	6a 01                	push   $0x1
     e6c:	e8 8a 07 00 00       	call   15fb <printf>
     e71:	83 c4 10             	add    $0x10,%esp
}
     e74:	90                   	nop
     e75:	c9                   	leave  
     e76:	c3                   	ret    

00000e77 <main>:

int
main(int argc, char *argv[])
{
     e77:	8d 4c 24 04          	lea    0x4(%esp),%ecx
     e7b:	83 e4 f0             	and    $0xfffffff0,%esp
     e7e:	ff 71 fc             	pushl  -0x4(%ecx)
     e81:	55                   	push   %ebp
     e82:	89 e5                	mov    %esp,%ebp
     e84:	51                   	push   %ecx
     e85:	83 ec 24             	sub    $0x24,%esp
  int rc, select, done;
  char buf[5];

  // test strings
  char *t0[] = {'\0'}; // dummy
     e88:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  char *t1[] = {"testsetuid", '\0'};
     e8f:	c7 45 d8 f2 21 00 00 	movl   $0x21f2,-0x28(%ebp)
     e96:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)

  while (1) {
    done = FALSE;
     e9d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    printMenu();
     ea4:	e8 cc fe ff ff       	call   d75 <printMenu>
    printf(1, "Enter test number: ");
     ea9:	83 ec 08             	sub    $0x8,%esp
     eac:	68 fd 21 00 00       	push   $0x21fd
     eb1:	6a 01                	push   $0x1
     eb3:	e8 43 07 00 00       	call   15fb <printf>
     eb8:	83 c4 10             	add    $0x10,%esp
    gets(buf, 5);
     ebb:	83 ec 08             	sub    $0x8,%esp
     ebe:	6a 05                	push   $0x5
     ec0:	8d 45 e7             	lea    -0x19(%ebp),%eax
     ec3:	50                   	push   %eax
     ec4:	e8 3a 03 00 00       	call   1203 <gets>
     ec9:	83 c4 10             	add    $0x10,%esp
    if ((buf[0] == '\n') || (buf[0] == '\0')) continue;
     ecc:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
     ed0:	3c 0a                	cmp    $0xa,%al
     ed2:	0f 84 f5 01 00 00    	je     10cd <main+0x256>
     ed8:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
     edc:	84 c0                	test   %al,%al
     ede:	0f 84 e9 01 00 00    	je     10cd <main+0x256>
    select = atoi(buf);
     ee4:	83 ec 0c             	sub    $0xc,%esp
     ee7:	8d 45 e7             	lea    -0x19(%ebp),%eax
     eea:	50                   	push   %eax
     eeb:	e8 cf 03 00 00       	call   12bf <atoi>
     ef0:	83 c4 10             	add    $0x10,%esp
     ef3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch (select) {
     ef6:	83 7d f0 07          	cmpl   $0x7,-0x10(%ebp)
     efa:	0f 87 9b 01 00 00    	ja     109b <main+0x224>
     f00:	8b 45 f0             	mov    -0x10(%ebp),%eax
     f03:	c1 e0 02             	shl    $0x2,%eax
     f06:	05 a0 22 00 00       	add    $0x22a0,%eax
     f0b:	8b 00                	mov    (%eax),%eax
     f0d:	ff e0                	jmp    *%eax
	    case 0: done = TRUE; break;
     f0f:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
     f16:	e9 a7 01 00 00       	jmp    10c2 <main+0x24b>
	    case 1:
		  doTest(doUidTest,    t0); break;
     f1b:	83 ec 0c             	sub    $0xc,%esp
     f1e:	8d 45 e0             	lea    -0x20(%ebp),%eax
     f21:	50                   	push   %eax
     f22:	e8 b6 f4 ff ff       	call   3dd <doUidTest>
     f27:	83 c4 10             	add    $0x10,%esp
     f2a:	89 45 ec             	mov    %eax,-0x14(%ebp)
     f2d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     f31:	0f 85 78 01 00 00    	jne    10af <main+0x238>
     f37:	83 ec 04             	sub    $0x4,%esp
     f3a:	68 11 22 00 00       	push   $0x2211
     f3f:	68 1b 22 00 00       	push   $0x221b
     f44:	6a 02                	push   $0x2
     f46:	e8 b0 06 00 00       	call   15fb <printf>
     f4b:	83 c4 10             	add    $0x10,%esp
     f4e:	e8 d1 04 00 00       	call   1424 <exit>
	    case 2:
		  doTest(doGidTest,    t0); break;
     f53:	83 ec 0c             	sub    $0xc,%esp
     f56:	8d 45 e0             	lea    -0x20(%ebp),%eax
     f59:	50                   	push   %eax
     f5a:	e8 07 f6 ff ff       	call   566 <doGidTest>
     f5f:	83 c4 10             	add    $0x10,%esp
     f62:	89 45 ec             	mov    %eax,-0x14(%ebp)
     f65:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     f69:	0f 85 43 01 00 00    	jne    10b2 <main+0x23b>
     f6f:	83 ec 04             	sub    $0x4,%esp
     f72:	68 2d 22 00 00       	push   $0x222d
     f77:	68 1b 22 00 00       	push   $0x221b
     f7c:	6a 02                	push   $0x2
     f7e:	e8 78 06 00 00       	call   15fb <printf>
     f83:	83 c4 10             	add    $0x10,%esp
     f86:	e8 99 04 00 00       	call   1424 <exit>
	    case 3:
		  doTest(doChmodTest,  t1); break;
     f8b:	83 ec 0c             	sub    $0xc,%esp
     f8e:	8d 45 d8             	lea    -0x28(%ebp),%eax
     f91:	50                   	push   %eax
     f92:	e8 58 f7 ff ff       	call   6ef <doChmodTest>
     f97:	83 c4 10             	add    $0x10,%esp
     f9a:	89 45 ec             	mov    %eax,-0x14(%ebp)
     f9d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     fa1:	0f 85 0e 01 00 00    	jne    10b5 <main+0x23e>
     fa7:	83 ec 04             	sub    $0x4,%esp
     faa:	68 37 22 00 00       	push   $0x2237
     faf:	68 1b 22 00 00       	push   $0x221b
     fb4:	6a 02                	push   $0x2
     fb6:	e8 40 06 00 00       	call   15fb <printf>
     fbb:	83 c4 10             	add    $0x10,%esp
     fbe:	e8 61 04 00 00       	call   1424 <exit>
	    case 4:
		  doTest(doChownTest,  t1); break;
     fc3:	83 ec 0c             	sub    $0xc,%esp
     fc6:	8d 45 d8             	lea    -0x28(%ebp),%eax
     fc9:	50                   	push   %eax
     fca:	e8 97 f8 ff ff       	call   866 <doChownTest>
     fcf:	83 c4 10             	add    $0x10,%esp
     fd2:	89 45 ec             	mov    %eax,-0x14(%ebp)
     fd5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     fd9:	0f 85 d9 00 00 00    	jne    10b8 <main+0x241>
     fdf:	83 ec 04             	sub    $0x4,%esp
     fe2:	68 43 22 00 00       	push   $0x2243
     fe7:	68 1b 22 00 00       	push   $0x221b
     fec:	6a 02                	push   $0x2
     fee:	e8 08 06 00 00       	call   15fb <printf>
     ff3:	83 c4 10             	add    $0x10,%esp
     ff6:	e8 29 04 00 00       	call   1424 <exit>
	    case 5:
		  doTest(doChgrpTest,  t1); break;
     ffb:	83 ec 0c             	sub    $0xc,%esp
     ffe:	8d 45 d8             	lea    -0x28(%ebp),%eax
    1001:	50                   	push   %eax
    1002:	e8 58 f9 ff ff       	call   95f <doChgrpTest>
    1007:	83 c4 10             	add    $0x10,%esp
    100a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    100d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1011:	0f 85 a4 00 00 00    	jne    10bb <main+0x244>
    1017:	83 ec 04             	sub    $0x4,%esp
    101a:	68 4f 22 00 00       	push   $0x224f
    101f:	68 1b 22 00 00       	push   $0x221b
    1024:	6a 02                	push   $0x2
    1026:	e8 d0 05 00 00       	call   15fb <printf>
    102b:	83 c4 10             	add    $0x10,%esp
    102e:	e8 f1 03 00 00       	call   1424 <exit>
	    case 6:
		  doTest(doExecTest,   t1); break;
    1033:	83 ec 0c             	sub    $0xc,%esp
    1036:	8d 45 d8             	lea    -0x28(%ebp),%eax
    1039:	50                   	push   %eax
    103a:	e8 01 fa ff ff       	call   a40 <doExecTest>
    103f:	83 c4 10             	add    $0x10,%esp
    1042:	89 45 ec             	mov    %eax,-0x14(%ebp)
    1045:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1049:	75 73                	jne    10be <main+0x247>
    104b:	83 ec 04             	sub    $0x4,%esp
    104e:	68 5b 22 00 00       	push   $0x225b
    1053:	68 1b 22 00 00       	push   $0x221b
    1058:	6a 02                	push   $0x2
    105a:	e8 9c 05 00 00       	call   15fb <printf>
    105f:	83 c4 10             	add    $0x10,%esp
    1062:	e8 bd 03 00 00       	call   1424 <exit>
	    case 7:
		  doTest(doSetuidTest, t1); break;
    1067:	83 ec 0c             	sub    $0xc,%esp
    106a:	8d 45 d8             	lea    -0x28(%ebp),%eax
    106d:	50                   	push   %eax
    106e:	e8 78 f0 ff ff       	call   eb <doSetuidTest>
    1073:	83 c4 10             	add    $0x10,%esp
    1076:	89 45 ec             	mov    %eax,-0x14(%ebp)
    1079:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    107d:	75 42                	jne    10c1 <main+0x24a>
    107f:	83 ec 04             	sub    $0x4,%esp
    1082:	68 66 22 00 00       	push   $0x2266
    1087:	68 1b 22 00 00       	push   $0x221b
    108c:	6a 02                	push   $0x2
    108e:	e8 68 05 00 00       	call   15fb <printf>
    1093:	83 c4 10             	add    $0x10,%esp
    1096:	e8 89 03 00 00       	call   1424 <exit>
	    default:
		   printf(1, "Error:invalid test number.\n");
    109b:	83 ec 08             	sub    $0x8,%esp
    109e:	68 73 22 00 00       	push   $0x2273
    10a3:	6a 01                	push   $0x1
    10a5:	e8 51 05 00 00       	call   15fb <printf>
    10aa:	83 c4 10             	add    $0x10,%esp
    10ad:	eb 13                	jmp    10c2 <main+0x24b>
    if ((buf[0] == '\n') || (buf[0] == '\0')) continue;
    select = atoi(buf);
    switch (select) {
	    case 0: done = TRUE; break;
	    case 1:
		  doTest(doUidTest,    t0); break;
    10af:	90                   	nop
    10b0:	eb 10                	jmp    10c2 <main+0x24b>
	    case 2:
		  doTest(doGidTest,    t0); break;
    10b2:	90                   	nop
    10b3:	eb 0d                	jmp    10c2 <main+0x24b>
	    case 3:
		  doTest(doChmodTest,  t1); break;
    10b5:	90                   	nop
    10b6:	eb 0a                	jmp    10c2 <main+0x24b>
	    case 4:
		  doTest(doChownTest,  t1); break;
    10b8:	90                   	nop
    10b9:	eb 07                	jmp    10c2 <main+0x24b>
	    case 5:
		  doTest(doChgrpTest,  t1); break;
    10bb:	90                   	nop
    10bc:	eb 04                	jmp    10c2 <main+0x24b>
	    case 6:
		  doTest(doExecTest,   t1); break;
    10be:	90                   	nop
    10bf:	eb 01                	jmp    10c2 <main+0x24b>
	    case 7:
		  doTest(doSetuidTest, t1); break;
    10c1:	90                   	nop
	    default:
		   printf(1, "Error:invalid test number.\n");
    }

    if (done) break;
    10c2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    10c6:	75 0b                	jne    10d3 <main+0x25c>
    10c8:	e9 d0 fd ff ff       	jmp    e9d <main+0x26>
  while (1) {
    done = FALSE;
    printMenu();
    printf(1, "Enter test number: ");
    gets(buf, 5);
    if ((buf[0] == '\n') || (buf[0] == '\0')) continue;
    10cd:	90                   	nop
	    default:
		   printf(1, "Error:invalid test number.\n");
    }

    if (done) break;
  }
    10ce:	e9 ca fd ff ff       	jmp    e9d <main+0x26>
		  doTest(doSetuidTest, t1); break;
	    default:
		   printf(1, "Error:invalid test number.\n");
    }

    if (done) break;
    10d3:	90                   	nop
  }

  printf(1, "\nDone for now\n");
    10d4:	83 ec 08             	sub    $0x8,%esp
    10d7:	68 8f 22 00 00       	push   $0x228f
    10dc:	6a 01                	push   $0x1
    10de:	e8 18 05 00 00       	call   15fb <printf>
    10e3:	83 c4 10             	add    $0x10,%esp
  free(buf);
    10e6:	83 ec 0c             	sub    $0xc,%esp
    10e9:	8d 45 e7             	lea    -0x19(%ebp),%eax
    10ec:	50                   	push   %eax
    10ed:	e8 9a 06 00 00       	call   178c <free>
    10f2:	83 c4 10             	add    $0x10,%esp
  exit();
    10f5:	e8 2a 03 00 00       	call   1424 <exit>

000010fa <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
    10fa:	55                   	push   %ebp
    10fb:	89 e5                	mov    %esp,%ebp
    10fd:	57                   	push   %edi
    10fe:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
    10ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
    1102:	8b 55 10             	mov    0x10(%ebp),%edx
    1105:	8b 45 0c             	mov    0xc(%ebp),%eax
    1108:	89 cb                	mov    %ecx,%ebx
    110a:	89 df                	mov    %ebx,%edi
    110c:	89 d1                	mov    %edx,%ecx
    110e:	fc                   	cld    
    110f:	f3 aa                	rep stos %al,%es:(%edi)
    1111:	89 ca                	mov    %ecx,%edx
    1113:	89 fb                	mov    %edi,%ebx
    1115:	89 5d 08             	mov    %ebx,0x8(%ebp)
    1118:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
    111b:	90                   	nop
    111c:	5b                   	pop    %ebx
    111d:	5f                   	pop    %edi
    111e:	5d                   	pop    %ebp
    111f:	c3                   	ret    

00001120 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
    1120:	55                   	push   %ebp
    1121:	89 e5                	mov    %esp,%ebp
    1123:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
    1126:	8b 45 08             	mov    0x8(%ebp),%eax
    1129:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
    112c:	90                   	nop
    112d:	8b 45 08             	mov    0x8(%ebp),%eax
    1130:	8d 50 01             	lea    0x1(%eax),%edx
    1133:	89 55 08             	mov    %edx,0x8(%ebp)
    1136:	8b 55 0c             	mov    0xc(%ebp),%edx
    1139:	8d 4a 01             	lea    0x1(%edx),%ecx
    113c:	89 4d 0c             	mov    %ecx,0xc(%ebp)
    113f:	0f b6 12             	movzbl (%edx),%edx
    1142:	88 10                	mov    %dl,(%eax)
    1144:	0f b6 00             	movzbl (%eax),%eax
    1147:	84 c0                	test   %al,%al
    1149:	75 e2                	jne    112d <strcpy+0xd>
    ;
  return os;
    114b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    114e:	c9                   	leave  
    114f:	c3                   	ret    

00001150 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    1150:	55                   	push   %ebp
    1151:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
    1153:	eb 08                	jmp    115d <strcmp+0xd>
    p++, q++;
    1155:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    1159:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    115d:	8b 45 08             	mov    0x8(%ebp),%eax
    1160:	0f b6 00             	movzbl (%eax),%eax
    1163:	84 c0                	test   %al,%al
    1165:	74 10                	je     1177 <strcmp+0x27>
    1167:	8b 45 08             	mov    0x8(%ebp),%eax
    116a:	0f b6 10             	movzbl (%eax),%edx
    116d:	8b 45 0c             	mov    0xc(%ebp),%eax
    1170:	0f b6 00             	movzbl (%eax),%eax
    1173:	38 c2                	cmp    %al,%dl
    1175:	74 de                	je     1155 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
    1177:	8b 45 08             	mov    0x8(%ebp),%eax
    117a:	0f b6 00             	movzbl (%eax),%eax
    117d:	0f b6 d0             	movzbl %al,%edx
    1180:	8b 45 0c             	mov    0xc(%ebp),%eax
    1183:	0f b6 00             	movzbl (%eax),%eax
    1186:	0f b6 c0             	movzbl %al,%eax
    1189:	29 c2                	sub    %eax,%edx
    118b:	89 d0                	mov    %edx,%eax
}
    118d:	5d                   	pop    %ebp
    118e:	c3                   	ret    

0000118f <strlen>:

uint
strlen(char *s)
{
    118f:	55                   	push   %ebp
    1190:	89 e5                	mov    %esp,%ebp
    1192:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
    1195:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    119c:	eb 04                	jmp    11a2 <strlen+0x13>
    119e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    11a2:	8b 55 fc             	mov    -0x4(%ebp),%edx
    11a5:	8b 45 08             	mov    0x8(%ebp),%eax
    11a8:	01 d0                	add    %edx,%eax
    11aa:	0f b6 00             	movzbl (%eax),%eax
    11ad:	84 c0                	test   %al,%al
    11af:	75 ed                	jne    119e <strlen+0xf>
    ;
  return n;
    11b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    11b4:	c9                   	leave  
    11b5:	c3                   	ret    

000011b6 <memset>:

void*
memset(void *dst, int c, uint n)
{
    11b6:	55                   	push   %ebp
    11b7:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
    11b9:	8b 45 10             	mov    0x10(%ebp),%eax
    11bc:	50                   	push   %eax
    11bd:	ff 75 0c             	pushl  0xc(%ebp)
    11c0:	ff 75 08             	pushl  0x8(%ebp)
    11c3:	e8 32 ff ff ff       	call   10fa <stosb>
    11c8:	83 c4 0c             	add    $0xc,%esp
  return dst;
    11cb:	8b 45 08             	mov    0x8(%ebp),%eax
}
    11ce:	c9                   	leave  
    11cf:	c3                   	ret    

000011d0 <strchr>:

char*
strchr(const char *s, char c)
{
    11d0:	55                   	push   %ebp
    11d1:	89 e5                	mov    %esp,%ebp
    11d3:	83 ec 04             	sub    $0x4,%esp
    11d6:	8b 45 0c             	mov    0xc(%ebp),%eax
    11d9:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
    11dc:	eb 14                	jmp    11f2 <strchr+0x22>
    if(*s == c)
    11de:	8b 45 08             	mov    0x8(%ebp),%eax
    11e1:	0f b6 00             	movzbl (%eax),%eax
    11e4:	3a 45 fc             	cmp    -0x4(%ebp),%al
    11e7:	75 05                	jne    11ee <strchr+0x1e>
      return (char*)s;
    11e9:	8b 45 08             	mov    0x8(%ebp),%eax
    11ec:	eb 13                	jmp    1201 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    11ee:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    11f2:	8b 45 08             	mov    0x8(%ebp),%eax
    11f5:	0f b6 00             	movzbl (%eax),%eax
    11f8:	84 c0                	test   %al,%al
    11fa:	75 e2                	jne    11de <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
    11fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
    1201:	c9                   	leave  
    1202:	c3                   	ret    

00001203 <gets>:

char*
gets(char *buf, int max)
{
    1203:	55                   	push   %ebp
    1204:	89 e5                	mov    %esp,%ebp
    1206:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    1209:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1210:	eb 42                	jmp    1254 <gets+0x51>
    cc = read(0, &c, 1);
    1212:	83 ec 04             	sub    $0x4,%esp
    1215:	6a 01                	push   $0x1
    1217:	8d 45 ef             	lea    -0x11(%ebp),%eax
    121a:	50                   	push   %eax
    121b:	6a 00                	push   $0x0
    121d:	e8 1a 02 00 00       	call   143c <read>
    1222:	83 c4 10             	add    $0x10,%esp
    1225:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
    1228:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    122c:	7e 33                	jle    1261 <gets+0x5e>
      break;
    buf[i++] = c;
    122e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1231:	8d 50 01             	lea    0x1(%eax),%edx
    1234:	89 55 f4             	mov    %edx,-0xc(%ebp)
    1237:	89 c2                	mov    %eax,%edx
    1239:	8b 45 08             	mov    0x8(%ebp),%eax
    123c:	01 c2                	add    %eax,%edx
    123e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    1242:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
    1244:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    1248:	3c 0a                	cmp    $0xa,%al
    124a:	74 16                	je     1262 <gets+0x5f>
    124c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    1250:	3c 0d                	cmp    $0xd,%al
    1252:	74 0e                	je     1262 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    1254:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1257:	83 c0 01             	add    $0x1,%eax
    125a:	3b 45 0c             	cmp    0xc(%ebp),%eax
    125d:	7c b3                	jl     1212 <gets+0xf>
    125f:	eb 01                	jmp    1262 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    1261:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    1262:	8b 55 f4             	mov    -0xc(%ebp),%edx
    1265:	8b 45 08             	mov    0x8(%ebp),%eax
    1268:	01 d0                	add    %edx,%eax
    126a:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    126d:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1270:	c9                   	leave  
    1271:	c3                   	ret    

00001272 <stat>:

int
stat(char *n, struct stat *st)
{
    1272:	55                   	push   %ebp
    1273:	89 e5                	mov    %esp,%ebp
    1275:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    1278:	83 ec 08             	sub    $0x8,%esp
    127b:	6a 00                	push   $0x0
    127d:	ff 75 08             	pushl  0x8(%ebp)
    1280:	e8 df 01 00 00       	call   1464 <open>
    1285:	83 c4 10             	add    $0x10,%esp
    1288:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    128b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    128f:	79 07                	jns    1298 <stat+0x26>
    return -1;
    1291:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    1296:	eb 25                	jmp    12bd <stat+0x4b>
  r = fstat(fd, st);
    1298:	83 ec 08             	sub    $0x8,%esp
    129b:	ff 75 0c             	pushl  0xc(%ebp)
    129e:	ff 75 f4             	pushl  -0xc(%ebp)
    12a1:	e8 d6 01 00 00       	call   147c <fstat>
    12a6:	83 c4 10             	add    $0x10,%esp
    12a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    12ac:	83 ec 0c             	sub    $0xc,%esp
    12af:	ff 75 f4             	pushl  -0xc(%ebp)
    12b2:	e8 95 01 00 00       	call   144c <close>
    12b7:	83 c4 10             	add    $0x10,%esp
  return r;
    12ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    12bd:	c9                   	leave  
    12be:	c3                   	ret    

000012bf <atoi>:

int
atoi(const char *s)
{
    12bf:	55                   	push   %ebp
    12c0:	89 e5                	mov    %esp,%ebp
    12c2:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
    12c5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
    12cc:	eb 04                	jmp    12d2 <atoi+0x13>
    12ce:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    12d2:	8b 45 08             	mov    0x8(%ebp),%eax
    12d5:	0f b6 00             	movzbl (%eax),%eax
    12d8:	3c 20                	cmp    $0x20,%al
    12da:	74 f2                	je     12ce <atoi+0xf>
  sign = (*s == '-') ? -1 : 1;
    12dc:	8b 45 08             	mov    0x8(%ebp),%eax
    12df:	0f b6 00             	movzbl (%eax),%eax
    12e2:	3c 2d                	cmp    $0x2d,%al
    12e4:	75 07                	jne    12ed <atoi+0x2e>
    12e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    12eb:	eb 05                	jmp    12f2 <atoi+0x33>
    12ed:	b8 01 00 00 00       	mov    $0x1,%eax
    12f2:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
    12f5:	8b 45 08             	mov    0x8(%ebp),%eax
    12f8:	0f b6 00             	movzbl (%eax),%eax
    12fb:	3c 2b                	cmp    $0x2b,%al
    12fd:	74 0a                	je     1309 <atoi+0x4a>
    12ff:	8b 45 08             	mov    0x8(%ebp),%eax
    1302:	0f b6 00             	movzbl (%eax),%eax
    1305:	3c 2d                	cmp    $0x2d,%al
    1307:	75 2b                	jne    1334 <atoi+0x75>
    s++;
    1309:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '9')
    130d:	eb 25                	jmp    1334 <atoi+0x75>
    n = n*10 + *s++ - '0';
    130f:	8b 55 fc             	mov    -0x4(%ebp),%edx
    1312:	89 d0                	mov    %edx,%eax
    1314:	c1 e0 02             	shl    $0x2,%eax
    1317:	01 d0                	add    %edx,%eax
    1319:	01 c0                	add    %eax,%eax
    131b:	89 c1                	mov    %eax,%ecx
    131d:	8b 45 08             	mov    0x8(%ebp),%eax
    1320:	8d 50 01             	lea    0x1(%eax),%edx
    1323:	89 55 08             	mov    %edx,0x8(%ebp)
    1326:	0f b6 00             	movzbl (%eax),%eax
    1329:	0f be c0             	movsbl %al,%eax
    132c:	01 c8                	add    %ecx,%eax
    132e:	83 e8 30             	sub    $0x30,%eax
    1331:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '9')
    1334:	8b 45 08             	mov    0x8(%ebp),%eax
    1337:	0f b6 00             	movzbl (%eax),%eax
    133a:	3c 2f                	cmp    $0x2f,%al
    133c:	7e 0a                	jle    1348 <atoi+0x89>
    133e:	8b 45 08             	mov    0x8(%ebp),%eax
    1341:	0f b6 00             	movzbl (%eax),%eax
    1344:	3c 39                	cmp    $0x39,%al
    1346:	7e c7                	jle    130f <atoi+0x50>
    n = n*10 + *s++ - '0';
  return sign*n;
    1348:	8b 45 f8             	mov    -0x8(%ebp),%eax
    134b:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
    134f:	c9                   	leave  
    1350:	c3                   	ret    

00001351 <atoo>:

int
atoo(const char *s)
{
    1351:	55                   	push   %ebp
    1352:	89 e5                	mov    %esp,%ebp
    1354:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
    1357:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
    135e:	eb 04                	jmp    1364 <atoo+0x13>
    1360:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    1364:	8b 45 08             	mov    0x8(%ebp),%eax
    1367:	0f b6 00             	movzbl (%eax),%eax
    136a:	3c 20                	cmp    $0x20,%al
    136c:	74 f2                	je     1360 <atoo+0xf>
  sign = (*s == '-') ? -1 : 1;
    136e:	8b 45 08             	mov    0x8(%ebp),%eax
    1371:	0f b6 00             	movzbl (%eax),%eax
    1374:	3c 2d                	cmp    $0x2d,%al
    1376:	75 07                	jne    137f <atoo+0x2e>
    1378:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    137d:	eb 05                	jmp    1384 <atoo+0x33>
    137f:	b8 01 00 00 00       	mov    $0x1,%eax
    1384:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
    1387:	8b 45 08             	mov    0x8(%ebp),%eax
    138a:	0f b6 00             	movzbl (%eax),%eax
    138d:	3c 2b                	cmp    $0x2b,%al
    138f:	74 0a                	je     139b <atoo+0x4a>
    1391:	8b 45 08             	mov    0x8(%ebp),%eax
    1394:	0f b6 00             	movzbl (%eax),%eax
    1397:	3c 2d                	cmp    $0x2d,%al
    1399:	75 27                	jne    13c2 <atoo+0x71>
    s++;
    139b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '7')
    139f:	eb 21                	jmp    13c2 <atoo+0x71>
    n = n*8 + *s++ - '0';
    13a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
    13a4:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
    13ab:	8b 45 08             	mov    0x8(%ebp),%eax
    13ae:	8d 50 01             	lea    0x1(%eax),%edx
    13b1:	89 55 08             	mov    %edx,0x8(%ebp)
    13b4:	0f b6 00             	movzbl (%eax),%eax
    13b7:	0f be c0             	movsbl %al,%eax
    13ba:	01 c8                	add    %ecx,%eax
    13bc:	83 e8 30             	sub    $0x30,%eax
    13bf:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '7')
    13c2:	8b 45 08             	mov    0x8(%ebp),%eax
    13c5:	0f b6 00             	movzbl (%eax),%eax
    13c8:	3c 2f                	cmp    $0x2f,%al
    13ca:	7e 0a                	jle    13d6 <atoo+0x85>
    13cc:	8b 45 08             	mov    0x8(%ebp),%eax
    13cf:	0f b6 00             	movzbl (%eax),%eax
    13d2:	3c 37                	cmp    $0x37,%al
    13d4:	7e cb                	jle    13a1 <atoo+0x50>
    n = n*8 + *s++ - '0';
  return sign*n;
    13d6:	8b 45 f8             	mov    -0x8(%ebp),%eax
    13d9:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
    13dd:	c9                   	leave  
    13de:	c3                   	ret    

000013df <memmove>:


void*
memmove(void *vdst, void *vsrc, int n)
{
    13df:	55                   	push   %ebp
    13e0:	89 e5                	mov    %esp,%ebp
    13e2:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
    13e5:	8b 45 08             	mov    0x8(%ebp),%eax
    13e8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    13eb:	8b 45 0c             	mov    0xc(%ebp),%eax
    13ee:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    13f1:	eb 17                	jmp    140a <memmove+0x2b>
    *dst++ = *src++;
    13f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
    13f6:	8d 50 01             	lea    0x1(%eax),%edx
    13f9:	89 55 fc             	mov    %edx,-0x4(%ebp)
    13fc:	8b 55 f8             	mov    -0x8(%ebp),%edx
    13ff:	8d 4a 01             	lea    0x1(%edx),%ecx
    1402:	89 4d f8             	mov    %ecx,-0x8(%ebp)
    1405:	0f b6 12             	movzbl (%edx),%edx
    1408:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    140a:	8b 45 10             	mov    0x10(%ebp),%eax
    140d:	8d 50 ff             	lea    -0x1(%eax),%edx
    1410:	89 55 10             	mov    %edx,0x10(%ebp)
    1413:	85 c0                	test   %eax,%eax
    1415:	7f dc                	jg     13f3 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    1417:	8b 45 08             	mov    0x8(%ebp),%eax
}
    141a:	c9                   	leave  
    141b:	c3                   	ret    

0000141c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    141c:	b8 01 00 00 00       	mov    $0x1,%eax
    1421:	cd 40                	int    $0x40
    1423:	c3                   	ret    

00001424 <exit>:
SYSCALL(exit)
    1424:	b8 02 00 00 00       	mov    $0x2,%eax
    1429:	cd 40                	int    $0x40
    142b:	c3                   	ret    

0000142c <wait>:
SYSCALL(wait)
    142c:	b8 03 00 00 00       	mov    $0x3,%eax
    1431:	cd 40                	int    $0x40
    1433:	c3                   	ret    

00001434 <pipe>:
SYSCALL(pipe)
    1434:	b8 04 00 00 00       	mov    $0x4,%eax
    1439:	cd 40                	int    $0x40
    143b:	c3                   	ret    

0000143c <read>:
SYSCALL(read)
    143c:	b8 05 00 00 00       	mov    $0x5,%eax
    1441:	cd 40                	int    $0x40
    1443:	c3                   	ret    

00001444 <write>:
SYSCALL(write)
    1444:	b8 10 00 00 00       	mov    $0x10,%eax
    1449:	cd 40                	int    $0x40
    144b:	c3                   	ret    

0000144c <close>:
SYSCALL(close)
    144c:	b8 15 00 00 00       	mov    $0x15,%eax
    1451:	cd 40                	int    $0x40
    1453:	c3                   	ret    

00001454 <kill>:
SYSCALL(kill)
    1454:	b8 06 00 00 00       	mov    $0x6,%eax
    1459:	cd 40                	int    $0x40
    145b:	c3                   	ret    

0000145c <exec>:
SYSCALL(exec)
    145c:	b8 07 00 00 00       	mov    $0x7,%eax
    1461:	cd 40                	int    $0x40
    1463:	c3                   	ret    

00001464 <open>:
SYSCALL(open)
    1464:	b8 0f 00 00 00       	mov    $0xf,%eax
    1469:	cd 40                	int    $0x40
    146b:	c3                   	ret    

0000146c <mknod>:
SYSCALL(mknod)
    146c:	b8 11 00 00 00       	mov    $0x11,%eax
    1471:	cd 40                	int    $0x40
    1473:	c3                   	ret    

00001474 <unlink>:
SYSCALL(unlink)
    1474:	b8 12 00 00 00       	mov    $0x12,%eax
    1479:	cd 40                	int    $0x40
    147b:	c3                   	ret    

0000147c <fstat>:
SYSCALL(fstat)
    147c:	b8 08 00 00 00       	mov    $0x8,%eax
    1481:	cd 40                	int    $0x40
    1483:	c3                   	ret    

00001484 <link>:
SYSCALL(link)
    1484:	b8 13 00 00 00       	mov    $0x13,%eax
    1489:	cd 40                	int    $0x40
    148b:	c3                   	ret    

0000148c <mkdir>:
SYSCALL(mkdir)
    148c:	b8 14 00 00 00       	mov    $0x14,%eax
    1491:	cd 40                	int    $0x40
    1493:	c3                   	ret    

00001494 <chdir>:
SYSCALL(chdir)
    1494:	b8 09 00 00 00       	mov    $0x9,%eax
    1499:	cd 40                	int    $0x40
    149b:	c3                   	ret    

0000149c <dup>:
SYSCALL(dup)
    149c:	b8 0a 00 00 00       	mov    $0xa,%eax
    14a1:	cd 40                	int    $0x40
    14a3:	c3                   	ret    

000014a4 <getpid>:
SYSCALL(getpid)
    14a4:	b8 0b 00 00 00       	mov    $0xb,%eax
    14a9:	cd 40                	int    $0x40
    14ab:	c3                   	ret    

000014ac <sbrk>:
SYSCALL(sbrk)
    14ac:	b8 0c 00 00 00       	mov    $0xc,%eax
    14b1:	cd 40                	int    $0x40
    14b3:	c3                   	ret    

000014b4 <sleep>:
SYSCALL(sleep)
    14b4:	b8 0d 00 00 00       	mov    $0xd,%eax
    14b9:	cd 40                	int    $0x40
    14bb:	c3                   	ret    

000014bc <uptime>:
SYSCALL(uptime)
    14bc:	b8 0e 00 00 00       	mov    $0xe,%eax
    14c1:	cd 40                	int    $0x40
    14c3:	c3                   	ret    

000014c4 <halt>:
SYSCALL(halt)
    14c4:	b8 16 00 00 00       	mov    $0x16,%eax
    14c9:	cd 40                	int    $0x40
    14cb:	c3                   	ret    

000014cc <date>:
SYSCALL(date)
    14cc:	b8 17 00 00 00       	mov    $0x17,%eax
    14d1:	cd 40                	int    $0x40
    14d3:	c3                   	ret    

000014d4 <getuid>:
SYSCALL(getuid)
    14d4:	b8 18 00 00 00       	mov    $0x18,%eax
    14d9:	cd 40                	int    $0x40
    14db:	c3                   	ret    

000014dc <getgid>:
SYSCALL(getgid)
    14dc:	b8 19 00 00 00       	mov    $0x19,%eax
    14e1:	cd 40                	int    $0x40
    14e3:	c3                   	ret    

000014e4 <getppid>:
SYSCALL(getppid)
    14e4:	b8 1a 00 00 00       	mov    $0x1a,%eax
    14e9:	cd 40                	int    $0x40
    14eb:	c3                   	ret    

000014ec <setuid>:
SYSCALL(setuid)
    14ec:	b8 1b 00 00 00       	mov    $0x1b,%eax
    14f1:	cd 40                	int    $0x40
    14f3:	c3                   	ret    

000014f4 <setgid>:
SYSCALL(setgid)
    14f4:	b8 1c 00 00 00       	mov    $0x1c,%eax
    14f9:	cd 40                	int    $0x40
    14fb:	c3                   	ret    

000014fc <getprocs>:
SYSCALL(getprocs)
    14fc:	b8 1d 00 00 00       	mov    $0x1d,%eax
    1501:	cd 40                	int    $0x40
    1503:	c3                   	ret    

00001504 <setpriority>:
SYSCALL(setpriority)
    1504:	b8 1e 00 00 00       	mov    $0x1e,%eax
    1509:	cd 40                	int    $0x40
    150b:	c3                   	ret    

0000150c <chmod>:
SYSCALL(chmod)
    150c:	b8 1f 00 00 00       	mov    $0x1f,%eax
    1511:	cd 40                	int    $0x40
    1513:	c3                   	ret    

00001514 <chown>:
SYSCALL(chown)
    1514:	b8 20 00 00 00       	mov    $0x20,%eax
    1519:	cd 40                	int    $0x40
    151b:	c3                   	ret    

0000151c <chgrp>:
SYSCALL(chgrp)
    151c:	b8 21 00 00 00       	mov    $0x21,%eax
    1521:	cd 40                	int    $0x40
    1523:	c3                   	ret    

00001524 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    1524:	55                   	push   %ebp
    1525:	89 e5                	mov    %esp,%ebp
    1527:	83 ec 18             	sub    $0x18,%esp
    152a:	8b 45 0c             	mov    0xc(%ebp),%eax
    152d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    1530:	83 ec 04             	sub    $0x4,%esp
    1533:	6a 01                	push   $0x1
    1535:	8d 45 f4             	lea    -0xc(%ebp),%eax
    1538:	50                   	push   %eax
    1539:	ff 75 08             	pushl  0x8(%ebp)
    153c:	e8 03 ff ff ff       	call   1444 <write>
    1541:	83 c4 10             	add    $0x10,%esp
}
    1544:	90                   	nop
    1545:	c9                   	leave  
    1546:	c3                   	ret    

00001547 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    1547:	55                   	push   %ebp
    1548:	89 e5                	mov    %esp,%ebp
    154a:	53                   	push   %ebx
    154b:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    154e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    1555:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    1559:	74 17                	je     1572 <printint+0x2b>
    155b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    155f:	79 11                	jns    1572 <printint+0x2b>
    neg = 1;
    1561:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    1568:	8b 45 0c             	mov    0xc(%ebp),%eax
    156b:	f7 d8                	neg    %eax
    156d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    1570:	eb 06                	jmp    1578 <printint+0x31>
  } else {
    x = xx;
    1572:	8b 45 0c             	mov    0xc(%ebp),%eax
    1575:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    1578:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    157f:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    1582:	8d 41 01             	lea    0x1(%ecx),%eax
    1585:	89 45 f4             	mov    %eax,-0xc(%ebp)
    1588:	8b 5d 10             	mov    0x10(%ebp),%ebx
    158b:	8b 45 ec             	mov    -0x14(%ebp),%eax
    158e:	ba 00 00 00 00       	mov    $0x0,%edx
    1593:	f7 f3                	div    %ebx
    1595:	89 d0                	mov    %edx,%eax
    1597:	0f b6 80 c0 26 00 00 	movzbl 0x26c0(%eax),%eax
    159e:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    15a2:	8b 5d 10             	mov    0x10(%ebp),%ebx
    15a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
    15a8:	ba 00 00 00 00       	mov    $0x0,%edx
    15ad:	f7 f3                	div    %ebx
    15af:	89 45 ec             	mov    %eax,-0x14(%ebp)
    15b2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    15b6:	75 c7                	jne    157f <printint+0x38>
  if(neg)
    15b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    15bc:	74 2d                	je     15eb <printint+0xa4>
    buf[i++] = '-';
    15be:	8b 45 f4             	mov    -0xc(%ebp),%eax
    15c1:	8d 50 01             	lea    0x1(%eax),%edx
    15c4:	89 55 f4             	mov    %edx,-0xc(%ebp)
    15c7:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    15cc:	eb 1d                	jmp    15eb <printint+0xa4>
    putc(fd, buf[i]);
    15ce:	8d 55 dc             	lea    -0x24(%ebp),%edx
    15d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    15d4:	01 d0                	add    %edx,%eax
    15d6:	0f b6 00             	movzbl (%eax),%eax
    15d9:	0f be c0             	movsbl %al,%eax
    15dc:	83 ec 08             	sub    $0x8,%esp
    15df:	50                   	push   %eax
    15e0:	ff 75 08             	pushl  0x8(%ebp)
    15e3:	e8 3c ff ff ff       	call   1524 <putc>
    15e8:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    15eb:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    15ef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    15f3:	79 d9                	jns    15ce <printint+0x87>
    putc(fd, buf[i]);
}
    15f5:	90                   	nop
    15f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    15f9:	c9                   	leave  
    15fa:	c3                   	ret    

000015fb <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    15fb:	55                   	push   %ebp
    15fc:	89 e5                	mov    %esp,%ebp
    15fe:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    1601:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    1608:	8d 45 0c             	lea    0xc(%ebp),%eax
    160b:	83 c0 04             	add    $0x4,%eax
    160e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    1611:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    1618:	e9 59 01 00 00       	jmp    1776 <printf+0x17b>
    c = fmt[i] & 0xff;
    161d:	8b 55 0c             	mov    0xc(%ebp),%edx
    1620:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1623:	01 d0                	add    %edx,%eax
    1625:	0f b6 00             	movzbl (%eax),%eax
    1628:	0f be c0             	movsbl %al,%eax
    162b:	25 ff 00 00 00       	and    $0xff,%eax
    1630:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    1633:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1637:	75 2c                	jne    1665 <printf+0x6a>
      if(c == '%'){
    1639:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    163d:	75 0c                	jne    164b <printf+0x50>
        state = '%';
    163f:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    1646:	e9 27 01 00 00       	jmp    1772 <printf+0x177>
      } else {
        putc(fd, c);
    164b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    164e:	0f be c0             	movsbl %al,%eax
    1651:	83 ec 08             	sub    $0x8,%esp
    1654:	50                   	push   %eax
    1655:	ff 75 08             	pushl  0x8(%ebp)
    1658:	e8 c7 fe ff ff       	call   1524 <putc>
    165d:	83 c4 10             	add    $0x10,%esp
    1660:	e9 0d 01 00 00       	jmp    1772 <printf+0x177>
      }
    } else if(state == '%'){
    1665:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    1669:	0f 85 03 01 00 00    	jne    1772 <printf+0x177>
      if(c == 'd'){
    166f:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    1673:	75 1e                	jne    1693 <printf+0x98>
        printint(fd, *ap, 10, 1);
    1675:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1678:	8b 00                	mov    (%eax),%eax
    167a:	6a 01                	push   $0x1
    167c:	6a 0a                	push   $0xa
    167e:	50                   	push   %eax
    167f:	ff 75 08             	pushl  0x8(%ebp)
    1682:	e8 c0 fe ff ff       	call   1547 <printint>
    1687:	83 c4 10             	add    $0x10,%esp
        ap++;
    168a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    168e:	e9 d8 00 00 00       	jmp    176b <printf+0x170>
      } else if(c == 'x' || c == 'p'){
    1693:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    1697:	74 06                	je     169f <printf+0xa4>
    1699:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    169d:	75 1e                	jne    16bd <printf+0xc2>
        printint(fd, *ap, 16, 0);
    169f:	8b 45 e8             	mov    -0x18(%ebp),%eax
    16a2:	8b 00                	mov    (%eax),%eax
    16a4:	6a 00                	push   $0x0
    16a6:	6a 10                	push   $0x10
    16a8:	50                   	push   %eax
    16a9:	ff 75 08             	pushl  0x8(%ebp)
    16ac:	e8 96 fe ff ff       	call   1547 <printint>
    16b1:	83 c4 10             	add    $0x10,%esp
        ap++;
    16b4:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    16b8:	e9 ae 00 00 00       	jmp    176b <printf+0x170>
      } else if(c == 's'){
    16bd:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    16c1:	75 43                	jne    1706 <printf+0x10b>
        s = (char*)*ap;
    16c3:	8b 45 e8             	mov    -0x18(%ebp),%eax
    16c6:	8b 00                	mov    (%eax),%eax
    16c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    16cb:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    16cf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    16d3:	75 25                	jne    16fa <printf+0xff>
          s = "(null)";
    16d5:	c7 45 f4 c0 22 00 00 	movl   $0x22c0,-0xc(%ebp)
        while(*s != 0){
    16dc:	eb 1c                	jmp    16fa <printf+0xff>
          putc(fd, *s);
    16de:	8b 45 f4             	mov    -0xc(%ebp),%eax
    16e1:	0f b6 00             	movzbl (%eax),%eax
    16e4:	0f be c0             	movsbl %al,%eax
    16e7:	83 ec 08             	sub    $0x8,%esp
    16ea:	50                   	push   %eax
    16eb:	ff 75 08             	pushl  0x8(%ebp)
    16ee:	e8 31 fe ff ff       	call   1524 <putc>
    16f3:	83 c4 10             	add    $0x10,%esp
          s++;
    16f6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    16fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
    16fd:	0f b6 00             	movzbl (%eax),%eax
    1700:	84 c0                	test   %al,%al
    1702:	75 da                	jne    16de <printf+0xe3>
    1704:	eb 65                	jmp    176b <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    1706:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    170a:	75 1d                	jne    1729 <printf+0x12e>
        putc(fd, *ap);
    170c:	8b 45 e8             	mov    -0x18(%ebp),%eax
    170f:	8b 00                	mov    (%eax),%eax
    1711:	0f be c0             	movsbl %al,%eax
    1714:	83 ec 08             	sub    $0x8,%esp
    1717:	50                   	push   %eax
    1718:	ff 75 08             	pushl  0x8(%ebp)
    171b:	e8 04 fe ff ff       	call   1524 <putc>
    1720:	83 c4 10             	add    $0x10,%esp
        ap++;
    1723:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1727:	eb 42                	jmp    176b <printf+0x170>
      } else if(c == '%'){
    1729:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    172d:	75 17                	jne    1746 <printf+0x14b>
        putc(fd, c);
    172f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1732:	0f be c0             	movsbl %al,%eax
    1735:	83 ec 08             	sub    $0x8,%esp
    1738:	50                   	push   %eax
    1739:	ff 75 08             	pushl  0x8(%ebp)
    173c:	e8 e3 fd ff ff       	call   1524 <putc>
    1741:	83 c4 10             	add    $0x10,%esp
    1744:	eb 25                	jmp    176b <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    1746:	83 ec 08             	sub    $0x8,%esp
    1749:	6a 25                	push   $0x25
    174b:	ff 75 08             	pushl  0x8(%ebp)
    174e:	e8 d1 fd ff ff       	call   1524 <putc>
    1753:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
    1756:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1759:	0f be c0             	movsbl %al,%eax
    175c:	83 ec 08             	sub    $0x8,%esp
    175f:	50                   	push   %eax
    1760:	ff 75 08             	pushl  0x8(%ebp)
    1763:	e8 bc fd ff ff       	call   1524 <putc>
    1768:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
    176b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    1772:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    1776:	8b 55 0c             	mov    0xc(%ebp),%edx
    1779:	8b 45 f0             	mov    -0x10(%ebp),%eax
    177c:	01 d0                	add    %edx,%eax
    177e:	0f b6 00             	movzbl (%eax),%eax
    1781:	84 c0                	test   %al,%al
    1783:	0f 85 94 fe ff ff    	jne    161d <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    1789:	90                   	nop
    178a:	c9                   	leave  
    178b:	c3                   	ret    

0000178c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    178c:	55                   	push   %ebp
    178d:	89 e5                	mov    %esp,%ebp
    178f:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1792:	8b 45 08             	mov    0x8(%ebp),%eax
    1795:	83 e8 08             	sub    $0x8,%eax
    1798:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    179b:	a1 dc 26 00 00       	mov    0x26dc,%eax
    17a0:	89 45 fc             	mov    %eax,-0x4(%ebp)
    17a3:	eb 24                	jmp    17c9 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    17a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
    17a8:	8b 00                	mov    (%eax),%eax
    17aa:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    17ad:	77 12                	ja     17c1 <free+0x35>
    17af:	8b 45 f8             	mov    -0x8(%ebp),%eax
    17b2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    17b5:	77 24                	ja     17db <free+0x4f>
    17b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
    17ba:	8b 00                	mov    (%eax),%eax
    17bc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    17bf:	77 1a                	ja     17db <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    17c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
    17c4:	8b 00                	mov    (%eax),%eax
    17c6:	89 45 fc             	mov    %eax,-0x4(%ebp)
    17c9:	8b 45 f8             	mov    -0x8(%ebp),%eax
    17cc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    17cf:	76 d4                	jbe    17a5 <free+0x19>
    17d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
    17d4:	8b 00                	mov    (%eax),%eax
    17d6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    17d9:	76 ca                	jbe    17a5 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    17db:	8b 45 f8             	mov    -0x8(%ebp),%eax
    17de:	8b 40 04             	mov    0x4(%eax),%eax
    17e1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    17e8:	8b 45 f8             	mov    -0x8(%ebp),%eax
    17eb:	01 c2                	add    %eax,%edx
    17ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
    17f0:	8b 00                	mov    (%eax),%eax
    17f2:	39 c2                	cmp    %eax,%edx
    17f4:	75 24                	jne    181a <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    17f6:	8b 45 f8             	mov    -0x8(%ebp),%eax
    17f9:	8b 50 04             	mov    0x4(%eax),%edx
    17fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
    17ff:	8b 00                	mov    (%eax),%eax
    1801:	8b 40 04             	mov    0x4(%eax),%eax
    1804:	01 c2                	add    %eax,%edx
    1806:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1809:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    180c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    180f:	8b 00                	mov    (%eax),%eax
    1811:	8b 10                	mov    (%eax),%edx
    1813:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1816:	89 10                	mov    %edx,(%eax)
    1818:	eb 0a                	jmp    1824 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    181a:	8b 45 fc             	mov    -0x4(%ebp),%eax
    181d:	8b 10                	mov    (%eax),%edx
    181f:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1822:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    1824:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1827:	8b 40 04             	mov    0x4(%eax),%eax
    182a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    1831:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1834:	01 d0                	add    %edx,%eax
    1836:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1839:	75 20                	jne    185b <free+0xcf>
    p->s.size += bp->s.size;
    183b:	8b 45 fc             	mov    -0x4(%ebp),%eax
    183e:	8b 50 04             	mov    0x4(%eax),%edx
    1841:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1844:	8b 40 04             	mov    0x4(%eax),%eax
    1847:	01 c2                	add    %eax,%edx
    1849:	8b 45 fc             	mov    -0x4(%ebp),%eax
    184c:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    184f:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1852:	8b 10                	mov    (%eax),%edx
    1854:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1857:	89 10                	mov    %edx,(%eax)
    1859:	eb 08                	jmp    1863 <free+0xd7>
  } else
    p->s.ptr = bp;
    185b:	8b 45 fc             	mov    -0x4(%ebp),%eax
    185e:	8b 55 f8             	mov    -0x8(%ebp),%edx
    1861:	89 10                	mov    %edx,(%eax)
  freep = p;
    1863:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1866:	a3 dc 26 00 00       	mov    %eax,0x26dc
}
    186b:	90                   	nop
    186c:	c9                   	leave  
    186d:	c3                   	ret    

0000186e <morecore>:

static Header*
morecore(uint nu)
{
    186e:	55                   	push   %ebp
    186f:	89 e5                	mov    %esp,%ebp
    1871:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    1874:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    187b:	77 07                	ja     1884 <morecore+0x16>
    nu = 4096;
    187d:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    1884:	8b 45 08             	mov    0x8(%ebp),%eax
    1887:	c1 e0 03             	shl    $0x3,%eax
    188a:	83 ec 0c             	sub    $0xc,%esp
    188d:	50                   	push   %eax
    188e:	e8 19 fc ff ff       	call   14ac <sbrk>
    1893:	83 c4 10             	add    $0x10,%esp
    1896:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    1899:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    189d:	75 07                	jne    18a6 <morecore+0x38>
    return 0;
    189f:	b8 00 00 00 00       	mov    $0x0,%eax
    18a4:	eb 26                	jmp    18cc <morecore+0x5e>
  hp = (Header*)p;
    18a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
    18a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    18ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
    18af:	8b 55 08             	mov    0x8(%ebp),%edx
    18b2:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    18b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
    18b8:	83 c0 08             	add    $0x8,%eax
    18bb:	83 ec 0c             	sub    $0xc,%esp
    18be:	50                   	push   %eax
    18bf:	e8 c8 fe ff ff       	call   178c <free>
    18c4:	83 c4 10             	add    $0x10,%esp
  return freep;
    18c7:	a1 dc 26 00 00       	mov    0x26dc,%eax
}
    18cc:	c9                   	leave  
    18cd:	c3                   	ret    

000018ce <malloc>:

void*
malloc(uint nbytes)
{
    18ce:	55                   	push   %ebp
    18cf:	89 e5                	mov    %esp,%ebp
    18d1:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    18d4:	8b 45 08             	mov    0x8(%ebp),%eax
    18d7:	83 c0 07             	add    $0x7,%eax
    18da:	c1 e8 03             	shr    $0x3,%eax
    18dd:	83 c0 01             	add    $0x1,%eax
    18e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    18e3:	a1 dc 26 00 00       	mov    0x26dc,%eax
    18e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    18eb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    18ef:	75 23                	jne    1914 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    18f1:	c7 45 f0 d4 26 00 00 	movl   $0x26d4,-0x10(%ebp)
    18f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
    18fb:	a3 dc 26 00 00       	mov    %eax,0x26dc
    1900:	a1 dc 26 00 00       	mov    0x26dc,%eax
    1905:	a3 d4 26 00 00       	mov    %eax,0x26d4
    base.s.size = 0;
    190a:	c7 05 d8 26 00 00 00 	movl   $0x0,0x26d8
    1911:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1914:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1917:	8b 00                	mov    (%eax),%eax
    1919:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    191c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    191f:	8b 40 04             	mov    0x4(%eax),%eax
    1922:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1925:	72 4d                	jb     1974 <malloc+0xa6>
      if(p->s.size == nunits)
    1927:	8b 45 f4             	mov    -0xc(%ebp),%eax
    192a:	8b 40 04             	mov    0x4(%eax),%eax
    192d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1930:	75 0c                	jne    193e <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    1932:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1935:	8b 10                	mov    (%eax),%edx
    1937:	8b 45 f0             	mov    -0x10(%ebp),%eax
    193a:	89 10                	mov    %edx,(%eax)
    193c:	eb 26                	jmp    1964 <malloc+0x96>
      else {
        p->s.size -= nunits;
    193e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1941:	8b 40 04             	mov    0x4(%eax),%eax
    1944:	2b 45 ec             	sub    -0x14(%ebp),%eax
    1947:	89 c2                	mov    %eax,%edx
    1949:	8b 45 f4             	mov    -0xc(%ebp),%eax
    194c:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    194f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1952:	8b 40 04             	mov    0x4(%eax),%eax
    1955:	c1 e0 03             	shl    $0x3,%eax
    1958:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    195b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    195e:	8b 55 ec             	mov    -0x14(%ebp),%edx
    1961:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    1964:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1967:	a3 dc 26 00 00       	mov    %eax,0x26dc
      return (void*)(p + 1);
    196c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    196f:	83 c0 08             	add    $0x8,%eax
    1972:	eb 3b                	jmp    19af <malloc+0xe1>
    }
    if(p == freep)
    1974:	a1 dc 26 00 00       	mov    0x26dc,%eax
    1979:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    197c:	75 1e                	jne    199c <malloc+0xce>
      if((p = morecore(nunits)) == 0)
    197e:	83 ec 0c             	sub    $0xc,%esp
    1981:	ff 75 ec             	pushl  -0x14(%ebp)
    1984:	e8 e5 fe ff ff       	call   186e <morecore>
    1989:	83 c4 10             	add    $0x10,%esp
    198c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    198f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1993:	75 07                	jne    199c <malloc+0xce>
        return 0;
    1995:	b8 00 00 00 00       	mov    $0x0,%eax
    199a:	eb 13                	jmp    19af <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    199c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    199f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    19a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    19a5:	8b 00                	mov    (%eax),%eax
    19a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    19aa:	e9 6d ff ff ff       	jmp    191c <malloc+0x4e>
}
    19af:	c9                   	leave  
    19b0:	c3                   	ret    
