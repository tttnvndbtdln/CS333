
_ps:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "user.h"
#include "uproc.h"

int
main(void)
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	57                   	push   %edi
   e:	56                   	push   %esi
   f:	53                   	push   %ebx
  10:	51                   	push   %ecx
  11:	83 ec 38             	sub    $0x38,%esp
  int num = 0;
  14:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  int MAX = 72;
  1b:	c7 45 dc 48 00 00 00 	movl   $0x48,-0x24(%ebp)
  int sec, mili, cpu_sec, cpu_mili;
  struct uproc *table;

  table = (struct uproc*)malloc(sizeof(struct uproc) * MAX);
  22:	8b 45 dc             	mov    -0x24(%ebp),%eax
  25:	6b c0 5c             	imul   $0x5c,%eax,%eax
  28:	83 ec 0c             	sub    $0xc,%esp
  2b:	50                   	push   %eax
  2c:	e8 5b 09 00 00       	call   98c <malloc>
  31:	83 c4 10             	add    $0x10,%esp
  34:	89 45 d8             	mov    %eax,-0x28(%ebp)

  num = getprocs(MAX, table);
  37:	8b 45 dc             	mov    -0x24(%ebp),%eax
  3a:	83 ec 08             	sub    $0x8,%esp
  3d:	ff 75 d8             	pushl  -0x28(%ebp)
  40:	50                   	push   %eax
  41:	e8 94 05 00 00       	call   5da <getprocs>
  46:	83 c4 10             	add    $0x10,%esp
  49:	89 45 e0             	mov    %eax,-0x20(%ebp)

  if (num == -1)
  4c:	83 7d e0 ff          	cmpl   $0xffffffff,-0x20(%ebp)
  50:	75 14                	jne    66 <main+0x66>
    printf(2, "Error. ps Test failed.\n");
  52:	83 ec 08             	sub    $0x8,%esp
  55:	68 70 0a 00 00       	push   $0xa70
  5a:	6a 02                	push   $0x2
  5c:	e8 58 06 00 00       	call   6b9 <printf>
  61:	83 c4 10             	add    $0x10,%esp
  64:	eb 15                	jmp    7b <main+0x7b>
  else
    printf(2, "Number of entries: %d\n\n", num);
  66:	83 ec 04             	sub    $0x4,%esp
  69:	ff 75 e0             	pushl  -0x20(%ebp)
  6c:	68 88 0a 00 00       	push   $0xa88
  71:	6a 02                	push   $0x2
  73:	e8 41 06 00 00       	call   6b9 <printf>
  78:	83 c4 10             	add    $0x10,%esp

  printf(2, "PID\t Name\t UID\t GID\t PPID\t Elapsed\t CPU\t State\t\t Size\n"); 
  7b:	83 ec 08             	sub    $0x8,%esp
  7e:	68 a0 0a 00 00       	push   $0xaa0
  83:	6a 02                	push   $0x2
  85:	e8 2f 06 00 00       	call   6b9 <printf>
  8a:	83 c4 10             	add    $0x10,%esp
  
  for(int i = 0; i<num; i++)
  8d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  94:	e9 20 01 00 00       	jmp    1b9 <main+0x1b9>
  {
    sec = table[i].elapsed_ticks / 1000;
  99:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  9c:	6b d0 5c             	imul   $0x5c,%eax,%edx
  9f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  a2:	01 d0                	add    %edx,%eax
  a4:	8b 40 10             	mov    0x10(%eax),%eax
  a7:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
  ac:	f7 e2                	mul    %edx
  ae:	89 d0                	mov    %edx,%eax
  b0:	c1 e8 06             	shr    $0x6,%eax
  b3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    mili = table[i].elapsed_ticks % 1000;
  b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  b9:	6b d0 5c             	imul   $0x5c,%eax,%edx
  bc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  bf:	01 d0                	add    %edx,%eax
  c1:	8b 48 10             	mov    0x10(%eax),%ecx
  c4:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
  c9:	89 c8                	mov    %ecx,%eax
  cb:	f7 e2                	mul    %edx
  cd:	89 d0                	mov    %edx,%eax
  cf:	c1 e8 06             	shr    $0x6,%eax
  d2:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
  d8:	29 c1                	sub    %eax,%ecx
  da:	89 c8                	mov    %ecx,%eax
  dc:	89 45 d0             	mov    %eax,-0x30(%ebp)

    cpu_sec = table[i].CPU_total_ticks / 1000;
  df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  e2:	6b d0 5c             	imul   $0x5c,%eax,%edx
  e5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  e8:	01 d0                	add    %edx,%eax
  ea:	8b 40 14             	mov    0x14(%eax),%eax
  ed:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
  f2:	f7 e2                	mul    %edx
  f4:	89 d0                	mov    %edx,%eax
  f6:	c1 e8 06             	shr    $0x6,%eax
  f9:	89 45 cc             	mov    %eax,-0x34(%ebp)
    cpu_mili = table[i].CPU_total_ticks % 1000;
  fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  ff:	6b d0 5c             	imul   $0x5c,%eax,%edx
 102:	8b 45 d8             	mov    -0x28(%ebp),%eax
 105:	01 d0                	add    %edx,%eax
 107:	8b 48 14             	mov    0x14(%eax),%ecx
 10a:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
 10f:	89 c8                	mov    %ecx,%eax
 111:	f7 e2                	mul    %edx
 113:	89 d0                	mov    %edx,%eax
 115:	c1 e8 06             	shr    $0x6,%eax
 118:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
 11e:	29 c1                	sub    %eax,%ecx
 120:	89 c8                	mov    %ecx,%eax
 122:	89 45 c8             	mov    %eax,-0x38(%ebp)

    printf(2, "%d\t %s\t %d\t %d\t %d\t %d.%d\t\t %d.%d\t %s\t  %d\n", table[i].pid, table[i].name, table[i].uid, table[i].gid, table[i].ppid, sec, mili, cpu_sec, cpu_mili, table[i].state, table[i].size);
 125:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 128:	6b d0 5c             	imul   $0x5c,%eax,%edx
 12b:	8b 45 d8             	mov    -0x28(%ebp),%eax
 12e:	01 d0                	add    %edx,%eax
 130:	8b 40 38             	mov    0x38(%eax),%eax
 133:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 136:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 139:	6b d0 5c             	imul   $0x5c,%eax,%edx
 13c:	8b 45 d8             	mov    -0x28(%ebp),%eax
 13f:	01 d0                	add    %edx,%eax
 141:	8d 58 18             	lea    0x18(%eax),%ebx
 144:	89 5d c0             	mov    %ebx,-0x40(%ebp)
 147:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 14a:	6b d0 5c             	imul   $0x5c,%eax,%edx
 14d:	8b 45 d8             	mov    -0x28(%ebp),%eax
 150:	01 d0                	add    %edx,%eax
 152:	8b 78 0c             	mov    0xc(%eax),%edi
 155:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 158:	6b d0 5c             	imul   $0x5c,%eax,%edx
 15b:	8b 45 d8             	mov    -0x28(%ebp),%eax
 15e:	01 d0                	add    %edx,%eax
 160:	8b 70 08             	mov    0x8(%eax),%esi
 163:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 166:	6b d0 5c             	imul   $0x5c,%eax,%edx
 169:	8b 45 d8             	mov    -0x28(%ebp),%eax
 16c:	01 d0                	add    %edx,%eax
 16e:	8b 58 04             	mov    0x4(%eax),%ebx
 171:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 174:	6b d0 5c             	imul   $0x5c,%eax,%edx
 177:	8b 45 d8             	mov    -0x28(%ebp),%eax
 17a:	01 d0                	add    %edx,%eax
 17c:	8d 48 3c             	lea    0x3c(%eax),%ecx
 17f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 182:	6b d0 5c             	imul   $0x5c,%eax,%edx
 185:	8b 45 d8             	mov    -0x28(%ebp),%eax
 188:	01 d0                	add    %edx,%eax
 18a:	8b 00                	mov    (%eax),%eax
 18c:	83 ec 0c             	sub    $0xc,%esp
 18f:	ff 75 c4             	pushl  -0x3c(%ebp)
 192:	ff 75 c0             	pushl  -0x40(%ebp)
 195:	ff 75 c8             	pushl  -0x38(%ebp)
 198:	ff 75 cc             	pushl  -0x34(%ebp)
 19b:	ff 75 d0             	pushl  -0x30(%ebp)
 19e:	ff 75 d4             	pushl  -0x2c(%ebp)
 1a1:	57                   	push   %edi
 1a2:	56                   	push   %esi
 1a3:	53                   	push   %ebx
 1a4:	51                   	push   %ecx
 1a5:	50                   	push   %eax
 1a6:	68 d8 0a 00 00       	push   $0xad8
 1ab:	6a 02                	push   $0x2
 1ad:	e8 07 05 00 00       	call   6b9 <printf>
 1b2:	83 c4 40             	add    $0x40,%esp
  else
    printf(2, "Number of entries: %d\n\n", num);

  printf(2, "PID\t Name\t UID\t GID\t PPID\t Elapsed\t CPU\t State\t\t Size\n"); 
  
  for(int i = 0; i<num; i++)
 1b5:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
 1b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 1bc:	3b 45 e0             	cmp    -0x20(%ebp),%eax
 1bf:	0f 8c d4 fe ff ff    	jl     99 <main+0x99>
    cpu_mili = table[i].CPU_total_ticks % 1000;

    printf(2, "%d\t %s\t %d\t %d\t %d\t %d.%d\t\t %d.%d\t %s\t  %d\n", table[i].pid, table[i].name, table[i].uid, table[i].gid, table[i].ppid, sec, mili, cpu_sec, cpu_mili, table[i].state, table[i].size);
  }

  free(table);
 1c5:	83 ec 0c             	sub    $0xc,%esp
 1c8:	ff 75 d8             	pushl  -0x28(%ebp)
 1cb:	e8 7a 06 00 00       	call   84a <free>
 1d0:	83 c4 10             	add    $0x10,%esp
  
  exit();
 1d3:	e8 2a 03 00 00       	call   502 <exit>

000001d8 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 1d8:	55                   	push   %ebp
 1d9:	89 e5                	mov    %esp,%ebp
 1db:	57                   	push   %edi
 1dc:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 1dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1e0:	8b 55 10             	mov    0x10(%ebp),%edx
 1e3:	8b 45 0c             	mov    0xc(%ebp),%eax
 1e6:	89 cb                	mov    %ecx,%ebx
 1e8:	89 df                	mov    %ebx,%edi
 1ea:	89 d1                	mov    %edx,%ecx
 1ec:	fc                   	cld    
 1ed:	f3 aa                	rep stos %al,%es:(%edi)
 1ef:	89 ca                	mov    %ecx,%edx
 1f1:	89 fb                	mov    %edi,%ebx
 1f3:	89 5d 08             	mov    %ebx,0x8(%ebp)
 1f6:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 1f9:	90                   	nop
 1fa:	5b                   	pop    %ebx
 1fb:	5f                   	pop    %edi
 1fc:	5d                   	pop    %ebp
 1fd:	c3                   	ret    

000001fe <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 1fe:	55                   	push   %ebp
 1ff:	89 e5                	mov    %esp,%ebp
 201:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 204:	8b 45 08             	mov    0x8(%ebp),%eax
 207:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 20a:	90                   	nop
 20b:	8b 45 08             	mov    0x8(%ebp),%eax
 20e:	8d 50 01             	lea    0x1(%eax),%edx
 211:	89 55 08             	mov    %edx,0x8(%ebp)
 214:	8b 55 0c             	mov    0xc(%ebp),%edx
 217:	8d 4a 01             	lea    0x1(%edx),%ecx
 21a:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 21d:	0f b6 12             	movzbl (%edx),%edx
 220:	88 10                	mov    %dl,(%eax)
 222:	0f b6 00             	movzbl (%eax),%eax
 225:	84 c0                	test   %al,%al
 227:	75 e2                	jne    20b <strcpy+0xd>
    ;
  return os;
 229:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 22c:	c9                   	leave  
 22d:	c3                   	ret    

0000022e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 22e:	55                   	push   %ebp
 22f:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 231:	eb 08                	jmp    23b <strcmp+0xd>
    p++, q++;
 233:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 237:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 23b:	8b 45 08             	mov    0x8(%ebp),%eax
 23e:	0f b6 00             	movzbl (%eax),%eax
 241:	84 c0                	test   %al,%al
 243:	74 10                	je     255 <strcmp+0x27>
 245:	8b 45 08             	mov    0x8(%ebp),%eax
 248:	0f b6 10             	movzbl (%eax),%edx
 24b:	8b 45 0c             	mov    0xc(%ebp),%eax
 24e:	0f b6 00             	movzbl (%eax),%eax
 251:	38 c2                	cmp    %al,%dl
 253:	74 de                	je     233 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 255:	8b 45 08             	mov    0x8(%ebp),%eax
 258:	0f b6 00             	movzbl (%eax),%eax
 25b:	0f b6 d0             	movzbl %al,%edx
 25e:	8b 45 0c             	mov    0xc(%ebp),%eax
 261:	0f b6 00             	movzbl (%eax),%eax
 264:	0f b6 c0             	movzbl %al,%eax
 267:	29 c2                	sub    %eax,%edx
 269:	89 d0                	mov    %edx,%eax
}
 26b:	5d                   	pop    %ebp
 26c:	c3                   	ret    

0000026d <strlen>:

uint
strlen(char *s)
{
 26d:	55                   	push   %ebp
 26e:	89 e5                	mov    %esp,%ebp
 270:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 273:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 27a:	eb 04                	jmp    280 <strlen+0x13>
 27c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 280:	8b 55 fc             	mov    -0x4(%ebp),%edx
 283:	8b 45 08             	mov    0x8(%ebp),%eax
 286:	01 d0                	add    %edx,%eax
 288:	0f b6 00             	movzbl (%eax),%eax
 28b:	84 c0                	test   %al,%al
 28d:	75 ed                	jne    27c <strlen+0xf>
    ;
  return n;
 28f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 292:	c9                   	leave  
 293:	c3                   	ret    

00000294 <memset>:

void*
memset(void *dst, int c, uint n)
{
 294:	55                   	push   %ebp
 295:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 297:	8b 45 10             	mov    0x10(%ebp),%eax
 29a:	50                   	push   %eax
 29b:	ff 75 0c             	pushl  0xc(%ebp)
 29e:	ff 75 08             	pushl  0x8(%ebp)
 2a1:	e8 32 ff ff ff       	call   1d8 <stosb>
 2a6:	83 c4 0c             	add    $0xc,%esp
  return dst;
 2a9:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2ac:	c9                   	leave  
 2ad:	c3                   	ret    

000002ae <strchr>:

char*
strchr(const char *s, char c)
{
 2ae:	55                   	push   %ebp
 2af:	89 e5                	mov    %esp,%ebp
 2b1:	83 ec 04             	sub    $0x4,%esp
 2b4:	8b 45 0c             	mov    0xc(%ebp),%eax
 2b7:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 2ba:	eb 14                	jmp    2d0 <strchr+0x22>
    if(*s == c)
 2bc:	8b 45 08             	mov    0x8(%ebp),%eax
 2bf:	0f b6 00             	movzbl (%eax),%eax
 2c2:	3a 45 fc             	cmp    -0x4(%ebp),%al
 2c5:	75 05                	jne    2cc <strchr+0x1e>
      return (char*)s;
 2c7:	8b 45 08             	mov    0x8(%ebp),%eax
 2ca:	eb 13                	jmp    2df <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 2cc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2d0:	8b 45 08             	mov    0x8(%ebp),%eax
 2d3:	0f b6 00             	movzbl (%eax),%eax
 2d6:	84 c0                	test   %al,%al
 2d8:	75 e2                	jne    2bc <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 2da:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2df:	c9                   	leave  
 2e0:	c3                   	ret    

000002e1 <gets>:

char*
gets(char *buf, int max)
{
 2e1:	55                   	push   %ebp
 2e2:	89 e5                	mov    %esp,%ebp
 2e4:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2e7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2ee:	eb 42                	jmp    332 <gets+0x51>
    cc = read(0, &c, 1);
 2f0:	83 ec 04             	sub    $0x4,%esp
 2f3:	6a 01                	push   $0x1
 2f5:	8d 45 ef             	lea    -0x11(%ebp),%eax
 2f8:	50                   	push   %eax
 2f9:	6a 00                	push   $0x0
 2fb:	e8 1a 02 00 00       	call   51a <read>
 300:	83 c4 10             	add    $0x10,%esp
 303:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 306:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 30a:	7e 33                	jle    33f <gets+0x5e>
      break;
    buf[i++] = c;
 30c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 30f:	8d 50 01             	lea    0x1(%eax),%edx
 312:	89 55 f4             	mov    %edx,-0xc(%ebp)
 315:	89 c2                	mov    %eax,%edx
 317:	8b 45 08             	mov    0x8(%ebp),%eax
 31a:	01 c2                	add    %eax,%edx
 31c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 320:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 322:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 326:	3c 0a                	cmp    $0xa,%al
 328:	74 16                	je     340 <gets+0x5f>
 32a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 32e:	3c 0d                	cmp    $0xd,%al
 330:	74 0e                	je     340 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 332:	8b 45 f4             	mov    -0xc(%ebp),%eax
 335:	83 c0 01             	add    $0x1,%eax
 338:	3b 45 0c             	cmp    0xc(%ebp),%eax
 33b:	7c b3                	jl     2f0 <gets+0xf>
 33d:	eb 01                	jmp    340 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 33f:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 340:	8b 55 f4             	mov    -0xc(%ebp),%edx
 343:	8b 45 08             	mov    0x8(%ebp),%eax
 346:	01 d0                	add    %edx,%eax
 348:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 34b:	8b 45 08             	mov    0x8(%ebp),%eax
}
 34e:	c9                   	leave  
 34f:	c3                   	ret    

00000350 <stat>:

int
stat(char *n, struct stat *st)
{
 350:	55                   	push   %ebp
 351:	89 e5                	mov    %esp,%ebp
 353:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 356:	83 ec 08             	sub    $0x8,%esp
 359:	6a 00                	push   $0x0
 35b:	ff 75 08             	pushl  0x8(%ebp)
 35e:	e8 df 01 00 00       	call   542 <open>
 363:	83 c4 10             	add    $0x10,%esp
 366:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 369:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 36d:	79 07                	jns    376 <stat+0x26>
    return -1;
 36f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 374:	eb 25                	jmp    39b <stat+0x4b>
  r = fstat(fd, st);
 376:	83 ec 08             	sub    $0x8,%esp
 379:	ff 75 0c             	pushl  0xc(%ebp)
 37c:	ff 75 f4             	pushl  -0xc(%ebp)
 37f:	e8 d6 01 00 00       	call   55a <fstat>
 384:	83 c4 10             	add    $0x10,%esp
 387:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 38a:	83 ec 0c             	sub    $0xc,%esp
 38d:	ff 75 f4             	pushl  -0xc(%ebp)
 390:	e8 95 01 00 00       	call   52a <close>
 395:	83 c4 10             	add    $0x10,%esp
  return r;
 398:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 39b:	c9                   	leave  
 39c:	c3                   	ret    

0000039d <atoi>:

int
atoi(const char *s)
{
 39d:	55                   	push   %ebp
 39e:	89 e5                	mov    %esp,%ebp
 3a0:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 3a3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 3aa:	eb 04                	jmp    3b0 <atoi+0x13>
 3ac:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3b0:	8b 45 08             	mov    0x8(%ebp),%eax
 3b3:	0f b6 00             	movzbl (%eax),%eax
 3b6:	3c 20                	cmp    $0x20,%al
 3b8:	74 f2                	je     3ac <atoi+0xf>
  sign = (*s == '-') ? -1 : 1;
 3ba:	8b 45 08             	mov    0x8(%ebp),%eax
 3bd:	0f b6 00             	movzbl (%eax),%eax
 3c0:	3c 2d                	cmp    $0x2d,%al
 3c2:	75 07                	jne    3cb <atoi+0x2e>
 3c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 3c9:	eb 05                	jmp    3d0 <atoi+0x33>
 3cb:	b8 01 00 00 00       	mov    $0x1,%eax
 3d0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 3d3:	8b 45 08             	mov    0x8(%ebp),%eax
 3d6:	0f b6 00             	movzbl (%eax),%eax
 3d9:	3c 2b                	cmp    $0x2b,%al
 3db:	74 0a                	je     3e7 <atoi+0x4a>
 3dd:	8b 45 08             	mov    0x8(%ebp),%eax
 3e0:	0f b6 00             	movzbl (%eax),%eax
 3e3:	3c 2d                	cmp    $0x2d,%al
 3e5:	75 2b                	jne    412 <atoi+0x75>
    s++;
 3e7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '9')
 3eb:	eb 25                	jmp    412 <atoi+0x75>
    n = n*10 + *s++ - '0';
 3ed:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3f0:	89 d0                	mov    %edx,%eax
 3f2:	c1 e0 02             	shl    $0x2,%eax
 3f5:	01 d0                	add    %edx,%eax
 3f7:	01 c0                	add    %eax,%eax
 3f9:	89 c1                	mov    %eax,%ecx
 3fb:	8b 45 08             	mov    0x8(%ebp),%eax
 3fe:	8d 50 01             	lea    0x1(%eax),%edx
 401:	89 55 08             	mov    %edx,0x8(%ebp)
 404:	0f b6 00             	movzbl (%eax),%eax
 407:	0f be c0             	movsbl %al,%eax
 40a:	01 c8                	add    %ecx,%eax
 40c:	83 e8 30             	sub    $0x30,%eax
 40f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '9')
 412:	8b 45 08             	mov    0x8(%ebp),%eax
 415:	0f b6 00             	movzbl (%eax),%eax
 418:	3c 2f                	cmp    $0x2f,%al
 41a:	7e 0a                	jle    426 <atoi+0x89>
 41c:	8b 45 08             	mov    0x8(%ebp),%eax
 41f:	0f b6 00             	movzbl (%eax),%eax
 422:	3c 39                	cmp    $0x39,%al
 424:	7e c7                	jle    3ed <atoi+0x50>
    n = n*10 + *s++ - '0';
  return sign*n;
 426:	8b 45 f8             	mov    -0x8(%ebp),%eax
 429:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 42d:	c9                   	leave  
 42e:	c3                   	ret    

0000042f <atoo>:

int
atoo(const char *s)
{
 42f:	55                   	push   %ebp
 430:	89 e5                	mov    %esp,%ebp
 432:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 435:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 43c:	eb 04                	jmp    442 <atoo+0x13>
 43e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 442:	8b 45 08             	mov    0x8(%ebp),%eax
 445:	0f b6 00             	movzbl (%eax),%eax
 448:	3c 20                	cmp    $0x20,%al
 44a:	74 f2                	je     43e <atoo+0xf>
  sign = (*s == '-') ? -1 : 1;
 44c:	8b 45 08             	mov    0x8(%ebp),%eax
 44f:	0f b6 00             	movzbl (%eax),%eax
 452:	3c 2d                	cmp    $0x2d,%al
 454:	75 07                	jne    45d <atoo+0x2e>
 456:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 45b:	eb 05                	jmp    462 <atoo+0x33>
 45d:	b8 01 00 00 00       	mov    $0x1,%eax
 462:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 465:	8b 45 08             	mov    0x8(%ebp),%eax
 468:	0f b6 00             	movzbl (%eax),%eax
 46b:	3c 2b                	cmp    $0x2b,%al
 46d:	74 0a                	je     479 <atoo+0x4a>
 46f:	8b 45 08             	mov    0x8(%ebp),%eax
 472:	0f b6 00             	movzbl (%eax),%eax
 475:	3c 2d                	cmp    $0x2d,%al
 477:	75 27                	jne    4a0 <atoo+0x71>
    s++;
 479:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '7')
 47d:	eb 21                	jmp    4a0 <atoo+0x71>
    n = n*8 + *s++ - '0';
 47f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 482:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
 489:	8b 45 08             	mov    0x8(%ebp),%eax
 48c:	8d 50 01             	lea    0x1(%eax),%edx
 48f:	89 55 08             	mov    %edx,0x8(%ebp)
 492:	0f b6 00             	movzbl (%eax),%eax
 495:	0f be c0             	movsbl %al,%eax
 498:	01 c8                	add    %ecx,%eax
 49a:	83 e8 30             	sub    $0x30,%eax
 49d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '7')
 4a0:	8b 45 08             	mov    0x8(%ebp),%eax
 4a3:	0f b6 00             	movzbl (%eax),%eax
 4a6:	3c 2f                	cmp    $0x2f,%al
 4a8:	7e 0a                	jle    4b4 <atoo+0x85>
 4aa:	8b 45 08             	mov    0x8(%ebp),%eax
 4ad:	0f b6 00             	movzbl (%eax),%eax
 4b0:	3c 37                	cmp    $0x37,%al
 4b2:	7e cb                	jle    47f <atoo+0x50>
    n = n*8 + *s++ - '0';
  return sign*n;
 4b4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 4b7:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 4bb:	c9                   	leave  
 4bc:	c3                   	ret    

000004bd <memmove>:


void*
memmove(void *vdst, void *vsrc, int n)
{
 4bd:	55                   	push   %ebp
 4be:	89 e5                	mov    %esp,%ebp
 4c0:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 4c3:	8b 45 08             	mov    0x8(%ebp),%eax
 4c6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 4c9:	8b 45 0c             	mov    0xc(%ebp),%eax
 4cc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 4cf:	eb 17                	jmp    4e8 <memmove+0x2b>
    *dst++ = *src++;
 4d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4d4:	8d 50 01             	lea    0x1(%eax),%edx
 4d7:	89 55 fc             	mov    %edx,-0x4(%ebp)
 4da:	8b 55 f8             	mov    -0x8(%ebp),%edx
 4dd:	8d 4a 01             	lea    0x1(%edx),%ecx
 4e0:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 4e3:	0f b6 12             	movzbl (%edx),%edx
 4e6:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 4e8:	8b 45 10             	mov    0x10(%ebp),%eax
 4eb:	8d 50 ff             	lea    -0x1(%eax),%edx
 4ee:	89 55 10             	mov    %edx,0x10(%ebp)
 4f1:	85 c0                	test   %eax,%eax
 4f3:	7f dc                	jg     4d1 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 4f5:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4f8:	c9                   	leave  
 4f9:	c3                   	ret    

000004fa <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 4fa:	b8 01 00 00 00       	mov    $0x1,%eax
 4ff:	cd 40                	int    $0x40
 501:	c3                   	ret    

00000502 <exit>:
SYSCALL(exit)
 502:	b8 02 00 00 00       	mov    $0x2,%eax
 507:	cd 40                	int    $0x40
 509:	c3                   	ret    

0000050a <wait>:
SYSCALL(wait)
 50a:	b8 03 00 00 00       	mov    $0x3,%eax
 50f:	cd 40                	int    $0x40
 511:	c3                   	ret    

00000512 <pipe>:
SYSCALL(pipe)
 512:	b8 04 00 00 00       	mov    $0x4,%eax
 517:	cd 40                	int    $0x40
 519:	c3                   	ret    

0000051a <read>:
SYSCALL(read)
 51a:	b8 05 00 00 00       	mov    $0x5,%eax
 51f:	cd 40                	int    $0x40
 521:	c3                   	ret    

00000522 <write>:
SYSCALL(write)
 522:	b8 10 00 00 00       	mov    $0x10,%eax
 527:	cd 40                	int    $0x40
 529:	c3                   	ret    

0000052a <close>:
SYSCALL(close)
 52a:	b8 15 00 00 00       	mov    $0x15,%eax
 52f:	cd 40                	int    $0x40
 531:	c3                   	ret    

00000532 <kill>:
SYSCALL(kill)
 532:	b8 06 00 00 00       	mov    $0x6,%eax
 537:	cd 40                	int    $0x40
 539:	c3                   	ret    

0000053a <exec>:
SYSCALL(exec)
 53a:	b8 07 00 00 00       	mov    $0x7,%eax
 53f:	cd 40                	int    $0x40
 541:	c3                   	ret    

00000542 <open>:
SYSCALL(open)
 542:	b8 0f 00 00 00       	mov    $0xf,%eax
 547:	cd 40                	int    $0x40
 549:	c3                   	ret    

0000054a <mknod>:
SYSCALL(mknod)
 54a:	b8 11 00 00 00       	mov    $0x11,%eax
 54f:	cd 40                	int    $0x40
 551:	c3                   	ret    

00000552 <unlink>:
SYSCALL(unlink)
 552:	b8 12 00 00 00       	mov    $0x12,%eax
 557:	cd 40                	int    $0x40
 559:	c3                   	ret    

0000055a <fstat>:
SYSCALL(fstat)
 55a:	b8 08 00 00 00       	mov    $0x8,%eax
 55f:	cd 40                	int    $0x40
 561:	c3                   	ret    

00000562 <link>:
SYSCALL(link)
 562:	b8 13 00 00 00       	mov    $0x13,%eax
 567:	cd 40                	int    $0x40
 569:	c3                   	ret    

0000056a <mkdir>:
SYSCALL(mkdir)
 56a:	b8 14 00 00 00       	mov    $0x14,%eax
 56f:	cd 40                	int    $0x40
 571:	c3                   	ret    

00000572 <chdir>:
SYSCALL(chdir)
 572:	b8 09 00 00 00       	mov    $0x9,%eax
 577:	cd 40                	int    $0x40
 579:	c3                   	ret    

0000057a <dup>:
SYSCALL(dup)
 57a:	b8 0a 00 00 00       	mov    $0xa,%eax
 57f:	cd 40                	int    $0x40
 581:	c3                   	ret    

00000582 <getpid>:
SYSCALL(getpid)
 582:	b8 0b 00 00 00       	mov    $0xb,%eax
 587:	cd 40                	int    $0x40
 589:	c3                   	ret    

0000058a <sbrk>:
SYSCALL(sbrk)
 58a:	b8 0c 00 00 00       	mov    $0xc,%eax
 58f:	cd 40                	int    $0x40
 591:	c3                   	ret    

00000592 <sleep>:
SYSCALL(sleep)
 592:	b8 0d 00 00 00       	mov    $0xd,%eax
 597:	cd 40                	int    $0x40
 599:	c3                   	ret    

0000059a <uptime>:
SYSCALL(uptime)
 59a:	b8 0e 00 00 00       	mov    $0xe,%eax
 59f:	cd 40                	int    $0x40
 5a1:	c3                   	ret    

000005a2 <halt>:
SYSCALL(halt)
 5a2:	b8 16 00 00 00       	mov    $0x16,%eax
 5a7:	cd 40                	int    $0x40
 5a9:	c3                   	ret    

000005aa <date>:
SYSCALL(date)
 5aa:	b8 17 00 00 00       	mov    $0x17,%eax
 5af:	cd 40                	int    $0x40
 5b1:	c3                   	ret    

000005b2 <getuid>:
SYSCALL(getuid)
 5b2:	b8 18 00 00 00       	mov    $0x18,%eax
 5b7:	cd 40                	int    $0x40
 5b9:	c3                   	ret    

000005ba <getgid>:
SYSCALL(getgid)
 5ba:	b8 19 00 00 00       	mov    $0x19,%eax
 5bf:	cd 40                	int    $0x40
 5c1:	c3                   	ret    

000005c2 <getppid>:
SYSCALL(getppid)
 5c2:	b8 1a 00 00 00       	mov    $0x1a,%eax
 5c7:	cd 40                	int    $0x40
 5c9:	c3                   	ret    

000005ca <setuid>:
SYSCALL(setuid)
 5ca:	b8 1b 00 00 00       	mov    $0x1b,%eax
 5cf:	cd 40                	int    $0x40
 5d1:	c3                   	ret    

000005d2 <setgid>:
SYSCALL(setgid)
 5d2:	b8 1c 00 00 00       	mov    $0x1c,%eax
 5d7:	cd 40                	int    $0x40
 5d9:	c3                   	ret    

000005da <getprocs>:
SYSCALL(getprocs)
 5da:	b8 1d 00 00 00       	mov    $0x1d,%eax
 5df:	cd 40                	int    $0x40
 5e1:	c3                   	ret    

000005e2 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5e2:	55                   	push   %ebp
 5e3:	89 e5                	mov    %esp,%ebp
 5e5:	83 ec 18             	sub    $0x18,%esp
 5e8:	8b 45 0c             	mov    0xc(%ebp),%eax
 5eb:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 5ee:	83 ec 04             	sub    $0x4,%esp
 5f1:	6a 01                	push   $0x1
 5f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
 5f6:	50                   	push   %eax
 5f7:	ff 75 08             	pushl  0x8(%ebp)
 5fa:	e8 23 ff ff ff       	call   522 <write>
 5ff:	83 c4 10             	add    $0x10,%esp
}
 602:	90                   	nop
 603:	c9                   	leave  
 604:	c3                   	ret    

00000605 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 605:	55                   	push   %ebp
 606:	89 e5                	mov    %esp,%ebp
 608:	53                   	push   %ebx
 609:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 60c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 613:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 617:	74 17                	je     630 <printint+0x2b>
 619:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 61d:	79 11                	jns    630 <printint+0x2b>
    neg = 1;
 61f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 626:	8b 45 0c             	mov    0xc(%ebp),%eax
 629:	f7 d8                	neg    %eax
 62b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 62e:	eb 06                	jmp    636 <printint+0x31>
  } else {
    x = xx;
 630:	8b 45 0c             	mov    0xc(%ebp),%eax
 633:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 636:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 63d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 640:	8d 41 01             	lea    0x1(%ecx),%eax
 643:	89 45 f4             	mov    %eax,-0xc(%ebp)
 646:	8b 5d 10             	mov    0x10(%ebp),%ebx
 649:	8b 45 ec             	mov    -0x14(%ebp),%eax
 64c:	ba 00 00 00 00       	mov    $0x0,%edx
 651:	f7 f3                	div    %ebx
 653:	89 d0                	mov    %edx,%eax
 655:	0f b6 80 80 0d 00 00 	movzbl 0xd80(%eax),%eax
 65c:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 660:	8b 5d 10             	mov    0x10(%ebp),%ebx
 663:	8b 45 ec             	mov    -0x14(%ebp),%eax
 666:	ba 00 00 00 00       	mov    $0x0,%edx
 66b:	f7 f3                	div    %ebx
 66d:	89 45 ec             	mov    %eax,-0x14(%ebp)
 670:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 674:	75 c7                	jne    63d <printint+0x38>
  if(neg)
 676:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 67a:	74 2d                	je     6a9 <printint+0xa4>
    buf[i++] = '-';
 67c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 67f:	8d 50 01             	lea    0x1(%eax),%edx
 682:	89 55 f4             	mov    %edx,-0xc(%ebp)
 685:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 68a:	eb 1d                	jmp    6a9 <printint+0xa4>
    putc(fd, buf[i]);
 68c:	8d 55 dc             	lea    -0x24(%ebp),%edx
 68f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 692:	01 d0                	add    %edx,%eax
 694:	0f b6 00             	movzbl (%eax),%eax
 697:	0f be c0             	movsbl %al,%eax
 69a:	83 ec 08             	sub    $0x8,%esp
 69d:	50                   	push   %eax
 69e:	ff 75 08             	pushl  0x8(%ebp)
 6a1:	e8 3c ff ff ff       	call   5e2 <putc>
 6a6:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 6a9:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 6ad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6b1:	79 d9                	jns    68c <printint+0x87>
    putc(fd, buf[i]);
}
 6b3:	90                   	nop
 6b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 6b7:	c9                   	leave  
 6b8:	c3                   	ret    

000006b9 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 6b9:	55                   	push   %ebp
 6ba:	89 e5                	mov    %esp,%ebp
 6bc:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 6bf:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 6c6:	8d 45 0c             	lea    0xc(%ebp),%eax
 6c9:	83 c0 04             	add    $0x4,%eax
 6cc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6cf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 6d6:	e9 59 01 00 00       	jmp    834 <printf+0x17b>
    c = fmt[i] & 0xff;
 6db:	8b 55 0c             	mov    0xc(%ebp),%edx
 6de:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6e1:	01 d0                	add    %edx,%eax
 6e3:	0f b6 00             	movzbl (%eax),%eax
 6e6:	0f be c0             	movsbl %al,%eax
 6e9:	25 ff 00 00 00       	and    $0xff,%eax
 6ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6f1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6f5:	75 2c                	jne    723 <printf+0x6a>
      if(c == '%'){
 6f7:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6fb:	75 0c                	jne    709 <printf+0x50>
        state = '%';
 6fd:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 704:	e9 27 01 00 00       	jmp    830 <printf+0x177>
      } else {
        putc(fd, c);
 709:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 70c:	0f be c0             	movsbl %al,%eax
 70f:	83 ec 08             	sub    $0x8,%esp
 712:	50                   	push   %eax
 713:	ff 75 08             	pushl  0x8(%ebp)
 716:	e8 c7 fe ff ff       	call   5e2 <putc>
 71b:	83 c4 10             	add    $0x10,%esp
 71e:	e9 0d 01 00 00       	jmp    830 <printf+0x177>
      }
    } else if(state == '%'){
 723:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 727:	0f 85 03 01 00 00    	jne    830 <printf+0x177>
      if(c == 'd'){
 72d:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 731:	75 1e                	jne    751 <printf+0x98>
        printint(fd, *ap, 10, 1);
 733:	8b 45 e8             	mov    -0x18(%ebp),%eax
 736:	8b 00                	mov    (%eax),%eax
 738:	6a 01                	push   $0x1
 73a:	6a 0a                	push   $0xa
 73c:	50                   	push   %eax
 73d:	ff 75 08             	pushl  0x8(%ebp)
 740:	e8 c0 fe ff ff       	call   605 <printint>
 745:	83 c4 10             	add    $0x10,%esp
        ap++;
 748:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 74c:	e9 d8 00 00 00       	jmp    829 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 751:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 755:	74 06                	je     75d <printf+0xa4>
 757:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 75b:	75 1e                	jne    77b <printf+0xc2>
        printint(fd, *ap, 16, 0);
 75d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 760:	8b 00                	mov    (%eax),%eax
 762:	6a 00                	push   $0x0
 764:	6a 10                	push   $0x10
 766:	50                   	push   %eax
 767:	ff 75 08             	pushl  0x8(%ebp)
 76a:	e8 96 fe ff ff       	call   605 <printint>
 76f:	83 c4 10             	add    $0x10,%esp
        ap++;
 772:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 776:	e9 ae 00 00 00       	jmp    829 <printf+0x170>
      } else if(c == 's'){
 77b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 77f:	75 43                	jne    7c4 <printf+0x10b>
        s = (char*)*ap;
 781:	8b 45 e8             	mov    -0x18(%ebp),%eax
 784:	8b 00                	mov    (%eax),%eax
 786:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 789:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 78d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 791:	75 25                	jne    7b8 <printf+0xff>
          s = "(null)";
 793:	c7 45 f4 04 0b 00 00 	movl   $0xb04,-0xc(%ebp)
        while(*s != 0){
 79a:	eb 1c                	jmp    7b8 <printf+0xff>
          putc(fd, *s);
 79c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79f:	0f b6 00             	movzbl (%eax),%eax
 7a2:	0f be c0             	movsbl %al,%eax
 7a5:	83 ec 08             	sub    $0x8,%esp
 7a8:	50                   	push   %eax
 7a9:	ff 75 08             	pushl  0x8(%ebp)
 7ac:	e8 31 fe ff ff       	call   5e2 <putc>
 7b1:	83 c4 10             	add    $0x10,%esp
          s++;
 7b4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 7b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7bb:	0f b6 00             	movzbl (%eax),%eax
 7be:	84 c0                	test   %al,%al
 7c0:	75 da                	jne    79c <printf+0xe3>
 7c2:	eb 65                	jmp    829 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 7c4:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 7c8:	75 1d                	jne    7e7 <printf+0x12e>
        putc(fd, *ap);
 7ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7cd:	8b 00                	mov    (%eax),%eax
 7cf:	0f be c0             	movsbl %al,%eax
 7d2:	83 ec 08             	sub    $0x8,%esp
 7d5:	50                   	push   %eax
 7d6:	ff 75 08             	pushl  0x8(%ebp)
 7d9:	e8 04 fe ff ff       	call   5e2 <putc>
 7de:	83 c4 10             	add    $0x10,%esp
        ap++;
 7e1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7e5:	eb 42                	jmp    829 <printf+0x170>
      } else if(c == '%'){
 7e7:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7eb:	75 17                	jne    804 <printf+0x14b>
        putc(fd, c);
 7ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7f0:	0f be c0             	movsbl %al,%eax
 7f3:	83 ec 08             	sub    $0x8,%esp
 7f6:	50                   	push   %eax
 7f7:	ff 75 08             	pushl  0x8(%ebp)
 7fa:	e8 e3 fd ff ff       	call   5e2 <putc>
 7ff:	83 c4 10             	add    $0x10,%esp
 802:	eb 25                	jmp    829 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 804:	83 ec 08             	sub    $0x8,%esp
 807:	6a 25                	push   $0x25
 809:	ff 75 08             	pushl  0x8(%ebp)
 80c:	e8 d1 fd ff ff       	call   5e2 <putc>
 811:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 814:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 817:	0f be c0             	movsbl %al,%eax
 81a:	83 ec 08             	sub    $0x8,%esp
 81d:	50                   	push   %eax
 81e:	ff 75 08             	pushl  0x8(%ebp)
 821:	e8 bc fd ff ff       	call   5e2 <putc>
 826:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 829:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 830:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 834:	8b 55 0c             	mov    0xc(%ebp),%edx
 837:	8b 45 f0             	mov    -0x10(%ebp),%eax
 83a:	01 d0                	add    %edx,%eax
 83c:	0f b6 00             	movzbl (%eax),%eax
 83f:	84 c0                	test   %al,%al
 841:	0f 85 94 fe ff ff    	jne    6db <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 847:	90                   	nop
 848:	c9                   	leave  
 849:	c3                   	ret    

0000084a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 84a:	55                   	push   %ebp
 84b:	89 e5                	mov    %esp,%ebp
 84d:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 850:	8b 45 08             	mov    0x8(%ebp),%eax
 853:	83 e8 08             	sub    $0x8,%eax
 856:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 859:	a1 9c 0d 00 00       	mov    0xd9c,%eax
 85e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 861:	eb 24                	jmp    887 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 863:	8b 45 fc             	mov    -0x4(%ebp),%eax
 866:	8b 00                	mov    (%eax),%eax
 868:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 86b:	77 12                	ja     87f <free+0x35>
 86d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 870:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 873:	77 24                	ja     899 <free+0x4f>
 875:	8b 45 fc             	mov    -0x4(%ebp),%eax
 878:	8b 00                	mov    (%eax),%eax
 87a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 87d:	77 1a                	ja     899 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 87f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 882:	8b 00                	mov    (%eax),%eax
 884:	89 45 fc             	mov    %eax,-0x4(%ebp)
 887:	8b 45 f8             	mov    -0x8(%ebp),%eax
 88a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 88d:	76 d4                	jbe    863 <free+0x19>
 88f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 892:	8b 00                	mov    (%eax),%eax
 894:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 897:	76 ca                	jbe    863 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 899:	8b 45 f8             	mov    -0x8(%ebp),%eax
 89c:	8b 40 04             	mov    0x4(%eax),%eax
 89f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8a6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a9:	01 c2                	add    %eax,%edx
 8ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ae:	8b 00                	mov    (%eax),%eax
 8b0:	39 c2                	cmp    %eax,%edx
 8b2:	75 24                	jne    8d8 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 8b4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8b7:	8b 50 04             	mov    0x4(%eax),%edx
 8ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8bd:	8b 00                	mov    (%eax),%eax
 8bf:	8b 40 04             	mov    0x4(%eax),%eax
 8c2:	01 c2                	add    %eax,%edx
 8c4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8c7:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 8ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8cd:	8b 00                	mov    (%eax),%eax
 8cf:	8b 10                	mov    (%eax),%edx
 8d1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8d4:	89 10                	mov    %edx,(%eax)
 8d6:	eb 0a                	jmp    8e2 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 8d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8db:	8b 10                	mov    (%eax),%edx
 8dd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8e0:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e5:	8b 40 04             	mov    0x4(%eax),%eax
 8e8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f2:	01 d0                	add    %edx,%eax
 8f4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8f7:	75 20                	jne    919 <free+0xcf>
    p->s.size += bp->s.size;
 8f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8fc:	8b 50 04             	mov    0x4(%eax),%edx
 8ff:	8b 45 f8             	mov    -0x8(%ebp),%eax
 902:	8b 40 04             	mov    0x4(%eax),%eax
 905:	01 c2                	add    %eax,%edx
 907:	8b 45 fc             	mov    -0x4(%ebp),%eax
 90a:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 90d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 910:	8b 10                	mov    (%eax),%edx
 912:	8b 45 fc             	mov    -0x4(%ebp),%eax
 915:	89 10                	mov    %edx,(%eax)
 917:	eb 08                	jmp    921 <free+0xd7>
  } else
    p->s.ptr = bp;
 919:	8b 45 fc             	mov    -0x4(%ebp),%eax
 91c:	8b 55 f8             	mov    -0x8(%ebp),%edx
 91f:	89 10                	mov    %edx,(%eax)
  freep = p;
 921:	8b 45 fc             	mov    -0x4(%ebp),%eax
 924:	a3 9c 0d 00 00       	mov    %eax,0xd9c
}
 929:	90                   	nop
 92a:	c9                   	leave  
 92b:	c3                   	ret    

0000092c <morecore>:

static Header*
morecore(uint nu)
{
 92c:	55                   	push   %ebp
 92d:	89 e5                	mov    %esp,%ebp
 92f:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 932:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 939:	77 07                	ja     942 <morecore+0x16>
    nu = 4096;
 93b:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 942:	8b 45 08             	mov    0x8(%ebp),%eax
 945:	c1 e0 03             	shl    $0x3,%eax
 948:	83 ec 0c             	sub    $0xc,%esp
 94b:	50                   	push   %eax
 94c:	e8 39 fc ff ff       	call   58a <sbrk>
 951:	83 c4 10             	add    $0x10,%esp
 954:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 957:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 95b:	75 07                	jne    964 <morecore+0x38>
    return 0;
 95d:	b8 00 00 00 00       	mov    $0x0,%eax
 962:	eb 26                	jmp    98a <morecore+0x5e>
  hp = (Header*)p;
 964:	8b 45 f4             	mov    -0xc(%ebp),%eax
 967:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 96a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 96d:	8b 55 08             	mov    0x8(%ebp),%edx
 970:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 973:	8b 45 f0             	mov    -0x10(%ebp),%eax
 976:	83 c0 08             	add    $0x8,%eax
 979:	83 ec 0c             	sub    $0xc,%esp
 97c:	50                   	push   %eax
 97d:	e8 c8 fe ff ff       	call   84a <free>
 982:	83 c4 10             	add    $0x10,%esp
  return freep;
 985:	a1 9c 0d 00 00       	mov    0xd9c,%eax
}
 98a:	c9                   	leave  
 98b:	c3                   	ret    

0000098c <malloc>:

void*
malloc(uint nbytes)
{
 98c:	55                   	push   %ebp
 98d:	89 e5                	mov    %esp,%ebp
 98f:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 992:	8b 45 08             	mov    0x8(%ebp),%eax
 995:	83 c0 07             	add    $0x7,%eax
 998:	c1 e8 03             	shr    $0x3,%eax
 99b:	83 c0 01             	add    $0x1,%eax
 99e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 9a1:	a1 9c 0d 00 00       	mov    0xd9c,%eax
 9a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9a9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 9ad:	75 23                	jne    9d2 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 9af:	c7 45 f0 94 0d 00 00 	movl   $0xd94,-0x10(%ebp)
 9b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9b9:	a3 9c 0d 00 00       	mov    %eax,0xd9c
 9be:	a1 9c 0d 00 00       	mov    0xd9c,%eax
 9c3:	a3 94 0d 00 00       	mov    %eax,0xd94
    base.s.size = 0;
 9c8:	c7 05 98 0d 00 00 00 	movl   $0x0,0xd98
 9cf:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9d5:	8b 00                	mov    (%eax),%eax
 9d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9da:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9dd:	8b 40 04             	mov    0x4(%eax),%eax
 9e0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9e3:	72 4d                	jb     a32 <malloc+0xa6>
      if(p->s.size == nunits)
 9e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e8:	8b 40 04             	mov    0x4(%eax),%eax
 9eb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9ee:	75 0c                	jne    9fc <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 9f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f3:	8b 10                	mov    (%eax),%edx
 9f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9f8:	89 10                	mov    %edx,(%eax)
 9fa:	eb 26                	jmp    a22 <malloc+0x96>
      else {
        p->s.size -= nunits;
 9fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ff:	8b 40 04             	mov    0x4(%eax),%eax
 a02:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a05:	89 c2                	mov    %eax,%edx
 a07:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a0a:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a10:	8b 40 04             	mov    0x4(%eax),%eax
 a13:	c1 e0 03             	shl    $0x3,%eax
 a16:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a19:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a1c:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a1f:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a22:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a25:	a3 9c 0d 00 00       	mov    %eax,0xd9c
      return (void*)(p + 1);
 a2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a2d:	83 c0 08             	add    $0x8,%eax
 a30:	eb 3b                	jmp    a6d <malloc+0xe1>
    }
    if(p == freep)
 a32:	a1 9c 0d 00 00       	mov    0xd9c,%eax
 a37:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a3a:	75 1e                	jne    a5a <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 a3c:	83 ec 0c             	sub    $0xc,%esp
 a3f:	ff 75 ec             	pushl  -0x14(%ebp)
 a42:	e8 e5 fe ff ff       	call   92c <morecore>
 a47:	83 c4 10             	add    $0x10,%esp
 a4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a4d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a51:	75 07                	jne    a5a <malloc+0xce>
        return 0;
 a53:	b8 00 00 00 00       	mov    $0x0,%eax
 a58:	eb 13                	jmp    a6d <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a5d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a60:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a63:	8b 00                	mov    (%eax),%eax
 a65:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 a68:	e9 6d ff ff ff       	jmp    9da <malloc+0x4e>
}
 a6d:	c9                   	leave  
 a6e:	c3                   	ret    
