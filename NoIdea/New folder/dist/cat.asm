
_cat:     file format elf32-i386


Disassembly of section .text:

00000000 <cat>:

char buf[512];

void
cat(int fd)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 18             	sub    $0x18,%esp
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0)
   6:	eb 15                	jmp    1d <cat+0x1d>
    write(1, buf, n);
   8:	83 ec 04             	sub    $0x4,%esp
   b:	ff 75 f4             	pushl  -0xc(%ebp)
   e:	68 c0 0c 00 00       	push   $0xcc0
  13:	6a 01                	push   $0x1
  15:	e8 3f 04 00 00       	call   459 <write>
  1a:	83 c4 10             	add    $0x10,%esp
void
cat(int fd)
{
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0)
  1d:	83 ec 04             	sub    $0x4,%esp
  20:	68 00 02 00 00       	push   $0x200
  25:	68 c0 0c 00 00       	push   $0xcc0
  2a:	ff 75 08             	pushl  0x8(%ebp)
  2d:	e8 1f 04 00 00       	call   451 <read>
  32:	83 c4 10             	add    $0x10,%esp
  35:	89 45 f4             	mov    %eax,-0xc(%ebp)
  38:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  3c:	7f ca                	jg     8 <cat+0x8>
    write(1, buf, n);
  if(n < 0){
  3e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  42:	79 17                	jns    5b <cat+0x5b>
    printf(1, "cat: read error\n");
  44:	83 ec 08             	sub    $0x8,%esp
  47:	68 c6 09 00 00       	push   $0x9c6
  4c:	6a 01                	push   $0x1
  4e:	e8 bd 05 00 00       	call   610 <printf>
  53:	83 c4 10             	add    $0x10,%esp
    exit();
  56:	e8 de 03 00 00       	call   439 <exit>
  }
}
  5b:	90                   	nop
  5c:	c9                   	leave  
  5d:	c3                   	ret    

0000005e <main>:

int
main(int argc, char *argv[])
{
  5e:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  62:	83 e4 f0             	and    $0xfffffff0,%esp
  65:	ff 71 fc             	pushl  -0x4(%ecx)
  68:	55                   	push   %ebp
  69:	89 e5                	mov    %esp,%ebp
  6b:	53                   	push   %ebx
  6c:	51                   	push   %ecx
  6d:	83 ec 10             	sub    $0x10,%esp
  70:	89 cb                	mov    %ecx,%ebx
  int fd, i;

  if(argc <= 1){
  72:	83 3b 01             	cmpl   $0x1,(%ebx)
  75:	7f 12                	jg     89 <main+0x2b>
    cat(0);
  77:	83 ec 0c             	sub    $0xc,%esp
  7a:	6a 00                	push   $0x0
  7c:	e8 7f ff ff ff       	call   0 <cat>
  81:	83 c4 10             	add    $0x10,%esp
    exit();
  84:	e8 b0 03 00 00       	call   439 <exit>
  }

  for(i = 1; i < argc; i++){
  89:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  90:	eb 71                	jmp    103 <main+0xa5>
    if((fd = open(argv[i], 0)) < 0){
  92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  95:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  9c:	8b 43 04             	mov    0x4(%ebx),%eax
  9f:	01 d0                	add    %edx,%eax
  a1:	8b 00                	mov    (%eax),%eax
  a3:	83 ec 08             	sub    $0x8,%esp
  a6:	6a 00                	push   $0x0
  a8:	50                   	push   %eax
  a9:	e8 cb 03 00 00       	call   479 <open>
  ae:	83 c4 10             	add    $0x10,%esp
  b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  b4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  b8:	79 29                	jns    e3 <main+0x85>
      printf(1, "cat: cannot open %s\n", argv[i]);
  ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  bd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  c4:	8b 43 04             	mov    0x4(%ebx),%eax
  c7:	01 d0                	add    %edx,%eax
  c9:	8b 00                	mov    (%eax),%eax
  cb:	83 ec 04             	sub    $0x4,%esp
  ce:	50                   	push   %eax
  cf:	68 d7 09 00 00       	push   $0x9d7
  d4:	6a 01                	push   $0x1
  d6:	e8 35 05 00 00       	call   610 <printf>
  db:	83 c4 10             	add    $0x10,%esp
      exit();
  de:	e8 56 03 00 00       	call   439 <exit>
    }
    cat(fd);
  e3:	83 ec 0c             	sub    $0xc,%esp
  e6:	ff 75 f0             	pushl  -0x10(%ebp)
  e9:	e8 12 ff ff ff       	call   0 <cat>
  ee:	83 c4 10             	add    $0x10,%esp
    close(fd);
  f1:	83 ec 0c             	sub    $0xc,%esp
  f4:	ff 75 f0             	pushl  -0x10(%ebp)
  f7:	e8 65 03 00 00       	call   461 <close>
  fc:	83 c4 10             	add    $0x10,%esp
  if(argc <= 1){
    cat(0);
    exit();
  }

  for(i = 1; i < argc; i++){
  ff:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 103:	8b 45 f4             	mov    -0xc(%ebp),%eax
 106:	3b 03                	cmp    (%ebx),%eax
 108:	7c 88                	jl     92 <main+0x34>
      exit();
    }
    cat(fd);
    close(fd);
  }
  exit();
 10a:	e8 2a 03 00 00       	call   439 <exit>

0000010f <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 10f:	55                   	push   %ebp
 110:	89 e5                	mov    %esp,%ebp
 112:	57                   	push   %edi
 113:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 114:	8b 4d 08             	mov    0x8(%ebp),%ecx
 117:	8b 55 10             	mov    0x10(%ebp),%edx
 11a:	8b 45 0c             	mov    0xc(%ebp),%eax
 11d:	89 cb                	mov    %ecx,%ebx
 11f:	89 df                	mov    %ebx,%edi
 121:	89 d1                	mov    %edx,%ecx
 123:	fc                   	cld    
 124:	f3 aa                	rep stos %al,%es:(%edi)
 126:	89 ca                	mov    %ecx,%edx
 128:	89 fb                	mov    %edi,%ebx
 12a:	89 5d 08             	mov    %ebx,0x8(%ebp)
 12d:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 130:	90                   	nop
 131:	5b                   	pop    %ebx
 132:	5f                   	pop    %edi
 133:	5d                   	pop    %ebp
 134:	c3                   	ret    

00000135 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 135:	55                   	push   %ebp
 136:	89 e5                	mov    %esp,%ebp
 138:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 13b:	8b 45 08             	mov    0x8(%ebp),%eax
 13e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 141:	90                   	nop
 142:	8b 45 08             	mov    0x8(%ebp),%eax
 145:	8d 50 01             	lea    0x1(%eax),%edx
 148:	89 55 08             	mov    %edx,0x8(%ebp)
 14b:	8b 55 0c             	mov    0xc(%ebp),%edx
 14e:	8d 4a 01             	lea    0x1(%edx),%ecx
 151:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 154:	0f b6 12             	movzbl (%edx),%edx
 157:	88 10                	mov    %dl,(%eax)
 159:	0f b6 00             	movzbl (%eax),%eax
 15c:	84 c0                	test   %al,%al
 15e:	75 e2                	jne    142 <strcpy+0xd>
    ;
  return os;
 160:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 163:	c9                   	leave  
 164:	c3                   	ret    

00000165 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 165:	55                   	push   %ebp
 166:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 168:	eb 08                	jmp    172 <strcmp+0xd>
    p++, q++;
 16a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 16e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 172:	8b 45 08             	mov    0x8(%ebp),%eax
 175:	0f b6 00             	movzbl (%eax),%eax
 178:	84 c0                	test   %al,%al
 17a:	74 10                	je     18c <strcmp+0x27>
 17c:	8b 45 08             	mov    0x8(%ebp),%eax
 17f:	0f b6 10             	movzbl (%eax),%edx
 182:	8b 45 0c             	mov    0xc(%ebp),%eax
 185:	0f b6 00             	movzbl (%eax),%eax
 188:	38 c2                	cmp    %al,%dl
 18a:	74 de                	je     16a <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 18c:	8b 45 08             	mov    0x8(%ebp),%eax
 18f:	0f b6 00             	movzbl (%eax),%eax
 192:	0f b6 d0             	movzbl %al,%edx
 195:	8b 45 0c             	mov    0xc(%ebp),%eax
 198:	0f b6 00             	movzbl (%eax),%eax
 19b:	0f b6 c0             	movzbl %al,%eax
 19e:	29 c2                	sub    %eax,%edx
 1a0:	89 d0                	mov    %edx,%eax
}
 1a2:	5d                   	pop    %ebp
 1a3:	c3                   	ret    

000001a4 <strlen>:

uint
strlen(char *s)
{
 1a4:	55                   	push   %ebp
 1a5:	89 e5                	mov    %esp,%ebp
 1a7:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1aa:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1b1:	eb 04                	jmp    1b7 <strlen+0x13>
 1b3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1b7:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1ba:	8b 45 08             	mov    0x8(%ebp),%eax
 1bd:	01 d0                	add    %edx,%eax
 1bf:	0f b6 00             	movzbl (%eax),%eax
 1c2:	84 c0                	test   %al,%al
 1c4:	75 ed                	jne    1b3 <strlen+0xf>
    ;
  return n;
 1c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1c9:	c9                   	leave  
 1ca:	c3                   	ret    

000001cb <memset>:

void*
memset(void *dst, int c, uint n)
{
 1cb:	55                   	push   %ebp
 1cc:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 1ce:	8b 45 10             	mov    0x10(%ebp),%eax
 1d1:	50                   	push   %eax
 1d2:	ff 75 0c             	pushl  0xc(%ebp)
 1d5:	ff 75 08             	pushl  0x8(%ebp)
 1d8:	e8 32 ff ff ff       	call   10f <stosb>
 1dd:	83 c4 0c             	add    $0xc,%esp
  return dst;
 1e0:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1e3:	c9                   	leave  
 1e4:	c3                   	ret    

000001e5 <strchr>:

char*
strchr(const char *s, char c)
{
 1e5:	55                   	push   %ebp
 1e6:	89 e5                	mov    %esp,%ebp
 1e8:	83 ec 04             	sub    $0x4,%esp
 1eb:	8b 45 0c             	mov    0xc(%ebp),%eax
 1ee:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1f1:	eb 14                	jmp    207 <strchr+0x22>
    if(*s == c)
 1f3:	8b 45 08             	mov    0x8(%ebp),%eax
 1f6:	0f b6 00             	movzbl (%eax),%eax
 1f9:	3a 45 fc             	cmp    -0x4(%ebp),%al
 1fc:	75 05                	jne    203 <strchr+0x1e>
      return (char*)s;
 1fe:	8b 45 08             	mov    0x8(%ebp),%eax
 201:	eb 13                	jmp    216 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 203:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 207:	8b 45 08             	mov    0x8(%ebp),%eax
 20a:	0f b6 00             	movzbl (%eax),%eax
 20d:	84 c0                	test   %al,%al
 20f:	75 e2                	jne    1f3 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 211:	b8 00 00 00 00       	mov    $0x0,%eax
}
 216:	c9                   	leave  
 217:	c3                   	ret    

00000218 <gets>:

char*
gets(char *buf, int max)
{
 218:	55                   	push   %ebp
 219:	89 e5                	mov    %esp,%ebp
 21b:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 21e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 225:	eb 42                	jmp    269 <gets+0x51>
    cc = read(0, &c, 1);
 227:	83 ec 04             	sub    $0x4,%esp
 22a:	6a 01                	push   $0x1
 22c:	8d 45 ef             	lea    -0x11(%ebp),%eax
 22f:	50                   	push   %eax
 230:	6a 00                	push   $0x0
 232:	e8 1a 02 00 00       	call   451 <read>
 237:	83 c4 10             	add    $0x10,%esp
 23a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 23d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 241:	7e 33                	jle    276 <gets+0x5e>
      break;
    buf[i++] = c;
 243:	8b 45 f4             	mov    -0xc(%ebp),%eax
 246:	8d 50 01             	lea    0x1(%eax),%edx
 249:	89 55 f4             	mov    %edx,-0xc(%ebp)
 24c:	89 c2                	mov    %eax,%edx
 24e:	8b 45 08             	mov    0x8(%ebp),%eax
 251:	01 c2                	add    %eax,%edx
 253:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 257:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 259:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 25d:	3c 0a                	cmp    $0xa,%al
 25f:	74 16                	je     277 <gets+0x5f>
 261:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 265:	3c 0d                	cmp    $0xd,%al
 267:	74 0e                	je     277 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 269:	8b 45 f4             	mov    -0xc(%ebp),%eax
 26c:	83 c0 01             	add    $0x1,%eax
 26f:	3b 45 0c             	cmp    0xc(%ebp),%eax
 272:	7c b3                	jl     227 <gets+0xf>
 274:	eb 01                	jmp    277 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 276:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 277:	8b 55 f4             	mov    -0xc(%ebp),%edx
 27a:	8b 45 08             	mov    0x8(%ebp),%eax
 27d:	01 d0                	add    %edx,%eax
 27f:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 282:	8b 45 08             	mov    0x8(%ebp),%eax
}
 285:	c9                   	leave  
 286:	c3                   	ret    

00000287 <stat>:

int
stat(char *n, struct stat *st)
{
 287:	55                   	push   %ebp
 288:	89 e5                	mov    %esp,%ebp
 28a:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 28d:	83 ec 08             	sub    $0x8,%esp
 290:	6a 00                	push   $0x0
 292:	ff 75 08             	pushl  0x8(%ebp)
 295:	e8 df 01 00 00       	call   479 <open>
 29a:	83 c4 10             	add    $0x10,%esp
 29d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2a0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2a4:	79 07                	jns    2ad <stat+0x26>
    return -1;
 2a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2ab:	eb 25                	jmp    2d2 <stat+0x4b>
  r = fstat(fd, st);
 2ad:	83 ec 08             	sub    $0x8,%esp
 2b0:	ff 75 0c             	pushl  0xc(%ebp)
 2b3:	ff 75 f4             	pushl  -0xc(%ebp)
 2b6:	e8 d6 01 00 00       	call   491 <fstat>
 2bb:	83 c4 10             	add    $0x10,%esp
 2be:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2c1:	83 ec 0c             	sub    $0xc,%esp
 2c4:	ff 75 f4             	pushl  -0xc(%ebp)
 2c7:	e8 95 01 00 00       	call   461 <close>
 2cc:	83 c4 10             	add    $0x10,%esp
  return r;
 2cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2d2:	c9                   	leave  
 2d3:	c3                   	ret    

000002d4 <atoi>:

int
atoi(const char *s)
{
 2d4:	55                   	push   %ebp
 2d5:	89 e5                	mov    %esp,%ebp
 2d7:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 2da:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 2e1:	eb 04                	jmp    2e7 <atoi+0x13>
 2e3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2e7:	8b 45 08             	mov    0x8(%ebp),%eax
 2ea:	0f b6 00             	movzbl (%eax),%eax
 2ed:	3c 20                	cmp    $0x20,%al
 2ef:	74 f2                	je     2e3 <atoi+0xf>
  sign = (*s == '-') ? -1 : 1;
 2f1:	8b 45 08             	mov    0x8(%ebp),%eax
 2f4:	0f b6 00             	movzbl (%eax),%eax
 2f7:	3c 2d                	cmp    $0x2d,%al
 2f9:	75 07                	jne    302 <atoi+0x2e>
 2fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 300:	eb 05                	jmp    307 <atoi+0x33>
 302:	b8 01 00 00 00       	mov    $0x1,%eax
 307:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 30a:	8b 45 08             	mov    0x8(%ebp),%eax
 30d:	0f b6 00             	movzbl (%eax),%eax
 310:	3c 2b                	cmp    $0x2b,%al
 312:	74 0a                	je     31e <atoi+0x4a>
 314:	8b 45 08             	mov    0x8(%ebp),%eax
 317:	0f b6 00             	movzbl (%eax),%eax
 31a:	3c 2d                	cmp    $0x2d,%al
 31c:	75 2b                	jne    349 <atoi+0x75>
    s++;
 31e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '9')
 322:	eb 25                	jmp    349 <atoi+0x75>
    n = n*10 + *s++ - '0';
 324:	8b 55 fc             	mov    -0x4(%ebp),%edx
 327:	89 d0                	mov    %edx,%eax
 329:	c1 e0 02             	shl    $0x2,%eax
 32c:	01 d0                	add    %edx,%eax
 32e:	01 c0                	add    %eax,%eax
 330:	89 c1                	mov    %eax,%ecx
 332:	8b 45 08             	mov    0x8(%ebp),%eax
 335:	8d 50 01             	lea    0x1(%eax),%edx
 338:	89 55 08             	mov    %edx,0x8(%ebp)
 33b:	0f b6 00             	movzbl (%eax),%eax
 33e:	0f be c0             	movsbl %al,%eax
 341:	01 c8                	add    %ecx,%eax
 343:	83 e8 30             	sub    $0x30,%eax
 346:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '9')
 349:	8b 45 08             	mov    0x8(%ebp),%eax
 34c:	0f b6 00             	movzbl (%eax),%eax
 34f:	3c 2f                	cmp    $0x2f,%al
 351:	7e 0a                	jle    35d <atoi+0x89>
 353:	8b 45 08             	mov    0x8(%ebp),%eax
 356:	0f b6 00             	movzbl (%eax),%eax
 359:	3c 39                	cmp    $0x39,%al
 35b:	7e c7                	jle    324 <atoi+0x50>
    n = n*10 + *s++ - '0';
  return sign*n;
 35d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 360:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 364:	c9                   	leave  
 365:	c3                   	ret    

00000366 <atoo>:

int
atoo(const char *s)
{
 366:	55                   	push   %ebp
 367:	89 e5                	mov    %esp,%ebp
 369:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 36c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 373:	eb 04                	jmp    379 <atoo+0x13>
 375:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 379:	8b 45 08             	mov    0x8(%ebp),%eax
 37c:	0f b6 00             	movzbl (%eax),%eax
 37f:	3c 20                	cmp    $0x20,%al
 381:	74 f2                	je     375 <atoo+0xf>
  sign = (*s == '-') ? -1 : 1;
 383:	8b 45 08             	mov    0x8(%ebp),%eax
 386:	0f b6 00             	movzbl (%eax),%eax
 389:	3c 2d                	cmp    $0x2d,%al
 38b:	75 07                	jne    394 <atoo+0x2e>
 38d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 392:	eb 05                	jmp    399 <atoo+0x33>
 394:	b8 01 00 00 00       	mov    $0x1,%eax
 399:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 39c:	8b 45 08             	mov    0x8(%ebp),%eax
 39f:	0f b6 00             	movzbl (%eax),%eax
 3a2:	3c 2b                	cmp    $0x2b,%al
 3a4:	74 0a                	je     3b0 <atoo+0x4a>
 3a6:	8b 45 08             	mov    0x8(%ebp),%eax
 3a9:	0f b6 00             	movzbl (%eax),%eax
 3ac:	3c 2d                	cmp    $0x2d,%al
 3ae:	75 27                	jne    3d7 <atoo+0x71>
    s++;
 3b0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '7')
 3b4:	eb 21                	jmp    3d7 <atoo+0x71>
    n = n*8 + *s++ - '0';
 3b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3b9:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
 3c0:	8b 45 08             	mov    0x8(%ebp),%eax
 3c3:	8d 50 01             	lea    0x1(%eax),%edx
 3c6:	89 55 08             	mov    %edx,0x8(%ebp)
 3c9:	0f b6 00             	movzbl (%eax),%eax
 3cc:	0f be c0             	movsbl %al,%eax
 3cf:	01 c8                	add    %ecx,%eax
 3d1:	83 e8 30             	sub    $0x30,%eax
 3d4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '7')
 3d7:	8b 45 08             	mov    0x8(%ebp),%eax
 3da:	0f b6 00             	movzbl (%eax),%eax
 3dd:	3c 2f                	cmp    $0x2f,%al
 3df:	7e 0a                	jle    3eb <atoo+0x85>
 3e1:	8b 45 08             	mov    0x8(%ebp),%eax
 3e4:	0f b6 00             	movzbl (%eax),%eax
 3e7:	3c 37                	cmp    $0x37,%al
 3e9:	7e cb                	jle    3b6 <atoo+0x50>
    n = n*8 + *s++ - '0';
  return sign*n;
 3eb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 3ee:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 3f2:	c9                   	leave  
 3f3:	c3                   	ret    

000003f4 <memmove>:


void*
memmove(void *vdst, void *vsrc, int n)
{
 3f4:	55                   	push   %ebp
 3f5:	89 e5                	mov    %esp,%ebp
 3f7:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 3fa:	8b 45 08             	mov    0x8(%ebp),%eax
 3fd:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 400:	8b 45 0c             	mov    0xc(%ebp),%eax
 403:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 406:	eb 17                	jmp    41f <memmove+0x2b>
    *dst++ = *src++;
 408:	8b 45 fc             	mov    -0x4(%ebp),%eax
 40b:	8d 50 01             	lea    0x1(%eax),%edx
 40e:	89 55 fc             	mov    %edx,-0x4(%ebp)
 411:	8b 55 f8             	mov    -0x8(%ebp),%edx
 414:	8d 4a 01             	lea    0x1(%edx),%ecx
 417:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 41a:	0f b6 12             	movzbl (%edx),%edx
 41d:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 41f:	8b 45 10             	mov    0x10(%ebp),%eax
 422:	8d 50 ff             	lea    -0x1(%eax),%edx
 425:	89 55 10             	mov    %edx,0x10(%ebp)
 428:	85 c0                	test   %eax,%eax
 42a:	7f dc                	jg     408 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 42c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 42f:	c9                   	leave  
 430:	c3                   	ret    

00000431 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 431:	b8 01 00 00 00       	mov    $0x1,%eax
 436:	cd 40                	int    $0x40
 438:	c3                   	ret    

00000439 <exit>:
SYSCALL(exit)
 439:	b8 02 00 00 00       	mov    $0x2,%eax
 43e:	cd 40                	int    $0x40
 440:	c3                   	ret    

00000441 <wait>:
SYSCALL(wait)
 441:	b8 03 00 00 00       	mov    $0x3,%eax
 446:	cd 40                	int    $0x40
 448:	c3                   	ret    

00000449 <pipe>:
SYSCALL(pipe)
 449:	b8 04 00 00 00       	mov    $0x4,%eax
 44e:	cd 40                	int    $0x40
 450:	c3                   	ret    

00000451 <read>:
SYSCALL(read)
 451:	b8 05 00 00 00       	mov    $0x5,%eax
 456:	cd 40                	int    $0x40
 458:	c3                   	ret    

00000459 <write>:
SYSCALL(write)
 459:	b8 10 00 00 00       	mov    $0x10,%eax
 45e:	cd 40                	int    $0x40
 460:	c3                   	ret    

00000461 <close>:
SYSCALL(close)
 461:	b8 15 00 00 00       	mov    $0x15,%eax
 466:	cd 40                	int    $0x40
 468:	c3                   	ret    

00000469 <kill>:
SYSCALL(kill)
 469:	b8 06 00 00 00       	mov    $0x6,%eax
 46e:	cd 40                	int    $0x40
 470:	c3                   	ret    

00000471 <exec>:
SYSCALL(exec)
 471:	b8 07 00 00 00       	mov    $0x7,%eax
 476:	cd 40                	int    $0x40
 478:	c3                   	ret    

00000479 <open>:
SYSCALL(open)
 479:	b8 0f 00 00 00       	mov    $0xf,%eax
 47e:	cd 40                	int    $0x40
 480:	c3                   	ret    

00000481 <mknod>:
SYSCALL(mknod)
 481:	b8 11 00 00 00       	mov    $0x11,%eax
 486:	cd 40                	int    $0x40
 488:	c3                   	ret    

00000489 <unlink>:
SYSCALL(unlink)
 489:	b8 12 00 00 00       	mov    $0x12,%eax
 48e:	cd 40                	int    $0x40
 490:	c3                   	ret    

00000491 <fstat>:
SYSCALL(fstat)
 491:	b8 08 00 00 00       	mov    $0x8,%eax
 496:	cd 40                	int    $0x40
 498:	c3                   	ret    

00000499 <link>:
SYSCALL(link)
 499:	b8 13 00 00 00       	mov    $0x13,%eax
 49e:	cd 40                	int    $0x40
 4a0:	c3                   	ret    

000004a1 <mkdir>:
SYSCALL(mkdir)
 4a1:	b8 14 00 00 00       	mov    $0x14,%eax
 4a6:	cd 40                	int    $0x40
 4a8:	c3                   	ret    

000004a9 <chdir>:
SYSCALL(chdir)
 4a9:	b8 09 00 00 00       	mov    $0x9,%eax
 4ae:	cd 40                	int    $0x40
 4b0:	c3                   	ret    

000004b1 <dup>:
SYSCALL(dup)
 4b1:	b8 0a 00 00 00       	mov    $0xa,%eax
 4b6:	cd 40                	int    $0x40
 4b8:	c3                   	ret    

000004b9 <getpid>:
SYSCALL(getpid)
 4b9:	b8 0b 00 00 00       	mov    $0xb,%eax
 4be:	cd 40                	int    $0x40
 4c0:	c3                   	ret    

000004c1 <sbrk>:
SYSCALL(sbrk)
 4c1:	b8 0c 00 00 00       	mov    $0xc,%eax
 4c6:	cd 40                	int    $0x40
 4c8:	c3                   	ret    

000004c9 <sleep>:
SYSCALL(sleep)
 4c9:	b8 0d 00 00 00       	mov    $0xd,%eax
 4ce:	cd 40                	int    $0x40
 4d0:	c3                   	ret    

000004d1 <uptime>:
SYSCALL(uptime)
 4d1:	b8 0e 00 00 00       	mov    $0xe,%eax
 4d6:	cd 40                	int    $0x40
 4d8:	c3                   	ret    

000004d9 <halt>:
SYSCALL(halt)
 4d9:	b8 16 00 00 00       	mov    $0x16,%eax
 4de:	cd 40                	int    $0x40
 4e0:	c3                   	ret    

000004e1 <date>:
SYSCALL(date)
 4e1:	b8 17 00 00 00       	mov    $0x17,%eax
 4e6:	cd 40                	int    $0x40
 4e8:	c3                   	ret    

000004e9 <getuid>:
SYSCALL(getuid)
 4e9:	b8 18 00 00 00       	mov    $0x18,%eax
 4ee:	cd 40                	int    $0x40
 4f0:	c3                   	ret    

000004f1 <getgid>:
SYSCALL(getgid)
 4f1:	b8 19 00 00 00       	mov    $0x19,%eax
 4f6:	cd 40                	int    $0x40
 4f8:	c3                   	ret    

000004f9 <getppid>:
SYSCALL(getppid)
 4f9:	b8 1a 00 00 00       	mov    $0x1a,%eax
 4fe:	cd 40                	int    $0x40
 500:	c3                   	ret    

00000501 <setuid>:
SYSCALL(setuid)
 501:	b8 1b 00 00 00       	mov    $0x1b,%eax
 506:	cd 40                	int    $0x40
 508:	c3                   	ret    

00000509 <setgid>:
SYSCALL(setgid)
 509:	b8 1c 00 00 00       	mov    $0x1c,%eax
 50e:	cd 40                	int    $0x40
 510:	c3                   	ret    

00000511 <getprocs>:
SYSCALL(getprocs)
 511:	b8 1d 00 00 00       	mov    $0x1d,%eax
 516:	cd 40                	int    $0x40
 518:	c3                   	ret    

00000519 <setpriority>:
SYSCALL(setpriority)
 519:	b8 1e 00 00 00       	mov    $0x1e,%eax
 51e:	cd 40                	int    $0x40
 520:	c3                   	ret    

00000521 <chmod>:
SYSCALL(chmod)
 521:	b8 1f 00 00 00       	mov    $0x1f,%eax
 526:	cd 40                	int    $0x40
 528:	c3                   	ret    

00000529 <chown>:
SYSCALL(chown)
 529:	b8 20 00 00 00       	mov    $0x20,%eax
 52e:	cd 40                	int    $0x40
 530:	c3                   	ret    

00000531 <chgrp>:
SYSCALL(chgrp)
 531:	b8 21 00 00 00       	mov    $0x21,%eax
 536:	cd 40                	int    $0x40
 538:	c3                   	ret    

00000539 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 539:	55                   	push   %ebp
 53a:	89 e5                	mov    %esp,%ebp
 53c:	83 ec 18             	sub    $0x18,%esp
 53f:	8b 45 0c             	mov    0xc(%ebp),%eax
 542:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 545:	83 ec 04             	sub    $0x4,%esp
 548:	6a 01                	push   $0x1
 54a:	8d 45 f4             	lea    -0xc(%ebp),%eax
 54d:	50                   	push   %eax
 54e:	ff 75 08             	pushl  0x8(%ebp)
 551:	e8 03 ff ff ff       	call   459 <write>
 556:	83 c4 10             	add    $0x10,%esp
}
 559:	90                   	nop
 55a:	c9                   	leave  
 55b:	c3                   	ret    

0000055c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 55c:	55                   	push   %ebp
 55d:	89 e5                	mov    %esp,%ebp
 55f:	53                   	push   %ebx
 560:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 563:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 56a:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 56e:	74 17                	je     587 <printint+0x2b>
 570:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 574:	79 11                	jns    587 <printint+0x2b>
    neg = 1;
 576:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 57d:	8b 45 0c             	mov    0xc(%ebp),%eax
 580:	f7 d8                	neg    %eax
 582:	89 45 ec             	mov    %eax,-0x14(%ebp)
 585:	eb 06                	jmp    58d <printint+0x31>
  } else {
    x = xx;
 587:	8b 45 0c             	mov    0xc(%ebp),%eax
 58a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 58d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 594:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 597:	8d 41 01             	lea    0x1(%ecx),%eax
 59a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 59d:	8b 5d 10             	mov    0x10(%ebp),%ebx
 5a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5a3:	ba 00 00 00 00       	mov    $0x0,%edx
 5a8:	f7 f3                	div    %ebx
 5aa:	89 d0                	mov    %edx,%eax
 5ac:	0f b6 80 80 0c 00 00 	movzbl 0xc80(%eax),%eax
 5b3:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 5b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
 5ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5bd:	ba 00 00 00 00       	mov    $0x0,%edx
 5c2:	f7 f3                	div    %ebx
 5c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5c7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5cb:	75 c7                	jne    594 <printint+0x38>
  if(neg)
 5cd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5d1:	74 2d                	je     600 <printint+0xa4>
    buf[i++] = '-';
 5d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5d6:	8d 50 01             	lea    0x1(%eax),%edx
 5d9:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5dc:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 5e1:	eb 1d                	jmp    600 <printint+0xa4>
    putc(fd, buf[i]);
 5e3:	8d 55 dc             	lea    -0x24(%ebp),%edx
 5e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5e9:	01 d0                	add    %edx,%eax
 5eb:	0f b6 00             	movzbl (%eax),%eax
 5ee:	0f be c0             	movsbl %al,%eax
 5f1:	83 ec 08             	sub    $0x8,%esp
 5f4:	50                   	push   %eax
 5f5:	ff 75 08             	pushl  0x8(%ebp)
 5f8:	e8 3c ff ff ff       	call   539 <putc>
 5fd:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 600:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 604:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 608:	79 d9                	jns    5e3 <printint+0x87>
    putc(fd, buf[i]);
}
 60a:	90                   	nop
 60b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 60e:	c9                   	leave  
 60f:	c3                   	ret    

00000610 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 610:	55                   	push   %ebp
 611:	89 e5                	mov    %esp,%ebp
 613:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 616:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 61d:	8d 45 0c             	lea    0xc(%ebp),%eax
 620:	83 c0 04             	add    $0x4,%eax
 623:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 626:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 62d:	e9 59 01 00 00       	jmp    78b <printf+0x17b>
    c = fmt[i] & 0xff;
 632:	8b 55 0c             	mov    0xc(%ebp),%edx
 635:	8b 45 f0             	mov    -0x10(%ebp),%eax
 638:	01 d0                	add    %edx,%eax
 63a:	0f b6 00             	movzbl (%eax),%eax
 63d:	0f be c0             	movsbl %al,%eax
 640:	25 ff 00 00 00       	and    $0xff,%eax
 645:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 648:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 64c:	75 2c                	jne    67a <printf+0x6a>
      if(c == '%'){
 64e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 652:	75 0c                	jne    660 <printf+0x50>
        state = '%';
 654:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 65b:	e9 27 01 00 00       	jmp    787 <printf+0x177>
      } else {
        putc(fd, c);
 660:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 663:	0f be c0             	movsbl %al,%eax
 666:	83 ec 08             	sub    $0x8,%esp
 669:	50                   	push   %eax
 66a:	ff 75 08             	pushl  0x8(%ebp)
 66d:	e8 c7 fe ff ff       	call   539 <putc>
 672:	83 c4 10             	add    $0x10,%esp
 675:	e9 0d 01 00 00       	jmp    787 <printf+0x177>
      }
    } else if(state == '%'){
 67a:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 67e:	0f 85 03 01 00 00    	jne    787 <printf+0x177>
      if(c == 'd'){
 684:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 688:	75 1e                	jne    6a8 <printf+0x98>
        printint(fd, *ap, 10, 1);
 68a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 68d:	8b 00                	mov    (%eax),%eax
 68f:	6a 01                	push   $0x1
 691:	6a 0a                	push   $0xa
 693:	50                   	push   %eax
 694:	ff 75 08             	pushl  0x8(%ebp)
 697:	e8 c0 fe ff ff       	call   55c <printint>
 69c:	83 c4 10             	add    $0x10,%esp
        ap++;
 69f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6a3:	e9 d8 00 00 00       	jmp    780 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 6a8:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6ac:	74 06                	je     6b4 <printf+0xa4>
 6ae:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6b2:	75 1e                	jne    6d2 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 6b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6b7:	8b 00                	mov    (%eax),%eax
 6b9:	6a 00                	push   $0x0
 6bb:	6a 10                	push   $0x10
 6bd:	50                   	push   %eax
 6be:	ff 75 08             	pushl  0x8(%ebp)
 6c1:	e8 96 fe ff ff       	call   55c <printint>
 6c6:	83 c4 10             	add    $0x10,%esp
        ap++;
 6c9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6cd:	e9 ae 00 00 00       	jmp    780 <printf+0x170>
      } else if(c == 's'){
 6d2:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6d6:	75 43                	jne    71b <printf+0x10b>
        s = (char*)*ap;
 6d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6db:	8b 00                	mov    (%eax),%eax
 6dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6e0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6e4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6e8:	75 25                	jne    70f <printf+0xff>
          s = "(null)";
 6ea:	c7 45 f4 ec 09 00 00 	movl   $0x9ec,-0xc(%ebp)
        while(*s != 0){
 6f1:	eb 1c                	jmp    70f <printf+0xff>
          putc(fd, *s);
 6f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6f6:	0f b6 00             	movzbl (%eax),%eax
 6f9:	0f be c0             	movsbl %al,%eax
 6fc:	83 ec 08             	sub    $0x8,%esp
 6ff:	50                   	push   %eax
 700:	ff 75 08             	pushl  0x8(%ebp)
 703:	e8 31 fe ff ff       	call   539 <putc>
 708:	83 c4 10             	add    $0x10,%esp
          s++;
 70b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 70f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 712:	0f b6 00             	movzbl (%eax),%eax
 715:	84 c0                	test   %al,%al
 717:	75 da                	jne    6f3 <printf+0xe3>
 719:	eb 65                	jmp    780 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 71b:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 71f:	75 1d                	jne    73e <printf+0x12e>
        putc(fd, *ap);
 721:	8b 45 e8             	mov    -0x18(%ebp),%eax
 724:	8b 00                	mov    (%eax),%eax
 726:	0f be c0             	movsbl %al,%eax
 729:	83 ec 08             	sub    $0x8,%esp
 72c:	50                   	push   %eax
 72d:	ff 75 08             	pushl  0x8(%ebp)
 730:	e8 04 fe ff ff       	call   539 <putc>
 735:	83 c4 10             	add    $0x10,%esp
        ap++;
 738:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 73c:	eb 42                	jmp    780 <printf+0x170>
      } else if(c == '%'){
 73e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 742:	75 17                	jne    75b <printf+0x14b>
        putc(fd, c);
 744:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 747:	0f be c0             	movsbl %al,%eax
 74a:	83 ec 08             	sub    $0x8,%esp
 74d:	50                   	push   %eax
 74e:	ff 75 08             	pushl  0x8(%ebp)
 751:	e8 e3 fd ff ff       	call   539 <putc>
 756:	83 c4 10             	add    $0x10,%esp
 759:	eb 25                	jmp    780 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 75b:	83 ec 08             	sub    $0x8,%esp
 75e:	6a 25                	push   $0x25
 760:	ff 75 08             	pushl  0x8(%ebp)
 763:	e8 d1 fd ff ff       	call   539 <putc>
 768:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 76b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 76e:	0f be c0             	movsbl %al,%eax
 771:	83 ec 08             	sub    $0x8,%esp
 774:	50                   	push   %eax
 775:	ff 75 08             	pushl  0x8(%ebp)
 778:	e8 bc fd ff ff       	call   539 <putc>
 77d:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 780:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 787:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 78b:	8b 55 0c             	mov    0xc(%ebp),%edx
 78e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 791:	01 d0                	add    %edx,%eax
 793:	0f b6 00             	movzbl (%eax),%eax
 796:	84 c0                	test   %al,%al
 798:	0f 85 94 fe ff ff    	jne    632 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 79e:	90                   	nop
 79f:	c9                   	leave  
 7a0:	c3                   	ret    

000007a1 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7a1:	55                   	push   %ebp
 7a2:	89 e5                	mov    %esp,%ebp
 7a4:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7a7:	8b 45 08             	mov    0x8(%ebp),%eax
 7aa:	83 e8 08             	sub    $0x8,%eax
 7ad:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7b0:	a1 a8 0c 00 00       	mov    0xca8,%eax
 7b5:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7b8:	eb 24                	jmp    7de <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7bd:	8b 00                	mov    (%eax),%eax
 7bf:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7c2:	77 12                	ja     7d6 <free+0x35>
 7c4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7c7:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7ca:	77 24                	ja     7f0 <free+0x4f>
 7cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7cf:	8b 00                	mov    (%eax),%eax
 7d1:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7d4:	77 1a                	ja     7f0 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d9:	8b 00                	mov    (%eax),%eax
 7db:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7de:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7e1:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7e4:	76 d4                	jbe    7ba <free+0x19>
 7e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e9:	8b 00                	mov    (%eax),%eax
 7eb:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7ee:	76 ca                	jbe    7ba <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 7f0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7f3:	8b 40 04             	mov    0x4(%eax),%eax
 7f6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7fd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 800:	01 c2                	add    %eax,%edx
 802:	8b 45 fc             	mov    -0x4(%ebp),%eax
 805:	8b 00                	mov    (%eax),%eax
 807:	39 c2                	cmp    %eax,%edx
 809:	75 24                	jne    82f <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 80b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 80e:	8b 50 04             	mov    0x4(%eax),%edx
 811:	8b 45 fc             	mov    -0x4(%ebp),%eax
 814:	8b 00                	mov    (%eax),%eax
 816:	8b 40 04             	mov    0x4(%eax),%eax
 819:	01 c2                	add    %eax,%edx
 81b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 81e:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 821:	8b 45 fc             	mov    -0x4(%ebp),%eax
 824:	8b 00                	mov    (%eax),%eax
 826:	8b 10                	mov    (%eax),%edx
 828:	8b 45 f8             	mov    -0x8(%ebp),%eax
 82b:	89 10                	mov    %edx,(%eax)
 82d:	eb 0a                	jmp    839 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 82f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 832:	8b 10                	mov    (%eax),%edx
 834:	8b 45 f8             	mov    -0x8(%ebp),%eax
 837:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 839:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83c:	8b 40 04             	mov    0x4(%eax),%eax
 83f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 846:	8b 45 fc             	mov    -0x4(%ebp),%eax
 849:	01 d0                	add    %edx,%eax
 84b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 84e:	75 20                	jne    870 <free+0xcf>
    p->s.size += bp->s.size;
 850:	8b 45 fc             	mov    -0x4(%ebp),%eax
 853:	8b 50 04             	mov    0x4(%eax),%edx
 856:	8b 45 f8             	mov    -0x8(%ebp),%eax
 859:	8b 40 04             	mov    0x4(%eax),%eax
 85c:	01 c2                	add    %eax,%edx
 85e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 861:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 864:	8b 45 f8             	mov    -0x8(%ebp),%eax
 867:	8b 10                	mov    (%eax),%edx
 869:	8b 45 fc             	mov    -0x4(%ebp),%eax
 86c:	89 10                	mov    %edx,(%eax)
 86e:	eb 08                	jmp    878 <free+0xd7>
  } else
    p->s.ptr = bp;
 870:	8b 45 fc             	mov    -0x4(%ebp),%eax
 873:	8b 55 f8             	mov    -0x8(%ebp),%edx
 876:	89 10                	mov    %edx,(%eax)
  freep = p;
 878:	8b 45 fc             	mov    -0x4(%ebp),%eax
 87b:	a3 a8 0c 00 00       	mov    %eax,0xca8
}
 880:	90                   	nop
 881:	c9                   	leave  
 882:	c3                   	ret    

00000883 <morecore>:

static Header*
morecore(uint nu)
{
 883:	55                   	push   %ebp
 884:	89 e5                	mov    %esp,%ebp
 886:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 889:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 890:	77 07                	ja     899 <morecore+0x16>
    nu = 4096;
 892:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 899:	8b 45 08             	mov    0x8(%ebp),%eax
 89c:	c1 e0 03             	shl    $0x3,%eax
 89f:	83 ec 0c             	sub    $0xc,%esp
 8a2:	50                   	push   %eax
 8a3:	e8 19 fc ff ff       	call   4c1 <sbrk>
 8a8:	83 c4 10             	add    $0x10,%esp
 8ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8ae:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8b2:	75 07                	jne    8bb <morecore+0x38>
    return 0;
 8b4:	b8 00 00 00 00       	mov    $0x0,%eax
 8b9:	eb 26                	jmp    8e1 <morecore+0x5e>
  hp = (Header*)p;
 8bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8be:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8c4:	8b 55 08             	mov    0x8(%ebp),%edx
 8c7:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8cd:	83 c0 08             	add    $0x8,%eax
 8d0:	83 ec 0c             	sub    $0xc,%esp
 8d3:	50                   	push   %eax
 8d4:	e8 c8 fe ff ff       	call   7a1 <free>
 8d9:	83 c4 10             	add    $0x10,%esp
  return freep;
 8dc:	a1 a8 0c 00 00       	mov    0xca8,%eax
}
 8e1:	c9                   	leave  
 8e2:	c3                   	ret    

000008e3 <malloc>:

void*
malloc(uint nbytes)
{
 8e3:	55                   	push   %ebp
 8e4:	89 e5                	mov    %esp,%ebp
 8e6:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8e9:	8b 45 08             	mov    0x8(%ebp),%eax
 8ec:	83 c0 07             	add    $0x7,%eax
 8ef:	c1 e8 03             	shr    $0x3,%eax
 8f2:	83 c0 01             	add    $0x1,%eax
 8f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8f8:	a1 a8 0c 00 00       	mov    0xca8,%eax
 8fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 900:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 904:	75 23                	jne    929 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 906:	c7 45 f0 a0 0c 00 00 	movl   $0xca0,-0x10(%ebp)
 90d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 910:	a3 a8 0c 00 00       	mov    %eax,0xca8
 915:	a1 a8 0c 00 00       	mov    0xca8,%eax
 91a:	a3 a0 0c 00 00       	mov    %eax,0xca0
    base.s.size = 0;
 91f:	c7 05 a4 0c 00 00 00 	movl   $0x0,0xca4
 926:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 929:	8b 45 f0             	mov    -0x10(%ebp),%eax
 92c:	8b 00                	mov    (%eax),%eax
 92e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 931:	8b 45 f4             	mov    -0xc(%ebp),%eax
 934:	8b 40 04             	mov    0x4(%eax),%eax
 937:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 93a:	72 4d                	jb     989 <malloc+0xa6>
      if(p->s.size == nunits)
 93c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 93f:	8b 40 04             	mov    0x4(%eax),%eax
 942:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 945:	75 0c                	jne    953 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 947:	8b 45 f4             	mov    -0xc(%ebp),%eax
 94a:	8b 10                	mov    (%eax),%edx
 94c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 94f:	89 10                	mov    %edx,(%eax)
 951:	eb 26                	jmp    979 <malloc+0x96>
      else {
        p->s.size -= nunits;
 953:	8b 45 f4             	mov    -0xc(%ebp),%eax
 956:	8b 40 04             	mov    0x4(%eax),%eax
 959:	2b 45 ec             	sub    -0x14(%ebp),%eax
 95c:	89 c2                	mov    %eax,%edx
 95e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 961:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 964:	8b 45 f4             	mov    -0xc(%ebp),%eax
 967:	8b 40 04             	mov    0x4(%eax),%eax
 96a:	c1 e0 03             	shl    $0x3,%eax
 96d:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 970:	8b 45 f4             	mov    -0xc(%ebp),%eax
 973:	8b 55 ec             	mov    -0x14(%ebp),%edx
 976:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 979:	8b 45 f0             	mov    -0x10(%ebp),%eax
 97c:	a3 a8 0c 00 00       	mov    %eax,0xca8
      return (void*)(p + 1);
 981:	8b 45 f4             	mov    -0xc(%ebp),%eax
 984:	83 c0 08             	add    $0x8,%eax
 987:	eb 3b                	jmp    9c4 <malloc+0xe1>
    }
    if(p == freep)
 989:	a1 a8 0c 00 00       	mov    0xca8,%eax
 98e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 991:	75 1e                	jne    9b1 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 993:	83 ec 0c             	sub    $0xc,%esp
 996:	ff 75 ec             	pushl  -0x14(%ebp)
 999:	e8 e5 fe ff ff       	call   883 <morecore>
 99e:	83 c4 10             	add    $0x10,%esp
 9a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9a4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9a8:	75 07                	jne    9b1 <malloc+0xce>
        return 0;
 9aa:	b8 00 00 00 00       	mov    $0x0,%eax
 9af:	eb 13                	jmp    9c4 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ba:	8b 00                	mov    (%eax),%eax
 9bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 9bf:	e9 6d ff ff ff       	jmp    931 <malloc+0x4e>
}
 9c4:	c9                   	leave  
 9c5:	c3                   	ret    
