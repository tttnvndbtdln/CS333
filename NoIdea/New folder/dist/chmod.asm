
_chmod:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#ifdef CS333_P5
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
   f:	83 ec 10             	sub    $0x10,%esp
  12:	89 cb                	mov    %ecx,%ebx
  int mode;
  int rc;

  if(argc != 3)
  14:	83 3b 03             	cmpl   $0x3,(%ebx)
  17:	74 17                	je     30 <main+0x30>
  {
    printf(2, "\nIncorrect number of arguments.\n");
  19:	83 ec 08             	sub    $0x8,%esp
  1c:	68 7c 09 00 00       	push   $0x97c
  21:	6a 02                	push   $0x2
  23:	e8 9e 05 00 00       	call   5c6 <printf>
  28:	83 c4 10             	add    $0x10,%esp
    exit();
  2b:	e8 bf 03 00 00       	call   3ef <exit>
  }
  if(strlen(argv[1]) != 4)
  30:	8b 43 04             	mov    0x4(%ebx),%eax
  33:	83 c0 04             	add    $0x4,%eax
  36:	8b 00                	mov    (%eax),%eax
  38:	83 ec 0c             	sub    $0xc,%esp
  3b:	50                   	push   %eax
  3c:	e8 19 01 00 00       	call   15a <strlen>
  41:	83 c4 10             	add    $0x10,%esp
  44:	83 f8 04             	cmp    $0x4,%eax
  47:	74 17                	je     60 <main+0x60>
  {
    printf(2, "\nIncorrect mode.\n");
  49:	83 ec 08             	sub    $0x8,%esp
  4c:	68 9d 09 00 00       	push   $0x99d
  51:	6a 02                	push   $0x2
  53:	e8 6e 05 00 00       	call   5c6 <printf>
  58:	83 c4 10             	add    $0x10,%esp
    exit();
  5b:	e8 8f 03 00 00       	call   3ef <exit>
  }

  mode = atoi(argv[1]);
  60:	8b 43 04             	mov    0x4(%ebx),%eax
  63:	83 c0 04             	add    $0x4,%eax
  66:	8b 00                	mov    (%eax),%eax
  68:	83 ec 0c             	sub    $0xc,%esp
  6b:	50                   	push   %eax
  6c:	e8 19 02 00 00       	call   28a <atoi>
  71:	83 c4 10             	add    $0x10,%esp
  74:	89 45 f4             	mov    %eax,-0xc(%ebp)

  rc = chmod(argv[2], mode);
  77:	8b 43 04             	mov    0x4(%ebx),%eax
  7a:	83 c0 08             	add    $0x8,%eax
  7d:	8b 00                	mov    (%eax),%eax
  7f:	83 ec 08             	sub    $0x8,%esp
  82:	ff 75 f4             	pushl  -0xc(%ebp)
  85:	50                   	push   %eax
  86:	e8 4c 04 00 00       	call   4d7 <chmod>
  8b:	83 c4 10             	add    $0x10,%esp
  8e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(rc != 0)
  91:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  95:	74 17                	je     ae <main+0xae>
  {
    printf(2, "\nChange mode failed.\n");
  97:	83 ec 08             	sub    $0x8,%esp
  9a:	68 af 09 00 00       	push   $0x9af
  9f:	6a 02                	push   $0x2
  a1:	e8 20 05 00 00       	call   5c6 <printf>
  a6:	83 c4 10             	add    $0x10,%esp
    exit();
  a9:	e8 41 03 00 00       	call   3ef <exit>
  }   
  else
  {
    printf(2, "\nMode changed.\n");
  ae:	83 ec 08             	sub    $0x8,%esp
  b1:	68 c5 09 00 00       	push   $0x9c5
  b6:	6a 02                	push   $0x2
  b8:	e8 09 05 00 00       	call   5c6 <printf>
  bd:	83 c4 10             	add    $0x10,%esp
    exit();
  c0:	e8 2a 03 00 00       	call   3ef <exit>

000000c5 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  c5:	55                   	push   %ebp
  c6:	89 e5                	mov    %esp,%ebp
  c8:	57                   	push   %edi
  c9:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  cd:	8b 55 10             	mov    0x10(%ebp),%edx
  d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  d3:	89 cb                	mov    %ecx,%ebx
  d5:	89 df                	mov    %ebx,%edi
  d7:	89 d1                	mov    %edx,%ecx
  d9:	fc                   	cld    
  da:	f3 aa                	rep stos %al,%es:(%edi)
  dc:	89 ca                	mov    %ecx,%edx
  de:	89 fb                	mov    %edi,%ebx
  e0:	89 5d 08             	mov    %ebx,0x8(%ebp)
  e3:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  e6:	90                   	nop
  e7:	5b                   	pop    %ebx
  e8:	5f                   	pop    %edi
  e9:	5d                   	pop    %ebp
  ea:	c3                   	ret    

000000eb <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  eb:	55                   	push   %ebp
  ec:	89 e5                	mov    %esp,%ebp
  ee:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  f1:	8b 45 08             	mov    0x8(%ebp),%eax
  f4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  f7:	90                   	nop
  f8:	8b 45 08             	mov    0x8(%ebp),%eax
  fb:	8d 50 01             	lea    0x1(%eax),%edx
  fe:	89 55 08             	mov    %edx,0x8(%ebp)
 101:	8b 55 0c             	mov    0xc(%ebp),%edx
 104:	8d 4a 01             	lea    0x1(%edx),%ecx
 107:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 10a:	0f b6 12             	movzbl (%edx),%edx
 10d:	88 10                	mov    %dl,(%eax)
 10f:	0f b6 00             	movzbl (%eax),%eax
 112:	84 c0                	test   %al,%al
 114:	75 e2                	jne    f8 <strcpy+0xd>
    ;
  return os;
 116:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 119:	c9                   	leave  
 11a:	c3                   	ret    

0000011b <strcmp>:

int
strcmp(const char *p, const char *q)
{
 11b:	55                   	push   %ebp
 11c:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 11e:	eb 08                	jmp    128 <strcmp+0xd>
    p++, q++;
 120:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 124:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 128:	8b 45 08             	mov    0x8(%ebp),%eax
 12b:	0f b6 00             	movzbl (%eax),%eax
 12e:	84 c0                	test   %al,%al
 130:	74 10                	je     142 <strcmp+0x27>
 132:	8b 45 08             	mov    0x8(%ebp),%eax
 135:	0f b6 10             	movzbl (%eax),%edx
 138:	8b 45 0c             	mov    0xc(%ebp),%eax
 13b:	0f b6 00             	movzbl (%eax),%eax
 13e:	38 c2                	cmp    %al,%dl
 140:	74 de                	je     120 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 142:	8b 45 08             	mov    0x8(%ebp),%eax
 145:	0f b6 00             	movzbl (%eax),%eax
 148:	0f b6 d0             	movzbl %al,%edx
 14b:	8b 45 0c             	mov    0xc(%ebp),%eax
 14e:	0f b6 00             	movzbl (%eax),%eax
 151:	0f b6 c0             	movzbl %al,%eax
 154:	29 c2                	sub    %eax,%edx
 156:	89 d0                	mov    %edx,%eax
}
 158:	5d                   	pop    %ebp
 159:	c3                   	ret    

0000015a <strlen>:

uint
strlen(char *s)
{
 15a:	55                   	push   %ebp
 15b:	89 e5                	mov    %esp,%ebp
 15d:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 160:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 167:	eb 04                	jmp    16d <strlen+0x13>
 169:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 16d:	8b 55 fc             	mov    -0x4(%ebp),%edx
 170:	8b 45 08             	mov    0x8(%ebp),%eax
 173:	01 d0                	add    %edx,%eax
 175:	0f b6 00             	movzbl (%eax),%eax
 178:	84 c0                	test   %al,%al
 17a:	75 ed                	jne    169 <strlen+0xf>
    ;
  return n;
 17c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 17f:	c9                   	leave  
 180:	c3                   	ret    

00000181 <memset>:

void*
memset(void *dst, int c, uint n)
{
 181:	55                   	push   %ebp
 182:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 184:	8b 45 10             	mov    0x10(%ebp),%eax
 187:	50                   	push   %eax
 188:	ff 75 0c             	pushl  0xc(%ebp)
 18b:	ff 75 08             	pushl  0x8(%ebp)
 18e:	e8 32 ff ff ff       	call   c5 <stosb>
 193:	83 c4 0c             	add    $0xc,%esp
  return dst;
 196:	8b 45 08             	mov    0x8(%ebp),%eax
}
 199:	c9                   	leave  
 19a:	c3                   	ret    

0000019b <strchr>:

char*
strchr(const char *s, char c)
{
 19b:	55                   	push   %ebp
 19c:	89 e5                	mov    %esp,%ebp
 19e:	83 ec 04             	sub    $0x4,%esp
 1a1:	8b 45 0c             	mov    0xc(%ebp),%eax
 1a4:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1a7:	eb 14                	jmp    1bd <strchr+0x22>
    if(*s == c)
 1a9:	8b 45 08             	mov    0x8(%ebp),%eax
 1ac:	0f b6 00             	movzbl (%eax),%eax
 1af:	3a 45 fc             	cmp    -0x4(%ebp),%al
 1b2:	75 05                	jne    1b9 <strchr+0x1e>
      return (char*)s;
 1b4:	8b 45 08             	mov    0x8(%ebp),%eax
 1b7:	eb 13                	jmp    1cc <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 1b9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1bd:	8b 45 08             	mov    0x8(%ebp),%eax
 1c0:	0f b6 00             	movzbl (%eax),%eax
 1c3:	84 c0                	test   %al,%al
 1c5:	75 e2                	jne    1a9 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 1c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1cc:	c9                   	leave  
 1cd:	c3                   	ret    

000001ce <gets>:

char*
gets(char *buf, int max)
{
 1ce:	55                   	push   %ebp
 1cf:	89 e5                	mov    %esp,%ebp
 1d1:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1db:	eb 42                	jmp    21f <gets+0x51>
    cc = read(0, &c, 1);
 1dd:	83 ec 04             	sub    $0x4,%esp
 1e0:	6a 01                	push   $0x1
 1e2:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1e5:	50                   	push   %eax
 1e6:	6a 00                	push   $0x0
 1e8:	e8 1a 02 00 00       	call   407 <read>
 1ed:	83 c4 10             	add    $0x10,%esp
 1f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1f3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1f7:	7e 33                	jle    22c <gets+0x5e>
      break;
    buf[i++] = c;
 1f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1fc:	8d 50 01             	lea    0x1(%eax),%edx
 1ff:	89 55 f4             	mov    %edx,-0xc(%ebp)
 202:	89 c2                	mov    %eax,%edx
 204:	8b 45 08             	mov    0x8(%ebp),%eax
 207:	01 c2                	add    %eax,%edx
 209:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 20d:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 20f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 213:	3c 0a                	cmp    $0xa,%al
 215:	74 16                	je     22d <gets+0x5f>
 217:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 21b:	3c 0d                	cmp    $0xd,%al
 21d:	74 0e                	je     22d <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 21f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 222:	83 c0 01             	add    $0x1,%eax
 225:	3b 45 0c             	cmp    0xc(%ebp),%eax
 228:	7c b3                	jl     1dd <gets+0xf>
 22a:	eb 01                	jmp    22d <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 22c:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 22d:	8b 55 f4             	mov    -0xc(%ebp),%edx
 230:	8b 45 08             	mov    0x8(%ebp),%eax
 233:	01 d0                	add    %edx,%eax
 235:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 238:	8b 45 08             	mov    0x8(%ebp),%eax
}
 23b:	c9                   	leave  
 23c:	c3                   	ret    

0000023d <stat>:

int
stat(char *n, struct stat *st)
{
 23d:	55                   	push   %ebp
 23e:	89 e5                	mov    %esp,%ebp
 240:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 243:	83 ec 08             	sub    $0x8,%esp
 246:	6a 00                	push   $0x0
 248:	ff 75 08             	pushl  0x8(%ebp)
 24b:	e8 df 01 00 00       	call   42f <open>
 250:	83 c4 10             	add    $0x10,%esp
 253:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 256:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 25a:	79 07                	jns    263 <stat+0x26>
    return -1;
 25c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 261:	eb 25                	jmp    288 <stat+0x4b>
  r = fstat(fd, st);
 263:	83 ec 08             	sub    $0x8,%esp
 266:	ff 75 0c             	pushl  0xc(%ebp)
 269:	ff 75 f4             	pushl  -0xc(%ebp)
 26c:	e8 d6 01 00 00       	call   447 <fstat>
 271:	83 c4 10             	add    $0x10,%esp
 274:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 277:	83 ec 0c             	sub    $0xc,%esp
 27a:	ff 75 f4             	pushl  -0xc(%ebp)
 27d:	e8 95 01 00 00       	call   417 <close>
 282:	83 c4 10             	add    $0x10,%esp
  return r;
 285:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 288:	c9                   	leave  
 289:	c3                   	ret    

0000028a <atoi>:

int
atoi(const char *s)
{
 28a:	55                   	push   %ebp
 28b:	89 e5                	mov    %esp,%ebp
 28d:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 290:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 297:	eb 04                	jmp    29d <atoi+0x13>
 299:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 29d:	8b 45 08             	mov    0x8(%ebp),%eax
 2a0:	0f b6 00             	movzbl (%eax),%eax
 2a3:	3c 20                	cmp    $0x20,%al
 2a5:	74 f2                	je     299 <atoi+0xf>
  sign = (*s == '-') ? -1 : 1;
 2a7:	8b 45 08             	mov    0x8(%ebp),%eax
 2aa:	0f b6 00             	movzbl (%eax),%eax
 2ad:	3c 2d                	cmp    $0x2d,%al
 2af:	75 07                	jne    2b8 <atoi+0x2e>
 2b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2b6:	eb 05                	jmp    2bd <atoi+0x33>
 2b8:	b8 01 00 00 00       	mov    $0x1,%eax
 2bd:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 2c0:	8b 45 08             	mov    0x8(%ebp),%eax
 2c3:	0f b6 00             	movzbl (%eax),%eax
 2c6:	3c 2b                	cmp    $0x2b,%al
 2c8:	74 0a                	je     2d4 <atoi+0x4a>
 2ca:	8b 45 08             	mov    0x8(%ebp),%eax
 2cd:	0f b6 00             	movzbl (%eax),%eax
 2d0:	3c 2d                	cmp    $0x2d,%al
 2d2:	75 2b                	jne    2ff <atoi+0x75>
    s++;
 2d4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '9')
 2d8:	eb 25                	jmp    2ff <atoi+0x75>
    n = n*10 + *s++ - '0';
 2da:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2dd:	89 d0                	mov    %edx,%eax
 2df:	c1 e0 02             	shl    $0x2,%eax
 2e2:	01 d0                	add    %edx,%eax
 2e4:	01 c0                	add    %eax,%eax
 2e6:	89 c1                	mov    %eax,%ecx
 2e8:	8b 45 08             	mov    0x8(%ebp),%eax
 2eb:	8d 50 01             	lea    0x1(%eax),%edx
 2ee:	89 55 08             	mov    %edx,0x8(%ebp)
 2f1:	0f b6 00             	movzbl (%eax),%eax
 2f4:	0f be c0             	movsbl %al,%eax
 2f7:	01 c8                	add    %ecx,%eax
 2f9:	83 e8 30             	sub    $0x30,%eax
 2fc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '9')
 2ff:	8b 45 08             	mov    0x8(%ebp),%eax
 302:	0f b6 00             	movzbl (%eax),%eax
 305:	3c 2f                	cmp    $0x2f,%al
 307:	7e 0a                	jle    313 <atoi+0x89>
 309:	8b 45 08             	mov    0x8(%ebp),%eax
 30c:	0f b6 00             	movzbl (%eax),%eax
 30f:	3c 39                	cmp    $0x39,%al
 311:	7e c7                	jle    2da <atoi+0x50>
    n = n*10 + *s++ - '0';
  return sign*n;
 313:	8b 45 f8             	mov    -0x8(%ebp),%eax
 316:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 31a:	c9                   	leave  
 31b:	c3                   	ret    

0000031c <atoo>:

int
atoo(const char *s)
{
 31c:	55                   	push   %ebp
 31d:	89 e5                	mov    %esp,%ebp
 31f:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 322:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 329:	eb 04                	jmp    32f <atoo+0x13>
 32b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 32f:	8b 45 08             	mov    0x8(%ebp),%eax
 332:	0f b6 00             	movzbl (%eax),%eax
 335:	3c 20                	cmp    $0x20,%al
 337:	74 f2                	je     32b <atoo+0xf>
  sign = (*s == '-') ? -1 : 1;
 339:	8b 45 08             	mov    0x8(%ebp),%eax
 33c:	0f b6 00             	movzbl (%eax),%eax
 33f:	3c 2d                	cmp    $0x2d,%al
 341:	75 07                	jne    34a <atoo+0x2e>
 343:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 348:	eb 05                	jmp    34f <atoo+0x33>
 34a:	b8 01 00 00 00       	mov    $0x1,%eax
 34f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 352:	8b 45 08             	mov    0x8(%ebp),%eax
 355:	0f b6 00             	movzbl (%eax),%eax
 358:	3c 2b                	cmp    $0x2b,%al
 35a:	74 0a                	je     366 <atoo+0x4a>
 35c:	8b 45 08             	mov    0x8(%ebp),%eax
 35f:	0f b6 00             	movzbl (%eax),%eax
 362:	3c 2d                	cmp    $0x2d,%al
 364:	75 27                	jne    38d <atoo+0x71>
    s++;
 366:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '7')
 36a:	eb 21                	jmp    38d <atoo+0x71>
    n = n*8 + *s++ - '0';
 36c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 36f:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
 376:	8b 45 08             	mov    0x8(%ebp),%eax
 379:	8d 50 01             	lea    0x1(%eax),%edx
 37c:	89 55 08             	mov    %edx,0x8(%ebp)
 37f:	0f b6 00             	movzbl (%eax),%eax
 382:	0f be c0             	movsbl %al,%eax
 385:	01 c8                	add    %ecx,%eax
 387:	83 e8 30             	sub    $0x30,%eax
 38a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '7')
 38d:	8b 45 08             	mov    0x8(%ebp),%eax
 390:	0f b6 00             	movzbl (%eax),%eax
 393:	3c 2f                	cmp    $0x2f,%al
 395:	7e 0a                	jle    3a1 <atoo+0x85>
 397:	8b 45 08             	mov    0x8(%ebp),%eax
 39a:	0f b6 00             	movzbl (%eax),%eax
 39d:	3c 37                	cmp    $0x37,%al
 39f:	7e cb                	jle    36c <atoo+0x50>
    n = n*8 + *s++ - '0';
  return sign*n;
 3a1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 3a4:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 3a8:	c9                   	leave  
 3a9:	c3                   	ret    

000003aa <memmove>:


void*
memmove(void *vdst, void *vsrc, int n)
{
 3aa:	55                   	push   %ebp
 3ab:	89 e5                	mov    %esp,%ebp
 3ad:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 3b0:	8b 45 08             	mov    0x8(%ebp),%eax
 3b3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 3b6:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 3bc:	eb 17                	jmp    3d5 <memmove+0x2b>
    *dst++ = *src++;
 3be:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3c1:	8d 50 01             	lea    0x1(%eax),%edx
 3c4:	89 55 fc             	mov    %edx,-0x4(%ebp)
 3c7:	8b 55 f8             	mov    -0x8(%ebp),%edx
 3ca:	8d 4a 01             	lea    0x1(%edx),%ecx
 3cd:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 3d0:	0f b6 12             	movzbl (%edx),%edx
 3d3:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 3d5:	8b 45 10             	mov    0x10(%ebp),%eax
 3d8:	8d 50 ff             	lea    -0x1(%eax),%edx
 3db:	89 55 10             	mov    %edx,0x10(%ebp)
 3de:	85 c0                	test   %eax,%eax
 3e0:	7f dc                	jg     3be <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 3e2:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3e5:	c9                   	leave  
 3e6:	c3                   	ret    

000003e7 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 3e7:	b8 01 00 00 00       	mov    $0x1,%eax
 3ec:	cd 40                	int    $0x40
 3ee:	c3                   	ret    

000003ef <exit>:
SYSCALL(exit)
 3ef:	b8 02 00 00 00       	mov    $0x2,%eax
 3f4:	cd 40                	int    $0x40
 3f6:	c3                   	ret    

000003f7 <wait>:
SYSCALL(wait)
 3f7:	b8 03 00 00 00       	mov    $0x3,%eax
 3fc:	cd 40                	int    $0x40
 3fe:	c3                   	ret    

000003ff <pipe>:
SYSCALL(pipe)
 3ff:	b8 04 00 00 00       	mov    $0x4,%eax
 404:	cd 40                	int    $0x40
 406:	c3                   	ret    

00000407 <read>:
SYSCALL(read)
 407:	b8 05 00 00 00       	mov    $0x5,%eax
 40c:	cd 40                	int    $0x40
 40e:	c3                   	ret    

0000040f <write>:
SYSCALL(write)
 40f:	b8 10 00 00 00       	mov    $0x10,%eax
 414:	cd 40                	int    $0x40
 416:	c3                   	ret    

00000417 <close>:
SYSCALL(close)
 417:	b8 15 00 00 00       	mov    $0x15,%eax
 41c:	cd 40                	int    $0x40
 41e:	c3                   	ret    

0000041f <kill>:
SYSCALL(kill)
 41f:	b8 06 00 00 00       	mov    $0x6,%eax
 424:	cd 40                	int    $0x40
 426:	c3                   	ret    

00000427 <exec>:
SYSCALL(exec)
 427:	b8 07 00 00 00       	mov    $0x7,%eax
 42c:	cd 40                	int    $0x40
 42e:	c3                   	ret    

0000042f <open>:
SYSCALL(open)
 42f:	b8 0f 00 00 00       	mov    $0xf,%eax
 434:	cd 40                	int    $0x40
 436:	c3                   	ret    

00000437 <mknod>:
SYSCALL(mknod)
 437:	b8 11 00 00 00       	mov    $0x11,%eax
 43c:	cd 40                	int    $0x40
 43e:	c3                   	ret    

0000043f <unlink>:
SYSCALL(unlink)
 43f:	b8 12 00 00 00       	mov    $0x12,%eax
 444:	cd 40                	int    $0x40
 446:	c3                   	ret    

00000447 <fstat>:
SYSCALL(fstat)
 447:	b8 08 00 00 00       	mov    $0x8,%eax
 44c:	cd 40                	int    $0x40
 44e:	c3                   	ret    

0000044f <link>:
SYSCALL(link)
 44f:	b8 13 00 00 00       	mov    $0x13,%eax
 454:	cd 40                	int    $0x40
 456:	c3                   	ret    

00000457 <mkdir>:
SYSCALL(mkdir)
 457:	b8 14 00 00 00       	mov    $0x14,%eax
 45c:	cd 40                	int    $0x40
 45e:	c3                   	ret    

0000045f <chdir>:
SYSCALL(chdir)
 45f:	b8 09 00 00 00       	mov    $0x9,%eax
 464:	cd 40                	int    $0x40
 466:	c3                   	ret    

00000467 <dup>:
SYSCALL(dup)
 467:	b8 0a 00 00 00       	mov    $0xa,%eax
 46c:	cd 40                	int    $0x40
 46e:	c3                   	ret    

0000046f <getpid>:
SYSCALL(getpid)
 46f:	b8 0b 00 00 00       	mov    $0xb,%eax
 474:	cd 40                	int    $0x40
 476:	c3                   	ret    

00000477 <sbrk>:
SYSCALL(sbrk)
 477:	b8 0c 00 00 00       	mov    $0xc,%eax
 47c:	cd 40                	int    $0x40
 47e:	c3                   	ret    

0000047f <sleep>:
SYSCALL(sleep)
 47f:	b8 0d 00 00 00       	mov    $0xd,%eax
 484:	cd 40                	int    $0x40
 486:	c3                   	ret    

00000487 <uptime>:
SYSCALL(uptime)
 487:	b8 0e 00 00 00       	mov    $0xe,%eax
 48c:	cd 40                	int    $0x40
 48e:	c3                   	ret    

0000048f <halt>:
SYSCALL(halt)
 48f:	b8 16 00 00 00       	mov    $0x16,%eax
 494:	cd 40                	int    $0x40
 496:	c3                   	ret    

00000497 <date>:
SYSCALL(date)
 497:	b8 17 00 00 00       	mov    $0x17,%eax
 49c:	cd 40                	int    $0x40
 49e:	c3                   	ret    

0000049f <getuid>:
SYSCALL(getuid)
 49f:	b8 18 00 00 00       	mov    $0x18,%eax
 4a4:	cd 40                	int    $0x40
 4a6:	c3                   	ret    

000004a7 <getgid>:
SYSCALL(getgid)
 4a7:	b8 19 00 00 00       	mov    $0x19,%eax
 4ac:	cd 40                	int    $0x40
 4ae:	c3                   	ret    

000004af <getppid>:
SYSCALL(getppid)
 4af:	b8 1a 00 00 00       	mov    $0x1a,%eax
 4b4:	cd 40                	int    $0x40
 4b6:	c3                   	ret    

000004b7 <setuid>:
SYSCALL(setuid)
 4b7:	b8 1b 00 00 00       	mov    $0x1b,%eax
 4bc:	cd 40                	int    $0x40
 4be:	c3                   	ret    

000004bf <setgid>:
SYSCALL(setgid)
 4bf:	b8 1c 00 00 00       	mov    $0x1c,%eax
 4c4:	cd 40                	int    $0x40
 4c6:	c3                   	ret    

000004c7 <getprocs>:
SYSCALL(getprocs)
 4c7:	b8 1d 00 00 00       	mov    $0x1d,%eax
 4cc:	cd 40                	int    $0x40
 4ce:	c3                   	ret    

000004cf <setpriority>:
SYSCALL(setpriority)
 4cf:	b8 1e 00 00 00       	mov    $0x1e,%eax
 4d4:	cd 40                	int    $0x40
 4d6:	c3                   	ret    

000004d7 <chmod>:
SYSCALL(chmod)
 4d7:	b8 1f 00 00 00       	mov    $0x1f,%eax
 4dc:	cd 40                	int    $0x40
 4de:	c3                   	ret    

000004df <chown>:
SYSCALL(chown)
 4df:	b8 20 00 00 00       	mov    $0x20,%eax
 4e4:	cd 40                	int    $0x40
 4e6:	c3                   	ret    

000004e7 <chgrp>:
SYSCALL(chgrp)
 4e7:	b8 21 00 00 00       	mov    $0x21,%eax
 4ec:	cd 40                	int    $0x40
 4ee:	c3                   	ret    

000004ef <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 4ef:	55                   	push   %ebp
 4f0:	89 e5                	mov    %esp,%ebp
 4f2:	83 ec 18             	sub    $0x18,%esp
 4f5:	8b 45 0c             	mov    0xc(%ebp),%eax
 4f8:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 4fb:	83 ec 04             	sub    $0x4,%esp
 4fe:	6a 01                	push   $0x1
 500:	8d 45 f4             	lea    -0xc(%ebp),%eax
 503:	50                   	push   %eax
 504:	ff 75 08             	pushl  0x8(%ebp)
 507:	e8 03 ff ff ff       	call   40f <write>
 50c:	83 c4 10             	add    $0x10,%esp
}
 50f:	90                   	nop
 510:	c9                   	leave  
 511:	c3                   	ret    

00000512 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 512:	55                   	push   %ebp
 513:	89 e5                	mov    %esp,%ebp
 515:	53                   	push   %ebx
 516:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 519:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 520:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 524:	74 17                	je     53d <printint+0x2b>
 526:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 52a:	79 11                	jns    53d <printint+0x2b>
    neg = 1;
 52c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 533:	8b 45 0c             	mov    0xc(%ebp),%eax
 536:	f7 d8                	neg    %eax
 538:	89 45 ec             	mov    %eax,-0x14(%ebp)
 53b:	eb 06                	jmp    543 <printint+0x31>
  } else {
    x = xx;
 53d:	8b 45 0c             	mov    0xc(%ebp),%eax
 540:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 543:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 54a:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 54d:	8d 41 01             	lea    0x1(%ecx),%eax
 550:	89 45 f4             	mov    %eax,-0xc(%ebp)
 553:	8b 5d 10             	mov    0x10(%ebp),%ebx
 556:	8b 45 ec             	mov    -0x14(%ebp),%eax
 559:	ba 00 00 00 00       	mov    $0x0,%edx
 55e:	f7 f3                	div    %ebx
 560:	89 d0                	mov    %edx,%eax
 562:	0f b6 80 48 0c 00 00 	movzbl 0xc48(%eax),%eax
 569:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 56d:	8b 5d 10             	mov    0x10(%ebp),%ebx
 570:	8b 45 ec             	mov    -0x14(%ebp),%eax
 573:	ba 00 00 00 00       	mov    $0x0,%edx
 578:	f7 f3                	div    %ebx
 57a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 57d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 581:	75 c7                	jne    54a <printint+0x38>
  if(neg)
 583:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 587:	74 2d                	je     5b6 <printint+0xa4>
    buf[i++] = '-';
 589:	8b 45 f4             	mov    -0xc(%ebp),%eax
 58c:	8d 50 01             	lea    0x1(%eax),%edx
 58f:	89 55 f4             	mov    %edx,-0xc(%ebp)
 592:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 597:	eb 1d                	jmp    5b6 <printint+0xa4>
    putc(fd, buf[i]);
 599:	8d 55 dc             	lea    -0x24(%ebp),%edx
 59c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 59f:	01 d0                	add    %edx,%eax
 5a1:	0f b6 00             	movzbl (%eax),%eax
 5a4:	0f be c0             	movsbl %al,%eax
 5a7:	83 ec 08             	sub    $0x8,%esp
 5aa:	50                   	push   %eax
 5ab:	ff 75 08             	pushl  0x8(%ebp)
 5ae:	e8 3c ff ff ff       	call   4ef <putc>
 5b3:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 5b6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 5ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5be:	79 d9                	jns    599 <printint+0x87>
    putc(fd, buf[i]);
}
 5c0:	90                   	nop
 5c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 5c4:	c9                   	leave  
 5c5:	c3                   	ret    

000005c6 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5c6:	55                   	push   %ebp
 5c7:	89 e5                	mov    %esp,%ebp
 5c9:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 5cc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5d3:	8d 45 0c             	lea    0xc(%ebp),%eax
 5d6:	83 c0 04             	add    $0x4,%eax
 5d9:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 5dc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 5e3:	e9 59 01 00 00       	jmp    741 <printf+0x17b>
    c = fmt[i] & 0xff;
 5e8:	8b 55 0c             	mov    0xc(%ebp),%edx
 5eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5ee:	01 d0                	add    %edx,%eax
 5f0:	0f b6 00             	movzbl (%eax),%eax
 5f3:	0f be c0             	movsbl %al,%eax
 5f6:	25 ff 00 00 00       	and    $0xff,%eax
 5fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 5fe:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 602:	75 2c                	jne    630 <printf+0x6a>
      if(c == '%'){
 604:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 608:	75 0c                	jne    616 <printf+0x50>
        state = '%';
 60a:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 611:	e9 27 01 00 00       	jmp    73d <printf+0x177>
      } else {
        putc(fd, c);
 616:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 619:	0f be c0             	movsbl %al,%eax
 61c:	83 ec 08             	sub    $0x8,%esp
 61f:	50                   	push   %eax
 620:	ff 75 08             	pushl  0x8(%ebp)
 623:	e8 c7 fe ff ff       	call   4ef <putc>
 628:	83 c4 10             	add    $0x10,%esp
 62b:	e9 0d 01 00 00       	jmp    73d <printf+0x177>
      }
    } else if(state == '%'){
 630:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 634:	0f 85 03 01 00 00    	jne    73d <printf+0x177>
      if(c == 'd'){
 63a:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 63e:	75 1e                	jne    65e <printf+0x98>
        printint(fd, *ap, 10, 1);
 640:	8b 45 e8             	mov    -0x18(%ebp),%eax
 643:	8b 00                	mov    (%eax),%eax
 645:	6a 01                	push   $0x1
 647:	6a 0a                	push   $0xa
 649:	50                   	push   %eax
 64a:	ff 75 08             	pushl  0x8(%ebp)
 64d:	e8 c0 fe ff ff       	call   512 <printint>
 652:	83 c4 10             	add    $0x10,%esp
        ap++;
 655:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 659:	e9 d8 00 00 00       	jmp    736 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 65e:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 662:	74 06                	je     66a <printf+0xa4>
 664:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 668:	75 1e                	jne    688 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 66a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 66d:	8b 00                	mov    (%eax),%eax
 66f:	6a 00                	push   $0x0
 671:	6a 10                	push   $0x10
 673:	50                   	push   %eax
 674:	ff 75 08             	pushl  0x8(%ebp)
 677:	e8 96 fe ff ff       	call   512 <printint>
 67c:	83 c4 10             	add    $0x10,%esp
        ap++;
 67f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 683:	e9 ae 00 00 00       	jmp    736 <printf+0x170>
      } else if(c == 's'){
 688:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 68c:	75 43                	jne    6d1 <printf+0x10b>
        s = (char*)*ap;
 68e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 691:	8b 00                	mov    (%eax),%eax
 693:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 696:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 69a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 69e:	75 25                	jne    6c5 <printf+0xff>
          s = "(null)";
 6a0:	c7 45 f4 d5 09 00 00 	movl   $0x9d5,-0xc(%ebp)
        while(*s != 0){
 6a7:	eb 1c                	jmp    6c5 <printf+0xff>
          putc(fd, *s);
 6a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6ac:	0f b6 00             	movzbl (%eax),%eax
 6af:	0f be c0             	movsbl %al,%eax
 6b2:	83 ec 08             	sub    $0x8,%esp
 6b5:	50                   	push   %eax
 6b6:	ff 75 08             	pushl  0x8(%ebp)
 6b9:	e8 31 fe ff ff       	call   4ef <putc>
 6be:	83 c4 10             	add    $0x10,%esp
          s++;
 6c1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 6c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6c8:	0f b6 00             	movzbl (%eax),%eax
 6cb:	84 c0                	test   %al,%al
 6cd:	75 da                	jne    6a9 <printf+0xe3>
 6cf:	eb 65                	jmp    736 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6d1:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 6d5:	75 1d                	jne    6f4 <printf+0x12e>
        putc(fd, *ap);
 6d7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6da:	8b 00                	mov    (%eax),%eax
 6dc:	0f be c0             	movsbl %al,%eax
 6df:	83 ec 08             	sub    $0x8,%esp
 6e2:	50                   	push   %eax
 6e3:	ff 75 08             	pushl  0x8(%ebp)
 6e6:	e8 04 fe ff ff       	call   4ef <putc>
 6eb:	83 c4 10             	add    $0x10,%esp
        ap++;
 6ee:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6f2:	eb 42                	jmp    736 <printf+0x170>
      } else if(c == '%'){
 6f4:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6f8:	75 17                	jne    711 <printf+0x14b>
        putc(fd, c);
 6fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6fd:	0f be c0             	movsbl %al,%eax
 700:	83 ec 08             	sub    $0x8,%esp
 703:	50                   	push   %eax
 704:	ff 75 08             	pushl  0x8(%ebp)
 707:	e8 e3 fd ff ff       	call   4ef <putc>
 70c:	83 c4 10             	add    $0x10,%esp
 70f:	eb 25                	jmp    736 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 711:	83 ec 08             	sub    $0x8,%esp
 714:	6a 25                	push   $0x25
 716:	ff 75 08             	pushl  0x8(%ebp)
 719:	e8 d1 fd ff ff       	call   4ef <putc>
 71e:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 721:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 724:	0f be c0             	movsbl %al,%eax
 727:	83 ec 08             	sub    $0x8,%esp
 72a:	50                   	push   %eax
 72b:	ff 75 08             	pushl  0x8(%ebp)
 72e:	e8 bc fd ff ff       	call   4ef <putc>
 733:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 736:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 73d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 741:	8b 55 0c             	mov    0xc(%ebp),%edx
 744:	8b 45 f0             	mov    -0x10(%ebp),%eax
 747:	01 d0                	add    %edx,%eax
 749:	0f b6 00             	movzbl (%eax),%eax
 74c:	84 c0                	test   %al,%al
 74e:	0f 85 94 fe ff ff    	jne    5e8 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 754:	90                   	nop
 755:	c9                   	leave  
 756:	c3                   	ret    

00000757 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 757:	55                   	push   %ebp
 758:	89 e5                	mov    %esp,%ebp
 75a:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 75d:	8b 45 08             	mov    0x8(%ebp),%eax
 760:	83 e8 08             	sub    $0x8,%eax
 763:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 766:	a1 64 0c 00 00       	mov    0xc64,%eax
 76b:	89 45 fc             	mov    %eax,-0x4(%ebp)
 76e:	eb 24                	jmp    794 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 770:	8b 45 fc             	mov    -0x4(%ebp),%eax
 773:	8b 00                	mov    (%eax),%eax
 775:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 778:	77 12                	ja     78c <free+0x35>
 77a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 77d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 780:	77 24                	ja     7a6 <free+0x4f>
 782:	8b 45 fc             	mov    -0x4(%ebp),%eax
 785:	8b 00                	mov    (%eax),%eax
 787:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 78a:	77 1a                	ja     7a6 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 78c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78f:	8b 00                	mov    (%eax),%eax
 791:	89 45 fc             	mov    %eax,-0x4(%ebp)
 794:	8b 45 f8             	mov    -0x8(%ebp),%eax
 797:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 79a:	76 d4                	jbe    770 <free+0x19>
 79c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 79f:	8b 00                	mov    (%eax),%eax
 7a1:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7a4:	76 ca                	jbe    770 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 7a6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7a9:	8b 40 04             	mov    0x4(%eax),%eax
 7ac:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7b3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7b6:	01 c2                	add    %eax,%edx
 7b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7bb:	8b 00                	mov    (%eax),%eax
 7bd:	39 c2                	cmp    %eax,%edx
 7bf:	75 24                	jne    7e5 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 7c1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7c4:	8b 50 04             	mov    0x4(%eax),%edx
 7c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ca:	8b 00                	mov    (%eax),%eax
 7cc:	8b 40 04             	mov    0x4(%eax),%eax
 7cf:	01 c2                	add    %eax,%edx
 7d1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7d4:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 7d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7da:	8b 00                	mov    (%eax),%eax
 7dc:	8b 10                	mov    (%eax),%edx
 7de:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7e1:	89 10                	mov    %edx,(%eax)
 7e3:	eb 0a                	jmp    7ef <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 7e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e8:	8b 10                	mov    (%eax),%edx
 7ea:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ed:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 7ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f2:	8b 40 04             	mov    0x4(%eax),%eax
 7f5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ff:	01 d0                	add    %edx,%eax
 801:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 804:	75 20                	jne    826 <free+0xcf>
    p->s.size += bp->s.size;
 806:	8b 45 fc             	mov    -0x4(%ebp),%eax
 809:	8b 50 04             	mov    0x4(%eax),%edx
 80c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 80f:	8b 40 04             	mov    0x4(%eax),%eax
 812:	01 c2                	add    %eax,%edx
 814:	8b 45 fc             	mov    -0x4(%ebp),%eax
 817:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 81a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 81d:	8b 10                	mov    (%eax),%edx
 81f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 822:	89 10                	mov    %edx,(%eax)
 824:	eb 08                	jmp    82e <free+0xd7>
  } else
    p->s.ptr = bp;
 826:	8b 45 fc             	mov    -0x4(%ebp),%eax
 829:	8b 55 f8             	mov    -0x8(%ebp),%edx
 82c:	89 10                	mov    %edx,(%eax)
  freep = p;
 82e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 831:	a3 64 0c 00 00       	mov    %eax,0xc64
}
 836:	90                   	nop
 837:	c9                   	leave  
 838:	c3                   	ret    

00000839 <morecore>:

static Header*
morecore(uint nu)
{
 839:	55                   	push   %ebp
 83a:	89 e5                	mov    %esp,%ebp
 83c:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 83f:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 846:	77 07                	ja     84f <morecore+0x16>
    nu = 4096;
 848:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 84f:	8b 45 08             	mov    0x8(%ebp),%eax
 852:	c1 e0 03             	shl    $0x3,%eax
 855:	83 ec 0c             	sub    $0xc,%esp
 858:	50                   	push   %eax
 859:	e8 19 fc ff ff       	call   477 <sbrk>
 85e:	83 c4 10             	add    $0x10,%esp
 861:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 864:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 868:	75 07                	jne    871 <morecore+0x38>
    return 0;
 86a:	b8 00 00 00 00       	mov    $0x0,%eax
 86f:	eb 26                	jmp    897 <morecore+0x5e>
  hp = (Header*)p;
 871:	8b 45 f4             	mov    -0xc(%ebp),%eax
 874:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 877:	8b 45 f0             	mov    -0x10(%ebp),%eax
 87a:	8b 55 08             	mov    0x8(%ebp),%edx
 87d:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 880:	8b 45 f0             	mov    -0x10(%ebp),%eax
 883:	83 c0 08             	add    $0x8,%eax
 886:	83 ec 0c             	sub    $0xc,%esp
 889:	50                   	push   %eax
 88a:	e8 c8 fe ff ff       	call   757 <free>
 88f:	83 c4 10             	add    $0x10,%esp
  return freep;
 892:	a1 64 0c 00 00       	mov    0xc64,%eax
}
 897:	c9                   	leave  
 898:	c3                   	ret    

00000899 <malloc>:

void*
malloc(uint nbytes)
{
 899:	55                   	push   %ebp
 89a:	89 e5                	mov    %esp,%ebp
 89c:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 89f:	8b 45 08             	mov    0x8(%ebp),%eax
 8a2:	83 c0 07             	add    $0x7,%eax
 8a5:	c1 e8 03             	shr    $0x3,%eax
 8a8:	83 c0 01             	add    $0x1,%eax
 8ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8ae:	a1 64 0c 00 00       	mov    0xc64,%eax
 8b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8b6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8ba:	75 23                	jne    8df <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 8bc:	c7 45 f0 5c 0c 00 00 	movl   $0xc5c,-0x10(%ebp)
 8c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8c6:	a3 64 0c 00 00       	mov    %eax,0xc64
 8cb:	a1 64 0c 00 00       	mov    0xc64,%eax
 8d0:	a3 5c 0c 00 00       	mov    %eax,0xc5c
    base.s.size = 0;
 8d5:	c7 05 60 0c 00 00 00 	movl   $0x0,0xc60
 8dc:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8df:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8e2:	8b 00                	mov    (%eax),%eax
 8e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 8e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ea:	8b 40 04             	mov    0x4(%eax),%eax
 8ed:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8f0:	72 4d                	jb     93f <malloc+0xa6>
      if(p->s.size == nunits)
 8f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f5:	8b 40 04             	mov    0x4(%eax),%eax
 8f8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8fb:	75 0c                	jne    909 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 8fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 900:	8b 10                	mov    (%eax),%edx
 902:	8b 45 f0             	mov    -0x10(%ebp),%eax
 905:	89 10                	mov    %edx,(%eax)
 907:	eb 26                	jmp    92f <malloc+0x96>
      else {
        p->s.size -= nunits;
 909:	8b 45 f4             	mov    -0xc(%ebp),%eax
 90c:	8b 40 04             	mov    0x4(%eax),%eax
 90f:	2b 45 ec             	sub    -0x14(%ebp),%eax
 912:	89 c2                	mov    %eax,%edx
 914:	8b 45 f4             	mov    -0xc(%ebp),%eax
 917:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 91a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 91d:	8b 40 04             	mov    0x4(%eax),%eax
 920:	c1 e0 03             	shl    $0x3,%eax
 923:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 926:	8b 45 f4             	mov    -0xc(%ebp),%eax
 929:	8b 55 ec             	mov    -0x14(%ebp),%edx
 92c:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 92f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 932:	a3 64 0c 00 00       	mov    %eax,0xc64
      return (void*)(p + 1);
 937:	8b 45 f4             	mov    -0xc(%ebp),%eax
 93a:	83 c0 08             	add    $0x8,%eax
 93d:	eb 3b                	jmp    97a <malloc+0xe1>
    }
    if(p == freep)
 93f:	a1 64 0c 00 00       	mov    0xc64,%eax
 944:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 947:	75 1e                	jne    967 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 949:	83 ec 0c             	sub    $0xc,%esp
 94c:	ff 75 ec             	pushl  -0x14(%ebp)
 94f:	e8 e5 fe ff ff       	call   839 <morecore>
 954:	83 c4 10             	add    $0x10,%esp
 957:	89 45 f4             	mov    %eax,-0xc(%ebp)
 95a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 95e:	75 07                	jne    967 <malloc+0xce>
        return 0;
 960:	b8 00 00 00 00       	mov    $0x0,%eax
 965:	eb 13                	jmp    97a <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 967:	8b 45 f4             	mov    -0xc(%ebp),%eax
 96a:	89 45 f0             	mov    %eax,-0x10(%ebp)
 96d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 970:	8b 00                	mov    (%eax),%eax
 972:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 975:	e9 6d ff ff ff       	jmp    8e7 <malloc+0x4e>
}
 97a:	c9                   	leave  
 97b:	c3                   	ret    
