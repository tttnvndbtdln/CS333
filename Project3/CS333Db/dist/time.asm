
_time:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#ifdef CS333_P2
#include "types.h"
#include "user.h"
int
main(int argc, char * argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	53                   	push   %ebx
   e:	51                   	push   %ecx
   f:	83 ec 20             	sub    $0x20,%esp
  12:	89 cb                	mov    %ecx,%ebx
  int start_time = 0;
  14:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  int end_time = 0;
  1b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  int sec, mili, num;

  start_time = uptime();
  22:	e8 9d 04 00 00       	call   4c4 <uptime>
  27:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(argc == 1)
  2a:	83 3b 01             	cmpl   $0x1,(%ebx)
  2d:	75 17                	jne    46 <main+0x46>
  {
    printf(2, "Ran in 0.00 seconds.\n\n");
  2f:	83 ec 08             	sub    $0x8,%esp
  32:	68 99 09 00 00       	push   $0x999
  37:	6a 02                	push   $0x2
  39:	e8 a5 05 00 00       	call   5e3 <printf>
  3e:	83 c4 10             	add    $0x10,%esp
    exit();
  41:	e8 e6 03 00 00       	call   42c <exit>
  }

  num = fork();
  46:	e8 d9 03 00 00       	call   424 <fork>
  4b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  if (num)
  4e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  52:	74 07                	je     5b <main+0x5b>
    wait();
  54:	e8 db 03 00 00       	call   434 <wait>
  59:	eb 36                	jmp    91 <main+0x91>

  else
  {
    if(exec(argv[1], argv+1) == 0)
  5b:	8b 43 04             	mov    0x4(%ebx),%eax
  5e:	8d 50 04             	lea    0x4(%eax),%edx
  61:	8b 43 04             	mov    0x4(%ebx),%eax
  64:	83 c0 04             	add    $0x4,%eax
  67:	8b 00                	mov    (%eax),%eax
  69:	83 ec 08             	sub    $0x8,%esp
  6c:	52                   	push   %edx
  6d:	50                   	push   %eax
  6e:	e8 f1 03 00 00       	call   464 <exec>
  73:	83 c4 10             	add    $0x10,%esp
  76:	85 c0                	test   %eax,%eax
  78:	75 17                	jne    91 <main+0x91>
    {
      printf(2, "Error. Test failed.\n");
  7a:	83 ec 08             	sub    $0x8,%esp
  7d:	68 b0 09 00 00       	push   $0x9b0
  82:	6a 02                	push   $0x2
  84:	e8 5a 05 00 00       	call   5e3 <printf>
  89:	83 c4 10             	add    $0x10,%esp
      exit();
  8c:	e8 9b 03 00 00       	call   42c <exit>
    }
  }

  end_time = uptime() - start_time;
  91:	e8 2e 04 00 00       	call   4c4 <uptime>
  96:	2b 45 f4             	sub    -0xc(%ebp),%eax
  99:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  sec = end_time / 1000;
  9c:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  9f:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
  a4:	89 c8                	mov    %ecx,%eax
  a6:	f7 ea                	imul   %edx
  a8:	c1 fa 06             	sar    $0x6,%edx
  ab:	89 c8                	mov    %ecx,%eax
  ad:	c1 f8 1f             	sar    $0x1f,%eax
  b0:	29 c2                	sub    %eax,%edx
  b2:	89 d0                	mov    %edx,%eax
  b4:	89 45 e8             	mov    %eax,-0x18(%ebp)
  mili = end_time % 1000;
  b7:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  ba:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
  bf:	89 c8                	mov    %ecx,%eax
  c1:	f7 ea                	imul   %edx
  c3:	c1 fa 06             	sar    $0x6,%edx
  c6:	89 c8                	mov    %ecx,%eax
  c8:	c1 f8 1f             	sar    $0x1f,%eax
  cb:	29 c2                	sub    %eax,%edx
  cd:	89 d0                	mov    %edx,%eax
  cf:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
  d5:	29 c1                	sub    %eax,%ecx
  d7:	89 c8                	mov    %ecx,%eax
  d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)

  printf(2, "%s ran in %d.%d seconds.\n\n", argv[1], sec, mili);
  dc:	8b 43 04             	mov    0x4(%ebx),%eax
  df:	83 c0 04             	add    $0x4,%eax
  e2:	8b 00                	mov    (%eax),%eax
  e4:	83 ec 0c             	sub    $0xc,%esp
  e7:	ff 75 e4             	pushl  -0x1c(%ebp)
  ea:	ff 75 e8             	pushl  -0x18(%ebp)
  ed:	50                   	push   %eax
  ee:	68 c5 09 00 00       	push   $0x9c5
  f3:	6a 02                	push   $0x2
  f5:	e8 e9 04 00 00       	call   5e3 <printf>
  fa:	83 c4 20             	add    $0x20,%esp

  exit();
  fd:	e8 2a 03 00 00       	call   42c <exit>

00000102 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 102:	55                   	push   %ebp
 103:	89 e5                	mov    %esp,%ebp
 105:	57                   	push   %edi
 106:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 107:	8b 4d 08             	mov    0x8(%ebp),%ecx
 10a:	8b 55 10             	mov    0x10(%ebp),%edx
 10d:	8b 45 0c             	mov    0xc(%ebp),%eax
 110:	89 cb                	mov    %ecx,%ebx
 112:	89 df                	mov    %ebx,%edi
 114:	89 d1                	mov    %edx,%ecx
 116:	fc                   	cld    
 117:	f3 aa                	rep stos %al,%es:(%edi)
 119:	89 ca                	mov    %ecx,%edx
 11b:	89 fb                	mov    %edi,%ebx
 11d:	89 5d 08             	mov    %ebx,0x8(%ebp)
 120:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 123:	90                   	nop
 124:	5b                   	pop    %ebx
 125:	5f                   	pop    %edi
 126:	5d                   	pop    %ebp
 127:	c3                   	ret    

00000128 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 128:	55                   	push   %ebp
 129:	89 e5                	mov    %esp,%ebp
 12b:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 12e:	8b 45 08             	mov    0x8(%ebp),%eax
 131:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 134:	90                   	nop
 135:	8b 45 08             	mov    0x8(%ebp),%eax
 138:	8d 50 01             	lea    0x1(%eax),%edx
 13b:	89 55 08             	mov    %edx,0x8(%ebp)
 13e:	8b 55 0c             	mov    0xc(%ebp),%edx
 141:	8d 4a 01             	lea    0x1(%edx),%ecx
 144:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 147:	0f b6 12             	movzbl (%edx),%edx
 14a:	88 10                	mov    %dl,(%eax)
 14c:	0f b6 00             	movzbl (%eax),%eax
 14f:	84 c0                	test   %al,%al
 151:	75 e2                	jne    135 <strcpy+0xd>
    ;
  return os;
 153:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 156:	c9                   	leave  
 157:	c3                   	ret    

00000158 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 158:	55                   	push   %ebp
 159:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 15b:	eb 08                	jmp    165 <strcmp+0xd>
    p++, q++;
 15d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 161:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 165:	8b 45 08             	mov    0x8(%ebp),%eax
 168:	0f b6 00             	movzbl (%eax),%eax
 16b:	84 c0                	test   %al,%al
 16d:	74 10                	je     17f <strcmp+0x27>
 16f:	8b 45 08             	mov    0x8(%ebp),%eax
 172:	0f b6 10             	movzbl (%eax),%edx
 175:	8b 45 0c             	mov    0xc(%ebp),%eax
 178:	0f b6 00             	movzbl (%eax),%eax
 17b:	38 c2                	cmp    %al,%dl
 17d:	74 de                	je     15d <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 17f:	8b 45 08             	mov    0x8(%ebp),%eax
 182:	0f b6 00             	movzbl (%eax),%eax
 185:	0f b6 d0             	movzbl %al,%edx
 188:	8b 45 0c             	mov    0xc(%ebp),%eax
 18b:	0f b6 00             	movzbl (%eax),%eax
 18e:	0f b6 c0             	movzbl %al,%eax
 191:	29 c2                	sub    %eax,%edx
 193:	89 d0                	mov    %edx,%eax
}
 195:	5d                   	pop    %ebp
 196:	c3                   	ret    

00000197 <strlen>:

uint
strlen(char *s)
{
 197:	55                   	push   %ebp
 198:	89 e5                	mov    %esp,%ebp
 19a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 19d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1a4:	eb 04                	jmp    1aa <strlen+0x13>
 1a6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1aa:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1ad:	8b 45 08             	mov    0x8(%ebp),%eax
 1b0:	01 d0                	add    %edx,%eax
 1b2:	0f b6 00             	movzbl (%eax),%eax
 1b5:	84 c0                	test   %al,%al
 1b7:	75 ed                	jne    1a6 <strlen+0xf>
    ;
  return n;
 1b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1bc:	c9                   	leave  
 1bd:	c3                   	ret    

000001be <memset>:

void*
memset(void *dst, int c, uint n)
{
 1be:	55                   	push   %ebp
 1bf:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 1c1:	8b 45 10             	mov    0x10(%ebp),%eax
 1c4:	50                   	push   %eax
 1c5:	ff 75 0c             	pushl  0xc(%ebp)
 1c8:	ff 75 08             	pushl  0x8(%ebp)
 1cb:	e8 32 ff ff ff       	call   102 <stosb>
 1d0:	83 c4 0c             	add    $0xc,%esp
  return dst;
 1d3:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1d6:	c9                   	leave  
 1d7:	c3                   	ret    

000001d8 <strchr>:

char*
strchr(const char *s, char c)
{
 1d8:	55                   	push   %ebp
 1d9:	89 e5                	mov    %esp,%ebp
 1db:	83 ec 04             	sub    $0x4,%esp
 1de:	8b 45 0c             	mov    0xc(%ebp),%eax
 1e1:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1e4:	eb 14                	jmp    1fa <strchr+0x22>
    if(*s == c)
 1e6:	8b 45 08             	mov    0x8(%ebp),%eax
 1e9:	0f b6 00             	movzbl (%eax),%eax
 1ec:	3a 45 fc             	cmp    -0x4(%ebp),%al
 1ef:	75 05                	jne    1f6 <strchr+0x1e>
      return (char*)s;
 1f1:	8b 45 08             	mov    0x8(%ebp),%eax
 1f4:	eb 13                	jmp    209 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 1f6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1fa:	8b 45 08             	mov    0x8(%ebp),%eax
 1fd:	0f b6 00             	movzbl (%eax),%eax
 200:	84 c0                	test   %al,%al
 202:	75 e2                	jne    1e6 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 204:	b8 00 00 00 00       	mov    $0x0,%eax
}
 209:	c9                   	leave  
 20a:	c3                   	ret    

0000020b <gets>:

char*
gets(char *buf, int max)
{
 20b:	55                   	push   %ebp
 20c:	89 e5                	mov    %esp,%ebp
 20e:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 211:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 218:	eb 42                	jmp    25c <gets+0x51>
    cc = read(0, &c, 1);
 21a:	83 ec 04             	sub    $0x4,%esp
 21d:	6a 01                	push   $0x1
 21f:	8d 45 ef             	lea    -0x11(%ebp),%eax
 222:	50                   	push   %eax
 223:	6a 00                	push   $0x0
 225:	e8 1a 02 00 00       	call   444 <read>
 22a:	83 c4 10             	add    $0x10,%esp
 22d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 230:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 234:	7e 33                	jle    269 <gets+0x5e>
      break;
    buf[i++] = c;
 236:	8b 45 f4             	mov    -0xc(%ebp),%eax
 239:	8d 50 01             	lea    0x1(%eax),%edx
 23c:	89 55 f4             	mov    %edx,-0xc(%ebp)
 23f:	89 c2                	mov    %eax,%edx
 241:	8b 45 08             	mov    0x8(%ebp),%eax
 244:	01 c2                	add    %eax,%edx
 246:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 24a:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 24c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 250:	3c 0a                	cmp    $0xa,%al
 252:	74 16                	je     26a <gets+0x5f>
 254:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 258:	3c 0d                	cmp    $0xd,%al
 25a:	74 0e                	je     26a <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 25c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 25f:	83 c0 01             	add    $0x1,%eax
 262:	3b 45 0c             	cmp    0xc(%ebp),%eax
 265:	7c b3                	jl     21a <gets+0xf>
 267:	eb 01                	jmp    26a <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 269:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 26a:	8b 55 f4             	mov    -0xc(%ebp),%edx
 26d:	8b 45 08             	mov    0x8(%ebp),%eax
 270:	01 d0                	add    %edx,%eax
 272:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 275:	8b 45 08             	mov    0x8(%ebp),%eax
}
 278:	c9                   	leave  
 279:	c3                   	ret    

0000027a <stat>:

int
stat(char *n, struct stat *st)
{
 27a:	55                   	push   %ebp
 27b:	89 e5                	mov    %esp,%ebp
 27d:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 280:	83 ec 08             	sub    $0x8,%esp
 283:	6a 00                	push   $0x0
 285:	ff 75 08             	pushl  0x8(%ebp)
 288:	e8 df 01 00 00       	call   46c <open>
 28d:	83 c4 10             	add    $0x10,%esp
 290:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 293:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 297:	79 07                	jns    2a0 <stat+0x26>
    return -1;
 299:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 29e:	eb 25                	jmp    2c5 <stat+0x4b>
  r = fstat(fd, st);
 2a0:	83 ec 08             	sub    $0x8,%esp
 2a3:	ff 75 0c             	pushl  0xc(%ebp)
 2a6:	ff 75 f4             	pushl  -0xc(%ebp)
 2a9:	e8 d6 01 00 00       	call   484 <fstat>
 2ae:	83 c4 10             	add    $0x10,%esp
 2b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2b4:	83 ec 0c             	sub    $0xc,%esp
 2b7:	ff 75 f4             	pushl  -0xc(%ebp)
 2ba:	e8 95 01 00 00       	call   454 <close>
 2bf:	83 c4 10             	add    $0x10,%esp
  return r;
 2c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2c5:	c9                   	leave  
 2c6:	c3                   	ret    

000002c7 <atoi>:

int
atoi(const char *s)
{
 2c7:	55                   	push   %ebp
 2c8:	89 e5                	mov    %esp,%ebp
 2ca:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 2cd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 2d4:	eb 04                	jmp    2da <atoi+0x13>
 2d6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2da:	8b 45 08             	mov    0x8(%ebp),%eax
 2dd:	0f b6 00             	movzbl (%eax),%eax
 2e0:	3c 20                	cmp    $0x20,%al
 2e2:	74 f2                	je     2d6 <atoi+0xf>
  sign = (*s == '-') ? -1 : 1;
 2e4:	8b 45 08             	mov    0x8(%ebp),%eax
 2e7:	0f b6 00             	movzbl (%eax),%eax
 2ea:	3c 2d                	cmp    $0x2d,%al
 2ec:	75 07                	jne    2f5 <atoi+0x2e>
 2ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2f3:	eb 05                	jmp    2fa <atoi+0x33>
 2f5:	b8 01 00 00 00       	mov    $0x1,%eax
 2fa:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 2fd:	8b 45 08             	mov    0x8(%ebp),%eax
 300:	0f b6 00             	movzbl (%eax),%eax
 303:	3c 2b                	cmp    $0x2b,%al
 305:	74 0a                	je     311 <atoi+0x4a>
 307:	8b 45 08             	mov    0x8(%ebp),%eax
 30a:	0f b6 00             	movzbl (%eax),%eax
 30d:	3c 2d                	cmp    $0x2d,%al
 30f:	75 2b                	jne    33c <atoi+0x75>
    s++;
 311:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '9')
 315:	eb 25                	jmp    33c <atoi+0x75>
    n = n*10 + *s++ - '0';
 317:	8b 55 fc             	mov    -0x4(%ebp),%edx
 31a:	89 d0                	mov    %edx,%eax
 31c:	c1 e0 02             	shl    $0x2,%eax
 31f:	01 d0                	add    %edx,%eax
 321:	01 c0                	add    %eax,%eax
 323:	89 c1                	mov    %eax,%ecx
 325:	8b 45 08             	mov    0x8(%ebp),%eax
 328:	8d 50 01             	lea    0x1(%eax),%edx
 32b:	89 55 08             	mov    %edx,0x8(%ebp)
 32e:	0f b6 00             	movzbl (%eax),%eax
 331:	0f be c0             	movsbl %al,%eax
 334:	01 c8                	add    %ecx,%eax
 336:	83 e8 30             	sub    $0x30,%eax
 339:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '9')
 33c:	8b 45 08             	mov    0x8(%ebp),%eax
 33f:	0f b6 00             	movzbl (%eax),%eax
 342:	3c 2f                	cmp    $0x2f,%al
 344:	7e 0a                	jle    350 <atoi+0x89>
 346:	8b 45 08             	mov    0x8(%ebp),%eax
 349:	0f b6 00             	movzbl (%eax),%eax
 34c:	3c 39                	cmp    $0x39,%al
 34e:	7e c7                	jle    317 <atoi+0x50>
    n = n*10 + *s++ - '0';
  return sign*n;
 350:	8b 45 f8             	mov    -0x8(%ebp),%eax
 353:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 357:	c9                   	leave  
 358:	c3                   	ret    

00000359 <atoo>:

int
atoo(const char *s)
{
 359:	55                   	push   %ebp
 35a:	89 e5                	mov    %esp,%ebp
 35c:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 35f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 366:	eb 04                	jmp    36c <atoo+0x13>
 368:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 36c:	8b 45 08             	mov    0x8(%ebp),%eax
 36f:	0f b6 00             	movzbl (%eax),%eax
 372:	3c 20                	cmp    $0x20,%al
 374:	74 f2                	je     368 <atoo+0xf>
  sign = (*s == '-') ? -1 : 1;
 376:	8b 45 08             	mov    0x8(%ebp),%eax
 379:	0f b6 00             	movzbl (%eax),%eax
 37c:	3c 2d                	cmp    $0x2d,%al
 37e:	75 07                	jne    387 <atoo+0x2e>
 380:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 385:	eb 05                	jmp    38c <atoo+0x33>
 387:	b8 01 00 00 00       	mov    $0x1,%eax
 38c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 38f:	8b 45 08             	mov    0x8(%ebp),%eax
 392:	0f b6 00             	movzbl (%eax),%eax
 395:	3c 2b                	cmp    $0x2b,%al
 397:	74 0a                	je     3a3 <atoo+0x4a>
 399:	8b 45 08             	mov    0x8(%ebp),%eax
 39c:	0f b6 00             	movzbl (%eax),%eax
 39f:	3c 2d                	cmp    $0x2d,%al
 3a1:	75 27                	jne    3ca <atoo+0x71>
    s++;
 3a3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '7')
 3a7:	eb 21                	jmp    3ca <atoo+0x71>
    n = n*8 + *s++ - '0';
 3a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3ac:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
 3b3:	8b 45 08             	mov    0x8(%ebp),%eax
 3b6:	8d 50 01             	lea    0x1(%eax),%edx
 3b9:	89 55 08             	mov    %edx,0x8(%ebp)
 3bc:	0f b6 00             	movzbl (%eax),%eax
 3bf:	0f be c0             	movsbl %al,%eax
 3c2:	01 c8                	add    %ecx,%eax
 3c4:	83 e8 30             	sub    $0x30,%eax
 3c7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '7')
 3ca:	8b 45 08             	mov    0x8(%ebp),%eax
 3cd:	0f b6 00             	movzbl (%eax),%eax
 3d0:	3c 2f                	cmp    $0x2f,%al
 3d2:	7e 0a                	jle    3de <atoo+0x85>
 3d4:	8b 45 08             	mov    0x8(%ebp),%eax
 3d7:	0f b6 00             	movzbl (%eax),%eax
 3da:	3c 37                	cmp    $0x37,%al
 3dc:	7e cb                	jle    3a9 <atoo+0x50>
    n = n*8 + *s++ - '0';
  return sign*n;
 3de:	8b 45 f8             	mov    -0x8(%ebp),%eax
 3e1:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 3e5:	c9                   	leave  
 3e6:	c3                   	ret    

000003e7 <memmove>:


void*
memmove(void *vdst, void *vsrc, int n)
{
 3e7:	55                   	push   %ebp
 3e8:	89 e5                	mov    %esp,%ebp
 3ea:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 3ed:	8b 45 08             	mov    0x8(%ebp),%eax
 3f0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 3f3:	8b 45 0c             	mov    0xc(%ebp),%eax
 3f6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 3f9:	eb 17                	jmp    412 <memmove+0x2b>
    *dst++ = *src++;
 3fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3fe:	8d 50 01             	lea    0x1(%eax),%edx
 401:	89 55 fc             	mov    %edx,-0x4(%ebp)
 404:	8b 55 f8             	mov    -0x8(%ebp),%edx
 407:	8d 4a 01             	lea    0x1(%edx),%ecx
 40a:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 40d:	0f b6 12             	movzbl (%edx),%edx
 410:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 412:	8b 45 10             	mov    0x10(%ebp),%eax
 415:	8d 50 ff             	lea    -0x1(%eax),%edx
 418:	89 55 10             	mov    %edx,0x10(%ebp)
 41b:	85 c0                	test   %eax,%eax
 41d:	7f dc                	jg     3fb <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 41f:	8b 45 08             	mov    0x8(%ebp),%eax
}
 422:	c9                   	leave  
 423:	c3                   	ret    

00000424 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 424:	b8 01 00 00 00       	mov    $0x1,%eax
 429:	cd 40                	int    $0x40
 42b:	c3                   	ret    

0000042c <exit>:
SYSCALL(exit)
 42c:	b8 02 00 00 00       	mov    $0x2,%eax
 431:	cd 40                	int    $0x40
 433:	c3                   	ret    

00000434 <wait>:
SYSCALL(wait)
 434:	b8 03 00 00 00       	mov    $0x3,%eax
 439:	cd 40                	int    $0x40
 43b:	c3                   	ret    

0000043c <pipe>:
SYSCALL(pipe)
 43c:	b8 04 00 00 00       	mov    $0x4,%eax
 441:	cd 40                	int    $0x40
 443:	c3                   	ret    

00000444 <read>:
SYSCALL(read)
 444:	b8 05 00 00 00       	mov    $0x5,%eax
 449:	cd 40                	int    $0x40
 44b:	c3                   	ret    

0000044c <write>:
SYSCALL(write)
 44c:	b8 10 00 00 00       	mov    $0x10,%eax
 451:	cd 40                	int    $0x40
 453:	c3                   	ret    

00000454 <close>:
SYSCALL(close)
 454:	b8 15 00 00 00       	mov    $0x15,%eax
 459:	cd 40                	int    $0x40
 45b:	c3                   	ret    

0000045c <kill>:
SYSCALL(kill)
 45c:	b8 06 00 00 00       	mov    $0x6,%eax
 461:	cd 40                	int    $0x40
 463:	c3                   	ret    

00000464 <exec>:
SYSCALL(exec)
 464:	b8 07 00 00 00       	mov    $0x7,%eax
 469:	cd 40                	int    $0x40
 46b:	c3                   	ret    

0000046c <open>:
SYSCALL(open)
 46c:	b8 0f 00 00 00       	mov    $0xf,%eax
 471:	cd 40                	int    $0x40
 473:	c3                   	ret    

00000474 <mknod>:
SYSCALL(mknod)
 474:	b8 11 00 00 00       	mov    $0x11,%eax
 479:	cd 40                	int    $0x40
 47b:	c3                   	ret    

0000047c <unlink>:
SYSCALL(unlink)
 47c:	b8 12 00 00 00       	mov    $0x12,%eax
 481:	cd 40                	int    $0x40
 483:	c3                   	ret    

00000484 <fstat>:
SYSCALL(fstat)
 484:	b8 08 00 00 00       	mov    $0x8,%eax
 489:	cd 40                	int    $0x40
 48b:	c3                   	ret    

0000048c <link>:
SYSCALL(link)
 48c:	b8 13 00 00 00       	mov    $0x13,%eax
 491:	cd 40                	int    $0x40
 493:	c3                   	ret    

00000494 <mkdir>:
SYSCALL(mkdir)
 494:	b8 14 00 00 00       	mov    $0x14,%eax
 499:	cd 40                	int    $0x40
 49b:	c3                   	ret    

0000049c <chdir>:
SYSCALL(chdir)
 49c:	b8 09 00 00 00       	mov    $0x9,%eax
 4a1:	cd 40                	int    $0x40
 4a3:	c3                   	ret    

000004a4 <dup>:
SYSCALL(dup)
 4a4:	b8 0a 00 00 00       	mov    $0xa,%eax
 4a9:	cd 40                	int    $0x40
 4ab:	c3                   	ret    

000004ac <getpid>:
SYSCALL(getpid)
 4ac:	b8 0b 00 00 00       	mov    $0xb,%eax
 4b1:	cd 40                	int    $0x40
 4b3:	c3                   	ret    

000004b4 <sbrk>:
SYSCALL(sbrk)
 4b4:	b8 0c 00 00 00       	mov    $0xc,%eax
 4b9:	cd 40                	int    $0x40
 4bb:	c3                   	ret    

000004bc <sleep>:
SYSCALL(sleep)
 4bc:	b8 0d 00 00 00       	mov    $0xd,%eax
 4c1:	cd 40                	int    $0x40
 4c3:	c3                   	ret    

000004c4 <uptime>:
SYSCALL(uptime)
 4c4:	b8 0e 00 00 00       	mov    $0xe,%eax
 4c9:	cd 40                	int    $0x40
 4cb:	c3                   	ret    

000004cc <halt>:
SYSCALL(halt)
 4cc:	b8 16 00 00 00       	mov    $0x16,%eax
 4d1:	cd 40                	int    $0x40
 4d3:	c3                   	ret    

000004d4 <date>:
SYSCALL(date)
 4d4:	b8 17 00 00 00       	mov    $0x17,%eax
 4d9:	cd 40                	int    $0x40
 4db:	c3                   	ret    

000004dc <getuid>:
SYSCALL(getuid)
 4dc:	b8 18 00 00 00       	mov    $0x18,%eax
 4e1:	cd 40                	int    $0x40
 4e3:	c3                   	ret    

000004e4 <getgid>:
SYSCALL(getgid)
 4e4:	b8 19 00 00 00       	mov    $0x19,%eax
 4e9:	cd 40                	int    $0x40
 4eb:	c3                   	ret    

000004ec <getppid>:
SYSCALL(getppid)
 4ec:	b8 1a 00 00 00       	mov    $0x1a,%eax
 4f1:	cd 40                	int    $0x40
 4f3:	c3                   	ret    

000004f4 <setuid>:
SYSCALL(setuid)
 4f4:	b8 1b 00 00 00       	mov    $0x1b,%eax
 4f9:	cd 40                	int    $0x40
 4fb:	c3                   	ret    

000004fc <setgid>:
SYSCALL(setgid)
 4fc:	b8 1c 00 00 00       	mov    $0x1c,%eax
 501:	cd 40                	int    $0x40
 503:	c3                   	ret    

00000504 <getprocs>:
SYSCALL(getprocs)
 504:	b8 1d 00 00 00       	mov    $0x1d,%eax
 509:	cd 40                	int    $0x40
 50b:	c3                   	ret    

0000050c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 50c:	55                   	push   %ebp
 50d:	89 e5                	mov    %esp,%ebp
 50f:	83 ec 18             	sub    $0x18,%esp
 512:	8b 45 0c             	mov    0xc(%ebp),%eax
 515:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 518:	83 ec 04             	sub    $0x4,%esp
 51b:	6a 01                	push   $0x1
 51d:	8d 45 f4             	lea    -0xc(%ebp),%eax
 520:	50                   	push   %eax
 521:	ff 75 08             	pushl  0x8(%ebp)
 524:	e8 23 ff ff ff       	call   44c <write>
 529:	83 c4 10             	add    $0x10,%esp
}
 52c:	90                   	nop
 52d:	c9                   	leave  
 52e:	c3                   	ret    

0000052f <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 52f:	55                   	push   %ebp
 530:	89 e5                	mov    %esp,%ebp
 532:	53                   	push   %ebx
 533:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 536:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 53d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 541:	74 17                	je     55a <printint+0x2b>
 543:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 547:	79 11                	jns    55a <printint+0x2b>
    neg = 1;
 549:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 550:	8b 45 0c             	mov    0xc(%ebp),%eax
 553:	f7 d8                	neg    %eax
 555:	89 45 ec             	mov    %eax,-0x14(%ebp)
 558:	eb 06                	jmp    560 <printint+0x31>
  } else {
    x = xx;
 55a:	8b 45 0c             	mov    0xc(%ebp),%eax
 55d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 560:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 567:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 56a:	8d 41 01             	lea    0x1(%ecx),%eax
 56d:	89 45 f4             	mov    %eax,-0xc(%ebp)
 570:	8b 5d 10             	mov    0x10(%ebp),%ebx
 573:	8b 45 ec             	mov    -0x14(%ebp),%eax
 576:	ba 00 00 00 00       	mov    $0x0,%edx
 57b:	f7 f3                	div    %ebx
 57d:	89 d0                	mov    %edx,%eax
 57f:	0f b6 80 54 0c 00 00 	movzbl 0xc54(%eax),%eax
 586:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 58a:	8b 5d 10             	mov    0x10(%ebp),%ebx
 58d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 590:	ba 00 00 00 00       	mov    $0x0,%edx
 595:	f7 f3                	div    %ebx
 597:	89 45 ec             	mov    %eax,-0x14(%ebp)
 59a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 59e:	75 c7                	jne    567 <printint+0x38>
  if(neg)
 5a0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5a4:	74 2d                	je     5d3 <printint+0xa4>
    buf[i++] = '-';
 5a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5a9:	8d 50 01             	lea    0x1(%eax),%edx
 5ac:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5af:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 5b4:	eb 1d                	jmp    5d3 <printint+0xa4>
    putc(fd, buf[i]);
 5b6:	8d 55 dc             	lea    -0x24(%ebp),%edx
 5b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5bc:	01 d0                	add    %edx,%eax
 5be:	0f b6 00             	movzbl (%eax),%eax
 5c1:	0f be c0             	movsbl %al,%eax
 5c4:	83 ec 08             	sub    $0x8,%esp
 5c7:	50                   	push   %eax
 5c8:	ff 75 08             	pushl  0x8(%ebp)
 5cb:	e8 3c ff ff ff       	call   50c <putc>
 5d0:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 5d3:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 5d7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5db:	79 d9                	jns    5b6 <printint+0x87>
    putc(fd, buf[i]);
}
 5dd:	90                   	nop
 5de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 5e1:	c9                   	leave  
 5e2:	c3                   	ret    

000005e3 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5e3:	55                   	push   %ebp
 5e4:	89 e5                	mov    %esp,%ebp
 5e6:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 5e9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5f0:	8d 45 0c             	lea    0xc(%ebp),%eax
 5f3:	83 c0 04             	add    $0x4,%eax
 5f6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 5f9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 600:	e9 59 01 00 00       	jmp    75e <printf+0x17b>
    c = fmt[i] & 0xff;
 605:	8b 55 0c             	mov    0xc(%ebp),%edx
 608:	8b 45 f0             	mov    -0x10(%ebp),%eax
 60b:	01 d0                	add    %edx,%eax
 60d:	0f b6 00             	movzbl (%eax),%eax
 610:	0f be c0             	movsbl %al,%eax
 613:	25 ff 00 00 00       	and    $0xff,%eax
 618:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 61b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 61f:	75 2c                	jne    64d <printf+0x6a>
      if(c == '%'){
 621:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 625:	75 0c                	jne    633 <printf+0x50>
        state = '%';
 627:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 62e:	e9 27 01 00 00       	jmp    75a <printf+0x177>
      } else {
        putc(fd, c);
 633:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 636:	0f be c0             	movsbl %al,%eax
 639:	83 ec 08             	sub    $0x8,%esp
 63c:	50                   	push   %eax
 63d:	ff 75 08             	pushl  0x8(%ebp)
 640:	e8 c7 fe ff ff       	call   50c <putc>
 645:	83 c4 10             	add    $0x10,%esp
 648:	e9 0d 01 00 00       	jmp    75a <printf+0x177>
      }
    } else if(state == '%'){
 64d:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 651:	0f 85 03 01 00 00    	jne    75a <printf+0x177>
      if(c == 'd'){
 657:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 65b:	75 1e                	jne    67b <printf+0x98>
        printint(fd, *ap, 10, 1);
 65d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 660:	8b 00                	mov    (%eax),%eax
 662:	6a 01                	push   $0x1
 664:	6a 0a                	push   $0xa
 666:	50                   	push   %eax
 667:	ff 75 08             	pushl  0x8(%ebp)
 66a:	e8 c0 fe ff ff       	call   52f <printint>
 66f:	83 c4 10             	add    $0x10,%esp
        ap++;
 672:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 676:	e9 d8 00 00 00       	jmp    753 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 67b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 67f:	74 06                	je     687 <printf+0xa4>
 681:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 685:	75 1e                	jne    6a5 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 687:	8b 45 e8             	mov    -0x18(%ebp),%eax
 68a:	8b 00                	mov    (%eax),%eax
 68c:	6a 00                	push   $0x0
 68e:	6a 10                	push   $0x10
 690:	50                   	push   %eax
 691:	ff 75 08             	pushl  0x8(%ebp)
 694:	e8 96 fe ff ff       	call   52f <printint>
 699:	83 c4 10             	add    $0x10,%esp
        ap++;
 69c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6a0:	e9 ae 00 00 00       	jmp    753 <printf+0x170>
      } else if(c == 's'){
 6a5:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6a9:	75 43                	jne    6ee <printf+0x10b>
        s = (char*)*ap;
 6ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6ae:	8b 00                	mov    (%eax),%eax
 6b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6b3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6b7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6bb:	75 25                	jne    6e2 <printf+0xff>
          s = "(null)";
 6bd:	c7 45 f4 e0 09 00 00 	movl   $0x9e0,-0xc(%ebp)
        while(*s != 0){
 6c4:	eb 1c                	jmp    6e2 <printf+0xff>
          putc(fd, *s);
 6c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6c9:	0f b6 00             	movzbl (%eax),%eax
 6cc:	0f be c0             	movsbl %al,%eax
 6cf:	83 ec 08             	sub    $0x8,%esp
 6d2:	50                   	push   %eax
 6d3:	ff 75 08             	pushl  0x8(%ebp)
 6d6:	e8 31 fe ff ff       	call   50c <putc>
 6db:	83 c4 10             	add    $0x10,%esp
          s++;
 6de:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 6e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6e5:	0f b6 00             	movzbl (%eax),%eax
 6e8:	84 c0                	test   %al,%al
 6ea:	75 da                	jne    6c6 <printf+0xe3>
 6ec:	eb 65                	jmp    753 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6ee:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 6f2:	75 1d                	jne    711 <printf+0x12e>
        putc(fd, *ap);
 6f4:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6f7:	8b 00                	mov    (%eax),%eax
 6f9:	0f be c0             	movsbl %al,%eax
 6fc:	83 ec 08             	sub    $0x8,%esp
 6ff:	50                   	push   %eax
 700:	ff 75 08             	pushl  0x8(%ebp)
 703:	e8 04 fe ff ff       	call   50c <putc>
 708:	83 c4 10             	add    $0x10,%esp
        ap++;
 70b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 70f:	eb 42                	jmp    753 <printf+0x170>
      } else if(c == '%'){
 711:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 715:	75 17                	jne    72e <printf+0x14b>
        putc(fd, c);
 717:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 71a:	0f be c0             	movsbl %al,%eax
 71d:	83 ec 08             	sub    $0x8,%esp
 720:	50                   	push   %eax
 721:	ff 75 08             	pushl  0x8(%ebp)
 724:	e8 e3 fd ff ff       	call   50c <putc>
 729:	83 c4 10             	add    $0x10,%esp
 72c:	eb 25                	jmp    753 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 72e:	83 ec 08             	sub    $0x8,%esp
 731:	6a 25                	push   $0x25
 733:	ff 75 08             	pushl  0x8(%ebp)
 736:	e8 d1 fd ff ff       	call   50c <putc>
 73b:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 73e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 741:	0f be c0             	movsbl %al,%eax
 744:	83 ec 08             	sub    $0x8,%esp
 747:	50                   	push   %eax
 748:	ff 75 08             	pushl  0x8(%ebp)
 74b:	e8 bc fd ff ff       	call   50c <putc>
 750:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 753:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 75a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 75e:	8b 55 0c             	mov    0xc(%ebp),%edx
 761:	8b 45 f0             	mov    -0x10(%ebp),%eax
 764:	01 d0                	add    %edx,%eax
 766:	0f b6 00             	movzbl (%eax),%eax
 769:	84 c0                	test   %al,%al
 76b:	0f 85 94 fe ff ff    	jne    605 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 771:	90                   	nop
 772:	c9                   	leave  
 773:	c3                   	ret    

00000774 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 774:	55                   	push   %ebp
 775:	89 e5                	mov    %esp,%ebp
 777:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 77a:	8b 45 08             	mov    0x8(%ebp),%eax
 77d:	83 e8 08             	sub    $0x8,%eax
 780:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 783:	a1 70 0c 00 00       	mov    0xc70,%eax
 788:	89 45 fc             	mov    %eax,-0x4(%ebp)
 78b:	eb 24                	jmp    7b1 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 78d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 790:	8b 00                	mov    (%eax),%eax
 792:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 795:	77 12                	ja     7a9 <free+0x35>
 797:	8b 45 f8             	mov    -0x8(%ebp),%eax
 79a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 79d:	77 24                	ja     7c3 <free+0x4f>
 79f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a2:	8b 00                	mov    (%eax),%eax
 7a4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7a7:	77 1a                	ja     7c3 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ac:	8b 00                	mov    (%eax),%eax
 7ae:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7b1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7b4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7b7:	76 d4                	jbe    78d <free+0x19>
 7b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7bc:	8b 00                	mov    (%eax),%eax
 7be:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7c1:	76 ca                	jbe    78d <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 7c3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7c6:	8b 40 04             	mov    0x4(%eax),%eax
 7c9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7d0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7d3:	01 c2                	add    %eax,%edx
 7d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d8:	8b 00                	mov    (%eax),%eax
 7da:	39 c2                	cmp    %eax,%edx
 7dc:	75 24                	jne    802 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 7de:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7e1:	8b 50 04             	mov    0x4(%eax),%edx
 7e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e7:	8b 00                	mov    (%eax),%eax
 7e9:	8b 40 04             	mov    0x4(%eax),%eax
 7ec:	01 c2                	add    %eax,%edx
 7ee:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7f1:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 7f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f7:	8b 00                	mov    (%eax),%eax
 7f9:	8b 10                	mov    (%eax),%edx
 7fb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7fe:	89 10                	mov    %edx,(%eax)
 800:	eb 0a                	jmp    80c <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 802:	8b 45 fc             	mov    -0x4(%ebp),%eax
 805:	8b 10                	mov    (%eax),%edx
 807:	8b 45 f8             	mov    -0x8(%ebp),%eax
 80a:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 80c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 80f:	8b 40 04             	mov    0x4(%eax),%eax
 812:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 819:	8b 45 fc             	mov    -0x4(%ebp),%eax
 81c:	01 d0                	add    %edx,%eax
 81e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 821:	75 20                	jne    843 <free+0xcf>
    p->s.size += bp->s.size;
 823:	8b 45 fc             	mov    -0x4(%ebp),%eax
 826:	8b 50 04             	mov    0x4(%eax),%edx
 829:	8b 45 f8             	mov    -0x8(%ebp),%eax
 82c:	8b 40 04             	mov    0x4(%eax),%eax
 82f:	01 c2                	add    %eax,%edx
 831:	8b 45 fc             	mov    -0x4(%ebp),%eax
 834:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 837:	8b 45 f8             	mov    -0x8(%ebp),%eax
 83a:	8b 10                	mov    (%eax),%edx
 83c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83f:	89 10                	mov    %edx,(%eax)
 841:	eb 08                	jmp    84b <free+0xd7>
  } else
    p->s.ptr = bp;
 843:	8b 45 fc             	mov    -0x4(%ebp),%eax
 846:	8b 55 f8             	mov    -0x8(%ebp),%edx
 849:	89 10                	mov    %edx,(%eax)
  freep = p;
 84b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 84e:	a3 70 0c 00 00       	mov    %eax,0xc70
}
 853:	90                   	nop
 854:	c9                   	leave  
 855:	c3                   	ret    

00000856 <morecore>:

static Header*
morecore(uint nu)
{
 856:	55                   	push   %ebp
 857:	89 e5                	mov    %esp,%ebp
 859:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 85c:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 863:	77 07                	ja     86c <morecore+0x16>
    nu = 4096;
 865:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 86c:	8b 45 08             	mov    0x8(%ebp),%eax
 86f:	c1 e0 03             	shl    $0x3,%eax
 872:	83 ec 0c             	sub    $0xc,%esp
 875:	50                   	push   %eax
 876:	e8 39 fc ff ff       	call   4b4 <sbrk>
 87b:	83 c4 10             	add    $0x10,%esp
 87e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 881:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 885:	75 07                	jne    88e <morecore+0x38>
    return 0;
 887:	b8 00 00 00 00       	mov    $0x0,%eax
 88c:	eb 26                	jmp    8b4 <morecore+0x5e>
  hp = (Header*)p;
 88e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 891:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 894:	8b 45 f0             	mov    -0x10(%ebp),%eax
 897:	8b 55 08             	mov    0x8(%ebp),%edx
 89a:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 89d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8a0:	83 c0 08             	add    $0x8,%eax
 8a3:	83 ec 0c             	sub    $0xc,%esp
 8a6:	50                   	push   %eax
 8a7:	e8 c8 fe ff ff       	call   774 <free>
 8ac:	83 c4 10             	add    $0x10,%esp
  return freep;
 8af:	a1 70 0c 00 00       	mov    0xc70,%eax
}
 8b4:	c9                   	leave  
 8b5:	c3                   	ret    

000008b6 <malloc>:

void*
malloc(uint nbytes)
{
 8b6:	55                   	push   %ebp
 8b7:	89 e5                	mov    %esp,%ebp
 8b9:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8bc:	8b 45 08             	mov    0x8(%ebp),%eax
 8bf:	83 c0 07             	add    $0x7,%eax
 8c2:	c1 e8 03             	shr    $0x3,%eax
 8c5:	83 c0 01             	add    $0x1,%eax
 8c8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8cb:	a1 70 0c 00 00       	mov    0xc70,%eax
 8d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8d3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8d7:	75 23                	jne    8fc <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 8d9:	c7 45 f0 68 0c 00 00 	movl   $0xc68,-0x10(%ebp)
 8e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8e3:	a3 70 0c 00 00       	mov    %eax,0xc70
 8e8:	a1 70 0c 00 00       	mov    0xc70,%eax
 8ed:	a3 68 0c 00 00       	mov    %eax,0xc68
    base.s.size = 0;
 8f2:	c7 05 6c 0c 00 00 00 	movl   $0x0,0xc6c
 8f9:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8ff:	8b 00                	mov    (%eax),%eax
 901:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 904:	8b 45 f4             	mov    -0xc(%ebp),%eax
 907:	8b 40 04             	mov    0x4(%eax),%eax
 90a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 90d:	72 4d                	jb     95c <malloc+0xa6>
      if(p->s.size == nunits)
 90f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 912:	8b 40 04             	mov    0x4(%eax),%eax
 915:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 918:	75 0c                	jne    926 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 91a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 91d:	8b 10                	mov    (%eax),%edx
 91f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 922:	89 10                	mov    %edx,(%eax)
 924:	eb 26                	jmp    94c <malloc+0x96>
      else {
        p->s.size -= nunits;
 926:	8b 45 f4             	mov    -0xc(%ebp),%eax
 929:	8b 40 04             	mov    0x4(%eax),%eax
 92c:	2b 45 ec             	sub    -0x14(%ebp),%eax
 92f:	89 c2                	mov    %eax,%edx
 931:	8b 45 f4             	mov    -0xc(%ebp),%eax
 934:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 937:	8b 45 f4             	mov    -0xc(%ebp),%eax
 93a:	8b 40 04             	mov    0x4(%eax),%eax
 93d:	c1 e0 03             	shl    $0x3,%eax
 940:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 943:	8b 45 f4             	mov    -0xc(%ebp),%eax
 946:	8b 55 ec             	mov    -0x14(%ebp),%edx
 949:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 94c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 94f:	a3 70 0c 00 00       	mov    %eax,0xc70
      return (void*)(p + 1);
 954:	8b 45 f4             	mov    -0xc(%ebp),%eax
 957:	83 c0 08             	add    $0x8,%eax
 95a:	eb 3b                	jmp    997 <malloc+0xe1>
    }
    if(p == freep)
 95c:	a1 70 0c 00 00       	mov    0xc70,%eax
 961:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 964:	75 1e                	jne    984 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 966:	83 ec 0c             	sub    $0xc,%esp
 969:	ff 75 ec             	pushl  -0x14(%ebp)
 96c:	e8 e5 fe ff ff       	call   856 <morecore>
 971:	83 c4 10             	add    $0x10,%esp
 974:	89 45 f4             	mov    %eax,-0xc(%ebp)
 977:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 97b:	75 07                	jne    984 <malloc+0xce>
        return 0;
 97d:	b8 00 00 00 00       	mov    $0x0,%eax
 982:	eb 13                	jmp    997 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 984:	8b 45 f4             	mov    -0xc(%ebp),%eax
 987:	89 45 f0             	mov    %eax,-0x10(%ebp)
 98a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 98d:	8b 00                	mov    (%eax),%eax
 98f:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 992:	e9 6d ff ff ff       	jmp    904 <malloc+0x4e>
}
 997:	c9                   	leave  
 998:	c3                   	ret    
