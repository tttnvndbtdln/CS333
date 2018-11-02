
_chown:     file format elf32-i386


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
  int uid;
  int rc;

  if(argc != 3)
  14:	83 3b 03             	cmpl   $0x3,(%ebx)
  17:	74 17                	je     30 <main+0x30>
  {
    printf(2, "\nIncorrect number of arguments.\n");
  19:	83 ec 08             	sub    $0x8,%esp
  1c:	68 4c 09 00 00       	push   $0x94c
  21:	6a 02                	push   $0x2
  23:	e8 6e 05 00 00       	call   596 <printf>
  28:	83 c4 10             	add    $0x10,%esp
    exit();
  2b:	e8 8f 03 00 00       	call   3bf <exit>
  } 
  
  uid = atoi(argv[1]);
  30:	8b 43 04             	mov    0x4(%ebx),%eax
  33:	83 c0 04             	add    $0x4,%eax
  36:	8b 00                	mov    (%eax),%eax
  38:	83 ec 0c             	sub    $0xc,%esp
  3b:	50                   	push   %eax
  3c:	e8 19 02 00 00       	call   25a <atoi>
  41:	83 c4 10             	add    $0x10,%esp
  44:	89 45 f4             	mov    %eax,-0xc(%ebp)

  rc = chown(argv[2], uid);
  47:	8b 43 04             	mov    0x4(%ebx),%eax
  4a:	83 c0 08             	add    $0x8,%eax
  4d:	8b 00                	mov    (%eax),%eax
  4f:	83 ec 08             	sub    $0x8,%esp
  52:	ff 75 f4             	pushl  -0xc(%ebp)
  55:	50                   	push   %eax
  56:	e8 54 04 00 00       	call   4af <chown>
  5b:	83 c4 10             	add    $0x10,%esp
  5e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(rc != 0)
  61:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  65:	74 17                	je     7e <main+0x7e>
  {
    printf(2, "\nChange UID failed.\n");
  67:	83 ec 08             	sub    $0x8,%esp
  6a:	68 6d 09 00 00       	push   $0x96d
  6f:	6a 02                	push   $0x2
  71:	e8 20 05 00 00       	call   596 <printf>
  76:	83 c4 10             	add    $0x10,%esp
    exit();
  79:	e8 41 03 00 00       	call   3bf <exit>
  }
  else
  {
    printf(2, "\nUID changed.\n");
  7e:	83 ec 08             	sub    $0x8,%esp
  81:	68 82 09 00 00       	push   $0x982
  86:	6a 02                	push   $0x2
  88:	e8 09 05 00 00       	call   596 <printf>
  8d:	83 c4 10             	add    $0x10,%esp
    exit();
  90:	e8 2a 03 00 00       	call   3bf <exit>

00000095 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  95:	55                   	push   %ebp
  96:	89 e5                	mov    %esp,%ebp
  98:	57                   	push   %edi
  99:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  9a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  9d:	8b 55 10             	mov    0x10(%ebp),%edx
  a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  a3:	89 cb                	mov    %ecx,%ebx
  a5:	89 df                	mov    %ebx,%edi
  a7:	89 d1                	mov    %edx,%ecx
  a9:	fc                   	cld    
  aa:	f3 aa                	rep stos %al,%es:(%edi)
  ac:	89 ca                	mov    %ecx,%edx
  ae:	89 fb                	mov    %edi,%ebx
  b0:	89 5d 08             	mov    %ebx,0x8(%ebp)
  b3:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  b6:	90                   	nop
  b7:	5b                   	pop    %ebx
  b8:	5f                   	pop    %edi
  b9:	5d                   	pop    %ebp
  ba:	c3                   	ret    

000000bb <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  bb:	55                   	push   %ebp
  bc:	89 e5                	mov    %esp,%ebp
  be:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  c1:	8b 45 08             	mov    0x8(%ebp),%eax
  c4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  c7:	90                   	nop
  c8:	8b 45 08             	mov    0x8(%ebp),%eax
  cb:	8d 50 01             	lea    0x1(%eax),%edx
  ce:	89 55 08             	mov    %edx,0x8(%ebp)
  d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  d4:	8d 4a 01             	lea    0x1(%edx),%ecx
  d7:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  da:	0f b6 12             	movzbl (%edx),%edx
  dd:	88 10                	mov    %dl,(%eax)
  df:	0f b6 00             	movzbl (%eax),%eax
  e2:	84 c0                	test   %al,%al
  e4:	75 e2                	jne    c8 <strcpy+0xd>
    ;
  return os;
  e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  e9:	c9                   	leave  
  ea:	c3                   	ret    

000000eb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  eb:	55                   	push   %ebp
  ec:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  ee:	eb 08                	jmp    f8 <strcmp+0xd>
    p++, q++;
  f0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  f4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  f8:	8b 45 08             	mov    0x8(%ebp),%eax
  fb:	0f b6 00             	movzbl (%eax),%eax
  fe:	84 c0                	test   %al,%al
 100:	74 10                	je     112 <strcmp+0x27>
 102:	8b 45 08             	mov    0x8(%ebp),%eax
 105:	0f b6 10             	movzbl (%eax),%edx
 108:	8b 45 0c             	mov    0xc(%ebp),%eax
 10b:	0f b6 00             	movzbl (%eax),%eax
 10e:	38 c2                	cmp    %al,%dl
 110:	74 de                	je     f0 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 112:	8b 45 08             	mov    0x8(%ebp),%eax
 115:	0f b6 00             	movzbl (%eax),%eax
 118:	0f b6 d0             	movzbl %al,%edx
 11b:	8b 45 0c             	mov    0xc(%ebp),%eax
 11e:	0f b6 00             	movzbl (%eax),%eax
 121:	0f b6 c0             	movzbl %al,%eax
 124:	29 c2                	sub    %eax,%edx
 126:	89 d0                	mov    %edx,%eax
}
 128:	5d                   	pop    %ebp
 129:	c3                   	ret    

0000012a <strlen>:

uint
strlen(char *s)
{
 12a:	55                   	push   %ebp
 12b:	89 e5                	mov    %esp,%ebp
 12d:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 130:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 137:	eb 04                	jmp    13d <strlen+0x13>
 139:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 13d:	8b 55 fc             	mov    -0x4(%ebp),%edx
 140:	8b 45 08             	mov    0x8(%ebp),%eax
 143:	01 d0                	add    %edx,%eax
 145:	0f b6 00             	movzbl (%eax),%eax
 148:	84 c0                	test   %al,%al
 14a:	75 ed                	jne    139 <strlen+0xf>
    ;
  return n;
 14c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 14f:	c9                   	leave  
 150:	c3                   	ret    

00000151 <memset>:

void*
memset(void *dst, int c, uint n)
{
 151:	55                   	push   %ebp
 152:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 154:	8b 45 10             	mov    0x10(%ebp),%eax
 157:	50                   	push   %eax
 158:	ff 75 0c             	pushl  0xc(%ebp)
 15b:	ff 75 08             	pushl  0x8(%ebp)
 15e:	e8 32 ff ff ff       	call   95 <stosb>
 163:	83 c4 0c             	add    $0xc,%esp
  return dst;
 166:	8b 45 08             	mov    0x8(%ebp),%eax
}
 169:	c9                   	leave  
 16a:	c3                   	ret    

0000016b <strchr>:

char*
strchr(const char *s, char c)
{
 16b:	55                   	push   %ebp
 16c:	89 e5                	mov    %esp,%ebp
 16e:	83 ec 04             	sub    $0x4,%esp
 171:	8b 45 0c             	mov    0xc(%ebp),%eax
 174:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 177:	eb 14                	jmp    18d <strchr+0x22>
    if(*s == c)
 179:	8b 45 08             	mov    0x8(%ebp),%eax
 17c:	0f b6 00             	movzbl (%eax),%eax
 17f:	3a 45 fc             	cmp    -0x4(%ebp),%al
 182:	75 05                	jne    189 <strchr+0x1e>
      return (char*)s;
 184:	8b 45 08             	mov    0x8(%ebp),%eax
 187:	eb 13                	jmp    19c <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 189:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 18d:	8b 45 08             	mov    0x8(%ebp),%eax
 190:	0f b6 00             	movzbl (%eax),%eax
 193:	84 c0                	test   %al,%al
 195:	75 e2                	jne    179 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 197:	b8 00 00 00 00       	mov    $0x0,%eax
}
 19c:	c9                   	leave  
 19d:	c3                   	ret    

0000019e <gets>:

char*
gets(char *buf, int max)
{
 19e:	55                   	push   %ebp
 19f:	89 e5                	mov    %esp,%ebp
 1a1:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1a4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1ab:	eb 42                	jmp    1ef <gets+0x51>
    cc = read(0, &c, 1);
 1ad:	83 ec 04             	sub    $0x4,%esp
 1b0:	6a 01                	push   $0x1
 1b2:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1b5:	50                   	push   %eax
 1b6:	6a 00                	push   $0x0
 1b8:	e8 1a 02 00 00       	call   3d7 <read>
 1bd:	83 c4 10             	add    $0x10,%esp
 1c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1c3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1c7:	7e 33                	jle    1fc <gets+0x5e>
      break;
    buf[i++] = c;
 1c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1cc:	8d 50 01             	lea    0x1(%eax),%edx
 1cf:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1d2:	89 c2                	mov    %eax,%edx
 1d4:	8b 45 08             	mov    0x8(%ebp),%eax
 1d7:	01 c2                	add    %eax,%edx
 1d9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1dd:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1df:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1e3:	3c 0a                	cmp    $0xa,%al
 1e5:	74 16                	je     1fd <gets+0x5f>
 1e7:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1eb:	3c 0d                	cmp    $0xd,%al
 1ed:	74 0e                	je     1fd <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1f2:	83 c0 01             	add    $0x1,%eax
 1f5:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1f8:	7c b3                	jl     1ad <gets+0xf>
 1fa:	eb 01                	jmp    1fd <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 1fc:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
 200:	8b 45 08             	mov    0x8(%ebp),%eax
 203:	01 d0                	add    %edx,%eax
 205:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 208:	8b 45 08             	mov    0x8(%ebp),%eax
}
 20b:	c9                   	leave  
 20c:	c3                   	ret    

0000020d <stat>:

int
stat(char *n, struct stat *st)
{
 20d:	55                   	push   %ebp
 20e:	89 e5                	mov    %esp,%ebp
 210:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 213:	83 ec 08             	sub    $0x8,%esp
 216:	6a 00                	push   $0x0
 218:	ff 75 08             	pushl  0x8(%ebp)
 21b:	e8 df 01 00 00       	call   3ff <open>
 220:	83 c4 10             	add    $0x10,%esp
 223:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 226:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 22a:	79 07                	jns    233 <stat+0x26>
    return -1;
 22c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 231:	eb 25                	jmp    258 <stat+0x4b>
  r = fstat(fd, st);
 233:	83 ec 08             	sub    $0x8,%esp
 236:	ff 75 0c             	pushl  0xc(%ebp)
 239:	ff 75 f4             	pushl  -0xc(%ebp)
 23c:	e8 d6 01 00 00       	call   417 <fstat>
 241:	83 c4 10             	add    $0x10,%esp
 244:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 247:	83 ec 0c             	sub    $0xc,%esp
 24a:	ff 75 f4             	pushl  -0xc(%ebp)
 24d:	e8 95 01 00 00       	call   3e7 <close>
 252:	83 c4 10             	add    $0x10,%esp
  return r;
 255:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 258:	c9                   	leave  
 259:	c3                   	ret    

0000025a <atoi>:

int
atoi(const char *s)
{
 25a:	55                   	push   %ebp
 25b:	89 e5                	mov    %esp,%ebp
 25d:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 260:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 267:	eb 04                	jmp    26d <atoi+0x13>
 269:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 26d:	8b 45 08             	mov    0x8(%ebp),%eax
 270:	0f b6 00             	movzbl (%eax),%eax
 273:	3c 20                	cmp    $0x20,%al
 275:	74 f2                	je     269 <atoi+0xf>
  sign = (*s == '-') ? -1 : 1;
 277:	8b 45 08             	mov    0x8(%ebp),%eax
 27a:	0f b6 00             	movzbl (%eax),%eax
 27d:	3c 2d                	cmp    $0x2d,%al
 27f:	75 07                	jne    288 <atoi+0x2e>
 281:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 286:	eb 05                	jmp    28d <atoi+0x33>
 288:	b8 01 00 00 00       	mov    $0x1,%eax
 28d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 290:	8b 45 08             	mov    0x8(%ebp),%eax
 293:	0f b6 00             	movzbl (%eax),%eax
 296:	3c 2b                	cmp    $0x2b,%al
 298:	74 0a                	je     2a4 <atoi+0x4a>
 29a:	8b 45 08             	mov    0x8(%ebp),%eax
 29d:	0f b6 00             	movzbl (%eax),%eax
 2a0:	3c 2d                	cmp    $0x2d,%al
 2a2:	75 2b                	jne    2cf <atoi+0x75>
    s++;
 2a4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '9')
 2a8:	eb 25                	jmp    2cf <atoi+0x75>
    n = n*10 + *s++ - '0';
 2aa:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2ad:	89 d0                	mov    %edx,%eax
 2af:	c1 e0 02             	shl    $0x2,%eax
 2b2:	01 d0                	add    %edx,%eax
 2b4:	01 c0                	add    %eax,%eax
 2b6:	89 c1                	mov    %eax,%ecx
 2b8:	8b 45 08             	mov    0x8(%ebp),%eax
 2bb:	8d 50 01             	lea    0x1(%eax),%edx
 2be:	89 55 08             	mov    %edx,0x8(%ebp)
 2c1:	0f b6 00             	movzbl (%eax),%eax
 2c4:	0f be c0             	movsbl %al,%eax
 2c7:	01 c8                	add    %ecx,%eax
 2c9:	83 e8 30             	sub    $0x30,%eax
 2cc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '9')
 2cf:	8b 45 08             	mov    0x8(%ebp),%eax
 2d2:	0f b6 00             	movzbl (%eax),%eax
 2d5:	3c 2f                	cmp    $0x2f,%al
 2d7:	7e 0a                	jle    2e3 <atoi+0x89>
 2d9:	8b 45 08             	mov    0x8(%ebp),%eax
 2dc:	0f b6 00             	movzbl (%eax),%eax
 2df:	3c 39                	cmp    $0x39,%al
 2e1:	7e c7                	jle    2aa <atoi+0x50>
    n = n*10 + *s++ - '0';
  return sign*n;
 2e3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 2e6:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 2ea:	c9                   	leave  
 2eb:	c3                   	ret    

000002ec <atoo>:

int
atoo(const char *s)
{
 2ec:	55                   	push   %ebp
 2ed:	89 e5                	mov    %esp,%ebp
 2ef:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 2f2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 2f9:	eb 04                	jmp    2ff <atoo+0x13>
 2fb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2ff:	8b 45 08             	mov    0x8(%ebp),%eax
 302:	0f b6 00             	movzbl (%eax),%eax
 305:	3c 20                	cmp    $0x20,%al
 307:	74 f2                	je     2fb <atoo+0xf>
  sign = (*s == '-') ? -1 : 1;
 309:	8b 45 08             	mov    0x8(%ebp),%eax
 30c:	0f b6 00             	movzbl (%eax),%eax
 30f:	3c 2d                	cmp    $0x2d,%al
 311:	75 07                	jne    31a <atoo+0x2e>
 313:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 318:	eb 05                	jmp    31f <atoo+0x33>
 31a:	b8 01 00 00 00       	mov    $0x1,%eax
 31f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 322:	8b 45 08             	mov    0x8(%ebp),%eax
 325:	0f b6 00             	movzbl (%eax),%eax
 328:	3c 2b                	cmp    $0x2b,%al
 32a:	74 0a                	je     336 <atoo+0x4a>
 32c:	8b 45 08             	mov    0x8(%ebp),%eax
 32f:	0f b6 00             	movzbl (%eax),%eax
 332:	3c 2d                	cmp    $0x2d,%al
 334:	75 27                	jne    35d <atoo+0x71>
    s++;
 336:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '7')
 33a:	eb 21                	jmp    35d <atoo+0x71>
    n = n*8 + *s++ - '0';
 33c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 33f:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
 346:	8b 45 08             	mov    0x8(%ebp),%eax
 349:	8d 50 01             	lea    0x1(%eax),%edx
 34c:	89 55 08             	mov    %edx,0x8(%ebp)
 34f:	0f b6 00             	movzbl (%eax),%eax
 352:	0f be c0             	movsbl %al,%eax
 355:	01 c8                	add    %ecx,%eax
 357:	83 e8 30             	sub    $0x30,%eax
 35a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '7')
 35d:	8b 45 08             	mov    0x8(%ebp),%eax
 360:	0f b6 00             	movzbl (%eax),%eax
 363:	3c 2f                	cmp    $0x2f,%al
 365:	7e 0a                	jle    371 <atoo+0x85>
 367:	8b 45 08             	mov    0x8(%ebp),%eax
 36a:	0f b6 00             	movzbl (%eax),%eax
 36d:	3c 37                	cmp    $0x37,%al
 36f:	7e cb                	jle    33c <atoo+0x50>
    n = n*8 + *s++ - '0';
  return sign*n;
 371:	8b 45 f8             	mov    -0x8(%ebp),%eax
 374:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 378:	c9                   	leave  
 379:	c3                   	ret    

0000037a <memmove>:


void*
memmove(void *vdst, void *vsrc, int n)
{
 37a:	55                   	push   %ebp
 37b:	89 e5                	mov    %esp,%ebp
 37d:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 380:	8b 45 08             	mov    0x8(%ebp),%eax
 383:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 386:	8b 45 0c             	mov    0xc(%ebp),%eax
 389:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 38c:	eb 17                	jmp    3a5 <memmove+0x2b>
    *dst++ = *src++;
 38e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 391:	8d 50 01             	lea    0x1(%eax),%edx
 394:	89 55 fc             	mov    %edx,-0x4(%ebp)
 397:	8b 55 f8             	mov    -0x8(%ebp),%edx
 39a:	8d 4a 01             	lea    0x1(%edx),%ecx
 39d:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 3a0:	0f b6 12             	movzbl (%edx),%edx
 3a3:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 3a5:	8b 45 10             	mov    0x10(%ebp),%eax
 3a8:	8d 50 ff             	lea    -0x1(%eax),%edx
 3ab:	89 55 10             	mov    %edx,0x10(%ebp)
 3ae:	85 c0                	test   %eax,%eax
 3b0:	7f dc                	jg     38e <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 3b2:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3b5:	c9                   	leave  
 3b6:	c3                   	ret    

000003b7 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 3b7:	b8 01 00 00 00       	mov    $0x1,%eax
 3bc:	cd 40                	int    $0x40
 3be:	c3                   	ret    

000003bf <exit>:
SYSCALL(exit)
 3bf:	b8 02 00 00 00       	mov    $0x2,%eax
 3c4:	cd 40                	int    $0x40
 3c6:	c3                   	ret    

000003c7 <wait>:
SYSCALL(wait)
 3c7:	b8 03 00 00 00       	mov    $0x3,%eax
 3cc:	cd 40                	int    $0x40
 3ce:	c3                   	ret    

000003cf <pipe>:
SYSCALL(pipe)
 3cf:	b8 04 00 00 00       	mov    $0x4,%eax
 3d4:	cd 40                	int    $0x40
 3d6:	c3                   	ret    

000003d7 <read>:
SYSCALL(read)
 3d7:	b8 05 00 00 00       	mov    $0x5,%eax
 3dc:	cd 40                	int    $0x40
 3de:	c3                   	ret    

000003df <write>:
SYSCALL(write)
 3df:	b8 10 00 00 00       	mov    $0x10,%eax
 3e4:	cd 40                	int    $0x40
 3e6:	c3                   	ret    

000003e7 <close>:
SYSCALL(close)
 3e7:	b8 15 00 00 00       	mov    $0x15,%eax
 3ec:	cd 40                	int    $0x40
 3ee:	c3                   	ret    

000003ef <kill>:
SYSCALL(kill)
 3ef:	b8 06 00 00 00       	mov    $0x6,%eax
 3f4:	cd 40                	int    $0x40
 3f6:	c3                   	ret    

000003f7 <exec>:
SYSCALL(exec)
 3f7:	b8 07 00 00 00       	mov    $0x7,%eax
 3fc:	cd 40                	int    $0x40
 3fe:	c3                   	ret    

000003ff <open>:
SYSCALL(open)
 3ff:	b8 0f 00 00 00       	mov    $0xf,%eax
 404:	cd 40                	int    $0x40
 406:	c3                   	ret    

00000407 <mknod>:
SYSCALL(mknod)
 407:	b8 11 00 00 00       	mov    $0x11,%eax
 40c:	cd 40                	int    $0x40
 40e:	c3                   	ret    

0000040f <unlink>:
SYSCALL(unlink)
 40f:	b8 12 00 00 00       	mov    $0x12,%eax
 414:	cd 40                	int    $0x40
 416:	c3                   	ret    

00000417 <fstat>:
SYSCALL(fstat)
 417:	b8 08 00 00 00       	mov    $0x8,%eax
 41c:	cd 40                	int    $0x40
 41e:	c3                   	ret    

0000041f <link>:
SYSCALL(link)
 41f:	b8 13 00 00 00       	mov    $0x13,%eax
 424:	cd 40                	int    $0x40
 426:	c3                   	ret    

00000427 <mkdir>:
SYSCALL(mkdir)
 427:	b8 14 00 00 00       	mov    $0x14,%eax
 42c:	cd 40                	int    $0x40
 42e:	c3                   	ret    

0000042f <chdir>:
SYSCALL(chdir)
 42f:	b8 09 00 00 00       	mov    $0x9,%eax
 434:	cd 40                	int    $0x40
 436:	c3                   	ret    

00000437 <dup>:
SYSCALL(dup)
 437:	b8 0a 00 00 00       	mov    $0xa,%eax
 43c:	cd 40                	int    $0x40
 43e:	c3                   	ret    

0000043f <getpid>:
SYSCALL(getpid)
 43f:	b8 0b 00 00 00       	mov    $0xb,%eax
 444:	cd 40                	int    $0x40
 446:	c3                   	ret    

00000447 <sbrk>:
SYSCALL(sbrk)
 447:	b8 0c 00 00 00       	mov    $0xc,%eax
 44c:	cd 40                	int    $0x40
 44e:	c3                   	ret    

0000044f <sleep>:
SYSCALL(sleep)
 44f:	b8 0d 00 00 00       	mov    $0xd,%eax
 454:	cd 40                	int    $0x40
 456:	c3                   	ret    

00000457 <uptime>:
SYSCALL(uptime)
 457:	b8 0e 00 00 00       	mov    $0xe,%eax
 45c:	cd 40                	int    $0x40
 45e:	c3                   	ret    

0000045f <halt>:
SYSCALL(halt)
 45f:	b8 16 00 00 00       	mov    $0x16,%eax
 464:	cd 40                	int    $0x40
 466:	c3                   	ret    

00000467 <date>:
SYSCALL(date)
 467:	b8 17 00 00 00       	mov    $0x17,%eax
 46c:	cd 40                	int    $0x40
 46e:	c3                   	ret    

0000046f <getuid>:
SYSCALL(getuid)
 46f:	b8 18 00 00 00       	mov    $0x18,%eax
 474:	cd 40                	int    $0x40
 476:	c3                   	ret    

00000477 <getgid>:
SYSCALL(getgid)
 477:	b8 19 00 00 00       	mov    $0x19,%eax
 47c:	cd 40                	int    $0x40
 47e:	c3                   	ret    

0000047f <getppid>:
SYSCALL(getppid)
 47f:	b8 1a 00 00 00       	mov    $0x1a,%eax
 484:	cd 40                	int    $0x40
 486:	c3                   	ret    

00000487 <setuid>:
SYSCALL(setuid)
 487:	b8 1b 00 00 00       	mov    $0x1b,%eax
 48c:	cd 40                	int    $0x40
 48e:	c3                   	ret    

0000048f <setgid>:
SYSCALL(setgid)
 48f:	b8 1c 00 00 00       	mov    $0x1c,%eax
 494:	cd 40                	int    $0x40
 496:	c3                   	ret    

00000497 <getprocs>:
SYSCALL(getprocs)
 497:	b8 1d 00 00 00       	mov    $0x1d,%eax
 49c:	cd 40                	int    $0x40
 49e:	c3                   	ret    

0000049f <setpriority>:
SYSCALL(setpriority)
 49f:	b8 1e 00 00 00       	mov    $0x1e,%eax
 4a4:	cd 40                	int    $0x40
 4a6:	c3                   	ret    

000004a7 <chmod>:
SYSCALL(chmod)
 4a7:	b8 1f 00 00 00       	mov    $0x1f,%eax
 4ac:	cd 40                	int    $0x40
 4ae:	c3                   	ret    

000004af <chown>:
SYSCALL(chown)
 4af:	b8 20 00 00 00       	mov    $0x20,%eax
 4b4:	cd 40                	int    $0x40
 4b6:	c3                   	ret    

000004b7 <chgrp>:
SYSCALL(chgrp)
 4b7:	b8 21 00 00 00       	mov    $0x21,%eax
 4bc:	cd 40                	int    $0x40
 4be:	c3                   	ret    

000004bf <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 4bf:	55                   	push   %ebp
 4c0:	89 e5                	mov    %esp,%ebp
 4c2:	83 ec 18             	sub    $0x18,%esp
 4c5:	8b 45 0c             	mov    0xc(%ebp),%eax
 4c8:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 4cb:	83 ec 04             	sub    $0x4,%esp
 4ce:	6a 01                	push   $0x1
 4d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
 4d3:	50                   	push   %eax
 4d4:	ff 75 08             	pushl  0x8(%ebp)
 4d7:	e8 03 ff ff ff       	call   3df <write>
 4dc:	83 c4 10             	add    $0x10,%esp
}
 4df:	90                   	nop
 4e0:	c9                   	leave  
 4e1:	c3                   	ret    

000004e2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4e2:	55                   	push   %ebp
 4e3:	89 e5                	mov    %esp,%ebp
 4e5:	53                   	push   %ebx
 4e6:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 4e9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 4f0:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 4f4:	74 17                	je     50d <printint+0x2b>
 4f6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 4fa:	79 11                	jns    50d <printint+0x2b>
    neg = 1;
 4fc:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 503:	8b 45 0c             	mov    0xc(%ebp),%eax
 506:	f7 d8                	neg    %eax
 508:	89 45 ec             	mov    %eax,-0x14(%ebp)
 50b:	eb 06                	jmp    513 <printint+0x31>
  } else {
    x = xx;
 50d:	8b 45 0c             	mov    0xc(%ebp),%eax
 510:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 513:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 51a:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 51d:	8d 41 01             	lea    0x1(%ecx),%eax
 520:	89 45 f4             	mov    %eax,-0xc(%ebp)
 523:	8b 5d 10             	mov    0x10(%ebp),%ebx
 526:	8b 45 ec             	mov    -0x14(%ebp),%eax
 529:	ba 00 00 00 00       	mov    $0x0,%edx
 52e:	f7 f3                	div    %ebx
 530:	89 d0                	mov    %edx,%eax
 532:	0f b6 80 04 0c 00 00 	movzbl 0xc04(%eax),%eax
 539:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 53d:	8b 5d 10             	mov    0x10(%ebp),%ebx
 540:	8b 45 ec             	mov    -0x14(%ebp),%eax
 543:	ba 00 00 00 00       	mov    $0x0,%edx
 548:	f7 f3                	div    %ebx
 54a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 54d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 551:	75 c7                	jne    51a <printint+0x38>
  if(neg)
 553:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 557:	74 2d                	je     586 <printint+0xa4>
    buf[i++] = '-';
 559:	8b 45 f4             	mov    -0xc(%ebp),%eax
 55c:	8d 50 01             	lea    0x1(%eax),%edx
 55f:	89 55 f4             	mov    %edx,-0xc(%ebp)
 562:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 567:	eb 1d                	jmp    586 <printint+0xa4>
    putc(fd, buf[i]);
 569:	8d 55 dc             	lea    -0x24(%ebp),%edx
 56c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 56f:	01 d0                	add    %edx,%eax
 571:	0f b6 00             	movzbl (%eax),%eax
 574:	0f be c0             	movsbl %al,%eax
 577:	83 ec 08             	sub    $0x8,%esp
 57a:	50                   	push   %eax
 57b:	ff 75 08             	pushl  0x8(%ebp)
 57e:	e8 3c ff ff ff       	call   4bf <putc>
 583:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 586:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 58a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 58e:	79 d9                	jns    569 <printint+0x87>
    putc(fd, buf[i]);
}
 590:	90                   	nop
 591:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 594:	c9                   	leave  
 595:	c3                   	ret    

00000596 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 596:	55                   	push   %ebp
 597:	89 e5                	mov    %esp,%ebp
 599:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 59c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5a3:	8d 45 0c             	lea    0xc(%ebp),%eax
 5a6:	83 c0 04             	add    $0x4,%eax
 5a9:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 5ac:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 5b3:	e9 59 01 00 00       	jmp    711 <printf+0x17b>
    c = fmt[i] & 0xff;
 5b8:	8b 55 0c             	mov    0xc(%ebp),%edx
 5bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5be:	01 d0                	add    %edx,%eax
 5c0:	0f b6 00             	movzbl (%eax),%eax
 5c3:	0f be c0             	movsbl %al,%eax
 5c6:	25 ff 00 00 00       	and    $0xff,%eax
 5cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 5ce:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5d2:	75 2c                	jne    600 <printf+0x6a>
      if(c == '%'){
 5d4:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5d8:	75 0c                	jne    5e6 <printf+0x50>
        state = '%';
 5da:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 5e1:	e9 27 01 00 00       	jmp    70d <printf+0x177>
      } else {
        putc(fd, c);
 5e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5e9:	0f be c0             	movsbl %al,%eax
 5ec:	83 ec 08             	sub    $0x8,%esp
 5ef:	50                   	push   %eax
 5f0:	ff 75 08             	pushl  0x8(%ebp)
 5f3:	e8 c7 fe ff ff       	call   4bf <putc>
 5f8:	83 c4 10             	add    $0x10,%esp
 5fb:	e9 0d 01 00 00       	jmp    70d <printf+0x177>
      }
    } else if(state == '%'){
 600:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 604:	0f 85 03 01 00 00    	jne    70d <printf+0x177>
      if(c == 'd'){
 60a:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 60e:	75 1e                	jne    62e <printf+0x98>
        printint(fd, *ap, 10, 1);
 610:	8b 45 e8             	mov    -0x18(%ebp),%eax
 613:	8b 00                	mov    (%eax),%eax
 615:	6a 01                	push   $0x1
 617:	6a 0a                	push   $0xa
 619:	50                   	push   %eax
 61a:	ff 75 08             	pushl  0x8(%ebp)
 61d:	e8 c0 fe ff ff       	call   4e2 <printint>
 622:	83 c4 10             	add    $0x10,%esp
        ap++;
 625:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 629:	e9 d8 00 00 00       	jmp    706 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 62e:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 632:	74 06                	je     63a <printf+0xa4>
 634:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 638:	75 1e                	jne    658 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 63a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 63d:	8b 00                	mov    (%eax),%eax
 63f:	6a 00                	push   $0x0
 641:	6a 10                	push   $0x10
 643:	50                   	push   %eax
 644:	ff 75 08             	pushl  0x8(%ebp)
 647:	e8 96 fe ff ff       	call   4e2 <printint>
 64c:	83 c4 10             	add    $0x10,%esp
        ap++;
 64f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 653:	e9 ae 00 00 00       	jmp    706 <printf+0x170>
      } else if(c == 's'){
 658:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 65c:	75 43                	jne    6a1 <printf+0x10b>
        s = (char*)*ap;
 65e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 661:	8b 00                	mov    (%eax),%eax
 663:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 666:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 66a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 66e:	75 25                	jne    695 <printf+0xff>
          s = "(null)";
 670:	c7 45 f4 91 09 00 00 	movl   $0x991,-0xc(%ebp)
        while(*s != 0){
 677:	eb 1c                	jmp    695 <printf+0xff>
          putc(fd, *s);
 679:	8b 45 f4             	mov    -0xc(%ebp),%eax
 67c:	0f b6 00             	movzbl (%eax),%eax
 67f:	0f be c0             	movsbl %al,%eax
 682:	83 ec 08             	sub    $0x8,%esp
 685:	50                   	push   %eax
 686:	ff 75 08             	pushl  0x8(%ebp)
 689:	e8 31 fe ff ff       	call   4bf <putc>
 68e:	83 c4 10             	add    $0x10,%esp
          s++;
 691:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 695:	8b 45 f4             	mov    -0xc(%ebp),%eax
 698:	0f b6 00             	movzbl (%eax),%eax
 69b:	84 c0                	test   %al,%al
 69d:	75 da                	jne    679 <printf+0xe3>
 69f:	eb 65                	jmp    706 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6a1:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 6a5:	75 1d                	jne    6c4 <printf+0x12e>
        putc(fd, *ap);
 6a7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6aa:	8b 00                	mov    (%eax),%eax
 6ac:	0f be c0             	movsbl %al,%eax
 6af:	83 ec 08             	sub    $0x8,%esp
 6b2:	50                   	push   %eax
 6b3:	ff 75 08             	pushl  0x8(%ebp)
 6b6:	e8 04 fe ff ff       	call   4bf <putc>
 6bb:	83 c4 10             	add    $0x10,%esp
        ap++;
 6be:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6c2:	eb 42                	jmp    706 <printf+0x170>
      } else if(c == '%'){
 6c4:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6c8:	75 17                	jne    6e1 <printf+0x14b>
        putc(fd, c);
 6ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6cd:	0f be c0             	movsbl %al,%eax
 6d0:	83 ec 08             	sub    $0x8,%esp
 6d3:	50                   	push   %eax
 6d4:	ff 75 08             	pushl  0x8(%ebp)
 6d7:	e8 e3 fd ff ff       	call   4bf <putc>
 6dc:	83 c4 10             	add    $0x10,%esp
 6df:	eb 25                	jmp    706 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6e1:	83 ec 08             	sub    $0x8,%esp
 6e4:	6a 25                	push   $0x25
 6e6:	ff 75 08             	pushl  0x8(%ebp)
 6e9:	e8 d1 fd ff ff       	call   4bf <putc>
 6ee:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 6f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6f4:	0f be c0             	movsbl %al,%eax
 6f7:	83 ec 08             	sub    $0x8,%esp
 6fa:	50                   	push   %eax
 6fb:	ff 75 08             	pushl  0x8(%ebp)
 6fe:	e8 bc fd ff ff       	call   4bf <putc>
 703:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 706:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 70d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 711:	8b 55 0c             	mov    0xc(%ebp),%edx
 714:	8b 45 f0             	mov    -0x10(%ebp),%eax
 717:	01 d0                	add    %edx,%eax
 719:	0f b6 00             	movzbl (%eax),%eax
 71c:	84 c0                	test   %al,%al
 71e:	0f 85 94 fe ff ff    	jne    5b8 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 724:	90                   	nop
 725:	c9                   	leave  
 726:	c3                   	ret    

00000727 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 727:	55                   	push   %ebp
 728:	89 e5                	mov    %esp,%ebp
 72a:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 72d:	8b 45 08             	mov    0x8(%ebp),%eax
 730:	83 e8 08             	sub    $0x8,%eax
 733:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 736:	a1 20 0c 00 00       	mov    0xc20,%eax
 73b:	89 45 fc             	mov    %eax,-0x4(%ebp)
 73e:	eb 24                	jmp    764 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 740:	8b 45 fc             	mov    -0x4(%ebp),%eax
 743:	8b 00                	mov    (%eax),%eax
 745:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 748:	77 12                	ja     75c <free+0x35>
 74a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 74d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 750:	77 24                	ja     776 <free+0x4f>
 752:	8b 45 fc             	mov    -0x4(%ebp),%eax
 755:	8b 00                	mov    (%eax),%eax
 757:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 75a:	77 1a                	ja     776 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 75c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75f:	8b 00                	mov    (%eax),%eax
 761:	89 45 fc             	mov    %eax,-0x4(%ebp)
 764:	8b 45 f8             	mov    -0x8(%ebp),%eax
 767:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 76a:	76 d4                	jbe    740 <free+0x19>
 76c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 76f:	8b 00                	mov    (%eax),%eax
 771:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 774:	76 ca                	jbe    740 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 776:	8b 45 f8             	mov    -0x8(%ebp),%eax
 779:	8b 40 04             	mov    0x4(%eax),%eax
 77c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 783:	8b 45 f8             	mov    -0x8(%ebp),%eax
 786:	01 c2                	add    %eax,%edx
 788:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78b:	8b 00                	mov    (%eax),%eax
 78d:	39 c2                	cmp    %eax,%edx
 78f:	75 24                	jne    7b5 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 791:	8b 45 f8             	mov    -0x8(%ebp),%eax
 794:	8b 50 04             	mov    0x4(%eax),%edx
 797:	8b 45 fc             	mov    -0x4(%ebp),%eax
 79a:	8b 00                	mov    (%eax),%eax
 79c:	8b 40 04             	mov    0x4(%eax),%eax
 79f:	01 c2                	add    %eax,%edx
 7a1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7a4:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 7a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7aa:	8b 00                	mov    (%eax),%eax
 7ac:	8b 10                	mov    (%eax),%edx
 7ae:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7b1:	89 10                	mov    %edx,(%eax)
 7b3:	eb 0a                	jmp    7bf <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 7b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b8:	8b 10                	mov    (%eax),%edx
 7ba:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7bd:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 7bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c2:	8b 40 04             	mov    0x4(%eax),%eax
 7c5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7cf:	01 d0                	add    %edx,%eax
 7d1:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7d4:	75 20                	jne    7f6 <free+0xcf>
    p->s.size += bp->s.size;
 7d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d9:	8b 50 04             	mov    0x4(%eax),%edx
 7dc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7df:	8b 40 04             	mov    0x4(%eax),%eax
 7e2:	01 c2                	add    %eax,%edx
 7e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e7:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 7ea:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ed:	8b 10                	mov    (%eax),%edx
 7ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f2:	89 10                	mov    %edx,(%eax)
 7f4:	eb 08                	jmp    7fe <free+0xd7>
  } else
    p->s.ptr = bp;
 7f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f9:	8b 55 f8             	mov    -0x8(%ebp),%edx
 7fc:	89 10                	mov    %edx,(%eax)
  freep = p;
 7fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
 801:	a3 20 0c 00 00       	mov    %eax,0xc20
}
 806:	90                   	nop
 807:	c9                   	leave  
 808:	c3                   	ret    

00000809 <morecore>:

static Header*
morecore(uint nu)
{
 809:	55                   	push   %ebp
 80a:	89 e5                	mov    %esp,%ebp
 80c:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 80f:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 816:	77 07                	ja     81f <morecore+0x16>
    nu = 4096;
 818:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 81f:	8b 45 08             	mov    0x8(%ebp),%eax
 822:	c1 e0 03             	shl    $0x3,%eax
 825:	83 ec 0c             	sub    $0xc,%esp
 828:	50                   	push   %eax
 829:	e8 19 fc ff ff       	call   447 <sbrk>
 82e:	83 c4 10             	add    $0x10,%esp
 831:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 834:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 838:	75 07                	jne    841 <morecore+0x38>
    return 0;
 83a:	b8 00 00 00 00       	mov    $0x0,%eax
 83f:	eb 26                	jmp    867 <morecore+0x5e>
  hp = (Header*)p;
 841:	8b 45 f4             	mov    -0xc(%ebp),%eax
 844:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 847:	8b 45 f0             	mov    -0x10(%ebp),%eax
 84a:	8b 55 08             	mov    0x8(%ebp),%edx
 84d:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 850:	8b 45 f0             	mov    -0x10(%ebp),%eax
 853:	83 c0 08             	add    $0x8,%eax
 856:	83 ec 0c             	sub    $0xc,%esp
 859:	50                   	push   %eax
 85a:	e8 c8 fe ff ff       	call   727 <free>
 85f:	83 c4 10             	add    $0x10,%esp
  return freep;
 862:	a1 20 0c 00 00       	mov    0xc20,%eax
}
 867:	c9                   	leave  
 868:	c3                   	ret    

00000869 <malloc>:

void*
malloc(uint nbytes)
{
 869:	55                   	push   %ebp
 86a:	89 e5                	mov    %esp,%ebp
 86c:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 86f:	8b 45 08             	mov    0x8(%ebp),%eax
 872:	83 c0 07             	add    $0x7,%eax
 875:	c1 e8 03             	shr    $0x3,%eax
 878:	83 c0 01             	add    $0x1,%eax
 87b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 87e:	a1 20 0c 00 00       	mov    0xc20,%eax
 883:	89 45 f0             	mov    %eax,-0x10(%ebp)
 886:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 88a:	75 23                	jne    8af <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 88c:	c7 45 f0 18 0c 00 00 	movl   $0xc18,-0x10(%ebp)
 893:	8b 45 f0             	mov    -0x10(%ebp),%eax
 896:	a3 20 0c 00 00       	mov    %eax,0xc20
 89b:	a1 20 0c 00 00       	mov    0xc20,%eax
 8a0:	a3 18 0c 00 00       	mov    %eax,0xc18
    base.s.size = 0;
 8a5:	c7 05 1c 0c 00 00 00 	movl   $0x0,0xc1c
 8ac:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8af:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8b2:	8b 00                	mov    (%eax),%eax
 8b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 8b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ba:	8b 40 04             	mov    0x4(%eax),%eax
 8bd:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8c0:	72 4d                	jb     90f <malloc+0xa6>
      if(p->s.size == nunits)
 8c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c5:	8b 40 04             	mov    0x4(%eax),%eax
 8c8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8cb:	75 0c                	jne    8d9 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 8cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d0:	8b 10                	mov    (%eax),%edx
 8d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8d5:	89 10                	mov    %edx,(%eax)
 8d7:	eb 26                	jmp    8ff <malloc+0x96>
      else {
        p->s.size -= nunits;
 8d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8dc:	8b 40 04             	mov    0x4(%eax),%eax
 8df:	2b 45 ec             	sub    -0x14(%ebp),%eax
 8e2:	89 c2                	mov    %eax,%edx
 8e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e7:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 8ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ed:	8b 40 04             	mov    0x4(%eax),%eax
 8f0:	c1 e0 03             	shl    $0x3,%eax
 8f3:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 8f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f9:	8b 55 ec             	mov    -0x14(%ebp),%edx
 8fc:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 8ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
 902:	a3 20 0c 00 00       	mov    %eax,0xc20
      return (void*)(p + 1);
 907:	8b 45 f4             	mov    -0xc(%ebp),%eax
 90a:	83 c0 08             	add    $0x8,%eax
 90d:	eb 3b                	jmp    94a <malloc+0xe1>
    }
    if(p == freep)
 90f:	a1 20 0c 00 00       	mov    0xc20,%eax
 914:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 917:	75 1e                	jne    937 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 919:	83 ec 0c             	sub    $0xc,%esp
 91c:	ff 75 ec             	pushl  -0x14(%ebp)
 91f:	e8 e5 fe ff ff       	call   809 <morecore>
 924:	83 c4 10             	add    $0x10,%esp
 927:	89 45 f4             	mov    %eax,-0xc(%ebp)
 92a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 92e:	75 07                	jne    937 <malloc+0xce>
        return 0;
 930:	b8 00 00 00 00       	mov    $0x0,%eax
 935:	eb 13                	jmp    94a <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 937:	8b 45 f4             	mov    -0xc(%ebp),%eax
 93a:	89 45 f0             	mov    %eax,-0x10(%ebp)
 93d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 940:	8b 00                	mov    (%eax),%eax
 942:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 945:	e9 6d ff ff ff       	jmp    8b7 <malloc+0x4e>
}
 94a:	c9                   	leave  
 94b:	c3                   	ret    
