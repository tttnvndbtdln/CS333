
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 b0 10 00       	mov    $0x10b000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 70 d6 10 80       	mov    $0x8010d670,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 23 39 10 80       	mov    $0x80103923,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	83 ec 08             	sub    $0x8,%esp
8010003d:	68 90 95 10 80       	push   $0x80109590
80100042:	68 80 d6 10 80       	push   $0x8010d680
80100047:	e8 96 5e 00 00       	call   80105ee2 <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 90 15 11 80 84 	movl   $0x80111584,0x80111590
80100056:	15 11 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 94 15 11 80 84 	movl   $0x80111584,0x80111594
80100060:	15 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 b4 d6 10 80 	movl   $0x8010d6b4,-0xc(%ebp)
8010006a:	eb 3a                	jmp    801000a6 <binit+0x72>
    b->next = bcache.head.next;
8010006c:	8b 15 94 15 11 80    	mov    0x80111594,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 0c 84 15 11 80 	movl   $0x80111584,0xc(%eax)
    b->dev = -1;
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008c:	a1 94 15 11 80       	mov    0x80111594,%eax
80100091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100094:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010009a:	a3 94 15 11 80       	mov    %eax,0x80111594
  initlock(&bcache.lock, "bcache");

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009f:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a6:	b8 84 15 11 80       	mov    $0x80111584,%eax
801000ab:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ae:	72 bc                	jb     8010006c <binit+0x38>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000b0:	90                   	nop
801000b1:	c9                   	leave  
801000b2:	c3                   	ret    

801000b3 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000b3:	55                   	push   %ebp
801000b4:	89 e5                	mov    %esp,%ebp
801000b6:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b9:	83 ec 0c             	sub    $0xc,%esp
801000bc:	68 80 d6 10 80       	push   $0x8010d680
801000c1:	e8 3e 5e 00 00       	call   80105f04 <acquire>
801000c6:	83 c4 10             	add    $0x10,%esp

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c9:	a1 94 15 11 80       	mov    0x80111594,%eax
801000ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000d1:	eb 67                	jmp    8010013a <bget+0x87>
    if(b->dev == dev && b->blockno == blockno){
801000d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d6:	8b 40 04             	mov    0x4(%eax),%eax
801000d9:	3b 45 08             	cmp    0x8(%ebp),%eax
801000dc:	75 53                	jne    80100131 <bget+0x7e>
801000de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e1:	8b 40 08             	mov    0x8(%eax),%eax
801000e4:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e7:	75 48                	jne    80100131 <bget+0x7e>
      if(!(b->flags & B_BUSY)){
801000e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ec:	8b 00                	mov    (%eax),%eax
801000ee:	83 e0 01             	and    $0x1,%eax
801000f1:	85 c0                	test   %eax,%eax
801000f3:	75 27                	jne    8010011c <bget+0x69>
        b->flags |= B_BUSY;
801000f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f8:	8b 00                	mov    (%eax),%eax
801000fa:	83 c8 01             	or     $0x1,%eax
801000fd:	89 c2                	mov    %eax,%edx
801000ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100102:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
80100104:	83 ec 0c             	sub    $0xc,%esp
80100107:	68 80 d6 10 80       	push   $0x8010d680
8010010c:	e8 5a 5e 00 00       	call   80105f6b <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 80 d6 10 80       	push   $0x8010d680
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 d0 52 00 00       	call   801053fc <sleep>
8010012c:	83 c4 10             	add    $0x10,%esp
      goto loop;
8010012f:	eb 98                	jmp    801000c9 <bget+0x16>

  acquire(&bcache.lock);

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100131:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100134:	8b 40 10             	mov    0x10(%eax),%eax
80100137:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010013a:	81 7d f4 84 15 11 80 	cmpl   $0x80111584,-0xc(%ebp)
80100141:	75 90                	jne    801000d3 <bget+0x20>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100143:	a1 90 15 11 80       	mov    0x80111590,%eax
80100148:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010014b:	eb 51                	jmp    8010019e <bget+0xeb>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
8010014d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100150:	8b 00                	mov    (%eax),%eax
80100152:	83 e0 01             	and    $0x1,%eax
80100155:	85 c0                	test   %eax,%eax
80100157:	75 3c                	jne    80100195 <bget+0xe2>
80100159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015c:	8b 00                	mov    (%eax),%eax
8010015e:	83 e0 04             	and    $0x4,%eax
80100161:	85 c0                	test   %eax,%eax
80100163:	75 30                	jne    80100195 <bget+0xe2>
      b->dev = dev;
80100165:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100168:	8b 55 08             	mov    0x8(%ebp),%edx
8010016b:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010016e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100171:	8b 55 0c             	mov    0xc(%ebp),%edx
80100174:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
80100177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010017a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100180:	83 ec 0c             	sub    $0xc,%esp
80100183:	68 80 d6 10 80       	push   $0x8010d680
80100188:	e8 de 5d 00 00       	call   80105f6b <release>
8010018d:	83 c4 10             	add    $0x10,%esp
      return b;
80100190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100193:	eb 1f                	jmp    801001b4 <bget+0x101>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100198:	8b 40 0c             	mov    0xc(%eax),%eax
8010019b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010019e:	81 7d f4 84 15 11 80 	cmpl   $0x80111584,-0xc(%ebp)
801001a5:	75 a6                	jne    8010014d <bget+0x9a>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a7:	83 ec 0c             	sub    $0xc,%esp
801001aa:	68 97 95 10 80       	push   $0x80109597
801001af:	e8 b2 03 00 00       	call   80100566 <panic>
}
801001b4:	c9                   	leave  
801001b5:	c3                   	ret    

801001b6 <bread>:

// Return a B_BUSY buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001b6:	55                   	push   %ebp
801001b7:	89 e5                	mov    %esp,%ebp
801001b9:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001bc:	83 ec 08             	sub    $0x8,%esp
801001bf:	ff 75 0c             	pushl  0xc(%ebp)
801001c2:	ff 75 08             	pushl  0x8(%ebp)
801001c5:	e8 e9 fe ff ff       	call   801000b3 <bget>
801001ca:	83 c4 10             	add    $0x10,%esp
801001cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID)) {
801001d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d3:	8b 00                	mov    (%eax),%eax
801001d5:	83 e0 02             	and    $0x2,%eax
801001d8:	85 c0                	test   %eax,%eax
801001da:	75 0e                	jne    801001ea <bread+0x34>
    iderw(b);
801001dc:	83 ec 0c             	sub    $0xc,%esp
801001df:	ff 75 f4             	pushl  -0xc(%ebp)
801001e2:	e8 ba 27 00 00       	call   801029a1 <iderw>
801001e7:	83 c4 10             	add    $0x10,%esp
  }
  return b;
801001ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001ed:	c9                   	leave  
801001ee:	c3                   	ret    

801001ef <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001ef:	55                   	push   %ebp
801001f0:	89 e5                	mov    %esp,%ebp
801001f2:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
801001f5:	8b 45 08             	mov    0x8(%ebp),%eax
801001f8:	8b 00                	mov    (%eax),%eax
801001fa:	83 e0 01             	and    $0x1,%eax
801001fd:	85 c0                	test   %eax,%eax
801001ff:	75 0d                	jne    8010020e <bwrite+0x1f>
    panic("bwrite");
80100201:	83 ec 0c             	sub    $0xc,%esp
80100204:	68 a8 95 10 80       	push   $0x801095a8
80100209:	e8 58 03 00 00       	call   80100566 <panic>
  b->flags |= B_DIRTY;
8010020e:	8b 45 08             	mov    0x8(%ebp),%eax
80100211:	8b 00                	mov    (%eax),%eax
80100213:	83 c8 04             	or     $0x4,%eax
80100216:	89 c2                	mov    %eax,%edx
80100218:	8b 45 08             	mov    0x8(%ebp),%eax
8010021b:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010021d:	83 ec 0c             	sub    $0xc,%esp
80100220:	ff 75 08             	pushl  0x8(%ebp)
80100223:	e8 79 27 00 00       	call   801029a1 <iderw>
80100228:	83 c4 10             	add    $0x10,%esp
}
8010022b:	90                   	nop
8010022c:	c9                   	leave  
8010022d:	c3                   	ret    

8010022e <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
8010022e:	55                   	push   %ebp
8010022f:	89 e5                	mov    %esp,%ebp
80100231:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
80100234:	8b 45 08             	mov    0x8(%ebp),%eax
80100237:	8b 00                	mov    (%eax),%eax
80100239:	83 e0 01             	and    $0x1,%eax
8010023c:	85 c0                	test   %eax,%eax
8010023e:	75 0d                	jne    8010024d <brelse+0x1f>
    panic("brelse");
80100240:	83 ec 0c             	sub    $0xc,%esp
80100243:	68 af 95 10 80       	push   $0x801095af
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 80 d6 10 80       	push   $0x8010d680
80100255:	e8 aa 5c 00 00       	call   80105f04 <acquire>
8010025a:	83 c4 10             	add    $0x10,%esp

  b->next->prev = b->prev;
8010025d:	8b 45 08             	mov    0x8(%ebp),%eax
80100260:	8b 40 10             	mov    0x10(%eax),%eax
80100263:	8b 55 08             	mov    0x8(%ebp),%edx
80100266:	8b 52 0c             	mov    0xc(%edx),%edx
80100269:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
8010026c:	8b 45 08             	mov    0x8(%ebp),%eax
8010026f:	8b 40 0c             	mov    0xc(%eax),%eax
80100272:	8b 55 08             	mov    0x8(%ebp),%edx
80100275:	8b 52 10             	mov    0x10(%edx),%edx
80100278:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010027b:	8b 15 94 15 11 80    	mov    0x80111594,%edx
80100281:	8b 45 08             	mov    0x8(%ebp),%eax
80100284:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
80100287:	8b 45 08             	mov    0x8(%ebp),%eax
8010028a:	c7 40 0c 84 15 11 80 	movl   $0x80111584,0xc(%eax)
  bcache.head.next->prev = b;
80100291:	a1 94 15 11 80       	mov    0x80111594,%eax
80100296:	8b 55 08             	mov    0x8(%ebp),%edx
80100299:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
8010029c:	8b 45 08             	mov    0x8(%ebp),%eax
8010029f:	a3 94 15 11 80       	mov    %eax,0x80111594

  b->flags &= ~B_BUSY;
801002a4:	8b 45 08             	mov    0x8(%ebp),%eax
801002a7:	8b 00                	mov    (%eax),%eax
801002a9:	83 e0 fe             	and    $0xfffffffe,%eax
801002ac:	89 c2                	mov    %eax,%edx
801002ae:	8b 45 08             	mov    0x8(%ebp),%eax
801002b1:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	ff 75 08             	pushl  0x8(%ebp)
801002b9:	e8 96 52 00 00       	call   80105554 <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 80 d6 10 80       	push   $0x8010d680
801002c9:	e8 9d 5c 00 00       	call   80105f6b <release>
801002ce:	83 c4 10             	add    $0x10,%esp
}
801002d1:	90                   	nop
801002d2:	c9                   	leave  
801002d3:	c3                   	ret    

801002d4 <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
801002d4:	55                   	push   %ebp
801002d5:	89 e5                	mov    %esp,%ebp
801002d7:	83 ec 14             	sub    $0x14,%esp
801002da:	8b 45 08             	mov    0x8(%ebp),%eax
801002dd:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002e1:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002e5:	89 c2                	mov    %eax,%edx
801002e7:	ec                   	in     (%dx),%al
801002e8:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002eb:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002ef:	c9                   	leave  
801002f0:	c3                   	ret    

801002f1 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002f1:	55                   	push   %ebp
801002f2:	89 e5                	mov    %esp,%ebp
801002f4:	83 ec 08             	sub    $0x8,%esp
801002f7:	8b 55 08             	mov    0x8(%ebp),%edx
801002fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801002fd:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80100301:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100304:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100308:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010030c:	ee                   	out    %al,(%dx)
}
8010030d:	90                   	nop
8010030e:	c9                   	leave  
8010030f:	c3                   	ret    

80100310 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100310:	55                   	push   %ebp
80100311:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100313:	fa                   	cli    
}
80100314:	90                   	nop
80100315:	5d                   	pop    %ebp
80100316:	c3                   	ret    

80100317 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100317:	55                   	push   %ebp
80100318:	89 e5                	mov    %esp,%ebp
8010031a:	53                   	push   %ebx
8010031b:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010031e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100322:	74 1c                	je     80100340 <printint+0x29>
80100324:	8b 45 08             	mov    0x8(%ebp),%eax
80100327:	c1 e8 1f             	shr    $0x1f,%eax
8010032a:	0f b6 c0             	movzbl %al,%eax
8010032d:	89 45 10             	mov    %eax,0x10(%ebp)
80100330:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100334:	74 0a                	je     80100340 <printint+0x29>
    x = -xx;
80100336:	8b 45 08             	mov    0x8(%ebp),%eax
80100339:	f7 d8                	neg    %eax
8010033b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010033e:	eb 06                	jmp    80100346 <printint+0x2f>
  else
    x = xx;
80100340:	8b 45 08             	mov    0x8(%ebp),%eax
80100343:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100346:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010034d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100350:	8d 41 01             	lea    0x1(%ecx),%eax
80100353:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100356:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100359:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035c:	ba 00 00 00 00       	mov    $0x0,%edx
80100361:	f7 f3                	div    %ebx
80100363:	89 d0                	mov    %edx,%eax
80100365:	0f b6 80 04 a0 10 80 	movzbl -0x7fef5ffc(%eax),%eax
8010036c:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
80100370:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100373:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100376:	ba 00 00 00 00       	mov    $0x0,%edx
8010037b:	f7 f3                	div    %ebx
8010037d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100380:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100384:	75 c7                	jne    8010034d <printint+0x36>

  if(sign)
80100386:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010038a:	74 2a                	je     801003b6 <printint+0x9f>
    buf[i++] = '-';
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
8010039a:	eb 1a                	jmp    801003b6 <printint+0x9f>
    consputc(buf[i]);
8010039c:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010039f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a2:	01 d0                	add    %edx,%eax
801003a4:	0f b6 00             	movzbl (%eax),%eax
801003a7:	0f be c0             	movsbl %al,%eax
801003aa:	83 ec 0c             	sub    $0xc,%esp
801003ad:	50                   	push   %eax
801003ae:	e8 df 03 00 00       	call   80100792 <consputc>
801003b3:	83 c4 10             	add    $0x10,%esp
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
801003b6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003be:	79 dc                	jns    8010039c <printint+0x85>
    consputc(buf[i]);
}
801003c0:	90                   	nop
801003c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801003c4:	c9                   	leave  
801003c5:	c3                   	ret    

801003c6 <cprintf>:

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003c6:	55                   	push   %ebp
801003c7:	89 e5                	mov    %esp,%ebp
801003c9:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003cc:	a1 14 c6 10 80       	mov    0x8010c614,%eax
801003d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003d4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d8:	74 10                	je     801003ea <cprintf+0x24>
    acquire(&cons.lock);
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	68 e0 c5 10 80       	push   $0x8010c5e0
801003e2:	e8 1d 5b 00 00       	call   80105f04 <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 b6 95 10 80       	push   $0x801095b6
801003f9:	e8 68 01 00 00       	call   80100566 <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003fe:	8d 45 0c             	lea    0xc(%ebp),%eax
80100401:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100404:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010040b:	e9 1a 01 00 00       	jmp    8010052a <cprintf+0x164>
    if(c != '%'){
80100410:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100414:	74 13                	je     80100429 <cprintf+0x63>
      consputc(c);
80100416:	83 ec 0c             	sub    $0xc,%esp
80100419:	ff 75 e4             	pushl  -0x1c(%ebp)
8010041c:	e8 71 03 00 00       	call   80100792 <consputc>
80100421:	83 c4 10             	add    $0x10,%esp
      continue;
80100424:	e9 fd 00 00 00       	jmp    80100526 <cprintf+0x160>
    }
    c = fmt[++i] & 0xff;
80100429:	8b 55 08             	mov    0x8(%ebp),%edx
8010042c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100430:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100433:	01 d0                	add    %edx,%eax
80100435:	0f b6 00             	movzbl (%eax),%eax
80100438:	0f be c0             	movsbl %al,%eax
8010043b:	25 ff 00 00 00       	and    $0xff,%eax
80100440:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100443:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100447:	0f 84 ff 00 00 00    	je     8010054c <cprintf+0x186>
      break;
    switch(c){
8010044d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100450:	83 f8 70             	cmp    $0x70,%eax
80100453:	74 47                	je     8010049c <cprintf+0xd6>
80100455:	83 f8 70             	cmp    $0x70,%eax
80100458:	7f 13                	jg     8010046d <cprintf+0xa7>
8010045a:	83 f8 25             	cmp    $0x25,%eax
8010045d:	0f 84 98 00 00 00    	je     801004fb <cprintf+0x135>
80100463:	83 f8 64             	cmp    $0x64,%eax
80100466:	74 14                	je     8010047c <cprintf+0xb6>
80100468:	e9 9d 00 00 00       	jmp    8010050a <cprintf+0x144>
8010046d:	83 f8 73             	cmp    $0x73,%eax
80100470:	74 47                	je     801004b9 <cprintf+0xf3>
80100472:	83 f8 78             	cmp    $0x78,%eax
80100475:	74 25                	je     8010049c <cprintf+0xd6>
80100477:	e9 8e 00 00 00       	jmp    8010050a <cprintf+0x144>
    case 'd':
      printint(*argp++, 10, 1);
8010047c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010047f:	8d 50 04             	lea    0x4(%eax),%edx
80100482:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100485:	8b 00                	mov    (%eax),%eax
80100487:	83 ec 04             	sub    $0x4,%esp
8010048a:	6a 01                	push   $0x1
8010048c:	6a 0a                	push   $0xa
8010048e:	50                   	push   %eax
8010048f:	e8 83 fe ff ff       	call   80100317 <printint>
80100494:	83 c4 10             	add    $0x10,%esp
      break;
80100497:	e9 8a 00 00 00       	jmp    80100526 <cprintf+0x160>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
8010049c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049f:	8d 50 04             	lea    0x4(%eax),%edx
801004a2:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004a5:	8b 00                	mov    (%eax),%eax
801004a7:	83 ec 04             	sub    $0x4,%esp
801004aa:	6a 00                	push   $0x0
801004ac:	6a 10                	push   $0x10
801004ae:	50                   	push   %eax
801004af:	e8 63 fe ff ff       	call   80100317 <printint>
801004b4:	83 c4 10             	add    $0x10,%esp
      break;
801004b7:	eb 6d                	jmp    80100526 <cprintf+0x160>
    case 's':
      if((s = (char*)*argp++) == 0)
801004b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004bc:	8d 50 04             	lea    0x4(%eax),%edx
801004bf:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c2:	8b 00                	mov    (%eax),%eax
801004c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004c7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004cb:	75 22                	jne    801004ef <cprintf+0x129>
        s = "(null)";
801004cd:	c7 45 ec bf 95 10 80 	movl   $0x801095bf,-0x14(%ebp)
      for(; *s; s++)
801004d4:	eb 19                	jmp    801004ef <cprintf+0x129>
        consputc(*s);
801004d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d9:	0f b6 00             	movzbl (%eax),%eax
801004dc:	0f be c0             	movsbl %al,%eax
801004df:	83 ec 0c             	sub    $0xc,%esp
801004e2:	50                   	push   %eax
801004e3:	e8 aa 02 00 00       	call   80100792 <consputc>
801004e8:	83 c4 10             	add    $0x10,%esp
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004eb:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004f2:	0f b6 00             	movzbl (%eax),%eax
801004f5:	84 c0                	test   %al,%al
801004f7:	75 dd                	jne    801004d6 <cprintf+0x110>
        consputc(*s);
      break;
801004f9:	eb 2b                	jmp    80100526 <cprintf+0x160>
    case '%':
      consputc('%');
801004fb:	83 ec 0c             	sub    $0xc,%esp
801004fe:	6a 25                	push   $0x25
80100500:	e8 8d 02 00 00       	call   80100792 <consputc>
80100505:	83 c4 10             	add    $0x10,%esp
      break;
80100508:	eb 1c                	jmp    80100526 <cprintf+0x160>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010050a:	83 ec 0c             	sub    $0xc,%esp
8010050d:	6a 25                	push   $0x25
8010050f:	e8 7e 02 00 00       	call   80100792 <consputc>
80100514:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100517:	83 ec 0c             	sub    $0xc,%esp
8010051a:	ff 75 e4             	pushl  -0x1c(%ebp)
8010051d:	e8 70 02 00 00       	call   80100792 <consputc>
80100522:	83 c4 10             	add    $0x10,%esp
      break;
80100525:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100526:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010052a:	8b 55 08             	mov    0x8(%ebp),%edx
8010052d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100530:	01 d0                	add    %edx,%eax
80100532:	0f b6 00             	movzbl (%eax),%eax
80100535:	0f be c0             	movsbl %al,%eax
80100538:	25 ff 00 00 00       	and    $0xff,%eax
8010053d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100540:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100544:	0f 85 c6 fe ff ff    	jne    80100410 <cprintf+0x4a>
8010054a:	eb 01                	jmp    8010054d <cprintf+0x187>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
8010054c:	90                   	nop
      consputc(c);
      break;
    }
  }

  if(locking)
8010054d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100551:	74 10                	je     80100563 <cprintf+0x19d>
    release(&cons.lock);
80100553:	83 ec 0c             	sub    $0xc,%esp
80100556:	68 e0 c5 10 80       	push   $0x8010c5e0
8010055b:	e8 0b 5a 00 00       	call   80105f6b <release>
80100560:	83 c4 10             	add    $0x10,%esp
}
80100563:	90                   	nop
80100564:	c9                   	leave  
80100565:	c3                   	ret    

80100566 <panic>:

void
panic(char *s)
{
80100566:	55                   	push   %ebp
80100567:	89 e5                	mov    %esp,%ebp
80100569:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];
  
  cli();
8010056c:	e8 9f fd ff ff       	call   80100310 <cli>
  cons.locking = 0;
80100571:	c7 05 14 c6 10 80 00 	movl   $0x0,0x8010c614
80100578:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010057b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100581:	0f b6 00             	movzbl (%eax),%eax
80100584:	0f b6 c0             	movzbl %al,%eax
80100587:	83 ec 08             	sub    $0x8,%esp
8010058a:	50                   	push   %eax
8010058b:	68 c6 95 10 80       	push   $0x801095c6
80100590:	e8 31 fe ff ff       	call   801003c6 <cprintf>
80100595:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
80100598:	8b 45 08             	mov    0x8(%ebp),%eax
8010059b:	83 ec 0c             	sub    $0xc,%esp
8010059e:	50                   	push   %eax
8010059f:	e8 22 fe ff ff       	call   801003c6 <cprintf>
801005a4:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005a7:	83 ec 0c             	sub    $0xc,%esp
801005aa:	68 d5 95 10 80       	push   $0x801095d5
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 f6 59 00 00       	call   80105fbd <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 d7 95 10 80       	push   $0x801095d7
801005e3:	e8 de fd ff ff       	call   801003c6 <cprintf>
801005e8:	83 c4 10             	add    $0x10,%esp
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005eb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005ef:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005f3:	7e de                	jle    801005d3 <panic+0x6d>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005f5:	c7 05 c0 c5 10 80 01 	movl   $0x1,0x8010c5c0
801005fc:	00 00 00 
  for(;;)
    ;
801005ff:	eb fe                	jmp    801005ff <panic+0x99>

80100601 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
80100601:	55                   	push   %ebp
80100602:	89 e5                	mov    %esp,%ebp
80100604:	83 ec 18             	sub    $0x18,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
80100607:	6a 0e                	push   $0xe
80100609:	68 d4 03 00 00       	push   $0x3d4
8010060e:	e8 de fc ff ff       	call   801002f1 <outb>
80100613:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
80100616:	68 d5 03 00 00       	push   $0x3d5
8010061b:	e8 b4 fc ff ff       	call   801002d4 <inb>
80100620:	83 c4 04             	add    $0x4,%esp
80100623:	0f b6 c0             	movzbl %al,%eax
80100626:	c1 e0 08             	shl    $0x8,%eax
80100629:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
8010062c:	6a 0f                	push   $0xf
8010062e:	68 d4 03 00 00       	push   $0x3d4
80100633:	e8 b9 fc ff ff       	call   801002f1 <outb>
80100638:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
8010063b:	68 d5 03 00 00       	push   $0x3d5
80100640:	e8 8f fc ff ff       	call   801002d4 <inb>
80100645:	83 c4 04             	add    $0x4,%esp
80100648:	0f b6 c0             	movzbl %al,%eax
8010064b:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
8010064e:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100652:	75 30                	jne    80100684 <cgaputc+0x83>
    pos += 80 - pos%80;
80100654:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100657:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010065c:	89 c8                	mov    %ecx,%eax
8010065e:	f7 ea                	imul   %edx
80100660:	c1 fa 05             	sar    $0x5,%edx
80100663:	89 c8                	mov    %ecx,%eax
80100665:	c1 f8 1f             	sar    $0x1f,%eax
80100668:	29 c2                	sub    %eax,%edx
8010066a:	89 d0                	mov    %edx,%eax
8010066c:	c1 e0 02             	shl    $0x2,%eax
8010066f:	01 d0                	add    %edx,%eax
80100671:	c1 e0 04             	shl    $0x4,%eax
80100674:	29 c1                	sub    %eax,%ecx
80100676:	89 ca                	mov    %ecx,%edx
80100678:	b8 50 00 00 00       	mov    $0x50,%eax
8010067d:	29 d0                	sub    %edx,%eax
8010067f:	01 45 f4             	add    %eax,-0xc(%ebp)
80100682:	eb 34                	jmp    801006b8 <cgaputc+0xb7>
  else if(c == BACKSPACE){
80100684:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010068b:	75 0c                	jne    80100699 <cgaputc+0x98>
    if(pos > 0) --pos;
8010068d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100691:	7e 25                	jle    801006b8 <cgaputc+0xb7>
80100693:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100697:	eb 1f                	jmp    801006b8 <cgaputc+0xb7>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100699:	8b 0d 00 a0 10 80    	mov    0x8010a000,%ecx
8010069f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006a2:	8d 50 01             	lea    0x1(%eax),%edx
801006a5:	89 55 f4             	mov    %edx,-0xc(%ebp)
801006a8:	01 c0                	add    %eax,%eax
801006aa:	01 c8                	add    %ecx,%eax
801006ac:	8b 55 08             	mov    0x8(%ebp),%edx
801006af:	0f b6 d2             	movzbl %dl,%edx
801006b2:	80 ce 07             	or     $0x7,%dh
801006b5:	66 89 10             	mov    %dx,(%eax)

  if(pos < 0 || pos > 25*80)
801006b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006bc:	78 09                	js     801006c7 <cgaputc+0xc6>
801006be:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
801006c5:	7e 0d                	jle    801006d4 <cgaputc+0xd3>
    panic("pos under/overflow");
801006c7:	83 ec 0c             	sub    $0xc,%esp
801006ca:	68 db 95 10 80       	push   $0x801095db
801006cf:	e8 92 fe ff ff       	call   80100566 <panic>
  
  if((pos/80) >= 24){  // Scroll up.
801006d4:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006db:	7e 4c                	jle    80100729 <cgaputc+0x128>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006dd:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006e2:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006e8:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006ed:	83 ec 04             	sub    $0x4,%esp
801006f0:	68 60 0e 00 00       	push   $0xe60
801006f5:	52                   	push   %edx
801006f6:	50                   	push   %eax
801006f7:	e8 2a 5b 00 00       	call   80106226 <memmove>
801006fc:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
801006ff:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100703:	b8 80 07 00 00       	mov    $0x780,%eax
80100708:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010070b:	8d 14 00             	lea    (%eax,%eax,1),%edx
8010070e:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100713:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100716:	01 c9                	add    %ecx,%ecx
80100718:	01 c8                	add    %ecx,%eax
8010071a:	83 ec 04             	sub    $0x4,%esp
8010071d:	52                   	push   %edx
8010071e:	6a 00                	push   $0x0
80100720:	50                   	push   %eax
80100721:	e8 41 5a 00 00       	call   80106167 <memset>
80100726:	83 c4 10             	add    $0x10,%esp
  }
  
  outb(CRTPORT, 14);
80100729:	83 ec 08             	sub    $0x8,%esp
8010072c:	6a 0e                	push   $0xe
8010072e:	68 d4 03 00 00       	push   $0x3d4
80100733:	e8 b9 fb ff ff       	call   801002f1 <outb>
80100738:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
8010073b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010073e:	c1 f8 08             	sar    $0x8,%eax
80100741:	0f b6 c0             	movzbl %al,%eax
80100744:	83 ec 08             	sub    $0x8,%esp
80100747:	50                   	push   %eax
80100748:	68 d5 03 00 00       	push   $0x3d5
8010074d:	e8 9f fb ff ff       	call   801002f1 <outb>
80100752:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
80100755:	83 ec 08             	sub    $0x8,%esp
80100758:	6a 0f                	push   $0xf
8010075a:	68 d4 03 00 00       	push   $0x3d4
8010075f:	e8 8d fb ff ff       	call   801002f1 <outb>
80100764:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
80100767:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010076a:	0f b6 c0             	movzbl %al,%eax
8010076d:	83 ec 08             	sub    $0x8,%esp
80100770:	50                   	push   %eax
80100771:	68 d5 03 00 00       	push   $0x3d5
80100776:	e8 76 fb ff ff       	call   801002f1 <outb>
8010077b:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
8010077e:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100783:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100786:	01 d2                	add    %edx,%edx
80100788:	01 d0                	add    %edx,%eax
8010078a:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
8010078f:	90                   	nop
80100790:	c9                   	leave  
80100791:	c3                   	ret    

80100792 <consputc>:

void
consputc(int c)
{
80100792:	55                   	push   %ebp
80100793:	89 e5                	mov    %esp,%ebp
80100795:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
80100798:	a1 c0 c5 10 80       	mov    0x8010c5c0,%eax
8010079d:	85 c0                	test   %eax,%eax
8010079f:	74 07                	je     801007a8 <consputc+0x16>
    cli();
801007a1:	e8 6a fb ff ff       	call   80100310 <cli>
    for(;;)
      ;
801007a6:	eb fe                	jmp    801007a6 <consputc+0x14>
  }

  if(c == BACKSPACE){
801007a8:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801007af:	75 29                	jne    801007da <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
801007b1:	83 ec 0c             	sub    $0xc,%esp
801007b4:	6a 08                	push   $0x8
801007b6:	e8 5b 74 00 00       	call   80107c16 <uartputc>
801007bb:	83 c4 10             	add    $0x10,%esp
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	6a 20                	push   $0x20
801007c3:	e8 4e 74 00 00       	call   80107c16 <uartputc>
801007c8:	83 c4 10             	add    $0x10,%esp
801007cb:	83 ec 0c             	sub    $0xc,%esp
801007ce:	6a 08                	push   $0x8
801007d0:	e8 41 74 00 00       	call   80107c16 <uartputc>
801007d5:	83 c4 10             	add    $0x10,%esp
801007d8:	eb 0e                	jmp    801007e8 <consputc+0x56>
  } else
    uartputc(c);
801007da:	83 ec 0c             	sub    $0xc,%esp
801007dd:	ff 75 08             	pushl  0x8(%ebp)
801007e0:	e8 31 74 00 00       	call   80107c16 <uartputc>
801007e5:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
801007e8:	83 ec 0c             	sub    $0xc,%esp
801007eb:	ff 75 08             	pushl  0x8(%ebp)
801007ee:	e8 0e fe ff ff       	call   80100601 <cgaputc>
801007f3:	83 c4 10             	add    $0x10,%esp
}
801007f6:	90                   	nop
801007f7:	c9                   	leave  
801007f8:	c3                   	ret    

801007f9 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007f9:	55                   	push   %ebp
801007fa:	89 e5                	mov    %esp,%ebp
801007fc:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
801007ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
80100806:	83 ec 0c             	sub    $0xc,%esp
80100809:	68 e0 c5 10 80       	push   $0x8010c5e0
8010080e:	e8 f1 56 00 00       	call   80105f04 <acquire>
80100813:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
80100816:	e9 a6 01 00 00       	jmp    801009c1 <consoleintr+0x1c8>
    switch(c){
8010081b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010081e:	83 f8 12             	cmp    $0x12,%eax
80100821:	0f 84 d8 00 00 00    	je     801008ff <consoleintr+0x106>
80100827:	83 f8 12             	cmp    $0x12,%eax
8010082a:	7f 1c                	jg     80100848 <consoleintr+0x4f>
8010082c:	83 f8 08             	cmp    $0x8,%eax
8010082f:	0f 84 95 00 00 00    	je     801008ca <consoleintr+0xd1>
80100835:	83 f8 10             	cmp    $0x10,%eax
80100838:	74 39                	je     80100873 <consoleintr+0x7a>
8010083a:	83 f8 06             	cmp    $0x6,%eax
8010083d:	0f 84 c8 00 00 00    	je     8010090b <consoleintr+0x112>
80100843:	e9 e7 00 00 00       	jmp    8010092f <consoleintr+0x136>
80100848:	83 f8 15             	cmp    $0x15,%eax
8010084b:	74 4f                	je     8010089c <consoleintr+0xa3>
8010084d:	83 f8 15             	cmp    $0x15,%eax
80100850:	7f 0e                	jg     80100860 <consoleintr+0x67>
80100852:	83 f8 13             	cmp    $0x13,%eax
80100855:	0f 84 bc 00 00 00    	je     80100917 <consoleintr+0x11e>
8010085b:	e9 cf 00 00 00       	jmp    8010092f <consoleintr+0x136>
80100860:	83 f8 1a             	cmp    $0x1a,%eax
80100863:	0f 84 ba 00 00 00    	je     80100923 <consoleintr+0x12a>
80100869:	83 f8 7f             	cmp    $0x7f,%eax
8010086c:	74 5c                	je     801008ca <consoleintr+0xd1>
8010086e:	e9 bc 00 00 00       	jmp    8010092f <consoleintr+0x136>
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
80100873:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
8010087a:	e9 42 01 00 00       	jmp    801009c1 <consoleintr+0x1c8>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
8010087f:	a1 28 18 11 80       	mov    0x80111828,%eax
80100884:	83 e8 01             	sub    $0x1,%eax
80100887:	a3 28 18 11 80       	mov    %eax,0x80111828
        consputc(BACKSPACE);
8010088c:	83 ec 0c             	sub    $0xc,%esp
8010088f:	68 00 01 00 00       	push   $0x100
80100894:	e8 f9 fe ff ff       	call   80100792 <consputc>
80100899:	83 c4 10             	add    $0x10,%esp
    switch(c){
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010089c:	8b 15 28 18 11 80    	mov    0x80111828,%edx
801008a2:	a1 24 18 11 80       	mov    0x80111824,%eax
801008a7:	39 c2                	cmp    %eax,%edx
801008a9:	0f 84 12 01 00 00    	je     801009c1 <consoleintr+0x1c8>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
801008af:	a1 28 18 11 80       	mov    0x80111828,%eax
801008b4:	83 e8 01             	sub    $0x1,%eax
801008b7:	83 e0 7f             	and    $0x7f,%eax
801008ba:	0f b6 80 a0 17 11 80 	movzbl -0x7feee860(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
801008c1:	3c 0a                	cmp    $0xa,%al
801008c3:	75 ba                	jne    8010087f <consoleintr+0x86>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
801008c5:	e9 f7 00 00 00       	jmp    801009c1 <consoleintr+0x1c8>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
801008ca:	8b 15 28 18 11 80    	mov    0x80111828,%edx
801008d0:	a1 24 18 11 80       	mov    0x80111824,%eax
801008d5:	39 c2                	cmp    %eax,%edx
801008d7:	0f 84 e4 00 00 00    	je     801009c1 <consoleintr+0x1c8>
        input.e--;
801008dd:	a1 28 18 11 80       	mov    0x80111828,%eax
801008e2:	83 e8 01             	sub    $0x1,%eax
801008e5:	a3 28 18 11 80       	mov    %eax,0x80111828
        consputc(BACKSPACE);
801008ea:	83 ec 0c             	sub    $0xc,%esp
801008ed:	68 00 01 00 00       	push   $0x100
801008f2:	e8 9b fe ff ff       	call   80100792 <consputc>
801008f7:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008fa:	e9 c2 00 00 00       	jmp    801009c1 <consoleintr+0x1c8>

#ifdef CS333_P3P4
    case C('R'):
      doprocdump = 2;
801008ff:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
      break;
80100906:	e9 b6 00 00 00       	jmp    801009c1 <consoleintr+0x1c8>
    case C('F'):
      doprocdump = 3;
8010090b:	c7 45 f4 03 00 00 00 	movl   $0x3,-0xc(%ebp)
      break;
80100912:	e9 aa 00 00 00       	jmp    801009c1 <consoleintr+0x1c8>
    case C('S'):
      doprocdump = 4;
80100917:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%ebp)
      break;
8010091e:	e9 9e 00 00 00       	jmp    801009c1 <consoleintr+0x1c8>
    case C('Z'):
      doprocdump = 5;
80100923:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%ebp)
      break;
8010092a:	e9 92 00 00 00       	jmp    801009c1 <consoleintr+0x1c8>
#endif
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
8010092f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100933:	0f 84 87 00 00 00    	je     801009c0 <consoleintr+0x1c7>
80100939:	8b 15 28 18 11 80    	mov    0x80111828,%edx
8010093f:	a1 20 18 11 80       	mov    0x80111820,%eax
80100944:	29 c2                	sub    %eax,%edx
80100946:	89 d0                	mov    %edx,%eax
80100948:	83 f8 7f             	cmp    $0x7f,%eax
8010094b:	77 73                	ja     801009c0 <consoleintr+0x1c7>
        c = (c == '\r') ? '\n' : c;
8010094d:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80100951:	74 05                	je     80100958 <consoleintr+0x15f>
80100953:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100956:	eb 05                	jmp    8010095d <consoleintr+0x164>
80100958:	b8 0a 00 00 00       	mov    $0xa,%eax
8010095d:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
80100960:	a1 28 18 11 80       	mov    0x80111828,%eax
80100965:	8d 50 01             	lea    0x1(%eax),%edx
80100968:	89 15 28 18 11 80    	mov    %edx,0x80111828
8010096e:	83 e0 7f             	and    $0x7f,%eax
80100971:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100974:	88 90 a0 17 11 80    	mov    %dl,-0x7feee860(%eax)
        consputc(c);
8010097a:	83 ec 0c             	sub    $0xc,%esp
8010097d:	ff 75 f0             	pushl  -0x10(%ebp)
80100980:	e8 0d fe ff ff       	call   80100792 <consputc>
80100985:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100988:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
8010098c:	74 18                	je     801009a6 <consoleintr+0x1ad>
8010098e:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100992:	74 12                	je     801009a6 <consoleintr+0x1ad>
80100994:	a1 28 18 11 80       	mov    0x80111828,%eax
80100999:	8b 15 20 18 11 80    	mov    0x80111820,%edx
8010099f:	83 ea 80             	sub    $0xffffff80,%edx
801009a2:	39 d0                	cmp    %edx,%eax
801009a4:	75 1a                	jne    801009c0 <consoleintr+0x1c7>
          input.w = input.e;
801009a6:	a1 28 18 11 80       	mov    0x80111828,%eax
801009ab:	a3 24 18 11 80       	mov    %eax,0x80111824
          wakeup(&input.r);
801009b0:	83 ec 0c             	sub    $0xc,%esp
801009b3:	68 20 18 11 80       	push   $0x80111820
801009b8:	e8 97 4b 00 00       	call   80105554 <wakeup>
801009bd:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
801009c0:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c, doprocdump = 0;

  acquire(&cons.lock);
  while((c = getc()) >= 0){
801009c1:	8b 45 08             	mov    0x8(%ebp),%eax
801009c4:	ff d0                	call   *%eax
801009c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801009c9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801009cd:	0f 89 48 fe ff ff    	jns    8010081b <consoleintr+0x22>
        }
      }
      break;
    }
  }
  release(&cons.lock);
801009d3:	83 ec 0c             	sub    $0xc,%esp
801009d6:	68 e0 c5 10 80       	push   $0x8010c5e0
801009db:	e8 8b 55 00 00       	call   80105f6b <release>
801009e0:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
801009e3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801009e7:	74 05                	je     801009ee <consoleintr+0x1f5>
    procdump();  // now call procdump() wo. cons.lock held
801009e9:	e8 c6 4d 00 00       	call   801057b4 <procdump>
  }
  if(doprocdump == 2) {
801009ee:	83 7d f4 02          	cmpl   $0x2,-0xc(%ebp)
801009f2:	75 07                	jne    801009fb <consoleintr+0x202>
    doready();
801009f4:	e8 e6 52 00 00       	call   80105cdf <doready>
  }
  else if(doprocdump == 5) {
    dozombie();
  }
  
}
801009f9:	eb 25                	jmp    80100a20 <consoleintr+0x227>
    procdump();  // now call procdump() wo. cons.lock held
  }
  if(doprocdump == 2) {
    doready();
  }
  else if(doprocdump == 3) {
801009fb:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
801009ff:	75 07                	jne    80100a08 <consoleintr+0x20f>
    dofree();
80100a01:	e8 4c 53 00 00       	call   80105d52 <dofree>
  }
  else if(doprocdump == 5) {
    dozombie();
  }
  
}
80100a06:	eb 18                	jmp    80100a20 <consoleintr+0x227>
    doready();
  }
  else if(doprocdump == 3) {
    dofree();
  }
  else if(doprocdump == 4) {
80100a08:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
80100a0c:	75 07                	jne    80100a15 <consoleintr+0x21c>
    dosleep();
80100a0e:	e8 a7 53 00 00       	call   80105dba <dosleep>
  }
  else if(doprocdump == 5) {
    dozombie();
  }
  
}
80100a13:	eb 0b                	jmp    80100a20 <consoleintr+0x227>
    dofree();
  }
  else if(doprocdump == 4) {
    dosleep();
  }
  else if(doprocdump == 5) {
80100a15:	83 7d f4 05          	cmpl   $0x5,-0xc(%ebp)
80100a19:	75 05                	jne    80100a20 <consoleintr+0x227>
    dozombie();
80100a1b:	e8 0d 54 00 00       	call   80105e2d <dozombie>
  }
  
}
80100a20:	90                   	nop
80100a21:	c9                   	leave  
80100a22:	c3                   	ret    

80100a23 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100a23:	55                   	push   %ebp
80100a24:	89 e5                	mov    %esp,%ebp
80100a26:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
80100a29:	83 ec 0c             	sub    $0xc,%esp
80100a2c:	ff 75 08             	pushl  0x8(%ebp)
80100a2f:	e8 28 11 00 00       	call   80101b5c <iunlock>
80100a34:	83 c4 10             	add    $0x10,%esp
  target = n;
80100a37:	8b 45 10             	mov    0x10(%ebp),%eax
80100a3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100a3d:	83 ec 0c             	sub    $0xc,%esp
80100a40:	68 e0 c5 10 80       	push   $0x8010c5e0
80100a45:	e8 ba 54 00 00       	call   80105f04 <acquire>
80100a4a:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
80100a4d:	e9 ac 00 00 00       	jmp    80100afe <consoleread+0xdb>
    while(input.r == input.w){
      if(proc->killed){
80100a52:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100a58:	8b 40 24             	mov    0x24(%eax),%eax
80100a5b:	85 c0                	test   %eax,%eax
80100a5d:	74 28                	je     80100a87 <consoleread+0x64>
        release(&cons.lock);
80100a5f:	83 ec 0c             	sub    $0xc,%esp
80100a62:	68 e0 c5 10 80       	push   $0x8010c5e0
80100a67:	e8 ff 54 00 00       	call   80105f6b <release>
80100a6c:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a6f:	83 ec 0c             	sub    $0xc,%esp
80100a72:	ff 75 08             	pushl  0x8(%ebp)
80100a75:	e8 84 0f 00 00       	call   801019fe <ilock>
80100a7a:	83 c4 10             	add    $0x10,%esp
        return -1;
80100a7d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a82:	e9 ab 00 00 00       	jmp    80100b32 <consoleread+0x10f>
      }
      sleep(&input.r, &cons.lock);
80100a87:	83 ec 08             	sub    $0x8,%esp
80100a8a:	68 e0 c5 10 80       	push   $0x8010c5e0
80100a8f:	68 20 18 11 80       	push   $0x80111820
80100a94:	e8 63 49 00 00       	call   801053fc <sleep>
80100a99:	83 c4 10             	add    $0x10,%esp

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
80100a9c:	8b 15 20 18 11 80    	mov    0x80111820,%edx
80100aa2:	a1 24 18 11 80       	mov    0x80111824,%eax
80100aa7:	39 c2                	cmp    %eax,%edx
80100aa9:	74 a7                	je     80100a52 <consoleread+0x2f>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100aab:	a1 20 18 11 80       	mov    0x80111820,%eax
80100ab0:	8d 50 01             	lea    0x1(%eax),%edx
80100ab3:	89 15 20 18 11 80    	mov    %edx,0x80111820
80100ab9:	83 e0 7f             	and    $0x7f,%eax
80100abc:	0f b6 80 a0 17 11 80 	movzbl -0x7feee860(%eax),%eax
80100ac3:	0f be c0             	movsbl %al,%eax
80100ac6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100ac9:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100acd:	75 17                	jne    80100ae6 <consoleread+0xc3>
      if(n < target){
80100acf:	8b 45 10             	mov    0x10(%ebp),%eax
80100ad2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100ad5:	73 2f                	jae    80100b06 <consoleread+0xe3>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100ad7:	a1 20 18 11 80       	mov    0x80111820,%eax
80100adc:	83 e8 01             	sub    $0x1,%eax
80100adf:	a3 20 18 11 80       	mov    %eax,0x80111820
      }
      break;
80100ae4:	eb 20                	jmp    80100b06 <consoleread+0xe3>
    }
    *dst++ = c;
80100ae6:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ae9:	8d 50 01             	lea    0x1(%eax),%edx
80100aec:	89 55 0c             	mov    %edx,0xc(%ebp)
80100aef:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100af2:	88 10                	mov    %dl,(%eax)
    --n;
80100af4:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100af8:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100afc:	74 0b                	je     80100b09 <consoleread+0xe6>
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
80100afe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100b02:	7f 98                	jg     80100a9c <consoleread+0x79>
80100b04:	eb 04                	jmp    80100b0a <consoleread+0xe7>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
80100b06:	90                   	nop
80100b07:	eb 01                	jmp    80100b0a <consoleread+0xe7>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100b09:	90                   	nop
  }
  release(&cons.lock);
80100b0a:	83 ec 0c             	sub    $0xc,%esp
80100b0d:	68 e0 c5 10 80       	push   $0x8010c5e0
80100b12:	e8 54 54 00 00       	call   80105f6b <release>
80100b17:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b1a:	83 ec 0c             	sub    $0xc,%esp
80100b1d:	ff 75 08             	pushl  0x8(%ebp)
80100b20:	e8 d9 0e 00 00       	call   801019fe <ilock>
80100b25:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100b28:	8b 45 10             	mov    0x10(%ebp),%eax
80100b2b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b2e:	29 c2                	sub    %eax,%edx
80100b30:	89 d0                	mov    %edx,%eax
}
80100b32:	c9                   	leave  
80100b33:	c3                   	ret    

80100b34 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100b34:	55                   	push   %ebp
80100b35:	89 e5                	mov    %esp,%ebp
80100b37:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100b3a:	83 ec 0c             	sub    $0xc,%esp
80100b3d:	ff 75 08             	pushl  0x8(%ebp)
80100b40:	e8 17 10 00 00       	call   80101b5c <iunlock>
80100b45:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100b48:	83 ec 0c             	sub    $0xc,%esp
80100b4b:	68 e0 c5 10 80       	push   $0x8010c5e0
80100b50:	e8 af 53 00 00       	call   80105f04 <acquire>
80100b55:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100b58:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100b5f:	eb 21                	jmp    80100b82 <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100b61:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b64:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b67:	01 d0                	add    %edx,%eax
80100b69:	0f b6 00             	movzbl (%eax),%eax
80100b6c:	0f be c0             	movsbl %al,%eax
80100b6f:	0f b6 c0             	movzbl %al,%eax
80100b72:	83 ec 0c             	sub    $0xc,%esp
80100b75:	50                   	push   %eax
80100b76:	e8 17 fc ff ff       	call   80100792 <consputc>
80100b7b:	83 c4 10             	add    $0x10,%esp
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100b7e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b85:	3b 45 10             	cmp    0x10(%ebp),%eax
80100b88:	7c d7                	jl     80100b61 <consolewrite+0x2d>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100b8a:	83 ec 0c             	sub    $0xc,%esp
80100b8d:	68 e0 c5 10 80       	push   $0x8010c5e0
80100b92:	e8 d4 53 00 00       	call   80105f6b <release>
80100b97:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b9a:	83 ec 0c             	sub    $0xc,%esp
80100b9d:	ff 75 08             	pushl  0x8(%ebp)
80100ba0:	e8 59 0e 00 00       	call   801019fe <ilock>
80100ba5:	83 c4 10             	add    $0x10,%esp

  return n;
80100ba8:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100bab:	c9                   	leave  
80100bac:	c3                   	ret    

80100bad <consoleinit>:

void
consoleinit(void)
{
80100bad:	55                   	push   %ebp
80100bae:	89 e5                	mov    %esp,%ebp
80100bb0:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100bb3:	83 ec 08             	sub    $0x8,%esp
80100bb6:	68 ee 95 10 80       	push   $0x801095ee
80100bbb:	68 e0 c5 10 80       	push   $0x8010c5e0
80100bc0:	e8 1d 53 00 00       	call   80105ee2 <initlock>
80100bc5:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100bc8:	c7 05 ec 21 11 80 34 	movl   $0x80100b34,0x801121ec
80100bcf:	0b 10 80 
  devsw[CONSOLE].read = consoleread;
80100bd2:	c7 05 e8 21 11 80 23 	movl   $0x80100a23,0x801121e8
80100bd9:	0a 10 80 
  cons.locking = 1;
80100bdc:	c7 05 14 c6 10 80 01 	movl   $0x1,0x8010c614
80100be3:	00 00 00 

  picenable(IRQ_KBD);
80100be6:	83 ec 0c             	sub    $0xc,%esp
80100be9:	6a 01                	push   $0x1
80100beb:	e8 cf 33 00 00       	call   80103fbf <picenable>
80100bf0:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100bf3:	83 ec 08             	sub    $0x8,%esp
80100bf6:	6a 00                	push   $0x0
80100bf8:	6a 01                	push   $0x1
80100bfa:	e8 6f 1f 00 00       	call   80102b6e <ioapicenable>
80100bff:	83 c4 10             	add    $0x10,%esp
}
80100c02:	90                   	nop
80100c03:	c9                   	leave  
80100c04:	c3                   	ret    

80100c05 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100c05:	55                   	push   %ebp
80100c06:	89 e5                	mov    %esp,%ebp
80100c08:	81 ec 18 01 00 00    	sub    $0x118,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100c0e:	e8 ce 29 00 00       	call   801035e1 <begin_op>
  if((ip = namei(path)) == 0){
80100c13:	83 ec 0c             	sub    $0xc,%esp
80100c16:	ff 75 08             	pushl  0x8(%ebp)
80100c19:	e8 9e 19 00 00       	call   801025bc <namei>
80100c1e:	83 c4 10             	add    $0x10,%esp
80100c21:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c24:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c28:	75 0f                	jne    80100c39 <exec+0x34>
    end_op();
80100c2a:	e8 3e 2a 00 00       	call   8010366d <end_op>
    return -1;
80100c2f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c34:	e9 ce 03 00 00       	jmp    80101007 <exec+0x402>
  }
  ilock(ip);
80100c39:	83 ec 0c             	sub    $0xc,%esp
80100c3c:	ff 75 d8             	pushl  -0x28(%ebp)
80100c3f:	e8 ba 0d 00 00       	call   801019fe <ilock>
80100c44:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100c47:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100c4e:	6a 34                	push   $0x34
80100c50:	6a 00                	push   $0x0
80100c52:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100c58:	50                   	push   %eax
80100c59:	ff 75 d8             	pushl  -0x28(%ebp)
80100c5c:	e8 0b 13 00 00       	call   80101f6c <readi>
80100c61:	83 c4 10             	add    $0x10,%esp
80100c64:	83 f8 33             	cmp    $0x33,%eax
80100c67:	0f 86 49 03 00 00    	jbe    80100fb6 <exec+0x3b1>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c6d:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100c73:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c78:	0f 85 3b 03 00 00    	jne    80100fb9 <exec+0x3b4>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c7e:	e8 e8 80 00 00       	call   80108d6b <setupkvm>
80100c83:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c86:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c8a:	0f 84 2c 03 00 00    	je     80100fbc <exec+0x3b7>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c90:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c97:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c9e:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100ca4:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100ca7:	e9 ab 00 00 00       	jmp    80100d57 <exec+0x152>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100cac:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100caf:	6a 20                	push   $0x20
80100cb1:	50                   	push   %eax
80100cb2:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100cb8:	50                   	push   %eax
80100cb9:	ff 75 d8             	pushl  -0x28(%ebp)
80100cbc:	e8 ab 12 00 00       	call   80101f6c <readi>
80100cc1:	83 c4 10             	add    $0x10,%esp
80100cc4:	83 f8 20             	cmp    $0x20,%eax
80100cc7:	0f 85 f2 02 00 00    	jne    80100fbf <exec+0x3ba>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100ccd:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100cd3:	83 f8 01             	cmp    $0x1,%eax
80100cd6:	75 71                	jne    80100d49 <exec+0x144>
      continue;
    if(ph.memsz < ph.filesz)
80100cd8:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100cde:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100ce4:	39 c2                	cmp    %eax,%edx
80100ce6:	0f 82 d6 02 00 00    	jb     80100fc2 <exec+0x3bd>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100cec:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100cf2:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100cf8:	01 d0                	add    %edx,%eax
80100cfa:	83 ec 04             	sub    $0x4,%esp
80100cfd:	50                   	push   %eax
80100cfe:	ff 75 e0             	pushl  -0x20(%ebp)
80100d01:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d04:	e8 09 84 00 00       	call   80109112 <allocuvm>
80100d09:	83 c4 10             	add    $0x10,%esp
80100d0c:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d0f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d13:	0f 84 ac 02 00 00    	je     80100fc5 <exec+0x3c0>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100d19:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100d1f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d25:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100d2b:	83 ec 0c             	sub    $0xc,%esp
80100d2e:	52                   	push   %edx
80100d2f:	50                   	push   %eax
80100d30:	ff 75 d8             	pushl  -0x28(%ebp)
80100d33:	51                   	push   %ecx
80100d34:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d37:	e8 ff 82 00 00       	call   8010903b <loaduvm>
80100d3c:	83 c4 20             	add    $0x20,%esp
80100d3f:	85 c0                	test   %eax,%eax
80100d41:	0f 88 81 02 00 00    	js     80100fc8 <exec+0x3c3>
80100d47:	eb 01                	jmp    80100d4a <exec+0x145>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100d49:	90                   	nop
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d4a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d4e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d51:	83 c0 20             	add    $0x20,%eax
80100d54:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d57:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100d5e:	0f b7 c0             	movzwl %ax,%eax
80100d61:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100d64:	0f 8f 42 ff ff ff    	jg     80100cac <exec+0xa7>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100d6a:	83 ec 0c             	sub    $0xc,%esp
80100d6d:	ff 75 d8             	pushl  -0x28(%ebp)
80100d70:	e8 49 0f 00 00       	call   80101cbe <iunlockput>
80100d75:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d78:	e8 f0 28 00 00       	call   8010366d <end_op>
  ip = 0;
80100d7d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d84:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d87:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d8c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d91:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d94:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d97:	05 00 20 00 00       	add    $0x2000,%eax
80100d9c:	83 ec 04             	sub    $0x4,%esp
80100d9f:	50                   	push   %eax
80100da0:	ff 75 e0             	pushl  -0x20(%ebp)
80100da3:	ff 75 d4             	pushl  -0x2c(%ebp)
80100da6:	e8 67 83 00 00       	call   80109112 <allocuvm>
80100dab:	83 c4 10             	add    $0x10,%esp
80100dae:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100db1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100db5:	0f 84 10 02 00 00    	je     80100fcb <exec+0x3c6>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100dbb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100dbe:	2d 00 20 00 00       	sub    $0x2000,%eax
80100dc3:	83 ec 08             	sub    $0x8,%esp
80100dc6:	50                   	push   %eax
80100dc7:	ff 75 d4             	pushl  -0x2c(%ebp)
80100dca:	e8 69 85 00 00       	call   80109338 <clearpteu>
80100dcf:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100dd2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100dd5:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100dd8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100ddf:	e9 96 00 00 00       	jmp    80100e7a <exec+0x275>
    if(argc >= MAXARG)
80100de4:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100de8:	0f 87 e0 01 00 00    	ja     80100fce <exec+0x3c9>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100dee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100df1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100df8:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dfb:	01 d0                	add    %edx,%eax
80100dfd:	8b 00                	mov    (%eax),%eax
80100dff:	83 ec 0c             	sub    $0xc,%esp
80100e02:	50                   	push   %eax
80100e03:	e8 ac 55 00 00       	call   801063b4 <strlen>
80100e08:	83 c4 10             	add    $0x10,%esp
80100e0b:	89 c2                	mov    %eax,%edx
80100e0d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e10:	29 d0                	sub    %edx,%eax
80100e12:	83 e8 01             	sub    $0x1,%eax
80100e15:	83 e0 fc             	and    $0xfffffffc,%eax
80100e18:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100e1b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e1e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e25:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e28:	01 d0                	add    %edx,%eax
80100e2a:	8b 00                	mov    (%eax),%eax
80100e2c:	83 ec 0c             	sub    $0xc,%esp
80100e2f:	50                   	push   %eax
80100e30:	e8 7f 55 00 00       	call   801063b4 <strlen>
80100e35:	83 c4 10             	add    $0x10,%esp
80100e38:	83 c0 01             	add    $0x1,%eax
80100e3b:	89 c1                	mov    %eax,%ecx
80100e3d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e40:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e47:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e4a:	01 d0                	add    %edx,%eax
80100e4c:	8b 00                	mov    (%eax),%eax
80100e4e:	51                   	push   %ecx
80100e4f:	50                   	push   %eax
80100e50:	ff 75 dc             	pushl  -0x24(%ebp)
80100e53:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e56:	e8 94 86 00 00       	call   801094ef <copyout>
80100e5b:	83 c4 10             	add    $0x10,%esp
80100e5e:	85 c0                	test   %eax,%eax
80100e60:	0f 88 6b 01 00 00    	js     80100fd1 <exec+0x3cc>
      goto bad;
    ustack[3+argc] = sp;
80100e66:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e69:	8d 50 03             	lea    0x3(%eax),%edx
80100e6c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e6f:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100e76:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e7a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e7d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e84:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e87:	01 d0                	add    %edx,%eax
80100e89:	8b 00                	mov    (%eax),%eax
80100e8b:	85 c0                	test   %eax,%eax
80100e8d:	0f 85 51 ff ff ff    	jne    80100de4 <exec+0x1df>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100e93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e96:	83 c0 03             	add    $0x3,%eax
80100e99:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100ea0:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100ea4:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100eab:	ff ff ff 
  ustack[1] = argc;
80100eae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eb1:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100eb7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eba:	83 c0 01             	add    $0x1,%eax
80100ebd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ec4:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ec7:	29 d0                	sub    %edx,%eax
80100ec9:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100ecf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ed2:	83 c0 04             	add    $0x4,%eax
80100ed5:	c1 e0 02             	shl    $0x2,%eax
80100ed8:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100edb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ede:	83 c0 04             	add    $0x4,%eax
80100ee1:	c1 e0 02             	shl    $0x2,%eax
80100ee4:	50                   	push   %eax
80100ee5:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100eeb:	50                   	push   %eax
80100eec:	ff 75 dc             	pushl  -0x24(%ebp)
80100eef:	ff 75 d4             	pushl  -0x2c(%ebp)
80100ef2:	e8 f8 85 00 00       	call   801094ef <copyout>
80100ef7:	83 c4 10             	add    $0x10,%esp
80100efa:	85 c0                	test   %eax,%eax
80100efc:	0f 88 d2 00 00 00    	js     80100fd4 <exec+0x3cf>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f02:	8b 45 08             	mov    0x8(%ebp),%eax
80100f05:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100f08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f0b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100f0e:	eb 17                	jmp    80100f27 <exec+0x322>
    if(*s == '/')
80100f10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f13:	0f b6 00             	movzbl (%eax),%eax
80100f16:	3c 2f                	cmp    $0x2f,%al
80100f18:	75 09                	jne    80100f23 <exec+0x31e>
      last = s+1;
80100f1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f1d:	83 c0 01             	add    $0x1,%eax
80100f20:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f23:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100f27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f2a:	0f b6 00             	movzbl (%eax),%eax
80100f2d:	84 c0                	test   %al,%al
80100f2f:	75 df                	jne    80100f10 <exec+0x30b>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100f31:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f37:	83 c0 6c             	add    $0x6c,%eax
80100f3a:	83 ec 04             	sub    $0x4,%esp
80100f3d:	6a 10                	push   $0x10
80100f3f:	ff 75 f0             	pushl  -0x10(%ebp)
80100f42:	50                   	push   %eax
80100f43:	e8 22 54 00 00       	call   8010636a <safestrcpy>
80100f48:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100f4b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f51:	8b 40 04             	mov    0x4(%eax),%eax
80100f54:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100f57:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f5d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f60:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100f63:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f69:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f6c:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100f6e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f74:	8b 40 18             	mov    0x18(%eax),%eax
80100f77:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100f7d:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100f80:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f86:	8b 40 18             	mov    0x18(%eax),%eax
80100f89:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f8c:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100f8f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f95:	83 ec 0c             	sub    $0xc,%esp
80100f98:	50                   	push   %eax
80100f99:	e8 b4 7e 00 00       	call   80108e52 <switchuvm>
80100f9e:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100fa1:	83 ec 0c             	sub    $0xc,%esp
80100fa4:	ff 75 d0             	pushl  -0x30(%ebp)
80100fa7:	e8 ec 82 00 00       	call   80109298 <freevm>
80100fac:	83 c4 10             	add    $0x10,%esp
  return 0;
80100faf:	b8 00 00 00 00       	mov    $0x0,%eax
80100fb4:	eb 51                	jmp    80101007 <exec+0x402>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
80100fb6:	90                   	nop
80100fb7:	eb 1c                	jmp    80100fd5 <exec+0x3d0>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80100fb9:	90                   	nop
80100fba:	eb 19                	jmp    80100fd5 <exec+0x3d0>

  if((pgdir = setupkvm()) == 0)
    goto bad;
80100fbc:	90                   	nop
80100fbd:	eb 16                	jmp    80100fd5 <exec+0x3d0>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80100fbf:	90                   	nop
80100fc0:	eb 13                	jmp    80100fd5 <exec+0x3d0>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80100fc2:	90                   	nop
80100fc3:	eb 10                	jmp    80100fd5 <exec+0x3d0>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80100fc5:	90                   	nop
80100fc6:	eb 0d                	jmp    80100fd5 <exec+0x3d0>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80100fc8:	90                   	nop
80100fc9:	eb 0a                	jmp    80100fd5 <exec+0x3d0>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
80100fcb:	90                   	nop
80100fcc:	eb 07                	jmp    80100fd5 <exec+0x3d0>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80100fce:	90                   	nop
80100fcf:	eb 04                	jmp    80100fd5 <exec+0x3d0>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80100fd1:	90                   	nop
80100fd2:	eb 01                	jmp    80100fd5 <exec+0x3d0>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80100fd4:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
80100fd5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100fd9:	74 0e                	je     80100fe9 <exec+0x3e4>
    freevm(pgdir);
80100fdb:	83 ec 0c             	sub    $0xc,%esp
80100fde:	ff 75 d4             	pushl  -0x2c(%ebp)
80100fe1:	e8 b2 82 00 00       	call   80109298 <freevm>
80100fe6:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100fe9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100fed:	74 13                	je     80101002 <exec+0x3fd>
    iunlockput(ip);
80100fef:	83 ec 0c             	sub    $0xc,%esp
80100ff2:	ff 75 d8             	pushl  -0x28(%ebp)
80100ff5:	e8 c4 0c 00 00       	call   80101cbe <iunlockput>
80100ffa:	83 c4 10             	add    $0x10,%esp
    end_op();
80100ffd:	e8 6b 26 00 00       	call   8010366d <end_op>
  }
  return -1;
80101002:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101007:	c9                   	leave  
80101008:	c3                   	ret    

80101009 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80101009:	55                   	push   %ebp
8010100a:	89 e5                	mov    %esp,%ebp
8010100c:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
8010100f:	83 ec 08             	sub    $0x8,%esp
80101012:	68 f6 95 10 80       	push   $0x801095f6
80101017:	68 40 18 11 80       	push   $0x80111840
8010101c:	e8 c1 4e 00 00       	call   80105ee2 <initlock>
80101021:	83 c4 10             	add    $0x10,%esp
}
80101024:	90                   	nop
80101025:	c9                   	leave  
80101026:	c3                   	ret    

80101027 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101027:	55                   	push   %ebp
80101028:	89 e5                	mov    %esp,%ebp
8010102a:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
8010102d:	83 ec 0c             	sub    $0xc,%esp
80101030:	68 40 18 11 80       	push   $0x80111840
80101035:	e8 ca 4e 00 00       	call   80105f04 <acquire>
8010103a:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010103d:	c7 45 f4 74 18 11 80 	movl   $0x80111874,-0xc(%ebp)
80101044:	eb 2d                	jmp    80101073 <filealloc+0x4c>
    if(f->ref == 0){
80101046:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101049:	8b 40 04             	mov    0x4(%eax),%eax
8010104c:	85 c0                	test   %eax,%eax
8010104e:	75 1f                	jne    8010106f <filealloc+0x48>
      f->ref = 1;
80101050:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101053:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
8010105a:	83 ec 0c             	sub    $0xc,%esp
8010105d:	68 40 18 11 80       	push   $0x80111840
80101062:	e8 04 4f 00 00       	call   80105f6b <release>
80101067:	83 c4 10             	add    $0x10,%esp
      return f;
8010106a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010106d:	eb 23                	jmp    80101092 <filealloc+0x6b>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010106f:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101073:	b8 d4 21 11 80       	mov    $0x801121d4,%eax
80101078:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010107b:	72 c9                	jb     80101046 <filealloc+0x1f>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
8010107d:	83 ec 0c             	sub    $0xc,%esp
80101080:	68 40 18 11 80       	push   $0x80111840
80101085:	e8 e1 4e 00 00       	call   80105f6b <release>
8010108a:	83 c4 10             	add    $0x10,%esp
  return 0;
8010108d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101092:	c9                   	leave  
80101093:	c3                   	ret    

80101094 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101094:	55                   	push   %ebp
80101095:	89 e5                	mov    %esp,%ebp
80101097:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
8010109a:	83 ec 0c             	sub    $0xc,%esp
8010109d:	68 40 18 11 80       	push   $0x80111840
801010a2:	e8 5d 4e 00 00       	call   80105f04 <acquire>
801010a7:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010aa:	8b 45 08             	mov    0x8(%ebp),%eax
801010ad:	8b 40 04             	mov    0x4(%eax),%eax
801010b0:	85 c0                	test   %eax,%eax
801010b2:	7f 0d                	jg     801010c1 <filedup+0x2d>
    panic("filedup");
801010b4:	83 ec 0c             	sub    $0xc,%esp
801010b7:	68 fd 95 10 80       	push   $0x801095fd
801010bc:	e8 a5 f4 ff ff       	call   80100566 <panic>
  f->ref++;
801010c1:	8b 45 08             	mov    0x8(%ebp),%eax
801010c4:	8b 40 04             	mov    0x4(%eax),%eax
801010c7:	8d 50 01             	lea    0x1(%eax),%edx
801010ca:	8b 45 08             	mov    0x8(%ebp),%eax
801010cd:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801010d0:	83 ec 0c             	sub    $0xc,%esp
801010d3:	68 40 18 11 80       	push   $0x80111840
801010d8:	e8 8e 4e 00 00       	call   80105f6b <release>
801010dd:	83 c4 10             	add    $0x10,%esp
  return f;
801010e0:	8b 45 08             	mov    0x8(%ebp),%eax
}
801010e3:	c9                   	leave  
801010e4:	c3                   	ret    

801010e5 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801010e5:	55                   	push   %ebp
801010e6:	89 e5                	mov    %esp,%ebp
801010e8:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801010eb:	83 ec 0c             	sub    $0xc,%esp
801010ee:	68 40 18 11 80       	push   $0x80111840
801010f3:	e8 0c 4e 00 00       	call   80105f04 <acquire>
801010f8:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010fb:	8b 45 08             	mov    0x8(%ebp),%eax
801010fe:	8b 40 04             	mov    0x4(%eax),%eax
80101101:	85 c0                	test   %eax,%eax
80101103:	7f 0d                	jg     80101112 <fileclose+0x2d>
    panic("fileclose");
80101105:	83 ec 0c             	sub    $0xc,%esp
80101108:	68 05 96 10 80       	push   $0x80109605
8010110d:	e8 54 f4 ff ff       	call   80100566 <panic>
  if(--f->ref > 0){
80101112:	8b 45 08             	mov    0x8(%ebp),%eax
80101115:	8b 40 04             	mov    0x4(%eax),%eax
80101118:	8d 50 ff             	lea    -0x1(%eax),%edx
8010111b:	8b 45 08             	mov    0x8(%ebp),%eax
8010111e:	89 50 04             	mov    %edx,0x4(%eax)
80101121:	8b 45 08             	mov    0x8(%ebp),%eax
80101124:	8b 40 04             	mov    0x4(%eax),%eax
80101127:	85 c0                	test   %eax,%eax
80101129:	7e 15                	jle    80101140 <fileclose+0x5b>
    release(&ftable.lock);
8010112b:	83 ec 0c             	sub    $0xc,%esp
8010112e:	68 40 18 11 80       	push   $0x80111840
80101133:	e8 33 4e 00 00       	call   80105f6b <release>
80101138:	83 c4 10             	add    $0x10,%esp
8010113b:	e9 8b 00 00 00       	jmp    801011cb <fileclose+0xe6>
    return;
  }
  ff = *f;
80101140:	8b 45 08             	mov    0x8(%ebp),%eax
80101143:	8b 10                	mov    (%eax),%edx
80101145:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101148:	8b 50 04             	mov    0x4(%eax),%edx
8010114b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010114e:	8b 50 08             	mov    0x8(%eax),%edx
80101151:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101154:	8b 50 0c             	mov    0xc(%eax),%edx
80101157:	89 55 ec             	mov    %edx,-0x14(%ebp)
8010115a:	8b 50 10             	mov    0x10(%eax),%edx
8010115d:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101160:	8b 40 14             	mov    0x14(%eax),%eax
80101163:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101166:	8b 45 08             	mov    0x8(%ebp),%eax
80101169:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101170:	8b 45 08             	mov    0x8(%ebp),%eax
80101173:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101179:	83 ec 0c             	sub    $0xc,%esp
8010117c:	68 40 18 11 80       	push   $0x80111840
80101181:	e8 e5 4d 00 00       	call   80105f6b <release>
80101186:	83 c4 10             	add    $0x10,%esp
  
  if(ff.type == FD_PIPE)
80101189:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010118c:	83 f8 01             	cmp    $0x1,%eax
8010118f:	75 19                	jne    801011aa <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
80101191:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101195:	0f be d0             	movsbl %al,%edx
80101198:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010119b:	83 ec 08             	sub    $0x8,%esp
8010119e:	52                   	push   %edx
8010119f:	50                   	push   %eax
801011a0:	e8 83 30 00 00       	call   80104228 <pipeclose>
801011a5:	83 c4 10             	add    $0x10,%esp
801011a8:	eb 21                	jmp    801011cb <fileclose+0xe6>
  else if(ff.type == FD_INODE){
801011aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011ad:	83 f8 02             	cmp    $0x2,%eax
801011b0:	75 19                	jne    801011cb <fileclose+0xe6>
    begin_op();
801011b2:	e8 2a 24 00 00       	call   801035e1 <begin_op>
    iput(ff.ip);
801011b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801011ba:	83 ec 0c             	sub    $0xc,%esp
801011bd:	50                   	push   %eax
801011be:	e8 0b 0a 00 00       	call   80101bce <iput>
801011c3:	83 c4 10             	add    $0x10,%esp
    end_op();
801011c6:	e8 a2 24 00 00       	call   8010366d <end_op>
  }
}
801011cb:	c9                   	leave  
801011cc:	c3                   	ret    

801011cd <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801011cd:	55                   	push   %ebp
801011ce:	89 e5                	mov    %esp,%ebp
801011d0:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
801011d3:	8b 45 08             	mov    0x8(%ebp),%eax
801011d6:	8b 00                	mov    (%eax),%eax
801011d8:	83 f8 02             	cmp    $0x2,%eax
801011db:	75 40                	jne    8010121d <filestat+0x50>
    ilock(f->ip);
801011dd:	8b 45 08             	mov    0x8(%ebp),%eax
801011e0:	8b 40 10             	mov    0x10(%eax),%eax
801011e3:	83 ec 0c             	sub    $0xc,%esp
801011e6:	50                   	push   %eax
801011e7:	e8 12 08 00 00       	call   801019fe <ilock>
801011ec:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801011ef:	8b 45 08             	mov    0x8(%ebp),%eax
801011f2:	8b 40 10             	mov    0x10(%eax),%eax
801011f5:	83 ec 08             	sub    $0x8,%esp
801011f8:	ff 75 0c             	pushl  0xc(%ebp)
801011fb:	50                   	push   %eax
801011fc:	e8 25 0d 00 00       	call   80101f26 <stati>
80101201:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
80101204:	8b 45 08             	mov    0x8(%ebp),%eax
80101207:	8b 40 10             	mov    0x10(%eax),%eax
8010120a:	83 ec 0c             	sub    $0xc,%esp
8010120d:	50                   	push   %eax
8010120e:	e8 49 09 00 00       	call   80101b5c <iunlock>
80101213:	83 c4 10             	add    $0x10,%esp
    return 0;
80101216:	b8 00 00 00 00       	mov    $0x0,%eax
8010121b:	eb 05                	jmp    80101222 <filestat+0x55>
  }
  return -1;
8010121d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101222:	c9                   	leave  
80101223:	c3                   	ret    

80101224 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101224:	55                   	push   %ebp
80101225:	89 e5                	mov    %esp,%ebp
80101227:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
8010122a:	8b 45 08             	mov    0x8(%ebp),%eax
8010122d:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101231:	84 c0                	test   %al,%al
80101233:	75 0a                	jne    8010123f <fileread+0x1b>
    return -1;
80101235:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010123a:	e9 9b 00 00 00       	jmp    801012da <fileread+0xb6>
  if(f->type == FD_PIPE)
8010123f:	8b 45 08             	mov    0x8(%ebp),%eax
80101242:	8b 00                	mov    (%eax),%eax
80101244:	83 f8 01             	cmp    $0x1,%eax
80101247:	75 1a                	jne    80101263 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
80101249:	8b 45 08             	mov    0x8(%ebp),%eax
8010124c:	8b 40 0c             	mov    0xc(%eax),%eax
8010124f:	83 ec 04             	sub    $0x4,%esp
80101252:	ff 75 10             	pushl  0x10(%ebp)
80101255:	ff 75 0c             	pushl  0xc(%ebp)
80101258:	50                   	push   %eax
80101259:	e8 72 31 00 00       	call   801043d0 <piperead>
8010125e:	83 c4 10             	add    $0x10,%esp
80101261:	eb 77                	jmp    801012da <fileread+0xb6>
  if(f->type == FD_INODE){
80101263:	8b 45 08             	mov    0x8(%ebp),%eax
80101266:	8b 00                	mov    (%eax),%eax
80101268:	83 f8 02             	cmp    $0x2,%eax
8010126b:	75 60                	jne    801012cd <fileread+0xa9>
    ilock(f->ip);
8010126d:	8b 45 08             	mov    0x8(%ebp),%eax
80101270:	8b 40 10             	mov    0x10(%eax),%eax
80101273:	83 ec 0c             	sub    $0xc,%esp
80101276:	50                   	push   %eax
80101277:	e8 82 07 00 00       	call   801019fe <ilock>
8010127c:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010127f:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101282:	8b 45 08             	mov    0x8(%ebp),%eax
80101285:	8b 50 14             	mov    0x14(%eax),%edx
80101288:	8b 45 08             	mov    0x8(%ebp),%eax
8010128b:	8b 40 10             	mov    0x10(%eax),%eax
8010128e:	51                   	push   %ecx
8010128f:	52                   	push   %edx
80101290:	ff 75 0c             	pushl  0xc(%ebp)
80101293:	50                   	push   %eax
80101294:	e8 d3 0c 00 00       	call   80101f6c <readi>
80101299:	83 c4 10             	add    $0x10,%esp
8010129c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010129f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801012a3:	7e 11                	jle    801012b6 <fileread+0x92>
      f->off += r;
801012a5:	8b 45 08             	mov    0x8(%ebp),%eax
801012a8:	8b 50 14             	mov    0x14(%eax),%edx
801012ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012ae:	01 c2                	add    %eax,%edx
801012b0:	8b 45 08             	mov    0x8(%ebp),%eax
801012b3:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801012b6:	8b 45 08             	mov    0x8(%ebp),%eax
801012b9:	8b 40 10             	mov    0x10(%eax),%eax
801012bc:	83 ec 0c             	sub    $0xc,%esp
801012bf:	50                   	push   %eax
801012c0:	e8 97 08 00 00       	call   80101b5c <iunlock>
801012c5:	83 c4 10             	add    $0x10,%esp
    return r;
801012c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012cb:	eb 0d                	jmp    801012da <fileread+0xb6>
  }
  panic("fileread");
801012cd:	83 ec 0c             	sub    $0xc,%esp
801012d0:	68 0f 96 10 80       	push   $0x8010960f
801012d5:	e8 8c f2 ff ff       	call   80100566 <panic>
}
801012da:	c9                   	leave  
801012db:	c3                   	ret    

801012dc <filewrite>:

// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801012dc:	55                   	push   %ebp
801012dd:	89 e5                	mov    %esp,%ebp
801012df:	53                   	push   %ebx
801012e0:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
801012e3:	8b 45 08             	mov    0x8(%ebp),%eax
801012e6:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801012ea:	84 c0                	test   %al,%al
801012ec:	75 0a                	jne    801012f8 <filewrite+0x1c>
    return -1;
801012ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012f3:	e9 1b 01 00 00       	jmp    80101413 <filewrite+0x137>
  if(f->type == FD_PIPE)
801012f8:	8b 45 08             	mov    0x8(%ebp),%eax
801012fb:	8b 00                	mov    (%eax),%eax
801012fd:	83 f8 01             	cmp    $0x1,%eax
80101300:	75 1d                	jne    8010131f <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
80101302:	8b 45 08             	mov    0x8(%ebp),%eax
80101305:	8b 40 0c             	mov    0xc(%eax),%eax
80101308:	83 ec 04             	sub    $0x4,%esp
8010130b:	ff 75 10             	pushl  0x10(%ebp)
8010130e:	ff 75 0c             	pushl  0xc(%ebp)
80101311:	50                   	push   %eax
80101312:	e8 bb 2f 00 00       	call   801042d2 <pipewrite>
80101317:	83 c4 10             	add    $0x10,%esp
8010131a:	e9 f4 00 00 00       	jmp    80101413 <filewrite+0x137>
  if(f->type == FD_INODE){
8010131f:	8b 45 08             	mov    0x8(%ebp),%eax
80101322:	8b 00                	mov    (%eax),%eax
80101324:	83 f8 02             	cmp    $0x2,%eax
80101327:	0f 85 d9 00 00 00    	jne    80101406 <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
8010132d:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
80101334:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
8010133b:	e9 a3 00 00 00       	jmp    801013e3 <filewrite+0x107>
      int n1 = n - i;
80101340:	8b 45 10             	mov    0x10(%ebp),%eax
80101343:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101346:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101349:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010134c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010134f:	7e 06                	jle    80101357 <filewrite+0x7b>
        n1 = max;
80101351:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101354:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101357:	e8 85 22 00 00       	call   801035e1 <begin_op>
      ilock(f->ip);
8010135c:	8b 45 08             	mov    0x8(%ebp),%eax
8010135f:	8b 40 10             	mov    0x10(%eax),%eax
80101362:	83 ec 0c             	sub    $0xc,%esp
80101365:	50                   	push   %eax
80101366:	e8 93 06 00 00       	call   801019fe <ilock>
8010136b:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010136e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101371:	8b 45 08             	mov    0x8(%ebp),%eax
80101374:	8b 50 14             	mov    0x14(%eax),%edx
80101377:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010137a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010137d:	01 c3                	add    %eax,%ebx
8010137f:	8b 45 08             	mov    0x8(%ebp),%eax
80101382:	8b 40 10             	mov    0x10(%eax),%eax
80101385:	51                   	push   %ecx
80101386:	52                   	push   %edx
80101387:	53                   	push   %ebx
80101388:	50                   	push   %eax
80101389:	e8 35 0d 00 00       	call   801020c3 <writei>
8010138e:	83 c4 10             	add    $0x10,%esp
80101391:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101394:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101398:	7e 11                	jle    801013ab <filewrite+0xcf>
        f->off += r;
8010139a:	8b 45 08             	mov    0x8(%ebp),%eax
8010139d:	8b 50 14             	mov    0x14(%eax),%edx
801013a0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013a3:	01 c2                	add    %eax,%edx
801013a5:	8b 45 08             	mov    0x8(%ebp),%eax
801013a8:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801013ab:	8b 45 08             	mov    0x8(%ebp),%eax
801013ae:	8b 40 10             	mov    0x10(%eax),%eax
801013b1:	83 ec 0c             	sub    $0xc,%esp
801013b4:	50                   	push   %eax
801013b5:	e8 a2 07 00 00       	call   80101b5c <iunlock>
801013ba:	83 c4 10             	add    $0x10,%esp
      end_op();
801013bd:	e8 ab 22 00 00       	call   8010366d <end_op>

      if(r < 0)
801013c2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801013c6:	78 29                	js     801013f1 <filewrite+0x115>
        break;
      if(r != n1)
801013c8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013cb:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801013ce:	74 0d                	je     801013dd <filewrite+0x101>
        panic("short filewrite");
801013d0:	83 ec 0c             	sub    $0xc,%esp
801013d3:	68 18 96 10 80       	push   $0x80109618
801013d8:	e8 89 f1 ff ff       	call   80100566 <panic>
      i += r;
801013dd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013e0:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801013e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013e6:	3b 45 10             	cmp    0x10(%ebp),%eax
801013e9:	0f 8c 51 ff ff ff    	jl     80101340 <filewrite+0x64>
801013ef:	eb 01                	jmp    801013f2 <filewrite+0x116>
        f->off += r;
      iunlock(f->ip);
      end_op();

      if(r < 0)
        break;
801013f1:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801013f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013f5:	3b 45 10             	cmp    0x10(%ebp),%eax
801013f8:	75 05                	jne    801013ff <filewrite+0x123>
801013fa:	8b 45 10             	mov    0x10(%ebp),%eax
801013fd:	eb 14                	jmp    80101413 <filewrite+0x137>
801013ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101404:	eb 0d                	jmp    80101413 <filewrite+0x137>
  }
  panic("filewrite");
80101406:	83 ec 0c             	sub    $0xc,%esp
80101409:	68 28 96 10 80       	push   $0x80109628
8010140e:	e8 53 f1 ff ff       	call   80100566 <panic>
}
80101413:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101416:	c9                   	leave  
80101417:	c3                   	ret    

80101418 <readsb>:
struct superblock sb;   // there should be one per dev, but we run with one dev

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101418:	55                   	push   %ebp
80101419:	89 e5                	mov    %esp,%ebp
8010141b:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
8010141e:	8b 45 08             	mov    0x8(%ebp),%eax
80101421:	83 ec 08             	sub    $0x8,%esp
80101424:	6a 01                	push   $0x1
80101426:	50                   	push   %eax
80101427:	e8 8a ed ff ff       	call   801001b6 <bread>
8010142c:	83 c4 10             	add    $0x10,%esp
8010142f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101432:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101435:	83 c0 18             	add    $0x18,%eax
80101438:	83 ec 04             	sub    $0x4,%esp
8010143b:	6a 1c                	push   $0x1c
8010143d:	50                   	push   %eax
8010143e:	ff 75 0c             	pushl  0xc(%ebp)
80101441:	e8 e0 4d 00 00       	call   80106226 <memmove>
80101446:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101449:	83 ec 0c             	sub    $0xc,%esp
8010144c:	ff 75 f4             	pushl  -0xc(%ebp)
8010144f:	e8 da ed ff ff       	call   8010022e <brelse>
80101454:	83 c4 10             	add    $0x10,%esp
}
80101457:	90                   	nop
80101458:	c9                   	leave  
80101459:	c3                   	ret    

8010145a <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
8010145a:	55                   	push   %ebp
8010145b:	89 e5                	mov    %esp,%ebp
8010145d:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
80101460:	8b 55 0c             	mov    0xc(%ebp),%edx
80101463:	8b 45 08             	mov    0x8(%ebp),%eax
80101466:	83 ec 08             	sub    $0x8,%esp
80101469:	52                   	push   %edx
8010146a:	50                   	push   %eax
8010146b:	e8 46 ed ff ff       	call   801001b6 <bread>
80101470:	83 c4 10             	add    $0x10,%esp
80101473:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101476:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101479:	83 c0 18             	add    $0x18,%eax
8010147c:	83 ec 04             	sub    $0x4,%esp
8010147f:	68 00 02 00 00       	push   $0x200
80101484:	6a 00                	push   $0x0
80101486:	50                   	push   %eax
80101487:	e8 db 4c 00 00       	call   80106167 <memset>
8010148c:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
8010148f:	83 ec 0c             	sub    $0xc,%esp
80101492:	ff 75 f4             	pushl  -0xc(%ebp)
80101495:	e8 7f 23 00 00       	call   80103819 <log_write>
8010149a:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010149d:	83 ec 0c             	sub    $0xc,%esp
801014a0:	ff 75 f4             	pushl  -0xc(%ebp)
801014a3:	e8 86 ed ff ff       	call   8010022e <brelse>
801014a8:	83 c4 10             	add    $0x10,%esp
}
801014ab:	90                   	nop
801014ac:	c9                   	leave  
801014ad:	c3                   	ret    

801014ae <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801014ae:	55                   	push   %ebp
801014af:	89 e5                	mov    %esp,%ebp
801014b1:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
801014b4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801014bb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801014c2:	e9 13 01 00 00       	jmp    801015da <balloc+0x12c>
    bp = bread(dev, BBLOCK(b, sb));
801014c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014ca:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801014d0:	85 c0                	test   %eax,%eax
801014d2:	0f 48 c2             	cmovs  %edx,%eax
801014d5:	c1 f8 0c             	sar    $0xc,%eax
801014d8:	89 c2                	mov    %eax,%edx
801014da:	a1 58 22 11 80       	mov    0x80112258,%eax
801014df:	01 d0                	add    %edx,%eax
801014e1:	83 ec 08             	sub    $0x8,%esp
801014e4:	50                   	push   %eax
801014e5:	ff 75 08             	pushl  0x8(%ebp)
801014e8:	e8 c9 ec ff ff       	call   801001b6 <bread>
801014ed:	83 c4 10             	add    $0x10,%esp
801014f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014f3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801014fa:	e9 a6 00 00 00       	jmp    801015a5 <balloc+0xf7>
      m = 1 << (bi % 8);
801014ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101502:	99                   	cltd   
80101503:	c1 ea 1d             	shr    $0x1d,%edx
80101506:	01 d0                	add    %edx,%eax
80101508:	83 e0 07             	and    $0x7,%eax
8010150b:	29 d0                	sub    %edx,%eax
8010150d:	ba 01 00 00 00       	mov    $0x1,%edx
80101512:	89 c1                	mov    %eax,%ecx
80101514:	d3 e2                	shl    %cl,%edx
80101516:	89 d0                	mov    %edx,%eax
80101518:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010151b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010151e:	8d 50 07             	lea    0x7(%eax),%edx
80101521:	85 c0                	test   %eax,%eax
80101523:	0f 48 c2             	cmovs  %edx,%eax
80101526:	c1 f8 03             	sar    $0x3,%eax
80101529:	89 c2                	mov    %eax,%edx
8010152b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010152e:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
80101533:	0f b6 c0             	movzbl %al,%eax
80101536:	23 45 e8             	and    -0x18(%ebp),%eax
80101539:	85 c0                	test   %eax,%eax
8010153b:	75 64                	jne    801015a1 <balloc+0xf3>
        bp->data[bi/8] |= m;  // Mark block in use.
8010153d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101540:	8d 50 07             	lea    0x7(%eax),%edx
80101543:	85 c0                	test   %eax,%eax
80101545:	0f 48 c2             	cmovs  %edx,%eax
80101548:	c1 f8 03             	sar    $0x3,%eax
8010154b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010154e:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101553:	89 d1                	mov    %edx,%ecx
80101555:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101558:	09 ca                	or     %ecx,%edx
8010155a:	89 d1                	mov    %edx,%ecx
8010155c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010155f:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
80101563:	83 ec 0c             	sub    $0xc,%esp
80101566:	ff 75 ec             	pushl  -0x14(%ebp)
80101569:	e8 ab 22 00 00       	call   80103819 <log_write>
8010156e:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101571:	83 ec 0c             	sub    $0xc,%esp
80101574:	ff 75 ec             	pushl  -0x14(%ebp)
80101577:	e8 b2 ec ff ff       	call   8010022e <brelse>
8010157c:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
8010157f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101582:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101585:	01 c2                	add    %eax,%edx
80101587:	8b 45 08             	mov    0x8(%ebp),%eax
8010158a:	83 ec 08             	sub    $0x8,%esp
8010158d:	52                   	push   %edx
8010158e:	50                   	push   %eax
8010158f:	e8 c6 fe ff ff       	call   8010145a <bzero>
80101594:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101597:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010159a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010159d:	01 d0                	add    %edx,%eax
8010159f:	eb 57                	jmp    801015f8 <balloc+0x14a>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801015a1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801015a5:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801015ac:	7f 17                	jg     801015c5 <balloc+0x117>
801015ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015b4:	01 d0                	add    %edx,%eax
801015b6:	89 c2                	mov    %eax,%edx
801015b8:	a1 40 22 11 80       	mov    0x80112240,%eax
801015bd:	39 c2                	cmp    %eax,%edx
801015bf:	0f 82 3a ff ff ff    	jb     801014ff <balloc+0x51>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
801015c5:	83 ec 0c             	sub    $0xc,%esp
801015c8:	ff 75 ec             	pushl  -0x14(%ebp)
801015cb:	e8 5e ec ff ff       	call   8010022e <brelse>
801015d0:	83 c4 10             	add    $0x10,%esp
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
801015d3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801015da:	8b 15 40 22 11 80    	mov    0x80112240,%edx
801015e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015e3:	39 c2                	cmp    %eax,%edx
801015e5:	0f 87 dc fe ff ff    	ja     801014c7 <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801015eb:	83 ec 0c             	sub    $0xc,%esp
801015ee:	68 34 96 10 80       	push   $0x80109634
801015f3:	e8 6e ef ff ff       	call   80100566 <panic>
}
801015f8:	c9                   	leave  
801015f9:	c3                   	ret    

801015fa <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801015fa:	55                   	push   %ebp
801015fb:	89 e5                	mov    %esp,%ebp
801015fd:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101600:	83 ec 08             	sub    $0x8,%esp
80101603:	68 40 22 11 80       	push   $0x80112240
80101608:	ff 75 08             	pushl  0x8(%ebp)
8010160b:	e8 08 fe ff ff       	call   80101418 <readsb>
80101610:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
80101613:	8b 45 0c             	mov    0xc(%ebp),%eax
80101616:	c1 e8 0c             	shr    $0xc,%eax
80101619:	89 c2                	mov    %eax,%edx
8010161b:	a1 58 22 11 80       	mov    0x80112258,%eax
80101620:	01 c2                	add    %eax,%edx
80101622:	8b 45 08             	mov    0x8(%ebp),%eax
80101625:	83 ec 08             	sub    $0x8,%esp
80101628:	52                   	push   %edx
80101629:	50                   	push   %eax
8010162a:	e8 87 eb ff ff       	call   801001b6 <bread>
8010162f:	83 c4 10             	add    $0x10,%esp
80101632:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101635:	8b 45 0c             	mov    0xc(%ebp),%eax
80101638:	25 ff 0f 00 00       	and    $0xfff,%eax
8010163d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101640:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101643:	99                   	cltd   
80101644:	c1 ea 1d             	shr    $0x1d,%edx
80101647:	01 d0                	add    %edx,%eax
80101649:	83 e0 07             	and    $0x7,%eax
8010164c:	29 d0                	sub    %edx,%eax
8010164e:	ba 01 00 00 00       	mov    $0x1,%edx
80101653:	89 c1                	mov    %eax,%ecx
80101655:	d3 e2                	shl    %cl,%edx
80101657:	89 d0                	mov    %edx,%eax
80101659:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
8010165c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010165f:	8d 50 07             	lea    0x7(%eax),%edx
80101662:	85 c0                	test   %eax,%eax
80101664:	0f 48 c2             	cmovs  %edx,%eax
80101667:	c1 f8 03             	sar    $0x3,%eax
8010166a:	89 c2                	mov    %eax,%edx
8010166c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010166f:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
80101674:	0f b6 c0             	movzbl %al,%eax
80101677:	23 45 ec             	and    -0x14(%ebp),%eax
8010167a:	85 c0                	test   %eax,%eax
8010167c:	75 0d                	jne    8010168b <bfree+0x91>
    panic("freeing free block");
8010167e:	83 ec 0c             	sub    $0xc,%esp
80101681:	68 4a 96 10 80       	push   $0x8010964a
80101686:	e8 db ee ff ff       	call   80100566 <panic>
  bp->data[bi/8] &= ~m;
8010168b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010168e:	8d 50 07             	lea    0x7(%eax),%edx
80101691:	85 c0                	test   %eax,%eax
80101693:	0f 48 c2             	cmovs  %edx,%eax
80101696:	c1 f8 03             	sar    $0x3,%eax
80101699:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010169c:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801016a1:	89 d1                	mov    %edx,%ecx
801016a3:	8b 55 ec             	mov    -0x14(%ebp),%edx
801016a6:	f7 d2                	not    %edx
801016a8:	21 ca                	and    %ecx,%edx
801016aa:	89 d1                	mov    %edx,%ecx
801016ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016af:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
801016b3:	83 ec 0c             	sub    $0xc,%esp
801016b6:	ff 75 f4             	pushl  -0xc(%ebp)
801016b9:	e8 5b 21 00 00       	call   80103819 <log_write>
801016be:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801016c1:	83 ec 0c             	sub    $0xc,%esp
801016c4:	ff 75 f4             	pushl  -0xc(%ebp)
801016c7:	e8 62 eb ff ff       	call   8010022e <brelse>
801016cc:	83 c4 10             	add    $0x10,%esp
}
801016cf:	90                   	nop
801016d0:	c9                   	leave  
801016d1:	c3                   	ret    

801016d2 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
801016d2:	55                   	push   %ebp
801016d3:	89 e5                	mov    %esp,%ebp
801016d5:	57                   	push   %edi
801016d6:	56                   	push   %esi
801016d7:	53                   	push   %ebx
801016d8:	83 ec 1c             	sub    $0x1c,%esp
  initlock(&icache.lock, "icache");
801016db:	83 ec 08             	sub    $0x8,%esp
801016de:	68 5d 96 10 80       	push   $0x8010965d
801016e3:	68 60 22 11 80       	push   $0x80112260
801016e8:	e8 f5 47 00 00       	call   80105ee2 <initlock>
801016ed:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
801016f0:	83 ec 08             	sub    $0x8,%esp
801016f3:	68 40 22 11 80       	push   $0x80112240
801016f8:	ff 75 08             	pushl  0x8(%ebp)
801016fb:	e8 18 fd ff ff       	call   80101418 <readsb>
80101700:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n", sb.size,
80101703:	a1 58 22 11 80       	mov    0x80112258,%eax
80101708:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010170b:	8b 3d 54 22 11 80    	mov    0x80112254,%edi
80101711:	8b 35 50 22 11 80    	mov    0x80112250,%esi
80101717:	8b 1d 4c 22 11 80    	mov    0x8011224c,%ebx
8010171d:	8b 0d 48 22 11 80    	mov    0x80112248,%ecx
80101723:	8b 15 44 22 11 80    	mov    0x80112244,%edx
80101729:	a1 40 22 11 80       	mov    0x80112240,%eax
8010172e:	ff 75 e4             	pushl  -0x1c(%ebp)
80101731:	57                   	push   %edi
80101732:	56                   	push   %esi
80101733:	53                   	push   %ebx
80101734:	51                   	push   %ecx
80101735:	52                   	push   %edx
80101736:	50                   	push   %eax
80101737:	68 64 96 10 80       	push   $0x80109664
8010173c:	e8 85 ec ff ff       	call   801003c6 <cprintf>
80101741:	83 c4 20             	add    $0x20,%esp
          sb.nblocks, sb.ninodes, sb.nlog, sb.logstart, sb.inodestart, sb.bmapstart);
}
80101744:	90                   	nop
80101745:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101748:	5b                   	pop    %ebx
80101749:	5e                   	pop    %esi
8010174a:	5f                   	pop    %edi
8010174b:	5d                   	pop    %ebp
8010174c:	c3                   	ret    

8010174d <ialloc>:

// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
8010174d:	55                   	push   %ebp
8010174e:	89 e5                	mov    %esp,%ebp
80101750:	83 ec 28             	sub    $0x28,%esp
80101753:	8b 45 0c             	mov    0xc(%ebp),%eax
80101756:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010175a:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101761:	e9 9e 00 00 00       	jmp    80101804 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
80101766:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101769:	c1 e8 03             	shr    $0x3,%eax
8010176c:	89 c2                	mov    %eax,%edx
8010176e:	a1 54 22 11 80       	mov    0x80112254,%eax
80101773:	01 d0                	add    %edx,%eax
80101775:	83 ec 08             	sub    $0x8,%esp
80101778:	50                   	push   %eax
80101779:	ff 75 08             	pushl  0x8(%ebp)
8010177c:	e8 35 ea ff ff       	call   801001b6 <bread>
80101781:	83 c4 10             	add    $0x10,%esp
80101784:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101787:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010178a:	8d 50 18             	lea    0x18(%eax),%edx
8010178d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101790:	83 e0 07             	and    $0x7,%eax
80101793:	c1 e0 06             	shl    $0x6,%eax
80101796:	01 d0                	add    %edx,%eax
80101798:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010179b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010179e:	0f b7 00             	movzwl (%eax),%eax
801017a1:	66 85 c0             	test   %ax,%ax
801017a4:	75 4c                	jne    801017f2 <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
801017a6:	83 ec 04             	sub    $0x4,%esp
801017a9:	6a 40                	push   $0x40
801017ab:	6a 00                	push   $0x0
801017ad:	ff 75 ec             	pushl  -0x14(%ebp)
801017b0:	e8 b2 49 00 00       	call   80106167 <memset>
801017b5:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801017b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017bb:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801017bf:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801017c2:	83 ec 0c             	sub    $0xc,%esp
801017c5:	ff 75 f0             	pushl  -0x10(%ebp)
801017c8:	e8 4c 20 00 00       	call   80103819 <log_write>
801017cd:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801017d0:	83 ec 0c             	sub    $0xc,%esp
801017d3:	ff 75 f0             	pushl  -0x10(%ebp)
801017d6:	e8 53 ea ff ff       	call   8010022e <brelse>
801017db:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801017de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017e1:	83 ec 08             	sub    $0x8,%esp
801017e4:	50                   	push   %eax
801017e5:	ff 75 08             	pushl  0x8(%ebp)
801017e8:	e8 f8 00 00 00       	call   801018e5 <iget>
801017ed:	83 c4 10             	add    $0x10,%esp
801017f0:	eb 30                	jmp    80101822 <ialloc+0xd5>
    }
    brelse(bp);
801017f2:	83 ec 0c             	sub    $0xc,%esp
801017f5:	ff 75 f0             	pushl  -0x10(%ebp)
801017f8:	e8 31 ea ff ff       	call   8010022e <brelse>
801017fd:	83 c4 10             	add    $0x10,%esp
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101800:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101804:	8b 15 48 22 11 80    	mov    0x80112248,%edx
8010180a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010180d:	39 c2                	cmp    %eax,%edx
8010180f:	0f 87 51 ff ff ff    	ja     80101766 <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101815:	83 ec 0c             	sub    $0xc,%esp
80101818:	68 b7 96 10 80       	push   $0x801096b7
8010181d:	e8 44 ed ff ff       	call   80100566 <panic>
}
80101822:	c9                   	leave  
80101823:	c3                   	ret    

80101824 <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101824:	55                   	push   %ebp
80101825:	89 e5                	mov    %esp,%ebp
80101827:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010182a:	8b 45 08             	mov    0x8(%ebp),%eax
8010182d:	8b 40 04             	mov    0x4(%eax),%eax
80101830:	c1 e8 03             	shr    $0x3,%eax
80101833:	89 c2                	mov    %eax,%edx
80101835:	a1 54 22 11 80       	mov    0x80112254,%eax
8010183a:	01 c2                	add    %eax,%edx
8010183c:	8b 45 08             	mov    0x8(%ebp),%eax
8010183f:	8b 00                	mov    (%eax),%eax
80101841:	83 ec 08             	sub    $0x8,%esp
80101844:	52                   	push   %edx
80101845:	50                   	push   %eax
80101846:	e8 6b e9 ff ff       	call   801001b6 <bread>
8010184b:	83 c4 10             	add    $0x10,%esp
8010184e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101851:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101854:	8d 50 18             	lea    0x18(%eax),%edx
80101857:	8b 45 08             	mov    0x8(%ebp),%eax
8010185a:	8b 40 04             	mov    0x4(%eax),%eax
8010185d:	83 e0 07             	and    $0x7,%eax
80101860:	c1 e0 06             	shl    $0x6,%eax
80101863:	01 d0                	add    %edx,%eax
80101865:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101868:	8b 45 08             	mov    0x8(%ebp),%eax
8010186b:	0f b7 50 10          	movzwl 0x10(%eax),%edx
8010186f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101872:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101875:	8b 45 08             	mov    0x8(%ebp),%eax
80101878:	0f b7 50 12          	movzwl 0x12(%eax),%edx
8010187c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010187f:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101883:	8b 45 08             	mov    0x8(%ebp),%eax
80101886:	0f b7 50 14          	movzwl 0x14(%eax),%edx
8010188a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010188d:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101891:	8b 45 08             	mov    0x8(%ebp),%eax
80101894:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101898:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010189b:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
8010189f:	8b 45 08             	mov    0x8(%ebp),%eax
801018a2:	8b 50 18             	mov    0x18(%eax),%edx
801018a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018a8:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801018ab:	8b 45 08             	mov    0x8(%ebp),%eax
801018ae:	8d 50 1c             	lea    0x1c(%eax),%edx
801018b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018b4:	83 c0 0c             	add    $0xc,%eax
801018b7:	83 ec 04             	sub    $0x4,%esp
801018ba:	6a 34                	push   $0x34
801018bc:	52                   	push   %edx
801018bd:	50                   	push   %eax
801018be:	e8 63 49 00 00       	call   80106226 <memmove>
801018c3:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801018c6:	83 ec 0c             	sub    $0xc,%esp
801018c9:	ff 75 f4             	pushl  -0xc(%ebp)
801018cc:	e8 48 1f 00 00       	call   80103819 <log_write>
801018d1:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801018d4:	83 ec 0c             	sub    $0xc,%esp
801018d7:	ff 75 f4             	pushl  -0xc(%ebp)
801018da:	e8 4f e9 ff ff       	call   8010022e <brelse>
801018df:	83 c4 10             	add    $0x10,%esp
}
801018e2:	90                   	nop
801018e3:	c9                   	leave  
801018e4:	c3                   	ret    

801018e5 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801018e5:	55                   	push   %ebp
801018e6:	89 e5                	mov    %esp,%ebp
801018e8:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801018eb:	83 ec 0c             	sub    $0xc,%esp
801018ee:	68 60 22 11 80       	push   $0x80112260
801018f3:	e8 0c 46 00 00       	call   80105f04 <acquire>
801018f8:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801018fb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101902:	c7 45 f4 94 22 11 80 	movl   $0x80112294,-0xc(%ebp)
80101909:	eb 5d                	jmp    80101968 <iget+0x83>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
8010190b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010190e:	8b 40 08             	mov    0x8(%eax),%eax
80101911:	85 c0                	test   %eax,%eax
80101913:	7e 39                	jle    8010194e <iget+0x69>
80101915:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101918:	8b 00                	mov    (%eax),%eax
8010191a:	3b 45 08             	cmp    0x8(%ebp),%eax
8010191d:	75 2f                	jne    8010194e <iget+0x69>
8010191f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101922:	8b 40 04             	mov    0x4(%eax),%eax
80101925:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101928:	75 24                	jne    8010194e <iget+0x69>
      ip->ref++;
8010192a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010192d:	8b 40 08             	mov    0x8(%eax),%eax
80101930:	8d 50 01             	lea    0x1(%eax),%edx
80101933:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101936:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101939:	83 ec 0c             	sub    $0xc,%esp
8010193c:	68 60 22 11 80       	push   $0x80112260
80101941:	e8 25 46 00 00       	call   80105f6b <release>
80101946:	83 c4 10             	add    $0x10,%esp
      return ip;
80101949:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010194c:	eb 74                	jmp    801019c2 <iget+0xdd>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
8010194e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101952:	75 10                	jne    80101964 <iget+0x7f>
80101954:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101957:	8b 40 08             	mov    0x8(%eax),%eax
8010195a:	85 c0                	test   %eax,%eax
8010195c:	75 06                	jne    80101964 <iget+0x7f>
      empty = ip;
8010195e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101961:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101964:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
80101968:	81 7d f4 34 32 11 80 	cmpl   $0x80113234,-0xc(%ebp)
8010196f:	72 9a                	jb     8010190b <iget+0x26>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101971:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101975:	75 0d                	jne    80101984 <iget+0x9f>
    panic("iget: no inodes");
80101977:	83 ec 0c             	sub    $0xc,%esp
8010197a:	68 c9 96 10 80       	push   $0x801096c9
8010197f:	e8 e2 eb ff ff       	call   80100566 <panic>

  ip = empty;
80101984:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101987:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
8010198a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010198d:	8b 55 08             	mov    0x8(%ebp),%edx
80101990:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101992:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101995:	8b 55 0c             	mov    0xc(%ebp),%edx
80101998:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
8010199b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010199e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
801019a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a8:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
801019af:	83 ec 0c             	sub    $0xc,%esp
801019b2:	68 60 22 11 80       	push   $0x80112260
801019b7:	e8 af 45 00 00       	call   80105f6b <release>
801019bc:	83 c4 10             	add    $0x10,%esp

  return ip;
801019bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801019c2:	c9                   	leave  
801019c3:	c3                   	ret    

801019c4 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801019c4:	55                   	push   %ebp
801019c5:	89 e5                	mov    %esp,%ebp
801019c7:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801019ca:	83 ec 0c             	sub    $0xc,%esp
801019cd:	68 60 22 11 80       	push   $0x80112260
801019d2:	e8 2d 45 00 00       	call   80105f04 <acquire>
801019d7:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019da:	8b 45 08             	mov    0x8(%ebp),%eax
801019dd:	8b 40 08             	mov    0x8(%eax),%eax
801019e0:	8d 50 01             	lea    0x1(%eax),%edx
801019e3:	8b 45 08             	mov    0x8(%ebp),%eax
801019e6:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019e9:	83 ec 0c             	sub    $0xc,%esp
801019ec:	68 60 22 11 80       	push   $0x80112260
801019f1:	e8 75 45 00 00       	call   80105f6b <release>
801019f6:	83 c4 10             	add    $0x10,%esp
  return ip;
801019f9:	8b 45 08             	mov    0x8(%ebp),%eax
}
801019fc:	c9                   	leave  
801019fd:	c3                   	ret    

801019fe <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801019fe:	55                   	push   %ebp
801019ff:	89 e5                	mov    %esp,%ebp
80101a01:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101a04:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a08:	74 0a                	je     80101a14 <ilock+0x16>
80101a0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a0d:	8b 40 08             	mov    0x8(%eax),%eax
80101a10:	85 c0                	test   %eax,%eax
80101a12:	7f 0d                	jg     80101a21 <ilock+0x23>
    panic("ilock");
80101a14:	83 ec 0c             	sub    $0xc,%esp
80101a17:	68 d9 96 10 80       	push   $0x801096d9
80101a1c:	e8 45 eb ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101a21:	83 ec 0c             	sub    $0xc,%esp
80101a24:	68 60 22 11 80       	push   $0x80112260
80101a29:	e8 d6 44 00 00       	call   80105f04 <acquire>
80101a2e:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
80101a31:	eb 13                	jmp    80101a46 <ilock+0x48>
    sleep(ip, &icache.lock);
80101a33:	83 ec 08             	sub    $0x8,%esp
80101a36:	68 60 22 11 80       	push   $0x80112260
80101a3b:	ff 75 08             	pushl  0x8(%ebp)
80101a3e:	e8 b9 39 00 00       	call   801053fc <sleep>
80101a43:	83 c4 10             	add    $0x10,%esp

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101a46:	8b 45 08             	mov    0x8(%ebp),%eax
80101a49:	8b 40 0c             	mov    0xc(%eax),%eax
80101a4c:	83 e0 01             	and    $0x1,%eax
80101a4f:	85 c0                	test   %eax,%eax
80101a51:	75 e0                	jne    80101a33 <ilock+0x35>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101a53:	8b 45 08             	mov    0x8(%ebp),%eax
80101a56:	8b 40 0c             	mov    0xc(%eax),%eax
80101a59:	83 c8 01             	or     $0x1,%eax
80101a5c:	89 c2                	mov    %eax,%edx
80101a5e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a61:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80101a64:	83 ec 0c             	sub    $0xc,%esp
80101a67:	68 60 22 11 80       	push   $0x80112260
80101a6c:	e8 fa 44 00 00       	call   80105f6b <release>
80101a71:	83 c4 10             	add    $0x10,%esp

  if(!(ip->flags & I_VALID)){
80101a74:	8b 45 08             	mov    0x8(%ebp),%eax
80101a77:	8b 40 0c             	mov    0xc(%eax),%eax
80101a7a:	83 e0 02             	and    $0x2,%eax
80101a7d:	85 c0                	test   %eax,%eax
80101a7f:	0f 85 d4 00 00 00    	jne    80101b59 <ilock+0x15b>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a85:	8b 45 08             	mov    0x8(%ebp),%eax
80101a88:	8b 40 04             	mov    0x4(%eax),%eax
80101a8b:	c1 e8 03             	shr    $0x3,%eax
80101a8e:	89 c2                	mov    %eax,%edx
80101a90:	a1 54 22 11 80       	mov    0x80112254,%eax
80101a95:	01 c2                	add    %eax,%edx
80101a97:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9a:	8b 00                	mov    (%eax),%eax
80101a9c:	83 ec 08             	sub    $0x8,%esp
80101a9f:	52                   	push   %edx
80101aa0:	50                   	push   %eax
80101aa1:	e8 10 e7 ff ff       	call   801001b6 <bread>
80101aa6:	83 c4 10             	add    $0x10,%esp
80101aa9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aaf:	8d 50 18             	lea    0x18(%eax),%edx
80101ab2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab5:	8b 40 04             	mov    0x4(%eax),%eax
80101ab8:	83 e0 07             	and    $0x7,%eax
80101abb:	c1 e0 06             	shl    $0x6,%eax
80101abe:	01 d0                	add    %edx,%eax
80101ac0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101ac3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ac6:	0f b7 10             	movzwl (%eax),%edx
80101ac9:	8b 45 08             	mov    0x8(%ebp),%eax
80101acc:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101ad0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ad3:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101ad7:	8b 45 08             	mov    0x8(%ebp),%eax
80101ada:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101ade:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ae1:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101ae5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae8:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101aec:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aef:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101af3:	8b 45 08             	mov    0x8(%ebp),%eax
80101af6:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101afa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101afd:	8b 50 08             	mov    0x8(%eax),%edx
80101b00:	8b 45 08             	mov    0x8(%ebp),%eax
80101b03:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101b06:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b09:	8d 50 0c             	lea    0xc(%eax),%edx
80101b0c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0f:	83 c0 1c             	add    $0x1c,%eax
80101b12:	83 ec 04             	sub    $0x4,%esp
80101b15:	6a 34                	push   $0x34
80101b17:	52                   	push   %edx
80101b18:	50                   	push   %eax
80101b19:	e8 08 47 00 00       	call   80106226 <memmove>
80101b1e:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101b21:	83 ec 0c             	sub    $0xc,%esp
80101b24:	ff 75 f4             	pushl  -0xc(%ebp)
80101b27:	e8 02 e7 ff ff       	call   8010022e <brelse>
80101b2c:	83 c4 10             	add    $0x10,%esp
    ip->flags |= I_VALID;
80101b2f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b32:	8b 40 0c             	mov    0xc(%eax),%eax
80101b35:	83 c8 02             	or     $0x2,%eax
80101b38:	89 c2                	mov    %eax,%edx
80101b3a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b3d:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101b40:	8b 45 08             	mov    0x8(%ebp),%eax
80101b43:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101b47:	66 85 c0             	test   %ax,%ax
80101b4a:	75 0d                	jne    80101b59 <ilock+0x15b>
      panic("ilock: no type");
80101b4c:	83 ec 0c             	sub    $0xc,%esp
80101b4f:	68 df 96 10 80       	push   $0x801096df
80101b54:	e8 0d ea ff ff       	call   80100566 <panic>
  }
}
80101b59:	90                   	nop
80101b5a:	c9                   	leave  
80101b5b:	c3                   	ret    

80101b5c <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101b5c:	55                   	push   %ebp
80101b5d:	89 e5                	mov    %esp,%ebp
80101b5f:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101b62:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b66:	74 17                	je     80101b7f <iunlock+0x23>
80101b68:	8b 45 08             	mov    0x8(%ebp),%eax
80101b6b:	8b 40 0c             	mov    0xc(%eax),%eax
80101b6e:	83 e0 01             	and    $0x1,%eax
80101b71:	85 c0                	test   %eax,%eax
80101b73:	74 0a                	je     80101b7f <iunlock+0x23>
80101b75:	8b 45 08             	mov    0x8(%ebp),%eax
80101b78:	8b 40 08             	mov    0x8(%eax),%eax
80101b7b:	85 c0                	test   %eax,%eax
80101b7d:	7f 0d                	jg     80101b8c <iunlock+0x30>
    panic("iunlock");
80101b7f:	83 ec 0c             	sub    $0xc,%esp
80101b82:	68 ee 96 10 80       	push   $0x801096ee
80101b87:	e8 da e9 ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101b8c:	83 ec 0c             	sub    $0xc,%esp
80101b8f:	68 60 22 11 80       	push   $0x80112260
80101b94:	e8 6b 43 00 00       	call   80105f04 <acquire>
80101b99:	83 c4 10             	add    $0x10,%esp
  ip->flags &= ~I_BUSY;
80101b9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b9f:	8b 40 0c             	mov    0xc(%eax),%eax
80101ba2:	83 e0 fe             	and    $0xfffffffe,%eax
80101ba5:	89 c2                	mov    %eax,%edx
80101ba7:	8b 45 08             	mov    0x8(%ebp),%eax
80101baa:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101bad:	83 ec 0c             	sub    $0xc,%esp
80101bb0:	ff 75 08             	pushl  0x8(%ebp)
80101bb3:	e8 9c 39 00 00       	call   80105554 <wakeup>
80101bb8:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101bbb:	83 ec 0c             	sub    $0xc,%esp
80101bbe:	68 60 22 11 80       	push   $0x80112260
80101bc3:	e8 a3 43 00 00       	call   80105f6b <release>
80101bc8:	83 c4 10             	add    $0x10,%esp
}
80101bcb:	90                   	nop
80101bcc:	c9                   	leave  
80101bcd:	c3                   	ret    

80101bce <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101bce:	55                   	push   %ebp
80101bcf:	89 e5                	mov    %esp,%ebp
80101bd1:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101bd4:	83 ec 0c             	sub    $0xc,%esp
80101bd7:	68 60 22 11 80       	push   $0x80112260
80101bdc:	e8 23 43 00 00       	call   80105f04 <acquire>
80101be1:	83 c4 10             	add    $0x10,%esp
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101be4:	8b 45 08             	mov    0x8(%ebp),%eax
80101be7:	8b 40 08             	mov    0x8(%eax),%eax
80101bea:	83 f8 01             	cmp    $0x1,%eax
80101bed:	0f 85 a9 00 00 00    	jne    80101c9c <iput+0xce>
80101bf3:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf6:	8b 40 0c             	mov    0xc(%eax),%eax
80101bf9:	83 e0 02             	and    $0x2,%eax
80101bfc:	85 c0                	test   %eax,%eax
80101bfe:	0f 84 98 00 00 00    	je     80101c9c <iput+0xce>
80101c04:	8b 45 08             	mov    0x8(%ebp),%eax
80101c07:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101c0b:	66 85 c0             	test   %ax,%ax
80101c0e:	0f 85 88 00 00 00    	jne    80101c9c <iput+0xce>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101c14:	8b 45 08             	mov    0x8(%ebp),%eax
80101c17:	8b 40 0c             	mov    0xc(%eax),%eax
80101c1a:	83 e0 01             	and    $0x1,%eax
80101c1d:	85 c0                	test   %eax,%eax
80101c1f:	74 0d                	je     80101c2e <iput+0x60>
      panic("iput busy");
80101c21:	83 ec 0c             	sub    $0xc,%esp
80101c24:	68 f6 96 10 80       	push   $0x801096f6
80101c29:	e8 38 e9 ff ff       	call   80100566 <panic>
    ip->flags |= I_BUSY;
80101c2e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c31:	8b 40 0c             	mov    0xc(%eax),%eax
80101c34:	83 c8 01             	or     $0x1,%eax
80101c37:	89 c2                	mov    %eax,%edx
80101c39:	8b 45 08             	mov    0x8(%ebp),%eax
80101c3c:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101c3f:	83 ec 0c             	sub    $0xc,%esp
80101c42:	68 60 22 11 80       	push   $0x80112260
80101c47:	e8 1f 43 00 00       	call   80105f6b <release>
80101c4c:	83 c4 10             	add    $0x10,%esp
    itrunc(ip);
80101c4f:	83 ec 0c             	sub    $0xc,%esp
80101c52:	ff 75 08             	pushl  0x8(%ebp)
80101c55:	e8 a8 01 00 00       	call   80101e02 <itrunc>
80101c5a:	83 c4 10             	add    $0x10,%esp
    ip->type = 0;
80101c5d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c60:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101c66:	83 ec 0c             	sub    $0xc,%esp
80101c69:	ff 75 08             	pushl  0x8(%ebp)
80101c6c:	e8 b3 fb ff ff       	call   80101824 <iupdate>
80101c71:	83 c4 10             	add    $0x10,%esp
    acquire(&icache.lock);
80101c74:	83 ec 0c             	sub    $0xc,%esp
80101c77:	68 60 22 11 80       	push   $0x80112260
80101c7c:	e8 83 42 00 00       	call   80105f04 <acquire>
80101c81:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101c84:	8b 45 08             	mov    0x8(%ebp),%eax
80101c87:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101c8e:	83 ec 0c             	sub    $0xc,%esp
80101c91:	ff 75 08             	pushl  0x8(%ebp)
80101c94:	e8 bb 38 00 00       	call   80105554 <wakeup>
80101c99:	83 c4 10             	add    $0x10,%esp
  }
  ip->ref--;
80101c9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9f:	8b 40 08             	mov    0x8(%eax),%eax
80101ca2:	8d 50 ff             	lea    -0x1(%eax),%edx
80101ca5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca8:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101cab:	83 ec 0c             	sub    $0xc,%esp
80101cae:	68 60 22 11 80       	push   $0x80112260
80101cb3:	e8 b3 42 00 00       	call   80105f6b <release>
80101cb8:	83 c4 10             	add    $0x10,%esp
}
80101cbb:	90                   	nop
80101cbc:	c9                   	leave  
80101cbd:	c3                   	ret    

80101cbe <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101cbe:	55                   	push   %ebp
80101cbf:	89 e5                	mov    %esp,%ebp
80101cc1:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101cc4:	83 ec 0c             	sub    $0xc,%esp
80101cc7:	ff 75 08             	pushl  0x8(%ebp)
80101cca:	e8 8d fe ff ff       	call   80101b5c <iunlock>
80101ccf:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101cd2:	83 ec 0c             	sub    $0xc,%esp
80101cd5:	ff 75 08             	pushl  0x8(%ebp)
80101cd8:	e8 f1 fe ff ff       	call   80101bce <iput>
80101cdd:	83 c4 10             	add    $0x10,%esp
}
80101ce0:	90                   	nop
80101ce1:	c9                   	leave  
80101ce2:	c3                   	ret    

80101ce3 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101ce3:	55                   	push   %ebp
80101ce4:	89 e5                	mov    %esp,%ebp
80101ce6:	53                   	push   %ebx
80101ce7:	83 ec 14             	sub    $0x14,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101cea:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101cee:	77 42                	ja     80101d32 <bmap+0x4f>
    if((addr = ip->addrs[bn]) == 0)
80101cf0:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf3:	8b 55 0c             	mov    0xc(%ebp),%edx
80101cf6:	83 c2 04             	add    $0x4,%edx
80101cf9:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101cfd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d00:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d04:	75 24                	jne    80101d2a <bmap+0x47>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101d06:	8b 45 08             	mov    0x8(%ebp),%eax
80101d09:	8b 00                	mov    (%eax),%eax
80101d0b:	83 ec 0c             	sub    $0xc,%esp
80101d0e:	50                   	push   %eax
80101d0f:	e8 9a f7 ff ff       	call   801014ae <balloc>
80101d14:	83 c4 10             	add    $0x10,%esp
80101d17:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d1a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d1d:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d20:	8d 4a 04             	lea    0x4(%edx),%ecx
80101d23:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d26:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101d2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d2d:	e9 cb 00 00 00       	jmp    80101dfd <bmap+0x11a>
  }
  bn -= NDIRECT;
80101d32:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101d36:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101d3a:	0f 87 b0 00 00 00    	ja     80101df0 <bmap+0x10d>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101d40:	8b 45 08             	mov    0x8(%ebp),%eax
80101d43:	8b 40 4c             	mov    0x4c(%eax),%eax
80101d46:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d49:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d4d:	75 1d                	jne    80101d6c <bmap+0x89>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101d4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d52:	8b 00                	mov    (%eax),%eax
80101d54:	83 ec 0c             	sub    $0xc,%esp
80101d57:	50                   	push   %eax
80101d58:	e8 51 f7 ff ff       	call   801014ae <balloc>
80101d5d:	83 c4 10             	add    $0x10,%esp
80101d60:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d63:	8b 45 08             	mov    0x8(%ebp),%eax
80101d66:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d69:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101d6c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d6f:	8b 00                	mov    (%eax),%eax
80101d71:	83 ec 08             	sub    $0x8,%esp
80101d74:	ff 75 f4             	pushl  -0xc(%ebp)
80101d77:	50                   	push   %eax
80101d78:	e8 39 e4 ff ff       	call   801001b6 <bread>
80101d7d:	83 c4 10             	add    $0x10,%esp
80101d80:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101d83:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d86:	83 c0 18             	add    $0x18,%eax
80101d89:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101d8c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d8f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d96:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d99:	01 d0                	add    %edx,%eax
80101d9b:	8b 00                	mov    (%eax),%eax
80101d9d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101da0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101da4:	75 37                	jne    80101ddd <bmap+0xfa>
      a[bn] = addr = balloc(ip->dev);
80101da6:	8b 45 0c             	mov    0xc(%ebp),%eax
80101da9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101db0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101db3:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101db6:	8b 45 08             	mov    0x8(%ebp),%eax
80101db9:	8b 00                	mov    (%eax),%eax
80101dbb:	83 ec 0c             	sub    $0xc,%esp
80101dbe:	50                   	push   %eax
80101dbf:	e8 ea f6 ff ff       	call   801014ae <balloc>
80101dc4:	83 c4 10             	add    $0x10,%esp
80101dc7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dcd:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101dcf:	83 ec 0c             	sub    $0xc,%esp
80101dd2:	ff 75 f0             	pushl  -0x10(%ebp)
80101dd5:	e8 3f 1a 00 00       	call   80103819 <log_write>
80101dda:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101ddd:	83 ec 0c             	sub    $0xc,%esp
80101de0:	ff 75 f0             	pushl  -0x10(%ebp)
80101de3:	e8 46 e4 ff ff       	call   8010022e <brelse>
80101de8:	83 c4 10             	add    $0x10,%esp
    return addr;
80101deb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dee:	eb 0d                	jmp    80101dfd <bmap+0x11a>
  }

  panic("bmap: out of range");
80101df0:	83 ec 0c             	sub    $0xc,%esp
80101df3:	68 00 97 10 80       	push   $0x80109700
80101df8:	e8 69 e7 ff ff       	call   80100566 <panic>
}
80101dfd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101e00:	c9                   	leave  
80101e01:	c3                   	ret    

80101e02 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101e02:	55                   	push   %ebp
80101e03:	89 e5                	mov    %esp,%ebp
80101e05:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e08:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e0f:	eb 45                	jmp    80101e56 <itrunc+0x54>
    if(ip->addrs[i]){
80101e11:	8b 45 08             	mov    0x8(%ebp),%eax
80101e14:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e17:	83 c2 04             	add    $0x4,%edx
80101e1a:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e1e:	85 c0                	test   %eax,%eax
80101e20:	74 30                	je     80101e52 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101e22:	8b 45 08             	mov    0x8(%ebp),%eax
80101e25:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e28:	83 c2 04             	add    $0x4,%edx
80101e2b:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e2f:	8b 55 08             	mov    0x8(%ebp),%edx
80101e32:	8b 12                	mov    (%edx),%edx
80101e34:	83 ec 08             	sub    $0x8,%esp
80101e37:	50                   	push   %eax
80101e38:	52                   	push   %edx
80101e39:	e8 bc f7 ff ff       	call   801015fa <bfree>
80101e3e:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101e41:	8b 45 08             	mov    0x8(%ebp),%eax
80101e44:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e47:	83 c2 04             	add    $0x4,%edx
80101e4a:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101e51:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e52:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101e56:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101e5a:	7e b5                	jle    80101e11 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101e5c:	8b 45 08             	mov    0x8(%ebp),%eax
80101e5f:	8b 40 4c             	mov    0x4c(%eax),%eax
80101e62:	85 c0                	test   %eax,%eax
80101e64:	0f 84 a1 00 00 00    	je     80101f0b <itrunc+0x109>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101e6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6d:	8b 50 4c             	mov    0x4c(%eax),%edx
80101e70:	8b 45 08             	mov    0x8(%ebp),%eax
80101e73:	8b 00                	mov    (%eax),%eax
80101e75:	83 ec 08             	sub    $0x8,%esp
80101e78:	52                   	push   %edx
80101e79:	50                   	push   %eax
80101e7a:	e8 37 e3 ff ff       	call   801001b6 <bread>
80101e7f:	83 c4 10             	add    $0x10,%esp
80101e82:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101e85:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e88:	83 c0 18             	add    $0x18,%eax
80101e8b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101e8e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101e95:	eb 3c                	jmp    80101ed3 <itrunc+0xd1>
      if(a[j])
80101e97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e9a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ea1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101ea4:	01 d0                	add    %edx,%eax
80101ea6:	8b 00                	mov    (%eax),%eax
80101ea8:	85 c0                	test   %eax,%eax
80101eaa:	74 23                	je     80101ecf <itrunc+0xcd>
        bfree(ip->dev, a[j]);
80101eac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101eaf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101eb6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101eb9:	01 d0                	add    %edx,%eax
80101ebb:	8b 00                	mov    (%eax),%eax
80101ebd:	8b 55 08             	mov    0x8(%ebp),%edx
80101ec0:	8b 12                	mov    (%edx),%edx
80101ec2:	83 ec 08             	sub    $0x8,%esp
80101ec5:	50                   	push   %eax
80101ec6:	52                   	push   %edx
80101ec7:	e8 2e f7 ff ff       	call   801015fa <bfree>
80101ecc:	83 c4 10             	add    $0x10,%esp
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101ecf:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101ed3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ed6:	83 f8 7f             	cmp    $0x7f,%eax
80101ed9:	76 bc                	jbe    80101e97 <itrunc+0x95>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101edb:	83 ec 0c             	sub    $0xc,%esp
80101ede:	ff 75 ec             	pushl  -0x14(%ebp)
80101ee1:	e8 48 e3 ff ff       	call   8010022e <brelse>
80101ee6:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101ee9:	8b 45 08             	mov    0x8(%ebp),%eax
80101eec:	8b 40 4c             	mov    0x4c(%eax),%eax
80101eef:	8b 55 08             	mov    0x8(%ebp),%edx
80101ef2:	8b 12                	mov    (%edx),%edx
80101ef4:	83 ec 08             	sub    $0x8,%esp
80101ef7:	50                   	push   %eax
80101ef8:	52                   	push   %edx
80101ef9:	e8 fc f6 ff ff       	call   801015fa <bfree>
80101efe:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101f01:	8b 45 08             	mov    0x8(%ebp),%eax
80101f04:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101f0b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0e:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101f15:	83 ec 0c             	sub    $0xc,%esp
80101f18:	ff 75 08             	pushl  0x8(%ebp)
80101f1b:	e8 04 f9 ff ff       	call   80101824 <iupdate>
80101f20:	83 c4 10             	add    $0x10,%esp
}
80101f23:	90                   	nop
80101f24:	c9                   	leave  
80101f25:	c3                   	ret    

80101f26 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101f26:	55                   	push   %ebp
80101f27:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101f29:	8b 45 08             	mov    0x8(%ebp),%eax
80101f2c:	8b 00                	mov    (%eax),%eax
80101f2e:	89 c2                	mov    %eax,%edx
80101f30:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f33:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101f36:	8b 45 08             	mov    0x8(%ebp),%eax
80101f39:	8b 50 04             	mov    0x4(%eax),%edx
80101f3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f3f:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101f42:	8b 45 08             	mov    0x8(%ebp),%eax
80101f45:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101f49:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f4c:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101f4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f52:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101f56:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f59:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101f5d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f60:	8b 50 18             	mov    0x18(%eax),%edx
80101f63:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f66:	89 50 10             	mov    %edx,0x10(%eax)
}
80101f69:	90                   	nop
80101f6a:	5d                   	pop    %ebp
80101f6b:	c3                   	ret    

80101f6c <readi>:

// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101f6c:	55                   	push   %ebp
80101f6d:	89 e5                	mov    %esp,%ebp
80101f6f:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101f72:	8b 45 08             	mov    0x8(%ebp),%eax
80101f75:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101f79:	66 83 f8 03          	cmp    $0x3,%ax
80101f7d:	75 5c                	jne    80101fdb <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101f7f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f82:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f86:	66 85 c0             	test   %ax,%ax
80101f89:	78 20                	js     80101fab <readi+0x3f>
80101f8b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f8e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f92:	66 83 f8 09          	cmp    $0x9,%ax
80101f96:	7f 13                	jg     80101fab <readi+0x3f>
80101f98:	8b 45 08             	mov    0x8(%ebp),%eax
80101f9b:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f9f:	98                   	cwtl   
80101fa0:	8b 04 c5 e0 21 11 80 	mov    -0x7feede20(,%eax,8),%eax
80101fa7:	85 c0                	test   %eax,%eax
80101fa9:	75 0a                	jne    80101fb5 <readi+0x49>
      return -1;
80101fab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fb0:	e9 0c 01 00 00       	jmp    801020c1 <readi+0x155>
    return devsw[ip->major].read(ip, dst, n);
80101fb5:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb8:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101fbc:	98                   	cwtl   
80101fbd:	8b 04 c5 e0 21 11 80 	mov    -0x7feede20(,%eax,8),%eax
80101fc4:	8b 55 14             	mov    0x14(%ebp),%edx
80101fc7:	83 ec 04             	sub    $0x4,%esp
80101fca:	52                   	push   %edx
80101fcb:	ff 75 0c             	pushl  0xc(%ebp)
80101fce:	ff 75 08             	pushl  0x8(%ebp)
80101fd1:	ff d0                	call   *%eax
80101fd3:	83 c4 10             	add    $0x10,%esp
80101fd6:	e9 e6 00 00 00       	jmp    801020c1 <readi+0x155>
  }

  if(off > ip->size || off + n < off)
80101fdb:	8b 45 08             	mov    0x8(%ebp),%eax
80101fde:	8b 40 18             	mov    0x18(%eax),%eax
80101fe1:	3b 45 10             	cmp    0x10(%ebp),%eax
80101fe4:	72 0d                	jb     80101ff3 <readi+0x87>
80101fe6:	8b 55 10             	mov    0x10(%ebp),%edx
80101fe9:	8b 45 14             	mov    0x14(%ebp),%eax
80101fec:	01 d0                	add    %edx,%eax
80101fee:	3b 45 10             	cmp    0x10(%ebp),%eax
80101ff1:	73 0a                	jae    80101ffd <readi+0x91>
    return -1;
80101ff3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101ff8:	e9 c4 00 00 00       	jmp    801020c1 <readi+0x155>
  if(off + n > ip->size)
80101ffd:	8b 55 10             	mov    0x10(%ebp),%edx
80102000:	8b 45 14             	mov    0x14(%ebp),%eax
80102003:	01 c2                	add    %eax,%edx
80102005:	8b 45 08             	mov    0x8(%ebp),%eax
80102008:	8b 40 18             	mov    0x18(%eax),%eax
8010200b:	39 c2                	cmp    %eax,%edx
8010200d:	76 0c                	jbe    8010201b <readi+0xaf>
    n = ip->size - off;
8010200f:	8b 45 08             	mov    0x8(%ebp),%eax
80102012:	8b 40 18             	mov    0x18(%eax),%eax
80102015:	2b 45 10             	sub    0x10(%ebp),%eax
80102018:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010201b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102022:	e9 8b 00 00 00       	jmp    801020b2 <readi+0x146>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102027:	8b 45 10             	mov    0x10(%ebp),%eax
8010202a:	c1 e8 09             	shr    $0x9,%eax
8010202d:	83 ec 08             	sub    $0x8,%esp
80102030:	50                   	push   %eax
80102031:	ff 75 08             	pushl  0x8(%ebp)
80102034:	e8 aa fc ff ff       	call   80101ce3 <bmap>
80102039:	83 c4 10             	add    $0x10,%esp
8010203c:	89 c2                	mov    %eax,%edx
8010203e:	8b 45 08             	mov    0x8(%ebp),%eax
80102041:	8b 00                	mov    (%eax),%eax
80102043:	83 ec 08             	sub    $0x8,%esp
80102046:	52                   	push   %edx
80102047:	50                   	push   %eax
80102048:	e8 69 e1 ff ff       	call   801001b6 <bread>
8010204d:	83 c4 10             	add    $0x10,%esp
80102050:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102053:	8b 45 10             	mov    0x10(%ebp),%eax
80102056:	25 ff 01 00 00       	and    $0x1ff,%eax
8010205b:	ba 00 02 00 00       	mov    $0x200,%edx
80102060:	29 c2                	sub    %eax,%edx
80102062:	8b 45 14             	mov    0x14(%ebp),%eax
80102065:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102068:	39 c2                	cmp    %eax,%edx
8010206a:	0f 46 c2             	cmovbe %edx,%eax
8010206d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80102070:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102073:	8d 50 18             	lea    0x18(%eax),%edx
80102076:	8b 45 10             	mov    0x10(%ebp),%eax
80102079:	25 ff 01 00 00       	and    $0x1ff,%eax
8010207e:	01 d0                	add    %edx,%eax
80102080:	83 ec 04             	sub    $0x4,%esp
80102083:	ff 75 ec             	pushl  -0x14(%ebp)
80102086:	50                   	push   %eax
80102087:	ff 75 0c             	pushl  0xc(%ebp)
8010208a:	e8 97 41 00 00       	call   80106226 <memmove>
8010208f:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102092:	83 ec 0c             	sub    $0xc,%esp
80102095:	ff 75 f0             	pushl  -0x10(%ebp)
80102098:	e8 91 e1 ff ff       	call   8010022e <brelse>
8010209d:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801020a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020a3:	01 45 f4             	add    %eax,-0xc(%ebp)
801020a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020a9:	01 45 10             	add    %eax,0x10(%ebp)
801020ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020af:	01 45 0c             	add    %eax,0xc(%ebp)
801020b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020b5:	3b 45 14             	cmp    0x14(%ebp),%eax
801020b8:	0f 82 69 ff ff ff    	jb     80102027 <readi+0xbb>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
801020be:	8b 45 14             	mov    0x14(%ebp),%eax
}
801020c1:	c9                   	leave  
801020c2:	c3                   	ret    

801020c3 <writei>:

// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801020c3:	55                   	push   %ebp
801020c4:	89 e5                	mov    %esp,%ebp
801020c6:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801020c9:	8b 45 08             	mov    0x8(%ebp),%eax
801020cc:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801020d0:	66 83 f8 03          	cmp    $0x3,%ax
801020d4:	75 5c                	jne    80102132 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801020d6:	8b 45 08             	mov    0x8(%ebp),%eax
801020d9:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020dd:	66 85 c0             	test   %ax,%ax
801020e0:	78 20                	js     80102102 <writei+0x3f>
801020e2:	8b 45 08             	mov    0x8(%ebp),%eax
801020e5:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020e9:	66 83 f8 09          	cmp    $0x9,%ax
801020ed:	7f 13                	jg     80102102 <writei+0x3f>
801020ef:	8b 45 08             	mov    0x8(%ebp),%eax
801020f2:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020f6:	98                   	cwtl   
801020f7:	8b 04 c5 e4 21 11 80 	mov    -0x7feede1c(,%eax,8),%eax
801020fe:	85 c0                	test   %eax,%eax
80102100:	75 0a                	jne    8010210c <writei+0x49>
      return -1;
80102102:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102107:	e9 3d 01 00 00       	jmp    80102249 <writei+0x186>
    return devsw[ip->major].write(ip, src, n);
8010210c:	8b 45 08             	mov    0x8(%ebp),%eax
8010210f:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102113:	98                   	cwtl   
80102114:	8b 04 c5 e4 21 11 80 	mov    -0x7feede1c(,%eax,8),%eax
8010211b:	8b 55 14             	mov    0x14(%ebp),%edx
8010211e:	83 ec 04             	sub    $0x4,%esp
80102121:	52                   	push   %edx
80102122:	ff 75 0c             	pushl  0xc(%ebp)
80102125:	ff 75 08             	pushl  0x8(%ebp)
80102128:	ff d0                	call   *%eax
8010212a:	83 c4 10             	add    $0x10,%esp
8010212d:	e9 17 01 00 00       	jmp    80102249 <writei+0x186>
  }

  if(off > ip->size || off + n < off)
80102132:	8b 45 08             	mov    0x8(%ebp),%eax
80102135:	8b 40 18             	mov    0x18(%eax),%eax
80102138:	3b 45 10             	cmp    0x10(%ebp),%eax
8010213b:	72 0d                	jb     8010214a <writei+0x87>
8010213d:	8b 55 10             	mov    0x10(%ebp),%edx
80102140:	8b 45 14             	mov    0x14(%ebp),%eax
80102143:	01 d0                	add    %edx,%eax
80102145:	3b 45 10             	cmp    0x10(%ebp),%eax
80102148:	73 0a                	jae    80102154 <writei+0x91>
    return -1;
8010214a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010214f:	e9 f5 00 00 00       	jmp    80102249 <writei+0x186>
  if(off + n > MAXFILE*BSIZE)
80102154:	8b 55 10             	mov    0x10(%ebp),%edx
80102157:	8b 45 14             	mov    0x14(%ebp),%eax
8010215a:	01 d0                	add    %edx,%eax
8010215c:	3d 00 18 01 00       	cmp    $0x11800,%eax
80102161:	76 0a                	jbe    8010216d <writei+0xaa>
    return -1;
80102163:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102168:	e9 dc 00 00 00       	jmp    80102249 <writei+0x186>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010216d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102174:	e9 99 00 00 00       	jmp    80102212 <writei+0x14f>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102179:	8b 45 10             	mov    0x10(%ebp),%eax
8010217c:	c1 e8 09             	shr    $0x9,%eax
8010217f:	83 ec 08             	sub    $0x8,%esp
80102182:	50                   	push   %eax
80102183:	ff 75 08             	pushl  0x8(%ebp)
80102186:	e8 58 fb ff ff       	call   80101ce3 <bmap>
8010218b:	83 c4 10             	add    $0x10,%esp
8010218e:	89 c2                	mov    %eax,%edx
80102190:	8b 45 08             	mov    0x8(%ebp),%eax
80102193:	8b 00                	mov    (%eax),%eax
80102195:	83 ec 08             	sub    $0x8,%esp
80102198:	52                   	push   %edx
80102199:	50                   	push   %eax
8010219a:	e8 17 e0 ff ff       	call   801001b6 <bread>
8010219f:	83 c4 10             	add    $0x10,%esp
801021a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801021a5:	8b 45 10             	mov    0x10(%ebp),%eax
801021a8:	25 ff 01 00 00       	and    $0x1ff,%eax
801021ad:	ba 00 02 00 00       	mov    $0x200,%edx
801021b2:	29 c2                	sub    %eax,%edx
801021b4:	8b 45 14             	mov    0x14(%ebp),%eax
801021b7:	2b 45 f4             	sub    -0xc(%ebp),%eax
801021ba:	39 c2                	cmp    %eax,%edx
801021bc:	0f 46 c2             	cmovbe %edx,%eax
801021bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801021c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021c5:	8d 50 18             	lea    0x18(%eax),%edx
801021c8:	8b 45 10             	mov    0x10(%ebp),%eax
801021cb:	25 ff 01 00 00       	and    $0x1ff,%eax
801021d0:	01 d0                	add    %edx,%eax
801021d2:	83 ec 04             	sub    $0x4,%esp
801021d5:	ff 75 ec             	pushl  -0x14(%ebp)
801021d8:	ff 75 0c             	pushl  0xc(%ebp)
801021db:	50                   	push   %eax
801021dc:	e8 45 40 00 00       	call   80106226 <memmove>
801021e1:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
801021e4:	83 ec 0c             	sub    $0xc,%esp
801021e7:	ff 75 f0             	pushl  -0x10(%ebp)
801021ea:	e8 2a 16 00 00       	call   80103819 <log_write>
801021ef:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801021f2:	83 ec 0c             	sub    $0xc,%esp
801021f5:	ff 75 f0             	pushl  -0x10(%ebp)
801021f8:	e8 31 e0 ff ff       	call   8010022e <brelse>
801021fd:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102200:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102203:	01 45 f4             	add    %eax,-0xc(%ebp)
80102206:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102209:	01 45 10             	add    %eax,0x10(%ebp)
8010220c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010220f:	01 45 0c             	add    %eax,0xc(%ebp)
80102212:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102215:	3b 45 14             	cmp    0x14(%ebp),%eax
80102218:	0f 82 5b ff ff ff    	jb     80102179 <writei+0xb6>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
8010221e:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102222:	74 22                	je     80102246 <writei+0x183>
80102224:	8b 45 08             	mov    0x8(%ebp),%eax
80102227:	8b 40 18             	mov    0x18(%eax),%eax
8010222a:	3b 45 10             	cmp    0x10(%ebp),%eax
8010222d:	73 17                	jae    80102246 <writei+0x183>
    ip->size = off;
8010222f:	8b 45 08             	mov    0x8(%ebp),%eax
80102232:	8b 55 10             	mov    0x10(%ebp),%edx
80102235:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
80102238:	83 ec 0c             	sub    $0xc,%esp
8010223b:	ff 75 08             	pushl  0x8(%ebp)
8010223e:	e8 e1 f5 ff ff       	call   80101824 <iupdate>
80102243:	83 c4 10             	add    $0x10,%esp
  }
  return n;
80102246:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102249:	c9                   	leave  
8010224a:	c3                   	ret    

8010224b <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
8010224b:	55                   	push   %ebp
8010224c:	89 e5                	mov    %esp,%ebp
8010224e:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
80102251:	83 ec 04             	sub    $0x4,%esp
80102254:	6a 0e                	push   $0xe
80102256:	ff 75 0c             	pushl  0xc(%ebp)
80102259:	ff 75 08             	pushl  0x8(%ebp)
8010225c:	e8 5b 40 00 00       	call   801062bc <strncmp>
80102261:	83 c4 10             	add    $0x10,%esp
}
80102264:	c9                   	leave  
80102265:	c3                   	ret    

80102266 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102266:	55                   	push   %ebp
80102267:	89 e5                	mov    %esp,%ebp
80102269:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
8010226c:	8b 45 08             	mov    0x8(%ebp),%eax
8010226f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102273:	66 83 f8 01          	cmp    $0x1,%ax
80102277:	74 0d                	je     80102286 <dirlookup+0x20>
    panic("dirlookup not DIR");
80102279:	83 ec 0c             	sub    $0xc,%esp
8010227c:	68 13 97 10 80       	push   $0x80109713
80102281:	e8 e0 e2 ff ff       	call   80100566 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102286:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010228d:	eb 7b                	jmp    8010230a <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010228f:	6a 10                	push   $0x10
80102291:	ff 75 f4             	pushl  -0xc(%ebp)
80102294:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102297:	50                   	push   %eax
80102298:	ff 75 08             	pushl  0x8(%ebp)
8010229b:	e8 cc fc ff ff       	call   80101f6c <readi>
801022a0:	83 c4 10             	add    $0x10,%esp
801022a3:	83 f8 10             	cmp    $0x10,%eax
801022a6:	74 0d                	je     801022b5 <dirlookup+0x4f>
      panic("dirlink read");
801022a8:	83 ec 0c             	sub    $0xc,%esp
801022ab:	68 25 97 10 80       	push   $0x80109725
801022b0:	e8 b1 e2 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
801022b5:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022b9:	66 85 c0             	test   %ax,%ax
801022bc:	74 47                	je     80102305 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
801022be:	83 ec 08             	sub    $0x8,%esp
801022c1:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022c4:	83 c0 02             	add    $0x2,%eax
801022c7:	50                   	push   %eax
801022c8:	ff 75 0c             	pushl  0xc(%ebp)
801022cb:	e8 7b ff ff ff       	call   8010224b <namecmp>
801022d0:	83 c4 10             	add    $0x10,%esp
801022d3:	85 c0                	test   %eax,%eax
801022d5:	75 2f                	jne    80102306 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
801022d7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801022db:	74 08                	je     801022e5 <dirlookup+0x7f>
        *poff = off;
801022dd:	8b 45 10             	mov    0x10(%ebp),%eax
801022e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801022e3:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
801022e5:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022e9:	0f b7 c0             	movzwl %ax,%eax
801022ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
801022ef:	8b 45 08             	mov    0x8(%ebp),%eax
801022f2:	8b 00                	mov    (%eax),%eax
801022f4:	83 ec 08             	sub    $0x8,%esp
801022f7:	ff 75 f0             	pushl  -0x10(%ebp)
801022fa:	50                   	push   %eax
801022fb:	e8 e5 f5 ff ff       	call   801018e5 <iget>
80102300:	83 c4 10             	add    $0x10,%esp
80102303:	eb 19                	jmp    8010231e <dirlookup+0xb8>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
80102305:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102306:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010230a:	8b 45 08             	mov    0x8(%ebp),%eax
8010230d:	8b 40 18             	mov    0x18(%eax),%eax
80102310:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102313:	0f 87 76 ff ff ff    	ja     8010228f <dirlookup+0x29>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102319:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010231e:	c9                   	leave  
8010231f:	c3                   	ret    

80102320 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102320:	55                   	push   %ebp
80102321:	89 e5                	mov    %esp,%ebp
80102323:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102326:	83 ec 04             	sub    $0x4,%esp
80102329:	6a 00                	push   $0x0
8010232b:	ff 75 0c             	pushl  0xc(%ebp)
8010232e:	ff 75 08             	pushl  0x8(%ebp)
80102331:	e8 30 ff ff ff       	call   80102266 <dirlookup>
80102336:	83 c4 10             	add    $0x10,%esp
80102339:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010233c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102340:	74 18                	je     8010235a <dirlink+0x3a>
    iput(ip);
80102342:	83 ec 0c             	sub    $0xc,%esp
80102345:	ff 75 f0             	pushl  -0x10(%ebp)
80102348:	e8 81 f8 ff ff       	call   80101bce <iput>
8010234d:	83 c4 10             	add    $0x10,%esp
    return -1;
80102350:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102355:	e9 9c 00 00 00       	jmp    801023f6 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
8010235a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102361:	eb 39                	jmp    8010239c <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102363:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102366:	6a 10                	push   $0x10
80102368:	50                   	push   %eax
80102369:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010236c:	50                   	push   %eax
8010236d:	ff 75 08             	pushl  0x8(%ebp)
80102370:	e8 f7 fb ff ff       	call   80101f6c <readi>
80102375:	83 c4 10             	add    $0x10,%esp
80102378:	83 f8 10             	cmp    $0x10,%eax
8010237b:	74 0d                	je     8010238a <dirlink+0x6a>
      panic("dirlink read");
8010237d:	83 ec 0c             	sub    $0xc,%esp
80102380:	68 25 97 10 80       	push   $0x80109725
80102385:	e8 dc e1 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
8010238a:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010238e:	66 85 c0             	test   %ax,%ax
80102391:	74 18                	je     801023ab <dirlink+0x8b>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102393:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102396:	83 c0 10             	add    $0x10,%eax
80102399:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010239c:	8b 45 08             	mov    0x8(%ebp),%eax
8010239f:	8b 50 18             	mov    0x18(%eax),%edx
801023a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023a5:	39 c2                	cmp    %eax,%edx
801023a7:	77 ba                	ja     80102363 <dirlink+0x43>
801023a9:	eb 01                	jmp    801023ac <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
801023ab:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801023ac:	83 ec 04             	sub    $0x4,%esp
801023af:	6a 0e                	push   $0xe
801023b1:	ff 75 0c             	pushl  0xc(%ebp)
801023b4:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023b7:	83 c0 02             	add    $0x2,%eax
801023ba:	50                   	push   %eax
801023bb:	e8 52 3f 00 00       	call   80106312 <strncpy>
801023c0:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
801023c3:	8b 45 10             	mov    0x10(%ebp),%eax
801023c6:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801023ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023cd:	6a 10                	push   $0x10
801023cf:	50                   	push   %eax
801023d0:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023d3:	50                   	push   %eax
801023d4:	ff 75 08             	pushl  0x8(%ebp)
801023d7:	e8 e7 fc ff ff       	call   801020c3 <writei>
801023dc:	83 c4 10             	add    $0x10,%esp
801023df:	83 f8 10             	cmp    $0x10,%eax
801023e2:	74 0d                	je     801023f1 <dirlink+0xd1>
    panic("dirlink");
801023e4:	83 ec 0c             	sub    $0xc,%esp
801023e7:	68 32 97 10 80       	push   $0x80109732
801023ec:	e8 75 e1 ff ff       	call   80100566 <panic>
  
  return 0;
801023f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801023f6:	c9                   	leave  
801023f7:	c3                   	ret    

801023f8 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
801023f8:	55                   	push   %ebp
801023f9:	89 e5                	mov    %esp,%ebp
801023fb:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
801023fe:	eb 04                	jmp    80102404 <skipelem+0xc>
    path++;
80102400:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102404:	8b 45 08             	mov    0x8(%ebp),%eax
80102407:	0f b6 00             	movzbl (%eax),%eax
8010240a:	3c 2f                	cmp    $0x2f,%al
8010240c:	74 f2                	je     80102400 <skipelem+0x8>
    path++;
  if(*path == 0)
8010240e:	8b 45 08             	mov    0x8(%ebp),%eax
80102411:	0f b6 00             	movzbl (%eax),%eax
80102414:	84 c0                	test   %al,%al
80102416:	75 07                	jne    8010241f <skipelem+0x27>
    return 0;
80102418:	b8 00 00 00 00       	mov    $0x0,%eax
8010241d:	eb 7b                	jmp    8010249a <skipelem+0xa2>
  s = path;
8010241f:	8b 45 08             	mov    0x8(%ebp),%eax
80102422:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102425:	eb 04                	jmp    8010242b <skipelem+0x33>
    path++;
80102427:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
8010242b:	8b 45 08             	mov    0x8(%ebp),%eax
8010242e:	0f b6 00             	movzbl (%eax),%eax
80102431:	3c 2f                	cmp    $0x2f,%al
80102433:	74 0a                	je     8010243f <skipelem+0x47>
80102435:	8b 45 08             	mov    0x8(%ebp),%eax
80102438:	0f b6 00             	movzbl (%eax),%eax
8010243b:	84 c0                	test   %al,%al
8010243d:	75 e8                	jne    80102427 <skipelem+0x2f>
    path++;
  len = path - s;
8010243f:	8b 55 08             	mov    0x8(%ebp),%edx
80102442:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102445:	29 c2                	sub    %eax,%edx
80102447:	89 d0                	mov    %edx,%eax
80102449:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
8010244c:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102450:	7e 15                	jle    80102467 <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
80102452:	83 ec 04             	sub    $0x4,%esp
80102455:	6a 0e                	push   $0xe
80102457:	ff 75 f4             	pushl  -0xc(%ebp)
8010245a:	ff 75 0c             	pushl  0xc(%ebp)
8010245d:	e8 c4 3d 00 00       	call   80106226 <memmove>
80102462:	83 c4 10             	add    $0x10,%esp
80102465:	eb 26                	jmp    8010248d <skipelem+0x95>
  else {
    memmove(name, s, len);
80102467:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010246a:	83 ec 04             	sub    $0x4,%esp
8010246d:	50                   	push   %eax
8010246e:	ff 75 f4             	pushl  -0xc(%ebp)
80102471:	ff 75 0c             	pushl  0xc(%ebp)
80102474:	e8 ad 3d 00 00       	call   80106226 <memmove>
80102479:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
8010247c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010247f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102482:	01 d0                	add    %edx,%eax
80102484:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102487:	eb 04                	jmp    8010248d <skipelem+0x95>
    path++;
80102489:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
8010248d:	8b 45 08             	mov    0x8(%ebp),%eax
80102490:	0f b6 00             	movzbl (%eax),%eax
80102493:	3c 2f                	cmp    $0x2f,%al
80102495:	74 f2                	je     80102489 <skipelem+0x91>
    path++;
  return path;
80102497:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010249a:	c9                   	leave  
8010249b:	c3                   	ret    

8010249c <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
8010249c:	55                   	push   %ebp
8010249d:	89 e5                	mov    %esp,%ebp
8010249f:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
801024a2:	8b 45 08             	mov    0x8(%ebp),%eax
801024a5:	0f b6 00             	movzbl (%eax),%eax
801024a8:	3c 2f                	cmp    $0x2f,%al
801024aa:	75 17                	jne    801024c3 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
801024ac:	83 ec 08             	sub    $0x8,%esp
801024af:	6a 01                	push   $0x1
801024b1:	6a 01                	push   $0x1
801024b3:	e8 2d f4 ff ff       	call   801018e5 <iget>
801024b8:	83 c4 10             	add    $0x10,%esp
801024bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801024be:	e9 bb 00 00 00       	jmp    8010257e <namex+0xe2>
  else
    ip = idup(proc->cwd);
801024c3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801024c9:	8b 40 68             	mov    0x68(%eax),%eax
801024cc:	83 ec 0c             	sub    $0xc,%esp
801024cf:	50                   	push   %eax
801024d0:	e8 ef f4 ff ff       	call   801019c4 <idup>
801024d5:	83 c4 10             	add    $0x10,%esp
801024d8:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
801024db:	e9 9e 00 00 00       	jmp    8010257e <namex+0xe2>
    ilock(ip);
801024e0:	83 ec 0c             	sub    $0xc,%esp
801024e3:	ff 75 f4             	pushl  -0xc(%ebp)
801024e6:	e8 13 f5 ff ff       	call   801019fe <ilock>
801024eb:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
801024ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024f1:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801024f5:	66 83 f8 01          	cmp    $0x1,%ax
801024f9:	74 18                	je     80102513 <namex+0x77>
      iunlockput(ip);
801024fb:	83 ec 0c             	sub    $0xc,%esp
801024fe:	ff 75 f4             	pushl  -0xc(%ebp)
80102501:	e8 b8 f7 ff ff       	call   80101cbe <iunlockput>
80102506:	83 c4 10             	add    $0x10,%esp
      return 0;
80102509:	b8 00 00 00 00       	mov    $0x0,%eax
8010250e:	e9 a7 00 00 00       	jmp    801025ba <namex+0x11e>
    }
    if(nameiparent && *path == '\0'){
80102513:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102517:	74 20                	je     80102539 <namex+0x9d>
80102519:	8b 45 08             	mov    0x8(%ebp),%eax
8010251c:	0f b6 00             	movzbl (%eax),%eax
8010251f:	84 c0                	test   %al,%al
80102521:	75 16                	jne    80102539 <namex+0x9d>
      // Stop one level early.
      iunlock(ip);
80102523:	83 ec 0c             	sub    $0xc,%esp
80102526:	ff 75 f4             	pushl  -0xc(%ebp)
80102529:	e8 2e f6 ff ff       	call   80101b5c <iunlock>
8010252e:	83 c4 10             	add    $0x10,%esp
      return ip;
80102531:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102534:	e9 81 00 00 00       	jmp    801025ba <namex+0x11e>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102539:	83 ec 04             	sub    $0x4,%esp
8010253c:	6a 00                	push   $0x0
8010253e:	ff 75 10             	pushl  0x10(%ebp)
80102541:	ff 75 f4             	pushl  -0xc(%ebp)
80102544:	e8 1d fd ff ff       	call   80102266 <dirlookup>
80102549:	83 c4 10             	add    $0x10,%esp
8010254c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010254f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102553:	75 15                	jne    8010256a <namex+0xce>
      iunlockput(ip);
80102555:	83 ec 0c             	sub    $0xc,%esp
80102558:	ff 75 f4             	pushl  -0xc(%ebp)
8010255b:	e8 5e f7 ff ff       	call   80101cbe <iunlockput>
80102560:	83 c4 10             	add    $0x10,%esp
      return 0;
80102563:	b8 00 00 00 00       	mov    $0x0,%eax
80102568:	eb 50                	jmp    801025ba <namex+0x11e>
    }
    iunlockput(ip);
8010256a:	83 ec 0c             	sub    $0xc,%esp
8010256d:	ff 75 f4             	pushl  -0xc(%ebp)
80102570:	e8 49 f7 ff ff       	call   80101cbe <iunlockput>
80102575:	83 c4 10             	add    $0x10,%esp
    ip = next;
80102578:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010257b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
8010257e:	83 ec 08             	sub    $0x8,%esp
80102581:	ff 75 10             	pushl  0x10(%ebp)
80102584:	ff 75 08             	pushl  0x8(%ebp)
80102587:	e8 6c fe ff ff       	call   801023f8 <skipelem>
8010258c:	83 c4 10             	add    $0x10,%esp
8010258f:	89 45 08             	mov    %eax,0x8(%ebp)
80102592:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102596:	0f 85 44 ff ff ff    	jne    801024e0 <namex+0x44>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
8010259c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801025a0:	74 15                	je     801025b7 <namex+0x11b>
    iput(ip);
801025a2:	83 ec 0c             	sub    $0xc,%esp
801025a5:	ff 75 f4             	pushl  -0xc(%ebp)
801025a8:	e8 21 f6 ff ff       	call   80101bce <iput>
801025ad:	83 c4 10             	add    $0x10,%esp
    return 0;
801025b0:	b8 00 00 00 00       	mov    $0x0,%eax
801025b5:	eb 03                	jmp    801025ba <namex+0x11e>
  }
  return ip;
801025b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801025ba:	c9                   	leave  
801025bb:	c3                   	ret    

801025bc <namei>:

struct inode*
namei(char *path)
{
801025bc:	55                   	push   %ebp
801025bd:	89 e5                	mov    %esp,%ebp
801025bf:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801025c2:	83 ec 04             	sub    $0x4,%esp
801025c5:	8d 45 ea             	lea    -0x16(%ebp),%eax
801025c8:	50                   	push   %eax
801025c9:	6a 00                	push   $0x0
801025cb:	ff 75 08             	pushl  0x8(%ebp)
801025ce:	e8 c9 fe ff ff       	call   8010249c <namex>
801025d3:	83 c4 10             	add    $0x10,%esp
}
801025d6:	c9                   	leave  
801025d7:	c3                   	ret    

801025d8 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801025d8:	55                   	push   %ebp
801025d9:	89 e5                	mov    %esp,%ebp
801025db:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
801025de:	83 ec 04             	sub    $0x4,%esp
801025e1:	ff 75 0c             	pushl  0xc(%ebp)
801025e4:	6a 01                	push   $0x1
801025e6:	ff 75 08             	pushl  0x8(%ebp)
801025e9:	e8 ae fe ff ff       	call   8010249c <namex>
801025ee:	83 c4 10             	add    $0x10,%esp
}
801025f1:	c9                   	leave  
801025f2:	c3                   	ret    

801025f3 <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
801025f3:	55                   	push   %ebp
801025f4:	89 e5                	mov    %esp,%ebp
801025f6:	83 ec 14             	sub    $0x14,%esp
801025f9:	8b 45 08             	mov    0x8(%ebp),%eax
801025fc:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102600:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102604:	89 c2                	mov    %eax,%edx
80102606:	ec                   	in     (%dx),%al
80102607:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010260a:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010260e:	c9                   	leave  
8010260f:	c3                   	ret    

80102610 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102610:	55                   	push   %ebp
80102611:	89 e5                	mov    %esp,%ebp
80102613:	57                   	push   %edi
80102614:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102615:	8b 55 08             	mov    0x8(%ebp),%edx
80102618:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010261b:	8b 45 10             	mov    0x10(%ebp),%eax
8010261e:	89 cb                	mov    %ecx,%ebx
80102620:	89 df                	mov    %ebx,%edi
80102622:	89 c1                	mov    %eax,%ecx
80102624:	fc                   	cld    
80102625:	f3 6d                	rep insl (%dx),%es:(%edi)
80102627:	89 c8                	mov    %ecx,%eax
80102629:	89 fb                	mov    %edi,%ebx
8010262b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010262e:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102631:	90                   	nop
80102632:	5b                   	pop    %ebx
80102633:	5f                   	pop    %edi
80102634:	5d                   	pop    %ebp
80102635:	c3                   	ret    

80102636 <outb>:

static inline void
outb(ushort port, uchar data)
{
80102636:	55                   	push   %ebp
80102637:	89 e5                	mov    %esp,%ebp
80102639:	83 ec 08             	sub    $0x8,%esp
8010263c:	8b 55 08             	mov    0x8(%ebp),%edx
8010263f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102642:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102646:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102649:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010264d:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102651:	ee                   	out    %al,(%dx)
}
80102652:	90                   	nop
80102653:	c9                   	leave  
80102654:	c3                   	ret    

80102655 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102655:	55                   	push   %ebp
80102656:	89 e5                	mov    %esp,%ebp
80102658:	56                   	push   %esi
80102659:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
8010265a:	8b 55 08             	mov    0x8(%ebp),%edx
8010265d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102660:	8b 45 10             	mov    0x10(%ebp),%eax
80102663:	89 cb                	mov    %ecx,%ebx
80102665:	89 de                	mov    %ebx,%esi
80102667:	89 c1                	mov    %eax,%ecx
80102669:	fc                   	cld    
8010266a:	f3 6f                	rep outsl %ds:(%esi),(%dx)
8010266c:	89 c8                	mov    %ecx,%eax
8010266e:	89 f3                	mov    %esi,%ebx
80102670:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102673:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102676:	90                   	nop
80102677:	5b                   	pop    %ebx
80102678:	5e                   	pop    %esi
80102679:	5d                   	pop    %ebp
8010267a:	c3                   	ret    

8010267b <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
8010267b:	55                   	push   %ebp
8010267c:	89 e5                	mov    %esp,%ebp
8010267e:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102681:	90                   	nop
80102682:	68 f7 01 00 00       	push   $0x1f7
80102687:	e8 67 ff ff ff       	call   801025f3 <inb>
8010268c:	83 c4 04             	add    $0x4,%esp
8010268f:	0f b6 c0             	movzbl %al,%eax
80102692:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102695:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102698:	25 c0 00 00 00       	and    $0xc0,%eax
8010269d:	83 f8 40             	cmp    $0x40,%eax
801026a0:	75 e0                	jne    80102682 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801026a2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026a6:	74 11                	je     801026b9 <idewait+0x3e>
801026a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801026ab:	83 e0 21             	and    $0x21,%eax
801026ae:	85 c0                	test   %eax,%eax
801026b0:	74 07                	je     801026b9 <idewait+0x3e>
    return -1;
801026b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801026b7:	eb 05                	jmp    801026be <idewait+0x43>
  return 0;
801026b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801026be:	c9                   	leave  
801026bf:	c3                   	ret    

801026c0 <ideinit>:

void
ideinit(void)
{
801026c0:	55                   	push   %ebp
801026c1:	89 e5                	mov    %esp,%ebp
801026c3:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  initlock(&idelock, "ide");
801026c6:	83 ec 08             	sub    $0x8,%esp
801026c9:	68 3a 97 10 80       	push   $0x8010973a
801026ce:	68 20 c6 10 80       	push   $0x8010c620
801026d3:	e8 0a 38 00 00       	call   80105ee2 <initlock>
801026d8:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
801026db:	83 ec 0c             	sub    $0xc,%esp
801026de:	6a 0e                	push   $0xe
801026e0:	e8 da 18 00 00       	call   80103fbf <picenable>
801026e5:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
801026e8:	a1 60 39 11 80       	mov    0x80113960,%eax
801026ed:	83 e8 01             	sub    $0x1,%eax
801026f0:	83 ec 08             	sub    $0x8,%esp
801026f3:	50                   	push   %eax
801026f4:	6a 0e                	push   $0xe
801026f6:	e8 73 04 00 00       	call   80102b6e <ioapicenable>
801026fb:	83 c4 10             	add    $0x10,%esp
  idewait(0);
801026fe:	83 ec 0c             	sub    $0xc,%esp
80102701:	6a 00                	push   $0x0
80102703:	e8 73 ff ff ff       	call   8010267b <idewait>
80102708:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
8010270b:	83 ec 08             	sub    $0x8,%esp
8010270e:	68 f0 00 00 00       	push   $0xf0
80102713:	68 f6 01 00 00       	push   $0x1f6
80102718:	e8 19 ff ff ff       	call   80102636 <outb>
8010271d:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102720:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102727:	eb 24                	jmp    8010274d <ideinit+0x8d>
    if(inb(0x1f7) != 0){
80102729:	83 ec 0c             	sub    $0xc,%esp
8010272c:	68 f7 01 00 00       	push   $0x1f7
80102731:	e8 bd fe ff ff       	call   801025f3 <inb>
80102736:	83 c4 10             	add    $0x10,%esp
80102739:	84 c0                	test   %al,%al
8010273b:	74 0c                	je     80102749 <ideinit+0x89>
      havedisk1 = 1;
8010273d:	c7 05 58 c6 10 80 01 	movl   $0x1,0x8010c658
80102744:	00 00 00 
      break;
80102747:	eb 0d                	jmp    80102756 <ideinit+0x96>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102749:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010274d:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102754:	7e d3                	jle    80102729 <ideinit+0x69>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102756:	83 ec 08             	sub    $0x8,%esp
80102759:	68 e0 00 00 00       	push   $0xe0
8010275e:	68 f6 01 00 00       	push   $0x1f6
80102763:	e8 ce fe ff ff       	call   80102636 <outb>
80102768:	83 c4 10             	add    $0x10,%esp
}
8010276b:	90                   	nop
8010276c:	c9                   	leave  
8010276d:	c3                   	ret    

8010276e <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
8010276e:	55                   	push   %ebp
8010276f:	89 e5                	mov    %esp,%ebp
80102771:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
80102774:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102778:	75 0d                	jne    80102787 <idestart+0x19>
    panic("idestart");
8010277a:	83 ec 0c             	sub    $0xc,%esp
8010277d:	68 3e 97 10 80       	push   $0x8010973e
80102782:	e8 df dd ff ff       	call   80100566 <panic>
  if(b->blockno >= FSSIZE)
80102787:	8b 45 08             	mov    0x8(%ebp),%eax
8010278a:	8b 40 08             	mov    0x8(%eax),%eax
8010278d:	3d cf 07 00 00       	cmp    $0x7cf,%eax
80102792:	76 0d                	jbe    801027a1 <idestart+0x33>
    panic("incorrect blockno");
80102794:	83 ec 0c             	sub    $0xc,%esp
80102797:	68 47 97 10 80       	push   $0x80109747
8010279c:	e8 c5 dd ff ff       	call   80100566 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
801027a1:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
801027a8:	8b 45 08             	mov    0x8(%ebp),%eax
801027ab:	8b 50 08             	mov    0x8(%eax),%edx
801027ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027b1:	0f af c2             	imul   %edx,%eax
801027b4:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
801027b7:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
801027bb:	7e 0d                	jle    801027ca <idestart+0x5c>
801027bd:	83 ec 0c             	sub    $0xc,%esp
801027c0:	68 3e 97 10 80       	push   $0x8010973e
801027c5:	e8 9c dd ff ff       	call   80100566 <panic>
  
  idewait(0);
801027ca:	83 ec 0c             	sub    $0xc,%esp
801027cd:	6a 00                	push   $0x0
801027cf:	e8 a7 fe ff ff       	call   8010267b <idewait>
801027d4:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
801027d7:	83 ec 08             	sub    $0x8,%esp
801027da:	6a 00                	push   $0x0
801027dc:	68 f6 03 00 00       	push   $0x3f6
801027e1:	e8 50 fe ff ff       	call   80102636 <outb>
801027e6:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
801027e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027ec:	0f b6 c0             	movzbl %al,%eax
801027ef:	83 ec 08             	sub    $0x8,%esp
801027f2:	50                   	push   %eax
801027f3:	68 f2 01 00 00       	push   $0x1f2
801027f8:	e8 39 fe ff ff       	call   80102636 <outb>
801027fd:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
80102800:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102803:	0f b6 c0             	movzbl %al,%eax
80102806:	83 ec 08             	sub    $0x8,%esp
80102809:	50                   	push   %eax
8010280a:	68 f3 01 00 00       	push   $0x1f3
8010280f:	e8 22 fe ff ff       	call   80102636 <outb>
80102814:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102817:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010281a:	c1 f8 08             	sar    $0x8,%eax
8010281d:	0f b6 c0             	movzbl %al,%eax
80102820:	83 ec 08             	sub    $0x8,%esp
80102823:	50                   	push   %eax
80102824:	68 f4 01 00 00       	push   $0x1f4
80102829:	e8 08 fe ff ff       	call   80102636 <outb>
8010282e:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
80102831:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102834:	c1 f8 10             	sar    $0x10,%eax
80102837:	0f b6 c0             	movzbl %al,%eax
8010283a:	83 ec 08             	sub    $0x8,%esp
8010283d:	50                   	push   %eax
8010283e:	68 f5 01 00 00       	push   $0x1f5
80102843:	e8 ee fd ff ff       	call   80102636 <outb>
80102848:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
8010284b:	8b 45 08             	mov    0x8(%ebp),%eax
8010284e:	8b 40 04             	mov    0x4(%eax),%eax
80102851:	83 e0 01             	and    $0x1,%eax
80102854:	c1 e0 04             	shl    $0x4,%eax
80102857:	89 c2                	mov    %eax,%edx
80102859:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010285c:	c1 f8 18             	sar    $0x18,%eax
8010285f:	83 e0 0f             	and    $0xf,%eax
80102862:	09 d0                	or     %edx,%eax
80102864:	83 c8 e0             	or     $0xffffffe0,%eax
80102867:	0f b6 c0             	movzbl %al,%eax
8010286a:	83 ec 08             	sub    $0x8,%esp
8010286d:	50                   	push   %eax
8010286e:	68 f6 01 00 00       	push   $0x1f6
80102873:	e8 be fd ff ff       	call   80102636 <outb>
80102878:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
8010287b:	8b 45 08             	mov    0x8(%ebp),%eax
8010287e:	8b 00                	mov    (%eax),%eax
80102880:	83 e0 04             	and    $0x4,%eax
80102883:	85 c0                	test   %eax,%eax
80102885:	74 30                	je     801028b7 <idestart+0x149>
    outb(0x1f7, IDE_CMD_WRITE);
80102887:	83 ec 08             	sub    $0x8,%esp
8010288a:	6a 30                	push   $0x30
8010288c:	68 f7 01 00 00       	push   $0x1f7
80102891:	e8 a0 fd ff ff       	call   80102636 <outb>
80102896:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
80102899:	8b 45 08             	mov    0x8(%ebp),%eax
8010289c:	83 c0 18             	add    $0x18,%eax
8010289f:	83 ec 04             	sub    $0x4,%esp
801028a2:	68 80 00 00 00       	push   $0x80
801028a7:	50                   	push   %eax
801028a8:	68 f0 01 00 00       	push   $0x1f0
801028ad:	e8 a3 fd ff ff       	call   80102655 <outsl>
801028b2:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
801028b5:	eb 12                	jmp    801028c9 <idestart+0x15b>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, IDE_CMD_WRITE);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, IDE_CMD_READ);
801028b7:	83 ec 08             	sub    $0x8,%esp
801028ba:	6a 20                	push   $0x20
801028bc:	68 f7 01 00 00       	push   $0x1f7
801028c1:	e8 70 fd ff ff       	call   80102636 <outb>
801028c6:	83 c4 10             	add    $0x10,%esp
  }
}
801028c9:	90                   	nop
801028ca:	c9                   	leave  
801028cb:	c3                   	ret    

801028cc <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801028cc:	55                   	push   %ebp
801028cd:	89 e5                	mov    %esp,%ebp
801028cf:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801028d2:	83 ec 0c             	sub    $0xc,%esp
801028d5:	68 20 c6 10 80       	push   $0x8010c620
801028da:	e8 25 36 00 00       	call   80105f04 <acquire>
801028df:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
801028e2:	a1 54 c6 10 80       	mov    0x8010c654,%eax
801028e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801028ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801028ee:	75 15                	jne    80102905 <ideintr+0x39>
    release(&idelock);
801028f0:	83 ec 0c             	sub    $0xc,%esp
801028f3:	68 20 c6 10 80       	push   $0x8010c620
801028f8:	e8 6e 36 00 00       	call   80105f6b <release>
801028fd:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
80102900:	e9 9a 00 00 00       	jmp    8010299f <ideintr+0xd3>
  }
  idequeue = b->qnext;
80102905:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102908:	8b 40 14             	mov    0x14(%eax),%eax
8010290b:	a3 54 c6 10 80       	mov    %eax,0x8010c654

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102910:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102913:	8b 00                	mov    (%eax),%eax
80102915:	83 e0 04             	and    $0x4,%eax
80102918:	85 c0                	test   %eax,%eax
8010291a:	75 2d                	jne    80102949 <ideintr+0x7d>
8010291c:	83 ec 0c             	sub    $0xc,%esp
8010291f:	6a 01                	push   $0x1
80102921:	e8 55 fd ff ff       	call   8010267b <idewait>
80102926:	83 c4 10             	add    $0x10,%esp
80102929:	85 c0                	test   %eax,%eax
8010292b:	78 1c                	js     80102949 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
8010292d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102930:	83 c0 18             	add    $0x18,%eax
80102933:	83 ec 04             	sub    $0x4,%esp
80102936:	68 80 00 00 00       	push   $0x80
8010293b:	50                   	push   %eax
8010293c:	68 f0 01 00 00       	push   $0x1f0
80102941:	e8 ca fc ff ff       	call   80102610 <insl>
80102946:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102949:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010294c:	8b 00                	mov    (%eax),%eax
8010294e:	83 c8 02             	or     $0x2,%eax
80102951:	89 c2                	mov    %eax,%edx
80102953:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102956:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102958:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010295b:	8b 00                	mov    (%eax),%eax
8010295d:	83 e0 fb             	and    $0xfffffffb,%eax
80102960:	89 c2                	mov    %eax,%edx
80102962:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102965:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102967:	83 ec 0c             	sub    $0xc,%esp
8010296a:	ff 75 f4             	pushl  -0xc(%ebp)
8010296d:	e8 e2 2b 00 00       	call   80105554 <wakeup>
80102972:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80102975:	a1 54 c6 10 80       	mov    0x8010c654,%eax
8010297a:	85 c0                	test   %eax,%eax
8010297c:	74 11                	je     8010298f <ideintr+0xc3>
    idestart(idequeue);
8010297e:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80102983:	83 ec 0c             	sub    $0xc,%esp
80102986:	50                   	push   %eax
80102987:	e8 e2 fd ff ff       	call   8010276e <idestart>
8010298c:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
8010298f:	83 ec 0c             	sub    $0xc,%esp
80102992:	68 20 c6 10 80       	push   $0x8010c620
80102997:	e8 cf 35 00 00       	call   80105f6b <release>
8010299c:	83 c4 10             	add    $0x10,%esp
}
8010299f:	c9                   	leave  
801029a0:	c3                   	ret    

801029a1 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
801029a1:	55                   	push   %ebp
801029a2:	89 e5                	mov    %esp,%ebp
801029a4:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
801029a7:	8b 45 08             	mov    0x8(%ebp),%eax
801029aa:	8b 00                	mov    (%eax),%eax
801029ac:	83 e0 01             	and    $0x1,%eax
801029af:	85 c0                	test   %eax,%eax
801029b1:	75 0d                	jne    801029c0 <iderw+0x1f>
    panic("iderw: buf not busy");
801029b3:	83 ec 0c             	sub    $0xc,%esp
801029b6:	68 59 97 10 80       	push   $0x80109759
801029bb:	e8 a6 db ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801029c0:	8b 45 08             	mov    0x8(%ebp),%eax
801029c3:	8b 00                	mov    (%eax),%eax
801029c5:	83 e0 06             	and    $0x6,%eax
801029c8:	83 f8 02             	cmp    $0x2,%eax
801029cb:	75 0d                	jne    801029da <iderw+0x39>
    panic("iderw: nothing to do");
801029cd:	83 ec 0c             	sub    $0xc,%esp
801029d0:	68 6d 97 10 80       	push   $0x8010976d
801029d5:	e8 8c db ff ff       	call   80100566 <panic>
  if(b->dev != 0 && !havedisk1)
801029da:	8b 45 08             	mov    0x8(%ebp),%eax
801029dd:	8b 40 04             	mov    0x4(%eax),%eax
801029e0:	85 c0                	test   %eax,%eax
801029e2:	74 16                	je     801029fa <iderw+0x59>
801029e4:	a1 58 c6 10 80       	mov    0x8010c658,%eax
801029e9:	85 c0                	test   %eax,%eax
801029eb:	75 0d                	jne    801029fa <iderw+0x59>
    panic("iderw: ide disk 1 not present");
801029ed:	83 ec 0c             	sub    $0xc,%esp
801029f0:	68 82 97 10 80       	push   $0x80109782
801029f5:	e8 6c db ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
801029fa:	83 ec 0c             	sub    $0xc,%esp
801029fd:	68 20 c6 10 80       	push   $0x8010c620
80102a02:	e8 fd 34 00 00       	call   80105f04 <acquire>
80102a07:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102a0a:	8b 45 08             	mov    0x8(%ebp),%eax
80102a0d:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102a14:	c7 45 f4 54 c6 10 80 	movl   $0x8010c654,-0xc(%ebp)
80102a1b:	eb 0b                	jmp    80102a28 <iderw+0x87>
80102a1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a20:	8b 00                	mov    (%eax),%eax
80102a22:	83 c0 14             	add    $0x14,%eax
80102a25:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a2b:	8b 00                	mov    (%eax),%eax
80102a2d:	85 c0                	test   %eax,%eax
80102a2f:	75 ec                	jne    80102a1d <iderw+0x7c>
    ;
  *pp = b;
80102a31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a34:	8b 55 08             	mov    0x8(%ebp),%edx
80102a37:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102a39:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80102a3e:	3b 45 08             	cmp    0x8(%ebp),%eax
80102a41:	75 23                	jne    80102a66 <iderw+0xc5>
    idestart(b);
80102a43:	83 ec 0c             	sub    $0xc,%esp
80102a46:	ff 75 08             	pushl  0x8(%ebp)
80102a49:	e8 20 fd ff ff       	call   8010276e <idestart>
80102a4e:	83 c4 10             	add    $0x10,%esp
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a51:	eb 13                	jmp    80102a66 <iderw+0xc5>
    sleep(b, &idelock);
80102a53:	83 ec 08             	sub    $0x8,%esp
80102a56:	68 20 c6 10 80       	push   $0x8010c620
80102a5b:	ff 75 08             	pushl  0x8(%ebp)
80102a5e:	e8 99 29 00 00       	call   801053fc <sleep>
80102a63:	83 c4 10             	add    $0x10,%esp
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a66:	8b 45 08             	mov    0x8(%ebp),%eax
80102a69:	8b 00                	mov    (%eax),%eax
80102a6b:	83 e0 06             	and    $0x6,%eax
80102a6e:	83 f8 02             	cmp    $0x2,%eax
80102a71:	75 e0                	jne    80102a53 <iderw+0xb2>
    sleep(b, &idelock);
  }

  release(&idelock);
80102a73:	83 ec 0c             	sub    $0xc,%esp
80102a76:	68 20 c6 10 80       	push   $0x8010c620
80102a7b:	e8 eb 34 00 00       	call   80105f6b <release>
80102a80:	83 c4 10             	add    $0x10,%esp
}
80102a83:	90                   	nop
80102a84:	c9                   	leave  
80102a85:	c3                   	ret    

80102a86 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102a86:	55                   	push   %ebp
80102a87:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a89:	a1 34 32 11 80       	mov    0x80113234,%eax
80102a8e:	8b 55 08             	mov    0x8(%ebp),%edx
80102a91:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102a93:	a1 34 32 11 80       	mov    0x80113234,%eax
80102a98:	8b 40 10             	mov    0x10(%eax),%eax
}
80102a9b:	5d                   	pop    %ebp
80102a9c:	c3                   	ret    

80102a9d <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102a9d:	55                   	push   %ebp
80102a9e:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102aa0:	a1 34 32 11 80       	mov    0x80113234,%eax
80102aa5:	8b 55 08             	mov    0x8(%ebp),%edx
80102aa8:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102aaa:	a1 34 32 11 80       	mov    0x80113234,%eax
80102aaf:	8b 55 0c             	mov    0xc(%ebp),%edx
80102ab2:	89 50 10             	mov    %edx,0x10(%eax)
}
80102ab5:	90                   	nop
80102ab6:	5d                   	pop    %ebp
80102ab7:	c3                   	ret    

80102ab8 <ioapicinit>:

void
ioapicinit(void)
{
80102ab8:	55                   	push   %ebp
80102ab9:	89 e5                	mov    %esp,%ebp
80102abb:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
80102abe:	a1 64 33 11 80       	mov    0x80113364,%eax
80102ac3:	85 c0                	test   %eax,%eax
80102ac5:	0f 84 a0 00 00 00    	je     80102b6b <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102acb:	c7 05 34 32 11 80 00 	movl   $0xfec00000,0x80113234
80102ad2:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102ad5:	6a 01                	push   $0x1
80102ad7:	e8 aa ff ff ff       	call   80102a86 <ioapicread>
80102adc:	83 c4 04             	add    $0x4,%esp
80102adf:	c1 e8 10             	shr    $0x10,%eax
80102ae2:	25 ff 00 00 00       	and    $0xff,%eax
80102ae7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102aea:	6a 00                	push   $0x0
80102aec:	e8 95 ff ff ff       	call   80102a86 <ioapicread>
80102af1:	83 c4 04             	add    $0x4,%esp
80102af4:	c1 e8 18             	shr    $0x18,%eax
80102af7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102afa:	0f b6 05 60 33 11 80 	movzbl 0x80113360,%eax
80102b01:	0f b6 c0             	movzbl %al,%eax
80102b04:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102b07:	74 10                	je     80102b19 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102b09:	83 ec 0c             	sub    $0xc,%esp
80102b0c:	68 a0 97 10 80       	push   $0x801097a0
80102b11:	e8 b0 d8 ff ff       	call   801003c6 <cprintf>
80102b16:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102b19:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102b20:	eb 3f                	jmp    80102b61 <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102b22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b25:	83 c0 20             	add    $0x20,%eax
80102b28:	0d 00 00 01 00       	or     $0x10000,%eax
80102b2d:	89 c2                	mov    %eax,%edx
80102b2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b32:	83 c0 08             	add    $0x8,%eax
80102b35:	01 c0                	add    %eax,%eax
80102b37:	83 ec 08             	sub    $0x8,%esp
80102b3a:	52                   	push   %edx
80102b3b:	50                   	push   %eax
80102b3c:	e8 5c ff ff ff       	call   80102a9d <ioapicwrite>
80102b41:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b47:	83 c0 08             	add    $0x8,%eax
80102b4a:	01 c0                	add    %eax,%eax
80102b4c:	83 c0 01             	add    $0x1,%eax
80102b4f:	83 ec 08             	sub    $0x8,%esp
80102b52:	6a 00                	push   $0x0
80102b54:	50                   	push   %eax
80102b55:	e8 43 ff ff ff       	call   80102a9d <ioapicwrite>
80102b5a:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102b5d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102b61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b64:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102b67:	7e b9                	jle    80102b22 <ioapicinit+0x6a>
80102b69:	eb 01                	jmp    80102b6c <ioapicinit+0xb4>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80102b6b:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102b6c:	c9                   	leave  
80102b6d:	c3                   	ret    

80102b6e <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102b6e:	55                   	push   %ebp
80102b6f:	89 e5                	mov    %esp,%ebp
  if(!ismp)
80102b71:	a1 64 33 11 80       	mov    0x80113364,%eax
80102b76:	85 c0                	test   %eax,%eax
80102b78:	74 39                	je     80102bb3 <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102b7a:	8b 45 08             	mov    0x8(%ebp),%eax
80102b7d:	83 c0 20             	add    $0x20,%eax
80102b80:	89 c2                	mov    %eax,%edx
80102b82:	8b 45 08             	mov    0x8(%ebp),%eax
80102b85:	83 c0 08             	add    $0x8,%eax
80102b88:	01 c0                	add    %eax,%eax
80102b8a:	52                   	push   %edx
80102b8b:	50                   	push   %eax
80102b8c:	e8 0c ff ff ff       	call   80102a9d <ioapicwrite>
80102b91:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102b94:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b97:	c1 e0 18             	shl    $0x18,%eax
80102b9a:	89 c2                	mov    %eax,%edx
80102b9c:	8b 45 08             	mov    0x8(%ebp),%eax
80102b9f:	83 c0 08             	add    $0x8,%eax
80102ba2:	01 c0                	add    %eax,%eax
80102ba4:	83 c0 01             	add    $0x1,%eax
80102ba7:	52                   	push   %edx
80102ba8:	50                   	push   %eax
80102ba9:	e8 ef fe ff ff       	call   80102a9d <ioapicwrite>
80102bae:	83 c4 08             	add    $0x8,%esp
80102bb1:	eb 01                	jmp    80102bb4 <ioapicenable+0x46>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80102bb3:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102bb4:	c9                   	leave  
80102bb5:	c3                   	ret    

80102bb6 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102bb6:	55                   	push   %ebp
80102bb7:	89 e5                	mov    %esp,%ebp
80102bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80102bbc:	05 00 00 00 80       	add    $0x80000000,%eax
80102bc1:	5d                   	pop    %ebp
80102bc2:	c3                   	ret    

80102bc3 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102bc3:	55                   	push   %ebp
80102bc4:	89 e5                	mov    %esp,%ebp
80102bc6:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102bc9:	83 ec 08             	sub    $0x8,%esp
80102bcc:	68 d2 97 10 80       	push   $0x801097d2
80102bd1:	68 40 32 11 80       	push   $0x80113240
80102bd6:	e8 07 33 00 00       	call   80105ee2 <initlock>
80102bdb:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102bde:	c7 05 74 32 11 80 00 	movl   $0x0,0x80113274
80102be5:	00 00 00 
  freerange(vstart, vend);
80102be8:	83 ec 08             	sub    $0x8,%esp
80102beb:	ff 75 0c             	pushl  0xc(%ebp)
80102bee:	ff 75 08             	pushl  0x8(%ebp)
80102bf1:	e8 2a 00 00 00       	call   80102c20 <freerange>
80102bf6:	83 c4 10             	add    $0x10,%esp
}
80102bf9:	90                   	nop
80102bfa:	c9                   	leave  
80102bfb:	c3                   	ret    

80102bfc <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102bfc:	55                   	push   %ebp
80102bfd:	89 e5                	mov    %esp,%ebp
80102bff:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102c02:	83 ec 08             	sub    $0x8,%esp
80102c05:	ff 75 0c             	pushl  0xc(%ebp)
80102c08:	ff 75 08             	pushl  0x8(%ebp)
80102c0b:	e8 10 00 00 00       	call   80102c20 <freerange>
80102c10:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102c13:	c7 05 74 32 11 80 01 	movl   $0x1,0x80113274
80102c1a:	00 00 00 
}
80102c1d:	90                   	nop
80102c1e:	c9                   	leave  
80102c1f:	c3                   	ret    

80102c20 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102c20:	55                   	push   %ebp
80102c21:	89 e5                	mov    %esp,%ebp
80102c23:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102c26:	8b 45 08             	mov    0x8(%ebp),%eax
80102c29:	05 ff 0f 00 00       	add    $0xfff,%eax
80102c2e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102c33:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102c36:	eb 15                	jmp    80102c4d <freerange+0x2d>
    kfree(p);
80102c38:	83 ec 0c             	sub    $0xc,%esp
80102c3b:	ff 75 f4             	pushl  -0xc(%ebp)
80102c3e:	e8 1a 00 00 00       	call   80102c5d <kfree>
80102c43:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102c46:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102c4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c50:	05 00 10 00 00       	add    $0x1000,%eax
80102c55:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102c58:	76 de                	jbe    80102c38 <freerange+0x18>
    kfree(p);
}
80102c5a:	90                   	nop
80102c5b:	c9                   	leave  
80102c5c:	c3                   	ret    

80102c5d <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102c5d:	55                   	push   %ebp
80102c5e:	89 e5                	mov    %esp,%ebp
80102c60:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102c63:	8b 45 08             	mov    0x8(%ebp),%eax
80102c66:	25 ff 0f 00 00       	and    $0xfff,%eax
80102c6b:	85 c0                	test   %eax,%eax
80102c6d:	75 1b                	jne    80102c8a <kfree+0x2d>
80102c6f:	81 7d 08 3c 67 11 80 	cmpl   $0x8011673c,0x8(%ebp)
80102c76:	72 12                	jb     80102c8a <kfree+0x2d>
80102c78:	ff 75 08             	pushl  0x8(%ebp)
80102c7b:	e8 36 ff ff ff       	call   80102bb6 <v2p>
80102c80:	83 c4 04             	add    $0x4,%esp
80102c83:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102c88:	76 0d                	jbe    80102c97 <kfree+0x3a>
    panic("kfree");
80102c8a:	83 ec 0c             	sub    $0xc,%esp
80102c8d:	68 d7 97 10 80       	push   $0x801097d7
80102c92:	e8 cf d8 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102c97:	83 ec 04             	sub    $0x4,%esp
80102c9a:	68 00 10 00 00       	push   $0x1000
80102c9f:	6a 01                	push   $0x1
80102ca1:	ff 75 08             	pushl  0x8(%ebp)
80102ca4:	e8 be 34 00 00       	call   80106167 <memset>
80102ca9:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102cac:	a1 74 32 11 80       	mov    0x80113274,%eax
80102cb1:	85 c0                	test   %eax,%eax
80102cb3:	74 10                	je     80102cc5 <kfree+0x68>
    acquire(&kmem.lock);
80102cb5:	83 ec 0c             	sub    $0xc,%esp
80102cb8:	68 40 32 11 80       	push   $0x80113240
80102cbd:	e8 42 32 00 00       	call   80105f04 <acquire>
80102cc2:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102cc5:	8b 45 08             	mov    0x8(%ebp),%eax
80102cc8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102ccb:	8b 15 78 32 11 80    	mov    0x80113278,%edx
80102cd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cd4:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102cd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cd9:	a3 78 32 11 80       	mov    %eax,0x80113278
  if(kmem.use_lock)
80102cde:	a1 74 32 11 80       	mov    0x80113274,%eax
80102ce3:	85 c0                	test   %eax,%eax
80102ce5:	74 10                	je     80102cf7 <kfree+0x9a>
    release(&kmem.lock);
80102ce7:	83 ec 0c             	sub    $0xc,%esp
80102cea:	68 40 32 11 80       	push   $0x80113240
80102cef:	e8 77 32 00 00       	call   80105f6b <release>
80102cf4:	83 c4 10             	add    $0x10,%esp
}
80102cf7:	90                   	nop
80102cf8:	c9                   	leave  
80102cf9:	c3                   	ret    

80102cfa <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102cfa:	55                   	push   %ebp
80102cfb:	89 e5                	mov    %esp,%ebp
80102cfd:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102d00:	a1 74 32 11 80       	mov    0x80113274,%eax
80102d05:	85 c0                	test   %eax,%eax
80102d07:	74 10                	je     80102d19 <kalloc+0x1f>
    acquire(&kmem.lock);
80102d09:	83 ec 0c             	sub    $0xc,%esp
80102d0c:	68 40 32 11 80       	push   $0x80113240
80102d11:	e8 ee 31 00 00       	call   80105f04 <acquire>
80102d16:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102d19:	a1 78 32 11 80       	mov    0x80113278,%eax
80102d1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102d21:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102d25:	74 0a                	je     80102d31 <kalloc+0x37>
    kmem.freelist = r->next;
80102d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d2a:	8b 00                	mov    (%eax),%eax
80102d2c:	a3 78 32 11 80       	mov    %eax,0x80113278
  if(kmem.use_lock)
80102d31:	a1 74 32 11 80       	mov    0x80113274,%eax
80102d36:	85 c0                	test   %eax,%eax
80102d38:	74 10                	je     80102d4a <kalloc+0x50>
    release(&kmem.lock);
80102d3a:	83 ec 0c             	sub    $0xc,%esp
80102d3d:	68 40 32 11 80       	push   $0x80113240
80102d42:	e8 24 32 00 00       	call   80105f6b <release>
80102d47:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102d4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102d4d:	c9                   	leave  
80102d4e:	c3                   	ret    

80102d4f <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80102d4f:	55                   	push   %ebp
80102d50:	89 e5                	mov    %esp,%ebp
80102d52:	83 ec 14             	sub    $0x14,%esp
80102d55:	8b 45 08             	mov    0x8(%ebp),%eax
80102d58:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d5c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102d60:	89 c2                	mov    %eax,%edx
80102d62:	ec                   	in     (%dx),%al
80102d63:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102d66:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102d6a:	c9                   	leave  
80102d6b:	c3                   	ret    

80102d6c <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102d6c:	55                   	push   %ebp
80102d6d:	89 e5                	mov    %esp,%ebp
80102d6f:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102d72:	6a 64                	push   $0x64
80102d74:	e8 d6 ff ff ff       	call   80102d4f <inb>
80102d79:	83 c4 04             	add    $0x4,%esp
80102d7c:	0f b6 c0             	movzbl %al,%eax
80102d7f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102d82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d85:	83 e0 01             	and    $0x1,%eax
80102d88:	85 c0                	test   %eax,%eax
80102d8a:	75 0a                	jne    80102d96 <kbdgetc+0x2a>
    return -1;
80102d8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d91:	e9 23 01 00 00       	jmp    80102eb9 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102d96:	6a 60                	push   $0x60
80102d98:	e8 b2 ff ff ff       	call   80102d4f <inb>
80102d9d:	83 c4 04             	add    $0x4,%esp
80102da0:	0f b6 c0             	movzbl %al,%eax
80102da3:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102da6:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102dad:	75 17                	jne    80102dc6 <kbdgetc+0x5a>
    shift |= E0ESC;
80102daf:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102db4:	83 c8 40             	or     $0x40,%eax
80102db7:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
    return 0;
80102dbc:	b8 00 00 00 00       	mov    $0x0,%eax
80102dc1:	e9 f3 00 00 00       	jmp    80102eb9 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102dc6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dc9:	25 80 00 00 00       	and    $0x80,%eax
80102dce:	85 c0                	test   %eax,%eax
80102dd0:	74 45                	je     80102e17 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102dd2:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102dd7:	83 e0 40             	and    $0x40,%eax
80102dda:	85 c0                	test   %eax,%eax
80102ddc:	75 08                	jne    80102de6 <kbdgetc+0x7a>
80102dde:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102de1:	83 e0 7f             	and    $0x7f,%eax
80102de4:	eb 03                	jmp    80102de9 <kbdgetc+0x7d>
80102de6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102de9:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102dec:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102def:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102df4:	0f b6 00             	movzbl (%eax),%eax
80102df7:	83 c8 40             	or     $0x40,%eax
80102dfa:	0f b6 c0             	movzbl %al,%eax
80102dfd:	f7 d0                	not    %eax
80102dff:	89 c2                	mov    %eax,%edx
80102e01:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102e06:	21 d0                	and    %edx,%eax
80102e08:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
    return 0;
80102e0d:	b8 00 00 00 00       	mov    $0x0,%eax
80102e12:	e9 a2 00 00 00       	jmp    80102eb9 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102e17:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102e1c:	83 e0 40             	and    $0x40,%eax
80102e1f:	85 c0                	test   %eax,%eax
80102e21:	74 14                	je     80102e37 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102e23:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102e2a:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102e2f:	83 e0 bf             	and    $0xffffffbf,%eax
80102e32:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  }

  shift |= shiftcode[data];
80102e37:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e3a:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102e3f:	0f b6 00             	movzbl (%eax),%eax
80102e42:	0f b6 d0             	movzbl %al,%edx
80102e45:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102e4a:	09 d0                	or     %edx,%eax
80102e4c:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  shift ^= togglecode[data];
80102e51:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e54:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102e59:	0f b6 00             	movzbl (%eax),%eax
80102e5c:	0f b6 d0             	movzbl %al,%edx
80102e5f:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102e64:	31 d0                	xor    %edx,%eax
80102e66:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  c = charcode[shift & (CTL | SHIFT)][data];
80102e6b:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102e70:	83 e0 03             	and    $0x3,%eax
80102e73:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80102e7a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e7d:	01 d0                	add    %edx,%eax
80102e7f:	0f b6 00             	movzbl (%eax),%eax
80102e82:	0f b6 c0             	movzbl %al,%eax
80102e85:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102e88:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102e8d:	83 e0 08             	and    $0x8,%eax
80102e90:	85 c0                	test   %eax,%eax
80102e92:	74 22                	je     80102eb6 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102e94:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102e98:	76 0c                	jbe    80102ea6 <kbdgetc+0x13a>
80102e9a:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102e9e:	77 06                	ja     80102ea6 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102ea0:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102ea4:	eb 10                	jmp    80102eb6 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102ea6:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102eaa:	76 0a                	jbe    80102eb6 <kbdgetc+0x14a>
80102eac:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102eb0:	77 04                	ja     80102eb6 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102eb2:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102eb6:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102eb9:	c9                   	leave  
80102eba:	c3                   	ret    

80102ebb <kbdintr>:

void
kbdintr(void)
{
80102ebb:	55                   	push   %ebp
80102ebc:	89 e5                	mov    %esp,%ebp
80102ebe:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102ec1:	83 ec 0c             	sub    $0xc,%esp
80102ec4:	68 6c 2d 10 80       	push   $0x80102d6c
80102ec9:	e8 2b d9 ff ff       	call   801007f9 <consoleintr>
80102ece:	83 c4 10             	add    $0x10,%esp
}
80102ed1:	90                   	nop
80102ed2:	c9                   	leave  
80102ed3:	c3                   	ret    

80102ed4 <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80102ed4:	55                   	push   %ebp
80102ed5:	89 e5                	mov    %esp,%ebp
80102ed7:	83 ec 14             	sub    $0x14,%esp
80102eda:	8b 45 08             	mov    0x8(%ebp),%eax
80102edd:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ee1:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102ee5:	89 c2                	mov    %eax,%edx
80102ee7:	ec                   	in     (%dx),%al
80102ee8:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102eeb:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102eef:	c9                   	leave  
80102ef0:	c3                   	ret    

80102ef1 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102ef1:	55                   	push   %ebp
80102ef2:	89 e5                	mov    %esp,%ebp
80102ef4:	83 ec 08             	sub    $0x8,%esp
80102ef7:	8b 55 08             	mov    0x8(%ebp),%edx
80102efa:	8b 45 0c             	mov    0xc(%ebp),%eax
80102efd:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102f01:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102f04:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102f08:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102f0c:	ee                   	out    %al,(%dx)
}
80102f0d:	90                   	nop
80102f0e:	c9                   	leave  
80102f0f:	c3                   	ret    

80102f10 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102f10:	55                   	push   %ebp
80102f11:	89 e5                	mov    %esp,%ebp
80102f13:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102f16:	9c                   	pushf  
80102f17:	58                   	pop    %eax
80102f18:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102f1b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102f1e:	c9                   	leave  
80102f1f:	c3                   	ret    

80102f20 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102f20:	55                   	push   %ebp
80102f21:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102f23:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102f28:	8b 55 08             	mov    0x8(%ebp),%edx
80102f2b:	c1 e2 02             	shl    $0x2,%edx
80102f2e:	01 c2                	add    %eax,%edx
80102f30:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f33:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102f35:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102f3a:	83 c0 20             	add    $0x20,%eax
80102f3d:	8b 00                	mov    (%eax),%eax
}
80102f3f:	90                   	nop
80102f40:	5d                   	pop    %ebp
80102f41:	c3                   	ret    

80102f42 <lapicinit>:

void
lapicinit(void)
{
80102f42:	55                   	push   %ebp
80102f43:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
80102f45:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102f4a:	85 c0                	test   %eax,%eax
80102f4c:	0f 84 0b 01 00 00    	je     8010305d <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102f52:	68 3f 01 00 00       	push   $0x13f
80102f57:	6a 3c                	push   $0x3c
80102f59:	e8 c2 ff ff ff       	call   80102f20 <lapicw>
80102f5e:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102f61:	6a 0b                	push   $0xb
80102f63:	68 f8 00 00 00       	push   $0xf8
80102f68:	e8 b3 ff ff ff       	call   80102f20 <lapicw>
80102f6d:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102f70:	68 20 00 02 00       	push   $0x20020
80102f75:	68 c8 00 00 00       	push   $0xc8
80102f7a:	e8 a1 ff ff ff       	call   80102f20 <lapicw>
80102f7f:	83 c4 08             	add    $0x8,%esp
  // lapicw(TICR, 10000000); 
  lapicw(TICR, 1000000000/TPS); // PSU CS333. Makes ticks per second programmable
80102f82:	68 40 42 0f 00       	push   $0xf4240
80102f87:	68 e0 00 00 00       	push   $0xe0
80102f8c:	e8 8f ff ff ff       	call   80102f20 <lapicw>
80102f91:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102f94:	68 00 00 01 00       	push   $0x10000
80102f99:	68 d4 00 00 00       	push   $0xd4
80102f9e:	e8 7d ff ff ff       	call   80102f20 <lapicw>
80102fa3:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102fa6:	68 00 00 01 00       	push   $0x10000
80102fab:	68 d8 00 00 00       	push   $0xd8
80102fb0:	e8 6b ff ff ff       	call   80102f20 <lapicw>
80102fb5:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102fb8:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102fbd:	83 c0 30             	add    $0x30,%eax
80102fc0:	8b 00                	mov    (%eax),%eax
80102fc2:	c1 e8 10             	shr    $0x10,%eax
80102fc5:	0f b6 c0             	movzbl %al,%eax
80102fc8:	83 f8 03             	cmp    $0x3,%eax
80102fcb:	76 12                	jbe    80102fdf <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
80102fcd:	68 00 00 01 00       	push   $0x10000
80102fd2:	68 d0 00 00 00       	push   $0xd0
80102fd7:	e8 44 ff ff ff       	call   80102f20 <lapicw>
80102fdc:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102fdf:	6a 33                	push   $0x33
80102fe1:	68 dc 00 00 00       	push   $0xdc
80102fe6:	e8 35 ff ff ff       	call   80102f20 <lapicw>
80102feb:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102fee:	6a 00                	push   $0x0
80102ff0:	68 a0 00 00 00       	push   $0xa0
80102ff5:	e8 26 ff ff ff       	call   80102f20 <lapicw>
80102ffa:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102ffd:	6a 00                	push   $0x0
80102fff:	68 a0 00 00 00       	push   $0xa0
80103004:	e8 17 ff ff ff       	call   80102f20 <lapicw>
80103009:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
8010300c:	6a 00                	push   $0x0
8010300e:	6a 2c                	push   $0x2c
80103010:	e8 0b ff ff ff       	call   80102f20 <lapicw>
80103015:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103018:	6a 00                	push   $0x0
8010301a:	68 c4 00 00 00       	push   $0xc4
8010301f:	e8 fc fe ff ff       	call   80102f20 <lapicw>
80103024:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80103027:	68 00 85 08 00       	push   $0x88500
8010302c:	68 c0 00 00 00       	push   $0xc0
80103031:	e8 ea fe ff ff       	call   80102f20 <lapicw>
80103036:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80103039:	90                   	nop
8010303a:	a1 7c 32 11 80       	mov    0x8011327c,%eax
8010303f:	05 00 03 00 00       	add    $0x300,%eax
80103044:	8b 00                	mov    (%eax),%eax
80103046:	25 00 10 00 00       	and    $0x1000,%eax
8010304b:	85 c0                	test   %eax,%eax
8010304d:	75 eb                	jne    8010303a <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
8010304f:	6a 00                	push   $0x0
80103051:	6a 20                	push   $0x20
80103053:	e8 c8 fe ff ff       	call   80102f20 <lapicw>
80103058:	83 c4 08             	add    $0x8,%esp
8010305b:	eb 01                	jmp    8010305e <lapicinit+0x11c>

void
lapicinit(void)
{
  if(!lapic) 
    return;
8010305d:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
8010305e:	c9                   	leave  
8010305f:	c3                   	ret    

80103060 <cpunum>:

int
cpunum(void)
{
80103060:	55                   	push   %ebp
80103061:	89 e5                	mov    %esp,%ebp
80103063:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80103066:	e8 a5 fe ff ff       	call   80102f10 <readeflags>
8010306b:	25 00 02 00 00       	and    $0x200,%eax
80103070:	85 c0                	test   %eax,%eax
80103072:	74 26                	je     8010309a <cpunum+0x3a>
    static int n;
    if(n++ == 0)
80103074:	a1 60 c6 10 80       	mov    0x8010c660,%eax
80103079:	8d 50 01             	lea    0x1(%eax),%edx
8010307c:	89 15 60 c6 10 80    	mov    %edx,0x8010c660
80103082:	85 c0                	test   %eax,%eax
80103084:	75 14                	jne    8010309a <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
80103086:	8b 45 04             	mov    0x4(%ebp),%eax
80103089:	83 ec 08             	sub    $0x8,%esp
8010308c:	50                   	push   %eax
8010308d:	68 e0 97 10 80       	push   $0x801097e0
80103092:	e8 2f d3 ff ff       	call   801003c6 <cprintf>
80103097:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
8010309a:	a1 7c 32 11 80       	mov    0x8011327c,%eax
8010309f:	85 c0                	test   %eax,%eax
801030a1:	74 0f                	je     801030b2 <cpunum+0x52>
    return lapic[ID]>>24;
801030a3:	a1 7c 32 11 80       	mov    0x8011327c,%eax
801030a8:	83 c0 20             	add    $0x20,%eax
801030ab:	8b 00                	mov    (%eax),%eax
801030ad:	c1 e8 18             	shr    $0x18,%eax
801030b0:	eb 05                	jmp    801030b7 <cpunum+0x57>
  return 0;
801030b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801030b7:	c9                   	leave  
801030b8:	c3                   	ret    

801030b9 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
801030b9:	55                   	push   %ebp
801030ba:	89 e5                	mov    %esp,%ebp
  if(lapic)
801030bc:	a1 7c 32 11 80       	mov    0x8011327c,%eax
801030c1:	85 c0                	test   %eax,%eax
801030c3:	74 0c                	je     801030d1 <lapiceoi+0x18>
    lapicw(EOI, 0);
801030c5:	6a 00                	push   $0x0
801030c7:	6a 2c                	push   $0x2c
801030c9:	e8 52 fe ff ff       	call   80102f20 <lapicw>
801030ce:	83 c4 08             	add    $0x8,%esp
}
801030d1:	90                   	nop
801030d2:	c9                   	leave  
801030d3:	c3                   	ret    

801030d4 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
801030d4:	55                   	push   %ebp
801030d5:	89 e5                	mov    %esp,%ebp
}
801030d7:	90                   	nop
801030d8:	5d                   	pop    %ebp
801030d9:	c3                   	ret    

801030da <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
801030da:	55                   	push   %ebp
801030db:	89 e5                	mov    %esp,%ebp
801030dd:	83 ec 14             	sub    $0x14,%esp
801030e0:	8b 45 08             	mov    0x8(%ebp),%eax
801030e3:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
801030e6:	6a 0f                	push   $0xf
801030e8:	6a 70                	push   $0x70
801030ea:	e8 02 fe ff ff       	call   80102ef1 <outb>
801030ef:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
801030f2:	6a 0a                	push   $0xa
801030f4:	6a 71                	push   $0x71
801030f6:	e8 f6 fd ff ff       	call   80102ef1 <outb>
801030fb:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
801030fe:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103105:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103108:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
8010310d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103110:	83 c0 02             	add    $0x2,%eax
80103113:	8b 55 0c             	mov    0xc(%ebp),%edx
80103116:	c1 ea 04             	shr    $0x4,%edx
80103119:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
8010311c:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103120:	c1 e0 18             	shl    $0x18,%eax
80103123:	50                   	push   %eax
80103124:	68 c4 00 00 00       	push   $0xc4
80103129:	e8 f2 fd ff ff       	call   80102f20 <lapicw>
8010312e:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80103131:	68 00 c5 00 00       	push   $0xc500
80103136:	68 c0 00 00 00       	push   $0xc0
8010313b:	e8 e0 fd ff ff       	call   80102f20 <lapicw>
80103140:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103143:	68 c8 00 00 00       	push   $0xc8
80103148:	e8 87 ff ff ff       	call   801030d4 <microdelay>
8010314d:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80103150:	68 00 85 00 00       	push   $0x8500
80103155:	68 c0 00 00 00       	push   $0xc0
8010315a:	e8 c1 fd ff ff       	call   80102f20 <lapicw>
8010315f:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103162:	6a 64                	push   $0x64
80103164:	e8 6b ff ff ff       	call   801030d4 <microdelay>
80103169:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010316c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103173:	eb 3d                	jmp    801031b2 <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
80103175:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103179:	c1 e0 18             	shl    $0x18,%eax
8010317c:	50                   	push   %eax
8010317d:	68 c4 00 00 00       	push   $0xc4
80103182:	e8 99 fd ff ff       	call   80102f20 <lapicw>
80103187:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
8010318a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010318d:	c1 e8 0c             	shr    $0xc,%eax
80103190:	80 cc 06             	or     $0x6,%ah
80103193:	50                   	push   %eax
80103194:	68 c0 00 00 00       	push   $0xc0
80103199:	e8 82 fd ff ff       	call   80102f20 <lapicw>
8010319e:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
801031a1:	68 c8 00 00 00       	push   $0xc8
801031a6:	e8 29 ff ff ff       	call   801030d4 <microdelay>
801031ab:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801031ae:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801031b2:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801031b6:	7e bd                	jle    80103175 <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
801031b8:	90                   	nop
801031b9:	c9                   	leave  
801031ba:	c3                   	ret    

801031bb <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
801031bb:	55                   	push   %ebp
801031bc:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
801031be:	8b 45 08             	mov    0x8(%ebp),%eax
801031c1:	0f b6 c0             	movzbl %al,%eax
801031c4:	50                   	push   %eax
801031c5:	6a 70                	push   $0x70
801031c7:	e8 25 fd ff ff       	call   80102ef1 <outb>
801031cc:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801031cf:	68 c8 00 00 00       	push   $0xc8
801031d4:	e8 fb fe ff ff       	call   801030d4 <microdelay>
801031d9:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
801031dc:	6a 71                	push   $0x71
801031de:	e8 f1 fc ff ff       	call   80102ed4 <inb>
801031e3:	83 c4 04             	add    $0x4,%esp
801031e6:	0f b6 c0             	movzbl %al,%eax
}
801031e9:	c9                   	leave  
801031ea:	c3                   	ret    

801031eb <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
801031eb:	55                   	push   %ebp
801031ec:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
801031ee:	6a 00                	push   $0x0
801031f0:	e8 c6 ff ff ff       	call   801031bb <cmos_read>
801031f5:	83 c4 04             	add    $0x4,%esp
801031f8:	89 c2                	mov    %eax,%edx
801031fa:	8b 45 08             	mov    0x8(%ebp),%eax
801031fd:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
801031ff:	6a 02                	push   $0x2
80103201:	e8 b5 ff ff ff       	call   801031bb <cmos_read>
80103206:	83 c4 04             	add    $0x4,%esp
80103209:	89 c2                	mov    %eax,%edx
8010320b:	8b 45 08             	mov    0x8(%ebp),%eax
8010320e:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
80103211:	6a 04                	push   $0x4
80103213:	e8 a3 ff ff ff       	call   801031bb <cmos_read>
80103218:	83 c4 04             	add    $0x4,%esp
8010321b:	89 c2                	mov    %eax,%edx
8010321d:	8b 45 08             	mov    0x8(%ebp),%eax
80103220:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
80103223:	6a 07                	push   $0x7
80103225:	e8 91 ff ff ff       	call   801031bb <cmos_read>
8010322a:	83 c4 04             	add    $0x4,%esp
8010322d:	89 c2                	mov    %eax,%edx
8010322f:	8b 45 08             	mov    0x8(%ebp),%eax
80103232:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
80103235:	6a 08                	push   $0x8
80103237:	e8 7f ff ff ff       	call   801031bb <cmos_read>
8010323c:	83 c4 04             	add    $0x4,%esp
8010323f:	89 c2                	mov    %eax,%edx
80103241:	8b 45 08             	mov    0x8(%ebp),%eax
80103244:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
80103247:	6a 09                	push   $0x9
80103249:	e8 6d ff ff ff       	call   801031bb <cmos_read>
8010324e:	83 c4 04             	add    $0x4,%esp
80103251:	89 c2                	mov    %eax,%edx
80103253:	8b 45 08             	mov    0x8(%ebp),%eax
80103256:	89 50 14             	mov    %edx,0x14(%eax)
}
80103259:	90                   	nop
8010325a:	c9                   	leave  
8010325b:	c3                   	ret    

8010325c <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
8010325c:	55                   	push   %ebp
8010325d:	89 e5                	mov    %esp,%ebp
8010325f:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80103262:	6a 0b                	push   $0xb
80103264:	e8 52 ff ff ff       	call   801031bb <cmos_read>
80103269:	83 c4 04             	add    $0x4,%esp
8010326c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
8010326f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103272:	83 e0 04             	and    $0x4,%eax
80103275:	85 c0                	test   %eax,%eax
80103277:	0f 94 c0             	sete   %al
8010327a:	0f b6 c0             	movzbl %al,%eax
8010327d:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
80103280:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103283:	50                   	push   %eax
80103284:	e8 62 ff ff ff       	call   801031eb <fill_rtcdate>
80103289:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
8010328c:	6a 0a                	push   $0xa
8010328e:	e8 28 ff ff ff       	call   801031bb <cmos_read>
80103293:	83 c4 04             	add    $0x4,%esp
80103296:	25 80 00 00 00       	and    $0x80,%eax
8010329b:	85 c0                	test   %eax,%eax
8010329d:	75 27                	jne    801032c6 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
8010329f:	8d 45 c0             	lea    -0x40(%ebp),%eax
801032a2:	50                   	push   %eax
801032a3:	e8 43 ff ff ff       	call   801031eb <fill_rtcdate>
801032a8:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
801032ab:	83 ec 04             	sub    $0x4,%esp
801032ae:	6a 18                	push   $0x18
801032b0:	8d 45 c0             	lea    -0x40(%ebp),%eax
801032b3:	50                   	push   %eax
801032b4:	8d 45 d8             	lea    -0x28(%ebp),%eax
801032b7:	50                   	push   %eax
801032b8:	e8 11 2f 00 00       	call   801061ce <memcmp>
801032bd:	83 c4 10             	add    $0x10,%esp
801032c0:	85 c0                	test   %eax,%eax
801032c2:	74 05                	je     801032c9 <cmostime+0x6d>
801032c4:	eb ba                	jmp    80103280 <cmostime+0x24>

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
801032c6:	90                   	nop
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
801032c7:	eb b7                	jmp    80103280 <cmostime+0x24>
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
801032c9:	90                   	nop
  }

  // convert
  if (bcd) {
801032ca:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801032ce:	0f 84 b4 00 00 00    	je     80103388 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801032d4:	8b 45 d8             	mov    -0x28(%ebp),%eax
801032d7:	c1 e8 04             	shr    $0x4,%eax
801032da:	89 c2                	mov    %eax,%edx
801032dc:	89 d0                	mov    %edx,%eax
801032de:	c1 e0 02             	shl    $0x2,%eax
801032e1:	01 d0                	add    %edx,%eax
801032e3:	01 c0                	add    %eax,%eax
801032e5:	89 c2                	mov    %eax,%edx
801032e7:	8b 45 d8             	mov    -0x28(%ebp),%eax
801032ea:	83 e0 0f             	and    $0xf,%eax
801032ed:	01 d0                	add    %edx,%eax
801032ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
801032f2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801032f5:	c1 e8 04             	shr    $0x4,%eax
801032f8:	89 c2                	mov    %eax,%edx
801032fa:	89 d0                	mov    %edx,%eax
801032fc:	c1 e0 02             	shl    $0x2,%eax
801032ff:	01 d0                	add    %edx,%eax
80103301:	01 c0                	add    %eax,%eax
80103303:	89 c2                	mov    %eax,%edx
80103305:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103308:	83 e0 0f             	and    $0xf,%eax
8010330b:	01 d0                	add    %edx,%eax
8010330d:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103310:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103313:	c1 e8 04             	shr    $0x4,%eax
80103316:	89 c2                	mov    %eax,%edx
80103318:	89 d0                	mov    %edx,%eax
8010331a:	c1 e0 02             	shl    $0x2,%eax
8010331d:	01 d0                	add    %edx,%eax
8010331f:	01 c0                	add    %eax,%eax
80103321:	89 c2                	mov    %eax,%edx
80103323:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103326:	83 e0 0f             	and    $0xf,%eax
80103329:	01 d0                	add    %edx,%eax
8010332b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
8010332e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103331:	c1 e8 04             	shr    $0x4,%eax
80103334:	89 c2                	mov    %eax,%edx
80103336:	89 d0                	mov    %edx,%eax
80103338:	c1 e0 02             	shl    $0x2,%eax
8010333b:	01 d0                	add    %edx,%eax
8010333d:	01 c0                	add    %eax,%eax
8010333f:	89 c2                	mov    %eax,%edx
80103341:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103344:	83 e0 0f             	and    $0xf,%eax
80103347:	01 d0                	add    %edx,%eax
80103349:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
8010334c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010334f:	c1 e8 04             	shr    $0x4,%eax
80103352:	89 c2                	mov    %eax,%edx
80103354:	89 d0                	mov    %edx,%eax
80103356:	c1 e0 02             	shl    $0x2,%eax
80103359:	01 d0                	add    %edx,%eax
8010335b:	01 c0                	add    %eax,%eax
8010335d:	89 c2                	mov    %eax,%edx
8010335f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103362:	83 e0 0f             	and    $0xf,%eax
80103365:	01 d0                	add    %edx,%eax
80103367:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
8010336a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010336d:	c1 e8 04             	shr    $0x4,%eax
80103370:	89 c2                	mov    %eax,%edx
80103372:	89 d0                	mov    %edx,%eax
80103374:	c1 e0 02             	shl    $0x2,%eax
80103377:	01 d0                	add    %edx,%eax
80103379:	01 c0                	add    %eax,%eax
8010337b:	89 c2                	mov    %eax,%edx
8010337d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103380:	83 e0 0f             	and    $0xf,%eax
80103383:	01 d0                	add    %edx,%eax
80103385:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103388:	8b 45 08             	mov    0x8(%ebp),%eax
8010338b:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010338e:	89 10                	mov    %edx,(%eax)
80103390:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103393:	89 50 04             	mov    %edx,0x4(%eax)
80103396:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103399:	89 50 08             	mov    %edx,0x8(%eax)
8010339c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010339f:	89 50 0c             	mov    %edx,0xc(%eax)
801033a2:	8b 55 e8             	mov    -0x18(%ebp),%edx
801033a5:	89 50 10             	mov    %edx,0x10(%eax)
801033a8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801033ab:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801033ae:	8b 45 08             	mov    0x8(%ebp),%eax
801033b1:	8b 40 14             	mov    0x14(%eax),%eax
801033b4:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801033ba:	8b 45 08             	mov    0x8(%ebp),%eax
801033bd:	89 50 14             	mov    %edx,0x14(%eax)
}
801033c0:	90                   	nop
801033c1:	c9                   	leave  
801033c2:	c3                   	ret    

801033c3 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
801033c3:	55                   	push   %ebp
801033c4:	89 e5                	mov    %esp,%ebp
801033c6:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
801033c9:	83 ec 08             	sub    $0x8,%esp
801033cc:	68 0c 98 10 80       	push   $0x8010980c
801033d1:	68 80 32 11 80       	push   $0x80113280
801033d6:	e8 07 2b 00 00       	call   80105ee2 <initlock>
801033db:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
801033de:	83 ec 08             	sub    $0x8,%esp
801033e1:	8d 45 dc             	lea    -0x24(%ebp),%eax
801033e4:	50                   	push   %eax
801033e5:	ff 75 08             	pushl  0x8(%ebp)
801033e8:	e8 2b e0 ff ff       	call   80101418 <readsb>
801033ed:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
801033f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033f3:	a3 b4 32 11 80       	mov    %eax,0x801132b4
  log.size = sb.nlog;
801033f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801033fb:	a3 b8 32 11 80       	mov    %eax,0x801132b8
  log.dev = dev;
80103400:	8b 45 08             	mov    0x8(%ebp),%eax
80103403:	a3 c4 32 11 80       	mov    %eax,0x801132c4
  recover_from_log();
80103408:	e8 b2 01 00 00       	call   801035bf <recover_from_log>
}
8010340d:	90                   	nop
8010340e:	c9                   	leave  
8010340f:	c3                   	ret    

80103410 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80103410:	55                   	push   %ebp
80103411:	89 e5                	mov    %esp,%ebp
80103413:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103416:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010341d:	e9 95 00 00 00       	jmp    801034b7 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103422:	8b 15 b4 32 11 80    	mov    0x801132b4,%edx
80103428:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010342b:	01 d0                	add    %edx,%eax
8010342d:	83 c0 01             	add    $0x1,%eax
80103430:	89 c2                	mov    %eax,%edx
80103432:	a1 c4 32 11 80       	mov    0x801132c4,%eax
80103437:	83 ec 08             	sub    $0x8,%esp
8010343a:	52                   	push   %edx
8010343b:	50                   	push   %eax
8010343c:	e8 75 cd ff ff       	call   801001b6 <bread>
80103441:	83 c4 10             	add    $0x10,%esp
80103444:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103447:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010344a:	83 c0 10             	add    $0x10,%eax
8010344d:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
80103454:	89 c2                	mov    %eax,%edx
80103456:	a1 c4 32 11 80       	mov    0x801132c4,%eax
8010345b:	83 ec 08             	sub    $0x8,%esp
8010345e:	52                   	push   %edx
8010345f:	50                   	push   %eax
80103460:	e8 51 cd ff ff       	call   801001b6 <bread>
80103465:	83 c4 10             	add    $0x10,%esp
80103468:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
8010346b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010346e:	8d 50 18             	lea    0x18(%eax),%edx
80103471:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103474:	83 c0 18             	add    $0x18,%eax
80103477:	83 ec 04             	sub    $0x4,%esp
8010347a:	68 00 02 00 00       	push   $0x200
8010347f:	52                   	push   %edx
80103480:	50                   	push   %eax
80103481:	e8 a0 2d 00 00       	call   80106226 <memmove>
80103486:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103489:	83 ec 0c             	sub    $0xc,%esp
8010348c:	ff 75 ec             	pushl  -0x14(%ebp)
8010348f:	e8 5b cd ff ff       	call   801001ef <bwrite>
80103494:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
80103497:	83 ec 0c             	sub    $0xc,%esp
8010349a:	ff 75 f0             	pushl  -0x10(%ebp)
8010349d:	e8 8c cd ff ff       	call   8010022e <brelse>
801034a2:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
801034a5:	83 ec 0c             	sub    $0xc,%esp
801034a8:	ff 75 ec             	pushl  -0x14(%ebp)
801034ab:	e8 7e cd ff ff       	call   8010022e <brelse>
801034b0:	83 c4 10             	add    $0x10,%esp
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801034b3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034b7:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801034bc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801034bf:	0f 8f 5d ff ff ff    	jg     80103422 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
801034c5:	90                   	nop
801034c6:	c9                   	leave  
801034c7:	c3                   	ret    

801034c8 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801034c8:	55                   	push   %ebp
801034c9:	89 e5                	mov    %esp,%ebp
801034cb:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801034ce:	a1 b4 32 11 80       	mov    0x801132b4,%eax
801034d3:	89 c2                	mov    %eax,%edx
801034d5:	a1 c4 32 11 80       	mov    0x801132c4,%eax
801034da:	83 ec 08             	sub    $0x8,%esp
801034dd:	52                   	push   %edx
801034de:	50                   	push   %eax
801034df:	e8 d2 cc ff ff       	call   801001b6 <bread>
801034e4:	83 c4 10             	add    $0x10,%esp
801034e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801034ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034ed:	83 c0 18             	add    $0x18,%eax
801034f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801034f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034f6:	8b 00                	mov    (%eax),%eax
801034f8:	a3 c8 32 11 80       	mov    %eax,0x801132c8
  for (i = 0; i < log.lh.n; i++) {
801034fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103504:	eb 1b                	jmp    80103521 <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80103506:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103509:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010350c:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103510:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103513:	83 c2 10             	add    $0x10,%edx
80103516:	89 04 95 8c 32 11 80 	mov    %eax,-0x7feecd74(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
8010351d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103521:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103526:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103529:	7f db                	jg     80103506 <read_head+0x3e>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
8010352b:	83 ec 0c             	sub    $0xc,%esp
8010352e:	ff 75 f0             	pushl  -0x10(%ebp)
80103531:	e8 f8 cc ff ff       	call   8010022e <brelse>
80103536:	83 c4 10             	add    $0x10,%esp
}
80103539:	90                   	nop
8010353a:	c9                   	leave  
8010353b:	c3                   	ret    

8010353c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
8010353c:	55                   	push   %ebp
8010353d:	89 e5                	mov    %esp,%ebp
8010353f:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103542:	a1 b4 32 11 80       	mov    0x801132b4,%eax
80103547:	89 c2                	mov    %eax,%edx
80103549:	a1 c4 32 11 80       	mov    0x801132c4,%eax
8010354e:	83 ec 08             	sub    $0x8,%esp
80103551:	52                   	push   %edx
80103552:	50                   	push   %eax
80103553:	e8 5e cc ff ff       	call   801001b6 <bread>
80103558:	83 c4 10             	add    $0x10,%esp
8010355b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
8010355e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103561:	83 c0 18             	add    $0x18,%eax
80103564:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103567:	8b 15 c8 32 11 80    	mov    0x801132c8,%edx
8010356d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103570:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103572:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103579:	eb 1b                	jmp    80103596 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
8010357b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010357e:	83 c0 10             	add    $0x10,%eax
80103581:	8b 0c 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%ecx
80103588:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010358b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010358e:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80103592:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103596:	a1 c8 32 11 80       	mov    0x801132c8,%eax
8010359b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010359e:	7f db                	jg     8010357b <write_head+0x3f>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
801035a0:	83 ec 0c             	sub    $0xc,%esp
801035a3:	ff 75 f0             	pushl  -0x10(%ebp)
801035a6:	e8 44 cc ff ff       	call   801001ef <bwrite>
801035ab:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
801035ae:	83 ec 0c             	sub    $0xc,%esp
801035b1:	ff 75 f0             	pushl  -0x10(%ebp)
801035b4:	e8 75 cc ff ff       	call   8010022e <brelse>
801035b9:	83 c4 10             	add    $0x10,%esp
}
801035bc:	90                   	nop
801035bd:	c9                   	leave  
801035be:	c3                   	ret    

801035bf <recover_from_log>:

static void
recover_from_log(void)
{
801035bf:	55                   	push   %ebp
801035c0:	89 e5                	mov    %esp,%ebp
801035c2:	83 ec 08             	sub    $0x8,%esp
  read_head();      
801035c5:	e8 fe fe ff ff       	call   801034c8 <read_head>
  install_trans(); // if committed, copy from log to disk
801035ca:	e8 41 fe ff ff       	call   80103410 <install_trans>
  log.lh.n = 0;
801035cf:	c7 05 c8 32 11 80 00 	movl   $0x0,0x801132c8
801035d6:	00 00 00 
  write_head(); // clear the log
801035d9:	e8 5e ff ff ff       	call   8010353c <write_head>
}
801035de:	90                   	nop
801035df:	c9                   	leave  
801035e0:	c3                   	ret    

801035e1 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
801035e1:	55                   	push   %ebp
801035e2:	89 e5                	mov    %esp,%ebp
801035e4:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
801035e7:	83 ec 0c             	sub    $0xc,%esp
801035ea:	68 80 32 11 80       	push   $0x80113280
801035ef:	e8 10 29 00 00       	call   80105f04 <acquire>
801035f4:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
801035f7:	a1 c0 32 11 80       	mov    0x801132c0,%eax
801035fc:	85 c0                	test   %eax,%eax
801035fe:	74 17                	je     80103617 <begin_op+0x36>
      sleep(&log, &log.lock);
80103600:	83 ec 08             	sub    $0x8,%esp
80103603:	68 80 32 11 80       	push   $0x80113280
80103608:	68 80 32 11 80       	push   $0x80113280
8010360d:	e8 ea 1d 00 00       	call   801053fc <sleep>
80103612:	83 c4 10             	add    $0x10,%esp
80103615:	eb e0                	jmp    801035f7 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103617:	8b 0d c8 32 11 80    	mov    0x801132c8,%ecx
8010361d:	a1 bc 32 11 80       	mov    0x801132bc,%eax
80103622:	8d 50 01             	lea    0x1(%eax),%edx
80103625:	89 d0                	mov    %edx,%eax
80103627:	c1 e0 02             	shl    $0x2,%eax
8010362a:	01 d0                	add    %edx,%eax
8010362c:	01 c0                	add    %eax,%eax
8010362e:	01 c8                	add    %ecx,%eax
80103630:	83 f8 1e             	cmp    $0x1e,%eax
80103633:	7e 17                	jle    8010364c <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103635:	83 ec 08             	sub    $0x8,%esp
80103638:	68 80 32 11 80       	push   $0x80113280
8010363d:	68 80 32 11 80       	push   $0x80113280
80103642:	e8 b5 1d 00 00       	call   801053fc <sleep>
80103647:	83 c4 10             	add    $0x10,%esp
8010364a:	eb ab                	jmp    801035f7 <begin_op+0x16>
    } else {
      log.outstanding += 1;
8010364c:	a1 bc 32 11 80       	mov    0x801132bc,%eax
80103651:	83 c0 01             	add    $0x1,%eax
80103654:	a3 bc 32 11 80       	mov    %eax,0x801132bc
      release(&log.lock);
80103659:	83 ec 0c             	sub    $0xc,%esp
8010365c:	68 80 32 11 80       	push   $0x80113280
80103661:	e8 05 29 00 00       	call   80105f6b <release>
80103666:	83 c4 10             	add    $0x10,%esp
      break;
80103669:	90                   	nop
    }
  }
}
8010366a:	90                   	nop
8010366b:	c9                   	leave  
8010366c:	c3                   	ret    

8010366d <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
8010366d:	55                   	push   %ebp
8010366e:	89 e5                	mov    %esp,%ebp
80103670:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
80103673:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
8010367a:	83 ec 0c             	sub    $0xc,%esp
8010367d:	68 80 32 11 80       	push   $0x80113280
80103682:	e8 7d 28 00 00       	call   80105f04 <acquire>
80103687:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
8010368a:	a1 bc 32 11 80       	mov    0x801132bc,%eax
8010368f:	83 e8 01             	sub    $0x1,%eax
80103692:	a3 bc 32 11 80       	mov    %eax,0x801132bc
  if(log.committing)
80103697:	a1 c0 32 11 80       	mov    0x801132c0,%eax
8010369c:	85 c0                	test   %eax,%eax
8010369e:	74 0d                	je     801036ad <end_op+0x40>
    panic("log.committing");
801036a0:	83 ec 0c             	sub    $0xc,%esp
801036a3:	68 10 98 10 80       	push   $0x80109810
801036a8:	e8 b9 ce ff ff       	call   80100566 <panic>
  if(log.outstanding == 0){
801036ad:	a1 bc 32 11 80       	mov    0x801132bc,%eax
801036b2:	85 c0                	test   %eax,%eax
801036b4:	75 13                	jne    801036c9 <end_op+0x5c>
    do_commit = 1;
801036b6:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801036bd:	c7 05 c0 32 11 80 01 	movl   $0x1,0x801132c0
801036c4:	00 00 00 
801036c7:	eb 10                	jmp    801036d9 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
801036c9:	83 ec 0c             	sub    $0xc,%esp
801036cc:	68 80 32 11 80       	push   $0x80113280
801036d1:	e8 7e 1e 00 00       	call   80105554 <wakeup>
801036d6:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
801036d9:	83 ec 0c             	sub    $0xc,%esp
801036dc:	68 80 32 11 80       	push   $0x80113280
801036e1:	e8 85 28 00 00       	call   80105f6b <release>
801036e6:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
801036e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801036ed:	74 3f                	je     8010372e <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
801036ef:	e8 f5 00 00 00       	call   801037e9 <commit>
    acquire(&log.lock);
801036f4:	83 ec 0c             	sub    $0xc,%esp
801036f7:	68 80 32 11 80       	push   $0x80113280
801036fc:	e8 03 28 00 00       	call   80105f04 <acquire>
80103701:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103704:	c7 05 c0 32 11 80 00 	movl   $0x0,0x801132c0
8010370b:	00 00 00 
    wakeup(&log);
8010370e:	83 ec 0c             	sub    $0xc,%esp
80103711:	68 80 32 11 80       	push   $0x80113280
80103716:	e8 39 1e 00 00       	call   80105554 <wakeup>
8010371b:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010371e:	83 ec 0c             	sub    $0xc,%esp
80103721:	68 80 32 11 80       	push   $0x80113280
80103726:	e8 40 28 00 00       	call   80105f6b <release>
8010372b:	83 c4 10             	add    $0x10,%esp
  }
}
8010372e:	90                   	nop
8010372f:	c9                   	leave  
80103730:	c3                   	ret    

80103731 <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
80103731:	55                   	push   %ebp
80103732:	89 e5                	mov    %esp,%ebp
80103734:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103737:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010373e:	e9 95 00 00 00       	jmp    801037d8 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103743:	8b 15 b4 32 11 80    	mov    0x801132b4,%edx
80103749:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010374c:	01 d0                	add    %edx,%eax
8010374e:	83 c0 01             	add    $0x1,%eax
80103751:	89 c2                	mov    %eax,%edx
80103753:	a1 c4 32 11 80       	mov    0x801132c4,%eax
80103758:	83 ec 08             	sub    $0x8,%esp
8010375b:	52                   	push   %edx
8010375c:	50                   	push   %eax
8010375d:	e8 54 ca ff ff       	call   801001b6 <bread>
80103762:	83 c4 10             	add    $0x10,%esp
80103765:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103768:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010376b:	83 c0 10             	add    $0x10,%eax
8010376e:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
80103775:	89 c2                	mov    %eax,%edx
80103777:	a1 c4 32 11 80       	mov    0x801132c4,%eax
8010377c:	83 ec 08             	sub    $0x8,%esp
8010377f:	52                   	push   %edx
80103780:	50                   	push   %eax
80103781:	e8 30 ca ff ff       	call   801001b6 <bread>
80103786:	83 c4 10             	add    $0x10,%esp
80103789:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
8010378c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010378f:	8d 50 18             	lea    0x18(%eax),%edx
80103792:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103795:	83 c0 18             	add    $0x18,%eax
80103798:	83 ec 04             	sub    $0x4,%esp
8010379b:	68 00 02 00 00       	push   $0x200
801037a0:	52                   	push   %edx
801037a1:	50                   	push   %eax
801037a2:	e8 7f 2a 00 00       	call   80106226 <memmove>
801037a7:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
801037aa:	83 ec 0c             	sub    $0xc,%esp
801037ad:	ff 75 f0             	pushl  -0x10(%ebp)
801037b0:	e8 3a ca ff ff       	call   801001ef <bwrite>
801037b5:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
801037b8:	83 ec 0c             	sub    $0xc,%esp
801037bb:	ff 75 ec             	pushl  -0x14(%ebp)
801037be:	e8 6b ca ff ff       	call   8010022e <brelse>
801037c3:	83 c4 10             	add    $0x10,%esp
    brelse(to);
801037c6:	83 ec 0c             	sub    $0xc,%esp
801037c9:	ff 75 f0             	pushl  -0x10(%ebp)
801037cc:	e8 5d ca ff ff       	call   8010022e <brelse>
801037d1:	83 c4 10             	add    $0x10,%esp
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801037d4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801037d8:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801037dd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801037e0:	0f 8f 5d ff ff ff    	jg     80103743 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
801037e6:	90                   	nop
801037e7:	c9                   	leave  
801037e8:	c3                   	ret    

801037e9 <commit>:

static void
commit()
{
801037e9:	55                   	push   %ebp
801037ea:	89 e5                	mov    %esp,%ebp
801037ec:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
801037ef:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801037f4:	85 c0                	test   %eax,%eax
801037f6:	7e 1e                	jle    80103816 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
801037f8:	e8 34 ff ff ff       	call   80103731 <write_log>
    write_head();    // Write header to disk -- the real commit
801037fd:	e8 3a fd ff ff       	call   8010353c <write_head>
    install_trans(); // Now install writes to home locations
80103802:	e8 09 fc ff ff       	call   80103410 <install_trans>
    log.lh.n = 0; 
80103807:	c7 05 c8 32 11 80 00 	movl   $0x0,0x801132c8
8010380e:	00 00 00 
    write_head();    // Erase the transaction from the log
80103811:	e8 26 fd ff ff       	call   8010353c <write_head>
  }
}
80103816:	90                   	nop
80103817:	c9                   	leave  
80103818:	c3                   	ret    

80103819 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103819:	55                   	push   %ebp
8010381a:	89 e5                	mov    %esp,%ebp
8010381c:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010381f:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103824:	83 f8 1d             	cmp    $0x1d,%eax
80103827:	7f 12                	jg     8010383b <log_write+0x22>
80103829:	a1 c8 32 11 80       	mov    0x801132c8,%eax
8010382e:	8b 15 b8 32 11 80    	mov    0x801132b8,%edx
80103834:	83 ea 01             	sub    $0x1,%edx
80103837:	39 d0                	cmp    %edx,%eax
80103839:	7c 0d                	jl     80103848 <log_write+0x2f>
    panic("too big a transaction");
8010383b:	83 ec 0c             	sub    $0xc,%esp
8010383e:	68 1f 98 10 80       	push   $0x8010981f
80103843:	e8 1e cd ff ff       	call   80100566 <panic>
  if (log.outstanding < 1)
80103848:	a1 bc 32 11 80       	mov    0x801132bc,%eax
8010384d:	85 c0                	test   %eax,%eax
8010384f:	7f 0d                	jg     8010385e <log_write+0x45>
    panic("log_write outside of trans");
80103851:	83 ec 0c             	sub    $0xc,%esp
80103854:	68 35 98 10 80       	push   $0x80109835
80103859:	e8 08 cd ff ff       	call   80100566 <panic>

  acquire(&log.lock);
8010385e:	83 ec 0c             	sub    $0xc,%esp
80103861:	68 80 32 11 80       	push   $0x80113280
80103866:	e8 99 26 00 00       	call   80105f04 <acquire>
8010386b:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
8010386e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103875:	eb 1d                	jmp    80103894 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103877:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010387a:	83 c0 10             	add    $0x10,%eax
8010387d:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
80103884:	89 c2                	mov    %eax,%edx
80103886:	8b 45 08             	mov    0x8(%ebp),%eax
80103889:	8b 40 08             	mov    0x8(%eax),%eax
8010388c:	39 c2                	cmp    %eax,%edx
8010388e:	74 10                	je     801038a0 <log_write+0x87>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80103890:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103894:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103899:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010389c:	7f d9                	jg     80103877 <log_write+0x5e>
8010389e:	eb 01                	jmp    801038a1 <log_write+0x88>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
801038a0:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801038a1:	8b 45 08             	mov    0x8(%ebp),%eax
801038a4:	8b 40 08             	mov    0x8(%eax),%eax
801038a7:	89 c2                	mov    %eax,%edx
801038a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038ac:	83 c0 10             	add    $0x10,%eax
801038af:	89 14 85 8c 32 11 80 	mov    %edx,-0x7feecd74(,%eax,4)
  if (i == log.lh.n)
801038b6:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801038bb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038be:	75 0d                	jne    801038cd <log_write+0xb4>
    log.lh.n++;
801038c0:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801038c5:	83 c0 01             	add    $0x1,%eax
801038c8:	a3 c8 32 11 80       	mov    %eax,0x801132c8
  b->flags |= B_DIRTY; // prevent eviction
801038cd:	8b 45 08             	mov    0x8(%ebp),%eax
801038d0:	8b 00                	mov    (%eax),%eax
801038d2:	83 c8 04             	or     $0x4,%eax
801038d5:	89 c2                	mov    %eax,%edx
801038d7:	8b 45 08             	mov    0x8(%ebp),%eax
801038da:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
801038dc:	83 ec 0c             	sub    $0xc,%esp
801038df:	68 80 32 11 80       	push   $0x80113280
801038e4:	e8 82 26 00 00       	call   80105f6b <release>
801038e9:	83 c4 10             	add    $0x10,%esp
}
801038ec:	90                   	nop
801038ed:	c9                   	leave  
801038ee:	c3                   	ret    

801038ef <v2p>:
801038ef:	55                   	push   %ebp
801038f0:	89 e5                	mov    %esp,%ebp
801038f2:	8b 45 08             	mov    0x8(%ebp),%eax
801038f5:	05 00 00 00 80       	add    $0x80000000,%eax
801038fa:	5d                   	pop    %ebp
801038fb:	c3                   	ret    

801038fc <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801038fc:	55                   	push   %ebp
801038fd:	89 e5                	mov    %esp,%ebp
801038ff:	8b 45 08             	mov    0x8(%ebp),%eax
80103902:	05 00 00 00 80       	add    $0x80000000,%eax
80103907:	5d                   	pop    %ebp
80103908:	c3                   	ret    

80103909 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103909:	55                   	push   %ebp
8010390a:	89 e5                	mov    %esp,%ebp
8010390c:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010390f:	8b 55 08             	mov    0x8(%ebp),%edx
80103912:	8b 45 0c             	mov    0xc(%ebp),%eax
80103915:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103918:	f0 87 02             	lock xchg %eax,(%edx)
8010391b:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010391e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103921:	c9                   	leave  
80103922:	c3                   	ret    

80103923 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103923:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103927:	83 e4 f0             	and    $0xfffffff0,%esp
8010392a:	ff 71 fc             	pushl  -0x4(%ecx)
8010392d:	55                   	push   %ebp
8010392e:	89 e5                	mov    %esp,%ebp
80103930:	51                   	push   %ecx
80103931:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103934:	83 ec 08             	sub    $0x8,%esp
80103937:	68 00 00 40 80       	push   $0x80400000
8010393c:	68 3c 67 11 80       	push   $0x8011673c
80103941:	e8 7d f2 ff ff       	call   80102bc3 <kinit1>
80103946:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103949:	e8 cf 54 00 00       	call   80108e1d <kvmalloc>
  mpinit();        // collect info about this machine
8010394e:	e8 43 04 00 00       	call   80103d96 <mpinit>
  lapicinit();
80103953:	e8 ea f5 ff ff       	call   80102f42 <lapicinit>
  seginit();       // set up segments
80103958:	e8 69 4e 00 00       	call   801087c6 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
8010395d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103963:	0f b6 00             	movzbl (%eax),%eax
80103966:	0f b6 c0             	movzbl %al,%eax
80103969:	83 ec 08             	sub    $0x8,%esp
8010396c:	50                   	push   %eax
8010396d:	68 50 98 10 80       	push   $0x80109850
80103972:	e8 4f ca ff ff       	call   801003c6 <cprintf>
80103977:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
8010397a:	e8 6d 06 00 00       	call   80103fec <picinit>
  ioapicinit();    // another interrupt controller
8010397f:	e8 34 f1 ff ff       	call   80102ab8 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80103984:	e8 24 d2 ff ff       	call   80100bad <consoleinit>
  uartinit();      // serial port
80103989:	e8 94 41 00 00       	call   80107b22 <uartinit>
  pinit();         // process table
8010398e:	e8 5d 0b 00 00       	call   801044f0 <pinit>
  tvinit();        // trap vectors
80103993:	e8 63 3d 00 00       	call   801076fb <tvinit>
  binit();         // buffer cache
80103998:	e8 97 c6 ff ff       	call   80100034 <binit>
  fileinit();      // file table
8010399d:	e8 67 d6 ff ff       	call   80101009 <fileinit>
  ideinit();       // disk
801039a2:	e8 19 ed ff ff       	call   801026c0 <ideinit>
  if(!ismp)
801039a7:	a1 64 33 11 80       	mov    0x80113364,%eax
801039ac:	85 c0                	test   %eax,%eax
801039ae:	75 05                	jne    801039b5 <main+0x92>
    timerinit();   // uniprocessor timer
801039b0:	e8 97 3c 00 00       	call   8010764c <timerinit>
  startothers();   // start other processors
801039b5:	e8 7f 00 00 00       	call   80103a39 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801039ba:	83 ec 08             	sub    $0x8,%esp
801039bd:	68 00 00 00 8e       	push   $0x8e000000
801039c2:	68 00 00 40 80       	push   $0x80400000
801039c7:	e8 30 f2 ff ff       	call   80102bfc <kinit2>
801039cc:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
801039cf:	e8 6e 0d 00 00       	call   80104742 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
801039d4:	e8 1a 00 00 00       	call   801039f3 <mpmain>

801039d9 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801039d9:	55                   	push   %ebp
801039da:	89 e5                	mov    %esp,%ebp
801039dc:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
801039df:	e8 51 54 00 00       	call   80108e35 <switchkvm>
  seginit();
801039e4:	e8 dd 4d 00 00       	call   801087c6 <seginit>
  lapicinit();
801039e9:	e8 54 f5 ff ff       	call   80102f42 <lapicinit>
  mpmain();
801039ee:	e8 00 00 00 00       	call   801039f3 <mpmain>

801039f3 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801039f3:	55                   	push   %ebp
801039f4:	89 e5                	mov    %esp,%ebp
801039f6:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
801039f9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801039ff:	0f b6 00             	movzbl (%eax),%eax
80103a02:	0f b6 c0             	movzbl %al,%eax
80103a05:	83 ec 08             	sub    $0x8,%esp
80103a08:	50                   	push   %eax
80103a09:	68 67 98 10 80       	push   $0x80109867
80103a0e:	e8 b3 c9 ff ff       	call   801003c6 <cprintf>
80103a13:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103a16:	e8 41 3e 00 00       	call   8010785c <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103a1b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103a21:	05 a8 00 00 00       	add    $0xa8,%eax
80103a26:	83 ec 08             	sub    $0x8,%esp
80103a29:	6a 01                	push   $0x1
80103a2b:	50                   	push   %eax
80103a2c:	e8 d8 fe ff ff       	call   80103909 <xchg>
80103a31:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103a34:	e8 ab 16 00 00       	call   801050e4 <scheduler>

80103a39 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103a39:	55                   	push   %ebp
80103a3a:	89 e5                	mov    %esp,%ebp
80103a3c:	53                   	push   %ebx
80103a3d:	83 ec 14             	sub    $0x14,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
80103a40:	68 00 70 00 00       	push   $0x7000
80103a45:	e8 b2 fe ff ff       	call   801038fc <p2v>
80103a4a:	83 c4 04             	add    $0x4,%esp
80103a4d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103a50:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103a55:	83 ec 04             	sub    $0x4,%esp
80103a58:	50                   	push   %eax
80103a59:	68 2c c5 10 80       	push   $0x8010c52c
80103a5e:	ff 75 f0             	pushl  -0x10(%ebp)
80103a61:	e8 c0 27 00 00       	call   80106226 <memmove>
80103a66:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103a69:	c7 45 f4 80 33 11 80 	movl   $0x80113380,-0xc(%ebp)
80103a70:	e9 90 00 00 00       	jmp    80103b05 <startothers+0xcc>
    if(c == cpus+cpunum())  // We've started already.
80103a75:	e8 e6 f5 ff ff       	call   80103060 <cpunum>
80103a7a:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103a80:	05 80 33 11 80       	add    $0x80113380,%eax
80103a85:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a88:	74 73                	je     80103afd <startothers+0xc4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103a8a:	e8 6b f2 ff ff       	call   80102cfa <kalloc>
80103a8f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103a92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a95:	83 e8 04             	sub    $0x4,%eax
80103a98:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103a9b:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103aa1:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103aa3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103aa6:	83 e8 08             	sub    $0x8,%eax
80103aa9:	c7 00 d9 39 10 80    	movl   $0x801039d9,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103aaf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ab2:	8d 58 f4             	lea    -0xc(%eax),%ebx
80103ab5:	83 ec 0c             	sub    $0xc,%esp
80103ab8:	68 00 b0 10 80       	push   $0x8010b000
80103abd:	e8 2d fe ff ff       	call   801038ef <v2p>
80103ac2:	83 c4 10             	add    $0x10,%esp
80103ac5:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80103ac7:	83 ec 0c             	sub    $0xc,%esp
80103aca:	ff 75 f0             	pushl  -0x10(%ebp)
80103acd:	e8 1d fe ff ff       	call   801038ef <v2p>
80103ad2:	83 c4 10             	add    $0x10,%esp
80103ad5:	89 c2                	mov    %eax,%edx
80103ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ada:	0f b6 00             	movzbl (%eax),%eax
80103add:	0f b6 c0             	movzbl %al,%eax
80103ae0:	83 ec 08             	sub    $0x8,%esp
80103ae3:	52                   	push   %edx
80103ae4:	50                   	push   %eax
80103ae5:	e8 f0 f5 ff ff       	call   801030da <lapicstartap>
80103aea:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103aed:	90                   	nop
80103aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103af1:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103af7:	85 c0                	test   %eax,%eax
80103af9:	74 f3                	je     80103aee <startothers+0xb5>
80103afb:	eb 01                	jmp    80103afe <startothers+0xc5>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
80103afd:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103afe:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103b05:	a1 60 39 11 80       	mov    0x80113960,%eax
80103b0a:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103b10:	05 80 33 11 80       	add    $0x80113380,%eax
80103b15:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103b18:	0f 87 57 ff ff ff    	ja     80103a75 <startothers+0x3c>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103b1e:	90                   	nop
80103b1f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103b22:	c9                   	leave  
80103b23:	c3                   	ret    

80103b24 <p2v>:
80103b24:	55                   	push   %ebp
80103b25:	89 e5                	mov    %esp,%ebp
80103b27:	8b 45 08             	mov    0x8(%ebp),%eax
80103b2a:	05 00 00 00 80       	add    $0x80000000,%eax
80103b2f:	5d                   	pop    %ebp
80103b30:	c3                   	ret    

80103b31 <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80103b31:	55                   	push   %ebp
80103b32:	89 e5                	mov    %esp,%ebp
80103b34:	83 ec 14             	sub    $0x14,%esp
80103b37:	8b 45 08             	mov    0x8(%ebp),%eax
80103b3a:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103b3e:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103b42:	89 c2                	mov    %eax,%edx
80103b44:	ec                   	in     (%dx),%al
80103b45:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103b48:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103b4c:	c9                   	leave  
80103b4d:	c3                   	ret    

80103b4e <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103b4e:	55                   	push   %ebp
80103b4f:	89 e5                	mov    %esp,%ebp
80103b51:	83 ec 08             	sub    $0x8,%esp
80103b54:	8b 55 08             	mov    0x8(%ebp),%edx
80103b57:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b5a:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103b5e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103b61:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103b65:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103b69:	ee                   	out    %al,(%dx)
}
80103b6a:	90                   	nop
80103b6b:	c9                   	leave  
80103b6c:	c3                   	ret    

80103b6d <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103b6d:	55                   	push   %ebp
80103b6e:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103b70:	a1 64 c6 10 80       	mov    0x8010c664,%eax
80103b75:	89 c2                	mov    %eax,%edx
80103b77:	b8 80 33 11 80       	mov    $0x80113380,%eax
80103b7c:	29 c2                	sub    %eax,%edx
80103b7e:	89 d0                	mov    %edx,%eax
80103b80:	c1 f8 02             	sar    $0x2,%eax
80103b83:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103b89:	5d                   	pop    %ebp
80103b8a:	c3                   	ret    

80103b8b <sum>:

static uchar
sum(uchar *addr, int len)
{
80103b8b:	55                   	push   %ebp
80103b8c:	89 e5                	mov    %esp,%ebp
80103b8e:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103b91:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103b98:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103b9f:	eb 15                	jmp    80103bb6 <sum+0x2b>
    sum += addr[i];
80103ba1:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103ba4:	8b 45 08             	mov    0x8(%ebp),%eax
80103ba7:	01 d0                	add    %edx,%eax
80103ba9:	0f b6 00             	movzbl (%eax),%eax
80103bac:	0f b6 c0             	movzbl %al,%eax
80103baf:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103bb2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103bb6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103bb9:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103bbc:	7c e3                	jl     80103ba1 <sum+0x16>
    sum += addr[i];
  return sum;
80103bbe:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103bc1:	c9                   	leave  
80103bc2:	c3                   	ret    

80103bc3 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103bc3:	55                   	push   %ebp
80103bc4:	89 e5                	mov    %esp,%ebp
80103bc6:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103bc9:	ff 75 08             	pushl  0x8(%ebp)
80103bcc:	e8 53 ff ff ff       	call   80103b24 <p2v>
80103bd1:	83 c4 04             	add    $0x4,%esp
80103bd4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103bd7:	8b 55 0c             	mov    0xc(%ebp),%edx
80103bda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bdd:	01 d0                	add    %edx,%eax
80103bdf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103be2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103be5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103be8:	eb 36                	jmp    80103c20 <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103bea:	83 ec 04             	sub    $0x4,%esp
80103bed:	6a 04                	push   $0x4
80103bef:	68 78 98 10 80       	push   $0x80109878
80103bf4:	ff 75 f4             	pushl  -0xc(%ebp)
80103bf7:	e8 d2 25 00 00       	call   801061ce <memcmp>
80103bfc:	83 c4 10             	add    $0x10,%esp
80103bff:	85 c0                	test   %eax,%eax
80103c01:	75 19                	jne    80103c1c <mpsearch1+0x59>
80103c03:	83 ec 08             	sub    $0x8,%esp
80103c06:	6a 10                	push   $0x10
80103c08:	ff 75 f4             	pushl  -0xc(%ebp)
80103c0b:	e8 7b ff ff ff       	call   80103b8b <sum>
80103c10:	83 c4 10             	add    $0x10,%esp
80103c13:	84 c0                	test   %al,%al
80103c15:	75 05                	jne    80103c1c <mpsearch1+0x59>
      return (struct mp*)p;
80103c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c1a:	eb 11                	jmp    80103c2d <mpsearch1+0x6a>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103c1c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103c20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c23:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103c26:	72 c2                	jb     80103bea <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103c28:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103c2d:	c9                   	leave  
80103c2e:	c3                   	ret    

80103c2f <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103c2f:	55                   	push   %ebp
80103c30:	89 e5                	mov    %esp,%ebp
80103c32:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103c35:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c3f:	83 c0 0f             	add    $0xf,%eax
80103c42:	0f b6 00             	movzbl (%eax),%eax
80103c45:	0f b6 c0             	movzbl %al,%eax
80103c48:	c1 e0 08             	shl    $0x8,%eax
80103c4b:	89 c2                	mov    %eax,%edx
80103c4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c50:	83 c0 0e             	add    $0xe,%eax
80103c53:	0f b6 00             	movzbl (%eax),%eax
80103c56:	0f b6 c0             	movzbl %al,%eax
80103c59:	09 d0                	or     %edx,%eax
80103c5b:	c1 e0 04             	shl    $0x4,%eax
80103c5e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103c61:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103c65:	74 21                	je     80103c88 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103c67:	83 ec 08             	sub    $0x8,%esp
80103c6a:	68 00 04 00 00       	push   $0x400
80103c6f:	ff 75 f0             	pushl  -0x10(%ebp)
80103c72:	e8 4c ff ff ff       	call   80103bc3 <mpsearch1>
80103c77:	83 c4 10             	add    $0x10,%esp
80103c7a:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c7d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c81:	74 51                	je     80103cd4 <mpsearch+0xa5>
      return mp;
80103c83:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c86:	eb 61                	jmp    80103ce9 <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103c88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c8b:	83 c0 14             	add    $0x14,%eax
80103c8e:	0f b6 00             	movzbl (%eax),%eax
80103c91:	0f b6 c0             	movzbl %al,%eax
80103c94:	c1 e0 08             	shl    $0x8,%eax
80103c97:	89 c2                	mov    %eax,%edx
80103c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c9c:	83 c0 13             	add    $0x13,%eax
80103c9f:	0f b6 00             	movzbl (%eax),%eax
80103ca2:	0f b6 c0             	movzbl %al,%eax
80103ca5:	09 d0                	or     %edx,%eax
80103ca7:	c1 e0 0a             	shl    $0xa,%eax
80103caa:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103cad:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cb0:	2d 00 04 00 00       	sub    $0x400,%eax
80103cb5:	83 ec 08             	sub    $0x8,%esp
80103cb8:	68 00 04 00 00       	push   $0x400
80103cbd:	50                   	push   %eax
80103cbe:	e8 00 ff ff ff       	call   80103bc3 <mpsearch1>
80103cc3:	83 c4 10             	add    $0x10,%esp
80103cc6:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103cc9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103ccd:	74 05                	je     80103cd4 <mpsearch+0xa5>
      return mp;
80103ccf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103cd2:	eb 15                	jmp    80103ce9 <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103cd4:	83 ec 08             	sub    $0x8,%esp
80103cd7:	68 00 00 01 00       	push   $0x10000
80103cdc:	68 00 00 0f 00       	push   $0xf0000
80103ce1:	e8 dd fe ff ff       	call   80103bc3 <mpsearch1>
80103ce6:	83 c4 10             	add    $0x10,%esp
}
80103ce9:	c9                   	leave  
80103cea:	c3                   	ret    

80103ceb <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103ceb:	55                   	push   %ebp
80103cec:	89 e5                	mov    %esp,%ebp
80103cee:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103cf1:	e8 39 ff ff ff       	call   80103c2f <mpsearch>
80103cf6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103cf9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103cfd:	74 0a                	je     80103d09 <mpconfig+0x1e>
80103cff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d02:	8b 40 04             	mov    0x4(%eax),%eax
80103d05:	85 c0                	test   %eax,%eax
80103d07:	75 0a                	jne    80103d13 <mpconfig+0x28>
    return 0;
80103d09:	b8 00 00 00 00       	mov    $0x0,%eax
80103d0e:	e9 81 00 00 00       	jmp    80103d94 <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103d13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d16:	8b 40 04             	mov    0x4(%eax),%eax
80103d19:	83 ec 0c             	sub    $0xc,%esp
80103d1c:	50                   	push   %eax
80103d1d:	e8 02 fe ff ff       	call   80103b24 <p2v>
80103d22:	83 c4 10             	add    $0x10,%esp
80103d25:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103d28:	83 ec 04             	sub    $0x4,%esp
80103d2b:	6a 04                	push   $0x4
80103d2d:	68 7d 98 10 80       	push   $0x8010987d
80103d32:	ff 75 f0             	pushl  -0x10(%ebp)
80103d35:	e8 94 24 00 00       	call   801061ce <memcmp>
80103d3a:	83 c4 10             	add    $0x10,%esp
80103d3d:	85 c0                	test   %eax,%eax
80103d3f:	74 07                	je     80103d48 <mpconfig+0x5d>
    return 0;
80103d41:	b8 00 00 00 00       	mov    $0x0,%eax
80103d46:	eb 4c                	jmp    80103d94 <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
80103d48:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d4b:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103d4f:	3c 01                	cmp    $0x1,%al
80103d51:	74 12                	je     80103d65 <mpconfig+0x7a>
80103d53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d56:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103d5a:	3c 04                	cmp    $0x4,%al
80103d5c:	74 07                	je     80103d65 <mpconfig+0x7a>
    return 0;
80103d5e:	b8 00 00 00 00       	mov    $0x0,%eax
80103d63:	eb 2f                	jmp    80103d94 <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
80103d65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d68:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103d6c:	0f b7 c0             	movzwl %ax,%eax
80103d6f:	83 ec 08             	sub    $0x8,%esp
80103d72:	50                   	push   %eax
80103d73:	ff 75 f0             	pushl  -0x10(%ebp)
80103d76:	e8 10 fe ff ff       	call   80103b8b <sum>
80103d7b:	83 c4 10             	add    $0x10,%esp
80103d7e:	84 c0                	test   %al,%al
80103d80:	74 07                	je     80103d89 <mpconfig+0x9e>
    return 0;
80103d82:	b8 00 00 00 00       	mov    $0x0,%eax
80103d87:	eb 0b                	jmp    80103d94 <mpconfig+0xa9>
  *pmp = mp;
80103d89:	8b 45 08             	mov    0x8(%ebp),%eax
80103d8c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d8f:	89 10                	mov    %edx,(%eax)
  return conf;
80103d91:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103d94:	c9                   	leave  
80103d95:	c3                   	ret    

80103d96 <mpinit>:

void
mpinit(void)
{
80103d96:	55                   	push   %ebp
80103d97:	89 e5                	mov    %esp,%ebp
80103d99:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103d9c:	c7 05 64 c6 10 80 80 	movl   $0x80113380,0x8010c664
80103da3:	33 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103da6:	83 ec 0c             	sub    $0xc,%esp
80103da9:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103dac:	50                   	push   %eax
80103dad:	e8 39 ff ff ff       	call   80103ceb <mpconfig>
80103db2:	83 c4 10             	add    $0x10,%esp
80103db5:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103db8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103dbc:	0f 84 96 01 00 00    	je     80103f58 <mpinit+0x1c2>
    return;
  ismp = 1;
80103dc2:	c7 05 64 33 11 80 01 	movl   $0x1,0x80113364
80103dc9:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103dcc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dcf:	8b 40 24             	mov    0x24(%eax),%eax
80103dd2:	a3 7c 32 11 80       	mov    %eax,0x8011327c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103dd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dda:	83 c0 2c             	add    $0x2c,%eax
80103ddd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103de0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103de3:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103de7:	0f b7 d0             	movzwl %ax,%edx
80103dea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ded:	01 d0                	add    %edx,%eax
80103def:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103df2:	e9 f2 00 00 00       	jmp    80103ee9 <mpinit+0x153>
    switch(*p){
80103df7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dfa:	0f b6 00             	movzbl (%eax),%eax
80103dfd:	0f b6 c0             	movzbl %al,%eax
80103e00:	83 f8 04             	cmp    $0x4,%eax
80103e03:	0f 87 bc 00 00 00    	ja     80103ec5 <mpinit+0x12f>
80103e09:	8b 04 85 c0 98 10 80 	mov    -0x7fef6740(,%eax,4),%eax
80103e10:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103e12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e15:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103e18:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103e1b:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103e1f:	0f b6 d0             	movzbl %al,%edx
80103e22:	a1 60 39 11 80       	mov    0x80113960,%eax
80103e27:	39 c2                	cmp    %eax,%edx
80103e29:	74 2b                	je     80103e56 <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103e2b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103e2e:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103e32:	0f b6 d0             	movzbl %al,%edx
80103e35:	a1 60 39 11 80       	mov    0x80113960,%eax
80103e3a:	83 ec 04             	sub    $0x4,%esp
80103e3d:	52                   	push   %edx
80103e3e:	50                   	push   %eax
80103e3f:	68 82 98 10 80       	push   $0x80109882
80103e44:	e8 7d c5 ff ff       	call   801003c6 <cprintf>
80103e49:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
80103e4c:	c7 05 64 33 11 80 00 	movl   $0x0,0x80113364
80103e53:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103e56:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103e59:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103e5d:	0f b6 c0             	movzbl %al,%eax
80103e60:	83 e0 02             	and    $0x2,%eax
80103e63:	85 c0                	test   %eax,%eax
80103e65:	74 15                	je     80103e7c <mpinit+0xe6>
        bcpu = &cpus[ncpu];
80103e67:	a1 60 39 11 80       	mov    0x80113960,%eax
80103e6c:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103e72:	05 80 33 11 80       	add    $0x80113380,%eax
80103e77:	a3 64 c6 10 80       	mov    %eax,0x8010c664
      cpus[ncpu].id = ncpu;
80103e7c:	a1 60 39 11 80       	mov    0x80113960,%eax
80103e81:	8b 15 60 39 11 80    	mov    0x80113960,%edx
80103e87:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103e8d:	05 80 33 11 80       	add    $0x80113380,%eax
80103e92:	88 10                	mov    %dl,(%eax)
      ncpu++;
80103e94:	a1 60 39 11 80       	mov    0x80113960,%eax
80103e99:	83 c0 01             	add    $0x1,%eax
80103e9c:	a3 60 39 11 80       	mov    %eax,0x80113960
      p += sizeof(struct mpproc);
80103ea1:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103ea5:	eb 42                	jmp    80103ee9 <mpinit+0x153>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103ea7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eaa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103ead:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103eb0:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103eb4:	a2 60 33 11 80       	mov    %al,0x80113360
      p += sizeof(struct mpioapic);
80103eb9:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103ebd:	eb 2a                	jmp    80103ee9 <mpinit+0x153>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103ebf:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103ec3:	eb 24                	jmp    80103ee9 <mpinit+0x153>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103ec5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ec8:	0f b6 00             	movzbl (%eax),%eax
80103ecb:	0f b6 c0             	movzbl %al,%eax
80103ece:	83 ec 08             	sub    $0x8,%esp
80103ed1:	50                   	push   %eax
80103ed2:	68 a0 98 10 80       	push   $0x801098a0
80103ed7:	e8 ea c4 ff ff       	call   801003c6 <cprintf>
80103edc:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
80103edf:	c7 05 64 33 11 80 00 	movl   $0x0,0x80113364
80103ee6:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103ee9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eec:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103eef:	0f 82 02 ff ff ff    	jb     80103df7 <mpinit+0x61>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103ef5:	a1 64 33 11 80       	mov    0x80113364,%eax
80103efa:	85 c0                	test   %eax,%eax
80103efc:	75 1d                	jne    80103f1b <mpinit+0x185>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103efe:	c7 05 60 39 11 80 01 	movl   $0x1,0x80113960
80103f05:	00 00 00 
    lapic = 0;
80103f08:	c7 05 7c 32 11 80 00 	movl   $0x0,0x8011327c
80103f0f:	00 00 00 
    ioapicid = 0;
80103f12:	c6 05 60 33 11 80 00 	movb   $0x0,0x80113360
    return;
80103f19:	eb 3e                	jmp    80103f59 <mpinit+0x1c3>
  }

  if(mp->imcrp){
80103f1b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f1e:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103f22:	84 c0                	test   %al,%al
80103f24:	74 33                	je     80103f59 <mpinit+0x1c3>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103f26:	83 ec 08             	sub    $0x8,%esp
80103f29:	6a 70                	push   $0x70
80103f2b:	6a 22                	push   $0x22
80103f2d:	e8 1c fc ff ff       	call   80103b4e <outb>
80103f32:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103f35:	83 ec 0c             	sub    $0xc,%esp
80103f38:	6a 23                	push   $0x23
80103f3a:	e8 f2 fb ff ff       	call   80103b31 <inb>
80103f3f:	83 c4 10             	add    $0x10,%esp
80103f42:	83 c8 01             	or     $0x1,%eax
80103f45:	0f b6 c0             	movzbl %al,%eax
80103f48:	83 ec 08             	sub    $0x8,%esp
80103f4b:	50                   	push   %eax
80103f4c:	6a 23                	push   $0x23
80103f4e:	e8 fb fb ff ff       	call   80103b4e <outb>
80103f53:	83 c4 10             	add    $0x10,%esp
80103f56:	eb 01                	jmp    80103f59 <mpinit+0x1c3>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80103f58:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80103f59:	c9                   	leave  
80103f5a:	c3                   	ret    

80103f5b <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103f5b:	55                   	push   %ebp
80103f5c:	89 e5                	mov    %esp,%ebp
80103f5e:	83 ec 08             	sub    $0x8,%esp
80103f61:	8b 55 08             	mov    0x8(%ebp),%edx
80103f64:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f67:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103f6b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103f6e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103f72:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103f76:	ee                   	out    %al,(%dx)
}
80103f77:	90                   	nop
80103f78:	c9                   	leave  
80103f79:	c3                   	ret    

80103f7a <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103f7a:	55                   	push   %ebp
80103f7b:	89 e5                	mov    %esp,%ebp
80103f7d:	83 ec 04             	sub    $0x4,%esp
80103f80:	8b 45 08             	mov    0x8(%ebp),%eax
80103f83:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103f87:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f8b:	66 a3 00 c0 10 80    	mov    %ax,0x8010c000
  outb(IO_PIC1+1, mask);
80103f91:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f95:	0f b6 c0             	movzbl %al,%eax
80103f98:	50                   	push   %eax
80103f99:	6a 21                	push   $0x21
80103f9b:	e8 bb ff ff ff       	call   80103f5b <outb>
80103fa0:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80103fa3:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103fa7:	66 c1 e8 08          	shr    $0x8,%ax
80103fab:	0f b6 c0             	movzbl %al,%eax
80103fae:	50                   	push   %eax
80103faf:	68 a1 00 00 00       	push   $0xa1
80103fb4:	e8 a2 ff ff ff       	call   80103f5b <outb>
80103fb9:	83 c4 08             	add    $0x8,%esp
}
80103fbc:	90                   	nop
80103fbd:	c9                   	leave  
80103fbe:	c3                   	ret    

80103fbf <picenable>:

void
picenable(int irq)
{
80103fbf:	55                   	push   %ebp
80103fc0:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80103fc2:	8b 45 08             	mov    0x8(%ebp),%eax
80103fc5:	ba 01 00 00 00       	mov    $0x1,%edx
80103fca:	89 c1                	mov    %eax,%ecx
80103fcc:	d3 e2                	shl    %cl,%edx
80103fce:	89 d0                	mov    %edx,%eax
80103fd0:	f7 d0                	not    %eax
80103fd2:	89 c2                	mov    %eax,%edx
80103fd4:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103fdb:	21 d0                	and    %edx,%eax
80103fdd:	0f b7 c0             	movzwl %ax,%eax
80103fe0:	50                   	push   %eax
80103fe1:	e8 94 ff ff ff       	call   80103f7a <picsetmask>
80103fe6:	83 c4 04             	add    $0x4,%esp
}
80103fe9:	90                   	nop
80103fea:	c9                   	leave  
80103feb:	c3                   	ret    

80103fec <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103fec:	55                   	push   %ebp
80103fed:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103fef:	68 ff 00 00 00       	push   $0xff
80103ff4:	6a 21                	push   $0x21
80103ff6:	e8 60 ff ff ff       	call   80103f5b <outb>
80103ffb:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103ffe:	68 ff 00 00 00       	push   $0xff
80104003:	68 a1 00 00 00       	push   $0xa1
80104008:	e8 4e ff ff ff       	call   80103f5b <outb>
8010400d:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80104010:	6a 11                	push   $0x11
80104012:	6a 20                	push   $0x20
80104014:	e8 42 ff ff ff       	call   80103f5b <outb>
80104019:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
8010401c:	6a 20                	push   $0x20
8010401e:	6a 21                	push   $0x21
80104020:	e8 36 ff ff ff       	call   80103f5b <outb>
80104025:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80104028:	6a 04                	push   $0x4
8010402a:	6a 21                	push   $0x21
8010402c:	e8 2a ff ff ff       	call   80103f5b <outb>
80104031:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80104034:	6a 03                	push   $0x3
80104036:	6a 21                	push   $0x21
80104038:	e8 1e ff ff ff       	call   80103f5b <outb>
8010403d:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80104040:	6a 11                	push   $0x11
80104042:	68 a0 00 00 00       	push   $0xa0
80104047:	e8 0f ff ff ff       	call   80103f5b <outb>
8010404c:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
8010404f:	6a 28                	push   $0x28
80104051:	68 a1 00 00 00       	push   $0xa1
80104056:	e8 00 ff ff ff       	call   80103f5b <outb>
8010405b:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
8010405e:	6a 02                	push   $0x2
80104060:	68 a1 00 00 00       	push   $0xa1
80104065:	e8 f1 fe ff ff       	call   80103f5b <outb>
8010406a:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
8010406d:	6a 03                	push   $0x3
8010406f:	68 a1 00 00 00       	push   $0xa1
80104074:	e8 e2 fe ff ff       	call   80103f5b <outb>
80104079:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
8010407c:	6a 68                	push   $0x68
8010407e:	6a 20                	push   $0x20
80104080:	e8 d6 fe ff ff       	call   80103f5b <outb>
80104085:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
80104088:	6a 0a                	push   $0xa
8010408a:	6a 20                	push   $0x20
8010408c:	e8 ca fe ff ff       	call   80103f5b <outb>
80104091:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
80104094:	6a 68                	push   $0x68
80104096:	68 a0 00 00 00       	push   $0xa0
8010409b:	e8 bb fe ff ff       	call   80103f5b <outb>
801040a0:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
801040a3:	6a 0a                	push   $0xa
801040a5:	68 a0 00 00 00       	push   $0xa0
801040aa:	e8 ac fe ff ff       	call   80103f5b <outb>
801040af:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
801040b2:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
801040b9:	66 83 f8 ff          	cmp    $0xffff,%ax
801040bd:	74 13                	je     801040d2 <picinit+0xe6>
    picsetmask(irqmask);
801040bf:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
801040c6:	0f b7 c0             	movzwl %ax,%eax
801040c9:	50                   	push   %eax
801040ca:	e8 ab fe ff ff       	call   80103f7a <picsetmask>
801040cf:	83 c4 04             	add    $0x4,%esp
}
801040d2:	90                   	nop
801040d3:	c9                   	leave  
801040d4:	c3                   	ret    

801040d5 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
801040d5:	55                   	push   %ebp
801040d6:	89 e5                	mov    %esp,%ebp
801040d8:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
801040db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
801040e2:	8b 45 0c             	mov    0xc(%ebp),%eax
801040e5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
801040eb:	8b 45 0c             	mov    0xc(%ebp),%eax
801040ee:	8b 10                	mov    (%eax),%edx
801040f0:	8b 45 08             	mov    0x8(%ebp),%eax
801040f3:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
801040f5:	e8 2d cf ff ff       	call   80101027 <filealloc>
801040fa:	89 c2                	mov    %eax,%edx
801040fc:	8b 45 08             	mov    0x8(%ebp),%eax
801040ff:	89 10                	mov    %edx,(%eax)
80104101:	8b 45 08             	mov    0x8(%ebp),%eax
80104104:	8b 00                	mov    (%eax),%eax
80104106:	85 c0                	test   %eax,%eax
80104108:	0f 84 cb 00 00 00    	je     801041d9 <pipealloc+0x104>
8010410e:	e8 14 cf ff ff       	call   80101027 <filealloc>
80104113:	89 c2                	mov    %eax,%edx
80104115:	8b 45 0c             	mov    0xc(%ebp),%eax
80104118:	89 10                	mov    %edx,(%eax)
8010411a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010411d:	8b 00                	mov    (%eax),%eax
8010411f:	85 c0                	test   %eax,%eax
80104121:	0f 84 b2 00 00 00    	je     801041d9 <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80104127:	e8 ce eb ff ff       	call   80102cfa <kalloc>
8010412c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010412f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104133:	0f 84 9f 00 00 00    	je     801041d8 <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
80104139:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010413c:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80104143:	00 00 00 
  p->writeopen = 1;
80104146:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104149:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104150:	00 00 00 
  p->nwrite = 0;
80104153:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104156:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
8010415d:	00 00 00 
  p->nread = 0;
80104160:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104163:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
8010416a:	00 00 00 
  initlock(&p->lock, "pipe");
8010416d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104170:	83 ec 08             	sub    $0x8,%esp
80104173:	68 d4 98 10 80       	push   $0x801098d4
80104178:	50                   	push   %eax
80104179:	e8 64 1d 00 00       	call   80105ee2 <initlock>
8010417e:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80104181:	8b 45 08             	mov    0x8(%ebp),%eax
80104184:	8b 00                	mov    (%eax),%eax
80104186:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
8010418c:	8b 45 08             	mov    0x8(%ebp),%eax
8010418f:	8b 00                	mov    (%eax),%eax
80104191:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104195:	8b 45 08             	mov    0x8(%ebp),%eax
80104198:	8b 00                	mov    (%eax),%eax
8010419a:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
8010419e:	8b 45 08             	mov    0x8(%ebp),%eax
801041a1:	8b 00                	mov    (%eax),%eax
801041a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041a6:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
801041a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801041ac:	8b 00                	mov    (%eax),%eax
801041ae:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801041b4:	8b 45 0c             	mov    0xc(%ebp),%eax
801041b7:	8b 00                	mov    (%eax),%eax
801041b9:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801041bd:	8b 45 0c             	mov    0xc(%ebp),%eax
801041c0:	8b 00                	mov    (%eax),%eax
801041c2:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801041c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801041c9:	8b 00                	mov    (%eax),%eax
801041cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041ce:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
801041d1:	b8 00 00 00 00       	mov    $0x0,%eax
801041d6:	eb 4e                	jmp    80104226 <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
801041d8:	90                   	nop
  (*f1)->writable = 1;
  (*f1)->pipe = p;
  return 0;

 bad:
  if(p)
801041d9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801041dd:	74 0e                	je     801041ed <pipealloc+0x118>
    kfree((char*)p);
801041df:	83 ec 0c             	sub    $0xc,%esp
801041e2:	ff 75 f4             	pushl  -0xc(%ebp)
801041e5:	e8 73 ea ff ff       	call   80102c5d <kfree>
801041ea:	83 c4 10             	add    $0x10,%esp
  if(*f0)
801041ed:	8b 45 08             	mov    0x8(%ebp),%eax
801041f0:	8b 00                	mov    (%eax),%eax
801041f2:	85 c0                	test   %eax,%eax
801041f4:	74 11                	je     80104207 <pipealloc+0x132>
    fileclose(*f0);
801041f6:	8b 45 08             	mov    0x8(%ebp),%eax
801041f9:	8b 00                	mov    (%eax),%eax
801041fb:	83 ec 0c             	sub    $0xc,%esp
801041fe:	50                   	push   %eax
801041ff:	e8 e1 ce ff ff       	call   801010e5 <fileclose>
80104204:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80104207:	8b 45 0c             	mov    0xc(%ebp),%eax
8010420a:	8b 00                	mov    (%eax),%eax
8010420c:	85 c0                	test   %eax,%eax
8010420e:	74 11                	je     80104221 <pipealloc+0x14c>
    fileclose(*f1);
80104210:	8b 45 0c             	mov    0xc(%ebp),%eax
80104213:	8b 00                	mov    (%eax),%eax
80104215:	83 ec 0c             	sub    $0xc,%esp
80104218:	50                   	push   %eax
80104219:	e8 c7 ce ff ff       	call   801010e5 <fileclose>
8010421e:	83 c4 10             	add    $0x10,%esp
  return -1;
80104221:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104226:	c9                   	leave  
80104227:	c3                   	ret    

80104228 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104228:	55                   	push   %ebp
80104229:	89 e5                	mov    %esp,%ebp
8010422b:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
8010422e:	8b 45 08             	mov    0x8(%ebp),%eax
80104231:	83 ec 0c             	sub    $0xc,%esp
80104234:	50                   	push   %eax
80104235:	e8 ca 1c 00 00       	call   80105f04 <acquire>
8010423a:	83 c4 10             	add    $0x10,%esp
  if(writable){
8010423d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104241:	74 23                	je     80104266 <pipeclose+0x3e>
    p->writeopen = 0;
80104243:	8b 45 08             	mov    0x8(%ebp),%eax
80104246:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
8010424d:	00 00 00 
    wakeup(&p->nread);
80104250:	8b 45 08             	mov    0x8(%ebp),%eax
80104253:	05 34 02 00 00       	add    $0x234,%eax
80104258:	83 ec 0c             	sub    $0xc,%esp
8010425b:	50                   	push   %eax
8010425c:	e8 f3 12 00 00       	call   80105554 <wakeup>
80104261:	83 c4 10             	add    $0x10,%esp
80104264:	eb 21                	jmp    80104287 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
80104266:	8b 45 08             	mov    0x8(%ebp),%eax
80104269:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104270:	00 00 00 
    wakeup(&p->nwrite);
80104273:	8b 45 08             	mov    0x8(%ebp),%eax
80104276:	05 38 02 00 00       	add    $0x238,%eax
8010427b:	83 ec 0c             	sub    $0xc,%esp
8010427e:	50                   	push   %eax
8010427f:	e8 d0 12 00 00       	call   80105554 <wakeup>
80104284:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104287:	8b 45 08             	mov    0x8(%ebp),%eax
8010428a:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104290:	85 c0                	test   %eax,%eax
80104292:	75 2c                	jne    801042c0 <pipeclose+0x98>
80104294:	8b 45 08             	mov    0x8(%ebp),%eax
80104297:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010429d:	85 c0                	test   %eax,%eax
8010429f:	75 1f                	jne    801042c0 <pipeclose+0x98>
    release(&p->lock);
801042a1:	8b 45 08             	mov    0x8(%ebp),%eax
801042a4:	83 ec 0c             	sub    $0xc,%esp
801042a7:	50                   	push   %eax
801042a8:	e8 be 1c 00 00       	call   80105f6b <release>
801042ad:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
801042b0:	83 ec 0c             	sub    $0xc,%esp
801042b3:	ff 75 08             	pushl  0x8(%ebp)
801042b6:	e8 a2 e9 ff ff       	call   80102c5d <kfree>
801042bb:	83 c4 10             	add    $0x10,%esp
801042be:	eb 0f                	jmp    801042cf <pipeclose+0xa7>
  } else
    release(&p->lock);
801042c0:	8b 45 08             	mov    0x8(%ebp),%eax
801042c3:	83 ec 0c             	sub    $0xc,%esp
801042c6:	50                   	push   %eax
801042c7:	e8 9f 1c 00 00       	call   80105f6b <release>
801042cc:	83 c4 10             	add    $0x10,%esp
}
801042cf:	90                   	nop
801042d0:	c9                   	leave  
801042d1:	c3                   	ret    

801042d2 <pipewrite>:

int
pipewrite(struct pipe *p, char *addr, int n)
{
801042d2:	55                   	push   %ebp
801042d3:	89 e5                	mov    %esp,%ebp
801042d5:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
801042d8:	8b 45 08             	mov    0x8(%ebp),%eax
801042db:	83 ec 0c             	sub    $0xc,%esp
801042de:	50                   	push   %eax
801042df:	e8 20 1c 00 00       	call   80105f04 <acquire>
801042e4:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
801042e7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801042ee:	e9 ad 00 00 00       	jmp    801043a0 <pipewrite+0xce>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
801042f3:	8b 45 08             	mov    0x8(%ebp),%eax
801042f6:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801042fc:	85 c0                	test   %eax,%eax
801042fe:	74 0d                	je     8010430d <pipewrite+0x3b>
80104300:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104306:	8b 40 24             	mov    0x24(%eax),%eax
80104309:	85 c0                	test   %eax,%eax
8010430b:	74 19                	je     80104326 <pipewrite+0x54>
        release(&p->lock);
8010430d:	8b 45 08             	mov    0x8(%ebp),%eax
80104310:	83 ec 0c             	sub    $0xc,%esp
80104313:	50                   	push   %eax
80104314:	e8 52 1c 00 00       	call   80105f6b <release>
80104319:	83 c4 10             	add    $0x10,%esp
        return -1;
8010431c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104321:	e9 a8 00 00 00       	jmp    801043ce <pipewrite+0xfc>
      }
      wakeup(&p->nread);
80104326:	8b 45 08             	mov    0x8(%ebp),%eax
80104329:	05 34 02 00 00       	add    $0x234,%eax
8010432e:	83 ec 0c             	sub    $0xc,%esp
80104331:	50                   	push   %eax
80104332:	e8 1d 12 00 00       	call   80105554 <wakeup>
80104337:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010433a:	8b 45 08             	mov    0x8(%ebp),%eax
8010433d:	8b 55 08             	mov    0x8(%ebp),%edx
80104340:	81 c2 38 02 00 00    	add    $0x238,%edx
80104346:	83 ec 08             	sub    $0x8,%esp
80104349:	50                   	push   %eax
8010434a:	52                   	push   %edx
8010434b:	e8 ac 10 00 00       	call   801053fc <sleep>
80104350:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104353:	8b 45 08             	mov    0x8(%ebp),%eax
80104356:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
8010435c:	8b 45 08             	mov    0x8(%ebp),%eax
8010435f:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104365:	05 00 02 00 00       	add    $0x200,%eax
8010436a:	39 c2                	cmp    %eax,%edx
8010436c:	74 85                	je     801042f3 <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
8010436e:	8b 45 08             	mov    0x8(%ebp),%eax
80104371:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104377:	8d 48 01             	lea    0x1(%eax),%ecx
8010437a:	8b 55 08             	mov    0x8(%ebp),%edx
8010437d:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104383:	25 ff 01 00 00       	and    $0x1ff,%eax
80104388:	89 c1                	mov    %eax,%ecx
8010438a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010438d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104390:	01 d0                	add    %edx,%eax
80104392:	0f b6 10             	movzbl (%eax),%edx
80104395:	8b 45 08             	mov    0x8(%ebp),%eax
80104398:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
8010439c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801043a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043a3:	3b 45 10             	cmp    0x10(%ebp),%eax
801043a6:	7c ab                	jl     80104353 <pipewrite+0x81>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801043a8:	8b 45 08             	mov    0x8(%ebp),%eax
801043ab:	05 34 02 00 00       	add    $0x234,%eax
801043b0:	83 ec 0c             	sub    $0xc,%esp
801043b3:	50                   	push   %eax
801043b4:	e8 9b 11 00 00       	call   80105554 <wakeup>
801043b9:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801043bc:	8b 45 08             	mov    0x8(%ebp),%eax
801043bf:	83 ec 0c             	sub    $0xc,%esp
801043c2:	50                   	push   %eax
801043c3:	e8 a3 1b 00 00       	call   80105f6b <release>
801043c8:	83 c4 10             	add    $0x10,%esp
  return n;
801043cb:	8b 45 10             	mov    0x10(%ebp),%eax
}
801043ce:	c9                   	leave  
801043cf:	c3                   	ret    

801043d0 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801043d0:	55                   	push   %ebp
801043d1:	89 e5                	mov    %esp,%ebp
801043d3:	53                   	push   %ebx
801043d4:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
801043d7:	8b 45 08             	mov    0x8(%ebp),%eax
801043da:	83 ec 0c             	sub    $0xc,%esp
801043dd:	50                   	push   %eax
801043de:	e8 21 1b 00 00       	call   80105f04 <acquire>
801043e3:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801043e6:	eb 3f                	jmp    80104427 <piperead+0x57>
    if(proc->killed){
801043e8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801043ee:	8b 40 24             	mov    0x24(%eax),%eax
801043f1:	85 c0                	test   %eax,%eax
801043f3:	74 19                	je     8010440e <piperead+0x3e>
      release(&p->lock);
801043f5:	8b 45 08             	mov    0x8(%ebp),%eax
801043f8:	83 ec 0c             	sub    $0xc,%esp
801043fb:	50                   	push   %eax
801043fc:	e8 6a 1b 00 00       	call   80105f6b <release>
80104401:	83 c4 10             	add    $0x10,%esp
      return -1;
80104404:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104409:	e9 bf 00 00 00       	jmp    801044cd <piperead+0xfd>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010440e:	8b 45 08             	mov    0x8(%ebp),%eax
80104411:	8b 55 08             	mov    0x8(%ebp),%edx
80104414:	81 c2 34 02 00 00    	add    $0x234,%edx
8010441a:	83 ec 08             	sub    $0x8,%esp
8010441d:	50                   	push   %eax
8010441e:	52                   	push   %edx
8010441f:	e8 d8 0f 00 00       	call   801053fc <sleep>
80104424:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104427:	8b 45 08             	mov    0x8(%ebp),%eax
8010442a:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104430:	8b 45 08             	mov    0x8(%ebp),%eax
80104433:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104439:	39 c2                	cmp    %eax,%edx
8010443b:	75 0d                	jne    8010444a <piperead+0x7a>
8010443d:	8b 45 08             	mov    0x8(%ebp),%eax
80104440:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104446:	85 c0                	test   %eax,%eax
80104448:	75 9e                	jne    801043e8 <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010444a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104451:	eb 49                	jmp    8010449c <piperead+0xcc>
    if(p->nread == p->nwrite)
80104453:	8b 45 08             	mov    0x8(%ebp),%eax
80104456:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010445c:	8b 45 08             	mov    0x8(%ebp),%eax
8010445f:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104465:	39 c2                	cmp    %eax,%edx
80104467:	74 3d                	je     801044a6 <piperead+0xd6>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104469:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010446c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010446f:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104472:	8b 45 08             	mov    0x8(%ebp),%eax
80104475:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010447b:	8d 48 01             	lea    0x1(%eax),%ecx
8010447e:	8b 55 08             	mov    0x8(%ebp),%edx
80104481:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104487:	25 ff 01 00 00       	and    $0x1ff,%eax
8010448c:	89 c2                	mov    %eax,%edx
8010448e:	8b 45 08             	mov    0x8(%ebp),%eax
80104491:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
80104496:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104498:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010449c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010449f:	3b 45 10             	cmp    0x10(%ebp),%eax
801044a2:	7c af                	jl     80104453 <piperead+0x83>
801044a4:	eb 01                	jmp    801044a7 <piperead+0xd7>
    if(p->nread == p->nwrite)
      break;
801044a6:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801044a7:	8b 45 08             	mov    0x8(%ebp),%eax
801044aa:	05 38 02 00 00       	add    $0x238,%eax
801044af:	83 ec 0c             	sub    $0xc,%esp
801044b2:	50                   	push   %eax
801044b3:	e8 9c 10 00 00       	call   80105554 <wakeup>
801044b8:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801044bb:	8b 45 08             	mov    0x8(%ebp),%eax
801044be:	83 ec 0c             	sub    $0xc,%esp
801044c1:	50                   	push   %eax
801044c2:	e8 a4 1a 00 00       	call   80105f6b <release>
801044c7:	83 c4 10             	add    $0x10,%esp
  return i;
801044ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801044cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801044d0:	c9                   	leave  
801044d1:	c3                   	ret    

801044d2 <hlt>:
}

// hlt() added by Noah Zentzis, Fall 2016.
static inline void
hlt()
{
801044d2:	55                   	push   %ebp
801044d3:	89 e5                	mov    %esp,%ebp
  asm volatile("hlt");
801044d5:	f4                   	hlt    
}
801044d6:	90                   	nop
801044d7:	5d                   	pop    %ebp
801044d8:	c3                   	ret    

801044d9 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801044d9:	55                   	push   %ebp
801044da:	89 e5                	mov    %esp,%ebp
801044dc:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801044df:	9c                   	pushf  
801044e0:	58                   	pop    %eax
801044e1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801044e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801044e7:	c9                   	leave  
801044e8:	c3                   	ret    

801044e9 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
801044e9:	55                   	push   %ebp
801044ea:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801044ec:	fb                   	sti    
}
801044ed:	90                   	nop
801044ee:	5d                   	pop    %ebp
801044ef:	c3                   	ret    

801044f0 <pinit>:
addToStateListHead(struct proc** sList, struct proc* p);
#endif

void
pinit(void)
{
801044f0:	55                   	push   %ebp
801044f1:	89 e5                	mov    %esp,%ebp
801044f3:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
801044f6:	83 ec 08             	sub    $0x8,%esp
801044f9:	68 dc 98 10 80       	push   $0x801098dc
801044fe:	68 80 39 11 80       	push   $0x80113980
80104503:	e8 da 19 00 00       	call   80105ee2 <initlock>
80104508:	83 c4 10             	add    $0x10,%esp
}
8010450b:	90                   	nop
8010450c:	c9                   	leave  
8010450d:	c3                   	ret    

8010450e <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
8010450e:	55                   	push   %ebp
8010450f:	89 e5                	mov    %esp,%ebp
80104511:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;
  int rc;

  acquire(&ptable.lock);
80104514:	83 ec 0c             	sub    $0xc,%esp
80104517:	68 80 39 11 80       	push   $0x80113980
8010451c:	e8 e3 19 00 00       	call   80105f04 <acquire>
80104521:	83 c4 10             	add    $0x10,%esp

#ifdef CS333_P3P4
  //If there's nothing in the list
  if(ptable.pLists.free == 0)
80104524:	a1 b8 5e 11 80       	mov    0x80115eb8,%eax
80104529:	85 c0                	test   %eax,%eax
8010452b:	75 1a                	jne    80104547 <allocproc+0x39>
  {
    release(&ptable.lock);
8010452d:	83 ec 0c             	sub    $0xc,%esp
80104530:	68 80 39 11 80       	push   $0x80113980
80104535:	e8 31 1a 00 00       	call   80105f6b <release>
8010453a:	83 c4 10             	add    $0x10,%esp
    return 0;
8010453d:	b8 00 00 00 00       	mov    $0x0,%eax
80104542:	e9 f9 01 00 00       	jmp    80104740 <allocproc+0x232>
  }

  //Set p to the first item in the free list
  p = ptable.pLists.free;
80104547:	a1 b8 5e 11 80       	mov    0x80115eb8,%eax
8010454c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  goto found;
8010454f:	90                   	nop

#endif

found:
#ifdef CS333_P3P4
  assertState(p, UNUSED); //Check if p's state was really free
80104550:	83 ec 08             	sub    $0x8,%esp
80104553:	6a 00                	push   $0x0
80104555:	ff 75 f4             	pushl  -0xc(%ebp)
80104558:	e8 b9 16 00 00       	call   80105c16 <assertState>
8010455d:	83 c4 10             	add    $0x10,%esp
  
  //Free list now points to the next process after p
  //Effectively removing p from free list

  rc = removeFromStateList(&ptable.pLists.free, p);
80104560:	83 ec 08             	sub    $0x8,%esp
80104563:	ff 75 f4             	pushl  -0xc(%ebp)
80104566:	68 b8 5e 11 80       	push   $0x80115eb8
8010456b:	e8 f6 15 00 00       	call   80105b66 <removeFromStateList>
80104570:	83 c4 10             	add    $0x10,%esp
80104573:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(rc == -1)
80104576:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
8010457a:	75 0d                	jne    80104589 <allocproc+0x7b>
    panic("Could not remove from free list.");
8010457c:	83 ec 0c             	sub    $0xc,%esp
8010457f:	68 e4 98 10 80       	push   $0x801098e4
80104584:	e8 dd bf ff ff       	call   80100566 <panic>
  p->state = EMBRYO;
80104589:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010458c:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  rc = addToStateListHead(&ptable.pLists.embryo, p);
80104593:	83 ec 08             	sub    $0x8,%esp
80104596:	ff 75 f4             	pushl  -0xc(%ebp)
80104599:	68 c8 5e 11 80       	push   $0x80115ec8
8010459e:	e8 0f 17 00 00       	call   80105cb2 <addToStateListHead>
801045a3:	83 c4 10             	add    $0x10,%esp
801045a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(rc == -1)
801045a9:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
801045ad:	75 0d                	jne    801045bc <allocproc+0xae>
    panic("Could not add process to embryo.");
801045af:	83 ec 0c             	sub    $0xc,%esp
801045b2:	68 08 99 10 80       	push   $0x80109908
801045b7:	e8 aa bf ff ff       	call   80100566 <panic>

  assertState(p, EMBRYO);
801045bc:	83 ec 08             	sub    $0x8,%esp
801045bf:	6a 01                	push   $0x1
801045c1:	ff 75 f4             	pushl  -0xc(%ebp)
801045c4:	e8 4d 16 00 00       	call   80105c16 <assertState>
801045c9:	83 c4 10             	add    $0x10,%esp
  p->pid = nextpid++;
801045cc:	a1 04 c0 10 80       	mov    0x8010c004,%eax
801045d1:	8d 50 01             	lea    0x1(%eax),%edx
801045d4:	89 15 04 c0 10 80    	mov    %edx,0x8010c004
801045da:	89 c2                	mov    %eax,%edx
801045dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045df:	89 50 10             	mov    %edx,0x10(%eax)
#endif

  release(&ptable.lock);
801045e2:	83 ec 0c             	sub    $0xc,%esp
801045e5:	68 80 39 11 80       	push   $0x80113980
801045ea:	e8 7c 19 00 00       	call   80105f6b <release>
801045ef:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801045f2:	e8 03 e7 ff ff       	call   80102cfa <kalloc>
801045f7:	89 c2                	mov    %eax,%edx
801045f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045fc:	89 50 08             	mov    %edx,0x8(%eax)
801045ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104602:	8b 40 08             	mov    0x8(%eax),%eax
80104605:	85 c0                	test   %eax,%eax
80104607:	0f 85 96 00 00 00    	jne    801046a3 <allocproc+0x195>
    acquire(&ptable.lock);
8010460d:	83 ec 0c             	sub    $0xc,%esp
80104610:	68 80 39 11 80       	push   $0x80113980
80104615:	e8 ea 18 00 00       	call   80105f04 <acquire>
8010461a:	83 c4 10             	add    $0x10,%esp
#ifdef CS333_P3P4
    assertState(p, EMBRYO);
8010461d:	83 ec 08             	sub    $0x8,%esp
80104620:	6a 01                	push   $0x1
80104622:	ff 75 f4             	pushl  -0xc(%ebp)
80104625:	e8 ec 15 00 00       	call   80105c16 <assertState>
8010462a:	83 c4 10             	add    $0x10,%esp
    rc = removeFromStateList(&ptable.pLists.embryo, p);
8010462d:	83 ec 08             	sub    $0x8,%esp
80104630:	ff 75 f4             	pushl  -0xc(%ebp)
80104633:	68 c8 5e 11 80       	push   $0x80115ec8
80104638:	e8 29 15 00 00       	call   80105b66 <removeFromStateList>
8010463d:	83 c4 10             	add    $0x10,%esp
80104640:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(rc == -1)
80104643:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80104647:	75 0d                	jne    80104656 <allocproc+0x148>
      panic("Could not remove from embryo list.");
80104649:	83 ec 0c             	sub    $0xc,%esp
8010464c:	68 2c 99 10 80       	push   $0x8010992c
80104651:	e8 10 bf ff ff       	call   80100566 <panic>
#endif
    p->state = UNUSED;
80104656:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104659:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
#ifdef CS333_P3P4
    rc = addToStateListHead(&ptable.pLists.free, p);
80104660:	83 ec 08             	sub    $0x8,%esp
80104663:	ff 75 f4             	pushl  -0xc(%ebp)
80104666:	68 b8 5e 11 80       	push   $0x80115eb8
8010466b:	e8 42 16 00 00       	call   80105cb2 <addToStateListHead>
80104670:	83 c4 10             	add    $0x10,%esp
80104673:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(rc == -1)
80104676:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
8010467a:	75 0d                	jne    80104689 <allocproc+0x17b>
      panic("Could not add to free list.");
8010467c:	83 ec 0c             	sub    $0xc,%esp
8010467f:	68 4f 99 10 80       	push   $0x8010994f
80104684:	e8 dd be ff ff       	call   80100566 <panic>
#endif
    release(&ptable.lock);
80104689:	83 ec 0c             	sub    $0xc,%esp
8010468c:	68 80 39 11 80       	push   $0x80113980
80104691:	e8 d5 18 00 00       	call   80105f6b <release>
80104696:	83 c4 10             	add    $0x10,%esp
    return 0;
80104699:	b8 00 00 00 00       	mov    $0x0,%eax
8010469e:	e9 9d 00 00 00       	jmp    80104740 <allocproc+0x232>
  }
  sp = p->kstack + KSTACKSIZE;
801046a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046a6:	8b 40 08             	mov    0x8(%eax),%eax
801046a9:	05 00 10 00 00       	add    $0x1000,%eax
801046ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801046b1:	83 6d ec 4c          	subl   $0x4c,-0x14(%ebp)
  p->tf = (struct trapframe*)sp;
801046b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046b8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801046bb:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
801046be:	83 6d ec 04          	subl   $0x4,-0x14(%ebp)
  *(uint*)sp = (uint)trapret;
801046c2:	ba a9 76 10 80       	mov    $0x801076a9,%edx
801046c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801046ca:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801046cc:	83 6d ec 14          	subl   $0x14,-0x14(%ebp)
  p->context = (struct context*)sp;
801046d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d3:	8b 55 ec             	mov    -0x14(%ebp),%edx
801046d6:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
801046d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046dc:	8b 40 1c             	mov    0x1c(%eax),%eax
801046df:	83 ec 04             	sub    $0x4,%esp
801046e2:	6a 14                	push   $0x14
801046e4:	6a 00                	push   $0x0
801046e6:	50                   	push   %eax
801046e7:	e8 7b 1a 00 00       	call   80106167 <memset>
801046ec:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
801046ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046f2:	8b 40 1c             	mov    0x1c(%eax),%eax
801046f5:	ba b6 53 10 80       	mov    $0x801053b6,%edx
801046fa:	89 50 10             	mov    %edx,0x10(%eax)

#ifdef CS333_P1
  p->start_ticks = ticks;
801046fd:	8b 15 e0 66 11 80    	mov    0x801166e0,%edx
80104703:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104706:	89 50 7c             	mov    %edx,0x7c(%eax)
#endif

#ifdef CS333_P2
  p->uid = DEFAULT_UID;
80104709:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010470c:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80104713:	00 00 00 
  p->gid = DEFAULT_GID;
80104716:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104719:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
80104720:	00 00 00 
  p->cpu_ticks_total = 0;
80104723:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104726:	c7 80 88 00 00 00 00 	movl   $0x0,0x88(%eax)
8010472d:	00 00 00 
  p->cpu_ticks_in = 0;
80104730:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104733:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
8010473a:	00 00 00 
#endif

  return p;
8010473d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104740:	c9                   	leave  
80104741:	c3                   	ret    

80104742 <userinit>:

// Set up first user process.
void
userinit(void)
{
80104742:	55                   	push   %ebp
80104743:	89 e5                	mov    %esp,%ebp
80104745:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  int rc;

#ifdef CS333_P3P4
  acquire(&ptable.lock);
80104748:	83 ec 0c             	sub    $0xc,%esp
8010474b:	68 80 39 11 80       	push   $0x80113980
80104750:	e8 af 17 00 00       	call   80105f04 <acquire>
80104755:	83 c4 10             	add    $0x10,%esp

  //Initialize all 6 lists
  ptable.pLists.ready = 0;
80104758:	c7 05 b4 5e 11 80 00 	movl   $0x0,0x80115eb4
8010475f:	00 00 00 
  ptable.pLists.free = 0;
80104762:	c7 05 b8 5e 11 80 00 	movl   $0x0,0x80115eb8
80104769:	00 00 00 
  ptable.pLists.sleep = 0;
8010476c:	c7 05 bc 5e 11 80 00 	movl   $0x0,0x80115ebc
80104773:	00 00 00 
  ptable.pLists.zombie = 0;
80104776:	c7 05 c0 5e 11 80 00 	movl   $0x0,0x80115ec0
8010477d:	00 00 00 
  ptable.pLists.running = 0;
80104780:	c7 05 c4 5e 11 80 00 	movl   $0x0,0x80115ec4
80104787:	00 00 00 
  ptable.pLists.embryo = 0;
8010478a:	c7 05 c8 5e 11 80 00 	movl   $0x0,0x80115ec8
80104791:	00 00 00 

  //Storing all 64 processes into the free list
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) 
80104794:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
8010479b:	eb 30                	jmp    801047cd <userinit+0x8b>
  {
    rc = addToStateListHead(&ptable.pLists.free, p);
8010479d:	83 ec 08             	sub    $0x8,%esp
801047a0:	ff 75 f4             	pushl  -0xc(%ebp)
801047a3:	68 b8 5e 11 80       	push   $0x80115eb8
801047a8:	e8 05 15 00 00       	call   80105cb2 <addToStateListHead>
801047ad:	83 c4 10             	add    $0x10,%esp
801047b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(rc == -1)
801047b3:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
801047b7:	75 0d                	jne    801047c6 <userinit+0x84>
      panic("Could not add to free list.");
801047b9:	83 ec 0c             	sub    $0xc,%esp
801047bc:	68 4f 99 10 80       	push   $0x8010994f
801047c1:	e8 a0 bd ff ff       	call   80100566 <panic>
  ptable.pLists.zombie = 0;
  ptable.pLists.running = 0;
  ptable.pLists.embryo = 0;

  //Storing all 64 processes into the free list
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) 
801047c6:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
801047cd:	81 7d f4 b4 5e 11 80 	cmpl   $0x80115eb4,-0xc(%ebp)
801047d4:	72 c7                	jb     8010479d <userinit+0x5b>
      panic("Could not add to free list.");
  }
  //All processes should be on the free list
  //ptable array is "still there" but processes will be managed by lists

  release(&ptable.lock);
801047d6:	83 ec 0c             	sub    $0xc,%esp
801047d9:	68 80 39 11 80       	push   $0x80113980
801047de:	e8 88 17 00 00       	call   80105f6b <release>
801047e3:	83 c4 10             	add    $0x10,%esp

#endif  

  p = allocproc();
801047e6:	e8 23 fd ff ff       	call   8010450e <allocproc>
801047eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
801047ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047f1:	a3 68 c6 10 80       	mov    %eax,0x8010c668
  if((p->pgdir = setupkvm()) == 0)
801047f6:	e8 70 45 00 00       	call   80108d6b <setupkvm>
801047fb:	89 c2                	mov    %eax,%edx
801047fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104800:	89 50 04             	mov    %edx,0x4(%eax)
80104803:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104806:	8b 40 04             	mov    0x4(%eax),%eax
80104809:	85 c0                	test   %eax,%eax
8010480b:	75 0d                	jne    8010481a <userinit+0xd8>
    panic("userinit: out of memory?");
8010480d:	83 ec 0c             	sub    $0xc,%esp
80104810:	68 6b 99 10 80       	push   $0x8010996b
80104815:	e8 4c bd ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
8010481a:	ba 2c 00 00 00       	mov    $0x2c,%edx
8010481f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104822:	8b 40 04             	mov    0x4(%eax),%eax
80104825:	83 ec 04             	sub    $0x4,%esp
80104828:	52                   	push   %edx
80104829:	68 00 c5 10 80       	push   $0x8010c500
8010482e:	50                   	push   %eax
8010482f:	e8 91 47 00 00       	call   80108fc5 <inituvm>
80104834:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104837:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010483a:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104840:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104843:	8b 40 18             	mov    0x18(%eax),%eax
80104846:	83 ec 04             	sub    $0x4,%esp
80104849:	6a 4c                	push   $0x4c
8010484b:	6a 00                	push   $0x0
8010484d:	50                   	push   %eax
8010484e:	e8 14 19 00 00       	call   80106167 <memset>
80104853:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104856:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104859:	8b 40 18             	mov    0x18(%eax),%eax
8010485c:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104862:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104865:	8b 40 18             	mov    0x18(%eax),%eax
80104868:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010486e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104871:	8b 40 18             	mov    0x18(%eax),%eax
80104874:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104877:	8b 52 18             	mov    0x18(%edx),%edx
8010487a:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010487e:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104882:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104885:	8b 40 18             	mov    0x18(%eax),%eax
80104888:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010488b:	8b 52 18             	mov    0x18(%edx),%edx
8010488e:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104892:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104896:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104899:	8b 40 18             	mov    0x18(%eax),%eax
8010489c:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801048a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048a6:	8b 40 18             	mov    0x18(%eax),%eax
801048a9:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801048b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048b3:	8b 40 18             	mov    0x18(%eax),%eax
801048b6:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801048bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048c0:	83 c0 6c             	add    $0x6c,%eax
801048c3:	83 ec 04             	sub    $0x4,%esp
801048c6:	6a 10                	push   $0x10
801048c8:	68 84 99 10 80       	push   $0x80109984
801048cd:	50                   	push   %eax
801048ce:	e8 97 1a 00 00       	call   8010636a <safestrcpy>
801048d3:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
801048d6:	83 ec 0c             	sub    $0xc,%esp
801048d9:	68 8d 99 10 80       	push   $0x8010998d
801048de:	e8 d9 dc ff ff       	call   801025bc <namei>
801048e3:	83 c4 10             	add    $0x10,%esp
801048e6:	89 c2                	mov    %eax,%edx
801048e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048eb:	89 50 68             	mov    %edx,0x68(%eax)
  
#ifdef CS333_P2
  p->uid = DEFAULT_UID;
801048ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048f1:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
801048f8:	00 00 00 
  p->gid = DEFAULT_GID;
801048fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048fe:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
80104905:	00 00 00 
  p->parent = p;
80104908:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010490b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010490e:	89 50 14             	mov    %edx,0x14(%eax)
#endif

#ifdef CS333_P3P4
  //After p becomes runnable, it needs to be put on the ready list
  acquire(&ptable.lock);
80104911:	83 ec 0c             	sub    $0xc,%esp
80104914:	68 80 39 11 80       	push   $0x80113980
80104919:	e8 e6 15 00 00       	call   80105f04 <acquire>
8010491e:	83 c4 10             	add    $0x10,%esp

  assertState(p, EMBRYO);
80104921:	83 ec 08             	sub    $0x8,%esp
80104924:	6a 01                	push   $0x1
80104926:	ff 75 f4             	pushl  -0xc(%ebp)
80104929:	e8 e8 12 00 00       	call   80105c16 <assertState>
8010492e:	83 c4 10             	add    $0x10,%esp
  rc = removeFromStateList(&ptable.pLists.embryo, p);
80104931:	83 ec 08             	sub    $0x8,%esp
80104934:	ff 75 f4             	pushl  -0xc(%ebp)
80104937:	68 c8 5e 11 80       	push   $0x80115ec8
8010493c:	e8 25 12 00 00       	call   80105b66 <removeFromStateList>
80104941:	83 c4 10             	add    $0x10,%esp
80104944:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(rc == -1)
80104947:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
8010494b:	75 0d                	jne    8010495a <userinit+0x218>
    panic("Could not remove process from embryo list");
8010494d:	83 ec 0c             	sub    $0xc,%esp
80104950:	68 90 99 10 80       	push   $0x80109990
80104955:	e8 0c bc ff ff       	call   80100566 <panic>

  p->state = RUNNABLE;
8010495a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010495d:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  rc = addToStateListHead(&ptable.pLists.ready, p);
80104964:	83 ec 08             	sub    $0x8,%esp
80104967:	ff 75 f4             	pushl  -0xc(%ebp)
8010496a:	68 b4 5e 11 80       	push   $0x80115eb4
8010496f:	e8 3e 13 00 00       	call   80105cb2 <addToStateListHead>
80104974:	83 c4 10             	add    $0x10,%esp
80104977:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(rc == -1)
8010497a:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
8010497e:	75 0d                	jne    8010498d <userinit+0x24b>
    panic("Could not add process to free list.");
80104980:	83 ec 0c             	sub    $0xc,%esp
80104983:	68 bc 99 10 80       	push   $0x801099bc
80104988:	e8 d9 bb ff ff       	call   80100566 <panic>

  release(&ptable.lock);
8010498d:	83 ec 0c             	sub    $0xc,%esp
80104990:	68 80 39 11 80       	push   $0x80113980
80104995:	e8 d1 15 00 00       	call   80105f6b <release>
8010499a:	83 c4 10             	add    $0x10,%esp
#endif

}
8010499d:	90                   	nop
8010499e:	c9                   	leave  
8010499f:	c3                   	ret    

801049a0 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801049a0:	55                   	push   %ebp
801049a1:	89 e5                	mov    %esp,%ebp
801049a3:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
801049a6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049ac:	8b 00                	mov    (%eax),%eax
801049ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801049b1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801049b5:	7e 31                	jle    801049e8 <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801049b7:	8b 55 08             	mov    0x8(%ebp),%edx
801049ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049bd:	01 c2                	add    %eax,%edx
801049bf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049c5:	8b 40 04             	mov    0x4(%eax),%eax
801049c8:	83 ec 04             	sub    $0x4,%esp
801049cb:	52                   	push   %edx
801049cc:	ff 75 f4             	pushl  -0xc(%ebp)
801049cf:	50                   	push   %eax
801049d0:	e8 3d 47 00 00       	call   80109112 <allocuvm>
801049d5:	83 c4 10             	add    $0x10,%esp
801049d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801049db:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801049df:	75 3e                	jne    80104a1f <growproc+0x7f>
      return -1;
801049e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049e6:	eb 59                	jmp    80104a41 <growproc+0xa1>
  } else if(n < 0){
801049e8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801049ec:	79 31                	jns    80104a1f <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
801049ee:	8b 55 08             	mov    0x8(%ebp),%edx
801049f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049f4:	01 c2                	add    %eax,%edx
801049f6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049fc:	8b 40 04             	mov    0x4(%eax),%eax
801049ff:	83 ec 04             	sub    $0x4,%esp
80104a02:	52                   	push   %edx
80104a03:	ff 75 f4             	pushl  -0xc(%ebp)
80104a06:	50                   	push   %eax
80104a07:	e8 cf 47 00 00       	call   801091db <deallocuvm>
80104a0c:	83 c4 10             	add    $0x10,%esp
80104a0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104a12:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104a16:	75 07                	jne    80104a1f <growproc+0x7f>
      return -1;
80104a18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a1d:	eb 22                	jmp    80104a41 <growproc+0xa1>
  }
  proc->sz = sz;
80104a1f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a25:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a28:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104a2a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a30:	83 ec 0c             	sub    $0xc,%esp
80104a33:	50                   	push   %eax
80104a34:	e8 19 44 00 00       	call   80108e52 <switchuvm>
80104a39:	83 c4 10             	add    $0x10,%esp
  return 0;
80104a3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a41:	c9                   	leave  
80104a42:	c3                   	ret    

80104a43 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104a43:	55                   	push   %ebp
80104a44:	89 e5                	mov    %esp,%ebp
80104a46:	57                   	push   %edi
80104a47:	56                   	push   %esi
80104a48:	53                   	push   %ebx
80104a49:	83 ec 2c             	sub    $0x2c,%esp
  struct proc *p;
  int rc;
#endif

  // Allocate process.
  if((np = allocproc()) == 0)
80104a4c:	e8 bd fa ff ff       	call   8010450e <allocproc>
80104a51:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104a54:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104a58:	75 0a                	jne    80104a64 <fork+0x21>
    return -1;
80104a5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a5f:	e9 0a 02 00 00       	jmp    80104c6e <fork+0x22b>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104a64:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a6a:	8b 10                	mov    (%eax),%edx
80104a6c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a72:	8b 40 04             	mov    0x4(%eax),%eax
80104a75:	83 ec 08             	sub    $0x8,%esp
80104a78:	52                   	push   %edx
80104a79:	50                   	push   %eax
80104a7a:	e8 fa 48 00 00       	call   80109379 <copyuvm>
80104a7f:	83 c4 10             	add    $0x10,%esp
80104a82:	89 c2                	mov    %eax,%edx
80104a84:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a87:	89 50 04             	mov    %edx,0x4(%eax)
80104a8a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a8d:	8b 40 04             	mov    0x4(%eax),%eax
80104a90:	85 c0                	test   %eax,%eax
80104a92:	75 30                	jne    80104ac4 <fork+0x81>
    kfree(np->kstack);
80104a94:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a97:	8b 40 08             	mov    0x8(%eax),%eax
80104a9a:	83 ec 0c             	sub    $0xc,%esp
80104a9d:	50                   	push   %eax
80104a9e:	e8 ba e1 ff ff       	call   80102c5d <kfree>
80104aa3:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80104aa6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104aa9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;//TODO
80104ab0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104ab3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104aba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104abf:	e9 aa 01 00 00       	jmp    80104c6e <fork+0x22b>
  }
  np->sz = proc->sz;
80104ac4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104aca:	8b 10                	mov    (%eax),%edx
80104acc:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104acf:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104ad1:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104ad8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104adb:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104ade:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104ae1:	8b 50 18             	mov    0x18(%eax),%edx
80104ae4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104aea:	8b 40 18             	mov    0x18(%eax),%eax
80104aed:	89 c3                	mov    %eax,%ebx
80104aef:	b8 13 00 00 00       	mov    $0x13,%eax
80104af4:	89 d7                	mov    %edx,%edi
80104af6:	89 de                	mov    %ebx,%esi
80104af8:	89 c1                	mov    %eax,%ecx
80104afa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104afc:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104aff:	8b 40 18             	mov    0x18(%eax),%eax
80104b02:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104b09:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104b10:	eb 43                	jmp    80104b55 <fork+0x112>
    if(proc->ofile[i])
80104b12:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b18:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104b1b:	83 c2 08             	add    $0x8,%edx
80104b1e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104b22:	85 c0                	test   %eax,%eax
80104b24:	74 2b                	je     80104b51 <fork+0x10e>
      np->ofile[i] = filedup(proc->ofile[i]);
80104b26:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b2c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104b2f:	83 c2 08             	add    $0x8,%edx
80104b32:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104b36:	83 ec 0c             	sub    $0xc,%esp
80104b39:	50                   	push   %eax
80104b3a:	e8 55 c5 ff ff       	call   80101094 <filedup>
80104b3f:	83 c4 10             	add    $0x10,%esp
80104b42:	89 c1                	mov    %eax,%ecx
80104b44:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b47:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104b4a:	83 c2 08             	add    $0x8,%edx
80104b4d:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104b51:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104b55:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104b59:	7e b7                	jle    80104b12 <fork+0xcf>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104b5b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b61:	8b 40 68             	mov    0x68(%eax),%eax
80104b64:	83 ec 0c             	sub    $0xc,%esp
80104b67:	50                   	push   %eax
80104b68:	e8 57 ce ff ff       	call   801019c4 <idup>
80104b6d:	83 c4 10             	add    $0x10,%esp
80104b70:	89 c2                	mov    %eax,%edx
80104b72:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b75:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104b78:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b7e:	8d 50 6c             	lea    0x6c(%eax),%edx
80104b81:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b84:	83 c0 6c             	add    $0x6c,%eax
80104b87:	83 ec 04             	sub    $0x4,%esp
80104b8a:	6a 10                	push   $0x10
80104b8c:	52                   	push   %edx
80104b8d:	50                   	push   %eax
80104b8e:	e8 d7 17 00 00       	call   8010636a <safestrcpy>
80104b93:	83 c4 10             	add    $0x10,%esp
 
  pid = np->pid;
80104b96:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b99:	8b 40 10             	mov    0x10(%eax),%eax
80104b9c:	89 45 dc             	mov    %eax,-0x24(%ebp)

#ifdef CS333_P2
  np->uid = proc->uid;
80104b9f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ba5:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80104bab:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104bae:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  np->gid = proc->gid;
80104bb4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bba:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80104bc0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104bc3:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
#endif

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80104bc9:	83 ec 0c             	sub    $0xc,%esp
80104bcc:	68 80 39 11 80       	push   $0x80113980
80104bd1:	e8 2e 13 00 00       	call   80105f04 <acquire>
80104bd6:	83 c4 10             	add    $0x10,%esp

#ifdef CS333_P3P4
  //Remove the process from the embryo list
  p = np;
80104bd9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104bdc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  assertState(p, EMBRYO);
80104bdf:	83 ec 08             	sub    $0x8,%esp
80104be2:	6a 01                	push   $0x1
80104be4:	ff 75 d8             	pushl  -0x28(%ebp)
80104be7:	e8 2a 10 00 00       	call   80105c16 <assertState>
80104bec:	83 c4 10             	add    $0x10,%esp
  rc = removeFromStateList(&ptable.pLists.embryo, p);
80104bef:	83 ec 08             	sub    $0x8,%esp
80104bf2:	ff 75 d8             	pushl  -0x28(%ebp)
80104bf5:	68 c8 5e 11 80       	push   $0x80115ec8
80104bfa:	e8 67 0f 00 00       	call   80105b66 <removeFromStateList>
80104bff:	83 c4 10             	add    $0x10,%esp
80104c02:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  if(rc == -1)
80104c05:	83 7d d4 ff          	cmpl   $0xffffffff,-0x2c(%ebp)
80104c09:	75 0d                	jne    80104c18 <fork+0x1d5>
    panic("Could not remove process from embryo.");
80104c0b:	83 ec 0c             	sub    $0xc,%esp
80104c0e:	68 e0 99 10 80       	push   $0x801099e0
80104c13:	e8 4e b9 ff ff       	call   80100566 <panic>
#endif
  np->state = RUNNABLE;
80104c18:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104c1b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

#ifdef CS333_P3P4
  //Add process to ready list
  assertState(p, RUNNABLE);
80104c22:	83 ec 08             	sub    $0x8,%esp
80104c25:	6a 03                	push   $0x3
80104c27:	ff 75 d8             	pushl  -0x28(%ebp)
80104c2a:	e8 e7 0f 00 00       	call   80105c16 <assertState>
80104c2f:	83 c4 10             	add    $0x10,%esp
  rc = addToStateListEnd(&ptable.pLists.ready, p);
80104c32:	83 ec 08             	sub    $0x8,%esp
80104c35:	ff 75 d8             	pushl  -0x28(%ebp)
80104c38:	68 b4 5e 11 80       	push   $0x80115eb4
80104c3d:	e8 f5 0f 00 00       	call   80105c37 <addToStateListEnd>
80104c42:	83 c4 10             	add    $0x10,%esp
80104c45:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  if(rc == -1)
80104c48:	83 7d d4 ff          	cmpl   $0xffffffff,-0x2c(%ebp)
80104c4c:	75 0d                	jne    80104c5b <fork+0x218>
    panic("Could not add process to ready list.");
80104c4e:	83 ec 0c             	sub    $0xc,%esp
80104c51:	68 08 9a 10 80       	push   $0x80109a08
80104c56:	e8 0b b9 ff ff       	call   80100566 <panic>
#endif

  release(&ptable.lock);
80104c5b:	83 ec 0c             	sub    $0xc,%esp
80104c5e:	68 80 39 11 80       	push   $0x80113980
80104c63:	e8 03 13 00 00       	call   80105f6b <release>
80104c68:	83 c4 10             	add    $0x10,%esp
  
  return pid;
80104c6b:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80104c6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104c71:	5b                   	pop    %ebx
80104c72:	5e                   	pop    %esi
80104c73:	5f                   	pop    %edi
80104c74:	5d                   	pop    %ebp
80104c75:	c3                   	ret    

80104c76 <exit>:
  panic("zombie exit");
}
#else
void
exit(void) //Project 3
{
80104c76:	55                   	push   %ebp
80104c77:	89 e5                	mov    %esp,%ebp
80104c79:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
80104c7c:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104c83:	a1 68 c6 10 80       	mov    0x8010c668,%eax
80104c88:	39 c2                	cmp    %eax,%edx
80104c8a:	75 0d                	jne    80104c99 <exit+0x23>
    panic("init exiting");
80104c8c:	83 ec 0c             	sub    $0xc,%esp
80104c8f:	68 2d 9a 10 80       	push   $0x80109a2d
80104c94:	e8 cd b8 ff ff       	call   80100566 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104c99:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104ca0:	eb 48                	jmp    80104cea <exit+0x74>
    if(proc->ofile[fd]){
80104ca2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ca8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cab:	83 c2 08             	add    $0x8,%edx
80104cae:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104cb2:	85 c0                	test   %eax,%eax
80104cb4:	74 30                	je     80104ce6 <exit+0x70>
      fileclose(proc->ofile[fd]);
80104cb6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cbc:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cbf:	83 c2 08             	add    $0x8,%edx
80104cc2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104cc6:	83 ec 0c             	sub    $0xc,%esp
80104cc9:	50                   	push   %eax
80104cca:	e8 16 c4 ff ff       	call   801010e5 <fileclose>
80104ccf:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
80104cd2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cd8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cdb:	83 c2 08             	add    $0x8,%edx
80104cde:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104ce5:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104ce6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104cea:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104cee:	7e b2                	jle    80104ca2 <exit+0x2c>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
80104cf0:	e8 ec e8 ff ff       	call   801035e1 <begin_op>
  iput(proc->cwd);
80104cf5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cfb:	8b 40 68             	mov    0x68(%eax),%eax
80104cfe:	83 ec 0c             	sub    $0xc,%esp
80104d01:	50                   	push   %eax
80104d02:	e8 c7 ce ff ff       	call   80101bce <iput>
80104d07:	83 c4 10             	add    $0x10,%esp
  end_op();
80104d0a:	e8 5e e9 ff ff       	call   8010366d <end_op>
  proc->cwd = 0;
80104d0f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d15:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104d1c:	83 ec 0c             	sub    $0xc,%esp
80104d1f:	68 80 39 11 80       	push   $0x80113980
80104d24:	e8 db 11 00 00       	call   80105f04 <acquire>
80104d29:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104d2c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d32:	8b 40 14             	mov    0x14(%eax),%eax
80104d35:	83 ec 0c             	sub    $0xc,%esp
80104d38:	50                   	push   %eax
80104d39:	e8 63 07 00 00       	call   801054a1 <wakeup1>
80104d3e:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  
  p = ptable.pLists.ready;
80104d41:	a1 b4 5e 11 80       	mov    0x80115eb4,%eax
80104d46:	89 45 f0             	mov    %eax,-0x10(%ebp)
  assertState(p, RUNNABLE);
80104d49:	83 ec 08             	sub    $0x8,%esp
80104d4c:	6a 03                	push   $0x3
80104d4e:	ff 75 f0             	pushl  -0x10(%ebp)
80104d51:	e8 c0 0e 00 00       	call   80105c16 <assertState>
80104d56:	83 c4 10             	add    $0x10,%esp

  while(p != 0)
80104d59:	eb 1c                	jmp    80104d77 <exit+0x101>
  {
    if(p->parent == proc)
80104d5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d5e:	8b 50 14             	mov    0x14(%eax),%edx
80104d61:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d67:	39 c2                	cmp    %eax,%edx
80104d69:	75 0c                	jne    80104d77 <exit+0x101>
      p->parent = initproc;
80104d6b:	8b 15 68 c6 10 80    	mov    0x8010c668,%edx
80104d71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d74:	89 50 14             	mov    %edx,0x14(%eax)
  // Pass abandoned children to init.
  
  p = ptable.pLists.ready;
  assertState(p, RUNNABLE);

  while(p != 0)
80104d77:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104d7b:	75 de                	jne    80104d5b <exit+0xe5>
  {
    if(p->parent == proc)
      p->parent = initproc;
  }

  p = ptable.pLists.sleep;
80104d7d:	a1 bc 5e 11 80       	mov    0x80115ebc,%eax
80104d82:	89 45 f0             	mov    %eax,-0x10(%ebp)
  assertState(p, SLEEPING);
80104d85:	83 ec 08             	sub    $0x8,%esp
80104d88:	6a 02                	push   $0x2
80104d8a:	ff 75 f0             	pushl  -0x10(%ebp)
80104d8d:	e8 84 0e 00 00       	call   80105c16 <assertState>
80104d92:	83 c4 10             	add    $0x10,%esp

  while(p != 0)
80104d95:	eb 1c                	jmp    80104db3 <exit+0x13d>
  {
    if(p->parent == proc)
80104d97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d9a:	8b 50 14             	mov    0x14(%eax),%edx
80104d9d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104da3:	39 c2                	cmp    %eax,%edx
80104da5:	75 0c                	jne    80104db3 <exit+0x13d>
      p->parent = initproc;
80104da7:	8b 15 68 c6 10 80    	mov    0x8010c668,%edx
80104dad:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104db0:	89 50 14             	mov    %edx,0x14(%eax)
  }

  p = ptable.pLists.sleep;
  assertState(p, SLEEPING);

  while(p != 0)
80104db3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104db7:	75 de                	jne    80104d97 <exit+0x121>
  {
    if(p->parent == proc)
      p->parent = initproc;
  }

  p = ptable.pLists.embryo;
80104db9:	a1 c8 5e 11 80       	mov    0x80115ec8,%eax
80104dbe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  assertState(p, EMBRYO);
80104dc1:	83 ec 08             	sub    $0x8,%esp
80104dc4:	6a 01                	push   $0x1
80104dc6:	ff 75 f0             	pushl  -0x10(%ebp)
80104dc9:	e8 48 0e 00 00       	call   80105c16 <assertState>
80104dce:	83 c4 10             	add    $0x10,%esp

  while(p != 0)
80104dd1:	eb 1c                	jmp    80104def <exit+0x179>
  {
    if(p->parent == proc)
80104dd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dd6:	8b 50 14             	mov    0x14(%eax),%edx
80104dd9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ddf:	39 c2                	cmp    %eax,%edx
80104de1:	75 0c                	jne    80104def <exit+0x179>
      p->parent = initproc;
80104de3:	8b 15 68 c6 10 80    	mov    0x8010c668,%edx
80104de9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dec:	89 50 14             	mov    %edx,0x14(%eax)
  }

  p = ptable.pLists.embryo;
  assertState(p, EMBRYO);

  while(p != 0)
80104def:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104df3:	75 de                	jne    80104dd3 <exit+0x15d>
  {
    if(p->parent == proc)
      p->parent = initproc;
  }

  p = ptable.pLists.running;
80104df5:	a1 c4 5e 11 80       	mov    0x80115ec4,%eax
80104dfa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  assertState(p, RUNNING);
80104dfd:	83 ec 08             	sub    $0x8,%esp
80104e00:	6a 04                	push   $0x4
80104e02:	ff 75 f0             	pushl  -0x10(%ebp)
80104e05:	e8 0c 0e 00 00       	call   80105c16 <assertState>
80104e0a:	83 c4 10             	add    $0x10,%esp

  while(p != 0)
80104e0d:	eb 1c                	jmp    80104e2b <exit+0x1b5>
  {
    if(p->parent == proc)
80104e0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e12:	8b 50 14             	mov    0x14(%eax),%edx
80104e15:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e1b:	39 c2                	cmp    %eax,%edx
80104e1d:	75 0c                	jne    80104e2b <exit+0x1b5>
      p->parent = initproc;
80104e1f:	8b 15 68 c6 10 80    	mov    0x8010c668,%edx
80104e25:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e28:	89 50 14             	mov    %edx,0x14(%eax)
  }

  p = ptable.pLists.running;
  assertState(p, RUNNING);

  while(p != 0)
80104e2b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104e2f:	75 de                	jne    80104e0f <exit+0x199>
  {
    if(p->parent == proc)
      p->parent = initproc;
  }

  p = ptable.pLists.zombie;
80104e31:	a1 c0 5e 11 80       	mov    0x80115ec0,%eax
80104e36:	89 45 f0             	mov    %eax,-0x10(%ebp)
  assertState(p, ZOMBIE);
80104e39:	83 ec 08             	sub    $0x8,%esp
80104e3c:	6a 05                	push   $0x5
80104e3e:	ff 75 f0             	pushl  -0x10(%ebp)
80104e41:	e8 d0 0d 00 00       	call   80105c16 <assertState>
80104e46:	83 c4 10             	add    $0x10,%esp

  while(p != 0)
80104e49:	eb 2d                	jmp    80104e78 <exit+0x202>
  {
    if(p->parent == proc)
80104e4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e4e:	8b 50 14             	mov    0x14(%eax),%edx
80104e51:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e57:	39 c2                	cmp    %eax,%edx
80104e59:	75 1d                	jne    80104e78 <exit+0x202>
    {
      p->parent = initproc;
80104e5b:	8b 15 68 c6 10 80    	mov    0x8010c668,%edx
80104e61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e64:	89 50 14             	mov    %edx,0x14(%eax)
      wakeup1(initproc);
80104e67:	a1 68 c6 10 80       	mov    0x8010c668,%eax
80104e6c:	83 ec 0c             	sub    $0xc,%esp
80104e6f:	50                   	push   %eax
80104e70:	e8 2c 06 00 00       	call   801054a1 <wakeup1>
80104e75:	83 c4 10             	add    $0x10,%esp
  }

  p = ptable.pLists.zombie;
  assertState(p, ZOMBIE);

  while(p != 0)
80104e78:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104e7c:	75 cd                	jne    80104e4b <exit+0x1d5>
      wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104e7e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e84:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104e8b:	e8 9e 03 00 00       	call   8010522e <sched>
  panic("zombie exit");
80104e90:	83 ec 0c             	sub    $0xc,%esp
80104e93:	68 3a 9a 10 80       	push   $0x80109a3a
80104e98:	e8 c9 b6 ff ff       	call   80100566 <panic>

80104e9d <wait>:
  }
}
#else
int
wait(void) //Project 3
{
80104e9d:	55                   	push   %ebp
80104e9e:	89 e5                	mov    %esp,%ebp
80104ea0:	83 ec 18             	sub    $0x18,%esp
  //struct proc *p;
  struct proc *current;
  int havekids, pid;
  int rc;

  acquire(&ptable.lock);
80104ea3:	83 ec 0c             	sub    $0xc,%esp
80104ea6:	68 80 39 11 80       	push   $0x80113980
80104eab:	e8 54 10 00 00       	call   80105f04 <acquire>
80104eb0:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104eb3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    current = ptable.pLists.ready;
80104eba:	a1 b4 5e 11 80       	mov    0x80115eb4,%eax
80104ebf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assertState(current, RUNNABLE);
80104ec2:	83 ec 08             	sub    $0x8,%esp
80104ec5:	6a 03                	push   $0x3
80104ec7:	ff 75 f0             	pushl  -0x10(%ebp)
80104eca:	e8 47 0d 00 00       	call   80105c16 <assertState>
80104ecf:	83 c4 10             	add    $0x10,%esp

    while(current != 0)
80104ed2:	eb 17                	jmp    80104eeb <wait+0x4e>
    {
      if(current->parent == proc)
80104ed4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ed7:	8b 50 14             	mov    0x14(%eax),%edx
80104eda:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ee0:	39 c2                	cmp    %eax,%edx
80104ee2:	75 07                	jne    80104eeb <wait+0x4e>
        havekids = 1;
80104ee4:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    havekids = 0;

    current = ptable.pLists.ready;
    assertState(current, RUNNABLE);

    while(current != 0)
80104eeb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104eef:	75 e3                	jne    80104ed4 <wait+0x37>
    {
      if(current->parent == proc)
        havekids = 1;
    }

    current = ptable.pLists.sleep;
80104ef1:	a1 bc 5e 11 80       	mov    0x80115ebc,%eax
80104ef6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assertState(current, SLEEPING);
80104ef9:	83 ec 08             	sub    $0x8,%esp
80104efc:	6a 02                	push   $0x2
80104efe:	ff 75 f0             	pushl  -0x10(%ebp)
80104f01:	e8 10 0d 00 00       	call   80105c16 <assertState>
80104f06:	83 c4 10             	add    $0x10,%esp

    while(current != 0)
80104f09:	eb 17                	jmp    80104f22 <wait+0x85>
    {
      if(current->parent == proc)
80104f0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f0e:	8b 50 14             	mov    0x14(%eax),%edx
80104f11:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f17:	39 c2                	cmp    %eax,%edx
80104f19:	75 07                	jne    80104f22 <wait+0x85>
        havekids = 1;
80104f1b:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    }

    current = ptable.pLists.sleep;
    assertState(current, SLEEPING);

    while(current != 0)
80104f22:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104f26:	75 e3                	jne    80104f0b <wait+0x6e>
    {
      if(current->parent == proc)
        havekids = 1;
    }

    current = ptable.pLists.embryo;
80104f28:	a1 c8 5e 11 80       	mov    0x80115ec8,%eax
80104f2d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assertState(current, EMBRYO);
80104f30:	83 ec 08             	sub    $0x8,%esp
80104f33:	6a 01                	push   $0x1
80104f35:	ff 75 f0             	pushl  -0x10(%ebp)
80104f38:	e8 d9 0c 00 00       	call   80105c16 <assertState>
80104f3d:	83 c4 10             	add    $0x10,%esp

    while(current != 0)
80104f40:	eb 17                	jmp    80104f59 <wait+0xbc>
    {
      if(current->parent == proc)
80104f42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f45:	8b 50 14             	mov    0x14(%eax),%edx
80104f48:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f4e:	39 c2                	cmp    %eax,%edx
80104f50:	75 07                	jne    80104f59 <wait+0xbc>
        havekids = 1;
80104f52:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    }

    current = ptable.pLists.embryo;
    assertState(current, EMBRYO);

    while(current != 0)
80104f59:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104f5d:	75 e3                	jne    80104f42 <wait+0xa5>
    {
      if(current->parent == proc)
        havekids = 1;
    }

    current = ptable.pLists.running;
80104f5f:	a1 c4 5e 11 80       	mov    0x80115ec4,%eax
80104f64:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assertState(current, RUNNING);
80104f67:	83 ec 08             	sub    $0x8,%esp
80104f6a:	6a 04                	push   $0x4
80104f6c:	ff 75 f0             	pushl  -0x10(%ebp)
80104f6f:	e8 a2 0c 00 00       	call   80105c16 <assertState>
80104f74:	83 c4 10             	add    $0x10,%esp

    while(current != 0)
80104f77:	eb 17                	jmp    80104f90 <wait+0xf3>
    {
      if(current->parent == proc)
80104f79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f7c:	8b 50 14             	mov    0x14(%eax),%edx
80104f7f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f85:	39 c2                	cmp    %eax,%edx
80104f87:	75 07                	jne    80104f90 <wait+0xf3>
        havekids = 1;
80104f89:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    }

    current = ptable.pLists.running;
    assertState(current, RUNNING);

    while(current != 0)
80104f90:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104f94:	75 e3                	jne    80104f79 <wait+0xdc>
    {
      if(current->parent == proc)
        havekids = 1;
    }

    current = ptable.pLists.zombie;
80104f96:	a1 c0 5e 11 80       	mov    0x80115ec0,%eax
80104f9b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assertState(current, ZOMBIE);
80104f9e:	83 ec 08             	sub    $0x8,%esp
80104fa1:	6a 05                	push   $0x5
80104fa3:	ff 75 f0             	pushl  -0x10(%ebp)
80104fa6:	e8 6b 0c 00 00       	call   80105c16 <assertState>
80104fab:	83 c4 10             	add    $0x10,%esp

    while(current != 0)
80104fae:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104fb2:	0f 84 e4 00 00 00    	je     8010509c <wait+0x1ff>
    {
      if(current->parent == proc)
80104fb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fbb:	8b 50 14             	mov    0x14(%eax),%edx
80104fbe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fc4:	39 c2                	cmp    %eax,%edx
80104fc6:	75 07                	jne    80104fcf <wait+0x132>
        havekids = 1;
80104fc8:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)

      rc = removeFromStateList(&ptable.pLists.zombie, current);
80104fcf:	83 ec 08             	sub    $0x8,%esp
80104fd2:	ff 75 f0             	pushl  -0x10(%ebp)
80104fd5:	68 c0 5e 11 80       	push   $0x80115ec0
80104fda:	e8 87 0b 00 00       	call   80105b66 <removeFromStateList>
80104fdf:	83 c4 10             	add    $0x10,%esp
80104fe2:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(rc == -1)
80104fe5:	83 7d ec ff          	cmpl   $0xffffffff,-0x14(%ebp)
80104fe9:	75 0d                	jne    80104ff8 <wait+0x15b>
        panic("Could not remove from zombie list.");
80104feb:	83 ec 0c             	sub    $0xc,%esp
80104fee:	68 48 9a 10 80       	push   $0x80109a48
80104ff3:	e8 6e b5 ff ff       	call   80100566 <panic>

      pid = current->pid;
80104ff8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ffb:	8b 40 10             	mov    0x10(%eax),%eax
80104ffe:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(current->kstack);
80105001:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105004:	8b 40 08             	mov    0x8(%eax),%eax
80105007:	83 ec 0c             	sub    $0xc,%esp
8010500a:	50                   	push   %eax
8010500b:	e8 4d dc ff ff       	call   80102c5d <kfree>
80105010:	83 c4 10             	add    $0x10,%esp
      current->kstack = 0;
80105013:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105016:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
      freevm(current->pgdir);
8010501d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105020:	8b 40 04             	mov    0x4(%eax),%eax
80105023:	83 ec 0c             	sub    $0xc,%esp
80105026:	50                   	push   %eax
80105027:	e8 6c 42 00 00       	call   80109298 <freevm>
8010502c:	83 c4 10             	add    $0x10,%esp
      current->state = UNUSED;
8010502f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105032:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)

      rc = addToStateListHead(&ptable.pLists.free, current);
80105039:	83 ec 08             	sub    $0x8,%esp
8010503c:	ff 75 f0             	pushl  -0x10(%ebp)
8010503f:	68 b8 5e 11 80       	push   $0x80115eb8
80105044:	e8 69 0c 00 00       	call   80105cb2 <addToStateListHead>
80105049:	83 c4 10             	add    $0x10,%esp
8010504c:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(rc == -1)
8010504f:	83 7d ec ff          	cmpl   $0xffffffff,-0x14(%ebp)
80105053:	75 0d                	jne    80105062 <wait+0x1c5>
        panic("Could not add to free list.");
80105055:	83 ec 0c             	sub    $0xc,%esp
80105058:	68 4f 99 10 80       	push   $0x8010994f
8010505d:	e8 04 b5 ff ff       	call   80100566 <panic>

      current->pid = 0;
80105062:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105065:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
      current->parent = 0;
8010506c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010506f:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
      current->name[0] = 0;
80105076:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105079:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
      current->killed = 0;
8010507d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105080:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
      release(&ptable.lock);
80105087:	83 ec 0c             	sub    $0xc,%esp
8010508a:	68 80 39 11 80       	push   $0x80113980
8010508f:	e8 d7 0e 00 00       	call   80105f6b <release>
80105094:	83 c4 10             	add    $0x10,%esp
      return pid;
80105097:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010509a:	eb 46                	jmp    801050e2 <wait+0x245>
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
8010509c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801050a0:	74 0d                	je     801050af <wait+0x212>
801050a2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050a8:	8b 40 24             	mov    0x24(%eax),%eax
801050ab:	85 c0                	test   %eax,%eax
801050ad:	74 17                	je     801050c6 <wait+0x229>
      release(&ptable.lock);
801050af:	83 ec 0c             	sub    $0xc,%esp
801050b2:	68 80 39 11 80       	push   $0x80113980
801050b7:	e8 af 0e 00 00       	call   80105f6b <release>
801050bc:	83 c4 10             	add    $0x10,%esp
      return -1;
801050bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050c4:	eb 1c                	jmp    801050e2 <wait+0x245>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
801050c6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050cc:	83 ec 08             	sub    $0x8,%esp
801050cf:	68 80 39 11 80       	push   $0x80113980
801050d4:	50                   	push   %eax
801050d5:	e8 22 03 00 00       	call   801053fc <sleep>
801050da:	83 c4 10             	add    $0x10,%esp
  }
801050dd:	e9 d1 fd ff ff       	jmp    80104eb3 <wait+0x16>
}
801050e2:	c9                   	leave  
801050e3:	c3                   	ret    

801050e4 <scheduler>:
}

#else //Scheduler for Project 3
void
scheduler(void)
{
801050e4:	55                   	push   %ebp
801050e5:	89 e5                	mov    %esp,%ebp
801050e7:	83 ec 18             	sub    $0x18,%esp
  int idle;  // for checking if processor is idle
  int rc;

  for (;;){
    // Enable interrupts on this processor.
    sti();
801050ea:	e8 fa f3 ff ff       	call   801044e9 <sti>
    
    idle = 1;  // assume idle unless we schedule a process
801050ef:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

    acquire(&ptable.lock);
801050f6:	83 ec 0c             	sub    $0xc,%esp
801050f9:	68 80 39 11 80       	push   $0x80113980
801050fe:	e8 01 0e 00 00       	call   80105f04 <acquire>
80105103:	83 c4 10             	add    $0x10,%esp
   
    //if (ptable.pLists.ready == 0)
      //panic("No runnable process."); 
    
    p = ptable.pLists.ready;
80105106:	a1 b4 5e 11 80       	mov    0x80115eb4,%eax
8010510b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    
    while(p != 0)
8010510e:	e9 e8 00 00 00       	jmp    801051fb <scheduler+0x117>
    {
      //Remove process from ready list
      assertState(p, RUNNABLE);
80105113:	83 ec 08             	sub    $0x8,%esp
80105116:	6a 03                	push   $0x3
80105118:	ff 75 f4             	pushl  -0xc(%ebp)
8010511b:	e8 f6 0a 00 00       	call   80105c16 <assertState>
80105120:	83 c4 10             	add    $0x10,%esp
      rc = removeFromStateList(&ptable.pLists.ready, p);
80105123:	83 ec 08             	sub    $0x8,%esp
80105126:	ff 75 f4             	pushl  -0xc(%ebp)
80105129:	68 b4 5e 11 80       	push   $0x80115eb4
8010512e:	e8 33 0a 00 00       	call   80105b66 <removeFromStateList>
80105133:	83 c4 10             	add    $0x10,%esp
80105136:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(rc == -1)
80105139:	83 7d ec ff          	cmpl   $0xffffffff,-0x14(%ebp)
8010513d:	75 0d                	jne    8010514c <scheduler+0x68>
        panic("Could not remove from free list.");
8010513f:	83 ec 0c             	sub    $0xc,%esp
80105142:	68 e4 98 10 80       	push   $0x801098e4
80105147:	e8 1a b4 ff ff       	call   80100566 <panic>
      
      idle = 0;
8010514c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      proc = p;
80105153:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105156:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      
      switchuvm(p);
8010515c:	83 ec 0c             	sub    $0xc,%esp
8010515f:	ff 75 f4             	pushl  -0xc(%ebp)
80105162:	e8 eb 3c 00 00       	call   80108e52 <switchuvm>
80105167:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
8010516a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010516d:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      //Put process on running list
      rc = addToStateListHead(&ptable.pLists.running, p);
80105174:	83 ec 08             	sub    $0x8,%esp
80105177:	ff 75 f4             	pushl  -0xc(%ebp)
8010517a:	68 c4 5e 11 80       	push   $0x80115ec4
8010517f:	e8 2e 0b 00 00       	call   80105cb2 <addToStateListHead>
80105184:	83 c4 10             	add    $0x10,%esp
80105187:	89 45 ec             	mov    %eax,-0x14(%ebp)
      assertState(p, RUNNING);
8010518a:	83 ec 08             	sub    $0x8,%esp
8010518d:	6a 04                	push   $0x4
8010518f:	ff 75 f4             	pushl  -0xc(%ebp)
80105192:	e8 7f 0a 00 00       	call   80105c16 <assertState>
80105197:	83 c4 10             	add    $0x10,%esp
      if(rc == -1)
8010519a:	83 7d ec ff          	cmpl   $0xffffffff,-0x14(%ebp)
8010519e:	75 0d                	jne    801051ad <scheduler+0xc9>
        panic("Could not add to running list.");
801051a0:	83 ec 0c             	sub    $0xc,%esp
801051a3:	68 6c 9a 10 80       	push   $0x80109a6c
801051a8:	e8 b9 b3 ff ff       	call   80100566 <panic>

#ifdef CS333_P2
      proc->cpu_ticks_in = ticks;
801051ad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051b3:	8b 15 e0 66 11 80    	mov    0x801166e0,%edx
801051b9:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
#endif

      swtch(&cpu->scheduler, proc->context);
801051bf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051c5:	8b 40 1c             	mov    0x1c(%eax),%eax
801051c8:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801051cf:	83 c2 04             	add    $0x4,%edx
801051d2:	83 ec 08             	sub    $0x8,%esp
801051d5:	50                   	push   %eax
801051d6:	52                   	push   %edx
801051d7:	e8 ff 11 00 00       	call   801063db <swtch>
801051dc:	83 c4 10             	add    $0x10,%esp
      switchkvm();
801051df:	e8 51 3c 00 00       	call   80108e35 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
801051e4:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
801051eb:	00 00 00 00 
      p = p->next;
801051ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051f2:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801051f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    //if (ptable.pLists.ready == 0)
      //panic("No runnable process."); 
    
    p = ptable.pLists.ready;
    
    while(p != 0)
801051fb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801051ff:	0f 85 0e ff ff ff    	jne    80105113 <scheduler+0x2f>
      // It should have changed its p->state before coming back.
      proc = 0;
      p = p->next;
    }

    release(&ptable.lock);
80105205:	83 ec 0c             	sub    $0xc,%esp
80105208:	68 80 39 11 80       	push   $0x80113980
8010520d:	e8 59 0d 00 00       	call   80105f6b <release>
80105212:	83 c4 10             	add    $0x10,%esp
    // if idle, wait for next interrupt
    if (idle) {
80105215:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105219:	0f 84 cb fe ff ff    	je     801050ea <scheduler+0x6>
      sti();
8010521f:	e8 c5 f2 ff ff       	call   801044e9 <sti>
      hlt();
80105224:	e8 a9 f2 ff ff       	call   801044d2 <hlt>
    }
  }
80105229:	e9 bc fe ff ff       	jmp    801050ea <scheduler+0x6>

8010522e <sched>:

}
#else
void
sched(void) //For Project 3
{
8010522e:	55                   	push   %ebp
8010522f:	89 e5                	mov    %esp,%ebp
80105231:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
80105234:	83 ec 0c             	sub    $0xc,%esp
80105237:	68 80 39 11 80       	push   $0x80113980
8010523c:	e8 f6 0d 00 00       	call   80106037 <holding>
80105241:	83 c4 10             	add    $0x10,%esp
80105244:	85 c0                	test   %eax,%eax
80105246:	75 0d                	jne    80105255 <sched+0x27>
    panic("sched ptable.lock");
80105248:	83 ec 0c             	sub    $0xc,%esp
8010524b:	68 8b 9a 10 80       	push   $0x80109a8b
80105250:	e8 11 b3 ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
80105255:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010525b:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105261:	83 f8 01             	cmp    $0x1,%eax
80105264:	74 0d                	je     80105273 <sched+0x45>
    panic("sched locks");
80105266:	83 ec 0c             	sub    $0xc,%esp
80105269:	68 9d 9a 10 80       	push   $0x80109a9d
8010526e:	e8 f3 b2 ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
80105273:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105279:	8b 40 0c             	mov    0xc(%eax),%eax
8010527c:	83 f8 04             	cmp    $0x4,%eax
8010527f:	75 0d                	jne    8010528e <sched+0x60>
    panic("sched running");
80105281:	83 ec 0c             	sub    $0xc,%esp
80105284:	68 a9 9a 10 80       	push   $0x80109aa9
80105289:	e8 d8 b2 ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
8010528e:	e8 46 f2 ff ff       	call   801044d9 <readeflags>
80105293:	25 00 02 00 00       	and    $0x200,%eax
80105298:	85 c0                	test   %eax,%eax
8010529a:	74 0d                	je     801052a9 <sched+0x7b>
    panic("sched interruptible");
8010529c:	83 ec 0c             	sub    $0xc,%esp
8010529f:	68 b7 9a 10 80       	push   $0x80109ab7
801052a4:	e8 bd b2 ff ff       	call   80100566 <panic>
  intena = cpu->intena;
801052a9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801052af:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801052b5:	89 45 f4             	mov    %eax,-0xc(%ebp)

#ifdef CS333_P2 
  proc->cpu_ticks_total = ticks - proc->cpu_ticks_in;  
801052b8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052be:	8b 0d e0 66 11 80    	mov    0x801166e0,%ecx
801052c4:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801052cb:	8b 92 8c 00 00 00    	mov    0x8c(%edx),%edx
801052d1:	29 d1                	sub    %edx,%ecx
801052d3:	89 ca                	mov    %ecx,%edx
801052d5:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
#endif

  swtch(&proc->context, cpu->scheduler);
801052db:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801052e1:	8b 40 04             	mov    0x4(%eax),%eax
801052e4:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801052eb:	83 c2 1c             	add    $0x1c,%edx
801052ee:	83 ec 08             	sub    $0x8,%esp
801052f1:	50                   	push   %eax
801052f2:	52                   	push   %edx
801052f3:	e8 e3 10 00 00       	call   801063db <swtch>
801052f8:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
801052fb:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105301:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105304:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)

}
8010530a:	90                   	nop
8010530b:	c9                   	leave  
8010530c:	c3                   	ret    

8010530d <yield>:
#endif

// Give up the CPU for one scheduling round.
void
yield(void)
{
8010530d:	55                   	push   %ebp
8010530e:	89 e5                	mov    %esp,%ebp
80105310:	83 ec 18             	sub    $0x18,%esp
  int rc;
  acquire(&ptable.lock);  //DOC: yieldlock
80105313:	83 ec 0c             	sub    $0xc,%esp
80105316:	68 80 39 11 80       	push   $0x80113980
8010531b:	e8 e4 0b 00 00       	call   80105f04 <acquire>
80105320:	83 c4 10             	add    $0x10,%esp

  assertState(proc, RUNNING);
80105323:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105329:	83 ec 08             	sub    $0x8,%esp
8010532c:	6a 04                	push   $0x4
8010532e:	50                   	push   %eax
8010532f:	e8 e2 08 00 00       	call   80105c16 <assertState>
80105334:	83 c4 10             	add    $0x10,%esp
  rc = removeFromStateList(&ptable.pLists.running, proc);
80105337:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010533d:	83 ec 08             	sub    $0x8,%esp
80105340:	50                   	push   %eax
80105341:	68 c4 5e 11 80       	push   $0x80115ec4
80105346:	e8 1b 08 00 00       	call   80105b66 <removeFromStateList>
8010534b:	83 c4 10             	add    $0x10,%esp
8010534e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(rc == -1)
80105351:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
80105355:	75 0d                	jne    80105364 <yield+0x57>
    panic("Could not remove from running list.");
80105357:	83 ec 0c             	sub    $0xc,%esp
8010535a:	68 cc 9a 10 80       	push   $0x80109acc
8010535f:	e8 02 b2 ff ff       	call   80100566 <panic>
  
  proc->state = RUNNABLE;
80105364:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010536a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  rc = addToStateListEnd(&ptable.pLists.free, proc);
80105371:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105377:	83 ec 08             	sub    $0x8,%esp
8010537a:	50                   	push   %eax
8010537b:	68 b8 5e 11 80       	push   $0x80115eb8
80105380:	e8 b2 08 00 00       	call   80105c37 <addToStateListEnd>
80105385:	83 c4 10             	add    $0x10,%esp
80105388:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(rc == -1)
8010538b:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
8010538f:	75 0d                	jne    8010539e <yield+0x91>
    panic("Could not remove from free list.");
80105391:	83 ec 0c             	sub    $0xc,%esp
80105394:	68 e4 98 10 80       	push   $0x801098e4
80105399:	e8 c8 b1 ff ff       	call   80100566 <panic>

  sched();
8010539e:	e8 8b fe ff ff       	call   8010522e <sched>
  release(&ptable.lock);
801053a3:	83 ec 0c             	sub    $0xc,%esp
801053a6:	68 80 39 11 80       	push   $0x80113980
801053ab:	e8 bb 0b 00 00       	call   80105f6b <release>
801053b0:	83 c4 10             	add    $0x10,%esp
}
801053b3:	90                   	nop
801053b4:	c9                   	leave  
801053b5:	c3                   	ret    

801053b6 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801053b6:	55                   	push   %ebp
801053b7:	89 e5                	mov    %esp,%ebp
801053b9:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801053bc:	83 ec 0c             	sub    $0xc,%esp
801053bf:	68 80 39 11 80       	push   $0x80113980
801053c4:	e8 a2 0b 00 00       	call   80105f6b <release>
801053c9:	83 c4 10             	add    $0x10,%esp

  if (first) {
801053cc:	a1 20 c0 10 80       	mov    0x8010c020,%eax
801053d1:	85 c0                	test   %eax,%eax
801053d3:	74 24                	je     801053f9 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
801053d5:	c7 05 20 c0 10 80 00 	movl   $0x0,0x8010c020
801053dc:	00 00 00 
    iinit(ROOTDEV);
801053df:	83 ec 0c             	sub    $0xc,%esp
801053e2:	6a 01                	push   $0x1
801053e4:	e8 e9 c2 ff ff       	call   801016d2 <iinit>
801053e9:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
801053ec:	83 ec 0c             	sub    $0xc,%esp
801053ef:	6a 01                	push   $0x1
801053f1:	e8 cd df ff ff       	call   801033c3 <initlog>
801053f6:	83 c4 10             	add    $0x10,%esp
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
801053f9:	90                   	nop
801053fa:	c9                   	leave  
801053fb:	c3                   	ret    

801053fc <sleep>:
// Reacquires lock when awakened.
// 2016/12/28: ticklock removed from xv6. sleep() changed to
// accept a NULL lock to accommodate.
void
sleep(void *chan, struct spinlock *lk)
{
801053fc:	55                   	push   %ebp
801053fd:	89 e5                	mov    %esp,%ebp
801053ff:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
80105402:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105408:	85 c0                	test   %eax,%eax
8010540a:	75 0d                	jne    80105419 <sleep+0x1d>
    panic("sleep");
8010540c:	83 ec 0c             	sub    $0xc,%esp
8010540f:	68 f0 9a 10 80       	push   $0x80109af0
80105414:	e8 4d b1 ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){
80105419:	81 7d 0c 80 39 11 80 	cmpl   $0x80113980,0xc(%ebp)
80105420:	74 24                	je     80105446 <sleep+0x4a>
    acquire(&ptable.lock);
80105422:	83 ec 0c             	sub    $0xc,%esp
80105425:	68 80 39 11 80       	push   $0x80113980
8010542a:	e8 d5 0a 00 00       	call   80105f04 <acquire>
8010542f:	83 c4 10             	add    $0x10,%esp
    if (lk) release(lk);
80105432:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105436:	74 0e                	je     80105446 <sleep+0x4a>
80105438:	83 ec 0c             	sub    $0xc,%esp
8010543b:	ff 75 0c             	pushl  0xc(%ebp)
8010543e:	e8 28 0b 00 00       	call   80105f6b <release>
80105443:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
80105446:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010544c:	8b 55 08             	mov    0x8(%ebp),%edx
8010544f:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80105452:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105458:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
8010545f:	e8 ca fd ff ff       	call   8010522e <sched>

  // Tidy up.
  proc->chan = 0;
80105464:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010546a:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){ 
80105471:	81 7d 0c 80 39 11 80 	cmpl   $0x80113980,0xc(%ebp)
80105478:	74 24                	je     8010549e <sleep+0xa2>
    release(&ptable.lock);
8010547a:	83 ec 0c             	sub    $0xc,%esp
8010547d:	68 80 39 11 80       	push   $0x80113980
80105482:	e8 e4 0a 00 00       	call   80105f6b <release>
80105487:	83 c4 10             	add    $0x10,%esp
    if (lk) acquire(lk);
8010548a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010548e:	74 0e                	je     8010549e <sleep+0xa2>
80105490:	83 ec 0c             	sub    $0xc,%esp
80105493:	ff 75 0c             	pushl  0xc(%ebp)
80105496:	e8 69 0a 00 00       	call   80105f04 <acquire>
8010549b:	83 c4 10             	add    $0x10,%esp
  }
}
8010549e:	90                   	nop
8010549f:	c9                   	leave  
801054a0:	c3                   	ret    

801054a1 <wakeup1>:
      p->state = RUNNABLE;
}
#else
static void
wakeup1(void *chan) //For Project 3
{
801054a1:	55                   	push   %ebp
801054a2:	89 e5                	mov    %esp,%ebp
801054a4:	83 ec 18             	sub    $0x18,%esp
  struct proc *current;
  int rc;

  current = ptable.pLists.sleep;
801054a7:	a1 bc 5e 11 80       	mov    0x80115ebc,%eax
801054ac:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while(current != 0)
801054af:	e9 93 00 00 00       	jmp    80105547 <wakeup1+0xa6>
  {
    assertState(current, SLEEPING);
801054b4:	83 ec 08             	sub    $0x8,%esp
801054b7:	6a 02                	push   $0x2
801054b9:	ff 75 f4             	pushl  -0xc(%ebp)
801054bc:	e8 55 07 00 00       	call   80105c16 <assertState>
801054c1:	83 c4 10             	add    $0x10,%esp

    if(current->chan == chan)
801054c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054c7:	8b 40 20             	mov    0x20(%eax),%eax
801054ca:	3b 45 08             	cmp    0x8(%ebp),%eax
801054cd:	75 6c                	jne    8010553b <wakeup1+0x9a>
    {
       rc = removeFromStateList(&ptable.pLists.sleep, current);
801054cf:	83 ec 08             	sub    $0x8,%esp
801054d2:	ff 75 f4             	pushl  -0xc(%ebp)
801054d5:	68 bc 5e 11 80       	push   $0x80115ebc
801054da:	e8 87 06 00 00       	call   80105b66 <removeFromStateList>
801054df:	83 c4 10             	add    $0x10,%esp
801054e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
       if(rc == -1)
801054e5:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
801054e9:	75 0d                	jne    801054f8 <wakeup1+0x57>
         panic("Could not remove process from sleep list.");
801054eb:	83 ec 0c             	sub    $0xc,%esp
801054ee:	68 f8 9a 10 80       	push   $0x80109af8
801054f3:	e8 6e b0 ff ff       	call   80100566 <panic>

       current->state = RUNNABLE;
801054f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054fb:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

       assertState(current, RUNNABLE);
80105502:	83 ec 08             	sub    $0x8,%esp
80105505:	6a 03                	push   $0x3
80105507:	ff 75 f4             	pushl  -0xc(%ebp)
8010550a:	e8 07 07 00 00       	call   80105c16 <assertState>
8010550f:	83 c4 10             	add    $0x10,%esp
       rc = addToStateListEnd(&ptable.pLists.ready, current);
80105512:	83 ec 08             	sub    $0x8,%esp
80105515:	ff 75 f4             	pushl  -0xc(%ebp)
80105518:	68 b4 5e 11 80       	push   $0x80115eb4
8010551d:	e8 15 07 00 00       	call   80105c37 <addToStateListEnd>
80105522:	83 c4 10             	add    $0x10,%esp
80105525:	89 45 f0             	mov    %eax,-0x10(%ebp)
       if(rc == -1)
80105528:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
8010552c:	75 0d                	jne    8010553b <wakeup1+0x9a>
         panic("Could not add process to ready list."); 
8010552e:	83 ec 0c             	sub    $0xc,%esp
80105531:	68 08 9a 10 80       	push   $0x80109a08
80105536:	e8 2b b0 ff ff       	call   80100566 <panic>
    }
    current = current->next;
8010553b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010553e:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105544:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct proc *current;
  int rc;

  current = ptable.pLists.sleep;

  while(current != 0)
80105547:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010554b:	0f 85 63 ff ff ff    	jne    801054b4 <wakeup1+0x13>
       if(rc == -1)
         panic("Could not add process to ready list."); 
    }
    current = current->next;
  }  
}
80105551:	90                   	nop
80105552:	c9                   	leave  
80105553:	c3                   	ret    

80105554 <wakeup>:
#endif

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80105554:	55                   	push   %ebp
80105555:	89 e5                	mov    %esp,%ebp
80105557:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
8010555a:	83 ec 0c             	sub    $0xc,%esp
8010555d:	68 80 39 11 80       	push   $0x80113980
80105562:	e8 9d 09 00 00       	call   80105f04 <acquire>
80105567:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
8010556a:	83 ec 0c             	sub    $0xc,%esp
8010556d:	ff 75 08             	pushl  0x8(%ebp)
80105570:	e8 2c ff ff ff       	call   801054a1 <wakeup1>
80105575:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80105578:	83 ec 0c             	sub    $0xc,%esp
8010557b:	68 80 39 11 80       	push   $0x80113980
80105580:	e8 e6 09 00 00       	call   80105f6b <release>
80105585:	83 c4 10             	add    $0x10,%esp
}
80105588:	90                   	nop
80105589:	c9                   	leave  
8010558a:	c3                   	ret    

8010558b <kill>:
}

#else
int
kill(int pid) //Project 3
{
8010558b:	55                   	push   %ebp
8010558c:	89 e5                	mov    %esp,%ebp
8010558e:	83 ec 18             	sub    $0x18,%esp
  //struct proc *p;
  struct proc *current;
  int rc;

  acquire(&ptable.lock);
80105591:	83 ec 0c             	sub    $0xc,%esp
80105594:	68 80 39 11 80       	push   $0x80113980
80105599:	e8 66 09 00 00       	call   80105f04 <acquire>
8010559e:	83 c4 10             	add    $0x10,%esp
  
  current = ptable.pLists.running;
801055a1:	a1 c4 5e 11 80       	mov    0x80115ec4,%eax
801055a6:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while(current != 0)
801055a9:	eb 5a                	jmp    80105605 <kill+0x7a>
  {
    if(current->pid == pid)
801055ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055ae:	8b 50 10             	mov    0x10(%eax),%edx
801055b1:	8b 45 08             	mov    0x8(%ebp),%eax
801055b4:	39 c2                	cmp    %eax,%edx
801055b6:	75 4d                	jne    80105605 <kill+0x7a>
    {
      current->killed = 1;
801055b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055bb:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      rc = removeFromStateList(&ptable.pLists.running, current);
801055c2:	83 ec 08             	sub    $0x8,%esp
801055c5:	ff 75 f4             	pushl  -0xc(%ebp)
801055c8:	68 c4 5e 11 80       	push   $0x80115ec4
801055cd:	e8 94 05 00 00       	call   80105b66 <removeFromStateList>
801055d2:	83 c4 10             	add    $0x10,%esp
801055d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(rc == -1)
801055d8:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
801055dc:	75 0d                	jne    801055eb <kill+0x60>
        panic("Could not remove from running list.");
801055de:	83 ec 0c             	sub    $0xc,%esp
801055e1:	68 cc 9a 10 80       	push   $0x80109acc
801055e6:	e8 7b af ff ff       	call   80100566 <panic>
      release(&ptable.lock);
801055eb:	83 ec 0c             	sub    $0xc,%esp
801055ee:	68 80 39 11 80       	push   $0x80113980
801055f3:	e8 73 09 00 00       	call   80105f6b <release>
801055f8:	83 c4 10             	add    $0x10,%esp
      return 0;
801055fb:	b8 00 00 00 00       	mov    $0x0,%eax
80105600:	e9 ad 01 00 00       	jmp    801057b2 <kill+0x227>

  acquire(&ptable.lock);
  
  current = ptable.pLists.running;

  while(current != 0)
80105605:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105609:	75 a0                	jne    801055ab <kill+0x20>
      release(&ptable.lock);
      return 0;
    }  
  }

  current = ptable.pLists.sleep;
8010560b:	a1 bc 5e 11 80       	mov    0x80115ebc,%eax
80105610:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while(current != 0)
80105613:	eb 5a                	jmp    8010566f <kill+0xe4>
  {
    if(current->pid == pid)
80105615:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105618:	8b 50 10             	mov    0x10(%eax),%edx
8010561b:	8b 45 08             	mov    0x8(%ebp),%eax
8010561e:	39 c2                	cmp    %eax,%edx
80105620:	75 4d                	jne    8010566f <kill+0xe4>
    {
      current->killed = 1;
80105622:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105625:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      rc = removeFromStateList(&ptable.pLists.sleep, current);
8010562c:	83 ec 08             	sub    $0x8,%esp
8010562f:	ff 75 f4             	pushl  -0xc(%ebp)
80105632:	68 bc 5e 11 80       	push   $0x80115ebc
80105637:	e8 2a 05 00 00       	call   80105b66 <removeFromStateList>
8010563c:	83 c4 10             	add    $0x10,%esp
8010563f:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(rc == -1)
80105642:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80105646:	75 0d                	jne    80105655 <kill+0xca>
        panic("Could not remove from sleep list.");
80105648:	83 ec 0c             	sub    $0xc,%esp
8010564b:	68 24 9b 10 80       	push   $0x80109b24
80105650:	e8 11 af ff ff       	call   80100566 <panic>
      release(&ptable.lock);
80105655:	83 ec 0c             	sub    $0xc,%esp
80105658:	68 80 39 11 80       	push   $0x80113980
8010565d:	e8 09 09 00 00       	call   80105f6b <release>
80105662:	83 c4 10             	add    $0x10,%esp
      return 0;
80105665:	b8 00 00 00 00       	mov    $0x0,%eax
8010566a:	e9 43 01 00 00       	jmp    801057b2 <kill+0x227>
    }  
  }

  current = ptable.pLists.sleep;

  while(current != 0)
8010566f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105673:	75 a0                	jne    80105615 <kill+0x8a>
      release(&ptable.lock);
      return 0;
    }
  }

  current = ptable.pLists.zombie;
80105675:	a1 c0 5e 11 80       	mov    0x80115ec0,%eax
8010567a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  while(current != 0)
8010567d:	eb 5a                	jmp    801056d9 <kill+0x14e>
  {
    if(current->pid == pid)
8010567f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105682:	8b 50 10             	mov    0x10(%eax),%edx
80105685:	8b 45 08             	mov    0x8(%ebp),%eax
80105688:	39 c2                	cmp    %eax,%edx
8010568a:	75 4d                	jne    801056d9 <kill+0x14e>
    {
      current->killed = 1;
8010568c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010568f:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      rc = removeFromStateList(&ptable.pLists.zombie, current);
80105696:	83 ec 08             	sub    $0x8,%esp
80105699:	ff 75 f4             	pushl  -0xc(%ebp)
8010569c:	68 c0 5e 11 80       	push   $0x80115ec0
801056a1:	e8 c0 04 00 00       	call   80105b66 <removeFromStateList>
801056a6:	83 c4 10             	add    $0x10,%esp
801056a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(rc == -1)
801056ac:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
801056b0:	75 0d                	jne    801056bf <kill+0x134>
        panic("Could not remove from zombie list.");
801056b2:	83 ec 0c             	sub    $0xc,%esp
801056b5:	68 48 9a 10 80       	push   $0x80109a48
801056ba:	e8 a7 ae ff ff       	call   80100566 <panic>
      release(&ptable.lock);
801056bf:	83 ec 0c             	sub    $0xc,%esp
801056c2:	68 80 39 11 80       	push   $0x80113980
801056c7:	e8 9f 08 00 00       	call   80105f6b <release>
801056cc:	83 c4 10             	add    $0x10,%esp
      return 0;
801056cf:	b8 00 00 00 00       	mov    $0x0,%eax
801056d4:	e9 d9 00 00 00       	jmp    801057b2 <kill+0x227>
    }
  }

  current = ptable.pLists.zombie;
  
  while(current != 0)
801056d9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056dd:	75 a0                	jne    8010567f <kill+0xf4>
      release(&ptable.lock);
      return 0;
    }
  }

  current = ptable.pLists.embryo;
801056df:	a1 c8 5e 11 80       	mov    0x80115ec8,%eax
801056e4:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while(current != 0)
801056e7:	eb 57                	jmp    80105740 <kill+0x1b5>
  {
    if(current->pid == pid)
801056e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056ec:	8b 50 10             	mov    0x10(%eax),%edx
801056ef:	8b 45 08             	mov    0x8(%ebp),%eax
801056f2:	39 c2                	cmp    %eax,%edx
801056f4:	75 4a                	jne    80105740 <kill+0x1b5>
    {
      current->killed = 1;
801056f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056f9:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      rc = removeFromStateList(&ptable.pLists.embryo, current);
80105700:	83 ec 08             	sub    $0x8,%esp
80105703:	ff 75 f4             	pushl  -0xc(%ebp)
80105706:	68 c8 5e 11 80       	push   $0x80115ec8
8010570b:	e8 56 04 00 00       	call   80105b66 <removeFromStateList>
80105710:	83 c4 10             	add    $0x10,%esp
80105713:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(rc == -1)
80105716:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
8010571a:	75 0d                	jne    80105729 <kill+0x19e>
        panic("Could not remove from embryo list.");
8010571c:	83 ec 0c             	sub    $0xc,%esp
8010571f:	68 2c 99 10 80       	push   $0x8010992c
80105724:	e8 3d ae ff ff       	call   80100566 <panic>
      release(&ptable.lock);
80105729:	83 ec 0c             	sub    $0xc,%esp
8010572c:	68 80 39 11 80       	push   $0x80113980
80105731:	e8 35 08 00 00       	call   80105f6b <release>
80105736:	83 c4 10             	add    $0x10,%esp
      return 0;
80105739:	b8 00 00 00 00       	mov    $0x0,%eax
8010573e:	eb 72                	jmp    801057b2 <kill+0x227>
    }
  }

  current = ptable.pLists.embryo;

  while(current != 0)
80105740:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105744:	75 a3                	jne    801056e9 <kill+0x15e>
      release(&ptable.lock);
      return 0;
    }
  }

  current = ptable.pLists.ready;
80105746:	a1 b4 5e 11 80       	mov    0x80115eb4,%eax
8010574b:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while(current != 0)
8010574e:	eb 47                	jmp    80105797 <kill+0x20c>
  {

    if(current->pid == pid)
80105750:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105753:	8b 50 10             	mov    0x10(%eax),%edx
80105756:	8b 45 08             	mov    0x8(%ebp),%eax
80105759:	39 c2                	cmp    %eax,%edx
8010575b:	75 3a                	jne    80105797 <kill+0x20c>
    {
      current->killed = 1;
8010575d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105760:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      rc = removeFromStateList(&ptable.pLists.ready, current);
80105767:	83 ec 08             	sub    $0x8,%esp
8010576a:	ff 75 f4             	pushl  -0xc(%ebp)
8010576d:	68 b4 5e 11 80       	push   $0x80115eb4
80105772:	e8 ef 03 00 00       	call   80105b66 <removeFromStateList>
80105777:	83 c4 10             	add    $0x10,%esp
8010577a:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(rc == -1)
8010577d:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80105781:	75 0d                	jne    80105790 <kill+0x205>
        panic("Could not remove from ready list.");
80105783:	83 ec 0c             	sub    $0xc,%esp
80105786:	68 48 9b 10 80       	push   $0x80109b48
8010578b:	e8 d6 ad ff ff       	call   80100566 <panic>
      return 0;
80105790:	b8 00 00 00 00       	mov    $0x0,%eax
80105795:	eb 1b                	jmp    801057b2 <kill+0x227>
    }
  }

  current = ptable.pLists.ready;

  while(current != 0)
80105797:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010579b:	75 b3                	jne    80105750 <kill+0x1c5>
        panic("Could not remove from ready list.");
      return 0;
    }
  }
 
  release(&ptable.lock);
8010579d:	83 ec 0c             	sub    $0xc,%esp
801057a0:	68 80 39 11 80       	push   $0x80113980
801057a5:	e8 c1 07 00 00       	call   80105f6b <release>
801057aa:	83 c4 10             	add    $0x10,%esp
  return -1;
801057ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801057b2:	c9                   	leave  
801057b3:	c3                   	ret    

801057b4 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801057b4:	55                   	push   %ebp
801057b5:	89 e5                	mov    %esp,%ebp
801057b7:	57                   	push   %edi
801057b8:	56                   	push   %esi
801057b9:	53                   	push   %ebx
801057ba:	83 ec 5c             	sub    $0x5c,%esp
#ifdef CS333_P1
  cprintf("PID     State    Name    Elapsed (s)     PCs\n");
#endif
*/
#ifdef CS333_P2 
  cprintf("\nPID\t Name\t UID\t GID\t PPID\t Elapsed\t CPU\t State\t Size\t PCs\n");
801057bd:	83 ec 0c             	sub    $0xc,%esp
801057c0:	68 94 9b 10 80       	push   $0x80109b94
801057c5:	e8 fc ab ff ff       	call   801003c6 <cprintf>
801057ca:	83 c4 10             	add    $0x10,%esp
#endif

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801057cd:	c7 45 e0 b4 39 11 80 	movl   $0x801139b4,-0x20(%ebp)
801057d4:	e9 6f 01 00 00       	jmp    80105948 <procdump+0x194>
    if(p->state == UNUSED)
801057d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801057dc:	8b 40 0c             	mov    0xc(%eax),%eax
801057df:	85 c0                	test   %eax,%eax
801057e1:	0f 84 59 01 00 00    	je     80105940 <procdump+0x18c>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801057e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801057ea:	8b 40 0c             	mov    0xc(%eax),%eax
801057ed:	83 f8 05             	cmp    $0x5,%eax
801057f0:	77 23                	ja     80105815 <procdump+0x61>
801057f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801057f5:	8b 40 0c             	mov    0xc(%eax),%eax
801057f8:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
801057ff:	85 c0                	test   %eax,%eax
80105801:	74 12                	je     80105815 <procdump+0x61>
      state = states[p->state];
80105803:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105806:	8b 40 0c             	mov    0xc(%eax),%eax
80105809:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80105810:	89 45 dc             	mov    %eax,-0x24(%ebp)
80105813:	eb 07                	jmp    8010581c <procdump+0x68>
    else
      state = "???";
80105815:	c7 45 dc d0 9b 10 80 	movl   $0x80109bd0,-0x24(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
#endif
*/

#ifdef CS333_P2
  uint elapsed = ticks - p->start_ticks;
8010581c:	8b 15 e0 66 11 80    	mov    0x801166e0,%edx
80105822:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105825:	8b 40 7c             	mov    0x7c(%eax),%eax
80105828:	29 c2                	sub    %eax,%edx
8010582a:	89 d0                	mov    %edx,%eax
8010582c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint sec = calcsec(elapsed);
8010582f:	83 ec 0c             	sub    $0xc,%esp
80105832:	ff 75 d8             	pushl  -0x28(%ebp)
80105835:	e8 24 01 00 00       	call   8010595e <calcsec>
8010583a:	83 c4 10             	add    $0x10,%esp
8010583d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  uint mili = calcmili(elapsed);
80105840:	83 ec 0c             	sub    $0xc,%esp
80105843:	ff 75 d8             	pushl  -0x28(%ebp)
80105846:	e8 30 01 00 00       	call   8010597b <calcmili>
8010584b:	83 c4 10             	add    $0x10,%esp
8010584e:	89 45 d0             	mov    %eax,-0x30(%ebp)

  uint cpu_sec = calcsec(p->cpu_ticks_total);
80105851:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105854:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
8010585a:	83 ec 0c             	sub    $0xc,%esp
8010585d:	50                   	push   %eax
8010585e:	e8 fb 00 00 00       	call   8010595e <calcsec>
80105863:	83 c4 10             	add    $0x10,%esp
80105866:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint cpu_mili = calcmili(p->cpu_ticks_total);
80105869:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010586c:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80105872:	83 ec 0c             	sub    $0xc,%esp
80105875:	50                   	push   %eax
80105876:	e8 00 01 00 00       	call   8010597b <calcmili>
8010587b:	83 c4 10             	add    $0x10,%esp
8010587e:	89 45 c8             	mov    %eax,-0x38(%ebp)

  cprintf("%d\t %s\t %d\t %d\t %d\t %d.%d\t\t %d.%d\t %s\t %d\t", p->pid, p->name, p->uid, p->gid, p->parent->pid, sec, mili, cpu_sec, cpu_mili, state, p->sz);
80105881:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105884:	8b 30                	mov    (%eax),%esi
80105886:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105889:	8b 40 14             	mov    0x14(%eax),%eax
8010588c:	8b 58 10             	mov    0x10(%eax),%ebx
8010588f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105892:	8b 88 84 00 00 00    	mov    0x84(%eax),%ecx
80105898:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010589b:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
801058a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801058a4:	8d 78 6c             	lea    0x6c(%eax),%edi
801058a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801058aa:	8b 40 10             	mov    0x10(%eax),%eax
801058ad:	56                   	push   %esi
801058ae:	ff 75 dc             	pushl  -0x24(%ebp)
801058b1:	ff 75 c8             	pushl  -0x38(%ebp)
801058b4:	ff 75 cc             	pushl  -0x34(%ebp)
801058b7:	ff 75 d0             	pushl  -0x30(%ebp)
801058ba:	ff 75 d4             	pushl  -0x2c(%ebp)
801058bd:	53                   	push   %ebx
801058be:	51                   	push   %ecx
801058bf:	52                   	push   %edx
801058c0:	57                   	push   %edi
801058c1:	50                   	push   %eax
801058c2:	68 d4 9b 10 80       	push   $0x80109bd4
801058c7:	e8 fa aa ff ff       	call   801003c6 <cprintf>
801058cc:	83 c4 30             	add    $0x30,%esp
#endif

    if(p->state == SLEEPING){
801058cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
801058d2:	8b 40 0c             	mov    0xc(%eax),%eax
801058d5:	83 f8 02             	cmp    $0x2,%eax
801058d8:	75 54                	jne    8010592e <procdump+0x17a>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801058da:	8b 45 e0             	mov    -0x20(%ebp),%eax
801058dd:	8b 40 1c             	mov    0x1c(%eax),%eax
801058e0:	8b 40 0c             	mov    0xc(%eax),%eax
801058e3:	83 c0 08             	add    $0x8,%eax
801058e6:	89 c2                	mov    %eax,%edx
801058e8:	83 ec 08             	sub    $0x8,%esp
801058eb:	8d 45 a0             	lea    -0x60(%ebp),%eax
801058ee:	50                   	push   %eax
801058ef:	52                   	push   %edx
801058f0:	e8 c8 06 00 00       	call   80105fbd <getcallerpcs>
801058f5:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801058f8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801058ff:	eb 1c                	jmp    8010591d <procdump+0x169>
        cprintf(" %p", pc[i]);
80105901:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105904:	8b 44 85 a0          	mov    -0x60(%ebp,%eax,4),%eax
80105908:	83 ec 08             	sub    $0x8,%esp
8010590b:	50                   	push   %eax
8010590c:	68 ff 9b 10 80       	push   $0x80109bff
80105911:	e8 b0 aa ff ff       	call   801003c6 <cprintf>
80105916:	83 c4 10             	add    $0x10,%esp
  cprintf("%d\t %s\t %d\t %d\t %d\t %d.%d\t\t %d.%d\t %s\t %d\t", p->pid, p->name, p->uid, p->gid, p->parent->pid, sec, mili, cpu_sec, cpu_mili, state, p->sz);
#endif

    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80105919:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010591d:	83 7d e4 09          	cmpl   $0x9,-0x1c(%ebp)
80105921:	7f 0b                	jg     8010592e <procdump+0x17a>
80105923:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105926:	8b 44 85 a0          	mov    -0x60(%ebp,%eax,4),%eax
8010592a:	85 c0                	test   %eax,%eax
8010592c:	75 d3                	jne    80105901 <procdump+0x14d>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
8010592e:	83 ec 0c             	sub    $0xc,%esp
80105931:	68 03 9c 10 80       	push   $0x80109c03
80105936:	e8 8b aa ff ff       	call   801003c6 <cprintf>
8010593b:	83 c4 10             	add    $0x10,%esp
8010593e:	eb 01                	jmp    80105941 <procdump+0x18d>
  cprintf("\nPID\t Name\t UID\t GID\t PPID\t Elapsed\t CPU\t State\t Size\t PCs\n");
#endif

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80105940:	90                   	nop
*/
#ifdef CS333_P2 
  cprintf("\nPID\t Name\t UID\t GID\t PPID\t Elapsed\t CPU\t State\t Size\t PCs\n");
#endif

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105941:	81 45 e0 94 00 00 00 	addl   $0x94,-0x20(%ebp)
80105948:	81 7d e0 b4 5e 11 80 	cmpl   $0x80115eb4,-0x20(%ebp)
8010594f:	0f 82 84 fe ff ff    	jb     801057d9 <procdump+0x25>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80105955:	90                   	nop
80105956:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105959:	5b                   	pop    %ebx
8010595a:	5e                   	pop    %esi
8010595b:	5f                   	pop    %edi
8010595c:	5d                   	pop    %ebp
8010595d:	c3                   	ret    

8010595e <calcsec>:
#ifdef CS333_P1
//procdump's helper function
//calculating the seconds and miliseconds since a process has ran
uint
calcsec(uint num)
{
8010595e:	55                   	push   %ebp
8010595f:	89 e5                	mov    %esp,%ebp
80105961:	83 ec 10             	sub    $0x10,%esp
  uint sec = num / 1000;
80105964:	8b 45 08             	mov    0x8(%ebp),%eax
80105967:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
8010596c:	f7 e2                	mul    %edx
8010596e:	89 d0                	mov    %edx,%eax
80105970:	c1 e8 06             	shr    $0x6,%eax
80105973:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return sec;
80105976:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105979:	c9                   	leave  
8010597a:	c3                   	ret    

8010597b <calcmili>:

uint
calcmili(uint num)
{
8010597b:	55                   	push   %ebp
8010597c:	89 e5                	mov    %esp,%ebp
8010597e:	83 ec 10             	sub    $0x10,%esp
  uint mili = num % 1000;
80105981:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105984:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80105989:	89 c8                	mov    %ecx,%eax
8010598b:	f7 e2                	mul    %edx
8010598d:	89 d0                	mov    %edx,%eax
8010598f:	c1 e8 06             	shr    $0x6,%eax
80105992:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
80105998:	29 c1                	sub    %eax,%ecx
8010599a:	89 c8                	mov    %ecx,%eax
8010599c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return mili;
8010599f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801059a2:	c9                   	leave  
801059a3:	c3                   	ret    

801059a4 <getprocs>:
#endif

#ifdef CS333_P2
int
getprocs(uint max, struct uproc *table)
{
801059a4:	55                   	push   %ebp
801059a5:	89 e5                	mov    %esp,%ebp
801059a7:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int index = 0;
801059aa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

  acquire(&ptable.lock);
801059b1:	83 ec 0c             	sub    $0xc,%esp
801059b4:	68 80 39 11 80       	push   $0x80113980
801059b9:	e8 46 05 00 00       	call   80105f04 <acquire>
801059be:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC] && index < max; p++)
801059c1:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
801059c8:	e9 6f 01 00 00       	jmp    80105b3c <getprocs+0x198>
  {
    if(p->state != EMBRYO && p->state != UNUSED)
801059cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059d0:	8b 40 0c             	mov    0xc(%eax),%eax
801059d3:	83 f8 01             	cmp    $0x1,%eax
801059d6:	0f 84 59 01 00 00    	je     80105b35 <getprocs+0x191>
801059dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059df:	8b 40 0c             	mov    0xc(%eax),%eax
801059e2:	85 c0                	test   %eax,%eax
801059e4:	0f 84 4b 01 00 00    	je     80105b35 <getprocs+0x191>
    {
      table[index].pid = p->pid;
801059ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059ed:	6b d0 5c             	imul   $0x5c,%eax,%edx
801059f0:	8b 45 0c             	mov    0xc(%ebp),%eax
801059f3:	01 c2                	add    %eax,%edx
801059f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059f8:	8b 40 10             	mov    0x10(%eax),%eax
801059fb:	89 02                	mov    %eax,(%edx)
      table[index].uid = p->uid;
801059fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a00:	6b d0 5c             	imul   $0x5c,%eax,%edx
80105a03:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a06:	01 c2                	add    %eax,%edx
80105a08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a0b:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105a11:	89 42 04             	mov    %eax,0x4(%edx)
      table[index].gid = p->gid;
80105a14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a17:	6b d0 5c             	imul   $0x5c,%eax,%edx
80105a1a:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a1d:	01 c2                	add    %eax,%edx
80105a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a22:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80105a28:	89 42 08             	mov    %eax,0x8(%edx)
      table[index].ppid = p->parent->pid;
80105a2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a2e:	6b d0 5c             	imul   $0x5c,%eax,%edx
80105a31:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a34:	01 c2                	add    %eax,%edx
80105a36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a39:	8b 40 14             	mov    0x14(%eax),%eax
80105a3c:	8b 40 10             	mov    0x10(%eax),%eax
80105a3f:	89 42 0c             	mov    %eax,0xc(%edx)
      table[index].elapsed_ticks = ticks - p->start_ticks;
80105a42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a45:	6b d0 5c             	imul   $0x5c,%eax,%edx
80105a48:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a4b:	01 c2                	add    %eax,%edx
80105a4d:	8b 0d e0 66 11 80    	mov    0x801166e0,%ecx
80105a53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a56:	8b 40 7c             	mov    0x7c(%eax),%eax
80105a59:	29 c1                	sub    %eax,%ecx
80105a5b:	89 c8                	mov    %ecx,%eax
80105a5d:	89 42 10             	mov    %eax,0x10(%edx)
      table[index].CPU_total_ticks = p->cpu_ticks_total;
80105a60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a63:	6b d0 5c             	imul   $0x5c,%eax,%edx
80105a66:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a69:	01 c2                	add    %eax,%edx
80105a6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a6e:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80105a74:	89 42 14             	mov    %eax,0x14(%edx)
      table[index].size = p->sz;
80105a77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a7a:	6b d0 5c             	imul   $0x5c,%eax,%edx
80105a7d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a80:	01 c2                	add    %eax,%edx
80105a82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a85:	8b 00                	mov    (%eax),%eax
80105a87:	89 42 38             	mov    %eax,0x38(%edx)

      safestrcpy(table[index].name, p->name, sizeof(table[index].name));
80105a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a8d:	8d 50 6c             	lea    0x6c(%eax),%edx
80105a90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a93:	6b c8 5c             	imul   $0x5c,%eax,%ecx
80105a96:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a99:	01 c8                	add    %ecx,%eax
80105a9b:	83 c0 3c             	add    $0x3c,%eax
80105a9e:	83 ec 04             	sub    $0x4,%esp
80105aa1:	6a 20                	push   $0x20
80105aa3:	52                   	push   %edx
80105aa4:	50                   	push   %eax
80105aa5:	e8 c0 08 00 00       	call   8010636a <safestrcpy>
80105aaa:	83 c4 10             	add    $0x10,%esp

      if(p->state == RUNNING)
80105aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ab0:	8b 40 0c             	mov    0xc(%eax),%eax
80105ab3:	83 f8 04             	cmp    $0x4,%eax
80105ab6:	75 21                	jne    80105ad9 <getprocs+0x135>
        safestrcpy(table[index].state, "RUNNING", sizeof(table[index].state));
80105ab8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105abb:	6b d0 5c             	imul   $0x5c,%eax,%edx
80105abe:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ac1:	01 d0                	add    %edx,%eax
80105ac3:	83 c0 18             	add    $0x18,%eax
80105ac6:	83 ec 04             	sub    $0x4,%esp
80105ac9:	6a 20                	push   $0x20
80105acb:	68 05 9c 10 80       	push   $0x80109c05
80105ad0:	50                   	push   %eax
80105ad1:	e8 94 08 00 00       	call   8010636a <safestrcpy>
80105ad6:	83 c4 10             	add    $0x10,%esp
      if(p->state == SLEEPING)
80105ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105adc:	8b 40 0c             	mov    0xc(%eax),%eax
80105adf:	83 f8 02             	cmp    $0x2,%eax
80105ae2:	75 21                	jne    80105b05 <getprocs+0x161>
        safestrcpy(table[index].state, "SLEEPING", sizeof(table[index].state));
80105ae4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ae7:	6b d0 5c             	imul   $0x5c,%eax,%edx
80105aea:	8b 45 0c             	mov    0xc(%ebp),%eax
80105aed:	01 d0                	add    %edx,%eax
80105aef:	83 c0 18             	add    $0x18,%eax
80105af2:	83 ec 04             	sub    $0x4,%esp
80105af5:	6a 20                	push   $0x20
80105af7:	68 0d 9c 10 80       	push   $0x80109c0d
80105afc:	50                   	push   %eax
80105afd:	e8 68 08 00 00       	call   8010636a <safestrcpy>
80105b02:	83 c4 10             	add    $0x10,%esp
      if(p->state == RUNNABLE)
80105b05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b08:	8b 40 0c             	mov    0xc(%eax),%eax
80105b0b:	83 f8 03             	cmp    $0x3,%eax
80105b0e:	75 21                	jne    80105b31 <getprocs+0x18d>
        safestrcpy(table[index].state, "RUNNABLE", sizeof(table[index].state));
80105b10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b13:	6b d0 5c             	imul   $0x5c,%eax,%edx
80105b16:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b19:	01 d0                	add    %edx,%eax
80105b1b:	83 c0 18             	add    $0x18,%eax
80105b1e:	83 ec 04             	sub    $0x4,%esp
80105b21:	6a 20                	push   $0x20
80105b23:	68 16 9c 10 80       	push   $0x80109c16
80105b28:	50                   	push   %eax
80105b29:	e8 3c 08 00 00       	call   8010636a <safestrcpy>
80105b2e:	83 c4 10             	add    $0x10,%esp

      ++index;
80105b31:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  struct proc *p;
  int index = 0;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC] && index < max; p++)
80105b35:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
80105b3c:	81 7d f4 b4 5e 11 80 	cmpl   $0x80115eb4,-0xc(%ebp)
80105b43:	73 0c                	jae    80105b51 <getprocs+0x1ad>
80105b45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b48:	3b 45 08             	cmp    0x8(%ebp),%eax
80105b4b:	0f 82 7c fe ff ff    	jb     801059cd <getprocs+0x29>

      ++index;
    }
  }

  release(&ptable.lock);
80105b51:	83 ec 0c             	sub    $0xc,%esp
80105b54:	68 80 39 11 80       	push   $0x80113980
80105b59:	e8 0d 04 00 00       	call   80105f6b <release>
80105b5e:	83 c4 10             	add    $0x10,%esp

  return index;
80105b61:	8b 45 f0             	mov    -0x10(%ebp),%eax
} 
80105b64:	c9                   	leave  
80105b65:	c3                   	ret    

80105b66 <removeFromStateList>:

#ifdef CS333_P3P4
//add holding locks check for all functions following
static int
removeFromStateList(struct proc** sList, struct proc* p)
{
80105b66:	55                   	push   %ebp
80105b67:	89 e5                	mov    %esp,%ebp
80105b69:	83 ec 10             	sub    $0x10,%esp
  if (*sList == 0)
80105b6c:	8b 45 08             	mov    0x8(%ebp),%eax
80105b6f:	8b 00                	mov    (%eax),%eax
80105b71:	85 c0                	test   %eax,%eax
80105b73:	75 0a                	jne    80105b7f <removeFromStateList+0x19>
    return -1;
80105b75:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b7a:	e9 95 00 00 00       	jmp    80105c14 <removeFromStateList+0xae>

  else if(*sList == p)
80105b7f:	8b 45 08             	mov    0x8(%ebp),%eax
80105b82:	8b 00                	mov    (%eax),%eax
80105b84:	3b 45 0c             	cmp    0xc(%ebp),%eax
80105b87:	75 2a                	jne    80105bb3 <removeFromStateList+0x4d>
  {
    struct proc *temp = *sList;
80105b89:	8b 45 08             	mov    0x8(%ebp),%eax
80105b8c:	8b 00                	mov    (%eax),%eax
80105b8e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    *sList = temp->next;
80105b91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b94:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
80105b9a:	8b 45 08             	mov    0x8(%ebp),%eax
80105b9d:	89 10                	mov    %edx,(%eax)
    temp->next = 0;
80105b9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ba2:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
80105ba9:	00 00 00 
    return 0;
80105bac:	b8 00 00 00 00       	mov    $0x0,%eax
80105bb1:	eb 61                	jmp    80105c14 <removeFromStateList+0xae>
  }

  else
  {
    struct proc *previous = *sList;
80105bb3:	8b 45 08             	mov    0x8(%ebp),%eax
80105bb6:	8b 00                	mov    (%eax),%eax
80105bb8:	89 45 fc             	mov    %eax,-0x4(%ebp)
    struct proc *current = previous->next;
80105bbb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105bbe:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105bc4:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while(current != 0)
80105bc7:	eb 40                	jmp    80105c09 <removeFromStateList+0xa3>
    {
      if(current == p)
80105bc9:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105bcc:	3b 45 0c             	cmp    0xc(%ebp),%eax
80105bcf:	75 26                	jne    80105bf7 <removeFromStateList+0x91>
      {
        previous->next = current->next;
80105bd1:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105bd4:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
80105bda:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105bdd:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
        current->next = 0;
80105be3:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105be6:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
80105bed:	00 00 00 
        return 0;
80105bf0:	b8 00 00 00 00       	mov    $0x0,%eax
80105bf5:	eb 1d                	jmp    80105c14 <removeFromStateList+0xae>
      }
      previous = current;
80105bf7:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105bfa:	89 45 fc             	mov    %eax,-0x4(%ebp)
      current = current->next;
80105bfd:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105c00:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105c06:	89 45 f8             	mov    %eax,-0x8(%ebp)

  else
  {
    struct proc *previous = *sList;
    struct proc *current = previous->next;
    while(current != 0)
80105c09:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
80105c0d:	75 ba                	jne    80105bc9 <removeFromStateList+0x63>
      previous = current;
      current = current->next;
    }
  }
  
  return -1;
80105c0f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105c14:	c9                   	leave  
80105c15:	c3                   	ret    

80105c16 <assertState>:

static void
assertState(struct proc* p, enum procstate state)
{
80105c16:	55                   	push   %ebp
80105c17:	89 e5                	mov    %esp,%ebp
80105c19:	83 ec 08             	sub    $0x8,%esp
  if(p->state != state)
80105c1c:	8b 45 08             	mov    0x8(%ebp),%eax
80105c1f:	8b 40 0c             	mov    0xc(%eax),%eax
80105c22:	3b 45 0c             	cmp    0xc(%ebp),%eax
80105c25:	74 0d                	je     80105c34 <assertState+0x1e>
    panic("State does not match");
80105c27:	83 ec 0c             	sub    $0xc,%esp
80105c2a:	68 1f 9c 10 80       	push   $0x80109c1f
80105c2f:	e8 32 a9 ff ff       	call   80100566 <panic>
  else
    return;  
80105c34:	90                   	nop
}
80105c35:	c9                   	leave  
80105c36:	c3                   	ret    

80105c37 <addToStateListEnd>:

static int
addToStateListEnd(struct proc** sList, struct proc* p)
{
80105c37:	55                   	push   %ebp
80105c38:	89 e5                	mov    %esp,%ebp
80105c3a:	83 ec 10             	sub    $0x10,%esp
  if(*sList == 0)
80105c3d:	8b 45 08             	mov    0x8(%ebp),%eax
80105c40:	8b 00                	mov    (%eax),%eax
80105c42:	85 c0                	test   %eax,%eax
80105c44:	75 1c                	jne    80105c62 <addToStateListEnd+0x2b>
  {
    *sList = p;
80105c46:	8b 45 08             	mov    0x8(%ebp),%eax
80105c49:	8b 55 0c             	mov    0xc(%ebp),%edx
80105c4c:	89 10                	mov    %edx,(%eax)
    p->next = 0;
80105c4e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c51:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
80105c58:	00 00 00 
    return 0;
80105c5b:	b8 00 00 00 00       	mov    $0x0,%eax
80105c60:	eb 4e                	jmp    80105cb0 <addToStateListEnd+0x79>
  }

  else
  {
    struct proc* current = *sList;
80105c62:	8b 45 08             	mov    0x8(%ebp),%eax
80105c65:	8b 00                	mov    (%eax),%eax
80105c67:	89 45 fc             	mov    %eax,-0x4(%ebp)
  
    while(current != 0)
80105c6a:	eb 39                	jmp    80105ca5 <addToStateListEnd+0x6e>
    { 
      if(current->next == 0)
80105c6c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c6f:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105c75:	85 c0                	test   %eax,%eax
80105c77:	75 20                	jne    80105c99 <addToStateListEnd+0x62>
      {
        current->next = p;
80105c79:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c7c:	8b 55 0c             	mov    0xc(%ebp),%edx
80105c7f:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
        p->next = 0;
80105c85:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c88:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
80105c8f:	00 00 00 
        return 0;
80105c92:	b8 00 00 00 00       	mov    $0x0,%eax
80105c97:	eb 17                	jmp    80105cb0 <addToStateListEnd+0x79>
      }
      current = current->next;
80105c99:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c9c:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105ca2:	89 45 fc             	mov    %eax,-0x4(%ebp)

  else
  {
    struct proc* current = *sList;
  
    while(current != 0)
80105ca5:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105ca9:	75 c1                	jne    80105c6c <addToStateListEnd+0x35>
        return 0;
      }
      current = current->next;
    }
  }
  return -1;
80105cab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105cb0:	c9                   	leave  
80105cb1:	c3                   	ret    

80105cb2 <addToStateListHead>:

static int
addToStateListHead(struct proc ** sList, struct proc* p)
{
80105cb2:	55                   	push   %ebp
80105cb3:	89 e5                	mov    %esp,%ebp
  if(p == 0)
80105cb5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105cb9:	75 07                	jne    80105cc2 <addToStateListHead+0x10>
    return -1;
80105cbb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cc0:	eb 1b                	jmp    80105cdd <addToStateListHead+0x2b>
  p->next = *sList;
80105cc2:	8b 45 08             	mov    0x8(%ebp),%eax
80105cc5:	8b 10                	mov    (%eax),%edx
80105cc7:	8b 45 0c             	mov    0xc(%ebp),%eax
80105cca:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
  *sList = p;
80105cd0:	8b 45 08             	mov    0x8(%ebp),%eax
80105cd3:	8b 55 0c             	mov    0xc(%ebp),%edx
80105cd6:	89 10                	mov    %edx,(%eax)
  return 0;
80105cd8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105cdd:	5d                   	pop    %ebp
80105cde:	c3                   	ret    

80105cdf <doready>:

void
doready(void)
{
80105cdf:	55                   	push   %ebp
80105ce0:	89 e5                	mov    %esp,%ebp
80105ce2:	83 ec 18             	sub    $0x18,%esp
  struct proc *current;

  current = ptable.pLists.ready;
80105ce5:	a1 b4 5e 11 80       	mov    0x80115eb4,%eax
80105cea:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(current == 0)
80105ced:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105cf1:	75 12                	jne    80105d05 <doready+0x26>
  {
    cprintf("No ready processes.");
80105cf3:	83 ec 0c             	sub    $0xc,%esp
80105cf6:	68 34 9c 10 80       	push   $0x80109c34
80105cfb:	e8 c6 a6 ff ff       	call   801003c6 <cprintf>
80105d00:	83 c4 10             	add    $0x10,%esp
    return;
80105d03:	eb 4b                	jmp    80105d50 <doready+0x71>
  }

  cprintf("\nReady List Processes:\n");
80105d05:	83 ec 0c             	sub    $0xc,%esp
80105d08:	68 48 9c 10 80       	push   $0x80109c48
80105d0d:	e8 b4 a6 ff ff       	call   801003c6 <cprintf>
80105d12:	83 c4 10             	add    $0x10,%esp
  while(current != 0)
80105d15:	eb 33                	jmp    80105d4a <doready+0x6b>
  {
    assertState(current, RUNNABLE);
80105d17:	83 ec 08             	sub    $0x8,%esp
80105d1a:	6a 03                	push   $0x3
80105d1c:	ff 75 f4             	pushl  -0xc(%ebp)
80105d1f:	e8 f2 fe ff ff       	call   80105c16 <assertState>
80105d24:	83 c4 10             	add    $0x10,%esp
    cprintf("%d -> ", current->pid);
80105d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d2a:	8b 40 10             	mov    0x10(%eax),%eax
80105d2d:	83 ec 08             	sub    $0x8,%esp
80105d30:	50                   	push   %eax
80105d31:	68 60 9c 10 80       	push   $0x80109c60
80105d36:	e8 8b a6 ff ff       	call   801003c6 <cprintf>
80105d3b:	83 c4 10             	add    $0x10,%esp
    current = current->next;
80105d3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d41:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105d47:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("No ready processes.");
    return;
  }

  cprintf("\nReady List Processes:\n");
  while(current != 0)
80105d4a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d4e:	75 c7                	jne    80105d17 <doready+0x38>
  {
    assertState(current, RUNNABLE);
    cprintf("%d -> ", current->pid);
    current = current->next;
  }
}
80105d50:	c9                   	leave  
80105d51:	c3                   	ret    

80105d52 <dofree>:

void
dofree(void)
{
80105d52:	55                   	push   %ebp
80105d53:	89 e5                	mov    %esp,%ebp
80105d55:	83 ec 18             	sub    $0x18,%esp
  int count = 0;
80105d58:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  struct proc *current;
  
  current = ptable.pLists.free;
80105d5f:	a1 b8 5e 11 80       	mov    0x80115eb8,%eax
80105d64:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(current == 0)
80105d67:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d6b:	75 32                	jne    80105d9f <dofree+0x4d>
  {
    cprintf("No free processes.");
80105d6d:	83 ec 0c             	sub    $0xc,%esp
80105d70:	68 67 9c 10 80       	push   $0x80109c67
80105d75:	e8 4c a6 ff ff       	call   801003c6 <cprintf>
80105d7a:	83 c4 10             	add    $0x10,%esp
    return;
80105d7d:	eb 39                	jmp    80105db8 <dofree+0x66>
  }

  while(current != 0)
  {
    assertState(current, UNUSED);
80105d7f:	83 ec 08             	sub    $0x8,%esp
80105d82:	6a 00                	push   $0x0
80105d84:	ff 75 f0             	pushl  -0x10(%ebp)
80105d87:	e8 8a fe ff ff       	call   80105c16 <assertState>
80105d8c:	83 c4 10             	add    $0x10,%esp
    ++count;
80105d8f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    current = current->next;
80105d93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d96:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105d9c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  {
    cprintf("No free processes.");
    return;
  }

  while(current != 0)
80105d9f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105da3:	75 da                	jne    80105d7f <dofree+0x2d>
    assertState(current, UNUSED);
    ++count;
    current = current->next;
  } 

  cprintf("\nFree List Size: %d processes.\n", count); 
80105da5:	83 ec 08             	sub    $0x8,%esp
80105da8:	ff 75 f4             	pushl  -0xc(%ebp)
80105dab:	68 7c 9c 10 80       	push   $0x80109c7c
80105db0:	e8 11 a6 ff ff       	call   801003c6 <cprintf>
80105db5:	83 c4 10             	add    $0x10,%esp
}
80105db8:	c9                   	leave  
80105db9:	c3                   	ret    

80105dba <dosleep>:

void 
dosleep(void)
{
80105dba:	55                   	push   %ebp
80105dbb:	89 e5                	mov    %esp,%ebp
80105dbd:	83 ec 18             	sub    $0x18,%esp
  struct proc *current;
  
  current = ptable.pLists.sleep;
80105dc0:	a1 bc 5e 11 80       	mov    0x80115ebc,%eax
80105dc5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(current == 0)
80105dc8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105dcc:	75 12                	jne    80105de0 <dosleep+0x26>
  {
    cprintf("No sleeping processes.");
80105dce:	83 ec 0c             	sub    $0xc,%esp
80105dd1:	68 9c 9c 10 80       	push   $0x80109c9c
80105dd6:	e8 eb a5 ff ff       	call   801003c6 <cprintf>
80105ddb:	83 c4 10             	add    $0x10,%esp
    return;
80105dde:	eb 4b                	jmp    80105e2b <dosleep+0x71>
  }

  cprintf("\nSleep List Processes:\n");
80105de0:	83 ec 0c             	sub    $0xc,%esp
80105de3:	68 b3 9c 10 80       	push   $0x80109cb3
80105de8:	e8 d9 a5 ff ff       	call   801003c6 <cprintf>
80105ded:	83 c4 10             	add    $0x10,%esp
  while(current != 0)
80105df0:	eb 33                	jmp    80105e25 <dosleep+0x6b>
  {
    assertState(current, SLEEPING);
80105df2:	83 ec 08             	sub    $0x8,%esp
80105df5:	6a 02                	push   $0x2
80105df7:	ff 75 f4             	pushl  -0xc(%ebp)
80105dfa:	e8 17 fe ff ff       	call   80105c16 <assertState>
80105dff:	83 c4 10             	add    $0x10,%esp
    cprintf("%d -> ", current->pid);
80105e02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e05:	8b 40 10             	mov    0x10(%eax),%eax
80105e08:	83 ec 08             	sub    $0x8,%esp
80105e0b:	50                   	push   %eax
80105e0c:	68 60 9c 10 80       	push   $0x80109c60
80105e11:	e8 b0 a5 ff ff       	call   801003c6 <cprintf>
80105e16:	83 c4 10             	add    $0x10,%esp
    current = current->next;
80105e19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e1c:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105e22:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("No sleeping processes.");
    return;
  }

  cprintf("\nSleep List Processes:\n");
  while(current != 0)
80105e25:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e29:	75 c7                	jne    80105df2 <dosleep+0x38>
  {
    assertState(current, SLEEPING);
    cprintf("%d -> ", current->pid);
    current = current->next;
  }
}
80105e2b:	c9                   	leave  
80105e2c:	c3                   	ret    

80105e2d <dozombie>:

void
dozombie(void)
{
80105e2d:	55                   	push   %ebp
80105e2e:	89 e5                	mov    %esp,%ebp
80105e30:	83 ec 18             	sub    $0x18,%esp
  struct proc *current;
  
  current = ptable.pLists.zombie;
80105e33:	a1 c0 5e 11 80       	mov    0x80115ec0,%eax
80105e38:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(current == 0)
80105e3b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e3f:	75 12                	jne    80105e53 <dozombie+0x26>
  {
    cprintf("No zombie processes.");
80105e41:	83 ec 0c             	sub    $0xc,%esp
80105e44:	68 cb 9c 10 80       	push   $0x80109ccb
80105e49:	e8 78 a5 ff ff       	call   801003c6 <cprintf>
80105e4e:	83 c4 10             	add    $0x10,%esp
    return;
80105e51:	eb 55                	jmp    80105ea8 <dozombie+0x7b>
  }
  
  cprintf("\nZombie List Processes:\n");
80105e53:	83 ec 0c             	sub    $0xc,%esp
80105e56:	68 e0 9c 10 80       	push   $0x80109ce0
80105e5b:	e8 66 a5 ff ff       	call   801003c6 <cprintf>
80105e60:	83 c4 10             	add    $0x10,%esp
  while(current != 0)
80105e63:	eb 3d                	jmp    80105ea2 <dozombie+0x75>
  {
    assertState(current, ZOMBIE);
80105e65:	83 ec 08             	sub    $0x8,%esp
80105e68:	6a 05                	push   $0x5
80105e6a:	ff 75 f4             	pushl  -0xc(%ebp)
80105e6d:	e8 a4 fd ff ff       	call   80105c16 <assertState>
80105e72:	83 c4 10             	add    $0x10,%esp
    cprintf("(%d, %d) -> ", current->pid, current->parent->pid);
80105e75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e78:	8b 40 14             	mov    0x14(%eax),%eax
80105e7b:	8b 50 10             	mov    0x10(%eax),%edx
80105e7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e81:	8b 40 10             	mov    0x10(%eax),%eax
80105e84:	83 ec 04             	sub    $0x4,%esp
80105e87:	52                   	push   %edx
80105e88:	50                   	push   %eax
80105e89:	68 f9 9c 10 80       	push   $0x80109cf9
80105e8e:	e8 33 a5 ff ff       	call   801003c6 <cprintf>
80105e93:	83 c4 10             	add    $0x10,%esp
    current = current->next;
80105e96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e99:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105e9f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("No zombie processes.");
    return;
  }
  
  cprintf("\nZombie List Processes:\n");
  while(current != 0)
80105ea2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ea6:	75 bd                	jne    80105e65 <dozombie+0x38>
  {
    assertState(current, ZOMBIE);
    cprintf("(%d, %d) -> ", current->pid, current->parent->pid);
    current = current->next;
  }
}
80105ea8:	c9                   	leave  
80105ea9:	c3                   	ret    

80105eaa <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105eaa:	55                   	push   %ebp
80105eab:	89 e5                	mov    %esp,%ebp
80105ead:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105eb0:	9c                   	pushf  
80105eb1:	58                   	pop    %eax
80105eb2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105eb5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105eb8:	c9                   	leave  
80105eb9:	c3                   	ret    

80105eba <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105eba:	55                   	push   %ebp
80105ebb:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105ebd:	fa                   	cli    
}
80105ebe:	90                   	nop
80105ebf:	5d                   	pop    %ebp
80105ec0:	c3                   	ret    

80105ec1 <sti>:

static inline void
sti(void)
{
80105ec1:	55                   	push   %ebp
80105ec2:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105ec4:	fb                   	sti    
}
80105ec5:	90                   	nop
80105ec6:	5d                   	pop    %ebp
80105ec7:	c3                   	ret    

80105ec8 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105ec8:	55                   	push   %ebp
80105ec9:	89 e5                	mov    %esp,%ebp
80105ecb:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105ece:	8b 55 08             	mov    0x8(%ebp),%edx
80105ed1:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ed4:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105ed7:	f0 87 02             	lock xchg %eax,(%edx)
80105eda:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105edd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105ee0:	c9                   	leave  
80105ee1:	c3                   	ret    

80105ee2 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105ee2:	55                   	push   %ebp
80105ee3:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105ee5:	8b 45 08             	mov    0x8(%ebp),%eax
80105ee8:	8b 55 0c             	mov    0xc(%ebp),%edx
80105eeb:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105eee:	8b 45 08             	mov    0x8(%ebp),%eax
80105ef1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105ef7:	8b 45 08             	mov    0x8(%ebp),%eax
80105efa:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105f01:	90                   	nop
80105f02:	5d                   	pop    %ebp
80105f03:	c3                   	ret    

80105f04 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105f04:	55                   	push   %ebp
80105f05:	89 e5                	mov    %esp,%ebp
80105f07:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105f0a:	e8 52 01 00 00       	call   80106061 <pushcli>
  if(holding(lk))
80105f0f:	8b 45 08             	mov    0x8(%ebp),%eax
80105f12:	83 ec 0c             	sub    $0xc,%esp
80105f15:	50                   	push   %eax
80105f16:	e8 1c 01 00 00       	call   80106037 <holding>
80105f1b:	83 c4 10             	add    $0x10,%esp
80105f1e:	85 c0                	test   %eax,%eax
80105f20:	74 0d                	je     80105f2f <acquire+0x2b>
    panic("acquire");
80105f22:	83 ec 0c             	sub    $0xc,%esp
80105f25:	68 06 9d 10 80       	push   $0x80109d06
80105f2a:	e8 37 a6 ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105f2f:	90                   	nop
80105f30:	8b 45 08             	mov    0x8(%ebp),%eax
80105f33:	83 ec 08             	sub    $0x8,%esp
80105f36:	6a 01                	push   $0x1
80105f38:	50                   	push   %eax
80105f39:	e8 8a ff ff ff       	call   80105ec8 <xchg>
80105f3e:	83 c4 10             	add    $0x10,%esp
80105f41:	85 c0                	test   %eax,%eax
80105f43:	75 eb                	jne    80105f30 <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105f45:	8b 45 08             	mov    0x8(%ebp),%eax
80105f48:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105f4f:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105f52:	8b 45 08             	mov    0x8(%ebp),%eax
80105f55:	83 c0 0c             	add    $0xc,%eax
80105f58:	83 ec 08             	sub    $0x8,%esp
80105f5b:	50                   	push   %eax
80105f5c:	8d 45 08             	lea    0x8(%ebp),%eax
80105f5f:	50                   	push   %eax
80105f60:	e8 58 00 00 00       	call   80105fbd <getcallerpcs>
80105f65:	83 c4 10             	add    $0x10,%esp
}
80105f68:	90                   	nop
80105f69:	c9                   	leave  
80105f6a:	c3                   	ret    

80105f6b <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105f6b:	55                   	push   %ebp
80105f6c:	89 e5                	mov    %esp,%ebp
80105f6e:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105f71:	83 ec 0c             	sub    $0xc,%esp
80105f74:	ff 75 08             	pushl  0x8(%ebp)
80105f77:	e8 bb 00 00 00       	call   80106037 <holding>
80105f7c:	83 c4 10             	add    $0x10,%esp
80105f7f:	85 c0                	test   %eax,%eax
80105f81:	75 0d                	jne    80105f90 <release+0x25>
    panic("release");
80105f83:	83 ec 0c             	sub    $0xc,%esp
80105f86:	68 0e 9d 10 80       	push   $0x80109d0e
80105f8b:	e8 d6 a5 ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
80105f90:	8b 45 08             	mov    0x8(%ebp),%eax
80105f93:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105f9a:	8b 45 08             	mov    0x8(%ebp),%eax
80105f9d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105fa4:	8b 45 08             	mov    0x8(%ebp),%eax
80105fa7:	83 ec 08             	sub    $0x8,%esp
80105faa:	6a 00                	push   $0x0
80105fac:	50                   	push   %eax
80105fad:	e8 16 ff ff ff       	call   80105ec8 <xchg>
80105fb2:	83 c4 10             	add    $0x10,%esp

  popcli();
80105fb5:	e8 ec 00 00 00       	call   801060a6 <popcli>
}
80105fba:	90                   	nop
80105fbb:	c9                   	leave  
80105fbc:	c3                   	ret    

80105fbd <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105fbd:	55                   	push   %ebp
80105fbe:	89 e5                	mov    %esp,%ebp
80105fc0:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105fc3:	8b 45 08             	mov    0x8(%ebp),%eax
80105fc6:	83 e8 08             	sub    $0x8,%eax
80105fc9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105fcc:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105fd3:	eb 38                	jmp    8010600d <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105fd5:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105fd9:	74 53                	je     8010602e <getcallerpcs+0x71>
80105fdb:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105fe2:	76 4a                	jbe    8010602e <getcallerpcs+0x71>
80105fe4:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105fe8:	74 44                	je     8010602e <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105fea:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105fed:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105ff4:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ff7:	01 c2                	add    %eax,%edx
80105ff9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105ffc:	8b 40 04             	mov    0x4(%eax),%eax
80105fff:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80106001:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106004:	8b 00                	mov    (%eax),%eax
80106006:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80106009:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010600d:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80106011:	7e c2                	jle    80105fd5 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80106013:	eb 19                	jmp    8010602e <getcallerpcs+0x71>
    pcs[i] = 0;
80106015:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106018:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010601f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106022:	01 d0                	add    %edx,%eax
80106024:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
8010602a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010602e:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80106032:	7e e1                	jle    80106015 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80106034:	90                   	nop
80106035:	c9                   	leave  
80106036:	c3                   	ret    

80106037 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80106037:	55                   	push   %ebp
80106038:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
8010603a:	8b 45 08             	mov    0x8(%ebp),%eax
8010603d:	8b 00                	mov    (%eax),%eax
8010603f:	85 c0                	test   %eax,%eax
80106041:	74 17                	je     8010605a <holding+0x23>
80106043:	8b 45 08             	mov    0x8(%ebp),%eax
80106046:	8b 50 08             	mov    0x8(%eax),%edx
80106049:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010604f:	39 c2                	cmp    %eax,%edx
80106051:	75 07                	jne    8010605a <holding+0x23>
80106053:	b8 01 00 00 00       	mov    $0x1,%eax
80106058:	eb 05                	jmp    8010605f <holding+0x28>
8010605a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010605f:	5d                   	pop    %ebp
80106060:	c3                   	ret    

80106061 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80106061:	55                   	push   %ebp
80106062:	89 e5                	mov    %esp,%ebp
80106064:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80106067:	e8 3e fe ff ff       	call   80105eaa <readeflags>
8010606c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
8010606f:	e8 46 fe ff ff       	call   80105eba <cli>
  if(cpu->ncli++ == 0)
80106074:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010607b:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80106081:	8d 48 01             	lea    0x1(%eax),%ecx
80106084:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
8010608a:	85 c0                	test   %eax,%eax
8010608c:	75 15                	jne    801060a3 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
8010608e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106094:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106097:	81 e2 00 02 00 00    	and    $0x200,%edx
8010609d:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
801060a3:	90                   	nop
801060a4:	c9                   	leave  
801060a5:	c3                   	ret    

801060a6 <popcli>:

void
popcli(void)
{
801060a6:	55                   	push   %ebp
801060a7:	89 e5                	mov    %esp,%ebp
801060a9:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
801060ac:	e8 f9 fd ff ff       	call   80105eaa <readeflags>
801060b1:	25 00 02 00 00       	and    $0x200,%eax
801060b6:	85 c0                	test   %eax,%eax
801060b8:	74 0d                	je     801060c7 <popcli+0x21>
    panic("popcli - interruptible");
801060ba:	83 ec 0c             	sub    $0xc,%esp
801060bd:	68 16 9d 10 80       	push   $0x80109d16
801060c2:	e8 9f a4 ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
801060c7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801060cd:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
801060d3:	83 ea 01             	sub    $0x1,%edx
801060d6:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
801060dc:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801060e2:	85 c0                	test   %eax,%eax
801060e4:	79 0d                	jns    801060f3 <popcli+0x4d>
    panic("popcli");
801060e6:	83 ec 0c             	sub    $0xc,%esp
801060e9:	68 2d 9d 10 80       	push   $0x80109d2d
801060ee:	e8 73 a4 ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
801060f3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801060f9:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801060ff:	85 c0                	test   %eax,%eax
80106101:	75 15                	jne    80106118 <popcli+0x72>
80106103:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106109:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
8010610f:	85 c0                	test   %eax,%eax
80106111:	74 05                	je     80106118 <popcli+0x72>
    sti();
80106113:	e8 a9 fd ff ff       	call   80105ec1 <sti>
}
80106118:	90                   	nop
80106119:	c9                   	leave  
8010611a:	c3                   	ret    

8010611b <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
8010611b:	55                   	push   %ebp
8010611c:	89 e5                	mov    %esp,%ebp
8010611e:	57                   	push   %edi
8010611f:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80106120:	8b 4d 08             	mov    0x8(%ebp),%ecx
80106123:	8b 55 10             	mov    0x10(%ebp),%edx
80106126:	8b 45 0c             	mov    0xc(%ebp),%eax
80106129:	89 cb                	mov    %ecx,%ebx
8010612b:	89 df                	mov    %ebx,%edi
8010612d:	89 d1                	mov    %edx,%ecx
8010612f:	fc                   	cld    
80106130:	f3 aa                	rep stos %al,%es:(%edi)
80106132:	89 ca                	mov    %ecx,%edx
80106134:	89 fb                	mov    %edi,%ebx
80106136:	89 5d 08             	mov    %ebx,0x8(%ebp)
80106139:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010613c:	90                   	nop
8010613d:	5b                   	pop    %ebx
8010613e:	5f                   	pop    %edi
8010613f:	5d                   	pop    %ebp
80106140:	c3                   	ret    

80106141 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80106141:	55                   	push   %ebp
80106142:	89 e5                	mov    %esp,%ebp
80106144:	57                   	push   %edi
80106145:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80106146:	8b 4d 08             	mov    0x8(%ebp),%ecx
80106149:	8b 55 10             	mov    0x10(%ebp),%edx
8010614c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010614f:	89 cb                	mov    %ecx,%ebx
80106151:	89 df                	mov    %ebx,%edi
80106153:	89 d1                	mov    %edx,%ecx
80106155:	fc                   	cld    
80106156:	f3 ab                	rep stos %eax,%es:(%edi)
80106158:	89 ca                	mov    %ecx,%edx
8010615a:	89 fb                	mov    %edi,%ebx
8010615c:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010615f:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80106162:	90                   	nop
80106163:	5b                   	pop    %ebx
80106164:	5f                   	pop    %edi
80106165:	5d                   	pop    %ebp
80106166:	c3                   	ret    

80106167 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80106167:	55                   	push   %ebp
80106168:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
8010616a:	8b 45 08             	mov    0x8(%ebp),%eax
8010616d:	83 e0 03             	and    $0x3,%eax
80106170:	85 c0                	test   %eax,%eax
80106172:	75 43                	jne    801061b7 <memset+0x50>
80106174:	8b 45 10             	mov    0x10(%ebp),%eax
80106177:	83 e0 03             	and    $0x3,%eax
8010617a:	85 c0                	test   %eax,%eax
8010617c:	75 39                	jne    801061b7 <memset+0x50>
    c &= 0xFF;
8010617e:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80106185:	8b 45 10             	mov    0x10(%ebp),%eax
80106188:	c1 e8 02             	shr    $0x2,%eax
8010618b:	89 c1                	mov    %eax,%ecx
8010618d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106190:	c1 e0 18             	shl    $0x18,%eax
80106193:	89 c2                	mov    %eax,%edx
80106195:	8b 45 0c             	mov    0xc(%ebp),%eax
80106198:	c1 e0 10             	shl    $0x10,%eax
8010619b:	09 c2                	or     %eax,%edx
8010619d:	8b 45 0c             	mov    0xc(%ebp),%eax
801061a0:	c1 e0 08             	shl    $0x8,%eax
801061a3:	09 d0                	or     %edx,%eax
801061a5:	0b 45 0c             	or     0xc(%ebp),%eax
801061a8:	51                   	push   %ecx
801061a9:	50                   	push   %eax
801061aa:	ff 75 08             	pushl  0x8(%ebp)
801061ad:	e8 8f ff ff ff       	call   80106141 <stosl>
801061b2:	83 c4 0c             	add    $0xc,%esp
801061b5:	eb 12                	jmp    801061c9 <memset+0x62>
  } else
    stosb(dst, c, n);
801061b7:	8b 45 10             	mov    0x10(%ebp),%eax
801061ba:	50                   	push   %eax
801061bb:	ff 75 0c             	pushl  0xc(%ebp)
801061be:	ff 75 08             	pushl  0x8(%ebp)
801061c1:	e8 55 ff ff ff       	call   8010611b <stosb>
801061c6:	83 c4 0c             	add    $0xc,%esp
  return dst;
801061c9:	8b 45 08             	mov    0x8(%ebp),%eax
}
801061cc:	c9                   	leave  
801061cd:	c3                   	ret    

801061ce <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801061ce:	55                   	push   %ebp
801061cf:	89 e5                	mov    %esp,%ebp
801061d1:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
801061d4:	8b 45 08             	mov    0x8(%ebp),%eax
801061d7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801061da:	8b 45 0c             	mov    0xc(%ebp),%eax
801061dd:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801061e0:	eb 30                	jmp    80106212 <memcmp+0x44>
    if(*s1 != *s2)
801061e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801061e5:	0f b6 10             	movzbl (%eax),%edx
801061e8:	8b 45 f8             	mov    -0x8(%ebp),%eax
801061eb:	0f b6 00             	movzbl (%eax),%eax
801061ee:	38 c2                	cmp    %al,%dl
801061f0:	74 18                	je     8010620a <memcmp+0x3c>
      return *s1 - *s2;
801061f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801061f5:	0f b6 00             	movzbl (%eax),%eax
801061f8:	0f b6 d0             	movzbl %al,%edx
801061fb:	8b 45 f8             	mov    -0x8(%ebp),%eax
801061fe:	0f b6 00             	movzbl (%eax),%eax
80106201:	0f b6 c0             	movzbl %al,%eax
80106204:	29 c2                	sub    %eax,%edx
80106206:	89 d0                	mov    %edx,%eax
80106208:	eb 1a                	jmp    80106224 <memcmp+0x56>
    s1++, s2++;
8010620a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010620e:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80106212:	8b 45 10             	mov    0x10(%ebp),%eax
80106215:	8d 50 ff             	lea    -0x1(%eax),%edx
80106218:	89 55 10             	mov    %edx,0x10(%ebp)
8010621b:	85 c0                	test   %eax,%eax
8010621d:	75 c3                	jne    801061e2 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
8010621f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106224:	c9                   	leave  
80106225:	c3                   	ret    

80106226 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80106226:	55                   	push   %ebp
80106227:	89 e5                	mov    %esp,%ebp
80106229:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
8010622c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010622f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80106232:	8b 45 08             	mov    0x8(%ebp),%eax
80106235:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80106238:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010623b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010623e:	73 54                	jae    80106294 <memmove+0x6e>
80106240:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106243:	8b 45 10             	mov    0x10(%ebp),%eax
80106246:	01 d0                	add    %edx,%eax
80106248:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010624b:	76 47                	jbe    80106294 <memmove+0x6e>
    s += n;
8010624d:	8b 45 10             	mov    0x10(%ebp),%eax
80106250:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80106253:	8b 45 10             	mov    0x10(%ebp),%eax
80106256:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80106259:	eb 13                	jmp    8010626e <memmove+0x48>
      *--d = *--s;
8010625b:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
8010625f:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80106263:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106266:	0f b6 10             	movzbl (%eax),%edx
80106269:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010626c:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
8010626e:	8b 45 10             	mov    0x10(%ebp),%eax
80106271:	8d 50 ff             	lea    -0x1(%eax),%edx
80106274:	89 55 10             	mov    %edx,0x10(%ebp)
80106277:	85 c0                	test   %eax,%eax
80106279:	75 e0                	jne    8010625b <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
8010627b:	eb 24                	jmp    801062a1 <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
8010627d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106280:	8d 50 01             	lea    0x1(%eax),%edx
80106283:	89 55 f8             	mov    %edx,-0x8(%ebp)
80106286:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106289:	8d 4a 01             	lea    0x1(%edx),%ecx
8010628c:	89 4d fc             	mov    %ecx,-0x4(%ebp)
8010628f:	0f b6 12             	movzbl (%edx),%edx
80106292:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80106294:	8b 45 10             	mov    0x10(%ebp),%eax
80106297:	8d 50 ff             	lea    -0x1(%eax),%edx
8010629a:	89 55 10             	mov    %edx,0x10(%ebp)
8010629d:	85 c0                	test   %eax,%eax
8010629f:	75 dc                	jne    8010627d <memmove+0x57>
      *d++ = *s++;

  return dst;
801062a1:	8b 45 08             	mov    0x8(%ebp),%eax
}
801062a4:	c9                   	leave  
801062a5:	c3                   	ret    

801062a6 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801062a6:	55                   	push   %ebp
801062a7:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
801062a9:	ff 75 10             	pushl  0x10(%ebp)
801062ac:	ff 75 0c             	pushl  0xc(%ebp)
801062af:	ff 75 08             	pushl  0x8(%ebp)
801062b2:	e8 6f ff ff ff       	call   80106226 <memmove>
801062b7:	83 c4 0c             	add    $0xc,%esp
}
801062ba:	c9                   	leave  
801062bb:	c3                   	ret    

801062bc <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801062bc:	55                   	push   %ebp
801062bd:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801062bf:	eb 0c                	jmp    801062cd <strncmp+0x11>
    n--, p++, q++;
801062c1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801062c5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801062c9:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
801062cd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801062d1:	74 1a                	je     801062ed <strncmp+0x31>
801062d3:	8b 45 08             	mov    0x8(%ebp),%eax
801062d6:	0f b6 00             	movzbl (%eax),%eax
801062d9:	84 c0                	test   %al,%al
801062db:	74 10                	je     801062ed <strncmp+0x31>
801062dd:	8b 45 08             	mov    0x8(%ebp),%eax
801062e0:	0f b6 10             	movzbl (%eax),%edx
801062e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801062e6:	0f b6 00             	movzbl (%eax),%eax
801062e9:	38 c2                	cmp    %al,%dl
801062eb:	74 d4                	je     801062c1 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
801062ed:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801062f1:	75 07                	jne    801062fa <strncmp+0x3e>
    return 0;
801062f3:	b8 00 00 00 00       	mov    $0x0,%eax
801062f8:	eb 16                	jmp    80106310 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
801062fa:	8b 45 08             	mov    0x8(%ebp),%eax
801062fd:	0f b6 00             	movzbl (%eax),%eax
80106300:	0f b6 d0             	movzbl %al,%edx
80106303:	8b 45 0c             	mov    0xc(%ebp),%eax
80106306:	0f b6 00             	movzbl (%eax),%eax
80106309:	0f b6 c0             	movzbl %al,%eax
8010630c:	29 c2                	sub    %eax,%edx
8010630e:	89 d0                	mov    %edx,%eax
}
80106310:	5d                   	pop    %ebp
80106311:	c3                   	ret    

80106312 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80106312:	55                   	push   %ebp
80106313:	89 e5                	mov    %esp,%ebp
80106315:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80106318:	8b 45 08             	mov    0x8(%ebp),%eax
8010631b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010631e:	90                   	nop
8010631f:	8b 45 10             	mov    0x10(%ebp),%eax
80106322:	8d 50 ff             	lea    -0x1(%eax),%edx
80106325:	89 55 10             	mov    %edx,0x10(%ebp)
80106328:	85 c0                	test   %eax,%eax
8010632a:	7e 2c                	jle    80106358 <strncpy+0x46>
8010632c:	8b 45 08             	mov    0x8(%ebp),%eax
8010632f:	8d 50 01             	lea    0x1(%eax),%edx
80106332:	89 55 08             	mov    %edx,0x8(%ebp)
80106335:	8b 55 0c             	mov    0xc(%ebp),%edx
80106338:	8d 4a 01             	lea    0x1(%edx),%ecx
8010633b:	89 4d 0c             	mov    %ecx,0xc(%ebp)
8010633e:	0f b6 12             	movzbl (%edx),%edx
80106341:	88 10                	mov    %dl,(%eax)
80106343:	0f b6 00             	movzbl (%eax),%eax
80106346:	84 c0                	test   %al,%al
80106348:	75 d5                	jne    8010631f <strncpy+0xd>
    ;
  while(n-- > 0)
8010634a:	eb 0c                	jmp    80106358 <strncpy+0x46>
    *s++ = 0;
8010634c:	8b 45 08             	mov    0x8(%ebp),%eax
8010634f:	8d 50 01             	lea    0x1(%eax),%edx
80106352:	89 55 08             	mov    %edx,0x8(%ebp)
80106355:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80106358:	8b 45 10             	mov    0x10(%ebp),%eax
8010635b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010635e:	89 55 10             	mov    %edx,0x10(%ebp)
80106361:	85 c0                	test   %eax,%eax
80106363:	7f e7                	jg     8010634c <strncpy+0x3a>
    *s++ = 0;
  return os;
80106365:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106368:	c9                   	leave  
80106369:	c3                   	ret    

8010636a <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
8010636a:	55                   	push   %ebp
8010636b:	89 e5                	mov    %esp,%ebp
8010636d:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80106370:	8b 45 08             	mov    0x8(%ebp),%eax
80106373:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80106376:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010637a:	7f 05                	jg     80106381 <safestrcpy+0x17>
    return os;
8010637c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010637f:	eb 31                	jmp    801063b2 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80106381:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80106385:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106389:	7e 1e                	jle    801063a9 <safestrcpy+0x3f>
8010638b:	8b 45 08             	mov    0x8(%ebp),%eax
8010638e:	8d 50 01             	lea    0x1(%eax),%edx
80106391:	89 55 08             	mov    %edx,0x8(%ebp)
80106394:	8b 55 0c             	mov    0xc(%ebp),%edx
80106397:	8d 4a 01             	lea    0x1(%edx),%ecx
8010639a:	89 4d 0c             	mov    %ecx,0xc(%ebp)
8010639d:	0f b6 12             	movzbl (%edx),%edx
801063a0:	88 10                	mov    %dl,(%eax)
801063a2:	0f b6 00             	movzbl (%eax),%eax
801063a5:	84 c0                	test   %al,%al
801063a7:	75 d8                	jne    80106381 <safestrcpy+0x17>
    ;
  *s = 0;
801063a9:	8b 45 08             	mov    0x8(%ebp),%eax
801063ac:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801063af:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801063b2:	c9                   	leave  
801063b3:	c3                   	ret    

801063b4 <strlen>:

int
strlen(const char *s)
{
801063b4:	55                   	push   %ebp
801063b5:	89 e5                	mov    %esp,%ebp
801063b7:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801063ba:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801063c1:	eb 04                	jmp    801063c7 <strlen+0x13>
801063c3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801063c7:	8b 55 fc             	mov    -0x4(%ebp),%edx
801063ca:	8b 45 08             	mov    0x8(%ebp),%eax
801063cd:	01 d0                	add    %edx,%eax
801063cf:	0f b6 00             	movzbl (%eax),%eax
801063d2:	84 c0                	test   %al,%al
801063d4:	75 ed                	jne    801063c3 <strlen+0xf>
    ;
  return n;
801063d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801063d9:	c9                   	leave  
801063da:	c3                   	ret    

801063db <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
801063db:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801063df:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801063e3:	55                   	push   %ebp
  pushl %ebx
801063e4:	53                   	push   %ebx
  pushl %esi
801063e5:	56                   	push   %esi
  pushl %edi
801063e6:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801063e7:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801063e9:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801063eb:	5f                   	pop    %edi
  popl %esi
801063ec:	5e                   	pop    %esi
  popl %ebx
801063ed:	5b                   	pop    %ebx
  popl %ebp
801063ee:	5d                   	pop    %ebp
  ret
801063ef:	c3                   	ret    

801063f0 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801063f0:	55                   	push   %ebp
801063f1:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
801063f3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801063f9:	8b 00                	mov    (%eax),%eax
801063fb:	3b 45 08             	cmp    0x8(%ebp),%eax
801063fe:	76 12                	jbe    80106412 <fetchint+0x22>
80106400:	8b 45 08             	mov    0x8(%ebp),%eax
80106403:	8d 50 04             	lea    0x4(%eax),%edx
80106406:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010640c:	8b 00                	mov    (%eax),%eax
8010640e:	39 c2                	cmp    %eax,%edx
80106410:	76 07                	jbe    80106419 <fetchint+0x29>
    return -1;
80106412:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106417:	eb 0f                	jmp    80106428 <fetchint+0x38>
  *ip = *(int*)(addr);
80106419:	8b 45 08             	mov    0x8(%ebp),%eax
8010641c:	8b 10                	mov    (%eax),%edx
8010641e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106421:	89 10                	mov    %edx,(%eax)
  return 0;
80106423:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106428:	5d                   	pop    %ebp
80106429:	c3                   	ret    

8010642a <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010642a:	55                   	push   %ebp
8010642b:	89 e5                	mov    %esp,%ebp
8010642d:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80106430:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106436:	8b 00                	mov    (%eax),%eax
80106438:	3b 45 08             	cmp    0x8(%ebp),%eax
8010643b:	77 07                	ja     80106444 <fetchstr+0x1a>
    return -1;
8010643d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106442:	eb 46                	jmp    8010648a <fetchstr+0x60>
  *pp = (char*)addr;
80106444:	8b 55 08             	mov    0x8(%ebp),%edx
80106447:	8b 45 0c             	mov    0xc(%ebp),%eax
8010644a:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
8010644c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106452:	8b 00                	mov    (%eax),%eax
80106454:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80106457:	8b 45 0c             	mov    0xc(%ebp),%eax
8010645a:	8b 00                	mov    (%eax),%eax
8010645c:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010645f:	eb 1c                	jmp    8010647d <fetchstr+0x53>
    if(*s == 0)
80106461:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106464:	0f b6 00             	movzbl (%eax),%eax
80106467:	84 c0                	test   %al,%al
80106469:	75 0e                	jne    80106479 <fetchstr+0x4f>
      return s - *pp;
8010646b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010646e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106471:	8b 00                	mov    (%eax),%eax
80106473:	29 c2                	sub    %eax,%edx
80106475:	89 d0                	mov    %edx,%eax
80106477:	eb 11                	jmp    8010648a <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80106479:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010647d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106480:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80106483:	72 dc                	jb     80106461 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80106485:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010648a:	c9                   	leave  
8010648b:	c3                   	ret    

8010648c <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010648c:	55                   	push   %ebp
8010648d:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
8010648f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106495:	8b 40 18             	mov    0x18(%eax),%eax
80106498:	8b 40 44             	mov    0x44(%eax),%eax
8010649b:	8b 55 08             	mov    0x8(%ebp),%edx
8010649e:	c1 e2 02             	shl    $0x2,%edx
801064a1:	01 d0                	add    %edx,%eax
801064a3:	83 c0 04             	add    $0x4,%eax
801064a6:	ff 75 0c             	pushl  0xc(%ebp)
801064a9:	50                   	push   %eax
801064aa:	e8 41 ff ff ff       	call   801063f0 <fetchint>
801064af:	83 c4 08             	add    $0x8,%esp
}
801064b2:	c9                   	leave  
801064b3:	c3                   	ret    

801064b4 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801064b4:	55                   	push   %ebp
801064b5:	89 e5                	mov    %esp,%ebp
801064b7:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
801064ba:	8d 45 fc             	lea    -0x4(%ebp),%eax
801064bd:	50                   	push   %eax
801064be:	ff 75 08             	pushl  0x8(%ebp)
801064c1:	e8 c6 ff ff ff       	call   8010648c <argint>
801064c6:	83 c4 08             	add    $0x8,%esp
801064c9:	85 c0                	test   %eax,%eax
801064cb:	79 07                	jns    801064d4 <argptr+0x20>
    return -1;
801064cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064d2:	eb 3b                	jmp    8010650f <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
801064d4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064da:	8b 00                	mov    (%eax),%eax
801064dc:	8b 55 fc             	mov    -0x4(%ebp),%edx
801064df:	39 d0                	cmp    %edx,%eax
801064e1:	76 16                	jbe    801064f9 <argptr+0x45>
801064e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801064e6:	89 c2                	mov    %eax,%edx
801064e8:	8b 45 10             	mov    0x10(%ebp),%eax
801064eb:	01 c2                	add    %eax,%edx
801064ed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064f3:	8b 00                	mov    (%eax),%eax
801064f5:	39 c2                	cmp    %eax,%edx
801064f7:	76 07                	jbe    80106500 <argptr+0x4c>
    return -1;
801064f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064fe:	eb 0f                	jmp    8010650f <argptr+0x5b>
  *pp = (char*)i;
80106500:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106503:	89 c2                	mov    %eax,%edx
80106505:	8b 45 0c             	mov    0xc(%ebp),%eax
80106508:	89 10                	mov    %edx,(%eax)
  return 0;
8010650a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010650f:	c9                   	leave  
80106510:	c3                   	ret    

80106511 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80106511:	55                   	push   %ebp
80106512:	89 e5                	mov    %esp,%ebp
80106514:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
80106517:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010651a:	50                   	push   %eax
8010651b:	ff 75 08             	pushl  0x8(%ebp)
8010651e:	e8 69 ff ff ff       	call   8010648c <argint>
80106523:	83 c4 08             	add    $0x8,%esp
80106526:	85 c0                	test   %eax,%eax
80106528:	79 07                	jns    80106531 <argstr+0x20>
    return -1;
8010652a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010652f:	eb 0f                	jmp    80106540 <argstr+0x2f>
  return fetchstr(addr, pp);
80106531:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106534:	ff 75 0c             	pushl  0xc(%ebp)
80106537:	50                   	push   %eax
80106538:	e8 ed fe ff ff       	call   8010642a <fetchstr>
8010653d:	83 c4 08             	add    $0x8,%esp
}
80106540:	c9                   	leave  
80106541:	c3                   	ret    

80106542 <syscall>:
};
#endif

void
syscall(void)
{
80106542:	55                   	push   %ebp
80106543:	89 e5                	mov    %esp,%ebp
80106545:	53                   	push   %ebx
80106546:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
80106549:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010654f:	8b 40 18             	mov    0x18(%eax),%eax
80106552:	8b 40 1c             	mov    0x1c(%eax),%eax
80106555:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80106558:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010655c:	7e 30                	jle    8010658e <syscall+0x4c>
8010655e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106561:	83 f8 1d             	cmp    $0x1d,%eax
80106564:	77 28                	ja     8010658e <syscall+0x4c>
80106566:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106569:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80106570:	85 c0                	test   %eax,%eax
80106572:	74 1a                	je     8010658e <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80106574:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010657a:	8b 58 18             	mov    0x18(%eax),%ebx
8010657d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106580:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80106587:	ff d0                	call   *%eax
80106589:	89 43 1c             	mov    %eax,0x1c(%ebx)
8010658c:	eb 34                	jmp    801065c2 <syscall+0x80>
  cprintf("%s -> %d\n", syscallnames[num], proc->tf->eax);
#endif

  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
8010658e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106594:	8d 50 6c             	lea    0x6c(%eax),%edx
80106597:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
#ifdef PRINT_SYSCALLS//CS333_P1
  cprintf("%s -> %d\n", syscallnames[num], proc->tf->eax);
#endif

  } else {
    cprintf("%d %s: unknown sys call %d\n",
8010659d:	8b 40 10             	mov    0x10(%eax),%eax
801065a0:	ff 75 f4             	pushl  -0xc(%ebp)
801065a3:	52                   	push   %edx
801065a4:	50                   	push   %eax
801065a5:	68 34 9d 10 80       	push   $0x80109d34
801065aa:	e8 17 9e ff ff       	call   801003c6 <cprintf>
801065af:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
801065b2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065b8:	8b 40 18             	mov    0x18(%eax),%eax
801065bb:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801065c2:	90                   	nop
801065c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801065c6:	c9                   	leave  
801065c7:	c3                   	ret    

801065c8 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801065c8:	55                   	push   %ebp
801065c9:	89 e5                	mov    %esp,%ebp
801065cb:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801065ce:	83 ec 08             	sub    $0x8,%esp
801065d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065d4:	50                   	push   %eax
801065d5:	ff 75 08             	pushl  0x8(%ebp)
801065d8:	e8 af fe ff ff       	call   8010648c <argint>
801065dd:	83 c4 10             	add    $0x10,%esp
801065e0:	85 c0                	test   %eax,%eax
801065e2:	79 07                	jns    801065eb <argfd+0x23>
    return -1;
801065e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065e9:	eb 50                	jmp    8010663b <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
801065eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065ee:	85 c0                	test   %eax,%eax
801065f0:	78 21                	js     80106613 <argfd+0x4b>
801065f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065f5:	83 f8 0f             	cmp    $0xf,%eax
801065f8:	7f 19                	jg     80106613 <argfd+0x4b>
801065fa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106600:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106603:	83 c2 08             	add    $0x8,%edx
80106606:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010660a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010660d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106611:	75 07                	jne    8010661a <argfd+0x52>
    return -1;
80106613:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106618:	eb 21                	jmp    8010663b <argfd+0x73>
  if(pfd)
8010661a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010661e:	74 08                	je     80106628 <argfd+0x60>
    *pfd = fd;
80106620:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106623:	8b 45 0c             	mov    0xc(%ebp),%eax
80106626:	89 10                	mov    %edx,(%eax)
  if(pf)
80106628:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010662c:	74 08                	je     80106636 <argfd+0x6e>
    *pf = f;
8010662e:	8b 45 10             	mov    0x10(%ebp),%eax
80106631:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106634:	89 10                	mov    %edx,(%eax)
  return 0;
80106636:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010663b:	c9                   	leave  
8010663c:	c3                   	ret    

8010663d <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010663d:	55                   	push   %ebp
8010663e:	89 e5                	mov    %esp,%ebp
80106640:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80106643:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010664a:	eb 30                	jmp    8010667c <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
8010664c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106652:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106655:	83 c2 08             	add    $0x8,%edx
80106658:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010665c:	85 c0                	test   %eax,%eax
8010665e:	75 18                	jne    80106678 <fdalloc+0x3b>
      proc->ofile[fd] = f;
80106660:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106666:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106669:	8d 4a 08             	lea    0x8(%edx),%ecx
8010666c:	8b 55 08             	mov    0x8(%ebp),%edx
8010666f:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80106673:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106676:	eb 0f                	jmp    80106687 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80106678:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010667c:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80106680:	7e ca                	jle    8010664c <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80106682:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106687:	c9                   	leave  
80106688:	c3                   	ret    

80106689 <sys_dup>:

int
sys_dup(void)
{
80106689:	55                   	push   %ebp
8010668a:	89 e5                	mov    %esp,%ebp
8010668c:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
8010668f:	83 ec 04             	sub    $0x4,%esp
80106692:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106695:	50                   	push   %eax
80106696:	6a 00                	push   $0x0
80106698:	6a 00                	push   $0x0
8010669a:	e8 29 ff ff ff       	call   801065c8 <argfd>
8010669f:	83 c4 10             	add    $0x10,%esp
801066a2:	85 c0                	test   %eax,%eax
801066a4:	79 07                	jns    801066ad <sys_dup+0x24>
    return -1;
801066a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066ab:	eb 31                	jmp    801066de <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801066ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066b0:	83 ec 0c             	sub    $0xc,%esp
801066b3:	50                   	push   %eax
801066b4:	e8 84 ff ff ff       	call   8010663d <fdalloc>
801066b9:	83 c4 10             	add    $0x10,%esp
801066bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801066bf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801066c3:	79 07                	jns    801066cc <sys_dup+0x43>
    return -1;
801066c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066ca:	eb 12                	jmp    801066de <sys_dup+0x55>
  filedup(f);
801066cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066cf:	83 ec 0c             	sub    $0xc,%esp
801066d2:	50                   	push   %eax
801066d3:	e8 bc a9 ff ff       	call   80101094 <filedup>
801066d8:	83 c4 10             	add    $0x10,%esp
  return fd;
801066db:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801066de:	c9                   	leave  
801066df:	c3                   	ret    

801066e0 <sys_read>:

int
sys_read(void)
{
801066e0:	55                   	push   %ebp
801066e1:	89 e5                	mov    %esp,%ebp
801066e3:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801066e6:	83 ec 04             	sub    $0x4,%esp
801066e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
801066ec:	50                   	push   %eax
801066ed:	6a 00                	push   $0x0
801066ef:	6a 00                	push   $0x0
801066f1:	e8 d2 fe ff ff       	call   801065c8 <argfd>
801066f6:	83 c4 10             	add    $0x10,%esp
801066f9:	85 c0                	test   %eax,%eax
801066fb:	78 2e                	js     8010672b <sys_read+0x4b>
801066fd:	83 ec 08             	sub    $0x8,%esp
80106700:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106703:	50                   	push   %eax
80106704:	6a 02                	push   $0x2
80106706:	e8 81 fd ff ff       	call   8010648c <argint>
8010670b:	83 c4 10             	add    $0x10,%esp
8010670e:	85 c0                	test   %eax,%eax
80106710:	78 19                	js     8010672b <sys_read+0x4b>
80106712:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106715:	83 ec 04             	sub    $0x4,%esp
80106718:	50                   	push   %eax
80106719:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010671c:	50                   	push   %eax
8010671d:	6a 01                	push   $0x1
8010671f:	e8 90 fd ff ff       	call   801064b4 <argptr>
80106724:	83 c4 10             	add    $0x10,%esp
80106727:	85 c0                	test   %eax,%eax
80106729:	79 07                	jns    80106732 <sys_read+0x52>
    return -1;
8010672b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106730:	eb 17                	jmp    80106749 <sys_read+0x69>
  return fileread(f, p, n);
80106732:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80106735:	8b 55 ec             	mov    -0x14(%ebp),%edx
80106738:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010673b:	83 ec 04             	sub    $0x4,%esp
8010673e:	51                   	push   %ecx
8010673f:	52                   	push   %edx
80106740:	50                   	push   %eax
80106741:	e8 de aa ff ff       	call   80101224 <fileread>
80106746:	83 c4 10             	add    $0x10,%esp
}
80106749:	c9                   	leave  
8010674a:	c3                   	ret    

8010674b <sys_write>:

int
sys_write(void)
{
8010674b:	55                   	push   %ebp
8010674c:	89 e5                	mov    %esp,%ebp
8010674e:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80106751:	83 ec 04             	sub    $0x4,%esp
80106754:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106757:	50                   	push   %eax
80106758:	6a 00                	push   $0x0
8010675a:	6a 00                	push   $0x0
8010675c:	e8 67 fe ff ff       	call   801065c8 <argfd>
80106761:	83 c4 10             	add    $0x10,%esp
80106764:	85 c0                	test   %eax,%eax
80106766:	78 2e                	js     80106796 <sys_write+0x4b>
80106768:	83 ec 08             	sub    $0x8,%esp
8010676b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010676e:	50                   	push   %eax
8010676f:	6a 02                	push   $0x2
80106771:	e8 16 fd ff ff       	call   8010648c <argint>
80106776:	83 c4 10             	add    $0x10,%esp
80106779:	85 c0                	test   %eax,%eax
8010677b:	78 19                	js     80106796 <sys_write+0x4b>
8010677d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106780:	83 ec 04             	sub    $0x4,%esp
80106783:	50                   	push   %eax
80106784:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106787:	50                   	push   %eax
80106788:	6a 01                	push   $0x1
8010678a:	e8 25 fd ff ff       	call   801064b4 <argptr>
8010678f:	83 c4 10             	add    $0x10,%esp
80106792:	85 c0                	test   %eax,%eax
80106794:	79 07                	jns    8010679d <sys_write+0x52>
    return -1;
80106796:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010679b:	eb 17                	jmp    801067b4 <sys_write+0x69>
  return filewrite(f, p, n);
8010679d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801067a0:	8b 55 ec             	mov    -0x14(%ebp),%edx
801067a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067a6:	83 ec 04             	sub    $0x4,%esp
801067a9:	51                   	push   %ecx
801067aa:	52                   	push   %edx
801067ab:	50                   	push   %eax
801067ac:	e8 2b ab ff ff       	call   801012dc <filewrite>
801067b1:	83 c4 10             	add    $0x10,%esp
}
801067b4:	c9                   	leave  
801067b5:	c3                   	ret    

801067b6 <sys_close>:

int
sys_close(void)
{
801067b6:	55                   	push   %ebp
801067b7:	89 e5                	mov    %esp,%ebp
801067b9:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
801067bc:	83 ec 04             	sub    $0x4,%esp
801067bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
801067c2:	50                   	push   %eax
801067c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
801067c6:	50                   	push   %eax
801067c7:	6a 00                	push   $0x0
801067c9:	e8 fa fd ff ff       	call   801065c8 <argfd>
801067ce:	83 c4 10             	add    $0x10,%esp
801067d1:	85 c0                	test   %eax,%eax
801067d3:	79 07                	jns    801067dc <sys_close+0x26>
    return -1;
801067d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067da:	eb 28                	jmp    80106804 <sys_close+0x4e>
  proc->ofile[fd] = 0;
801067dc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801067e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801067e5:	83 c2 08             	add    $0x8,%edx
801067e8:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801067ef:	00 
  fileclose(f);
801067f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067f3:	83 ec 0c             	sub    $0xc,%esp
801067f6:	50                   	push   %eax
801067f7:	e8 e9 a8 ff ff       	call   801010e5 <fileclose>
801067fc:	83 c4 10             	add    $0x10,%esp
  return 0;
801067ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106804:	c9                   	leave  
80106805:	c3                   	ret    

80106806 <sys_fstat>:

int
sys_fstat(void)
{
80106806:	55                   	push   %ebp
80106807:	89 e5                	mov    %esp,%ebp
80106809:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010680c:	83 ec 04             	sub    $0x4,%esp
8010680f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106812:	50                   	push   %eax
80106813:	6a 00                	push   $0x0
80106815:	6a 00                	push   $0x0
80106817:	e8 ac fd ff ff       	call   801065c8 <argfd>
8010681c:	83 c4 10             	add    $0x10,%esp
8010681f:	85 c0                	test   %eax,%eax
80106821:	78 17                	js     8010683a <sys_fstat+0x34>
80106823:	83 ec 04             	sub    $0x4,%esp
80106826:	6a 14                	push   $0x14
80106828:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010682b:	50                   	push   %eax
8010682c:	6a 01                	push   $0x1
8010682e:	e8 81 fc ff ff       	call   801064b4 <argptr>
80106833:	83 c4 10             	add    $0x10,%esp
80106836:	85 c0                	test   %eax,%eax
80106838:	79 07                	jns    80106841 <sys_fstat+0x3b>
    return -1;
8010683a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010683f:	eb 13                	jmp    80106854 <sys_fstat+0x4e>
  return filestat(f, st);
80106841:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106844:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106847:	83 ec 08             	sub    $0x8,%esp
8010684a:	52                   	push   %edx
8010684b:	50                   	push   %eax
8010684c:	e8 7c a9 ff ff       	call   801011cd <filestat>
80106851:	83 c4 10             	add    $0x10,%esp
}
80106854:	c9                   	leave  
80106855:	c3                   	ret    

80106856 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80106856:	55                   	push   %ebp
80106857:	89 e5                	mov    %esp,%ebp
80106859:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010685c:	83 ec 08             	sub    $0x8,%esp
8010685f:	8d 45 d8             	lea    -0x28(%ebp),%eax
80106862:	50                   	push   %eax
80106863:	6a 00                	push   $0x0
80106865:	e8 a7 fc ff ff       	call   80106511 <argstr>
8010686a:	83 c4 10             	add    $0x10,%esp
8010686d:	85 c0                	test   %eax,%eax
8010686f:	78 15                	js     80106886 <sys_link+0x30>
80106871:	83 ec 08             	sub    $0x8,%esp
80106874:	8d 45 dc             	lea    -0x24(%ebp),%eax
80106877:	50                   	push   %eax
80106878:	6a 01                	push   $0x1
8010687a:	e8 92 fc ff ff       	call   80106511 <argstr>
8010687f:	83 c4 10             	add    $0x10,%esp
80106882:	85 c0                	test   %eax,%eax
80106884:	79 0a                	jns    80106890 <sys_link+0x3a>
    return -1;
80106886:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010688b:	e9 68 01 00 00       	jmp    801069f8 <sys_link+0x1a2>

  begin_op();
80106890:	e8 4c cd ff ff       	call   801035e1 <begin_op>
  if((ip = namei(old)) == 0){
80106895:	8b 45 d8             	mov    -0x28(%ebp),%eax
80106898:	83 ec 0c             	sub    $0xc,%esp
8010689b:	50                   	push   %eax
8010689c:	e8 1b bd ff ff       	call   801025bc <namei>
801068a1:	83 c4 10             	add    $0x10,%esp
801068a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801068a7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801068ab:	75 0f                	jne    801068bc <sys_link+0x66>
    end_op();
801068ad:	e8 bb cd ff ff       	call   8010366d <end_op>
    return -1;
801068b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068b7:	e9 3c 01 00 00       	jmp    801069f8 <sys_link+0x1a2>
  }

  ilock(ip);
801068bc:	83 ec 0c             	sub    $0xc,%esp
801068bf:	ff 75 f4             	pushl  -0xc(%ebp)
801068c2:	e8 37 b1 ff ff       	call   801019fe <ilock>
801068c7:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
801068ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068cd:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801068d1:	66 83 f8 01          	cmp    $0x1,%ax
801068d5:	75 1d                	jne    801068f4 <sys_link+0x9e>
    iunlockput(ip);
801068d7:	83 ec 0c             	sub    $0xc,%esp
801068da:	ff 75 f4             	pushl  -0xc(%ebp)
801068dd:	e8 dc b3 ff ff       	call   80101cbe <iunlockput>
801068e2:	83 c4 10             	add    $0x10,%esp
    end_op();
801068e5:	e8 83 cd ff ff       	call   8010366d <end_op>
    return -1;
801068ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068ef:	e9 04 01 00 00       	jmp    801069f8 <sys_link+0x1a2>
  }

  ip->nlink++;
801068f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068f7:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801068fb:	83 c0 01             	add    $0x1,%eax
801068fe:	89 c2                	mov    %eax,%edx
80106900:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106903:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106907:	83 ec 0c             	sub    $0xc,%esp
8010690a:	ff 75 f4             	pushl  -0xc(%ebp)
8010690d:	e8 12 af ff ff       	call   80101824 <iupdate>
80106912:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80106915:	83 ec 0c             	sub    $0xc,%esp
80106918:	ff 75 f4             	pushl  -0xc(%ebp)
8010691b:	e8 3c b2 ff ff       	call   80101b5c <iunlock>
80106920:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80106923:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106926:	83 ec 08             	sub    $0x8,%esp
80106929:	8d 55 e2             	lea    -0x1e(%ebp),%edx
8010692c:	52                   	push   %edx
8010692d:	50                   	push   %eax
8010692e:	e8 a5 bc ff ff       	call   801025d8 <nameiparent>
80106933:	83 c4 10             	add    $0x10,%esp
80106936:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106939:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010693d:	74 71                	je     801069b0 <sys_link+0x15a>
    goto bad;
  ilock(dp);
8010693f:	83 ec 0c             	sub    $0xc,%esp
80106942:	ff 75 f0             	pushl  -0x10(%ebp)
80106945:	e8 b4 b0 ff ff       	call   801019fe <ilock>
8010694a:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
8010694d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106950:	8b 10                	mov    (%eax),%edx
80106952:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106955:	8b 00                	mov    (%eax),%eax
80106957:	39 c2                	cmp    %eax,%edx
80106959:	75 1d                	jne    80106978 <sys_link+0x122>
8010695b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010695e:	8b 40 04             	mov    0x4(%eax),%eax
80106961:	83 ec 04             	sub    $0x4,%esp
80106964:	50                   	push   %eax
80106965:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106968:	50                   	push   %eax
80106969:	ff 75 f0             	pushl  -0x10(%ebp)
8010696c:	e8 af b9 ff ff       	call   80102320 <dirlink>
80106971:	83 c4 10             	add    $0x10,%esp
80106974:	85 c0                	test   %eax,%eax
80106976:	79 10                	jns    80106988 <sys_link+0x132>
    iunlockput(dp);
80106978:	83 ec 0c             	sub    $0xc,%esp
8010697b:	ff 75 f0             	pushl  -0x10(%ebp)
8010697e:	e8 3b b3 ff ff       	call   80101cbe <iunlockput>
80106983:	83 c4 10             	add    $0x10,%esp
    goto bad;
80106986:	eb 29                	jmp    801069b1 <sys_link+0x15b>
  }
  iunlockput(dp);
80106988:	83 ec 0c             	sub    $0xc,%esp
8010698b:	ff 75 f0             	pushl  -0x10(%ebp)
8010698e:	e8 2b b3 ff ff       	call   80101cbe <iunlockput>
80106993:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80106996:	83 ec 0c             	sub    $0xc,%esp
80106999:	ff 75 f4             	pushl  -0xc(%ebp)
8010699c:	e8 2d b2 ff ff       	call   80101bce <iput>
801069a1:	83 c4 10             	add    $0x10,%esp

  end_op();
801069a4:	e8 c4 cc ff ff       	call   8010366d <end_op>

  return 0;
801069a9:	b8 00 00 00 00       	mov    $0x0,%eax
801069ae:	eb 48                	jmp    801069f8 <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
801069b0:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
801069b1:	83 ec 0c             	sub    $0xc,%esp
801069b4:	ff 75 f4             	pushl  -0xc(%ebp)
801069b7:	e8 42 b0 ff ff       	call   801019fe <ilock>
801069bc:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
801069bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069c2:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801069c6:	83 e8 01             	sub    $0x1,%eax
801069c9:	89 c2                	mov    %eax,%edx
801069cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069ce:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801069d2:	83 ec 0c             	sub    $0xc,%esp
801069d5:	ff 75 f4             	pushl  -0xc(%ebp)
801069d8:	e8 47 ae ff ff       	call   80101824 <iupdate>
801069dd:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801069e0:	83 ec 0c             	sub    $0xc,%esp
801069e3:	ff 75 f4             	pushl  -0xc(%ebp)
801069e6:	e8 d3 b2 ff ff       	call   80101cbe <iunlockput>
801069eb:	83 c4 10             	add    $0x10,%esp
  end_op();
801069ee:	e8 7a cc ff ff       	call   8010366d <end_op>
  return -1;
801069f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801069f8:	c9                   	leave  
801069f9:	c3                   	ret    

801069fa <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801069fa:	55                   	push   %ebp
801069fb:	89 e5                	mov    %esp,%ebp
801069fd:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80106a00:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80106a07:	eb 40                	jmp    80106a49 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a0c:	6a 10                	push   $0x10
80106a0e:	50                   	push   %eax
80106a0f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106a12:	50                   	push   %eax
80106a13:	ff 75 08             	pushl  0x8(%ebp)
80106a16:	e8 51 b5 ff ff       	call   80101f6c <readi>
80106a1b:	83 c4 10             	add    $0x10,%esp
80106a1e:	83 f8 10             	cmp    $0x10,%eax
80106a21:	74 0d                	je     80106a30 <isdirempty+0x36>
      panic("isdirempty: readi");
80106a23:	83 ec 0c             	sub    $0xc,%esp
80106a26:	68 50 9d 10 80       	push   $0x80109d50
80106a2b:	e8 36 9b ff ff       	call   80100566 <panic>
    if(de.inum != 0)
80106a30:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80106a34:	66 85 c0             	test   %ax,%ax
80106a37:	74 07                	je     80106a40 <isdirempty+0x46>
      return 0;
80106a39:	b8 00 00 00 00       	mov    $0x0,%eax
80106a3e:	eb 1b                	jmp    80106a5b <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80106a40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a43:	83 c0 10             	add    $0x10,%eax
80106a46:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106a49:	8b 45 08             	mov    0x8(%ebp),%eax
80106a4c:	8b 50 18             	mov    0x18(%eax),%edx
80106a4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a52:	39 c2                	cmp    %eax,%edx
80106a54:	77 b3                	ja     80106a09 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80106a56:	b8 01 00 00 00       	mov    $0x1,%eax
}
80106a5b:	c9                   	leave  
80106a5c:	c3                   	ret    

80106a5d <sys_unlink>:

int
sys_unlink(void)
{
80106a5d:	55                   	push   %ebp
80106a5e:	89 e5                	mov    %esp,%ebp
80106a60:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80106a63:	83 ec 08             	sub    $0x8,%esp
80106a66:	8d 45 cc             	lea    -0x34(%ebp),%eax
80106a69:	50                   	push   %eax
80106a6a:	6a 00                	push   $0x0
80106a6c:	e8 a0 fa ff ff       	call   80106511 <argstr>
80106a71:	83 c4 10             	add    $0x10,%esp
80106a74:	85 c0                	test   %eax,%eax
80106a76:	79 0a                	jns    80106a82 <sys_unlink+0x25>
    return -1;
80106a78:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a7d:	e9 bc 01 00 00       	jmp    80106c3e <sys_unlink+0x1e1>

  begin_op();
80106a82:	e8 5a cb ff ff       	call   801035e1 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80106a87:	8b 45 cc             	mov    -0x34(%ebp),%eax
80106a8a:	83 ec 08             	sub    $0x8,%esp
80106a8d:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80106a90:	52                   	push   %edx
80106a91:	50                   	push   %eax
80106a92:	e8 41 bb ff ff       	call   801025d8 <nameiparent>
80106a97:	83 c4 10             	add    $0x10,%esp
80106a9a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106a9d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106aa1:	75 0f                	jne    80106ab2 <sys_unlink+0x55>
    end_op();
80106aa3:	e8 c5 cb ff ff       	call   8010366d <end_op>
    return -1;
80106aa8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106aad:	e9 8c 01 00 00       	jmp    80106c3e <sys_unlink+0x1e1>
  }

  ilock(dp);
80106ab2:	83 ec 0c             	sub    $0xc,%esp
80106ab5:	ff 75 f4             	pushl  -0xc(%ebp)
80106ab8:	e8 41 af ff ff       	call   801019fe <ilock>
80106abd:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80106ac0:	83 ec 08             	sub    $0x8,%esp
80106ac3:	68 62 9d 10 80       	push   $0x80109d62
80106ac8:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106acb:	50                   	push   %eax
80106acc:	e8 7a b7 ff ff       	call   8010224b <namecmp>
80106ad1:	83 c4 10             	add    $0x10,%esp
80106ad4:	85 c0                	test   %eax,%eax
80106ad6:	0f 84 4a 01 00 00    	je     80106c26 <sys_unlink+0x1c9>
80106adc:	83 ec 08             	sub    $0x8,%esp
80106adf:	68 64 9d 10 80       	push   $0x80109d64
80106ae4:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106ae7:	50                   	push   %eax
80106ae8:	e8 5e b7 ff ff       	call   8010224b <namecmp>
80106aed:	83 c4 10             	add    $0x10,%esp
80106af0:	85 c0                	test   %eax,%eax
80106af2:	0f 84 2e 01 00 00    	je     80106c26 <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80106af8:	83 ec 04             	sub    $0x4,%esp
80106afb:	8d 45 c8             	lea    -0x38(%ebp),%eax
80106afe:	50                   	push   %eax
80106aff:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106b02:	50                   	push   %eax
80106b03:	ff 75 f4             	pushl  -0xc(%ebp)
80106b06:	e8 5b b7 ff ff       	call   80102266 <dirlookup>
80106b0b:	83 c4 10             	add    $0x10,%esp
80106b0e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106b11:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106b15:	0f 84 0a 01 00 00    	je     80106c25 <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
80106b1b:	83 ec 0c             	sub    $0xc,%esp
80106b1e:	ff 75 f0             	pushl  -0x10(%ebp)
80106b21:	e8 d8 ae ff ff       	call   801019fe <ilock>
80106b26:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80106b29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b2c:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106b30:	66 85 c0             	test   %ax,%ax
80106b33:	7f 0d                	jg     80106b42 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80106b35:	83 ec 0c             	sub    $0xc,%esp
80106b38:	68 67 9d 10 80       	push   $0x80109d67
80106b3d:	e8 24 9a ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80106b42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b45:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106b49:	66 83 f8 01          	cmp    $0x1,%ax
80106b4d:	75 25                	jne    80106b74 <sys_unlink+0x117>
80106b4f:	83 ec 0c             	sub    $0xc,%esp
80106b52:	ff 75 f0             	pushl  -0x10(%ebp)
80106b55:	e8 a0 fe ff ff       	call   801069fa <isdirempty>
80106b5a:	83 c4 10             	add    $0x10,%esp
80106b5d:	85 c0                	test   %eax,%eax
80106b5f:	75 13                	jne    80106b74 <sys_unlink+0x117>
    iunlockput(ip);
80106b61:	83 ec 0c             	sub    $0xc,%esp
80106b64:	ff 75 f0             	pushl  -0x10(%ebp)
80106b67:	e8 52 b1 ff ff       	call   80101cbe <iunlockput>
80106b6c:	83 c4 10             	add    $0x10,%esp
    goto bad;
80106b6f:	e9 b2 00 00 00       	jmp    80106c26 <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
80106b74:	83 ec 04             	sub    $0x4,%esp
80106b77:	6a 10                	push   $0x10
80106b79:	6a 00                	push   $0x0
80106b7b:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106b7e:	50                   	push   %eax
80106b7f:	e8 e3 f5 ff ff       	call   80106167 <memset>
80106b84:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106b87:	8b 45 c8             	mov    -0x38(%ebp),%eax
80106b8a:	6a 10                	push   $0x10
80106b8c:	50                   	push   %eax
80106b8d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106b90:	50                   	push   %eax
80106b91:	ff 75 f4             	pushl  -0xc(%ebp)
80106b94:	e8 2a b5 ff ff       	call   801020c3 <writei>
80106b99:	83 c4 10             	add    $0x10,%esp
80106b9c:	83 f8 10             	cmp    $0x10,%eax
80106b9f:	74 0d                	je     80106bae <sys_unlink+0x151>
    panic("unlink: writei");
80106ba1:	83 ec 0c             	sub    $0xc,%esp
80106ba4:	68 79 9d 10 80       	push   $0x80109d79
80106ba9:	e8 b8 99 ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR){
80106bae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106bb1:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106bb5:	66 83 f8 01          	cmp    $0x1,%ax
80106bb9:	75 21                	jne    80106bdc <sys_unlink+0x17f>
    dp->nlink--;
80106bbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bbe:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106bc2:	83 e8 01             	sub    $0x1,%eax
80106bc5:	89 c2                	mov    %eax,%edx
80106bc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bca:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106bce:	83 ec 0c             	sub    $0xc,%esp
80106bd1:	ff 75 f4             	pushl  -0xc(%ebp)
80106bd4:	e8 4b ac ff ff       	call   80101824 <iupdate>
80106bd9:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80106bdc:	83 ec 0c             	sub    $0xc,%esp
80106bdf:	ff 75 f4             	pushl  -0xc(%ebp)
80106be2:	e8 d7 b0 ff ff       	call   80101cbe <iunlockput>
80106be7:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80106bea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106bed:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106bf1:	83 e8 01             	sub    $0x1,%eax
80106bf4:	89 c2                	mov    %eax,%edx
80106bf6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106bf9:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106bfd:	83 ec 0c             	sub    $0xc,%esp
80106c00:	ff 75 f0             	pushl  -0x10(%ebp)
80106c03:	e8 1c ac ff ff       	call   80101824 <iupdate>
80106c08:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80106c0b:	83 ec 0c             	sub    $0xc,%esp
80106c0e:	ff 75 f0             	pushl  -0x10(%ebp)
80106c11:	e8 a8 b0 ff ff       	call   80101cbe <iunlockput>
80106c16:	83 c4 10             	add    $0x10,%esp

  end_op();
80106c19:	e8 4f ca ff ff       	call   8010366d <end_op>

  return 0;
80106c1e:	b8 00 00 00 00       	mov    $0x0,%eax
80106c23:	eb 19                	jmp    80106c3e <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80106c25:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
80106c26:	83 ec 0c             	sub    $0xc,%esp
80106c29:	ff 75 f4             	pushl  -0xc(%ebp)
80106c2c:	e8 8d b0 ff ff       	call   80101cbe <iunlockput>
80106c31:	83 c4 10             	add    $0x10,%esp
  end_op();
80106c34:	e8 34 ca ff ff       	call   8010366d <end_op>
  return -1;
80106c39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106c3e:	c9                   	leave  
80106c3f:	c3                   	ret    

80106c40 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80106c40:	55                   	push   %ebp
80106c41:	89 e5                	mov    %esp,%ebp
80106c43:	83 ec 38             	sub    $0x38,%esp
80106c46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106c49:	8b 55 10             	mov    0x10(%ebp),%edx
80106c4c:	8b 45 14             	mov    0x14(%ebp),%eax
80106c4f:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80106c53:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80106c57:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80106c5b:	83 ec 08             	sub    $0x8,%esp
80106c5e:	8d 45 de             	lea    -0x22(%ebp),%eax
80106c61:	50                   	push   %eax
80106c62:	ff 75 08             	pushl  0x8(%ebp)
80106c65:	e8 6e b9 ff ff       	call   801025d8 <nameiparent>
80106c6a:	83 c4 10             	add    $0x10,%esp
80106c6d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106c70:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106c74:	75 0a                	jne    80106c80 <create+0x40>
    return 0;
80106c76:	b8 00 00 00 00       	mov    $0x0,%eax
80106c7b:	e9 90 01 00 00       	jmp    80106e10 <create+0x1d0>
  ilock(dp);
80106c80:	83 ec 0c             	sub    $0xc,%esp
80106c83:	ff 75 f4             	pushl  -0xc(%ebp)
80106c86:	e8 73 ad ff ff       	call   801019fe <ilock>
80106c8b:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80106c8e:	83 ec 04             	sub    $0x4,%esp
80106c91:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106c94:	50                   	push   %eax
80106c95:	8d 45 de             	lea    -0x22(%ebp),%eax
80106c98:	50                   	push   %eax
80106c99:	ff 75 f4             	pushl  -0xc(%ebp)
80106c9c:	e8 c5 b5 ff ff       	call   80102266 <dirlookup>
80106ca1:	83 c4 10             	add    $0x10,%esp
80106ca4:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106ca7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106cab:	74 50                	je     80106cfd <create+0xbd>
    iunlockput(dp);
80106cad:	83 ec 0c             	sub    $0xc,%esp
80106cb0:	ff 75 f4             	pushl  -0xc(%ebp)
80106cb3:	e8 06 b0 ff ff       	call   80101cbe <iunlockput>
80106cb8:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80106cbb:	83 ec 0c             	sub    $0xc,%esp
80106cbe:	ff 75 f0             	pushl  -0x10(%ebp)
80106cc1:	e8 38 ad ff ff       	call   801019fe <ilock>
80106cc6:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80106cc9:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106cce:	75 15                	jne    80106ce5 <create+0xa5>
80106cd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106cd3:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106cd7:	66 83 f8 02          	cmp    $0x2,%ax
80106cdb:	75 08                	jne    80106ce5 <create+0xa5>
      return ip;
80106cdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106ce0:	e9 2b 01 00 00       	jmp    80106e10 <create+0x1d0>
    iunlockput(ip);
80106ce5:	83 ec 0c             	sub    $0xc,%esp
80106ce8:	ff 75 f0             	pushl  -0x10(%ebp)
80106ceb:	e8 ce af ff ff       	call   80101cbe <iunlockput>
80106cf0:	83 c4 10             	add    $0x10,%esp
    return 0;
80106cf3:	b8 00 00 00 00       	mov    $0x0,%eax
80106cf8:	e9 13 01 00 00       	jmp    80106e10 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106cfd:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106d01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d04:	8b 00                	mov    (%eax),%eax
80106d06:	83 ec 08             	sub    $0x8,%esp
80106d09:	52                   	push   %edx
80106d0a:	50                   	push   %eax
80106d0b:	e8 3d aa ff ff       	call   8010174d <ialloc>
80106d10:	83 c4 10             	add    $0x10,%esp
80106d13:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106d16:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106d1a:	75 0d                	jne    80106d29 <create+0xe9>
    panic("create: ialloc");
80106d1c:	83 ec 0c             	sub    $0xc,%esp
80106d1f:	68 88 9d 10 80       	push   $0x80109d88
80106d24:	e8 3d 98 ff ff       	call   80100566 <panic>

  ilock(ip);
80106d29:	83 ec 0c             	sub    $0xc,%esp
80106d2c:	ff 75 f0             	pushl  -0x10(%ebp)
80106d2f:	e8 ca ac ff ff       	call   801019fe <ilock>
80106d34:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80106d37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d3a:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106d3e:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80106d42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d45:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106d49:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80106d4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d50:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80106d56:	83 ec 0c             	sub    $0xc,%esp
80106d59:	ff 75 f0             	pushl  -0x10(%ebp)
80106d5c:	e8 c3 aa ff ff       	call   80101824 <iupdate>
80106d61:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80106d64:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106d69:	75 6a                	jne    80106dd5 <create+0x195>
    dp->nlink++;  // for ".."
80106d6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d6e:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106d72:	83 c0 01             	add    $0x1,%eax
80106d75:	89 c2                	mov    %eax,%edx
80106d77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d7a:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106d7e:	83 ec 0c             	sub    $0xc,%esp
80106d81:	ff 75 f4             	pushl  -0xc(%ebp)
80106d84:	e8 9b aa ff ff       	call   80101824 <iupdate>
80106d89:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106d8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d8f:	8b 40 04             	mov    0x4(%eax),%eax
80106d92:	83 ec 04             	sub    $0x4,%esp
80106d95:	50                   	push   %eax
80106d96:	68 62 9d 10 80       	push   $0x80109d62
80106d9b:	ff 75 f0             	pushl  -0x10(%ebp)
80106d9e:	e8 7d b5 ff ff       	call   80102320 <dirlink>
80106da3:	83 c4 10             	add    $0x10,%esp
80106da6:	85 c0                	test   %eax,%eax
80106da8:	78 1e                	js     80106dc8 <create+0x188>
80106daa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106dad:	8b 40 04             	mov    0x4(%eax),%eax
80106db0:	83 ec 04             	sub    $0x4,%esp
80106db3:	50                   	push   %eax
80106db4:	68 64 9d 10 80       	push   $0x80109d64
80106db9:	ff 75 f0             	pushl  -0x10(%ebp)
80106dbc:	e8 5f b5 ff ff       	call   80102320 <dirlink>
80106dc1:	83 c4 10             	add    $0x10,%esp
80106dc4:	85 c0                	test   %eax,%eax
80106dc6:	79 0d                	jns    80106dd5 <create+0x195>
      panic("create dots");
80106dc8:	83 ec 0c             	sub    $0xc,%esp
80106dcb:	68 97 9d 10 80       	push   $0x80109d97
80106dd0:	e8 91 97 ff ff       	call   80100566 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106dd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106dd8:	8b 40 04             	mov    0x4(%eax),%eax
80106ddb:	83 ec 04             	sub    $0x4,%esp
80106dde:	50                   	push   %eax
80106ddf:	8d 45 de             	lea    -0x22(%ebp),%eax
80106de2:	50                   	push   %eax
80106de3:	ff 75 f4             	pushl  -0xc(%ebp)
80106de6:	e8 35 b5 ff ff       	call   80102320 <dirlink>
80106deb:	83 c4 10             	add    $0x10,%esp
80106dee:	85 c0                	test   %eax,%eax
80106df0:	79 0d                	jns    80106dff <create+0x1bf>
    panic("create: dirlink");
80106df2:	83 ec 0c             	sub    $0xc,%esp
80106df5:	68 a3 9d 10 80       	push   $0x80109da3
80106dfa:	e8 67 97 ff ff       	call   80100566 <panic>

  iunlockput(dp);
80106dff:	83 ec 0c             	sub    $0xc,%esp
80106e02:	ff 75 f4             	pushl  -0xc(%ebp)
80106e05:	e8 b4 ae ff ff       	call   80101cbe <iunlockput>
80106e0a:	83 c4 10             	add    $0x10,%esp

  return ip;
80106e0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106e10:	c9                   	leave  
80106e11:	c3                   	ret    

80106e12 <sys_open>:

int
sys_open(void)
{
80106e12:	55                   	push   %ebp
80106e13:	89 e5                	mov    %esp,%ebp
80106e15:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106e18:	83 ec 08             	sub    $0x8,%esp
80106e1b:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106e1e:	50                   	push   %eax
80106e1f:	6a 00                	push   $0x0
80106e21:	e8 eb f6 ff ff       	call   80106511 <argstr>
80106e26:	83 c4 10             	add    $0x10,%esp
80106e29:	85 c0                	test   %eax,%eax
80106e2b:	78 15                	js     80106e42 <sys_open+0x30>
80106e2d:	83 ec 08             	sub    $0x8,%esp
80106e30:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106e33:	50                   	push   %eax
80106e34:	6a 01                	push   $0x1
80106e36:	e8 51 f6 ff ff       	call   8010648c <argint>
80106e3b:	83 c4 10             	add    $0x10,%esp
80106e3e:	85 c0                	test   %eax,%eax
80106e40:	79 0a                	jns    80106e4c <sys_open+0x3a>
    return -1;
80106e42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e47:	e9 61 01 00 00       	jmp    80106fad <sys_open+0x19b>

  begin_op();
80106e4c:	e8 90 c7 ff ff       	call   801035e1 <begin_op>

  if(omode & O_CREATE){
80106e51:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106e54:	25 00 02 00 00       	and    $0x200,%eax
80106e59:	85 c0                	test   %eax,%eax
80106e5b:	74 2a                	je     80106e87 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80106e5d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106e60:	6a 00                	push   $0x0
80106e62:	6a 00                	push   $0x0
80106e64:	6a 02                	push   $0x2
80106e66:	50                   	push   %eax
80106e67:	e8 d4 fd ff ff       	call   80106c40 <create>
80106e6c:	83 c4 10             	add    $0x10,%esp
80106e6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106e72:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106e76:	75 75                	jne    80106eed <sys_open+0xdb>
      end_op();
80106e78:	e8 f0 c7 ff ff       	call   8010366d <end_op>
      return -1;
80106e7d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e82:	e9 26 01 00 00       	jmp    80106fad <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80106e87:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106e8a:	83 ec 0c             	sub    $0xc,%esp
80106e8d:	50                   	push   %eax
80106e8e:	e8 29 b7 ff ff       	call   801025bc <namei>
80106e93:	83 c4 10             	add    $0x10,%esp
80106e96:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106e99:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106e9d:	75 0f                	jne    80106eae <sys_open+0x9c>
      end_op();
80106e9f:	e8 c9 c7 ff ff       	call   8010366d <end_op>
      return -1;
80106ea4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ea9:	e9 ff 00 00 00       	jmp    80106fad <sys_open+0x19b>
    }
    ilock(ip);
80106eae:	83 ec 0c             	sub    $0xc,%esp
80106eb1:	ff 75 f4             	pushl  -0xc(%ebp)
80106eb4:	e8 45 ab ff ff       	call   801019fe <ilock>
80106eb9:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106ebc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ebf:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106ec3:	66 83 f8 01          	cmp    $0x1,%ax
80106ec7:	75 24                	jne    80106eed <sys_open+0xdb>
80106ec9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106ecc:	85 c0                	test   %eax,%eax
80106ece:	74 1d                	je     80106eed <sys_open+0xdb>
      iunlockput(ip);
80106ed0:	83 ec 0c             	sub    $0xc,%esp
80106ed3:	ff 75 f4             	pushl  -0xc(%ebp)
80106ed6:	e8 e3 ad ff ff       	call   80101cbe <iunlockput>
80106edb:	83 c4 10             	add    $0x10,%esp
      end_op();
80106ede:	e8 8a c7 ff ff       	call   8010366d <end_op>
      return -1;
80106ee3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ee8:	e9 c0 00 00 00       	jmp    80106fad <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106eed:	e8 35 a1 ff ff       	call   80101027 <filealloc>
80106ef2:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106ef5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106ef9:	74 17                	je     80106f12 <sys_open+0x100>
80106efb:	83 ec 0c             	sub    $0xc,%esp
80106efe:	ff 75 f0             	pushl  -0x10(%ebp)
80106f01:	e8 37 f7 ff ff       	call   8010663d <fdalloc>
80106f06:	83 c4 10             	add    $0x10,%esp
80106f09:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106f0c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106f10:	79 2e                	jns    80106f40 <sys_open+0x12e>
    if(f)
80106f12:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106f16:	74 0e                	je     80106f26 <sys_open+0x114>
      fileclose(f);
80106f18:	83 ec 0c             	sub    $0xc,%esp
80106f1b:	ff 75 f0             	pushl  -0x10(%ebp)
80106f1e:	e8 c2 a1 ff ff       	call   801010e5 <fileclose>
80106f23:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80106f26:	83 ec 0c             	sub    $0xc,%esp
80106f29:	ff 75 f4             	pushl  -0xc(%ebp)
80106f2c:	e8 8d ad ff ff       	call   80101cbe <iunlockput>
80106f31:	83 c4 10             	add    $0x10,%esp
    end_op();
80106f34:	e8 34 c7 ff ff       	call   8010366d <end_op>
    return -1;
80106f39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f3e:	eb 6d                	jmp    80106fad <sys_open+0x19b>
  }
  iunlock(ip);
80106f40:	83 ec 0c             	sub    $0xc,%esp
80106f43:	ff 75 f4             	pushl  -0xc(%ebp)
80106f46:	e8 11 ac ff ff       	call   80101b5c <iunlock>
80106f4b:	83 c4 10             	add    $0x10,%esp
  end_op();
80106f4e:	e8 1a c7 ff ff       	call   8010366d <end_op>

  f->type = FD_INODE;
80106f53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106f56:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106f5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106f5f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106f62:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106f65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106f68:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106f6f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106f72:	83 e0 01             	and    $0x1,%eax
80106f75:	85 c0                	test   %eax,%eax
80106f77:	0f 94 c0             	sete   %al
80106f7a:	89 c2                	mov    %eax,%edx
80106f7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106f7f:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106f82:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106f85:	83 e0 01             	and    $0x1,%eax
80106f88:	85 c0                	test   %eax,%eax
80106f8a:	75 0a                	jne    80106f96 <sys_open+0x184>
80106f8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106f8f:	83 e0 02             	and    $0x2,%eax
80106f92:	85 c0                	test   %eax,%eax
80106f94:	74 07                	je     80106f9d <sys_open+0x18b>
80106f96:	b8 01 00 00 00       	mov    $0x1,%eax
80106f9b:	eb 05                	jmp    80106fa2 <sys_open+0x190>
80106f9d:	b8 00 00 00 00       	mov    $0x0,%eax
80106fa2:	89 c2                	mov    %eax,%edx
80106fa4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106fa7:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106faa:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106fad:	c9                   	leave  
80106fae:	c3                   	ret    

80106faf <sys_mkdir>:

int
sys_mkdir(void)
{
80106faf:	55                   	push   %ebp
80106fb0:	89 e5                	mov    %esp,%ebp
80106fb2:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106fb5:	e8 27 c6 ff ff       	call   801035e1 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106fba:	83 ec 08             	sub    $0x8,%esp
80106fbd:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106fc0:	50                   	push   %eax
80106fc1:	6a 00                	push   $0x0
80106fc3:	e8 49 f5 ff ff       	call   80106511 <argstr>
80106fc8:	83 c4 10             	add    $0x10,%esp
80106fcb:	85 c0                	test   %eax,%eax
80106fcd:	78 1b                	js     80106fea <sys_mkdir+0x3b>
80106fcf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106fd2:	6a 00                	push   $0x0
80106fd4:	6a 00                	push   $0x0
80106fd6:	6a 01                	push   $0x1
80106fd8:	50                   	push   %eax
80106fd9:	e8 62 fc ff ff       	call   80106c40 <create>
80106fde:	83 c4 10             	add    $0x10,%esp
80106fe1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106fe4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106fe8:	75 0c                	jne    80106ff6 <sys_mkdir+0x47>
    end_op();
80106fea:	e8 7e c6 ff ff       	call   8010366d <end_op>
    return -1;
80106fef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ff4:	eb 18                	jmp    8010700e <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80106ff6:	83 ec 0c             	sub    $0xc,%esp
80106ff9:	ff 75 f4             	pushl  -0xc(%ebp)
80106ffc:	e8 bd ac ff ff       	call   80101cbe <iunlockput>
80107001:	83 c4 10             	add    $0x10,%esp
  end_op();
80107004:	e8 64 c6 ff ff       	call   8010366d <end_op>
  return 0;
80107009:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010700e:	c9                   	leave  
8010700f:	c3                   	ret    

80107010 <sys_mknod>:

int
sys_mknod(void)
{
80107010:	55                   	push   %ebp
80107011:	89 e5                	mov    %esp,%ebp
80107013:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80107016:	e8 c6 c5 ff ff       	call   801035e1 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
8010701b:	83 ec 08             	sub    $0x8,%esp
8010701e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107021:	50                   	push   %eax
80107022:	6a 00                	push   $0x0
80107024:	e8 e8 f4 ff ff       	call   80106511 <argstr>
80107029:	83 c4 10             	add    $0x10,%esp
8010702c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010702f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107033:	78 4f                	js     80107084 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
80107035:	83 ec 08             	sub    $0x8,%esp
80107038:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010703b:	50                   	push   %eax
8010703c:	6a 01                	push   $0x1
8010703e:	e8 49 f4 ff ff       	call   8010648c <argint>
80107043:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80107046:	85 c0                	test   %eax,%eax
80107048:	78 3a                	js     80107084 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010704a:	83 ec 08             	sub    $0x8,%esp
8010704d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80107050:	50                   	push   %eax
80107051:	6a 02                	push   $0x2
80107053:	e8 34 f4 ff ff       	call   8010648c <argint>
80107058:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
8010705b:	85 c0                	test   %eax,%eax
8010705d:	78 25                	js     80107084 <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
8010705f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107062:	0f bf c8             	movswl %ax,%ecx
80107065:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107068:	0f bf d0             	movswl %ax,%edx
8010706b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010706e:	51                   	push   %ecx
8010706f:	52                   	push   %edx
80107070:	6a 03                	push   $0x3
80107072:	50                   	push   %eax
80107073:	e8 c8 fb ff ff       	call   80106c40 <create>
80107078:	83 c4 10             	add    $0x10,%esp
8010707b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010707e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107082:	75 0c                	jne    80107090 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80107084:	e8 e4 c5 ff ff       	call   8010366d <end_op>
    return -1;
80107089:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010708e:	eb 18                	jmp    801070a8 <sys_mknod+0x98>
  }
  iunlockput(ip);
80107090:	83 ec 0c             	sub    $0xc,%esp
80107093:	ff 75 f0             	pushl  -0x10(%ebp)
80107096:	e8 23 ac ff ff       	call   80101cbe <iunlockput>
8010709b:	83 c4 10             	add    $0x10,%esp
  end_op();
8010709e:	e8 ca c5 ff ff       	call   8010366d <end_op>
  return 0;
801070a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801070a8:	c9                   	leave  
801070a9:	c3                   	ret    

801070aa <sys_chdir>:

int
sys_chdir(void)
{
801070aa:	55                   	push   %ebp
801070ab:	89 e5                	mov    %esp,%ebp
801070ad:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801070b0:	e8 2c c5 ff ff       	call   801035e1 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801070b5:	83 ec 08             	sub    $0x8,%esp
801070b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801070bb:	50                   	push   %eax
801070bc:	6a 00                	push   $0x0
801070be:	e8 4e f4 ff ff       	call   80106511 <argstr>
801070c3:	83 c4 10             	add    $0x10,%esp
801070c6:	85 c0                	test   %eax,%eax
801070c8:	78 18                	js     801070e2 <sys_chdir+0x38>
801070ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801070cd:	83 ec 0c             	sub    $0xc,%esp
801070d0:	50                   	push   %eax
801070d1:	e8 e6 b4 ff ff       	call   801025bc <namei>
801070d6:	83 c4 10             	add    $0x10,%esp
801070d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801070dc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801070e0:	75 0c                	jne    801070ee <sys_chdir+0x44>
    end_op();
801070e2:	e8 86 c5 ff ff       	call   8010366d <end_op>
    return -1;
801070e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070ec:	eb 6e                	jmp    8010715c <sys_chdir+0xb2>
  }
  ilock(ip);
801070ee:	83 ec 0c             	sub    $0xc,%esp
801070f1:	ff 75 f4             	pushl  -0xc(%ebp)
801070f4:	e8 05 a9 ff ff       	call   801019fe <ilock>
801070f9:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
801070fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070ff:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80107103:	66 83 f8 01          	cmp    $0x1,%ax
80107107:	74 1a                	je     80107123 <sys_chdir+0x79>
    iunlockput(ip);
80107109:	83 ec 0c             	sub    $0xc,%esp
8010710c:	ff 75 f4             	pushl  -0xc(%ebp)
8010710f:	e8 aa ab ff ff       	call   80101cbe <iunlockput>
80107114:	83 c4 10             	add    $0x10,%esp
    end_op();
80107117:	e8 51 c5 ff ff       	call   8010366d <end_op>
    return -1;
8010711c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107121:	eb 39                	jmp    8010715c <sys_chdir+0xb2>
  }
  iunlock(ip);
80107123:	83 ec 0c             	sub    $0xc,%esp
80107126:	ff 75 f4             	pushl  -0xc(%ebp)
80107129:	e8 2e aa ff ff       	call   80101b5c <iunlock>
8010712e:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
80107131:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107137:	8b 40 68             	mov    0x68(%eax),%eax
8010713a:	83 ec 0c             	sub    $0xc,%esp
8010713d:	50                   	push   %eax
8010713e:	e8 8b aa ff ff       	call   80101bce <iput>
80107143:	83 c4 10             	add    $0x10,%esp
  end_op();
80107146:	e8 22 c5 ff ff       	call   8010366d <end_op>
  proc->cwd = ip;
8010714b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107151:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107154:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80107157:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010715c:	c9                   	leave  
8010715d:	c3                   	ret    

8010715e <sys_exec>:

int
sys_exec(void)
{
8010715e:	55                   	push   %ebp
8010715f:	89 e5                	mov    %esp,%ebp
80107161:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80107167:	83 ec 08             	sub    $0x8,%esp
8010716a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010716d:	50                   	push   %eax
8010716e:	6a 00                	push   $0x0
80107170:	e8 9c f3 ff ff       	call   80106511 <argstr>
80107175:	83 c4 10             	add    $0x10,%esp
80107178:	85 c0                	test   %eax,%eax
8010717a:	78 18                	js     80107194 <sys_exec+0x36>
8010717c:	83 ec 08             	sub    $0x8,%esp
8010717f:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80107185:	50                   	push   %eax
80107186:	6a 01                	push   $0x1
80107188:	e8 ff f2 ff ff       	call   8010648c <argint>
8010718d:	83 c4 10             	add    $0x10,%esp
80107190:	85 c0                	test   %eax,%eax
80107192:	79 0a                	jns    8010719e <sys_exec+0x40>
    return -1;
80107194:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107199:	e9 c6 00 00 00       	jmp    80107264 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
8010719e:	83 ec 04             	sub    $0x4,%esp
801071a1:	68 80 00 00 00       	push   $0x80
801071a6:	6a 00                	push   $0x0
801071a8:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801071ae:	50                   	push   %eax
801071af:	e8 b3 ef ff ff       	call   80106167 <memset>
801071b4:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
801071b7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801071be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071c1:	83 f8 1f             	cmp    $0x1f,%eax
801071c4:	76 0a                	jbe    801071d0 <sys_exec+0x72>
      return -1;
801071c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071cb:	e9 94 00 00 00       	jmp    80107264 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801071d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071d3:	c1 e0 02             	shl    $0x2,%eax
801071d6:	89 c2                	mov    %eax,%edx
801071d8:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801071de:	01 c2                	add    %eax,%edx
801071e0:	83 ec 08             	sub    $0x8,%esp
801071e3:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801071e9:	50                   	push   %eax
801071ea:	52                   	push   %edx
801071eb:	e8 00 f2 ff ff       	call   801063f0 <fetchint>
801071f0:	83 c4 10             	add    $0x10,%esp
801071f3:	85 c0                	test   %eax,%eax
801071f5:	79 07                	jns    801071fe <sys_exec+0xa0>
      return -1;
801071f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071fc:	eb 66                	jmp    80107264 <sys_exec+0x106>
    if(uarg == 0){
801071fe:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80107204:	85 c0                	test   %eax,%eax
80107206:	75 27                	jne    8010722f <sys_exec+0xd1>
      argv[i] = 0;
80107208:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010720b:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80107212:	00 00 00 00 
      break;
80107216:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80107217:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010721a:	83 ec 08             	sub    $0x8,%esp
8010721d:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80107223:	52                   	push   %edx
80107224:	50                   	push   %eax
80107225:	e8 db 99 ff ff       	call   80100c05 <exec>
8010722a:	83 c4 10             	add    $0x10,%esp
8010722d:	eb 35                	jmp    80107264 <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
8010722f:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80107235:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107238:	c1 e2 02             	shl    $0x2,%edx
8010723b:	01 c2                	add    %eax,%edx
8010723d:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80107243:	83 ec 08             	sub    $0x8,%esp
80107246:	52                   	push   %edx
80107247:	50                   	push   %eax
80107248:	e8 dd f1 ff ff       	call   8010642a <fetchstr>
8010724d:	83 c4 10             	add    $0x10,%esp
80107250:	85 c0                	test   %eax,%eax
80107252:	79 07                	jns    8010725b <sys_exec+0xfd>
      return -1;
80107254:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107259:	eb 09                	jmp    80107264 <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
8010725b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
8010725f:	e9 5a ff ff ff       	jmp    801071be <sys_exec+0x60>
  return exec(path, argv);
}
80107264:	c9                   	leave  
80107265:	c3                   	ret    

80107266 <sys_pipe>:

int
sys_pipe(void)
{
80107266:	55                   	push   %ebp
80107267:	89 e5                	mov    %esp,%ebp
80107269:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010726c:	83 ec 04             	sub    $0x4,%esp
8010726f:	6a 08                	push   $0x8
80107271:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107274:	50                   	push   %eax
80107275:	6a 00                	push   $0x0
80107277:	e8 38 f2 ff ff       	call   801064b4 <argptr>
8010727c:	83 c4 10             	add    $0x10,%esp
8010727f:	85 c0                	test   %eax,%eax
80107281:	79 0a                	jns    8010728d <sys_pipe+0x27>
    return -1;
80107283:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107288:	e9 af 00 00 00       	jmp    8010733c <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
8010728d:	83 ec 08             	sub    $0x8,%esp
80107290:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80107293:	50                   	push   %eax
80107294:	8d 45 e8             	lea    -0x18(%ebp),%eax
80107297:	50                   	push   %eax
80107298:	e8 38 ce ff ff       	call   801040d5 <pipealloc>
8010729d:	83 c4 10             	add    $0x10,%esp
801072a0:	85 c0                	test   %eax,%eax
801072a2:	79 0a                	jns    801072ae <sys_pipe+0x48>
    return -1;
801072a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801072a9:	e9 8e 00 00 00       	jmp    8010733c <sys_pipe+0xd6>
  fd0 = -1;
801072ae:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801072b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801072b8:	83 ec 0c             	sub    $0xc,%esp
801072bb:	50                   	push   %eax
801072bc:	e8 7c f3 ff ff       	call   8010663d <fdalloc>
801072c1:	83 c4 10             	add    $0x10,%esp
801072c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801072c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801072cb:	78 18                	js     801072e5 <sys_pipe+0x7f>
801072cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801072d0:	83 ec 0c             	sub    $0xc,%esp
801072d3:	50                   	push   %eax
801072d4:	e8 64 f3 ff ff       	call   8010663d <fdalloc>
801072d9:	83 c4 10             	add    $0x10,%esp
801072dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
801072df:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801072e3:	79 3f                	jns    80107324 <sys_pipe+0xbe>
    if(fd0 >= 0)
801072e5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801072e9:	78 14                	js     801072ff <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
801072eb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801072f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801072f4:	83 c2 08             	add    $0x8,%edx
801072f7:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801072fe:	00 
    fileclose(rf);
801072ff:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107302:	83 ec 0c             	sub    $0xc,%esp
80107305:	50                   	push   %eax
80107306:	e8 da 9d ff ff       	call   801010e5 <fileclose>
8010730b:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
8010730e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107311:	83 ec 0c             	sub    $0xc,%esp
80107314:	50                   	push   %eax
80107315:	e8 cb 9d ff ff       	call   801010e5 <fileclose>
8010731a:	83 c4 10             	add    $0x10,%esp
    return -1;
8010731d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107322:	eb 18                	jmp    8010733c <sys_pipe+0xd6>
  }
  fd[0] = fd0;
80107324:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107327:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010732a:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
8010732c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010732f:	8d 50 04             	lea    0x4(%eax),%edx
80107332:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107335:	89 02                	mov    %eax,(%edx)
  return 0;
80107337:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010733c:	c9                   	leave  
8010733d:	c3                   	ret    

8010733e <outw>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outw(ushort port, ushort data)
{
8010733e:	55                   	push   %ebp
8010733f:	89 e5                	mov    %esp,%ebp
80107341:	83 ec 08             	sub    $0x8,%esp
80107344:	8b 55 08             	mov    0x8(%ebp),%edx
80107347:	8b 45 0c             	mov    0xc(%ebp),%eax
8010734a:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010734e:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107352:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
80107356:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010735a:	66 ef                	out    %ax,(%dx)
}
8010735c:	90                   	nop
8010735d:	c9                   	leave  
8010735e:	c3                   	ret    

8010735f <sys_fork>:
#include "proc.h"
#include "uproc.h"

int
sys_fork(void)
{
8010735f:	55                   	push   %ebp
80107360:	89 e5                	mov    %esp,%ebp
80107362:	83 ec 08             	sub    $0x8,%esp
  return fork();
80107365:	e8 d9 d6 ff ff       	call   80104a43 <fork>
}
8010736a:	c9                   	leave  
8010736b:	c3                   	ret    

8010736c <sys_exit>:

int
sys_exit(void)
{
8010736c:	55                   	push   %ebp
8010736d:	89 e5                	mov    %esp,%ebp
8010736f:	83 ec 08             	sub    $0x8,%esp
  exit();
80107372:	e8 ff d8 ff ff       	call   80104c76 <exit>
  return 0;  // not reached
80107377:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010737c:	c9                   	leave  
8010737d:	c3                   	ret    

8010737e <sys_wait>:

int
sys_wait(void)
{
8010737e:	55                   	push   %ebp
8010737f:	89 e5                	mov    %esp,%ebp
80107381:	83 ec 08             	sub    $0x8,%esp
  return wait();
80107384:	e8 14 db ff ff       	call   80104e9d <wait>
}
80107389:	c9                   	leave  
8010738a:	c3                   	ret    

8010738b <sys_kill>:

int
sys_kill(void)
{
8010738b:	55                   	push   %ebp
8010738c:	89 e5                	mov    %esp,%ebp
8010738e:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80107391:	83 ec 08             	sub    $0x8,%esp
80107394:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107397:	50                   	push   %eax
80107398:	6a 00                	push   $0x0
8010739a:	e8 ed f0 ff ff       	call   8010648c <argint>
8010739f:	83 c4 10             	add    $0x10,%esp
801073a2:	85 c0                	test   %eax,%eax
801073a4:	79 07                	jns    801073ad <sys_kill+0x22>
    return -1;
801073a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801073ab:	eb 0f                	jmp    801073bc <sys_kill+0x31>
  return kill(pid);
801073ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073b0:	83 ec 0c             	sub    $0xc,%esp
801073b3:	50                   	push   %eax
801073b4:	e8 d2 e1 ff ff       	call   8010558b <kill>
801073b9:	83 c4 10             	add    $0x10,%esp
}
801073bc:	c9                   	leave  
801073bd:	c3                   	ret    

801073be <sys_getpid>:

int
sys_getpid(void)
{
801073be:	55                   	push   %ebp
801073bf:	89 e5                	mov    %esp,%ebp
  return proc->pid;
801073c1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073c7:	8b 40 10             	mov    0x10(%eax),%eax
}
801073ca:	5d                   	pop    %ebp
801073cb:	c3                   	ret    

801073cc <sys_sbrk>:

int
sys_sbrk(void)
{
801073cc:	55                   	push   %ebp
801073cd:	89 e5                	mov    %esp,%ebp
801073cf:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801073d2:	83 ec 08             	sub    $0x8,%esp
801073d5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801073d8:	50                   	push   %eax
801073d9:	6a 00                	push   $0x0
801073db:	e8 ac f0 ff ff       	call   8010648c <argint>
801073e0:	83 c4 10             	add    $0x10,%esp
801073e3:	85 c0                	test   %eax,%eax
801073e5:	79 07                	jns    801073ee <sys_sbrk+0x22>
    return -1;
801073e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801073ec:	eb 28                	jmp    80107416 <sys_sbrk+0x4a>
  addr = proc->sz;
801073ee:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073f4:	8b 00                	mov    (%eax),%eax
801073f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801073f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801073fc:	83 ec 0c             	sub    $0xc,%esp
801073ff:	50                   	push   %eax
80107400:	e8 9b d5 ff ff       	call   801049a0 <growproc>
80107405:	83 c4 10             	add    $0x10,%esp
80107408:	85 c0                	test   %eax,%eax
8010740a:	79 07                	jns    80107413 <sys_sbrk+0x47>
    return -1;
8010740c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107411:	eb 03                	jmp    80107416 <sys_sbrk+0x4a>
  return addr;
80107413:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80107416:	c9                   	leave  
80107417:	c3                   	ret    

80107418 <sys_sleep>:

int
sys_sleep(void)
{
80107418:	55                   	push   %ebp
80107419:	89 e5                	mov    %esp,%ebp
8010741b:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
8010741e:	83 ec 08             	sub    $0x8,%esp
80107421:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107424:	50                   	push   %eax
80107425:	6a 00                	push   $0x0
80107427:	e8 60 f0 ff ff       	call   8010648c <argint>
8010742c:	83 c4 10             	add    $0x10,%esp
8010742f:	85 c0                	test   %eax,%eax
80107431:	79 07                	jns    8010743a <sys_sleep+0x22>
    return -1;
80107433:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107438:	eb 44                	jmp    8010747e <sys_sleep+0x66>
  ticks0 = ticks;
8010743a:	a1 e0 66 11 80       	mov    0x801166e0,%eax
8010743f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80107442:	eb 26                	jmp    8010746a <sys_sleep+0x52>
    if(proc->killed){
80107444:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010744a:	8b 40 24             	mov    0x24(%eax),%eax
8010744d:	85 c0                	test   %eax,%eax
8010744f:	74 07                	je     80107458 <sys_sleep+0x40>
      return -1;
80107451:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107456:	eb 26                	jmp    8010747e <sys_sleep+0x66>
    }
    sleep(&ticks, (struct spinlock *)0);
80107458:	83 ec 08             	sub    $0x8,%esp
8010745b:	6a 00                	push   $0x0
8010745d:	68 e0 66 11 80       	push   $0x801166e0
80107462:	e8 95 df ff ff       	call   801053fc <sleep>
80107467:	83 c4 10             	add    $0x10,%esp
  uint ticks0;
  
  if(argint(0, &n) < 0)
    return -1;
  ticks0 = ticks;
  while(ticks - ticks0 < n){
8010746a:	a1 e0 66 11 80       	mov    0x801166e0,%eax
8010746f:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107472:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107475:	39 d0                	cmp    %edx,%eax
80107477:	72 cb                	jb     80107444 <sys_sleep+0x2c>
    if(proc->killed){
      return -1;
    }
    sleep(&ticks, (struct spinlock *)0);
  }
  return 0;
80107479:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010747e:	c9                   	leave  
8010747f:	c3                   	ret    

80107480 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start. 
int
sys_uptime(void)
{
80107480:	55                   	push   %ebp
80107481:	89 e5                	mov    %esp,%ebp
80107483:	83 ec 10             	sub    $0x10,%esp
  uint xticks;
  
  xticks = ticks;
80107486:	a1 e0 66 11 80       	mov    0x801166e0,%eax
8010748b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return xticks;
8010748e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80107491:	c9                   	leave  
80107492:	c3                   	ret    

80107493 <sys_halt>:

//Turn of the computer
int
sys_halt(void){
80107493:	55                   	push   %ebp
80107494:	89 e5                	mov    %esp,%ebp
80107496:	83 ec 08             	sub    $0x8,%esp
  cprintf("Shutting down ...\n");
80107499:	83 ec 0c             	sub    $0xc,%esp
8010749c:	68 b3 9d 10 80       	push   $0x80109db3
801074a1:	e8 20 8f ff ff       	call   801003c6 <cprintf>
801074a6:	83 c4 10             	add    $0x10,%esp
  outw( 0x604, 0x0 | 0x2000);
801074a9:	83 ec 08             	sub    $0x8,%esp
801074ac:	68 00 20 00 00       	push   $0x2000
801074b1:	68 04 06 00 00       	push   $0x604
801074b6:	e8 83 fe ff ff       	call   8010733e <outw>
801074bb:	83 c4 10             	add    $0x10,%esp
  return 0;
801074be:	b8 00 00 00 00       	mov    $0x0,%eax
}
801074c3:	c9                   	leave  
801074c4:	c3                   	ret    

801074c5 <sys_date>:

#ifdef CS333_P1
//Display date
int
sys_date(void)
{
801074c5:	55                   	push   %ebp
801074c6:	89 e5                	mov    %esp,%ebp
801074c8:	83 ec 18             	sub    $0x18,%esp
  struct rtcdate *d;
  if (argptr(0, (void*)&d, sizeof(struct rtcdate)) < 0)
801074cb:	83 ec 04             	sub    $0x4,%esp
801074ce:	6a 18                	push   $0x18
801074d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
801074d3:	50                   	push   %eax
801074d4:	6a 00                	push   $0x0
801074d6:	e8 d9 ef ff ff       	call   801064b4 <argptr>
801074db:	83 c4 10             	add    $0x10,%esp
801074de:	85 c0                	test   %eax,%eax
801074e0:	79 07                	jns    801074e9 <sys_date+0x24>
    return -1;
801074e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801074e7:	eb 14                	jmp    801074fd <sys_date+0x38>
  cmostime(d);
801074e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074ec:	83 ec 0c             	sub    $0xc,%esp
801074ef:	50                   	push   %eax
801074f0:	e8 67 bd ff ff       	call   8010325c <cmostime>
801074f5:	83 c4 10             	add    $0x10,%esp
  return 0;  
801074f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801074fd:	c9                   	leave  
801074fe:	c3                   	ret    

801074ff <sys_getuid>:

#ifdef CS333_P2
//Get uid
uint
sys_getuid(void)
{
801074ff:	55                   	push   %ebp
80107500:	89 e5                	mov    %esp,%ebp
  return proc->uid;
80107502:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107508:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
8010750e:	5d                   	pop    %ebp
8010750f:	c3                   	ret    

80107510 <sys_getgid>:

//Get pid
uint
sys_getgid(void)
{
80107510:	55                   	push   %ebp
80107511:	89 e5                	mov    %esp,%ebp
  return proc->gid;
80107513:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107519:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
}
8010751f:	5d                   	pop    %ebp
80107520:	c3                   	ret    

80107521 <sys_getppid>:

//Get ppid
uint
sys_getppid(void)
{
80107521:	55                   	push   %ebp
80107522:	89 e5                	mov    %esp,%ebp
  return proc->parent->pid;  
80107524:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010752a:	8b 40 14             	mov    0x14(%eax),%eax
8010752d:	8b 40 10             	mov    0x10(%eax),%eax
}
80107530:	5d                   	pop    %ebp
80107531:	c3                   	ret    

80107532 <sys_setuid>:

//Set uid
int
sys_setuid(void)
{
80107532:	55                   	push   %ebp
80107533:	89 e5                	mov    %esp,%ebp
80107535:	83 ec 18             	sub    $0x18,%esp
  int i;
  if (argint(0, &i) < 0)
80107538:	83 ec 08             	sub    $0x8,%esp
8010753b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010753e:	50                   	push   %eax
8010753f:	6a 00                	push   $0x0
80107541:	e8 46 ef ff ff       	call   8010648c <argint>
80107546:	83 c4 10             	add    $0x10,%esp
80107549:	85 c0                	test   %eax,%eax
8010754b:	79 07                	jns    80107554 <sys_setuid+0x22>
    return -1;
8010754d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107552:	eb 2c                	jmp    80107580 <sys_setuid+0x4e>
  if (i < 0 || i > 32767)
80107554:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107557:	85 c0                	test   %eax,%eax
80107559:	78 0a                	js     80107565 <sys_setuid+0x33>
8010755b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010755e:	3d ff 7f 00 00       	cmp    $0x7fff,%eax
80107563:	7e 07                	jle    8010756c <sys_setuid+0x3a>
    return -1; 
80107565:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010756a:	eb 14                	jmp    80107580 <sys_setuid+0x4e>
  proc->uid = i;
8010756c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107572:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107575:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  return 0;
8010757b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107580:	c9                   	leave  
80107581:	c3                   	ret    

80107582 <sys_setgid>:

//Set gid
int
sys_setgid(void)
{
80107582:	55                   	push   %ebp
80107583:	89 e5                	mov    %esp,%ebp
80107585:	83 ec 18             	sub    $0x18,%esp
  int i;
  if (argint(0, &i) < 0)
80107588:	83 ec 08             	sub    $0x8,%esp
8010758b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010758e:	50                   	push   %eax
8010758f:	6a 00                	push   $0x0
80107591:	e8 f6 ee ff ff       	call   8010648c <argint>
80107596:	83 c4 10             	add    $0x10,%esp
80107599:	85 c0                	test   %eax,%eax
8010759b:	79 07                	jns    801075a4 <sys_setgid+0x22>
    return -1;
8010759d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801075a2:	eb 2c                	jmp    801075d0 <sys_setgid+0x4e>
  if (i < 0 || i > 32767)
801075a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075a7:	85 c0                	test   %eax,%eax
801075a9:	78 0a                	js     801075b5 <sys_setgid+0x33>
801075ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ae:	3d ff 7f 00 00       	cmp    $0x7fff,%eax
801075b3:	7e 07                	jle    801075bc <sys_setgid+0x3a>
    return -1;
801075b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801075ba:	eb 14                	jmp    801075d0 <sys_setgid+0x4e>
  proc->gid = i;
801075bc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801075c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801075c5:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
  return 0;
801075cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801075d0:	c9                   	leave  
801075d1:	c3                   	ret    

801075d2 <sys_getprocs>:

//getprocs
int
sys_getprocs(void)
{
801075d2:	55                   	push   %ebp
801075d3:	89 e5                	mov    %esp,%ebp
801075d5:	83 ec 18             	sub    $0x18,%esp
  int i;
  int index;
  struct uproc *table; 

  if (argint(0, &i) < 0)
801075d8:	83 ec 08             	sub    $0x8,%esp
801075db:	8d 45 f0             	lea    -0x10(%ebp),%eax
801075de:	50                   	push   %eax
801075df:	6a 00                	push   $0x0
801075e1:	e8 a6 ee ff ff       	call   8010648c <argint>
801075e6:	83 c4 10             	add    $0x10,%esp
801075e9:	85 c0                	test   %eax,%eax
801075eb:	79 07                	jns    801075f4 <sys_getprocs+0x22>
    return -1;
801075ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801075f2:	eb 37                	jmp    8010762b <sys_getprocs+0x59>
  if (argptr(1, (void*)&table, sizeof(struct uproc) < 0))
801075f4:	83 ec 04             	sub    $0x4,%esp
801075f7:	6a 00                	push   $0x0
801075f9:	8d 45 ec             	lea    -0x14(%ebp),%eax
801075fc:	50                   	push   %eax
801075fd:	6a 01                	push   $0x1
801075ff:	e8 b0 ee ff ff       	call   801064b4 <argptr>
80107604:	83 c4 10             	add    $0x10,%esp
80107607:	85 c0                	test   %eax,%eax
80107609:	74 07                	je     80107612 <sys_getprocs+0x40>
    return -1;
8010760b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107610:	eb 19                	jmp    8010762b <sys_getprocs+0x59>

  index = getprocs(i, table);  
80107612:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107615:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107618:	83 ec 08             	sub    $0x8,%esp
8010761b:	50                   	push   %eax
8010761c:	52                   	push   %edx
8010761d:	e8 82 e3 ff ff       	call   801059a4 <getprocs>
80107622:	83 c4 10             	add    $0x10,%esp
80107625:	89 45 f4             	mov    %eax,-0xc(%ebp)

  return index;
80107628:	8b 45 f4             	mov    -0xc(%ebp),%eax
  
}
8010762b:	c9                   	leave  
8010762c:	c3                   	ret    

8010762d <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010762d:	55                   	push   %ebp
8010762e:	89 e5                	mov    %esp,%ebp
80107630:	83 ec 08             	sub    $0x8,%esp
80107633:	8b 55 08             	mov    0x8(%ebp),%edx
80107636:	8b 45 0c             	mov    0xc(%ebp),%eax
80107639:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010763d:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107640:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107644:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107648:	ee                   	out    %al,(%dx)
}
80107649:	90                   	nop
8010764a:	c9                   	leave  
8010764b:	c3                   	ret    

8010764c <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
8010764c:	55                   	push   %ebp
8010764d:	89 e5                	mov    %esp,%ebp
8010764f:	83 ec 08             	sub    $0x8,%esp
  // Interrupt TPS times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80107652:	6a 34                	push   $0x34
80107654:	6a 43                	push   $0x43
80107656:	e8 d2 ff ff ff       	call   8010762d <outb>
8010765b:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(TPS) % 256);
8010765e:	68 a9 00 00 00       	push   $0xa9
80107663:	6a 40                	push   $0x40
80107665:	e8 c3 ff ff ff       	call   8010762d <outb>
8010766a:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(TPS) / 256);
8010766d:	6a 04                	push   $0x4
8010766f:	6a 40                	push   $0x40
80107671:	e8 b7 ff ff ff       	call   8010762d <outb>
80107676:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
80107679:	83 ec 0c             	sub    $0xc,%esp
8010767c:	6a 00                	push   $0x0
8010767e:	e8 3c c9 ff ff       	call   80103fbf <picenable>
80107683:	83 c4 10             	add    $0x10,%esp
}
80107686:	90                   	nop
80107687:	c9                   	leave  
80107688:	c3                   	ret    

80107689 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80107689:	1e                   	push   %ds
  pushl %es
8010768a:	06                   	push   %es
  pushl %fs
8010768b:	0f a0                	push   %fs
  pushl %gs
8010768d:	0f a8                	push   %gs
  pushal
8010768f:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80107690:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80107694:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80107696:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80107698:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
8010769c:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
8010769e:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
801076a0:	54                   	push   %esp
  call trap
801076a1:	e8 ce 01 00 00       	call   80107874 <trap>
  addl $4, %esp
801076a6:	83 c4 04             	add    $0x4,%esp

801076a9 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801076a9:	61                   	popa   
  popl %gs
801076aa:	0f a9                	pop    %gs
  popl %fs
801076ac:	0f a1                	pop    %fs
  popl %es
801076ae:	07                   	pop    %es
  popl %ds
801076af:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801076b0:	83 c4 08             	add    $0x8,%esp
  iret
801076b3:	cf                   	iret   

801076b4 <atom_inc>:

// Routines added for CS333
// atom_inc() added to simplify handling of ticks global
static inline void
atom_inc(volatile int *num)
{
801076b4:	55                   	push   %ebp
801076b5:	89 e5                	mov    %esp,%ebp
  asm volatile ( "lock incl %0" : "=m" (*num));
801076b7:	8b 45 08             	mov    0x8(%ebp),%eax
801076ba:	f0 ff 00             	lock incl (%eax)
}
801076bd:	90                   	nop
801076be:	5d                   	pop    %ebp
801076bf:	c3                   	ret    

801076c0 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801076c0:	55                   	push   %ebp
801076c1:	89 e5                	mov    %esp,%ebp
801076c3:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801076c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801076c9:	83 e8 01             	sub    $0x1,%eax
801076cc:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801076d0:	8b 45 08             	mov    0x8(%ebp),%eax
801076d3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801076d7:	8b 45 08             	mov    0x8(%ebp),%eax
801076da:	c1 e8 10             	shr    $0x10,%eax
801076dd:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801076e1:	8d 45 fa             	lea    -0x6(%ebp),%eax
801076e4:	0f 01 18             	lidtl  (%eax)
}
801076e7:	90                   	nop
801076e8:	c9                   	leave  
801076e9:	c3                   	ret    

801076ea <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
801076ea:	55                   	push   %ebp
801076eb:	89 e5                	mov    %esp,%ebp
801076ed:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801076f0:	0f 20 d0             	mov    %cr2,%eax
801076f3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801076f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801076f9:	c9                   	leave  
801076fa:	c3                   	ret    

801076fb <tvinit>:
// Software Developer’s Manual, Vol 3A, 8.1.1 Guaranteed Atomic Operations.
uint ticks __attribute__ ((aligned (4)));

void
tvinit(void)
{
801076fb:	55                   	push   %ebp
801076fc:	89 e5                	mov    %esp,%ebp
801076fe:	83 ec 10             	sub    $0x10,%esp
  int i;

  for(i = 0; i < 256; i++)
80107701:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80107708:	e9 c3 00 00 00       	jmp    801077d0 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010770d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107710:	8b 04 85 b8 c0 10 80 	mov    -0x7fef3f48(,%eax,4),%eax
80107717:	89 c2                	mov    %eax,%edx
80107719:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010771c:	66 89 14 c5 e0 5e 11 	mov    %dx,-0x7feea120(,%eax,8)
80107723:	80 
80107724:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107727:	66 c7 04 c5 e2 5e 11 	movw   $0x8,-0x7feea11e(,%eax,8)
8010772e:	80 08 00 
80107731:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107734:	0f b6 14 c5 e4 5e 11 	movzbl -0x7feea11c(,%eax,8),%edx
8010773b:	80 
8010773c:	83 e2 e0             	and    $0xffffffe0,%edx
8010773f:	88 14 c5 e4 5e 11 80 	mov    %dl,-0x7feea11c(,%eax,8)
80107746:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107749:	0f b6 14 c5 e4 5e 11 	movzbl -0x7feea11c(,%eax,8),%edx
80107750:	80 
80107751:	83 e2 1f             	and    $0x1f,%edx
80107754:	88 14 c5 e4 5e 11 80 	mov    %dl,-0x7feea11c(,%eax,8)
8010775b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010775e:	0f b6 14 c5 e5 5e 11 	movzbl -0x7feea11b(,%eax,8),%edx
80107765:	80 
80107766:	83 e2 f0             	and    $0xfffffff0,%edx
80107769:	83 ca 0e             	or     $0xe,%edx
8010776c:	88 14 c5 e5 5e 11 80 	mov    %dl,-0x7feea11b(,%eax,8)
80107773:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107776:	0f b6 14 c5 e5 5e 11 	movzbl -0x7feea11b(,%eax,8),%edx
8010777d:	80 
8010777e:	83 e2 ef             	and    $0xffffffef,%edx
80107781:	88 14 c5 e5 5e 11 80 	mov    %dl,-0x7feea11b(,%eax,8)
80107788:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010778b:	0f b6 14 c5 e5 5e 11 	movzbl -0x7feea11b(,%eax,8),%edx
80107792:	80 
80107793:	83 e2 9f             	and    $0xffffff9f,%edx
80107796:	88 14 c5 e5 5e 11 80 	mov    %dl,-0x7feea11b(,%eax,8)
8010779d:	8b 45 fc             	mov    -0x4(%ebp),%eax
801077a0:	0f b6 14 c5 e5 5e 11 	movzbl -0x7feea11b(,%eax,8),%edx
801077a7:	80 
801077a8:	83 ca 80             	or     $0xffffff80,%edx
801077ab:	88 14 c5 e5 5e 11 80 	mov    %dl,-0x7feea11b(,%eax,8)
801077b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801077b5:	8b 04 85 b8 c0 10 80 	mov    -0x7fef3f48(,%eax,4),%eax
801077bc:	c1 e8 10             	shr    $0x10,%eax
801077bf:	89 c2                	mov    %eax,%edx
801077c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801077c4:	66 89 14 c5 e6 5e 11 	mov    %dx,-0x7feea11a(,%eax,8)
801077cb:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
801077cc:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801077d0:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
801077d7:	0f 8e 30 ff ff ff    	jle    8010770d <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801077dd:	a1 b8 c1 10 80       	mov    0x8010c1b8,%eax
801077e2:	66 a3 e0 60 11 80    	mov    %ax,0x801160e0
801077e8:	66 c7 05 e2 60 11 80 	movw   $0x8,0x801160e2
801077ef:	08 00 
801077f1:	0f b6 05 e4 60 11 80 	movzbl 0x801160e4,%eax
801077f8:	83 e0 e0             	and    $0xffffffe0,%eax
801077fb:	a2 e4 60 11 80       	mov    %al,0x801160e4
80107800:	0f b6 05 e4 60 11 80 	movzbl 0x801160e4,%eax
80107807:	83 e0 1f             	and    $0x1f,%eax
8010780a:	a2 e4 60 11 80       	mov    %al,0x801160e4
8010780f:	0f b6 05 e5 60 11 80 	movzbl 0x801160e5,%eax
80107816:	83 c8 0f             	or     $0xf,%eax
80107819:	a2 e5 60 11 80       	mov    %al,0x801160e5
8010781e:	0f b6 05 e5 60 11 80 	movzbl 0x801160e5,%eax
80107825:	83 e0 ef             	and    $0xffffffef,%eax
80107828:	a2 e5 60 11 80       	mov    %al,0x801160e5
8010782d:	0f b6 05 e5 60 11 80 	movzbl 0x801160e5,%eax
80107834:	83 c8 60             	or     $0x60,%eax
80107837:	a2 e5 60 11 80       	mov    %al,0x801160e5
8010783c:	0f b6 05 e5 60 11 80 	movzbl 0x801160e5,%eax
80107843:	83 c8 80             	or     $0xffffff80,%eax
80107846:	a2 e5 60 11 80       	mov    %al,0x801160e5
8010784b:	a1 b8 c1 10 80       	mov    0x8010c1b8,%eax
80107850:	c1 e8 10             	shr    $0x10,%eax
80107853:	66 a3 e6 60 11 80    	mov    %ax,0x801160e6
  
}
80107859:	90                   	nop
8010785a:	c9                   	leave  
8010785b:	c3                   	ret    

8010785c <idtinit>:

void
idtinit(void)
{
8010785c:	55                   	push   %ebp
8010785d:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
8010785f:	68 00 08 00 00       	push   $0x800
80107864:	68 e0 5e 11 80       	push   $0x80115ee0
80107869:	e8 52 fe ff ff       	call   801076c0 <lidt>
8010786e:	83 c4 08             	add    $0x8,%esp
}
80107871:	90                   	nop
80107872:	c9                   	leave  
80107873:	c3                   	ret    

80107874 <trap>:

void
trap(struct trapframe *tf)
{
80107874:	55                   	push   %ebp
80107875:	89 e5                	mov    %esp,%ebp
80107877:	57                   	push   %edi
80107878:	56                   	push   %esi
80107879:	53                   	push   %ebx
8010787a:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
8010787d:	8b 45 08             	mov    0x8(%ebp),%eax
80107880:	8b 40 30             	mov    0x30(%eax),%eax
80107883:	83 f8 40             	cmp    $0x40,%eax
80107886:	75 3e                	jne    801078c6 <trap+0x52>
    if(proc->killed)
80107888:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010788e:	8b 40 24             	mov    0x24(%eax),%eax
80107891:	85 c0                	test   %eax,%eax
80107893:	74 05                	je     8010789a <trap+0x26>
      exit();
80107895:	e8 dc d3 ff ff       	call   80104c76 <exit>
    proc->tf = tf;
8010789a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801078a0:	8b 55 08             	mov    0x8(%ebp),%edx
801078a3:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801078a6:	e8 97 ec ff ff       	call   80106542 <syscall>
    if(proc->killed)
801078ab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801078b1:	8b 40 24             	mov    0x24(%eax),%eax
801078b4:	85 c0                	test   %eax,%eax
801078b6:	0f 84 21 02 00 00    	je     80107add <trap+0x269>
      exit();
801078bc:	e8 b5 d3 ff ff       	call   80104c76 <exit>
    return;
801078c1:	e9 17 02 00 00       	jmp    80107add <trap+0x269>
  }

  switch(tf->trapno){
801078c6:	8b 45 08             	mov    0x8(%ebp),%eax
801078c9:	8b 40 30             	mov    0x30(%eax),%eax
801078cc:	83 e8 20             	sub    $0x20,%eax
801078cf:	83 f8 1f             	cmp    $0x1f,%eax
801078d2:	0f 87 a3 00 00 00    	ja     8010797b <trap+0x107>
801078d8:	8b 04 85 68 9e 10 80 	mov    -0x7fef6198(,%eax,4),%eax
801078df:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
   if(cpu->id == 0){
801078e1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801078e7:	0f b6 00             	movzbl (%eax),%eax
801078ea:	84 c0                	test   %al,%al
801078ec:	75 20                	jne    8010790e <trap+0x9a>
      atom_inc((int *)&ticks);   // guaranteed atomic so no lock necessary
801078ee:	83 ec 0c             	sub    $0xc,%esp
801078f1:	68 e0 66 11 80       	push   $0x801166e0
801078f6:	e8 b9 fd ff ff       	call   801076b4 <atom_inc>
801078fb:	83 c4 10             	add    $0x10,%esp
      wakeup(&ticks);
801078fe:	83 ec 0c             	sub    $0xc,%esp
80107901:	68 e0 66 11 80       	push   $0x801166e0
80107906:	e8 49 dc ff ff       	call   80105554 <wakeup>
8010790b:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
8010790e:	e8 a6 b7 ff ff       	call   801030b9 <lapiceoi>
    break;
80107913:	e9 1c 01 00 00       	jmp    80107a34 <trap+0x1c0>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80107918:	e8 af af ff ff       	call   801028cc <ideintr>
    lapiceoi();
8010791d:	e8 97 b7 ff ff       	call   801030b9 <lapiceoi>
    break;
80107922:	e9 0d 01 00 00       	jmp    80107a34 <trap+0x1c0>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80107927:	e8 8f b5 ff ff       	call   80102ebb <kbdintr>
    lapiceoi();
8010792c:	e8 88 b7 ff ff       	call   801030b9 <lapiceoi>
    break;
80107931:	e9 fe 00 00 00       	jmp    80107a34 <trap+0x1c0>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80107936:	e8 83 03 00 00       	call   80107cbe <uartintr>
    lapiceoi();
8010793b:	e8 79 b7 ff ff       	call   801030b9 <lapiceoi>
    break;
80107940:	e9 ef 00 00 00       	jmp    80107a34 <trap+0x1c0>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107945:	8b 45 08             	mov    0x8(%ebp),%eax
80107948:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
8010794b:	8b 45 08             	mov    0x8(%ebp),%eax
8010794e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107952:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80107955:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010795b:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010795e:	0f b6 c0             	movzbl %al,%eax
80107961:	51                   	push   %ecx
80107962:	52                   	push   %edx
80107963:	50                   	push   %eax
80107964:	68 c8 9d 10 80       	push   $0x80109dc8
80107969:	e8 58 8a ff ff       	call   801003c6 <cprintf>
8010796e:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80107971:	e8 43 b7 ff ff       	call   801030b9 <lapiceoi>
    break;
80107976:	e9 b9 00 00 00       	jmp    80107a34 <trap+0x1c0>
   
  default:
    if(proc == 0 || (tf->cs&3) == 0){
8010797b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107981:	85 c0                	test   %eax,%eax
80107983:	74 11                	je     80107996 <trap+0x122>
80107985:	8b 45 08             	mov    0x8(%ebp),%eax
80107988:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010798c:	0f b7 c0             	movzwl %ax,%eax
8010798f:	83 e0 03             	and    $0x3,%eax
80107992:	85 c0                	test   %eax,%eax
80107994:	75 40                	jne    801079d6 <trap+0x162>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80107996:	e8 4f fd ff ff       	call   801076ea <rcr2>
8010799b:	89 c3                	mov    %eax,%ebx
8010799d:	8b 45 08             	mov    0x8(%ebp),%eax
801079a0:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
801079a3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801079a9:	0f b6 00             	movzbl (%eax),%eax
    break;
   
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801079ac:	0f b6 d0             	movzbl %al,%edx
801079af:	8b 45 08             	mov    0x8(%ebp),%eax
801079b2:	8b 40 30             	mov    0x30(%eax),%eax
801079b5:	83 ec 0c             	sub    $0xc,%esp
801079b8:	53                   	push   %ebx
801079b9:	51                   	push   %ecx
801079ba:	52                   	push   %edx
801079bb:	50                   	push   %eax
801079bc:	68 ec 9d 10 80       	push   $0x80109dec
801079c1:	e8 00 8a ff ff       	call   801003c6 <cprintf>
801079c6:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
801079c9:	83 ec 0c             	sub    $0xc,%esp
801079cc:	68 1e 9e 10 80       	push   $0x80109e1e
801079d1:	e8 90 8b ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801079d6:	e8 0f fd ff ff       	call   801076ea <rcr2>
801079db:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801079de:	8b 45 08             	mov    0x8(%ebp),%eax
801079e1:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801079e4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801079ea:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801079ed:	0f b6 d8             	movzbl %al,%ebx
801079f0:	8b 45 08             	mov    0x8(%ebp),%eax
801079f3:	8b 48 34             	mov    0x34(%eax),%ecx
801079f6:	8b 45 08             	mov    0x8(%ebp),%eax
801079f9:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801079fc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107a02:	8d 78 6c             	lea    0x6c(%eax),%edi
80107a05:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107a0b:	8b 40 10             	mov    0x10(%eax),%eax
80107a0e:	ff 75 e4             	pushl  -0x1c(%ebp)
80107a11:	56                   	push   %esi
80107a12:	53                   	push   %ebx
80107a13:	51                   	push   %ecx
80107a14:	52                   	push   %edx
80107a15:	57                   	push   %edi
80107a16:	50                   	push   %eax
80107a17:	68 24 9e 10 80       	push   $0x80109e24
80107a1c:	e8 a5 89 ff ff       	call   801003c6 <cprintf>
80107a21:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80107a24:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107a2a:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80107a31:	eb 01                	jmp    80107a34 <trap+0x1c0>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80107a33:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80107a34:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107a3a:	85 c0                	test   %eax,%eax
80107a3c:	74 24                	je     80107a62 <trap+0x1ee>
80107a3e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107a44:	8b 40 24             	mov    0x24(%eax),%eax
80107a47:	85 c0                	test   %eax,%eax
80107a49:	74 17                	je     80107a62 <trap+0x1ee>
80107a4b:	8b 45 08             	mov    0x8(%ebp),%eax
80107a4e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107a52:	0f b7 c0             	movzwl %ax,%eax
80107a55:	83 e0 03             	and    $0x3,%eax
80107a58:	83 f8 03             	cmp    $0x3,%eax
80107a5b:	75 05                	jne    80107a62 <trap+0x1ee>
    exit();
80107a5d:	e8 14 d2 ff ff       	call   80104c76 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING &&
80107a62:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107a68:	85 c0                	test   %eax,%eax
80107a6a:	74 41                	je     80107aad <trap+0x239>
80107a6c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107a72:	8b 40 0c             	mov    0xc(%eax),%eax
80107a75:	83 f8 04             	cmp    $0x4,%eax
80107a78:	75 33                	jne    80107aad <trap+0x239>
	  tf->trapno == T_IRQ0+IRQ_TIMER && ticks%SCHED_INTERVAL==0)
80107a7a:	8b 45 08             	mov    0x8(%ebp),%eax
80107a7d:	8b 40 30             	mov    0x30(%eax),%eax
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING &&
80107a80:	83 f8 20             	cmp    $0x20,%eax
80107a83:	75 28                	jne    80107aad <trap+0x239>
	  tf->trapno == T_IRQ0+IRQ_TIMER && ticks%SCHED_INTERVAL==0)
80107a85:	8b 0d e0 66 11 80    	mov    0x801166e0,%ecx
80107a8b:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
80107a90:	89 c8                	mov    %ecx,%eax
80107a92:	f7 e2                	mul    %edx
80107a94:	c1 ea 03             	shr    $0x3,%edx
80107a97:	89 d0                	mov    %edx,%eax
80107a99:	c1 e0 02             	shl    $0x2,%eax
80107a9c:	01 d0                	add    %edx,%eax
80107a9e:	01 c0                	add    %eax,%eax
80107aa0:	29 c1                	sub    %eax,%ecx
80107aa2:	89 ca                	mov    %ecx,%edx
80107aa4:	85 d2                	test   %edx,%edx
80107aa6:	75 05                	jne    80107aad <trap+0x239>
    yield();
80107aa8:	e8 60 d8 ff ff       	call   8010530d <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80107aad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107ab3:	85 c0                	test   %eax,%eax
80107ab5:	74 27                	je     80107ade <trap+0x26a>
80107ab7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107abd:	8b 40 24             	mov    0x24(%eax),%eax
80107ac0:	85 c0                	test   %eax,%eax
80107ac2:	74 1a                	je     80107ade <trap+0x26a>
80107ac4:	8b 45 08             	mov    0x8(%ebp),%eax
80107ac7:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107acb:	0f b7 c0             	movzwl %ax,%eax
80107ace:	83 e0 03             	and    $0x3,%eax
80107ad1:	83 f8 03             	cmp    $0x3,%eax
80107ad4:	75 08                	jne    80107ade <trap+0x26a>
    exit();
80107ad6:	e8 9b d1 ff ff       	call   80104c76 <exit>
80107adb:	eb 01                	jmp    80107ade <trap+0x26a>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
80107add:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80107ade:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107ae1:	5b                   	pop    %ebx
80107ae2:	5e                   	pop    %esi
80107ae3:	5f                   	pop    %edi
80107ae4:	5d                   	pop    %ebp
80107ae5:	c3                   	ret    

80107ae6 <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80107ae6:	55                   	push   %ebp
80107ae7:	89 e5                	mov    %esp,%ebp
80107ae9:	83 ec 14             	sub    $0x14,%esp
80107aec:	8b 45 08             	mov    0x8(%ebp),%eax
80107aef:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107af3:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80107af7:	89 c2                	mov    %eax,%edx
80107af9:	ec                   	in     (%dx),%al
80107afa:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80107afd:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80107b01:	c9                   	leave  
80107b02:	c3                   	ret    

80107b03 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80107b03:	55                   	push   %ebp
80107b04:	89 e5                	mov    %esp,%ebp
80107b06:	83 ec 08             	sub    $0x8,%esp
80107b09:	8b 55 08             	mov    0x8(%ebp),%edx
80107b0c:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b0f:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107b13:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107b16:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107b1a:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107b1e:	ee                   	out    %al,(%dx)
}
80107b1f:	90                   	nop
80107b20:	c9                   	leave  
80107b21:	c3                   	ret    

80107b22 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80107b22:	55                   	push   %ebp
80107b23:	89 e5                	mov    %esp,%ebp
80107b25:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80107b28:	6a 00                	push   $0x0
80107b2a:	68 fa 03 00 00       	push   $0x3fa
80107b2f:	e8 cf ff ff ff       	call   80107b03 <outb>
80107b34:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107b37:	68 80 00 00 00       	push   $0x80
80107b3c:	68 fb 03 00 00       	push   $0x3fb
80107b41:	e8 bd ff ff ff       	call   80107b03 <outb>
80107b46:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80107b49:	6a 0c                	push   $0xc
80107b4b:	68 f8 03 00 00       	push   $0x3f8
80107b50:	e8 ae ff ff ff       	call   80107b03 <outb>
80107b55:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80107b58:	6a 00                	push   $0x0
80107b5a:	68 f9 03 00 00       	push   $0x3f9
80107b5f:	e8 9f ff ff ff       	call   80107b03 <outb>
80107b64:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107b67:	6a 03                	push   $0x3
80107b69:	68 fb 03 00 00       	push   $0x3fb
80107b6e:	e8 90 ff ff ff       	call   80107b03 <outb>
80107b73:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80107b76:	6a 00                	push   $0x0
80107b78:	68 fc 03 00 00       	push   $0x3fc
80107b7d:	e8 81 ff ff ff       	call   80107b03 <outb>
80107b82:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80107b85:	6a 01                	push   $0x1
80107b87:	68 f9 03 00 00       	push   $0x3f9
80107b8c:	e8 72 ff ff ff       	call   80107b03 <outb>
80107b91:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80107b94:	68 fd 03 00 00       	push   $0x3fd
80107b99:	e8 48 ff ff ff       	call   80107ae6 <inb>
80107b9e:	83 c4 04             	add    $0x4,%esp
80107ba1:	3c ff                	cmp    $0xff,%al
80107ba3:	74 6e                	je     80107c13 <uartinit+0xf1>
    return;
  uart = 1;
80107ba5:	c7 05 6c c6 10 80 01 	movl   $0x1,0x8010c66c
80107bac:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80107baf:	68 fa 03 00 00       	push   $0x3fa
80107bb4:	e8 2d ff ff ff       	call   80107ae6 <inb>
80107bb9:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80107bbc:	68 f8 03 00 00       	push   $0x3f8
80107bc1:	e8 20 ff ff ff       	call   80107ae6 <inb>
80107bc6:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
80107bc9:	83 ec 0c             	sub    $0xc,%esp
80107bcc:	6a 04                	push   $0x4
80107bce:	e8 ec c3 ff ff       	call   80103fbf <picenable>
80107bd3:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80107bd6:	83 ec 08             	sub    $0x8,%esp
80107bd9:	6a 00                	push   $0x0
80107bdb:	6a 04                	push   $0x4
80107bdd:	e8 8c af ff ff       	call   80102b6e <ioapicenable>
80107be2:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107be5:	c7 45 f4 e8 9e 10 80 	movl   $0x80109ee8,-0xc(%ebp)
80107bec:	eb 19                	jmp    80107c07 <uartinit+0xe5>
    uartputc(*p);
80107bee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf1:	0f b6 00             	movzbl (%eax),%eax
80107bf4:	0f be c0             	movsbl %al,%eax
80107bf7:	83 ec 0c             	sub    $0xc,%esp
80107bfa:	50                   	push   %eax
80107bfb:	e8 16 00 00 00       	call   80107c16 <uartputc>
80107c00:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107c03:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107c07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c0a:	0f b6 00             	movzbl (%eax),%eax
80107c0d:	84 c0                	test   %al,%al
80107c0f:	75 dd                	jne    80107bee <uartinit+0xcc>
80107c11:	eb 01                	jmp    80107c14 <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80107c13:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80107c14:	c9                   	leave  
80107c15:	c3                   	ret    

80107c16 <uartputc>:

void
uartputc(int c)
{
80107c16:	55                   	push   %ebp
80107c17:	89 e5                	mov    %esp,%ebp
80107c19:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80107c1c:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
80107c21:	85 c0                	test   %eax,%eax
80107c23:	74 53                	je     80107c78 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107c25:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107c2c:	eb 11                	jmp    80107c3f <uartputc+0x29>
    microdelay(10);
80107c2e:	83 ec 0c             	sub    $0xc,%esp
80107c31:	6a 0a                	push   $0xa
80107c33:	e8 9c b4 ff ff       	call   801030d4 <microdelay>
80107c38:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107c3b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107c3f:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107c43:	7f 1a                	jg     80107c5f <uartputc+0x49>
80107c45:	83 ec 0c             	sub    $0xc,%esp
80107c48:	68 fd 03 00 00       	push   $0x3fd
80107c4d:	e8 94 fe ff ff       	call   80107ae6 <inb>
80107c52:	83 c4 10             	add    $0x10,%esp
80107c55:	0f b6 c0             	movzbl %al,%eax
80107c58:	83 e0 20             	and    $0x20,%eax
80107c5b:	85 c0                	test   %eax,%eax
80107c5d:	74 cf                	je     80107c2e <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80107c5f:	8b 45 08             	mov    0x8(%ebp),%eax
80107c62:	0f b6 c0             	movzbl %al,%eax
80107c65:	83 ec 08             	sub    $0x8,%esp
80107c68:	50                   	push   %eax
80107c69:	68 f8 03 00 00       	push   $0x3f8
80107c6e:	e8 90 fe ff ff       	call   80107b03 <outb>
80107c73:	83 c4 10             	add    $0x10,%esp
80107c76:	eb 01                	jmp    80107c79 <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80107c78:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80107c79:	c9                   	leave  
80107c7a:	c3                   	ret    

80107c7b <uartgetc>:

static int
uartgetc(void)
{
80107c7b:	55                   	push   %ebp
80107c7c:	89 e5                	mov    %esp,%ebp
  if(!uart)
80107c7e:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
80107c83:	85 c0                	test   %eax,%eax
80107c85:	75 07                	jne    80107c8e <uartgetc+0x13>
    return -1;
80107c87:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107c8c:	eb 2e                	jmp    80107cbc <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80107c8e:	68 fd 03 00 00       	push   $0x3fd
80107c93:	e8 4e fe ff ff       	call   80107ae6 <inb>
80107c98:	83 c4 04             	add    $0x4,%esp
80107c9b:	0f b6 c0             	movzbl %al,%eax
80107c9e:	83 e0 01             	and    $0x1,%eax
80107ca1:	85 c0                	test   %eax,%eax
80107ca3:	75 07                	jne    80107cac <uartgetc+0x31>
    return -1;
80107ca5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107caa:	eb 10                	jmp    80107cbc <uartgetc+0x41>
  return inb(COM1+0);
80107cac:	68 f8 03 00 00       	push   $0x3f8
80107cb1:	e8 30 fe ff ff       	call   80107ae6 <inb>
80107cb6:	83 c4 04             	add    $0x4,%esp
80107cb9:	0f b6 c0             	movzbl %al,%eax
}
80107cbc:	c9                   	leave  
80107cbd:	c3                   	ret    

80107cbe <uartintr>:

void
uartintr(void)
{
80107cbe:	55                   	push   %ebp
80107cbf:	89 e5                	mov    %esp,%ebp
80107cc1:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80107cc4:	83 ec 0c             	sub    $0xc,%esp
80107cc7:	68 7b 7c 10 80       	push   $0x80107c7b
80107ccc:	e8 28 8b ff ff       	call   801007f9 <consoleintr>
80107cd1:	83 c4 10             	add    $0x10,%esp
}
80107cd4:	90                   	nop
80107cd5:	c9                   	leave  
80107cd6:	c3                   	ret    

80107cd7 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107cd7:	6a 00                	push   $0x0
  pushl $0
80107cd9:	6a 00                	push   $0x0
  jmp alltraps
80107cdb:	e9 a9 f9 ff ff       	jmp    80107689 <alltraps>

80107ce0 <vector1>:
.globl vector1
vector1:
  pushl $0
80107ce0:	6a 00                	push   $0x0
  pushl $1
80107ce2:	6a 01                	push   $0x1
  jmp alltraps
80107ce4:	e9 a0 f9 ff ff       	jmp    80107689 <alltraps>

80107ce9 <vector2>:
.globl vector2
vector2:
  pushl $0
80107ce9:	6a 00                	push   $0x0
  pushl $2
80107ceb:	6a 02                	push   $0x2
  jmp alltraps
80107ced:	e9 97 f9 ff ff       	jmp    80107689 <alltraps>

80107cf2 <vector3>:
.globl vector3
vector3:
  pushl $0
80107cf2:	6a 00                	push   $0x0
  pushl $3
80107cf4:	6a 03                	push   $0x3
  jmp alltraps
80107cf6:	e9 8e f9 ff ff       	jmp    80107689 <alltraps>

80107cfb <vector4>:
.globl vector4
vector4:
  pushl $0
80107cfb:	6a 00                	push   $0x0
  pushl $4
80107cfd:	6a 04                	push   $0x4
  jmp alltraps
80107cff:	e9 85 f9 ff ff       	jmp    80107689 <alltraps>

80107d04 <vector5>:
.globl vector5
vector5:
  pushl $0
80107d04:	6a 00                	push   $0x0
  pushl $5
80107d06:	6a 05                	push   $0x5
  jmp alltraps
80107d08:	e9 7c f9 ff ff       	jmp    80107689 <alltraps>

80107d0d <vector6>:
.globl vector6
vector6:
  pushl $0
80107d0d:	6a 00                	push   $0x0
  pushl $6
80107d0f:	6a 06                	push   $0x6
  jmp alltraps
80107d11:	e9 73 f9 ff ff       	jmp    80107689 <alltraps>

80107d16 <vector7>:
.globl vector7
vector7:
  pushl $0
80107d16:	6a 00                	push   $0x0
  pushl $7
80107d18:	6a 07                	push   $0x7
  jmp alltraps
80107d1a:	e9 6a f9 ff ff       	jmp    80107689 <alltraps>

80107d1f <vector8>:
.globl vector8
vector8:
  pushl $8
80107d1f:	6a 08                	push   $0x8
  jmp alltraps
80107d21:	e9 63 f9 ff ff       	jmp    80107689 <alltraps>

80107d26 <vector9>:
.globl vector9
vector9:
  pushl $0
80107d26:	6a 00                	push   $0x0
  pushl $9
80107d28:	6a 09                	push   $0x9
  jmp alltraps
80107d2a:	e9 5a f9 ff ff       	jmp    80107689 <alltraps>

80107d2f <vector10>:
.globl vector10
vector10:
  pushl $10
80107d2f:	6a 0a                	push   $0xa
  jmp alltraps
80107d31:	e9 53 f9 ff ff       	jmp    80107689 <alltraps>

80107d36 <vector11>:
.globl vector11
vector11:
  pushl $11
80107d36:	6a 0b                	push   $0xb
  jmp alltraps
80107d38:	e9 4c f9 ff ff       	jmp    80107689 <alltraps>

80107d3d <vector12>:
.globl vector12
vector12:
  pushl $12
80107d3d:	6a 0c                	push   $0xc
  jmp alltraps
80107d3f:	e9 45 f9 ff ff       	jmp    80107689 <alltraps>

80107d44 <vector13>:
.globl vector13
vector13:
  pushl $13
80107d44:	6a 0d                	push   $0xd
  jmp alltraps
80107d46:	e9 3e f9 ff ff       	jmp    80107689 <alltraps>

80107d4b <vector14>:
.globl vector14
vector14:
  pushl $14
80107d4b:	6a 0e                	push   $0xe
  jmp alltraps
80107d4d:	e9 37 f9 ff ff       	jmp    80107689 <alltraps>

80107d52 <vector15>:
.globl vector15
vector15:
  pushl $0
80107d52:	6a 00                	push   $0x0
  pushl $15
80107d54:	6a 0f                	push   $0xf
  jmp alltraps
80107d56:	e9 2e f9 ff ff       	jmp    80107689 <alltraps>

80107d5b <vector16>:
.globl vector16
vector16:
  pushl $0
80107d5b:	6a 00                	push   $0x0
  pushl $16
80107d5d:	6a 10                	push   $0x10
  jmp alltraps
80107d5f:	e9 25 f9 ff ff       	jmp    80107689 <alltraps>

80107d64 <vector17>:
.globl vector17
vector17:
  pushl $17
80107d64:	6a 11                	push   $0x11
  jmp alltraps
80107d66:	e9 1e f9 ff ff       	jmp    80107689 <alltraps>

80107d6b <vector18>:
.globl vector18
vector18:
  pushl $0
80107d6b:	6a 00                	push   $0x0
  pushl $18
80107d6d:	6a 12                	push   $0x12
  jmp alltraps
80107d6f:	e9 15 f9 ff ff       	jmp    80107689 <alltraps>

80107d74 <vector19>:
.globl vector19
vector19:
  pushl $0
80107d74:	6a 00                	push   $0x0
  pushl $19
80107d76:	6a 13                	push   $0x13
  jmp alltraps
80107d78:	e9 0c f9 ff ff       	jmp    80107689 <alltraps>

80107d7d <vector20>:
.globl vector20
vector20:
  pushl $0
80107d7d:	6a 00                	push   $0x0
  pushl $20
80107d7f:	6a 14                	push   $0x14
  jmp alltraps
80107d81:	e9 03 f9 ff ff       	jmp    80107689 <alltraps>

80107d86 <vector21>:
.globl vector21
vector21:
  pushl $0
80107d86:	6a 00                	push   $0x0
  pushl $21
80107d88:	6a 15                	push   $0x15
  jmp alltraps
80107d8a:	e9 fa f8 ff ff       	jmp    80107689 <alltraps>

80107d8f <vector22>:
.globl vector22
vector22:
  pushl $0
80107d8f:	6a 00                	push   $0x0
  pushl $22
80107d91:	6a 16                	push   $0x16
  jmp alltraps
80107d93:	e9 f1 f8 ff ff       	jmp    80107689 <alltraps>

80107d98 <vector23>:
.globl vector23
vector23:
  pushl $0
80107d98:	6a 00                	push   $0x0
  pushl $23
80107d9a:	6a 17                	push   $0x17
  jmp alltraps
80107d9c:	e9 e8 f8 ff ff       	jmp    80107689 <alltraps>

80107da1 <vector24>:
.globl vector24
vector24:
  pushl $0
80107da1:	6a 00                	push   $0x0
  pushl $24
80107da3:	6a 18                	push   $0x18
  jmp alltraps
80107da5:	e9 df f8 ff ff       	jmp    80107689 <alltraps>

80107daa <vector25>:
.globl vector25
vector25:
  pushl $0
80107daa:	6a 00                	push   $0x0
  pushl $25
80107dac:	6a 19                	push   $0x19
  jmp alltraps
80107dae:	e9 d6 f8 ff ff       	jmp    80107689 <alltraps>

80107db3 <vector26>:
.globl vector26
vector26:
  pushl $0
80107db3:	6a 00                	push   $0x0
  pushl $26
80107db5:	6a 1a                	push   $0x1a
  jmp alltraps
80107db7:	e9 cd f8 ff ff       	jmp    80107689 <alltraps>

80107dbc <vector27>:
.globl vector27
vector27:
  pushl $0
80107dbc:	6a 00                	push   $0x0
  pushl $27
80107dbe:	6a 1b                	push   $0x1b
  jmp alltraps
80107dc0:	e9 c4 f8 ff ff       	jmp    80107689 <alltraps>

80107dc5 <vector28>:
.globl vector28
vector28:
  pushl $0
80107dc5:	6a 00                	push   $0x0
  pushl $28
80107dc7:	6a 1c                	push   $0x1c
  jmp alltraps
80107dc9:	e9 bb f8 ff ff       	jmp    80107689 <alltraps>

80107dce <vector29>:
.globl vector29
vector29:
  pushl $0
80107dce:	6a 00                	push   $0x0
  pushl $29
80107dd0:	6a 1d                	push   $0x1d
  jmp alltraps
80107dd2:	e9 b2 f8 ff ff       	jmp    80107689 <alltraps>

80107dd7 <vector30>:
.globl vector30
vector30:
  pushl $0
80107dd7:	6a 00                	push   $0x0
  pushl $30
80107dd9:	6a 1e                	push   $0x1e
  jmp alltraps
80107ddb:	e9 a9 f8 ff ff       	jmp    80107689 <alltraps>

80107de0 <vector31>:
.globl vector31
vector31:
  pushl $0
80107de0:	6a 00                	push   $0x0
  pushl $31
80107de2:	6a 1f                	push   $0x1f
  jmp alltraps
80107de4:	e9 a0 f8 ff ff       	jmp    80107689 <alltraps>

80107de9 <vector32>:
.globl vector32
vector32:
  pushl $0
80107de9:	6a 00                	push   $0x0
  pushl $32
80107deb:	6a 20                	push   $0x20
  jmp alltraps
80107ded:	e9 97 f8 ff ff       	jmp    80107689 <alltraps>

80107df2 <vector33>:
.globl vector33
vector33:
  pushl $0
80107df2:	6a 00                	push   $0x0
  pushl $33
80107df4:	6a 21                	push   $0x21
  jmp alltraps
80107df6:	e9 8e f8 ff ff       	jmp    80107689 <alltraps>

80107dfb <vector34>:
.globl vector34
vector34:
  pushl $0
80107dfb:	6a 00                	push   $0x0
  pushl $34
80107dfd:	6a 22                	push   $0x22
  jmp alltraps
80107dff:	e9 85 f8 ff ff       	jmp    80107689 <alltraps>

80107e04 <vector35>:
.globl vector35
vector35:
  pushl $0
80107e04:	6a 00                	push   $0x0
  pushl $35
80107e06:	6a 23                	push   $0x23
  jmp alltraps
80107e08:	e9 7c f8 ff ff       	jmp    80107689 <alltraps>

80107e0d <vector36>:
.globl vector36
vector36:
  pushl $0
80107e0d:	6a 00                	push   $0x0
  pushl $36
80107e0f:	6a 24                	push   $0x24
  jmp alltraps
80107e11:	e9 73 f8 ff ff       	jmp    80107689 <alltraps>

80107e16 <vector37>:
.globl vector37
vector37:
  pushl $0
80107e16:	6a 00                	push   $0x0
  pushl $37
80107e18:	6a 25                	push   $0x25
  jmp alltraps
80107e1a:	e9 6a f8 ff ff       	jmp    80107689 <alltraps>

80107e1f <vector38>:
.globl vector38
vector38:
  pushl $0
80107e1f:	6a 00                	push   $0x0
  pushl $38
80107e21:	6a 26                	push   $0x26
  jmp alltraps
80107e23:	e9 61 f8 ff ff       	jmp    80107689 <alltraps>

80107e28 <vector39>:
.globl vector39
vector39:
  pushl $0
80107e28:	6a 00                	push   $0x0
  pushl $39
80107e2a:	6a 27                	push   $0x27
  jmp alltraps
80107e2c:	e9 58 f8 ff ff       	jmp    80107689 <alltraps>

80107e31 <vector40>:
.globl vector40
vector40:
  pushl $0
80107e31:	6a 00                	push   $0x0
  pushl $40
80107e33:	6a 28                	push   $0x28
  jmp alltraps
80107e35:	e9 4f f8 ff ff       	jmp    80107689 <alltraps>

80107e3a <vector41>:
.globl vector41
vector41:
  pushl $0
80107e3a:	6a 00                	push   $0x0
  pushl $41
80107e3c:	6a 29                	push   $0x29
  jmp alltraps
80107e3e:	e9 46 f8 ff ff       	jmp    80107689 <alltraps>

80107e43 <vector42>:
.globl vector42
vector42:
  pushl $0
80107e43:	6a 00                	push   $0x0
  pushl $42
80107e45:	6a 2a                	push   $0x2a
  jmp alltraps
80107e47:	e9 3d f8 ff ff       	jmp    80107689 <alltraps>

80107e4c <vector43>:
.globl vector43
vector43:
  pushl $0
80107e4c:	6a 00                	push   $0x0
  pushl $43
80107e4e:	6a 2b                	push   $0x2b
  jmp alltraps
80107e50:	e9 34 f8 ff ff       	jmp    80107689 <alltraps>

80107e55 <vector44>:
.globl vector44
vector44:
  pushl $0
80107e55:	6a 00                	push   $0x0
  pushl $44
80107e57:	6a 2c                	push   $0x2c
  jmp alltraps
80107e59:	e9 2b f8 ff ff       	jmp    80107689 <alltraps>

80107e5e <vector45>:
.globl vector45
vector45:
  pushl $0
80107e5e:	6a 00                	push   $0x0
  pushl $45
80107e60:	6a 2d                	push   $0x2d
  jmp alltraps
80107e62:	e9 22 f8 ff ff       	jmp    80107689 <alltraps>

80107e67 <vector46>:
.globl vector46
vector46:
  pushl $0
80107e67:	6a 00                	push   $0x0
  pushl $46
80107e69:	6a 2e                	push   $0x2e
  jmp alltraps
80107e6b:	e9 19 f8 ff ff       	jmp    80107689 <alltraps>

80107e70 <vector47>:
.globl vector47
vector47:
  pushl $0
80107e70:	6a 00                	push   $0x0
  pushl $47
80107e72:	6a 2f                	push   $0x2f
  jmp alltraps
80107e74:	e9 10 f8 ff ff       	jmp    80107689 <alltraps>

80107e79 <vector48>:
.globl vector48
vector48:
  pushl $0
80107e79:	6a 00                	push   $0x0
  pushl $48
80107e7b:	6a 30                	push   $0x30
  jmp alltraps
80107e7d:	e9 07 f8 ff ff       	jmp    80107689 <alltraps>

80107e82 <vector49>:
.globl vector49
vector49:
  pushl $0
80107e82:	6a 00                	push   $0x0
  pushl $49
80107e84:	6a 31                	push   $0x31
  jmp alltraps
80107e86:	e9 fe f7 ff ff       	jmp    80107689 <alltraps>

80107e8b <vector50>:
.globl vector50
vector50:
  pushl $0
80107e8b:	6a 00                	push   $0x0
  pushl $50
80107e8d:	6a 32                	push   $0x32
  jmp alltraps
80107e8f:	e9 f5 f7 ff ff       	jmp    80107689 <alltraps>

80107e94 <vector51>:
.globl vector51
vector51:
  pushl $0
80107e94:	6a 00                	push   $0x0
  pushl $51
80107e96:	6a 33                	push   $0x33
  jmp alltraps
80107e98:	e9 ec f7 ff ff       	jmp    80107689 <alltraps>

80107e9d <vector52>:
.globl vector52
vector52:
  pushl $0
80107e9d:	6a 00                	push   $0x0
  pushl $52
80107e9f:	6a 34                	push   $0x34
  jmp alltraps
80107ea1:	e9 e3 f7 ff ff       	jmp    80107689 <alltraps>

80107ea6 <vector53>:
.globl vector53
vector53:
  pushl $0
80107ea6:	6a 00                	push   $0x0
  pushl $53
80107ea8:	6a 35                	push   $0x35
  jmp alltraps
80107eaa:	e9 da f7 ff ff       	jmp    80107689 <alltraps>

80107eaf <vector54>:
.globl vector54
vector54:
  pushl $0
80107eaf:	6a 00                	push   $0x0
  pushl $54
80107eb1:	6a 36                	push   $0x36
  jmp alltraps
80107eb3:	e9 d1 f7 ff ff       	jmp    80107689 <alltraps>

80107eb8 <vector55>:
.globl vector55
vector55:
  pushl $0
80107eb8:	6a 00                	push   $0x0
  pushl $55
80107eba:	6a 37                	push   $0x37
  jmp alltraps
80107ebc:	e9 c8 f7 ff ff       	jmp    80107689 <alltraps>

80107ec1 <vector56>:
.globl vector56
vector56:
  pushl $0
80107ec1:	6a 00                	push   $0x0
  pushl $56
80107ec3:	6a 38                	push   $0x38
  jmp alltraps
80107ec5:	e9 bf f7 ff ff       	jmp    80107689 <alltraps>

80107eca <vector57>:
.globl vector57
vector57:
  pushl $0
80107eca:	6a 00                	push   $0x0
  pushl $57
80107ecc:	6a 39                	push   $0x39
  jmp alltraps
80107ece:	e9 b6 f7 ff ff       	jmp    80107689 <alltraps>

80107ed3 <vector58>:
.globl vector58
vector58:
  pushl $0
80107ed3:	6a 00                	push   $0x0
  pushl $58
80107ed5:	6a 3a                	push   $0x3a
  jmp alltraps
80107ed7:	e9 ad f7 ff ff       	jmp    80107689 <alltraps>

80107edc <vector59>:
.globl vector59
vector59:
  pushl $0
80107edc:	6a 00                	push   $0x0
  pushl $59
80107ede:	6a 3b                	push   $0x3b
  jmp alltraps
80107ee0:	e9 a4 f7 ff ff       	jmp    80107689 <alltraps>

80107ee5 <vector60>:
.globl vector60
vector60:
  pushl $0
80107ee5:	6a 00                	push   $0x0
  pushl $60
80107ee7:	6a 3c                	push   $0x3c
  jmp alltraps
80107ee9:	e9 9b f7 ff ff       	jmp    80107689 <alltraps>

80107eee <vector61>:
.globl vector61
vector61:
  pushl $0
80107eee:	6a 00                	push   $0x0
  pushl $61
80107ef0:	6a 3d                	push   $0x3d
  jmp alltraps
80107ef2:	e9 92 f7 ff ff       	jmp    80107689 <alltraps>

80107ef7 <vector62>:
.globl vector62
vector62:
  pushl $0
80107ef7:	6a 00                	push   $0x0
  pushl $62
80107ef9:	6a 3e                	push   $0x3e
  jmp alltraps
80107efb:	e9 89 f7 ff ff       	jmp    80107689 <alltraps>

80107f00 <vector63>:
.globl vector63
vector63:
  pushl $0
80107f00:	6a 00                	push   $0x0
  pushl $63
80107f02:	6a 3f                	push   $0x3f
  jmp alltraps
80107f04:	e9 80 f7 ff ff       	jmp    80107689 <alltraps>

80107f09 <vector64>:
.globl vector64
vector64:
  pushl $0
80107f09:	6a 00                	push   $0x0
  pushl $64
80107f0b:	6a 40                	push   $0x40
  jmp alltraps
80107f0d:	e9 77 f7 ff ff       	jmp    80107689 <alltraps>

80107f12 <vector65>:
.globl vector65
vector65:
  pushl $0
80107f12:	6a 00                	push   $0x0
  pushl $65
80107f14:	6a 41                	push   $0x41
  jmp alltraps
80107f16:	e9 6e f7 ff ff       	jmp    80107689 <alltraps>

80107f1b <vector66>:
.globl vector66
vector66:
  pushl $0
80107f1b:	6a 00                	push   $0x0
  pushl $66
80107f1d:	6a 42                	push   $0x42
  jmp alltraps
80107f1f:	e9 65 f7 ff ff       	jmp    80107689 <alltraps>

80107f24 <vector67>:
.globl vector67
vector67:
  pushl $0
80107f24:	6a 00                	push   $0x0
  pushl $67
80107f26:	6a 43                	push   $0x43
  jmp alltraps
80107f28:	e9 5c f7 ff ff       	jmp    80107689 <alltraps>

80107f2d <vector68>:
.globl vector68
vector68:
  pushl $0
80107f2d:	6a 00                	push   $0x0
  pushl $68
80107f2f:	6a 44                	push   $0x44
  jmp alltraps
80107f31:	e9 53 f7 ff ff       	jmp    80107689 <alltraps>

80107f36 <vector69>:
.globl vector69
vector69:
  pushl $0
80107f36:	6a 00                	push   $0x0
  pushl $69
80107f38:	6a 45                	push   $0x45
  jmp alltraps
80107f3a:	e9 4a f7 ff ff       	jmp    80107689 <alltraps>

80107f3f <vector70>:
.globl vector70
vector70:
  pushl $0
80107f3f:	6a 00                	push   $0x0
  pushl $70
80107f41:	6a 46                	push   $0x46
  jmp alltraps
80107f43:	e9 41 f7 ff ff       	jmp    80107689 <alltraps>

80107f48 <vector71>:
.globl vector71
vector71:
  pushl $0
80107f48:	6a 00                	push   $0x0
  pushl $71
80107f4a:	6a 47                	push   $0x47
  jmp alltraps
80107f4c:	e9 38 f7 ff ff       	jmp    80107689 <alltraps>

80107f51 <vector72>:
.globl vector72
vector72:
  pushl $0
80107f51:	6a 00                	push   $0x0
  pushl $72
80107f53:	6a 48                	push   $0x48
  jmp alltraps
80107f55:	e9 2f f7 ff ff       	jmp    80107689 <alltraps>

80107f5a <vector73>:
.globl vector73
vector73:
  pushl $0
80107f5a:	6a 00                	push   $0x0
  pushl $73
80107f5c:	6a 49                	push   $0x49
  jmp alltraps
80107f5e:	e9 26 f7 ff ff       	jmp    80107689 <alltraps>

80107f63 <vector74>:
.globl vector74
vector74:
  pushl $0
80107f63:	6a 00                	push   $0x0
  pushl $74
80107f65:	6a 4a                	push   $0x4a
  jmp alltraps
80107f67:	e9 1d f7 ff ff       	jmp    80107689 <alltraps>

80107f6c <vector75>:
.globl vector75
vector75:
  pushl $0
80107f6c:	6a 00                	push   $0x0
  pushl $75
80107f6e:	6a 4b                	push   $0x4b
  jmp alltraps
80107f70:	e9 14 f7 ff ff       	jmp    80107689 <alltraps>

80107f75 <vector76>:
.globl vector76
vector76:
  pushl $0
80107f75:	6a 00                	push   $0x0
  pushl $76
80107f77:	6a 4c                	push   $0x4c
  jmp alltraps
80107f79:	e9 0b f7 ff ff       	jmp    80107689 <alltraps>

80107f7e <vector77>:
.globl vector77
vector77:
  pushl $0
80107f7e:	6a 00                	push   $0x0
  pushl $77
80107f80:	6a 4d                	push   $0x4d
  jmp alltraps
80107f82:	e9 02 f7 ff ff       	jmp    80107689 <alltraps>

80107f87 <vector78>:
.globl vector78
vector78:
  pushl $0
80107f87:	6a 00                	push   $0x0
  pushl $78
80107f89:	6a 4e                	push   $0x4e
  jmp alltraps
80107f8b:	e9 f9 f6 ff ff       	jmp    80107689 <alltraps>

80107f90 <vector79>:
.globl vector79
vector79:
  pushl $0
80107f90:	6a 00                	push   $0x0
  pushl $79
80107f92:	6a 4f                	push   $0x4f
  jmp alltraps
80107f94:	e9 f0 f6 ff ff       	jmp    80107689 <alltraps>

80107f99 <vector80>:
.globl vector80
vector80:
  pushl $0
80107f99:	6a 00                	push   $0x0
  pushl $80
80107f9b:	6a 50                	push   $0x50
  jmp alltraps
80107f9d:	e9 e7 f6 ff ff       	jmp    80107689 <alltraps>

80107fa2 <vector81>:
.globl vector81
vector81:
  pushl $0
80107fa2:	6a 00                	push   $0x0
  pushl $81
80107fa4:	6a 51                	push   $0x51
  jmp alltraps
80107fa6:	e9 de f6 ff ff       	jmp    80107689 <alltraps>

80107fab <vector82>:
.globl vector82
vector82:
  pushl $0
80107fab:	6a 00                	push   $0x0
  pushl $82
80107fad:	6a 52                	push   $0x52
  jmp alltraps
80107faf:	e9 d5 f6 ff ff       	jmp    80107689 <alltraps>

80107fb4 <vector83>:
.globl vector83
vector83:
  pushl $0
80107fb4:	6a 00                	push   $0x0
  pushl $83
80107fb6:	6a 53                	push   $0x53
  jmp alltraps
80107fb8:	e9 cc f6 ff ff       	jmp    80107689 <alltraps>

80107fbd <vector84>:
.globl vector84
vector84:
  pushl $0
80107fbd:	6a 00                	push   $0x0
  pushl $84
80107fbf:	6a 54                	push   $0x54
  jmp alltraps
80107fc1:	e9 c3 f6 ff ff       	jmp    80107689 <alltraps>

80107fc6 <vector85>:
.globl vector85
vector85:
  pushl $0
80107fc6:	6a 00                	push   $0x0
  pushl $85
80107fc8:	6a 55                	push   $0x55
  jmp alltraps
80107fca:	e9 ba f6 ff ff       	jmp    80107689 <alltraps>

80107fcf <vector86>:
.globl vector86
vector86:
  pushl $0
80107fcf:	6a 00                	push   $0x0
  pushl $86
80107fd1:	6a 56                	push   $0x56
  jmp alltraps
80107fd3:	e9 b1 f6 ff ff       	jmp    80107689 <alltraps>

80107fd8 <vector87>:
.globl vector87
vector87:
  pushl $0
80107fd8:	6a 00                	push   $0x0
  pushl $87
80107fda:	6a 57                	push   $0x57
  jmp alltraps
80107fdc:	e9 a8 f6 ff ff       	jmp    80107689 <alltraps>

80107fe1 <vector88>:
.globl vector88
vector88:
  pushl $0
80107fe1:	6a 00                	push   $0x0
  pushl $88
80107fe3:	6a 58                	push   $0x58
  jmp alltraps
80107fe5:	e9 9f f6 ff ff       	jmp    80107689 <alltraps>

80107fea <vector89>:
.globl vector89
vector89:
  pushl $0
80107fea:	6a 00                	push   $0x0
  pushl $89
80107fec:	6a 59                	push   $0x59
  jmp alltraps
80107fee:	e9 96 f6 ff ff       	jmp    80107689 <alltraps>

80107ff3 <vector90>:
.globl vector90
vector90:
  pushl $0
80107ff3:	6a 00                	push   $0x0
  pushl $90
80107ff5:	6a 5a                	push   $0x5a
  jmp alltraps
80107ff7:	e9 8d f6 ff ff       	jmp    80107689 <alltraps>

80107ffc <vector91>:
.globl vector91
vector91:
  pushl $0
80107ffc:	6a 00                	push   $0x0
  pushl $91
80107ffe:	6a 5b                	push   $0x5b
  jmp alltraps
80108000:	e9 84 f6 ff ff       	jmp    80107689 <alltraps>

80108005 <vector92>:
.globl vector92
vector92:
  pushl $0
80108005:	6a 00                	push   $0x0
  pushl $92
80108007:	6a 5c                	push   $0x5c
  jmp alltraps
80108009:	e9 7b f6 ff ff       	jmp    80107689 <alltraps>

8010800e <vector93>:
.globl vector93
vector93:
  pushl $0
8010800e:	6a 00                	push   $0x0
  pushl $93
80108010:	6a 5d                	push   $0x5d
  jmp alltraps
80108012:	e9 72 f6 ff ff       	jmp    80107689 <alltraps>

80108017 <vector94>:
.globl vector94
vector94:
  pushl $0
80108017:	6a 00                	push   $0x0
  pushl $94
80108019:	6a 5e                	push   $0x5e
  jmp alltraps
8010801b:	e9 69 f6 ff ff       	jmp    80107689 <alltraps>

80108020 <vector95>:
.globl vector95
vector95:
  pushl $0
80108020:	6a 00                	push   $0x0
  pushl $95
80108022:	6a 5f                	push   $0x5f
  jmp alltraps
80108024:	e9 60 f6 ff ff       	jmp    80107689 <alltraps>

80108029 <vector96>:
.globl vector96
vector96:
  pushl $0
80108029:	6a 00                	push   $0x0
  pushl $96
8010802b:	6a 60                	push   $0x60
  jmp alltraps
8010802d:	e9 57 f6 ff ff       	jmp    80107689 <alltraps>

80108032 <vector97>:
.globl vector97
vector97:
  pushl $0
80108032:	6a 00                	push   $0x0
  pushl $97
80108034:	6a 61                	push   $0x61
  jmp alltraps
80108036:	e9 4e f6 ff ff       	jmp    80107689 <alltraps>

8010803b <vector98>:
.globl vector98
vector98:
  pushl $0
8010803b:	6a 00                	push   $0x0
  pushl $98
8010803d:	6a 62                	push   $0x62
  jmp alltraps
8010803f:	e9 45 f6 ff ff       	jmp    80107689 <alltraps>

80108044 <vector99>:
.globl vector99
vector99:
  pushl $0
80108044:	6a 00                	push   $0x0
  pushl $99
80108046:	6a 63                	push   $0x63
  jmp alltraps
80108048:	e9 3c f6 ff ff       	jmp    80107689 <alltraps>

8010804d <vector100>:
.globl vector100
vector100:
  pushl $0
8010804d:	6a 00                	push   $0x0
  pushl $100
8010804f:	6a 64                	push   $0x64
  jmp alltraps
80108051:	e9 33 f6 ff ff       	jmp    80107689 <alltraps>

80108056 <vector101>:
.globl vector101
vector101:
  pushl $0
80108056:	6a 00                	push   $0x0
  pushl $101
80108058:	6a 65                	push   $0x65
  jmp alltraps
8010805a:	e9 2a f6 ff ff       	jmp    80107689 <alltraps>

8010805f <vector102>:
.globl vector102
vector102:
  pushl $0
8010805f:	6a 00                	push   $0x0
  pushl $102
80108061:	6a 66                	push   $0x66
  jmp alltraps
80108063:	e9 21 f6 ff ff       	jmp    80107689 <alltraps>

80108068 <vector103>:
.globl vector103
vector103:
  pushl $0
80108068:	6a 00                	push   $0x0
  pushl $103
8010806a:	6a 67                	push   $0x67
  jmp alltraps
8010806c:	e9 18 f6 ff ff       	jmp    80107689 <alltraps>

80108071 <vector104>:
.globl vector104
vector104:
  pushl $0
80108071:	6a 00                	push   $0x0
  pushl $104
80108073:	6a 68                	push   $0x68
  jmp alltraps
80108075:	e9 0f f6 ff ff       	jmp    80107689 <alltraps>

8010807a <vector105>:
.globl vector105
vector105:
  pushl $0
8010807a:	6a 00                	push   $0x0
  pushl $105
8010807c:	6a 69                	push   $0x69
  jmp alltraps
8010807e:	e9 06 f6 ff ff       	jmp    80107689 <alltraps>

80108083 <vector106>:
.globl vector106
vector106:
  pushl $0
80108083:	6a 00                	push   $0x0
  pushl $106
80108085:	6a 6a                	push   $0x6a
  jmp alltraps
80108087:	e9 fd f5 ff ff       	jmp    80107689 <alltraps>

8010808c <vector107>:
.globl vector107
vector107:
  pushl $0
8010808c:	6a 00                	push   $0x0
  pushl $107
8010808e:	6a 6b                	push   $0x6b
  jmp alltraps
80108090:	e9 f4 f5 ff ff       	jmp    80107689 <alltraps>

80108095 <vector108>:
.globl vector108
vector108:
  pushl $0
80108095:	6a 00                	push   $0x0
  pushl $108
80108097:	6a 6c                	push   $0x6c
  jmp alltraps
80108099:	e9 eb f5 ff ff       	jmp    80107689 <alltraps>

8010809e <vector109>:
.globl vector109
vector109:
  pushl $0
8010809e:	6a 00                	push   $0x0
  pushl $109
801080a0:	6a 6d                	push   $0x6d
  jmp alltraps
801080a2:	e9 e2 f5 ff ff       	jmp    80107689 <alltraps>

801080a7 <vector110>:
.globl vector110
vector110:
  pushl $0
801080a7:	6a 00                	push   $0x0
  pushl $110
801080a9:	6a 6e                	push   $0x6e
  jmp alltraps
801080ab:	e9 d9 f5 ff ff       	jmp    80107689 <alltraps>

801080b0 <vector111>:
.globl vector111
vector111:
  pushl $0
801080b0:	6a 00                	push   $0x0
  pushl $111
801080b2:	6a 6f                	push   $0x6f
  jmp alltraps
801080b4:	e9 d0 f5 ff ff       	jmp    80107689 <alltraps>

801080b9 <vector112>:
.globl vector112
vector112:
  pushl $0
801080b9:	6a 00                	push   $0x0
  pushl $112
801080bb:	6a 70                	push   $0x70
  jmp alltraps
801080bd:	e9 c7 f5 ff ff       	jmp    80107689 <alltraps>

801080c2 <vector113>:
.globl vector113
vector113:
  pushl $0
801080c2:	6a 00                	push   $0x0
  pushl $113
801080c4:	6a 71                	push   $0x71
  jmp alltraps
801080c6:	e9 be f5 ff ff       	jmp    80107689 <alltraps>

801080cb <vector114>:
.globl vector114
vector114:
  pushl $0
801080cb:	6a 00                	push   $0x0
  pushl $114
801080cd:	6a 72                	push   $0x72
  jmp alltraps
801080cf:	e9 b5 f5 ff ff       	jmp    80107689 <alltraps>

801080d4 <vector115>:
.globl vector115
vector115:
  pushl $0
801080d4:	6a 00                	push   $0x0
  pushl $115
801080d6:	6a 73                	push   $0x73
  jmp alltraps
801080d8:	e9 ac f5 ff ff       	jmp    80107689 <alltraps>

801080dd <vector116>:
.globl vector116
vector116:
  pushl $0
801080dd:	6a 00                	push   $0x0
  pushl $116
801080df:	6a 74                	push   $0x74
  jmp alltraps
801080e1:	e9 a3 f5 ff ff       	jmp    80107689 <alltraps>

801080e6 <vector117>:
.globl vector117
vector117:
  pushl $0
801080e6:	6a 00                	push   $0x0
  pushl $117
801080e8:	6a 75                	push   $0x75
  jmp alltraps
801080ea:	e9 9a f5 ff ff       	jmp    80107689 <alltraps>

801080ef <vector118>:
.globl vector118
vector118:
  pushl $0
801080ef:	6a 00                	push   $0x0
  pushl $118
801080f1:	6a 76                	push   $0x76
  jmp alltraps
801080f3:	e9 91 f5 ff ff       	jmp    80107689 <alltraps>

801080f8 <vector119>:
.globl vector119
vector119:
  pushl $0
801080f8:	6a 00                	push   $0x0
  pushl $119
801080fa:	6a 77                	push   $0x77
  jmp alltraps
801080fc:	e9 88 f5 ff ff       	jmp    80107689 <alltraps>

80108101 <vector120>:
.globl vector120
vector120:
  pushl $0
80108101:	6a 00                	push   $0x0
  pushl $120
80108103:	6a 78                	push   $0x78
  jmp alltraps
80108105:	e9 7f f5 ff ff       	jmp    80107689 <alltraps>

8010810a <vector121>:
.globl vector121
vector121:
  pushl $0
8010810a:	6a 00                	push   $0x0
  pushl $121
8010810c:	6a 79                	push   $0x79
  jmp alltraps
8010810e:	e9 76 f5 ff ff       	jmp    80107689 <alltraps>

80108113 <vector122>:
.globl vector122
vector122:
  pushl $0
80108113:	6a 00                	push   $0x0
  pushl $122
80108115:	6a 7a                	push   $0x7a
  jmp alltraps
80108117:	e9 6d f5 ff ff       	jmp    80107689 <alltraps>

8010811c <vector123>:
.globl vector123
vector123:
  pushl $0
8010811c:	6a 00                	push   $0x0
  pushl $123
8010811e:	6a 7b                	push   $0x7b
  jmp alltraps
80108120:	e9 64 f5 ff ff       	jmp    80107689 <alltraps>

80108125 <vector124>:
.globl vector124
vector124:
  pushl $0
80108125:	6a 00                	push   $0x0
  pushl $124
80108127:	6a 7c                	push   $0x7c
  jmp alltraps
80108129:	e9 5b f5 ff ff       	jmp    80107689 <alltraps>

8010812e <vector125>:
.globl vector125
vector125:
  pushl $0
8010812e:	6a 00                	push   $0x0
  pushl $125
80108130:	6a 7d                	push   $0x7d
  jmp alltraps
80108132:	e9 52 f5 ff ff       	jmp    80107689 <alltraps>

80108137 <vector126>:
.globl vector126
vector126:
  pushl $0
80108137:	6a 00                	push   $0x0
  pushl $126
80108139:	6a 7e                	push   $0x7e
  jmp alltraps
8010813b:	e9 49 f5 ff ff       	jmp    80107689 <alltraps>

80108140 <vector127>:
.globl vector127
vector127:
  pushl $0
80108140:	6a 00                	push   $0x0
  pushl $127
80108142:	6a 7f                	push   $0x7f
  jmp alltraps
80108144:	e9 40 f5 ff ff       	jmp    80107689 <alltraps>

80108149 <vector128>:
.globl vector128
vector128:
  pushl $0
80108149:	6a 00                	push   $0x0
  pushl $128
8010814b:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80108150:	e9 34 f5 ff ff       	jmp    80107689 <alltraps>

80108155 <vector129>:
.globl vector129
vector129:
  pushl $0
80108155:	6a 00                	push   $0x0
  pushl $129
80108157:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010815c:	e9 28 f5 ff ff       	jmp    80107689 <alltraps>

80108161 <vector130>:
.globl vector130
vector130:
  pushl $0
80108161:	6a 00                	push   $0x0
  pushl $130
80108163:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80108168:	e9 1c f5 ff ff       	jmp    80107689 <alltraps>

8010816d <vector131>:
.globl vector131
vector131:
  pushl $0
8010816d:	6a 00                	push   $0x0
  pushl $131
8010816f:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80108174:	e9 10 f5 ff ff       	jmp    80107689 <alltraps>

80108179 <vector132>:
.globl vector132
vector132:
  pushl $0
80108179:	6a 00                	push   $0x0
  pushl $132
8010817b:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80108180:	e9 04 f5 ff ff       	jmp    80107689 <alltraps>

80108185 <vector133>:
.globl vector133
vector133:
  pushl $0
80108185:	6a 00                	push   $0x0
  pushl $133
80108187:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010818c:	e9 f8 f4 ff ff       	jmp    80107689 <alltraps>

80108191 <vector134>:
.globl vector134
vector134:
  pushl $0
80108191:	6a 00                	push   $0x0
  pushl $134
80108193:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80108198:	e9 ec f4 ff ff       	jmp    80107689 <alltraps>

8010819d <vector135>:
.globl vector135
vector135:
  pushl $0
8010819d:	6a 00                	push   $0x0
  pushl $135
8010819f:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801081a4:	e9 e0 f4 ff ff       	jmp    80107689 <alltraps>

801081a9 <vector136>:
.globl vector136
vector136:
  pushl $0
801081a9:	6a 00                	push   $0x0
  pushl $136
801081ab:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801081b0:	e9 d4 f4 ff ff       	jmp    80107689 <alltraps>

801081b5 <vector137>:
.globl vector137
vector137:
  pushl $0
801081b5:	6a 00                	push   $0x0
  pushl $137
801081b7:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801081bc:	e9 c8 f4 ff ff       	jmp    80107689 <alltraps>

801081c1 <vector138>:
.globl vector138
vector138:
  pushl $0
801081c1:	6a 00                	push   $0x0
  pushl $138
801081c3:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801081c8:	e9 bc f4 ff ff       	jmp    80107689 <alltraps>

801081cd <vector139>:
.globl vector139
vector139:
  pushl $0
801081cd:	6a 00                	push   $0x0
  pushl $139
801081cf:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801081d4:	e9 b0 f4 ff ff       	jmp    80107689 <alltraps>

801081d9 <vector140>:
.globl vector140
vector140:
  pushl $0
801081d9:	6a 00                	push   $0x0
  pushl $140
801081db:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801081e0:	e9 a4 f4 ff ff       	jmp    80107689 <alltraps>

801081e5 <vector141>:
.globl vector141
vector141:
  pushl $0
801081e5:	6a 00                	push   $0x0
  pushl $141
801081e7:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801081ec:	e9 98 f4 ff ff       	jmp    80107689 <alltraps>

801081f1 <vector142>:
.globl vector142
vector142:
  pushl $0
801081f1:	6a 00                	push   $0x0
  pushl $142
801081f3:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801081f8:	e9 8c f4 ff ff       	jmp    80107689 <alltraps>

801081fd <vector143>:
.globl vector143
vector143:
  pushl $0
801081fd:	6a 00                	push   $0x0
  pushl $143
801081ff:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80108204:	e9 80 f4 ff ff       	jmp    80107689 <alltraps>

80108209 <vector144>:
.globl vector144
vector144:
  pushl $0
80108209:	6a 00                	push   $0x0
  pushl $144
8010820b:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80108210:	e9 74 f4 ff ff       	jmp    80107689 <alltraps>

80108215 <vector145>:
.globl vector145
vector145:
  pushl $0
80108215:	6a 00                	push   $0x0
  pushl $145
80108217:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010821c:	e9 68 f4 ff ff       	jmp    80107689 <alltraps>

80108221 <vector146>:
.globl vector146
vector146:
  pushl $0
80108221:	6a 00                	push   $0x0
  pushl $146
80108223:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80108228:	e9 5c f4 ff ff       	jmp    80107689 <alltraps>

8010822d <vector147>:
.globl vector147
vector147:
  pushl $0
8010822d:	6a 00                	push   $0x0
  pushl $147
8010822f:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80108234:	e9 50 f4 ff ff       	jmp    80107689 <alltraps>

80108239 <vector148>:
.globl vector148
vector148:
  pushl $0
80108239:	6a 00                	push   $0x0
  pushl $148
8010823b:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80108240:	e9 44 f4 ff ff       	jmp    80107689 <alltraps>

80108245 <vector149>:
.globl vector149
vector149:
  pushl $0
80108245:	6a 00                	push   $0x0
  pushl $149
80108247:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010824c:	e9 38 f4 ff ff       	jmp    80107689 <alltraps>

80108251 <vector150>:
.globl vector150
vector150:
  pushl $0
80108251:	6a 00                	push   $0x0
  pushl $150
80108253:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80108258:	e9 2c f4 ff ff       	jmp    80107689 <alltraps>

8010825d <vector151>:
.globl vector151
vector151:
  pushl $0
8010825d:	6a 00                	push   $0x0
  pushl $151
8010825f:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80108264:	e9 20 f4 ff ff       	jmp    80107689 <alltraps>

80108269 <vector152>:
.globl vector152
vector152:
  pushl $0
80108269:	6a 00                	push   $0x0
  pushl $152
8010826b:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80108270:	e9 14 f4 ff ff       	jmp    80107689 <alltraps>

80108275 <vector153>:
.globl vector153
vector153:
  pushl $0
80108275:	6a 00                	push   $0x0
  pushl $153
80108277:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010827c:	e9 08 f4 ff ff       	jmp    80107689 <alltraps>

80108281 <vector154>:
.globl vector154
vector154:
  pushl $0
80108281:	6a 00                	push   $0x0
  pushl $154
80108283:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80108288:	e9 fc f3 ff ff       	jmp    80107689 <alltraps>

8010828d <vector155>:
.globl vector155
vector155:
  pushl $0
8010828d:	6a 00                	push   $0x0
  pushl $155
8010828f:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80108294:	e9 f0 f3 ff ff       	jmp    80107689 <alltraps>

80108299 <vector156>:
.globl vector156
vector156:
  pushl $0
80108299:	6a 00                	push   $0x0
  pushl $156
8010829b:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801082a0:	e9 e4 f3 ff ff       	jmp    80107689 <alltraps>

801082a5 <vector157>:
.globl vector157
vector157:
  pushl $0
801082a5:	6a 00                	push   $0x0
  pushl $157
801082a7:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801082ac:	e9 d8 f3 ff ff       	jmp    80107689 <alltraps>

801082b1 <vector158>:
.globl vector158
vector158:
  pushl $0
801082b1:	6a 00                	push   $0x0
  pushl $158
801082b3:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801082b8:	e9 cc f3 ff ff       	jmp    80107689 <alltraps>

801082bd <vector159>:
.globl vector159
vector159:
  pushl $0
801082bd:	6a 00                	push   $0x0
  pushl $159
801082bf:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801082c4:	e9 c0 f3 ff ff       	jmp    80107689 <alltraps>

801082c9 <vector160>:
.globl vector160
vector160:
  pushl $0
801082c9:	6a 00                	push   $0x0
  pushl $160
801082cb:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801082d0:	e9 b4 f3 ff ff       	jmp    80107689 <alltraps>

801082d5 <vector161>:
.globl vector161
vector161:
  pushl $0
801082d5:	6a 00                	push   $0x0
  pushl $161
801082d7:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801082dc:	e9 a8 f3 ff ff       	jmp    80107689 <alltraps>

801082e1 <vector162>:
.globl vector162
vector162:
  pushl $0
801082e1:	6a 00                	push   $0x0
  pushl $162
801082e3:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801082e8:	e9 9c f3 ff ff       	jmp    80107689 <alltraps>

801082ed <vector163>:
.globl vector163
vector163:
  pushl $0
801082ed:	6a 00                	push   $0x0
  pushl $163
801082ef:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801082f4:	e9 90 f3 ff ff       	jmp    80107689 <alltraps>

801082f9 <vector164>:
.globl vector164
vector164:
  pushl $0
801082f9:	6a 00                	push   $0x0
  pushl $164
801082fb:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80108300:	e9 84 f3 ff ff       	jmp    80107689 <alltraps>

80108305 <vector165>:
.globl vector165
vector165:
  pushl $0
80108305:	6a 00                	push   $0x0
  pushl $165
80108307:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010830c:	e9 78 f3 ff ff       	jmp    80107689 <alltraps>

80108311 <vector166>:
.globl vector166
vector166:
  pushl $0
80108311:	6a 00                	push   $0x0
  pushl $166
80108313:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80108318:	e9 6c f3 ff ff       	jmp    80107689 <alltraps>

8010831d <vector167>:
.globl vector167
vector167:
  pushl $0
8010831d:	6a 00                	push   $0x0
  pushl $167
8010831f:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80108324:	e9 60 f3 ff ff       	jmp    80107689 <alltraps>

80108329 <vector168>:
.globl vector168
vector168:
  pushl $0
80108329:	6a 00                	push   $0x0
  pushl $168
8010832b:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80108330:	e9 54 f3 ff ff       	jmp    80107689 <alltraps>

80108335 <vector169>:
.globl vector169
vector169:
  pushl $0
80108335:	6a 00                	push   $0x0
  pushl $169
80108337:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010833c:	e9 48 f3 ff ff       	jmp    80107689 <alltraps>

80108341 <vector170>:
.globl vector170
vector170:
  pushl $0
80108341:	6a 00                	push   $0x0
  pushl $170
80108343:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80108348:	e9 3c f3 ff ff       	jmp    80107689 <alltraps>

8010834d <vector171>:
.globl vector171
vector171:
  pushl $0
8010834d:	6a 00                	push   $0x0
  pushl $171
8010834f:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80108354:	e9 30 f3 ff ff       	jmp    80107689 <alltraps>

80108359 <vector172>:
.globl vector172
vector172:
  pushl $0
80108359:	6a 00                	push   $0x0
  pushl $172
8010835b:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80108360:	e9 24 f3 ff ff       	jmp    80107689 <alltraps>

80108365 <vector173>:
.globl vector173
vector173:
  pushl $0
80108365:	6a 00                	push   $0x0
  pushl $173
80108367:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010836c:	e9 18 f3 ff ff       	jmp    80107689 <alltraps>

80108371 <vector174>:
.globl vector174
vector174:
  pushl $0
80108371:	6a 00                	push   $0x0
  pushl $174
80108373:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80108378:	e9 0c f3 ff ff       	jmp    80107689 <alltraps>

8010837d <vector175>:
.globl vector175
vector175:
  pushl $0
8010837d:	6a 00                	push   $0x0
  pushl $175
8010837f:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80108384:	e9 00 f3 ff ff       	jmp    80107689 <alltraps>

80108389 <vector176>:
.globl vector176
vector176:
  pushl $0
80108389:	6a 00                	push   $0x0
  pushl $176
8010838b:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80108390:	e9 f4 f2 ff ff       	jmp    80107689 <alltraps>

80108395 <vector177>:
.globl vector177
vector177:
  pushl $0
80108395:	6a 00                	push   $0x0
  pushl $177
80108397:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010839c:	e9 e8 f2 ff ff       	jmp    80107689 <alltraps>

801083a1 <vector178>:
.globl vector178
vector178:
  pushl $0
801083a1:	6a 00                	push   $0x0
  pushl $178
801083a3:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801083a8:	e9 dc f2 ff ff       	jmp    80107689 <alltraps>

801083ad <vector179>:
.globl vector179
vector179:
  pushl $0
801083ad:	6a 00                	push   $0x0
  pushl $179
801083af:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801083b4:	e9 d0 f2 ff ff       	jmp    80107689 <alltraps>

801083b9 <vector180>:
.globl vector180
vector180:
  pushl $0
801083b9:	6a 00                	push   $0x0
  pushl $180
801083bb:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801083c0:	e9 c4 f2 ff ff       	jmp    80107689 <alltraps>

801083c5 <vector181>:
.globl vector181
vector181:
  pushl $0
801083c5:	6a 00                	push   $0x0
  pushl $181
801083c7:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801083cc:	e9 b8 f2 ff ff       	jmp    80107689 <alltraps>

801083d1 <vector182>:
.globl vector182
vector182:
  pushl $0
801083d1:	6a 00                	push   $0x0
  pushl $182
801083d3:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801083d8:	e9 ac f2 ff ff       	jmp    80107689 <alltraps>

801083dd <vector183>:
.globl vector183
vector183:
  pushl $0
801083dd:	6a 00                	push   $0x0
  pushl $183
801083df:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801083e4:	e9 a0 f2 ff ff       	jmp    80107689 <alltraps>

801083e9 <vector184>:
.globl vector184
vector184:
  pushl $0
801083e9:	6a 00                	push   $0x0
  pushl $184
801083eb:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801083f0:	e9 94 f2 ff ff       	jmp    80107689 <alltraps>

801083f5 <vector185>:
.globl vector185
vector185:
  pushl $0
801083f5:	6a 00                	push   $0x0
  pushl $185
801083f7:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801083fc:	e9 88 f2 ff ff       	jmp    80107689 <alltraps>

80108401 <vector186>:
.globl vector186
vector186:
  pushl $0
80108401:	6a 00                	push   $0x0
  pushl $186
80108403:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80108408:	e9 7c f2 ff ff       	jmp    80107689 <alltraps>

8010840d <vector187>:
.globl vector187
vector187:
  pushl $0
8010840d:	6a 00                	push   $0x0
  pushl $187
8010840f:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80108414:	e9 70 f2 ff ff       	jmp    80107689 <alltraps>

80108419 <vector188>:
.globl vector188
vector188:
  pushl $0
80108419:	6a 00                	push   $0x0
  pushl $188
8010841b:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80108420:	e9 64 f2 ff ff       	jmp    80107689 <alltraps>

80108425 <vector189>:
.globl vector189
vector189:
  pushl $0
80108425:	6a 00                	push   $0x0
  pushl $189
80108427:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010842c:	e9 58 f2 ff ff       	jmp    80107689 <alltraps>

80108431 <vector190>:
.globl vector190
vector190:
  pushl $0
80108431:	6a 00                	push   $0x0
  pushl $190
80108433:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80108438:	e9 4c f2 ff ff       	jmp    80107689 <alltraps>

8010843d <vector191>:
.globl vector191
vector191:
  pushl $0
8010843d:	6a 00                	push   $0x0
  pushl $191
8010843f:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80108444:	e9 40 f2 ff ff       	jmp    80107689 <alltraps>

80108449 <vector192>:
.globl vector192
vector192:
  pushl $0
80108449:	6a 00                	push   $0x0
  pushl $192
8010844b:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80108450:	e9 34 f2 ff ff       	jmp    80107689 <alltraps>

80108455 <vector193>:
.globl vector193
vector193:
  pushl $0
80108455:	6a 00                	push   $0x0
  pushl $193
80108457:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010845c:	e9 28 f2 ff ff       	jmp    80107689 <alltraps>

80108461 <vector194>:
.globl vector194
vector194:
  pushl $0
80108461:	6a 00                	push   $0x0
  pushl $194
80108463:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80108468:	e9 1c f2 ff ff       	jmp    80107689 <alltraps>

8010846d <vector195>:
.globl vector195
vector195:
  pushl $0
8010846d:	6a 00                	push   $0x0
  pushl $195
8010846f:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80108474:	e9 10 f2 ff ff       	jmp    80107689 <alltraps>

80108479 <vector196>:
.globl vector196
vector196:
  pushl $0
80108479:	6a 00                	push   $0x0
  pushl $196
8010847b:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80108480:	e9 04 f2 ff ff       	jmp    80107689 <alltraps>

80108485 <vector197>:
.globl vector197
vector197:
  pushl $0
80108485:	6a 00                	push   $0x0
  pushl $197
80108487:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010848c:	e9 f8 f1 ff ff       	jmp    80107689 <alltraps>

80108491 <vector198>:
.globl vector198
vector198:
  pushl $0
80108491:	6a 00                	push   $0x0
  pushl $198
80108493:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80108498:	e9 ec f1 ff ff       	jmp    80107689 <alltraps>

8010849d <vector199>:
.globl vector199
vector199:
  pushl $0
8010849d:	6a 00                	push   $0x0
  pushl $199
8010849f:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801084a4:	e9 e0 f1 ff ff       	jmp    80107689 <alltraps>

801084a9 <vector200>:
.globl vector200
vector200:
  pushl $0
801084a9:	6a 00                	push   $0x0
  pushl $200
801084ab:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801084b0:	e9 d4 f1 ff ff       	jmp    80107689 <alltraps>

801084b5 <vector201>:
.globl vector201
vector201:
  pushl $0
801084b5:	6a 00                	push   $0x0
  pushl $201
801084b7:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801084bc:	e9 c8 f1 ff ff       	jmp    80107689 <alltraps>

801084c1 <vector202>:
.globl vector202
vector202:
  pushl $0
801084c1:	6a 00                	push   $0x0
  pushl $202
801084c3:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801084c8:	e9 bc f1 ff ff       	jmp    80107689 <alltraps>

801084cd <vector203>:
.globl vector203
vector203:
  pushl $0
801084cd:	6a 00                	push   $0x0
  pushl $203
801084cf:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801084d4:	e9 b0 f1 ff ff       	jmp    80107689 <alltraps>

801084d9 <vector204>:
.globl vector204
vector204:
  pushl $0
801084d9:	6a 00                	push   $0x0
  pushl $204
801084db:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801084e0:	e9 a4 f1 ff ff       	jmp    80107689 <alltraps>

801084e5 <vector205>:
.globl vector205
vector205:
  pushl $0
801084e5:	6a 00                	push   $0x0
  pushl $205
801084e7:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801084ec:	e9 98 f1 ff ff       	jmp    80107689 <alltraps>

801084f1 <vector206>:
.globl vector206
vector206:
  pushl $0
801084f1:	6a 00                	push   $0x0
  pushl $206
801084f3:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801084f8:	e9 8c f1 ff ff       	jmp    80107689 <alltraps>

801084fd <vector207>:
.globl vector207
vector207:
  pushl $0
801084fd:	6a 00                	push   $0x0
  pushl $207
801084ff:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80108504:	e9 80 f1 ff ff       	jmp    80107689 <alltraps>

80108509 <vector208>:
.globl vector208
vector208:
  pushl $0
80108509:	6a 00                	push   $0x0
  pushl $208
8010850b:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80108510:	e9 74 f1 ff ff       	jmp    80107689 <alltraps>

80108515 <vector209>:
.globl vector209
vector209:
  pushl $0
80108515:	6a 00                	push   $0x0
  pushl $209
80108517:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010851c:	e9 68 f1 ff ff       	jmp    80107689 <alltraps>

80108521 <vector210>:
.globl vector210
vector210:
  pushl $0
80108521:	6a 00                	push   $0x0
  pushl $210
80108523:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80108528:	e9 5c f1 ff ff       	jmp    80107689 <alltraps>

8010852d <vector211>:
.globl vector211
vector211:
  pushl $0
8010852d:	6a 00                	push   $0x0
  pushl $211
8010852f:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80108534:	e9 50 f1 ff ff       	jmp    80107689 <alltraps>

80108539 <vector212>:
.globl vector212
vector212:
  pushl $0
80108539:	6a 00                	push   $0x0
  pushl $212
8010853b:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80108540:	e9 44 f1 ff ff       	jmp    80107689 <alltraps>

80108545 <vector213>:
.globl vector213
vector213:
  pushl $0
80108545:	6a 00                	push   $0x0
  pushl $213
80108547:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010854c:	e9 38 f1 ff ff       	jmp    80107689 <alltraps>

80108551 <vector214>:
.globl vector214
vector214:
  pushl $0
80108551:	6a 00                	push   $0x0
  pushl $214
80108553:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80108558:	e9 2c f1 ff ff       	jmp    80107689 <alltraps>

8010855d <vector215>:
.globl vector215
vector215:
  pushl $0
8010855d:	6a 00                	push   $0x0
  pushl $215
8010855f:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80108564:	e9 20 f1 ff ff       	jmp    80107689 <alltraps>

80108569 <vector216>:
.globl vector216
vector216:
  pushl $0
80108569:	6a 00                	push   $0x0
  pushl $216
8010856b:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80108570:	e9 14 f1 ff ff       	jmp    80107689 <alltraps>

80108575 <vector217>:
.globl vector217
vector217:
  pushl $0
80108575:	6a 00                	push   $0x0
  pushl $217
80108577:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010857c:	e9 08 f1 ff ff       	jmp    80107689 <alltraps>

80108581 <vector218>:
.globl vector218
vector218:
  pushl $0
80108581:	6a 00                	push   $0x0
  pushl $218
80108583:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80108588:	e9 fc f0 ff ff       	jmp    80107689 <alltraps>

8010858d <vector219>:
.globl vector219
vector219:
  pushl $0
8010858d:	6a 00                	push   $0x0
  pushl $219
8010858f:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80108594:	e9 f0 f0 ff ff       	jmp    80107689 <alltraps>

80108599 <vector220>:
.globl vector220
vector220:
  pushl $0
80108599:	6a 00                	push   $0x0
  pushl $220
8010859b:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801085a0:	e9 e4 f0 ff ff       	jmp    80107689 <alltraps>

801085a5 <vector221>:
.globl vector221
vector221:
  pushl $0
801085a5:	6a 00                	push   $0x0
  pushl $221
801085a7:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801085ac:	e9 d8 f0 ff ff       	jmp    80107689 <alltraps>

801085b1 <vector222>:
.globl vector222
vector222:
  pushl $0
801085b1:	6a 00                	push   $0x0
  pushl $222
801085b3:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801085b8:	e9 cc f0 ff ff       	jmp    80107689 <alltraps>

801085bd <vector223>:
.globl vector223
vector223:
  pushl $0
801085bd:	6a 00                	push   $0x0
  pushl $223
801085bf:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801085c4:	e9 c0 f0 ff ff       	jmp    80107689 <alltraps>

801085c9 <vector224>:
.globl vector224
vector224:
  pushl $0
801085c9:	6a 00                	push   $0x0
  pushl $224
801085cb:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801085d0:	e9 b4 f0 ff ff       	jmp    80107689 <alltraps>

801085d5 <vector225>:
.globl vector225
vector225:
  pushl $0
801085d5:	6a 00                	push   $0x0
  pushl $225
801085d7:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801085dc:	e9 a8 f0 ff ff       	jmp    80107689 <alltraps>

801085e1 <vector226>:
.globl vector226
vector226:
  pushl $0
801085e1:	6a 00                	push   $0x0
  pushl $226
801085e3:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801085e8:	e9 9c f0 ff ff       	jmp    80107689 <alltraps>

801085ed <vector227>:
.globl vector227
vector227:
  pushl $0
801085ed:	6a 00                	push   $0x0
  pushl $227
801085ef:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801085f4:	e9 90 f0 ff ff       	jmp    80107689 <alltraps>

801085f9 <vector228>:
.globl vector228
vector228:
  pushl $0
801085f9:	6a 00                	push   $0x0
  pushl $228
801085fb:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80108600:	e9 84 f0 ff ff       	jmp    80107689 <alltraps>

80108605 <vector229>:
.globl vector229
vector229:
  pushl $0
80108605:	6a 00                	push   $0x0
  pushl $229
80108607:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
8010860c:	e9 78 f0 ff ff       	jmp    80107689 <alltraps>

80108611 <vector230>:
.globl vector230
vector230:
  pushl $0
80108611:	6a 00                	push   $0x0
  pushl $230
80108613:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80108618:	e9 6c f0 ff ff       	jmp    80107689 <alltraps>

8010861d <vector231>:
.globl vector231
vector231:
  pushl $0
8010861d:	6a 00                	push   $0x0
  pushl $231
8010861f:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80108624:	e9 60 f0 ff ff       	jmp    80107689 <alltraps>

80108629 <vector232>:
.globl vector232
vector232:
  pushl $0
80108629:	6a 00                	push   $0x0
  pushl $232
8010862b:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80108630:	e9 54 f0 ff ff       	jmp    80107689 <alltraps>

80108635 <vector233>:
.globl vector233
vector233:
  pushl $0
80108635:	6a 00                	push   $0x0
  pushl $233
80108637:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010863c:	e9 48 f0 ff ff       	jmp    80107689 <alltraps>

80108641 <vector234>:
.globl vector234
vector234:
  pushl $0
80108641:	6a 00                	push   $0x0
  pushl $234
80108643:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80108648:	e9 3c f0 ff ff       	jmp    80107689 <alltraps>

8010864d <vector235>:
.globl vector235
vector235:
  pushl $0
8010864d:	6a 00                	push   $0x0
  pushl $235
8010864f:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80108654:	e9 30 f0 ff ff       	jmp    80107689 <alltraps>

80108659 <vector236>:
.globl vector236
vector236:
  pushl $0
80108659:	6a 00                	push   $0x0
  pushl $236
8010865b:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80108660:	e9 24 f0 ff ff       	jmp    80107689 <alltraps>

80108665 <vector237>:
.globl vector237
vector237:
  pushl $0
80108665:	6a 00                	push   $0x0
  pushl $237
80108667:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010866c:	e9 18 f0 ff ff       	jmp    80107689 <alltraps>

80108671 <vector238>:
.globl vector238
vector238:
  pushl $0
80108671:	6a 00                	push   $0x0
  pushl $238
80108673:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80108678:	e9 0c f0 ff ff       	jmp    80107689 <alltraps>

8010867d <vector239>:
.globl vector239
vector239:
  pushl $0
8010867d:	6a 00                	push   $0x0
  pushl $239
8010867f:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80108684:	e9 00 f0 ff ff       	jmp    80107689 <alltraps>

80108689 <vector240>:
.globl vector240
vector240:
  pushl $0
80108689:	6a 00                	push   $0x0
  pushl $240
8010868b:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80108690:	e9 f4 ef ff ff       	jmp    80107689 <alltraps>

80108695 <vector241>:
.globl vector241
vector241:
  pushl $0
80108695:	6a 00                	push   $0x0
  pushl $241
80108697:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010869c:	e9 e8 ef ff ff       	jmp    80107689 <alltraps>

801086a1 <vector242>:
.globl vector242
vector242:
  pushl $0
801086a1:	6a 00                	push   $0x0
  pushl $242
801086a3:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801086a8:	e9 dc ef ff ff       	jmp    80107689 <alltraps>

801086ad <vector243>:
.globl vector243
vector243:
  pushl $0
801086ad:	6a 00                	push   $0x0
  pushl $243
801086af:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801086b4:	e9 d0 ef ff ff       	jmp    80107689 <alltraps>

801086b9 <vector244>:
.globl vector244
vector244:
  pushl $0
801086b9:	6a 00                	push   $0x0
  pushl $244
801086bb:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801086c0:	e9 c4 ef ff ff       	jmp    80107689 <alltraps>

801086c5 <vector245>:
.globl vector245
vector245:
  pushl $0
801086c5:	6a 00                	push   $0x0
  pushl $245
801086c7:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801086cc:	e9 b8 ef ff ff       	jmp    80107689 <alltraps>

801086d1 <vector246>:
.globl vector246
vector246:
  pushl $0
801086d1:	6a 00                	push   $0x0
  pushl $246
801086d3:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801086d8:	e9 ac ef ff ff       	jmp    80107689 <alltraps>

801086dd <vector247>:
.globl vector247
vector247:
  pushl $0
801086dd:	6a 00                	push   $0x0
  pushl $247
801086df:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801086e4:	e9 a0 ef ff ff       	jmp    80107689 <alltraps>

801086e9 <vector248>:
.globl vector248
vector248:
  pushl $0
801086e9:	6a 00                	push   $0x0
  pushl $248
801086eb:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801086f0:	e9 94 ef ff ff       	jmp    80107689 <alltraps>

801086f5 <vector249>:
.globl vector249
vector249:
  pushl $0
801086f5:	6a 00                	push   $0x0
  pushl $249
801086f7:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801086fc:	e9 88 ef ff ff       	jmp    80107689 <alltraps>

80108701 <vector250>:
.globl vector250
vector250:
  pushl $0
80108701:	6a 00                	push   $0x0
  pushl $250
80108703:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80108708:	e9 7c ef ff ff       	jmp    80107689 <alltraps>

8010870d <vector251>:
.globl vector251
vector251:
  pushl $0
8010870d:	6a 00                	push   $0x0
  pushl $251
8010870f:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80108714:	e9 70 ef ff ff       	jmp    80107689 <alltraps>

80108719 <vector252>:
.globl vector252
vector252:
  pushl $0
80108719:	6a 00                	push   $0x0
  pushl $252
8010871b:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80108720:	e9 64 ef ff ff       	jmp    80107689 <alltraps>

80108725 <vector253>:
.globl vector253
vector253:
  pushl $0
80108725:	6a 00                	push   $0x0
  pushl $253
80108727:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010872c:	e9 58 ef ff ff       	jmp    80107689 <alltraps>

80108731 <vector254>:
.globl vector254
vector254:
  pushl $0
80108731:	6a 00                	push   $0x0
  pushl $254
80108733:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80108738:	e9 4c ef ff ff       	jmp    80107689 <alltraps>

8010873d <vector255>:
.globl vector255
vector255:
  pushl $0
8010873d:	6a 00                	push   $0x0
  pushl $255
8010873f:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80108744:	e9 40 ef ff ff       	jmp    80107689 <alltraps>

80108749 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80108749:	55                   	push   %ebp
8010874a:	89 e5                	mov    %esp,%ebp
8010874c:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010874f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108752:	83 e8 01             	sub    $0x1,%eax
80108755:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80108759:	8b 45 08             	mov    0x8(%ebp),%eax
8010875c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80108760:	8b 45 08             	mov    0x8(%ebp),%eax
80108763:	c1 e8 10             	shr    $0x10,%eax
80108766:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
8010876a:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010876d:	0f 01 10             	lgdtl  (%eax)
}
80108770:	90                   	nop
80108771:	c9                   	leave  
80108772:	c3                   	ret    

80108773 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80108773:	55                   	push   %ebp
80108774:	89 e5                	mov    %esp,%ebp
80108776:	83 ec 04             	sub    $0x4,%esp
80108779:	8b 45 08             	mov    0x8(%ebp),%eax
8010877c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80108780:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80108784:	0f 00 d8             	ltr    %ax
}
80108787:	90                   	nop
80108788:	c9                   	leave  
80108789:	c3                   	ret    

8010878a <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
8010878a:	55                   	push   %ebp
8010878b:	89 e5                	mov    %esp,%ebp
8010878d:	83 ec 04             	sub    $0x4,%esp
80108790:	8b 45 08             	mov    0x8(%ebp),%eax
80108793:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80108797:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010879b:	8e e8                	mov    %eax,%gs
}
8010879d:	90                   	nop
8010879e:	c9                   	leave  
8010879f:	c3                   	ret    

801087a0 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
801087a0:	55                   	push   %ebp
801087a1:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801087a3:	8b 45 08             	mov    0x8(%ebp),%eax
801087a6:	0f 22 d8             	mov    %eax,%cr3
}
801087a9:	90                   	nop
801087aa:	5d                   	pop    %ebp
801087ab:	c3                   	ret    

801087ac <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801087ac:	55                   	push   %ebp
801087ad:	89 e5                	mov    %esp,%ebp
801087af:	8b 45 08             	mov    0x8(%ebp),%eax
801087b2:	05 00 00 00 80       	add    $0x80000000,%eax
801087b7:	5d                   	pop    %ebp
801087b8:	c3                   	ret    

801087b9 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801087b9:	55                   	push   %ebp
801087ba:	89 e5                	mov    %esp,%ebp
801087bc:	8b 45 08             	mov    0x8(%ebp),%eax
801087bf:	05 00 00 00 80       	add    $0x80000000,%eax
801087c4:	5d                   	pop    %ebp
801087c5:	c3                   	ret    

801087c6 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801087c6:	55                   	push   %ebp
801087c7:	89 e5                	mov    %esp,%ebp
801087c9:	53                   	push   %ebx
801087ca:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
801087cd:	e8 8e a8 ff ff       	call   80103060 <cpunum>
801087d2:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801087d8:	05 80 33 11 80       	add    $0x80113380,%eax
801087dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801087e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087e3:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801087e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087ec:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801087f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087f5:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801087f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087fc:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108800:	83 e2 f0             	and    $0xfffffff0,%edx
80108803:	83 ca 0a             	or     $0xa,%edx
80108806:	88 50 7d             	mov    %dl,0x7d(%eax)
80108809:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010880c:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108810:	83 ca 10             	or     $0x10,%edx
80108813:	88 50 7d             	mov    %dl,0x7d(%eax)
80108816:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108819:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010881d:	83 e2 9f             	and    $0xffffff9f,%edx
80108820:	88 50 7d             	mov    %dl,0x7d(%eax)
80108823:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108826:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010882a:	83 ca 80             	or     $0xffffff80,%edx
8010882d:	88 50 7d             	mov    %dl,0x7d(%eax)
80108830:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108833:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108837:	83 ca 0f             	or     $0xf,%edx
8010883a:	88 50 7e             	mov    %dl,0x7e(%eax)
8010883d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108840:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108844:	83 e2 ef             	and    $0xffffffef,%edx
80108847:	88 50 7e             	mov    %dl,0x7e(%eax)
8010884a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010884d:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108851:	83 e2 df             	and    $0xffffffdf,%edx
80108854:	88 50 7e             	mov    %dl,0x7e(%eax)
80108857:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010885a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010885e:	83 ca 40             	or     $0x40,%edx
80108861:	88 50 7e             	mov    %dl,0x7e(%eax)
80108864:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108867:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010886b:	83 ca 80             	or     $0xffffff80,%edx
8010886e:	88 50 7e             	mov    %dl,0x7e(%eax)
80108871:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108874:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80108878:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010887b:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80108882:	ff ff 
80108884:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108887:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010888e:	00 00 
80108890:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108893:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010889a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010889d:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801088a4:	83 e2 f0             	and    $0xfffffff0,%edx
801088a7:	83 ca 02             	or     $0x2,%edx
801088aa:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801088b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088b3:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801088ba:	83 ca 10             	or     $0x10,%edx
801088bd:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801088c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088c6:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801088cd:	83 e2 9f             	and    $0xffffff9f,%edx
801088d0:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801088d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088d9:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801088e0:	83 ca 80             	or     $0xffffff80,%edx
801088e3:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801088e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ec:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801088f3:	83 ca 0f             	or     $0xf,%edx
801088f6:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801088fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ff:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108906:	83 e2 ef             	and    $0xffffffef,%edx
80108909:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010890f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108912:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108919:	83 e2 df             	and    $0xffffffdf,%edx
8010891c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108922:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108925:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010892c:	83 ca 40             	or     $0x40,%edx
8010892f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108935:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108938:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010893f:	83 ca 80             	or     $0xffffff80,%edx
80108942:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108948:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010894b:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80108952:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108955:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
8010895c:	ff ff 
8010895e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108961:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80108968:	00 00 
8010896a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010896d:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80108974:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108977:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010897e:	83 e2 f0             	and    $0xfffffff0,%edx
80108981:	83 ca 0a             	or     $0xa,%edx
80108984:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010898a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010898d:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108994:	83 ca 10             	or     $0x10,%edx
80108997:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010899d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089a0:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801089a7:	83 ca 60             	or     $0x60,%edx
801089aa:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801089b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089b3:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801089ba:	83 ca 80             	or     $0xffffff80,%edx
801089bd:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801089c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089c6:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801089cd:	83 ca 0f             	or     $0xf,%edx
801089d0:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801089d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089d9:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801089e0:	83 e2 ef             	and    $0xffffffef,%edx
801089e3:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801089e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089ec:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801089f3:	83 e2 df             	and    $0xffffffdf,%edx
801089f6:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801089fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089ff:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108a06:	83 ca 40             	or     $0x40,%edx
80108a09:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a12:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108a19:	83 ca 80             	or     $0xffffff80,%edx
80108a1c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108a22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a25:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80108a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a2f:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80108a36:	ff ff 
80108a38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a3b:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80108a42:	00 00 
80108a44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a47:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80108a4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a51:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108a58:	83 e2 f0             	and    $0xfffffff0,%edx
80108a5b:	83 ca 02             	or     $0x2,%edx
80108a5e:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108a64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a67:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108a6e:	83 ca 10             	or     $0x10,%edx
80108a71:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a7a:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108a81:	83 ca 60             	or     $0x60,%edx
80108a84:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a8d:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108a94:	83 ca 80             	or     $0xffffff80,%edx
80108a97:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aa0:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108aa7:	83 ca 0f             	or     $0xf,%edx
80108aaa:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108ab0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ab3:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108aba:	83 e2 ef             	and    $0xffffffef,%edx
80108abd:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108ac3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ac6:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108acd:	83 e2 df             	and    $0xffffffdf,%edx
80108ad0:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108ad6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ad9:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108ae0:	83 ca 40             	or     $0x40,%edx
80108ae3:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aec:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108af3:	83 ca 80             	or     $0xffffff80,%edx
80108af6:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108afc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aff:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80108b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b09:	05 b4 00 00 00       	add    $0xb4,%eax
80108b0e:	89 c3                	mov    %eax,%ebx
80108b10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b13:	05 b4 00 00 00       	add    $0xb4,%eax
80108b18:	c1 e8 10             	shr    $0x10,%eax
80108b1b:	89 c2                	mov    %eax,%edx
80108b1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b20:	05 b4 00 00 00       	add    $0xb4,%eax
80108b25:	c1 e8 18             	shr    $0x18,%eax
80108b28:	89 c1                	mov    %eax,%ecx
80108b2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b2d:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80108b34:	00 00 
80108b36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b39:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80108b40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b43:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
80108b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b4c:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108b53:	83 e2 f0             	and    $0xfffffff0,%edx
80108b56:	83 ca 02             	or     $0x2,%edx
80108b59:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108b5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b62:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108b69:	83 ca 10             	or     $0x10,%edx
80108b6c:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108b72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b75:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108b7c:	83 e2 9f             	and    $0xffffff9f,%edx
80108b7f:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108b85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b88:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108b8f:	83 ca 80             	or     $0xffffff80,%edx
80108b92:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108b98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b9b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108ba2:	83 e2 f0             	and    $0xfffffff0,%edx
80108ba5:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bae:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108bb5:	83 e2 ef             	and    $0xffffffef,%edx
80108bb8:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108bbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bc1:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108bc8:	83 e2 df             	and    $0xffffffdf,%edx
80108bcb:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bd4:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108bdb:	83 ca 40             	or     $0x40,%edx
80108bde:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108be7:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108bee:	83 ca 80             	or     $0xffffff80,%edx
80108bf1:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108bf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bfa:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80108c00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c03:	83 c0 70             	add    $0x70,%eax
80108c06:	83 ec 08             	sub    $0x8,%esp
80108c09:	6a 38                	push   $0x38
80108c0b:	50                   	push   %eax
80108c0c:	e8 38 fb ff ff       	call   80108749 <lgdt>
80108c11:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
80108c14:	83 ec 0c             	sub    $0xc,%esp
80108c17:	6a 18                	push   $0x18
80108c19:	e8 6c fb ff ff       	call   8010878a <loadgs>
80108c1e:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
80108c21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c24:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80108c2a:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80108c31:	00 00 00 00 
}
80108c35:	90                   	nop
80108c36:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108c39:	c9                   	leave  
80108c3a:	c3                   	ret    

80108c3b <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80108c3b:	55                   	push   %ebp
80108c3c:	89 e5                	mov    %esp,%ebp
80108c3e:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80108c41:	8b 45 0c             	mov    0xc(%ebp),%eax
80108c44:	c1 e8 16             	shr    $0x16,%eax
80108c47:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108c4e:	8b 45 08             	mov    0x8(%ebp),%eax
80108c51:	01 d0                	add    %edx,%eax
80108c53:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80108c56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c59:	8b 00                	mov    (%eax),%eax
80108c5b:	83 e0 01             	and    $0x1,%eax
80108c5e:	85 c0                	test   %eax,%eax
80108c60:	74 18                	je     80108c7a <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80108c62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c65:	8b 00                	mov    (%eax),%eax
80108c67:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108c6c:	50                   	push   %eax
80108c6d:	e8 47 fb ff ff       	call   801087b9 <p2v>
80108c72:	83 c4 04             	add    $0x4,%esp
80108c75:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108c78:	eb 48                	jmp    80108cc2 <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80108c7a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108c7e:	74 0e                	je     80108c8e <walkpgdir+0x53>
80108c80:	e8 75 a0 ff ff       	call   80102cfa <kalloc>
80108c85:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108c88:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108c8c:	75 07                	jne    80108c95 <walkpgdir+0x5a>
      return 0;
80108c8e:	b8 00 00 00 00       	mov    $0x0,%eax
80108c93:	eb 44                	jmp    80108cd9 <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80108c95:	83 ec 04             	sub    $0x4,%esp
80108c98:	68 00 10 00 00       	push   $0x1000
80108c9d:	6a 00                	push   $0x0
80108c9f:	ff 75 f4             	pushl  -0xc(%ebp)
80108ca2:	e8 c0 d4 ff ff       	call   80106167 <memset>
80108ca7:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80108caa:	83 ec 0c             	sub    $0xc,%esp
80108cad:	ff 75 f4             	pushl  -0xc(%ebp)
80108cb0:	e8 f7 fa ff ff       	call   801087ac <v2p>
80108cb5:	83 c4 10             	add    $0x10,%esp
80108cb8:	83 c8 07             	or     $0x7,%eax
80108cbb:	89 c2                	mov    %eax,%edx
80108cbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108cc0:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80108cc2:	8b 45 0c             	mov    0xc(%ebp),%eax
80108cc5:	c1 e8 0c             	shr    $0xc,%eax
80108cc8:	25 ff 03 00 00       	and    $0x3ff,%eax
80108ccd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108cd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cd7:	01 d0                	add    %edx,%eax
}
80108cd9:	c9                   	leave  
80108cda:	c3                   	ret    

80108cdb <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108cdb:	55                   	push   %ebp
80108cdc:	89 e5                	mov    %esp,%ebp
80108cde:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80108ce1:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ce4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108ce9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108cec:	8b 55 0c             	mov    0xc(%ebp),%edx
80108cef:	8b 45 10             	mov    0x10(%ebp),%eax
80108cf2:	01 d0                	add    %edx,%eax
80108cf4:	83 e8 01             	sub    $0x1,%eax
80108cf7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108cfc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108cff:	83 ec 04             	sub    $0x4,%esp
80108d02:	6a 01                	push   $0x1
80108d04:	ff 75 f4             	pushl  -0xc(%ebp)
80108d07:	ff 75 08             	pushl  0x8(%ebp)
80108d0a:	e8 2c ff ff ff       	call   80108c3b <walkpgdir>
80108d0f:	83 c4 10             	add    $0x10,%esp
80108d12:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108d15:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108d19:	75 07                	jne    80108d22 <mappages+0x47>
      return -1;
80108d1b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108d20:	eb 47                	jmp    80108d69 <mappages+0x8e>
    if(*pte & PTE_P)
80108d22:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d25:	8b 00                	mov    (%eax),%eax
80108d27:	83 e0 01             	and    $0x1,%eax
80108d2a:	85 c0                	test   %eax,%eax
80108d2c:	74 0d                	je     80108d3b <mappages+0x60>
      panic("remap");
80108d2e:	83 ec 0c             	sub    $0xc,%esp
80108d31:	68 f0 9e 10 80       	push   $0x80109ef0
80108d36:	e8 2b 78 ff ff       	call   80100566 <panic>
    *pte = pa | perm | PTE_P;
80108d3b:	8b 45 18             	mov    0x18(%ebp),%eax
80108d3e:	0b 45 14             	or     0x14(%ebp),%eax
80108d41:	83 c8 01             	or     $0x1,%eax
80108d44:	89 c2                	mov    %eax,%edx
80108d46:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d49:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108d4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d4e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108d51:	74 10                	je     80108d63 <mappages+0x88>
      break;
    a += PGSIZE;
80108d53:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108d5a:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80108d61:	eb 9c                	jmp    80108cff <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80108d63:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80108d64:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108d69:	c9                   	leave  
80108d6a:	c3                   	ret    

80108d6b <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108d6b:	55                   	push   %ebp
80108d6c:	89 e5                	mov    %esp,%ebp
80108d6e:	53                   	push   %ebx
80108d6f:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108d72:	e8 83 9f ff ff       	call   80102cfa <kalloc>
80108d77:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108d7a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108d7e:	75 0a                	jne    80108d8a <setupkvm+0x1f>
    return 0;
80108d80:	b8 00 00 00 00       	mov    $0x0,%eax
80108d85:	e9 8e 00 00 00       	jmp    80108e18 <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80108d8a:	83 ec 04             	sub    $0x4,%esp
80108d8d:	68 00 10 00 00       	push   $0x1000
80108d92:	6a 00                	push   $0x0
80108d94:	ff 75 f0             	pushl  -0x10(%ebp)
80108d97:	e8 cb d3 ff ff       	call   80106167 <memset>
80108d9c:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80108d9f:	83 ec 0c             	sub    $0xc,%esp
80108da2:	68 00 00 00 0e       	push   $0xe000000
80108da7:	e8 0d fa ff ff       	call   801087b9 <p2v>
80108dac:	83 c4 10             	add    $0x10,%esp
80108daf:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108db4:	76 0d                	jbe    80108dc3 <setupkvm+0x58>
    panic("PHYSTOP too high");
80108db6:	83 ec 0c             	sub    $0xc,%esp
80108db9:	68 f6 9e 10 80       	push   $0x80109ef6
80108dbe:	e8 a3 77 ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108dc3:	c7 45 f4 c0 c4 10 80 	movl   $0x8010c4c0,-0xc(%ebp)
80108dca:	eb 40                	jmp    80108e0c <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108dcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dcf:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80108dd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dd5:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108dd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ddb:	8b 58 08             	mov    0x8(%eax),%ebx
80108dde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108de1:	8b 40 04             	mov    0x4(%eax),%eax
80108de4:	29 c3                	sub    %eax,%ebx
80108de6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108de9:	8b 00                	mov    (%eax),%eax
80108deb:	83 ec 0c             	sub    $0xc,%esp
80108dee:	51                   	push   %ecx
80108def:	52                   	push   %edx
80108df0:	53                   	push   %ebx
80108df1:	50                   	push   %eax
80108df2:	ff 75 f0             	pushl  -0x10(%ebp)
80108df5:	e8 e1 fe ff ff       	call   80108cdb <mappages>
80108dfa:	83 c4 20             	add    $0x20,%esp
80108dfd:	85 c0                	test   %eax,%eax
80108dff:	79 07                	jns    80108e08 <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80108e01:	b8 00 00 00 00       	mov    $0x0,%eax
80108e06:	eb 10                	jmp    80108e18 <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108e08:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108e0c:	81 7d f4 00 c5 10 80 	cmpl   $0x8010c500,-0xc(%ebp)
80108e13:	72 b7                	jb     80108dcc <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80108e15:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108e18:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108e1b:	c9                   	leave  
80108e1c:	c3                   	ret    

80108e1d <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108e1d:	55                   	push   %ebp
80108e1e:	89 e5                	mov    %esp,%ebp
80108e20:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108e23:	e8 43 ff ff ff       	call   80108d6b <setupkvm>
80108e28:	a3 38 67 11 80       	mov    %eax,0x80116738
  switchkvm();
80108e2d:	e8 03 00 00 00       	call   80108e35 <switchkvm>
}
80108e32:	90                   	nop
80108e33:	c9                   	leave  
80108e34:	c3                   	ret    

80108e35 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108e35:	55                   	push   %ebp
80108e36:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80108e38:	a1 38 67 11 80       	mov    0x80116738,%eax
80108e3d:	50                   	push   %eax
80108e3e:	e8 69 f9 ff ff       	call   801087ac <v2p>
80108e43:	83 c4 04             	add    $0x4,%esp
80108e46:	50                   	push   %eax
80108e47:	e8 54 f9 ff ff       	call   801087a0 <lcr3>
80108e4c:	83 c4 04             	add    $0x4,%esp
}
80108e4f:	90                   	nop
80108e50:	c9                   	leave  
80108e51:	c3                   	ret    

80108e52 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108e52:	55                   	push   %ebp
80108e53:	89 e5                	mov    %esp,%ebp
80108e55:	56                   	push   %esi
80108e56:	53                   	push   %ebx
  pushcli();
80108e57:	e8 05 d2 ff ff       	call   80106061 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108e5c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108e62:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108e69:	83 c2 08             	add    $0x8,%edx
80108e6c:	89 d6                	mov    %edx,%esi
80108e6e:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108e75:	83 c2 08             	add    $0x8,%edx
80108e78:	c1 ea 10             	shr    $0x10,%edx
80108e7b:	89 d3                	mov    %edx,%ebx
80108e7d:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108e84:	83 c2 08             	add    $0x8,%edx
80108e87:	c1 ea 18             	shr    $0x18,%edx
80108e8a:	89 d1                	mov    %edx,%ecx
80108e8c:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108e93:	67 00 
80108e95:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80108e9c:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80108ea2:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108ea9:	83 e2 f0             	and    $0xfffffff0,%edx
80108eac:	83 ca 09             	or     $0x9,%edx
80108eaf:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108eb5:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108ebc:	83 ca 10             	or     $0x10,%edx
80108ebf:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108ec5:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108ecc:	83 e2 9f             	and    $0xffffff9f,%edx
80108ecf:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108ed5:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108edc:	83 ca 80             	or     $0xffffff80,%edx
80108edf:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108ee5:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108eec:	83 e2 f0             	and    $0xfffffff0,%edx
80108eef:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108ef5:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108efc:	83 e2 ef             	and    $0xffffffef,%edx
80108eff:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108f05:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108f0c:	83 e2 df             	and    $0xffffffdf,%edx
80108f0f:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108f15:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108f1c:	83 ca 40             	or     $0x40,%edx
80108f1f:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108f25:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108f2c:	83 e2 7f             	and    $0x7f,%edx
80108f2f:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108f35:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108f3b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108f41:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108f48:	83 e2 ef             	and    $0xffffffef,%edx
80108f4b:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108f51:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108f57:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108f5d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108f63:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108f6a:	8b 52 08             	mov    0x8(%edx),%edx
80108f6d:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108f73:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108f76:	83 ec 0c             	sub    $0xc,%esp
80108f79:	6a 30                	push   $0x30
80108f7b:	e8 f3 f7 ff ff       	call   80108773 <ltr>
80108f80:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80108f83:	8b 45 08             	mov    0x8(%ebp),%eax
80108f86:	8b 40 04             	mov    0x4(%eax),%eax
80108f89:	85 c0                	test   %eax,%eax
80108f8b:	75 0d                	jne    80108f9a <switchuvm+0x148>
    panic("switchuvm: no pgdir");
80108f8d:	83 ec 0c             	sub    $0xc,%esp
80108f90:	68 07 9f 10 80       	push   $0x80109f07
80108f95:	e8 cc 75 ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108f9a:	8b 45 08             	mov    0x8(%ebp),%eax
80108f9d:	8b 40 04             	mov    0x4(%eax),%eax
80108fa0:	83 ec 0c             	sub    $0xc,%esp
80108fa3:	50                   	push   %eax
80108fa4:	e8 03 f8 ff ff       	call   801087ac <v2p>
80108fa9:	83 c4 10             	add    $0x10,%esp
80108fac:	83 ec 0c             	sub    $0xc,%esp
80108faf:	50                   	push   %eax
80108fb0:	e8 eb f7 ff ff       	call   801087a0 <lcr3>
80108fb5:	83 c4 10             	add    $0x10,%esp
  popcli();
80108fb8:	e8 e9 d0 ff ff       	call   801060a6 <popcli>
}
80108fbd:	90                   	nop
80108fbe:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108fc1:	5b                   	pop    %ebx
80108fc2:	5e                   	pop    %esi
80108fc3:	5d                   	pop    %ebp
80108fc4:	c3                   	ret    

80108fc5 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108fc5:	55                   	push   %ebp
80108fc6:	89 e5                	mov    %esp,%ebp
80108fc8:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108fcb:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108fd2:	76 0d                	jbe    80108fe1 <inituvm+0x1c>
    panic("inituvm: more than a page");
80108fd4:	83 ec 0c             	sub    $0xc,%esp
80108fd7:	68 1b 9f 10 80       	push   $0x80109f1b
80108fdc:	e8 85 75 ff ff       	call   80100566 <panic>
  mem = kalloc();
80108fe1:	e8 14 9d ff ff       	call   80102cfa <kalloc>
80108fe6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108fe9:	83 ec 04             	sub    $0x4,%esp
80108fec:	68 00 10 00 00       	push   $0x1000
80108ff1:	6a 00                	push   $0x0
80108ff3:	ff 75 f4             	pushl  -0xc(%ebp)
80108ff6:	e8 6c d1 ff ff       	call   80106167 <memset>
80108ffb:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108ffe:	83 ec 0c             	sub    $0xc,%esp
80109001:	ff 75 f4             	pushl  -0xc(%ebp)
80109004:	e8 a3 f7 ff ff       	call   801087ac <v2p>
80109009:	83 c4 10             	add    $0x10,%esp
8010900c:	83 ec 0c             	sub    $0xc,%esp
8010900f:	6a 06                	push   $0x6
80109011:	50                   	push   %eax
80109012:	68 00 10 00 00       	push   $0x1000
80109017:	6a 00                	push   $0x0
80109019:	ff 75 08             	pushl  0x8(%ebp)
8010901c:	e8 ba fc ff ff       	call   80108cdb <mappages>
80109021:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80109024:	83 ec 04             	sub    $0x4,%esp
80109027:	ff 75 10             	pushl  0x10(%ebp)
8010902a:	ff 75 0c             	pushl  0xc(%ebp)
8010902d:	ff 75 f4             	pushl  -0xc(%ebp)
80109030:	e8 f1 d1 ff ff       	call   80106226 <memmove>
80109035:	83 c4 10             	add    $0x10,%esp
}
80109038:	90                   	nop
80109039:	c9                   	leave  
8010903a:	c3                   	ret    

8010903b <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010903b:	55                   	push   %ebp
8010903c:	89 e5                	mov    %esp,%ebp
8010903e:	53                   	push   %ebx
8010903f:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80109042:	8b 45 0c             	mov    0xc(%ebp),%eax
80109045:	25 ff 0f 00 00       	and    $0xfff,%eax
8010904a:	85 c0                	test   %eax,%eax
8010904c:	74 0d                	je     8010905b <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
8010904e:	83 ec 0c             	sub    $0xc,%esp
80109051:	68 38 9f 10 80       	push   $0x80109f38
80109056:	e8 0b 75 ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
8010905b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109062:	e9 95 00 00 00       	jmp    801090fc <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80109067:	8b 55 0c             	mov    0xc(%ebp),%edx
8010906a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010906d:	01 d0                	add    %edx,%eax
8010906f:	83 ec 04             	sub    $0x4,%esp
80109072:	6a 00                	push   $0x0
80109074:	50                   	push   %eax
80109075:	ff 75 08             	pushl  0x8(%ebp)
80109078:	e8 be fb ff ff       	call   80108c3b <walkpgdir>
8010907d:	83 c4 10             	add    $0x10,%esp
80109080:	89 45 ec             	mov    %eax,-0x14(%ebp)
80109083:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109087:	75 0d                	jne    80109096 <loaduvm+0x5b>
      panic("loaduvm: address should exist");
80109089:	83 ec 0c             	sub    $0xc,%esp
8010908c:	68 5b 9f 10 80       	push   $0x80109f5b
80109091:	e8 d0 74 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80109096:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109099:	8b 00                	mov    (%eax),%eax
8010909b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801090a0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801090a3:	8b 45 18             	mov    0x18(%ebp),%eax
801090a6:	2b 45 f4             	sub    -0xc(%ebp),%eax
801090a9:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801090ae:	77 0b                	ja     801090bb <loaduvm+0x80>
      n = sz - i;
801090b0:	8b 45 18             	mov    0x18(%ebp),%eax
801090b3:	2b 45 f4             	sub    -0xc(%ebp),%eax
801090b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801090b9:	eb 07                	jmp    801090c2 <loaduvm+0x87>
    else
      n = PGSIZE;
801090bb:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
801090c2:	8b 55 14             	mov    0x14(%ebp),%edx
801090c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090c8:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801090cb:	83 ec 0c             	sub    $0xc,%esp
801090ce:	ff 75 e8             	pushl  -0x18(%ebp)
801090d1:	e8 e3 f6 ff ff       	call   801087b9 <p2v>
801090d6:	83 c4 10             	add    $0x10,%esp
801090d9:	ff 75 f0             	pushl  -0x10(%ebp)
801090dc:	53                   	push   %ebx
801090dd:	50                   	push   %eax
801090de:	ff 75 10             	pushl  0x10(%ebp)
801090e1:	e8 86 8e ff ff       	call   80101f6c <readi>
801090e6:	83 c4 10             	add    $0x10,%esp
801090e9:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801090ec:	74 07                	je     801090f5 <loaduvm+0xba>
      return -1;
801090ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801090f3:	eb 18                	jmp    8010910d <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
801090f5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801090fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090ff:	3b 45 18             	cmp    0x18(%ebp),%eax
80109102:	0f 82 5f ff ff ff    	jb     80109067 <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80109108:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010910d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109110:	c9                   	leave  
80109111:	c3                   	ret    

80109112 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80109112:	55                   	push   %ebp
80109113:	89 e5                	mov    %esp,%ebp
80109115:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80109118:	8b 45 10             	mov    0x10(%ebp),%eax
8010911b:	85 c0                	test   %eax,%eax
8010911d:	79 0a                	jns    80109129 <allocuvm+0x17>
    return 0;
8010911f:	b8 00 00 00 00       	mov    $0x0,%eax
80109124:	e9 b0 00 00 00       	jmp    801091d9 <allocuvm+0xc7>
  if(newsz < oldsz)
80109129:	8b 45 10             	mov    0x10(%ebp),%eax
8010912c:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010912f:	73 08                	jae    80109139 <allocuvm+0x27>
    return oldsz;
80109131:	8b 45 0c             	mov    0xc(%ebp),%eax
80109134:	e9 a0 00 00 00       	jmp    801091d9 <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
80109139:	8b 45 0c             	mov    0xc(%ebp),%eax
8010913c:	05 ff 0f 00 00       	add    $0xfff,%eax
80109141:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109146:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80109149:	eb 7f                	jmp    801091ca <allocuvm+0xb8>
    mem = kalloc();
8010914b:	e8 aa 9b ff ff       	call   80102cfa <kalloc>
80109150:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80109153:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109157:	75 2b                	jne    80109184 <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
80109159:	83 ec 0c             	sub    $0xc,%esp
8010915c:	68 79 9f 10 80       	push   $0x80109f79
80109161:	e8 60 72 ff ff       	call   801003c6 <cprintf>
80109166:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80109169:	83 ec 04             	sub    $0x4,%esp
8010916c:	ff 75 0c             	pushl  0xc(%ebp)
8010916f:	ff 75 10             	pushl  0x10(%ebp)
80109172:	ff 75 08             	pushl  0x8(%ebp)
80109175:	e8 61 00 00 00       	call   801091db <deallocuvm>
8010917a:	83 c4 10             	add    $0x10,%esp
      return 0;
8010917d:	b8 00 00 00 00       	mov    $0x0,%eax
80109182:	eb 55                	jmp    801091d9 <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
80109184:	83 ec 04             	sub    $0x4,%esp
80109187:	68 00 10 00 00       	push   $0x1000
8010918c:	6a 00                	push   $0x0
8010918e:	ff 75 f0             	pushl  -0x10(%ebp)
80109191:	e8 d1 cf ff ff       	call   80106167 <memset>
80109196:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80109199:	83 ec 0c             	sub    $0xc,%esp
8010919c:	ff 75 f0             	pushl  -0x10(%ebp)
8010919f:	e8 08 f6 ff ff       	call   801087ac <v2p>
801091a4:	83 c4 10             	add    $0x10,%esp
801091a7:	89 c2                	mov    %eax,%edx
801091a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091ac:	83 ec 0c             	sub    $0xc,%esp
801091af:	6a 06                	push   $0x6
801091b1:	52                   	push   %edx
801091b2:	68 00 10 00 00       	push   $0x1000
801091b7:	50                   	push   %eax
801091b8:	ff 75 08             	pushl  0x8(%ebp)
801091bb:	e8 1b fb ff ff       	call   80108cdb <mappages>
801091c0:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
801091c3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801091ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091cd:	3b 45 10             	cmp    0x10(%ebp),%eax
801091d0:	0f 82 75 ff ff ff    	jb     8010914b <allocuvm+0x39>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
801091d6:	8b 45 10             	mov    0x10(%ebp),%eax
}
801091d9:	c9                   	leave  
801091da:	c3                   	ret    

801091db <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801091db:	55                   	push   %ebp
801091dc:	89 e5                	mov    %esp,%ebp
801091de:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801091e1:	8b 45 10             	mov    0x10(%ebp),%eax
801091e4:	3b 45 0c             	cmp    0xc(%ebp),%eax
801091e7:	72 08                	jb     801091f1 <deallocuvm+0x16>
    return oldsz;
801091e9:	8b 45 0c             	mov    0xc(%ebp),%eax
801091ec:	e9 a5 00 00 00       	jmp    80109296 <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
801091f1:	8b 45 10             	mov    0x10(%ebp),%eax
801091f4:	05 ff 0f 00 00       	add    $0xfff,%eax
801091f9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801091fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80109201:	e9 81 00 00 00       	jmp    80109287 <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
80109206:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109209:	83 ec 04             	sub    $0x4,%esp
8010920c:	6a 00                	push   $0x0
8010920e:	50                   	push   %eax
8010920f:	ff 75 08             	pushl  0x8(%ebp)
80109212:	e8 24 fa ff ff       	call   80108c3b <walkpgdir>
80109217:	83 c4 10             	add    $0x10,%esp
8010921a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
8010921d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109221:	75 09                	jne    8010922c <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
80109223:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
8010922a:	eb 54                	jmp    80109280 <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
8010922c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010922f:	8b 00                	mov    (%eax),%eax
80109231:	83 e0 01             	and    $0x1,%eax
80109234:	85 c0                	test   %eax,%eax
80109236:	74 48                	je     80109280 <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
80109238:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010923b:	8b 00                	mov    (%eax),%eax
8010923d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109242:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80109245:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109249:	75 0d                	jne    80109258 <deallocuvm+0x7d>
        panic("kfree");
8010924b:	83 ec 0c             	sub    $0xc,%esp
8010924e:	68 91 9f 10 80       	push   $0x80109f91
80109253:	e8 0e 73 ff ff       	call   80100566 <panic>
      char *v = p2v(pa);
80109258:	83 ec 0c             	sub    $0xc,%esp
8010925b:	ff 75 ec             	pushl  -0x14(%ebp)
8010925e:	e8 56 f5 ff ff       	call   801087b9 <p2v>
80109263:	83 c4 10             	add    $0x10,%esp
80109266:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80109269:	83 ec 0c             	sub    $0xc,%esp
8010926c:	ff 75 e8             	pushl  -0x18(%ebp)
8010926f:	e8 e9 99 ff ff       	call   80102c5d <kfree>
80109274:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80109277:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010927a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80109280:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109287:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010928a:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010928d:	0f 82 73 ff ff ff    	jb     80109206 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80109293:	8b 45 10             	mov    0x10(%ebp),%eax
}
80109296:	c9                   	leave  
80109297:	c3                   	ret    

80109298 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80109298:	55                   	push   %ebp
80109299:	89 e5                	mov    %esp,%ebp
8010929b:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
8010929e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801092a2:	75 0d                	jne    801092b1 <freevm+0x19>
    panic("freevm: no pgdir");
801092a4:	83 ec 0c             	sub    $0xc,%esp
801092a7:	68 97 9f 10 80       	push   $0x80109f97
801092ac:	e8 b5 72 ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801092b1:	83 ec 04             	sub    $0x4,%esp
801092b4:	6a 00                	push   $0x0
801092b6:	68 00 00 00 80       	push   $0x80000000
801092bb:	ff 75 08             	pushl  0x8(%ebp)
801092be:	e8 18 ff ff ff       	call   801091db <deallocuvm>
801092c3:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801092c6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801092cd:	eb 4f                	jmp    8010931e <freevm+0x86>
    if(pgdir[i] & PTE_P){
801092cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092d2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801092d9:	8b 45 08             	mov    0x8(%ebp),%eax
801092dc:	01 d0                	add    %edx,%eax
801092de:	8b 00                	mov    (%eax),%eax
801092e0:	83 e0 01             	and    $0x1,%eax
801092e3:	85 c0                	test   %eax,%eax
801092e5:	74 33                	je     8010931a <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
801092e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092ea:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801092f1:	8b 45 08             	mov    0x8(%ebp),%eax
801092f4:	01 d0                	add    %edx,%eax
801092f6:	8b 00                	mov    (%eax),%eax
801092f8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801092fd:	83 ec 0c             	sub    $0xc,%esp
80109300:	50                   	push   %eax
80109301:	e8 b3 f4 ff ff       	call   801087b9 <p2v>
80109306:	83 c4 10             	add    $0x10,%esp
80109309:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010930c:	83 ec 0c             	sub    $0xc,%esp
8010930f:	ff 75 f0             	pushl  -0x10(%ebp)
80109312:	e8 46 99 ff ff       	call   80102c5d <kfree>
80109317:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
8010931a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010931e:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80109325:	76 a8                	jbe    801092cf <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80109327:	83 ec 0c             	sub    $0xc,%esp
8010932a:	ff 75 08             	pushl  0x8(%ebp)
8010932d:	e8 2b 99 ff ff       	call   80102c5d <kfree>
80109332:	83 c4 10             	add    $0x10,%esp
}
80109335:	90                   	nop
80109336:	c9                   	leave  
80109337:	c3                   	ret    

80109338 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80109338:	55                   	push   %ebp
80109339:	89 e5                	mov    %esp,%ebp
8010933b:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010933e:	83 ec 04             	sub    $0x4,%esp
80109341:	6a 00                	push   $0x0
80109343:	ff 75 0c             	pushl  0xc(%ebp)
80109346:	ff 75 08             	pushl  0x8(%ebp)
80109349:	e8 ed f8 ff ff       	call   80108c3b <walkpgdir>
8010934e:	83 c4 10             	add    $0x10,%esp
80109351:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80109354:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109358:	75 0d                	jne    80109367 <clearpteu+0x2f>
    panic("clearpteu");
8010935a:	83 ec 0c             	sub    $0xc,%esp
8010935d:	68 a8 9f 10 80       	push   $0x80109fa8
80109362:	e8 ff 71 ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
80109367:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010936a:	8b 00                	mov    (%eax),%eax
8010936c:	83 e0 fb             	and    $0xfffffffb,%eax
8010936f:	89 c2                	mov    %eax,%edx
80109371:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109374:	89 10                	mov    %edx,(%eax)
}
80109376:	90                   	nop
80109377:	c9                   	leave  
80109378:	c3                   	ret    

80109379 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80109379:	55                   	push   %ebp
8010937a:	89 e5                	mov    %esp,%ebp
8010937c:	53                   	push   %ebx
8010937d:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80109380:	e8 e6 f9 ff ff       	call   80108d6b <setupkvm>
80109385:	89 45 f0             	mov    %eax,-0x10(%ebp)
80109388:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010938c:	75 0a                	jne    80109398 <copyuvm+0x1f>
    return 0;
8010938e:	b8 00 00 00 00       	mov    $0x0,%eax
80109393:	e9 f8 00 00 00       	jmp    80109490 <copyuvm+0x117>
  for(i = 0; i < sz; i += PGSIZE){
80109398:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010939f:	e9 c4 00 00 00       	jmp    80109468 <copyuvm+0xef>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801093a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093a7:	83 ec 04             	sub    $0x4,%esp
801093aa:	6a 00                	push   $0x0
801093ac:	50                   	push   %eax
801093ad:	ff 75 08             	pushl  0x8(%ebp)
801093b0:	e8 86 f8 ff ff       	call   80108c3b <walkpgdir>
801093b5:	83 c4 10             	add    $0x10,%esp
801093b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
801093bb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801093bf:	75 0d                	jne    801093ce <copyuvm+0x55>
      panic("copyuvm: pte should exist");
801093c1:	83 ec 0c             	sub    $0xc,%esp
801093c4:	68 b2 9f 10 80       	push   $0x80109fb2
801093c9:	e8 98 71 ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P))
801093ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
801093d1:	8b 00                	mov    (%eax),%eax
801093d3:	83 e0 01             	and    $0x1,%eax
801093d6:	85 c0                	test   %eax,%eax
801093d8:	75 0d                	jne    801093e7 <copyuvm+0x6e>
      panic("copyuvm: page not present");
801093da:	83 ec 0c             	sub    $0xc,%esp
801093dd:	68 cc 9f 10 80       	push   $0x80109fcc
801093e2:	e8 7f 71 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
801093e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801093ea:	8b 00                	mov    (%eax),%eax
801093ec:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801093f1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801093f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801093f7:	8b 00                	mov    (%eax),%eax
801093f9:	25 ff 0f 00 00       	and    $0xfff,%eax
801093fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80109401:	e8 f4 98 ff ff       	call   80102cfa <kalloc>
80109406:	89 45 e0             	mov    %eax,-0x20(%ebp)
80109409:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010940d:	74 6a                	je     80109479 <copyuvm+0x100>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
8010940f:	83 ec 0c             	sub    $0xc,%esp
80109412:	ff 75 e8             	pushl  -0x18(%ebp)
80109415:	e8 9f f3 ff ff       	call   801087b9 <p2v>
8010941a:	83 c4 10             	add    $0x10,%esp
8010941d:	83 ec 04             	sub    $0x4,%esp
80109420:	68 00 10 00 00       	push   $0x1000
80109425:	50                   	push   %eax
80109426:	ff 75 e0             	pushl  -0x20(%ebp)
80109429:	e8 f8 cd ff ff       	call   80106226 <memmove>
8010942e:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80109431:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80109434:	83 ec 0c             	sub    $0xc,%esp
80109437:	ff 75 e0             	pushl  -0x20(%ebp)
8010943a:	e8 6d f3 ff ff       	call   801087ac <v2p>
8010943f:	83 c4 10             	add    $0x10,%esp
80109442:	89 c2                	mov    %eax,%edx
80109444:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109447:	83 ec 0c             	sub    $0xc,%esp
8010944a:	53                   	push   %ebx
8010944b:	52                   	push   %edx
8010944c:	68 00 10 00 00       	push   $0x1000
80109451:	50                   	push   %eax
80109452:	ff 75 f0             	pushl  -0x10(%ebp)
80109455:	e8 81 f8 ff ff       	call   80108cdb <mappages>
8010945a:	83 c4 20             	add    $0x20,%esp
8010945d:	85 c0                	test   %eax,%eax
8010945f:	78 1b                	js     8010947c <copyuvm+0x103>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80109461:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109468:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010946b:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010946e:	0f 82 30 ff ff ff    	jb     801093a4 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
80109474:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109477:	eb 17                	jmp    80109490 <copyuvm+0x117>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
80109479:	90                   	nop
8010947a:	eb 01                	jmp    8010947d <copyuvm+0x104>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
8010947c:	90                   	nop
  }
  return d;

bad:
  freevm(d);
8010947d:	83 ec 0c             	sub    $0xc,%esp
80109480:	ff 75 f0             	pushl  -0x10(%ebp)
80109483:	e8 10 fe ff ff       	call   80109298 <freevm>
80109488:	83 c4 10             	add    $0x10,%esp
  return 0;
8010948b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109490:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109493:	c9                   	leave  
80109494:	c3                   	ret    

80109495 <uva2ka>:

// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80109495:	55                   	push   %ebp
80109496:	89 e5                	mov    %esp,%ebp
80109498:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010949b:	83 ec 04             	sub    $0x4,%esp
8010949e:	6a 00                	push   $0x0
801094a0:	ff 75 0c             	pushl  0xc(%ebp)
801094a3:	ff 75 08             	pushl  0x8(%ebp)
801094a6:	e8 90 f7 ff ff       	call   80108c3b <walkpgdir>
801094ab:	83 c4 10             	add    $0x10,%esp
801094ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801094b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094b4:	8b 00                	mov    (%eax),%eax
801094b6:	83 e0 01             	and    $0x1,%eax
801094b9:	85 c0                	test   %eax,%eax
801094bb:	75 07                	jne    801094c4 <uva2ka+0x2f>
    return 0;
801094bd:	b8 00 00 00 00       	mov    $0x0,%eax
801094c2:	eb 29                	jmp    801094ed <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
801094c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094c7:	8b 00                	mov    (%eax),%eax
801094c9:	83 e0 04             	and    $0x4,%eax
801094cc:	85 c0                	test   %eax,%eax
801094ce:	75 07                	jne    801094d7 <uva2ka+0x42>
    return 0;
801094d0:	b8 00 00 00 00       	mov    $0x0,%eax
801094d5:	eb 16                	jmp    801094ed <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
801094d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094da:	8b 00                	mov    (%eax),%eax
801094dc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801094e1:	83 ec 0c             	sub    $0xc,%esp
801094e4:	50                   	push   %eax
801094e5:	e8 cf f2 ff ff       	call   801087b9 <p2v>
801094ea:	83 c4 10             	add    $0x10,%esp
}
801094ed:	c9                   	leave  
801094ee:	c3                   	ret    

801094ef <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801094ef:	55                   	push   %ebp
801094f0:	89 e5                	mov    %esp,%ebp
801094f2:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801094f5:	8b 45 10             	mov    0x10(%ebp),%eax
801094f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801094fb:	eb 7f                	jmp    8010957c <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
801094fd:	8b 45 0c             	mov    0xc(%ebp),%eax
80109500:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109505:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80109508:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010950b:	83 ec 08             	sub    $0x8,%esp
8010950e:	50                   	push   %eax
8010950f:	ff 75 08             	pushl  0x8(%ebp)
80109512:	e8 7e ff ff ff       	call   80109495 <uva2ka>
80109517:	83 c4 10             	add    $0x10,%esp
8010951a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010951d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80109521:	75 07                	jne    8010952a <copyout+0x3b>
      return -1;
80109523:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109528:	eb 61                	jmp    8010958b <copyout+0x9c>
    n = PGSIZE - (va - va0);
8010952a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010952d:	2b 45 0c             	sub    0xc(%ebp),%eax
80109530:	05 00 10 00 00       	add    $0x1000,%eax
80109535:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80109538:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010953b:	3b 45 14             	cmp    0x14(%ebp),%eax
8010953e:	76 06                	jbe    80109546 <copyout+0x57>
      n = len;
80109540:	8b 45 14             	mov    0x14(%ebp),%eax
80109543:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80109546:	8b 45 0c             	mov    0xc(%ebp),%eax
80109549:	2b 45 ec             	sub    -0x14(%ebp),%eax
8010954c:	89 c2                	mov    %eax,%edx
8010954e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109551:	01 d0                	add    %edx,%eax
80109553:	83 ec 04             	sub    $0x4,%esp
80109556:	ff 75 f0             	pushl  -0x10(%ebp)
80109559:	ff 75 f4             	pushl  -0xc(%ebp)
8010955c:	50                   	push   %eax
8010955d:	e8 c4 cc ff ff       	call   80106226 <memmove>
80109562:	83 c4 10             	add    $0x10,%esp
    len -= n;
80109565:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109568:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010956b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010956e:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80109571:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109574:	05 00 10 00 00       	add    $0x1000,%eax
80109579:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
8010957c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80109580:	0f 85 77 ff ff ff    	jne    801094fd <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80109586:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010958b:	c9                   	leave  
8010958c:	c3                   	ret    
