
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
80100015:	b8 00 c0 10 00       	mov    $0x10c000,%eax
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
80100028:	bc 90 e6 10 80       	mov    $0x8010e690,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 2e 3c 10 80       	mov    $0x80103c2e,%eax
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
8010003d:	68 3c a2 10 80       	push   $0x8010a23c
80100042:	68 a0 e6 10 80       	push   $0x8010e6a0
80100047:	e8 99 69 00 00       	call   801069e5 <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 b0 25 11 80 a4 	movl   $0x801125a4,0x801125b0
80100056:	25 11 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 b4 25 11 80 a4 	movl   $0x801125a4,0x801125b4
80100060:	25 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 d4 e6 10 80 	movl   $0x8010e6d4,-0xc(%ebp)
8010006a:	eb 3a                	jmp    801000a6 <binit+0x72>
    b->next = bcache.head.next;
8010006c:	8b 15 b4 25 11 80    	mov    0x801125b4,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 0c a4 25 11 80 	movl   $0x801125a4,0xc(%eax)
    b->dev = -1;
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008c:	a1 b4 25 11 80       	mov    0x801125b4,%eax
80100091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100094:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010009a:	a3 b4 25 11 80       	mov    %eax,0x801125b4
  initlock(&bcache.lock, "bcache");

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009f:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a6:	b8 a4 25 11 80       	mov    $0x801125a4,%eax
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
801000bc:	68 a0 e6 10 80       	push   $0x8010e6a0
801000c1:	e8 41 69 00 00       	call   80106a07 <acquire>
801000c6:	83 c4 10             	add    $0x10,%esp

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c9:	a1 b4 25 11 80       	mov    0x801125b4,%eax
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
80100107:	68 a0 e6 10 80       	push   $0x8010e6a0
8010010c:	e8 5d 69 00 00       	call   80106a6e <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 a0 e6 10 80       	push   $0x8010e6a0
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 80 58 00 00       	call   801059ac <sleep>
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
8010013a:	81 7d f4 a4 25 11 80 	cmpl   $0x801125a4,-0xc(%ebp)
80100141:	75 90                	jne    801000d3 <bget+0x20>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100143:	a1 b0 25 11 80       	mov    0x801125b0,%eax
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
80100183:	68 a0 e6 10 80       	push   $0x8010e6a0
80100188:	e8 e1 68 00 00       	call   80106a6e <release>
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
8010019e:	81 7d f4 a4 25 11 80 	cmpl   $0x801125a4,-0xc(%ebp)
801001a5:	75 a6                	jne    8010014d <bget+0x9a>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a7:	83 ec 0c             	sub    $0xc,%esp
801001aa:	68 43 a2 10 80       	push   $0x8010a243
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
801001e2:	e8 c5 2a 00 00       	call   80102cac <iderw>
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
80100204:	68 54 a2 10 80       	push   $0x8010a254
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
80100223:	e8 84 2a 00 00       	call   80102cac <iderw>
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
80100243:	68 5b a2 10 80       	push   $0x8010a25b
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 a0 e6 10 80       	push   $0x8010e6a0
80100255:	e8 ad 67 00 00       	call   80106a07 <acquire>
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
8010027b:	8b 15 b4 25 11 80    	mov    0x801125b4,%edx
80100281:	8b 45 08             	mov    0x8(%ebp),%eax
80100284:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
80100287:	8b 45 08             	mov    0x8(%ebp),%eax
8010028a:	c7 40 0c a4 25 11 80 	movl   $0x801125a4,0xc(%eax)
  bcache.head.next->prev = b;
80100291:	a1 b4 25 11 80       	mov    0x801125b4,%eax
80100296:	8b 55 08             	mov    0x8(%ebp),%edx
80100299:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
8010029c:	8b 45 08             	mov    0x8(%ebp),%eax
8010029f:	a3 b4 25 11 80       	mov    %eax,0x801125b4

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
801002b9:	e8 41 59 00 00       	call   80105bff <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 a0 e6 10 80       	push   $0x8010e6a0
801002c9:	e8 a0 67 00 00       	call   80106a6e <release>
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
80100365:	0f b6 80 04 b0 10 80 	movzbl -0x7fef4ffc(%eax),%eax
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
801003cc:	a1 34 d6 10 80       	mov    0x8010d634,%eax
801003d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003d4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d8:	74 10                	je     801003ea <cprintf+0x24>
    acquire(&cons.lock);
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	68 00 d6 10 80       	push   $0x8010d600
801003e2:	e8 20 66 00 00       	call   80106a07 <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 62 a2 10 80       	push   $0x8010a262
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
801004cd:	c7 45 ec 6b a2 10 80 	movl   $0x8010a26b,-0x14(%ebp)
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
80100556:	68 00 d6 10 80       	push   $0x8010d600
8010055b:	e8 0e 65 00 00       	call   80106a6e <release>
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
80100571:	c7 05 34 d6 10 80 00 	movl   $0x0,0x8010d634
80100578:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010057b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100581:	0f b6 00             	movzbl (%eax),%eax
80100584:	0f b6 c0             	movzbl %al,%eax
80100587:	83 ec 08             	sub    $0x8,%esp
8010058a:	50                   	push   %eax
8010058b:	68 72 a2 10 80       	push   $0x8010a272
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
801005aa:	68 81 a2 10 80       	push   $0x8010a281
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 f9 64 00 00       	call   80106ac0 <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 83 a2 10 80       	push   $0x8010a283
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
801005f5:	c7 05 e0 d5 10 80 01 	movl   $0x1,0x8010d5e0
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
80100699:	8b 0d 00 b0 10 80    	mov    0x8010b000,%ecx
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
801006ca:	68 87 a2 10 80       	push   $0x8010a287
801006cf:	e8 92 fe ff ff       	call   80100566 <panic>
  
  if((pos/80) >= 24){  // Scroll up.
801006d4:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006db:	7e 4c                	jle    80100729 <cgaputc+0x128>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006dd:	a1 00 b0 10 80       	mov    0x8010b000,%eax
801006e2:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006e8:	a1 00 b0 10 80       	mov    0x8010b000,%eax
801006ed:	83 ec 04             	sub    $0x4,%esp
801006f0:	68 60 0e 00 00       	push   $0xe60
801006f5:	52                   	push   %edx
801006f6:	50                   	push   %eax
801006f7:	e8 2d 66 00 00       	call   80106d29 <memmove>
801006fc:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
801006ff:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100703:	b8 80 07 00 00       	mov    $0x780,%eax
80100708:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010070b:	8d 14 00             	lea    (%eax,%eax,1),%edx
8010070e:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80100713:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100716:	01 c9                	add    %ecx,%ecx
80100718:	01 c8                	add    %ecx,%eax
8010071a:	83 ec 04             	sub    $0x4,%esp
8010071d:	52                   	push   %edx
8010071e:	6a 00                	push   $0x0
80100720:	50                   	push   %eax
80100721:	e8 44 65 00 00       	call   80106c6a <memset>
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
8010077e:	a1 00 b0 10 80       	mov    0x8010b000,%eax
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
80100798:	a1 e0 d5 10 80       	mov    0x8010d5e0,%eax
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
801007b6:	e8 0a 81 00 00       	call   801088c5 <uartputc>
801007bb:	83 c4 10             	add    $0x10,%esp
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	6a 20                	push   $0x20
801007c3:	e8 fd 80 00 00       	call   801088c5 <uartputc>
801007c8:	83 c4 10             	add    $0x10,%esp
801007cb:	83 ec 0c             	sub    $0xc,%esp
801007ce:	6a 08                	push   $0x8
801007d0:	e8 f0 80 00 00       	call   801088c5 <uartputc>
801007d5:	83 c4 10             	add    $0x10,%esp
801007d8:	eb 0e                	jmp    801007e8 <consputc+0x56>
  } else
    uartputc(c);
801007da:	83 ec 0c             	sub    $0xc,%esp
801007dd:	ff 75 08             	pushl  0x8(%ebp)
801007e0:	e8 e0 80 00 00       	call   801088c5 <uartputc>
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
80100809:	68 00 d6 10 80       	push   $0x8010d600
8010080e:	e8 f4 61 00 00       	call   80106a07 <acquire>
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
8010087f:	a1 48 28 11 80       	mov    0x80112848,%eax
80100884:	83 e8 01             	sub    $0x1,%eax
80100887:	a3 48 28 11 80       	mov    %eax,0x80112848
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
8010089c:	8b 15 48 28 11 80    	mov    0x80112848,%edx
801008a2:	a1 44 28 11 80       	mov    0x80112844,%eax
801008a7:	39 c2                	cmp    %eax,%edx
801008a9:	0f 84 12 01 00 00    	je     801009c1 <consoleintr+0x1c8>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
801008af:	a1 48 28 11 80       	mov    0x80112848,%eax
801008b4:	83 e8 01             	sub    $0x1,%eax
801008b7:	83 e0 7f             	and    $0x7f,%eax
801008ba:	0f b6 80 c0 27 11 80 	movzbl -0x7feed840(%eax),%eax
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
801008ca:	8b 15 48 28 11 80    	mov    0x80112848,%edx
801008d0:	a1 44 28 11 80       	mov    0x80112844,%eax
801008d5:	39 c2                	cmp    %eax,%edx
801008d7:	0f 84 e4 00 00 00    	je     801009c1 <consoleintr+0x1c8>
        input.e--;
801008dd:	a1 48 28 11 80       	mov    0x80112848,%eax
801008e2:	83 e8 01             	sub    $0x1,%eax
801008e5:	a3 48 28 11 80       	mov    %eax,0x80112848
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
80100939:	8b 15 48 28 11 80    	mov    0x80112848,%edx
8010093f:	a1 40 28 11 80       	mov    0x80112840,%eax
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
80100960:	a1 48 28 11 80       	mov    0x80112848,%eax
80100965:	8d 50 01             	lea    0x1(%eax),%edx
80100968:	89 15 48 28 11 80    	mov    %edx,0x80112848
8010096e:	83 e0 7f             	and    $0x7f,%eax
80100971:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100974:	88 90 c0 27 11 80    	mov    %dl,-0x7feed840(%eax)
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
80100994:	a1 48 28 11 80       	mov    0x80112848,%eax
80100999:	8b 15 40 28 11 80    	mov    0x80112840,%edx
8010099f:	83 ea 80             	sub    $0xffffff80,%edx
801009a2:	39 d0                	cmp    %edx,%eax
801009a4:	75 1a                	jne    801009c0 <consoleintr+0x1c7>
          input.w = input.e;
801009a6:	a1 48 28 11 80       	mov    0x80112848,%eax
801009ab:	a3 44 28 11 80       	mov    %eax,0x80112844
          wakeup(&input.r);
801009b0:	83 ec 0c             	sub    $0xc,%esp
801009b3:	68 40 28 11 80       	push   $0x80112840
801009b8:	e8 42 52 00 00       	call   80105bff <wakeup>
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
801009d6:	68 00 d6 10 80       	push   $0x8010d600
801009db:	e8 8e 60 00 00       	call   80106a6e <release>
801009e0:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
801009e3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801009e7:	74 05                	je     801009ee <consoleintr+0x1f5>
    procdump();  // now call procdump() wo. cons.lock held
801009e9:	e8 e3 54 00 00       	call   80105ed1 <procdump>
  }
#ifdef CS333_P3P4
  if(doprocdump == 2) {
801009ee:	83 7d f4 02          	cmpl   $0x2,-0xc(%ebp)
801009f2:	75 07                	jne    801009fb <consoleintr+0x202>
    doready();
801009f4:	e8 06 5c 00 00       	call   801065ff <doready>
  else if(doprocdump == 5) {
    dozombie();
  }
#endif
  
}
801009f9:	eb 25                	jmp    80100a20 <consoleintr+0x227>
  }
#ifdef CS333_P3P4
  if(doprocdump == 2) {
    doready();
  }
  else if(doprocdump == 3) {
801009fb:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
801009ff:	75 07                	jne    80100a08 <consoleintr+0x20f>
    dofree();
80100a01:	e8 9f 5c 00 00       	call   801066a5 <dofree>
  else if(doprocdump == 5) {
    dozombie();
  }
#endif
  
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
80100a0e:	e8 fa 5c 00 00       	call   8010670d <dosleep>
  else if(doprocdump == 5) {
    dozombie();
  }
#endif
  
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
80100a1b:	e8 70 5d 00 00       	call   80106790 <dozombie>
  }
#endif
  
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
80100a2f:	e8 67 12 00 00       	call   80101c9b <iunlock>
80100a34:	83 c4 10             	add    $0x10,%esp
  target = n;
80100a37:	8b 45 10             	mov    0x10(%ebp),%eax
80100a3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100a3d:	83 ec 0c             	sub    $0xc,%esp
80100a40:	68 00 d6 10 80       	push   $0x8010d600
80100a45:	e8 bd 5f 00 00       	call   80106a07 <acquire>
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
80100a62:	68 00 d6 10 80       	push   $0x8010d600
80100a67:	e8 02 60 00 00       	call   80106a6e <release>
80100a6c:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a6f:	83 ec 0c             	sub    $0xc,%esp
80100a72:	ff 75 08             	pushl  0x8(%ebp)
80100a75:	e8 9b 10 00 00       	call   80101b15 <ilock>
80100a7a:	83 c4 10             	add    $0x10,%esp
        return -1;
80100a7d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a82:	e9 ab 00 00 00       	jmp    80100b32 <consoleread+0x10f>
      }
      sleep(&input.r, &cons.lock);
80100a87:	83 ec 08             	sub    $0x8,%esp
80100a8a:	68 00 d6 10 80       	push   $0x8010d600
80100a8f:	68 40 28 11 80       	push   $0x80112840
80100a94:	e8 13 4f 00 00       	call   801059ac <sleep>
80100a99:	83 c4 10             	add    $0x10,%esp

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
80100a9c:	8b 15 40 28 11 80    	mov    0x80112840,%edx
80100aa2:	a1 44 28 11 80       	mov    0x80112844,%eax
80100aa7:	39 c2                	cmp    %eax,%edx
80100aa9:	74 a7                	je     80100a52 <consoleread+0x2f>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100aab:	a1 40 28 11 80       	mov    0x80112840,%eax
80100ab0:	8d 50 01             	lea    0x1(%eax),%edx
80100ab3:	89 15 40 28 11 80    	mov    %edx,0x80112840
80100ab9:	83 e0 7f             	and    $0x7f,%eax
80100abc:	0f b6 80 c0 27 11 80 	movzbl -0x7feed840(%eax),%eax
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
80100ad7:	a1 40 28 11 80       	mov    0x80112840,%eax
80100adc:	83 e8 01             	sub    $0x1,%eax
80100adf:	a3 40 28 11 80       	mov    %eax,0x80112840
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
80100b0d:	68 00 d6 10 80       	push   $0x8010d600
80100b12:	e8 57 5f 00 00       	call   80106a6e <release>
80100b17:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b1a:	83 ec 0c             	sub    $0xc,%esp
80100b1d:	ff 75 08             	pushl  0x8(%ebp)
80100b20:	e8 f0 0f 00 00       	call   80101b15 <ilock>
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
80100b40:	e8 56 11 00 00       	call   80101c9b <iunlock>
80100b45:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100b48:	83 ec 0c             	sub    $0xc,%esp
80100b4b:	68 00 d6 10 80       	push   $0x8010d600
80100b50:	e8 b2 5e 00 00       	call   80106a07 <acquire>
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
80100b8d:	68 00 d6 10 80       	push   $0x8010d600
80100b92:	e8 d7 5e 00 00       	call   80106a6e <release>
80100b97:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b9a:	83 ec 0c             	sub    $0xc,%esp
80100b9d:	ff 75 08             	pushl  0x8(%ebp)
80100ba0:	e8 70 0f 00 00       	call   80101b15 <ilock>
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
80100bb6:	68 9a a2 10 80       	push   $0x8010a29a
80100bbb:	68 00 d6 10 80       	push   $0x8010d600
80100bc0:	e8 20 5e 00 00       	call   801069e5 <initlock>
80100bc5:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100bc8:	c7 05 0c 32 11 80 34 	movl   $0x80100b34,0x8011320c
80100bcf:	0b 10 80 
  devsw[CONSOLE].read = consoleread;
80100bd2:	c7 05 08 32 11 80 23 	movl   $0x80100a23,0x80113208
80100bd9:	0a 10 80 
  cons.locking = 1;
80100bdc:	c7 05 34 d6 10 80 01 	movl   $0x1,0x8010d634
80100be3:	00 00 00 

  picenable(IRQ_KBD);
80100be6:	83 ec 0c             	sub    $0xc,%esp
80100be9:	6a 01                	push   $0x1
80100beb:	e8 da 36 00 00       	call   801042ca <picenable>
80100bf0:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100bf3:	83 ec 08             	sub    $0x8,%esp
80100bf6:	6a 00                	push   $0x0
80100bf8:	6a 01                	push   $0x1
80100bfa:	e8 7a 22 00 00       	call   80102e79 <ioapicenable>
80100bff:	83 c4 10             	add    $0x10,%esp
}
80100c02:	90                   	nop
80100c03:	c9                   	leave  
80100c04:	c3                   	ret    

80100c05 <exec>:
#include "fs.h"
#include "file.h"

int
exec(char *path, char **argv)
{
80100c05:	55                   	push   %ebp
80100c06:	89 e5                	mov    %esp,%ebp
80100c08:	81 ec 38 01 00 00    	sub    $0x138,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100c0e:	e8 d9 2c 00 00       	call   801038ec <begin_op>
  if((ip = namei(path)) == 0){
80100c13:	83 ec 0c             	sub    $0xc,%esp
80100c16:	ff 75 08             	pushl  0x8(%ebp)
80100c19:	e8 05 1b 00 00       	call   80102723 <namei>
80100c1e:	83 c4 10             	add    $0x10,%esp
80100c21:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c24:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c28:	75 0f                	jne    80100c39 <exec+0x34>
    end_op();
80100c2a:	e8 49 2d 00 00       	call   80103978 <end_op>
    return -1;
80100c2f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c34:	e9 a1 04 00 00       	jmp    801010da <exec+0x4d5>
  }

  ilock(ip);
80100c39:	83 ec 0c             	sub    $0xc,%esp
80100c3c:	ff 75 d8             	pushl  -0x28(%ebp)
80100c3f:	e8 d1 0e 00 00       	call   80101b15 <ilock>
80100c44:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100c47:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

#ifdef CS333_P5
  struct stat st;
  int hold = 0;
80100c4e:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  int uid = -1;
80100c55:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  stati(ip, &st);
80100c5c:	83 ec 08             	sub    $0x8,%esp
80100c5f:	8d 85 c8 fe ff ff    	lea    -0x138(%ebp),%eax
80100c65:	50                   	push   %eax
80100c66:	ff 75 d8             	pushl  -0x28(%ebp)
80100c69:	e8 f7 13 00 00       	call   80102065 <stati>
80100c6e:	83 c4 10             	add    $0x10,%esp
  if(st.uid == proc->uid && st.mode.flags.u_x)
80100c71:	0f b7 85 dc fe ff ff 	movzwl -0x124(%ebp),%eax
80100c78:	0f b7 d0             	movzwl %ax,%edx
80100c7b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100c81:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80100c87:	39 c2                	cmp    %eax,%edx
80100c89:	75 15                	jne    80100ca0 <exec+0x9b>
80100c8b:	0f b6 85 e0 fe ff ff 	movzbl -0x120(%ebp),%eax
80100c92:	83 e0 40             	and    $0x40,%eax
80100c95:	84 c0                	test   %al,%al
80100c97:	74 07                	je     80100ca0 <exec+0x9b>
    hold = 1;
80100c99:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  if(st.gid == proc->gid && st.mode.flags.g_x)
80100ca0:	0f b7 85 de fe ff ff 	movzwl -0x122(%ebp),%eax
80100ca7:	0f b7 d0             	movzwl %ax,%edx
80100caa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100cb0:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80100cb6:	39 c2                	cmp    %eax,%edx
80100cb8:	75 15                	jne    80100ccf <exec+0xca>
80100cba:	0f b6 85 e0 fe ff ff 	movzbl -0x120(%ebp),%eax
80100cc1:	83 e0 08             	and    $0x8,%eax
80100cc4:	84 c0                	test   %al,%al
80100cc6:	74 07                	je     80100ccf <exec+0xca>
    hold = 1;
80100cc8:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  if(st.mode.flags.o_x)
80100ccf:	0f b6 85 e0 fe ff ff 	movzbl -0x120(%ebp),%eax
80100cd6:	83 e0 01             	and    $0x1,%eax
80100cd9:	84 c0                	test   %al,%al
80100cdb:	74 07                	je     80100ce4 <exec+0xdf>
    hold = 1;
80100cdd:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  if(hold == 0)
80100ce4:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
80100ce8:	0f 84 98 03 00 00    	je     80101086 <exec+0x481>
    goto bad;
  if(st.mode.flags.setuid)
80100cee:	0f b6 85 e1 fe ff ff 	movzbl -0x11f(%ebp),%eax
80100cf5:	83 e0 02             	and    $0x2,%eax
80100cf8:	84 c0                	test   %al,%al
80100cfa:	74 0d                	je     80100d09 <exec+0x104>
    uid = ip->uid;
80100cfc:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100cff:	0f b7 40 18          	movzwl 0x18(%eax),%eax
80100d03:	0f b7 c0             	movzwl %ax,%eax
80100d06:	89 45 cc             	mov    %eax,-0x34(%ebp)
#endif
  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100d09:	6a 34                	push   $0x34
80100d0b:	6a 00                	push   $0x0
80100d0d:	8d 85 04 ff ff ff    	lea    -0xfc(%ebp),%eax
80100d13:	50                   	push   %eax
80100d14:	ff 75 d8             	pushl  -0x28(%ebp)
80100d17:	e8 b7 13 00 00       	call   801020d3 <readi>
80100d1c:	83 c4 10             	add    $0x10,%esp
80100d1f:	83 f8 33             	cmp    $0x33,%eax
80100d22:	0f 86 61 03 00 00    	jbe    80101089 <exec+0x484>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100d28:	8b 85 04 ff ff ff    	mov    -0xfc(%ebp),%eax
80100d2e:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100d33:	0f 85 53 03 00 00    	jne    8010108c <exec+0x487>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100d39:	e8 dc 8c 00 00       	call   80109a1a <setupkvm>
80100d3e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100d41:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100d45:	0f 84 44 03 00 00    	je     8010108f <exec+0x48a>
    goto bad;

  // Load program into memory.
  sz = 0;
80100d4b:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d52:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100d59:	8b 85 20 ff ff ff    	mov    -0xe0(%ebp),%eax
80100d5f:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d62:	e9 ab 00 00 00       	jmp    80100e12 <exec+0x20d>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100d67:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d6a:	6a 20                	push   $0x20
80100d6c:	50                   	push   %eax
80100d6d:	8d 85 e4 fe ff ff    	lea    -0x11c(%ebp),%eax
80100d73:	50                   	push   %eax
80100d74:	ff 75 d8             	pushl  -0x28(%ebp)
80100d77:	e8 57 13 00 00       	call   801020d3 <readi>
80100d7c:	83 c4 10             	add    $0x10,%esp
80100d7f:	83 f8 20             	cmp    $0x20,%eax
80100d82:	0f 85 0a 03 00 00    	jne    80101092 <exec+0x48d>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100d88:	8b 85 e4 fe ff ff    	mov    -0x11c(%ebp),%eax
80100d8e:	83 f8 01             	cmp    $0x1,%eax
80100d91:	75 71                	jne    80100e04 <exec+0x1ff>
      continue;
    if(ph.memsz < ph.filesz)
80100d93:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100d99:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100d9f:	39 c2                	cmp    %eax,%edx
80100da1:	0f 82 ee 02 00 00    	jb     80101095 <exec+0x490>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100da7:	8b 95 ec fe ff ff    	mov    -0x114(%ebp),%edx
80100dad:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100db3:	01 d0                	add    %edx,%eax
80100db5:	83 ec 04             	sub    $0x4,%esp
80100db8:	50                   	push   %eax
80100db9:	ff 75 e0             	pushl  -0x20(%ebp)
80100dbc:	ff 75 d4             	pushl  -0x2c(%ebp)
80100dbf:	e8 fd 8f 00 00       	call   80109dc1 <allocuvm>
80100dc4:	83 c4 10             	add    $0x10,%esp
80100dc7:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100dca:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100dce:	0f 84 c4 02 00 00    	je     80101098 <exec+0x493>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100dd4:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100dda:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100de0:	8b 8d ec fe ff ff    	mov    -0x114(%ebp),%ecx
80100de6:	83 ec 0c             	sub    $0xc,%esp
80100de9:	52                   	push   %edx
80100dea:	50                   	push   %eax
80100deb:	ff 75 d8             	pushl  -0x28(%ebp)
80100dee:	51                   	push   %ecx
80100def:	ff 75 d4             	pushl  -0x2c(%ebp)
80100df2:	e8 f3 8e 00 00       	call   80109cea <loaduvm>
80100df7:	83 c4 20             	add    $0x20,%esp
80100dfa:	85 c0                	test   %eax,%eax
80100dfc:	0f 88 99 02 00 00    	js     8010109b <exec+0x496>
80100e02:	eb 01                	jmp    80100e05 <exec+0x200>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100e04:	90                   	nop
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100e05:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100e09:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100e0c:	83 c0 20             	add    $0x20,%eax
80100e0f:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100e12:	0f b7 85 30 ff ff ff 	movzwl -0xd0(%ebp),%eax
80100e19:	0f b7 c0             	movzwl %ax,%eax
80100e1c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100e1f:	0f 8f 42 ff ff ff    	jg     80100d67 <exec+0x162>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100e25:	83 ec 0c             	sub    $0xc,%esp
80100e28:	ff 75 d8             	pushl  -0x28(%ebp)
80100e2b:	e8 cd 0f 00 00       	call   80101dfd <iunlockput>
80100e30:	83 c4 10             	add    $0x10,%esp
  end_op();
80100e33:	e8 40 2b 00 00       	call   80103978 <end_op>
  ip = 0;
80100e38:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100e3f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e42:	05 ff 0f 00 00       	add    $0xfff,%eax
80100e47:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100e4c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100e4f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e52:	05 00 20 00 00       	add    $0x2000,%eax
80100e57:	83 ec 04             	sub    $0x4,%esp
80100e5a:	50                   	push   %eax
80100e5b:	ff 75 e0             	pushl  -0x20(%ebp)
80100e5e:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e61:	e8 5b 8f 00 00       	call   80109dc1 <allocuvm>
80100e66:	83 c4 10             	add    $0x10,%esp
80100e69:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100e6c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100e70:	0f 84 28 02 00 00    	je     8010109e <exec+0x499>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100e76:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e79:	2d 00 20 00 00       	sub    $0x2000,%eax
80100e7e:	83 ec 08             	sub    $0x8,%esp
80100e81:	50                   	push   %eax
80100e82:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e85:	e8 5d 91 00 00       	call   80109fe7 <clearpteu>
80100e8a:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100e8d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e90:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100e93:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100e9a:	e9 96 00 00 00       	jmp    80100f35 <exec+0x330>
    if(argc >= MAXARG)
80100e9f:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100ea3:	0f 87 f8 01 00 00    	ja     801010a1 <exec+0x49c>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100ea9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eac:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100eb3:	8b 45 0c             	mov    0xc(%ebp),%eax
80100eb6:	01 d0                	add    %edx,%eax
80100eb8:	8b 00                	mov    (%eax),%eax
80100eba:	83 ec 0c             	sub    $0xc,%esp
80100ebd:	50                   	push   %eax
80100ebe:	e8 f4 5f 00 00       	call   80106eb7 <strlen>
80100ec3:	83 c4 10             	add    $0x10,%esp
80100ec6:	89 c2                	mov    %eax,%edx
80100ec8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ecb:	29 d0                	sub    %edx,%eax
80100ecd:	83 e8 01             	sub    $0x1,%eax
80100ed0:	83 e0 fc             	and    $0xfffffffc,%eax
80100ed3:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100ed6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ed9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ee0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ee3:	01 d0                	add    %edx,%eax
80100ee5:	8b 00                	mov    (%eax),%eax
80100ee7:	83 ec 0c             	sub    $0xc,%esp
80100eea:	50                   	push   %eax
80100eeb:	e8 c7 5f 00 00       	call   80106eb7 <strlen>
80100ef0:	83 c4 10             	add    $0x10,%esp
80100ef3:	83 c0 01             	add    $0x1,%eax
80100ef6:	89 c1                	mov    %eax,%ecx
80100ef8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100efb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f02:	8b 45 0c             	mov    0xc(%ebp),%eax
80100f05:	01 d0                	add    %edx,%eax
80100f07:	8b 00                	mov    (%eax),%eax
80100f09:	51                   	push   %ecx
80100f0a:	50                   	push   %eax
80100f0b:	ff 75 dc             	pushl  -0x24(%ebp)
80100f0e:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f11:	e8 88 92 00 00       	call   8010a19e <copyout>
80100f16:	83 c4 10             	add    $0x10,%esp
80100f19:	85 c0                	test   %eax,%eax
80100f1b:	0f 88 83 01 00 00    	js     801010a4 <exec+0x49f>
      goto bad;
    ustack[3+argc] = sp;
80100f21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f24:	8d 50 03             	lea    0x3(%eax),%edx
80100f27:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f2a:	89 84 95 38 ff ff ff 	mov    %eax,-0xc8(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100f31:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100f35:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f38:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f3f:	8b 45 0c             	mov    0xc(%ebp),%eax
80100f42:	01 d0                	add    %edx,%eax
80100f44:	8b 00                	mov    (%eax),%eax
80100f46:	85 c0                	test   %eax,%eax
80100f48:	0f 85 51 ff ff ff    	jne    80100e9f <exec+0x29a>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100f4e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f51:	83 c0 03             	add    $0x3,%eax
80100f54:	c7 84 85 38 ff ff ff 	movl   $0x0,-0xc8(%ebp,%eax,4)
80100f5b:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100f5f:	c7 85 38 ff ff ff ff 	movl   $0xffffffff,-0xc8(%ebp)
80100f66:	ff ff ff 
  ustack[1] = argc;
80100f69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f6c:	89 85 3c ff ff ff    	mov    %eax,-0xc4(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100f72:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f75:	83 c0 01             	add    $0x1,%eax
80100f78:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f7f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f82:	29 d0                	sub    %edx,%eax
80100f84:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)

  sp -= (3+argc+1) * 4;
80100f8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f8d:	83 c0 04             	add    $0x4,%eax
80100f90:	c1 e0 02             	shl    $0x2,%eax
80100f93:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100f96:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f99:	83 c0 04             	add    $0x4,%eax
80100f9c:	c1 e0 02             	shl    $0x2,%eax
80100f9f:	50                   	push   %eax
80100fa0:	8d 85 38 ff ff ff    	lea    -0xc8(%ebp),%eax
80100fa6:	50                   	push   %eax
80100fa7:	ff 75 dc             	pushl  -0x24(%ebp)
80100faa:	ff 75 d4             	pushl  -0x2c(%ebp)
80100fad:	e8 ec 91 00 00       	call   8010a19e <copyout>
80100fb2:	83 c4 10             	add    $0x10,%esp
80100fb5:	85 c0                	test   %eax,%eax
80100fb7:	0f 88 ea 00 00 00    	js     801010a7 <exec+0x4a2>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100fbd:	8b 45 08             	mov    0x8(%ebp),%eax
80100fc0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fc6:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100fc9:	eb 17                	jmp    80100fe2 <exec+0x3dd>
    if(*s == '/')
80100fcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fce:	0f b6 00             	movzbl (%eax),%eax
80100fd1:	3c 2f                	cmp    $0x2f,%al
80100fd3:	75 09                	jne    80100fde <exec+0x3d9>
      last = s+1;
80100fd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fd8:	83 c0 01             	add    $0x1,%eax
80100fdb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100fde:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100fe2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fe5:	0f b6 00             	movzbl (%eax),%eax
80100fe8:	84 c0                	test   %al,%al
80100fea:	75 df                	jne    80100fcb <exec+0x3c6>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100fec:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ff2:	83 c0 6c             	add    $0x6c,%eax
80100ff5:	83 ec 04             	sub    $0x4,%esp
80100ff8:	6a 10                	push   $0x10
80100ffa:	ff 75 f0             	pushl  -0x10(%ebp)
80100ffd:	50                   	push   %eax
80100ffe:	e8 6a 5e 00 00       	call   80106e6d <safestrcpy>
80101003:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80101006:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010100c:	8b 40 04             	mov    0x4(%eax),%eax
8010100f:	89 45 c8             	mov    %eax,-0x38(%ebp)
  proc->pgdir = pgdir;
80101012:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101018:	8b 55 d4             	mov    -0x2c(%ebp),%edx
8010101b:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
8010101e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101024:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101027:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80101029:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010102f:	8b 40 18             	mov    0x18(%eax),%eax
80101032:	8b 95 1c ff ff ff    	mov    -0xe4(%ebp),%edx
80101038:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
8010103b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101041:	8b 40 18             	mov    0x18(%eax),%eax
80101044:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101047:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
8010104a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101050:	83 ec 0c             	sub    $0xc,%esp
80101053:	50                   	push   %eax
80101054:	e8 a8 8a 00 00       	call   80109b01 <switchuvm>
80101059:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
8010105c:	83 ec 0c             	sub    $0xc,%esp
8010105f:	ff 75 c8             	pushl  -0x38(%ebp)
80101062:	e8 e0 8e 00 00       	call   80109f47 <freevm>
80101067:	83 c4 10             	add    $0x10,%esp

#ifdef CS333_P5
  if(uid != -1)
8010106a:	83 7d cc ff          	cmpl   $0xffffffff,-0x34(%ebp)
8010106e:	74 0f                	je     8010107f <exec+0x47a>
    proc->uid = uid;
80101070:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101076:	8b 55 cc             	mov    -0x34(%ebp),%edx
80101079:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
#endif
  return 0;
8010107f:	b8 00 00 00 00       	mov    $0x0,%eax
80101084:	eb 54                	jmp    801010da <exec+0x4d5>
  if(st.gid == proc->gid && st.mode.flags.g_x)
    hold = 1;
  if(st.mode.flags.o_x)
    hold = 1;
  if(hold == 0)
    goto bad;
80101086:	90                   	nop
80101087:	eb 1f                	jmp    801010a8 <exec+0x4a3>
  if(st.mode.flags.setuid)
    uid = ip->uid;
#endif
  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
80101089:	90                   	nop
8010108a:	eb 1c                	jmp    801010a8 <exec+0x4a3>
  if(elf.magic != ELF_MAGIC)
    goto bad;
8010108c:	90                   	nop
8010108d:	eb 19                	jmp    801010a8 <exec+0x4a3>

  if((pgdir = setupkvm()) == 0)
    goto bad;
8010108f:	90                   	nop
80101090:	eb 16                	jmp    801010a8 <exec+0x4a3>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80101092:	90                   	nop
80101093:	eb 13                	jmp    801010a8 <exec+0x4a3>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80101095:	90                   	nop
80101096:	eb 10                	jmp    801010a8 <exec+0x4a3>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80101098:	90                   	nop
80101099:	eb 0d                	jmp    801010a8 <exec+0x4a3>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
8010109b:	90                   	nop
8010109c:	eb 0a                	jmp    801010a8 <exec+0x4a3>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
8010109e:	90                   	nop
8010109f:	eb 07                	jmp    801010a8 <exec+0x4a3>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
801010a1:	90                   	nop
801010a2:	eb 04                	jmp    801010a8 <exec+0x4a3>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
801010a4:	90                   	nop
801010a5:	eb 01                	jmp    801010a8 <exec+0x4a3>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
801010a7:	90                   	nop
    proc->uid = uid;
#endif
  return 0;

 bad:
  if(pgdir)
801010a8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
801010ac:	74 0e                	je     801010bc <exec+0x4b7>
    freevm(pgdir);
801010ae:	83 ec 0c             	sub    $0xc,%esp
801010b1:	ff 75 d4             	pushl  -0x2c(%ebp)
801010b4:	e8 8e 8e 00 00       	call   80109f47 <freevm>
801010b9:	83 c4 10             	add    $0x10,%esp
  if(ip){
801010bc:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
801010c0:	74 13                	je     801010d5 <exec+0x4d0>
    iunlockput(ip);
801010c2:	83 ec 0c             	sub    $0xc,%esp
801010c5:	ff 75 d8             	pushl  -0x28(%ebp)
801010c8:	e8 30 0d 00 00       	call   80101dfd <iunlockput>
801010cd:	83 c4 10             	add    $0x10,%esp
    end_op();
801010d0:	e8 a3 28 00 00       	call   80103978 <end_op>
  }
  return -1;
801010d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801010da:	c9                   	leave  
801010db:	c3                   	ret    

801010dc <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
801010dc:	55                   	push   %ebp
801010dd:	89 e5                	mov    %esp,%ebp
801010df:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
801010e2:	83 ec 08             	sub    $0x8,%esp
801010e5:	68 a2 a2 10 80       	push   $0x8010a2a2
801010ea:	68 60 28 11 80       	push   $0x80112860
801010ef:	e8 f1 58 00 00       	call   801069e5 <initlock>
801010f4:	83 c4 10             	add    $0x10,%esp
}
801010f7:	90                   	nop
801010f8:	c9                   	leave  
801010f9:	c3                   	ret    

801010fa <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
801010fa:	55                   	push   %ebp
801010fb:	89 e5                	mov    %esp,%ebp
801010fd:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80101100:	83 ec 0c             	sub    $0xc,%esp
80101103:	68 60 28 11 80       	push   $0x80112860
80101108:	e8 fa 58 00 00       	call   80106a07 <acquire>
8010110d:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101110:	c7 45 f4 94 28 11 80 	movl   $0x80112894,-0xc(%ebp)
80101117:	eb 2d                	jmp    80101146 <filealloc+0x4c>
    if(f->ref == 0){
80101119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010111c:	8b 40 04             	mov    0x4(%eax),%eax
8010111f:	85 c0                	test   %eax,%eax
80101121:	75 1f                	jne    80101142 <filealloc+0x48>
      f->ref = 1;
80101123:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101126:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
8010112d:	83 ec 0c             	sub    $0xc,%esp
80101130:	68 60 28 11 80       	push   $0x80112860
80101135:	e8 34 59 00 00       	call   80106a6e <release>
8010113a:	83 c4 10             	add    $0x10,%esp
      return f;
8010113d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101140:	eb 23                	jmp    80101165 <filealloc+0x6b>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101142:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101146:	b8 f4 31 11 80       	mov    $0x801131f4,%eax
8010114b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010114e:	72 c9                	jb     80101119 <filealloc+0x1f>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80101150:	83 ec 0c             	sub    $0xc,%esp
80101153:	68 60 28 11 80       	push   $0x80112860
80101158:	e8 11 59 00 00       	call   80106a6e <release>
8010115d:	83 c4 10             	add    $0x10,%esp
  return 0;
80101160:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101165:	c9                   	leave  
80101166:	c3                   	ret    

80101167 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101167:	55                   	push   %ebp
80101168:	89 e5                	mov    %esp,%ebp
8010116a:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
8010116d:	83 ec 0c             	sub    $0xc,%esp
80101170:	68 60 28 11 80       	push   $0x80112860
80101175:	e8 8d 58 00 00       	call   80106a07 <acquire>
8010117a:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010117d:	8b 45 08             	mov    0x8(%ebp),%eax
80101180:	8b 40 04             	mov    0x4(%eax),%eax
80101183:	85 c0                	test   %eax,%eax
80101185:	7f 0d                	jg     80101194 <filedup+0x2d>
    panic("filedup");
80101187:	83 ec 0c             	sub    $0xc,%esp
8010118a:	68 a9 a2 10 80       	push   $0x8010a2a9
8010118f:	e8 d2 f3 ff ff       	call   80100566 <panic>
  f->ref++;
80101194:	8b 45 08             	mov    0x8(%ebp),%eax
80101197:	8b 40 04             	mov    0x4(%eax),%eax
8010119a:	8d 50 01             	lea    0x1(%eax),%edx
8010119d:	8b 45 08             	mov    0x8(%ebp),%eax
801011a0:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801011a3:	83 ec 0c             	sub    $0xc,%esp
801011a6:	68 60 28 11 80       	push   $0x80112860
801011ab:	e8 be 58 00 00       	call   80106a6e <release>
801011b0:	83 c4 10             	add    $0x10,%esp
  return f;
801011b3:	8b 45 08             	mov    0x8(%ebp),%eax
}
801011b6:	c9                   	leave  
801011b7:	c3                   	ret    

801011b8 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801011b8:	55                   	push   %ebp
801011b9:	89 e5                	mov    %esp,%ebp
801011bb:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801011be:	83 ec 0c             	sub    $0xc,%esp
801011c1:	68 60 28 11 80       	push   $0x80112860
801011c6:	e8 3c 58 00 00       	call   80106a07 <acquire>
801011cb:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801011ce:	8b 45 08             	mov    0x8(%ebp),%eax
801011d1:	8b 40 04             	mov    0x4(%eax),%eax
801011d4:	85 c0                	test   %eax,%eax
801011d6:	7f 0d                	jg     801011e5 <fileclose+0x2d>
    panic("fileclose");
801011d8:	83 ec 0c             	sub    $0xc,%esp
801011db:	68 b1 a2 10 80       	push   $0x8010a2b1
801011e0:	e8 81 f3 ff ff       	call   80100566 <panic>
  if(--f->ref > 0){
801011e5:	8b 45 08             	mov    0x8(%ebp),%eax
801011e8:	8b 40 04             	mov    0x4(%eax),%eax
801011eb:	8d 50 ff             	lea    -0x1(%eax),%edx
801011ee:	8b 45 08             	mov    0x8(%ebp),%eax
801011f1:	89 50 04             	mov    %edx,0x4(%eax)
801011f4:	8b 45 08             	mov    0x8(%ebp),%eax
801011f7:	8b 40 04             	mov    0x4(%eax),%eax
801011fa:	85 c0                	test   %eax,%eax
801011fc:	7e 15                	jle    80101213 <fileclose+0x5b>
    release(&ftable.lock);
801011fe:	83 ec 0c             	sub    $0xc,%esp
80101201:	68 60 28 11 80       	push   $0x80112860
80101206:	e8 63 58 00 00       	call   80106a6e <release>
8010120b:	83 c4 10             	add    $0x10,%esp
8010120e:	e9 8b 00 00 00       	jmp    8010129e <fileclose+0xe6>
    return;
  }
  ff = *f;
80101213:	8b 45 08             	mov    0x8(%ebp),%eax
80101216:	8b 10                	mov    (%eax),%edx
80101218:	89 55 e0             	mov    %edx,-0x20(%ebp)
8010121b:	8b 50 04             	mov    0x4(%eax),%edx
8010121e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101221:	8b 50 08             	mov    0x8(%eax),%edx
80101224:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101227:	8b 50 0c             	mov    0xc(%eax),%edx
8010122a:	89 55 ec             	mov    %edx,-0x14(%ebp)
8010122d:	8b 50 10             	mov    0x10(%eax),%edx
80101230:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101233:	8b 40 14             	mov    0x14(%eax),%eax
80101236:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101239:	8b 45 08             	mov    0x8(%ebp),%eax
8010123c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101243:	8b 45 08             	mov    0x8(%ebp),%eax
80101246:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010124c:	83 ec 0c             	sub    $0xc,%esp
8010124f:	68 60 28 11 80       	push   $0x80112860
80101254:	e8 15 58 00 00       	call   80106a6e <release>
80101259:	83 c4 10             	add    $0x10,%esp
  
  if(ff.type == FD_PIPE)
8010125c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010125f:	83 f8 01             	cmp    $0x1,%eax
80101262:	75 19                	jne    8010127d <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
80101264:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101268:	0f be d0             	movsbl %al,%edx
8010126b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010126e:	83 ec 08             	sub    $0x8,%esp
80101271:	52                   	push   %edx
80101272:	50                   	push   %eax
80101273:	e8 bb 32 00 00       	call   80104533 <pipeclose>
80101278:	83 c4 10             	add    $0x10,%esp
8010127b:	eb 21                	jmp    8010129e <fileclose+0xe6>
  else if(ff.type == FD_INODE){
8010127d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101280:	83 f8 02             	cmp    $0x2,%eax
80101283:	75 19                	jne    8010129e <fileclose+0xe6>
    begin_op();
80101285:	e8 62 26 00 00       	call   801038ec <begin_op>
    iput(ff.ip);
8010128a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010128d:	83 ec 0c             	sub    $0xc,%esp
80101290:	50                   	push   %eax
80101291:	e8 77 0a 00 00       	call   80101d0d <iput>
80101296:	83 c4 10             	add    $0x10,%esp
    end_op();
80101299:	e8 da 26 00 00       	call   80103978 <end_op>
  }
}
8010129e:	c9                   	leave  
8010129f:	c3                   	ret    

801012a0 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801012a0:	55                   	push   %ebp
801012a1:	89 e5                	mov    %esp,%ebp
801012a3:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
801012a6:	8b 45 08             	mov    0x8(%ebp),%eax
801012a9:	8b 00                	mov    (%eax),%eax
801012ab:	83 f8 02             	cmp    $0x2,%eax
801012ae:	75 40                	jne    801012f0 <filestat+0x50>
    ilock(f->ip);
801012b0:	8b 45 08             	mov    0x8(%ebp),%eax
801012b3:	8b 40 10             	mov    0x10(%eax),%eax
801012b6:	83 ec 0c             	sub    $0xc,%esp
801012b9:	50                   	push   %eax
801012ba:	e8 56 08 00 00       	call   80101b15 <ilock>
801012bf:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801012c2:	8b 45 08             	mov    0x8(%ebp),%eax
801012c5:	8b 40 10             	mov    0x10(%eax),%eax
801012c8:	83 ec 08             	sub    $0x8,%esp
801012cb:	ff 75 0c             	pushl  0xc(%ebp)
801012ce:	50                   	push   %eax
801012cf:	e8 91 0d 00 00       	call   80102065 <stati>
801012d4:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801012d7:	8b 45 08             	mov    0x8(%ebp),%eax
801012da:	8b 40 10             	mov    0x10(%eax),%eax
801012dd:	83 ec 0c             	sub    $0xc,%esp
801012e0:	50                   	push   %eax
801012e1:	e8 b5 09 00 00       	call   80101c9b <iunlock>
801012e6:	83 c4 10             	add    $0x10,%esp
    return 0;
801012e9:	b8 00 00 00 00       	mov    $0x0,%eax
801012ee:	eb 05                	jmp    801012f5 <filestat+0x55>
  }
  return -1;
801012f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801012f5:	c9                   	leave  
801012f6:	c3                   	ret    

801012f7 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801012f7:	55                   	push   %ebp
801012f8:	89 e5                	mov    %esp,%ebp
801012fa:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801012fd:	8b 45 08             	mov    0x8(%ebp),%eax
80101300:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101304:	84 c0                	test   %al,%al
80101306:	75 0a                	jne    80101312 <fileread+0x1b>
    return -1;
80101308:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010130d:	e9 9b 00 00 00       	jmp    801013ad <fileread+0xb6>
  if(f->type == FD_PIPE)
80101312:	8b 45 08             	mov    0x8(%ebp),%eax
80101315:	8b 00                	mov    (%eax),%eax
80101317:	83 f8 01             	cmp    $0x1,%eax
8010131a:	75 1a                	jne    80101336 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
8010131c:	8b 45 08             	mov    0x8(%ebp),%eax
8010131f:	8b 40 0c             	mov    0xc(%eax),%eax
80101322:	83 ec 04             	sub    $0x4,%esp
80101325:	ff 75 10             	pushl  0x10(%ebp)
80101328:	ff 75 0c             	pushl  0xc(%ebp)
8010132b:	50                   	push   %eax
8010132c:	e8 aa 33 00 00       	call   801046db <piperead>
80101331:	83 c4 10             	add    $0x10,%esp
80101334:	eb 77                	jmp    801013ad <fileread+0xb6>
  if(f->type == FD_INODE){
80101336:	8b 45 08             	mov    0x8(%ebp),%eax
80101339:	8b 00                	mov    (%eax),%eax
8010133b:	83 f8 02             	cmp    $0x2,%eax
8010133e:	75 60                	jne    801013a0 <fileread+0xa9>
    ilock(f->ip);
80101340:	8b 45 08             	mov    0x8(%ebp),%eax
80101343:	8b 40 10             	mov    0x10(%eax),%eax
80101346:	83 ec 0c             	sub    $0xc,%esp
80101349:	50                   	push   %eax
8010134a:	e8 c6 07 00 00       	call   80101b15 <ilock>
8010134f:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101352:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101355:	8b 45 08             	mov    0x8(%ebp),%eax
80101358:	8b 50 14             	mov    0x14(%eax),%edx
8010135b:	8b 45 08             	mov    0x8(%ebp),%eax
8010135e:	8b 40 10             	mov    0x10(%eax),%eax
80101361:	51                   	push   %ecx
80101362:	52                   	push   %edx
80101363:	ff 75 0c             	pushl  0xc(%ebp)
80101366:	50                   	push   %eax
80101367:	e8 67 0d 00 00       	call   801020d3 <readi>
8010136c:	83 c4 10             	add    $0x10,%esp
8010136f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101372:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101376:	7e 11                	jle    80101389 <fileread+0x92>
      f->off += r;
80101378:	8b 45 08             	mov    0x8(%ebp),%eax
8010137b:	8b 50 14             	mov    0x14(%eax),%edx
8010137e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101381:	01 c2                	add    %eax,%edx
80101383:	8b 45 08             	mov    0x8(%ebp),%eax
80101386:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101389:	8b 45 08             	mov    0x8(%ebp),%eax
8010138c:	8b 40 10             	mov    0x10(%eax),%eax
8010138f:	83 ec 0c             	sub    $0xc,%esp
80101392:	50                   	push   %eax
80101393:	e8 03 09 00 00       	call   80101c9b <iunlock>
80101398:	83 c4 10             	add    $0x10,%esp
    return r;
8010139b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010139e:	eb 0d                	jmp    801013ad <fileread+0xb6>
  }
  panic("fileread");
801013a0:	83 ec 0c             	sub    $0xc,%esp
801013a3:	68 bb a2 10 80       	push   $0x8010a2bb
801013a8:	e8 b9 f1 ff ff       	call   80100566 <panic>
}
801013ad:	c9                   	leave  
801013ae:	c3                   	ret    

801013af <filewrite>:

// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801013af:	55                   	push   %ebp
801013b0:	89 e5                	mov    %esp,%ebp
801013b2:	53                   	push   %ebx
801013b3:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
801013b6:	8b 45 08             	mov    0x8(%ebp),%eax
801013b9:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801013bd:	84 c0                	test   %al,%al
801013bf:	75 0a                	jne    801013cb <filewrite+0x1c>
    return -1;
801013c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013c6:	e9 1b 01 00 00       	jmp    801014e6 <filewrite+0x137>
  if(f->type == FD_PIPE)
801013cb:	8b 45 08             	mov    0x8(%ebp),%eax
801013ce:	8b 00                	mov    (%eax),%eax
801013d0:	83 f8 01             	cmp    $0x1,%eax
801013d3:	75 1d                	jne    801013f2 <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
801013d5:	8b 45 08             	mov    0x8(%ebp),%eax
801013d8:	8b 40 0c             	mov    0xc(%eax),%eax
801013db:	83 ec 04             	sub    $0x4,%esp
801013de:	ff 75 10             	pushl  0x10(%ebp)
801013e1:	ff 75 0c             	pushl  0xc(%ebp)
801013e4:	50                   	push   %eax
801013e5:	e8 f3 31 00 00       	call   801045dd <pipewrite>
801013ea:	83 c4 10             	add    $0x10,%esp
801013ed:	e9 f4 00 00 00       	jmp    801014e6 <filewrite+0x137>
  if(f->type == FD_INODE){
801013f2:	8b 45 08             	mov    0x8(%ebp),%eax
801013f5:	8b 00                	mov    (%eax),%eax
801013f7:	83 f8 02             	cmp    $0x2,%eax
801013fa:	0f 85 d9 00 00 00    	jne    801014d9 <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
80101400:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
80101407:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
8010140e:	e9 a3 00 00 00       	jmp    801014b6 <filewrite+0x107>
      int n1 = n - i;
80101413:	8b 45 10             	mov    0x10(%ebp),%eax
80101416:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101419:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
8010141c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010141f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101422:	7e 06                	jle    8010142a <filewrite+0x7b>
        n1 = max;
80101424:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101427:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010142a:	e8 bd 24 00 00       	call   801038ec <begin_op>
      ilock(f->ip);
8010142f:	8b 45 08             	mov    0x8(%ebp),%eax
80101432:	8b 40 10             	mov    0x10(%eax),%eax
80101435:	83 ec 0c             	sub    $0xc,%esp
80101438:	50                   	push   %eax
80101439:	e8 d7 06 00 00       	call   80101b15 <ilock>
8010143e:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101441:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101444:	8b 45 08             	mov    0x8(%ebp),%eax
80101447:	8b 50 14             	mov    0x14(%eax),%edx
8010144a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010144d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101450:	01 c3                	add    %eax,%ebx
80101452:	8b 45 08             	mov    0x8(%ebp),%eax
80101455:	8b 40 10             	mov    0x10(%eax),%eax
80101458:	51                   	push   %ecx
80101459:	52                   	push   %edx
8010145a:	53                   	push   %ebx
8010145b:	50                   	push   %eax
8010145c:	e8 c9 0d 00 00       	call   8010222a <writei>
80101461:	83 c4 10             	add    $0x10,%esp
80101464:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101467:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010146b:	7e 11                	jle    8010147e <filewrite+0xcf>
        f->off += r;
8010146d:	8b 45 08             	mov    0x8(%ebp),%eax
80101470:	8b 50 14             	mov    0x14(%eax),%edx
80101473:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101476:	01 c2                	add    %eax,%edx
80101478:	8b 45 08             	mov    0x8(%ebp),%eax
8010147b:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
8010147e:	8b 45 08             	mov    0x8(%ebp),%eax
80101481:	8b 40 10             	mov    0x10(%eax),%eax
80101484:	83 ec 0c             	sub    $0xc,%esp
80101487:	50                   	push   %eax
80101488:	e8 0e 08 00 00       	call   80101c9b <iunlock>
8010148d:	83 c4 10             	add    $0x10,%esp
      end_op();
80101490:	e8 e3 24 00 00       	call   80103978 <end_op>

      if(r < 0)
80101495:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101499:	78 29                	js     801014c4 <filewrite+0x115>
        break;
      if(r != n1)
8010149b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010149e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801014a1:	74 0d                	je     801014b0 <filewrite+0x101>
        panic("short filewrite");
801014a3:	83 ec 0c             	sub    $0xc,%esp
801014a6:	68 c4 a2 10 80       	push   $0x8010a2c4
801014ab:	e8 b6 f0 ff ff       	call   80100566 <panic>
      i += r;
801014b0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801014b3:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801014b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014b9:	3b 45 10             	cmp    0x10(%ebp),%eax
801014bc:	0f 8c 51 ff ff ff    	jl     80101413 <filewrite+0x64>
801014c2:	eb 01                	jmp    801014c5 <filewrite+0x116>
        f->off += r;
      iunlock(f->ip);
      end_op();

      if(r < 0)
        break;
801014c4:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801014c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014c8:	3b 45 10             	cmp    0x10(%ebp),%eax
801014cb:	75 05                	jne    801014d2 <filewrite+0x123>
801014cd:	8b 45 10             	mov    0x10(%ebp),%eax
801014d0:	eb 14                	jmp    801014e6 <filewrite+0x137>
801014d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801014d7:	eb 0d                	jmp    801014e6 <filewrite+0x137>
  }
  panic("filewrite");
801014d9:	83 ec 0c             	sub    $0xc,%esp
801014dc:	68 d4 a2 10 80       	push   $0x8010a2d4
801014e1:	e8 80 f0 ff ff       	call   80100566 <panic>
}
801014e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801014e9:	c9                   	leave  
801014ea:	c3                   	ret    

801014eb <readsb>:
struct superblock sb;   // there should be one per dev, but we run with one dev

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801014eb:	55                   	push   %ebp
801014ec:	89 e5                	mov    %esp,%ebp
801014ee:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
801014f1:	8b 45 08             	mov    0x8(%ebp),%eax
801014f4:	83 ec 08             	sub    $0x8,%esp
801014f7:	6a 01                	push   $0x1
801014f9:	50                   	push   %eax
801014fa:	e8 b7 ec ff ff       	call   801001b6 <bread>
801014ff:	83 c4 10             	add    $0x10,%esp
80101502:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101505:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101508:	83 c0 18             	add    $0x18,%eax
8010150b:	83 ec 04             	sub    $0x4,%esp
8010150e:	6a 1c                	push   $0x1c
80101510:	50                   	push   %eax
80101511:	ff 75 0c             	pushl  0xc(%ebp)
80101514:	e8 10 58 00 00       	call   80106d29 <memmove>
80101519:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010151c:	83 ec 0c             	sub    $0xc,%esp
8010151f:	ff 75 f4             	pushl  -0xc(%ebp)
80101522:	e8 07 ed ff ff       	call   8010022e <brelse>
80101527:	83 c4 10             	add    $0x10,%esp
}
8010152a:	90                   	nop
8010152b:	c9                   	leave  
8010152c:	c3                   	ret    

8010152d <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
8010152d:	55                   	push   %ebp
8010152e:	89 e5                	mov    %esp,%ebp
80101530:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
80101533:	8b 55 0c             	mov    0xc(%ebp),%edx
80101536:	8b 45 08             	mov    0x8(%ebp),%eax
80101539:	83 ec 08             	sub    $0x8,%esp
8010153c:	52                   	push   %edx
8010153d:	50                   	push   %eax
8010153e:	e8 73 ec ff ff       	call   801001b6 <bread>
80101543:	83 c4 10             	add    $0x10,%esp
80101546:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101549:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010154c:	83 c0 18             	add    $0x18,%eax
8010154f:	83 ec 04             	sub    $0x4,%esp
80101552:	68 00 02 00 00       	push   $0x200
80101557:	6a 00                	push   $0x0
80101559:	50                   	push   %eax
8010155a:	e8 0b 57 00 00       	call   80106c6a <memset>
8010155f:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101562:	83 ec 0c             	sub    $0xc,%esp
80101565:	ff 75 f4             	pushl  -0xc(%ebp)
80101568:	e8 b7 25 00 00       	call   80103b24 <log_write>
8010156d:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101570:	83 ec 0c             	sub    $0xc,%esp
80101573:	ff 75 f4             	pushl  -0xc(%ebp)
80101576:	e8 b3 ec ff ff       	call   8010022e <brelse>
8010157b:	83 c4 10             	add    $0x10,%esp
}
8010157e:	90                   	nop
8010157f:	c9                   	leave  
80101580:	c3                   	ret    

80101581 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101581:	55                   	push   %ebp
80101582:	89 e5                	mov    %esp,%ebp
80101584:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101587:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
8010158e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101595:	e9 13 01 00 00       	jmp    801016ad <balloc+0x12c>
    bp = bread(dev, BBLOCK(b, sb));
8010159a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010159d:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801015a3:	85 c0                	test   %eax,%eax
801015a5:	0f 48 c2             	cmovs  %edx,%eax
801015a8:	c1 f8 0c             	sar    $0xc,%eax
801015ab:	89 c2                	mov    %eax,%edx
801015ad:	a1 78 32 11 80       	mov    0x80113278,%eax
801015b2:	01 d0                	add    %edx,%eax
801015b4:	83 ec 08             	sub    $0x8,%esp
801015b7:	50                   	push   %eax
801015b8:	ff 75 08             	pushl  0x8(%ebp)
801015bb:	e8 f6 eb ff ff       	call   801001b6 <bread>
801015c0:	83 c4 10             	add    $0x10,%esp
801015c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801015c6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801015cd:	e9 a6 00 00 00       	jmp    80101678 <balloc+0xf7>
      m = 1 << (bi % 8);
801015d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015d5:	99                   	cltd   
801015d6:	c1 ea 1d             	shr    $0x1d,%edx
801015d9:	01 d0                	add    %edx,%eax
801015db:	83 e0 07             	and    $0x7,%eax
801015de:	29 d0                	sub    %edx,%eax
801015e0:	ba 01 00 00 00       	mov    $0x1,%edx
801015e5:	89 c1                	mov    %eax,%ecx
801015e7:	d3 e2                	shl    %cl,%edx
801015e9:	89 d0                	mov    %edx,%eax
801015eb:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801015ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015f1:	8d 50 07             	lea    0x7(%eax),%edx
801015f4:	85 c0                	test   %eax,%eax
801015f6:	0f 48 c2             	cmovs  %edx,%eax
801015f9:	c1 f8 03             	sar    $0x3,%eax
801015fc:	89 c2                	mov    %eax,%edx
801015fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101601:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
80101606:	0f b6 c0             	movzbl %al,%eax
80101609:	23 45 e8             	and    -0x18(%ebp),%eax
8010160c:	85 c0                	test   %eax,%eax
8010160e:	75 64                	jne    80101674 <balloc+0xf3>
        bp->data[bi/8] |= m;  // Mark block in use.
80101610:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101613:	8d 50 07             	lea    0x7(%eax),%edx
80101616:	85 c0                	test   %eax,%eax
80101618:	0f 48 c2             	cmovs  %edx,%eax
8010161b:	c1 f8 03             	sar    $0x3,%eax
8010161e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101621:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101626:	89 d1                	mov    %edx,%ecx
80101628:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010162b:	09 ca                	or     %ecx,%edx
8010162d:	89 d1                	mov    %edx,%ecx
8010162f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101632:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
80101636:	83 ec 0c             	sub    $0xc,%esp
80101639:	ff 75 ec             	pushl  -0x14(%ebp)
8010163c:	e8 e3 24 00 00       	call   80103b24 <log_write>
80101641:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101644:	83 ec 0c             	sub    $0xc,%esp
80101647:	ff 75 ec             	pushl  -0x14(%ebp)
8010164a:	e8 df eb ff ff       	call   8010022e <brelse>
8010164f:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
80101652:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101655:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101658:	01 c2                	add    %eax,%edx
8010165a:	8b 45 08             	mov    0x8(%ebp),%eax
8010165d:	83 ec 08             	sub    $0x8,%esp
80101660:	52                   	push   %edx
80101661:	50                   	push   %eax
80101662:	e8 c6 fe ff ff       	call   8010152d <bzero>
80101667:	83 c4 10             	add    $0x10,%esp
        return b + bi;
8010166a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010166d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101670:	01 d0                	add    %edx,%eax
80101672:	eb 57                	jmp    801016cb <balloc+0x14a>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101674:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101678:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
8010167f:	7f 17                	jg     80101698 <balloc+0x117>
80101681:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101684:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101687:	01 d0                	add    %edx,%eax
80101689:	89 c2                	mov    %eax,%edx
8010168b:	a1 60 32 11 80       	mov    0x80113260,%eax
80101690:	39 c2                	cmp    %eax,%edx
80101692:	0f 82 3a ff ff ff    	jb     801015d2 <balloc+0x51>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
80101698:	83 ec 0c             	sub    $0xc,%esp
8010169b:	ff 75 ec             	pushl  -0x14(%ebp)
8010169e:	e8 8b eb ff ff       	call   8010022e <brelse>
801016a3:	83 c4 10             	add    $0x10,%esp
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
801016a6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801016ad:	8b 15 60 32 11 80    	mov    0x80113260,%edx
801016b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016b6:	39 c2                	cmp    %eax,%edx
801016b8:	0f 87 dc fe ff ff    	ja     8010159a <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801016be:	83 ec 0c             	sub    $0xc,%esp
801016c1:	68 e0 a2 10 80       	push   $0x8010a2e0
801016c6:	e8 9b ee ff ff       	call   80100566 <panic>
}
801016cb:	c9                   	leave  
801016cc:	c3                   	ret    

801016cd <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801016cd:	55                   	push   %ebp
801016ce:	89 e5                	mov    %esp,%ebp
801016d0:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
801016d3:	83 ec 08             	sub    $0x8,%esp
801016d6:	68 60 32 11 80       	push   $0x80113260
801016db:	ff 75 08             	pushl  0x8(%ebp)
801016de:	e8 08 fe ff ff       	call   801014eb <readsb>
801016e3:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801016e6:	8b 45 0c             	mov    0xc(%ebp),%eax
801016e9:	c1 e8 0c             	shr    $0xc,%eax
801016ec:	89 c2                	mov    %eax,%edx
801016ee:	a1 78 32 11 80       	mov    0x80113278,%eax
801016f3:	01 c2                	add    %eax,%edx
801016f5:	8b 45 08             	mov    0x8(%ebp),%eax
801016f8:	83 ec 08             	sub    $0x8,%esp
801016fb:	52                   	push   %edx
801016fc:	50                   	push   %eax
801016fd:	e8 b4 ea ff ff       	call   801001b6 <bread>
80101702:	83 c4 10             	add    $0x10,%esp
80101705:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101708:	8b 45 0c             	mov    0xc(%ebp),%eax
8010170b:	25 ff 0f 00 00       	and    $0xfff,%eax
80101710:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101713:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101716:	99                   	cltd   
80101717:	c1 ea 1d             	shr    $0x1d,%edx
8010171a:	01 d0                	add    %edx,%eax
8010171c:	83 e0 07             	and    $0x7,%eax
8010171f:	29 d0                	sub    %edx,%eax
80101721:	ba 01 00 00 00       	mov    $0x1,%edx
80101726:	89 c1                	mov    %eax,%ecx
80101728:	d3 e2                	shl    %cl,%edx
8010172a:	89 d0                	mov    %edx,%eax
8010172c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
8010172f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101732:	8d 50 07             	lea    0x7(%eax),%edx
80101735:	85 c0                	test   %eax,%eax
80101737:	0f 48 c2             	cmovs  %edx,%eax
8010173a:	c1 f8 03             	sar    $0x3,%eax
8010173d:	89 c2                	mov    %eax,%edx
8010173f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101742:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
80101747:	0f b6 c0             	movzbl %al,%eax
8010174a:	23 45 ec             	and    -0x14(%ebp),%eax
8010174d:	85 c0                	test   %eax,%eax
8010174f:	75 0d                	jne    8010175e <bfree+0x91>
    panic("freeing free block");
80101751:	83 ec 0c             	sub    $0xc,%esp
80101754:	68 f6 a2 10 80       	push   $0x8010a2f6
80101759:	e8 08 ee ff ff       	call   80100566 <panic>
  bp->data[bi/8] &= ~m;
8010175e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101761:	8d 50 07             	lea    0x7(%eax),%edx
80101764:	85 c0                	test   %eax,%eax
80101766:	0f 48 c2             	cmovs  %edx,%eax
80101769:	c1 f8 03             	sar    $0x3,%eax
8010176c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010176f:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101774:	89 d1                	mov    %edx,%ecx
80101776:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101779:	f7 d2                	not    %edx
8010177b:	21 ca                	and    %ecx,%edx
8010177d:	89 d1                	mov    %edx,%ecx
8010177f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101782:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
80101786:	83 ec 0c             	sub    $0xc,%esp
80101789:	ff 75 f4             	pushl  -0xc(%ebp)
8010178c:	e8 93 23 00 00       	call   80103b24 <log_write>
80101791:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101794:	83 ec 0c             	sub    $0xc,%esp
80101797:	ff 75 f4             	pushl  -0xc(%ebp)
8010179a:	e8 8f ea ff ff       	call   8010022e <brelse>
8010179f:	83 c4 10             	add    $0x10,%esp
}
801017a2:	90                   	nop
801017a3:	c9                   	leave  
801017a4:	c3                   	ret    

801017a5 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
801017a5:	55                   	push   %ebp
801017a6:	89 e5                	mov    %esp,%ebp
801017a8:	57                   	push   %edi
801017a9:	56                   	push   %esi
801017aa:	53                   	push   %ebx
801017ab:	83 ec 1c             	sub    $0x1c,%esp
  initlock(&icache.lock, "icache");
801017ae:	83 ec 08             	sub    $0x8,%esp
801017b1:	68 09 a3 10 80       	push   $0x8010a309
801017b6:	68 80 32 11 80       	push   $0x80113280
801017bb:	e8 25 52 00 00       	call   801069e5 <initlock>
801017c0:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
801017c3:	83 ec 08             	sub    $0x8,%esp
801017c6:	68 60 32 11 80       	push   $0x80113260
801017cb:	ff 75 08             	pushl  0x8(%ebp)
801017ce:	e8 18 fd ff ff       	call   801014eb <readsb>
801017d3:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n", sb.size,
801017d6:	a1 78 32 11 80       	mov    0x80113278,%eax
801017db:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801017de:	8b 3d 74 32 11 80    	mov    0x80113274,%edi
801017e4:	8b 35 70 32 11 80    	mov    0x80113270,%esi
801017ea:	8b 1d 6c 32 11 80    	mov    0x8011326c,%ebx
801017f0:	8b 0d 68 32 11 80    	mov    0x80113268,%ecx
801017f6:	8b 15 64 32 11 80    	mov    0x80113264,%edx
801017fc:	a1 60 32 11 80       	mov    0x80113260,%eax
80101801:	ff 75 e4             	pushl  -0x1c(%ebp)
80101804:	57                   	push   %edi
80101805:	56                   	push   %esi
80101806:	53                   	push   %ebx
80101807:	51                   	push   %ecx
80101808:	52                   	push   %edx
80101809:	50                   	push   %eax
8010180a:	68 10 a3 10 80       	push   $0x8010a310
8010180f:	e8 b2 eb ff ff       	call   801003c6 <cprintf>
80101814:	83 c4 20             	add    $0x20,%esp
          sb.nblocks, sb.ninodes, sb.nlog, sb.logstart, sb.inodestart, sb.bmapstart);
}
80101817:	90                   	nop
80101818:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010181b:	5b                   	pop    %ebx
8010181c:	5e                   	pop    %esi
8010181d:	5f                   	pop    %edi
8010181e:	5d                   	pop    %ebp
8010181f:	c3                   	ret    

80101820 <ialloc>:

// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
80101820:	55                   	push   %ebp
80101821:	89 e5                	mov    %esp,%ebp
80101823:	83 ec 28             	sub    $0x28,%esp
80101826:	8b 45 0c             	mov    0xc(%ebp),%eax
80101829:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010182d:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101834:	e9 ba 00 00 00       	jmp    801018f3 <ialloc+0xd3>
    bp = bread(dev, IBLOCK(inum, sb));
80101839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010183c:	c1 e8 03             	shr    $0x3,%eax
8010183f:	89 c2                	mov    %eax,%edx
80101841:	a1 74 32 11 80       	mov    0x80113274,%eax
80101846:	01 d0                	add    %edx,%eax
80101848:	83 ec 08             	sub    $0x8,%esp
8010184b:	50                   	push   %eax
8010184c:	ff 75 08             	pushl  0x8(%ebp)
8010184f:	e8 62 e9 ff ff       	call   801001b6 <bread>
80101854:	83 c4 10             	add    $0x10,%esp
80101857:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
8010185a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010185d:	8d 50 18             	lea    0x18(%eax),%edx
80101860:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101863:	83 e0 07             	and    $0x7,%eax
80101866:	c1 e0 06             	shl    $0x6,%eax
80101869:	01 d0                	add    %edx,%eax
8010186b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010186e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101871:	0f b7 00             	movzwl (%eax),%eax
80101874:	66 85 c0             	test   %ax,%ax
80101877:	75 68                	jne    801018e1 <ialloc+0xc1>
      memset(dip, 0, sizeof(*dip));
80101879:	83 ec 04             	sub    $0x4,%esp
8010187c:	6a 40                	push   $0x40
8010187e:	6a 00                	push   $0x0
80101880:	ff 75 ec             	pushl  -0x14(%ebp)
80101883:	e8 e2 53 00 00       	call   80106c6a <memset>
80101888:	83 c4 10             	add    $0x10,%esp
      dip->type = type; 
8010188b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010188e:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
80101892:	66 89 10             	mov    %dx,(%eax)
#ifdef CS333_P5
      dip->uid = DEFAULT_UID;
80101895:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101898:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
      dip->gid = DEFAULT_GID;
8010189e:	8b 45 ec             	mov    -0x14(%ebp),%eax
801018a1:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
      dip->mode.asInt = DEFAULT_MODE;
801018a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801018aa:	c7 40 0c ed 01 00 00 	movl   $0x1ed,0xc(%eax)
#endif
      log_write(bp);   // mark it allocated on the disk
801018b1:	83 ec 0c             	sub    $0xc,%esp
801018b4:	ff 75 f0             	pushl  -0x10(%ebp)
801018b7:	e8 68 22 00 00       	call   80103b24 <log_write>
801018bc:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801018bf:	83 ec 0c             	sub    $0xc,%esp
801018c2:	ff 75 f0             	pushl  -0x10(%ebp)
801018c5:	e8 64 e9 ff ff       	call   8010022e <brelse>
801018ca:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801018cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018d0:	83 ec 08             	sub    $0x8,%esp
801018d3:	50                   	push   %eax
801018d4:	ff 75 08             	pushl  0x8(%ebp)
801018d7:	e8 20 01 00 00       	call   801019fc <iget>
801018dc:	83 c4 10             	add    $0x10,%esp
801018df:	eb 30                	jmp    80101911 <ialloc+0xf1>
    }
    brelse(bp);
801018e1:	83 ec 0c             	sub    $0xc,%esp
801018e4:	ff 75 f0             	pushl  -0x10(%ebp)
801018e7:	e8 42 e9 ff ff       	call   8010022e <brelse>
801018ec:	83 c4 10             	add    $0x10,%esp
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801018ef:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801018f3:	8b 15 68 32 11 80    	mov    0x80113268,%edx
801018f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018fc:	39 c2                	cmp    %eax,%edx
801018fe:	0f 87 35 ff ff ff    	ja     80101839 <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101904:	83 ec 0c             	sub    $0xc,%esp
80101907:	68 63 a3 10 80       	push   $0x8010a363
8010190c:	e8 55 ec ff ff       	call   80100566 <panic>
}
80101911:	c9                   	leave  
80101912:	c3                   	ret    

80101913 <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101913:	55                   	push   %ebp
80101914:	89 e5                	mov    %esp,%ebp
80101916:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101919:	8b 45 08             	mov    0x8(%ebp),%eax
8010191c:	8b 40 04             	mov    0x4(%eax),%eax
8010191f:	c1 e8 03             	shr    $0x3,%eax
80101922:	89 c2                	mov    %eax,%edx
80101924:	a1 74 32 11 80       	mov    0x80113274,%eax
80101929:	01 c2                	add    %eax,%edx
8010192b:	8b 45 08             	mov    0x8(%ebp),%eax
8010192e:	8b 00                	mov    (%eax),%eax
80101930:	83 ec 08             	sub    $0x8,%esp
80101933:	52                   	push   %edx
80101934:	50                   	push   %eax
80101935:	e8 7c e8 ff ff       	call   801001b6 <bread>
8010193a:	83 c4 10             	add    $0x10,%esp
8010193d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101940:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101943:	8d 50 18             	lea    0x18(%eax),%edx
80101946:	8b 45 08             	mov    0x8(%ebp),%eax
80101949:	8b 40 04             	mov    0x4(%eax),%eax
8010194c:	83 e0 07             	and    $0x7,%eax
8010194f:	c1 e0 06             	shl    $0x6,%eax
80101952:	01 d0                	add    %edx,%eax
80101954:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101957:	8b 45 08             	mov    0x8(%ebp),%eax
8010195a:	0f b7 50 10          	movzwl 0x10(%eax),%edx
8010195e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101961:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101964:	8b 45 08             	mov    0x8(%ebp),%eax
80101967:	0f b7 50 12          	movzwl 0x12(%eax),%edx
8010196b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010196e:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101972:	8b 45 08             	mov    0x8(%ebp),%eax
80101975:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101979:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010197c:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101980:	8b 45 08             	mov    0x8(%ebp),%eax
80101983:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101987:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010198a:	66 89 50 06          	mov    %dx,0x6(%eax)
#ifdef CS333_P5
  dip->uid = ip->uid;
8010198e:	8b 45 08             	mov    0x8(%ebp),%eax
80101991:	0f b7 50 18          	movzwl 0x18(%eax),%edx
80101995:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101998:	66 89 50 08          	mov    %dx,0x8(%eax)
  dip->gid = ip->gid;
8010199c:	8b 45 08             	mov    0x8(%ebp),%eax
8010199f:	0f b7 50 1a          	movzwl 0x1a(%eax),%edx
801019a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019a6:	66 89 50 0a          	mov    %dx,0xa(%eax)
  dip->mode.asInt = ip->mode.asInt;
801019aa:	8b 45 08             	mov    0x8(%ebp),%eax
801019ad:	8b 50 1c             	mov    0x1c(%eax),%edx
801019b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019b3:	89 50 0c             	mov    %edx,0xc(%eax)
#endif
  dip->size = ip->size;
801019b6:	8b 45 08             	mov    0x8(%ebp),%eax
801019b9:	8b 50 20             	mov    0x20(%eax),%edx
801019bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019bf:	89 50 10             	mov    %edx,0x10(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801019c2:	8b 45 08             	mov    0x8(%ebp),%eax
801019c5:	8d 50 24             	lea    0x24(%eax),%edx
801019c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019cb:	83 c0 14             	add    $0x14,%eax
801019ce:	83 ec 04             	sub    $0x4,%esp
801019d1:	6a 2c                	push   $0x2c
801019d3:	52                   	push   %edx
801019d4:	50                   	push   %eax
801019d5:	e8 4f 53 00 00       	call   80106d29 <memmove>
801019da:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801019dd:	83 ec 0c             	sub    $0xc,%esp
801019e0:	ff 75 f4             	pushl  -0xc(%ebp)
801019e3:	e8 3c 21 00 00       	call   80103b24 <log_write>
801019e8:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801019eb:	83 ec 0c             	sub    $0xc,%esp
801019ee:	ff 75 f4             	pushl  -0xc(%ebp)
801019f1:	e8 38 e8 ff ff       	call   8010022e <brelse>
801019f6:	83 c4 10             	add    $0x10,%esp
}
801019f9:	90                   	nop
801019fa:	c9                   	leave  
801019fb:	c3                   	ret    

801019fc <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801019fc:	55                   	push   %ebp
801019fd:	89 e5                	mov    %esp,%ebp
801019ff:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101a02:	83 ec 0c             	sub    $0xc,%esp
80101a05:	68 80 32 11 80       	push   $0x80113280
80101a0a:	e8 f8 4f 00 00       	call   80106a07 <acquire>
80101a0f:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101a12:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a19:	c7 45 f4 b4 32 11 80 	movl   $0x801132b4,-0xc(%ebp)
80101a20:	eb 5d                	jmp    80101a7f <iget+0x83>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101a22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a25:	8b 40 08             	mov    0x8(%eax),%eax
80101a28:	85 c0                	test   %eax,%eax
80101a2a:	7e 39                	jle    80101a65 <iget+0x69>
80101a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a2f:	8b 00                	mov    (%eax),%eax
80101a31:	3b 45 08             	cmp    0x8(%ebp),%eax
80101a34:	75 2f                	jne    80101a65 <iget+0x69>
80101a36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a39:	8b 40 04             	mov    0x4(%eax),%eax
80101a3c:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101a3f:	75 24                	jne    80101a65 <iget+0x69>
      ip->ref++;
80101a41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a44:	8b 40 08             	mov    0x8(%eax),%eax
80101a47:	8d 50 01             	lea    0x1(%eax),%edx
80101a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a4d:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101a50:	83 ec 0c             	sub    $0xc,%esp
80101a53:	68 80 32 11 80       	push   $0x80113280
80101a58:	e8 11 50 00 00       	call   80106a6e <release>
80101a5d:	83 c4 10             	add    $0x10,%esp
      return ip;
80101a60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a63:	eb 74                	jmp    80101ad9 <iget+0xdd>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101a65:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a69:	75 10                	jne    80101a7b <iget+0x7f>
80101a6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a6e:	8b 40 08             	mov    0x8(%eax),%eax
80101a71:	85 c0                	test   %eax,%eax
80101a73:	75 06                	jne    80101a7b <iget+0x7f>
      empty = ip;
80101a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a78:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a7b:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
80101a7f:	81 7d f4 54 42 11 80 	cmpl   $0x80114254,-0xc(%ebp)
80101a86:	72 9a                	jb     80101a22 <iget+0x26>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101a88:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a8c:	75 0d                	jne    80101a9b <iget+0x9f>
    panic("iget: no inodes");
80101a8e:	83 ec 0c             	sub    $0xc,%esp
80101a91:	68 75 a3 10 80       	push   $0x8010a375
80101a96:	e8 cb ea ff ff       	call   80100566 <panic>

  ip = empty;
80101a9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a9e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101aa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aa4:	8b 55 08             	mov    0x8(%ebp),%edx
80101aa7:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101aa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aac:	8b 55 0c             	mov    0xc(%ebp),%edx
80101aaf:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101ab2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ab5:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101abc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101abf:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101ac6:	83 ec 0c             	sub    $0xc,%esp
80101ac9:	68 80 32 11 80       	push   $0x80113280
80101ace:	e8 9b 4f 00 00       	call   80106a6e <release>
80101ad3:	83 c4 10             	add    $0x10,%esp

  return ip;
80101ad6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101ad9:	c9                   	leave  
80101ada:	c3                   	ret    

80101adb <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101adb:	55                   	push   %ebp
80101adc:	89 e5                	mov    %esp,%ebp
80101ade:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101ae1:	83 ec 0c             	sub    $0xc,%esp
80101ae4:	68 80 32 11 80       	push   $0x80113280
80101ae9:	e8 19 4f 00 00       	call   80106a07 <acquire>
80101aee:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101af1:	8b 45 08             	mov    0x8(%ebp),%eax
80101af4:	8b 40 08             	mov    0x8(%eax),%eax
80101af7:	8d 50 01             	lea    0x1(%eax),%edx
80101afa:	8b 45 08             	mov    0x8(%ebp),%eax
80101afd:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101b00:	83 ec 0c             	sub    $0xc,%esp
80101b03:	68 80 32 11 80       	push   $0x80113280
80101b08:	e8 61 4f 00 00       	call   80106a6e <release>
80101b0d:	83 c4 10             	add    $0x10,%esp
  return ip;
80101b10:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101b13:	c9                   	leave  
80101b14:	c3                   	ret    

80101b15 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101b15:	55                   	push   %ebp
80101b16:	89 e5                	mov    %esp,%ebp
80101b18:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101b1b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b1f:	74 0a                	je     80101b2b <ilock+0x16>
80101b21:	8b 45 08             	mov    0x8(%ebp),%eax
80101b24:	8b 40 08             	mov    0x8(%eax),%eax
80101b27:	85 c0                	test   %eax,%eax
80101b29:	7f 0d                	jg     80101b38 <ilock+0x23>
    panic("ilock");
80101b2b:	83 ec 0c             	sub    $0xc,%esp
80101b2e:	68 85 a3 10 80       	push   $0x8010a385
80101b33:	e8 2e ea ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101b38:	83 ec 0c             	sub    $0xc,%esp
80101b3b:	68 80 32 11 80       	push   $0x80113280
80101b40:	e8 c2 4e 00 00       	call   80106a07 <acquire>
80101b45:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
80101b48:	eb 13                	jmp    80101b5d <ilock+0x48>
    sleep(ip, &icache.lock);
80101b4a:	83 ec 08             	sub    $0x8,%esp
80101b4d:	68 80 32 11 80       	push   $0x80113280
80101b52:	ff 75 08             	pushl  0x8(%ebp)
80101b55:	e8 52 3e 00 00       	call   801059ac <sleep>
80101b5a:	83 c4 10             	add    $0x10,%esp

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101b5d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b60:	8b 40 0c             	mov    0xc(%eax),%eax
80101b63:	83 e0 01             	and    $0x1,%eax
80101b66:	85 c0                	test   %eax,%eax
80101b68:	75 e0                	jne    80101b4a <ilock+0x35>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101b6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b6d:	8b 40 0c             	mov    0xc(%eax),%eax
80101b70:	83 c8 01             	or     $0x1,%eax
80101b73:	89 c2                	mov    %eax,%edx
80101b75:	8b 45 08             	mov    0x8(%ebp),%eax
80101b78:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80101b7b:	83 ec 0c             	sub    $0xc,%esp
80101b7e:	68 80 32 11 80       	push   $0x80113280
80101b83:	e8 e6 4e 00 00       	call   80106a6e <release>
80101b88:	83 c4 10             	add    $0x10,%esp

  if(!(ip->flags & I_VALID)){
80101b8b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8e:	8b 40 0c             	mov    0xc(%eax),%eax
80101b91:	83 e0 02             	and    $0x2,%eax
80101b94:	85 c0                	test   %eax,%eax
80101b96:	0f 85 fc 00 00 00    	jne    80101c98 <ilock+0x183>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101b9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b9f:	8b 40 04             	mov    0x4(%eax),%eax
80101ba2:	c1 e8 03             	shr    $0x3,%eax
80101ba5:	89 c2                	mov    %eax,%edx
80101ba7:	a1 74 32 11 80       	mov    0x80113274,%eax
80101bac:	01 c2                	add    %eax,%edx
80101bae:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb1:	8b 00                	mov    (%eax),%eax
80101bb3:	83 ec 08             	sub    $0x8,%esp
80101bb6:	52                   	push   %edx
80101bb7:	50                   	push   %eax
80101bb8:	e8 f9 e5 ff ff       	call   801001b6 <bread>
80101bbd:	83 c4 10             	add    $0x10,%esp
80101bc0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101bc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bc6:	8d 50 18             	lea    0x18(%eax),%edx
80101bc9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bcc:	8b 40 04             	mov    0x4(%eax),%eax
80101bcf:	83 e0 07             	and    $0x7,%eax
80101bd2:	c1 e0 06             	shl    $0x6,%eax
80101bd5:	01 d0                	add    %edx,%eax
80101bd7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101bda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bdd:	0f b7 10             	movzwl (%eax),%edx
80101be0:	8b 45 08             	mov    0x8(%ebp),%eax
80101be3:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101be7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bea:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101bee:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf1:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101bf5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bf8:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101bfc:	8b 45 08             	mov    0x8(%ebp),%eax
80101bff:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101c03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c06:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101c0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0d:	66 89 50 16          	mov    %dx,0x16(%eax)
#ifdef CS333_P5
    ip->uid = dip->uid;
80101c11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c14:	0f b7 50 08          	movzwl 0x8(%eax),%edx
80101c18:	8b 45 08             	mov    0x8(%ebp),%eax
80101c1b:	66 89 50 18          	mov    %dx,0x18(%eax)
    ip->gid = dip->gid;
80101c1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c22:	0f b7 50 0a          	movzwl 0xa(%eax),%edx
80101c26:	8b 45 08             	mov    0x8(%ebp),%eax
80101c29:	66 89 50 1a          	mov    %dx,0x1a(%eax)
    ip->mode.asInt = dip->mode.asInt;
80101c2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c30:	8b 50 0c             	mov    0xc(%eax),%edx
80101c33:	8b 45 08             	mov    0x8(%ebp),%eax
80101c36:	89 50 1c             	mov    %edx,0x1c(%eax)
#endif
    ip->size = dip->size; 
80101c39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c3c:	8b 50 10             	mov    0x10(%eax),%edx
80101c3f:	8b 45 08             	mov    0x8(%ebp),%eax
80101c42:	89 50 20             	mov    %edx,0x20(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101c45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c48:	8d 50 14             	lea    0x14(%eax),%edx
80101c4b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4e:	83 c0 24             	add    $0x24,%eax
80101c51:	83 ec 04             	sub    $0x4,%esp
80101c54:	6a 2c                	push   $0x2c
80101c56:	52                   	push   %edx
80101c57:	50                   	push   %eax
80101c58:	e8 cc 50 00 00       	call   80106d29 <memmove>
80101c5d:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101c60:	83 ec 0c             	sub    $0xc,%esp
80101c63:	ff 75 f4             	pushl  -0xc(%ebp)
80101c66:	e8 c3 e5 ff ff       	call   8010022e <brelse>
80101c6b:	83 c4 10             	add    $0x10,%esp
    ip->flags |= I_VALID;
80101c6e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c71:	8b 40 0c             	mov    0xc(%eax),%eax
80101c74:	83 c8 02             	or     $0x2,%eax
80101c77:	89 c2                	mov    %eax,%edx
80101c79:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7c:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101c7f:	8b 45 08             	mov    0x8(%ebp),%eax
80101c82:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101c86:	66 85 c0             	test   %ax,%ax
80101c89:	75 0d                	jne    80101c98 <ilock+0x183>
      panic("ilock: no type");
80101c8b:	83 ec 0c             	sub    $0xc,%esp
80101c8e:	68 8b a3 10 80       	push   $0x8010a38b
80101c93:	e8 ce e8 ff ff       	call   80100566 <panic>
  }
}
80101c98:	90                   	nop
80101c99:	c9                   	leave  
80101c9a:	c3                   	ret    

80101c9b <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101c9b:	55                   	push   %ebp
80101c9c:	89 e5                	mov    %esp,%ebp
80101c9e:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101ca1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101ca5:	74 17                	je     80101cbe <iunlock+0x23>
80101ca7:	8b 45 08             	mov    0x8(%ebp),%eax
80101caa:	8b 40 0c             	mov    0xc(%eax),%eax
80101cad:	83 e0 01             	and    $0x1,%eax
80101cb0:	85 c0                	test   %eax,%eax
80101cb2:	74 0a                	je     80101cbe <iunlock+0x23>
80101cb4:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb7:	8b 40 08             	mov    0x8(%eax),%eax
80101cba:	85 c0                	test   %eax,%eax
80101cbc:	7f 0d                	jg     80101ccb <iunlock+0x30>
    panic("iunlock");
80101cbe:	83 ec 0c             	sub    $0xc,%esp
80101cc1:	68 9a a3 10 80       	push   $0x8010a39a
80101cc6:	e8 9b e8 ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101ccb:	83 ec 0c             	sub    $0xc,%esp
80101cce:	68 80 32 11 80       	push   $0x80113280
80101cd3:	e8 2f 4d 00 00       	call   80106a07 <acquire>
80101cd8:	83 c4 10             	add    $0x10,%esp
  ip->flags &= ~I_BUSY;
80101cdb:	8b 45 08             	mov    0x8(%ebp),%eax
80101cde:	8b 40 0c             	mov    0xc(%eax),%eax
80101ce1:	83 e0 fe             	and    $0xfffffffe,%eax
80101ce4:	89 c2                	mov    %eax,%edx
80101ce6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce9:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101cec:	83 ec 0c             	sub    $0xc,%esp
80101cef:	ff 75 08             	pushl  0x8(%ebp)
80101cf2:	e8 08 3f 00 00       	call   80105bff <wakeup>
80101cf7:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101cfa:	83 ec 0c             	sub    $0xc,%esp
80101cfd:	68 80 32 11 80       	push   $0x80113280
80101d02:	e8 67 4d 00 00       	call   80106a6e <release>
80101d07:	83 c4 10             	add    $0x10,%esp
}
80101d0a:	90                   	nop
80101d0b:	c9                   	leave  
80101d0c:	c3                   	ret    

80101d0d <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101d0d:	55                   	push   %ebp
80101d0e:	89 e5                	mov    %esp,%ebp
80101d10:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101d13:	83 ec 0c             	sub    $0xc,%esp
80101d16:	68 80 32 11 80       	push   $0x80113280
80101d1b:	e8 e7 4c 00 00       	call   80106a07 <acquire>
80101d20:	83 c4 10             	add    $0x10,%esp
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101d23:	8b 45 08             	mov    0x8(%ebp),%eax
80101d26:	8b 40 08             	mov    0x8(%eax),%eax
80101d29:	83 f8 01             	cmp    $0x1,%eax
80101d2c:	0f 85 a9 00 00 00    	jne    80101ddb <iput+0xce>
80101d32:	8b 45 08             	mov    0x8(%ebp),%eax
80101d35:	8b 40 0c             	mov    0xc(%eax),%eax
80101d38:	83 e0 02             	and    $0x2,%eax
80101d3b:	85 c0                	test   %eax,%eax
80101d3d:	0f 84 98 00 00 00    	je     80101ddb <iput+0xce>
80101d43:	8b 45 08             	mov    0x8(%ebp),%eax
80101d46:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101d4a:	66 85 c0             	test   %ax,%ax
80101d4d:	0f 85 88 00 00 00    	jne    80101ddb <iput+0xce>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101d53:	8b 45 08             	mov    0x8(%ebp),%eax
80101d56:	8b 40 0c             	mov    0xc(%eax),%eax
80101d59:	83 e0 01             	and    $0x1,%eax
80101d5c:	85 c0                	test   %eax,%eax
80101d5e:	74 0d                	je     80101d6d <iput+0x60>
      panic("iput busy");
80101d60:	83 ec 0c             	sub    $0xc,%esp
80101d63:	68 a2 a3 10 80       	push   $0x8010a3a2
80101d68:	e8 f9 e7 ff ff       	call   80100566 <panic>
    ip->flags |= I_BUSY;
80101d6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d70:	8b 40 0c             	mov    0xc(%eax),%eax
80101d73:	83 c8 01             	or     $0x1,%eax
80101d76:	89 c2                	mov    %eax,%edx
80101d78:	8b 45 08             	mov    0x8(%ebp),%eax
80101d7b:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101d7e:	83 ec 0c             	sub    $0xc,%esp
80101d81:	68 80 32 11 80       	push   $0x80113280
80101d86:	e8 e3 4c 00 00       	call   80106a6e <release>
80101d8b:	83 c4 10             	add    $0x10,%esp
    itrunc(ip);
80101d8e:	83 ec 0c             	sub    $0xc,%esp
80101d91:	ff 75 08             	pushl  0x8(%ebp)
80101d94:	e8 a8 01 00 00       	call   80101f41 <itrunc>
80101d99:	83 c4 10             	add    $0x10,%esp
    ip->type = 0;
80101d9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d9f:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101da5:	83 ec 0c             	sub    $0xc,%esp
80101da8:	ff 75 08             	pushl  0x8(%ebp)
80101dab:	e8 63 fb ff ff       	call   80101913 <iupdate>
80101db0:	83 c4 10             	add    $0x10,%esp
    acquire(&icache.lock);
80101db3:	83 ec 0c             	sub    $0xc,%esp
80101db6:	68 80 32 11 80       	push   $0x80113280
80101dbb:	e8 47 4c 00 00       	call   80106a07 <acquire>
80101dc0:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101dc3:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc6:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101dcd:	83 ec 0c             	sub    $0xc,%esp
80101dd0:	ff 75 08             	pushl  0x8(%ebp)
80101dd3:	e8 27 3e 00 00       	call   80105bff <wakeup>
80101dd8:	83 c4 10             	add    $0x10,%esp
  }
  ip->ref--;
80101ddb:	8b 45 08             	mov    0x8(%ebp),%eax
80101dde:	8b 40 08             	mov    0x8(%eax),%eax
80101de1:	8d 50 ff             	lea    -0x1(%eax),%edx
80101de4:	8b 45 08             	mov    0x8(%ebp),%eax
80101de7:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101dea:	83 ec 0c             	sub    $0xc,%esp
80101ded:	68 80 32 11 80       	push   $0x80113280
80101df2:	e8 77 4c 00 00       	call   80106a6e <release>
80101df7:	83 c4 10             	add    $0x10,%esp
}
80101dfa:	90                   	nop
80101dfb:	c9                   	leave  
80101dfc:	c3                   	ret    

80101dfd <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101dfd:	55                   	push   %ebp
80101dfe:	89 e5                	mov    %esp,%ebp
80101e00:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101e03:	83 ec 0c             	sub    $0xc,%esp
80101e06:	ff 75 08             	pushl  0x8(%ebp)
80101e09:	e8 8d fe ff ff       	call   80101c9b <iunlock>
80101e0e:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101e11:	83 ec 0c             	sub    $0xc,%esp
80101e14:	ff 75 08             	pushl  0x8(%ebp)
80101e17:	e8 f1 fe ff ff       	call   80101d0d <iput>
80101e1c:	83 c4 10             	add    $0x10,%esp
}
80101e1f:	90                   	nop
80101e20:	c9                   	leave  
80101e21:	c3                   	ret    

80101e22 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101e22:	55                   	push   %ebp
80101e23:	89 e5                	mov    %esp,%ebp
80101e25:	53                   	push   %ebx
80101e26:	83 ec 14             	sub    $0x14,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101e29:	83 7d 0c 09          	cmpl   $0x9,0xc(%ebp)
80101e2d:	77 42                	ja     80101e71 <bmap+0x4f>
    if((addr = ip->addrs[bn]) == 0)
80101e2f:	8b 45 08             	mov    0x8(%ebp),%eax
80101e32:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e35:	83 c2 08             	add    $0x8,%edx
80101e38:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80101e3c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e3f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e43:	75 24                	jne    80101e69 <bmap+0x47>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101e45:	8b 45 08             	mov    0x8(%ebp),%eax
80101e48:	8b 00                	mov    (%eax),%eax
80101e4a:	83 ec 0c             	sub    $0xc,%esp
80101e4d:	50                   	push   %eax
80101e4e:	e8 2e f7 ff ff       	call   80101581 <balloc>
80101e53:	83 c4 10             	add    $0x10,%esp
80101e56:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e59:	8b 45 08             	mov    0x8(%ebp),%eax
80101e5c:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e5f:	8d 4a 08             	lea    0x8(%edx),%ecx
80101e62:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e65:	89 54 88 04          	mov    %edx,0x4(%eax,%ecx,4)
    return addr;
80101e69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e6c:	e9 cb 00 00 00       	jmp    80101f3c <bmap+0x11a>
  }
  bn -= NDIRECT;
80101e71:	83 6d 0c 0a          	subl   $0xa,0xc(%ebp)

  if(bn < NINDIRECT){
80101e75:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101e79:	0f 87 b0 00 00 00    	ja     80101f2f <bmap+0x10d>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101e7f:	8b 45 08             	mov    0x8(%ebp),%eax
80101e82:	8b 40 4c             	mov    0x4c(%eax),%eax
80101e85:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e88:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e8c:	75 1d                	jne    80101eab <bmap+0x89>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101e8e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e91:	8b 00                	mov    (%eax),%eax
80101e93:	83 ec 0c             	sub    $0xc,%esp
80101e96:	50                   	push   %eax
80101e97:	e8 e5 f6 ff ff       	call   80101581 <balloc>
80101e9c:	83 c4 10             	add    $0x10,%esp
80101e9f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ea2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ea8:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101eab:	8b 45 08             	mov    0x8(%ebp),%eax
80101eae:	8b 00                	mov    (%eax),%eax
80101eb0:	83 ec 08             	sub    $0x8,%esp
80101eb3:	ff 75 f4             	pushl  -0xc(%ebp)
80101eb6:	50                   	push   %eax
80101eb7:	e8 fa e2 ff ff       	call   801001b6 <bread>
80101ebc:	83 c4 10             	add    $0x10,%esp
80101ebf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101ec2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ec5:	83 c0 18             	add    $0x18,%eax
80101ec8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101ecb:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ece:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ed5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ed8:	01 d0                	add    %edx,%eax
80101eda:	8b 00                	mov    (%eax),%eax
80101edc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101edf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101ee3:	75 37                	jne    80101f1c <bmap+0xfa>
      a[bn] = addr = balloc(ip->dev);
80101ee5:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ee8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101eef:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ef2:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101ef5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef8:	8b 00                	mov    (%eax),%eax
80101efa:	83 ec 0c             	sub    $0xc,%esp
80101efd:	50                   	push   %eax
80101efe:	e8 7e f6 ff ff       	call   80101581 <balloc>
80101f03:	83 c4 10             	add    $0x10,%esp
80101f06:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101f09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f0c:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101f0e:	83 ec 0c             	sub    $0xc,%esp
80101f11:	ff 75 f0             	pushl  -0x10(%ebp)
80101f14:	e8 0b 1c 00 00       	call   80103b24 <log_write>
80101f19:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101f1c:	83 ec 0c             	sub    $0xc,%esp
80101f1f:	ff 75 f0             	pushl  -0x10(%ebp)
80101f22:	e8 07 e3 ff ff       	call   8010022e <brelse>
80101f27:	83 c4 10             	add    $0x10,%esp
    return addr;
80101f2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f2d:	eb 0d                	jmp    80101f3c <bmap+0x11a>
  }

  panic("bmap: out of range");
80101f2f:	83 ec 0c             	sub    $0xc,%esp
80101f32:	68 ac a3 10 80       	push   $0x8010a3ac
80101f37:	e8 2a e6 ff ff       	call   80100566 <panic>
}
80101f3c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101f3f:	c9                   	leave  
80101f40:	c3                   	ret    

80101f41 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101f41:	55                   	push   %ebp
80101f42:	89 e5                	mov    %esp,%ebp
80101f44:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101f47:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f4e:	eb 45                	jmp    80101f95 <itrunc+0x54>
    if(ip->addrs[i]){
80101f50:	8b 45 08             	mov    0x8(%ebp),%eax
80101f53:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f56:	83 c2 08             	add    $0x8,%edx
80101f59:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80101f5d:	85 c0                	test   %eax,%eax
80101f5f:	74 30                	je     80101f91 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101f61:	8b 45 08             	mov    0x8(%ebp),%eax
80101f64:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f67:	83 c2 08             	add    $0x8,%edx
80101f6a:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80101f6e:	8b 55 08             	mov    0x8(%ebp),%edx
80101f71:	8b 12                	mov    (%edx),%edx
80101f73:	83 ec 08             	sub    $0x8,%esp
80101f76:	50                   	push   %eax
80101f77:	52                   	push   %edx
80101f78:	e8 50 f7 ff ff       	call   801016cd <bfree>
80101f7d:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101f80:	8b 45 08             	mov    0x8(%ebp),%eax
80101f83:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f86:	83 c2 08             	add    $0x8,%edx
80101f89:	c7 44 90 04 00 00 00 	movl   $0x0,0x4(%eax,%edx,4)
80101f90:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101f91:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101f95:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80101f99:	7e b5                	jle    80101f50 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101f9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f9e:	8b 40 4c             	mov    0x4c(%eax),%eax
80101fa1:	85 c0                	test   %eax,%eax
80101fa3:	0f 84 a1 00 00 00    	je     8010204a <itrunc+0x109>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101fa9:	8b 45 08             	mov    0x8(%ebp),%eax
80101fac:	8b 50 4c             	mov    0x4c(%eax),%edx
80101faf:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb2:	8b 00                	mov    (%eax),%eax
80101fb4:	83 ec 08             	sub    $0x8,%esp
80101fb7:	52                   	push   %edx
80101fb8:	50                   	push   %eax
80101fb9:	e8 f8 e1 ff ff       	call   801001b6 <bread>
80101fbe:	83 c4 10             	add    $0x10,%esp
80101fc1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101fc4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fc7:	83 c0 18             	add    $0x18,%eax
80101fca:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101fcd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101fd4:	eb 3c                	jmp    80102012 <itrunc+0xd1>
      if(a[j])
80101fd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fd9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101fe0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101fe3:	01 d0                	add    %edx,%eax
80101fe5:	8b 00                	mov    (%eax),%eax
80101fe7:	85 c0                	test   %eax,%eax
80101fe9:	74 23                	je     8010200e <itrunc+0xcd>
        bfree(ip->dev, a[j]);
80101feb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fee:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ff5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101ff8:	01 d0                	add    %edx,%eax
80101ffa:	8b 00                	mov    (%eax),%eax
80101ffc:	8b 55 08             	mov    0x8(%ebp),%edx
80101fff:	8b 12                	mov    (%edx),%edx
80102001:	83 ec 08             	sub    $0x8,%esp
80102004:	50                   	push   %eax
80102005:	52                   	push   %edx
80102006:	e8 c2 f6 ff ff       	call   801016cd <bfree>
8010200b:	83 c4 10             	add    $0x10,%esp
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
8010200e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80102012:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102015:	83 f8 7f             	cmp    $0x7f,%eax
80102018:	76 bc                	jbe    80101fd6 <itrunc+0x95>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
8010201a:	83 ec 0c             	sub    $0xc,%esp
8010201d:	ff 75 ec             	pushl  -0x14(%ebp)
80102020:	e8 09 e2 ff ff       	call   8010022e <brelse>
80102025:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80102028:	8b 45 08             	mov    0x8(%ebp),%eax
8010202b:	8b 40 4c             	mov    0x4c(%eax),%eax
8010202e:	8b 55 08             	mov    0x8(%ebp),%edx
80102031:	8b 12                	mov    (%edx),%edx
80102033:	83 ec 08             	sub    $0x8,%esp
80102036:	50                   	push   %eax
80102037:	52                   	push   %edx
80102038:	e8 90 f6 ff ff       	call   801016cd <bfree>
8010203d:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80102040:	8b 45 08             	mov    0x8(%ebp),%eax
80102043:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
8010204a:	8b 45 08             	mov    0x8(%ebp),%eax
8010204d:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)
  iupdate(ip);
80102054:	83 ec 0c             	sub    $0xc,%esp
80102057:	ff 75 08             	pushl  0x8(%ebp)
8010205a:	e8 b4 f8 ff ff       	call   80101913 <iupdate>
8010205f:	83 c4 10             	add    $0x10,%esp
}
80102062:	90                   	nop
80102063:	c9                   	leave  
80102064:	c3                   	ret    

80102065 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80102065:	55                   	push   %ebp
80102066:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80102068:	8b 45 08             	mov    0x8(%ebp),%eax
8010206b:	8b 00                	mov    (%eax),%eax
8010206d:	89 c2                	mov    %eax,%edx
8010206f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102072:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80102075:	8b 45 08             	mov    0x8(%ebp),%eax
80102078:	8b 50 04             	mov    0x4(%eax),%edx
8010207b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010207e:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80102081:	8b 45 08             	mov    0x8(%ebp),%eax
80102084:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80102088:	8b 45 0c             	mov    0xc(%ebp),%eax
8010208b:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
8010208e:	8b 45 08             	mov    0x8(%ebp),%eax
80102091:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80102095:	8b 45 0c             	mov    0xc(%ebp),%eax
80102098:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
8010209c:	8b 45 08             	mov    0x8(%ebp),%eax
8010209f:	8b 50 20             	mov    0x20(%eax),%edx
801020a2:	8b 45 0c             	mov    0xc(%ebp),%eax
801020a5:	89 50 10             	mov    %edx,0x10(%eax)
#ifdef CS333_P5
  st->uid = ip->uid;
801020a8:	8b 45 08             	mov    0x8(%ebp),%eax
801020ab:	0f b7 50 18          	movzwl 0x18(%eax),%edx
801020af:	8b 45 0c             	mov    0xc(%ebp),%eax
801020b2:	66 89 50 14          	mov    %dx,0x14(%eax)
  st->gid = ip->gid;
801020b6:	8b 45 08             	mov    0x8(%ebp),%eax
801020b9:	0f b7 50 1a          	movzwl 0x1a(%eax),%edx
801020bd:	8b 45 0c             	mov    0xc(%ebp),%eax
801020c0:	66 89 50 16          	mov    %dx,0x16(%eax)
  st->mode.asInt = ip->mode.asInt;
801020c4:	8b 45 08             	mov    0x8(%ebp),%eax
801020c7:	8b 50 1c             	mov    0x1c(%eax),%edx
801020ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801020cd:	89 50 18             	mov    %edx,0x18(%eax)
#endif
}
801020d0:	90                   	nop
801020d1:	5d                   	pop    %ebp
801020d2:	c3                   	ret    

801020d3 <readi>:

// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
801020d3:	55                   	push   %ebp
801020d4:	89 e5                	mov    %esp,%ebp
801020d6:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801020d9:	8b 45 08             	mov    0x8(%ebp),%eax
801020dc:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801020e0:	66 83 f8 03          	cmp    $0x3,%ax
801020e4:	75 5c                	jne    80102142 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
801020e6:	8b 45 08             	mov    0x8(%ebp),%eax
801020e9:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020ed:	66 85 c0             	test   %ax,%ax
801020f0:	78 20                	js     80102112 <readi+0x3f>
801020f2:	8b 45 08             	mov    0x8(%ebp),%eax
801020f5:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020f9:	66 83 f8 09          	cmp    $0x9,%ax
801020fd:	7f 13                	jg     80102112 <readi+0x3f>
801020ff:	8b 45 08             	mov    0x8(%ebp),%eax
80102102:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102106:	98                   	cwtl   
80102107:	8b 04 c5 00 32 11 80 	mov    -0x7feece00(,%eax,8),%eax
8010210e:	85 c0                	test   %eax,%eax
80102110:	75 0a                	jne    8010211c <readi+0x49>
      return -1;
80102112:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102117:	e9 0c 01 00 00       	jmp    80102228 <readi+0x155>
    return devsw[ip->major].read(ip, dst, n);
8010211c:	8b 45 08             	mov    0x8(%ebp),%eax
8010211f:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102123:	98                   	cwtl   
80102124:	8b 04 c5 00 32 11 80 	mov    -0x7feece00(,%eax,8),%eax
8010212b:	8b 55 14             	mov    0x14(%ebp),%edx
8010212e:	83 ec 04             	sub    $0x4,%esp
80102131:	52                   	push   %edx
80102132:	ff 75 0c             	pushl  0xc(%ebp)
80102135:	ff 75 08             	pushl  0x8(%ebp)
80102138:	ff d0                	call   *%eax
8010213a:	83 c4 10             	add    $0x10,%esp
8010213d:	e9 e6 00 00 00       	jmp    80102228 <readi+0x155>
  }

  if(off > ip->size || off + n < off)
80102142:	8b 45 08             	mov    0x8(%ebp),%eax
80102145:	8b 40 20             	mov    0x20(%eax),%eax
80102148:	3b 45 10             	cmp    0x10(%ebp),%eax
8010214b:	72 0d                	jb     8010215a <readi+0x87>
8010214d:	8b 55 10             	mov    0x10(%ebp),%edx
80102150:	8b 45 14             	mov    0x14(%ebp),%eax
80102153:	01 d0                	add    %edx,%eax
80102155:	3b 45 10             	cmp    0x10(%ebp),%eax
80102158:	73 0a                	jae    80102164 <readi+0x91>
    return -1;
8010215a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010215f:	e9 c4 00 00 00       	jmp    80102228 <readi+0x155>
  if(off + n > ip->size)
80102164:	8b 55 10             	mov    0x10(%ebp),%edx
80102167:	8b 45 14             	mov    0x14(%ebp),%eax
8010216a:	01 c2                	add    %eax,%edx
8010216c:	8b 45 08             	mov    0x8(%ebp),%eax
8010216f:	8b 40 20             	mov    0x20(%eax),%eax
80102172:	39 c2                	cmp    %eax,%edx
80102174:	76 0c                	jbe    80102182 <readi+0xaf>
    n = ip->size - off;
80102176:	8b 45 08             	mov    0x8(%ebp),%eax
80102179:	8b 40 20             	mov    0x20(%eax),%eax
8010217c:	2b 45 10             	sub    0x10(%ebp),%eax
8010217f:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102182:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102189:	e9 8b 00 00 00       	jmp    80102219 <readi+0x146>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
8010218e:	8b 45 10             	mov    0x10(%ebp),%eax
80102191:	c1 e8 09             	shr    $0x9,%eax
80102194:	83 ec 08             	sub    $0x8,%esp
80102197:	50                   	push   %eax
80102198:	ff 75 08             	pushl  0x8(%ebp)
8010219b:	e8 82 fc ff ff       	call   80101e22 <bmap>
801021a0:	83 c4 10             	add    $0x10,%esp
801021a3:	89 c2                	mov    %eax,%edx
801021a5:	8b 45 08             	mov    0x8(%ebp),%eax
801021a8:	8b 00                	mov    (%eax),%eax
801021aa:	83 ec 08             	sub    $0x8,%esp
801021ad:	52                   	push   %edx
801021ae:	50                   	push   %eax
801021af:	e8 02 e0 ff ff       	call   801001b6 <bread>
801021b4:	83 c4 10             	add    $0x10,%esp
801021b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801021ba:	8b 45 10             	mov    0x10(%ebp),%eax
801021bd:	25 ff 01 00 00       	and    $0x1ff,%eax
801021c2:	ba 00 02 00 00       	mov    $0x200,%edx
801021c7:	29 c2                	sub    %eax,%edx
801021c9:	8b 45 14             	mov    0x14(%ebp),%eax
801021cc:	2b 45 f4             	sub    -0xc(%ebp),%eax
801021cf:	39 c2                	cmp    %eax,%edx
801021d1:	0f 46 c2             	cmovbe %edx,%eax
801021d4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
801021d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021da:	8d 50 18             	lea    0x18(%eax),%edx
801021dd:	8b 45 10             	mov    0x10(%ebp),%eax
801021e0:	25 ff 01 00 00       	and    $0x1ff,%eax
801021e5:	01 d0                	add    %edx,%eax
801021e7:	83 ec 04             	sub    $0x4,%esp
801021ea:	ff 75 ec             	pushl  -0x14(%ebp)
801021ed:	50                   	push   %eax
801021ee:	ff 75 0c             	pushl  0xc(%ebp)
801021f1:	e8 33 4b 00 00       	call   80106d29 <memmove>
801021f6:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801021f9:	83 ec 0c             	sub    $0xc,%esp
801021fc:	ff 75 f0             	pushl  -0x10(%ebp)
801021ff:	e8 2a e0 ff ff       	call   8010022e <brelse>
80102204:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102207:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010220a:	01 45 f4             	add    %eax,-0xc(%ebp)
8010220d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102210:	01 45 10             	add    %eax,0x10(%ebp)
80102213:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102216:	01 45 0c             	add    %eax,0xc(%ebp)
80102219:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010221c:	3b 45 14             	cmp    0x14(%ebp),%eax
8010221f:	0f 82 69 ff ff ff    	jb     8010218e <readi+0xbb>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80102225:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102228:	c9                   	leave  
80102229:	c3                   	ret    

8010222a <writei>:

// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
8010222a:	55                   	push   %ebp
8010222b:	89 e5                	mov    %esp,%ebp
8010222d:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102230:	8b 45 08             	mov    0x8(%ebp),%eax
80102233:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102237:	66 83 f8 03          	cmp    $0x3,%ax
8010223b:	75 5c                	jne    80102299 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
8010223d:	8b 45 08             	mov    0x8(%ebp),%eax
80102240:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102244:	66 85 c0             	test   %ax,%ax
80102247:	78 20                	js     80102269 <writei+0x3f>
80102249:	8b 45 08             	mov    0x8(%ebp),%eax
8010224c:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102250:	66 83 f8 09          	cmp    $0x9,%ax
80102254:	7f 13                	jg     80102269 <writei+0x3f>
80102256:	8b 45 08             	mov    0x8(%ebp),%eax
80102259:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010225d:	98                   	cwtl   
8010225e:	8b 04 c5 04 32 11 80 	mov    -0x7feecdfc(,%eax,8),%eax
80102265:	85 c0                	test   %eax,%eax
80102267:	75 0a                	jne    80102273 <writei+0x49>
      return -1;
80102269:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010226e:	e9 3d 01 00 00       	jmp    801023b0 <writei+0x186>
    return devsw[ip->major].write(ip, src, n);
80102273:	8b 45 08             	mov    0x8(%ebp),%eax
80102276:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010227a:	98                   	cwtl   
8010227b:	8b 04 c5 04 32 11 80 	mov    -0x7feecdfc(,%eax,8),%eax
80102282:	8b 55 14             	mov    0x14(%ebp),%edx
80102285:	83 ec 04             	sub    $0x4,%esp
80102288:	52                   	push   %edx
80102289:	ff 75 0c             	pushl  0xc(%ebp)
8010228c:	ff 75 08             	pushl  0x8(%ebp)
8010228f:	ff d0                	call   *%eax
80102291:	83 c4 10             	add    $0x10,%esp
80102294:	e9 17 01 00 00       	jmp    801023b0 <writei+0x186>
  }

  if(off > ip->size || off + n < off)
80102299:	8b 45 08             	mov    0x8(%ebp),%eax
8010229c:	8b 40 20             	mov    0x20(%eax),%eax
8010229f:	3b 45 10             	cmp    0x10(%ebp),%eax
801022a2:	72 0d                	jb     801022b1 <writei+0x87>
801022a4:	8b 55 10             	mov    0x10(%ebp),%edx
801022a7:	8b 45 14             	mov    0x14(%ebp),%eax
801022aa:	01 d0                	add    %edx,%eax
801022ac:	3b 45 10             	cmp    0x10(%ebp),%eax
801022af:	73 0a                	jae    801022bb <writei+0x91>
    return -1;
801022b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022b6:	e9 f5 00 00 00       	jmp    801023b0 <writei+0x186>
  if(off + n > MAXFILE*BSIZE)
801022bb:	8b 55 10             	mov    0x10(%ebp),%edx
801022be:	8b 45 14             	mov    0x14(%ebp),%eax
801022c1:	01 d0                	add    %edx,%eax
801022c3:	3d 00 14 01 00       	cmp    $0x11400,%eax
801022c8:	76 0a                	jbe    801022d4 <writei+0xaa>
    return -1;
801022ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022cf:	e9 dc 00 00 00       	jmp    801023b0 <writei+0x186>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801022d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022db:	e9 99 00 00 00       	jmp    80102379 <writei+0x14f>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801022e0:	8b 45 10             	mov    0x10(%ebp),%eax
801022e3:	c1 e8 09             	shr    $0x9,%eax
801022e6:	83 ec 08             	sub    $0x8,%esp
801022e9:	50                   	push   %eax
801022ea:	ff 75 08             	pushl  0x8(%ebp)
801022ed:	e8 30 fb ff ff       	call   80101e22 <bmap>
801022f2:	83 c4 10             	add    $0x10,%esp
801022f5:	89 c2                	mov    %eax,%edx
801022f7:	8b 45 08             	mov    0x8(%ebp),%eax
801022fa:	8b 00                	mov    (%eax),%eax
801022fc:	83 ec 08             	sub    $0x8,%esp
801022ff:	52                   	push   %edx
80102300:	50                   	push   %eax
80102301:	e8 b0 de ff ff       	call   801001b6 <bread>
80102306:	83 c4 10             	add    $0x10,%esp
80102309:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010230c:	8b 45 10             	mov    0x10(%ebp),%eax
8010230f:	25 ff 01 00 00       	and    $0x1ff,%eax
80102314:	ba 00 02 00 00       	mov    $0x200,%edx
80102319:	29 c2                	sub    %eax,%edx
8010231b:	8b 45 14             	mov    0x14(%ebp),%eax
8010231e:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102321:	39 c2                	cmp    %eax,%edx
80102323:	0f 46 c2             	cmovbe %edx,%eax
80102326:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102329:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010232c:	8d 50 18             	lea    0x18(%eax),%edx
8010232f:	8b 45 10             	mov    0x10(%ebp),%eax
80102332:	25 ff 01 00 00       	and    $0x1ff,%eax
80102337:	01 d0                	add    %edx,%eax
80102339:	83 ec 04             	sub    $0x4,%esp
8010233c:	ff 75 ec             	pushl  -0x14(%ebp)
8010233f:	ff 75 0c             	pushl  0xc(%ebp)
80102342:	50                   	push   %eax
80102343:	e8 e1 49 00 00       	call   80106d29 <memmove>
80102348:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
8010234b:	83 ec 0c             	sub    $0xc,%esp
8010234e:	ff 75 f0             	pushl  -0x10(%ebp)
80102351:	e8 ce 17 00 00       	call   80103b24 <log_write>
80102356:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102359:	83 ec 0c             	sub    $0xc,%esp
8010235c:	ff 75 f0             	pushl  -0x10(%ebp)
8010235f:	e8 ca de ff ff       	call   8010022e <brelse>
80102364:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102367:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010236a:	01 45 f4             	add    %eax,-0xc(%ebp)
8010236d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102370:	01 45 10             	add    %eax,0x10(%ebp)
80102373:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102376:	01 45 0c             	add    %eax,0xc(%ebp)
80102379:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010237c:	3b 45 14             	cmp    0x14(%ebp),%eax
8010237f:	0f 82 5b ff ff ff    	jb     801022e0 <writei+0xb6>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102385:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102389:	74 22                	je     801023ad <writei+0x183>
8010238b:	8b 45 08             	mov    0x8(%ebp),%eax
8010238e:	8b 40 20             	mov    0x20(%eax),%eax
80102391:	3b 45 10             	cmp    0x10(%ebp),%eax
80102394:	73 17                	jae    801023ad <writei+0x183>
    ip->size = off;
80102396:	8b 45 08             	mov    0x8(%ebp),%eax
80102399:	8b 55 10             	mov    0x10(%ebp),%edx
8010239c:	89 50 20             	mov    %edx,0x20(%eax)
    iupdate(ip);
8010239f:	83 ec 0c             	sub    $0xc,%esp
801023a2:	ff 75 08             	pushl  0x8(%ebp)
801023a5:	e8 69 f5 ff ff       	call   80101913 <iupdate>
801023aa:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801023ad:	8b 45 14             	mov    0x14(%ebp),%eax
}
801023b0:	c9                   	leave  
801023b1:	c3                   	ret    

801023b2 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
801023b2:	55                   	push   %ebp
801023b3:	89 e5                	mov    %esp,%ebp
801023b5:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801023b8:	83 ec 04             	sub    $0x4,%esp
801023bb:	6a 0e                	push   $0xe
801023bd:	ff 75 0c             	pushl  0xc(%ebp)
801023c0:	ff 75 08             	pushl  0x8(%ebp)
801023c3:	e8 f7 49 00 00       	call   80106dbf <strncmp>
801023c8:	83 c4 10             	add    $0x10,%esp
}
801023cb:	c9                   	leave  
801023cc:	c3                   	ret    

801023cd <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801023cd:	55                   	push   %ebp
801023ce:	89 e5                	mov    %esp,%ebp
801023d0:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801023d3:	8b 45 08             	mov    0x8(%ebp),%eax
801023d6:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801023da:	66 83 f8 01          	cmp    $0x1,%ax
801023de:	74 0d                	je     801023ed <dirlookup+0x20>
    panic("dirlookup not DIR");
801023e0:	83 ec 0c             	sub    $0xc,%esp
801023e3:	68 bf a3 10 80       	push   $0x8010a3bf
801023e8:	e8 79 e1 ff ff       	call   80100566 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801023ed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801023f4:	eb 7b                	jmp    80102471 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801023f6:	6a 10                	push   $0x10
801023f8:	ff 75 f4             	pushl  -0xc(%ebp)
801023fb:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023fe:	50                   	push   %eax
801023ff:	ff 75 08             	pushl  0x8(%ebp)
80102402:	e8 cc fc ff ff       	call   801020d3 <readi>
80102407:	83 c4 10             	add    $0x10,%esp
8010240a:	83 f8 10             	cmp    $0x10,%eax
8010240d:	74 0d                	je     8010241c <dirlookup+0x4f>
      panic("dirlink read");
8010240f:	83 ec 0c             	sub    $0xc,%esp
80102412:	68 d1 a3 10 80       	push   $0x8010a3d1
80102417:	e8 4a e1 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
8010241c:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102420:	66 85 c0             	test   %ax,%ax
80102423:	74 47                	je     8010246c <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
80102425:	83 ec 08             	sub    $0x8,%esp
80102428:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010242b:	83 c0 02             	add    $0x2,%eax
8010242e:	50                   	push   %eax
8010242f:	ff 75 0c             	pushl  0xc(%ebp)
80102432:	e8 7b ff ff ff       	call   801023b2 <namecmp>
80102437:	83 c4 10             	add    $0x10,%esp
8010243a:	85 c0                	test   %eax,%eax
8010243c:	75 2f                	jne    8010246d <dirlookup+0xa0>
      // entry matches path element
      if(poff)
8010243e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102442:	74 08                	je     8010244c <dirlookup+0x7f>
        *poff = off;
80102444:	8b 45 10             	mov    0x10(%ebp),%eax
80102447:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010244a:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010244c:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102450:	0f b7 c0             	movzwl %ax,%eax
80102453:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102456:	8b 45 08             	mov    0x8(%ebp),%eax
80102459:	8b 00                	mov    (%eax),%eax
8010245b:	83 ec 08             	sub    $0x8,%esp
8010245e:	ff 75 f0             	pushl  -0x10(%ebp)
80102461:	50                   	push   %eax
80102462:	e8 95 f5 ff ff       	call   801019fc <iget>
80102467:	83 c4 10             	add    $0x10,%esp
8010246a:	eb 19                	jmp    80102485 <dirlookup+0xb8>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
8010246c:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
8010246d:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102471:	8b 45 08             	mov    0x8(%ebp),%eax
80102474:	8b 40 20             	mov    0x20(%eax),%eax
80102477:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010247a:	0f 87 76 ff ff ff    	ja     801023f6 <dirlookup+0x29>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102480:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102485:	c9                   	leave  
80102486:	c3                   	ret    

80102487 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102487:	55                   	push   %ebp
80102488:	89 e5                	mov    %esp,%ebp
8010248a:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010248d:	83 ec 04             	sub    $0x4,%esp
80102490:	6a 00                	push   $0x0
80102492:	ff 75 0c             	pushl  0xc(%ebp)
80102495:	ff 75 08             	pushl  0x8(%ebp)
80102498:	e8 30 ff ff ff       	call   801023cd <dirlookup>
8010249d:	83 c4 10             	add    $0x10,%esp
801024a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024a3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024a7:	74 18                	je     801024c1 <dirlink+0x3a>
    iput(ip);
801024a9:	83 ec 0c             	sub    $0xc,%esp
801024ac:	ff 75 f0             	pushl  -0x10(%ebp)
801024af:	e8 59 f8 ff ff       	call   80101d0d <iput>
801024b4:	83 c4 10             	add    $0x10,%esp
    return -1;
801024b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801024bc:	e9 9c 00 00 00       	jmp    8010255d <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801024c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801024c8:	eb 39                	jmp    80102503 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801024ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024cd:	6a 10                	push   $0x10
801024cf:	50                   	push   %eax
801024d0:	8d 45 e0             	lea    -0x20(%ebp),%eax
801024d3:	50                   	push   %eax
801024d4:	ff 75 08             	pushl  0x8(%ebp)
801024d7:	e8 f7 fb ff ff       	call   801020d3 <readi>
801024dc:	83 c4 10             	add    $0x10,%esp
801024df:	83 f8 10             	cmp    $0x10,%eax
801024e2:	74 0d                	je     801024f1 <dirlink+0x6a>
      panic("dirlink read");
801024e4:	83 ec 0c             	sub    $0xc,%esp
801024e7:	68 d1 a3 10 80       	push   $0x8010a3d1
801024ec:	e8 75 e0 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
801024f1:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801024f5:	66 85 c0             	test   %ax,%ax
801024f8:	74 18                	je     80102512 <dirlink+0x8b>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801024fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024fd:	83 c0 10             	add    $0x10,%eax
80102500:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102503:	8b 45 08             	mov    0x8(%ebp),%eax
80102506:	8b 50 20             	mov    0x20(%eax),%edx
80102509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010250c:	39 c2                	cmp    %eax,%edx
8010250e:	77 ba                	ja     801024ca <dirlink+0x43>
80102510:	eb 01                	jmp    80102513 <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
80102512:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102513:	83 ec 04             	sub    $0x4,%esp
80102516:	6a 0e                	push   $0xe
80102518:	ff 75 0c             	pushl  0xc(%ebp)
8010251b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010251e:	83 c0 02             	add    $0x2,%eax
80102521:	50                   	push   %eax
80102522:	e8 ee 48 00 00       	call   80106e15 <strncpy>
80102527:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
8010252a:	8b 45 10             	mov    0x10(%ebp),%eax
8010252d:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102531:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102534:	6a 10                	push   $0x10
80102536:	50                   	push   %eax
80102537:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010253a:	50                   	push   %eax
8010253b:	ff 75 08             	pushl  0x8(%ebp)
8010253e:	e8 e7 fc ff ff       	call   8010222a <writei>
80102543:	83 c4 10             	add    $0x10,%esp
80102546:	83 f8 10             	cmp    $0x10,%eax
80102549:	74 0d                	je     80102558 <dirlink+0xd1>
    panic("dirlink");
8010254b:	83 ec 0c             	sub    $0xc,%esp
8010254e:	68 de a3 10 80       	push   $0x8010a3de
80102553:	e8 0e e0 ff ff       	call   80100566 <panic>
  
  return 0;
80102558:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010255d:	c9                   	leave  
8010255e:	c3                   	ret    

8010255f <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010255f:	55                   	push   %ebp
80102560:	89 e5                	mov    %esp,%ebp
80102562:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102565:	eb 04                	jmp    8010256b <skipelem+0xc>
    path++;
80102567:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
8010256b:	8b 45 08             	mov    0x8(%ebp),%eax
8010256e:	0f b6 00             	movzbl (%eax),%eax
80102571:	3c 2f                	cmp    $0x2f,%al
80102573:	74 f2                	je     80102567 <skipelem+0x8>
    path++;
  if(*path == 0)
80102575:	8b 45 08             	mov    0x8(%ebp),%eax
80102578:	0f b6 00             	movzbl (%eax),%eax
8010257b:	84 c0                	test   %al,%al
8010257d:	75 07                	jne    80102586 <skipelem+0x27>
    return 0;
8010257f:	b8 00 00 00 00       	mov    $0x0,%eax
80102584:	eb 7b                	jmp    80102601 <skipelem+0xa2>
  s = path;
80102586:	8b 45 08             	mov    0x8(%ebp),%eax
80102589:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
8010258c:	eb 04                	jmp    80102592 <skipelem+0x33>
    path++;
8010258e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102592:	8b 45 08             	mov    0x8(%ebp),%eax
80102595:	0f b6 00             	movzbl (%eax),%eax
80102598:	3c 2f                	cmp    $0x2f,%al
8010259a:	74 0a                	je     801025a6 <skipelem+0x47>
8010259c:	8b 45 08             	mov    0x8(%ebp),%eax
8010259f:	0f b6 00             	movzbl (%eax),%eax
801025a2:	84 c0                	test   %al,%al
801025a4:	75 e8                	jne    8010258e <skipelem+0x2f>
    path++;
  len = path - s;
801025a6:	8b 55 08             	mov    0x8(%ebp),%edx
801025a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025ac:	29 c2                	sub    %eax,%edx
801025ae:	89 d0                	mov    %edx,%eax
801025b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801025b3:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801025b7:	7e 15                	jle    801025ce <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
801025b9:	83 ec 04             	sub    $0x4,%esp
801025bc:	6a 0e                	push   $0xe
801025be:	ff 75 f4             	pushl  -0xc(%ebp)
801025c1:	ff 75 0c             	pushl  0xc(%ebp)
801025c4:	e8 60 47 00 00       	call   80106d29 <memmove>
801025c9:	83 c4 10             	add    $0x10,%esp
801025cc:	eb 26                	jmp    801025f4 <skipelem+0x95>
  else {
    memmove(name, s, len);
801025ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801025d1:	83 ec 04             	sub    $0x4,%esp
801025d4:	50                   	push   %eax
801025d5:	ff 75 f4             	pushl  -0xc(%ebp)
801025d8:	ff 75 0c             	pushl  0xc(%ebp)
801025db:	e8 49 47 00 00       	call   80106d29 <memmove>
801025e0:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801025e3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801025e6:	8b 45 0c             	mov    0xc(%ebp),%eax
801025e9:	01 d0                	add    %edx,%eax
801025eb:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801025ee:	eb 04                	jmp    801025f4 <skipelem+0x95>
    path++;
801025f0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801025f4:	8b 45 08             	mov    0x8(%ebp),%eax
801025f7:	0f b6 00             	movzbl (%eax),%eax
801025fa:	3c 2f                	cmp    $0x2f,%al
801025fc:	74 f2                	je     801025f0 <skipelem+0x91>
    path++;
  return path;
801025fe:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102601:	c9                   	leave  
80102602:	c3                   	ret    

80102603 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102603:	55                   	push   %ebp
80102604:	89 e5                	mov    %esp,%ebp
80102606:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102609:	8b 45 08             	mov    0x8(%ebp),%eax
8010260c:	0f b6 00             	movzbl (%eax),%eax
8010260f:	3c 2f                	cmp    $0x2f,%al
80102611:	75 17                	jne    8010262a <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
80102613:	83 ec 08             	sub    $0x8,%esp
80102616:	6a 01                	push   $0x1
80102618:	6a 01                	push   $0x1
8010261a:	e8 dd f3 ff ff       	call   801019fc <iget>
8010261f:	83 c4 10             	add    $0x10,%esp
80102622:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102625:	e9 bb 00 00 00       	jmp    801026e5 <namex+0xe2>
  else
    ip = idup(proc->cwd);
8010262a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102630:	8b 40 68             	mov    0x68(%eax),%eax
80102633:	83 ec 0c             	sub    $0xc,%esp
80102636:	50                   	push   %eax
80102637:	e8 9f f4 ff ff       	call   80101adb <idup>
8010263c:	83 c4 10             	add    $0x10,%esp
8010263f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102642:	e9 9e 00 00 00       	jmp    801026e5 <namex+0xe2>
    ilock(ip);
80102647:	83 ec 0c             	sub    $0xc,%esp
8010264a:	ff 75 f4             	pushl  -0xc(%ebp)
8010264d:	e8 c3 f4 ff ff       	call   80101b15 <ilock>
80102652:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
80102655:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102658:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010265c:	66 83 f8 01          	cmp    $0x1,%ax
80102660:	74 18                	je     8010267a <namex+0x77>
      iunlockput(ip);
80102662:	83 ec 0c             	sub    $0xc,%esp
80102665:	ff 75 f4             	pushl  -0xc(%ebp)
80102668:	e8 90 f7 ff ff       	call   80101dfd <iunlockput>
8010266d:	83 c4 10             	add    $0x10,%esp
      return 0;
80102670:	b8 00 00 00 00       	mov    $0x0,%eax
80102675:	e9 a7 00 00 00       	jmp    80102721 <namex+0x11e>
    }
    if(nameiparent && *path == '\0'){
8010267a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010267e:	74 20                	je     801026a0 <namex+0x9d>
80102680:	8b 45 08             	mov    0x8(%ebp),%eax
80102683:	0f b6 00             	movzbl (%eax),%eax
80102686:	84 c0                	test   %al,%al
80102688:	75 16                	jne    801026a0 <namex+0x9d>
      // Stop one level early.
      iunlock(ip);
8010268a:	83 ec 0c             	sub    $0xc,%esp
8010268d:	ff 75 f4             	pushl  -0xc(%ebp)
80102690:	e8 06 f6 ff ff       	call   80101c9b <iunlock>
80102695:	83 c4 10             	add    $0x10,%esp
      return ip;
80102698:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010269b:	e9 81 00 00 00       	jmp    80102721 <namex+0x11e>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801026a0:	83 ec 04             	sub    $0x4,%esp
801026a3:	6a 00                	push   $0x0
801026a5:	ff 75 10             	pushl  0x10(%ebp)
801026a8:	ff 75 f4             	pushl  -0xc(%ebp)
801026ab:	e8 1d fd ff ff       	call   801023cd <dirlookup>
801026b0:	83 c4 10             	add    $0x10,%esp
801026b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
801026b6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801026ba:	75 15                	jne    801026d1 <namex+0xce>
      iunlockput(ip);
801026bc:	83 ec 0c             	sub    $0xc,%esp
801026bf:	ff 75 f4             	pushl  -0xc(%ebp)
801026c2:	e8 36 f7 ff ff       	call   80101dfd <iunlockput>
801026c7:	83 c4 10             	add    $0x10,%esp
      return 0;
801026ca:	b8 00 00 00 00       	mov    $0x0,%eax
801026cf:	eb 50                	jmp    80102721 <namex+0x11e>
    }
    iunlockput(ip);
801026d1:	83 ec 0c             	sub    $0xc,%esp
801026d4:	ff 75 f4             	pushl  -0xc(%ebp)
801026d7:	e8 21 f7 ff ff       	call   80101dfd <iunlockput>
801026dc:	83 c4 10             	add    $0x10,%esp
    ip = next;
801026df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
801026e5:	83 ec 08             	sub    $0x8,%esp
801026e8:	ff 75 10             	pushl  0x10(%ebp)
801026eb:	ff 75 08             	pushl  0x8(%ebp)
801026ee:	e8 6c fe ff ff       	call   8010255f <skipelem>
801026f3:	83 c4 10             	add    $0x10,%esp
801026f6:	89 45 08             	mov    %eax,0x8(%ebp)
801026f9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026fd:	0f 85 44 ff ff ff    	jne    80102647 <namex+0x44>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102703:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102707:	74 15                	je     8010271e <namex+0x11b>
    iput(ip);
80102709:	83 ec 0c             	sub    $0xc,%esp
8010270c:	ff 75 f4             	pushl  -0xc(%ebp)
8010270f:	e8 f9 f5 ff ff       	call   80101d0d <iput>
80102714:	83 c4 10             	add    $0x10,%esp
    return 0;
80102717:	b8 00 00 00 00       	mov    $0x0,%eax
8010271c:	eb 03                	jmp    80102721 <namex+0x11e>
  }
  return ip;
8010271e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102721:	c9                   	leave  
80102722:	c3                   	ret    

80102723 <namei>:

struct inode*
namei(char *path)
{
80102723:	55                   	push   %ebp
80102724:	89 e5                	mov    %esp,%ebp
80102726:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102729:	83 ec 04             	sub    $0x4,%esp
8010272c:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010272f:	50                   	push   %eax
80102730:	6a 00                	push   $0x0
80102732:	ff 75 08             	pushl  0x8(%ebp)
80102735:	e8 c9 fe ff ff       	call   80102603 <namex>
8010273a:	83 c4 10             	add    $0x10,%esp
}
8010273d:	c9                   	leave  
8010273e:	c3                   	ret    

8010273f <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
8010273f:	55                   	push   %ebp
80102740:	89 e5                	mov    %esp,%ebp
80102742:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80102745:	83 ec 04             	sub    $0x4,%esp
80102748:	ff 75 0c             	pushl  0xc(%ebp)
8010274b:	6a 01                	push   $0x1
8010274d:	ff 75 08             	pushl  0x8(%ebp)
80102750:	e8 ae fe ff ff       	call   80102603 <namex>
80102755:	83 c4 10             	add    $0x10,%esp
}
80102758:	c9                   	leave  
80102759:	c3                   	ret    

8010275a <chmod>:

#ifdef CS333_P5
int
chmod(char *pathname, int mode)
{
8010275a:	55                   	push   %ebp
8010275b:	89 e5                	mov    %esp,%ebp
8010275d:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  if(mode < 0)
80102760:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102764:	79 07                	jns    8010276d <chmod+0x13>
    return -1;
80102766:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010276b:	eb 75                	jmp    801027e2 <chmod+0x88>
  if(mode > 01777)
8010276d:	81 7d 0c ff 03 00 00 	cmpl   $0x3ff,0xc(%ebp)
80102774:	7e 07                	jle    8010277d <chmod+0x23>
    return -1;
80102776:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010277b:	eb 65                	jmp    801027e2 <chmod+0x88>

  begin_op();
8010277d:	e8 6a 11 00 00       	call   801038ec <begin_op>
  ip = namei(pathname);
80102782:	83 ec 0c             	sub    $0xc,%esp
80102785:	ff 75 08             	pushl  0x8(%ebp)
80102788:	e8 96 ff ff ff       	call   80102723 <namei>
8010278d:	83 c4 10             	add    $0x10,%esp
80102790:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip == 0)
80102793:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102797:	75 0c                	jne    801027a5 <chmod+0x4b>
  {
    end_op();
80102799:	e8 da 11 00 00       	call   80103978 <end_op>
    return -1;
8010279e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801027a3:	eb 3d                	jmp    801027e2 <chmod+0x88>
  }

  ilock(ip);
801027a5:	83 ec 0c             	sub    $0xc,%esp
801027a8:	ff 75 f4             	pushl  -0xc(%ebp)
801027ab:	e8 65 f3 ff ff       	call   80101b15 <ilock>
801027b0:	83 c4 10             	add    $0x10,%esp
  ip->mode.asInt = mode;
801027b3:	8b 55 0c             	mov    0xc(%ebp),%edx
801027b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027b9:	89 50 1c             	mov    %edx,0x1c(%eax)
  iupdate(ip);
801027bc:	83 ec 0c             	sub    $0xc,%esp
801027bf:	ff 75 f4             	pushl  -0xc(%ebp)
801027c2:	e8 4c f1 ff ff       	call   80101913 <iupdate>
801027c7:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801027ca:	83 ec 0c             	sub    $0xc,%esp
801027cd:	ff 75 f4             	pushl  -0xc(%ebp)
801027d0:	e8 28 f6 ff ff       	call   80101dfd <iunlockput>
801027d5:	83 c4 10             	add    $0x10,%esp
  end_op();
801027d8:	e8 9b 11 00 00       	call   80103978 <end_op>
  return 0;
801027dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801027e2:	c9                   	leave  
801027e3:	c3                   	ret    

801027e4 <chgrp>:

int 
chgrp(char *pathname, int group)
{
801027e4:	55                   	push   %ebp
801027e5:	89 e5                	mov    %esp,%ebp
801027e7:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  if(group < 0)
801027ea:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801027ee:	79 07                	jns    801027f7 <chgrp+0x13>
    return -1;
801027f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801027f5:	eb 78                	jmp    8010286f <chgrp+0x8b>
  if(group > 32767)
801027f7:	81 7d 0c ff 7f 00 00 	cmpl   $0x7fff,0xc(%ebp)
801027fe:	7e 07                	jle    80102807 <chgrp+0x23>
    return -1;
80102800:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102805:	eb 68                	jmp    8010286f <chgrp+0x8b>

  begin_op();
80102807:	e8 e0 10 00 00       	call   801038ec <begin_op>
  ip = namei(pathname);
8010280c:	83 ec 0c             	sub    $0xc,%esp
8010280f:	ff 75 08             	pushl  0x8(%ebp)
80102812:	e8 0c ff ff ff       	call   80102723 <namei>
80102817:	83 c4 10             	add    $0x10,%esp
8010281a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip == 0)
8010281d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102821:	75 0c                	jne    8010282f <chgrp+0x4b>
  {
    end_op();
80102823:	e8 50 11 00 00       	call   80103978 <end_op>
    return -1;
80102828:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010282d:	eb 40                	jmp    8010286f <chgrp+0x8b>
  }

  ilock(ip);
8010282f:	83 ec 0c             	sub    $0xc,%esp
80102832:	ff 75 f4             	pushl  -0xc(%ebp)
80102835:	e8 db f2 ff ff       	call   80101b15 <ilock>
8010283a:	83 c4 10             	add    $0x10,%esp
  ip->gid = group;
8010283d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102840:	89 c2                	mov    %eax,%edx
80102842:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102845:	66 89 50 1a          	mov    %dx,0x1a(%eax)
  iupdate(ip);
80102849:	83 ec 0c             	sub    $0xc,%esp
8010284c:	ff 75 f4             	pushl  -0xc(%ebp)
8010284f:	e8 bf f0 ff ff       	call   80101913 <iupdate>
80102854:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80102857:	83 ec 0c             	sub    $0xc,%esp
8010285a:	ff 75 f4             	pushl  -0xc(%ebp)
8010285d:	e8 9b f5 ff ff       	call   80101dfd <iunlockput>
80102862:	83 c4 10             	add    $0x10,%esp
  end_op();
80102865:	e8 0e 11 00 00       	call   80103978 <end_op>
  return 0;
8010286a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010286f:	c9                   	leave  
80102870:	c3                   	ret    

80102871 <chown>:

int
chown(char *pathname, int owner)
{
80102871:	55                   	push   %ebp
80102872:	89 e5                	mov    %esp,%ebp
80102874:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  if(owner < 0)
80102877:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010287b:	79 07                	jns    80102884 <chown+0x13>
    return -1;
8010287d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102882:	eb 78                	jmp    801028fc <chown+0x8b>
  if(owner > 32767)
80102884:	81 7d 0c ff 7f 00 00 	cmpl   $0x7fff,0xc(%ebp)
8010288b:	7e 07                	jle    80102894 <chown+0x23>
    return -1;
8010288d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102892:	eb 68                	jmp    801028fc <chown+0x8b>
  
  begin_op();
80102894:	e8 53 10 00 00       	call   801038ec <begin_op>
  ip = namei(pathname);
80102899:	83 ec 0c             	sub    $0xc,%esp
8010289c:	ff 75 08             	pushl  0x8(%ebp)
8010289f:	e8 7f fe ff ff       	call   80102723 <namei>
801028a4:	83 c4 10             	add    $0x10,%esp
801028a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip == 0)
801028aa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801028ae:	75 0c                	jne    801028bc <chown+0x4b>
  {
    end_op();
801028b0:	e8 c3 10 00 00       	call   80103978 <end_op>
    return -1;
801028b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801028ba:	eb 40                	jmp    801028fc <chown+0x8b>
  }

  ilock(ip);
801028bc:	83 ec 0c             	sub    $0xc,%esp
801028bf:	ff 75 f4             	pushl  -0xc(%ebp)
801028c2:	e8 4e f2 ff ff       	call   80101b15 <ilock>
801028c7:	83 c4 10             	add    $0x10,%esp
  ip->uid = owner;
801028ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801028cd:	89 c2                	mov    %eax,%edx
801028cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028d2:	66 89 50 18          	mov    %dx,0x18(%eax)
  iupdate(ip);
801028d6:	83 ec 0c             	sub    $0xc,%esp
801028d9:	ff 75 f4             	pushl  -0xc(%ebp)
801028dc:	e8 32 f0 ff ff       	call   80101913 <iupdate>
801028e1:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801028e4:	83 ec 0c             	sub    $0xc,%esp
801028e7:	ff 75 f4             	pushl  -0xc(%ebp)
801028ea:	e8 0e f5 ff ff       	call   80101dfd <iunlockput>
801028ef:	83 c4 10             	add    $0x10,%esp
  end_op();
801028f2:	e8 81 10 00 00       	call   80103978 <end_op>
  return 0;
801028f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801028fc:	c9                   	leave  
801028fd:	c3                   	ret    

801028fe <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
801028fe:	55                   	push   %ebp
801028ff:	89 e5                	mov    %esp,%ebp
80102901:	83 ec 14             	sub    $0x14,%esp
80102904:	8b 45 08             	mov    0x8(%ebp),%eax
80102907:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010290b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010290f:	89 c2                	mov    %eax,%edx
80102911:	ec                   	in     (%dx),%al
80102912:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102915:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102919:	c9                   	leave  
8010291a:	c3                   	ret    

8010291b <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
8010291b:	55                   	push   %ebp
8010291c:	89 e5                	mov    %esp,%ebp
8010291e:	57                   	push   %edi
8010291f:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102920:	8b 55 08             	mov    0x8(%ebp),%edx
80102923:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102926:	8b 45 10             	mov    0x10(%ebp),%eax
80102929:	89 cb                	mov    %ecx,%ebx
8010292b:	89 df                	mov    %ebx,%edi
8010292d:	89 c1                	mov    %eax,%ecx
8010292f:	fc                   	cld    
80102930:	f3 6d                	rep insl (%dx),%es:(%edi)
80102932:	89 c8                	mov    %ecx,%eax
80102934:	89 fb                	mov    %edi,%ebx
80102936:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102939:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
8010293c:	90                   	nop
8010293d:	5b                   	pop    %ebx
8010293e:	5f                   	pop    %edi
8010293f:	5d                   	pop    %ebp
80102940:	c3                   	ret    

80102941 <outb>:

static inline void
outb(ushort port, uchar data)
{
80102941:	55                   	push   %ebp
80102942:	89 e5                	mov    %esp,%ebp
80102944:	83 ec 08             	sub    $0x8,%esp
80102947:	8b 55 08             	mov    0x8(%ebp),%edx
8010294a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010294d:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102951:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102954:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102958:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010295c:	ee                   	out    %al,(%dx)
}
8010295d:	90                   	nop
8010295e:	c9                   	leave  
8010295f:	c3                   	ret    

80102960 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102960:	55                   	push   %ebp
80102961:	89 e5                	mov    %esp,%ebp
80102963:	56                   	push   %esi
80102964:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102965:	8b 55 08             	mov    0x8(%ebp),%edx
80102968:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010296b:	8b 45 10             	mov    0x10(%ebp),%eax
8010296e:	89 cb                	mov    %ecx,%ebx
80102970:	89 de                	mov    %ebx,%esi
80102972:	89 c1                	mov    %eax,%ecx
80102974:	fc                   	cld    
80102975:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102977:	89 c8                	mov    %ecx,%eax
80102979:	89 f3                	mov    %esi,%ebx
8010297b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010297e:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102981:	90                   	nop
80102982:	5b                   	pop    %ebx
80102983:	5e                   	pop    %esi
80102984:	5d                   	pop    %ebp
80102985:	c3                   	ret    

80102986 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102986:	55                   	push   %ebp
80102987:	89 e5                	mov    %esp,%ebp
80102989:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
8010298c:	90                   	nop
8010298d:	68 f7 01 00 00       	push   $0x1f7
80102992:	e8 67 ff ff ff       	call   801028fe <inb>
80102997:	83 c4 04             	add    $0x4,%esp
8010299a:	0f b6 c0             	movzbl %al,%eax
8010299d:	89 45 fc             	mov    %eax,-0x4(%ebp)
801029a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801029a3:	25 c0 00 00 00       	and    $0xc0,%eax
801029a8:	83 f8 40             	cmp    $0x40,%eax
801029ab:	75 e0                	jne    8010298d <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801029ad:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801029b1:	74 11                	je     801029c4 <idewait+0x3e>
801029b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801029b6:	83 e0 21             	and    $0x21,%eax
801029b9:	85 c0                	test   %eax,%eax
801029bb:	74 07                	je     801029c4 <idewait+0x3e>
    return -1;
801029bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801029c2:	eb 05                	jmp    801029c9 <idewait+0x43>
  return 0;
801029c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801029c9:	c9                   	leave  
801029ca:	c3                   	ret    

801029cb <ideinit>:

void
ideinit(void)
{
801029cb:	55                   	push   %ebp
801029cc:	89 e5                	mov    %esp,%ebp
801029ce:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  initlock(&idelock, "ide");
801029d1:	83 ec 08             	sub    $0x8,%esp
801029d4:	68 e6 a3 10 80       	push   $0x8010a3e6
801029d9:	68 40 d6 10 80       	push   $0x8010d640
801029de:	e8 02 40 00 00       	call   801069e5 <initlock>
801029e3:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
801029e6:	83 ec 0c             	sub    $0xc,%esp
801029e9:	6a 0e                	push   $0xe
801029eb:	e8 da 18 00 00       	call   801042ca <picenable>
801029f0:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
801029f3:	a1 80 49 11 80       	mov    0x80114980,%eax
801029f8:	83 e8 01             	sub    $0x1,%eax
801029fb:	83 ec 08             	sub    $0x8,%esp
801029fe:	50                   	push   %eax
801029ff:	6a 0e                	push   $0xe
80102a01:	e8 73 04 00 00       	call   80102e79 <ioapicenable>
80102a06:	83 c4 10             	add    $0x10,%esp
  idewait(0);
80102a09:	83 ec 0c             	sub    $0xc,%esp
80102a0c:	6a 00                	push   $0x0
80102a0e:	e8 73 ff ff ff       	call   80102986 <idewait>
80102a13:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102a16:	83 ec 08             	sub    $0x8,%esp
80102a19:	68 f0 00 00 00       	push   $0xf0
80102a1e:	68 f6 01 00 00       	push   $0x1f6
80102a23:	e8 19 ff ff ff       	call   80102941 <outb>
80102a28:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102a2b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102a32:	eb 24                	jmp    80102a58 <ideinit+0x8d>
    if(inb(0x1f7) != 0){
80102a34:	83 ec 0c             	sub    $0xc,%esp
80102a37:	68 f7 01 00 00       	push   $0x1f7
80102a3c:	e8 bd fe ff ff       	call   801028fe <inb>
80102a41:	83 c4 10             	add    $0x10,%esp
80102a44:	84 c0                	test   %al,%al
80102a46:	74 0c                	je     80102a54 <ideinit+0x89>
      havedisk1 = 1;
80102a48:	c7 05 78 d6 10 80 01 	movl   $0x1,0x8010d678
80102a4f:	00 00 00 
      break;
80102a52:	eb 0d                	jmp    80102a61 <ideinit+0x96>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102a54:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102a58:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102a5f:	7e d3                	jle    80102a34 <ideinit+0x69>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102a61:	83 ec 08             	sub    $0x8,%esp
80102a64:	68 e0 00 00 00       	push   $0xe0
80102a69:	68 f6 01 00 00       	push   $0x1f6
80102a6e:	e8 ce fe ff ff       	call   80102941 <outb>
80102a73:	83 c4 10             	add    $0x10,%esp
}
80102a76:	90                   	nop
80102a77:	c9                   	leave  
80102a78:	c3                   	ret    

80102a79 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102a79:	55                   	push   %ebp
80102a7a:	89 e5                	mov    %esp,%ebp
80102a7c:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
80102a7f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102a83:	75 0d                	jne    80102a92 <idestart+0x19>
    panic("idestart");
80102a85:	83 ec 0c             	sub    $0xc,%esp
80102a88:	68 ea a3 10 80       	push   $0x8010a3ea
80102a8d:	e8 d4 da ff ff       	call   80100566 <panic>
  if(b->blockno >= FSSIZE)
80102a92:	8b 45 08             	mov    0x8(%ebp),%eax
80102a95:	8b 40 08             	mov    0x8(%eax),%eax
80102a98:	3d cf 07 00 00       	cmp    $0x7cf,%eax
80102a9d:	76 0d                	jbe    80102aac <idestart+0x33>
    panic("incorrect blockno");
80102a9f:	83 ec 0c             	sub    $0xc,%esp
80102aa2:	68 f3 a3 10 80       	push   $0x8010a3f3
80102aa7:	e8 ba da ff ff       	call   80100566 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102aac:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102ab3:	8b 45 08             	mov    0x8(%ebp),%eax
80102ab6:	8b 50 08             	mov    0x8(%eax),%edx
80102ab9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102abc:	0f af c2             	imul   %edx,%eax
80102abf:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102ac2:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102ac6:	7e 0d                	jle    80102ad5 <idestart+0x5c>
80102ac8:	83 ec 0c             	sub    $0xc,%esp
80102acb:	68 ea a3 10 80       	push   $0x8010a3ea
80102ad0:	e8 91 da ff ff       	call   80100566 <panic>
  
  idewait(0);
80102ad5:	83 ec 0c             	sub    $0xc,%esp
80102ad8:	6a 00                	push   $0x0
80102ada:	e8 a7 fe ff ff       	call   80102986 <idewait>
80102adf:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102ae2:	83 ec 08             	sub    $0x8,%esp
80102ae5:	6a 00                	push   $0x0
80102ae7:	68 f6 03 00 00       	push   $0x3f6
80102aec:	e8 50 fe ff ff       	call   80102941 <outb>
80102af1:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102af7:	0f b6 c0             	movzbl %al,%eax
80102afa:	83 ec 08             	sub    $0x8,%esp
80102afd:	50                   	push   %eax
80102afe:	68 f2 01 00 00       	push   $0x1f2
80102b03:	e8 39 fe ff ff       	call   80102941 <outb>
80102b08:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
80102b0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102b0e:	0f b6 c0             	movzbl %al,%eax
80102b11:	83 ec 08             	sub    $0x8,%esp
80102b14:	50                   	push   %eax
80102b15:	68 f3 01 00 00       	push   $0x1f3
80102b1a:	e8 22 fe ff ff       	call   80102941 <outb>
80102b1f:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102b22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102b25:	c1 f8 08             	sar    $0x8,%eax
80102b28:	0f b6 c0             	movzbl %al,%eax
80102b2b:	83 ec 08             	sub    $0x8,%esp
80102b2e:	50                   	push   %eax
80102b2f:	68 f4 01 00 00       	push   $0x1f4
80102b34:	e8 08 fe ff ff       	call   80102941 <outb>
80102b39:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
80102b3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102b3f:	c1 f8 10             	sar    $0x10,%eax
80102b42:	0f b6 c0             	movzbl %al,%eax
80102b45:	83 ec 08             	sub    $0x8,%esp
80102b48:	50                   	push   %eax
80102b49:	68 f5 01 00 00       	push   $0x1f5
80102b4e:	e8 ee fd ff ff       	call   80102941 <outb>
80102b53:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102b56:	8b 45 08             	mov    0x8(%ebp),%eax
80102b59:	8b 40 04             	mov    0x4(%eax),%eax
80102b5c:	83 e0 01             	and    $0x1,%eax
80102b5f:	c1 e0 04             	shl    $0x4,%eax
80102b62:	89 c2                	mov    %eax,%edx
80102b64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102b67:	c1 f8 18             	sar    $0x18,%eax
80102b6a:	83 e0 0f             	and    $0xf,%eax
80102b6d:	09 d0                	or     %edx,%eax
80102b6f:	83 c8 e0             	or     $0xffffffe0,%eax
80102b72:	0f b6 c0             	movzbl %al,%eax
80102b75:	83 ec 08             	sub    $0x8,%esp
80102b78:	50                   	push   %eax
80102b79:	68 f6 01 00 00       	push   $0x1f6
80102b7e:	e8 be fd ff ff       	call   80102941 <outb>
80102b83:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80102b86:	8b 45 08             	mov    0x8(%ebp),%eax
80102b89:	8b 00                	mov    (%eax),%eax
80102b8b:	83 e0 04             	and    $0x4,%eax
80102b8e:	85 c0                	test   %eax,%eax
80102b90:	74 30                	je     80102bc2 <idestart+0x149>
    outb(0x1f7, IDE_CMD_WRITE);
80102b92:	83 ec 08             	sub    $0x8,%esp
80102b95:	6a 30                	push   $0x30
80102b97:	68 f7 01 00 00       	push   $0x1f7
80102b9c:	e8 a0 fd ff ff       	call   80102941 <outb>
80102ba1:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
80102ba4:	8b 45 08             	mov    0x8(%ebp),%eax
80102ba7:	83 c0 18             	add    $0x18,%eax
80102baa:	83 ec 04             	sub    $0x4,%esp
80102bad:	68 80 00 00 00       	push   $0x80
80102bb2:	50                   	push   %eax
80102bb3:	68 f0 01 00 00       	push   $0x1f0
80102bb8:	e8 a3 fd ff ff       	call   80102960 <outsl>
80102bbd:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
80102bc0:	eb 12                	jmp    80102bd4 <idestart+0x15b>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, IDE_CMD_WRITE);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, IDE_CMD_READ);
80102bc2:	83 ec 08             	sub    $0x8,%esp
80102bc5:	6a 20                	push   $0x20
80102bc7:	68 f7 01 00 00       	push   $0x1f7
80102bcc:	e8 70 fd ff ff       	call   80102941 <outb>
80102bd1:	83 c4 10             	add    $0x10,%esp
  }
}
80102bd4:	90                   	nop
80102bd5:	c9                   	leave  
80102bd6:	c3                   	ret    

80102bd7 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102bd7:	55                   	push   %ebp
80102bd8:	89 e5                	mov    %esp,%ebp
80102bda:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102bdd:	83 ec 0c             	sub    $0xc,%esp
80102be0:	68 40 d6 10 80       	push   $0x8010d640
80102be5:	e8 1d 3e 00 00       	call   80106a07 <acquire>
80102bea:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
80102bed:	a1 74 d6 10 80       	mov    0x8010d674,%eax
80102bf2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102bf5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102bf9:	75 15                	jne    80102c10 <ideintr+0x39>
    release(&idelock);
80102bfb:	83 ec 0c             	sub    $0xc,%esp
80102bfe:	68 40 d6 10 80       	push   $0x8010d640
80102c03:	e8 66 3e 00 00       	call   80106a6e <release>
80102c08:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
80102c0b:	e9 9a 00 00 00       	jmp    80102caa <ideintr+0xd3>
  }
  idequeue = b->qnext;
80102c10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c13:	8b 40 14             	mov    0x14(%eax),%eax
80102c16:	a3 74 d6 10 80       	mov    %eax,0x8010d674

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102c1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c1e:	8b 00                	mov    (%eax),%eax
80102c20:	83 e0 04             	and    $0x4,%eax
80102c23:	85 c0                	test   %eax,%eax
80102c25:	75 2d                	jne    80102c54 <ideintr+0x7d>
80102c27:	83 ec 0c             	sub    $0xc,%esp
80102c2a:	6a 01                	push   $0x1
80102c2c:	e8 55 fd ff ff       	call   80102986 <idewait>
80102c31:	83 c4 10             	add    $0x10,%esp
80102c34:	85 c0                	test   %eax,%eax
80102c36:	78 1c                	js     80102c54 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
80102c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c3b:	83 c0 18             	add    $0x18,%eax
80102c3e:	83 ec 04             	sub    $0x4,%esp
80102c41:	68 80 00 00 00       	push   $0x80
80102c46:	50                   	push   %eax
80102c47:	68 f0 01 00 00       	push   $0x1f0
80102c4c:	e8 ca fc ff ff       	call   8010291b <insl>
80102c51:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102c54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c57:	8b 00                	mov    (%eax),%eax
80102c59:	83 c8 02             	or     $0x2,%eax
80102c5c:	89 c2                	mov    %eax,%edx
80102c5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c61:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102c63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c66:	8b 00                	mov    (%eax),%eax
80102c68:	83 e0 fb             	and    $0xfffffffb,%eax
80102c6b:	89 c2                	mov    %eax,%edx
80102c6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c70:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102c72:	83 ec 0c             	sub    $0xc,%esp
80102c75:	ff 75 f4             	pushl  -0xc(%ebp)
80102c78:	e8 82 2f 00 00       	call   80105bff <wakeup>
80102c7d:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80102c80:	a1 74 d6 10 80       	mov    0x8010d674,%eax
80102c85:	85 c0                	test   %eax,%eax
80102c87:	74 11                	je     80102c9a <ideintr+0xc3>
    idestart(idequeue);
80102c89:	a1 74 d6 10 80       	mov    0x8010d674,%eax
80102c8e:	83 ec 0c             	sub    $0xc,%esp
80102c91:	50                   	push   %eax
80102c92:	e8 e2 fd ff ff       	call   80102a79 <idestart>
80102c97:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102c9a:	83 ec 0c             	sub    $0xc,%esp
80102c9d:	68 40 d6 10 80       	push   $0x8010d640
80102ca2:	e8 c7 3d 00 00       	call   80106a6e <release>
80102ca7:	83 c4 10             	add    $0x10,%esp
}
80102caa:	c9                   	leave  
80102cab:	c3                   	ret    

80102cac <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102cac:	55                   	push   %ebp
80102cad:	89 e5                	mov    %esp,%ebp
80102caf:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102cb2:	8b 45 08             	mov    0x8(%ebp),%eax
80102cb5:	8b 00                	mov    (%eax),%eax
80102cb7:	83 e0 01             	and    $0x1,%eax
80102cba:	85 c0                	test   %eax,%eax
80102cbc:	75 0d                	jne    80102ccb <iderw+0x1f>
    panic("iderw: buf not busy");
80102cbe:	83 ec 0c             	sub    $0xc,%esp
80102cc1:	68 05 a4 10 80       	push   $0x8010a405
80102cc6:	e8 9b d8 ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102ccb:	8b 45 08             	mov    0x8(%ebp),%eax
80102cce:	8b 00                	mov    (%eax),%eax
80102cd0:	83 e0 06             	and    $0x6,%eax
80102cd3:	83 f8 02             	cmp    $0x2,%eax
80102cd6:	75 0d                	jne    80102ce5 <iderw+0x39>
    panic("iderw: nothing to do");
80102cd8:	83 ec 0c             	sub    $0xc,%esp
80102cdb:	68 19 a4 10 80       	push   $0x8010a419
80102ce0:	e8 81 d8 ff ff       	call   80100566 <panic>
  if(b->dev != 0 && !havedisk1)
80102ce5:	8b 45 08             	mov    0x8(%ebp),%eax
80102ce8:	8b 40 04             	mov    0x4(%eax),%eax
80102ceb:	85 c0                	test   %eax,%eax
80102ced:	74 16                	je     80102d05 <iderw+0x59>
80102cef:	a1 78 d6 10 80       	mov    0x8010d678,%eax
80102cf4:	85 c0                	test   %eax,%eax
80102cf6:	75 0d                	jne    80102d05 <iderw+0x59>
    panic("iderw: ide disk 1 not present");
80102cf8:	83 ec 0c             	sub    $0xc,%esp
80102cfb:	68 2e a4 10 80       	push   $0x8010a42e
80102d00:	e8 61 d8 ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102d05:	83 ec 0c             	sub    $0xc,%esp
80102d08:	68 40 d6 10 80       	push   $0x8010d640
80102d0d:	e8 f5 3c 00 00       	call   80106a07 <acquire>
80102d12:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102d15:	8b 45 08             	mov    0x8(%ebp),%eax
80102d18:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102d1f:	c7 45 f4 74 d6 10 80 	movl   $0x8010d674,-0xc(%ebp)
80102d26:	eb 0b                	jmp    80102d33 <iderw+0x87>
80102d28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d2b:	8b 00                	mov    (%eax),%eax
80102d2d:	83 c0 14             	add    $0x14,%eax
80102d30:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d36:	8b 00                	mov    (%eax),%eax
80102d38:	85 c0                	test   %eax,%eax
80102d3a:	75 ec                	jne    80102d28 <iderw+0x7c>
    ;
  *pp = b;
80102d3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d3f:	8b 55 08             	mov    0x8(%ebp),%edx
80102d42:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102d44:	a1 74 d6 10 80       	mov    0x8010d674,%eax
80102d49:	3b 45 08             	cmp    0x8(%ebp),%eax
80102d4c:	75 23                	jne    80102d71 <iderw+0xc5>
    idestart(b);
80102d4e:	83 ec 0c             	sub    $0xc,%esp
80102d51:	ff 75 08             	pushl  0x8(%ebp)
80102d54:	e8 20 fd ff ff       	call   80102a79 <idestart>
80102d59:	83 c4 10             	add    $0x10,%esp
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102d5c:	eb 13                	jmp    80102d71 <iderw+0xc5>
    sleep(b, &idelock);
80102d5e:	83 ec 08             	sub    $0x8,%esp
80102d61:	68 40 d6 10 80       	push   $0x8010d640
80102d66:	ff 75 08             	pushl  0x8(%ebp)
80102d69:	e8 3e 2c 00 00       	call   801059ac <sleep>
80102d6e:	83 c4 10             	add    $0x10,%esp
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102d71:	8b 45 08             	mov    0x8(%ebp),%eax
80102d74:	8b 00                	mov    (%eax),%eax
80102d76:	83 e0 06             	and    $0x6,%eax
80102d79:	83 f8 02             	cmp    $0x2,%eax
80102d7c:	75 e0                	jne    80102d5e <iderw+0xb2>
    sleep(b, &idelock);
  }

  release(&idelock);
80102d7e:	83 ec 0c             	sub    $0xc,%esp
80102d81:	68 40 d6 10 80       	push   $0x8010d640
80102d86:	e8 e3 3c 00 00       	call   80106a6e <release>
80102d8b:	83 c4 10             	add    $0x10,%esp
}
80102d8e:	90                   	nop
80102d8f:	c9                   	leave  
80102d90:	c3                   	ret    

80102d91 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102d91:	55                   	push   %ebp
80102d92:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102d94:	a1 54 42 11 80       	mov    0x80114254,%eax
80102d99:	8b 55 08             	mov    0x8(%ebp),%edx
80102d9c:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102d9e:	a1 54 42 11 80       	mov    0x80114254,%eax
80102da3:	8b 40 10             	mov    0x10(%eax),%eax
}
80102da6:	5d                   	pop    %ebp
80102da7:	c3                   	ret    

80102da8 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102da8:	55                   	push   %ebp
80102da9:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102dab:	a1 54 42 11 80       	mov    0x80114254,%eax
80102db0:	8b 55 08             	mov    0x8(%ebp),%edx
80102db3:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102db5:	a1 54 42 11 80       	mov    0x80114254,%eax
80102dba:	8b 55 0c             	mov    0xc(%ebp),%edx
80102dbd:	89 50 10             	mov    %edx,0x10(%eax)
}
80102dc0:	90                   	nop
80102dc1:	5d                   	pop    %ebp
80102dc2:	c3                   	ret    

80102dc3 <ioapicinit>:

void
ioapicinit(void)
{
80102dc3:	55                   	push   %ebp
80102dc4:	89 e5                	mov    %esp,%ebp
80102dc6:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
80102dc9:	a1 84 43 11 80       	mov    0x80114384,%eax
80102dce:	85 c0                	test   %eax,%eax
80102dd0:	0f 84 a0 00 00 00    	je     80102e76 <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102dd6:	c7 05 54 42 11 80 00 	movl   $0xfec00000,0x80114254
80102ddd:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102de0:	6a 01                	push   $0x1
80102de2:	e8 aa ff ff ff       	call   80102d91 <ioapicread>
80102de7:	83 c4 04             	add    $0x4,%esp
80102dea:	c1 e8 10             	shr    $0x10,%eax
80102ded:	25 ff 00 00 00       	and    $0xff,%eax
80102df2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102df5:	6a 00                	push   $0x0
80102df7:	e8 95 ff ff ff       	call   80102d91 <ioapicread>
80102dfc:	83 c4 04             	add    $0x4,%esp
80102dff:	c1 e8 18             	shr    $0x18,%eax
80102e02:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102e05:	0f b6 05 80 43 11 80 	movzbl 0x80114380,%eax
80102e0c:	0f b6 c0             	movzbl %al,%eax
80102e0f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102e12:	74 10                	je     80102e24 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102e14:	83 ec 0c             	sub    $0xc,%esp
80102e17:	68 4c a4 10 80       	push   $0x8010a44c
80102e1c:	e8 a5 d5 ff ff       	call   801003c6 <cprintf>
80102e21:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102e24:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102e2b:	eb 3f                	jmp    80102e6c <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102e2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e30:	83 c0 20             	add    $0x20,%eax
80102e33:	0d 00 00 01 00       	or     $0x10000,%eax
80102e38:	89 c2                	mov    %eax,%edx
80102e3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e3d:	83 c0 08             	add    $0x8,%eax
80102e40:	01 c0                	add    %eax,%eax
80102e42:	83 ec 08             	sub    $0x8,%esp
80102e45:	52                   	push   %edx
80102e46:	50                   	push   %eax
80102e47:	e8 5c ff ff ff       	call   80102da8 <ioapicwrite>
80102e4c:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102e4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e52:	83 c0 08             	add    $0x8,%eax
80102e55:	01 c0                	add    %eax,%eax
80102e57:	83 c0 01             	add    $0x1,%eax
80102e5a:	83 ec 08             	sub    $0x8,%esp
80102e5d:	6a 00                	push   $0x0
80102e5f:	50                   	push   %eax
80102e60:	e8 43 ff ff ff       	call   80102da8 <ioapicwrite>
80102e65:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102e68:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102e6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e6f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102e72:	7e b9                	jle    80102e2d <ioapicinit+0x6a>
80102e74:	eb 01                	jmp    80102e77 <ioapicinit+0xb4>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80102e76:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102e77:	c9                   	leave  
80102e78:	c3                   	ret    

80102e79 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102e79:	55                   	push   %ebp
80102e7a:	89 e5                	mov    %esp,%ebp
  if(!ismp)
80102e7c:	a1 84 43 11 80       	mov    0x80114384,%eax
80102e81:	85 c0                	test   %eax,%eax
80102e83:	74 39                	je     80102ebe <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102e85:	8b 45 08             	mov    0x8(%ebp),%eax
80102e88:	83 c0 20             	add    $0x20,%eax
80102e8b:	89 c2                	mov    %eax,%edx
80102e8d:	8b 45 08             	mov    0x8(%ebp),%eax
80102e90:	83 c0 08             	add    $0x8,%eax
80102e93:	01 c0                	add    %eax,%eax
80102e95:	52                   	push   %edx
80102e96:	50                   	push   %eax
80102e97:	e8 0c ff ff ff       	call   80102da8 <ioapicwrite>
80102e9c:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102e9f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ea2:	c1 e0 18             	shl    $0x18,%eax
80102ea5:	89 c2                	mov    %eax,%edx
80102ea7:	8b 45 08             	mov    0x8(%ebp),%eax
80102eaa:	83 c0 08             	add    $0x8,%eax
80102ead:	01 c0                	add    %eax,%eax
80102eaf:	83 c0 01             	add    $0x1,%eax
80102eb2:	52                   	push   %edx
80102eb3:	50                   	push   %eax
80102eb4:	e8 ef fe ff ff       	call   80102da8 <ioapicwrite>
80102eb9:	83 c4 08             	add    $0x8,%esp
80102ebc:	eb 01                	jmp    80102ebf <ioapicenable+0x46>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80102ebe:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102ebf:	c9                   	leave  
80102ec0:	c3                   	ret    

80102ec1 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102ec1:	55                   	push   %ebp
80102ec2:	89 e5                	mov    %esp,%ebp
80102ec4:	8b 45 08             	mov    0x8(%ebp),%eax
80102ec7:	05 00 00 00 80       	add    $0x80000000,%eax
80102ecc:	5d                   	pop    %ebp
80102ecd:	c3                   	ret    

80102ece <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102ece:	55                   	push   %ebp
80102ecf:	89 e5                	mov    %esp,%ebp
80102ed1:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102ed4:	83 ec 08             	sub    $0x8,%esp
80102ed7:	68 7e a4 10 80       	push   $0x8010a47e
80102edc:	68 60 42 11 80       	push   $0x80114260
80102ee1:	e8 ff 3a 00 00       	call   801069e5 <initlock>
80102ee6:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102ee9:	c7 05 94 42 11 80 00 	movl   $0x0,0x80114294
80102ef0:	00 00 00 
  freerange(vstart, vend);
80102ef3:	83 ec 08             	sub    $0x8,%esp
80102ef6:	ff 75 0c             	pushl  0xc(%ebp)
80102ef9:	ff 75 08             	pushl  0x8(%ebp)
80102efc:	e8 2a 00 00 00       	call   80102f2b <freerange>
80102f01:	83 c4 10             	add    $0x10,%esp
}
80102f04:	90                   	nop
80102f05:	c9                   	leave  
80102f06:	c3                   	ret    

80102f07 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102f07:	55                   	push   %ebp
80102f08:	89 e5                	mov    %esp,%ebp
80102f0a:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102f0d:	83 ec 08             	sub    $0x8,%esp
80102f10:	ff 75 0c             	pushl  0xc(%ebp)
80102f13:	ff 75 08             	pushl  0x8(%ebp)
80102f16:	e8 10 00 00 00       	call   80102f2b <freerange>
80102f1b:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102f1e:	c7 05 94 42 11 80 01 	movl   $0x1,0x80114294
80102f25:	00 00 00 
}
80102f28:	90                   	nop
80102f29:	c9                   	leave  
80102f2a:	c3                   	ret    

80102f2b <freerange>:

void
freerange(void *vstart, void *vend)
{
80102f2b:	55                   	push   %ebp
80102f2c:	89 e5                	mov    %esp,%ebp
80102f2e:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102f31:	8b 45 08             	mov    0x8(%ebp),%eax
80102f34:	05 ff 0f 00 00       	add    $0xfff,%eax
80102f39:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102f3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102f41:	eb 15                	jmp    80102f58 <freerange+0x2d>
    kfree(p);
80102f43:	83 ec 0c             	sub    $0xc,%esp
80102f46:	ff 75 f4             	pushl  -0xc(%ebp)
80102f49:	e8 1a 00 00 00       	call   80102f68 <kfree>
80102f4e:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102f51:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102f58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f5b:	05 00 10 00 00       	add    $0x1000,%eax
80102f60:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102f63:	76 de                	jbe    80102f43 <freerange+0x18>
    kfree(p);
}
80102f65:	90                   	nop
80102f66:	c9                   	leave  
80102f67:	c3                   	ret    

80102f68 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102f68:	55                   	push   %ebp
80102f69:	89 e5                	mov    %esp,%ebp
80102f6b:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102f6e:	8b 45 08             	mov    0x8(%ebp),%eax
80102f71:	25 ff 0f 00 00       	and    $0xfff,%eax
80102f76:	85 c0                	test   %eax,%eax
80102f78:	75 1b                	jne    80102f95 <kfree+0x2d>
80102f7a:	81 7d 08 7c 79 11 80 	cmpl   $0x8011797c,0x8(%ebp)
80102f81:	72 12                	jb     80102f95 <kfree+0x2d>
80102f83:	ff 75 08             	pushl  0x8(%ebp)
80102f86:	e8 36 ff ff ff       	call   80102ec1 <v2p>
80102f8b:	83 c4 04             	add    $0x4,%esp
80102f8e:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102f93:	76 0d                	jbe    80102fa2 <kfree+0x3a>
    panic("kfree");
80102f95:	83 ec 0c             	sub    $0xc,%esp
80102f98:	68 83 a4 10 80       	push   $0x8010a483
80102f9d:	e8 c4 d5 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102fa2:	83 ec 04             	sub    $0x4,%esp
80102fa5:	68 00 10 00 00       	push   $0x1000
80102faa:	6a 01                	push   $0x1
80102fac:	ff 75 08             	pushl  0x8(%ebp)
80102faf:	e8 b6 3c 00 00       	call   80106c6a <memset>
80102fb4:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102fb7:	a1 94 42 11 80       	mov    0x80114294,%eax
80102fbc:	85 c0                	test   %eax,%eax
80102fbe:	74 10                	je     80102fd0 <kfree+0x68>
    acquire(&kmem.lock);
80102fc0:	83 ec 0c             	sub    $0xc,%esp
80102fc3:	68 60 42 11 80       	push   $0x80114260
80102fc8:	e8 3a 3a 00 00       	call   80106a07 <acquire>
80102fcd:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102fd0:	8b 45 08             	mov    0x8(%ebp),%eax
80102fd3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102fd6:	8b 15 98 42 11 80    	mov    0x80114298,%edx
80102fdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fdf:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102fe1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fe4:	a3 98 42 11 80       	mov    %eax,0x80114298
  if(kmem.use_lock)
80102fe9:	a1 94 42 11 80       	mov    0x80114294,%eax
80102fee:	85 c0                	test   %eax,%eax
80102ff0:	74 10                	je     80103002 <kfree+0x9a>
    release(&kmem.lock);
80102ff2:	83 ec 0c             	sub    $0xc,%esp
80102ff5:	68 60 42 11 80       	push   $0x80114260
80102ffa:	e8 6f 3a 00 00       	call   80106a6e <release>
80102fff:	83 c4 10             	add    $0x10,%esp
}
80103002:	90                   	nop
80103003:	c9                   	leave  
80103004:	c3                   	ret    

80103005 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80103005:	55                   	push   %ebp
80103006:	89 e5                	mov    %esp,%ebp
80103008:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
8010300b:	a1 94 42 11 80       	mov    0x80114294,%eax
80103010:	85 c0                	test   %eax,%eax
80103012:	74 10                	je     80103024 <kalloc+0x1f>
    acquire(&kmem.lock);
80103014:	83 ec 0c             	sub    $0xc,%esp
80103017:	68 60 42 11 80       	push   $0x80114260
8010301c:	e8 e6 39 00 00       	call   80106a07 <acquire>
80103021:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80103024:	a1 98 42 11 80       	mov    0x80114298,%eax
80103029:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
8010302c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103030:	74 0a                	je     8010303c <kalloc+0x37>
    kmem.freelist = r->next;
80103032:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103035:	8b 00                	mov    (%eax),%eax
80103037:	a3 98 42 11 80       	mov    %eax,0x80114298
  if(kmem.use_lock)
8010303c:	a1 94 42 11 80       	mov    0x80114294,%eax
80103041:	85 c0                	test   %eax,%eax
80103043:	74 10                	je     80103055 <kalloc+0x50>
    release(&kmem.lock);
80103045:	83 ec 0c             	sub    $0xc,%esp
80103048:	68 60 42 11 80       	push   $0x80114260
8010304d:	e8 1c 3a 00 00       	call   80106a6e <release>
80103052:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80103055:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103058:	c9                   	leave  
80103059:	c3                   	ret    

8010305a <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
8010305a:	55                   	push   %ebp
8010305b:	89 e5                	mov    %esp,%ebp
8010305d:	83 ec 14             	sub    $0x14,%esp
80103060:	8b 45 08             	mov    0x8(%ebp),%eax
80103063:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103067:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010306b:	89 c2                	mov    %eax,%edx
8010306d:	ec                   	in     (%dx),%al
8010306e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103071:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103075:	c9                   	leave  
80103076:	c3                   	ret    

80103077 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80103077:	55                   	push   %ebp
80103078:	89 e5                	mov    %esp,%ebp
8010307a:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
8010307d:	6a 64                	push   $0x64
8010307f:	e8 d6 ff ff ff       	call   8010305a <inb>
80103084:	83 c4 04             	add    $0x4,%esp
80103087:	0f b6 c0             	movzbl %al,%eax
8010308a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
8010308d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103090:	83 e0 01             	and    $0x1,%eax
80103093:	85 c0                	test   %eax,%eax
80103095:	75 0a                	jne    801030a1 <kbdgetc+0x2a>
    return -1;
80103097:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010309c:	e9 23 01 00 00       	jmp    801031c4 <kbdgetc+0x14d>
  data = inb(KBDATAP);
801030a1:	6a 60                	push   $0x60
801030a3:	e8 b2 ff ff ff       	call   8010305a <inb>
801030a8:	83 c4 04             	add    $0x4,%esp
801030ab:	0f b6 c0             	movzbl %al,%eax
801030ae:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
801030b1:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
801030b8:	75 17                	jne    801030d1 <kbdgetc+0x5a>
    shift |= E0ESC;
801030ba:	a1 7c d6 10 80       	mov    0x8010d67c,%eax
801030bf:	83 c8 40             	or     $0x40,%eax
801030c2:	a3 7c d6 10 80       	mov    %eax,0x8010d67c
    return 0;
801030c7:	b8 00 00 00 00       	mov    $0x0,%eax
801030cc:	e9 f3 00 00 00       	jmp    801031c4 <kbdgetc+0x14d>
  } else if(data & 0x80){
801030d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801030d4:	25 80 00 00 00       	and    $0x80,%eax
801030d9:	85 c0                	test   %eax,%eax
801030db:	74 45                	je     80103122 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
801030dd:	a1 7c d6 10 80       	mov    0x8010d67c,%eax
801030e2:	83 e0 40             	and    $0x40,%eax
801030e5:	85 c0                	test   %eax,%eax
801030e7:	75 08                	jne    801030f1 <kbdgetc+0x7a>
801030e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801030ec:	83 e0 7f             	and    $0x7f,%eax
801030ef:	eb 03                	jmp    801030f4 <kbdgetc+0x7d>
801030f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801030f4:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
801030f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801030fa:	05 20 b0 10 80       	add    $0x8010b020,%eax
801030ff:	0f b6 00             	movzbl (%eax),%eax
80103102:	83 c8 40             	or     $0x40,%eax
80103105:	0f b6 c0             	movzbl %al,%eax
80103108:	f7 d0                	not    %eax
8010310a:	89 c2                	mov    %eax,%edx
8010310c:	a1 7c d6 10 80       	mov    0x8010d67c,%eax
80103111:	21 d0                	and    %edx,%eax
80103113:	a3 7c d6 10 80       	mov    %eax,0x8010d67c
    return 0;
80103118:	b8 00 00 00 00       	mov    $0x0,%eax
8010311d:	e9 a2 00 00 00       	jmp    801031c4 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80103122:	a1 7c d6 10 80       	mov    0x8010d67c,%eax
80103127:	83 e0 40             	and    $0x40,%eax
8010312a:	85 c0                	test   %eax,%eax
8010312c:	74 14                	je     80103142 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
8010312e:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80103135:	a1 7c d6 10 80       	mov    0x8010d67c,%eax
8010313a:	83 e0 bf             	and    $0xffffffbf,%eax
8010313d:	a3 7c d6 10 80       	mov    %eax,0x8010d67c
  }

  shift |= shiftcode[data];
80103142:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103145:	05 20 b0 10 80       	add    $0x8010b020,%eax
8010314a:	0f b6 00             	movzbl (%eax),%eax
8010314d:	0f b6 d0             	movzbl %al,%edx
80103150:	a1 7c d6 10 80       	mov    0x8010d67c,%eax
80103155:	09 d0                	or     %edx,%eax
80103157:	a3 7c d6 10 80       	mov    %eax,0x8010d67c
  shift ^= togglecode[data];
8010315c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010315f:	05 20 b1 10 80       	add    $0x8010b120,%eax
80103164:	0f b6 00             	movzbl (%eax),%eax
80103167:	0f b6 d0             	movzbl %al,%edx
8010316a:	a1 7c d6 10 80       	mov    0x8010d67c,%eax
8010316f:	31 d0                	xor    %edx,%eax
80103171:	a3 7c d6 10 80       	mov    %eax,0x8010d67c
  c = charcode[shift & (CTL | SHIFT)][data];
80103176:	a1 7c d6 10 80       	mov    0x8010d67c,%eax
8010317b:	83 e0 03             	and    $0x3,%eax
8010317e:	8b 14 85 20 b5 10 80 	mov    -0x7fef4ae0(,%eax,4),%edx
80103185:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103188:	01 d0                	add    %edx,%eax
8010318a:	0f b6 00             	movzbl (%eax),%eax
8010318d:	0f b6 c0             	movzbl %al,%eax
80103190:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80103193:	a1 7c d6 10 80       	mov    0x8010d67c,%eax
80103198:	83 e0 08             	and    $0x8,%eax
8010319b:	85 c0                	test   %eax,%eax
8010319d:	74 22                	je     801031c1 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
8010319f:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
801031a3:	76 0c                	jbe    801031b1 <kbdgetc+0x13a>
801031a5:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
801031a9:	77 06                	ja     801031b1 <kbdgetc+0x13a>
      c += 'A' - 'a';
801031ab:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
801031af:	eb 10                	jmp    801031c1 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
801031b1:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
801031b5:	76 0a                	jbe    801031c1 <kbdgetc+0x14a>
801031b7:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
801031bb:	77 04                	ja     801031c1 <kbdgetc+0x14a>
      c += 'a' - 'A';
801031bd:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
801031c1:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801031c4:	c9                   	leave  
801031c5:	c3                   	ret    

801031c6 <kbdintr>:

void
kbdintr(void)
{
801031c6:	55                   	push   %ebp
801031c7:	89 e5                	mov    %esp,%ebp
801031c9:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
801031cc:	83 ec 0c             	sub    $0xc,%esp
801031cf:	68 77 30 10 80       	push   $0x80103077
801031d4:	e8 20 d6 ff ff       	call   801007f9 <consoleintr>
801031d9:	83 c4 10             	add    $0x10,%esp
}
801031dc:	90                   	nop
801031dd:	c9                   	leave  
801031de:	c3                   	ret    

801031df <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
801031df:	55                   	push   %ebp
801031e0:	89 e5                	mov    %esp,%ebp
801031e2:	83 ec 14             	sub    $0x14,%esp
801031e5:	8b 45 08             	mov    0x8(%ebp),%eax
801031e8:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801031ec:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801031f0:	89 c2                	mov    %eax,%edx
801031f2:	ec                   	in     (%dx),%al
801031f3:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801031f6:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801031fa:	c9                   	leave  
801031fb:	c3                   	ret    

801031fc <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801031fc:	55                   	push   %ebp
801031fd:	89 e5                	mov    %esp,%ebp
801031ff:	83 ec 08             	sub    $0x8,%esp
80103202:	8b 55 08             	mov    0x8(%ebp),%edx
80103205:	8b 45 0c             	mov    0xc(%ebp),%eax
80103208:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010320c:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010320f:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103213:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103217:	ee                   	out    %al,(%dx)
}
80103218:	90                   	nop
80103219:	c9                   	leave  
8010321a:	c3                   	ret    

8010321b <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
8010321b:	55                   	push   %ebp
8010321c:	89 e5                	mov    %esp,%ebp
8010321e:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103221:	9c                   	pushf  
80103222:	58                   	pop    %eax
80103223:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103226:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103229:	c9                   	leave  
8010322a:	c3                   	ret    

8010322b <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
8010322b:	55                   	push   %ebp
8010322c:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
8010322e:	a1 9c 42 11 80       	mov    0x8011429c,%eax
80103233:	8b 55 08             	mov    0x8(%ebp),%edx
80103236:	c1 e2 02             	shl    $0x2,%edx
80103239:	01 c2                	add    %eax,%edx
8010323b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010323e:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80103240:	a1 9c 42 11 80       	mov    0x8011429c,%eax
80103245:	83 c0 20             	add    $0x20,%eax
80103248:	8b 00                	mov    (%eax),%eax
}
8010324a:	90                   	nop
8010324b:	5d                   	pop    %ebp
8010324c:	c3                   	ret    

8010324d <lapicinit>:

void
lapicinit(void)
{
8010324d:	55                   	push   %ebp
8010324e:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
80103250:	a1 9c 42 11 80       	mov    0x8011429c,%eax
80103255:	85 c0                	test   %eax,%eax
80103257:	0f 84 0b 01 00 00    	je     80103368 <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
8010325d:	68 3f 01 00 00       	push   $0x13f
80103262:	6a 3c                	push   $0x3c
80103264:	e8 c2 ff ff ff       	call   8010322b <lapicw>
80103269:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
8010326c:	6a 0b                	push   $0xb
8010326e:	68 f8 00 00 00       	push   $0xf8
80103273:	e8 b3 ff ff ff       	call   8010322b <lapicw>
80103278:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
8010327b:	68 20 00 02 00       	push   $0x20020
80103280:	68 c8 00 00 00       	push   $0xc8
80103285:	e8 a1 ff ff ff       	call   8010322b <lapicw>
8010328a:	83 c4 08             	add    $0x8,%esp
  // lapicw(TICR, 10000000); 
  lapicw(TICR, 1000000000/TPS); // PSU CS333. Makes ticks per second programmable
8010328d:	68 40 42 0f 00       	push   $0xf4240
80103292:	68 e0 00 00 00       	push   $0xe0
80103297:	e8 8f ff ff ff       	call   8010322b <lapicw>
8010329c:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
8010329f:	68 00 00 01 00       	push   $0x10000
801032a4:	68 d4 00 00 00       	push   $0xd4
801032a9:	e8 7d ff ff ff       	call   8010322b <lapicw>
801032ae:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
801032b1:	68 00 00 01 00       	push   $0x10000
801032b6:	68 d8 00 00 00       	push   $0xd8
801032bb:	e8 6b ff ff ff       	call   8010322b <lapicw>
801032c0:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
801032c3:	a1 9c 42 11 80       	mov    0x8011429c,%eax
801032c8:	83 c0 30             	add    $0x30,%eax
801032cb:	8b 00                	mov    (%eax),%eax
801032cd:	c1 e8 10             	shr    $0x10,%eax
801032d0:	0f b6 c0             	movzbl %al,%eax
801032d3:	83 f8 03             	cmp    $0x3,%eax
801032d6:	76 12                	jbe    801032ea <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
801032d8:	68 00 00 01 00       	push   $0x10000
801032dd:	68 d0 00 00 00       	push   $0xd0
801032e2:	e8 44 ff ff ff       	call   8010322b <lapicw>
801032e7:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
801032ea:	6a 33                	push   $0x33
801032ec:	68 dc 00 00 00       	push   $0xdc
801032f1:	e8 35 ff ff ff       	call   8010322b <lapicw>
801032f6:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
801032f9:	6a 00                	push   $0x0
801032fb:	68 a0 00 00 00       	push   $0xa0
80103300:	e8 26 ff ff ff       	call   8010322b <lapicw>
80103305:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80103308:	6a 00                	push   $0x0
8010330a:	68 a0 00 00 00       	push   $0xa0
8010330f:	e8 17 ff ff ff       	call   8010322b <lapicw>
80103314:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80103317:	6a 00                	push   $0x0
80103319:	6a 2c                	push   $0x2c
8010331b:	e8 0b ff ff ff       	call   8010322b <lapicw>
80103320:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103323:	6a 00                	push   $0x0
80103325:	68 c4 00 00 00       	push   $0xc4
8010332a:	e8 fc fe ff ff       	call   8010322b <lapicw>
8010332f:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80103332:	68 00 85 08 00       	push   $0x88500
80103337:	68 c0 00 00 00       	push   $0xc0
8010333c:	e8 ea fe ff ff       	call   8010322b <lapicw>
80103341:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80103344:	90                   	nop
80103345:	a1 9c 42 11 80       	mov    0x8011429c,%eax
8010334a:	05 00 03 00 00       	add    $0x300,%eax
8010334f:	8b 00                	mov    (%eax),%eax
80103351:	25 00 10 00 00       	and    $0x1000,%eax
80103356:	85 c0                	test   %eax,%eax
80103358:	75 eb                	jne    80103345 <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
8010335a:	6a 00                	push   $0x0
8010335c:	6a 20                	push   $0x20
8010335e:	e8 c8 fe ff ff       	call   8010322b <lapicw>
80103363:	83 c4 08             	add    $0x8,%esp
80103366:	eb 01                	jmp    80103369 <lapicinit+0x11c>

void
lapicinit(void)
{
  if(!lapic) 
    return;
80103368:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80103369:	c9                   	leave  
8010336a:	c3                   	ret    

8010336b <cpunum>:

int
cpunum(void)
{
8010336b:	55                   	push   %ebp
8010336c:	89 e5                	mov    %esp,%ebp
8010336e:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80103371:	e8 a5 fe ff ff       	call   8010321b <readeflags>
80103376:	25 00 02 00 00       	and    $0x200,%eax
8010337b:	85 c0                	test   %eax,%eax
8010337d:	74 26                	je     801033a5 <cpunum+0x3a>
    static int n;
    if(n++ == 0)
8010337f:	a1 80 d6 10 80       	mov    0x8010d680,%eax
80103384:	8d 50 01             	lea    0x1(%eax),%edx
80103387:	89 15 80 d6 10 80    	mov    %edx,0x8010d680
8010338d:	85 c0                	test   %eax,%eax
8010338f:	75 14                	jne    801033a5 <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
80103391:	8b 45 04             	mov    0x4(%ebp),%eax
80103394:	83 ec 08             	sub    $0x8,%esp
80103397:	50                   	push   %eax
80103398:	68 8c a4 10 80       	push   $0x8010a48c
8010339d:	e8 24 d0 ff ff       	call   801003c6 <cprintf>
801033a2:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
801033a5:	a1 9c 42 11 80       	mov    0x8011429c,%eax
801033aa:	85 c0                	test   %eax,%eax
801033ac:	74 0f                	je     801033bd <cpunum+0x52>
    return lapic[ID]>>24;
801033ae:	a1 9c 42 11 80       	mov    0x8011429c,%eax
801033b3:	83 c0 20             	add    $0x20,%eax
801033b6:	8b 00                	mov    (%eax),%eax
801033b8:	c1 e8 18             	shr    $0x18,%eax
801033bb:	eb 05                	jmp    801033c2 <cpunum+0x57>
  return 0;
801033bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801033c2:	c9                   	leave  
801033c3:	c3                   	ret    

801033c4 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
801033c4:	55                   	push   %ebp
801033c5:	89 e5                	mov    %esp,%ebp
  if(lapic)
801033c7:	a1 9c 42 11 80       	mov    0x8011429c,%eax
801033cc:	85 c0                	test   %eax,%eax
801033ce:	74 0c                	je     801033dc <lapiceoi+0x18>
    lapicw(EOI, 0);
801033d0:	6a 00                	push   $0x0
801033d2:	6a 2c                	push   $0x2c
801033d4:	e8 52 fe ff ff       	call   8010322b <lapicw>
801033d9:	83 c4 08             	add    $0x8,%esp
}
801033dc:	90                   	nop
801033dd:	c9                   	leave  
801033de:	c3                   	ret    

801033df <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
801033df:	55                   	push   %ebp
801033e0:	89 e5                	mov    %esp,%ebp
}
801033e2:	90                   	nop
801033e3:	5d                   	pop    %ebp
801033e4:	c3                   	ret    

801033e5 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
801033e5:	55                   	push   %ebp
801033e6:	89 e5                	mov    %esp,%ebp
801033e8:	83 ec 14             	sub    $0x14,%esp
801033eb:	8b 45 08             	mov    0x8(%ebp),%eax
801033ee:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
801033f1:	6a 0f                	push   $0xf
801033f3:	6a 70                	push   $0x70
801033f5:	e8 02 fe ff ff       	call   801031fc <outb>
801033fa:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
801033fd:	6a 0a                	push   $0xa
801033ff:	6a 71                	push   $0x71
80103401:	e8 f6 fd ff ff       	call   801031fc <outb>
80103406:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103409:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103410:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103413:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103418:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010341b:	83 c0 02             	add    $0x2,%eax
8010341e:	8b 55 0c             	mov    0xc(%ebp),%edx
80103421:	c1 ea 04             	shr    $0x4,%edx
80103424:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103427:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010342b:	c1 e0 18             	shl    $0x18,%eax
8010342e:	50                   	push   %eax
8010342f:	68 c4 00 00 00       	push   $0xc4
80103434:	e8 f2 fd ff ff       	call   8010322b <lapicw>
80103439:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010343c:	68 00 c5 00 00       	push   $0xc500
80103441:	68 c0 00 00 00       	push   $0xc0
80103446:	e8 e0 fd ff ff       	call   8010322b <lapicw>
8010344b:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010344e:	68 c8 00 00 00       	push   $0xc8
80103453:	e8 87 ff ff ff       	call   801033df <microdelay>
80103458:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
8010345b:	68 00 85 00 00       	push   $0x8500
80103460:	68 c0 00 00 00       	push   $0xc0
80103465:	e8 c1 fd ff ff       	call   8010322b <lapicw>
8010346a:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
8010346d:	6a 64                	push   $0x64
8010346f:	e8 6b ff ff ff       	call   801033df <microdelay>
80103474:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103477:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010347e:	eb 3d                	jmp    801034bd <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
80103480:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103484:	c1 e0 18             	shl    $0x18,%eax
80103487:	50                   	push   %eax
80103488:	68 c4 00 00 00       	push   $0xc4
8010348d:	e8 99 fd ff ff       	call   8010322b <lapicw>
80103492:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80103495:	8b 45 0c             	mov    0xc(%ebp),%eax
80103498:	c1 e8 0c             	shr    $0xc,%eax
8010349b:	80 cc 06             	or     $0x6,%ah
8010349e:	50                   	push   %eax
8010349f:	68 c0 00 00 00       	push   $0xc0
801034a4:	e8 82 fd ff ff       	call   8010322b <lapicw>
801034a9:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
801034ac:	68 c8 00 00 00       	push   $0xc8
801034b1:	e8 29 ff ff ff       	call   801033df <microdelay>
801034b6:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801034b9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801034bd:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801034c1:	7e bd                	jle    80103480 <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
801034c3:	90                   	nop
801034c4:	c9                   	leave  
801034c5:	c3                   	ret    

801034c6 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
801034c6:	55                   	push   %ebp
801034c7:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
801034c9:	8b 45 08             	mov    0x8(%ebp),%eax
801034cc:	0f b6 c0             	movzbl %al,%eax
801034cf:	50                   	push   %eax
801034d0:	6a 70                	push   $0x70
801034d2:	e8 25 fd ff ff       	call   801031fc <outb>
801034d7:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801034da:	68 c8 00 00 00       	push   $0xc8
801034df:	e8 fb fe ff ff       	call   801033df <microdelay>
801034e4:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
801034e7:	6a 71                	push   $0x71
801034e9:	e8 f1 fc ff ff       	call   801031df <inb>
801034ee:	83 c4 04             	add    $0x4,%esp
801034f1:	0f b6 c0             	movzbl %al,%eax
}
801034f4:	c9                   	leave  
801034f5:	c3                   	ret    

801034f6 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
801034f6:	55                   	push   %ebp
801034f7:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
801034f9:	6a 00                	push   $0x0
801034fb:	e8 c6 ff ff ff       	call   801034c6 <cmos_read>
80103500:	83 c4 04             	add    $0x4,%esp
80103503:	89 c2                	mov    %eax,%edx
80103505:	8b 45 08             	mov    0x8(%ebp),%eax
80103508:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
8010350a:	6a 02                	push   $0x2
8010350c:	e8 b5 ff ff ff       	call   801034c6 <cmos_read>
80103511:	83 c4 04             	add    $0x4,%esp
80103514:	89 c2                	mov    %eax,%edx
80103516:	8b 45 08             	mov    0x8(%ebp),%eax
80103519:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
8010351c:	6a 04                	push   $0x4
8010351e:	e8 a3 ff ff ff       	call   801034c6 <cmos_read>
80103523:	83 c4 04             	add    $0x4,%esp
80103526:	89 c2                	mov    %eax,%edx
80103528:	8b 45 08             	mov    0x8(%ebp),%eax
8010352b:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
8010352e:	6a 07                	push   $0x7
80103530:	e8 91 ff ff ff       	call   801034c6 <cmos_read>
80103535:	83 c4 04             	add    $0x4,%esp
80103538:	89 c2                	mov    %eax,%edx
8010353a:	8b 45 08             	mov    0x8(%ebp),%eax
8010353d:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
80103540:	6a 08                	push   $0x8
80103542:	e8 7f ff ff ff       	call   801034c6 <cmos_read>
80103547:	83 c4 04             	add    $0x4,%esp
8010354a:	89 c2                	mov    %eax,%edx
8010354c:	8b 45 08             	mov    0x8(%ebp),%eax
8010354f:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
80103552:	6a 09                	push   $0x9
80103554:	e8 6d ff ff ff       	call   801034c6 <cmos_read>
80103559:	83 c4 04             	add    $0x4,%esp
8010355c:	89 c2                	mov    %eax,%edx
8010355e:	8b 45 08             	mov    0x8(%ebp),%eax
80103561:	89 50 14             	mov    %edx,0x14(%eax)
}
80103564:	90                   	nop
80103565:	c9                   	leave  
80103566:	c3                   	ret    

80103567 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80103567:	55                   	push   %ebp
80103568:	89 e5                	mov    %esp,%ebp
8010356a:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
8010356d:	6a 0b                	push   $0xb
8010356f:	e8 52 ff ff ff       	call   801034c6 <cmos_read>
80103574:	83 c4 04             	add    $0x4,%esp
80103577:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
8010357a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010357d:	83 e0 04             	and    $0x4,%eax
80103580:	85 c0                	test   %eax,%eax
80103582:	0f 94 c0             	sete   %al
80103585:	0f b6 c0             	movzbl %al,%eax
80103588:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
8010358b:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010358e:	50                   	push   %eax
8010358f:	e8 62 ff ff ff       	call   801034f6 <fill_rtcdate>
80103594:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
80103597:	6a 0a                	push   $0xa
80103599:	e8 28 ff ff ff       	call   801034c6 <cmos_read>
8010359e:	83 c4 04             	add    $0x4,%esp
801035a1:	25 80 00 00 00       	and    $0x80,%eax
801035a6:	85 c0                	test   %eax,%eax
801035a8:	75 27                	jne    801035d1 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
801035aa:	8d 45 c0             	lea    -0x40(%ebp),%eax
801035ad:	50                   	push   %eax
801035ae:	e8 43 ff ff ff       	call   801034f6 <fill_rtcdate>
801035b3:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
801035b6:	83 ec 04             	sub    $0x4,%esp
801035b9:	6a 18                	push   $0x18
801035bb:	8d 45 c0             	lea    -0x40(%ebp),%eax
801035be:	50                   	push   %eax
801035bf:	8d 45 d8             	lea    -0x28(%ebp),%eax
801035c2:	50                   	push   %eax
801035c3:	e8 09 37 00 00       	call   80106cd1 <memcmp>
801035c8:	83 c4 10             	add    $0x10,%esp
801035cb:	85 c0                	test   %eax,%eax
801035cd:	74 05                	je     801035d4 <cmostime+0x6d>
801035cf:	eb ba                	jmp    8010358b <cmostime+0x24>

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
801035d1:	90                   	nop
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
801035d2:	eb b7                	jmp    8010358b <cmostime+0x24>
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
801035d4:	90                   	nop
  }

  // convert
  if (bcd) {
801035d5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801035d9:	0f 84 b4 00 00 00    	je     80103693 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801035df:	8b 45 d8             	mov    -0x28(%ebp),%eax
801035e2:	c1 e8 04             	shr    $0x4,%eax
801035e5:	89 c2                	mov    %eax,%edx
801035e7:	89 d0                	mov    %edx,%eax
801035e9:	c1 e0 02             	shl    $0x2,%eax
801035ec:	01 d0                	add    %edx,%eax
801035ee:	01 c0                	add    %eax,%eax
801035f0:	89 c2                	mov    %eax,%edx
801035f2:	8b 45 d8             	mov    -0x28(%ebp),%eax
801035f5:	83 e0 0f             	and    $0xf,%eax
801035f8:	01 d0                	add    %edx,%eax
801035fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
801035fd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103600:	c1 e8 04             	shr    $0x4,%eax
80103603:	89 c2                	mov    %eax,%edx
80103605:	89 d0                	mov    %edx,%eax
80103607:	c1 e0 02             	shl    $0x2,%eax
8010360a:	01 d0                	add    %edx,%eax
8010360c:	01 c0                	add    %eax,%eax
8010360e:	89 c2                	mov    %eax,%edx
80103610:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103613:	83 e0 0f             	and    $0xf,%eax
80103616:	01 d0                	add    %edx,%eax
80103618:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
8010361b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010361e:	c1 e8 04             	shr    $0x4,%eax
80103621:	89 c2                	mov    %eax,%edx
80103623:	89 d0                	mov    %edx,%eax
80103625:	c1 e0 02             	shl    $0x2,%eax
80103628:	01 d0                	add    %edx,%eax
8010362a:	01 c0                	add    %eax,%eax
8010362c:	89 c2                	mov    %eax,%edx
8010362e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103631:	83 e0 0f             	and    $0xf,%eax
80103634:	01 d0                	add    %edx,%eax
80103636:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80103639:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010363c:	c1 e8 04             	shr    $0x4,%eax
8010363f:	89 c2                	mov    %eax,%edx
80103641:	89 d0                	mov    %edx,%eax
80103643:	c1 e0 02             	shl    $0x2,%eax
80103646:	01 d0                	add    %edx,%eax
80103648:	01 c0                	add    %eax,%eax
8010364a:	89 c2                	mov    %eax,%edx
8010364c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010364f:	83 e0 0f             	and    $0xf,%eax
80103652:	01 d0                	add    %edx,%eax
80103654:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80103657:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010365a:	c1 e8 04             	shr    $0x4,%eax
8010365d:	89 c2                	mov    %eax,%edx
8010365f:	89 d0                	mov    %edx,%eax
80103661:	c1 e0 02             	shl    $0x2,%eax
80103664:	01 d0                	add    %edx,%eax
80103666:	01 c0                	add    %eax,%eax
80103668:	89 c2                	mov    %eax,%edx
8010366a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010366d:	83 e0 0f             	and    $0xf,%eax
80103670:	01 d0                	add    %edx,%eax
80103672:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80103675:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103678:	c1 e8 04             	shr    $0x4,%eax
8010367b:	89 c2                	mov    %eax,%edx
8010367d:	89 d0                	mov    %edx,%eax
8010367f:	c1 e0 02             	shl    $0x2,%eax
80103682:	01 d0                	add    %edx,%eax
80103684:	01 c0                	add    %eax,%eax
80103686:	89 c2                	mov    %eax,%edx
80103688:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010368b:	83 e0 0f             	and    $0xf,%eax
8010368e:	01 d0                	add    %edx,%eax
80103690:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103693:	8b 45 08             	mov    0x8(%ebp),%eax
80103696:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103699:	89 10                	mov    %edx,(%eax)
8010369b:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010369e:	89 50 04             	mov    %edx,0x4(%eax)
801036a1:	8b 55 e0             	mov    -0x20(%ebp),%edx
801036a4:	89 50 08             	mov    %edx,0x8(%eax)
801036a7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801036aa:	89 50 0c             	mov    %edx,0xc(%eax)
801036ad:	8b 55 e8             	mov    -0x18(%ebp),%edx
801036b0:	89 50 10             	mov    %edx,0x10(%eax)
801036b3:	8b 55 ec             	mov    -0x14(%ebp),%edx
801036b6:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801036b9:	8b 45 08             	mov    0x8(%ebp),%eax
801036bc:	8b 40 14             	mov    0x14(%eax),%eax
801036bf:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801036c5:	8b 45 08             	mov    0x8(%ebp),%eax
801036c8:	89 50 14             	mov    %edx,0x14(%eax)
}
801036cb:	90                   	nop
801036cc:	c9                   	leave  
801036cd:	c3                   	ret    

801036ce <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
801036ce:	55                   	push   %ebp
801036cf:	89 e5                	mov    %esp,%ebp
801036d1:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
801036d4:	83 ec 08             	sub    $0x8,%esp
801036d7:	68 b8 a4 10 80       	push   $0x8010a4b8
801036dc:	68 a0 42 11 80       	push   $0x801142a0
801036e1:	e8 ff 32 00 00       	call   801069e5 <initlock>
801036e6:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
801036e9:	83 ec 08             	sub    $0x8,%esp
801036ec:	8d 45 dc             	lea    -0x24(%ebp),%eax
801036ef:	50                   	push   %eax
801036f0:	ff 75 08             	pushl  0x8(%ebp)
801036f3:	e8 f3 dd ff ff       	call   801014eb <readsb>
801036f8:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
801036fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036fe:	a3 d4 42 11 80       	mov    %eax,0x801142d4
  log.size = sb.nlog;
80103703:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103706:	a3 d8 42 11 80       	mov    %eax,0x801142d8
  log.dev = dev;
8010370b:	8b 45 08             	mov    0x8(%ebp),%eax
8010370e:	a3 e4 42 11 80       	mov    %eax,0x801142e4
  recover_from_log();
80103713:	e8 b2 01 00 00       	call   801038ca <recover_from_log>
}
80103718:	90                   	nop
80103719:	c9                   	leave  
8010371a:	c3                   	ret    

8010371b <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
8010371b:	55                   	push   %ebp
8010371c:	89 e5                	mov    %esp,%ebp
8010371e:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103721:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103728:	e9 95 00 00 00       	jmp    801037c2 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
8010372d:	8b 15 d4 42 11 80    	mov    0x801142d4,%edx
80103733:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103736:	01 d0                	add    %edx,%eax
80103738:	83 c0 01             	add    $0x1,%eax
8010373b:	89 c2                	mov    %eax,%edx
8010373d:	a1 e4 42 11 80       	mov    0x801142e4,%eax
80103742:	83 ec 08             	sub    $0x8,%esp
80103745:	52                   	push   %edx
80103746:	50                   	push   %eax
80103747:	e8 6a ca ff ff       	call   801001b6 <bread>
8010374c:	83 c4 10             	add    $0x10,%esp
8010374f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103752:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103755:	83 c0 10             	add    $0x10,%eax
80103758:	8b 04 85 ac 42 11 80 	mov    -0x7feebd54(,%eax,4),%eax
8010375f:	89 c2                	mov    %eax,%edx
80103761:	a1 e4 42 11 80       	mov    0x801142e4,%eax
80103766:	83 ec 08             	sub    $0x8,%esp
80103769:	52                   	push   %edx
8010376a:	50                   	push   %eax
8010376b:	e8 46 ca ff ff       	call   801001b6 <bread>
80103770:	83 c4 10             	add    $0x10,%esp
80103773:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103776:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103779:	8d 50 18             	lea    0x18(%eax),%edx
8010377c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010377f:	83 c0 18             	add    $0x18,%eax
80103782:	83 ec 04             	sub    $0x4,%esp
80103785:	68 00 02 00 00       	push   $0x200
8010378a:	52                   	push   %edx
8010378b:	50                   	push   %eax
8010378c:	e8 98 35 00 00       	call   80106d29 <memmove>
80103791:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103794:	83 ec 0c             	sub    $0xc,%esp
80103797:	ff 75 ec             	pushl  -0x14(%ebp)
8010379a:	e8 50 ca ff ff       	call   801001ef <bwrite>
8010379f:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
801037a2:	83 ec 0c             	sub    $0xc,%esp
801037a5:	ff 75 f0             	pushl  -0x10(%ebp)
801037a8:	e8 81 ca ff ff       	call   8010022e <brelse>
801037ad:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
801037b0:	83 ec 0c             	sub    $0xc,%esp
801037b3:	ff 75 ec             	pushl  -0x14(%ebp)
801037b6:	e8 73 ca ff ff       	call   8010022e <brelse>
801037bb:	83 c4 10             	add    $0x10,%esp
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801037be:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801037c2:	a1 e8 42 11 80       	mov    0x801142e8,%eax
801037c7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801037ca:	0f 8f 5d ff ff ff    	jg     8010372d <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
801037d0:	90                   	nop
801037d1:	c9                   	leave  
801037d2:	c3                   	ret    

801037d3 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801037d3:	55                   	push   %ebp
801037d4:	89 e5                	mov    %esp,%ebp
801037d6:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801037d9:	a1 d4 42 11 80       	mov    0x801142d4,%eax
801037de:	89 c2                	mov    %eax,%edx
801037e0:	a1 e4 42 11 80       	mov    0x801142e4,%eax
801037e5:	83 ec 08             	sub    $0x8,%esp
801037e8:	52                   	push   %edx
801037e9:	50                   	push   %eax
801037ea:	e8 c7 c9 ff ff       	call   801001b6 <bread>
801037ef:	83 c4 10             	add    $0x10,%esp
801037f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801037f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037f8:	83 c0 18             	add    $0x18,%eax
801037fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801037fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103801:	8b 00                	mov    (%eax),%eax
80103803:	a3 e8 42 11 80       	mov    %eax,0x801142e8
  for (i = 0; i < log.lh.n; i++) {
80103808:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010380f:	eb 1b                	jmp    8010382c <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80103811:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103814:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103817:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010381b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010381e:	83 c2 10             	add    $0x10,%edx
80103821:	89 04 95 ac 42 11 80 	mov    %eax,-0x7feebd54(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103828:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010382c:	a1 e8 42 11 80       	mov    0x801142e8,%eax
80103831:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103834:	7f db                	jg     80103811 <read_head+0x3e>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
80103836:	83 ec 0c             	sub    $0xc,%esp
80103839:	ff 75 f0             	pushl  -0x10(%ebp)
8010383c:	e8 ed c9 ff ff       	call   8010022e <brelse>
80103841:	83 c4 10             	add    $0x10,%esp
}
80103844:	90                   	nop
80103845:	c9                   	leave  
80103846:	c3                   	ret    

80103847 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103847:	55                   	push   %ebp
80103848:	89 e5                	mov    %esp,%ebp
8010384a:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
8010384d:	a1 d4 42 11 80       	mov    0x801142d4,%eax
80103852:	89 c2                	mov    %eax,%edx
80103854:	a1 e4 42 11 80       	mov    0x801142e4,%eax
80103859:	83 ec 08             	sub    $0x8,%esp
8010385c:	52                   	push   %edx
8010385d:	50                   	push   %eax
8010385e:	e8 53 c9 ff ff       	call   801001b6 <bread>
80103863:	83 c4 10             	add    $0x10,%esp
80103866:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103869:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010386c:	83 c0 18             	add    $0x18,%eax
8010386f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103872:	8b 15 e8 42 11 80    	mov    0x801142e8,%edx
80103878:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010387b:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010387d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103884:	eb 1b                	jmp    801038a1 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80103886:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103889:	83 c0 10             	add    $0x10,%eax
8010388c:	8b 0c 85 ac 42 11 80 	mov    -0x7feebd54(,%eax,4),%ecx
80103893:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103896:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103899:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
8010389d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801038a1:	a1 e8 42 11 80       	mov    0x801142e8,%eax
801038a6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038a9:	7f db                	jg     80103886 <write_head+0x3f>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
801038ab:	83 ec 0c             	sub    $0xc,%esp
801038ae:	ff 75 f0             	pushl  -0x10(%ebp)
801038b1:	e8 39 c9 ff ff       	call   801001ef <bwrite>
801038b6:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
801038b9:	83 ec 0c             	sub    $0xc,%esp
801038bc:	ff 75 f0             	pushl  -0x10(%ebp)
801038bf:	e8 6a c9 ff ff       	call   8010022e <brelse>
801038c4:	83 c4 10             	add    $0x10,%esp
}
801038c7:	90                   	nop
801038c8:	c9                   	leave  
801038c9:	c3                   	ret    

801038ca <recover_from_log>:

static void
recover_from_log(void)
{
801038ca:	55                   	push   %ebp
801038cb:	89 e5                	mov    %esp,%ebp
801038cd:	83 ec 08             	sub    $0x8,%esp
  read_head();      
801038d0:	e8 fe fe ff ff       	call   801037d3 <read_head>
  install_trans(); // if committed, copy from log to disk
801038d5:	e8 41 fe ff ff       	call   8010371b <install_trans>
  log.lh.n = 0;
801038da:	c7 05 e8 42 11 80 00 	movl   $0x0,0x801142e8
801038e1:	00 00 00 
  write_head(); // clear the log
801038e4:	e8 5e ff ff ff       	call   80103847 <write_head>
}
801038e9:	90                   	nop
801038ea:	c9                   	leave  
801038eb:	c3                   	ret    

801038ec <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
801038ec:	55                   	push   %ebp
801038ed:	89 e5                	mov    %esp,%ebp
801038ef:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
801038f2:	83 ec 0c             	sub    $0xc,%esp
801038f5:	68 a0 42 11 80       	push   $0x801142a0
801038fa:	e8 08 31 00 00       	call   80106a07 <acquire>
801038ff:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103902:	a1 e0 42 11 80       	mov    0x801142e0,%eax
80103907:	85 c0                	test   %eax,%eax
80103909:	74 17                	je     80103922 <begin_op+0x36>
      sleep(&log, &log.lock);
8010390b:	83 ec 08             	sub    $0x8,%esp
8010390e:	68 a0 42 11 80       	push   $0x801142a0
80103913:	68 a0 42 11 80       	push   $0x801142a0
80103918:	e8 8f 20 00 00       	call   801059ac <sleep>
8010391d:	83 c4 10             	add    $0x10,%esp
80103920:	eb e0                	jmp    80103902 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103922:	8b 0d e8 42 11 80    	mov    0x801142e8,%ecx
80103928:	a1 dc 42 11 80       	mov    0x801142dc,%eax
8010392d:	8d 50 01             	lea    0x1(%eax),%edx
80103930:	89 d0                	mov    %edx,%eax
80103932:	c1 e0 02             	shl    $0x2,%eax
80103935:	01 d0                	add    %edx,%eax
80103937:	01 c0                	add    %eax,%eax
80103939:	01 c8                	add    %ecx,%eax
8010393b:	83 f8 1e             	cmp    $0x1e,%eax
8010393e:	7e 17                	jle    80103957 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103940:	83 ec 08             	sub    $0x8,%esp
80103943:	68 a0 42 11 80       	push   $0x801142a0
80103948:	68 a0 42 11 80       	push   $0x801142a0
8010394d:	e8 5a 20 00 00       	call   801059ac <sleep>
80103952:	83 c4 10             	add    $0x10,%esp
80103955:	eb ab                	jmp    80103902 <begin_op+0x16>
    } else {
      log.outstanding += 1;
80103957:	a1 dc 42 11 80       	mov    0x801142dc,%eax
8010395c:	83 c0 01             	add    $0x1,%eax
8010395f:	a3 dc 42 11 80       	mov    %eax,0x801142dc
      release(&log.lock);
80103964:	83 ec 0c             	sub    $0xc,%esp
80103967:	68 a0 42 11 80       	push   $0x801142a0
8010396c:	e8 fd 30 00 00       	call   80106a6e <release>
80103971:	83 c4 10             	add    $0x10,%esp
      break;
80103974:	90                   	nop
    }
  }
}
80103975:	90                   	nop
80103976:	c9                   	leave  
80103977:	c3                   	ret    

80103978 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103978:	55                   	push   %ebp
80103979:	89 e5                	mov    %esp,%ebp
8010397b:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
8010397e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103985:	83 ec 0c             	sub    $0xc,%esp
80103988:	68 a0 42 11 80       	push   $0x801142a0
8010398d:	e8 75 30 00 00       	call   80106a07 <acquire>
80103992:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103995:	a1 dc 42 11 80       	mov    0x801142dc,%eax
8010399a:	83 e8 01             	sub    $0x1,%eax
8010399d:	a3 dc 42 11 80       	mov    %eax,0x801142dc
  if(log.committing)
801039a2:	a1 e0 42 11 80       	mov    0x801142e0,%eax
801039a7:	85 c0                	test   %eax,%eax
801039a9:	74 0d                	je     801039b8 <end_op+0x40>
    panic("log.committing");
801039ab:	83 ec 0c             	sub    $0xc,%esp
801039ae:	68 bc a4 10 80       	push   $0x8010a4bc
801039b3:	e8 ae cb ff ff       	call   80100566 <panic>
  if(log.outstanding == 0){
801039b8:	a1 dc 42 11 80       	mov    0x801142dc,%eax
801039bd:	85 c0                	test   %eax,%eax
801039bf:	75 13                	jne    801039d4 <end_op+0x5c>
    do_commit = 1;
801039c1:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801039c8:	c7 05 e0 42 11 80 01 	movl   $0x1,0x801142e0
801039cf:	00 00 00 
801039d2:	eb 10                	jmp    801039e4 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
801039d4:	83 ec 0c             	sub    $0xc,%esp
801039d7:	68 a0 42 11 80       	push   $0x801142a0
801039dc:	e8 1e 22 00 00       	call   80105bff <wakeup>
801039e1:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
801039e4:	83 ec 0c             	sub    $0xc,%esp
801039e7:	68 a0 42 11 80       	push   $0x801142a0
801039ec:	e8 7d 30 00 00       	call   80106a6e <release>
801039f1:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
801039f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801039f8:	74 3f                	je     80103a39 <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
801039fa:	e8 f5 00 00 00       	call   80103af4 <commit>
    acquire(&log.lock);
801039ff:	83 ec 0c             	sub    $0xc,%esp
80103a02:	68 a0 42 11 80       	push   $0x801142a0
80103a07:	e8 fb 2f 00 00       	call   80106a07 <acquire>
80103a0c:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103a0f:	c7 05 e0 42 11 80 00 	movl   $0x0,0x801142e0
80103a16:	00 00 00 
    wakeup(&log);
80103a19:	83 ec 0c             	sub    $0xc,%esp
80103a1c:	68 a0 42 11 80       	push   $0x801142a0
80103a21:	e8 d9 21 00 00       	call   80105bff <wakeup>
80103a26:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103a29:	83 ec 0c             	sub    $0xc,%esp
80103a2c:	68 a0 42 11 80       	push   $0x801142a0
80103a31:	e8 38 30 00 00       	call   80106a6e <release>
80103a36:	83 c4 10             	add    $0x10,%esp
  }
}
80103a39:	90                   	nop
80103a3a:	c9                   	leave  
80103a3b:	c3                   	ret    

80103a3c <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
80103a3c:	55                   	push   %ebp
80103a3d:	89 e5                	mov    %esp,%ebp
80103a3f:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103a42:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103a49:	e9 95 00 00 00       	jmp    80103ae3 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103a4e:	8b 15 d4 42 11 80    	mov    0x801142d4,%edx
80103a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a57:	01 d0                	add    %edx,%eax
80103a59:	83 c0 01             	add    $0x1,%eax
80103a5c:	89 c2                	mov    %eax,%edx
80103a5e:	a1 e4 42 11 80       	mov    0x801142e4,%eax
80103a63:	83 ec 08             	sub    $0x8,%esp
80103a66:	52                   	push   %edx
80103a67:	50                   	push   %eax
80103a68:	e8 49 c7 ff ff       	call   801001b6 <bread>
80103a6d:	83 c4 10             	add    $0x10,%esp
80103a70:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103a73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a76:	83 c0 10             	add    $0x10,%eax
80103a79:	8b 04 85 ac 42 11 80 	mov    -0x7feebd54(,%eax,4),%eax
80103a80:	89 c2                	mov    %eax,%edx
80103a82:	a1 e4 42 11 80       	mov    0x801142e4,%eax
80103a87:	83 ec 08             	sub    $0x8,%esp
80103a8a:	52                   	push   %edx
80103a8b:	50                   	push   %eax
80103a8c:	e8 25 c7 ff ff       	call   801001b6 <bread>
80103a91:	83 c4 10             	add    $0x10,%esp
80103a94:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103a97:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103a9a:	8d 50 18             	lea    0x18(%eax),%edx
80103a9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103aa0:	83 c0 18             	add    $0x18,%eax
80103aa3:	83 ec 04             	sub    $0x4,%esp
80103aa6:	68 00 02 00 00       	push   $0x200
80103aab:	52                   	push   %edx
80103aac:	50                   	push   %eax
80103aad:	e8 77 32 00 00       	call   80106d29 <memmove>
80103ab2:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103ab5:	83 ec 0c             	sub    $0xc,%esp
80103ab8:	ff 75 f0             	pushl  -0x10(%ebp)
80103abb:	e8 2f c7 ff ff       	call   801001ef <bwrite>
80103ac0:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
80103ac3:	83 ec 0c             	sub    $0xc,%esp
80103ac6:	ff 75 ec             	pushl  -0x14(%ebp)
80103ac9:	e8 60 c7 ff ff       	call   8010022e <brelse>
80103ace:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103ad1:	83 ec 0c             	sub    $0xc,%esp
80103ad4:	ff 75 f0             	pushl  -0x10(%ebp)
80103ad7:	e8 52 c7 ff ff       	call   8010022e <brelse>
80103adc:	83 c4 10             	add    $0x10,%esp
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103adf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103ae3:	a1 e8 42 11 80       	mov    0x801142e8,%eax
80103ae8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103aeb:	0f 8f 5d ff ff ff    	jg     80103a4e <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
80103af1:	90                   	nop
80103af2:	c9                   	leave  
80103af3:	c3                   	ret    

80103af4 <commit>:

static void
commit()
{
80103af4:	55                   	push   %ebp
80103af5:	89 e5                	mov    %esp,%ebp
80103af7:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103afa:	a1 e8 42 11 80       	mov    0x801142e8,%eax
80103aff:	85 c0                	test   %eax,%eax
80103b01:	7e 1e                	jle    80103b21 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103b03:	e8 34 ff ff ff       	call   80103a3c <write_log>
    write_head();    // Write header to disk -- the real commit
80103b08:	e8 3a fd ff ff       	call   80103847 <write_head>
    install_trans(); // Now install writes to home locations
80103b0d:	e8 09 fc ff ff       	call   8010371b <install_trans>
    log.lh.n = 0; 
80103b12:	c7 05 e8 42 11 80 00 	movl   $0x0,0x801142e8
80103b19:	00 00 00 
    write_head();    // Erase the transaction from the log
80103b1c:	e8 26 fd ff ff       	call   80103847 <write_head>
  }
}
80103b21:	90                   	nop
80103b22:	c9                   	leave  
80103b23:	c3                   	ret    

80103b24 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103b24:	55                   	push   %ebp
80103b25:	89 e5                	mov    %esp,%ebp
80103b27:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103b2a:	a1 e8 42 11 80       	mov    0x801142e8,%eax
80103b2f:	83 f8 1d             	cmp    $0x1d,%eax
80103b32:	7f 12                	jg     80103b46 <log_write+0x22>
80103b34:	a1 e8 42 11 80       	mov    0x801142e8,%eax
80103b39:	8b 15 d8 42 11 80    	mov    0x801142d8,%edx
80103b3f:	83 ea 01             	sub    $0x1,%edx
80103b42:	39 d0                	cmp    %edx,%eax
80103b44:	7c 0d                	jl     80103b53 <log_write+0x2f>
    panic("too big a transaction");
80103b46:	83 ec 0c             	sub    $0xc,%esp
80103b49:	68 cb a4 10 80       	push   $0x8010a4cb
80103b4e:	e8 13 ca ff ff       	call   80100566 <panic>
  if (log.outstanding < 1)
80103b53:	a1 dc 42 11 80       	mov    0x801142dc,%eax
80103b58:	85 c0                	test   %eax,%eax
80103b5a:	7f 0d                	jg     80103b69 <log_write+0x45>
    panic("log_write outside of trans");
80103b5c:	83 ec 0c             	sub    $0xc,%esp
80103b5f:	68 e1 a4 10 80       	push   $0x8010a4e1
80103b64:	e8 fd c9 ff ff       	call   80100566 <panic>

  acquire(&log.lock);
80103b69:	83 ec 0c             	sub    $0xc,%esp
80103b6c:	68 a0 42 11 80       	push   $0x801142a0
80103b71:	e8 91 2e 00 00       	call   80106a07 <acquire>
80103b76:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103b79:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103b80:	eb 1d                	jmp    80103b9f <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103b82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b85:	83 c0 10             	add    $0x10,%eax
80103b88:	8b 04 85 ac 42 11 80 	mov    -0x7feebd54(,%eax,4),%eax
80103b8f:	89 c2                	mov    %eax,%edx
80103b91:	8b 45 08             	mov    0x8(%ebp),%eax
80103b94:	8b 40 08             	mov    0x8(%eax),%eax
80103b97:	39 c2                	cmp    %eax,%edx
80103b99:	74 10                	je     80103bab <log_write+0x87>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80103b9b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103b9f:	a1 e8 42 11 80       	mov    0x801142e8,%eax
80103ba4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103ba7:	7f d9                	jg     80103b82 <log_write+0x5e>
80103ba9:	eb 01                	jmp    80103bac <log_write+0x88>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
80103bab:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
80103bac:	8b 45 08             	mov    0x8(%ebp),%eax
80103baf:	8b 40 08             	mov    0x8(%eax),%eax
80103bb2:	89 c2                	mov    %eax,%edx
80103bb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bb7:	83 c0 10             	add    $0x10,%eax
80103bba:	89 14 85 ac 42 11 80 	mov    %edx,-0x7feebd54(,%eax,4)
  if (i == log.lh.n)
80103bc1:	a1 e8 42 11 80       	mov    0x801142e8,%eax
80103bc6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103bc9:	75 0d                	jne    80103bd8 <log_write+0xb4>
    log.lh.n++;
80103bcb:	a1 e8 42 11 80       	mov    0x801142e8,%eax
80103bd0:	83 c0 01             	add    $0x1,%eax
80103bd3:	a3 e8 42 11 80       	mov    %eax,0x801142e8
  b->flags |= B_DIRTY; // prevent eviction
80103bd8:	8b 45 08             	mov    0x8(%ebp),%eax
80103bdb:	8b 00                	mov    (%eax),%eax
80103bdd:	83 c8 04             	or     $0x4,%eax
80103be0:	89 c2                	mov    %eax,%edx
80103be2:	8b 45 08             	mov    0x8(%ebp),%eax
80103be5:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103be7:	83 ec 0c             	sub    $0xc,%esp
80103bea:	68 a0 42 11 80       	push   $0x801142a0
80103bef:	e8 7a 2e 00 00       	call   80106a6e <release>
80103bf4:	83 c4 10             	add    $0x10,%esp
}
80103bf7:	90                   	nop
80103bf8:	c9                   	leave  
80103bf9:	c3                   	ret    

80103bfa <v2p>:
80103bfa:	55                   	push   %ebp
80103bfb:	89 e5                	mov    %esp,%ebp
80103bfd:	8b 45 08             	mov    0x8(%ebp),%eax
80103c00:	05 00 00 00 80       	add    $0x80000000,%eax
80103c05:	5d                   	pop    %ebp
80103c06:	c3                   	ret    

80103c07 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103c07:	55                   	push   %ebp
80103c08:	89 e5                	mov    %esp,%ebp
80103c0a:	8b 45 08             	mov    0x8(%ebp),%eax
80103c0d:	05 00 00 00 80       	add    $0x80000000,%eax
80103c12:	5d                   	pop    %ebp
80103c13:	c3                   	ret    

80103c14 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103c14:	55                   	push   %ebp
80103c15:	89 e5                	mov    %esp,%ebp
80103c17:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103c1a:	8b 55 08             	mov    0x8(%ebp),%edx
80103c1d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c20:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103c23:	f0 87 02             	lock xchg %eax,(%edx)
80103c26:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103c29:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103c2c:	c9                   	leave  
80103c2d:	c3                   	ret    

80103c2e <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103c2e:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103c32:	83 e4 f0             	and    $0xfffffff0,%esp
80103c35:	ff 71 fc             	pushl  -0x4(%ecx)
80103c38:	55                   	push   %ebp
80103c39:	89 e5                	mov    %esp,%ebp
80103c3b:	51                   	push   %ecx
80103c3c:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103c3f:	83 ec 08             	sub    $0x8,%esp
80103c42:	68 00 00 40 80       	push   $0x80400000
80103c47:	68 7c 79 11 80       	push   $0x8011797c
80103c4c:	e8 7d f2 ff ff       	call   80102ece <kinit1>
80103c51:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103c54:	e8 73 5e 00 00       	call   80109acc <kvmalloc>
  mpinit();        // collect info about this machine
80103c59:	e8 43 04 00 00       	call   801040a1 <mpinit>
  lapicinit();
80103c5e:	e8 ea f5 ff ff       	call   8010324d <lapicinit>
  seginit();       // set up segments
80103c63:	e8 0d 58 00 00       	call   80109475 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103c68:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103c6e:	0f b6 00             	movzbl (%eax),%eax
80103c71:	0f b6 c0             	movzbl %al,%eax
80103c74:	83 ec 08             	sub    $0x8,%esp
80103c77:	50                   	push   %eax
80103c78:	68 fc a4 10 80       	push   $0x8010a4fc
80103c7d:	e8 44 c7 ff ff       	call   801003c6 <cprintf>
80103c82:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
80103c85:	e8 6d 06 00 00       	call   801042f7 <picinit>
  ioapicinit();    // another interrupt controller
80103c8a:	e8 34 f1 ff ff       	call   80102dc3 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80103c8f:	e8 19 cf ff ff       	call   80100bad <consoleinit>
  uartinit();      // serial port
80103c94:	e8 38 4b 00 00       	call   801087d1 <uartinit>
  pinit();         // process table
80103c99:	e8 5d 0b 00 00       	call   801047fb <pinit>
  tvinit();        // trap vectors
80103c9e:	e8 07 47 00 00       	call   801083aa <tvinit>
  binit();         // buffer cache
80103ca3:	e8 8c c3 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103ca8:	e8 2f d4 ff ff       	call   801010dc <fileinit>
  ideinit();       // disk
80103cad:	e8 19 ed ff ff       	call   801029cb <ideinit>
  if(!ismp)
80103cb2:	a1 84 43 11 80       	mov    0x80114384,%eax
80103cb7:	85 c0                	test   %eax,%eax
80103cb9:	75 05                	jne    80103cc0 <main+0x92>
    timerinit();   // uniprocessor timer
80103cbb:	e8 3b 46 00 00       	call   801082fb <timerinit>
  startothers();   // start other processors
80103cc0:	e8 7f 00 00 00       	call   80103d44 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103cc5:	83 ec 08             	sub    $0x8,%esp
80103cc8:	68 00 00 00 8e       	push   $0x8e000000
80103ccd:	68 00 00 40 80       	push   $0x80400000
80103cd2:	e8 30 f2 ff ff       	call   80102f07 <kinit2>
80103cd7:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
80103cda:	e8 a8 0d 00 00       	call   80104a87 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80103cdf:	e8 1a 00 00 00       	call   80103cfe <mpmain>

80103ce4 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103ce4:	55                   	push   %ebp
80103ce5:	89 e5                	mov    %esp,%ebp
80103ce7:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
80103cea:	e8 f5 5d 00 00       	call   80109ae4 <switchkvm>
  seginit();
80103cef:	e8 81 57 00 00       	call   80109475 <seginit>
  lapicinit();
80103cf4:	e8 54 f5 ff ff       	call   8010324d <lapicinit>
  mpmain();
80103cf9:	e8 00 00 00 00       	call   80103cfe <mpmain>

80103cfe <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103cfe:	55                   	push   %ebp
80103cff:	89 e5                	mov    %esp,%ebp
80103d01:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
80103d04:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103d0a:	0f b6 00             	movzbl (%eax),%eax
80103d0d:	0f b6 c0             	movzbl %al,%eax
80103d10:	83 ec 08             	sub    $0x8,%esp
80103d13:	50                   	push   %eax
80103d14:	68 13 a5 10 80       	push   $0x8010a513
80103d19:	e8 a8 c6 ff ff       	call   801003c6 <cprintf>
80103d1e:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103d21:	e8 e5 47 00 00       	call   8010850b <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103d26:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103d2c:	05 a8 00 00 00       	add    $0xa8,%eax
80103d31:	83 ec 08             	sub    $0x8,%esp
80103d34:	6a 01                	push   $0x1
80103d36:	50                   	push   %eax
80103d37:	e8 d8 fe ff ff       	call   80103c14 <xchg>
80103d3c:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103d3f:	e8 5e 18 00 00       	call   801055a2 <scheduler>

80103d44 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103d44:	55                   	push   %ebp
80103d45:	89 e5                	mov    %esp,%ebp
80103d47:	53                   	push   %ebx
80103d48:	83 ec 14             	sub    $0x14,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
80103d4b:	68 00 70 00 00       	push   $0x7000
80103d50:	e8 b2 fe ff ff       	call   80103c07 <p2v>
80103d55:	83 c4 04             	add    $0x4,%esp
80103d58:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103d5b:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103d60:	83 ec 04             	sub    $0x4,%esp
80103d63:	50                   	push   %eax
80103d64:	68 4c d5 10 80       	push   $0x8010d54c
80103d69:	ff 75 f0             	pushl  -0x10(%ebp)
80103d6c:	e8 b8 2f 00 00       	call   80106d29 <memmove>
80103d71:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103d74:	c7 45 f4 a0 43 11 80 	movl   $0x801143a0,-0xc(%ebp)
80103d7b:	e9 90 00 00 00       	jmp    80103e10 <startothers+0xcc>
    if(c == cpus+cpunum())  // We've started already.
80103d80:	e8 e6 f5 ff ff       	call   8010336b <cpunum>
80103d85:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103d8b:	05 a0 43 11 80       	add    $0x801143a0,%eax
80103d90:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103d93:	74 73                	je     80103e08 <startothers+0xc4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103d95:	e8 6b f2 ff ff       	call   80103005 <kalloc>
80103d9a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103d9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103da0:	83 e8 04             	sub    $0x4,%eax
80103da3:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103da6:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103dac:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103dae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103db1:	83 e8 08             	sub    $0x8,%eax
80103db4:	c7 00 e4 3c 10 80    	movl   $0x80103ce4,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103dba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dbd:	8d 58 f4             	lea    -0xc(%eax),%ebx
80103dc0:	83 ec 0c             	sub    $0xc,%esp
80103dc3:	68 00 c0 10 80       	push   $0x8010c000
80103dc8:	e8 2d fe ff ff       	call   80103bfa <v2p>
80103dcd:	83 c4 10             	add    $0x10,%esp
80103dd0:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80103dd2:	83 ec 0c             	sub    $0xc,%esp
80103dd5:	ff 75 f0             	pushl  -0x10(%ebp)
80103dd8:	e8 1d fe ff ff       	call   80103bfa <v2p>
80103ddd:	83 c4 10             	add    $0x10,%esp
80103de0:	89 c2                	mov    %eax,%edx
80103de2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103de5:	0f b6 00             	movzbl (%eax),%eax
80103de8:	0f b6 c0             	movzbl %al,%eax
80103deb:	83 ec 08             	sub    $0x8,%esp
80103dee:	52                   	push   %edx
80103def:	50                   	push   %eax
80103df0:	e8 f0 f5 ff ff       	call   801033e5 <lapicstartap>
80103df5:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103df8:	90                   	nop
80103df9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dfc:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103e02:	85 c0                	test   %eax,%eax
80103e04:	74 f3                	je     80103df9 <startothers+0xb5>
80103e06:	eb 01                	jmp    80103e09 <startothers+0xc5>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
80103e08:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103e09:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103e10:	a1 80 49 11 80       	mov    0x80114980,%eax
80103e15:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103e1b:	05 a0 43 11 80       	add    $0x801143a0,%eax
80103e20:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103e23:	0f 87 57 ff ff ff    	ja     80103d80 <startothers+0x3c>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103e29:	90                   	nop
80103e2a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103e2d:	c9                   	leave  
80103e2e:	c3                   	ret    

80103e2f <p2v>:
80103e2f:	55                   	push   %ebp
80103e30:	89 e5                	mov    %esp,%ebp
80103e32:	8b 45 08             	mov    0x8(%ebp),%eax
80103e35:	05 00 00 00 80       	add    $0x80000000,%eax
80103e3a:	5d                   	pop    %ebp
80103e3b:	c3                   	ret    

80103e3c <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80103e3c:	55                   	push   %ebp
80103e3d:	89 e5                	mov    %esp,%ebp
80103e3f:	83 ec 14             	sub    $0x14,%esp
80103e42:	8b 45 08             	mov    0x8(%ebp),%eax
80103e45:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103e49:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103e4d:	89 c2                	mov    %eax,%edx
80103e4f:	ec                   	in     (%dx),%al
80103e50:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103e53:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103e57:	c9                   	leave  
80103e58:	c3                   	ret    

80103e59 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103e59:	55                   	push   %ebp
80103e5a:	89 e5                	mov    %esp,%ebp
80103e5c:	83 ec 08             	sub    $0x8,%esp
80103e5f:	8b 55 08             	mov    0x8(%ebp),%edx
80103e62:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e65:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103e69:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103e6c:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103e70:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103e74:	ee                   	out    %al,(%dx)
}
80103e75:	90                   	nop
80103e76:	c9                   	leave  
80103e77:	c3                   	ret    

80103e78 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103e78:	55                   	push   %ebp
80103e79:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103e7b:	a1 84 d6 10 80       	mov    0x8010d684,%eax
80103e80:	89 c2                	mov    %eax,%edx
80103e82:	b8 a0 43 11 80       	mov    $0x801143a0,%eax
80103e87:	29 c2                	sub    %eax,%edx
80103e89:	89 d0                	mov    %edx,%eax
80103e8b:	c1 f8 02             	sar    $0x2,%eax
80103e8e:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103e94:	5d                   	pop    %ebp
80103e95:	c3                   	ret    

80103e96 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103e96:	55                   	push   %ebp
80103e97:	89 e5                	mov    %esp,%ebp
80103e99:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103e9c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103ea3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103eaa:	eb 15                	jmp    80103ec1 <sum+0x2b>
    sum += addr[i];
80103eac:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103eaf:	8b 45 08             	mov    0x8(%ebp),%eax
80103eb2:	01 d0                	add    %edx,%eax
80103eb4:	0f b6 00             	movzbl (%eax),%eax
80103eb7:	0f b6 c0             	movzbl %al,%eax
80103eba:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103ebd:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103ec1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103ec4:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103ec7:	7c e3                	jl     80103eac <sum+0x16>
    sum += addr[i];
  return sum;
80103ec9:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103ecc:	c9                   	leave  
80103ecd:	c3                   	ret    

80103ece <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103ece:	55                   	push   %ebp
80103ecf:	89 e5                	mov    %esp,%ebp
80103ed1:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103ed4:	ff 75 08             	pushl  0x8(%ebp)
80103ed7:	e8 53 ff ff ff       	call   80103e2f <p2v>
80103edc:	83 c4 04             	add    $0x4,%esp
80103edf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103ee2:	8b 55 0c             	mov    0xc(%ebp),%edx
80103ee5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ee8:	01 d0                	add    %edx,%eax
80103eea:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103eed:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ef0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ef3:	eb 36                	jmp    80103f2b <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103ef5:	83 ec 04             	sub    $0x4,%esp
80103ef8:	6a 04                	push   $0x4
80103efa:	68 24 a5 10 80       	push   $0x8010a524
80103eff:	ff 75 f4             	pushl  -0xc(%ebp)
80103f02:	e8 ca 2d 00 00       	call   80106cd1 <memcmp>
80103f07:	83 c4 10             	add    $0x10,%esp
80103f0a:	85 c0                	test   %eax,%eax
80103f0c:	75 19                	jne    80103f27 <mpsearch1+0x59>
80103f0e:	83 ec 08             	sub    $0x8,%esp
80103f11:	6a 10                	push   $0x10
80103f13:	ff 75 f4             	pushl  -0xc(%ebp)
80103f16:	e8 7b ff ff ff       	call   80103e96 <sum>
80103f1b:	83 c4 10             	add    $0x10,%esp
80103f1e:	84 c0                	test   %al,%al
80103f20:	75 05                	jne    80103f27 <mpsearch1+0x59>
      return (struct mp*)p;
80103f22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f25:	eb 11                	jmp    80103f38 <mpsearch1+0x6a>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103f27:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103f2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f2e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103f31:	72 c2                	jb     80103ef5 <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103f33:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103f38:	c9                   	leave  
80103f39:	c3                   	ret    

80103f3a <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103f3a:	55                   	push   %ebp
80103f3b:	89 e5                	mov    %esp,%ebp
80103f3d:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103f40:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103f47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f4a:	83 c0 0f             	add    $0xf,%eax
80103f4d:	0f b6 00             	movzbl (%eax),%eax
80103f50:	0f b6 c0             	movzbl %al,%eax
80103f53:	c1 e0 08             	shl    $0x8,%eax
80103f56:	89 c2                	mov    %eax,%edx
80103f58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f5b:	83 c0 0e             	add    $0xe,%eax
80103f5e:	0f b6 00             	movzbl (%eax),%eax
80103f61:	0f b6 c0             	movzbl %al,%eax
80103f64:	09 d0                	or     %edx,%eax
80103f66:	c1 e0 04             	shl    $0x4,%eax
80103f69:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103f6c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103f70:	74 21                	je     80103f93 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103f72:	83 ec 08             	sub    $0x8,%esp
80103f75:	68 00 04 00 00       	push   $0x400
80103f7a:	ff 75 f0             	pushl  -0x10(%ebp)
80103f7d:	e8 4c ff ff ff       	call   80103ece <mpsearch1>
80103f82:	83 c4 10             	add    $0x10,%esp
80103f85:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103f88:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103f8c:	74 51                	je     80103fdf <mpsearch+0xa5>
      return mp;
80103f8e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f91:	eb 61                	jmp    80103ff4 <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103f93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f96:	83 c0 14             	add    $0x14,%eax
80103f99:	0f b6 00             	movzbl (%eax),%eax
80103f9c:	0f b6 c0             	movzbl %al,%eax
80103f9f:	c1 e0 08             	shl    $0x8,%eax
80103fa2:	89 c2                	mov    %eax,%edx
80103fa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fa7:	83 c0 13             	add    $0x13,%eax
80103faa:	0f b6 00             	movzbl (%eax),%eax
80103fad:	0f b6 c0             	movzbl %al,%eax
80103fb0:	09 d0                	or     %edx,%eax
80103fb2:	c1 e0 0a             	shl    $0xa,%eax
80103fb5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103fb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103fbb:	2d 00 04 00 00       	sub    $0x400,%eax
80103fc0:	83 ec 08             	sub    $0x8,%esp
80103fc3:	68 00 04 00 00       	push   $0x400
80103fc8:	50                   	push   %eax
80103fc9:	e8 00 ff ff ff       	call   80103ece <mpsearch1>
80103fce:	83 c4 10             	add    $0x10,%esp
80103fd1:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103fd4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103fd8:	74 05                	je     80103fdf <mpsearch+0xa5>
      return mp;
80103fda:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fdd:	eb 15                	jmp    80103ff4 <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103fdf:	83 ec 08             	sub    $0x8,%esp
80103fe2:	68 00 00 01 00       	push   $0x10000
80103fe7:	68 00 00 0f 00       	push   $0xf0000
80103fec:	e8 dd fe ff ff       	call   80103ece <mpsearch1>
80103ff1:	83 c4 10             	add    $0x10,%esp
}
80103ff4:	c9                   	leave  
80103ff5:	c3                   	ret    

80103ff6 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103ff6:	55                   	push   %ebp
80103ff7:	89 e5                	mov    %esp,%ebp
80103ff9:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103ffc:	e8 39 ff ff ff       	call   80103f3a <mpsearch>
80104001:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104004:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104008:	74 0a                	je     80104014 <mpconfig+0x1e>
8010400a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010400d:	8b 40 04             	mov    0x4(%eax),%eax
80104010:	85 c0                	test   %eax,%eax
80104012:	75 0a                	jne    8010401e <mpconfig+0x28>
    return 0;
80104014:	b8 00 00 00 00       	mov    $0x0,%eax
80104019:	e9 81 00 00 00       	jmp    8010409f <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
8010401e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104021:	8b 40 04             	mov    0x4(%eax),%eax
80104024:	83 ec 0c             	sub    $0xc,%esp
80104027:	50                   	push   %eax
80104028:	e8 02 fe ff ff       	call   80103e2f <p2v>
8010402d:	83 c4 10             	add    $0x10,%esp
80104030:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80104033:	83 ec 04             	sub    $0x4,%esp
80104036:	6a 04                	push   $0x4
80104038:	68 29 a5 10 80       	push   $0x8010a529
8010403d:	ff 75 f0             	pushl  -0x10(%ebp)
80104040:	e8 8c 2c 00 00       	call   80106cd1 <memcmp>
80104045:	83 c4 10             	add    $0x10,%esp
80104048:	85 c0                	test   %eax,%eax
8010404a:	74 07                	je     80104053 <mpconfig+0x5d>
    return 0;
8010404c:	b8 00 00 00 00       	mov    $0x0,%eax
80104051:	eb 4c                	jmp    8010409f <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
80104053:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104056:	0f b6 40 06          	movzbl 0x6(%eax),%eax
8010405a:	3c 01                	cmp    $0x1,%al
8010405c:	74 12                	je     80104070 <mpconfig+0x7a>
8010405e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104061:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80104065:	3c 04                	cmp    $0x4,%al
80104067:	74 07                	je     80104070 <mpconfig+0x7a>
    return 0;
80104069:	b8 00 00 00 00       	mov    $0x0,%eax
8010406e:	eb 2f                	jmp    8010409f <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
80104070:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104073:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80104077:	0f b7 c0             	movzwl %ax,%eax
8010407a:	83 ec 08             	sub    $0x8,%esp
8010407d:	50                   	push   %eax
8010407e:	ff 75 f0             	pushl  -0x10(%ebp)
80104081:	e8 10 fe ff ff       	call   80103e96 <sum>
80104086:	83 c4 10             	add    $0x10,%esp
80104089:	84 c0                	test   %al,%al
8010408b:	74 07                	je     80104094 <mpconfig+0x9e>
    return 0;
8010408d:	b8 00 00 00 00       	mov    $0x0,%eax
80104092:	eb 0b                	jmp    8010409f <mpconfig+0xa9>
  *pmp = mp;
80104094:	8b 45 08             	mov    0x8(%ebp),%eax
80104097:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010409a:	89 10                	mov    %edx,(%eax)
  return conf;
8010409c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010409f:	c9                   	leave  
801040a0:	c3                   	ret    

801040a1 <mpinit>:

void
mpinit(void)
{
801040a1:	55                   	push   %ebp
801040a2:	89 e5                	mov    %esp,%ebp
801040a4:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
801040a7:	c7 05 84 d6 10 80 a0 	movl   $0x801143a0,0x8010d684
801040ae:	43 11 80 
  if((conf = mpconfig(&mp)) == 0)
801040b1:	83 ec 0c             	sub    $0xc,%esp
801040b4:	8d 45 e0             	lea    -0x20(%ebp),%eax
801040b7:	50                   	push   %eax
801040b8:	e8 39 ff ff ff       	call   80103ff6 <mpconfig>
801040bd:	83 c4 10             	add    $0x10,%esp
801040c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
801040c3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801040c7:	0f 84 96 01 00 00    	je     80104263 <mpinit+0x1c2>
    return;
  ismp = 1;
801040cd:	c7 05 84 43 11 80 01 	movl   $0x1,0x80114384
801040d4:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
801040d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801040da:	8b 40 24             	mov    0x24(%eax),%eax
801040dd:	a3 9c 42 11 80       	mov    %eax,0x8011429c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801040e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801040e5:	83 c0 2c             	add    $0x2c,%eax
801040e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801040eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801040ee:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801040f2:	0f b7 d0             	movzwl %ax,%edx
801040f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801040f8:	01 d0                	add    %edx,%eax
801040fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
801040fd:	e9 f2 00 00 00       	jmp    801041f4 <mpinit+0x153>
    switch(*p){
80104102:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104105:	0f b6 00             	movzbl (%eax),%eax
80104108:	0f b6 c0             	movzbl %al,%eax
8010410b:	83 f8 04             	cmp    $0x4,%eax
8010410e:	0f 87 bc 00 00 00    	ja     801041d0 <mpinit+0x12f>
80104114:	8b 04 85 6c a5 10 80 	mov    -0x7fef5a94(,%eax,4),%eax
8010411b:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
8010411d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104120:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80104123:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104126:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010412a:	0f b6 d0             	movzbl %al,%edx
8010412d:	a1 80 49 11 80       	mov    0x80114980,%eax
80104132:	39 c2                	cmp    %eax,%edx
80104134:	74 2b                	je     80104161 <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80104136:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104139:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010413d:	0f b6 d0             	movzbl %al,%edx
80104140:	a1 80 49 11 80       	mov    0x80114980,%eax
80104145:	83 ec 04             	sub    $0x4,%esp
80104148:	52                   	push   %edx
80104149:	50                   	push   %eax
8010414a:	68 2e a5 10 80       	push   $0x8010a52e
8010414f:	e8 72 c2 ff ff       	call   801003c6 <cprintf>
80104154:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
80104157:	c7 05 84 43 11 80 00 	movl   $0x0,0x80114384
8010415e:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80104161:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104164:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80104168:	0f b6 c0             	movzbl %al,%eax
8010416b:	83 e0 02             	and    $0x2,%eax
8010416e:	85 c0                	test   %eax,%eax
80104170:	74 15                	je     80104187 <mpinit+0xe6>
        bcpu = &cpus[ncpu];
80104172:	a1 80 49 11 80       	mov    0x80114980,%eax
80104177:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010417d:	05 a0 43 11 80       	add    $0x801143a0,%eax
80104182:	a3 84 d6 10 80       	mov    %eax,0x8010d684
      cpus[ncpu].id = ncpu;
80104187:	a1 80 49 11 80       	mov    0x80114980,%eax
8010418c:	8b 15 80 49 11 80    	mov    0x80114980,%edx
80104192:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80104198:	05 a0 43 11 80       	add    $0x801143a0,%eax
8010419d:	88 10                	mov    %dl,(%eax)
      ncpu++;
8010419f:	a1 80 49 11 80       	mov    0x80114980,%eax
801041a4:	83 c0 01             	add    $0x1,%eax
801041a7:	a3 80 49 11 80       	mov    %eax,0x80114980
      p += sizeof(struct mpproc);
801041ac:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
801041b0:	eb 42                	jmp    801041f4 <mpinit+0x153>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
801041b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
801041b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801041bb:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801041bf:	a2 80 43 11 80       	mov    %al,0x80114380
      p += sizeof(struct mpioapic);
801041c4:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
801041c8:	eb 2a                	jmp    801041f4 <mpinit+0x153>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
801041ca:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
801041ce:	eb 24                	jmp    801041f4 <mpinit+0x153>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
801041d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041d3:	0f b6 00             	movzbl (%eax),%eax
801041d6:	0f b6 c0             	movzbl %al,%eax
801041d9:	83 ec 08             	sub    $0x8,%esp
801041dc:	50                   	push   %eax
801041dd:	68 4c a5 10 80       	push   $0x8010a54c
801041e2:	e8 df c1 ff ff       	call   801003c6 <cprintf>
801041e7:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
801041ea:	c7 05 84 43 11 80 00 	movl   $0x0,0x80114384
801041f1:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801041f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041f7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801041fa:	0f 82 02 ff ff ff    	jb     80104102 <mpinit+0x61>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80104200:	a1 84 43 11 80       	mov    0x80114384,%eax
80104205:	85 c0                	test   %eax,%eax
80104207:	75 1d                	jne    80104226 <mpinit+0x185>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80104209:	c7 05 80 49 11 80 01 	movl   $0x1,0x80114980
80104210:	00 00 00 
    lapic = 0;
80104213:	c7 05 9c 42 11 80 00 	movl   $0x0,0x8011429c
8010421a:	00 00 00 
    ioapicid = 0;
8010421d:	c6 05 80 43 11 80 00 	movb   $0x0,0x80114380
    return;
80104224:	eb 3e                	jmp    80104264 <mpinit+0x1c3>
  }

  if(mp->imcrp){
80104226:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104229:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
8010422d:	84 c0                	test   %al,%al
8010422f:	74 33                	je     80104264 <mpinit+0x1c3>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80104231:	83 ec 08             	sub    $0x8,%esp
80104234:	6a 70                	push   $0x70
80104236:	6a 22                	push   $0x22
80104238:	e8 1c fc ff ff       	call   80103e59 <outb>
8010423d:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80104240:	83 ec 0c             	sub    $0xc,%esp
80104243:	6a 23                	push   $0x23
80104245:	e8 f2 fb ff ff       	call   80103e3c <inb>
8010424a:	83 c4 10             	add    $0x10,%esp
8010424d:	83 c8 01             	or     $0x1,%eax
80104250:	0f b6 c0             	movzbl %al,%eax
80104253:	83 ec 08             	sub    $0x8,%esp
80104256:	50                   	push   %eax
80104257:	6a 23                	push   $0x23
80104259:	e8 fb fb ff ff       	call   80103e59 <outb>
8010425e:	83 c4 10             	add    $0x10,%esp
80104261:	eb 01                	jmp    80104264 <mpinit+0x1c3>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80104263:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80104264:	c9                   	leave  
80104265:	c3                   	ret    

80104266 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80104266:	55                   	push   %ebp
80104267:	89 e5                	mov    %esp,%ebp
80104269:	83 ec 08             	sub    $0x8,%esp
8010426c:	8b 55 08             	mov    0x8(%ebp),%edx
8010426f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104272:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80104276:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80104279:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010427d:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80104281:	ee                   	out    %al,(%dx)
}
80104282:	90                   	nop
80104283:	c9                   	leave  
80104284:	c3                   	ret    

80104285 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80104285:	55                   	push   %ebp
80104286:	89 e5                	mov    %esp,%ebp
80104288:	83 ec 04             	sub    $0x4,%esp
8010428b:	8b 45 08             	mov    0x8(%ebp),%eax
8010428e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80104292:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104296:	66 a3 00 d0 10 80    	mov    %ax,0x8010d000
  outb(IO_PIC1+1, mask);
8010429c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801042a0:	0f b6 c0             	movzbl %al,%eax
801042a3:	50                   	push   %eax
801042a4:	6a 21                	push   $0x21
801042a6:	e8 bb ff ff ff       	call   80104266 <outb>
801042ab:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
801042ae:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801042b2:	66 c1 e8 08          	shr    $0x8,%ax
801042b6:	0f b6 c0             	movzbl %al,%eax
801042b9:	50                   	push   %eax
801042ba:	68 a1 00 00 00       	push   $0xa1
801042bf:	e8 a2 ff ff ff       	call   80104266 <outb>
801042c4:	83 c4 08             	add    $0x8,%esp
}
801042c7:	90                   	nop
801042c8:	c9                   	leave  
801042c9:	c3                   	ret    

801042ca <picenable>:

void
picenable(int irq)
{
801042ca:	55                   	push   %ebp
801042cb:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
801042cd:	8b 45 08             	mov    0x8(%ebp),%eax
801042d0:	ba 01 00 00 00       	mov    $0x1,%edx
801042d5:	89 c1                	mov    %eax,%ecx
801042d7:	d3 e2                	shl    %cl,%edx
801042d9:	89 d0                	mov    %edx,%eax
801042db:	f7 d0                	not    %eax
801042dd:	89 c2                	mov    %eax,%edx
801042df:	0f b7 05 00 d0 10 80 	movzwl 0x8010d000,%eax
801042e6:	21 d0                	and    %edx,%eax
801042e8:	0f b7 c0             	movzwl %ax,%eax
801042eb:	50                   	push   %eax
801042ec:	e8 94 ff ff ff       	call   80104285 <picsetmask>
801042f1:	83 c4 04             	add    $0x4,%esp
}
801042f4:	90                   	nop
801042f5:	c9                   	leave  
801042f6:	c3                   	ret    

801042f7 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
801042f7:	55                   	push   %ebp
801042f8:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
801042fa:	68 ff 00 00 00       	push   $0xff
801042ff:	6a 21                	push   $0x21
80104301:	e8 60 ff ff ff       	call   80104266 <outb>
80104306:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80104309:	68 ff 00 00 00       	push   $0xff
8010430e:	68 a1 00 00 00       	push   $0xa1
80104313:	e8 4e ff ff ff       	call   80104266 <outb>
80104318:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
8010431b:	6a 11                	push   $0x11
8010431d:	6a 20                	push   $0x20
8010431f:	e8 42 ff ff ff       	call   80104266 <outb>
80104324:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80104327:	6a 20                	push   $0x20
80104329:	6a 21                	push   $0x21
8010432b:	e8 36 ff ff ff       	call   80104266 <outb>
80104330:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80104333:	6a 04                	push   $0x4
80104335:	6a 21                	push   $0x21
80104337:	e8 2a ff ff ff       	call   80104266 <outb>
8010433c:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
8010433f:	6a 03                	push   $0x3
80104341:	6a 21                	push   $0x21
80104343:	e8 1e ff ff ff       	call   80104266 <outb>
80104348:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
8010434b:	6a 11                	push   $0x11
8010434d:	68 a0 00 00 00       	push   $0xa0
80104352:	e8 0f ff ff ff       	call   80104266 <outb>
80104357:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
8010435a:	6a 28                	push   $0x28
8010435c:	68 a1 00 00 00       	push   $0xa1
80104361:	e8 00 ff ff ff       	call   80104266 <outb>
80104366:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80104369:	6a 02                	push   $0x2
8010436b:	68 a1 00 00 00       	push   $0xa1
80104370:	e8 f1 fe ff ff       	call   80104266 <outb>
80104375:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80104378:	6a 03                	push   $0x3
8010437a:	68 a1 00 00 00       	push   $0xa1
8010437f:	e8 e2 fe ff ff       	call   80104266 <outb>
80104384:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80104387:	6a 68                	push   $0x68
80104389:	6a 20                	push   $0x20
8010438b:	e8 d6 fe ff ff       	call   80104266 <outb>
80104390:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
80104393:	6a 0a                	push   $0xa
80104395:	6a 20                	push   $0x20
80104397:	e8 ca fe ff ff       	call   80104266 <outb>
8010439c:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
8010439f:	6a 68                	push   $0x68
801043a1:	68 a0 00 00 00       	push   $0xa0
801043a6:	e8 bb fe ff ff       	call   80104266 <outb>
801043ab:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
801043ae:	6a 0a                	push   $0xa
801043b0:	68 a0 00 00 00       	push   $0xa0
801043b5:	e8 ac fe ff ff       	call   80104266 <outb>
801043ba:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
801043bd:	0f b7 05 00 d0 10 80 	movzwl 0x8010d000,%eax
801043c4:	66 83 f8 ff          	cmp    $0xffff,%ax
801043c8:	74 13                	je     801043dd <picinit+0xe6>
    picsetmask(irqmask);
801043ca:	0f b7 05 00 d0 10 80 	movzwl 0x8010d000,%eax
801043d1:	0f b7 c0             	movzwl %ax,%eax
801043d4:	50                   	push   %eax
801043d5:	e8 ab fe ff ff       	call   80104285 <picsetmask>
801043da:	83 c4 04             	add    $0x4,%esp
}
801043dd:	90                   	nop
801043de:	c9                   	leave  
801043df:	c3                   	ret    

801043e0 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
801043e0:	55                   	push   %ebp
801043e1:	89 e5                	mov    %esp,%ebp
801043e3:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
801043e6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
801043ed:	8b 45 0c             	mov    0xc(%ebp),%eax
801043f0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
801043f6:	8b 45 0c             	mov    0xc(%ebp),%eax
801043f9:	8b 10                	mov    (%eax),%edx
801043fb:	8b 45 08             	mov    0x8(%ebp),%eax
801043fe:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80104400:	e8 f5 cc ff ff       	call   801010fa <filealloc>
80104405:	89 c2                	mov    %eax,%edx
80104407:	8b 45 08             	mov    0x8(%ebp),%eax
8010440a:	89 10                	mov    %edx,(%eax)
8010440c:	8b 45 08             	mov    0x8(%ebp),%eax
8010440f:	8b 00                	mov    (%eax),%eax
80104411:	85 c0                	test   %eax,%eax
80104413:	0f 84 cb 00 00 00    	je     801044e4 <pipealloc+0x104>
80104419:	e8 dc cc ff ff       	call   801010fa <filealloc>
8010441e:	89 c2                	mov    %eax,%edx
80104420:	8b 45 0c             	mov    0xc(%ebp),%eax
80104423:	89 10                	mov    %edx,(%eax)
80104425:	8b 45 0c             	mov    0xc(%ebp),%eax
80104428:	8b 00                	mov    (%eax),%eax
8010442a:	85 c0                	test   %eax,%eax
8010442c:	0f 84 b2 00 00 00    	je     801044e4 <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80104432:	e8 ce eb ff ff       	call   80103005 <kalloc>
80104437:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010443a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010443e:	0f 84 9f 00 00 00    	je     801044e3 <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
80104444:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104447:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
8010444e:	00 00 00 
  p->writeopen = 1;
80104451:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104454:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
8010445b:	00 00 00 
  p->nwrite = 0;
8010445e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104461:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104468:	00 00 00 
  p->nread = 0;
8010446b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010446e:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80104475:	00 00 00 
  initlock(&p->lock, "pipe");
80104478:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010447b:	83 ec 08             	sub    $0x8,%esp
8010447e:	68 80 a5 10 80       	push   $0x8010a580
80104483:	50                   	push   %eax
80104484:	e8 5c 25 00 00       	call   801069e5 <initlock>
80104489:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
8010448c:	8b 45 08             	mov    0x8(%ebp),%eax
8010448f:	8b 00                	mov    (%eax),%eax
80104491:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104497:	8b 45 08             	mov    0x8(%ebp),%eax
8010449a:	8b 00                	mov    (%eax),%eax
8010449c:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
801044a0:	8b 45 08             	mov    0x8(%ebp),%eax
801044a3:	8b 00                	mov    (%eax),%eax
801044a5:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
801044a9:	8b 45 08             	mov    0x8(%ebp),%eax
801044ac:	8b 00                	mov    (%eax),%eax
801044ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044b1:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
801044b4:	8b 45 0c             	mov    0xc(%ebp),%eax
801044b7:	8b 00                	mov    (%eax),%eax
801044b9:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801044bf:	8b 45 0c             	mov    0xc(%ebp),%eax
801044c2:	8b 00                	mov    (%eax),%eax
801044c4:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801044c8:	8b 45 0c             	mov    0xc(%ebp),%eax
801044cb:	8b 00                	mov    (%eax),%eax
801044cd:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801044d1:	8b 45 0c             	mov    0xc(%ebp),%eax
801044d4:	8b 00                	mov    (%eax),%eax
801044d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044d9:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
801044dc:	b8 00 00 00 00       	mov    $0x0,%eax
801044e1:	eb 4e                	jmp    80104531 <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
801044e3:	90                   	nop
  (*f1)->writable = 1;
  (*f1)->pipe = p;
  return 0;

 bad:
  if(p)
801044e4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801044e8:	74 0e                	je     801044f8 <pipealloc+0x118>
    kfree((char*)p);
801044ea:	83 ec 0c             	sub    $0xc,%esp
801044ed:	ff 75 f4             	pushl  -0xc(%ebp)
801044f0:	e8 73 ea ff ff       	call   80102f68 <kfree>
801044f5:	83 c4 10             	add    $0x10,%esp
  if(*f0)
801044f8:	8b 45 08             	mov    0x8(%ebp),%eax
801044fb:	8b 00                	mov    (%eax),%eax
801044fd:	85 c0                	test   %eax,%eax
801044ff:	74 11                	je     80104512 <pipealloc+0x132>
    fileclose(*f0);
80104501:	8b 45 08             	mov    0x8(%ebp),%eax
80104504:	8b 00                	mov    (%eax),%eax
80104506:	83 ec 0c             	sub    $0xc,%esp
80104509:	50                   	push   %eax
8010450a:	e8 a9 cc ff ff       	call   801011b8 <fileclose>
8010450f:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80104512:	8b 45 0c             	mov    0xc(%ebp),%eax
80104515:	8b 00                	mov    (%eax),%eax
80104517:	85 c0                	test   %eax,%eax
80104519:	74 11                	je     8010452c <pipealloc+0x14c>
    fileclose(*f1);
8010451b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010451e:	8b 00                	mov    (%eax),%eax
80104520:	83 ec 0c             	sub    $0xc,%esp
80104523:	50                   	push   %eax
80104524:	e8 8f cc ff ff       	call   801011b8 <fileclose>
80104529:	83 c4 10             	add    $0x10,%esp
  return -1;
8010452c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104531:	c9                   	leave  
80104532:	c3                   	ret    

80104533 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104533:	55                   	push   %ebp
80104534:	89 e5                	mov    %esp,%ebp
80104536:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80104539:	8b 45 08             	mov    0x8(%ebp),%eax
8010453c:	83 ec 0c             	sub    $0xc,%esp
8010453f:	50                   	push   %eax
80104540:	e8 c2 24 00 00       	call   80106a07 <acquire>
80104545:	83 c4 10             	add    $0x10,%esp
  if(writable){
80104548:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010454c:	74 23                	je     80104571 <pipeclose+0x3e>
    p->writeopen = 0;
8010454e:	8b 45 08             	mov    0x8(%ebp),%eax
80104551:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104558:	00 00 00 
    wakeup(&p->nread);
8010455b:	8b 45 08             	mov    0x8(%ebp),%eax
8010455e:	05 34 02 00 00       	add    $0x234,%eax
80104563:	83 ec 0c             	sub    $0xc,%esp
80104566:	50                   	push   %eax
80104567:	e8 93 16 00 00       	call   80105bff <wakeup>
8010456c:	83 c4 10             	add    $0x10,%esp
8010456f:	eb 21                	jmp    80104592 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
80104571:	8b 45 08             	mov    0x8(%ebp),%eax
80104574:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
8010457b:	00 00 00 
    wakeup(&p->nwrite);
8010457e:	8b 45 08             	mov    0x8(%ebp),%eax
80104581:	05 38 02 00 00       	add    $0x238,%eax
80104586:	83 ec 0c             	sub    $0xc,%esp
80104589:	50                   	push   %eax
8010458a:	e8 70 16 00 00       	call   80105bff <wakeup>
8010458f:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104592:	8b 45 08             	mov    0x8(%ebp),%eax
80104595:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010459b:	85 c0                	test   %eax,%eax
8010459d:	75 2c                	jne    801045cb <pipeclose+0x98>
8010459f:	8b 45 08             	mov    0x8(%ebp),%eax
801045a2:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801045a8:	85 c0                	test   %eax,%eax
801045aa:	75 1f                	jne    801045cb <pipeclose+0x98>
    release(&p->lock);
801045ac:	8b 45 08             	mov    0x8(%ebp),%eax
801045af:	83 ec 0c             	sub    $0xc,%esp
801045b2:	50                   	push   %eax
801045b3:	e8 b6 24 00 00       	call   80106a6e <release>
801045b8:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
801045bb:	83 ec 0c             	sub    $0xc,%esp
801045be:	ff 75 08             	pushl  0x8(%ebp)
801045c1:	e8 a2 e9 ff ff       	call   80102f68 <kfree>
801045c6:	83 c4 10             	add    $0x10,%esp
801045c9:	eb 0f                	jmp    801045da <pipeclose+0xa7>
  } else
    release(&p->lock);
801045cb:	8b 45 08             	mov    0x8(%ebp),%eax
801045ce:	83 ec 0c             	sub    $0xc,%esp
801045d1:	50                   	push   %eax
801045d2:	e8 97 24 00 00       	call   80106a6e <release>
801045d7:	83 c4 10             	add    $0x10,%esp
}
801045da:	90                   	nop
801045db:	c9                   	leave  
801045dc:	c3                   	ret    

801045dd <pipewrite>:

int
pipewrite(struct pipe *p, char *addr, int n)
{
801045dd:	55                   	push   %ebp
801045de:	89 e5                	mov    %esp,%ebp
801045e0:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
801045e3:	8b 45 08             	mov    0x8(%ebp),%eax
801045e6:	83 ec 0c             	sub    $0xc,%esp
801045e9:	50                   	push   %eax
801045ea:	e8 18 24 00 00       	call   80106a07 <acquire>
801045ef:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
801045f2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801045f9:	e9 ad 00 00 00       	jmp    801046ab <pipewrite+0xce>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
801045fe:	8b 45 08             	mov    0x8(%ebp),%eax
80104601:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104607:	85 c0                	test   %eax,%eax
80104609:	74 0d                	je     80104618 <pipewrite+0x3b>
8010460b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104611:	8b 40 24             	mov    0x24(%eax),%eax
80104614:	85 c0                	test   %eax,%eax
80104616:	74 19                	je     80104631 <pipewrite+0x54>
        release(&p->lock);
80104618:	8b 45 08             	mov    0x8(%ebp),%eax
8010461b:	83 ec 0c             	sub    $0xc,%esp
8010461e:	50                   	push   %eax
8010461f:	e8 4a 24 00 00       	call   80106a6e <release>
80104624:	83 c4 10             	add    $0x10,%esp
        return -1;
80104627:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010462c:	e9 a8 00 00 00       	jmp    801046d9 <pipewrite+0xfc>
      }
      wakeup(&p->nread);
80104631:	8b 45 08             	mov    0x8(%ebp),%eax
80104634:	05 34 02 00 00       	add    $0x234,%eax
80104639:	83 ec 0c             	sub    $0xc,%esp
8010463c:	50                   	push   %eax
8010463d:	e8 bd 15 00 00       	call   80105bff <wakeup>
80104642:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104645:	8b 45 08             	mov    0x8(%ebp),%eax
80104648:	8b 55 08             	mov    0x8(%ebp),%edx
8010464b:	81 c2 38 02 00 00    	add    $0x238,%edx
80104651:	83 ec 08             	sub    $0x8,%esp
80104654:	50                   	push   %eax
80104655:	52                   	push   %edx
80104656:	e8 51 13 00 00       	call   801059ac <sleep>
8010465b:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
8010465e:	8b 45 08             	mov    0x8(%ebp),%eax
80104661:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104667:	8b 45 08             	mov    0x8(%ebp),%eax
8010466a:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104670:	05 00 02 00 00       	add    $0x200,%eax
80104675:	39 c2                	cmp    %eax,%edx
80104677:	74 85                	je     801045fe <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104679:	8b 45 08             	mov    0x8(%ebp),%eax
8010467c:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104682:	8d 48 01             	lea    0x1(%eax),%ecx
80104685:	8b 55 08             	mov    0x8(%ebp),%edx
80104688:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
8010468e:	25 ff 01 00 00       	and    $0x1ff,%eax
80104693:	89 c1                	mov    %eax,%ecx
80104695:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104698:	8b 45 0c             	mov    0xc(%ebp),%eax
8010469b:	01 d0                	add    %edx,%eax
8010469d:	0f b6 10             	movzbl (%eax),%edx
801046a0:	8b 45 08             	mov    0x8(%ebp),%eax
801046a3:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
801046a7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801046ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046ae:	3b 45 10             	cmp    0x10(%ebp),%eax
801046b1:	7c ab                	jl     8010465e <pipewrite+0x81>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801046b3:	8b 45 08             	mov    0x8(%ebp),%eax
801046b6:	05 34 02 00 00       	add    $0x234,%eax
801046bb:	83 ec 0c             	sub    $0xc,%esp
801046be:	50                   	push   %eax
801046bf:	e8 3b 15 00 00       	call   80105bff <wakeup>
801046c4:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801046c7:	8b 45 08             	mov    0x8(%ebp),%eax
801046ca:	83 ec 0c             	sub    $0xc,%esp
801046cd:	50                   	push   %eax
801046ce:	e8 9b 23 00 00       	call   80106a6e <release>
801046d3:	83 c4 10             	add    $0x10,%esp
  return n;
801046d6:	8b 45 10             	mov    0x10(%ebp),%eax
}
801046d9:	c9                   	leave  
801046da:	c3                   	ret    

801046db <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801046db:	55                   	push   %ebp
801046dc:	89 e5                	mov    %esp,%ebp
801046de:	53                   	push   %ebx
801046df:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
801046e2:	8b 45 08             	mov    0x8(%ebp),%eax
801046e5:	83 ec 0c             	sub    $0xc,%esp
801046e8:	50                   	push   %eax
801046e9:	e8 19 23 00 00       	call   80106a07 <acquire>
801046ee:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801046f1:	eb 3f                	jmp    80104732 <piperead+0x57>
    if(proc->killed){
801046f3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046f9:	8b 40 24             	mov    0x24(%eax),%eax
801046fc:	85 c0                	test   %eax,%eax
801046fe:	74 19                	je     80104719 <piperead+0x3e>
      release(&p->lock);
80104700:	8b 45 08             	mov    0x8(%ebp),%eax
80104703:	83 ec 0c             	sub    $0xc,%esp
80104706:	50                   	push   %eax
80104707:	e8 62 23 00 00       	call   80106a6e <release>
8010470c:	83 c4 10             	add    $0x10,%esp
      return -1;
8010470f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104714:	e9 bf 00 00 00       	jmp    801047d8 <piperead+0xfd>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104719:	8b 45 08             	mov    0x8(%ebp),%eax
8010471c:	8b 55 08             	mov    0x8(%ebp),%edx
8010471f:	81 c2 34 02 00 00    	add    $0x234,%edx
80104725:	83 ec 08             	sub    $0x8,%esp
80104728:	50                   	push   %eax
80104729:	52                   	push   %edx
8010472a:	e8 7d 12 00 00       	call   801059ac <sleep>
8010472f:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104732:	8b 45 08             	mov    0x8(%ebp),%eax
80104735:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010473b:	8b 45 08             	mov    0x8(%ebp),%eax
8010473e:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104744:	39 c2                	cmp    %eax,%edx
80104746:	75 0d                	jne    80104755 <piperead+0x7a>
80104748:	8b 45 08             	mov    0x8(%ebp),%eax
8010474b:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104751:	85 c0                	test   %eax,%eax
80104753:	75 9e                	jne    801046f3 <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104755:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010475c:	eb 49                	jmp    801047a7 <piperead+0xcc>
    if(p->nread == p->nwrite)
8010475e:	8b 45 08             	mov    0x8(%ebp),%eax
80104761:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104767:	8b 45 08             	mov    0x8(%ebp),%eax
8010476a:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104770:	39 c2                	cmp    %eax,%edx
80104772:	74 3d                	je     801047b1 <piperead+0xd6>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104774:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104777:	8b 45 0c             	mov    0xc(%ebp),%eax
8010477a:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010477d:	8b 45 08             	mov    0x8(%ebp),%eax
80104780:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104786:	8d 48 01             	lea    0x1(%eax),%ecx
80104789:	8b 55 08             	mov    0x8(%ebp),%edx
8010478c:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104792:	25 ff 01 00 00       	and    $0x1ff,%eax
80104797:	89 c2                	mov    %eax,%edx
80104799:	8b 45 08             	mov    0x8(%ebp),%eax
8010479c:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
801047a1:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801047a3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801047a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047aa:	3b 45 10             	cmp    0x10(%ebp),%eax
801047ad:	7c af                	jl     8010475e <piperead+0x83>
801047af:	eb 01                	jmp    801047b2 <piperead+0xd7>
    if(p->nread == p->nwrite)
      break;
801047b1:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801047b2:	8b 45 08             	mov    0x8(%ebp),%eax
801047b5:	05 38 02 00 00       	add    $0x238,%eax
801047ba:	83 ec 0c             	sub    $0xc,%esp
801047bd:	50                   	push   %eax
801047be:	e8 3c 14 00 00       	call   80105bff <wakeup>
801047c3:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801047c6:	8b 45 08             	mov    0x8(%ebp),%eax
801047c9:	83 ec 0c             	sub    $0xc,%esp
801047cc:	50                   	push   %eax
801047cd:	e8 9c 22 00 00       	call   80106a6e <release>
801047d2:	83 c4 10             	add    $0x10,%esp
  return i;
801047d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801047d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801047db:	c9                   	leave  
801047dc:	c3                   	ret    

801047dd <hlt>:
}

// hlt() added by Noah Zentzis, Fall 2016.
static inline void
hlt()
{
801047dd:	55                   	push   %ebp
801047de:	89 e5                	mov    %esp,%ebp
  asm volatile("hlt");
801047e0:	f4                   	hlt    
}
801047e1:	90                   	nop
801047e2:	5d                   	pop    %ebp
801047e3:	c3                   	ret    

801047e4 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801047e4:	55                   	push   %ebp
801047e5:	89 e5                	mov    %esp,%ebp
801047e7:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801047ea:	9c                   	pushf  
801047eb:	58                   	pop    %eax
801047ec:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801047ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801047f2:	c9                   	leave  
801047f3:	c3                   	ret    

801047f4 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
801047f4:	55                   	push   %ebp
801047f5:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801047f7:	fb                   	sti    
}
801047f8:	90                   	nop
801047f9:	5d                   	pop    %ebp
801047fa:	c3                   	ret    

801047fb <pinit>:
promoteAll();
#endif

void
pinit(void)
{
801047fb:	55                   	push   %ebp
801047fc:	89 e5                	mov    %esp,%ebp
801047fe:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80104801:	83 ec 08             	sub    $0x8,%esp
80104804:	68 88 a5 10 80       	push   $0x8010a588
80104809:	68 a0 49 11 80       	push   $0x801149a0
8010480e:	e8 d2 21 00 00       	call   801069e5 <initlock>
80104813:	83 c4 10             	add    $0x10,%esp
}
80104816:	90                   	nop
80104817:	c9                   	leave  
80104818:	c3                   	ret    

80104819 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104819:	55                   	push   %ebp
8010481a:	89 e5                	mov    %esp,%ebp
8010481c:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;
  int rc;

  acquire(&ptable.lock);
8010481f:	83 ec 0c             	sub    $0xc,%esp
80104822:	68 a0 49 11 80       	push   $0x801149a0
80104827:	e8 db 21 00 00       	call   80106a07 <acquire>
8010482c:	83 c4 10             	add    $0x10,%esp

#ifdef CS333_P3P4
  //If there's nothing in the list
  if(ptable.pLists.free == 0)
8010482f:	a1 f0 70 11 80       	mov    0x801170f0,%eax
80104834:	85 c0                	test   %eax,%eax
80104836:	75 1a                	jne    80104852 <allocproc+0x39>
  {
    release(&ptable.lock);
80104838:	83 ec 0c             	sub    $0xc,%esp
8010483b:	68 a0 49 11 80       	push   $0x801149a0
80104840:	e8 29 22 00 00       	call   80106a6e <release>
80104845:	83 c4 10             	add    $0x10,%esp
    return 0;
80104848:	b8 00 00 00 00       	mov    $0x0,%eax
8010484d:	e9 33 02 00 00       	jmp    80104a85 <allocproc+0x26c>
  }

  //Set p to the first item in the free list
  p = ptable.pLists.free;
80104852:	a1 f0 70 11 80       	mov    0x801170f0,%eax
80104857:	89 45 f4             	mov    %eax,-0xc(%ebp)

  goto found;
8010485a:	90                   	nop

#endif

found:
#ifdef CS333_P3P4
  assertState(p, UNUSED); //Check if p's state was really free
8010485b:	83 ec 08             	sub    $0x8,%esp
8010485e:	6a 00                	push   $0x0
80104860:	ff 75 f4             	pushl  -0xc(%ebp)
80104863:	e8 ce 1c 00 00       	call   80106536 <assertState>
80104868:	83 c4 10             	add    $0x10,%esp
  
  //Free list now points to the next process after p
  //Effectively removing p from free list

  rc = removeFromStateList(&ptable.pLists.free, p);
8010486b:	83 ec 08             	sub    $0x8,%esp
8010486e:	ff 75 f4             	pushl  -0xc(%ebp)
80104871:	68 f0 70 11 80       	push   $0x801170f0
80104876:	e8 0b 1c 00 00       	call   80106486 <removeFromStateList>
8010487b:	83 c4 10             	add    $0x10,%esp
8010487e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(rc == -1)
80104881:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80104885:	75 0d                	jne    80104894 <allocproc+0x7b>
    panic("Could not remove from free list.");
80104887:	83 ec 0c             	sub    $0xc,%esp
8010488a:	68 90 a5 10 80       	push   $0x8010a590
8010488f:	e8 d2 bc ff ff       	call   80100566 <panic>
  p->state = EMBRYO;
80104894:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104897:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  rc = addToStateListHead(&ptable.pLists.embryo, p);
8010489e:	83 ec 08             	sub    $0x8,%esp
801048a1:	ff 75 f4             	pushl  -0xc(%ebp)
801048a4:	68 00 71 11 80       	push   $0x80117100
801048a9:	e8 24 1d 00 00       	call   801065d2 <addToStateListHead>
801048ae:	83 c4 10             	add    $0x10,%esp
801048b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(rc == -1)
801048b4:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
801048b8:	75 0d                	jne    801048c7 <allocproc+0xae>
    panic("Could not add process to embryo.");
801048ba:	83 ec 0c             	sub    $0xc,%esp
801048bd:	68 b4 a5 10 80       	push   $0x8010a5b4
801048c2:	e8 9f bc ff ff       	call   80100566 <panic>
  assertState(p, EMBRYO);
801048c7:	83 ec 08             	sub    $0x8,%esp
801048ca:	6a 01                	push   $0x1
801048cc:	ff 75 f4             	pushl  -0xc(%ebp)
801048cf:	e8 62 1c 00 00       	call   80106536 <assertState>
801048d4:	83 c4 10             	add    $0x10,%esp
  p->pid = nextpid++;
801048d7:	a1 04 d0 10 80       	mov    0x8010d004,%eax
801048dc:	8d 50 01             	lea    0x1(%eax),%edx
801048df:	89 15 04 d0 10 80    	mov    %edx,0x8010d004
801048e5:	89 c2                	mov    %eax,%edx
801048e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ea:	89 50 10             	mov    %edx,0x10(%eax)
#endif

  release(&ptable.lock);
801048ed:	83 ec 0c             	sub    $0xc,%esp
801048f0:	68 a0 49 11 80       	push   $0x801149a0
801048f5:	e8 74 21 00 00       	call   80106a6e <release>
801048fa:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801048fd:	e8 03 e7 ff ff       	call   80103005 <kalloc>
80104902:	89 c2                	mov    %eax,%edx
80104904:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104907:	89 50 08             	mov    %edx,0x8(%eax)
8010490a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010490d:	8b 40 08             	mov    0x8(%eax),%eax
80104910:	85 c0                	test   %eax,%eax
80104912:	0f 85 96 00 00 00    	jne    801049ae <allocproc+0x195>
    acquire(&ptable.lock);
80104918:	83 ec 0c             	sub    $0xc,%esp
8010491b:	68 a0 49 11 80       	push   $0x801149a0
80104920:	e8 e2 20 00 00       	call   80106a07 <acquire>
80104925:	83 c4 10             	add    $0x10,%esp
#ifdef CS333_P3P4
    assertState(p, EMBRYO);
80104928:	83 ec 08             	sub    $0x8,%esp
8010492b:	6a 01                	push   $0x1
8010492d:	ff 75 f4             	pushl  -0xc(%ebp)
80104930:	e8 01 1c 00 00       	call   80106536 <assertState>
80104935:	83 c4 10             	add    $0x10,%esp
    rc = removeFromStateList(&ptable.pLists.embryo, p);
80104938:	83 ec 08             	sub    $0x8,%esp
8010493b:	ff 75 f4             	pushl  -0xc(%ebp)
8010493e:	68 00 71 11 80       	push   $0x80117100
80104943:	e8 3e 1b 00 00       	call   80106486 <removeFromStateList>
80104948:	83 c4 10             	add    $0x10,%esp
8010494b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(rc == -1)
8010494e:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80104952:	75 0d                	jne    80104961 <allocproc+0x148>
      panic("Could not remove from embryo list.");
80104954:	83 ec 0c             	sub    $0xc,%esp
80104957:	68 d8 a5 10 80       	push   $0x8010a5d8
8010495c:	e8 05 bc ff ff       	call   80100566 <panic>
#endif
    p->state = UNUSED;
80104961:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104964:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
#ifdef CS333_P3P4
    rc = addToStateListHead(&ptable.pLists.free, p);
8010496b:	83 ec 08             	sub    $0x8,%esp
8010496e:	ff 75 f4             	pushl  -0xc(%ebp)
80104971:	68 f0 70 11 80       	push   $0x801170f0
80104976:	e8 57 1c 00 00       	call   801065d2 <addToStateListHead>
8010497b:	83 c4 10             	add    $0x10,%esp
8010497e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(rc == -1)
80104981:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80104985:	75 0d                	jne    80104994 <allocproc+0x17b>
      panic("Could not add to free list.");
80104987:	83 ec 0c             	sub    $0xc,%esp
8010498a:	68 fb a5 10 80       	push   $0x8010a5fb
8010498f:	e8 d2 bb ff ff       	call   80100566 <panic>
#endif
    release(&ptable.lock);
80104994:	83 ec 0c             	sub    $0xc,%esp
80104997:	68 a0 49 11 80       	push   $0x801149a0
8010499c:	e8 cd 20 00 00       	call   80106a6e <release>
801049a1:	83 c4 10             	add    $0x10,%esp
    return 0;
801049a4:	b8 00 00 00 00       	mov    $0x0,%eax
801049a9:	e9 d7 00 00 00       	jmp    80104a85 <allocproc+0x26c>
  }
  sp = p->kstack + KSTACKSIZE;
801049ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049b1:	8b 40 08             	mov    0x8(%eax),%eax
801049b4:	05 00 10 00 00       	add    $0x1000,%eax
801049b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801049bc:	83 6d ec 4c          	subl   $0x4c,-0x14(%ebp)
  p->tf = (struct trapframe*)sp;
801049c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049c3:	8b 55 ec             	mov    -0x14(%ebp),%edx
801049c6:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
801049c9:	83 6d ec 04          	subl   $0x4,-0x14(%ebp)
  *(uint*)sp = (uint)trapret;
801049cd:	ba 58 83 10 80       	mov    $0x80108358,%edx
801049d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049d5:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801049d7:	83 6d ec 14          	subl   $0x14,-0x14(%ebp)
  p->context = (struct context*)sp;
801049db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049de:	8b 55 ec             	mov    -0x14(%ebp),%edx
801049e1:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
801049e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049e7:	8b 40 1c             	mov    0x1c(%eax),%eax
801049ea:	83 ec 04             	sub    $0x4,%esp
801049ed:	6a 14                	push   $0x14
801049ef:	6a 00                	push   $0x0
801049f1:	50                   	push   %eax
801049f2:	e8 73 22 00 00       	call   80106c6a <memset>
801049f7:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
801049fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049fd:	8b 40 1c             	mov    0x1c(%eax),%eax
80104a00:	ba 66 59 10 80       	mov    $0x80105966,%edx
80104a05:	89 50 10             	mov    %edx,0x10(%eax)

#ifdef CS333_P1
  p->start_ticks = ticks;
80104a08:	8b 15 20 79 11 80    	mov    0x80117920,%edx
80104a0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a11:	89 50 7c             	mov    %edx,0x7c(%eax)
#endif

#ifdef CS333_P2
  p->uid = DEFAULT_UID;
80104a14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a17:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80104a1e:	00 00 00 
  p->gid = DEFAULT_GID;
80104a21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a24:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
80104a2b:	00 00 00 
  p->cpu_ticks_total = 0;
80104a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a31:	c7 80 88 00 00 00 00 	movl   $0x0,0x88(%eax)
80104a38:	00 00 00 
  p->cpu_ticks_in = 0;
80104a3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a3e:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80104a45:	00 00 00 
#endif

#ifdef CS333_P3P4
  acquire(&ptable.lock);
80104a48:	83 ec 0c             	sub    $0xc,%esp
80104a4b:	68 a0 49 11 80       	push   $0x801149a0
80104a50:	e8 b2 1f 00 00       	call   80106a07 <acquire>
80104a55:	83 c4 10             	add    $0x10,%esp
  p->budget = BUDGET;
80104a58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a5b:	c7 80 98 00 00 00 e8 	movl   $0x3e8,0x98(%eax)
80104a62:	03 00 00 
  p->priority = 0;
80104a65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a68:	c7 80 94 00 00 00 00 	movl   $0x0,0x94(%eax)
80104a6f:	00 00 00 
  release(&ptable.lock);
80104a72:	83 ec 0c             	sub    $0xc,%esp
80104a75:	68 a0 49 11 80       	push   $0x801149a0
80104a7a:	e8 ef 1f 00 00       	call   80106a6e <release>
80104a7f:	83 c4 10             	add    $0x10,%esp
#endif

  return p;
80104a82:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104a85:	c9                   	leave  
80104a86:	c3                   	ret    

80104a87 <userinit>:

// Set up first user process.
void
userinit(void)
{
80104a87:	55                   	push   %ebp
80104a88:	89 e5                	mov    %esp,%ebp
80104a8a:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  int rc;

#ifdef CS333_P3P4
  acquire(&ptable.lock);
80104a8d:	83 ec 0c             	sub    $0xc,%esp
80104a90:	68 a0 49 11 80       	push   $0x801149a0
80104a95:	e8 6d 1f 00 00       	call   80106a07 <acquire>
80104a9a:	83 c4 10             	add    $0x10,%esp

  ptable.PromoteAtTime = ticks + TICKS_TO_PROMOTE;
80104a9d:	a1 20 79 11 80       	mov    0x80117920,%eax
80104aa2:	05 88 13 00 00       	add    $0x1388,%eax
80104aa7:	a3 04 71 11 80       	mov    %eax,0x80117104
  //Initialize all 6 lists
  for(int i = 0; i < MAX; i++) //Set multi queue for MLFQ
80104aac:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104ab3:	eb 17                	jmp    80104acc <userinit+0x45>
    ptable.pLists.ready[i] = 0;
80104ab5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ab8:	05 cc 09 00 00       	add    $0x9cc,%eax
80104abd:	c7 04 85 a4 49 11 80 	movl   $0x0,-0x7feeb65c(,%eax,4)
80104ac4:	00 00 00 00 
#ifdef CS333_P3P4
  acquire(&ptable.lock);

  ptable.PromoteAtTime = ticks + TICKS_TO_PROMOTE;
  //Initialize all 6 lists
  for(int i = 0; i < MAX; i++) //Set multi queue for MLFQ
80104ac8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104acc:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
80104ad0:	7e e3                	jle    80104ab5 <userinit+0x2e>
    ptable.pLists.ready[i] = 0;
  ptable.pLists.free = 0;
80104ad2:	c7 05 f0 70 11 80 00 	movl   $0x0,0x801170f0
80104ad9:	00 00 00 
  ptable.pLists.sleep = 0;
80104adc:	c7 05 f4 70 11 80 00 	movl   $0x0,0x801170f4
80104ae3:	00 00 00 
  ptable.pLists.zombie = 0;
80104ae6:	c7 05 f8 70 11 80 00 	movl   $0x0,0x801170f8
80104aed:	00 00 00 
  ptable.pLists.running = 0;
80104af0:	c7 05 fc 70 11 80 00 	movl   $0x0,0x801170fc
80104af7:	00 00 00 
  ptable.pLists.embryo = 0;
80104afa:	c7 05 00 71 11 80 00 	movl   $0x0,0x80117100
80104b01:	00 00 00 

  //Storing all 64 processes into the free list
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) 
80104b04:	c7 45 f4 d4 49 11 80 	movl   $0x801149d4,-0xc(%ebp)
80104b0b:	eb 30                	jmp    80104b3d <userinit+0xb6>
  {
    rc = addToStateListHead(&ptable.pLists.free, p);
80104b0d:	83 ec 08             	sub    $0x8,%esp
80104b10:	ff 75 f4             	pushl  -0xc(%ebp)
80104b13:	68 f0 70 11 80       	push   $0x801170f0
80104b18:	e8 b5 1a 00 00       	call   801065d2 <addToStateListHead>
80104b1d:	83 c4 10             	add    $0x10,%esp
80104b20:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(rc == -1)
80104b23:	83 7d ec ff          	cmpl   $0xffffffff,-0x14(%ebp)
80104b27:	75 0d                	jne    80104b36 <userinit+0xaf>
      panic("Could not add to free list.");
80104b29:	83 ec 0c             	sub    $0xc,%esp
80104b2c:	68 fb a5 10 80       	push   $0x8010a5fb
80104b31:	e8 30 ba ff ff       	call   80100566 <panic>
  ptable.pLists.zombie = 0;
  ptable.pLists.running = 0;
  ptable.pLists.embryo = 0;

  //Storing all 64 processes into the free list
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) 
80104b36:	81 45 f4 9c 00 00 00 	addl   $0x9c,-0xc(%ebp)
80104b3d:	81 7d f4 d4 70 11 80 	cmpl   $0x801170d4,-0xc(%ebp)
80104b44:	72 c7                	jb     80104b0d <userinit+0x86>
      panic("Could not add to free list.");
  }
  //All processes should be on the free list
  //ptable array is "still there" but processes will be managed by lists

  release(&ptable.lock);
80104b46:	83 ec 0c             	sub    $0xc,%esp
80104b49:	68 a0 49 11 80       	push   $0x801149a0
80104b4e:	e8 1b 1f 00 00       	call   80106a6e <release>
80104b53:	83 c4 10             	add    $0x10,%esp

#endif  

  p = allocproc();
80104b56:	e8 be fc ff ff       	call   80104819 <allocproc>
80104b5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
80104b5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b61:	a3 88 d6 10 80       	mov    %eax,0x8010d688
  if((p->pgdir = setupkvm()) == 0)
80104b66:	e8 af 4e 00 00       	call   80109a1a <setupkvm>
80104b6b:	89 c2                	mov    %eax,%edx
80104b6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b70:	89 50 04             	mov    %edx,0x4(%eax)
80104b73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b76:	8b 40 04             	mov    0x4(%eax),%eax
80104b79:	85 c0                	test   %eax,%eax
80104b7b:	75 0d                	jne    80104b8a <userinit+0x103>
    panic("userinit: out of memory?");
80104b7d:	83 ec 0c             	sub    $0xc,%esp
80104b80:	68 17 a6 10 80       	push   $0x8010a617
80104b85:	e8 dc b9 ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104b8a:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104b8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b92:	8b 40 04             	mov    0x4(%eax),%eax
80104b95:	83 ec 04             	sub    $0x4,%esp
80104b98:	52                   	push   %edx
80104b99:	68 20 d5 10 80       	push   $0x8010d520
80104b9e:	50                   	push   %eax
80104b9f:	e8 d0 50 00 00       	call   80109c74 <inituvm>
80104ba4:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104ba7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104baa:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104bb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bb3:	8b 40 18             	mov    0x18(%eax),%eax
80104bb6:	83 ec 04             	sub    $0x4,%esp
80104bb9:	6a 4c                	push   $0x4c
80104bbb:	6a 00                	push   $0x0
80104bbd:	50                   	push   %eax
80104bbe:	e8 a7 20 00 00       	call   80106c6a <memset>
80104bc3:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104bc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bc9:	8b 40 18             	mov    0x18(%eax),%eax
80104bcc:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104bd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bd5:	8b 40 18             	mov    0x18(%eax),%eax
80104bd8:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104bde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104be1:	8b 40 18             	mov    0x18(%eax),%eax
80104be4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104be7:	8b 52 18             	mov    0x18(%edx),%edx
80104bea:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104bee:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104bf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bf5:	8b 40 18             	mov    0x18(%eax),%eax
80104bf8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104bfb:	8b 52 18             	mov    0x18(%edx),%edx
80104bfe:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104c02:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104c06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c09:	8b 40 18             	mov    0x18(%eax),%eax
80104c0c:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104c13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c16:	8b 40 18             	mov    0x18(%eax),%eax
80104c19:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104c20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c23:	8b 40 18             	mov    0x18(%eax),%eax
80104c26:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104c2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c30:	83 c0 6c             	add    $0x6c,%eax
80104c33:	83 ec 04             	sub    $0x4,%esp
80104c36:	6a 10                	push   $0x10
80104c38:	68 30 a6 10 80       	push   $0x8010a630
80104c3d:	50                   	push   %eax
80104c3e:	e8 2a 22 00 00       	call   80106e6d <safestrcpy>
80104c43:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104c46:	83 ec 0c             	sub    $0xc,%esp
80104c49:	68 39 a6 10 80       	push   $0x8010a639
80104c4e:	e8 d0 da ff ff       	call   80102723 <namei>
80104c53:	83 c4 10             	add    $0x10,%esp
80104c56:	89 c2                	mov    %eax,%edx
80104c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c5b:	89 50 68             	mov    %edx,0x68(%eax)
  
#ifdef CS333_P2
  p->uid = DEFAULT_UID;
80104c5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c61:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80104c68:	00 00 00 
  p->gid = DEFAULT_GID;
80104c6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c6e:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
80104c75:	00 00 00 
  p->parent = p;
80104c78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c7b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c7e:	89 50 14             	mov    %edx,0x14(%eax)
#endif

#ifdef CS333_P3P4
  //After p becomes runnable, it needs to be put on the ready list
  acquire(&ptable.lock);
80104c81:	83 ec 0c             	sub    $0xc,%esp
80104c84:	68 a0 49 11 80       	push   $0x801149a0
80104c89:	e8 79 1d 00 00       	call   80106a07 <acquire>
80104c8e:	83 c4 10             	add    $0x10,%esp

  p->budget = BUDGET;
80104c91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c94:	c7 80 98 00 00 00 e8 	movl   $0x3e8,0x98(%eax)
80104c9b:	03 00 00 
  p->priority = 0;
80104c9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ca1:	c7 80 94 00 00 00 00 	movl   $0x0,0x94(%eax)
80104ca8:	00 00 00 

  rc = removeFromStateList(&ptable.pLists.embryo, p);
80104cab:	83 ec 08             	sub    $0x8,%esp
80104cae:	ff 75 f4             	pushl  -0xc(%ebp)
80104cb1:	68 00 71 11 80       	push   $0x80117100
80104cb6:	e8 cb 17 00 00       	call   80106486 <removeFromStateList>
80104cbb:	83 c4 10             	add    $0x10,%esp
80104cbe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(rc == -1)
80104cc1:	83 7d ec ff          	cmpl   $0xffffffff,-0x14(%ebp)
80104cc5:	75 0d                	jne    80104cd4 <userinit+0x24d>
    panic("Could not remove process from embryo list");
80104cc7:	83 ec 0c             	sub    $0xc,%esp
80104cca:	68 3c a6 10 80       	push   $0x8010a63c
80104ccf:	e8 92 b8 ff ff       	call   80100566 <panic>
  assertState(p, EMBRYO);
80104cd4:	83 ec 08             	sub    $0x8,%esp
80104cd7:	6a 01                	push   $0x1
80104cd9:	ff 75 f4             	pushl  -0xc(%ebp)
80104cdc:	e8 55 18 00 00       	call   80106536 <assertState>
80104ce1:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80104ce4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ce7:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  rc = addToStateListHead(&ptable.pLists.ready[0], p);
80104cee:	83 ec 08             	sub    $0x8,%esp
80104cf1:	ff 75 f4             	pushl  -0xc(%ebp)
80104cf4:	68 d4 70 11 80       	push   $0x801170d4
80104cf9:	e8 d4 18 00 00       	call   801065d2 <addToStateListHead>
80104cfe:	83 c4 10             	add    $0x10,%esp
80104d01:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(rc == -1)
80104d04:	83 7d ec ff          	cmpl   $0xffffffff,-0x14(%ebp)
80104d08:	75 0d                	jne    80104d17 <userinit+0x290>
    panic("Could not add process to free list.");
80104d0a:	83 ec 0c             	sub    $0xc,%esp
80104d0d:	68 68 a6 10 80       	push   $0x8010a668
80104d12:	e8 4f b8 ff ff       	call   80100566 <panic>

  release(&ptable.lock);
80104d17:	83 ec 0c             	sub    $0xc,%esp
80104d1a:	68 a0 49 11 80       	push   $0x801149a0
80104d1f:	e8 4a 1d 00 00       	call   80106a6e <release>
80104d24:	83 c4 10             	add    $0x10,%esp
#endif

}
80104d27:	90                   	nop
80104d28:	c9                   	leave  
80104d29:	c3                   	ret    

80104d2a <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104d2a:	55                   	push   %ebp
80104d2b:	89 e5                	mov    %esp,%ebp
80104d2d:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
80104d30:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d36:	8b 00                	mov    (%eax),%eax
80104d38:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104d3b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104d3f:	7e 31                	jle    80104d72 <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80104d41:	8b 55 08             	mov    0x8(%ebp),%edx
80104d44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d47:	01 c2                	add    %eax,%edx
80104d49:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d4f:	8b 40 04             	mov    0x4(%eax),%eax
80104d52:	83 ec 04             	sub    $0x4,%esp
80104d55:	52                   	push   %edx
80104d56:	ff 75 f4             	pushl  -0xc(%ebp)
80104d59:	50                   	push   %eax
80104d5a:	e8 62 50 00 00       	call   80109dc1 <allocuvm>
80104d5f:	83 c4 10             	add    $0x10,%esp
80104d62:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104d65:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104d69:	75 3e                	jne    80104da9 <growproc+0x7f>
      return -1;
80104d6b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d70:	eb 59                	jmp    80104dcb <growproc+0xa1>
  } else if(n < 0){
80104d72:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104d76:	79 31                	jns    80104da9 <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104d78:	8b 55 08             	mov    0x8(%ebp),%edx
80104d7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d7e:	01 c2                	add    %eax,%edx
80104d80:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d86:	8b 40 04             	mov    0x4(%eax),%eax
80104d89:	83 ec 04             	sub    $0x4,%esp
80104d8c:	52                   	push   %edx
80104d8d:	ff 75 f4             	pushl  -0xc(%ebp)
80104d90:	50                   	push   %eax
80104d91:	e8 f4 50 00 00       	call   80109e8a <deallocuvm>
80104d96:	83 c4 10             	add    $0x10,%esp
80104d99:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104d9c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104da0:	75 07                	jne    80104da9 <growproc+0x7f>
      return -1;
80104da2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104da7:	eb 22                	jmp    80104dcb <growproc+0xa1>
  }
  proc->sz = sz;
80104da9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104daf:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104db2:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104db4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dba:	83 ec 0c             	sub    $0xc,%esp
80104dbd:	50                   	push   %eax
80104dbe:	e8 3e 4d 00 00       	call   80109b01 <switchuvm>
80104dc3:	83 c4 10             	add    $0x10,%esp
  return 0;
80104dc6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104dcb:	c9                   	leave  
80104dcc:	c3                   	ret    

80104dcd <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104dcd:	55                   	push   %ebp
80104dce:	89 e5                	mov    %esp,%ebp
80104dd0:	57                   	push   %edi
80104dd1:	56                   	push   %esi
80104dd2:	53                   	push   %ebx
80104dd3:	83 ec 1c             	sub    $0x1c,%esp
  //struct proc *p;
  int rc;
#endif

  // Allocate process.
  if((np = allocproc()) == 0)
80104dd6:	e8 3e fa ff ff       	call   80104819 <allocproc>
80104ddb:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104dde:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104de2:	75 0a                	jne    80104dee <fork+0x21>
    return -1;
80104de4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104de9:	e9 8a 02 00 00       	jmp    80105078 <fork+0x2ab>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104dee:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104df4:	8b 10                	mov    (%eax),%edx
80104df6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dfc:	8b 40 04             	mov    0x4(%eax),%eax
80104dff:	83 ec 08             	sub    $0x8,%esp
80104e02:	52                   	push   %edx
80104e03:	50                   	push   %eax
80104e04:	e8 1f 52 00 00       	call   8010a028 <copyuvm>
80104e09:	83 c4 10             	add    $0x10,%esp
80104e0c:	89 c2                	mov    %eax,%edx
80104e0e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104e11:	89 50 04             	mov    %edx,0x4(%eax)
80104e14:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104e17:	8b 40 04             	mov    0x4(%eax),%eax
80104e1a:	85 c0                	test   %eax,%eax
80104e1c:	0f 85 b2 00 00 00    	jne    80104ed4 <fork+0x107>
    kfree(np->kstack);
80104e22:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104e25:	8b 40 08             	mov    0x8(%eax),%eax
80104e28:	83 ec 0c             	sub    $0xc,%esp
80104e2b:	50                   	push   %eax
80104e2c:	e8 37 e1 ff ff       	call   80102f68 <kfree>
80104e31:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80104e34:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104e37:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

#ifdef CS333_P3P4
    acquire(&ptable.lock);
80104e3e:	83 ec 0c             	sub    $0xc,%esp
80104e41:	68 a0 49 11 80       	push   $0x801149a0
80104e46:	e8 bc 1b 00 00       	call   80106a07 <acquire>
80104e4b:	83 c4 10             	add    $0x10,%esp
    assertState(np, EMBRYO);
80104e4e:	83 ec 08             	sub    $0x8,%esp
80104e51:	6a 01                	push   $0x1
80104e53:	ff 75 e0             	pushl  -0x20(%ebp)
80104e56:	e8 db 16 00 00       	call   80106536 <assertState>
80104e5b:	83 c4 10             	add    $0x10,%esp
    rc = removeFromStateList(&ptable.pLists.embryo, np);
80104e5e:	83 ec 08             	sub    $0x8,%esp
80104e61:	ff 75 e0             	pushl  -0x20(%ebp)
80104e64:	68 00 71 11 80       	push   $0x80117100
80104e69:	e8 18 16 00 00       	call   80106486 <removeFromStateList>
80104e6e:	83 c4 10             	add    $0x10,%esp
80104e71:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(rc == -1)
80104e74:	83 7d dc ff          	cmpl   $0xffffffff,-0x24(%ebp)
80104e78:	75 0d                	jne    80104e87 <fork+0xba>
      panic("Could not remove from embryo list");
80104e7a:	83 ec 0c             	sub    $0xc,%esp
80104e7d:	68 8c a6 10 80       	push   $0x8010a68c
80104e82:	e8 df b6 ff ff       	call   80100566 <panic>
#endif
    np->state = UNUSED;
80104e87:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104e8a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
#ifdef CS333_P3P4
    rc = addToStateListHead(&ptable.pLists.free, np);
80104e91:	83 ec 08             	sub    $0x8,%esp
80104e94:	ff 75 e0             	pushl  -0x20(%ebp)
80104e97:	68 f0 70 11 80       	push   $0x801170f0
80104e9c:	e8 31 17 00 00       	call   801065d2 <addToStateListHead>
80104ea1:	83 c4 10             	add    $0x10,%esp
80104ea4:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(rc == -1)
80104ea7:	83 7d dc ff          	cmpl   $0xffffffff,-0x24(%ebp)
80104eab:	75 0d                	jne    80104eba <fork+0xed>
      panic("Could not add to free list.");
80104ead:	83 ec 0c             	sub    $0xc,%esp
80104eb0:	68 fb a5 10 80       	push   $0x8010a5fb
80104eb5:	e8 ac b6 ff ff       	call   80100566 <panic>
    release(&ptable.lock);
80104eba:	83 ec 0c             	sub    $0xc,%esp
80104ebd:	68 a0 49 11 80       	push   $0x801149a0
80104ec2:	e8 a7 1b 00 00       	call   80106a6e <release>
80104ec7:	83 c4 10             	add    $0x10,%esp
#endif
    return -1;
80104eca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ecf:	e9 a4 01 00 00       	jmp    80105078 <fork+0x2ab>
  }
  np->sz = proc->sz;
80104ed4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104eda:	8b 10                	mov    (%eax),%edx
80104edc:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104edf:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104ee1:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104ee8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104eeb:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104eee:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104ef1:	8b 50 18             	mov    0x18(%eax),%edx
80104ef4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104efa:	8b 40 18             	mov    0x18(%eax),%eax
80104efd:	89 c3                	mov    %eax,%ebx
80104eff:	b8 13 00 00 00       	mov    $0x13,%eax
80104f04:	89 d7                	mov    %edx,%edi
80104f06:	89 de                	mov    %ebx,%esi
80104f08:	89 c1                	mov    %eax,%ecx
80104f0a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104f0c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104f0f:	8b 40 18             	mov    0x18(%eax),%eax
80104f12:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104f19:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104f20:	eb 43                	jmp    80104f65 <fork+0x198>
    if(proc->ofile[i])
80104f22:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f28:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104f2b:	83 c2 08             	add    $0x8,%edx
80104f2e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104f32:	85 c0                	test   %eax,%eax
80104f34:	74 2b                	je     80104f61 <fork+0x194>
      np->ofile[i] = filedup(proc->ofile[i]);
80104f36:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f3c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104f3f:	83 c2 08             	add    $0x8,%edx
80104f42:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104f46:	83 ec 0c             	sub    $0xc,%esp
80104f49:	50                   	push   %eax
80104f4a:	e8 18 c2 ff ff       	call   80101167 <filedup>
80104f4f:	83 c4 10             	add    $0x10,%esp
80104f52:	89 c1                	mov    %eax,%ecx
80104f54:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104f57:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104f5a:	83 c2 08             	add    $0x8,%edx
80104f5d:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104f61:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104f65:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104f69:	7e b7                	jle    80104f22 <fork+0x155>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104f6b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f71:	8b 40 68             	mov    0x68(%eax),%eax
80104f74:	83 ec 0c             	sub    $0xc,%esp
80104f77:	50                   	push   %eax
80104f78:	e8 5e cb ff ff       	call   80101adb <idup>
80104f7d:	83 c4 10             	add    $0x10,%esp
80104f80:	89 c2                	mov    %eax,%edx
80104f82:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104f85:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104f88:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f8e:	8d 50 6c             	lea    0x6c(%eax),%edx
80104f91:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104f94:	83 c0 6c             	add    $0x6c,%eax
80104f97:	83 ec 04             	sub    $0x4,%esp
80104f9a:	6a 10                	push   $0x10
80104f9c:	52                   	push   %edx
80104f9d:	50                   	push   %eax
80104f9e:	e8 ca 1e 00 00       	call   80106e6d <safestrcpy>
80104fa3:	83 c4 10             	add    $0x10,%esp
 
  pid = np->pid;
80104fa6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104fa9:	8b 40 10             	mov    0x10(%eax),%eax
80104fac:	89 45 d8             	mov    %eax,-0x28(%ebp)

#ifdef CS333_P2
  np->uid = proc->uid;
80104faf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fb5:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80104fbb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104fbe:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  np->gid = proc->gid;
80104fc4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fca:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80104fd0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104fd3:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
#endif

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80104fd9:	83 ec 0c             	sub    $0xc,%esp
80104fdc:	68 a0 49 11 80       	push   $0x801149a0
80104fe1:	e8 21 1a 00 00       	call   80106a07 <acquire>
80104fe6:	83 c4 10             	add    $0x10,%esp

#ifdef CS333_P3P4
  //Remove the process from the embryo list
  assertState(np, EMBRYO);
80104fe9:	83 ec 08             	sub    $0x8,%esp
80104fec:	6a 01                	push   $0x1
80104fee:	ff 75 e0             	pushl  -0x20(%ebp)
80104ff1:	e8 40 15 00 00       	call   80106536 <assertState>
80104ff6:	83 c4 10             	add    $0x10,%esp
  rc = removeFromStateList(&ptable.pLists.embryo, np);
80104ff9:	83 ec 08             	sub    $0x8,%esp
80104ffc:	ff 75 e0             	pushl  -0x20(%ebp)
80104fff:	68 00 71 11 80       	push   $0x80117100
80105004:	e8 7d 14 00 00       	call   80106486 <removeFromStateList>
80105009:	83 c4 10             	add    $0x10,%esp
8010500c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  if(rc == -1)
8010500f:	83 7d dc ff          	cmpl   $0xffffffff,-0x24(%ebp)
80105013:	75 0d                	jne    80105022 <fork+0x255>
    panic("Could not remove process from embryo.");
80105015:	83 ec 0c             	sub    $0xc,%esp
80105018:	68 b0 a6 10 80       	push   $0x8010a6b0
8010501d:	e8 44 b5 ff ff       	call   80100566 <panic>
#endif
  np->state = RUNNABLE;
80105022:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105025:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

#ifdef CS333_P3P4
  //Add process to end of ready list
  assertState(np, RUNNABLE);
8010502c:	83 ec 08             	sub    $0x8,%esp
8010502f:	6a 03                	push   $0x3
80105031:	ff 75 e0             	pushl  -0x20(%ebp)
80105034:	e8 fd 14 00 00       	call   80106536 <assertState>
80105039:	83 c4 10             	add    $0x10,%esp
  rc = addToStateListEnd(&ptable.pLists.ready[0], np); //Add to end of highest queue
8010503c:	83 ec 08             	sub    $0x8,%esp
8010503f:	ff 75 e0             	pushl  -0x20(%ebp)
80105042:	68 d4 70 11 80       	push   $0x801170d4
80105047:	e8 0b 15 00 00       	call   80106557 <addToStateListEnd>
8010504c:	83 c4 10             	add    $0x10,%esp
8010504f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  if(rc == -1)
80105052:	83 7d dc ff          	cmpl   $0xffffffff,-0x24(%ebp)
80105056:	75 0d                	jne    80105065 <fork+0x298>
    panic("Could not add process to ready list.");
80105058:	83 ec 0c             	sub    $0xc,%esp
8010505b:	68 d8 a6 10 80       	push   $0x8010a6d8
80105060:	e8 01 b5 ff ff       	call   80100566 <panic>
#endif

  release(&ptable.lock);
80105065:	83 ec 0c             	sub    $0xc,%esp
80105068:	68 a0 49 11 80       	push   $0x801149a0
8010506d:	e8 fc 19 00 00       	call   80106a6e <release>
80105072:	83 c4 10             	add    $0x10,%esp
  
  return pid;
80105075:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80105078:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010507b:	5b                   	pop    %ebx
8010507c:	5e                   	pop    %esi
8010507d:	5f                   	pop    %edi
8010507e:	5d                   	pop    %ebp
8010507f:	c3                   	ret    

80105080 <exit>:
  panic("zombie exit");
}
#else
void
exit(void) //Project 3
{
80105080:	55                   	push   %ebp
80105081:	89 e5                	mov    %esp,%ebp
80105083:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;
  int rc;

  if(proc == initproc)
80105086:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010508d:	a1 88 d6 10 80       	mov    0x8010d688,%eax
80105092:	39 c2                	cmp    %eax,%edx
80105094:	75 0d                	jne    801050a3 <exit+0x23>
    panic("init exiting");
80105096:	83 ec 0c             	sub    $0xc,%esp
80105099:	68 fd a6 10 80       	push   $0x8010a6fd
8010509e:	e8 c3 b4 ff ff       	call   80100566 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801050a3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801050aa:	eb 48                	jmp    801050f4 <exit+0x74>
    if(proc->ofile[fd]){
801050ac:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050b2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801050b5:	83 c2 08             	add    $0x8,%edx
801050b8:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801050bc:	85 c0                	test   %eax,%eax
801050be:	74 30                	je     801050f0 <exit+0x70>
      fileclose(proc->ofile[fd]);
801050c0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050c6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801050c9:	83 c2 08             	add    $0x8,%edx
801050cc:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801050d0:	83 ec 0c             	sub    $0xc,%esp
801050d3:	50                   	push   %eax
801050d4:	e8 df c0 ff ff       	call   801011b8 <fileclose>
801050d9:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
801050dc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050e2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801050e5:	83 c2 08             	add    $0x8,%edx
801050e8:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801050ef:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801050f0:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801050f4:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801050f8:	7e b2                	jle    801050ac <exit+0x2c>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
801050fa:	e8 ed e7 ff ff       	call   801038ec <begin_op>
  iput(proc->cwd);
801050ff:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105105:	8b 40 68             	mov    0x68(%eax),%eax
80105108:	83 ec 0c             	sub    $0xc,%esp
8010510b:	50                   	push   %eax
8010510c:	e8 fc cb ff ff       	call   80101d0d <iput>
80105111:	83 c4 10             	add    $0x10,%esp
  end_op();
80105114:	e8 5f e8 ff ff       	call   80103978 <end_op>
  proc->cwd = 0;
80105119:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010511f:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80105126:	83 ec 0c             	sub    $0xc,%esp
80105129:	68 a0 49 11 80       	push   $0x801149a0
8010512e:	e8 d4 18 00 00       	call   80106a07 <acquire>
80105133:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80105136:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010513c:	8b 40 14             	mov    0x14(%eax),%eax
8010513f:	83 ec 0c             	sub    $0xc,%esp
80105142:	50                   	push   %eax
80105143:	e8 f5 09 00 00       	call   80105b3d <wakeup1>
80105148:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
 
  for(int i = 0; i < MAX; i++)
8010514b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80105152:	eb 4c                	jmp    801051a0 <exit+0x120>
  { 
    p = ptable.pLists.ready[i];
80105154:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105157:	05 cc 09 00 00       	add    $0x9cc,%eax
8010515c:	8b 04 85 a4 49 11 80 	mov    -0x7feeb65c(,%eax,4),%eax
80105163:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if(p)
80105166:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010516a:	74 30                	je     8010519c <exit+0x11c>
    {
      while(p != 0)
8010516c:	eb 28                	jmp    80105196 <exit+0x116>
      {
        if(p->parent == proc)
8010516e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105171:	8b 50 14             	mov    0x14(%eax),%edx
80105174:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010517a:	39 c2                	cmp    %eax,%edx
8010517c:	75 0c                	jne    8010518a <exit+0x10a>
          p->parent = initproc;
8010517e:	8b 15 88 d6 10 80    	mov    0x8010d688,%edx
80105184:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105187:	89 50 14             	mov    %edx,0x14(%eax)
        p = p->next;
8010518a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010518d:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105193:	89 45 f4             	mov    %eax,-0xc(%ebp)
  { 
    p = ptable.pLists.ready[i];

    if(p)
    {
      while(p != 0)
80105196:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010519a:	75 d2                	jne    8010516e <exit+0xee>
  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
 
  for(int i = 0; i < MAX; i++)
8010519c:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801051a0:	83 7d ec 05          	cmpl   $0x5,-0x14(%ebp)
801051a4:	7e ae                	jle    80105154 <exit+0xd4>
        p = p->next;
      }
    }
  }

  p = ptable.pLists.sleep;
801051a6:	a1 f4 70 11 80       	mov    0x801170f4,%eax
801051ab:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(p)
801051ae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801051b2:	74 30                	je     801051e4 <exit+0x164>
  {
    while(p != 0)
801051b4:	eb 28                	jmp    801051de <exit+0x15e>
    {
      if(p->parent == proc)
801051b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051b9:	8b 50 14             	mov    0x14(%eax),%edx
801051bc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051c2:	39 c2                	cmp    %eax,%edx
801051c4:	75 0c                	jne    801051d2 <exit+0x152>
        p->parent = initproc;
801051c6:	8b 15 88 d6 10 80    	mov    0x8010d688,%edx
801051cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051cf:	89 50 14             	mov    %edx,0x14(%eax)
      p = p->next;
801051d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051d5:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801051db:	89 45 f4             	mov    %eax,-0xc(%ebp)

  p = ptable.pLists.sleep;

  if(p)
  {
    while(p != 0)
801051de:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801051e2:	75 d2                	jne    801051b6 <exit+0x136>
        p->parent = initproc;
      p = p->next;
    }
  }

  p = ptable.pLists.embryo;
801051e4:	a1 00 71 11 80       	mov    0x80117100,%eax
801051e9:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(p)
801051ec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801051f0:	74 30                	je     80105222 <exit+0x1a2>
  {
    while(p != 0)
801051f2:	eb 28                	jmp    8010521c <exit+0x19c>
    {
      if(p->parent == proc)
801051f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051f7:	8b 50 14             	mov    0x14(%eax),%edx
801051fa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105200:	39 c2                	cmp    %eax,%edx
80105202:	75 0c                	jne    80105210 <exit+0x190>
        p->parent = initproc;
80105204:	8b 15 88 d6 10 80    	mov    0x8010d688,%edx
8010520a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010520d:	89 50 14             	mov    %edx,0x14(%eax)
      p = p->next;
80105210:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105213:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105219:	89 45 f4             	mov    %eax,-0xc(%ebp)

  p = ptable.pLists.embryo;

  if(p)
  {
    while(p != 0)
8010521c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105220:	75 d2                	jne    801051f4 <exit+0x174>
        p->parent = initproc;
      p = p->next;
    }
  }

  p = ptable.pLists.running;
80105222:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80105227:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(p)
8010522a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010522e:	74 30                	je     80105260 <exit+0x1e0>
  {
    while(p != 0)
80105230:	eb 28                	jmp    8010525a <exit+0x1da>
    {
      if(p->parent == proc)
80105232:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105235:	8b 50 14             	mov    0x14(%eax),%edx
80105238:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010523e:	39 c2                	cmp    %eax,%edx
80105240:	75 0c                	jne    8010524e <exit+0x1ce>
        p->parent = initproc;
80105242:	8b 15 88 d6 10 80    	mov    0x8010d688,%edx
80105248:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010524b:	89 50 14             	mov    %edx,0x14(%eax)
      p = p->next;
8010524e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105251:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105257:	89 45 f4             	mov    %eax,-0xc(%ebp)

  p = ptable.pLists.running;

  if(p)
  {
    while(p != 0)
8010525a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010525e:	75 d2                	jne    80105232 <exit+0x1b2>
        p->parent = initproc;
      p = p->next;
    }
  }

  p = ptable.pLists.zombie;
80105260:	a1 f8 70 11 80       	mov    0x801170f8,%eax
80105265:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(p)
80105268:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010526c:	74 41                	je     801052af <exit+0x22f>
  {
    while(p != 0)
8010526e:	eb 39                	jmp    801052a9 <exit+0x229>
    {
      if(p->parent == proc)
80105270:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105273:	8b 50 14             	mov    0x14(%eax),%edx
80105276:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010527c:	39 c2                	cmp    %eax,%edx
8010527e:	75 1d                	jne    8010529d <exit+0x21d>
      {
        p->parent = initproc;
80105280:	8b 15 88 d6 10 80    	mov    0x8010d688,%edx
80105286:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105289:	89 50 14             	mov    %edx,0x14(%eax)
        wakeup1(initproc);
8010528c:	a1 88 d6 10 80       	mov    0x8010d688,%eax
80105291:	83 ec 0c             	sub    $0xc,%esp
80105294:	50                   	push   %eax
80105295:	e8 a3 08 00 00       	call   80105b3d <wakeup1>
8010529a:	83 c4 10             	add    $0x10,%esp
      }
      p = p->next;
8010529d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052a0:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801052a6:	89 45 f4             	mov    %eax,-0xc(%ebp)

  p = ptable.pLists.zombie;

  if(p)
  {
    while(p != 0)
801052a9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801052ad:	75 c1                	jne    80105270 <exit+0x1f0>
      p = p->next;
    }
  }

  // Jump into the scheduler, never to return.
  rc = removeFromStateList(&ptable.pLists.running, proc);
801052af:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052b5:	83 ec 08             	sub    $0x8,%esp
801052b8:	50                   	push   %eax
801052b9:	68 fc 70 11 80       	push   $0x801170fc
801052be:	e8 c3 11 00 00       	call   80106486 <removeFromStateList>
801052c3:	83 c4 10             	add    $0x10,%esp
801052c6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(rc == -1)
801052c9:	83 7d e8 ff          	cmpl   $0xffffffff,-0x18(%ebp)
801052cd:	75 0d                	jne    801052dc <exit+0x25c>
    panic("Could not remove from running list.");
801052cf:	83 ec 0c             	sub    $0xc,%esp
801052d2:	68 0c a7 10 80       	push   $0x8010a70c
801052d7:	e8 8a b2 ff ff       	call   80100566 <panic>
  assertState(proc, RUNNING);
801052dc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052e2:	83 ec 08             	sub    $0x8,%esp
801052e5:	6a 04                	push   $0x4
801052e7:	50                   	push   %eax
801052e8:	e8 49 12 00 00       	call   80106536 <assertState>
801052ed:	83 c4 10             	add    $0x10,%esp

  proc->state = ZOMBIE;
801052f0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052f6:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)

  rc = addToStateListHead(&ptable.pLists.zombie, proc);
801052fd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105303:	83 ec 08             	sub    $0x8,%esp
80105306:	50                   	push   %eax
80105307:	68 f8 70 11 80       	push   $0x801170f8
8010530c:	e8 c1 12 00 00       	call   801065d2 <addToStateListHead>
80105311:	83 c4 10             	add    $0x10,%esp
80105314:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(rc == -1)
80105317:	83 7d e8 ff          	cmpl   $0xffffffff,-0x18(%ebp)
8010531b:	75 0d                	jne    8010532a <exit+0x2aa>
    panic("Could not add to zombie list.");
8010531d:	83 ec 0c             	sub    $0xc,%esp
80105320:	68 30 a7 10 80       	push   $0x8010a730
80105325:	e8 3c b2 ff ff       	call   80100566 <panic>
  //release(&ptable.lock);
  
  sched();
8010532a:	e8 11 04 00 00       	call   80105740 <sched>
  panic("zombie exit");
8010532f:	83 ec 0c             	sub    $0xc,%esp
80105332:	68 4e a7 10 80       	push   $0x8010a74e
80105337:	e8 2a b2 ff ff       	call   80100566 <panic>

8010533c <wait>:
  }
}
#else
int
wait(void) //Project 3
{
8010533c:	55                   	push   %ebp
8010533d:	89 e5                	mov    %esp,%ebp
8010533f:	83 ec 28             	sub    $0x28,%esp
  //struct proc *p;
  struct proc *current;
  int havekids, pid;
  int rc;

  acquire(&ptable.lock);
80105342:	83 ec 0c             	sub    $0xc,%esp
80105345:	68 a0 49 11 80       	push   $0x801149a0
8010534a:	e8 b8 16 00 00       	call   80106a07 <acquire>
8010534f:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80105352:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

    for(int i = 0; i < MAX; i++)
80105359:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80105360:	eb 47                	jmp    801053a9 <wait+0x6d>
    {
      current = ptable.pLists.ready[i];
80105362:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105365:	05 cc 09 00 00       	add    $0x9cc,%eax
8010536a:	8b 04 85 a4 49 11 80 	mov    -0x7feeb65c(,%eax,4),%eax
80105371:	89 45 f4             	mov    %eax,-0xc(%ebp)

      if(current)
80105374:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105378:	74 2b                	je     801053a5 <wait+0x69>
      {
        while(current != 0)
8010537a:	eb 23                	jmp    8010539f <wait+0x63>
        {
          if(current->parent == proc)
8010537c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010537f:	8b 50 14             	mov    0x14(%eax),%edx
80105382:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105388:	39 c2                	cmp    %eax,%edx
8010538a:	75 07                	jne    80105393 <wait+0x57>
            havekids = 1;
8010538c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
          current = current->next;
80105393:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105396:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010539c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
      current = ptable.pLists.ready[i];

      if(current)
      {
        while(current != 0)
8010539f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801053a3:	75 d7                	jne    8010537c <wait+0x40>
  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;

    for(int i = 0; i < MAX; i++)
801053a5:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801053a9:	83 7d ec 05          	cmpl   $0x5,-0x14(%ebp)
801053ad:	7e b3                	jle    80105362 <wait+0x26>
          current = current->next;
        }
      }
    }

    current = ptable.pLists.sleep;
801053af:	a1 f4 70 11 80       	mov    0x801170f4,%eax
801053b4:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if(current)
801053b7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801053bb:	74 2b                	je     801053e8 <wait+0xac>
    {
      while(current != 0)
801053bd:	eb 23                	jmp    801053e2 <wait+0xa6>
      {
        if(current->parent == proc)
801053bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053c2:	8b 50 14             	mov    0x14(%eax),%edx
801053c5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053cb:	39 c2                	cmp    %eax,%edx
801053cd:	75 07                	jne    801053d6 <wait+0x9a>
          havekids = 1;
801053cf:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
        current = current->next;
801053d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053d9:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801053df:	89 45 f4             	mov    %eax,-0xc(%ebp)

    current = ptable.pLists.sleep;

    if(current)
    {
      while(current != 0)
801053e2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801053e6:	75 d7                	jne    801053bf <wait+0x83>
          havekids = 1;
        current = current->next;
      }
    }
 
    current = ptable.pLists.embryo;
801053e8:	a1 00 71 11 80       	mov    0x80117100,%eax
801053ed:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if(current)
801053f0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801053f4:	74 2b                	je     80105421 <wait+0xe5>
    {
      while(current != 0)
801053f6:	eb 23                	jmp    8010541b <wait+0xdf>
      {
        if(current->parent == proc)
801053f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053fb:	8b 50 14             	mov    0x14(%eax),%edx
801053fe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105404:	39 c2                	cmp    %eax,%edx
80105406:	75 07                	jne    8010540f <wait+0xd3>
          havekids = 1;
80105408:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
        current = current->next;
8010540f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105412:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105418:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
    current = ptable.pLists.embryo;

    if(current)
    {
      while(current != 0)
8010541b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010541f:	75 d7                	jne    801053f8 <wait+0xbc>
          havekids = 1;
        current = current->next;
      }
    }

    current = ptable.pLists.running;
80105421:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80105426:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if(current)
80105429:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010542d:	74 2b                	je     8010545a <wait+0x11e>
    {
      while(current != 0)
8010542f:	eb 23                	jmp    80105454 <wait+0x118>
      {
        if(current->parent == proc)
80105431:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105434:	8b 50 14             	mov    0x14(%eax),%edx
80105437:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010543d:	39 c2                	cmp    %eax,%edx
8010543f:	75 07                	jne    80105448 <wait+0x10c>
          havekids = 1;
80105441:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
        current = current->next;
80105448:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010544b:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105451:	89 45 f4             	mov    %eax,-0xc(%ebp)

    current = ptable.pLists.running;

    if(current)
    {
      while(current != 0)
80105454:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105458:	75 d7                	jne    80105431 <wait+0xf5>
          havekids = 1;
        current = current->next;
      }
    }

    current = ptable.pLists.zombie;
8010545a:	a1 f8 70 11 80       	mov    0x801170f8,%eax
8010545f:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if(current)
80105462:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105466:	0f 84 ee 00 00 00    	je     8010555a <wait+0x21e>
    {
      while(current != 0)
8010546c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105470:	0f 84 e4 00 00 00    	je     8010555a <wait+0x21e>
      {
        if(current->parent == proc)
80105476:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105479:	8b 50 14             	mov    0x14(%eax),%edx
8010547c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105482:	39 c2                	cmp    %eax,%edx
80105484:	75 07                	jne    8010548d <wait+0x151>
          havekids = 1;
80105486:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

        rc = removeFromStateList(&ptable.pLists.zombie, current);
8010548d:	83 ec 08             	sub    $0x8,%esp
80105490:	ff 75 f4             	pushl  -0xc(%ebp)
80105493:	68 f8 70 11 80       	push   $0x801170f8
80105498:	e8 e9 0f 00 00       	call   80106486 <removeFromStateList>
8010549d:	83 c4 10             	add    $0x10,%esp
801054a0:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if(rc == -1)
801054a3:	83 7d e8 ff          	cmpl   $0xffffffff,-0x18(%ebp)
801054a7:	75 0d                	jne    801054b6 <wait+0x17a>
          panic("Could not remove from zombie list.");
801054a9:	83 ec 0c             	sub    $0xc,%esp
801054ac:	68 5c a7 10 80       	push   $0x8010a75c
801054b1:	e8 b0 b0 ff ff       	call   80100566 <panic>

        pid = current->pid;
801054b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054b9:	8b 40 10             	mov    0x10(%eax),%eax
801054bc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        kfree(current->kstack);
801054bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054c2:	8b 40 08             	mov    0x8(%eax),%eax
801054c5:	83 ec 0c             	sub    $0xc,%esp
801054c8:	50                   	push   %eax
801054c9:	e8 9a da ff ff       	call   80102f68 <kfree>
801054ce:	83 c4 10             	add    $0x10,%esp
        current->kstack = 0;
801054d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054d4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(current->pgdir);
801054db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054de:	8b 40 04             	mov    0x4(%eax),%eax
801054e1:	83 ec 0c             	sub    $0xc,%esp
801054e4:	50                   	push   %eax
801054e5:	e8 5d 4a 00 00       	call   80109f47 <freevm>
801054ea:	83 c4 10             	add    $0x10,%esp
        current->state = UNUSED;
801054ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054f0:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)

        rc = addToStateListHead(&ptable.pLists.free, current);
801054f7:	83 ec 08             	sub    $0x8,%esp
801054fa:	ff 75 f4             	pushl  -0xc(%ebp)
801054fd:	68 f0 70 11 80       	push   $0x801170f0
80105502:	e8 cb 10 00 00       	call   801065d2 <addToStateListHead>
80105507:	83 c4 10             	add    $0x10,%esp
8010550a:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if(rc == -1)
8010550d:	83 7d e8 ff          	cmpl   $0xffffffff,-0x18(%ebp)
80105511:	75 0d                	jne    80105520 <wait+0x1e4>
          panic("Could not add to free list.");
80105513:	83 ec 0c             	sub    $0xc,%esp
80105516:	68 fb a5 10 80       	push   $0x8010a5fb
8010551b:	e8 46 b0 ff ff       	call   80100566 <panic>

        current->pid = 0;
80105520:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105523:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        current->parent = 0;
8010552a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010552d:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        current->name[0] = 0;
80105534:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105537:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        current->killed = 0;
8010553b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010553e:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80105545:	83 ec 0c             	sub    $0xc,%esp
80105548:	68 a0 49 11 80       	push   $0x801149a0
8010554d:	e8 1c 15 00 00       	call   80106a6e <release>
80105552:	83 c4 10             	add    $0x10,%esp
        return pid;
80105555:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105558:	eb 46                	jmp    801055a0 <wait+0x264>
        current = current->next;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
8010555a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010555e:	74 0d                	je     8010556d <wait+0x231>
80105560:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105566:	8b 40 24             	mov    0x24(%eax),%eax
80105569:	85 c0                	test   %eax,%eax
8010556b:	74 17                	je     80105584 <wait+0x248>
      release(&ptable.lock);
8010556d:	83 ec 0c             	sub    $0xc,%esp
80105570:	68 a0 49 11 80       	push   $0x801149a0
80105575:	e8 f4 14 00 00       	call   80106a6e <release>
8010557a:	83 c4 10             	add    $0x10,%esp
      return -1;
8010557d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105582:	eb 1c                	jmp    801055a0 <wait+0x264>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80105584:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010558a:	83 ec 08             	sub    $0x8,%esp
8010558d:	68 a0 49 11 80       	push   $0x801149a0
80105592:	50                   	push   %eax
80105593:	e8 14 04 00 00       	call   801059ac <sleep>
80105598:	83 c4 10             	add    $0x10,%esp
  }
8010559b:	e9 b2 fd ff ff       	jmp    80105352 <wait+0x16>
}
801055a0:	c9                   	leave  
801055a1:	c3                   	ret    

801055a2 <scheduler>:
}

#else //Scheduler for Project 4
void
scheduler(void)
{
801055a2:	55                   	push   %ebp
801055a3:	89 e5                	mov    %esp,%ebp
801055a5:	83 ec 18             	sub    $0x18,%esp
  int rc;
  //int list = 0;  // for looping through the array of ready lists in MLFQ

  for (;;){
    // Enable interrupts on this processor.
    sti();
801055a8:	e8 47 f2 ff ff       	call   801047f4 <sti>
    
    idle = 1;  // assume idle unless we schedule a process
801055ad:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

    acquire(&ptable.lock);
801055b4:	83 ec 0c             	sub    $0xc,%esp
801055b7:	68 a0 49 11 80       	push   $0x801149a0
801055bc:	e8 46 14 00 00       	call   80106a07 <acquire>
801055c1:	83 c4 10             	add    $0x10,%esp

    if(ptable.PromoteAtTime <= ticks)
801055c4:	8b 15 04 71 11 80    	mov    0x80117104,%edx
801055ca:	a1 20 79 11 80       	mov    0x80117920,%eax
801055cf:	39 c2                	cmp    %eax,%edx
801055d1:	77 14                	ja     801055e7 <scheduler+0x45>
    {
      promoteAll(); 
801055d3:	e8 34 0d 00 00       	call   8010630c <promoteAll>
      ptable.PromoteAtTime = ticks + TICKS_TO_PROMOTE;
801055d8:	a1 20 79 11 80       	mov    0x80117920,%eax
801055dd:	05 88 13 00 00       	add    $0x1388,%eax
801055e2:	a3 04 71 11 80       	mov    %eax,0x80117104
    }

    for(int i = 0; i < MAX+1; i++)
801055e7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801055ee:	eb 23                	jmp    80105613 <scheduler+0x71>
    {
      p = ptable.pLists.ready[i];
801055f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801055f3:	05 cc 09 00 00       	add    $0x9cc,%eax
801055f8:	8b 04 85 a4 49 11 80 	mov    -0x7feeb65c(,%eax,4),%eax
801055ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
      if(p)
80105602:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105606:	75 13                	jne    8010561b <scheduler+0x79>
        break;
      else
        p = 0;
80105608:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    {
      promoteAll(); 
      ptable.PromoteAtTime = ticks + TICKS_TO_PROMOTE;
    }

    for(int i = 0; i < MAX+1; i++)
8010560f:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80105613:	83 7d ec 06          	cmpl   $0x6,-0x14(%ebp)
80105617:	7e d7                	jle    801055f0 <scheduler+0x4e>
80105619:	eb 01                	jmp    8010561c <scheduler+0x7a>
    {
      p = ptable.pLists.ready[i];
      if(p)
        break;
8010561b:	90                   	nop
      else
        p = 0;
    }

    if(p)
8010561c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105620:	0f 84 f1 00 00 00    	je     80105717 <scheduler+0x175>
    {
      idle = 0;
80105626:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      proc = p;
8010562d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105630:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80105636:	83 ec 0c             	sub    $0xc,%esp
80105639:	ff 75 f4             	pushl  -0xc(%ebp)
8010563c:	e8 c0 44 00 00       	call   80109b01 <switchuvm>
80105641:	83 c4 10             	add    $0x10,%esp

      rc = removeFromStateList(&ptable.pLists.ready[p->priority], p);
80105644:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105647:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
8010564d:	05 cc 09 00 00       	add    $0x9cc,%eax
80105652:	c1 e0 02             	shl    $0x2,%eax
80105655:	05 a0 49 11 80       	add    $0x801149a0,%eax
8010565a:	83 c0 04             	add    $0x4,%eax
8010565d:	83 ec 08             	sub    $0x8,%esp
80105660:	ff 75 f4             	pushl  -0xc(%ebp)
80105663:	50                   	push   %eax
80105664:	e8 1d 0e 00 00       	call   80106486 <removeFromStateList>
80105669:	83 c4 10             	add    $0x10,%esp
8010566c:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(rc == -1)
8010566f:	83 7d e8 ff          	cmpl   $0xffffffff,-0x18(%ebp)
80105673:	75 0d                	jne    80105682 <scheduler+0xe0>
        panic("Could not remove from ready list.");
80105675:	83 ec 0c             	sub    $0xc,%esp
80105678:	68 80 a7 10 80       	push   $0x8010a780
8010567d:	e8 e4 ae ff ff       	call   80100566 <panic>
      assertState(p, RUNNABLE);
80105682:	83 ec 08             	sub    $0x8,%esp
80105685:	6a 03                	push   $0x3
80105687:	ff 75 f4             	pushl  -0xc(%ebp)
8010568a:	e8 a7 0e 00 00       	call   80106536 <assertState>
8010568f:	83 c4 10             	add    $0x10,%esp
        
      p->state = RUNNING;
80105692:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105695:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      //Put process on running list
      rc = addToStateListHead(&ptable.pLists.running, p);
8010569c:	83 ec 08             	sub    $0x8,%esp
8010569f:	ff 75 f4             	pushl  -0xc(%ebp)
801056a2:	68 fc 70 11 80       	push   $0x801170fc
801056a7:	e8 26 0f 00 00       	call   801065d2 <addToStateListHead>
801056ac:	83 c4 10             	add    $0x10,%esp
801056af:	89 45 e8             	mov    %eax,-0x18(%ebp)
      assertState(p, RUNNING);
801056b2:	83 ec 08             	sub    $0x8,%esp
801056b5:	6a 04                	push   $0x4
801056b7:	ff 75 f4             	pushl  -0xc(%ebp)
801056ba:	e8 77 0e 00 00       	call   80106536 <assertState>
801056bf:	83 c4 10             	add    $0x10,%esp
      if(rc == -1)
801056c2:	83 7d e8 ff          	cmpl   $0xffffffff,-0x18(%ebp)
801056c6:	75 0d                	jne    801056d5 <scheduler+0x133>
        panic("Could not add to running list.");
801056c8:	83 ec 0c             	sub    $0xc,%esp
801056cb:	68 a4 a7 10 80       	push   $0x8010a7a4
801056d0:	e8 91 ae ff ff       	call   80100566 <panic>

#ifdef CS333_P2
      proc->cpu_ticks_in = ticks;
801056d5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056db:	8b 15 20 79 11 80    	mov    0x80117920,%edx
801056e1:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
#endif

      swtch(&cpu->scheduler, proc->context);
801056e7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056ed:	8b 40 1c             	mov    0x1c(%eax),%eax
801056f0:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801056f7:	83 c2 04             	add    $0x4,%edx
801056fa:	83 ec 08             	sub    $0x8,%esp
801056fd:	50                   	push   %eax
801056fe:	52                   	push   %edx
801056ff:	e8 da 17 00 00       	call   80106ede <swtch>
80105704:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80105707:	e8 d8 43 00 00       	call   80109ae4 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
8010570c:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80105713:	00 00 00 00 
    }

    release(&ptable.lock);
80105717:	83 ec 0c             	sub    $0xc,%esp
8010571a:	68 a0 49 11 80       	push   $0x801149a0
8010571f:	e8 4a 13 00 00       	call   80106a6e <release>
80105724:	83 c4 10             	add    $0x10,%esp
    // if idle, wait for next interrupt
    if (idle) {
80105727:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010572b:	0f 84 77 fe ff ff    	je     801055a8 <scheduler+0x6>
      sti();
80105731:	e8 be f0 ff ff       	call   801047f4 <sti>
      hlt();
80105736:	e8 a2 f0 ff ff       	call   801047dd <hlt>
    }
  }
8010573b:	e9 68 fe ff ff       	jmp    801055a8 <scheduler+0x6>

80105740 <sched>:

}
#else
void
sched(void) //For Project 3
{
80105740:	55                   	push   %ebp
80105741:	89 e5                	mov    %esp,%ebp
80105743:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
80105746:	83 ec 0c             	sub    $0xc,%esp
80105749:	68 a0 49 11 80       	push   $0x801149a0
8010574e:	e8 e7 13 00 00       	call   80106b3a <holding>
80105753:	83 c4 10             	add    $0x10,%esp
80105756:	85 c0                	test   %eax,%eax
80105758:	75 0d                	jne    80105767 <sched+0x27>
    panic("sched ptable.lock");
8010575a:	83 ec 0c             	sub    $0xc,%esp
8010575d:	68 c3 a7 10 80       	push   $0x8010a7c3
80105762:	e8 ff ad ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
80105767:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010576d:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105773:	83 f8 01             	cmp    $0x1,%eax
80105776:	74 0d                	je     80105785 <sched+0x45>
    panic("sched locks");
80105778:	83 ec 0c             	sub    $0xc,%esp
8010577b:	68 d5 a7 10 80       	push   $0x8010a7d5
80105780:	e8 e1 ad ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
80105785:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010578b:	8b 40 0c             	mov    0xc(%eax),%eax
8010578e:	83 f8 04             	cmp    $0x4,%eax
80105791:	75 0d                	jne    801057a0 <sched+0x60>
    panic("sched running");
80105793:	83 ec 0c             	sub    $0xc,%esp
80105796:	68 e1 a7 10 80       	push   $0x8010a7e1
8010579b:	e8 c6 ad ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
801057a0:	e8 3f f0 ff ff       	call   801047e4 <readeflags>
801057a5:	25 00 02 00 00       	and    $0x200,%eax
801057aa:	85 c0                	test   %eax,%eax
801057ac:	74 0d                	je     801057bb <sched+0x7b>
    panic("sched interruptible");
801057ae:	83 ec 0c             	sub    $0xc,%esp
801057b1:	68 ef a7 10 80       	push   $0x8010a7ef
801057b6:	e8 ab ad ff ff       	call   80100566 <panic>
  intena = cpu->intena;
801057bb:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801057c1:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801057c7:	89 45 f4             	mov    %eax,-0xc(%ebp)

#ifdef CS333_P2 
  proc->cpu_ticks_total = ticks - proc->cpu_ticks_in;  
801057ca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057d0:	8b 0d 20 79 11 80    	mov    0x80117920,%ecx
801057d6:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801057dd:	8b 92 8c 00 00 00    	mov    0x8c(%edx),%edx
801057e3:	29 d1                	sub    %edx,%ecx
801057e5:	89 ca                	mov    %ecx,%edx
801057e7:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
#endif

  swtch(&proc->context, cpu->scheduler);
801057ed:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801057f3:	8b 40 04             	mov    0x4(%eax),%eax
801057f6:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801057fd:	83 c2 1c             	add    $0x1c,%edx
80105800:	83 ec 08             	sub    $0x8,%esp
80105803:	50                   	push   %eax
80105804:	52                   	push   %edx
80105805:	e8 d4 16 00 00       	call   80106ede <swtch>
8010580a:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
8010580d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105813:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105816:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)

}
8010581c:	90                   	nop
8010581d:	c9                   	leave  
8010581e:	c3                   	ret    

8010581f <yield>:
#endif

// Give up the CPU for one scheduling round.
void
yield(void)
{
8010581f:	55                   	push   %ebp
80105820:	89 e5                	mov    %esp,%ebp
80105822:	53                   	push   %ebx
80105823:	83 ec 14             	sub    $0x14,%esp
  int rc;
  int priority;
  acquire(&ptable.lock);  //DOC: yieldlock
80105826:	83 ec 0c             	sub    $0xc,%esp
80105829:	68 a0 49 11 80       	push   $0x801149a0
8010582e:	e8 d4 11 00 00       	call   80106a07 <acquire>
80105833:	83 c4 10             	add    $0x10,%esp

#ifdef CS333_P3P4
  rc = removeFromStateList(&ptable.pLists.running, proc);
80105836:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010583c:	83 ec 08             	sub    $0x8,%esp
8010583f:	50                   	push   %eax
80105840:	68 fc 70 11 80       	push   $0x801170fc
80105845:	e8 3c 0c 00 00       	call   80106486 <removeFromStateList>
8010584a:	83 c4 10             	add    $0x10,%esp
8010584d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(rc == -1)
80105850:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
80105854:	75 0d                	jne    80105863 <yield+0x44>
    panic("Could not remove from running list.");
80105856:	83 ec 0c             	sub    $0xc,%esp
80105859:	68 0c a7 10 80       	push   $0x8010a70c
8010585e:	e8 03 ad ff ff       	call   80100566 <panic>
  assertState(proc, RUNNING);
80105863:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105869:	83 ec 08             	sub    $0x8,%esp
8010586c:	6a 04                	push   $0x4
8010586e:	50                   	push   %eax
8010586f:	e8 c2 0c 00 00       	call   80106536 <assertState>
80105874:	83 c4 10             	add    $0x10,%esp
#endif  
  proc->state = RUNNABLE;
80105877:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010587d:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

#ifdef CS333_P3P4
  /*Project 4*/
  proc->budget = proc->budget - (ticks - proc->cpu_ticks_in);
80105884:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010588a:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105891:	8b 92 98 00 00 00    	mov    0x98(%edx),%edx
80105897:	89 d3                	mov    %edx,%ebx
80105899:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801058a0:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
801058a6:	8b 15 20 79 11 80    	mov    0x80117920,%edx
801058ac:	29 d1                	sub    %edx,%ecx
801058ae:	89 ca                	mov    %ecx,%edx
801058b0:	01 da                	add    %ebx,%edx
801058b2:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)
  if(proc->budget <= 0)
801058b8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058be:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
801058c4:	85 c0                	test   %eax,%eax
801058c6:	7f 36                	jg     801058fe <yield+0xdf>
  {
    if(proc->priority < MAX)
801058c8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058ce:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
801058d4:	83 f8 05             	cmp    $0x5,%eax
801058d7:	7f 25                	jg     801058fe <yield+0xdf>
    {
      ++(proc->priority);
801058d9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058df:	8b 90 94 00 00 00    	mov    0x94(%eax),%edx
801058e5:	83 c2 01             	add    $0x1,%edx
801058e8:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
      proc->budget = BUDGET;
801058ee:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058f4:	c7 80 98 00 00 00 e8 	movl   $0x3e8,0x98(%eax)
801058fb:	03 00 00 
    }
  }
  /*Project 4*/

  priority = proc->priority;
801058fe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105904:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
8010590a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  rc = addToStateListEnd(&ptable.pLists.ready[priority], proc);
8010590d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105913:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105916:	81 c2 cc 09 00 00    	add    $0x9cc,%edx
8010591c:	c1 e2 02             	shl    $0x2,%edx
8010591f:	81 c2 a0 49 11 80    	add    $0x801149a0,%edx
80105925:	83 c2 04             	add    $0x4,%edx
80105928:	83 ec 08             	sub    $0x8,%esp
8010592b:	50                   	push   %eax
8010592c:	52                   	push   %edx
8010592d:	e8 25 0c 00 00       	call   80106557 <addToStateListEnd>
80105932:	83 c4 10             	add    $0x10,%esp
80105935:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(rc == -1)
80105938:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
8010593c:	75 0d                	jne    8010594b <yield+0x12c>
    panic("Could not add to ready list.");
8010593e:	83 ec 0c             	sub    $0xc,%esp
80105941:	68 03 a8 10 80       	push   $0x8010a803
80105946:	e8 1b ac ff ff       	call   80100566 <panic>
#endif  

  sched();
8010594b:	e8 f0 fd ff ff       	call   80105740 <sched>
  release(&ptable.lock);
80105950:	83 ec 0c             	sub    $0xc,%esp
80105953:	68 a0 49 11 80       	push   $0x801149a0
80105958:	e8 11 11 00 00       	call   80106a6e <release>
8010595d:	83 c4 10             	add    $0x10,%esp
}
80105960:	90                   	nop
80105961:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105964:	c9                   	leave  
80105965:	c3                   	ret    

80105966 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80105966:	55                   	push   %ebp
80105967:	89 e5                	mov    %esp,%ebp
80105969:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
8010596c:	83 ec 0c             	sub    $0xc,%esp
8010596f:	68 a0 49 11 80       	push   $0x801149a0
80105974:	e8 f5 10 00 00       	call   80106a6e <release>
80105979:	83 c4 10             	add    $0x10,%esp

  if (first) {
8010597c:	a1 20 d0 10 80       	mov    0x8010d020,%eax
80105981:	85 c0                	test   %eax,%eax
80105983:	74 24                	je     801059a9 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80105985:	c7 05 20 d0 10 80 00 	movl   $0x0,0x8010d020
8010598c:	00 00 00 
    iinit(ROOTDEV);
8010598f:	83 ec 0c             	sub    $0xc,%esp
80105992:	6a 01                	push   $0x1
80105994:	e8 0c be ff ff       	call   801017a5 <iinit>
80105999:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
8010599c:	83 ec 0c             	sub    $0xc,%esp
8010599f:	6a 01                	push   $0x1
801059a1:	e8 28 dd ff ff       	call   801036ce <initlog>
801059a6:	83 c4 10             	add    $0x10,%esp
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
801059a9:	90                   	nop
801059aa:	c9                   	leave  
801059ab:	c3                   	ret    

801059ac <sleep>:
// Reacquires lock when awakened.
// 2016/12/28: ticklock removed from xv6. sleep() changed to
// accept a NULL lock to accommodate.
void
sleep(void *chan, struct spinlock *lk)
{
801059ac:	55                   	push   %ebp
801059ad:	89 e5                	mov    %esp,%ebp
801059af:	53                   	push   %ebx
801059b0:	83 ec 14             	sub    $0x14,%esp
  if(proc == 0)
801059b3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059b9:	85 c0                	test   %eax,%eax
801059bb:	75 0d                	jne    801059ca <sleep+0x1e>
    panic("sleep");
801059bd:	83 ec 0c             	sub    $0xc,%esp
801059c0:	68 20 a8 10 80       	push   $0x8010a820
801059c5:	e8 9c ab ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){
801059ca:	81 7d 0c a0 49 11 80 	cmpl   $0x801149a0,0xc(%ebp)
801059d1:	74 24                	je     801059f7 <sleep+0x4b>
    acquire(&ptable.lock);
801059d3:	83 ec 0c             	sub    $0xc,%esp
801059d6:	68 a0 49 11 80       	push   $0x801149a0
801059db:	e8 27 10 00 00       	call   80106a07 <acquire>
801059e0:	83 c4 10             	add    $0x10,%esp
    if (lk) release(lk);
801059e3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801059e7:	74 0e                	je     801059f7 <sleep+0x4b>
801059e9:	83 ec 0c             	sub    $0xc,%esp
801059ec:	ff 75 0c             	pushl  0xc(%ebp)
801059ef:	e8 7a 10 00 00       	call   80106a6e <release>
801059f4:	83 c4 10             	add    $0x10,%esp
  }

#ifdef CS333_P3P4
  int rc = removeFromStateList(&ptable.pLists.running, proc);
801059f7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059fd:	83 ec 08             	sub    $0x8,%esp
80105a00:	50                   	push   %eax
80105a01:	68 fc 70 11 80       	push   $0x801170fc
80105a06:	e8 7b 0a 00 00       	call   80106486 <removeFromStateList>
80105a0b:	83 c4 10             	add    $0x10,%esp
80105a0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(rc == -1)
80105a11:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
80105a15:	75 0d                	jne    80105a24 <sleep+0x78>
    panic("Could not remove process from running list.");
80105a17:	83 ec 0c             	sub    $0xc,%esp
80105a1a:	68 28 a8 10 80       	push   $0x8010a828
80105a1f:	e8 42 ab ff ff       	call   80100566 <panic>
  assertState(proc, RUNNING);
80105a24:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a2a:	83 ec 08             	sub    $0x8,%esp
80105a2d:	6a 04                	push   $0x4
80105a2f:	50                   	push   %eax
80105a30:	e8 01 0b 00 00       	call   80106536 <assertState>
80105a35:	83 c4 10             	add    $0x10,%esp
#endif
  // Go to sleep.
  proc->chan = chan;
80105a38:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a3e:	8b 55 08             	mov    0x8(%ebp),%edx
80105a41:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80105a44:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a4a:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

#ifdef CS333_P3P4
  /*Project 4*/
  proc->budget = proc->budget - (ticks - proc->cpu_ticks_in);
80105a51:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a57:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105a5e:	8b 92 98 00 00 00    	mov    0x98(%edx),%edx
80105a64:	89 d3                	mov    %edx,%ebx
80105a66:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105a6d:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
80105a73:	8b 15 20 79 11 80    	mov    0x80117920,%edx
80105a79:	29 d1                	sub    %edx,%ecx
80105a7b:	89 ca                	mov    %ecx,%edx
80105a7d:	01 da                	add    %ebx,%edx
80105a7f:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)
  if(proc->budget <= 0)
80105a85:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a8b:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
80105a91:	85 c0                	test   %eax,%eax
80105a93:	7f 36                	jg     80105acb <sleep+0x11f>
  {
    if(proc->priority < MAX)
80105a95:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a9b:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80105aa1:	83 f8 05             	cmp    $0x5,%eax
80105aa4:	7f 25                	jg     80105acb <sleep+0x11f>
    {
      ++(proc->priority);
80105aa6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105aac:	8b 90 94 00 00 00    	mov    0x94(%eax),%edx
80105ab2:	83 c2 01             	add    $0x1,%edx
80105ab5:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
      proc->budget = BUDGET;
80105abb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ac1:	c7 80 98 00 00 00 e8 	movl   $0x3e8,0x98(%eax)
80105ac8:	03 00 00 
    }
  }
  /*Project 4*/
  rc = addToStateListHead(&ptable.pLists.sleep, proc);
80105acb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ad1:	83 ec 08             	sub    $0x8,%esp
80105ad4:	50                   	push   %eax
80105ad5:	68 f4 70 11 80       	push   $0x801170f4
80105ada:	e8 f3 0a 00 00       	call   801065d2 <addToStateListHead>
80105adf:	83 c4 10             	add    $0x10,%esp
80105ae2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(rc == -1)
80105ae5:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
80105ae9:	75 0d                	jne    80105af8 <sleep+0x14c>
    panic("Could not add to sleep list.");
80105aeb:	83 ec 0c             	sub    $0xc,%esp
80105aee:	68 54 a8 10 80       	push   $0x8010a854
80105af3:	e8 6e aa ff ff       	call   80100566 <panic>
#endif
  sched();
80105af8:	e8 43 fc ff ff       	call   80105740 <sched>

  // Tidy up.
  proc->chan = 0;
80105afd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b03:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){ 
80105b0a:	81 7d 0c a0 49 11 80 	cmpl   $0x801149a0,0xc(%ebp)
80105b11:	74 24                	je     80105b37 <sleep+0x18b>
    release(&ptable.lock);
80105b13:	83 ec 0c             	sub    $0xc,%esp
80105b16:	68 a0 49 11 80       	push   $0x801149a0
80105b1b:	e8 4e 0f 00 00       	call   80106a6e <release>
80105b20:	83 c4 10             	add    $0x10,%esp
    if (lk) acquire(lk);
80105b23:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105b27:	74 0e                	je     80105b37 <sleep+0x18b>
80105b29:	83 ec 0c             	sub    $0xc,%esp
80105b2c:	ff 75 0c             	pushl  0xc(%ebp)
80105b2f:	e8 d3 0e 00 00       	call   80106a07 <acquire>
80105b34:	83 c4 10             	add    $0x10,%esp
  }
}
80105b37:	90                   	nop
80105b38:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105b3b:	c9                   	leave  
80105b3c:	c3                   	ret    

80105b3d <wakeup1>:
      p->state = RUNNABLE;
}
#else
static void
wakeup1(void *chan) //For Project 3
{
80105b3d:	55                   	push   %ebp
80105b3e:	89 e5                	mov    %esp,%ebp
80105b40:	83 ec 18             	sub    $0x18,%esp
  struct proc *current;
  int rc;
  int priority;

  current = ptable.pLists.sleep;
80105b43:	a1 f4 70 11 80       	mov    0x801170f4,%eax
80105b48:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while(current != 0)
80105b4b:	e9 a2 00 00 00       	jmp    80105bf2 <wakeup1+0xb5>
  {
    if(current->chan == chan)
80105b50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b53:	8b 40 20             	mov    0x20(%eax),%eax
80105b56:	3b 45 08             	cmp    0x8(%ebp),%eax
80105b59:	0f 85 87 00 00 00    	jne    80105be6 <wakeup1+0xa9>
    {
       rc = removeFromStateList(&ptable.pLists.sleep, current);
80105b5f:	83 ec 08             	sub    $0x8,%esp
80105b62:	ff 75 f4             	pushl  -0xc(%ebp)
80105b65:	68 f4 70 11 80       	push   $0x801170f4
80105b6a:	e8 17 09 00 00       	call   80106486 <removeFromStateList>
80105b6f:	83 c4 10             	add    $0x10,%esp
80105b72:	89 45 f0             	mov    %eax,-0x10(%ebp)
       if(rc == -1)
80105b75:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80105b79:	75 0d                	jne    80105b88 <wakeup1+0x4b>
         panic("Could not remove process from sleep list.");
80105b7b:	83 ec 0c             	sub    $0xc,%esp
80105b7e:	68 74 a8 10 80       	push   $0x8010a874
80105b83:	e8 de a9 ff ff       	call   80100566 <panic>
       assertState(current, SLEEPING);
80105b88:	83 ec 08             	sub    $0x8,%esp
80105b8b:	6a 02                	push   $0x2
80105b8d:	ff 75 f4             	pushl  -0xc(%ebp)
80105b90:	e8 a1 09 00 00       	call   80106536 <assertState>
80105b95:	83 c4 10             	add    $0x10,%esp

       current->state = RUNNABLE;
80105b98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b9b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
       priority = current->priority;
80105ba2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ba5:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80105bab:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
       rc = addToStateListEnd(&ptable.pLists.ready[priority], current);
80105bae:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105bb1:	05 cc 09 00 00       	add    $0x9cc,%eax
80105bb6:	c1 e0 02             	shl    $0x2,%eax
80105bb9:	05 a0 49 11 80       	add    $0x801149a0,%eax
80105bbe:	83 c0 04             	add    $0x4,%eax
80105bc1:	83 ec 08             	sub    $0x8,%esp
80105bc4:	ff 75 f4             	pushl  -0xc(%ebp)
80105bc7:	50                   	push   %eax
80105bc8:	e8 8a 09 00 00       	call   80106557 <addToStateListEnd>
80105bcd:	83 c4 10             	add    $0x10,%esp
80105bd0:	89 45 f0             	mov    %eax,-0x10(%ebp)
       if(rc == -1)
80105bd3:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80105bd7:	75 0d                	jne    80105be6 <wakeup1+0xa9>
         panic("Could not add process to ready list."); 
80105bd9:	83 ec 0c             	sub    $0xc,%esp
80105bdc:	68 d8 a6 10 80       	push   $0x8010a6d8
80105be1:	e8 80 a9 ff ff       	call   80100566 <panic>
    }
    current = current->next;
80105be6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105be9:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105bef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  int rc;
  int priority;

  current = ptable.pLists.sleep;

  while(current != 0)
80105bf2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bf6:	0f 85 54 ff ff ff    	jne    80105b50 <wakeup1+0x13>
       if(rc == -1)
         panic("Could not add process to ready list."); 
    }
    current = current->next;
  }  
}
80105bfc:	90                   	nop
80105bfd:	c9                   	leave  
80105bfe:	c3                   	ret    

80105bff <wakeup>:
#endif

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80105bff:	55                   	push   %ebp
80105c00:	89 e5                	mov    %esp,%ebp
80105c02:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80105c05:	83 ec 0c             	sub    $0xc,%esp
80105c08:	68 a0 49 11 80       	push   $0x801149a0
80105c0d:	e8 f5 0d 00 00       	call   80106a07 <acquire>
80105c12:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80105c15:	83 ec 0c             	sub    $0xc,%esp
80105c18:	ff 75 08             	pushl  0x8(%ebp)
80105c1b:	e8 1d ff ff ff       	call   80105b3d <wakeup1>
80105c20:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80105c23:	83 ec 0c             	sub    $0xc,%esp
80105c26:	68 a0 49 11 80       	push   $0x801149a0
80105c2b:	e8 3e 0e 00 00       	call   80106a6e <release>
80105c30:	83 c4 10             	add    $0x10,%esp
}
80105c33:	90                   	nop
80105c34:	c9                   	leave  
80105c35:	c3                   	ret    

80105c36 <kill>:
}

#else
int
kill(int pid) //Project 3
{
80105c36:	55                   	push   %ebp
80105c37:	89 e5                	mov    %esp,%ebp
80105c39:	83 ec 18             	sub    $0x18,%esp
  //struct proc *p;
  struct proc *current;
  int rc;

  acquire(&ptable.lock);
80105c3c:	83 ec 0c             	sub    $0xc,%esp
80105c3f:	68 a0 49 11 80       	push   $0x801149a0
80105c44:	e8 be 0d 00 00       	call   80106a07 <acquire>
80105c49:	83 c4 10             	add    $0x10,%esp
  
  current = ptable.pLists.running;
80105c4c:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80105c51:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while(current != 0)
80105c54:	eb 66                	jmp    80105cbc <kill+0x86>
  {
    if(current->pid == pid)
80105c56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c59:	8b 50 10             	mov    0x10(%eax),%edx
80105c5c:	8b 45 08             	mov    0x8(%ebp),%eax
80105c5f:	39 c2                	cmp    %eax,%edx
80105c61:	75 4d                	jne    80105cb0 <kill+0x7a>
    {
      current->killed = 1;
80105c63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c66:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      rc = removeFromStateList(&ptable.pLists.running, current);
80105c6d:	83 ec 08             	sub    $0x8,%esp
80105c70:	ff 75 f4             	pushl  -0xc(%ebp)
80105c73:	68 fc 70 11 80       	push   $0x801170fc
80105c78:	e8 09 08 00 00       	call   80106486 <removeFromStateList>
80105c7d:	83 c4 10             	add    $0x10,%esp
80105c80:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(rc == -1)
80105c83:	83 7d ec ff          	cmpl   $0xffffffff,-0x14(%ebp)
80105c87:	75 0d                	jne    80105c96 <kill+0x60>
        panic("Could not remove from running list.");
80105c89:	83 ec 0c             	sub    $0xc,%esp
80105c8c:	68 0c a7 10 80       	push   $0x8010a70c
80105c91:	e8 d0 a8 ff ff       	call   80100566 <panic>
      release(&ptable.lock);
80105c96:	83 ec 0c             	sub    $0xc,%esp
80105c99:	68 a0 49 11 80       	push   $0x801149a0
80105c9e:	e8 cb 0d 00 00       	call   80106a6e <release>
80105ca3:	83 c4 10             	add    $0x10,%esp
      return 0;
80105ca6:	b8 00 00 00 00       	mov    $0x0,%eax
80105cab:	e9 1f 02 00 00       	jmp    80105ecf <kill+0x299>
    } 
    current = current->next; 
80105cb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cb3:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105cb9:	89 45 f4             	mov    %eax,-0xc(%ebp)

  acquire(&ptable.lock);
  
  current = ptable.pLists.running;

  while(current != 0)
80105cbc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105cc0:	75 94                	jne    80105c56 <kill+0x20>
      return 0;
    } 
    current = current->next; 
  }

  current = ptable.pLists.sleep;
80105cc2:	a1 f4 70 11 80       	mov    0x801170f4,%eax
80105cc7:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while(current != 0)
80105cca:	eb 66                	jmp    80105d32 <kill+0xfc>
  {
    if(current->pid == pid)
80105ccc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ccf:	8b 50 10             	mov    0x10(%eax),%edx
80105cd2:	8b 45 08             	mov    0x8(%ebp),%eax
80105cd5:	39 c2                	cmp    %eax,%edx
80105cd7:	75 4d                	jne    80105d26 <kill+0xf0>
    {
      current->killed = 1;
80105cd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cdc:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      rc = removeFromStateList(&ptable.pLists.sleep, current);
80105ce3:	83 ec 08             	sub    $0x8,%esp
80105ce6:	ff 75 f4             	pushl  -0xc(%ebp)
80105ce9:	68 f4 70 11 80       	push   $0x801170f4
80105cee:	e8 93 07 00 00       	call   80106486 <removeFromStateList>
80105cf3:	83 c4 10             	add    $0x10,%esp
80105cf6:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(rc == -1)
80105cf9:	83 7d ec ff          	cmpl   $0xffffffff,-0x14(%ebp)
80105cfd:	75 0d                	jne    80105d0c <kill+0xd6>
        panic("Could not remove from sleep list.");
80105cff:	83 ec 0c             	sub    $0xc,%esp
80105d02:	68 a0 a8 10 80       	push   $0x8010a8a0
80105d07:	e8 5a a8 ff ff       	call   80100566 <panic>
      release(&ptable.lock);
80105d0c:	83 ec 0c             	sub    $0xc,%esp
80105d0f:	68 a0 49 11 80       	push   $0x801149a0
80105d14:	e8 55 0d 00 00       	call   80106a6e <release>
80105d19:	83 c4 10             	add    $0x10,%esp
      return 0;
80105d1c:	b8 00 00 00 00       	mov    $0x0,%eax
80105d21:	e9 a9 01 00 00       	jmp    80105ecf <kill+0x299>
    }
    current = current->next; 
80105d26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d29:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105d2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    current = current->next; 
  }

  current = ptable.pLists.sleep;

  while(current != 0)
80105d32:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d36:	75 94                	jne    80105ccc <kill+0x96>
      return 0;
    }
    current = current->next; 
  }

  current = ptable.pLists.zombie;
80105d38:	a1 f8 70 11 80       	mov    0x801170f8,%eax
80105d3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  while(current != 0)
80105d40:	eb 66                	jmp    80105da8 <kill+0x172>
  {
    if(current->pid == pid)
80105d42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d45:	8b 50 10             	mov    0x10(%eax),%edx
80105d48:	8b 45 08             	mov    0x8(%ebp),%eax
80105d4b:	39 c2                	cmp    %eax,%edx
80105d4d:	75 4d                	jne    80105d9c <kill+0x166>
    {
      current->killed = 1;
80105d4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d52:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      rc = removeFromStateList(&ptable.pLists.zombie, current);
80105d59:	83 ec 08             	sub    $0x8,%esp
80105d5c:	ff 75 f4             	pushl  -0xc(%ebp)
80105d5f:	68 f8 70 11 80       	push   $0x801170f8
80105d64:	e8 1d 07 00 00       	call   80106486 <removeFromStateList>
80105d69:	83 c4 10             	add    $0x10,%esp
80105d6c:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(rc == -1)
80105d6f:	83 7d ec ff          	cmpl   $0xffffffff,-0x14(%ebp)
80105d73:	75 0d                	jne    80105d82 <kill+0x14c>
        panic("Could not remove from zombie list.");
80105d75:	83 ec 0c             	sub    $0xc,%esp
80105d78:	68 5c a7 10 80       	push   $0x8010a75c
80105d7d:	e8 e4 a7 ff ff       	call   80100566 <panic>
      release(&ptable.lock);
80105d82:	83 ec 0c             	sub    $0xc,%esp
80105d85:	68 a0 49 11 80       	push   $0x801149a0
80105d8a:	e8 df 0c 00 00       	call   80106a6e <release>
80105d8f:	83 c4 10             	add    $0x10,%esp
      return 0;
80105d92:	b8 00 00 00 00       	mov    $0x0,%eax
80105d97:	e9 33 01 00 00       	jmp    80105ecf <kill+0x299>
    }
    current = current->next; 
80105d9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d9f:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105da5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    current = current->next; 
  }

  current = ptable.pLists.zombie;
  
  while(current != 0)
80105da8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105dac:	75 94                	jne    80105d42 <kill+0x10c>
      return 0;
    }
    current = current->next; 
  }

  current = ptable.pLists.embryo;
80105dae:	a1 00 71 11 80       	mov    0x80117100,%eax
80105db3:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while(current != 0)
80105db6:	eb 66                	jmp    80105e1e <kill+0x1e8>
  {
    if(current->pid == pid)
80105db8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dbb:	8b 50 10             	mov    0x10(%eax),%edx
80105dbe:	8b 45 08             	mov    0x8(%ebp),%eax
80105dc1:	39 c2                	cmp    %eax,%edx
80105dc3:	75 4d                	jne    80105e12 <kill+0x1dc>
    {
      current->killed = 1;
80105dc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dc8:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      rc = removeFromStateList(&ptable.pLists.embryo, current);
80105dcf:	83 ec 08             	sub    $0x8,%esp
80105dd2:	ff 75 f4             	pushl  -0xc(%ebp)
80105dd5:	68 00 71 11 80       	push   $0x80117100
80105dda:	e8 a7 06 00 00       	call   80106486 <removeFromStateList>
80105ddf:	83 c4 10             	add    $0x10,%esp
80105de2:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(rc == -1)
80105de5:	83 7d ec ff          	cmpl   $0xffffffff,-0x14(%ebp)
80105de9:	75 0d                	jne    80105df8 <kill+0x1c2>
        panic("Could not remove from embryo list.");
80105deb:	83 ec 0c             	sub    $0xc,%esp
80105dee:	68 d8 a5 10 80       	push   $0x8010a5d8
80105df3:	e8 6e a7 ff ff       	call   80100566 <panic>
      release(&ptable.lock);
80105df8:	83 ec 0c             	sub    $0xc,%esp
80105dfb:	68 a0 49 11 80       	push   $0x801149a0
80105e00:	e8 69 0c 00 00       	call   80106a6e <release>
80105e05:	83 c4 10             	add    $0x10,%esp
      return 0;
80105e08:	b8 00 00 00 00       	mov    $0x0,%eax
80105e0d:	e9 bd 00 00 00       	jmp    80105ecf <kill+0x299>
    }
    current = current->next; 
80105e12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e15:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105e1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    current = current->next; 
  }

  current = ptable.pLists.embryo;

  while(current != 0)
80105e1e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e22:	75 94                	jne    80105db8 <kill+0x182>
      return 0;
    }
    current = current->next; 
  }

  for(int i = 0; i < MAX; i++)
80105e24:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80105e2b:	e9 80 00 00 00       	jmp    80105eb0 <kill+0x27a>
  {
    current = ptable.pLists.ready[i];
80105e30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e33:	05 cc 09 00 00       	add    $0x9cc,%eax
80105e38:	8b 04 85 a4 49 11 80 	mov    -0x7feeb65c(,%eax,4),%eax
80105e3f:	89 45 f4             	mov    %eax,-0xc(%ebp)

    while(current != 0)
80105e42:	eb 62                	jmp    80105ea6 <kill+0x270>
    {
      if(current->pid == pid)
80105e44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e47:	8b 50 10             	mov    0x10(%eax),%edx
80105e4a:	8b 45 08             	mov    0x8(%ebp),%eax
80105e4d:	39 c2                	cmp    %eax,%edx
80105e4f:	75 49                	jne    80105e9a <kill+0x264>
      {
        current->killed = 1;
80105e51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e54:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
        rc = removeFromStateList(&ptable.pLists.ready[i], current);
80105e5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e5e:	05 cc 09 00 00       	add    $0x9cc,%eax
80105e63:	c1 e0 02             	shl    $0x2,%eax
80105e66:	05 a0 49 11 80       	add    $0x801149a0,%eax
80105e6b:	83 c0 04             	add    $0x4,%eax
80105e6e:	83 ec 08             	sub    $0x8,%esp
80105e71:	ff 75 f4             	pushl  -0xc(%ebp)
80105e74:	50                   	push   %eax
80105e75:	e8 0c 06 00 00       	call   80106486 <removeFromStateList>
80105e7a:	83 c4 10             	add    $0x10,%esp
80105e7d:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if(rc == -1)
80105e80:	83 7d ec ff          	cmpl   $0xffffffff,-0x14(%ebp)
80105e84:	75 0d                	jne    80105e93 <kill+0x25d>
          panic("Could not remove from ready list.");
80105e86:	83 ec 0c             	sub    $0xc,%esp
80105e89:	68 80 a7 10 80       	push   $0x8010a780
80105e8e:	e8 d3 a6 ff ff       	call   80100566 <panic>
        return 0;
80105e93:	b8 00 00 00 00       	mov    $0x0,%eax
80105e98:	eb 35                	jmp    80105ecf <kill+0x299>
      }
      current = current->next; 
80105e9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e9d:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105ea3:	89 45 f4             	mov    %eax,-0xc(%ebp)

  for(int i = 0; i < MAX; i++)
  {
    current = ptable.pLists.ready[i];

    while(current != 0)
80105ea6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105eaa:	75 98                	jne    80105e44 <kill+0x20e>
      return 0;
    }
    current = current->next; 
  }

  for(int i = 0; i < MAX; i++)
80105eac:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80105eb0:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
80105eb4:	0f 8e 76 ff ff ff    	jle    80105e30 <kill+0x1fa>
      }
      current = current->next; 
    }
  }
 
  release(&ptable.lock);
80105eba:	83 ec 0c             	sub    $0xc,%esp
80105ebd:	68 a0 49 11 80       	push   $0x801149a0
80105ec2:	e8 a7 0b 00 00       	call   80106a6e <release>
80105ec7:	83 c4 10             	add    $0x10,%esp
  return -1;
80105eca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105ecf:	c9                   	leave  
80105ed0:	c3                   	ret    

80105ed1 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80105ed1:	55                   	push   %ebp
80105ed2:	89 e5                	mov    %esp,%ebp
80105ed4:	57                   	push   %edi
80105ed5:	56                   	push   %esi
80105ed6:	53                   	push   %ebx
80105ed7:	83 ec 6c             	sub    $0x6c,%esp
#ifdef CS333_P1
  cprintf("PID     State    Name    Elapsed (s)     PCs\n");
#endif
*/
#ifdef CS333_P2 
  cprintf("\nPID\t Name\t\t Priority\t UID\t GID\t PPID\t Elapsed\t CPU\t State\t Size\t PCs\n");
80105eda:	83 ec 0c             	sub    $0xc,%esp
80105edd:	68 ec a8 10 80       	push   $0x8010a8ec
80105ee2:	e8 df a4 ff ff       	call   801003c6 <cprintf>
80105ee7:	83 c4 10             	add    $0x10,%esp
#endif

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105eea:	c7 45 e0 d4 49 11 80 	movl   $0x801149d4,-0x20(%ebp)
80105ef1:	e9 81 01 00 00       	jmp    80106077 <procdump+0x1a6>
    if(p->state == UNUSED)
80105ef6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105ef9:	8b 40 0c             	mov    0xc(%eax),%eax
80105efc:	85 c0                	test   %eax,%eax
80105efe:	0f 84 6b 01 00 00    	je     8010606f <procdump+0x19e>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105f04:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105f07:	8b 40 0c             	mov    0xc(%eax),%eax
80105f0a:	83 f8 05             	cmp    $0x5,%eax
80105f0d:	77 23                	ja     80105f32 <procdump+0x61>
80105f0f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105f12:	8b 40 0c             	mov    0xc(%eax),%eax
80105f15:	8b 04 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%eax
80105f1c:	85 c0                	test   %eax,%eax
80105f1e:	74 12                	je     80105f32 <procdump+0x61>
      state = states[p->state];
80105f20:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105f23:	8b 40 0c             	mov    0xc(%eax),%eax
80105f26:	8b 04 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%eax
80105f2d:	89 45 dc             	mov    %eax,-0x24(%ebp)
80105f30:	eb 07                	jmp    80105f39 <procdump+0x68>
    else
      state = "???";
80105f32:	c7 45 dc 33 a9 10 80 	movl   $0x8010a933,-0x24(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
#endif
*/

#ifdef CS333_P2
  uint elapsed = ticks - p->start_ticks;
80105f39:	8b 15 20 79 11 80    	mov    0x80117920,%edx
80105f3f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105f42:	8b 40 7c             	mov    0x7c(%eax),%eax
80105f45:	29 c2                	sub    %eax,%edx
80105f47:	89 d0                	mov    %edx,%eax
80105f49:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint sec = calcsec(elapsed);
80105f4c:	83 ec 0c             	sub    $0xc,%esp
80105f4f:	ff 75 d8             	pushl  -0x28(%ebp)
80105f52:	e8 36 01 00 00       	call   8010608d <calcsec>
80105f57:	83 c4 10             	add    $0x10,%esp
80105f5a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  uint mili = calcmili(elapsed);
80105f5d:	83 ec 0c             	sub    $0xc,%esp
80105f60:	ff 75 d8             	pushl  -0x28(%ebp)
80105f63:	e8 42 01 00 00       	call   801060aa <calcmili>
80105f68:	83 c4 10             	add    $0x10,%esp
80105f6b:	89 45 d0             	mov    %eax,-0x30(%ebp)

  uint cpu_sec = calcsec(p->cpu_ticks_total);
80105f6e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105f71:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80105f77:	83 ec 0c             	sub    $0xc,%esp
80105f7a:	50                   	push   %eax
80105f7b:	e8 0d 01 00 00       	call   8010608d <calcsec>
80105f80:	83 c4 10             	add    $0x10,%esp
80105f83:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint cpu_mili = calcmili(p->cpu_ticks_total);
80105f86:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105f89:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80105f8f:	83 ec 0c             	sub    $0xc,%esp
80105f92:	50                   	push   %eax
80105f93:	e8 12 01 00 00       	call   801060aa <calcmili>
80105f98:	83 c4 10             	add    $0x10,%esp
80105f9b:	89 45 c8             	mov    %eax,-0x38(%ebp)

  cprintf("%d\t %s\t\t %d\t\t %d\t %d\t %d\t %d.%d\t\t %d.%d\t %s\t %d\t", p->pid, p->name, p->priority, p->uid, p->gid, p->parent->pid, sec, mili, cpu_sec, cpu_mili, state, p->sz);
80105f9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105fa1:	8b 38                	mov    (%eax),%edi
80105fa3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105fa6:	8b 40 14             	mov    0x14(%eax),%eax
80105fa9:	8b 70 10             	mov    0x10(%eax),%esi
80105fac:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105faf:	8b 98 84 00 00 00    	mov    0x84(%eax),%ebx
80105fb5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105fb8:	8b 88 80 00 00 00    	mov    0x80(%eax),%ecx
80105fbe:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105fc1:	8b 90 94 00 00 00    	mov    0x94(%eax),%edx
80105fc7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105fca:	83 c0 6c             	add    $0x6c,%eax
80105fcd:	89 45 94             	mov    %eax,-0x6c(%ebp)
80105fd0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105fd3:	8b 40 10             	mov    0x10(%eax),%eax
80105fd6:	83 ec 0c             	sub    $0xc,%esp
80105fd9:	57                   	push   %edi
80105fda:	ff 75 dc             	pushl  -0x24(%ebp)
80105fdd:	ff 75 c8             	pushl  -0x38(%ebp)
80105fe0:	ff 75 cc             	pushl  -0x34(%ebp)
80105fe3:	ff 75 d0             	pushl  -0x30(%ebp)
80105fe6:	ff 75 d4             	pushl  -0x2c(%ebp)
80105fe9:	56                   	push   %esi
80105fea:	53                   	push   %ebx
80105feb:	51                   	push   %ecx
80105fec:	52                   	push   %edx
80105fed:	ff 75 94             	pushl  -0x6c(%ebp)
80105ff0:	50                   	push   %eax
80105ff1:	68 38 a9 10 80       	push   $0x8010a938
80105ff6:	e8 cb a3 ff ff       	call   801003c6 <cprintf>
80105ffb:	83 c4 40             	add    $0x40,%esp
#endif

    if(p->state == SLEEPING){
80105ffe:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106001:	8b 40 0c             	mov    0xc(%eax),%eax
80106004:	83 f8 02             	cmp    $0x2,%eax
80106007:	75 54                	jne    8010605d <procdump+0x18c>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80106009:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010600c:	8b 40 1c             	mov    0x1c(%eax),%eax
8010600f:	8b 40 0c             	mov    0xc(%eax),%eax
80106012:	83 c0 08             	add    $0x8,%eax
80106015:	89 c2                	mov    %eax,%edx
80106017:	83 ec 08             	sub    $0x8,%esp
8010601a:	8d 45 a0             	lea    -0x60(%ebp),%eax
8010601d:	50                   	push   %eax
8010601e:	52                   	push   %edx
8010601f:	e8 9c 0a 00 00       	call   80106ac0 <getcallerpcs>
80106024:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80106027:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010602e:	eb 1c                	jmp    8010604c <procdump+0x17b>
        cprintf(" %p", pc[i]);
80106030:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106033:	8b 44 85 a0          	mov    -0x60(%ebp,%eax,4),%eax
80106037:	83 ec 08             	sub    $0x8,%esp
8010603a:	50                   	push   %eax
8010603b:	68 69 a9 10 80       	push   $0x8010a969
80106040:	e8 81 a3 ff ff       	call   801003c6 <cprintf>
80106045:	83 c4 10             	add    $0x10,%esp
  cprintf("%d\t %s\t\t %d\t\t %d\t %d\t %d\t %d.%d\t\t %d.%d\t %s\t %d\t", p->pid, p->name, p->priority, p->uid, p->gid, p->parent->pid, sec, mili, cpu_sec, cpu_mili, state, p->sz);
#endif

    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80106048:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010604c:	83 7d e4 09          	cmpl   $0x9,-0x1c(%ebp)
80106050:	7f 0b                	jg     8010605d <procdump+0x18c>
80106052:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106055:	8b 44 85 a0          	mov    -0x60(%ebp,%eax,4),%eax
80106059:	85 c0                	test   %eax,%eax
8010605b:	75 d3                	jne    80106030 <procdump+0x15f>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
8010605d:	83 ec 0c             	sub    $0xc,%esp
80106060:	68 6d a9 10 80       	push   $0x8010a96d
80106065:	e8 5c a3 ff ff       	call   801003c6 <cprintf>
8010606a:	83 c4 10             	add    $0x10,%esp
8010606d:	eb 01                	jmp    80106070 <procdump+0x19f>
  cprintf("\nPID\t Name\t\t Priority\t UID\t GID\t PPID\t Elapsed\t CPU\t State\t Size\t PCs\n");
#endif

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
8010606f:	90                   	nop
*/
#ifdef CS333_P2 
  cprintf("\nPID\t Name\t\t Priority\t UID\t GID\t PPID\t Elapsed\t CPU\t State\t Size\t PCs\n");
#endif

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80106070:	81 45 e0 9c 00 00 00 	addl   $0x9c,-0x20(%ebp)
80106077:	81 7d e0 d4 70 11 80 	cmpl   $0x801170d4,-0x20(%ebp)
8010607e:	0f 82 72 fe ff ff    	jb     80105ef6 <procdump+0x25>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80106084:	90                   	nop
80106085:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106088:	5b                   	pop    %ebx
80106089:	5e                   	pop    %esi
8010608a:	5f                   	pop    %edi
8010608b:	5d                   	pop    %ebp
8010608c:	c3                   	ret    

8010608d <calcsec>:
#ifdef CS333_P1
//procdump's helper function
//calculating the seconds and miliseconds since a process has ran
uint
calcsec(uint num)
{
8010608d:	55                   	push   %ebp
8010608e:	89 e5                	mov    %esp,%ebp
80106090:	83 ec 10             	sub    $0x10,%esp
  uint sec = num / 1000;
80106093:	8b 45 08             	mov    0x8(%ebp),%eax
80106096:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
8010609b:	f7 e2                	mul    %edx
8010609d:	89 d0                	mov    %edx,%eax
8010609f:	c1 e8 06             	shr    $0x6,%eax
801060a2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return sec;
801060a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801060a8:	c9                   	leave  
801060a9:	c3                   	ret    

801060aa <calcmili>:

uint
calcmili(uint num)
{
801060aa:	55                   	push   %ebp
801060ab:	89 e5                	mov    %esp,%ebp
801060ad:	83 ec 10             	sub    $0x10,%esp
  uint mili = num % 1000;
801060b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
801060b3:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
801060b8:	89 c8                	mov    %ecx,%eax
801060ba:	f7 e2                	mul    %edx
801060bc:	89 d0                	mov    %edx,%eax
801060be:	c1 e8 06             	shr    $0x6,%eax
801060c1:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
801060c7:	29 c1                	sub    %eax,%ecx
801060c9:	89 c8                	mov    %ecx,%eax
801060cb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return mili;
801060ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801060d1:	c9                   	leave  
801060d2:	c3                   	ret    

801060d3 <getprocs>:
#endif

#ifdef CS333_P2
int
getprocs(uint max, struct uproc *table)
{
801060d3:	55                   	push   %ebp
801060d4:	89 e5                	mov    %esp,%ebp
801060d6:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int index = 0;
801060d9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

  acquire(&ptable.lock);
801060e0:	83 ec 0c             	sub    $0xc,%esp
801060e3:	68 a0 49 11 80       	push   $0x801149a0
801060e8:	e8 1a 09 00 00       	call   80106a07 <acquire>
801060ed:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC] && index < max; p++)
801060f0:	c7 45 f4 d4 49 11 80 	movl   $0x801149d4,-0xc(%ebp)
801060f7:	e9 e6 01 00 00       	jmp    801062e2 <getprocs+0x20f>
  {
    if(p->state != EMBRYO && p->state != UNUSED)
801060fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060ff:	8b 40 0c             	mov    0xc(%eax),%eax
80106102:	83 f8 01             	cmp    $0x1,%eax
80106105:	0f 84 d0 01 00 00    	je     801062db <getprocs+0x208>
8010610b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010610e:	8b 40 0c             	mov    0xc(%eax),%eax
80106111:	85 c0                	test   %eax,%eax
80106113:	0f 84 c2 01 00 00    	je     801062db <getprocs+0x208>
    {
      table[index].pid = p->pid;
80106119:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010611c:	89 d0                	mov    %edx,%eax
8010611e:	01 c0                	add    %eax,%eax
80106120:	01 d0                	add    %edx,%eax
80106122:	c1 e0 05             	shl    $0x5,%eax
80106125:	89 c2                	mov    %eax,%edx
80106127:	8b 45 0c             	mov    0xc(%ebp),%eax
8010612a:	01 c2                	add    %eax,%edx
8010612c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010612f:	8b 40 10             	mov    0x10(%eax),%eax
80106132:	89 02                	mov    %eax,(%edx)
      table[index].uid = p->uid;
80106134:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106137:	89 d0                	mov    %edx,%eax
80106139:	01 c0                	add    %eax,%eax
8010613b:	01 d0                	add    %edx,%eax
8010613d:	c1 e0 05             	shl    $0x5,%eax
80106140:	89 c2                	mov    %eax,%edx
80106142:	8b 45 0c             	mov    0xc(%ebp),%eax
80106145:	01 c2                	add    %eax,%edx
80106147:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010614a:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106150:	89 42 04             	mov    %eax,0x4(%edx)
      table[index].gid = p->gid;
80106153:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106156:	89 d0                	mov    %edx,%eax
80106158:	01 c0                	add    %eax,%eax
8010615a:	01 d0                	add    %edx,%eax
8010615c:	c1 e0 05             	shl    $0x5,%eax
8010615f:	89 c2                	mov    %eax,%edx
80106161:	8b 45 0c             	mov    0xc(%ebp),%eax
80106164:	01 c2                	add    %eax,%edx
80106166:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106169:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
8010616f:	89 42 08             	mov    %eax,0x8(%edx)
      table[index].priority = p->priority;
80106172:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106175:	89 d0                	mov    %edx,%eax
80106177:	01 c0                	add    %eax,%eax
80106179:	01 d0                	add    %edx,%eax
8010617b:	c1 e0 05             	shl    $0x5,%eax
8010617e:	89 c2                	mov    %eax,%edx
80106180:	8b 45 0c             	mov    0xc(%ebp),%eax
80106183:	01 c2                	add    %eax,%edx
80106185:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106188:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
8010618e:	89 42 5c             	mov    %eax,0x5c(%edx)
      table[index].ppid = p->parent->pid;
80106191:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106194:	89 d0                	mov    %edx,%eax
80106196:	01 c0                	add    %eax,%eax
80106198:	01 d0                	add    %edx,%eax
8010619a:	c1 e0 05             	shl    $0x5,%eax
8010619d:	89 c2                	mov    %eax,%edx
8010619f:	8b 45 0c             	mov    0xc(%ebp),%eax
801061a2:	01 c2                	add    %eax,%edx
801061a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061a7:	8b 40 14             	mov    0x14(%eax),%eax
801061aa:	8b 40 10             	mov    0x10(%eax),%eax
801061ad:	89 42 0c             	mov    %eax,0xc(%edx)
      table[index].elapsed_ticks = ticks - p->start_ticks;
801061b0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801061b3:	89 d0                	mov    %edx,%eax
801061b5:	01 c0                	add    %eax,%eax
801061b7:	01 d0                	add    %edx,%eax
801061b9:	c1 e0 05             	shl    $0x5,%eax
801061bc:	89 c2                	mov    %eax,%edx
801061be:	8b 45 0c             	mov    0xc(%ebp),%eax
801061c1:	01 c2                	add    %eax,%edx
801061c3:	8b 0d 20 79 11 80    	mov    0x80117920,%ecx
801061c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061cc:	8b 40 7c             	mov    0x7c(%eax),%eax
801061cf:	29 c1                	sub    %eax,%ecx
801061d1:	89 c8                	mov    %ecx,%eax
801061d3:	89 42 10             	mov    %eax,0x10(%edx)
      table[index].CPU_total_ticks = p->cpu_ticks_total;
801061d6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801061d9:	89 d0                	mov    %edx,%eax
801061db:	01 c0                	add    %eax,%eax
801061dd:	01 d0                	add    %edx,%eax
801061df:	c1 e0 05             	shl    $0x5,%eax
801061e2:	89 c2                	mov    %eax,%edx
801061e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801061e7:	01 c2                	add    %eax,%edx
801061e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061ec:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
801061f2:	89 42 14             	mov    %eax,0x14(%edx)
      table[index].size = p->sz;
801061f5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801061f8:	89 d0                	mov    %edx,%eax
801061fa:	01 c0                	add    %eax,%eax
801061fc:	01 d0                	add    %edx,%eax
801061fe:	c1 e0 05             	shl    $0x5,%eax
80106201:	89 c2                	mov    %eax,%edx
80106203:	8b 45 0c             	mov    0xc(%ebp),%eax
80106206:	01 c2                	add    %eax,%edx
80106208:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010620b:	8b 00                	mov    (%eax),%eax
8010620d:	89 42 38             	mov    %eax,0x38(%edx)

      safestrcpy(table[index].name, p->name, sizeof(table[index].name));
80106210:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106213:	8d 48 6c             	lea    0x6c(%eax),%ecx
80106216:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106219:	89 d0                	mov    %edx,%eax
8010621b:	01 c0                	add    %eax,%eax
8010621d:	01 d0                	add    %edx,%eax
8010621f:	c1 e0 05             	shl    $0x5,%eax
80106222:	89 c2                	mov    %eax,%edx
80106224:	8b 45 0c             	mov    0xc(%ebp),%eax
80106227:	01 d0                	add    %edx,%eax
80106229:	83 c0 3c             	add    $0x3c,%eax
8010622c:	83 ec 04             	sub    $0x4,%esp
8010622f:	6a 20                	push   $0x20
80106231:	51                   	push   %ecx
80106232:	50                   	push   %eax
80106233:	e8 35 0c 00 00       	call   80106e6d <safestrcpy>
80106238:	83 c4 10             	add    $0x10,%esp

      if(p->state == RUNNING)
8010623b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010623e:	8b 40 0c             	mov    0xc(%eax),%eax
80106241:	83 f8 04             	cmp    $0x4,%eax
80106244:	75 29                	jne    8010626f <getprocs+0x19c>
        safestrcpy(table[index].state, "RUNNING", sizeof(table[index].state));
80106246:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106249:	89 d0                	mov    %edx,%eax
8010624b:	01 c0                	add    %eax,%eax
8010624d:	01 d0                	add    %edx,%eax
8010624f:	c1 e0 05             	shl    $0x5,%eax
80106252:	89 c2                	mov    %eax,%edx
80106254:	8b 45 0c             	mov    0xc(%ebp),%eax
80106257:	01 d0                	add    %edx,%eax
80106259:	83 c0 18             	add    $0x18,%eax
8010625c:	83 ec 04             	sub    $0x4,%esp
8010625f:	6a 20                	push   $0x20
80106261:	68 6f a9 10 80       	push   $0x8010a96f
80106266:	50                   	push   %eax
80106267:	e8 01 0c 00 00       	call   80106e6d <safestrcpy>
8010626c:	83 c4 10             	add    $0x10,%esp
      if(p->state == SLEEPING)
8010626f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106272:	8b 40 0c             	mov    0xc(%eax),%eax
80106275:	83 f8 02             	cmp    $0x2,%eax
80106278:	75 29                	jne    801062a3 <getprocs+0x1d0>
        safestrcpy(table[index].state, "SLEEPING", sizeof(table[index].state));
8010627a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010627d:	89 d0                	mov    %edx,%eax
8010627f:	01 c0                	add    %eax,%eax
80106281:	01 d0                	add    %edx,%eax
80106283:	c1 e0 05             	shl    $0x5,%eax
80106286:	89 c2                	mov    %eax,%edx
80106288:	8b 45 0c             	mov    0xc(%ebp),%eax
8010628b:	01 d0                	add    %edx,%eax
8010628d:	83 c0 18             	add    $0x18,%eax
80106290:	83 ec 04             	sub    $0x4,%esp
80106293:	6a 20                	push   $0x20
80106295:	68 77 a9 10 80       	push   $0x8010a977
8010629a:	50                   	push   %eax
8010629b:	e8 cd 0b 00 00       	call   80106e6d <safestrcpy>
801062a0:	83 c4 10             	add    $0x10,%esp
      if(p->state == RUNNABLE)
801062a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062a6:	8b 40 0c             	mov    0xc(%eax),%eax
801062a9:	83 f8 03             	cmp    $0x3,%eax
801062ac:	75 29                	jne    801062d7 <getprocs+0x204>
        safestrcpy(table[index].state, "RUNNABLE", sizeof(table[index].state));
801062ae:	8b 55 f0             	mov    -0x10(%ebp),%edx
801062b1:	89 d0                	mov    %edx,%eax
801062b3:	01 c0                	add    %eax,%eax
801062b5:	01 d0                	add    %edx,%eax
801062b7:	c1 e0 05             	shl    $0x5,%eax
801062ba:	89 c2                	mov    %eax,%edx
801062bc:	8b 45 0c             	mov    0xc(%ebp),%eax
801062bf:	01 d0                	add    %edx,%eax
801062c1:	83 c0 18             	add    $0x18,%eax
801062c4:	83 ec 04             	sub    $0x4,%esp
801062c7:	6a 20                	push   $0x20
801062c9:	68 80 a9 10 80       	push   $0x8010a980
801062ce:	50                   	push   %eax
801062cf:	e8 99 0b 00 00       	call   80106e6d <safestrcpy>
801062d4:	83 c4 10             	add    $0x10,%esp

      ++index;
801062d7:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  struct proc *p;
  int index = 0;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC] && index < max; p++)
801062db:	81 45 f4 9c 00 00 00 	addl   $0x9c,-0xc(%ebp)
801062e2:	81 7d f4 d4 70 11 80 	cmpl   $0x801170d4,-0xc(%ebp)
801062e9:	73 0c                	jae    801062f7 <getprocs+0x224>
801062eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062ee:	3b 45 08             	cmp    0x8(%ebp),%eax
801062f1:	0f 82 05 fe ff ff    	jb     801060fc <getprocs+0x29>

      ++index;
    }
  }

  release(&ptable.lock);
801062f7:	83 ec 0c             	sub    $0xc,%esp
801062fa:	68 a0 49 11 80       	push   $0x801149a0
801062ff:	e8 6a 07 00 00       	call   80106a6e <release>
80106304:	83 c4 10             	add    $0x10,%esp

  return index;
80106307:	8b 45 f0             	mov    -0x10(%ebp),%eax
} 
8010630a:	c9                   	leave  
8010630b:	c3                   	ret    

8010630c <promoteAll>:

#ifdef CS333_P3P4
//add holding locks check for all functions following
static void
promoteAll()
{
8010630c:	55                   	push   %ebp
8010630d:	89 e5                	mov    %esp,%ebp
8010630f:	83 ec 18             	sub    $0x18,%esp
  struct proc *current;
  struct proc *hold;
  int rc;

  current = ptable.pLists.sleep;
80106312:	a1 f4 70 11 80       	mov    0x801170f4,%eax
80106317:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(current)
8010631a:	eb 2e                	jmp    8010634a <promoteAll+0x3e>
  {
    if(current->priority > 0)
8010631c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010631f:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80106325:	85 c0                	test   %eax,%eax
80106327:	7e 15                	jle    8010633e <promoteAll+0x32>
      --(current->priority);
80106329:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010632c:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80106332:	8d 50 ff             	lea    -0x1(%eax),%edx
80106335:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106338:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
    current = current->next;
8010633e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106341:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106347:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct proc *current;
  struct proc *hold;
  int rc;

  current = ptable.pLists.sleep;
  while(current)
8010634a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010634e:	75 cc                	jne    8010631c <promoteAll+0x10>
    if(current->priority > 0)
      --(current->priority);
    current = current->next;
  }
      
  current = ptable.pLists.running;
80106350:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80106355:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(current)
80106358:	eb 2e                	jmp    80106388 <promoteAll+0x7c>
  {
    if(current->priority > 0)
8010635a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010635d:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80106363:	85 c0                	test   %eax,%eax
80106365:	7e 15                	jle    8010637c <promoteAll+0x70>
      --(current->priority);
80106367:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010636a:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80106370:	8d 50 ff             	lea    -0x1(%eax),%edx
80106373:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106376:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
    current = current->next;
8010637c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010637f:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106385:	89 45 f4             	mov    %eax,-0xc(%ebp)
      --(current->priority);
    current = current->next;
  }
      
  current = ptable.pLists.running;
  while(current)
80106388:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010638c:	75 cc                	jne    8010635a <promoteAll+0x4e>
    if(current->priority > 0)
      --(current->priority);
    current = current->next;
  }

  for(int i = 0; i < MAX + 1; i++)
8010638e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80106395:	e9 df 00 00 00       	jmp    80106479 <promoteAll+0x16d>
  {
    current = ptable.pLists.ready[i];
8010639a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010639d:	05 cc 09 00 00       	add    $0x9cc,%eax
801063a2:	8b 04 85 a4 49 11 80 	mov    -0x7feeb65c(,%eax,4),%eax
801063a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while(current)
801063ac:	e9 ba 00 00 00       	jmp    8010646b <promoteAll+0x15f>
    {
      hold = current->next;
801063b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063b4:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801063ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
      rc = removeFromStateList(&ptable.pLists.ready[i], current);
801063bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063c0:	05 cc 09 00 00       	add    $0x9cc,%eax
801063c5:	c1 e0 02             	shl    $0x2,%eax
801063c8:	05 a0 49 11 80       	add    $0x801149a0,%eax
801063cd:	83 c0 04             	add    $0x4,%eax
801063d0:	83 ec 08             	sub    $0x8,%esp
801063d3:	ff 75 f4             	pushl  -0xc(%ebp)
801063d6:	50                   	push   %eax
801063d7:	e8 aa 00 00 00       	call   80106486 <removeFromStateList>
801063dc:	83 c4 10             	add    $0x10,%esp
801063df:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(rc == -1)
801063e2:	83 7d e8 ff          	cmpl   $0xffffffff,-0x18(%ebp)
801063e6:	75 0d                	jne    801063f5 <promoteAll+0xe9>
        panic("Could not remove from ready list.");
801063e8:	83 ec 0c             	sub    $0xc,%esp
801063eb:	68 80 a7 10 80       	push   $0x8010a780
801063f0:	e8 71 a1 ff ff       	call   80100566 <panic>
      assertState(current, RUNNABLE);
801063f5:	83 ec 08             	sub    $0x8,%esp
801063f8:	6a 03                	push   $0x3
801063fa:	ff 75 f4             	pushl  -0xc(%ebp)
801063fd:	e8 34 01 00 00       	call   80106536 <assertState>
80106402:	83 c4 10             	add    $0x10,%esp

      if(current->priority > 0)
80106405:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106408:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
8010640e:	85 c0                	test   %eax,%eax
80106410:	7e 15                	jle    80106427 <promoteAll+0x11b>
        --(current->priority);
80106412:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106415:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
8010641b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010641e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106421:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)

      rc = addToStateListEnd(&ptable.pLists.ready[current->priority], current);
80106427:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010642a:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80106430:	05 cc 09 00 00       	add    $0x9cc,%eax
80106435:	c1 e0 02             	shl    $0x2,%eax
80106438:	05 a0 49 11 80       	add    $0x801149a0,%eax
8010643d:	83 c0 04             	add    $0x4,%eax
80106440:	83 ec 08             	sub    $0x8,%esp
80106443:	ff 75 f4             	pushl  -0xc(%ebp)
80106446:	50                   	push   %eax
80106447:	e8 0b 01 00 00       	call   80106557 <addToStateListEnd>
8010644c:	83 c4 10             	add    $0x10,%esp
8010644f:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(rc == -1)
80106452:	83 7d e8 ff          	cmpl   $0xffffffff,-0x18(%ebp)
80106456:	75 0d                	jne    80106465 <promoteAll+0x159>
        panic("Could not add to ready list.");
80106458:	83 ec 0c             	sub    $0xc,%esp
8010645b:	68 03 a8 10 80       	push   $0x8010a803
80106460:	e8 01 a1 ff ff       	call   80100566 <panic>
          
      current = hold;
80106465:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106468:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }

  for(int i = 0; i < MAX + 1; i++)
  {
    current = ptable.pLists.ready[i];
    while(current)
8010646b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010646f:	0f 85 3c ff ff ff    	jne    801063b1 <promoteAll+0xa5>
    if(current->priority > 0)
      --(current->priority);
    current = current->next;
  }

  for(int i = 0; i < MAX + 1; i++)
80106475:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80106479:	83 7d f0 06          	cmpl   $0x6,-0x10(%ebp)
8010647d:	0f 8e 17 ff ff ff    	jle    8010639a <promoteAll+0x8e>
        panic("Could not add to ready list.");
          
      current = hold;
    }
  }
}
80106483:	90                   	nop
80106484:	c9                   	leave  
80106485:	c3                   	ret    

80106486 <removeFromStateList>:

static int
removeFromStateList(struct proc** sList, struct proc* p)
{
80106486:	55                   	push   %ebp
80106487:	89 e5                	mov    %esp,%ebp
80106489:	83 ec 10             	sub    $0x10,%esp
  if (*sList == 0)
8010648c:	8b 45 08             	mov    0x8(%ebp),%eax
8010648f:	8b 00                	mov    (%eax),%eax
80106491:	85 c0                	test   %eax,%eax
80106493:	75 0a                	jne    8010649f <removeFromStateList+0x19>
    return -1;
80106495:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010649a:	e9 95 00 00 00       	jmp    80106534 <removeFromStateList+0xae>

  else if(*sList == p)
8010649f:	8b 45 08             	mov    0x8(%ebp),%eax
801064a2:	8b 00                	mov    (%eax),%eax
801064a4:	3b 45 0c             	cmp    0xc(%ebp),%eax
801064a7:	75 2a                	jne    801064d3 <removeFromStateList+0x4d>
  {
    struct proc *temp = *sList;
801064a9:	8b 45 08             	mov    0x8(%ebp),%eax
801064ac:	8b 00                	mov    (%eax),%eax
801064ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
    *sList = temp->next;
801064b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064b4:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
801064ba:	8b 45 08             	mov    0x8(%ebp),%eax
801064bd:	89 10                	mov    %edx,(%eax)
    p->next = 0;
801064bf:	8b 45 0c             	mov    0xc(%ebp),%eax
801064c2:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
801064c9:	00 00 00 
    return 0;
801064cc:	b8 00 00 00 00       	mov    $0x0,%eax
801064d1:	eb 61                	jmp    80106534 <removeFromStateList+0xae>
  }

  else
  {
    struct proc *previous = *sList;
801064d3:	8b 45 08             	mov    0x8(%ebp),%eax
801064d6:	8b 00                	mov    (%eax),%eax
801064d8:	89 45 fc             	mov    %eax,-0x4(%ebp)
    struct proc *current = previous->next;
801064db:	8b 45 fc             	mov    -0x4(%ebp),%eax
801064de:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801064e4:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while(current != 0)
801064e7:	eb 40                	jmp    80106529 <removeFromStateList+0xa3>
    {
      if(current == p)
801064e9:	8b 45 f8             	mov    -0x8(%ebp),%eax
801064ec:	3b 45 0c             	cmp    0xc(%ebp),%eax
801064ef:	75 26                	jne    80106517 <removeFromStateList+0x91>
      {
        previous->next = current->next;
801064f1:	8b 45 f8             	mov    -0x8(%ebp),%eax
801064f4:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
801064fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
801064fd:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
        p->next = 0;
80106503:	8b 45 0c             	mov    0xc(%ebp),%eax
80106506:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
8010650d:	00 00 00 
        return 0;
80106510:	b8 00 00 00 00       	mov    $0x0,%eax
80106515:	eb 1d                	jmp    80106534 <removeFromStateList+0xae>
      }
      previous = current;
80106517:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010651a:	89 45 fc             	mov    %eax,-0x4(%ebp)
      current = current->next;
8010651d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106520:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106526:	89 45 f8             	mov    %eax,-0x8(%ebp)

  else
  {
    struct proc *previous = *sList;
    struct proc *current = previous->next;
    while(current != 0)
80106529:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
8010652d:	75 ba                	jne    801064e9 <removeFromStateList+0x63>
      previous = current;
      current = current->next;
    }
  }
  
  return -1;
8010652f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106534:	c9                   	leave  
80106535:	c3                   	ret    

80106536 <assertState>:

static void
assertState(struct proc* p, enum procstate state)
{
80106536:	55                   	push   %ebp
80106537:	89 e5                	mov    %esp,%ebp
80106539:	83 ec 08             	sub    $0x8,%esp
  if(p->state != state)
8010653c:	8b 45 08             	mov    0x8(%ebp),%eax
8010653f:	8b 40 0c             	mov    0xc(%eax),%eax
80106542:	3b 45 0c             	cmp    0xc(%ebp),%eax
80106545:	74 0d                	je     80106554 <assertState+0x1e>
    panic("State does not match");
80106547:	83 ec 0c             	sub    $0xc,%esp
8010654a:	68 89 a9 10 80       	push   $0x8010a989
8010654f:	e8 12 a0 ff ff       	call   80100566 <panic>
  else
    return;  
80106554:	90                   	nop
}
80106555:	c9                   	leave  
80106556:	c3                   	ret    

80106557 <addToStateListEnd>:

static int
addToStateListEnd(struct proc** sList, struct proc* p)
{
80106557:	55                   	push   %ebp
80106558:	89 e5                	mov    %esp,%ebp
8010655a:	83 ec 10             	sub    $0x10,%esp
  if(*sList == 0)
8010655d:	8b 45 08             	mov    0x8(%ebp),%eax
80106560:	8b 00                	mov    (%eax),%eax
80106562:	85 c0                	test   %eax,%eax
80106564:	75 1c                	jne    80106582 <addToStateListEnd+0x2b>
  {
    *sList = p;
80106566:	8b 45 08             	mov    0x8(%ebp),%eax
80106569:	8b 55 0c             	mov    0xc(%ebp),%edx
8010656c:	89 10                	mov    %edx,(%eax)
    p->next = 0;
8010656e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106571:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
80106578:	00 00 00 
    return 0;
8010657b:	b8 00 00 00 00       	mov    $0x0,%eax
80106580:	eb 4e                	jmp    801065d0 <addToStateListEnd+0x79>
  }

  else
  {
    struct proc* current = *sList;
80106582:	8b 45 08             	mov    0x8(%ebp),%eax
80106585:	8b 00                	mov    (%eax),%eax
80106587:	89 45 fc             	mov    %eax,-0x4(%ebp)
  
    while(current != 0)
8010658a:	eb 39                	jmp    801065c5 <addToStateListEnd+0x6e>
    { 
      if(current->next == 0)
8010658c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010658f:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106595:	85 c0                	test   %eax,%eax
80106597:	75 20                	jne    801065b9 <addToStateListEnd+0x62>
      {
        current->next = p;
80106599:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010659c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010659f:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
        p->next = 0;
801065a5:	8b 45 0c             	mov    0xc(%ebp),%eax
801065a8:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
801065af:	00 00 00 
        return 0;
801065b2:	b8 00 00 00 00       	mov    $0x0,%eax
801065b7:	eb 17                	jmp    801065d0 <addToStateListEnd+0x79>
      }
      current = current->next;
801065b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801065bc:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801065c2:	89 45 fc             	mov    %eax,-0x4(%ebp)

  else
  {
    struct proc* current = *sList;
  
    while(current != 0)
801065c5:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801065c9:	75 c1                	jne    8010658c <addToStateListEnd+0x35>
        return 0;
      }
      current = current->next;
    }
  }
  return -1;
801065cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801065d0:	c9                   	leave  
801065d1:	c3                   	ret    

801065d2 <addToStateListHead>:

static int
addToStateListHead(struct proc ** sList, struct proc* p)
{
801065d2:	55                   	push   %ebp
801065d3:	89 e5                	mov    %esp,%ebp
  if(p == 0)
801065d5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801065d9:	75 07                	jne    801065e2 <addToStateListHead+0x10>
    return -1;
801065db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065e0:	eb 1b                	jmp    801065fd <addToStateListHead+0x2b>
  p->next = *sList;
801065e2:	8b 45 08             	mov    0x8(%ebp),%eax
801065e5:	8b 10                	mov    (%eax),%edx
801065e7:	8b 45 0c             	mov    0xc(%ebp),%eax
801065ea:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
  *sList = p;
801065f0:	8b 45 08             	mov    0x8(%ebp),%eax
801065f3:	8b 55 0c             	mov    0xc(%ebp),%edx
801065f6:	89 10                	mov    %edx,(%eax)
  return 0;
801065f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065fd:	5d                   	pop    %ebp
801065fe:	c3                   	ret    

801065ff <doready>:

void
doready(void)
{
801065ff:	55                   	push   %ebp
80106600:	89 e5                	mov    %esp,%ebp
80106602:	83 ec 18             	sub    $0x18,%esp
  struct proc *current;

  cprintf("\nReady List Processes:\n");
80106605:	83 ec 0c             	sub    $0xc,%esp
80106608:	68 9e a9 10 80       	push   $0x8010a99e
8010660d:	e8 b4 9d ff ff       	call   801003c6 <cprintf>
80106612:	83 c4 10             	add    $0x10,%esp

  for(int list = 0; list < MAX + 1; list++)
80106615:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010661c:	eb 6e                	jmp    8010668c <doready+0x8d>
  {
    current = ptable.pLists.ready[list];
8010661e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106621:	05 cc 09 00 00       	add    $0x9cc,%eax
80106626:	8b 04 85 a4 49 11 80 	mov    -0x7feeb65c(,%eax,4),%eax
8010662d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("\nReady list %d: ", list);
80106630:	83 ec 08             	sub    $0x8,%esp
80106633:	ff 75 f0             	pushl  -0x10(%ebp)
80106636:	68 b6 a9 10 80       	push   $0x8010a9b6
8010663b:	e8 86 9d ff ff       	call   801003c6 <cprintf>
80106640:	83 c4 10             	add    $0x10,%esp
    while(current != 0)
80106643:	eb 3d                	jmp    80106682 <doready+0x83>
    {
      assertState(current, RUNNABLE);
80106645:	83 ec 08             	sub    $0x8,%esp
80106648:	6a 03                	push   $0x3
8010664a:	ff 75 f4             	pushl  -0xc(%ebp)
8010664d:	e8 e4 fe ff ff       	call   80106536 <assertState>
80106652:	83 c4 10             	add    $0x10,%esp
      cprintf("(%d, %d) -> ", current->pid, current->budget);
80106655:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106658:	8b 90 98 00 00 00    	mov    0x98(%eax),%edx
8010665e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106661:	8b 40 10             	mov    0x10(%eax),%eax
80106664:	83 ec 04             	sub    $0x4,%esp
80106667:	52                   	push   %edx
80106668:	50                   	push   %eax
80106669:	68 c7 a9 10 80       	push   $0x8010a9c7
8010666e:	e8 53 9d ff ff       	call   801003c6 <cprintf>
80106673:	83 c4 10             	add    $0x10,%esp
      current = current->next;
80106676:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106679:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010667f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  for(int list = 0; list < MAX + 1; list++)
  {
    current = ptable.pLists.ready[list];
    cprintf("\nReady list %d: ", list);
    while(current != 0)
80106682:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106686:	75 bd                	jne    80106645 <doready+0x46>
{
  struct proc *current;

  cprintf("\nReady List Processes:\n");

  for(int list = 0; list < MAX + 1; list++)
80106688:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010668c:	83 7d f0 06          	cmpl   $0x6,-0x10(%ebp)
80106690:	7e 8c                	jle    8010661e <doready+0x1f>
      cprintf("(%d, %d) -> ", current->pid, current->budget);
      current = current->next;
    }
  }

  cprintf("\n");
80106692:	83 ec 0c             	sub    $0xc,%esp
80106695:	68 6d a9 10 80       	push   $0x8010a96d
8010669a:	e8 27 9d ff ff       	call   801003c6 <cprintf>
8010669f:	83 c4 10             	add    $0x10,%esp
}
801066a2:	90                   	nop
801066a3:	c9                   	leave  
801066a4:	c3                   	ret    

801066a5 <dofree>:

void
dofree(void)
{
801066a5:	55                   	push   %ebp
801066a6:	89 e5                	mov    %esp,%ebp
801066a8:	83 ec 18             	sub    $0x18,%esp
  int count = 0;
801066ab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  struct proc *current;
  
  current = ptable.pLists.free;
801066b2:	a1 f0 70 11 80       	mov    0x801170f0,%eax
801066b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(current == 0)
801066ba:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801066be:	75 32                	jne    801066f2 <dofree+0x4d>
  {
    cprintf("\nNo free processes.\n");
801066c0:	83 ec 0c             	sub    $0xc,%esp
801066c3:	68 d4 a9 10 80       	push   $0x8010a9d4
801066c8:	e8 f9 9c ff ff       	call   801003c6 <cprintf>
801066cd:	83 c4 10             	add    $0x10,%esp
    return;
801066d0:	eb 39                	jmp    8010670b <dofree+0x66>
  }

  while(current != 0)
  {
    assertState(current, UNUSED);
801066d2:	83 ec 08             	sub    $0x8,%esp
801066d5:	6a 00                	push   $0x0
801066d7:	ff 75 f0             	pushl  -0x10(%ebp)
801066da:	e8 57 fe ff ff       	call   80106536 <assertState>
801066df:	83 c4 10             	add    $0x10,%esp
    ++count;
801066e2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    current = current->next;
801066e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066e9:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801066ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
  {
    cprintf("\nNo free processes.\n");
    return;
  }

  while(current != 0)
801066f2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801066f6:	75 da                	jne    801066d2 <dofree+0x2d>
    assertState(current, UNUSED);
    ++count;
    current = current->next;
  } 

  cprintf("\nFree List Size: %d processes.\n", count); 
801066f8:	83 ec 08             	sub    $0x8,%esp
801066fb:	ff 75 f4             	pushl  -0xc(%ebp)
801066fe:	68 ec a9 10 80       	push   $0x8010a9ec
80106703:	e8 be 9c ff ff       	call   801003c6 <cprintf>
80106708:	83 c4 10             	add    $0x10,%esp
}
8010670b:	c9                   	leave  
8010670c:	c3                   	ret    

8010670d <dosleep>:

void 
dosleep(void)
{
8010670d:	55                   	push   %ebp
8010670e:	89 e5                	mov    %esp,%ebp
80106710:	83 ec 18             	sub    $0x18,%esp
  struct proc *current;
  
  current = ptable.pLists.sleep;
80106713:	a1 f4 70 11 80       	mov    0x801170f4,%eax
80106718:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(current == 0)
8010671b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010671f:	75 12                	jne    80106733 <dosleep+0x26>
  {
    cprintf("\nNo sleeping processes.\n");
80106721:	83 ec 0c             	sub    $0xc,%esp
80106724:	68 0c aa 10 80       	push   $0x8010aa0c
80106729:	e8 98 9c ff ff       	call   801003c6 <cprintf>
8010672e:	83 c4 10             	add    $0x10,%esp
    return;
80106731:	eb 5b                	jmp    8010678e <dosleep+0x81>
  }

  cprintf("\nSleep List Processes:\n");
80106733:	83 ec 0c             	sub    $0xc,%esp
80106736:	68 25 aa 10 80       	push   $0x8010aa25
8010673b:	e8 86 9c ff ff       	call   801003c6 <cprintf>
80106740:	83 c4 10             	add    $0x10,%esp
  while(current != 0)
80106743:	eb 33                	jmp    80106778 <dosleep+0x6b>
  {
    assertState(current, SLEEPING);
80106745:	83 ec 08             	sub    $0x8,%esp
80106748:	6a 02                	push   $0x2
8010674a:	ff 75 f4             	pushl  -0xc(%ebp)
8010674d:	e8 e4 fd ff ff       	call   80106536 <assertState>
80106752:	83 c4 10             	add    $0x10,%esp
    cprintf("%d -> ", current->pid);
80106755:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106758:	8b 40 10             	mov    0x10(%eax),%eax
8010675b:	83 ec 08             	sub    $0x8,%esp
8010675e:	50                   	push   %eax
8010675f:	68 3d aa 10 80       	push   $0x8010aa3d
80106764:	e8 5d 9c ff ff       	call   801003c6 <cprintf>
80106769:	83 c4 10             	add    $0x10,%esp
    current = current->next;
8010676c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010676f:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106775:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("\nNo sleeping processes.\n");
    return;
  }

  cprintf("\nSleep List Processes:\n");
  while(current != 0)
80106778:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010677c:	75 c7                	jne    80106745 <dosleep+0x38>
  {
    assertState(current, SLEEPING);
    cprintf("%d -> ", current->pid);
    current = current->next;
  }
  cprintf("\n");
8010677e:	83 ec 0c             	sub    $0xc,%esp
80106781:	68 6d a9 10 80       	push   $0x8010a96d
80106786:	e8 3b 9c ff ff       	call   801003c6 <cprintf>
8010678b:	83 c4 10             	add    $0x10,%esp
}
8010678e:	c9                   	leave  
8010678f:	c3                   	ret    

80106790 <dozombie>:

void
dozombie(void)
{
80106790:	55                   	push   %ebp
80106791:	89 e5                	mov    %esp,%ebp
80106793:	83 ec 18             	sub    $0x18,%esp
  struct proc *current;
  
  current = ptable.pLists.zombie;
80106796:	a1 f8 70 11 80       	mov    0x801170f8,%eax
8010679b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(current == 0)
8010679e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067a2:	75 12                	jne    801067b6 <dozombie+0x26>
  {
    cprintf("\nNo zombie processes.\n");
801067a4:	83 ec 0c             	sub    $0xc,%esp
801067a7:	68 44 aa 10 80       	push   $0x8010aa44
801067ac:	e8 15 9c ff ff       	call   801003c6 <cprintf>
801067b1:	83 c4 10             	add    $0x10,%esp
    return;
801067b4:	eb 55                	jmp    8010680b <dozombie+0x7b>
  }
  
  cprintf("\nZombie List Processes:\n");
801067b6:	83 ec 0c             	sub    $0xc,%esp
801067b9:	68 5b aa 10 80       	push   $0x8010aa5b
801067be:	e8 03 9c ff ff       	call   801003c6 <cprintf>
801067c3:	83 c4 10             	add    $0x10,%esp
  while(current != 0)
801067c6:	eb 3d                	jmp    80106805 <dozombie+0x75>
  {
    assertState(current, ZOMBIE);
801067c8:	83 ec 08             	sub    $0x8,%esp
801067cb:	6a 05                	push   $0x5
801067cd:	ff 75 f4             	pushl  -0xc(%ebp)
801067d0:	e8 61 fd ff ff       	call   80106536 <assertState>
801067d5:	83 c4 10             	add    $0x10,%esp
    cprintf("(%d, %d) -> ", current->pid, current->parent->pid);
801067d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067db:	8b 40 14             	mov    0x14(%eax),%eax
801067de:	8b 50 10             	mov    0x10(%eax),%edx
801067e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067e4:	8b 40 10             	mov    0x10(%eax),%eax
801067e7:	83 ec 04             	sub    $0x4,%esp
801067ea:	52                   	push   %edx
801067eb:	50                   	push   %eax
801067ec:	68 c7 a9 10 80       	push   $0x8010a9c7
801067f1:	e8 d0 9b ff ff       	call   801003c6 <cprintf>
801067f6:	83 c4 10             	add    $0x10,%esp
    current = current->next;
801067f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067fc:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106802:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("\nNo zombie processes.\n");
    return;
  }
  
  cprintf("\nZombie List Processes:\n");
  while(current != 0)
80106805:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106809:	75 bd                	jne    801067c8 <dozombie+0x38>
  {
    assertState(current, ZOMBIE);
    cprintf("(%d, %d) -> ", current->pid, current->parent->pid);
    current = current->next;
  }
}
8010680b:	c9                   	leave  
8010680c:	c3                   	ret    

8010680d <setpriority>:

int
setpriority(int pid, int priority)
{
8010680d:	55                   	push   %ebp
8010680e:	89 e5                	mov    %esp,%ebp
80106810:	83 ec 18             	sub    $0x18,%esp
  struct proc *current;
  int rc;

  current = ptable.pLists.sleep;  
80106813:	a1 f4 70 11 80       	mov    0x801170f4,%eax
80106818:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(current)
8010681b:	eb 3c                	jmp    80106859 <setpriority+0x4c>
  {
    if(current->pid == pid)
8010681d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106820:	8b 50 10             	mov    0x10(%eax),%edx
80106823:	8b 45 08             	mov    0x8(%ebp),%eax
80106826:	39 c2                	cmp    %eax,%edx
80106828:	75 23                	jne    8010684d <setpriority+0x40>
    {
      current->priority = priority;
8010682a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010682d:	8b 55 0c             	mov    0xc(%ebp),%edx
80106830:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
      current->budget = BUDGET;
80106836:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106839:	c7 80 98 00 00 00 e8 	movl   $0x3e8,0x98(%eax)
80106840:	03 00 00 
      return 0;
80106843:	b8 00 00 00 00       	mov    $0x0,%eax
80106848:	e9 5e 01 00 00       	jmp    801069ab <setpriority+0x19e>
    }
    current = current->next;
8010684d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106850:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106856:	89 45 f4             	mov    %eax,-0xc(%ebp)
{
  struct proc *current;
  int rc;

  current = ptable.pLists.sleep;  
  while(current)
80106859:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010685d:	75 be                	jne    8010681d <setpriority+0x10>
      return 0;
    }
    current = current->next;
  }

  current = ptable.pLists.running;
8010685f:	a1 fc 70 11 80       	mov    0x801170fc,%eax
80106864:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(current)
80106867:	eb 3c                	jmp    801068a5 <setpriority+0x98>
  {
    if(current->pid == pid)
80106869:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010686c:	8b 50 10             	mov    0x10(%eax),%edx
8010686f:	8b 45 08             	mov    0x8(%ebp),%eax
80106872:	39 c2                	cmp    %eax,%edx
80106874:	75 23                	jne    80106899 <setpriority+0x8c>
    {
      current->priority = priority;
80106876:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106879:	8b 55 0c             	mov    0xc(%ebp),%edx
8010687c:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
      current->budget = BUDGET;
80106882:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106885:	c7 80 98 00 00 00 e8 	movl   $0x3e8,0x98(%eax)
8010688c:	03 00 00 
      return 0;
8010688f:	b8 00 00 00 00       	mov    $0x0,%eax
80106894:	e9 12 01 00 00       	jmp    801069ab <setpriority+0x19e>
    }
    current = current->next;
80106899:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010689c:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801068a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    current = current->next;
  }

  current = ptable.pLists.running;
  while(current)
801068a5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801068a9:	75 be                	jne    80106869 <setpriority+0x5c>
      return 0;
    }
    current = current->next;
  } 

  for(int i = 0; i < MAX+1; i++)
801068ab:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801068b2:	e9 e5 00 00 00       	jmp    8010699c <setpriority+0x18f>
  {
    current = ptable.pLists.ready[i];
801068b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068ba:	05 cc 09 00 00       	add    $0x9cc,%eax
801068bf:	8b 04 85 a4 49 11 80 	mov    -0x7feeb65c(,%eax,4),%eax
801068c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while(current)
801068c9:	e9 b4 00 00 00       	jmp    80106982 <setpriority+0x175>
    {
      if(current->pid == pid)
801068ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068d1:	8b 50 10             	mov    0x10(%eax),%edx
801068d4:	8b 45 08             	mov    0x8(%ebp),%eax
801068d7:	39 c2                	cmp    %eax,%edx
801068d9:	0f 85 a3 00 00 00    	jne    80106982 <setpriority+0x175>
      {
        rc = removeFromStateList(&ptable.pLists.ready[i], current);
801068df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068e2:	05 cc 09 00 00       	add    $0x9cc,%eax
801068e7:	c1 e0 02             	shl    $0x2,%eax
801068ea:	05 a0 49 11 80       	add    $0x801149a0,%eax
801068ef:	83 c0 04             	add    $0x4,%eax
801068f2:	ff 75 f4             	pushl  -0xc(%ebp)
801068f5:	50                   	push   %eax
801068f6:	e8 8b fb ff ff       	call   80106486 <removeFromStateList>
801068fb:	83 c4 08             	add    $0x8,%esp
801068fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if(rc == -1)
80106901:	83 7d ec ff          	cmpl   $0xffffffff,-0x14(%ebp)
80106905:	75 0d                	jne    80106914 <setpriority+0x107>
          panic("Could not remove from ready list.");
80106907:	83 ec 0c             	sub    $0xc,%esp
8010690a:	68 80 a7 10 80       	push   $0x8010a780
8010690f:	e8 52 9c ff ff       	call   80100566 <panic>
        assertState(current, RUNNABLE);
80106914:	83 ec 08             	sub    $0x8,%esp
80106917:	6a 03                	push   $0x3
80106919:	ff 75 f4             	pushl  -0xc(%ebp)
8010691c:	e8 15 fc ff ff       	call   80106536 <assertState>
80106921:	83 c4 10             	add    $0x10,%esp

        current->priority = priority;
80106924:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106927:	8b 55 0c             	mov    0xc(%ebp),%edx
8010692a:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
        current->budget = BUDGET;
80106930:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106933:	c7 80 98 00 00 00 e8 	movl   $0x3e8,0x98(%eax)
8010693a:	03 00 00 

        rc = addToStateListEnd(&ptable.pLists.ready[current->priority], current);
8010693d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106940:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80106946:	05 cc 09 00 00       	add    $0x9cc,%eax
8010694b:	c1 e0 02             	shl    $0x2,%eax
8010694e:	05 a0 49 11 80       	add    $0x801149a0,%eax
80106953:	83 c0 04             	add    $0x4,%eax
80106956:	83 ec 08             	sub    $0x8,%esp
80106959:	ff 75 f4             	pushl  -0xc(%ebp)
8010695c:	50                   	push   %eax
8010695d:	e8 f5 fb ff ff       	call   80106557 <addToStateListEnd>
80106962:	83 c4 10             	add    $0x10,%esp
80106965:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if(rc == -1)
80106968:	83 7d ec ff          	cmpl   $0xffffffff,-0x14(%ebp)
8010696c:	75 0d                	jne    8010697b <setpriority+0x16e>
          panic("Could not add to ready list.");
8010696e:	83 ec 0c             	sub    $0xc,%esp
80106971:	68 03 a8 10 80       	push   $0x8010a803
80106976:	e8 eb 9b ff ff       	call   80100566 <panic>

        return 0;
8010697b:	b8 00 00 00 00       	mov    $0x0,%eax
80106980:	eb 29                	jmp    801069ab <setpriority+0x19e>
  } 

  for(int i = 0; i < MAX+1; i++)
  {
    current = ptable.pLists.ready[i];
    while(current)
80106982:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106986:	0f 85 42 ff ff ff    	jne    801068ce <setpriority+0xc1>
          panic("Could not add to ready list.");

        return 0;
      }
    }
    current = current->next;
8010698c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010698f:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106995:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return 0;
    }
    current = current->next;
  } 

  for(int i = 0; i < MAX+1; i++)
80106998:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010699c:	83 7d f0 06          	cmpl   $0x6,-0x10(%ebp)
801069a0:	0f 8e 11 ff ff ff    	jle    801068b7 <setpriority+0xaa>
      }
    }
    current = current->next;
  }

  return -1;
801069a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801069ab:	c9                   	leave  
801069ac:	c3                   	ret    

801069ad <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801069ad:	55                   	push   %ebp
801069ae:	89 e5                	mov    %esp,%ebp
801069b0:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801069b3:	9c                   	pushf  
801069b4:	58                   	pop    %eax
801069b5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801069b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801069bb:	c9                   	leave  
801069bc:	c3                   	ret    

801069bd <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801069bd:	55                   	push   %ebp
801069be:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801069c0:	fa                   	cli    
}
801069c1:	90                   	nop
801069c2:	5d                   	pop    %ebp
801069c3:	c3                   	ret    

801069c4 <sti>:

static inline void
sti(void)
{
801069c4:	55                   	push   %ebp
801069c5:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801069c7:	fb                   	sti    
}
801069c8:	90                   	nop
801069c9:	5d                   	pop    %ebp
801069ca:	c3                   	ret    

801069cb <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
801069cb:	55                   	push   %ebp
801069cc:	89 e5                	mov    %esp,%ebp
801069ce:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801069d1:	8b 55 08             	mov    0x8(%ebp),%edx
801069d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801069d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
801069da:	f0 87 02             	lock xchg %eax,(%edx)
801069dd:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801069e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801069e3:	c9                   	leave  
801069e4:	c3                   	ret    

801069e5 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801069e5:	55                   	push   %ebp
801069e6:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801069e8:	8b 45 08             	mov    0x8(%ebp),%eax
801069eb:	8b 55 0c             	mov    0xc(%ebp),%edx
801069ee:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801069f1:	8b 45 08             	mov    0x8(%ebp),%eax
801069f4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801069fa:	8b 45 08             	mov    0x8(%ebp),%eax
801069fd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80106a04:	90                   	nop
80106a05:	5d                   	pop    %ebp
80106a06:	c3                   	ret    

80106a07 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80106a07:	55                   	push   %ebp
80106a08:	89 e5                	mov    %esp,%ebp
80106a0a:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80106a0d:	e8 52 01 00 00       	call   80106b64 <pushcli>
  if(holding(lk))
80106a12:	8b 45 08             	mov    0x8(%ebp),%eax
80106a15:	83 ec 0c             	sub    $0xc,%esp
80106a18:	50                   	push   %eax
80106a19:	e8 1c 01 00 00       	call   80106b3a <holding>
80106a1e:	83 c4 10             	add    $0x10,%esp
80106a21:	85 c0                	test   %eax,%eax
80106a23:	74 0d                	je     80106a32 <acquire+0x2b>
    panic("acquire");
80106a25:	83 ec 0c             	sub    $0xc,%esp
80106a28:	68 74 aa 10 80       	push   $0x8010aa74
80106a2d:	e8 34 9b ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80106a32:	90                   	nop
80106a33:	8b 45 08             	mov    0x8(%ebp),%eax
80106a36:	83 ec 08             	sub    $0x8,%esp
80106a39:	6a 01                	push   $0x1
80106a3b:	50                   	push   %eax
80106a3c:	e8 8a ff ff ff       	call   801069cb <xchg>
80106a41:	83 c4 10             	add    $0x10,%esp
80106a44:	85 c0                	test   %eax,%eax
80106a46:	75 eb                	jne    80106a33 <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80106a48:	8b 45 08             	mov    0x8(%ebp),%eax
80106a4b:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106a52:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80106a55:	8b 45 08             	mov    0x8(%ebp),%eax
80106a58:	83 c0 0c             	add    $0xc,%eax
80106a5b:	83 ec 08             	sub    $0x8,%esp
80106a5e:	50                   	push   %eax
80106a5f:	8d 45 08             	lea    0x8(%ebp),%eax
80106a62:	50                   	push   %eax
80106a63:	e8 58 00 00 00       	call   80106ac0 <getcallerpcs>
80106a68:	83 c4 10             	add    $0x10,%esp
}
80106a6b:	90                   	nop
80106a6c:	c9                   	leave  
80106a6d:	c3                   	ret    

80106a6e <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80106a6e:	55                   	push   %ebp
80106a6f:	89 e5                	mov    %esp,%ebp
80106a71:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80106a74:	83 ec 0c             	sub    $0xc,%esp
80106a77:	ff 75 08             	pushl  0x8(%ebp)
80106a7a:	e8 bb 00 00 00       	call   80106b3a <holding>
80106a7f:	83 c4 10             	add    $0x10,%esp
80106a82:	85 c0                	test   %eax,%eax
80106a84:	75 0d                	jne    80106a93 <release+0x25>
    panic("release");
80106a86:	83 ec 0c             	sub    $0xc,%esp
80106a89:	68 7c aa 10 80       	push   $0x8010aa7c
80106a8e:	e8 d3 9a ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
80106a93:	8b 45 08             	mov    0x8(%ebp),%eax
80106a96:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80106a9d:	8b 45 08             	mov    0x8(%ebp),%eax
80106aa0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80106aa7:	8b 45 08             	mov    0x8(%ebp),%eax
80106aaa:	83 ec 08             	sub    $0x8,%esp
80106aad:	6a 00                	push   $0x0
80106aaf:	50                   	push   %eax
80106ab0:	e8 16 ff ff ff       	call   801069cb <xchg>
80106ab5:	83 c4 10             	add    $0x10,%esp

  popcli();
80106ab8:	e8 ec 00 00 00       	call   80106ba9 <popcli>
}
80106abd:	90                   	nop
80106abe:	c9                   	leave  
80106abf:	c3                   	ret    

80106ac0 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80106ac0:	55                   	push   %ebp
80106ac1:	89 e5                	mov    %esp,%ebp
80106ac3:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80106ac6:	8b 45 08             	mov    0x8(%ebp),%eax
80106ac9:	83 e8 08             	sub    $0x8,%eax
80106acc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80106acf:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80106ad6:	eb 38                	jmp    80106b10 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80106ad8:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80106adc:	74 53                	je     80106b31 <getcallerpcs+0x71>
80106ade:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80106ae5:	76 4a                	jbe    80106b31 <getcallerpcs+0x71>
80106ae7:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80106aeb:	74 44                	je     80106b31 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80106aed:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106af0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106af7:	8b 45 0c             	mov    0xc(%ebp),%eax
80106afa:	01 c2                	add    %eax,%edx
80106afc:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106aff:	8b 40 04             	mov    0x4(%eax),%eax
80106b02:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80106b04:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106b07:	8b 00                	mov    (%eax),%eax
80106b09:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80106b0c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80106b10:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80106b14:	7e c2                	jle    80106ad8 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80106b16:	eb 19                	jmp    80106b31 <getcallerpcs+0x71>
    pcs[i] = 0;
80106b18:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106b1b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106b22:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b25:	01 d0                	add    %edx,%eax
80106b27:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80106b2d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80106b31:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80106b35:	7e e1                	jle    80106b18 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80106b37:	90                   	nop
80106b38:	c9                   	leave  
80106b39:	c3                   	ret    

80106b3a <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80106b3a:	55                   	push   %ebp
80106b3b:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80106b3d:	8b 45 08             	mov    0x8(%ebp),%eax
80106b40:	8b 00                	mov    (%eax),%eax
80106b42:	85 c0                	test   %eax,%eax
80106b44:	74 17                	je     80106b5d <holding+0x23>
80106b46:	8b 45 08             	mov    0x8(%ebp),%eax
80106b49:	8b 50 08             	mov    0x8(%eax),%edx
80106b4c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106b52:	39 c2                	cmp    %eax,%edx
80106b54:	75 07                	jne    80106b5d <holding+0x23>
80106b56:	b8 01 00 00 00       	mov    $0x1,%eax
80106b5b:	eb 05                	jmp    80106b62 <holding+0x28>
80106b5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106b62:	5d                   	pop    %ebp
80106b63:	c3                   	ret    

80106b64 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80106b64:	55                   	push   %ebp
80106b65:	89 e5                	mov    %esp,%ebp
80106b67:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80106b6a:	e8 3e fe ff ff       	call   801069ad <readeflags>
80106b6f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80106b72:	e8 46 fe ff ff       	call   801069bd <cli>
  if(cpu->ncli++ == 0)
80106b77:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106b7e:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80106b84:	8d 48 01             	lea    0x1(%eax),%ecx
80106b87:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80106b8d:	85 c0                	test   %eax,%eax
80106b8f:	75 15                	jne    80106ba6 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80106b91:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106b97:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106b9a:	81 e2 00 02 00 00    	and    $0x200,%edx
80106ba0:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80106ba6:	90                   	nop
80106ba7:	c9                   	leave  
80106ba8:	c3                   	ret    

80106ba9 <popcli>:

void
popcli(void)
{
80106ba9:	55                   	push   %ebp
80106baa:	89 e5                	mov    %esp,%ebp
80106bac:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80106baf:	e8 f9 fd ff ff       	call   801069ad <readeflags>
80106bb4:	25 00 02 00 00       	and    $0x200,%eax
80106bb9:	85 c0                	test   %eax,%eax
80106bbb:	74 0d                	je     80106bca <popcli+0x21>
    panic("popcli - interruptible");
80106bbd:	83 ec 0c             	sub    $0xc,%esp
80106bc0:	68 84 aa 10 80       	push   $0x8010aa84
80106bc5:	e8 9c 99 ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
80106bca:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106bd0:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80106bd6:	83 ea 01             	sub    $0x1,%edx
80106bd9:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80106bdf:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80106be5:	85 c0                	test   %eax,%eax
80106be7:	79 0d                	jns    80106bf6 <popcli+0x4d>
    panic("popcli");
80106be9:	83 ec 0c             	sub    $0xc,%esp
80106bec:	68 9b aa 10 80       	push   $0x8010aa9b
80106bf1:	e8 70 99 ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80106bf6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106bfc:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80106c02:	85 c0                	test   %eax,%eax
80106c04:	75 15                	jne    80106c1b <popcli+0x72>
80106c06:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106c0c:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80106c12:	85 c0                	test   %eax,%eax
80106c14:	74 05                	je     80106c1b <popcli+0x72>
    sti();
80106c16:	e8 a9 fd ff ff       	call   801069c4 <sti>
}
80106c1b:	90                   	nop
80106c1c:	c9                   	leave  
80106c1d:	c3                   	ret    

80106c1e <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80106c1e:	55                   	push   %ebp
80106c1f:	89 e5                	mov    %esp,%ebp
80106c21:	57                   	push   %edi
80106c22:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80106c23:	8b 4d 08             	mov    0x8(%ebp),%ecx
80106c26:	8b 55 10             	mov    0x10(%ebp),%edx
80106c29:	8b 45 0c             	mov    0xc(%ebp),%eax
80106c2c:	89 cb                	mov    %ecx,%ebx
80106c2e:	89 df                	mov    %ebx,%edi
80106c30:	89 d1                	mov    %edx,%ecx
80106c32:	fc                   	cld    
80106c33:	f3 aa                	rep stos %al,%es:(%edi)
80106c35:	89 ca                	mov    %ecx,%edx
80106c37:	89 fb                	mov    %edi,%ebx
80106c39:	89 5d 08             	mov    %ebx,0x8(%ebp)
80106c3c:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80106c3f:	90                   	nop
80106c40:	5b                   	pop    %ebx
80106c41:	5f                   	pop    %edi
80106c42:	5d                   	pop    %ebp
80106c43:	c3                   	ret    

80106c44 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80106c44:	55                   	push   %ebp
80106c45:	89 e5                	mov    %esp,%ebp
80106c47:	57                   	push   %edi
80106c48:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80106c49:	8b 4d 08             	mov    0x8(%ebp),%ecx
80106c4c:	8b 55 10             	mov    0x10(%ebp),%edx
80106c4f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106c52:	89 cb                	mov    %ecx,%ebx
80106c54:	89 df                	mov    %ebx,%edi
80106c56:	89 d1                	mov    %edx,%ecx
80106c58:	fc                   	cld    
80106c59:	f3 ab                	rep stos %eax,%es:(%edi)
80106c5b:	89 ca                	mov    %ecx,%edx
80106c5d:	89 fb                	mov    %edi,%ebx
80106c5f:	89 5d 08             	mov    %ebx,0x8(%ebp)
80106c62:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80106c65:	90                   	nop
80106c66:	5b                   	pop    %ebx
80106c67:	5f                   	pop    %edi
80106c68:	5d                   	pop    %ebp
80106c69:	c3                   	ret    

80106c6a <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80106c6a:	55                   	push   %ebp
80106c6b:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80106c6d:	8b 45 08             	mov    0x8(%ebp),%eax
80106c70:	83 e0 03             	and    $0x3,%eax
80106c73:	85 c0                	test   %eax,%eax
80106c75:	75 43                	jne    80106cba <memset+0x50>
80106c77:	8b 45 10             	mov    0x10(%ebp),%eax
80106c7a:	83 e0 03             	and    $0x3,%eax
80106c7d:	85 c0                	test   %eax,%eax
80106c7f:	75 39                	jne    80106cba <memset+0x50>
    c &= 0xFF;
80106c81:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80106c88:	8b 45 10             	mov    0x10(%ebp),%eax
80106c8b:	c1 e8 02             	shr    $0x2,%eax
80106c8e:	89 c1                	mov    %eax,%ecx
80106c90:	8b 45 0c             	mov    0xc(%ebp),%eax
80106c93:	c1 e0 18             	shl    $0x18,%eax
80106c96:	89 c2                	mov    %eax,%edx
80106c98:	8b 45 0c             	mov    0xc(%ebp),%eax
80106c9b:	c1 e0 10             	shl    $0x10,%eax
80106c9e:	09 c2                	or     %eax,%edx
80106ca0:	8b 45 0c             	mov    0xc(%ebp),%eax
80106ca3:	c1 e0 08             	shl    $0x8,%eax
80106ca6:	09 d0                	or     %edx,%eax
80106ca8:	0b 45 0c             	or     0xc(%ebp),%eax
80106cab:	51                   	push   %ecx
80106cac:	50                   	push   %eax
80106cad:	ff 75 08             	pushl  0x8(%ebp)
80106cb0:	e8 8f ff ff ff       	call   80106c44 <stosl>
80106cb5:	83 c4 0c             	add    $0xc,%esp
80106cb8:	eb 12                	jmp    80106ccc <memset+0x62>
  } else
    stosb(dst, c, n);
80106cba:	8b 45 10             	mov    0x10(%ebp),%eax
80106cbd:	50                   	push   %eax
80106cbe:	ff 75 0c             	pushl  0xc(%ebp)
80106cc1:	ff 75 08             	pushl  0x8(%ebp)
80106cc4:	e8 55 ff ff ff       	call   80106c1e <stosb>
80106cc9:	83 c4 0c             	add    $0xc,%esp
  return dst;
80106ccc:	8b 45 08             	mov    0x8(%ebp),%eax
}
80106ccf:	c9                   	leave  
80106cd0:	c3                   	ret    

80106cd1 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80106cd1:	55                   	push   %ebp
80106cd2:	89 e5                	mov    %esp,%ebp
80106cd4:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80106cd7:	8b 45 08             	mov    0x8(%ebp),%eax
80106cda:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80106cdd:	8b 45 0c             	mov    0xc(%ebp),%eax
80106ce0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80106ce3:	eb 30                	jmp    80106d15 <memcmp+0x44>
    if(*s1 != *s2)
80106ce5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106ce8:	0f b6 10             	movzbl (%eax),%edx
80106ceb:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106cee:	0f b6 00             	movzbl (%eax),%eax
80106cf1:	38 c2                	cmp    %al,%dl
80106cf3:	74 18                	je     80106d0d <memcmp+0x3c>
      return *s1 - *s2;
80106cf5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106cf8:	0f b6 00             	movzbl (%eax),%eax
80106cfb:	0f b6 d0             	movzbl %al,%edx
80106cfe:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106d01:	0f b6 00             	movzbl (%eax),%eax
80106d04:	0f b6 c0             	movzbl %al,%eax
80106d07:	29 c2                	sub    %eax,%edx
80106d09:	89 d0                	mov    %edx,%eax
80106d0b:	eb 1a                	jmp    80106d27 <memcmp+0x56>
    s1++, s2++;
80106d0d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106d11:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80106d15:	8b 45 10             	mov    0x10(%ebp),%eax
80106d18:	8d 50 ff             	lea    -0x1(%eax),%edx
80106d1b:	89 55 10             	mov    %edx,0x10(%ebp)
80106d1e:	85 c0                	test   %eax,%eax
80106d20:	75 c3                	jne    80106ce5 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80106d22:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106d27:	c9                   	leave  
80106d28:	c3                   	ret    

80106d29 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80106d29:	55                   	push   %ebp
80106d2a:	89 e5                	mov    %esp,%ebp
80106d2c:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80106d2f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106d32:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80106d35:	8b 45 08             	mov    0x8(%ebp),%eax
80106d38:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80106d3b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106d3e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80106d41:	73 54                	jae    80106d97 <memmove+0x6e>
80106d43:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106d46:	8b 45 10             	mov    0x10(%ebp),%eax
80106d49:	01 d0                	add    %edx,%eax
80106d4b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80106d4e:	76 47                	jbe    80106d97 <memmove+0x6e>
    s += n;
80106d50:	8b 45 10             	mov    0x10(%ebp),%eax
80106d53:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80106d56:	8b 45 10             	mov    0x10(%ebp),%eax
80106d59:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80106d5c:	eb 13                	jmp    80106d71 <memmove+0x48>
      *--d = *--s;
80106d5e:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80106d62:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80106d66:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106d69:	0f b6 10             	movzbl (%eax),%edx
80106d6c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106d6f:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80106d71:	8b 45 10             	mov    0x10(%ebp),%eax
80106d74:	8d 50 ff             	lea    -0x1(%eax),%edx
80106d77:	89 55 10             	mov    %edx,0x10(%ebp)
80106d7a:	85 c0                	test   %eax,%eax
80106d7c:	75 e0                	jne    80106d5e <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80106d7e:	eb 24                	jmp    80106da4 <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80106d80:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106d83:	8d 50 01             	lea    0x1(%eax),%edx
80106d86:	89 55 f8             	mov    %edx,-0x8(%ebp)
80106d89:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106d8c:	8d 4a 01             	lea    0x1(%edx),%ecx
80106d8f:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80106d92:	0f b6 12             	movzbl (%edx),%edx
80106d95:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80106d97:	8b 45 10             	mov    0x10(%ebp),%eax
80106d9a:	8d 50 ff             	lea    -0x1(%eax),%edx
80106d9d:	89 55 10             	mov    %edx,0x10(%ebp)
80106da0:	85 c0                	test   %eax,%eax
80106da2:	75 dc                	jne    80106d80 <memmove+0x57>
      *d++ = *s++;

  return dst;
80106da4:	8b 45 08             	mov    0x8(%ebp),%eax
}
80106da7:	c9                   	leave  
80106da8:	c3                   	ret    

80106da9 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80106da9:	55                   	push   %ebp
80106daa:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80106dac:	ff 75 10             	pushl  0x10(%ebp)
80106daf:	ff 75 0c             	pushl  0xc(%ebp)
80106db2:	ff 75 08             	pushl  0x8(%ebp)
80106db5:	e8 6f ff ff ff       	call   80106d29 <memmove>
80106dba:	83 c4 0c             	add    $0xc,%esp
}
80106dbd:	c9                   	leave  
80106dbe:	c3                   	ret    

80106dbf <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80106dbf:	55                   	push   %ebp
80106dc0:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80106dc2:	eb 0c                	jmp    80106dd0 <strncmp+0x11>
    n--, p++, q++;
80106dc4:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80106dc8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80106dcc:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80106dd0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106dd4:	74 1a                	je     80106df0 <strncmp+0x31>
80106dd6:	8b 45 08             	mov    0x8(%ebp),%eax
80106dd9:	0f b6 00             	movzbl (%eax),%eax
80106ddc:	84 c0                	test   %al,%al
80106dde:	74 10                	je     80106df0 <strncmp+0x31>
80106de0:	8b 45 08             	mov    0x8(%ebp),%eax
80106de3:	0f b6 10             	movzbl (%eax),%edx
80106de6:	8b 45 0c             	mov    0xc(%ebp),%eax
80106de9:	0f b6 00             	movzbl (%eax),%eax
80106dec:	38 c2                	cmp    %al,%dl
80106dee:	74 d4                	je     80106dc4 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80106df0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106df4:	75 07                	jne    80106dfd <strncmp+0x3e>
    return 0;
80106df6:	b8 00 00 00 00       	mov    $0x0,%eax
80106dfb:	eb 16                	jmp    80106e13 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80106dfd:	8b 45 08             	mov    0x8(%ebp),%eax
80106e00:	0f b6 00             	movzbl (%eax),%eax
80106e03:	0f b6 d0             	movzbl %al,%edx
80106e06:	8b 45 0c             	mov    0xc(%ebp),%eax
80106e09:	0f b6 00             	movzbl (%eax),%eax
80106e0c:	0f b6 c0             	movzbl %al,%eax
80106e0f:	29 c2                	sub    %eax,%edx
80106e11:	89 d0                	mov    %edx,%eax
}
80106e13:	5d                   	pop    %ebp
80106e14:	c3                   	ret    

80106e15 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80106e15:	55                   	push   %ebp
80106e16:	89 e5                	mov    %esp,%ebp
80106e18:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80106e1b:	8b 45 08             	mov    0x8(%ebp),%eax
80106e1e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80106e21:	90                   	nop
80106e22:	8b 45 10             	mov    0x10(%ebp),%eax
80106e25:	8d 50 ff             	lea    -0x1(%eax),%edx
80106e28:	89 55 10             	mov    %edx,0x10(%ebp)
80106e2b:	85 c0                	test   %eax,%eax
80106e2d:	7e 2c                	jle    80106e5b <strncpy+0x46>
80106e2f:	8b 45 08             	mov    0x8(%ebp),%eax
80106e32:	8d 50 01             	lea    0x1(%eax),%edx
80106e35:	89 55 08             	mov    %edx,0x8(%ebp)
80106e38:	8b 55 0c             	mov    0xc(%ebp),%edx
80106e3b:	8d 4a 01             	lea    0x1(%edx),%ecx
80106e3e:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80106e41:	0f b6 12             	movzbl (%edx),%edx
80106e44:	88 10                	mov    %dl,(%eax)
80106e46:	0f b6 00             	movzbl (%eax),%eax
80106e49:	84 c0                	test   %al,%al
80106e4b:	75 d5                	jne    80106e22 <strncpy+0xd>
    ;
  while(n-- > 0)
80106e4d:	eb 0c                	jmp    80106e5b <strncpy+0x46>
    *s++ = 0;
80106e4f:	8b 45 08             	mov    0x8(%ebp),%eax
80106e52:	8d 50 01             	lea    0x1(%eax),%edx
80106e55:	89 55 08             	mov    %edx,0x8(%ebp)
80106e58:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80106e5b:	8b 45 10             	mov    0x10(%ebp),%eax
80106e5e:	8d 50 ff             	lea    -0x1(%eax),%edx
80106e61:	89 55 10             	mov    %edx,0x10(%ebp)
80106e64:	85 c0                	test   %eax,%eax
80106e66:	7f e7                	jg     80106e4f <strncpy+0x3a>
    *s++ = 0;
  return os;
80106e68:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106e6b:	c9                   	leave  
80106e6c:	c3                   	ret    

80106e6d <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80106e6d:	55                   	push   %ebp
80106e6e:	89 e5                	mov    %esp,%ebp
80106e70:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80106e73:	8b 45 08             	mov    0x8(%ebp),%eax
80106e76:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80106e79:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106e7d:	7f 05                	jg     80106e84 <safestrcpy+0x17>
    return os;
80106e7f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106e82:	eb 31                	jmp    80106eb5 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80106e84:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80106e88:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106e8c:	7e 1e                	jle    80106eac <safestrcpy+0x3f>
80106e8e:	8b 45 08             	mov    0x8(%ebp),%eax
80106e91:	8d 50 01             	lea    0x1(%eax),%edx
80106e94:	89 55 08             	mov    %edx,0x8(%ebp)
80106e97:	8b 55 0c             	mov    0xc(%ebp),%edx
80106e9a:	8d 4a 01             	lea    0x1(%edx),%ecx
80106e9d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80106ea0:	0f b6 12             	movzbl (%edx),%edx
80106ea3:	88 10                	mov    %dl,(%eax)
80106ea5:	0f b6 00             	movzbl (%eax),%eax
80106ea8:	84 c0                	test   %al,%al
80106eaa:	75 d8                	jne    80106e84 <safestrcpy+0x17>
    ;
  *s = 0;
80106eac:	8b 45 08             	mov    0x8(%ebp),%eax
80106eaf:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80106eb2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106eb5:	c9                   	leave  
80106eb6:	c3                   	ret    

80106eb7 <strlen>:

int
strlen(const char *s)
{
80106eb7:	55                   	push   %ebp
80106eb8:	89 e5                	mov    %esp,%ebp
80106eba:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80106ebd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80106ec4:	eb 04                	jmp    80106eca <strlen+0x13>
80106ec6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106eca:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106ecd:	8b 45 08             	mov    0x8(%ebp),%eax
80106ed0:	01 d0                	add    %edx,%eax
80106ed2:	0f b6 00             	movzbl (%eax),%eax
80106ed5:	84 c0                	test   %al,%al
80106ed7:	75 ed                	jne    80106ec6 <strlen+0xf>
    ;
  return n;
80106ed9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106edc:	c9                   	leave  
80106edd:	c3                   	ret    

80106ede <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80106ede:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80106ee2:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80106ee6:	55                   	push   %ebp
  pushl %ebx
80106ee7:	53                   	push   %ebx
  pushl %esi
80106ee8:	56                   	push   %esi
  pushl %edi
80106ee9:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80106eea:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80106eec:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80106eee:	5f                   	pop    %edi
  popl %esi
80106eef:	5e                   	pop    %esi
  popl %ebx
80106ef0:	5b                   	pop    %ebx
  popl %ebp
80106ef1:	5d                   	pop    %ebp
  ret
80106ef2:	c3                   	ret    

80106ef3 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80106ef3:	55                   	push   %ebp
80106ef4:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80106ef6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106efc:	8b 00                	mov    (%eax),%eax
80106efe:	3b 45 08             	cmp    0x8(%ebp),%eax
80106f01:	76 12                	jbe    80106f15 <fetchint+0x22>
80106f03:	8b 45 08             	mov    0x8(%ebp),%eax
80106f06:	8d 50 04             	lea    0x4(%eax),%edx
80106f09:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f0f:	8b 00                	mov    (%eax),%eax
80106f11:	39 c2                	cmp    %eax,%edx
80106f13:	76 07                	jbe    80106f1c <fetchint+0x29>
    return -1;
80106f15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f1a:	eb 0f                	jmp    80106f2b <fetchint+0x38>
  *ip = *(int*)(addr);
80106f1c:	8b 45 08             	mov    0x8(%ebp),%eax
80106f1f:	8b 10                	mov    (%eax),%edx
80106f21:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f24:	89 10                	mov    %edx,(%eax)
  return 0;
80106f26:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106f2b:	5d                   	pop    %ebp
80106f2c:	c3                   	ret    

80106f2d <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80106f2d:	55                   	push   %ebp
80106f2e:	89 e5                	mov    %esp,%ebp
80106f30:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80106f33:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f39:	8b 00                	mov    (%eax),%eax
80106f3b:	3b 45 08             	cmp    0x8(%ebp),%eax
80106f3e:	77 07                	ja     80106f47 <fetchstr+0x1a>
    return -1;
80106f40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f45:	eb 46                	jmp    80106f8d <fetchstr+0x60>
  *pp = (char*)addr;
80106f47:	8b 55 08             	mov    0x8(%ebp),%edx
80106f4a:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f4d:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80106f4f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f55:	8b 00                	mov    (%eax),%eax
80106f57:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80106f5a:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f5d:	8b 00                	mov    (%eax),%eax
80106f5f:	89 45 fc             	mov    %eax,-0x4(%ebp)
80106f62:	eb 1c                	jmp    80106f80 <fetchstr+0x53>
    if(*s == 0)
80106f64:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106f67:	0f b6 00             	movzbl (%eax),%eax
80106f6a:	84 c0                	test   %al,%al
80106f6c:	75 0e                	jne    80106f7c <fetchstr+0x4f>
      return s - *pp;
80106f6e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106f71:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f74:	8b 00                	mov    (%eax),%eax
80106f76:	29 c2                	sub    %eax,%edx
80106f78:	89 d0                	mov    %edx,%eax
80106f7a:	eb 11                	jmp    80106f8d <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80106f7c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106f80:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106f83:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80106f86:	72 dc                	jb     80106f64 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80106f88:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106f8d:	c9                   	leave  
80106f8e:	c3                   	ret    

80106f8f <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80106f8f:	55                   	push   %ebp
80106f90:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80106f92:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f98:	8b 40 18             	mov    0x18(%eax),%eax
80106f9b:	8b 40 44             	mov    0x44(%eax),%eax
80106f9e:	8b 55 08             	mov    0x8(%ebp),%edx
80106fa1:	c1 e2 02             	shl    $0x2,%edx
80106fa4:	01 d0                	add    %edx,%eax
80106fa6:	83 c0 04             	add    $0x4,%eax
80106fa9:	ff 75 0c             	pushl  0xc(%ebp)
80106fac:	50                   	push   %eax
80106fad:	e8 41 ff ff ff       	call   80106ef3 <fetchint>
80106fb2:	83 c4 08             	add    $0x8,%esp
}
80106fb5:	c9                   	leave  
80106fb6:	c3                   	ret    

80106fb7 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80106fb7:	55                   	push   %ebp
80106fb8:	89 e5                	mov    %esp,%ebp
80106fba:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
80106fbd:	8d 45 fc             	lea    -0x4(%ebp),%eax
80106fc0:	50                   	push   %eax
80106fc1:	ff 75 08             	pushl  0x8(%ebp)
80106fc4:	e8 c6 ff ff ff       	call   80106f8f <argint>
80106fc9:	83 c4 08             	add    $0x8,%esp
80106fcc:	85 c0                	test   %eax,%eax
80106fce:	79 07                	jns    80106fd7 <argptr+0x20>
    return -1;
80106fd0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fd5:	eb 3b                	jmp    80107012 <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80106fd7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106fdd:	8b 00                	mov    (%eax),%eax
80106fdf:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106fe2:	39 d0                	cmp    %edx,%eax
80106fe4:	76 16                	jbe    80106ffc <argptr+0x45>
80106fe6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106fe9:	89 c2                	mov    %eax,%edx
80106feb:	8b 45 10             	mov    0x10(%ebp),%eax
80106fee:	01 c2                	add    %eax,%edx
80106ff0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ff6:	8b 00                	mov    (%eax),%eax
80106ff8:	39 c2                	cmp    %eax,%edx
80106ffa:	76 07                	jbe    80107003 <argptr+0x4c>
    return -1;
80106ffc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107001:	eb 0f                	jmp    80107012 <argptr+0x5b>
  *pp = (char*)i;
80107003:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107006:	89 c2                	mov    %eax,%edx
80107008:	8b 45 0c             	mov    0xc(%ebp),%eax
8010700b:	89 10                	mov    %edx,(%eax)
  return 0;
8010700d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107012:	c9                   	leave  
80107013:	c3                   	ret    

80107014 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80107014:	55                   	push   %ebp
80107015:	89 e5                	mov    %esp,%ebp
80107017:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
8010701a:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010701d:	50                   	push   %eax
8010701e:	ff 75 08             	pushl  0x8(%ebp)
80107021:	e8 69 ff ff ff       	call   80106f8f <argint>
80107026:	83 c4 08             	add    $0x8,%esp
80107029:	85 c0                	test   %eax,%eax
8010702b:	79 07                	jns    80107034 <argstr+0x20>
    return -1;
8010702d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107032:	eb 0f                	jmp    80107043 <argstr+0x2f>
  return fetchstr(addr, pp);
80107034:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107037:	ff 75 0c             	pushl  0xc(%ebp)
8010703a:	50                   	push   %eax
8010703b:	e8 ed fe ff ff       	call   80106f2d <fetchstr>
80107040:	83 c4 08             	add    $0x8,%esp
}
80107043:	c9                   	leave  
80107044:	c3                   	ret    

80107045 <syscall>:
};
#endif

void
syscall(void)
{
80107045:	55                   	push   %ebp
80107046:	89 e5                	mov    %esp,%ebp
80107048:	53                   	push   %ebx
80107049:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
8010704c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107052:	8b 40 18             	mov    0x18(%eax),%eax
80107055:	8b 40 1c             	mov    0x1c(%eax),%eax
80107058:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
8010705b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010705f:	7e 30                	jle    80107091 <syscall+0x4c>
80107061:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107064:	83 f8 21             	cmp    $0x21,%eax
80107067:	77 28                	ja     80107091 <syscall+0x4c>
80107069:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010706c:	8b 04 85 40 d0 10 80 	mov    -0x7fef2fc0(,%eax,4),%eax
80107073:	85 c0                	test   %eax,%eax
80107075:	74 1a                	je     80107091 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80107077:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010707d:	8b 58 18             	mov    0x18(%eax),%ebx
80107080:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107083:	8b 04 85 40 d0 10 80 	mov    -0x7fef2fc0(,%eax,4),%eax
8010708a:	ff d0                	call   *%eax
8010708c:	89 43 1c             	mov    %eax,0x1c(%ebx)
8010708f:	eb 34                	jmp    801070c5 <syscall+0x80>
  cprintf("%s -> %d\n", syscallnames[num], proc->tf->eax);
#endif

  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80107091:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107097:	8d 50 6c             	lea    0x6c(%eax),%edx
8010709a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
#ifdef PRINT_SYSCALLS//CS333_P1
  cprintf("%s -> %d\n", syscallnames[num], proc->tf->eax);
#endif

  } else {
    cprintf("%d %s: unknown sys call %d\n",
801070a0:	8b 40 10             	mov    0x10(%eax),%eax
801070a3:	ff 75 f4             	pushl  -0xc(%ebp)
801070a6:	52                   	push   %edx
801070a7:	50                   	push   %eax
801070a8:	68 a2 aa 10 80       	push   $0x8010aaa2
801070ad:	e8 14 93 ff ff       	call   801003c6 <cprintf>
801070b2:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
801070b5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801070bb:	8b 40 18             	mov    0x18(%eax),%eax
801070be:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801070c5:	90                   	nop
801070c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801070c9:	c9                   	leave  
801070ca:	c3                   	ret    

801070cb <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801070cb:	55                   	push   %ebp
801070cc:	89 e5                	mov    %esp,%ebp
801070ce:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801070d1:	83 ec 08             	sub    $0x8,%esp
801070d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801070d7:	50                   	push   %eax
801070d8:	ff 75 08             	pushl  0x8(%ebp)
801070db:	e8 af fe ff ff       	call   80106f8f <argint>
801070e0:	83 c4 10             	add    $0x10,%esp
801070e3:	85 c0                	test   %eax,%eax
801070e5:	79 07                	jns    801070ee <argfd+0x23>
    return -1;
801070e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070ec:	eb 50                	jmp    8010713e <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
801070ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801070f1:	85 c0                	test   %eax,%eax
801070f3:	78 21                	js     80107116 <argfd+0x4b>
801070f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801070f8:	83 f8 0f             	cmp    $0xf,%eax
801070fb:	7f 19                	jg     80107116 <argfd+0x4b>
801070fd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107103:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107106:	83 c2 08             	add    $0x8,%edx
80107109:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010710d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107110:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107114:	75 07                	jne    8010711d <argfd+0x52>
    return -1;
80107116:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010711b:	eb 21                	jmp    8010713e <argfd+0x73>
  if(pfd)
8010711d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80107121:	74 08                	je     8010712b <argfd+0x60>
    *pfd = fd;
80107123:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107126:	8b 45 0c             	mov    0xc(%ebp),%eax
80107129:	89 10                	mov    %edx,(%eax)
  if(pf)
8010712b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010712f:	74 08                	je     80107139 <argfd+0x6e>
    *pf = f;
80107131:	8b 45 10             	mov    0x10(%ebp),%eax
80107134:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107137:	89 10                	mov    %edx,(%eax)
  return 0;
80107139:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010713e:	c9                   	leave  
8010713f:	c3                   	ret    

80107140 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80107140:	55                   	push   %ebp
80107141:	89 e5                	mov    %esp,%ebp
80107143:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80107146:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010714d:	eb 30                	jmp    8010717f <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
8010714f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107155:	8b 55 fc             	mov    -0x4(%ebp),%edx
80107158:	83 c2 08             	add    $0x8,%edx
8010715b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010715f:	85 c0                	test   %eax,%eax
80107161:	75 18                	jne    8010717b <fdalloc+0x3b>
      proc->ofile[fd] = f;
80107163:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107169:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010716c:	8d 4a 08             	lea    0x8(%edx),%ecx
8010716f:	8b 55 08             	mov    0x8(%ebp),%edx
80107172:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80107176:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107179:	eb 0f                	jmp    8010718a <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
8010717b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010717f:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80107183:	7e ca                	jle    8010714f <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80107185:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010718a:	c9                   	leave  
8010718b:	c3                   	ret    

8010718c <sys_dup>:

int
sys_dup(void)
{
8010718c:	55                   	push   %ebp
8010718d:	89 e5                	mov    %esp,%ebp
8010718f:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80107192:	83 ec 04             	sub    $0x4,%esp
80107195:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107198:	50                   	push   %eax
80107199:	6a 00                	push   $0x0
8010719b:	6a 00                	push   $0x0
8010719d:	e8 29 ff ff ff       	call   801070cb <argfd>
801071a2:	83 c4 10             	add    $0x10,%esp
801071a5:	85 c0                	test   %eax,%eax
801071a7:	79 07                	jns    801071b0 <sys_dup+0x24>
    return -1;
801071a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071ae:	eb 31                	jmp    801071e1 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801071b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801071b3:	83 ec 0c             	sub    $0xc,%esp
801071b6:	50                   	push   %eax
801071b7:	e8 84 ff ff ff       	call   80107140 <fdalloc>
801071bc:	83 c4 10             	add    $0x10,%esp
801071bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
801071c2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801071c6:	79 07                	jns    801071cf <sys_dup+0x43>
    return -1;
801071c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071cd:	eb 12                	jmp    801071e1 <sys_dup+0x55>
  filedup(f);
801071cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801071d2:	83 ec 0c             	sub    $0xc,%esp
801071d5:	50                   	push   %eax
801071d6:	e8 8c 9f ff ff       	call   80101167 <filedup>
801071db:	83 c4 10             	add    $0x10,%esp
  return fd;
801071de:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801071e1:	c9                   	leave  
801071e2:	c3                   	ret    

801071e3 <sys_read>:

int
sys_read(void)
{
801071e3:	55                   	push   %ebp
801071e4:	89 e5                	mov    %esp,%ebp
801071e6:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801071e9:	83 ec 04             	sub    $0x4,%esp
801071ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
801071ef:	50                   	push   %eax
801071f0:	6a 00                	push   $0x0
801071f2:	6a 00                	push   $0x0
801071f4:	e8 d2 fe ff ff       	call   801070cb <argfd>
801071f9:	83 c4 10             	add    $0x10,%esp
801071fc:	85 c0                	test   %eax,%eax
801071fe:	78 2e                	js     8010722e <sys_read+0x4b>
80107200:	83 ec 08             	sub    $0x8,%esp
80107203:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107206:	50                   	push   %eax
80107207:	6a 02                	push   $0x2
80107209:	e8 81 fd ff ff       	call   80106f8f <argint>
8010720e:	83 c4 10             	add    $0x10,%esp
80107211:	85 c0                	test   %eax,%eax
80107213:	78 19                	js     8010722e <sys_read+0x4b>
80107215:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107218:	83 ec 04             	sub    $0x4,%esp
8010721b:	50                   	push   %eax
8010721c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010721f:	50                   	push   %eax
80107220:	6a 01                	push   $0x1
80107222:	e8 90 fd ff ff       	call   80106fb7 <argptr>
80107227:	83 c4 10             	add    $0x10,%esp
8010722a:	85 c0                	test   %eax,%eax
8010722c:	79 07                	jns    80107235 <sys_read+0x52>
    return -1;
8010722e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107233:	eb 17                	jmp    8010724c <sys_read+0x69>
  return fileread(f, p, n);
80107235:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80107238:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010723b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010723e:	83 ec 04             	sub    $0x4,%esp
80107241:	51                   	push   %ecx
80107242:	52                   	push   %edx
80107243:	50                   	push   %eax
80107244:	e8 ae a0 ff ff       	call   801012f7 <fileread>
80107249:	83 c4 10             	add    $0x10,%esp
}
8010724c:	c9                   	leave  
8010724d:	c3                   	ret    

8010724e <sys_write>:

int
sys_write(void)
{
8010724e:	55                   	push   %ebp
8010724f:	89 e5                	mov    %esp,%ebp
80107251:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80107254:	83 ec 04             	sub    $0x4,%esp
80107257:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010725a:	50                   	push   %eax
8010725b:	6a 00                	push   $0x0
8010725d:	6a 00                	push   $0x0
8010725f:	e8 67 fe ff ff       	call   801070cb <argfd>
80107264:	83 c4 10             	add    $0x10,%esp
80107267:	85 c0                	test   %eax,%eax
80107269:	78 2e                	js     80107299 <sys_write+0x4b>
8010726b:	83 ec 08             	sub    $0x8,%esp
8010726e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107271:	50                   	push   %eax
80107272:	6a 02                	push   $0x2
80107274:	e8 16 fd ff ff       	call   80106f8f <argint>
80107279:	83 c4 10             	add    $0x10,%esp
8010727c:	85 c0                	test   %eax,%eax
8010727e:	78 19                	js     80107299 <sys_write+0x4b>
80107280:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107283:	83 ec 04             	sub    $0x4,%esp
80107286:	50                   	push   %eax
80107287:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010728a:	50                   	push   %eax
8010728b:	6a 01                	push   $0x1
8010728d:	e8 25 fd ff ff       	call   80106fb7 <argptr>
80107292:	83 c4 10             	add    $0x10,%esp
80107295:	85 c0                	test   %eax,%eax
80107297:	79 07                	jns    801072a0 <sys_write+0x52>
    return -1;
80107299:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010729e:	eb 17                	jmp    801072b7 <sys_write+0x69>
  return filewrite(f, p, n);
801072a0:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801072a3:	8b 55 ec             	mov    -0x14(%ebp),%edx
801072a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072a9:	83 ec 04             	sub    $0x4,%esp
801072ac:	51                   	push   %ecx
801072ad:	52                   	push   %edx
801072ae:	50                   	push   %eax
801072af:	e8 fb a0 ff ff       	call   801013af <filewrite>
801072b4:	83 c4 10             	add    $0x10,%esp
}
801072b7:	c9                   	leave  
801072b8:	c3                   	ret    

801072b9 <sys_close>:

int
sys_close(void)
{
801072b9:	55                   	push   %ebp
801072ba:	89 e5                	mov    %esp,%ebp
801072bc:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
801072bf:	83 ec 04             	sub    $0x4,%esp
801072c2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801072c5:	50                   	push   %eax
801072c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801072c9:	50                   	push   %eax
801072ca:	6a 00                	push   $0x0
801072cc:	e8 fa fd ff ff       	call   801070cb <argfd>
801072d1:	83 c4 10             	add    $0x10,%esp
801072d4:	85 c0                	test   %eax,%eax
801072d6:	79 07                	jns    801072df <sys_close+0x26>
    return -1;
801072d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801072dd:	eb 28                	jmp    80107307 <sys_close+0x4e>
  proc->ofile[fd] = 0;
801072df:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801072e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801072e8:	83 c2 08             	add    $0x8,%edx
801072eb:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801072f2:	00 
  fileclose(f);
801072f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801072f6:	83 ec 0c             	sub    $0xc,%esp
801072f9:	50                   	push   %eax
801072fa:	e8 b9 9e ff ff       	call   801011b8 <fileclose>
801072ff:	83 c4 10             	add    $0x10,%esp
  return 0;
80107302:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107307:	c9                   	leave  
80107308:	c3                   	ret    

80107309 <sys_fstat>:

int
sys_fstat(void)
{
80107309:	55                   	push   %ebp
8010730a:	89 e5                	mov    %esp,%ebp
8010730c:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010730f:	83 ec 04             	sub    $0x4,%esp
80107312:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107315:	50                   	push   %eax
80107316:	6a 00                	push   $0x0
80107318:	6a 00                	push   $0x0
8010731a:	e8 ac fd ff ff       	call   801070cb <argfd>
8010731f:	83 c4 10             	add    $0x10,%esp
80107322:	85 c0                	test   %eax,%eax
80107324:	78 17                	js     8010733d <sys_fstat+0x34>
80107326:	83 ec 04             	sub    $0x4,%esp
80107329:	6a 1c                	push   $0x1c
8010732b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010732e:	50                   	push   %eax
8010732f:	6a 01                	push   $0x1
80107331:	e8 81 fc ff ff       	call   80106fb7 <argptr>
80107336:	83 c4 10             	add    $0x10,%esp
80107339:	85 c0                	test   %eax,%eax
8010733b:	79 07                	jns    80107344 <sys_fstat+0x3b>
    return -1;
8010733d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107342:	eb 13                	jmp    80107357 <sys_fstat+0x4e>
  return filestat(f, st);
80107344:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107347:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010734a:	83 ec 08             	sub    $0x8,%esp
8010734d:	52                   	push   %edx
8010734e:	50                   	push   %eax
8010734f:	e8 4c 9f ff ff       	call   801012a0 <filestat>
80107354:	83 c4 10             	add    $0x10,%esp
}
80107357:	c9                   	leave  
80107358:	c3                   	ret    

80107359 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80107359:	55                   	push   %ebp
8010735a:	89 e5                	mov    %esp,%ebp
8010735c:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010735f:	83 ec 08             	sub    $0x8,%esp
80107362:	8d 45 d8             	lea    -0x28(%ebp),%eax
80107365:	50                   	push   %eax
80107366:	6a 00                	push   $0x0
80107368:	e8 a7 fc ff ff       	call   80107014 <argstr>
8010736d:	83 c4 10             	add    $0x10,%esp
80107370:	85 c0                	test   %eax,%eax
80107372:	78 15                	js     80107389 <sys_link+0x30>
80107374:	83 ec 08             	sub    $0x8,%esp
80107377:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010737a:	50                   	push   %eax
8010737b:	6a 01                	push   $0x1
8010737d:	e8 92 fc ff ff       	call   80107014 <argstr>
80107382:	83 c4 10             	add    $0x10,%esp
80107385:	85 c0                	test   %eax,%eax
80107387:	79 0a                	jns    80107393 <sys_link+0x3a>
    return -1;
80107389:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010738e:	e9 68 01 00 00       	jmp    801074fb <sys_link+0x1a2>

  begin_op();
80107393:	e8 54 c5 ff ff       	call   801038ec <begin_op>
  if((ip = namei(old)) == 0){
80107398:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010739b:	83 ec 0c             	sub    $0xc,%esp
8010739e:	50                   	push   %eax
8010739f:	e8 7f b3 ff ff       	call   80102723 <namei>
801073a4:	83 c4 10             	add    $0x10,%esp
801073a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801073aa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801073ae:	75 0f                	jne    801073bf <sys_link+0x66>
    end_op();
801073b0:	e8 c3 c5 ff ff       	call   80103978 <end_op>
    return -1;
801073b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801073ba:	e9 3c 01 00 00       	jmp    801074fb <sys_link+0x1a2>
  }

  ilock(ip);
801073bf:	83 ec 0c             	sub    $0xc,%esp
801073c2:	ff 75 f4             	pushl  -0xc(%ebp)
801073c5:	e8 4b a7 ff ff       	call   80101b15 <ilock>
801073ca:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
801073cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073d0:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801073d4:	66 83 f8 01          	cmp    $0x1,%ax
801073d8:	75 1d                	jne    801073f7 <sys_link+0x9e>
    iunlockput(ip);
801073da:	83 ec 0c             	sub    $0xc,%esp
801073dd:	ff 75 f4             	pushl  -0xc(%ebp)
801073e0:	e8 18 aa ff ff       	call   80101dfd <iunlockput>
801073e5:	83 c4 10             	add    $0x10,%esp
    end_op();
801073e8:	e8 8b c5 ff ff       	call   80103978 <end_op>
    return -1;
801073ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801073f2:	e9 04 01 00 00       	jmp    801074fb <sys_link+0x1a2>
  }

  ip->nlink++;
801073f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073fa:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801073fe:	83 c0 01             	add    $0x1,%eax
80107401:	89 c2                	mov    %eax,%edx
80107403:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107406:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
8010740a:	83 ec 0c             	sub    $0xc,%esp
8010740d:	ff 75 f4             	pushl  -0xc(%ebp)
80107410:	e8 fe a4 ff ff       	call   80101913 <iupdate>
80107415:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80107418:	83 ec 0c             	sub    $0xc,%esp
8010741b:	ff 75 f4             	pushl  -0xc(%ebp)
8010741e:	e8 78 a8 ff ff       	call   80101c9b <iunlock>
80107423:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80107426:	8b 45 dc             	mov    -0x24(%ebp),%eax
80107429:	83 ec 08             	sub    $0x8,%esp
8010742c:	8d 55 e2             	lea    -0x1e(%ebp),%edx
8010742f:	52                   	push   %edx
80107430:	50                   	push   %eax
80107431:	e8 09 b3 ff ff       	call   8010273f <nameiparent>
80107436:	83 c4 10             	add    $0x10,%esp
80107439:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010743c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107440:	74 71                	je     801074b3 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80107442:	83 ec 0c             	sub    $0xc,%esp
80107445:	ff 75 f0             	pushl  -0x10(%ebp)
80107448:	e8 c8 a6 ff ff       	call   80101b15 <ilock>
8010744d:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80107450:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107453:	8b 10                	mov    (%eax),%edx
80107455:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107458:	8b 00                	mov    (%eax),%eax
8010745a:	39 c2                	cmp    %eax,%edx
8010745c:	75 1d                	jne    8010747b <sys_link+0x122>
8010745e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107461:	8b 40 04             	mov    0x4(%eax),%eax
80107464:	83 ec 04             	sub    $0x4,%esp
80107467:	50                   	push   %eax
80107468:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010746b:	50                   	push   %eax
8010746c:	ff 75 f0             	pushl  -0x10(%ebp)
8010746f:	e8 13 b0 ff ff       	call   80102487 <dirlink>
80107474:	83 c4 10             	add    $0x10,%esp
80107477:	85 c0                	test   %eax,%eax
80107479:	79 10                	jns    8010748b <sys_link+0x132>
    iunlockput(dp);
8010747b:	83 ec 0c             	sub    $0xc,%esp
8010747e:	ff 75 f0             	pushl  -0x10(%ebp)
80107481:	e8 77 a9 ff ff       	call   80101dfd <iunlockput>
80107486:	83 c4 10             	add    $0x10,%esp
    goto bad;
80107489:	eb 29                	jmp    801074b4 <sys_link+0x15b>
  }
  iunlockput(dp);
8010748b:	83 ec 0c             	sub    $0xc,%esp
8010748e:	ff 75 f0             	pushl  -0x10(%ebp)
80107491:	e8 67 a9 ff ff       	call   80101dfd <iunlockput>
80107496:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80107499:	83 ec 0c             	sub    $0xc,%esp
8010749c:	ff 75 f4             	pushl  -0xc(%ebp)
8010749f:	e8 69 a8 ff ff       	call   80101d0d <iput>
801074a4:	83 c4 10             	add    $0x10,%esp

  end_op();
801074a7:	e8 cc c4 ff ff       	call   80103978 <end_op>

  return 0;
801074ac:	b8 00 00 00 00       	mov    $0x0,%eax
801074b1:	eb 48                	jmp    801074fb <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
801074b3:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
801074b4:	83 ec 0c             	sub    $0xc,%esp
801074b7:	ff 75 f4             	pushl  -0xc(%ebp)
801074ba:	e8 56 a6 ff ff       	call   80101b15 <ilock>
801074bf:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
801074c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074c5:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801074c9:	83 e8 01             	sub    $0x1,%eax
801074cc:	89 c2                	mov    %eax,%edx
801074ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074d1:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801074d5:	83 ec 0c             	sub    $0xc,%esp
801074d8:	ff 75 f4             	pushl  -0xc(%ebp)
801074db:	e8 33 a4 ff ff       	call   80101913 <iupdate>
801074e0:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801074e3:	83 ec 0c             	sub    $0xc,%esp
801074e6:	ff 75 f4             	pushl  -0xc(%ebp)
801074e9:	e8 0f a9 ff ff       	call   80101dfd <iunlockput>
801074ee:	83 c4 10             	add    $0x10,%esp
  end_op();
801074f1:	e8 82 c4 ff ff       	call   80103978 <end_op>
  return -1;
801074f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801074fb:	c9                   	leave  
801074fc:	c3                   	ret    

801074fd <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801074fd:	55                   	push   %ebp
801074fe:	89 e5                	mov    %esp,%ebp
80107500:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80107503:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
8010750a:	eb 40                	jmp    8010754c <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010750c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010750f:	6a 10                	push   $0x10
80107511:	50                   	push   %eax
80107512:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80107515:	50                   	push   %eax
80107516:	ff 75 08             	pushl  0x8(%ebp)
80107519:	e8 b5 ab ff ff       	call   801020d3 <readi>
8010751e:	83 c4 10             	add    $0x10,%esp
80107521:	83 f8 10             	cmp    $0x10,%eax
80107524:	74 0d                	je     80107533 <isdirempty+0x36>
      panic("isdirempty: readi");
80107526:	83 ec 0c             	sub    $0xc,%esp
80107529:	68 be aa 10 80       	push   $0x8010aabe
8010752e:	e8 33 90 ff ff       	call   80100566 <panic>
    if(de.inum != 0)
80107533:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80107537:	66 85 c0             	test   %ax,%ax
8010753a:	74 07                	je     80107543 <isdirempty+0x46>
      return 0;
8010753c:	b8 00 00 00 00       	mov    $0x0,%eax
80107541:	eb 1b                	jmp    8010755e <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80107543:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107546:	83 c0 10             	add    $0x10,%eax
80107549:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010754c:	8b 45 08             	mov    0x8(%ebp),%eax
8010754f:	8b 50 20             	mov    0x20(%eax),%edx
80107552:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107555:	39 c2                	cmp    %eax,%edx
80107557:	77 b3                	ja     8010750c <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80107559:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010755e:	c9                   	leave  
8010755f:	c3                   	ret    

80107560 <sys_unlink>:

int
sys_unlink(void)
{
80107560:	55                   	push   %ebp
80107561:	89 e5                	mov    %esp,%ebp
80107563:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80107566:	83 ec 08             	sub    $0x8,%esp
80107569:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010756c:	50                   	push   %eax
8010756d:	6a 00                	push   $0x0
8010756f:	e8 a0 fa ff ff       	call   80107014 <argstr>
80107574:	83 c4 10             	add    $0x10,%esp
80107577:	85 c0                	test   %eax,%eax
80107579:	79 0a                	jns    80107585 <sys_unlink+0x25>
    return -1;
8010757b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107580:	e9 bc 01 00 00       	jmp    80107741 <sys_unlink+0x1e1>

  begin_op();
80107585:	e8 62 c3 ff ff       	call   801038ec <begin_op>
  if((dp = nameiparent(path, name)) == 0){
8010758a:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010758d:	83 ec 08             	sub    $0x8,%esp
80107590:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80107593:	52                   	push   %edx
80107594:	50                   	push   %eax
80107595:	e8 a5 b1 ff ff       	call   8010273f <nameiparent>
8010759a:	83 c4 10             	add    $0x10,%esp
8010759d:	89 45 f4             	mov    %eax,-0xc(%ebp)
801075a0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801075a4:	75 0f                	jne    801075b5 <sys_unlink+0x55>
    end_op();
801075a6:	e8 cd c3 ff ff       	call   80103978 <end_op>
    return -1;
801075ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801075b0:	e9 8c 01 00 00       	jmp    80107741 <sys_unlink+0x1e1>
  }

  ilock(dp);
801075b5:	83 ec 0c             	sub    $0xc,%esp
801075b8:	ff 75 f4             	pushl  -0xc(%ebp)
801075bb:	e8 55 a5 ff ff       	call   80101b15 <ilock>
801075c0:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801075c3:	83 ec 08             	sub    $0x8,%esp
801075c6:	68 d0 aa 10 80       	push   $0x8010aad0
801075cb:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801075ce:	50                   	push   %eax
801075cf:	e8 de ad ff ff       	call   801023b2 <namecmp>
801075d4:	83 c4 10             	add    $0x10,%esp
801075d7:	85 c0                	test   %eax,%eax
801075d9:	0f 84 4a 01 00 00    	je     80107729 <sys_unlink+0x1c9>
801075df:	83 ec 08             	sub    $0x8,%esp
801075e2:	68 d2 aa 10 80       	push   $0x8010aad2
801075e7:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801075ea:	50                   	push   %eax
801075eb:	e8 c2 ad ff ff       	call   801023b2 <namecmp>
801075f0:	83 c4 10             	add    $0x10,%esp
801075f3:	85 c0                	test   %eax,%eax
801075f5:	0f 84 2e 01 00 00    	je     80107729 <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801075fb:	83 ec 04             	sub    $0x4,%esp
801075fe:	8d 45 c8             	lea    -0x38(%ebp),%eax
80107601:	50                   	push   %eax
80107602:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80107605:	50                   	push   %eax
80107606:	ff 75 f4             	pushl  -0xc(%ebp)
80107609:	e8 bf ad ff ff       	call   801023cd <dirlookup>
8010760e:	83 c4 10             	add    $0x10,%esp
80107611:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107614:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107618:	0f 84 0a 01 00 00    	je     80107728 <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
8010761e:	83 ec 0c             	sub    $0xc,%esp
80107621:	ff 75 f0             	pushl  -0x10(%ebp)
80107624:	e8 ec a4 ff ff       	call   80101b15 <ilock>
80107629:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
8010762c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010762f:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80107633:	66 85 c0             	test   %ax,%ax
80107636:	7f 0d                	jg     80107645 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80107638:	83 ec 0c             	sub    $0xc,%esp
8010763b:	68 d5 aa 10 80       	push   $0x8010aad5
80107640:	e8 21 8f ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80107645:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107648:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010764c:	66 83 f8 01          	cmp    $0x1,%ax
80107650:	75 25                	jne    80107677 <sys_unlink+0x117>
80107652:	83 ec 0c             	sub    $0xc,%esp
80107655:	ff 75 f0             	pushl  -0x10(%ebp)
80107658:	e8 a0 fe ff ff       	call   801074fd <isdirempty>
8010765d:	83 c4 10             	add    $0x10,%esp
80107660:	85 c0                	test   %eax,%eax
80107662:	75 13                	jne    80107677 <sys_unlink+0x117>
    iunlockput(ip);
80107664:	83 ec 0c             	sub    $0xc,%esp
80107667:	ff 75 f0             	pushl  -0x10(%ebp)
8010766a:	e8 8e a7 ff ff       	call   80101dfd <iunlockput>
8010766f:	83 c4 10             	add    $0x10,%esp
    goto bad;
80107672:	e9 b2 00 00 00       	jmp    80107729 <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
80107677:	83 ec 04             	sub    $0x4,%esp
8010767a:	6a 10                	push   $0x10
8010767c:	6a 00                	push   $0x0
8010767e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80107681:	50                   	push   %eax
80107682:	e8 e3 f5 ff ff       	call   80106c6a <memset>
80107687:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010768a:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010768d:	6a 10                	push   $0x10
8010768f:	50                   	push   %eax
80107690:	8d 45 e0             	lea    -0x20(%ebp),%eax
80107693:	50                   	push   %eax
80107694:	ff 75 f4             	pushl  -0xc(%ebp)
80107697:	e8 8e ab ff ff       	call   8010222a <writei>
8010769c:	83 c4 10             	add    $0x10,%esp
8010769f:	83 f8 10             	cmp    $0x10,%eax
801076a2:	74 0d                	je     801076b1 <sys_unlink+0x151>
    panic("unlink: writei");
801076a4:	83 ec 0c             	sub    $0xc,%esp
801076a7:	68 e7 aa 10 80       	push   $0x8010aae7
801076ac:	e8 b5 8e ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR){
801076b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801076b4:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801076b8:	66 83 f8 01          	cmp    $0x1,%ax
801076bc:	75 21                	jne    801076df <sys_unlink+0x17f>
    dp->nlink--;
801076be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076c1:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801076c5:	83 e8 01             	sub    $0x1,%eax
801076c8:	89 c2                	mov    %eax,%edx
801076ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076cd:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
801076d1:	83 ec 0c             	sub    $0xc,%esp
801076d4:	ff 75 f4             	pushl  -0xc(%ebp)
801076d7:	e8 37 a2 ff ff       	call   80101913 <iupdate>
801076dc:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
801076df:	83 ec 0c             	sub    $0xc,%esp
801076e2:	ff 75 f4             	pushl  -0xc(%ebp)
801076e5:	e8 13 a7 ff ff       	call   80101dfd <iunlockput>
801076ea:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
801076ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801076f0:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801076f4:	83 e8 01             	sub    $0x1,%eax
801076f7:	89 c2                	mov    %eax,%edx
801076f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801076fc:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80107700:	83 ec 0c             	sub    $0xc,%esp
80107703:	ff 75 f0             	pushl  -0x10(%ebp)
80107706:	e8 08 a2 ff ff       	call   80101913 <iupdate>
8010770b:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010770e:	83 ec 0c             	sub    $0xc,%esp
80107711:	ff 75 f0             	pushl  -0x10(%ebp)
80107714:	e8 e4 a6 ff ff       	call   80101dfd <iunlockput>
80107719:	83 c4 10             	add    $0x10,%esp

  end_op();
8010771c:	e8 57 c2 ff ff       	call   80103978 <end_op>

  return 0;
80107721:	b8 00 00 00 00       	mov    $0x0,%eax
80107726:	eb 19                	jmp    80107741 <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80107728:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
80107729:	83 ec 0c             	sub    $0xc,%esp
8010772c:	ff 75 f4             	pushl  -0xc(%ebp)
8010772f:	e8 c9 a6 ff ff       	call   80101dfd <iunlockput>
80107734:	83 c4 10             	add    $0x10,%esp
  end_op();
80107737:	e8 3c c2 ff ff       	call   80103978 <end_op>
  return -1;
8010773c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80107741:	c9                   	leave  
80107742:	c3                   	ret    

80107743 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80107743:	55                   	push   %ebp
80107744:	89 e5                	mov    %esp,%ebp
80107746:	83 ec 38             	sub    $0x38,%esp
80107749:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010774c:	8b 55 10             	mov    0x10(%ebp),%edx
8010774f:	8b 45 14             	mov    0x14(%ebp),%eax
80107752:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80107756:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
8010775a:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010775e:	83 ec 08             	sub    $0x8,%esp
80107761:	8d 45 de             	lea    -0x22(%ebp),%eax
80107764:	50                   	push   %eax
80107765:	ff 75 08             	pushl  0x8(%ebp)
80107768:	e8 d2 af ff ff       	call   8010273f <nameiparent>
8010776d:	83 c4 10             	add    $0x10,%esp
80107770:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107773:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107777:	75 0a                	jne    80107783 <create+0x40>
    return 0;
80107779:	b8 00 00 00 00       	mov    $0x0,%eax
8010777e:	e9 90 01 00 00       	jmp    80107913 <create+0x1d0>
  ilock(dp);
80107783:	83 ec 0c             	sub    $0xc,%esp
80107786:	ff 75 f4             	pushl  -0xc(%ebp)
80107789:	e8 87 a3 ff ff       	call   80101b15 <ilock>
8010778e:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80107791:	83 ec 04             	sub    $0x4,%esp
80107794:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107797:	50                   	push   %eax
80107798:	8d 45 de             	lea    -0x22(%ebp),%eax
8010779b:	50                   	push   %eax
8010779c:	ff 75 f4             	pushl  -0xc(%ebp)
8010779f:	e8 29 ac ff ff       	call   801023cd <dirlookup>
801077a4:	83 c4 10             	add    $0x10,%esp
801077a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801077aa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801077ae:	74 50                	je     80107800 <create+0xbd>
    iunlockput(dp);
801077b0:	83 ec 0c             	sub    $0xc,%esp
801077b3:	ff 75 f4             	pushl  -0xc(%ebp)
801077b6:	e8 42 a6 ff ff       	call   80101dfd <iunlockput>
801077bb:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
801077be:	83 ec 0c             	sub    $0xc,%esp
801077c1:	ff 75 f0             	pushl  -0x10(%ebp)
801077c4:	e8 4c a3 ff ff       	call   80101b15 <ilock>
801077c9:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
801077cc:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801077d1:	75 15                	jne    801077e8 <create+0xa5>
801077d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801077d6:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801077da:	66 83 f8 02          	cmp    $0x2,%ax
801077de:	75 08                	jne    801077e8 <create+0xa5>
      return ip;
801077e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801077e3:	e9 2b 01 00 00       	jmp    80107913 <create+0x1d0>
    iunlockput(ip);
801077e8:	83 ec 0c             	sub    $0xc,%esp
801077eb:	ff 75 f0             	pushl  -0x10(%ebp)
801077ee:	e8 0a a6 ff ff       	call   80101dfd <iunlockput>
801077f3:	83 c4 10             	add    $0x10,%esp
    return 0;
801077f6:	b8 00 00 00 00       	mov    $0x0,%eax
801077fb:	e9 13 01 00 00       	jmp    80107913 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80107800:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80107804:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107807:	8b 00                	mov    (%eax),%eax
80107809:	83 ec 08             	sub    $0x8,%esp
8010780c:	52                   	push   %edx
8010780d:	50                   	push   %eax
8010780e:	e8 0d a0 ff ff       	call   80101820 <ialloc>
80107813:	83 c4 10             	add    $0x10,%esp
80107816:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107819:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010781d:	75 0d                	jne    8010782c <create+0xe9>
    panic("create: ialloc");
8010781f:	83 ec 0c             	sub    $0xc,%esp
80107822:	68 f6 aa 10 80       	push   $0x8010aaf6
80107827:	e8 3a 8d ff ff       	call   80100566 <panic>

  ilock(ip);
8010782c:	83 ec 0c             	sub    $0xc,%esp
8010782f:	ff 75 f0             	pushl  -0x10(%ebp)
80107832:	e8 de a2 ff ff       	call   80101b15 <ilock>
80107837:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
8010783a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010783d:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80107841:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80107845:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107848:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
8010784c:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80107850:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107853:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80107859:	83 ec 0c             	sub    $0xc,%esp
8010785c:	ff 75 f0             	pushl  -0x10(%ebp)
8010785f:	e8 af a0 ff ff       	call   80101913 <iupdate>
80107864:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80107867:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
8010786c:	75 6a                	jne    801078d8 <create+0x195>
    dp->nlink++;  // for ".."
8010786e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107871:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80107875:	83 c0 01             	add    $0x1,%eax
80107878:	89 c2                	mov    %eax,%edx
8010787a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010787d:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80107881:	83 ec 0c             	sub    $0xc,%esp
80107884:	ff 75 f4             	pushl  -0xc(%ebp)
80107887:	e8 87 a0 ff ff       	call   80101913 <iupdate>
8010788c:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010788f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107892:	8b 40 04             	mov    0x4(%eax),%eax
80107895:	83 ec 04             	sub    $0x4,%esp
80107898:	50                   	push   %eax
80107899:	68 d0 aa 10 80       	push   $0x8010aad0
8010789e:	ff 75 f0             	pushl  -0x10(%ebp)
801078a1:	e8 e1 ab ff ff       	call   80102487 <dirlink>
801078a6:	83 c4 10             	add    $0x10,%esp
801078a9:	85 c0                	test   %eax,%eax
801078ab:	78 1e                	js     801078cb <create+0x188>
801078ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078b0:	8b 40 04             	mov    0x4(%eax),%eax
801078b3:	83 ec 04             	sub    $0x4,%esp
801078b6:	50                   	push   %eax
801078b7:	68 d2 aa 10 80       	push   $0x8010aad2
801078bc:	ff 75 f0             	pushl  -0x10(%ebp)
801078bf:	e8 c3 ab ff ff       	call   80102487 <dirlink>
801078c4:	83 c4 10             	add    $0x10,%esp
801078c7:	85 c0                	test   %eax,%eax
801078c9:	79 0d                	jns    801078d8 <create+0x195>
      panic("create dots");
801078cb:	83 ec 0c             	sub    $0xc,%esp
801078ce:	68 05 ab 10 80       	push   $0x8010ab05
801078d3:	e8 8e 8c ff ff       	call   80100566 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801078d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078db:	8b 40 04             	mov    0x4(%eax),%eax
801078de:	83 ec 04             	sub    $0x4,%esp
801078e1:	50                   	push   %eax
801078e2:	8d 45 de             	lea    -0x22(%ebp),%eax
801078e5:	50                   	push   %eax
801078e6:	ff 75 f4             	pushl  -0xc(%ebp)
801078e9:	e8 99 ab ff ff       	call   80102487 <dirlink>
801078ee:	83 c4 10             	add    $0x10,%esp
801078f1:	85 c0                	test   %eax,%eax
801078f3:	79 0d                	jns    80107902 <create+0x1bf>
    panic("create: dirlink");
801078f5:	83 ec 0c             	sub    $0xc,%esp
801078f8:	68 11 ab 10 80       	push   $0x8010ab11
801078fd:	e8 64 8c ff ff       	call   80100566 <panic>

  iunlockput(dp);
80107902:	83 ec 0c             	sub    $0xc,%esp
80107905:	ff 75 f4             	pushl  -0xc(%ebp)
80107908:	e8 f0 a4 ff ff       	call   80101dfd <iunlockput>
8010790d:	83 c4 10             	add    $0x10,%esp

  return ip;
80107910:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107913:	c9                   	leave  
80107914:	c3                   	ret    

80107915 <sys_open>:

int
sys_open(void)
{
80107915:	55                   	push   %ebp
80107916:	89 e5                	mov    %esp,%ebp
80107918:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
8010791b:	83 ec 08             	sub    $0x8,%esp
8010791e:	8d 45 e8             	lea    -0x18(%ebp),%eax
80107921:	50                   	push   %eax
80107922:	6a 00                	push   $0x0
80107924:	e8 eb f6 ff ff       	call   80107014 <argstr>
80107929:	83 c4 10             	add    $0x10,%esp
8010792c:	85 c0                	test   %eax,%eax
8010792e:	78 15                	js     80107945 <sys_open+0x30>
80107930:	83 ec 08             	sub    $0x8,%esp
80107933:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80107936:	50                   	push   %eax
80107937:	6a 01                	push   $0x1
80107939:	e8 51 f6 ff ff       	call   80106f8f <argint>
8010793e:	83 c4 10             	add    $0x10,%esp
80107941:	85 c0                	test   %eax,%eax
80107943:	79 0a                	jns    8010794f <sys_open+0x3a>
    return -1;
80107945:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010794a:	e9 61 01 00 00       	jmp    80107ab0 <sys_open+0x19b>

  begin_op();
8010794f:	e8 98 bf ff ff       	call   801038ec <begin_op>

  if(omode & O_CREATE){
80107954:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107957:	25 00 02 00 00       	and    $0x200,%eax
8010795c:	85 c0                	test   %eax,%eax
8010795e:	74 2a                	je     8010798a <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80107960:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107963:	6a 00                	push   $0x0
80107965:	6a 00                	push   $0x0
80107967:	6a 02                	push   $0x2
80107969:	50                   	push   %eax
8010796a:	e8 d4 fd ff ff       	call   80107743 <create>
8010796f:	83 c4 10             	add    $0x10,%esp
80107972:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80107975:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107979:	75 75                	jne    801079f0 <sys_open+0xdb>
      end_op();
8010797b:	e8 f8 bf ff ff       	call   80103978 <end_op>
      return -1;
80107980:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107985:	e9 26 01 00 00       	jmp    80107ab0 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
8010798a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010798d:	83 ec 0c             	sub    $0xc,%esp
80107990:	50                   	push   %eax
80107991:	e8 8d ad ff ff       	call   80102723 <namei>
80107996:	83 c4 10             	add    $0x10,%esp
80107999:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010799c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801079a0:	75 0f                	jne    801079b1 <sys_open+0x9c>
      end_op();
801079a2:	e8 d1 bf ff ff       	call   80103978 <end_op>
      return -1;
801079a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801079ac:	e9 ff 00 00 00       	jmp    80107ab0 <sys_open+0x19b>
    }
    ilock(ip);
801079b1:	83 ec 0c             	sub    $0xc,%esp
801079b4:	ff 75 f4             	pushl  -0xc(%ebp)
801079b7:	e8 59 a1 ff ff       	call   80101b15 <ilock>
801079bc:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
801079bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c2:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801079c6:	66 83 f8 01          	cmp    $0x1,%ax
801079ca:	75 24                	jne    801079f0 <sys_open+0xdb>
801079cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801079cf:	85 c0                	test   %eax,%eax
801079d1:	74 1d                	je     801079f0 <sys_open+0xdb>
      iunlockput(ip);
801079d3:	83 ec 0c             	sub    $0xc,%esp
801079d6:	ff 75 f4             	pushl  -0xc(%ebp)
801079d9:	e8 1f a4 ff ff       	call   80101dfd <iunlockput>
801079de:	83 c4 10             	add    $0x10,%esp
      end_op();
801079e1:	e8 92 bf ff ff       	call   80103978 <end_op>
      return -1;
801079e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801079eb:	e9 c0 00 00 00       	jmp    80107ab0 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801079f0:	e8 05 97 ff ff       	call   801010fa <filealloc>
801079f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801079f8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801079fc:	74 17                	je     80107a15 <sys_open+0x100>
801079fe:	83 ec 0c             	sub    $0xc,%esp
80107a01:	ff 75 f0             	pushl  -0x10(%ebp)
80107a04:	e8 37 f7 ff ff       	call   80107140 <fdalloc>
80107a09:	83 c4 10             	add    $0x10,%esp
80107a0c:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107a0f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107a13:	79 2e                	jns    80107a43 <sys_open+0x12e>
    if(f)
80107a15:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107a19:	74 0e                	je     80107a29 <sys_open+0x114>
      fileclose(f);
80107a1b:	83 ec 0c             	sub    $0xc,%esp
80107a1e:	ff 75 f0             	pushl  -0x10(%ebp)
80107a21:	e8 92 97 ff ff       	call   801011b8 <fileclose>
80107a26:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80107a29:	83 ec 0c             	sub    $0xc,%esp
80107a2c:	ff 75 f4             	pushl  -0xc(%ebp)
80107a2f:	e8 c9 a3 ff ff       	call   80101dfd <iunlockput>
80107a34:	83 c4 10             	add    $0x10,%esp
    end_op();
80107a37:	e8 3c bf ff ff       	call   80103978 <end_op>
    return -1;
80107a3c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107a41:	eb 6d                	jmp    80107ab0 <sys_open+0x19b>
  }
  iunlock(ip);
80107a43:	83 ec 0c             	sub    $0xc,%esp
80107a46:	ff 75 f4             	pushl  -0xc(%ebp)
80107a49:	e8 4d a2 ff ff       	call   80101c9b <iunlock>
80107a4e:	83 c4 10             	add    $0x10,%esp
  end_op();
80107a51:	e8 22 bf ff ff       	call   80103978 <end_op>

  f->type = FD_INODE;
80107a56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a59:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80107a5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a62:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107a65:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80107a68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a6b:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80107a72:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107a75:	83 e0 01             	and    $0x1,%eax
80107a78:	85 c0                	test   %eax,%eax
80107a7a:	0f 94 c0             	sete   %al
80107a7d:	89 c2                	mov    %eax,%edx
80107a7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a82:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80107a85:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107a88:	83 e0 01             	and    $0x1,%eax
80107a8b:	85 c0                	test   %eax,%eax
80107a8d:	75 0a                	jne    80107a99 <sys_open+0x184>
80107a8f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107a92:	83 e0 02             	and    $0x2,%eax
80107a95:	85 c0                	test   %eax,%eax
80107a97:	74 07                	je     80107aa0 <sys_open+0x18b>
80107a99:	b8 01 00 00 00       	mov    $0x1,%eax
80107a9e:	eb 05                	jmp    80107aa5 <sys_open+0x190>
80107aa0:	b8 00 00 00 00       	mov    $0x0,%eax
80107aa5:	89 c2                	mov    %eax,%edx
80107aa7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107aaa:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80107aad:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80107ab0:	c9                   	leave  
80107ab1:	c3                   	ret    

80107ab2 <sys_mkdir>:

int
sys_mkdir(void)
{
80107ab2:	55                   	push   %ebp
80107ab3:	89 e5                	mov    %esp,%ebp
80107ab5:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80107ab8:	e8 2f be ff ff       	call   801038ec <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80107abd:	83 ec 08             	sub    $0x8,%esp
80107ac0:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107ac3:	50                   	push   %eax
80107ac4:	6a 00                	push   $0x0
80107ac6:	e8 49 f5 ff ff       	call   80107014 <argstr>
80107acb:	83 c4 10             	add    $0x10,%esp
80107ace:	85 c0                	test   %eax,%eax
80107ad0:	78 1b                	js     80107aed <sys_mkdir+0x3b>
80107ad2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ad5:	6a 00                	push   $0x0
80107ad7:	6a 00                	push   $0x0
80107ad9:	6a 01                	push   $0x1
80107adb:	50                   	push   %eax
80107adc:	e8 62 fc ff ff       	call   80107743 <create>
80107ae1:	83 c4 10             	add    $0x10,%esp
80107ae4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107ae7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107aeb:	75 0c                	jne    80107af9 <sys_mkdir+0x47>
    end_op();
80107aed:	e8 86 be ff ff       	call   80103978 <end_op>
    return -1;
80107af2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107af7:	eb 18                	jmp    80107b11 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80107af9:	83 ec 0c             	sub    $0xc,%esp
80107afc:	ff 75 f4             	pushl  -0xc(%ebp)
80107aff:	e8 f9 a2 ff ff       	call   80101dfd <iunlockput>
80107b04:	83 c4 10             	add    $0x10,%esp
  end_op();
80107b07:	e8 6c be ff ff       	call   80103978 <end_op>
  return 0;
80107b0c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107b11:	c9                   	leave  
80107b12:	c3                   	ret    

80107b13 <sys_mknod>:

int
sys_mknod(void)
{
80107b13:	55                   	push   %ebp
80107b14:	89 e5                	mov    %esp,%ebp
80107b16:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80107b19:	e8 ce bd ff ff       	call   801038ec <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80107b1e:	83 ec 08             	sub    $0x8,%esp
80107b21:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107b24:	50                   	push   %eax
80107b25:	6a 00                	push   $0x0
80107b27:	e8 e8 f4 ff ff       	call   80107014 <argstr>
80107b2c:	83 c4 10             	add    $0x10,%esp
80107b2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107b32:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107b36:	78 4f                	js     80107b87 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
80107b38:	83 ec 08             	sub    $0x8,%esp
80107b3b:	8d 45 e8             	lea    -0x18(%ebp),%eax
80107b3e:	50                   	push   %eax
80107b3f:	6a 01                	push   $0x1
80107b41:	e8 49 f4 ff ff       	call   80106f8f <argint>
80107b46:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80107b49:	85 c0                	test   %eax,%eax
80107b4b:	78 3a                	js     80107b87 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80107b4d:	83 ec 08             	sub    $0x8,%esp
80107b50:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80107b53:	50                   	push   %eax
80107b54:	6a 02                	push   $0x2
80107b56:	e8 34 f4 ff ff       	call   80106f8f <argint>
80107b5b:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80107b5e:	85 c0                	test   %eax,%eax
80107b60:	78 25                	js     80107b87 <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80107b62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107b65:	0f bf c8             	movswl %ax,%ecx
80107b68:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107b6b:	0f bf d0             	movswl %ax,%edx
80107b6e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80107b71:	51                   	push   %ecx
80107b72:	52                   	push   %edx
80107b73:	6a 03                	push   $0x3
80107b75:	50                   	push   %eax
80107b76:	e8 c8 fb ff ff       	call   80107743 <create>
80107b7b:	83 c4 10             	add    $0x10,%esp
80107b7e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107b81:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107b85:	75 0c                	jne    80107b93 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80107b87:	e8 ec bd ff ff       	call   80103978 <end_op>
    return -1;
80107b8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107b91:	eb 18                	jmp    80107bab <sys_mknod+0x98>
  }
  iunlockput(ip);
80107b93:	83 ec 0c             	sub    $0xc,%esp
80107b96:	ff 75 f0             	pushl  -0x10(%ebp)
80107b99:	e8 5f a2 ff ff       	call   80101dfd <iunlockput>
80107b9e:	83 c4 10             	add    $0x10,%esp
  end_op();
80107ba1:	e8 d2 bd ff ff       	call   80103978 <end_op>
  return 0;
80107ba6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107bab:	c9                   	leave  
80107bac:	c3                   	ret    

80107bad <sys_chdir>:

int
sys_chdir(void)
{
80107bad:	55                   	push   %ebp
80107bae:	89 e5                	mov    %esp,%ebp
80107bb0:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80107bb3:	e8 34 bd ff ff       	call   801038ec <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80107bb8:	83 ec 08             	sub    $0x8,%esp
80107bbb:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107bbe:	50                   	push   %eax
80107bbf:	6a 00                	push   $0x0
80107bc1:	e8 4e f4 ff ff       	call   80107014 <argstr>
80107bc6:	83 c4 10             	add    $0x10,%esp
80107bc9:	85 c0                	test   %eax,%eax
80107bcb:	78 18                	js     80107be5 <sys_chdir+0x38>
80107bcd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107bd0:	83 ec 0c             	sub    $0xc,%esp
80107bd3:	50                   	push   %eax
80107bd4:	e8 4a ab ff ff       	call   80102723 <namei>
80107bd9:	83 c4 10             	add    $0x10,%esp
80107bdc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107bdf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107be3:	75 0c                	jne    80107bf1 <sys_chdir+0x44>
    end_op();
80107be5:	e8 8e bd ff ff       	call   80103978 <end_op>
    return -1;
80107bea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107bef:	eb 6e                	jmp    80107c5f <sys_chdir+0xb2>
  }
  ilock(ip);
80107bf1:	83 ec 0c             	sub    $0xc,%esp
80107bf4:	ff 75 f4             	pushl  -0xc(%ebp)
80107bf7:	e8 19 9f ff ff       	call   80101b15 <ilock>
80107bfc:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80107bff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c02:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80107c06:	66 83 f8 01          	cmp    $0x1,%ax
80107c0a:	74 1a                	je     80107c26 <sys_chdir+0x79>
    iunlockput(ip);
80107c0c:	83 ec 0c             	sub    $0xc,%esp
80107c0f:	ff 75 f4             	pushl  -0xc(%ebp)
80107c12:	e8 e6 a1 ff ff       	call   80101dfd <iunlockput>
80107c17:	83 c4 10             	add    $0x10,%esp
    end_op();
80107c1a:	e8 59 bd ff ff       	call   80103978 <end_op>
    return -1;
80107c1f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107c24:	eb 39                	jmp    80107c5f <sys_chdir+0xb2>
  }
  iunlock(ip);
80107c26:	83 ec 0c             	sub    $0xc,%esp
80107c29:	ff 75 f4             	pushl  -0xc(%ebp)
80107c2c:	e8 6a a0 ff ff       	call   80101c9b <iunlock>
80107c31:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
80107c34:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107c3a:	8b 40 68             	mov    0x68(%eax),%eax
80107c3d:	83 ec 0c             	sub    $0xc,%esp
80107c40:	50                   	push   %eax
80107c41:	e8 c7 a0 ff ff       	call   80101d0d <iput>
80107c46:	83 c4 10             	add    $0x10,%esp
  end_op();
80107c49:	e8 2a bd ff ff       	call   80103978 <end_op>
  proc->cwd = ip;
80107c4e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107c54:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107c57:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80107c5a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107c5f:	c9                   	leave  
80107c60:	c3                   	ret    

80107c61 <sys_exec>:

int
sys_exec(void)
{
80107c61:	55                   	push   %ebp
80107c62:	89 e5                	mov    %esp,%ebp
80107c64:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80107c6a:	83 ec 08             	sub    $0x8,%esp
80107c6d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107c70:	50                   	push   %eax
80107c71:	6a 00                	push   $0x0
80107c73:	e8 9c f3 ff ff       	call   80107014 <argstr>
80107c78:	83 c4 10             	add    $0x10,%esp
80107c7b:	85 c0                	test   %eax,%eax
80107c7d:	78 18                	js     80107c97 <sys_exec+0x36>
80107c7f:	83 ec 08             	sub    $0x8,%esp
80107c82:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80107c88:	50                   	push   %eax
80107c89:	6a 01                	push   $0x1
80107c8b:	e8 ff f2 ff ff       	call   80106f8f <argint>
80107c90:	83 c4 10             	add    $0x10,%esp
80107c93:	85 c0                	test   %eax,%eax
80107c95:	79 0a                	jns    80107ca1 <sys_exec+0x40>
    return -1;
80107c97:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107c9c:	e9 c6 00 00 00       	jmp    80107d67 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80107ca1:	83 ec 04             	sub    $0x4,%esp
80107ca4:	68 80 00 00 00       	push   $0x80
80107ca9:	6a 00                	push   $0x0
80107cab:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80107cb1:	50                   	push   %eax
80107cb2:	e8 b3 ef ff ff       	call   80106c6a <memset>
80107cb7:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80107cba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80107cc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc4:	83 f8 1f             	cmp    $0x1f,%eax
80107cc7:	76 0a                	jbe    80107cd3 <sys_exec+0x72>
      return -1;
80107cc9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107cce:	e9 94 00 00 00       	jmp    80107d67 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80107cd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd6:	c1 e0 02             	shl    $0x2,%eax
80107cd9:	89 c2                	mov    %eax,%edx
80107cdb:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80107ce1:	01 c2                	add    %eax,%edx
80107ce3:	83 ec 08             	sub    $0x8,%esp
80107ce6:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80107cec:	50                   	push   %eax
80107ced:	52                   	push   %edx
80107cee:	e8 00 f2 ff ff       	call   80106ef3 <fetchint>
80107cf3:	83 c4 10             	add    $0x10,%esp
80107cf6:	85 c0                	test   %eax,%eax
80107cf8:	79 07                	jns    80107d01 <sys_exec+0xa0>
      return -1;
80107cfa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107cff:	eb 66                	jmp    80107d67 <sys_exec+0x106>
    if(uarg == 0){
80107d01:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80107d07:	85 c0                	test   %eax,%eax
80107d09:	75 27                	jne    80107d32 <sys_exec+0xd1>
      argv[i] = 0;
80107d0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d0e:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80107d15:	00 00 00 00 
      break;
80107d19:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80107d1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d1d:	83 ec 08             	sub    $0x8,%esp
80107d20:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80107d26:	52                   	push   %edx
80107d27:	50                   	push   %eax
80107d28:	e8 d8 8e ff ff       	call   80100c05 <exec>
80107d2d:	83 c4 10             	add    $0x10,%esp
80107d30:	eb 35                	jmp    80107d67 <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80107d32:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80107d38:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107d3b:	c1 e2 02             	shl    $0x2,%edx
80107d3e:	01 c2                	add    %eax,%edx
80107d40:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80107d46:	83 ec 08             	sub    $0x8,%esp
80107d49:	52                   	push   %edx
80107d4a:	50                   	push   %eax
80107d4b:	e8 dd f1 ff ff       	call   80106f2d <fetchstr>
80107d50:	83 c4 10             	add    $0x10,%esp
80107d53:	85 c0                	test   %eax,%eax
80107d55:	79 07                	jns    80107d5e <sys_exec+0xfd>
      return -1;
80107d57:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d5c:	eb 09                	jmp    80107d67 <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80107d5e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80107d62:	e9 5a ff ff ff       	jmp    80107cc1 <sys_exec+0x60>
  return exec(path, argv);
}
80107d67:	c9                   	leave  
80107d68:	c3                   	ret    

80107d69 <sys_pipe>:

int
sys_pipe(void)
{
80107d69:	55                   	push   %ebp
80107d6a:	89 e5                	mov    %esp,%ebp
80107d6c:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80107d6f:	83 ec 04             	sub    $0x4,%esp
80107d72:	6a 08                	push   $0x8
80107d74:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107d77:	50                   	push   %eax
80107d78:	6a 00                	push   $0x0
80107d7a:	e8 38 f2 ff ff       	call   80106fb7 <argptr>
80107d7f:	83 c4 10             	add    $0x10,%esp
80107d82:	85 c0                	test   %eax,%eax
80107d84:	79 0a                	jns    80107d90 <sys_pipe+0x27>
    return -1;
80107d86:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107d8b:	e9 af 00 00 00       	jmp    80107e3f <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
80107d90:	83 ec 08             	sub    $0x8,%esp
80107d93:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80107d96:	50                   	push   %eax
80107d97:	8d 45 e8             	lea    -0x18(%ebp),%eax
80107d9a:	50                   	push   %eax
80107d9b:	e8 40 c6 ff ff       	call   801043e0 <pipealloc>
80107da0:	83 c4 10             	add    $0x10,%esp
80107da3:	85 c0                	test   %eax,%eax
80107da5:	79 0a                	jns    80107db1 <sys_pipe+0x48>
    return -1;
80107da7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107dac:	e9 8e 00 00 00       	jmp    80107e3f <sys_pipe+0xd6>
  fd0 = -1;
80107db1:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80107db8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107dbb:	83 ec 0c             	sub    $0xc,%esp
80107dbe:	50                   	push   %eax
80107dbf:	e8 7c f3 ff ff       	call   80107140 <fdalloc>
80107dc4:	83 c4 10             	add    $0x10,%esp
80107dc7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107dca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107dce:	78 18                	js     80107de8 <sys_pipe+0x7f>
80107dd0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107dd3:	83 ec 0c             	sub    $0xc,%esp
80107dd6:	50                   	push   %eax
80107dd7:	e8 64 f3 ff ff       	call   80107140 <fdalloc>
80107ddc:	83 c4 10             	add    $0x10,%esp
80107ddf:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107de2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107de6:	79 3f                	jns    80107e27 <sys_pipe+0xbe>
    if(fd0 >= 0)
80107de8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107dec:	78 14                	js     80107e02 <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
80107dee:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107df4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107df7:	83 c2 08             	add    $0x8,%edx
80107dfa:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80107e01:	00 
    fileclose(rf);
80107e02:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107e05:	83 ec 0c             	sub    $0xc,%esp
80107e08:	50                   	push   %eax
80107e09:	e8 aa 93 ff ff       	call   801011b8 <fileclose>
80107e0e:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80107e11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107e14:	83 ec 0c             	sub    $0xc,%esp
80107e17:	50                   	push   %eax
80107e18:	e8 9b 93 ff ff       	call   801011b8 <fileclose>
80107e1d:	83 c4 10             	add    $0x10,%esp
    return -1;
80107e20:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107e25:	eb 18                	jmp    80107e3f <sys_pipe+0xd6>
  }
  fd[0] = fd0;
80107e27:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e2a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107e2d:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80107e2f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e32:	8d 50 04             	lea    0x4(%eax),%edx
80107e35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e38:	89 02                	mov    %eax,(%edx)
  return 0;
80107e3a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107e3f:	c9                   	leave  
80107e40:	c3                   	ret    

80107e41 <sys_chmod>:

#ifdef CS333_P5
int
sys_chmod(void)
{
80107e41:	55                   	push   %ebp
80107e42:	89 e5                	mov    %esp,%ebp
80107e44:	83 ec 18             	sub    $0x18,%esp
  char *pathname;
  int mode;
  int rc;

  if(argint(1, &mode) < 0)
80107e47:	83 ec 08             	sub    $0x8,%esp
80107e4a:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107e4d:	50                   	push   %eax
80107e4e:	6a 01                	push   $0x1
80107e50:	e8 3a f1 ff ff       	call   80106f8f <argint>
80107e55:	83 c4 10             	add    $0x10,%esp
80107e58:	85 c0                	test   %eax,%eax
80107e5a:	79 07                	jns    80107e63 <sys_chmod+0x22>
    return -1;
80107e5c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107e61:	eb 4d                	jmp    80107eb0 <sys_chmod+0x6f>
  if(argstr(0, &pathname) < 0)
80107e63:	83 ec 08             	sub    $0x8,%esp
80107e66:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107e69:	50                   	push   %eax
80107e6a:	6a 00                	push   $0x0
80107e6c:	e8 a3 f1 ff ff       	call   80107014 <argstr>
80107e71:	83 c4 10             	add    $0x10,%esp
80107e74:	85 c0                	test   %eax,%eax
80107e76:	79 07                	jns    80107e7f <sys_chmod+0x3e>
    return -1;
80107e78:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107e7d:	eb 31                	jmp    80107eb0 <sys_chmod+0x6f>
  if(mode < 0 || mode > 01777)
80107e7f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e82:	85 c0                	test   %eax,%eax
80107e84:	78 0a                	js     80107e90 <sys_chmod+0x4f>
80107e86:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e89:	3d ff 03 00 00       	cmp    $0x3ff,%eax
80107e8e:	7e 07                	jle    80107e97 <sys_chmod+0x56>
    return -1;
80107e90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107e95:	eb 19                	jmp    80107eb0 <sys_chmod+0x6f>

  rc = chmod(pathname, mode);
80107e97:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107e9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e9d:	83 ec 08             	sub    $0x8,%esp
80107ea0:	52                   	push   %edx
80107ea1:	50                   	push   %eax
80107ea2:	e8 b3 a8 ff ff       	call   8010275a <chmod>
80107ea7:	83 c4 10             	add    $0x10,%esp
80107eaa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  return rc;
80107ead:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80107eb0:	c9                   	leave  
80107eb1:	c3                   	ret    

80107eb2 <sys_chgrp>:

int
sys_chgrp(void)
{
80107eb2:	55                   	push   %ebp
80107eb3:	89 e5                	mov    %esp,%ebp
80107eb5:	83 ec 18             	sub    $0x18,%esp
  char *pathname;
  int group;
  int rc;

  if(argint(1, &group) < 0)
80107eb8:	83 ec 08             	sub    $0x8,%esp
80107ebb:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107ebe:	50                   	push   %eax
80107ebf:	6a 01                	push   $0x1
80107ec1:	e8 c9 f0 ff ff       	call   80106f8f <argint>
80107ec6:	83 c4 10             	add    $0x10,%esp
80107ec9:	85 c0                	test   %eax,%eax
80107ecb:	79 07                	jns    80107ed4 <sys_chgrp+0x22>
    return -1;
80107ecd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107ed2:	eb 4d                	jmp    80107f21 <sys_chgrp+0x6f>
  if(argstr(0, &pathname) < 0)
80107ed4:	83 ec 08             	sub    $0x8,%esp
80107ed7:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107eda:	50                   	push   %eax
80107edb:	6a 00                	push   $0x0
80107edd:	e8 32 f1 ff ff       	call   80107014 <argstr>
80107ee2:	83 c4 10             	add    $0x10,%esp
80107ee5:	85 c0                	test   %eax,%eax
80107ee7:	79 07                	jns    80107ef0 <sys_chgrp+0x3e>
    return -1;
80107ee9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107eee:	eb 31                	jmp    80107f21 <sys_chgrp+0x6f>
  if(group < 0 || group > 32767)
80107ef0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ef3:	85 c0                	test   %eax,%eax
80107ef5:	78 0a                	js     80107f01 <sys_chgrp+0x4f>
80107ef7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107efa:	3d ff 7f 00 00       	cmp    $0x7fff,%eax
80107eff:	7e 07                	jle    80107f08 <sys_chgrp+0x56>
    return -1;
80107f01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107f06:	eb 19                	jmp    80107f21 <sys_chgrp+0x6f>
  
  rc = chgrp(pathname, group);
80107f08:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107f0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f0e:	83 ec 08             	sub    $0x8,%esp
80107f11:	52                   	push   %edx
80107f12:	50                   	push   %eax
80107f13:	e8 cc a8 ff ff       	call   801027e4 <chgrp>
80107f18:	83 c4 10             	add    $0x10,%esp
80107f1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  return rc;
80107f1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80107f21:	c9                   	leave  
80107f22:	c3                   	ret    

80107f23 <sys_chown>:

int
sys_chown(void)
{
80107f23:	55                   	push   %ebp
80107f24:	89 e5                	mov    %esp,%ebp
80107f26:	83 ec 18             	sub    $0x18,%esp
  char *pathname;
  int owner;
  int rc;

  if(argint(1, &owner) < 0)
80107f29:	83 ec 08             	sub    $0x8,%esp
80107f2c:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107f2f:	50                   	push   %eax
80107f30:	6a 01                	push   $0x1
80107f32:	e8 58 f0 ff ff       	call   80106f8f <argint>
80107f37:	83 c4 10             	add    $0x10,%esp
80107f3a:	85 c0                	test   %eax,%eax
80107f3c:	79 07                	jns    80107f45 <sys_chown+0x22>
    return -1;
80107f3e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107f43:	eb 4d                	jmp    80107f92 <sys_chown+0x6f>
  if(argstr(0, &pathname) < 0)
80107f45:	83 ec 08             	sub    $0x8,%esp
80107f48:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107f4b:	50                   	push   %eax
80107f4c:	6a 00                	push   $0x0
80107f4e:	e8 c1 f0 ff ff       	call   80107014 <argstr>
80107f53:	83 c4 10             	add    $0x10,%esp
80107f56:	85 c0                	test   %eax,%eax
80107f58:	79 07                	jns    80107f61 <sys_chown+0x3e>
    return -1;
80107f5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107f5f:	eb 31                	jmp    80107f92 <sys_chown+0x6f>
  if(owner < 0 || owner > 32767)
80107f61:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f64:	85 c0                	test   %eax,%eax
80107f66:	78 0a                	js     80107f72 <sys_chown+0x4f>
80107f68:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f6b:	3d ff 7f 00 00       	cmp    $0x7fff,%eax
80107f70:	7e 07                	jle    80107f79 <sys_chown+0x56>
    return -1;
80107f72:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107f77:	eb 19                	jmp    80107f92 <sys_chown+0x6f>

  rc = chown(pathname, owner);
80107f79:	8b 55 ec             	mov    -0x14(%ebp),%edx
80107f7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f7f:	83 ec 08             	sub    $0x8,%esp
80107f82:	52                   	push   %edx
80107f83:	50                   	push   %eax
80107f84:	e8 e8 a8 ff ff       	call   80102871 <chown>
80107f89:	83 c4 10             	add    $0x10,%esp
80107f8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  return rc;
80107f8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80107f92:	c9                   	leave  
80107f93:	c3                   	ret    

80107f94 <outw>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outw(ushort port, ushort data)
{
80107f94:	55                   	push   %ebp
80107f95:	89 e5                	mov    %esp,%ebp
80107f97:	83 ec 08             	sub    $0x8,%esp
80107f9a:	8b 55 08             	mov    0x8(%ebp),%edx
80107f9d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fa0:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107fa4:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107fa8:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
80107fac:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107fb0:	66 ef                	out    %ax,(%dx)
}
80107fb2:	90                   	nop
80107fb3:	c9                   	leave  
80107fb4:	c3                   	ret    

80107fb5 <sys_fork>:
#include "proc.h"
#include "uproc.h"

int
sys_fork(void)
{
80107fb5:	55                   	push   %ebp
80107fb6:	89 e5                	mov    %esp,%ebp
80107fb8:	83 ec 08             	sub    $0x8,%esp
  return fork();
80107fbb:	e8 0d ce ff ff       	call   80104dcd <fork>
}
80107fc0:	c9                   	leave  
80107fc1:	c3                   	ret    

80107fc2 <sys_exit>:

int
sys_exit(void)
{
80107fc2:	55                   	push   %ebp
80107fc3:	89 e5                	mov    %esp,%ebp
80107fc5:	83 ec 08             	sub    $0x8,%esp
  exit();
80107fc8:	e8 b3 d0 ff ff       	call   80105080 <exit>
  return 0;  // not reached
80107fcd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107fd2:	c9                   	leave  
80107fd3:	c3                   	ret    

80107fd4 <sys_wait>:

int
sys_wait(void)
{
80107fd4:	55                   	push   %ebp
80107fd5:	89 e5                	mov    %esp,%ebp
80107fd7:	83 ec 08             	sub    $0x8,%esp
  return wait();
80107fda:	e8 5d d3 ff ff       	call   8010533c <wait>
}
80107fdf:	c9                   	leave  
80107fe0:	c3                   	ret    

80107fe1 <sys_kill>:

int
sys_kill(void)
{
80107fe1:	55                   	push   %ebp
80107fe2:	89 e5                	mov    %esp,%ebp
80107fe4:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80107fe7:	83 ec 08             	sub    $0x8,%esp
80107fea:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107fed:	50                   	push   %eax
80107fee:	6a 00                	push   $0x0
80107ff0:	e8 9a ef ff ff       	call   80106f8f <argint>
80107ff5:	83 c4 10             	add    $0x10,%esp
80107ff8:	85 c0                	test   %eax,%eax
80107ffa:	79 07                	jns    80108003 <sys_kill+0x22>
    return -1;
80107ffc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108001:	eb 0f                	jmp    80108012 <sys_kill+0x31>
  return kill(pid);
80108003:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108006:	83 ec 0c             	sub    $0xc,%esp
80108009:	50                   	push   %eax
8010800a:	e8 27 dc ff ff       	call   80105c36 <kill>
8010800f:	83 c4 10             	add    $0x10,%esp
}
80108012:	c9                   	leave  
80108013:	c3                   	ret    

80108014 <sys_getpid>:

int
sys_getpid(void)
{
80108014:	55                   	push   %ebp
80108015:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80108017:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010801d:	8b 40 10             	mov    0x10(%eax),%eax
}
80108020:	5d                   	pop    %ebp
80108021:	c3                   	ret    

80108022 <sys_sbrk>:

int
sys_sbrk(void)
{
80108022:	55                   	push   %ebp
80108023:	89 e5                	mov    %esp,%ebp
80108025:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80108028:	83 ec 08             	sub    $0x8,%esp
8010802b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010802e:	50                   	push   %eax
8010802f:	6a 00                	push   $0x0
80108031:	e8 59 ef ff ff       	call   80106f8f <argint>
80108036:	83 c4 10             	add    $0x10,%esp
80108039:	85 c0                	test   %eax,%eax
8010803b:	79 07                	jns    80108044 <sys_sbrk+0x22>
    return -1;
8010803d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108042:	eb 28                	jmp    8010806c <sys_sbrk+0x4a>
  addr = proc->sz;
80108044:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010804a:	8b 00                	mov    (%eax),%eax
8010804c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
8010804f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108052:	83 ec 0c             	sub    $0xc,%esp
80108055:	50                   	push   %eax
80108056:	e8 cf cc ff ff       	call   80104d2a <growproc>
8010805b:	83 c4 10             	add    $0x10,%esp
8010805e:	85 c0                	test   %eax,%eax
80108060:	79 07                	jns    80108069 <sys_sbrk+0x47>
    return -1;
80108062:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108067:	eb 03                	jmp    8010806c <sys_sbrk+0x4a>
  return addr;
80108069:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010806c:	c9                   	leave  
8010806d:	c3                   	ret    

8010806e <sys_sleep>:

int
sys_sleep(void)
{
8010806e:	55                   	push   %ebp
8010806f:	89 e5                	mov    %esp,%ebp
80108071:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
80108074:	83 ec 08             	sub    $0x8,%esp
80108077:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010807a:	50                   	push   %eax
8010807b:	6a 00                	push   $0x0
8010807d:	e8 0d ef ff ff       	call   80106f8f <argint>
80108082:	83 c4 10             	add    $0x10,%esp
80108085:	85 c0                	test   %eax,%eax
80108087:	79 07                	jns    80108090 <sys_sleep+0x22>
    return -1;
80108089:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010808e:	eb 44                	jmp    801080d4 <sys_sleep+0x66>
  ticks0 = ticks;
80108090:	a1 20 79 11 80       	mov    0x80117920,%eax
80108095:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80108098:	eb 26                	jmp    801080c0 <sys_sleep+0x52>
    if(proc->killed){
8010809a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801080a0:	8b 40 24             	mov    0x24(%eax),%eax
801080a3:	85 c0                	test   %eax,%eax
801080a5:	74 07                	je     801080ae <sys_sleep+0x40>
      return -1;
801080a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801080ac:	eb 26                	jmp    801080d4 <sys_sleep+0x66>
    }
    sleep(&ticks, (struct spinlock *)0);
801080ae:	83 ec 08             	sub    $0x8,%esp
801080b1:	6a 00                	push   $0x0
801080b3:	68 20 79 11 80       	push   $0x80117920
801080b8:	e8 ef d8 ff ff       	call   801059ac <sleep>
801080bd:	83 c4 10             	add    $0x10,%esp
  uint ticks0;
  
  if(argint(0, &n) < 0)
    return -1;
  ticks0 = ticks;
  while(ticks - ticks0 < n){
801080c0:	a1 20 79 11 80       	mov    0x80117920,%eax
801080c5:	2b 45 f4             	sub    -0xc(%ebp),%eax
801080c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801080cb:	39 d0                	cmp    %edx,%eax
801080cd:	72 cb                	jb     8010809a <sys_sleep+0x2c>
    if(proc->killed){
      return -1;
    }
    sleep(&ticks, (struct spinlock *)0);
  }
  return 0;
801080cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
801080d4:	c9                   	leave  
801080d5:	c3                   	ret    

801080d6 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start. 
int
sys_uptime(void)
{
801080d6:	55                   	push   %ebp
801080d7:	89 e5                	mov    %esp,%ebp
801080d9:	83 ec 10             	sub    $0x10,%esp
  uint xticks;
  
  xticks = ticks;
801080dc:	a1 20 79 11 80       	mov    0x80117920,%eax
801080e1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return xticks;
801080e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801080e7:	c9                   	leave  
801080e8:	c3                   	ret    

801080e9 <sys_halt>:

//Turn of the computer
int
sys_halt(void){
801080e9:	55                   	push   %ebp
801080ea:	89 e5                	mov    %esp,%ebp
801080ec:	83 ec 08             	sub    $0x8,%esp
  cprintf("Shutting down ...\n");
801080ef:	83 ec 0c             	sub    $0xc,%esp
801080f2:	68 21 ab 10 80       	push   $0x8010ab21
801080f7:	e8 ca 82 ff ff       	call   801003c6 <cprintf>
801080fc:	83 c4 10             	add    $0x10,%esp
  outw( 0x604, 0x0 | 0x2000);
801080ff:	83 ec 08             	sub    $0x8,%esp
80108102:	68 00 20 00 00       	push   $0x2000
80108107:	68 04 06 00 00       	push   $0x604
8010810c:	e8 83 fe ff ff       	call   80107f94 <outw>
80108111:	83 c4 10             	add    $0x10,%esp
  return 0;
80108114:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108119:	c9                   	leave  
8010811a:	c3                   	ret    

8010811b <sys_date>:

#ifdef CS333_P1
//Display date
int
sys_date(void)
{
8010811b:	55                   	push   %ebp
8010811c:	89 e5                	mov    %esp,%ebp
8010811e:	83 ec 18             	sub    $0x18,%esp
  struct rtcdate *d;
  if (argptr(0, (void*)&d, sizeof(struct rtcdate)) < 0)
80108121:	83 ec 04             	sub    $0x4,%esp
80108124:	6a 18                	push   $0x18
80108126:	8d 45 f4             	lea    -0xc(%ebp),%eax
80108129:	50                   	push   %eax
8010812a:	6a 00                	push   $0x0
8010812c:	e8 86 ee ff ff       	call   80106fb7 <argptr>
80108131:	83 c4 10             	add    $0x10,%esp
80108134:	85 c0                	test   %eax,%eax
80108136:	79 07                	jns    8010813f <sys_date+0x24>
    return -1;
80108138:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010813d:	eb 14                	jmp    80108153 <sys_date+0x38>
  cmostime(d);
8010813f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108142:	83 ec 0c             	sub    $0xc,%esp
80108145:	50                   	push   %eax
80108146:	e8 1c b4 ff ff       	call   80103567 <cmostime>
8010814b:	83 c4 10             	add    $0x10,%esp
  return 0;  
8010814e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108153:	c9                   	leave  
80108154:	c3                   	ret    

80108155 <sys_getuid>:

#ifdef CS333_P2
//Get uid
uint
sys_getuid(void)
{
80108155:	55                   	push   %ebp
80108156:	89 e5                	mov    %esp,%ebp
  return proc->uid;
80108158:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010815e:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
80108164:	5d                   	pop    %ebp
80108165:	c3                   	ret    

80108166 <sys_getgid>:

//Get pid
uint
sys_getgid(void)
{
80108166:	55                   	push   %ebp
80108167:	89 e5                	mov    %esp,%ebp
  return proc->gid;
80108169:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010816f:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
}
80108175:	5d                   	pop    %ebp
80108176:	c3                   	ret    

80108177 <sys_getppid>:

//Get ppid
uint
sys_getppid(void)
{
80108177:	55                   	push   %ebp
80108178:	89 e5                	mov    %esp,%ebp
  return proc->parent->pid;  
8010817a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108180:	8b 40 14             	mov    0x14(%eax),%eax
80108183:	8b 40 10             	mov    0x10(%eax),%eax
}
80108186:	5d                   	pop    %ebp
80108187:	c3                   	ret    

80108188 <sys_setuid>:

//Set uid
int
sys_setuid(void)
{
80108188:	55                   	push   %ebp
80108189:	89 e5                	mov    %esp,%ebp
8010818b:	83 ec 18             	sub    $0x18,%esp
  int i;
  if (argint(0, &i) < 0)
8010818e:	83 ec 08             	sub    $0x8,%esp
80108191:	8d 45 f4             	lea    -0xc(%ebp),%eax
80108194:	50                   	push   %eax
80108195:	6a 00                	push   $0x0
80108197:	e8 f3 ed ff ff       	call   80106f8f <argint>
8010819c:	83 c4 10             	add    $0x10,%esp
8010819f:	85 c0                	test   %eax,%eax
801081a1:	79 07                	jns    801081aa <sys_setuid+0x22>
    return -1;
801081a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801081a8:	eb 2c                	jmp    801081d6 <sys_setuid+0x4e>
  if (i < 0 || i > 32767)
801081aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081ad:	85 c0                	test   %eax,%eax
801081af:	78 0a                	js     801081bb <sys_setuid+0x33>
801081b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081b4:	3d ff 7f 00 00       	cmp    $0x7fff,%eax
801081b9:	7e 07                	jle    801081c2 <sys_setuid+0x3a>
    return -1; 
801081bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801081c0:	eb 14                	jmp    801081d6 <sys_setuid+0x4e>
  proc->uid = i;
801081c2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801081c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801081cb:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  return 0;
801081d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801081d6:	c9                   	leave  
801081d7:	c3                   	ret    

801081d8 <sys_setgid>:

//Set gid
int
sys_setgid(void)
{
801081d8:	55                   	push   %ebp
801081d9:	89 e5                	mov    %esp,%ebp
801081db:	83 ec 18             	sub    $0x18,%esp
  int i;
  if (argint(0, &i) < 0)
801081de:	83 ec 08             	sub    $0x8,%esp
801081e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
801081e4:	50                   	push   %eax
801081e5:	6a 00                	push   $0x0
801081e7:	e8 a3 ed ff ff       	call   80106f8f <argint>
801081ec:	83 c4 10             	add    $0x10,%esp
801081ef:	85 c0                	test   %eax,%eax
801081f1:	79 07                	jns    801081fa <sys_setgid+0x22>
    return -1;
801081f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801081f8:	eb 2c                	jmp    80108226 <sys_setgid+0x4e>
  if (i < 0 || i > 32767)
801081fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081fd:	85 c0                	test   %eax,%eax
801081ff:	78 0a                	js     8010820b <sys_setgid+0x33>
80108201:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108204:	3d ff 7f 00 00       	cmp    $0x7fff,%eax
80108209:	7e 07                	jle    80108212 <sys_setgid+0x3a>
    return -1;
8010820b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108210:	eb 14                	jmp    80108226 <sys_setgid+0x4e>
  proc->gid = i;
80108212:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108218:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010821b:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
  return 0;
80108221:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108226:	c9                   	leave  
80108227:	c3                   	ret    

80108228 <sys_getprocs>:

//getprocs
int
sys_getprocs(void)
{
80108228:	55                   	push   %ebp
80108229:	89 e5                	mov    %esp,%ebp
8010822b:	83 ec 18             	sub    $0x18,%esp
  int i;
  int index;
  struct uproc *table; 

  if (argint(0, &i) < 0)
8010822e:	83 ec 08             	sub    $0x8,%esp
80108231:	8d 45 f0             	lea    -0x10(%ebp),%eax
80108234:	50                   	push   %eax
80108235:	6a 00                	push   $0x0
80108237:	e8 53 ed ff ff       	call   80106f8f <argint>
8010823c:	83 c4 10             	add    $0x10,%esp
8010823f:	85 c0                	test   %eax,%eax
80108241:	79 07                	jns    8010824a <sys_getprocs+0x22>
    return -1;
80108243:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108248:	eb 37                	jmp    80108281 <sys_getprocs+0x59>
  if (argptr(1, (void*)&table, sizeof(struct uproc) < 0))
8010824a:	83 ec 04             	sub    $0x4,%esp
8010824d:	6a 00                	push   $0x0
8010824f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108252:	50                   	push   %eax
80108253:	6a 01                	push   $0x1
80108255:	e8 5d ed ff ff       	call   80106fb7 <argptr>
8010825a:	83 c4 10             	add    $0x10,%esp
8010825d:	85 c0                	test   %eax,%eax
8010825f:	74 07                	je     80108268 <sys_getprocs+0x40>
    return -1;
80108261:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108266:	eb 19                	jmp    80108281 <sys_getprocs+0x59>

  index = getprocs(i, table);  
80108268:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010826b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010826e:	83 ec 08             	sub    $0x8,%esp
80108271:	50                   	push   %eax
80108272:	52                   	push   %edx
80108273:	e8 5b de ff ff       	call   801060d3 <getprocs>
80108278:	83 c4 10             	add    $0x10,%esp
8010827b:	89 45 f4             	mov    %eax,-0xc(%ebp)

  return index;
8010827e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  
}
80108281:	c9                   	leave  
80108282:	c3                   	ret    

80108283 <sys_setpriority>:
#endif

#ifdef CS333_P3P4
int
sys_setpriority(void)
{
80108283:	55                   	push   %ebp
80108284:	89 e5                	mov    %esp,%ebp
80108286:	83 ec 18             	sub    $0x18,%esp
  int pid;
  int priority;
  int rc;
  
  if(argint(0, &pid) < 0)
80108289:	83 ec 08             	sub    $0x8,%esp
8010828c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010828f:	50                   	push   %eax
80108290:	6a 00                	push   $0x0
80108292:	e8 f8 ec ff ff       	call   80106f8f <argint>
80108297:	83 c4 10             	add    $0x10,%esp
8010829a:	85 c0                	test   %eax,%eax
8010829c:	79 07                	jns    801082a5 <sys_setpriority+0x22>
    return -1;
8010829e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801082a3:	eb 35                	jmp    801082da <sys_setpriority+0x57>
  if(argint(1, &priority) < 0)
801082a5:	83 ec 08             	sub    $0x8,%esp
801082a8:	8d 45 ec             	lea    -0x14(%ebp),%eax
801082ab:	50                   	push   %eax
801082ac:	6a 01                	push   $0x1
801082ae:	e8 dc ec ff ff       	call   80106f8f <argint>
801082b3:	83 c4 10             	add    $0x10,%esp
801082b6:	85 c0                	test   %eax,%eax
801082b8:	79 07                	jns    801082c1 <sys_setpriority+0x3e>
    return -1;
801082ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801082bf:	eb 19                	jmp    801082da <sys_setpriority+0x57>

  rc = setpriority(pid, priority);
801082c1:	8b 55 ec             	mov    -0x14(%ebp),%edx
801082c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082c7:	83 ec 08             	sub    $0x8,%esp
801082ca:	52                   	push   %edx
801082cb:	50                   	push   %eax
801082cc:	e8 3c e5 ff ff       	call   8010680d <setpriority>
801082d1:	83 c4 10             	add    $0x10,%esp
801082d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  return rc;
801082d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801082da:	c9                   	leave  
801082db:	c3                   	ret    

801082dc <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801082dc:	55                   	push   %ebp
801082dd:	89 e5                	mov    %esp,%ebp
801082df:	83 ec 08             	sub    $0x8,%esp
801082e2:	8b 55 08             	mov    0x8(%ebp),%edx
801082e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801082e8:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801082ec:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801082ef:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801082f3:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801082f7:	ee                   	out    %al,(%dx)
}
801082f8:	90                   	nop
801082f9:	c9                   	leave  
801082fa:	c3                   	ret    

801082fb <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
801082fb:	55                   	push   %ebp
801082fc:	89 e5                	mov    %esp,%ebp
801082fe:	83 ec 08             	sub    $0x8,%esp
  // Interrupt TPS times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80108301:	6a 34                	push   $0x34
80108303:	6a 43                	push   $0x43
80108305:	e8 d2 ff ff ff       	call   801082dc <outb>
8010830a:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(TPS) % 256);
8010830d:	68 a9 00 00 00       	push   $0xa9
80108312:	6a 40                	push   $0x40
80108314:	e8 c3 ff ff ff       	call   801082dc <outb>
80108319:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(TPS) / 256);
8010831c:	6a 04                	push   $0x4
8010831e:	6a 40                	push   $0x40
80108320:	e8 b7 ff ff ff       	call   801082dc <outb>
80108325:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
80108328:	83 ec 0c             	sub    $0xc,%esp
8010832b:	6a 00                	push   $0x0
8010832d:	e8 98 bf ff ff       	call   801042ca <picenable>
80108332:	83 c4 10             	add    $0x10,%esp
}
80108335:	90                   	nop
80108336:	c9                   	leave  
80108337:	c3                   	ret    

80108338 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80108338:	1e                   	push   %ds
  pushl %es
80108339:	06                   	push   %es
  pushl %fs
8010833a:	0f a0                	push   %fs
  pushl %gs
8010833c:	0f a8                	push   %gs
  pushal
8010833e:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
8010833f:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80108343:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80108345:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80108347:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
8010834b:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
8010834d:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
8010834f:	54                   	push   %esp
  call trap
80108350:	e8 ce 01 00 00       	call   80108523 <trap>
  addl $4, %esp
80108355:	83 c4 04             	add    $0x4,%esp

80108358 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80108358:	61                   	popa   
  popl %gs
80108359:	0f a9                	pop    %gs
  popl %fs
8010835b:	0f a1                	pop    %fs
  popl %es
8010835d:	07                   	pop    %es
  popl %ds
8010835e:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010835f:	83 c4 08             	add    $0x8,%esp
  iret
80108362:	cf                   	iret   

80108363 <atom_inc>:

// Routines added for CS333
// atom_inc() added to simplify handling of ticks global
static inline void
atom_inc(volatile int *num)
{
80108363:	55                   	push   %ebp
80108364:	89 e5                	mov    %esp,%ebp
  asm volatile ( "lock incl %0" : "=m" (*num));
80108366:	8b 45 08             	mov    0x8(%ebp),%eax
80108369:	f0 ff 00             	lock incl (%eax)
}
8010836c:	90                   	nop
8010836d:	5d                   	pop    %ebp
8010836e:	c3                   	ret    

8010836f <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
8010836f:	55                   	push   %ebp
80108370:	89 e5                	mov    %esp,%ebp
80108372:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80108375:	8b 45 0c             	mov    0xc(%ebp),%eax
80108378:	83 e8 01             	sub    $0x1,%eax
8010837b:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010837f:	8b 45 08             	mov    0x8(%ebp),%eax
80108382:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80108386:	8b 45 08             	mov    0x8(%ebp),%eax
80108389:	c1 e8 10             	shr    $0x10,%eax
8010838c:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80108390:	8d 45 fa             	lea    -0x6(%ebp),%eax
80108393:	0f 01 18             	lidtl  (%eax)
}
80108396:	90                   	nop
80108397:	c9                   	leave  
80108398:	c3                   	ret    

80108399 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80108399:	55                   	push   %ebp
8010839a:	89 e5                	mov    %esp,%ebp
8010839c:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010839f:	0f 20 d0             	mov    %cr2,%eax
801083a2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801083a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801083a8:	c9                   	leave  
801083a9:	c3                   	ret    

801083aa <tvinit>:
// Software Developer’s Manual, Vol 3A, 8.1.1 Guaranteed Atomic Operations.
uint ticks __attribute__ ((aligned (4)));

void
tvinit(void)
{
801083aa:	55                   	push   %ebp
801083ab:	89 e5                	mov    %esp,%ebp
801083ad:	83 ec 10             	sub    $0x10,%esp
  int i;

  for(i = 0; i < 256; i++)
801083b0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801083b7:	e9 c3 00 00 00       	jmp    8010847f <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801083bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801083bf:	8b 04 85 c8 d0 10 80 	mov    -0x7fef2f38(,%eax,4),%eax
801083c6:	89 c2                	mov    %eax,%edx
801083c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801083cb:	66 89 14 c5 20 71 11 	mov    %dx,-0x7fee8ee0(,%eax,8)
801083d2:	80 
801083d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801083d6:	66 c7 04 c5 22 71 11 	movw   $0x8,-0x7fee8ede(,%eax,8)
801083dd:	80 08 00 
801083e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801083e3:	0f b6 14 c5 24 71 11 	movzbl -0x7fee8edc(,%eax,8),%edx
801083ea:	80 
801083eb:	83 e2 e0             	and    $0xffffffe0,%edx
801083ee:	88 14 c5 24 71 11 80 	mov    %dl,-0x7fee8edc(,%eax,8)
801083f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801083f8:	0f b6 14 c5 24 71 11 	movzbl -0x7fee8edc(,%eax,8),%edx
801083ff:	80 
80108400:	83 e2 1f             	and    $0x1f,%edx
80108403:	88 14 c5 24 71 11 80 	mov    %dl,-0x7fee8edc(,%eax,8)
8010840a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010840d:	0f b6 14 c5 25 71 11 	movzbl -0x7fee8edb(,%eax,8),%edx
80108414:	80 
80108415:	83 e2 f0             	and    $0xfffffff0,%edx
80108418:	83 ca 0e             	or     $0xe,%edx
8010841b:	88 14 c5 25 71 11 80 	mov    %dl,-0x7fee8edb(,%eax,8)
80108422:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108425:	0f b6 14 c5 25 71 11 	movzbl -0x7fee8edb(,%eax,8),%edx
8010842c:	80 
8010842d:	83 e2 ef             	and    $0xffffffef,%edx
80108430:	88 14 c5 25 71 11 80 	mov    %dl,-0x7fee8edb(,%eax,8)
80108437:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010843a:	0f b6 14 c5 25 71 11 	movzbl -0x7fee8edb(,%eax,8),%edx
80108441:	80 
80108442:	83 e2 9f             	and    $0xffffff9f,%edx
80108445:	88 14 c5 25 71 11 80 	mov    %dl,-0x7fee8edb(,%eax,8)
8010844c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010844f:	0f b6 14 c5 25 71 11 	movzbl -0x7fee8edb(,%eax,8),%edx
80108456:	80 
80108457:	83 ca 80             	or     $0xffffff80,%edx
8010845a:	88 14 c5 25 71 11 80 	mov    %dl,-0x7fee8edb(,%eax,8)
80108461:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108464:	8b 04 85 c8 d0 10 80 	mov    -0x7fef2f38(,%eax,4),%eax
8010846b:	c1 e8 10             	shr    $0x10,%eax
8010846e:	89 c2                	mov    %eax,%edx
80108470:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108473:	66 89 14 c5 26 71 11 	mov    %dx,-0x7fee8eda(,%eax,8)
8010847a:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
8010847b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010847f:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
80108486:	0f 8e 30 ff ff ff    	jle    801083bc <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010848c:	a1 c8 d1 10 80       	mov    0x8010d1c8,%eax
80108491:	66 a3 20 73 11 80    	mov    %ax,0x80117320
80108497:	66 c7 05 22 73 11 80 	movw   $0x8,0x80117322
8010849e:	08 00 
801084a0:	0f b6 05 24 73 11 80 	movzbl 0x80117324,%eax
801084a7:	83 e0 e0             	and    $0xffffffe0,%eax
801084aa:	a2 24 73 11 80       	mov    %al,0x80117324
801084af:	0f b6 05 24 73 11 80 	movzbl 0x80117324,%eax
801084b6:	83 e0 1f             	and    $0x1f,%eax
801084b9:	a2 24 73 11 80       	mov    %al,0x80117324
801084be:	0f b6 05 25 73 11 80 	movzbl 0x80117325,%eax
801084c5:	83 c8 0f             	or     $0xf,%eax
801084c8:	a2 25 73 11 80       	mov    %al,0x80117325
801084cd:	0f b6 05 25 73 11 80 	movzbl 0x80117325,%eax
801084d4:	83 e0 ef             	and    $0xffffffef,%eax
801084d7:	a2 25 73 11 80       	mov    %al,0x80117325
801084dc:	0f b6 05 25 73 11 80 	movzbl 0x80117325,%eax
801084e3:	83 c8 60             	or     $0x60,%eax
801084e6:	a2 25 73 11 80       	mov    %al,0x80117325
801084eb:	0f b6 05 25 73 11 80 	movzbl 0x80117325,%eax
801084f2:	83 c8 80             	or     $0xffffff80,%eax
801084f5:	a2 25 73 11 80       	mov    %al,0x80117325
801084fa:	a1 c8 d1 10 80       	mov    0x8010d1c8,%eax
801084ff:	c1 e8 10             	shr    $0x10,%eax
80108502:	66 a3 26 73 11 80    	mov    %ax,0x80117326
  
}
80108508:	90                   	nop
80108509:	c9                   	leave  
8010850a:	c3                   	ret    

8010850b <idtinit>:

void
idtinit(void)
{
8010850b:	55                   	push   %ebp
8010850c:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
8010850e:	68 00 08 00 00       	push   $0x800
80108513:	68 20 71 11 80       	push   $0x80117120
80108518:	e8 52 fe ff ff       	call   8010836f <lidt>
8010851d:	83 c4 08             	add    $0x8,%esp
}
80108520:	90                   	nop
80108521:	c9                   	leave  
80108522:	c3                   	ret    

80108523 <trap>:

void
trap(struct trapframe *tf)
{
80108523:	55                   	push   %ebp
80108524:	89 e5                	mov    %esp,%ebp
80108526:	57                   	push   %edi
80108527:	56                   	push   %esi
80108528:	53                   	push   %ebx
80108529:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
8010852c:	8b 45 08             	mov    0x8(%ebp),%eax
8010852f:	8b 40 30             	mov    0x30(%eax),%eax
80108532:	83 f8 40             	cmp    $0x40,%eax
80108535:	75 3e                	jne    80108575 <trap+0x52>
    if(proc->killed)
80108537:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010853d:	8b 40 24             	mov    0x24(%eax),%eax
80108540:	85 c0                	test   %eax,%eax
80108542:	74 05                	je     80108549 <trap+0x26>
      exit();
80108544:	e8 37 cb ff ff       	call   80105080 <exit>
    proc->tf = tf;
80108549:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010854f:	8b 55 08             	mov    0x8(%ebp),%edx
80108552:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80108555:	e8 eb ea ff ff       	call   80107045 <syscall>
    if(proc->killed)
8010855a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108560:	8b 40 24             	mov    0x24(%eax),%eax
80108563:	85 c0                	test   %eax,%eax
80108565:	0f 84 21 02 00 00    	je     8010878c <trap+0x269>
      exit();
8010856b:	e8 10 cb ff ff       	call   80105080 <exit>
    return;
80108570:	e9 17 02 00 00       	jmp    8010878c <trap+0x269>
  }

  switch(tf->trapno){
80108575:	8b 45 08             	mov    0x8(%ebp),%eax
80108578:	8b 40 30             	mov    0x30(%eax),%eax
8010857b:	83 e8 20             	sub    $0x20,%eax
8010857e:	83 f8 1f             	cmp    $0x1f,%eax
80108581:	0f 87 a3 00 00 00    	ja     8010862a <trap+0x107>
80108587:	8b 04 85 d4 ab 10 80 	mov    -0x7fef542c(,%eax,4),%eax
8010858e:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
   if(cpu->id == 0){
80108590:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108596:	0f b6 00             	movzbl (%eax),%eax
80108599:	84 c0                	test   %al,%al
8010859b:	75 20                	jne    801085bd <trap+0x9a>
      atom_inc((int *)&ticks);   // guaranteed atomic so no lock necessary
8010859d:	83 ec 0c             	sub    $0xc,%esp
801085a0:	68 20 79 11 80       	push   $0x80117920
801085a5:	e8 b9 fd ff ff       	call   80108363 <atom_inc>
801085aa:	83 c4 10             	add    $0x10,%esp
      wakeup(&ticks);
801085ad:	83 ec 0c             	sub    $0xc,%esp
801085b0:	68 20 79 11 80       	push   $0x80117920
801085b5:	e8 45 d6 ff ff       	call   80105bff <wakeup>
801085ba:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
801085bd:	e8 02 ae ff ff       	call   801033c4 <lapiceoi>
    break;
801085c2:	e9 1c 01 00 00       	jmp    801086e3 <trap+0x1c0>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801085c7:	e8 0b a6 ff ff       	call   80102bd7 <ideintr>
    lapiceoi();
801085cc:	e8 f3 ad ff ff       	call   801033c4 <lapiceoi>
    break;
801085d1:	e9 0d 01 00 00       	jmp    801086e3 <trap+0x1c0>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801085d6:	e8 eb ab ff ff       	call   801031c6 <kbdintr>
    lapiceoi();
801085db:	e8 e4 ad ff ff       	call   801033c4 <lapiceoi>
    break;
801085e0:	e9 fe 00 00 00       	jmp    801086e3 <trap+0x1c0>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801085e5:	e8 83 03 00 00       	call   8010896d <uartintr>
    lapiceoi();
801085ea:	e8 d5 ad ff ff       	call   801033c4 <lapiceoi>
    break;
801085ef:	e9 ef 00 00 00       	jmp    801086e3 <trap+0x1c0>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801085f4:	8b 45 08             	mov    0x8(%ebp),%eax
801085f7:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
801085fa:	8b 45 08             	mov    0x8(%ebp),%eax
801085fd:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80108601:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80108604:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010860a:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010860d:	0f b6 c0             	movzbl %al,%eax
80108610:	51                   	push   %ecx
80108611:	52                   	push   %edx
80108612:	50                   	push   %eax
80108613:	68 34 ab 10 80       	push   $0x8010ab34
80108618:	e8 a9 7d ff ff       	call   801003c6 <cprintf>
8010861d:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80108620:	e8 9f ad ff ff       	call   801033c4 <lapiceoi>
    break;
80108625:	e9 b9 00 00 00       	jmp    801086e3 <trap+0x1c0>
   
  default:
    if(proc == 0 || (tf->cs&3) == 0){
8010862a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108630:	85 c0                	test   %eax,%eax
80108632:	74 11                	je     80108645 <trap+0x122>
80108634:	8b 45 08             	mov    0x8(%ebp),%eax
80108637:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010863b:	0f b7 c0             	movzwl %ax,%eax
8010863e:	83 e0 03             	and    $0x3,%eax
80108641:	85 c0                	test   %eax,%eax
80108643:	75 40                	jne    80108685 <trap+0x162>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80108645:	e8 4f fd ff ff       	call   80108399 <rcr2>
8010864a:	89 c3                	mov    %eax,%ebx
8010864c:	8b 45 08             	mov    0x8(%ebp),%eax
8010864f:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80108652:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108658:	0f b6 00             	movzbl (%eax),%eax
    break;
   
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010865b:	0f b6 d0             	movzbl %al,%edx
8010865e:	8b 45 08             	mov    0x8(%ebp),%eax
80108661:	8b 40 30             	mov    0x30(%eax),%eax
80108664:	83 ec 0c             	sub    $0xc,%esp
80108667:	53                   	push   %ebx
80108668:	51                   	push   %ecx
80108669:	52                   	push   %edx
8010866a:	50                   	push   %eax
8010866b:	68 58 ab 10 80       	push   $0x8010ab58
80108670:	e8 51 7d ff ff       	call   801003c6 <cprintf>
80108675:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80108678:	83 ec 0c             	sub    $0xc,%esp
8010867b:	68 8a ab 10 80       	push   $0x8010ab8a
80108680:	e8 e1 7e ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80108685:	e8 0f fd ff ff       	call   80108399 <rcr2>
8010868a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010868d:	8b 45 08             	mov    0x8(%ebp),%eax
80108690:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80108693:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108699:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010869c:	0f b6 d8             	movzbl %al,%ebx
8010869f:	8b 45 08             	mov    0x8(%ebp),%eax
801086a2:	8b 48 34             	mov    0x34(%eax),%ecx
801086a5:	8b 45 08             	mov    0x8(%ebp),%eax
801086a8:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801086ab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801086b1:	8d 78 6c             	lea    0x6c(%eax),%edi
801086b4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801086ba:	8b 40 10             	mov    0x10(%eax),%eax
801086bd:	ff 75 e4             	pushl  -0x1c(%ebp)
801086c0:	56                   	push   %esi
801086c1:	53                   	push   %ebx
801086c2:	51                   	push   %ecx
801086c3:	52                   	push   %edx
801086c4:	57                   	push   %edi
801086c5:	50                   	push   %eax
801086c6:	68 90 ab 10 80       	push   $0x8010ab90
801086cb:	e8 f6 7c ff ff       	call   801003c6 <cprintf>
801086d0:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
801086d3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801086d9:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801086e0:	eb 01                	jmp    801086e3 <trap+0x1c0>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
801086e2:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801086e3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801086e9:	85 c0                	test   %eax,%eax
801086eb:	74 24                	je     80108711 <trap+0x1ee>
801086ed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801086f3:	8b 40 24             	mov    0x24(%eax),%eax
801086f6:	85 c0                	test   %eax,%eax
801086f8:	74 17                	je     80108711 <trap+0x1ee>
801086fa:	8b 45 08             	mov    0x8(%ebp),%eax
801086fd:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80108701:	0f b7 c0             	movzwl %ax,%eax
80108704:	83 e0 03             	and    $0x3,%eax
80108707:	83 f8 03             	cmp    $0x3,%eax
8010870a:	75 05                	jne    80108711 <trap+0x1ee>
    exit();
8010870c:	e8 6f c9 ff ff       	call   80105080 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING &&
80108711:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108717:	85 c0                	test   %eax,%eax
80108719:	74 41                	je     8010875c <trap+0x239>
8010871b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108721:	8b 40 0c             	mov    0xc(%eax),%eax
80108724:	83 f8 04             	cmp    $0x4,%eax
80108727:	75 33                	jne    8010875c <trap+0x239>
	  tf->trapno == T_IRQ0+IRQ_TIMER && ticks%SCHED_INTERVAL==0)
80108729:	8b 45 08             	mov    0x8(%ebp),%eax
8010872c:	8b 40 30             	mov    0x30(%eax),%eax
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING &&
8010872f:	83 f8 20             	cmp    $0x20,%eax
80108732:	75 28                	jne    8010875c <trap+0x239>
	  tf->trapno == T_IRQ0+IRQ_TIMER && ticks%SCHED_INTERVAL==0)
80108734:	8b 0d 20 79 11 80    	mov    0x80117920,%ecx
8010873a:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
8010873f:	89 c8                	mov    %ecx,%eax
80108741:	f7 e2                	mul    %edx
80108743:	c1 ea 03             	shr    $0x3,%edx
80108746:	89 d0                	mov    %edx,%eax
80108748:	c1 e0 02             	shl    $0x2,%eax
8010874b:	01 d0                	add    %edx,%eax
8010874d:	01 c0                	add    %eax,%eax
8010874f:	29 c1                	sub    %eax,%ecx
80108751:	89 ca                	mov    %ecx,%edx
80108753:	85 d2                	test   %edx,%edx
80108755:	75 05                	jne    8010875c <trap+0x239>
    yield();
80108757:	e8 c3 d0 ff ff       	call   8010581f <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
8010875c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108762:	85 c0                	test   %eax,%eax
80108764:	74 27                	je     8010878d <trap+0x26a>
80108766:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010876c:	8b 40 24             	mov    0x24(%eax),%eax
8010876f:	85 c0                	test   %eax,%eax
80108771:	74 1a                	je     8010878d <trap+0x26a>
80108773:	8b 45 08             	mov    0x8(%ebp),%eax
80108776:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010877a:	0f b7 c0             	movzwl %ax,%eax
8010877d:	83 e0 03             	and    $0x3,%eax
80108780:	83 f8 03             	cmp    $0x3,%eax
80108783:	75 08                	jne    8010878d <trap+0x26a>
    exit();
80108785:	e8 f6 c8 ff ff       	call   80105080 <exit>
8010878a:	eb 01                	jmp    8010878d <trap+0x26a>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
8010878c:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
8010878d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80108790:	5b                   	pop    %ebx
80108791:	5e                   	pop    %esi
80108792:	5f                   	pop    %edi
80108793:	5d                   	pop    %ebp
80108794:	c3                   	ret    

80108795 <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80108795:	55                   	push   %ebp
80108796:	89 e5                	mov    %esp,%ebp
80108798:	83 ec 14             	sub    $0x14,%esp
8010879b:	8b 45 08             	mov    0x8(%ebp),%eax
8010879e:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801087a2:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801087a6:	89 c2                	mov    %eax,%edx
801087a8:	ec                   	in     (%dx),%al
801087a9:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801087ac:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801087b0:	c9                   	leave  
801087b1:	c3                   	ret    

801087b2 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801087b2:	55                   	push   %ebp
801087b3:	89 e5                	mov    %esp,%ebp
801087b5:	83 ec 08             	sub    $0x8,%esp
801087b8:	8b 55 08             	mov    0x8(%ebp),%edx
801087bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801087be:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801087c2:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801087c5:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801087c9:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801087cd:	ee                   	out    %al,(%dx)
}
801087ce:	90                   	nop
801087cf:	c9                   	leave  
801087d0:	c3                   	ret    

801087d1 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801087d1:	55                   	push   %ebp
801087d2:	89 e5                	mov    %esp,%ebp
801087d4:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801087d7:	6a 00                	push   $0x0
801087d9:	68 fa 03 00 00       	push   $0x3fa
801087de:	e8 cf ff ff ff       	call   801087b2 <outb>
801087e3:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801087e6:	68 80 00 00 00       	push   $0x80
801087eb:	68 fb 03 00 00       	push   $0x3fb
801087f0:	e8 bd ff ff ff       	call   801087b2 <outb>
801087f5:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801087f8:	6a 0c                	push   $0xc
801087fa:	68 f8 03 00 00       	push   $0x3f8
801087ff:	e8 ae ff ff ff       	call   801087b2 <outb>
80108804:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80108807:	6a 00                	push   $0x0
80108809:	68 f9 03 00 00       	push   $0x3f9
8010880e:	e8 9f ff ff ff       	call   801087b2 <outb>
80108813:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80108816:	6a 03                	push   $0x3
80108818:	68 fb 03 00 00       	push   $0x3fb
8010881d:	e8 90 ff ff ff       	call   801087b2 <outb>
80108822:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80108825:	6a 00                	push   $0x0
80108827:	68 fc 03 00 00       	push   $0x3fc
8010882c:	e8 81 ff ff ff       	call   801087b2 <outb>
80108831:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80108834:	6a 01                	push   $0x1
80108836:	68 f9 03 00 00       	push   $0x3f9
8010883b:	e8 72 ff ff ff       	call   801087b2 <outb>
80108840:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80108843:	68 fd 03 00 00       	push   $0x3fd
80108848:	e8 48 ff ff ff       	call   80108795 <inb>
8010884d:	83 c4 04             	add    $0x4,%esp
80108850:	3c ff                	cmp    $0xff,%al
80108852:	74 6e                	je     801088c2 <uartinit+0xf1>
    return;
  uart = 1;
80108854:	c7 05 8c d6 10 80 01 	movl   $0x1,0x8010d68c
8010885b:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
8010885e:	68 fa 03 00 00       	push   $0x3fa
80108863:	e8 2d ff ff ff       	call   80108795 <inb>
80108868:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
8010886b:	68 f8 03 00 00       	push   $0x3f8
80108870:	e8 20 ff ff ff       	call   80108795 <inb>
80108875:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
80108878:	83 ec 0c             	sub    $0xc,%esp
8010887b:	6a 04                	push   $0x4
8010887d:	e8 48 ba ff ff       	call   801042ca <picenable>
80108882:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80108885:	83 ec 08             	sub    $0x8,%esp
80108888:	6a 00                	push   $0x0
8010888a:	6a 04                	push   $0x4
8010888c:	e8 e8 a5 ff ff       	call   80102e79 <ioapicenable>
80108891:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80108894:	c7 45 f4 54 ac 10 80 	movl   $0x8010ac54,-0xc(%ebp)
8010889b:	eb 19                	jmp    801088b6 <uartinit+0xe5>
    uartputc(*p);
8010889d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088a0:	0f b6 00             	movzbl (%eax),%eax
801088a3:	0f be c0             	movsbl %al,%eax
801088a6:	83 ec 0c             	sub    $0xc,%esp
801088a9:	50                   	push   %eax
801088aa:	e8 16 00 00 00       	call   801088c5 <uartputc>
801088af:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801088b2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801088b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088b9:	0f b6 00             	movzbl (%eax),%eax
801088bc:	84 c0                	test   %al,%al
801088be:	75 dd                	jne    8010889d <uartinit+0xcc>
801088c0:	eb 01                	jmp    801088c3 <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
801088c2:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
801088c3:	c9                   	leave  
801088c4:	c3                   	ret    

801088c5 <uartputc>:

void
uartputc(int c)
{
801088c5:	55                   	push   %ebp
801088c6:	89 e5                	mov    %esp,%ebp
801088c8:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801088cb:	a1 8c d6 10 80       	mov    0x8010d68c,%eax
801088d0:	85 c0                	test   %eax,%eax
801088d2:	74 53                	je     80108927 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801088d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801088db:	eb 11                	jmp    801088ee <uartputc+0x29>
    microdelay(10);
801088dd:	83 ec 0c             	sub    $0xc,%esp
801088e0:	6a 0a                	push   $0xa
801088e2:	e8 f8 aa ff ff       	call   801033df <microdelay>
801088e7:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801088ea:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801088ee:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801088f2:	7f 1a                	jg     8010890e <uartputc+0x49>
801088f4:	83 ec 0c             	sub    $0xc,%esp
801088f7:	68 fd 03 00 00       	push   $0x3fd
801088fc:	e8 94 fe ff ff       	call   80108795 <inb>
80108901:	83 c4 10             	add    $0x10,%esp
80108904:	0f b6 c0             	movzbl %al,%eax
80108907:	83 e0 20             	and    $0x20,%eax
8010890a:	85 c0                	test   %eax,%eax
8010890c:	74 cf                	je     801088dd <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
8010890e:	8b 45 08             	mov    0x8(%ebp),%eax
80108911:	0f b6 c0             	movzbl %al,%eax
80108914:	83 ec 08             	sub    $0x8,%esp
80108917:	50                   	push   %eax
80108918:	68 f8 03 00 00       	push   $0x3f8
8010891d:	e8 90 fe ff ff       	call   801087b2 <outb>
80108922:	83 c4 10             	add    $0x10,%esp
80108925:	eb 01                	jmp    80108928 <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80108927:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80108928:	c9                   	leave  
80108929:	c3                   	ret    

8010892a <uartgetc>:

static int
uartgetc(void)
{
8010892a:	55                   	push   %ebp
8010892b:	89 e5                	mov    %esp,%ebp
  if(!uart)
8010892d:	a1 8c d6 10 80       	mov    0x8010d68c,%eax
80108932:	85 c0                	test   %eax,%eax
80108934:	75 07                	jne    8010893d <uartgetc+0x13>
    return -1;
80108936:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010893b:	eb 2e                	jmp    8010896b <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
8010893d:	68 fd 03 00 00       	push   $0x3fd
80108942:	e8 4e fe ff ff       	call   80108795 <inb>
80108947:	83 c4 04             	add    $0x4,%esp
8010894a:	0f b6 c0             	movzbl %al,%eax
8010894d:	83 e0 01             	and    $0x1,%eax
80108950:	85 c0                	test   %eax,%eax
80108952:	75 07                	jne    8010895b <uartgetc+0x31>
    return -1;
80108954:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108959:	eb 10                	jmp    8010896b <uartgetc+0x41>
  return inb(COM1+0);
8010895b:	68 f8 03 00 00       	push   $0x3f8
80108960:	e8 30 fe ff ff       	call   80108795 <inb>
80108965:	83 c4 04             	add    $0x4,%esp
80108968:	0f b6 c0             	movzbl %al,%eax
}
8010896b:	c9                   	leave  
8010896c:	c3                   	ret    

8010896d <uartintr>:

void
uartintr(void)
{
8010896d:	55                   	push   %ebp
8010896e:	89 e5                	mov    %esp,%ebp
80108970:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80108973:	83 ec 0c             	sub    $0xc,%esp
80108976:	68 2a 89 10 80       	push   $0x8010892a
8010897b:	e8 79 7e ff ff       	call   801007f9 <consoleintr>
80108980:	83 c4 10             	add    $0x10,%esp
}
80108983:	90                   	nop
80108984:	c9                   	leave  
80108985:	c3                   	ret    

80108986 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80108986:	6a 00                	push   $0x0
  pushl $0
80108988:	6a 00                	push   $0x0
  jmp alltraps
8010898a:	e9 a9 f9 ff ff       	jmp    80108338 <alltraps>

8010898f <vector1>:
.globl vector1
vector1:
  pushl $0
8010898f:	6a 00                	push   $0x0
  pushl $1
80108991:	6a 01                	push   $0x1
  jmp alltraps
80108993:	e9 a0 f9 ff ff       	jmp    80108338 <alltraps>

80108998 <vector2>:
.globl vector2
vector2:
  pushl $0
80108998:	6a 00                	push   $0x0
  pushl $2
8010899a:	6a 02                	push   $0x2
  jmp alltraps
8010899c:	e9 97 f9 ff ff       	jmp    80108338 <alltraps>

801089a1 <vector3>:
.globl vector3
vector3:
  pushl $0
801089a1:	6a 00                	push   $0x0
  pushl $3
801089a3:	6a 03                	push   $0x3
  jmp alltraps
801089a5:	e9 8e f9 ff ff       	jmp    80108338 <alltraps>

801089aa <vector4>:
.globl vector4
vector4:
  pushl $0
801089aa:	6a 00                	push   $0x0
  pushl $4
801089ac:	6a 04                	push   $0x4
  jmp alltraps
801089ae:	e9 85 f9 ff ff       	jmp    80108338 <alltraps>

801089b3 <vector5>:
.globl vector5
vector5:
  pushl $0
801089b3:	6a 00                	push   $0x0
  pushl $5
801089b5:	6a 05                	push   $0x5
  jmp alltraps
801089b7:	e9 7c f9 ff ff       	jmp    80108338 <alltraps>

801089bc <vector6>:
.globl vector6
vector6:
  pushl $0
801089bc:	6a 00                	push   $0x0
  pushl $6
801089be:	6a 06                	push   $0x6
  jmp alltraps
801089c0:	e9 73 f9 ff ff       	jmp    80108338 <alltraps>

801089c5 <vector7>:
.globl vector7
vector7:
  pushl $0
801089c5:	6a 00                	push   $0x0
  pushl $7
801089c7:	6a 07                	push   $0x7
  jmp alltraps
801089c9:	e9 6a f9 ff ff       	jmp    80108338 <alltraps>

801089ce <vector8>:
.globl vector8
vector8:
  pushl $8
801089ce:	6a 08                	push   $0x8
  jmp alltraps
801089d0:	e9 63 f9 ff ff       	jmp    80108338 <alltraps>

801089d5 <vector9>:
.globl vector9
vector9:
  pushl $0
801089d5:	6a 00                	push   $0x0
  pushl $9
801089d7:	6a 09                	push   $0x9
  jmp alltraps
801089d9:	e9 5a f9 ff ff       	jmp    80108338 <alltraps>

801089de <vector10>:
.globl vector10
vector10:
  pushl $10
801089de:	6a 0a                	push   $0xa
  jmp alltraps
801089e0:	e9 53 f9 ff ff       	jmp    80108338 <alltraps>

801089e5 <vector11>:
.globl vector11
vector11:
  pushl $11
801089e5:	6a 0b                	push   $0xb
  jmp alltraps
801089e7:	e9 4c f9 ff ff       	jmp    80108338 <alltraps>

801089ec <vector12>:
.globl vector12
vector12:
  pushl $12
801089ec:	6a 0c                	push   $0xc
  jmp alltraps
801089ee:	e9 45 f9 ff ff       	jmp    80108338 <alltraps>

801089f3 <vector13>:
.globl vector13
vector13:
  pushl $13
801089f3:	6a 0d                	push   $0xd
  jmp alltraps
801089f5:	e9 3e f9 ff ff       	jmp    80108338 <alltraps>

801089fa <vector14>:
.globl vector14
vector14:
  pushl $14
801089fa:	6a 0e                	push   $0xe
  jmp alltraps
801089fc:	e9 37 f9 ff ff       	jmp    80108338 <alltraps>

80108a01 <vector15>:
.globl vector15
vector15:
  pushl $0
80108a01:	6a 00                	push   $0x0
  pushl $15
80108a03:	6a 0f                	push   $0xf
  jmp alltraps
80108a05:	e9 2e f9 ff ff       	jmp    80108338 <alltraps>

80108a0a <vector16>:
.globl vector16
vector16:
  pushl $0
80108a0a:	6a 00                	push   $0x0
  pushl $16
80108a0c:	6a 10                	push   $0x10
  jmp alltraps
80108a0e:	e9 25 f9 ff ff       	jmp    80108338 <alltraps>

80108a13 <vector17>:
.globl vector17
vector17:
  pushl $17
80108a13:	6a 11                	push   $0x11
  jmp alltraps
80108a15:	e9 1e f9 ff ff       	jmp    80108338 <alltraps>

80108a1a <vector18>:
.globl vector18
vector18:
  pushl $0
80108a1a:	6a 00                	push   $0x0
  pushl $18
80108a1c:	6a 12                	push   $0x12
  jmp alltraps
80108a1e:	e9 15 f9 ff ff       	jmp    80108338 <alltraps>

80108a23 <vector19>:
.globl vector19
vector19:
  pushl $0
80108a23:	6a 00                	push   $0x0
  pushl $19
80108a25:	6a 13                	push   $0x13
  jmp alltraps
80108a27:	e9 0c f9 ff ff       	jmp    80108338 <alltraps>

80108a2c <vector20>:
.globl vector20
vector20:
  pushl $0
80108a2c:	6a 00                	push   $0x0
  pushl $20
80108a2e:	6a 14                	push   $0x14
  jmp alltraps
80108a30:	e9 03 f9 ff ff       	jmp    80108338 <alltraps>

80108a35 <vector21>:
.globl vector21
vector21:
  pushl $0
80108a35:	6a 00                	push   $0x0
  pushl $21
80108a37:	6a 15                	push   $0x15
  jmp alltraps
80108a39:	e9 fa f8 ff ff       	jmp    80108338 <alltraps>

80108a3e <vector22>:
.globl vector22
vector22:
  pushl $0
80108a3e:	6a 00                	push   $0x0
  pushl $22
80108a40:	6a 16                	push   $0x16
  jmp alltraps
80108a42:	e9 f1 f8 ff ff       	jmp    80108338 <alltraps>

80108a47 <vector23>:
.globl vector23
vector23:
  pushl $0
80108a47:	6a 00                	push   $0x0
  pushl $23
80108a49:	6a 17                	push   $0x17
  jmp alltraps
80108a4b:	e9 e8 f8 ff ff       	jmp    80108338 <alltraps>

80108a50 <vector24>:
.globl vector24
vector24:
  pushl $0
80108a50:	6a 00                	push   $0x0
  pushl $24
80108a52:	6a 18                	push   $0x18
  jmp alltraps
80108a54:	e9 df f8 ff ff       	jmp    80108338 <alltraps>

80108a59 <vector25>:
.globl vector25
vector25:
  pushl $0
80108a59:	6a 00                	push   $0x0
  pushl $25
80108a5b:	6a 19                	push   $0x19
  jmp alltraps
80108a5d:	e9 d6 f8 ff ff       	jmp    80108338 <alltraps>

80108a62 <vector26>:
.globl vector26
vector26:
  pushl $0
80108a62:	6a 00                	push   $0x0
  pushl $26
80108a64:	6a 1a                	push   $0x1a
  jmp alltraps
80108a66:	e9 cd f8 ff ff       	jmp    80108338 <alltraps>

80108a6b <vector27>:
.globl vector27
vector27:
  pushl $0
80108a6b:	6a 00                	push   $0x0
  pushl $27
80108a6d:	6a 1b                	push   $0x1b
  jmp alltraps
80108a6f:	e9 c4 f8 ff ff       	jmp    80108338 <alltraps>

80108a74 <vector28>:
.globl vector28
vector28:
  pushl $0
80108a74:	6a 00                	push   $0x0
  pushl $28
80108a76:	6a 1c                	push   $0x1c
  jmp alltraps
80108a78:	e9 bb f8 ff ff       	jmp    80108338 <alltraps>

80108a7d <vector29>:
.globl vector29
vector29:
  pushl $0
80108a7d:	6a 00                	push   $0x0
  pushl $29
80108a7f:	6a 1d                	push   $0x1d
  jmp alltraps
80108a81:	e9 b2 f8 ff ff       	jmp    80108338 <alltraps>

80108a86 <vector30>:
.globl vector30
vector30:
  pushl $0
80108a86:	6a 00                	push   $0x0
  pushl $30
80108a88:	6a 1e                	push   $0x1e
  jmp alltraps
80108a8a:	e9 a9 f8 ff ff       	jmp    80108338 <alltraps>

80108a8f <vector31>:
.globl vector31
vector31:
  pushl $0
80108a8f:	6a 00                	push   $0x0
  pushl $31
80108a91:	6a 1f                	push   $0x1f
  jmp alltraps
80108a93:	e9 a0 f8 ff ff       	jmp    80108338 <alltraps>

80108a98 <vector32>:
.globl vector32
vector32:
  pushl $0
80108a98:	6a 00                	push   $0x0
  pushl $32
80108a9a:	6a 20                	push   $0x20
  jmp alltraps
80108a9c:	e9 97 f8 ff ff       	jmp    80108338 <alltraps>

80108aa1 <vector33>:
.globl vector33
vector33:
  pushl $0
80108aa1:	6a 00                	push   $0x0
  pushl $33
80108aa3:	6a 21                	push   $0x21
  jmp alltraps
80108aa5:	e9 8e f8 ff ff       	jmp    80108338 <alltraps>

80108aaa <vector34>:
.globl vector34
vector34:
  pushl $0
80108aaa:	6a 00                	push   $0x0
  pushl $34
80108aac:	6a 22                	push   $0x22
  jmp alltraps
80108aae:	e9 85 f8 ff ff       	jmp    80108338 <alltraps>

80108ab3 <vector35>:
.globl vector35
vector35:
  pushl $0
80108ab3:	6a 00                	push   $0x0
  pushl $35
80108ab5:	6a 23                	push   $0x23
  jmp alltraps
80108ab7:	e9 7c f8 ff ff       	jmp    80108338 <alltraps>

80108abc <vector36>:
.globl vector36
vector36:
  pushl $0
80108abc:	6a 00                	push   $0x0
  pushl $36
80108abe:	6a 24                	push   $0x24
  jmp alltraps
80108ac0:	e9 73 f8 ff ff       	jmp    80108338 <alltraps>

80108ac5 <vector37>:
.globl vector37
vector37:
  pushl $0
80108ac5:	6a 00                	push   $0x0
  pushl $37
80108ac7:	6a 25                	push   $0x25
  jmp alltraps
80108ac9:	e9 6a f8 ff ff       	jmp    80108338 <alltraps>

80108ace <vector38>:
.globl vector38
vector38:
  pushl $0
80108ace:	6a 00                	push   $0x0
  pushl $38
80108ad0:	6a 26                	push   $0x26
  jmp alltraps
80108ad2:	e9 61 f8 ff ff       	jmp    80108338 <alltraps>

80108ad7 <vector39>:
.globl vector39
vector39:
  pushl $0
80108ad7:	6a 00                	push   $0x0
  pushl $39
80108ad9:	6a 27                	push   $0x27
  jmp alltraps
80108adb:	e9 58 f8 ff ff       	jmp    80108338 <alltraps>

80108ae0 <vector40>:
.globl vector40
vector40:
  pushl $0
80108ae0:	6a 00                	push   $0x0
  pushl $40
80108ae2:	6a 28                	push   $0x28
  jmp alltraps
80108ae4:	e9 4f f8 ff ff       	jmp    80108338 <alltraps>

80108ae9 <vector41>:
.globl vector41
vector41:
  pushl $0
80108ae9:	6a 00                	push   $0x0
  pushl $41
80108aeb:	6a 29                	push   $0x29
  jmp alltraps
80108aed:	e9 46 f8 ff ff       	jmp    80108338 <alltraps>

80108af2 <vector42>:
.globl vector42
vector42:
  pushl $0
80108af2:	6a 00                	push   $0x0
  pushl $42
80108af4:	6a 2a                	push   $0x2a
  jmp alltraps
80108af6:	e9 3d f8 ff ff       	jmp    80108338 <alltraps>

80108afb <vector43>:
.globl vector43
vector43:
  pushl $0
80108afb:	6a 00                	push   $0x0
  pushl $43
80108afd:	6a 2b                	push   $0x2b
  jmp alltraps
80108aff:	e9 34 f8 ff ff       	jmp    80108338 <alltraps>

80108b04 <vector44>:
.globl vector44
vector44:
  pushl $0
80108b04:	6a 00                	push   $0x0
  pushl $44
80108b06:	6a 2c                	push   $0x2c
  jmp alltraps
80108b08:	e9 2b f8 ff ff       	jmp    80108338 <alltraps>

80108b0d <vector45>:
.globl vector45
vector45:
  pushl $0
80108b0d:	6a 00                	push   $0x0
  pushl $45
80108b0f:	6a 2d                	push   $0x2d
  jmp alltraps
80108b11:	e9 22 f8 ff ff       	jmp    80108338 <alltraps>

80108b16 <vector46>:
.globl vector46
vector46:
  pushl $0
80108b16:	6a 00                	push   $0x0
  pushl $46
80108b18:	6a 2e                	push   $0x2e
  jmp alltraps
80108b1a:	e9 19 f8 ff ff       	jmp    80108338 <alltraps>

80108b1f <vector47>:
.globl vector47
vector47:
  pushl $0
80108b1f:	6a 00                	push   $0x0
  pushl $47
80108b21:	6a 2f                	push   $0x2f
  jmp alltraps
80108b23:	e9 10 f8 ff ff       	jmp    80108338 <alltraps>

80108b28 <vector48>:
.globl vector48
vector48:
  pushl $0
80108b28:	6a 00                	push   $0x0
  pushl $48
80108b2a:	6a 30                	push   $0x30
  jmp alltraps
80108b2c:	e9 07 f8 ff ff       	jmp    80108338 <alltraps>

80108b31 <vector49>:
.globl vector49
vector49:
  pushl $0
80108b31:	6a 00                	push   $0x0
  pushl $49
80108b33:	6a 31                	push   $0x31
  jmp alltraps
80108b35:	e9 fe f7 ff ff       	jmp    80108338 <alltraps>

80108b3a <vector50>:
.globl vector50
vector50:
  pushl $0
80108b3a:	6a 00                	push   $0x0
  pushl $50
80108b3c:	6a 32                	push   $0x32
  jmp alltraps
80108b3e:	e9 f5 f7 ff ff       	jmp    80108338 <alltraps>

80108b43 <vector51>:
.globl vector51
vector51:
  pushl $0
80108b43:	6a 00                	push   $0x0
  pushl $51
80108b45:	6a 33                	push   $0x33
  jmp alltraps
80108b47:	e9 ec f7 ff ff       	jmp    80108338 <alltraps>

80108b4c <vector52>:
.globl vector52
vector52:
  pushl $0
80108b4c:	6a 00                	push   $0x0
  pushl $52
80108b4e:	6a 34                	push   $0x34
  jmp alltraps
80108b50:	e9 e3 f7 ff ff       	jmp    80108338 <alltraps>

80108b55 <vector53>:
.globl vector53
vector53:
  pushl $0
80108b55:	6a 00                	push   $0x0
  pushl $53
80108b57:	6a 35                	push   $0x35
  jmp alltraps
80108b59:	e9 da f7 ff ff       	jmp    80108338 <alltraps>

80108b5e <vector54>:
.globl vector54
vector54:
  pushl $0
80108b5e:	6a 00                	push   $0x0
  pushl $54
80108b60:	6a 36                	push   $0x36
  jmp alltraps
80108b62:	e9 d1 f7 ff ff       	jmp    80108338 <alltraps>

80108b67 <vector55>:
.globl vector55
vector55:
  pushl $0
80108b67:	6a 00                	push   $0x0
  pushl $55
80108b69:	6a 37                	push   $0x37
  jmp alltraps
80108b6b:	e9 c8 f7 ff ff       	jmp    80108338 <alltraps>

80108b70 <vector56>:
.globl vector56
vector56:
  pushl $0
80108b70:	6a 00                	push   $0x0
  pushl $56
80108b72:	6a 38                	push   $0x38
  jmp alltraps
80108b74:	e9 bf f7 ff ff       	jmp    80108338 <alltraps>

80108b79 <vector57>:
.globl vector57
vector57:
  pushl $0
80108b79:	6a 00                	push   $0x0
  pushl $57
80108b7b:	6a 39                	push   $0x39
  jmp alltraps
80108b7d:	e9 b6 f7 ff ff       	jmp    80108338 <alltraps>

80108b82 <vector58>:
.globl vector58
vector58:
  pushl $0
80108b82:	6a 00                	push   $0x0
  pushl $58
80108b84:	6a 3a                	push   $0x3a
  jmp alltraps
80108b86:	e9 ad f7 ff ff       	jmp    80108338 <alltraps>

80108b8b <vector59>:
.globl vector59
vector59:
  pushl $0
80108b8b:	6a 00                	push   $0x0
  pushl $59
80108b8d:	6a 3b                	push   $0x3b
  jmp alltraps
80108b8f:	e9 a4 f7 ff ff       	jmp    80108338 <alltraps>

80108b94 <vector60>:
.globl vector60
vector60:
  pushl $0
80108b94:	6a 00                	push   $0x0
  pushl $60
80108b96:	6a 3c                	push   $0x3c
  jmp alltraps
80108b98:	e9 9b f7 ff ff       	jmp    80108338 <alltraps>

80108b9d <vector61>:
.globl vector61
vector61:
  pushl $0
80108b9d:	6a 00                	push   $0x0
  pushl $61
80108b9f:	6a 3d                	push   $0x3d
  jmp alltraps
80108ba1:	e9 92 f7 ff ff       	jmp    80108338 <alltraps>

80108ba6 <vector62>:
.globl vector62
vector62:
  pushl $0
80108ba6:	6a 00                	push   $0x0
  pushl $62
80108ba8:	6a 3e                	push   $0x3e
  jmp alltraps
80108baa:	e9 89 f7 ff ff       	jmp    80108338 <alltraps>

80108baf <vector63>:
.globl vector63
vector63:
  pushl $0
80108baf:	6a 00                	push   $0x0
  pushl $63
80108bb1:	6a 3f                	push   $0x3f
  jmp alltraps
80108bb3:	e9 80 f7 ff ff       	jmp    80108338 <alltraps>

80108bb8 <vector64>:
.globl vector64
vector64:
  pushl $0
80108bb8:	6a 00                	push   $0x0
  pushl $64
80108bba:	6a 40                	push   $0x40
  jmp alltraps
80108bbc:	e9 77 f7 ff ff       	jmp    80108338 <alltraps>

80108bc1 <vector65>:
.globl vector65
vector65:
  pushl $0
80108bc1:	6a 00                	push   $0x0
  pushl $65
80108bc3:	6a 41                	push   $0x41
  jmp alltraps
80108bc5:	e9 6e f7 ff ff       	jmp    80108338 <alltraps>

80108bca <vector66>:
.globl vector66
vector66:
  pushl $0
80108bca:	6a 00                	push   $0x0
  pushl $66
80108bcc:	6a 42                	push   $0x42
  jmp alltraps
80108bce:	e9 65 f7 ff ff       	jmp    80108338 <alltraps>

80108bd3 <vector67>:
.globl vector67
vector67:
  pushl $0
80108bd3:	6a 00                	push   $0x0
  pushl $67
80108bd5:	6a 43                	push   $0x43
  jmp alltraps
80108bd7:	e9 5c f7 ff ff       	jmp    80108338 <alltraps>

80108bdc <vector68>:
.globl vector68
vector68:
  pushl $0
80108bdc:	6a 00                	push   $0x0
  pushl $68
80108bde:	6a 44                	push   $0x44
  jmp alltraps
80108be0:	e9 53 f7 ff ff       	jmp    80108338 <alltraps>

80108be5 <vector69>:
.globl vector69
vector69:
  pushl $0
80108be5:	6a 00                	push   $0x0
  pushl $69
80108be7:	6a 45                	push   $0x45
  jmp alltraps
80108be9:	e9 4a f7 ff ff       	jmp    80108338 <alltraps>

80108bee <vector70>:
.globl vector70
vector70:
  pushl $0
80108bee:	6a 00                	push   $0x0
  pushl $70
80108bf0:	6a 46                	push   $0x46
  jmp alltraps
80108bf2:	e9 41 f7 ff ff       	jmp    80108338 <alltraps>

80108bf7 <vector71>:
.globl vector71
vector71:
  pushl $0
80108bf7:	6a 00                	push   $0x0
  pushl $71
80108bf9:	6a 47                	push   $0x47
  jmp alltraps
80108bfb:	e9 38 f7 ff ff       	jmp    80108338 <alltraps>

80108c00 <vector72>:
.globl vector72
vector72:
  pushl $0
80108c00:	6a 00                	push   $0x0
  pushl $72
80108c02:	6a 48                	push   $0x48
  jmp alltraps
80108c04:	e9 2f f7 ff ff       	jmp    80108338 <alltraps>

80108c09 <vector73>:
.globl vector73
vector73:
  pushl $0
80108c09:	6a 00                	push   $0x0
  pushl $73
80108c0b:	6a 49                	push   $0x49
  jmp alltraps
80108c0d:	e9 26 f7 ff ff       	jmp    80108338 <alltraps>

80108c12 <vector74>:
.globl vector74
vector74:
  pushl $0
80108c12:	6a 00                	push   $0x0
  pushl $74
80108c14:	6a 4a                	push   $0x4a
  jmp alltraps
80108c16:	e9 1d f7 ff ff       	jmp    80108338 <alltraps>

80108c1b <vector75>:
.globl vector75
vector75:
  pushl $0
80108c1b:	6a 00                	push   $0x0
  pushl $75
80108c1d:	6a 4b                	push   $0x4b
  jmp alltraps
80108c1f:	e9 14 f7 ff ff       	jmp    80108338 <alltraps>

80108c24 <vector76>:
.globl vector76
vector76:
  pushl $0
80108c24:	6a 00                	push   $0x0
  pushl $76
80108c26:	6a 4c                	push   $0x4c
  jmp alltraps
80108c28:	e9 0b f7 ff ff       	jmp    80108338 <alltraps>

80108c2d <vector77>:
.globl vector77
vector77:
  pushl $0
80108c2d:	6a 00                	push   $0x0
  pushl $77
80108c2f:	6a 4d                	push   $0x4d
  jmp alltraps
80108c31:	e9 02 f7 ff ff       	jmp    80108338 <alltraps>

80108c36 <vector78>:
.globl vector78
vector78:
  pushl $0
80108c36:	6a 00                	push   $0x0
  pushl $78
80108c38:	6a 4e                	push   $0x4e
  jmp alltraps
80108c3a:	e9 f9 f6 ff ff       	jmp    80108338 <alltraps>

80108c3f <vector79>:
.globl vector79
vector79:
  pushl $0
80108c3f:	6a 00                	push   $0x0
  pushl $79
80108c41:	6a 4f                	push   $0x4f
  jmp alltraps
80108c43:	e9 f0 f6 ff ff       	jmp    80108338 <alltraps>

80108c48 <vector80>:
.globl vector80
vector80:
  pushl $0
80108c48:	6a 00                	push   $0x0
  pushl $80
80108c4a:	6a 50                	push   $0x50
  jmp alltraps
80108c4c:	e9 e7 f6 ff ff       	jmp    80108338 <alltraps>

80108c51 <vector81>:
.globl vector81
vector81:
  pushl $0
80108c51:	6a 00                	push   $0x0
  pushl $81
80108c53:	6a 51                	push   $0x51
  jmp alltraps
80108c55:	e9 de f6 ff ff       	jmp    80108338 <alltraps>

80108c5a <vector82>:
.globl vector82
vector82:
  pushl $0
80108c5a:	6a 00                	push   $0x0
  pushl $82
80108c5c:	6a 52                	push   $0x52
  jmp alltraps
80108c5e:	e9 d5 f6 ff ff       	jmp    80108338 <alltraps>

80108c63 <vector83>:
.globl vector83
vector83:
  pushl $0
80108c63:	6a 00                	push   $0x0
  pushl $83
80108c65:	6a 53                	push   $0x53
  jmp alltraps
80108c67:	e9 cc f6 ff ff       	jmp    80108338 <alltraps>

80108c6c <vector84>:
.globl vector84
vector84:
  pushl $0
80108c6c:	6a 00                	push   $0x0
  pushl $84
80108c6e:	6a 54                	push   $0x54
  jmp alltraps
80108c70:	e9 c3 f6 ff ff       	jmp    80108338 <alltraps>

80108c75 <vector85>:
.globl vector85
vector85:
  pushl $0
80108c75:	6a 00                	push   $0x0
  pushl $85
80108c77:	6a 55                	push   $0x55
  jmp alltraps
80108c79:	e9 ba f6 ff ff       	jmp    80108338 <alltraps>

80108c7e <vector86>:
.globl vector86
vector86:
  pushl $0
80108c7e:	6a 00                	push   $0x0
  pushl $86
80108c80:	6a 56                	push   $0x56
  jmp alltraps
80108c82:	e9 b1 f6 ff ff       	jmp    80108338 <alltraps>

80108c87 <vector87>:
.globl vector87
vector87:
  pushl $0
80108c87:	6a 00                	push   $0x0
  pushl $87
80108c89:	6a 57                	push   $0x57
  jmp alltraps
80108c8b:	e9 a8 f6 ff ff       	jmp    80108338 <alltraps>

80108c90 <vector88>:
.globl vector88
vector88:
  pushl $0
80108c90:	6a 00                	push   $0x0
  pushl $88
80108c92:	6a 58                	push   $0x58
  jmp alltraps
80108c94:	e9 9f f6 ff ff       	jmp    80108338 <alltraps>

80108c99 <vector89>:
.globl vector89
vector89:
  pushl $0
80108c99:	6a 00                	push   $0x0
  pushl $89
80108c9b:	6a 59                	push   $0x59
  jmp alltraps
80108c9d:	e9 96 f6 ff ff       	jmp    80108338 <alltraps>

80108ca2 <vector90>:
.globl vector90
vector90:
  pushl $0
80108ca2:	6a 00                	push   $0x0
  pushl $90
80108ca4:	6a 5a                	push   $0x5a
  jmp alltraps
80108ca6:	e9 8d f6 ff ff       	jmp    80108338 <alltraps>

80108cab <vector91>:
.globl vector91
vector91:
  pushl $0
80108cab:	6a 00                	push   $0x0
  pushl $91
80108cad:	6a 5b                	push   $0x5b
  jmp alltraps
80108caf:	e9 84 f6 ff ff       	jmp    80108338 <alltraps>

80108cb4 <vector92>:
.globl vector92
vector92:
  pushl $0
80108cb4:	6a 00                	push   $0x0
  pushl $92
80108cb6:	6a 5c                	push   $0x5c
  jmp alltraps
80108cb8:	e9 7b f6 ff ff       	jmp    80108338 <alltraps>

80108cbd <vector93>:
.globl vector93
vector93:
  pushl $0
80108cbd:	6a 00                	push   $0x0
  pushl $93
80108cbf:	6a 5d                	push   $0x5d
  jmp alltraps
80108cc1:	e9 72 f6 ff ff       	jmp    80108338 <alltraps>

80108cc6 <vector94>:
.globl vector94
vector94:
  pushl $0
80108cc6:	6a 00                	push   $0x0
  pushl $94
80108cc8:	6a 5e                	push   $0x5e
  jmp alltraps
80108cca:	e9 69 f6 ff ff       	jmp    80108338 <alltraps>

80108ccf <vector95>:
.globl vector95
vector95:
  pushl $0
80108ccf:	6a 00                	push   $0x0
  pushl $95
80108cd1:	6a 5f                	push   $0x5f
  jmp alltraps
80108cd3:	e9 60 f6 ff ff       	jmp    80108338 <alltraps>

80108cd8 <vector96>:
.globl vector96
vector96:
  pushl $0
80108cd8:	6a 00                	push   $0x0
  pushl $96
80108cda:	6a 60                	push   $0x60
  jmp alltraps
80108cdc:	e9 57 f6 ff ff       	jmp    80108338 <alltraps>

80108ce1 <vector97>:
.globl vector97
vector97:
  pushl $0
80108ce1:	6a 00                	push   $0x0
  pushl $97
80108ce3:	6a 61                	push   $0x61
  jmp alltraps
80108ce5:	e9 4e f6 ff ff       	jmp    80108338 <alltraps>

80108cea <vector98>:
.globl vector98
vector98:
  pushl $0
80108cea:	6a 00                	push   $0x0
  pushl $98
80108cec:	6a 62                	push   $0x62
  jmp alltraps
80108cee:	e9 45 f6 ff ff       	jmp    80108338 <alltraps>

80108cf3 <vector99>:
.globl vector99
vector99:
  pushl $0
80108cf3:	6a 00                	push   $0x0
  pushl $99
80108cf5:	6a 63                	push   $0x63
  jmp alltraps
80108cf7:	e9 3c f6 ff ff       	jmp    80108338 <alltraps>

80108cfc <vector100>:
.globl vector100
vector100:
  pushl $0
80108cfc:	6a 00                	push   $0x0
  pushl $100
80108cfe:	6a 64                	push   $0x64
  jmp alltraps
80108d00:	e9 33 f6 ff ff       	jmp    80108338 <alltraps>

80108d05 <vector101>:
.globl vector101
vector101:
  pushl $0
80108d05:	6a 00                	push   $0x0
  pushl $101
80108d07:	6a 65                	push   $0x65
  jmp alltraps
80108d09:	e9 2a f6 ff ff       	jmp    80108338 <alltraps>

80108d0e <vector102>:
.globl vector102
vector102:
  pushl $0
80108d0e:	6a 00                	push   $0x0
  pushl $102
80108d10:	6a 66                	push   $0x66
  jmp alltraps
80108d12:	e9 21 f6 ff ff       	jmp    80108338 <alltraps>

80108d17 <vector103>:
.globl vector103
vector103:
  pushl $0
80108d17:	6a 00                	push   $0x0
  pushl $103
80108d19:	6a 67                	push   $0x67
  jmp alltraps
80108d1b:	e9 18 f6 ff ff       	jmp    80108338 <alltraps>

80108d20 <vector104>:
.globl vector104
vector104:
  pushl $0
80108d20:	6a 00                	push   $0x0
  pushl $104
80108d22:	6a 68                	push   $0x68
  jmp alltraps
80108d24:	e9 0f f6 ff ff       	jmp    80108338 <alltraps>

80108d29 <vector105>:
.globl vector105
vector105:
  pushl $0
80108d29:	6a 00                	push   $0x0
  pushl $105
80108d2b:	6a 69                	push   $0x69
  jmp alltraps
80108d2d:	e9 06 f6 ff ff       	jmp    80108338 <alltraps>

80108d32 <vector106>:
.globl vector106
vector106:
  pushl $0
80108d32:	6a 00                	push   $0x0
  pushl $106
80108d34:	6a 6a                	push   $0x6a
  jmp alltraps
80108d36:	e9 fd f5 ff ff       	jmp    80108338 <alltraps>

80108d3b <vector107>:
.globl vector107
vector107:
  pushl $0
80108d3b:	6a 00                	push   $0x0
  pushl $107
80108d3d:	6a 6b                	push   $0x6b
  jmp alltraps
80108d3f:	e9 f4 f5 ff ff       	jmp    80108338 <alltraps>

80108d44 <vector108>:
.globl vector108
vector108:
  pushl $0
80108d44:	6a 00                	push   $0x0
  pushl $108
80108d46:	6a 6c                	push   $0x6c
  jmp alltraps
80108d48:	e9 eb f5 ff ff       	jmp    80108338 <alltraps>

80108d4d <vector109>:
.globl vector109
vector109:
  pushl $0
80108d4d:	6a 00                	push   $0x0
  pushl $109
80108d4f:	6a 6d                	push   $0x6d
  jmp alltraps
80108d51:	e9 e2 f5 ff ff       	jmp    80108338 <alltraps>

80108d56 <vector110>:
.globl vector110
vector110:
  pushl $0
80108d56:	6a 00                	push   $0x0
  pushl $110
80108d58:	6a 6e                	push   $0x6e
  jmp alltraps
80108d5a:	e9 d9 f5 ff ff       	jmp    80108338 <alltraps>

80108d5f <vector111>:
.globl vector111
vector111:
  pushl $0
80108d5f:	6a 00                	push   $0x0
  pushl $111
80108d61:	6a 6f                	push   $0x6f
  jmp alltraps
80108d63:	e9 d0 f5 ff ff       	jmp    80108338 <alltraps>

80108d68 <vector112>:
.globl vector112
vector112:
  pushl $0
80108d68:	6a 00                	push   $0x0
  pushl $112
80108d6a:	6a 70                	push   $0x70
  jmp alltraps
80108d6c:	e9 c7 f5 ff ff       	jmp    80108338 <alltraps>

80108d71 <vector113>:
.globl vector113
vector113:
  pushl $0
80108d71:	6a 00                	push   $0x0
  pushl $113
80108d73:	6a 71                	push   $0x71
  jmp alltraps
80108d75:	e9 be f5 ff ff       	jmp    80108338 <alltraps>

80108d7a <vector114>:
.globl vector114
vector114:
  pushl $0
80108d7a:	6a 00                	push   $0x0
  pushl $114
80108d7c:	6a 72                	push   $0x72
  jmp alltraps
80108d7e:	e9 b5 f5 ff ff       	jmp    80108338 <alltraps>

80108d83 <vector115>:
.globl vector115
vector115:
  pushl $0
80108d83:	6a 00                	push   $0x0
  pushl $115
80108d85:	6a 73                	push   $0x73
  jmp alltraps
80108d87:	e9 ac f5 ff ff       	jmp    80108338 <alltraps>

80108d8c <vector116>:
.globl vector116
vector116:
  pushl $0
80108d8c:	6a 00                	push   $0x0
  pushl $116
80108d8e:	6a 74                	push   $0x74
  jmp alltraps
80108d90:	e9 a3 f5 ff ff       	jmp    80108338 <alltraps>

80108d95 <vector117>:
.globl vector117
vector117:
  pushl $0
80108d95:	6a 00                	push   $0x0
  pushl $117
80108d97:	6a 75                	push   $0x75
  jmp alltraps
80108d99:	e9 9a f5 ff ff       	jmp    80108338 <alltraps>

80108d9e <vector118>:
.globl vector118
vector118:
  pushl $0
80108d9e:	6a 00                	push   $0x0
  pushl $118
80108da0:	6a 76                	push   $0x76
  jmp alltraps
80108da2:	e9 91 f5 ff ff       	jmp    80108338 <alltraps>

80108da7 <vector119>:
.globl vector119
vector119:
  pushl $0
80108da7:	6a 00                	push   $0x0
  pushl $119
80108da9:	6a 77                	push   $0x77
  jmp alltraps
80108dab:	e9 88 f5 ff ff       	jmp    80108338 <alltraps>

80108db0 <vector120>:
.globl vector120
vector120:
  pushl $0
80108db0:	6a 00                	push   $0x0
  pushl $120
80108db2:	6a 78                	push   $0x78
  jmp alltraps
80108db4:	e9 7f f5 ff ff       	jmp    80108338 <alltraps>

80108db9 <vector121>:
.globl vector121
vector121:
  pushl $0
80108db9:	6a 00                	push   $0x0
  pushl $121
80108dbb:	6a 79                	push   $0x79
  jmp alltraps
80108dbd:	e9 76 f5 ff ff       	jmp    80108338 <alltraps>

80108dc2 <vector122>:
.globl vector122
vector122:
  pushl $0
80108dc2:	6a 00                	push   $0x0
  pushl $122
80108dc4:	6a 7a                	push   $0x7a
  jmp alltraps
80108dc6:	e9 6d f5 ff ff       	jmp    80108338 <alltraps>

80108dcb <vector123>:
.globl vector123
vector123:
  pushl $0
80108dcb:	6a 00                	push   $0x0
  pushl $123
80108dcd:	6a 7b                	push   $0x7b
  jmp alltraps
80108dcf:	e9 64 f5 ff ff       	jmp    80108338 <alltraps>

80108dd4 <vector124>:
.globl vector124
vector124:
  pushl $0
80108dd4:	6a 00                	push   $0x0
  pushl $124
80108dd6:	6a 7c                	push   $0x7c
  jmp alltraps
80108dd8:	e9 5b f5 ff ff       	jmp    80108338 <alltraps>

80108ddd <vector125>:
.globl vector125
vector125:
  pushl $0
80108ddd:	6a 00                	push   $0x0
  pushl $125
80108ddf:	6a 7d                	push   $0x7d
  jmp alltraps
80108de1:	e9 52 f5 ff ff       	jmp    80108338 <alltraps>

80108de6 <vector126>:
.globl vector126
vector126:
  pushl $0
80108de6:	6a 00                	push   $0x0
  pushl $126
80108de8:	6a 7e                	push   $0x7e
  jmp alltraps
80108dea:	e9 49 f5 ff ff       	jmp    80108338 <alltraps>

80108def <vector127>:
.globl vector127
vector127:
  pushl $0
80108def:	6a 00                	push   $0x0
  pushl $127
80108df1:	6a 7f                	push   $0x7f
  jmp alltraps
80108df3:	e9 40 f5 ff ff       	jmp    80108338 <alltraps>

80108df8 <vector128>:
.globl vector128
vector128:
  pushl $0
80108df8:	6a 00                	push   $0x0
  pushl $128
80108dfa:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80108dff:	e9 34 f5 ff ff       	jmp    80108338 <alltraps>

80108e04 <vector129>:
.globl vector129
vector129:
  pushl $0
80108e04:	6a 00                	push   $0x0
  pushl $129
80108e06:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80108e0b:	e9 28 f5 ff ff       	jmp    80108338 <alltraps>

80108e10 <vector130>:
.globl vector130
vector130:
  pushl $0
80108e10:	6a 00                	push   $0x0
  pushl $130
80108e12:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80108e17:	e9 1c f5 ff ff       	jmp    80108338 <alltraps>

80108e1c <vector131>:
.globl vector131
vector131:
  pushl $0
80108e1c:	6a 00                	push   $0x0
  pushl $131
80108e1e:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80108e23:	e9 10 f5 ff ff       	jmp    80108338 <alltraps>

80108e28 <vector132>:
.globl vector132
vector132:
  pushl $0
80108e28:	6a 00                	push   $0x0
  pushl $132
80108e2a:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80108e2f:	e9 04 f5 ff ff       	jmp    80108338 <alltraps>

80108e34 <vector133>:
.globl vector133
vector133:
  pushl $0
80108e34:	6a 00                	push   $0x0
  pushl $133
80108e36:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80108e3b:	e9 f8 f4 ff ff       	jmp    80108338 <alltraps>

80108e40 <vector134>:
.globl vector134
vector134:
  pushl $0
80108e40:	6a 00                	push   $0x0
  pushl $134
80108e42:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80108e47:	e9 ec f4 ff ff       	jmp    80108338 <alltraps>

80108e4c <vector135>:
.globl vector135
vector135:
  pushl $0
80108e4c:	6a 00                	push   $0x0
  pushl $135
80108e4e:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80108e53:	e9 e0 f4 ff ff       	jmp    80108338 <alltraps>

80108e58 <vector136>:
.globl vector136
vector136:
  pushl $0
80108e58:	6a 00                	push   $0x0
  pushl $136
80108e5a:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80108e5f:	e9 d4 f4 ff ff       	jmp    80108338 <alltraps>

80108e64 <vector137>:
.globl vector137
vector137:
  pushl $0
80108e64:	6a 00                	push   $0x0
  pushl $137
80108e66:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80108e6b:	e9 c8 f4 ff ff       	jmp    80108338 <alltraps>

80108e70 <vector138>:
.globl vector138
vector138:
  pushl $0
80108e70:	6a 00                	push   $0x0
  pushl $138
80108e72:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80108e77:	e9 bc f4 ff ff       	jmp    80108338 <alltraps>

80108e7c <vector139>:
.globl vector139
vector139:
  pushl $0
80108e7c:	6a 00                	push   $0x0
  pushl $139
80108e7e:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80108e83:	e9 b0 f4 ff ff       	jmp    80108338 <alltraps>

80108e88 <vector140>:
.globl vector140
vector140:
  pushl $0
80108e88:	6a 00                	push   $0x0
  pushl $140
80108e8a:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80108e8f:	e9 a4 f4 ff ff       	jmp    80108338 <alltraps>

80108e94 <vector141>:
.globl vector141
vector141:
  pushl $0
80108e94:	6a 00                	push   $0x0
  pushl $141
80108e96:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80108e9b:	e9 98 f4 ff ff       	jmp    80108338 <alltraps>

80108ea0 <vector142>:
.globl vector142
vector142:
  pushl $0
80108ea0:	6a 00                	push   $0x0
  pushl $142
80108ea2:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80108ea7:	e9 8c f4 ff ff       	jmp    80108338 <alltraps>

80108eac <vector143>:
.globl vector143
vector143:
  pushl $0
80108eac:	6a 00                	push   $0x0
  pushl $143
80108eae:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80108eb3:	e9 80 f4 ff ff       	jmp    80108338 <alltraps>

80108eb8 <vector144>:
.globl vector144
vector144:
  pushl $0
80108eb8:	6a 00                	push   $0x0
  pushl $144
80108eba:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80108ebf:	e9 74 f4 ff ff       	jmp    80108338 <alltraps>

80108ec4 <vector145>:
.globl vector145
vector145:
  pushl $0
80108ec4:	6a 00                	push   $0x0
  pushl $145
80108ec6:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80108ecb:	e9 68 f4 ff ff       	jmp    80108338 <alltraps>

80108ed0 <vector146>:
.globl vector146
vector146:
  pushl $0
80108ed0:	6a 00                	push   $0x0
  pushl $146
80108ed2:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80108ed7:	e9 5c f4 ff ff       	jmp    80108338 <alltraps>

80108edc <vector147>:
.globl vector147
vector147:
  pushl $0
80108edc:	6a 00                	push   $0x0
  pushl $147
80108ede:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80108ee3:	e9 50 f4 ff ff       	jmp    80108338 <alltraps>

80108ee8 <vector148>:
.globl vector148
vector148:
  pushl $0
80108ee8:	6a 00                	push   $0x0
  pushl $148
80108eea:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80108eef:	e9 44 f4 ff ff       	jmp    80108338 <alltraps>

80108ef4 <vector149>:
.globl vector149
vector149:
  pushl $0
80108ef4:	6a 00                	push   $0x0
  pushl $149
80108ef6:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80108efb:	e9 38 f4 ff ff       	jmp    80108338 <alltraps>

80108f00 <vector150>:
.globl vector150
vector150:
  pushl $0
80108f00:	6a 00                	push   $0x0
  pushl $150
80108f02:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80108f07:	e9 2c f4 ff ff       	jmp    80108338 <alltraps>

80108f0c <vector151>:
.globl vector151
vector151:
  pushl $0
80108f0c:	6a 00                	push   $0x0
  pushl $151
80108f0e:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80108f13:	e9 20 f4 ff ff       	jmp    80108338 <alltraps>

80108f18 <vector152>:
.globl vector152
vector152:
  pushl $0
80108f18:	6a 00                	push   $0x0
  pushl $152
80108f1a:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80108f1f:	e9 14 f4 ff ff       	jmp    80108338 <alltraps>

80108f24 <vector153>:
.globl vector153
vector153:
  pushl $0
80108f24:	6a 00                	push   $0x0
  pushl $153
80108f26:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80108f2b:	e9 08 f4 ff ff       	jmp    80108338 <alltraps>

80108f30 <vector154>:
.globl vector154
vector154:
  pushl $0
80108f30:	6a 00                	push   $0x0
  pushl $154
80108f32:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80108f37:	e9 fc f3 ff ff       	jmp    80108338 <alltraps>

80108f3c <vector155>:
.globl vector155
vector155:
  pushl $0
80108f3c:	6a 00                	push   $0x0
  pushl $155
80108f3e:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80108f43:	e9 f0 f3 ff ff       	jmp    80108338 <alltraps>

80108f48 <vector156>:
.globl vector156
vector156:
  pushl $0
80108f48:	6a 00                	push   $0x0
  pushl $156
80108f4a:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80108f4f:	e9 e4 f3 ff ff       	jmp    80108338 <alltraps>

80108f54 <vector157>:
.globl vector157
vector157:
  pushl $0
80108f54:	6a 00                	push   $0x0
  pushl $157
80108f56:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80108f5b:	e9 d8 f3 ff ff       	jmp    80108338 <alltraps>

80108f60 <vector158>:
.globl vector158
vector158:
  pushl $0
80108f60:	6a 00                	push   $0x0
  pushl $158
80108f62:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80108f67:	e9 cc f3 ff ff       	jmp    80108338 <alltraps>

80108f6c <vector159>:
.globl vector159
vector159:
  pushl $0
80108f6c:	6a 00                	push   $0x0
  pushl $159
80108f6e:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80108f73:	e9 c0 f3 ff ff       	jmp    80108338 <alltraps>

80108f78 <vector160>:
.globl vector160
vector160:
  pushl $0
80108f78:	6a 00                	push   $0x0
  pushl $160
80108f7a:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80108f7f:	e9 b4 f3 ff ff       	jmp    80108338 <alltraps>

80108f84 <vector161>:
.globl vector161
vector161:
  pushl $0
80108f84:	6a 00                	push   $0x0
  pushl $161
80108f86:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80108f8b:	e9 a8 f3 ff ff       	jmp    80108338 <alltraps>

80108f90 <vector162>:
.globl vector162
vector162:
  pushl $0
80108f90:	6a 00                	push   $0x0
  pushl $162
80108f92:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80108f97:	e9 9c f3 ff ff       	jmp    80108338 <alltraps>

80108f9c <vector163>:
.globl vector163
vector163:
  pushl $0
80108f9c:	6a 00                	push   $0x0
  pushl $163
80108f9e:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80108fa3:	e9 90 f3 ff ff       	jmp    80108338 <alltraps>

80108fa8 <vector164>:
.globl vector164
vector164:
  pushl $0
80108fa8:	6a 00                	push   $0x0
  pushl $164
80108faa:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80108faf:	e9 84 f3 ff ff       	jmp    80108338 <alltraps>

80108fb4 <vector165>:
.globl vector165
vector165:
  pushl $0
80108fb4:	6a 00                	push   $0x0
  pushl $165
80108fb6:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80108fbb:	e9 78 f3 ff ff       	jmp    80108338 <alltraps>

80108fc0 <vector166>:
.globl vector166
vector166:
  pushl $0
80108fc0:	6a 00                	push   $0x0
  pushl $166
80108fc2:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80108fc7:	e9 6c f3 ff ff       	jmp    80108338 <alltraps>

80108fcc <vector167>:
.globl vector167
vector167:
  pushl $0
80108fcc:	6a 00                	push   $0x0
  pushl $167
80108fce:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80108fd3:	e9 60 f3 ff ff       	jmp    80108338 <alltraps>

80108fd8 <vector168>:
.globl vector168
vector168:
  pushl $0
80108fd8:	6a 00                	push   $0x0
  pushl $168
80108fda:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80108fdf:	e9 54 f3 ff ff       	jmp    80108338 <alltraps>

80108fe4 <vector169>:
.globl vector169
vector169:
  pushl $0
80108fe4:	6a 00                	push   $0x0
  pushl $169
80108fe6:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80108feb:	e9 48 f3 ff ff       	jmp    80108338 <alltraps>

80108ff0 <vector170>:
.globl vector170
vector170:
  pushl $0
80108ff0:	6a 00                	push   $0x0
  pushl $170
80108ff2:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80108ff7:	e9 3c f3 ff ff       	jmp    80108338 <alltraps>

80108ffc <vector171>:
.globl vector171
vector171:
  pushl $0
80108ffc:	6a 00                	push   $0x0
  pushl $171
80108ffe:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80109003:	e9 30 f3 ff ff       	jmp    80108338 <alltraps>

80109008 <vector172>:
.globl vector172
vector172:
  pushl $0
80109008:	6a 00                	push   $0x0
  pushl $172
8010900a:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010900f:	e9 24 f3 ff ff       	jmp    80108338 <alltraps>

80109014 <vector173>:
.globl vector173
vector173:
  pushl $0
80109014:	6a 00                	push   $0x0
  pushl $173
80109016:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010901b:	e9 18 f3 ff ff       	jmp    80108338 <alltraps>

80109020 <vector174>:
.globl vector174
vector174:
  pushl $0
80109020:	6a 00                	push   $0x0
  pushl $174
80109022:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80109027:	e9 0c f3 ff ff       	jmp    80108338 <alltraps>

8010902c <vector175>:
.globl vector175
vector175:
  pushl $0
8010902c:	6a 00                	push   $0x0
  pushl $175
8010902e:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80109033:	e9 00 f3 ff ff       	jmp    80108338 <alltraps>

80109038 <vector176>:
.globl vector176
vector176:
  pushl $0
80109038:	6a 00                	push   $0x0
  pushl $176
8010903a:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010903f:	e9 f4 f2 ff ff       	jmp    80108338 <alltraps>

80109044 <vector177>:
.globl vector177
vector177:
  pushl $0
80109044:	6a 00                	push   $0x0
  pushl $177
80109046:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010904b:	e9 e8 f2 ff ff       	jmp    80108338 <alltraps>

80109050 <vector178>:
.globl vector178
vector178:
  pushl $0
80109050:	6a 00                	push   $0x0
  pushl $178
80109052:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80109057:	e9 dc f2 ff ff       	jmp    80108338 <alltraps>

8010905c <vector179>:
.globl vector179
vector179:
  pushl $0
8010905c:	6a 00                	push   $0x0
  pushl $179
8010905e:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80109063:	e9 d0 f2 ff ff       	jmp    80108338 <alltraps>

80109068 <vector180>:
.globl vector180
vector180:
  pushl $0
80109068:	6a 00                	push   $0x0
  pushl $180
8010906a:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
8010906f:	e9 c4 f2 ff ff       	jmp    80108338 <alltraps>

80109074 <vector181>:
.globl vector181
vector181:
  pushl $0
80109074:	6a 00                	push   $0x0
  pushl $181
80109076:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010907b:	e9 b8 f2 ff ff       	jmp    80108338 <alltraps>

80109080 <vector182>:
.globl vector182
vector182:
  pushl $0
80109080:	6a 00                	push   $0x0
  pushl $182
80109082:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80109087:	e9 ac f2 ff ff       	jmp    80108338 <alltraps>

8010908c <vector183>:
.globl vector183
vector183:
  pushl $0
8010908c:	6a 00                	push   $0x0
  pushl $183
8010908e:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80109093:	e9 a0 f2 ff ff       	jmp    80108338 <alltraps>

80109098 <vector184>:
.globl vector184
vector184:
  pushl $0
80109098:	6a 00                	push   $0x0
  pushl $184
8010909a:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010909f:	e9 94 f2 ff ff       	jmp    80108338 <alltraps>

801090a4 <vector185>:
.globl vector185
vector185:
  pushl $0
801090a4:	6a 00                	push   $0x0
  pushl $185
801090a6:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801090ab:	e9 88 f2 ff ff       	jmp    80108338 <alltraps>

801090b0 <vector186>:
.globl vector186
vector186:
  pushl $0
801090b0:	6a 00                	push   $0x0
  pushl $186
801090b2:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801090b7:	e9 7c f2 ff ff       	jmp    80108338 <alltraps>

801090bc <vector187>:
.globl vector187
vector187:
  pushl $0
801090bc:	6a 00                	push   $0x0
  pushl $187
801090be:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801090c3:	e9 70 f2 ff ff       	jmp    80108338 <alltraps>

801090c8 <vector188>:
.globl vector188
vector188:
  pushl $0
801090c8:	6a 00                	push   $0x0
  pushl $188
801090ca:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801090cf:	e9 64 f2 ff ff       	jmp    80108338 <alltraps>

801090d4 <vector189>:
.globl vector189
vector189:
  pushl $0
801090d4:	6a 00                	push   $0x0
  pushl $189
801090d6:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801090db:	e9 58 f2 ff ff       	jmp    80108338 <alltraps>

801090e0 <vector190>:
.globl vector190
vector190:
  pushl $0
801090e0:	6a 00                	push   $0x0
  pushl $190
801090e2:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801090e7:	e9 4c f2 ff ff       	jmp    80108338 <alltraps>

801090ec <vector191>:
.globl vector191
vector191:
  pushl $0
801090ec:	6a 00                	push   $0x0
  pushl $191
801090ee:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801090f3:	e9 40 f2 ff ff       	jmp    80108338 <alltraps>

801090f8 <vector192>:
.globl vector192
vector192:
  pushl $0
801090f8:	6a 00                	push   $0x0
  pushl $192
801090fa:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801090ff:	e9 34 f2 ff ff       	jmp    80108338 <alltraps>

80109104 <vector193>:
.globl vector193
vector193:
  pushl $0
80109104:	6a 00                	push   $0x0
  pushl $193
80109106:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010910b:	e9 28 f2 ff ff       	jmp    80108338 <alltraps>

80109110 <vector194>:
.globl vector194
vector194:
  pushl $0
80109110:	6a 00                	push   $0x0
  pushl $194
80109112:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80109117:	e9 1c f2 ff ff       	jmp    80108338 <alltraps>

8010911c <vector195>:
.globl vector195
vector195:
  pushl $0
8010911c:	6a 00                	push   $0x0
  pushl $195
8010911e:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80109123:	e9 10 f2 ff ff       	jmp    80108338 <alltraps>

80109128 <vector196>:
.globl vector196
vector196:
  pushl $0
80109128:	6a 00                	push   $0x0
  pushl $196
8010912a:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010912f:	e9 04 f2 ff ff       	jmp    80108338 <alltraps>

80109134 <vector197>:
.globl vector197
vector197:
  pushl $0
80109134:	6a 00                	push   $0x0
  pushl $197
80109136:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010913b:	e9 f8 f1 ff ff       	jmp    80108338 <alltraps>

80109140 <vector198>:
.globl vector198
vector198:
  pushl $0
80109140:	6a 00                	push   $0x0
  pushl $198
80109142:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80109147:	e9 ec f1 ff ff       	jmp    80108338 <alltraps>

8010914c <vector199>:
.globl vector199
vector199:
  pushl $0
8010914c:	6a 00                	push   $0x0
  pushl $199
8010914e:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80109153:	e9 e0 f1 ff ff       	jmp    80108338 <alltraps>

80109158 <vector200>:
.globl vector200
vector200:
  pushl $0
80109158:	6a 00                	push   $0x0
  pushl $200
8010915a:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010915f:	e9 d4 f1 ff ff       	jmp    80108338 <alltraps>

80109164 <vector201>:
.globl vector201
vector201:
  pushl $0
80109164:	6a 00                	push   $0x0
  pushl $201
80109166:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010916b:	e9 c8 f1 ff ff       	jmp    80108338 <alltraps>

80109170 <vector202>:
.globl vector202
vector202:
  pushl $0
80109170:	6a 00                	push   $0x0
  pushl $202
80109172:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80109177:	e9 bc f1 ff ff       	jmp    80108338 <alltraps>

8010917c <vector203>:
.globl vector203
vector203:
  pushl $0
8010917c:	6a 00                	push   $0x0
  pushl $203
8010917e:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80109183:	e9 b0 f1 ff ff       	jmp    80108338 <alltraps>

80109188 <vector204>:
.globl vector204
vector204:
  pushl $0
80109188:	6a 00                	push   $0x0
  pushl $204
8010918a:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010918f:	e9 a4 f1 ff ff       	jmp    80108338 <alltraps>

80109194 <vector205>:
.globl vector205
vector205:
  pushl $0
80109194:	6a 00                	push   $0x0
  pushl $205
80109196:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010919b:	e9 98 f1 ff ff       	jmp    80108338 <alltraps>

801091a0 <vector206>:
.globl vector206
vector206:
  pushl $0
801091a0:	6a 00                	push   $0x0
  pushl $206
801091a2:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801091a7:	e9 8c f1 ff ff       	jmp    80108338 <alltraps>

801091ac <vector207>:
.globl vector207
vector207:
  pushl $0
801091ac:	6a 00                	push   $0x0
  pushl $207
801091ae:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801091b3:	e9 80 f1 ff ff       	jmp    80108338 <alltraps>

801091b8 <vector208>:
.globl vector208
vector208:
  pushl $0
801091b8:	6a 00                	push   $0x0
  pushl $208
801091ba:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801091bf:	e9 74 f1 ff ff       	jmp    80108338 <alltraps>

801091c4 <vector209>:
.globl vector209
vector209:
  pushl $0
801091c4:	6a 00                	push   $0x0
  pushl $209
801091c6:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801091cb:	e9 68 f1 ff ff       	jmp    80108338 <alltraps>

801091d0 <vector210>:
.globl vector210
vector210:
  pushl $0
801091d0:	6a 00                	push   $0x0
  pushl $210
801091d2:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801091d7:	e9 5c f1 ff ff       	jmp    80108338 <alltraps>

801091dc <vector211>:
.globl vector211
vector211:
  pushl $0
801091dc:	6a 00                	push   $0x0
  pushl $211
801091de:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801091e3:	e9 50 f1 ff ff       	jmp    80108338 <alltraps>

801091e8 <vector212>:
.globl vector212
vector212:
  pushl $0
801091e8:	6a 00                	push   $0x0
  pushl $212
801091ea:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801091ef:	e9 44 f1 ff ff       	jmp    80108338 <alltraps>

801091f4 <vector213>:
.globl vector213
vector213:
  pushl $0
801091f4:	6a 00                	push   $0x0
  pushl $213
801091f6:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801091fb:	e9 38 f1 ff ff       	jmp    80108338 <alltraps>

80109200 <vector214>:
.globl vector214
vector214:
  pushl $0
80109200:	6a 00                	push   $0x0
  pushl $214
80109202:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80109207:	e9 2c f1 ff ff       	jmp    80108338 <alltraps>

8010920c <vector215>:
.globl vector215
vector215:
  pushl $0
8010920c:	6a 00                	push   $0x0
  pushl $215
8010920e:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80109213:	e9 20 f1 ff ff       	jmp    80108338 <alltraps>

80109218 <vector216>:
.globl vector216
vector216:
  pushl $0
80109218:	6a 00                	push   $0x0
  pushl $216
8010921a:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010921f:	e9 14 f1 ff ff       	jmp    80108338 <alltraps>

80109224 <vector217>:
.globl vector217
vector217:
  pushl $0
80109224:	6a 00                	push   $0x0
  pushl $217
80109226:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010922b:	e9 08 f1 ff ff       	jmp    80108338 <alltraps>

80109230 <vector218>:
.globl vector218
vector218:
  pushl $0
80109230:	6a 00                	push   $0x0
  pushl $218
80109232:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80109237:	e9 fc f0 ff ff       	jmp    80108338 <alltraps>

8010923c <vector219>:
.globl vector219
vector219:
  pushl $0
8010923c:	6a 00                	push   $0x0
  pushl $219
8010923e:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80109243:	e9 f0 f0 ff ff       	jmp    80108338 <alltraps>

80109248 <vector220>:
.globl vector220
vector220:
  pushl $0
80109248:	6a 00                	push   $0x0
  pushl $220
8010924a:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010924f:	e9 e4 f0 ff ff       	jmp    80108338 <alltraps>

80109254 <vector221>:
.globl vector221
vector221:
  pushl $0
80109254:	6a 00                	push   $0x0
  pushl $221
80109256:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010925b:	e9 d8 f0 ff ff       	jmp    80108338 <alltraps>

80109260 <vector222>:
.globl vector222
vector222:
  pushl $0
80109260:	6a 00                	push   $0x0
  pushl $222
80109262:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80109267:	e9 cc f0 ff ff       	jmp    80108338 <alltraps>

8010926c <vector223>:
.globl vector223
vector223:
  pushl $0
8010926c:	6a 00                	push   $0x0
  pushl $223
8010926e:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80109273:	e9 c0 f0 ff ff       	jmp    80108338 <alltraps>

80109278 <vector224>:
.globl vector224
vector224:
  pushl $0
80109278:	6a 00                	push   $0x0
  pushl $224
8010927a:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
8010927f:	e9 b4 f0 ff ff       	jmp    80108338 <alltraps>

80109284 <vector225>:
.globl vector225
vector225:
  pushl $0
80109284:	6a 00                	push   $0x0
  pushl $225
80109286:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010928b:	e9 a8 f0 ff ff       	jmp    80108338 <alltraps>

80109290 <vector226>:
.globl vector226
vector226:
  pushl $0
80109290:	6a 00                	push   $0x0
  pushl $226
80109292:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80109297:	e9 9c f0 ff ff       	jmp    80108338 <alltraps>

8010929c <vector227>:
.globl vector227
vector227:
  pushl $0
8010929c:	6a 00                	push   $0x0
  pushl $227
8010929e:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801092a3:	e9 90 f0 ff ff       	jmp    80108338 <alltraps>

801092a8 <vector228>:
.globl vector228
vector228:
  pushl $0
801092a8:	6a 00                	push   $0x0
  pushl $228
801092aa:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801092af:	e9 84 f0 ff ff       	jmp    80108338 <alltraps>

801092b4 <vector229>:
.globl vector229
vector229:
  pushl $0
801092b4:	6a 00                	push   $0x0
  pushl $229
801092b6:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801092bb:	e9 78 f0 ff ff       	jmp    80108338 <alltraps>

801092c0 <vector230>:
.globl vector230
vector230:
  pushl $0
801092c0:	6a 00                	push   $0x0
  pushl $230
801092c2:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801092c7:	e9 6c f0 ff ff       	jmp    80108338 <alltraps>

801092cc <vector231>:
.globl vector231
vector231:
  pushl $0
801092cc:	6a 00                	push   $0x0
  pushl $231
801092ce:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801092d3:	e9 60 f0 ff ff       	jmp    80108338 <alltraps>

801092d8 <vector232>:
.globl vector232
vector232:
  pushl $0
801092d8:	6a 00                	push   $0x0
  pushl $232
801092da:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801092df:	e9 54 f0 ff ff       	jmp    80108338 <alltraps>

801092e4 <vector233>:
.globl vector233
vector233:
  pushl $0
801092e4:	6a 00                	push   $0x0
  pushl $233
801092e6:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801092eb:	e9 48 f0 ff ff       	jmp    80108338 <alltraps>

801092f0 <vector234>:
.globl vector234
vector234:
  pushl $0
801092f0:	6a 00                	push   $0x0
  pushl $234
801092f2:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801092f7:	e9 3c f0 ff ff       	jmp    80108338 <alltraps>

801092fc <vector235>:
.globl vector235
vector235:
  pushl $0
801092fc:	6a 00                	push   $0x0
  pushl $235
801092fe:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80109303:	e9 30 f0 ff ff       	jmp    80108338 <alltraps>

80109308 <vector236>:
.globl vector236
vector236:
  pushl $0
80109308:	6a 00                	push   $0x0
  pushl $236
8010930a:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010930f:	e9 24 f0 ff ff       	jmp    80108338 <alltraps>

80109314 <vector237>:
.globl vector237
vector237:
  pushl $0
80109314:	6a 00                	push   $0x0
  pushl $237
80109316:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010931b:	e9 18 f0 ff ff       	jmp    80108338 <alltraps>

80109320 <vector238>:
.globl vector238
vector238:
  pushl $0
80109320:	6a 00                	push   $0x0
  pushl $238
80109322:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80109327:	e9 0c f0 ff ff       	jmp    80108338 <alltraps>

8010932c <vector239>:
.globl vector239
vector239:
  pushl $0
8010932c:	6a 00                	push   $0x0
  pushl $239
8010932e:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80109333:	e9 00 f0 ff ff       	jmp    80108338 <alltraps>

80109338 <vector240>:
.globl vector240
vector240:
  pushl $0
80109338:	6a 00                	push   $0x0
  pushl $240
8010933a:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010933f:	e9 f4 ef ff ff       	jmp    80108338 <alltraps>

80109344 <vector241>:
.globl vector241
vector241:
  pushl $0
80109344:	6a 00                	push   $0x0
  pushl $241
80109346:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010934b:	e9 e8 ef ff ff       	jmp    80108338 <alltraps>

80109350 <vector242>:
.globl vector242
vector242:
  pushl $0
80109350:	6a 00                	push   $0x0
  pushl $242
80109352:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80109357:	e9 dc ef ff ff       	jmp    80108338 <alltraps>

8010935c <vector243>:
.globl vector243
vector243:
  pushl $0
8010935c:	6a 00                	push   $0x0
  pushl $243
8010935e:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80109363:	e9 d0 ef ff ff       	jmp    80108338 <alltraps>

80109368 <vector244>:
.globl vector244
vector244:
  pushl $0
80109368:	6a 00                	push   $0x0
  pushl $244
8010936a:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010936f:	e9 c4 ef ff ff       	jmp    80108338 <alltraps>

80109374 <vector245>:
.globl vector245
vector245:
  pushl $0
80109374:	6a 00                	push   $0x0
  pushl $245
80109376:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010937b:	e9 b8 ef ff ff       	jmp    80108338 <alltraps>

80109380 <vector246>:
.globl vector246
vector246:
  pushl $0
80109380:	6a 00                	push   $0x0
  pushl $246
80109382:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80109387:	e9 ac ef ff ff       	jmp    80108338 <alltraps>

8010938c <vector247>:
.globl vector247
vector247:
  pushl $0
8010938c:	6a 00                	push   $0x0
  pushl $247
8010938e:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80109393:	e9 a0 ef ff ff       	jmp    80108338 <alltraps>

80109398 <vector248>:
.globl vector248
vector248:
  pushl $0
80109398:	6a 00                	push   $0x0
  pushl $248
8010939a:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010939f:	e9 94 ef ff ff       	jmp    80108338 <alltraps>

801093a4 <vector249>:
.globl vector249
vector249:
  pushl $0
801093a4:	6a 00                	push   $0x0
  pushl $249
801093a6:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801093ab:	e9 88 ef ff ff       	jmp    80108338 <alltraps>

801093b0 <vector250>:
.globl vector250
vector250:
  pushl $0
801093b0:	6a 00                	push   $0x0
  pushl $250
801093b2:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801093b7:	e9 7c ef ff ff       	jmp    80108338 <alltraps>

801093bc <vector251>:
.globl vector251
vector251:
  pushl $0
801093bc:	6a 00                	push   $0x0
  pushl $251
801093be:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801093c3:	e9 70 ef ff ff       	jmp    80108338 <alltraps>

801093c8 <vector252>:
.globl vector252
vector252:
  pushl $0
801093c8:	6a 00                	push   $0x0
  pushl $252
801093ca:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801093cf:	e9 64 ef ff ff       	jmp    80108338 <alltraps>

801093d4 <vector253>:
.globl vector253
vector253:
  pushl $0
801093d4:	6a 00                	push   $0x0
  pushl $253
801093d6:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801093db:	e9 58 ef ff ff       	jmp    80108338 <alltraps>

801093e0 <vector254>:
.globl vector254
vector254:
  pushl $0
801093e0:	6a 00                	push   $0x0
  pushl $254
801093e2:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801093e7:	e9 4c ef ff ff       	jmp    80108338 <alltraps>

801093ec <vector255>:
.globl vector255
vector255:
  pushl $0
801093ec:	6a 00                	push   $0x0
  pushl $255
801093ee:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801093f3:	e9 40 ef ff ff       	jmp    80108338 <alltraps>

801093f8 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801093f8:	55                   	push   %ebp
801093f9:	89 e5                	mov    %esp,%ebp
801093fb:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801093fe:	8b 45 0c             	mov    0xc(%ebp),%eax
80109401:	83 e8 01             	sub    $0x1,%eax
80109404:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80109408:	8b 45 08             	mov    0x8(%ebp),%eax
8010940b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010940f:	8b 45 08             	mov    0x8(%ebp),%eax
80109412:	c1 e8 10             	shr    $0x10,%eax
80109415:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80109419:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010941c:	0f 01 10             	lgdtl  (%eax)
}
8010941f:	90                   	nop
80109420:	c9                   	leave  
80109421:	c3                   	ret    

80109422 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80109422:	55                   	push   %ebp
80109423:	89 e5                	mov    %esp,%ebp
80109425:	83 ec 04             	sub    $0x4,%esp
80109428:	8b 45 08             	mov    0x8(%ebp),%eax
8010942b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
8010942f:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109433:	0f 00 d8             	ltr    %ax
}
80109436:	90                   	nop
80109437:	c9                   	leave  
80109438:	c3                   	ret    

80109439 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80109439:	55                   	push   %ebp
8010943a:	89 e5                	mov    %esp,%ebp
8010943c:	83 ec 04             	sub    $0x4,%esp
8010943f:	8b 45 08             	mov    0x8(%ebp),%eax
80109442:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80109446:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010944a:	8e e8                	mov    %eax,%gs
}
8010944c:	90                   	nop
8010944d:	c9                   	leave  
8010944e:	c3                   	ret    

8010944f <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
8010944f:	55                   	push   %ebp
80109450:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80109452:	8b 45 08             	mov    0x8(%ebp),%eax
80109455:	0f 22 d8             	mov    %eax,%cr3
}
80109458:	90                   	nop
80109459:	5d                   	pop    %ebp
8010945a:	c3                   	ret    

8010945b <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
8010945b:	55                   	push   %ebp
8010945c:	89 e5                	mov    %esp,%ebp
8010945e:	8b 45 08             	mov    0x8(%ebp),%eax
80109461:	05 00 00 00 80       	add    $0x80000000,%eax
80109466:	5d                   	pop    %ebp
80109467:	c3                   	ret    

80109468 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80109468:	55                   	push   %ebp
80109469:	89 e5                	mov    %esp,%ebp
8010946b:	8b 45 08             	mov    0x8(%ebp),%eax
8010946e:	05 00 00 00 80       	add    $0x80000000,%eax
80109473:	5d                   	pop    %ebp
80109474:	c3                   	ret    

80109475 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80109475:	55                   	push   %ebp
80109476:	89 e5                	mov    %esp,%ebp
80109478:	53                   	push   %ebx
80109479:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
8010947c:	e8 ea 9e ff ff       	call   8010336b <cpunum>
80109481:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80109487:	05 a0 43 11 80       	add    $0x801143a0,%eax
8010948c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010948f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109492:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80109498:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010949b:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801094a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094a4:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801094a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094ab:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801094af:	83 e2 f0             	and    $0xfffffff0,%edx
801094b2:	83 ca 0a             	or     $0xa,%edx
801094b5:	88 50 7d             	mov    %dl,0x7d(%eax)
801094b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094bb:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801094bf:	83 ca 10             	or     $0x10,%edx
801094c2:	88 50 7d             	mov    %dl,0x7d(%eax)
801094c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094c8:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801094cc:	83 e2 9f             	and    $0xffffff9f,%edx
801094cf:	88 50 7d             	mov    %dl,0x7d(%eax)
801094d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094d5:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801094d9:	83 ca 80             	or     $0xffffff80,%edx
801094dc:	88 50 7d             	mov    %dl,0x7d(%eax)
801094df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094e2:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801094e6:	83 ca 0f             	or     $0xf,%edx
801094e9:	88 50 7e             	mov    %dl,0x7e(%eax)
801094ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094ef:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801094f3:	83 e2 ef             	and    $0xffffffef,%edx
801094f6:	88 50 7e             	mov    %dl,0x7e(%eax)
801094f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094fc:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80109500:	83 e2 df             	and    $0xffffffdf,%edx
80109503:	88 50 7e             	mov    %dl,0x7e(%eax)
80109506:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109509:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010950d:	83 ca 40             	or     $0x40,%edx
80109510:	88 50 7e             	mov    %dl,0x7e(%eax)
80109513:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109516:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010951a:	83 ca 80             	or     $0xffffff80,%edx
8010951d:	88 50 7e             	mov    %dl,0x7e(%eax)
80109520:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109523:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80109527:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010952a:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80109531:	ff ff 
80109533:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109536:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010953d:	00 00 
8010953f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109542:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80109549:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010954c:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80109553:	83 e2 f0             	and    $0xfffffff0,%edx
80109556:	83 ca 02             	or     $0x2,%edx
80109559:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010955f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109562:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80109569:	83 ca 10             	or     $0x10,%edx
8010956c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80109572:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109575:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010957c:	83 e2 9f             	and    $0xffffff9f,%edx
8010957f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80109585:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109588:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010958f:	83 ca 80             	or     $0xffffff80,%edx
80109592:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80109598:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010959b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801095a2:	83 ca 0f             	or     $0xf,%edx
801095a5:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801095ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095ae:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801095b5:	83 e2 ef             	and    $0xffffffef,%edx
801095b8:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801095be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095c1:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801095c8:	83 e2 df             	and    $0xffffffdf,%edx
801095cb:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801095d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095d4:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801095db:	83 ca 40             	or     $0x40,%edx
801095de:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801095e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095e7:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801095ee:	83 ca 80             	or     $0xffffff80,%edx
801095f1:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801095f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095fa:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80109601:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109604:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
8010960b:	ff ff 
8010960d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109610:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80109617:	00 00 
80109619:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010961c:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80109623:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109626:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010962d:	83 e2 f0             	and    $0xfffffff0,%edx
80109630:	83 ca 0a             	or     $0xa,%edx
80109633:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80109639:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010963c:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80109643:	83 ca 10             	or     $0x10,%edx
80109646:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010964c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010964f:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80109656:	83 ca 60             	or     $0x60,%edx
80109659:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010965f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109662:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80109669:	83 ca 80             	or     $0xffffff80,%edx
8010966c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80109672:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109675:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010967c:	83 ca 0f             	or     $0xf,%edx
8010967f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80109685:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109688:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010968f:	83 e2 ef             	and    $0xffffffef,%edx
80109692:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80109698:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010969b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801096a2:	83 e2 df             	and    $0xffffffdf,%edx
801096a5:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801096ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096ae:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801096b5:	83 ca 40             	or     $0x40,%edx
801096b8:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801096be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096c1:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801096c8:	83 ca 80             	or     $0xffffff80,%edx
801096cb:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801096d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096d4:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801096db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096de:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
801096e5:	ff ff 
801096e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096ea:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
801096f1:	00 00 
801096f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096f6:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
801096fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109700:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80109707:	83 e2 f0             	and    $0xfffffff0,%edx
8010970a:	83 ca 02             	or     $0x2,%edx
8010970d:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80109713:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109716:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010971d:	83 ca 10             	or     $0x10,%edx
80109720:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80109726:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109729:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80109730:	83 ca 60             	or     $0x60,%edx
80109733:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80109739:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010973c:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80109743:	83 ca 80             	or     $0xffffff80,%edx
80109746:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010974c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010974f:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80109756:	83 ca 0f             	or     $0xf,%edx
80109759:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010975f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109762:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80109769:	83 e2 ef             	and    $0xffffffef,%edx
8010976c:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80109772:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109775:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010977c:	83 e2 df             	and    $0xffffffdf,%edx
8010977f:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80109785:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109788:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010978f:	83 ca 40             	or     $0x40,%edx
80109792:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80109798:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010979b:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801097a2:	83 ca 80             	or     $0xffffff80,%edx
801097a5:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801097ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097ae:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
801097b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097b8:	05 b4 00 00 00       	add    $0xb4,%eax
801097bd:	89 c3                	mov    %eax,%ebx
801097bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097c2:	05 b4 00 00 00       	add    $0xb4,%eax
801097c7:	c1 e8 10             	shr    $0x10,%eax
801097ca:	89 c2                	mov    %eax,%edx
801097cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097cf:	05 b4 00 00 00       	add    $0xb4,%eax
801097d4:	c1 e8 18             	shr    $0x18,%eax
801097d7:	89 c1                	mov    %eax,%ecx
801097d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097dc:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
801097e3:	00 00 
801097e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097e8:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
801097ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097f2:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
801097f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097fb:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80109802:	83 e2 f0             	and    $0xfffffff0,%edx
80109805:	83 ca 02             	or     $0x2,%edx
80109808:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010980e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109811:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80109818:	83 ca 10             	or     $0x10,%edx
8010981b:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80109821:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109824:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010982b:	83 e2 9f             	and    $0xffffff9f,%edx
8010982e:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80109834:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109837:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010983e:	83 ca 80             	or     $0xffffff80,%edx
80109841:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80109847:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010984a:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80109851:	83 e2 f0             	and    $0xfffffff0,%edx
80109854:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010985a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010985d:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80109864:	83 e2 ef             	and    $0xffffffef,%edx
80109867:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010986d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109870:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80109877:	83 e2 df             	and    $0xffffffdf,%edx
8010987a:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80109880:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109883:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010988a:	83 ca 40             	or     $0x40,%edx
8010988d:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80109893:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109896:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010989d:	83 ca 80             	or     $0xffffff80,%edx
801098a0:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801098a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098a9:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
801098af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098b2:	83 c0 70             	add    $0x70,%eax
801098b5:	83 ec 08             	sub    $0x8,%esp
801098b8:	6a 38                	push   $0x38
801098ba:	50                   	push   %eax
801098bb:	e8 38 fb ff ff       	call   801093f8 <lgdt>
801098c0:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
801098c3:	83 ec 0c             	sub    $0xc,%esp
801098c6:	6a 18                	push   $0x18
801098c8:	e8 6c fb ff ff       	call   80109439 <loadgs>
801098cd:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
801098d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098d3:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
801098d9:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
801098e0:	00 00 00 00 
}
801098e4:	90                   	nop
801098e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801098e8:	c9                   	leave  
801098e9:	c3                   	ret    

801098ea <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801098ea:	55                   	push   %ebp
801098eb:	89 e5                	mov    %esp,%ebp
801098ed:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801098f0:	8b 45 0c             	mov    0xc(%ebp),%eax
801098f3:	c1 e8 16             	shr    $0x16,%eax
801098f6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801098fd:	8b 45 08             	mov    0x8(%ebp),%eax
80109900:	01 d0                	add    %edx,%eax
80109902:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80109905:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109908:	8b 00                	mov    (%eax),%eax
8010990a:	83 e0 01             	and    $0x1,%eax
8010990d:	85 c0                	test   %eax,%eax
8010990f:	74 18                	je     80109929 <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80109911:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109914:	8b 00                	mov    (%eax),%eax
80109916:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010991b:	50                   	push   %eax
8010991c:	e8 47 fb ff ff       	call   80109468 <p2v>
80109921:	83 c4 04             	add    $0x4,%esp
80109924:	89 45 f4             	mov    %eax,-0xc(%ebp)
80109927:	eb 48                	jmp    80109971 <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80109929:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010992d:	74 0e                	je     8010993d <walkpgdir+0x53>
8010992f:	e8 d1 96 ff ff       	call   80103005 <kalloc>
80109934:	89 45 f4             	mov    %eax,-0xc(%ebp)
80109937:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010993b:	75 07                	jne    80109944 <walkpgdir+0x5a>
      return 0;
8010993d:	b8 00 00 00 00       	mov    $0x0,%eax
80109942:	eb 44                	jmp    80109988 <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80109944:	83 ec 04             	sub    $0x4,%esp
80109947:	68 00 10 00 00       	push   $0x1000
8010994c:	6a 00                	push   $0x0
8010994e:	ff 75 f4             	pushl  -0xc(%ebp)
80109951:	e8 14 d3 ff ff       	call   80106c6a <memset>
80109956:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80109959:	83 ec 0c             	sub    $0xc,%esp
8010995c:	ff 75 f4             	pushl  -0xc(%ebp)
8010995f:	e8 f7 fa ff ff       	call   8010945b <v2p>
80109964:	83 c4 10             	add    $0x10,%esp
80109967:	83 c8 07             	or     $0x7,%eax
8010996a:	89 c2                	mov    %eax,%edx
8010996c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010996f:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80109971:	8b 45 0c             	mov    0xc(%ebp),%eax
80109974:	c1 e8 0c             	shr    $0xc,%eax
80109977:	25 ff 03 00 00       	and    $0x3ff,%eax
8010997c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109983:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109986:	01 d0                	add    %edx,%eax
}
80109988:	c9                   	leave  
80109989:	c3                   	ret    

8010998a <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
8010998a:	55                   	push   %ebp
8010998b:	89 e5                	mov    %esp,%ebp
8010998d:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80109990:	8b 45 0c             	mov    0xc(%ebp),%eax
80109993:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109998:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010999b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010999e:	8b 45 10             	mov    0x10(%ebp),%eax
801099a1:	01 d0                	add    %edx,%eax
801099a3:	83 e8 01             	sub    $0x1,%eax
801099a6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801099ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801099ae:	83 ec 04             	sub    $0x4,%esp
801099b1:	6a 01                	push   $0x1
801099b3:	ff 75 f4             	pushl  -0xc(%ebp)
801099b6:	ff 75 08             	pushl  0x8(%ebp)
801099b9:	e8 2c ff ff ff       	call   801098ea <walkpgdir>
801099be:	83 c4 10             	add    $0x10,%esp
801099c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
801099c4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801099c8:	75 07                	jne    801099d1 <mappages+0x47>
      return -1;
801099ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801099cf:	eb 47                	jmp    80109a18 <mappages+0x8e>
    if(*pte & PTE_P)
801099d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801099d4:	8b 00                	mov    (%eax),%eax
801099d6:	83 e0 01             	and    $0x1,%eax
801099d9:	85 c0                	test   %eax,%eax
801099db:	74 0d                	je     801099ea <mappages+0x60>
      panic("remap");
801099dd:	83 ec 0c             	sub    $0xc,%esp
801099e0:	68 5c ac 10 80       	push   $0x8010ac5c
801099e5:	e8 7c 6b ff ff       	call   80100566 <panic>
    *pte = pa | perm | PTE_P;
801099ea:	8b 45 18             	mov    0x18(%ebp),%eax
801099ed:	0b 45 14             	or     0x14(%ebp),%eax
801099f0:	83 c8 01             	or     $0x1,%eax
801099f3:	89 c2                	mov    %eax,%edx
801099f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801099f8:	89 10                	mov    %edx,(%eax)
    if(a == last)
801099fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099fd:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80109a00:	74 10                	je     80109a12 <mappages+0x88>
      break;
    a += PGSIZE;
80109a02:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80109a09:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80109a10:	eb 9c                	jmp    801099ae <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80109a12:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80109a13:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109a18:	c9                   	leave  
80109a19:	c3                   	ret    

80109a1a <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80109a1a:	55                   	push   %ebp
80109a1b:	89 e5                	mov    %esp,%ebp
80109a1d:	53                   	push   %ebx
80109a1e:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80109a21:	e8 df 95 ff ff       	call   80103005 <kalloc>
80109a26:	89 45 f0             	mov    %eax,-0x10(%ebp)
80109a29:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109a2d:	75 0a                	jne    80109a39 <setupkvm+0x1f>
    return 0;
80109a2f:	b8 00 00 00 00       	mov    $0x0,%eax
80109a34:	e9 8e 00 00 00       	jmp    80109ac7 <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80109a39:	83 ec 04             	sub    $0x4,%esp
80109a3c:	68 00 10 00 00       	push   $0x1000
80109a41:	6a 00                	push   $0x0
80109a43:	ff 75 f0             	pushl  -0x10(%ebp)
80109a46:	e8 1f d2 ff ff       	call   80106c6a <memset>
80109a4b:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80109a4e:	83 ec 0c             	sub    $0xc,%esp
80109a51:	68 00 00 00 0e       	push   $0xe000000
80109a56:	e8 0d fa ff ff       	call   80109468 <p2v>
80109a5b:	83 c4 10             	add    $0x10,%esp
80109a5e:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80109a63:	76 0d                	jbe    80109a72 <setupkvm+0x58>
    panic("PHYSTOP too high");
80109a65:	83 ec 0c             	sub    $0xc,%esp
80109a68:	68 62 ac 10 80       	push   $0x8010ac62
80109a6d:	e8 f4 6a ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80109a72:	c7 45 f4 e0 d4 10 80 	movl   $0x8010d4e0,-0xc(%ebp)
80109a79:	eb 40                	jmp    80109abb <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80109a7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a7e:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80109a81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a84:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80109a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a8a:	8b 58 08             	mov    0x8(%eax),%ebx
80109a8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a90:	8b 40 04             	mov    0x4(%eax),%eax
80109a93:	29 c3                	sub    %eax,%ebx
80109a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a98:	8b 00                	mov    (%eax),%eax
80109a9a:	83 ec 0c             	sub    $0xc,%esp
80109a9d:	51                   	push   %ecx
80109a9e:	52                   	push   %edx
80109a9f:	53                   	push   %ebx
80109aa0:	50                   	push   %eax
80109aa1:	ff 75 f0             	pushl  -0x10(%ebp)
80109aa4:	e8 e1 fe ff ff       	call   8010998a <mappages>
80109aa9:	83 c4 20             	add    $0x20,%esp
80109aac:	85 c0                	test   %eax,%eax
80109aae:	79 07                	jns    80109ab7 <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80109ab0:	b8 00 00 00 00       	mov    $0x0,%eax
80109ab5:	eb 10                	jmp    80109ac7 <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80109ab7:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80109abb:	81 7d f4 20 d5 10 80 	cmpl   $0x8010d520,-0xc(%ebp)
80109ac2:	72 b7                	jb     80109a7b <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80109ac4:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80109ac7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109aca:	c9                   	leave  
80109acb:	c3                   	ret    

80109acc <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80109acc:	55                   	push   %ebp
80109acd:	89 e5                	mov    %esp,%ebp
80109acf:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80109ad2:	e8 43 ff ff ff       	call   80109a1a <setupkvm>
80109ad7:	a3 78 79 11 80       	mov    %eax,0x80117978
  switchkvm();
80109adc:	e8 03 00 00 00       	call   80109ae4 <switchkvm>
}
80109ae1:	90                   	nop
80109ae2:	c9                   	leave  
80109ae3:	c3                   	ret    

80109ae4 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80109ae4:	55                   	push   %ebp
80109ae5:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80109ae7:	a1 78 79 11 80       	mov    0x80117978,%eax
80109aec:	50                   	push   %eax
80109aed:	e8 69 f9 ff ff       	call   8010945b <v2p>
80109af2:	83 c4 04             	add    $0x4,%esp
80109af5:	50                   	push   %eax
80109af6:	e8 54 f9 ff ff       	call   8010944f <lcr3>
80109afb:	83 c4 04             	add    $0x4,%esp
}
80109afe:	90                   	nop
80109aff:	c9                   	leave  
80109b00:	c3                   	ret    

80109b01 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80109b01:	55                   	push   %ebp
80109b02:	89 e5                	mov    %esp,%ebp
80109b04:	56                   	push   %esi
80109b05:	53                   	push   %ebx
  pushcli();
80109b06:	e8 59 d0 ff ff       	call   80106b64 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80109b0b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80109b11:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80109b18:	83 c2 08             	add    $0x8,%edx
80109b1b:	89 d6                	mov    %edx,%esi
80109b1d:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80109b24:	83 c2 08             	add    $0x8,%edx
80109b27:	c1 ea 10             	shr    $0x10,%edx
80109b2a:	89 d3                	mov    %edx,%ebx
80109b2c:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80109b33:	83 c2 08             	add    $0x8,%edx
80109b36:	c1 ea 18             	shr    $0x18,%edx
80109b39:	89 d1                	mov    %edx,%ecx
80109b3b:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80109b42:	67 00 
80109b44:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80109b4b:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80109b51:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80109b58:	83 e2 f0             	and    $0xfffffff0,%edx
80109b5b:	83 ca 09             	or     $0x9,%edx
80109b5e:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80109b64:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80109b6b:	83 ca 10             	or     $0x10,%edx
80109b6e:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80109b74:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80109b7b:	83 e2 9f             	and    $0xffffff9f,%edx
80109b7e:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80109b84:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80109b8b:	83 ca 80             	or     $0xffffff80,%edx
80109b8e:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80109b94:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80109b9b:	83 e2 f0             	and    $0xfffffff0,%edx
80109b9e:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80109ba4:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80109bab:	83 e2 ef             	and    $0xffffffef,%edx
80109bae:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80109bb4:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80109bbb:	83 e2 df             	and    $0xffffffdf,%edx
80109bbe:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80109bc4:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80109bcb:	83 ca 40             	or     $0x40,%edx
80109bce:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80109bd4:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80109bdb:	83 e2 7f             	and    $0x7f,%edx
80109bde:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80109be4:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80109bea:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80109bf0:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80109bf7:	83 e2 ef             	and    $0xffffffef,%edx
80109bfa:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80109c00:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80109c06:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80109c0c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80109c12:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80109c19:	8b 52 08             	mov    0x8(%edx),%edx
80109c1c:	81 c2 00 10 00 00    	add    $0x1000,%edx
80109c22:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80109c25:	83 ec 0c             	sub    $0xc,%esp
80109c28:	6a 30                	push   $0x30
80109c2a:	e8 f3 f7 ff ff       	call   80109422 <ltr>
80109c2f:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80109c32:	8b 45 08             	mov    0x8(%ebp),%eax
80109c35:	8b 40 04             	mov    0x4(%eax),%eax
80109c38:	85 c0                	test   %eax,%eax
80109c3a:	75 0d                	jne    80109c49 <switchuvm+0x148>
    panic("switchuvm: no pgdir");
80109c3c:	83 ec 0c             	sub    $0xc,%esp
80109c3f:	68 73 ac 10 80       	push   $0x8010ac73
80109c44:	e8 1d 69 ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80109c49:	8b 45 08             	mov    0x8(%ebp),%eax
80109c4c:	8b 40 04             	mov    0x4(%eax),%eax
80109c4f:	83 ec 0c             	sub    $0xc,%esp
80109c52:	50                   	push   %eax
80109c53:	e8 03 f8 ff ff       	call   8010945b <v2p>
80109c58:	83 c4 10             	add    $0x10,%esp
80109c5b:	83 ec 0c             	sub    $0xc,%esp
80109c5e:	50                   	push   %eax
80109c5f:	e8 eb f7 ff ff       	call   8010944f <lcr3>
80109c64:	83 c4 10             	add    $0x10,%esp
  popcli();
80109c67:	e8 3d cf ff ff       	call   80106ba9 <popcli>
}
80109c6c:	90                   	nop
80109c6d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80109c70:	5b                   	pop    %ebx
80109c71:	5e                   	pop    %esi
80109c72:	5d                   	pop    %ebp
80109c73:	c3                   	ret    

80109c74 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80109c74:	55                   	push   %ebp
80109c75:	89 e5                	mov    %esp,%ebp
80109c77:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80109c7a:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80109c81:	76 0d                	jbe    80109c90 <inituvm+0x1c>
    panic("inituvm: more than a page");
80109c83:	83 ec 0c             	sub    $0xc,%esp
80109c86:	68 87 ac 10 80       	push   $0x8010ac87
80109c8b:	e8 d6 68 ff ff       	call   80100566 <panic>
  mem = kalloc();
80109c90:	e8 70 93 ff ff       	call   80103005 <kalloc>
80109c95:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80109c98:	83 ec 04             	sub    $0x4,%esp
80109c9b:	68 00 10 00 00       	push   $0x1000
80109ca0:	6a 00                	push   $0x0
80109ca2:	ff 75 f4             	pushl  -0xc(%ebp)
80109ca5:	e8 c0 cf ff ff       	call   80106c6a <memset>
80109caa:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80109cad:	83 ec 0c             	sub    $0xc,%esp
80109cb0:	ff 75 f4             	pushl  -0xc(%ebp)
80109cb3:	e8 a3 f7 ff ff       	call   8010945b <v2p>
80109cb8:	83 c4 10             	add    $0x10,%esp
80109cbb:	83 ec 0c             	sub    $0xc,%esp
80109cbe:	6a 06                	push   $0x6
80109cc0:	50                   	push   %eax
80109cc1:	68 00 10 00 00       	push   $0x1000
80109cc6:	6a 00                	push   $0x0
80109cc8:	ff 75 08             	pushl  0x8(%ebp)
80109ccb:	e8 ba fc ff ff       	call   8010998a <mappages>
80109cd0:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80109cd3:	83 ec 04             	sub    $0x4,%esp
80109cd6:	ff 75 10             	pushl  0x10(%ebp)
80109cd9:	ff 75 0c             	pushl  0xc(%ebp)
80109cdc:	ff 75 f4             	pushl  -0xc(%ebp)
80109cdf:	e8 45 d0 ff ff       	call   80106d29 <memmove>
80109ce4:	83 c4 10             	add    $0x10,%esp
}
80109ce7:	90                   	nop
80109ce8:	c9                   	leave  
80109ce9:	c3                   	ret    

80109cea <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80109cea:	55                   	push   %ebp
80109ceb:	89 e5                	mov    %esp,%ebp
80109ced:	53                   	push   %ebx
80109cee:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80109cf1:	8b 45 0c             	mov    0xc(%ebp),%eax
80109cf4:	25 ff 0f 00 00       	and    $0xfff,%eax
80109cf9:	85 c0                	test   %eax,%eax
80109cfb:	74 0d                	je     80109d0a <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
80109cfd:	83 ec 0c             	sub    $0xc,%esp
80109d00:	68 a4 ac 10 80       	push   $0x8010aca4
80109d05:	e8 5c 68 ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80109d0a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109d11:	e9 95 00 00 00       	jmp    80109dab <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80109d16:	8b 55 0c             	mov    0xc(%ebp),%edx
80109d19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d1c:	01 d0                	add    %edx,%eax
80109d1e:	83 ec 04             	sub    $0x4,%esp
80109d21:	6a 00                	push   $0x0
80109d23:	50                   	push   %eax
80109d24:	ff 75 08             	pushl  0x8(%ebp)
80109d27:	e8 be fb ff ff       	call   801098ea <walkpgdir>
80109d2c:	83 c4 10             	add    $0x10,%esp
80109d2f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80109d32:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109d36:	75 0d                	jne    80109d45 <loaduvm+0x5b>
      panic("loaduvm: address should exist");
80109d38:	83 ec 0c             	sub    $0xc,%esp
80109d3b:	68 c7 ac 10 80       	push   $0x8010acc7
80109d40:	e8 21 68 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80109d45:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d48:	8b 00                	mov    (%eax),%eax
80109d4a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109d4f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80109d52:	8b 45 18             	mov    0x18(%ebp),%eax
80109d55:	2b 45 f4             	sub    -0xc(%ebp),%eax
80109d58:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80109d5d:	77 0b                	ja     80109d6a <loaduvm+0x80>
      n = sz - i;
80109d5f:	8b 45 18             	mov    0x18(%ebp),%eax
80109d62:	2b 45 f4             	sub    -0xc(%ebp),%eax
80109d65:	89 45 f0             	mov    %eax,-0x10(%ebp)
80109d68:	eb 07                	jmp    80109d71 <loaduvm+0x87>
    else
      n = PGSIZE;
80109d6a:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80109d71:	8b 55 14             	mov    0x14(%ebp),%edx
80109d74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d77:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80109d7a:	83 ec 0c             	sub    $0xc,%esp
80109d7d:	ff 75 e8             	pushl  -0x18(%ebp)
80109d80:	e8 e3 f6 ff ff       	call   80109468 <p2v>
80109d85:	83 c4 10             	add    $0x10,%esp
80109d88:	ff 75 f0             	pushl  -0x10(%ebp)
80109d8b:	53                   	push   %ebx
80109d8c:	50                   	push   %eax
80109d8d:	ff 75 10             	pushl  0x10(%ebp)
80109d90:	e8 3e 83 ff ff       	call   801020d3 <readi>
80109d95:	83 c4 10             	add    $0x10,%esp
80109d98:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80109d9b:	74 07                	je     80109da4 <loaduvm+0xba>
      return -1;
80109d9d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109da2:	eb 18                	jmp    80109dbc <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80109da4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109dab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109dae:	3b 45 18             	cmp    0x18(%ebp),%eax
80109db1:	0f 82 5f ff ff ff    	jb     80109d16 <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80109db7:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109dbc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109dbf:	c9                   	leave  
80109dc0:	c3                   	ret    

80109dc1 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80109dc1:	55                   	push   %ebp
80109dc2:	89 e5                	mov    %esp,%ebp
80109dc4:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80109dc7:	8b 45 10             	mov    0x10(%ebp),%eax
80109dca:	85 c0                	test   %eax,%eax
80109dcc:	79 0a                	jns    80109dd8 <allocuvm+0x17>
    return 0;
80109dce:	b8 00 00 00 00       	mov    $0x0,%eax
80109dd3:	e9 b0 00 00 00       	jmp    80109e88 <allocuvm+0xc7>
  if(newsz < oldsz)
80109dd8:	8b 45 10             	mov    0x10(%ebp),%eax
80109ddb:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109dde:	73 08                	jae    80109de8 <allocuvm+0x27>
    return oldsz;
80109de0:	8b 45 0c             	mov    0xc(%ebp),%eax
80109de3:	e9 a0 00 00 00       	jmp    80109e88 <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
80109de8:	8b 45 0c             	mov    0xc(%ebp),%eax
80109deb:	05 ff 0f 00 00       	add    $0xfff,%eax
80109df0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109df5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80109df8:	eb 7f                	jmp    80109e79 <allocuvm+0xb8>
    mem = kalloc();
80109dfa:	e8 06 92 ff ff       	call   80103005 <kalloc>
80109dff:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80109e02:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109e06:	75 2b                	jne    80109e33 <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
80109e08:	83 ec 0c             	sub    $0xc,%esp
80109e0b:	68 e5 ac 10 80       	push   $0x8010ace5
80109e10:	e8 b1 65 ff ff       	call   801003c6 <cprintf>
80109e15:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80109e18:	83 ec 04             	sub    $0x4,%esp
80109e1b:	ff 75 0c             	pushl  0xc(%ebp)
80109e1e:	ff 75 10             	pushl  0x10(%ebp)
80109e21:	ff 75 08             	pushl  0x8(%ebp)
80109e24:	e8 61 00 00 00       	call   80109e8a <deallocuvm>
80109e29:	83 c4 10             	add    $0x10,%esp
      return 0;
80109e2c:	b8 00 00 00 00       	mov    $0x0,%eax
80109e31:	eb 55                	jmp    80109e88 <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
80109e33:	83 ec 04             	sub    $0x4,%esp
80109e36:	68 00 10 00 00       	push   $0x1000
80109e3b:	6a 00                	push   $0x0
80109e3d:	ff 75 f0             	pushl  -0x10(%ebp)
80109e40:	e8 25 ce ff ff       	call   80106c6a <memset>
80109e45:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80109e48:	83 ec 0c             	sub    $0xc,%esp
80109e4b:	ff 75 f0             	pushl  -0x10(%ebp)
80109e4e:	e8 08 f6 ff ff       	call   8010945b <v2p>
80109e53:	83 c4 10             	add    $0x10,%esp
80109e56:	89 c2                	mov    %eax,%edx
80109e58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e5b:	83 ec 0c             	sub    $0xc,%esp
80109e5e:	6a 06                	push   $0x6
80109e60:	52                   	push   %edx
80109e61:	68 00 10 00 00       	push   $0x1000
80109e66:	50                   	push   %eax
80109e67:	ff 75 08             	pushl  0x8(%ebp)
80109e6a:	e8 1b fb ff ff       	call   8010998a <mappages>
80109e6f:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80109e72:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109e79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e7c:	3b 45 10             	cmp    0x10(%ebp),%eax
80109e7f:	0f 82 75 ff ff ff    	jb     80109dfa <allocuvm+0x39>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80109e85:	8b 45 10             	mov    0x10(%ebp),%eax
}
80109e88:	c9                   	leave  
80109e89:	c3                   	ret    

80109e8a <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80109e8a:	55                   	push   %ebp
80109e8b:	89 e5                	mov    %esp,%ebp
80109e8d:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80109e90:	8b 45 10             	mov    0x10(%ebp),%eax
80109e93:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109e96:	72 08                	jb     80109ea0 <deallocuvm+0x16>
    return oldsz;
80109e98:	8b 45 0c             	mov    0xc(%ebp),%eax
80109e9b:	e9 a5 00 00 00       	jmp    80109f45 <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
80109ea0:	8b 45 10             	mov    0x10(%ebp),%eax
80109ea3:	05 ff 0f 00 00       	add    $0xfff,%eax
80109ea8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109ead:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80109eb0:	e9 81 00 00 00       	jmp    80109f36 <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
80109eb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109eb8:	83 ec 04             	sub    $0x4,%esp
80109ebb:	6a 00                	push   $0x0
80109ebd:	50                   	push   %eax
80109ebe:	ff 75 08             	pushl  0x8(%ebp)
80109ec1:	e8 24 fa ff ff       	call   801098ea <walkpgdir>
80109ec6:	83 c4 10             	add    $0x10,%esp
80109ec9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80109ecc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109ed0:	75 09                	jne    80109edb <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
80109ed2:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80109ed9:	eb 54                	jmp    80109f2f <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
80109edb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ede:	8b 00                	mov    (%eax),%eax
80109ee0:	83 e0 01             	and    $0x1,%eax
80109ee3:	85 c0                	test   %eax,%eax
80109ee5:	74 48                	je     80109f2f <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
80109ee7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109eea:	8b 00                	mov    (%eax),%eax
80109eec:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109ef1:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80109ef4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109ef8:	75 0d                	jne    80109f07 <deallocuvm+0x7d>
        panic("kfree");
80109efa:	83 ec 0c             	sub    $0xc,%esp
80109efd:	68 fd ac 10 80       	push   $0x8010acfd
80109f02:	e8 5f 66 ff ff       	call   80100566 <panic>
      char *v = p2v(pa);
80109f07:	83 ec 0c             	sub    $0xc,%esp
80109f0a:	ff 75 ec             	pushl  -0x14(%ebp)
80109f0d:	e8 56 f5 ff ff       	call   80109468 <p2v>
80109f12:	83 c4 10             	add    $0x10,%esp
80109f15:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80109f18:	83 ec 0c             	sub    $0xc,%esp
80109f1b:	ff 75 e8             	pushl  -0x18(%ebp)
80109f1e:	e8 45 90 ff ff       	call   80102f68 <kfree>
80109f23:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80109f26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f29:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80109f2f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109f36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f39:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109f3c:	0f 82 73 ff ff ff    	jb     80109eb5 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80109f42:	8b 45 10             	mov    0x10(%ebp),%eax
}
80109f45:	c9                   	leave  
80109f46:	c3                   	ret    

80109f47 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80109f47:	55                   	push   %ebp
80109f48:	89 e5                	mov    %esp,%ebp
80109f4a:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80109f4d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80109f51:	75 0d                	jne    80109f60 <freevm+0x19>
    panic("freevm: no pgdir");
80109f53:	83 ec 0c             	sub    $0xc,%esp
80109f56:	68 03 ad 10 80       	push   $0x8010ad03
80109f5b:	e8 06 66 ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80109f60:	83 ec 04             	sub    $0x4,%esp
80109f63:	6a 00                	push   $0x0
80109f65:	68 00 00 00 80       	push   $0x80000000
80109f6a:	ff 75 08             	pushl  0x8(%ebp)
80109f6d:	e8 18 ff ff ff       	call   80109e8a <deallocuvm>
80109f72:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80109f75:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109f7c:	eb 4f                	jmp    80109fcd <freevm+0x86>
    if(pgdir[i] & PTE_P){
80109f7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f81:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109f88:	8b 45 08             	mov    0x8(%ebp),%eax
80109f8b:	01 d0                	add    %edx,%eax
80109f8d:	8b 00                	mov    (%eax),%eax
80109f8f:	83 e0 01             	and    $0x1,%eax
80109f92:	85 c0                	test   %eax,%eax
80109f94:	74 33                	je     80109fc9 <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80109f96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f99:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109fa0:	8b 45 08             	mov    0x8(%ebp),%eax
80109fa3:	01 d0                	add    %edx,%eax
80109fa5:	8b 00                	mov    (%eax),%eax
80109fa7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109fac:	83 ec 0c             	sub    $0xc,%esp
80109faf:	50                   	push   %eax
80109fb0:	e8 b3 f4 ff ff       	call   80109468 <p2v>
80109fb5:	83 c4 10             	add    $0x10,%esp
80109fb8:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80109fbb:	83 ec 0c             	sub    $0xc,%esp
80109fbe:	ff 75 f0             	pushl  -0x10(%ebp)
80109fc1:	e8 a2 8f ff ff       	call   80102f68 <kfree>
80109fc6:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80109fc9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109fcd:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80109fd4:	76 a8                	jbe    80109f7e <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80109fd6:	83 ec 0c             	sub    $0xc,%esp
80109fd9:	ff 75 08             	pushl  0x8(%ebp)
80109fdc:	e8 87 8f ff ff       	call   80102f68 <kfree>
80109fe1:	83 c4 10             	add    $0x10,%esp
}
80109fe4:	90                   	nop
80109fe5:	c9                   	leave  
80109fe6:	c3                   	ret    

80109fe7 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80109fe7:	55                   	push   %ebp
80109fe8:	89 e5                	mov    %esp,%ebp
80109fea:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80109fed:	83 ec 04             	sub    $0x4,%esp
80109ff0:	6a 00                	push   $0x0
80109ff2:	ff 75 0c             	pushl  0xc(%ebp)
80109ff5:	ff 75 08             	pushl  0x8(%ebp)
80109ff8:	e8 ed f8 ff ff       	call   801098ea <walkpgdir>
80109ffd:	83 c4 10             	add    $0x10,%esp
8010a000:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
8010a003:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010a007:	75 0d                	jne    8010a016 <clearpteu+0x2f>
    panic("clearpteu");
8010a009:	83 ec 0c             	sub    $0xc,%esp
8010a00c:	68 14 ad 10 80       	push   $0x8010ad14
8010a011:	e8 50 65 ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
8010a016:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a019:	8b 00                	mov    (%eax),%eax
8010a01b:	83 e0 fb             	and    $0xfffffffb,%eax
8010a01e:	89 c2                	mov    %eax,%edx
8010a020:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a023:	89 10                	mov    %edx,(%eax)
}
8010a025:	90                   	nop
8010a026:	c9                   	leave  
8010a027:	c3                   	ret    

8010a028 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010a028:	55                   	push   %ebp
8010a029:	89 e5                	mov    %esp,%ebp
8010a02b:	53                   	push   %ebx
8010a02c:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010a02f:	e8 e6 f9 ff ff       	call   80109a1a <setupkvm>
8010a034:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010a037:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010a03b:	75 0a                	jne    8010a047 <copyuvm+0x1f>
    return 0;
8010a03d:	b8 00 00 00 00       	mov    $0x0,%eax
8010a042:	e9 f8 00 00 00       	jmp    8010a13f <copyuvm+0x117>
  for(i = 0; i < sz; i += PGSIZE){
8010a047:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010a04e:	e9 c4 00 00 00       	jmp    8010a117 <copyuvm+0xef>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
8010a053:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a056:	83 ec 04             	sub    $0x4,%esp
8010a059:	6a 00                	push   $0x0
8010a05b:	50                   	push   %eax
8010a05c:	ff 75 08             	pushl  0x8(%ebp)
8010a05f:	e8 86 f8 ff ff       	call   801098ea <walkpgdir>
8010a064:	83 c4 10             	add    $0x10,%esp
8010a067:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010a06a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010a06e:	75 0d                	jne    8010a07d <copyuvm+0x55>
      panic("copyuvm: pte should exist");
8010a070:	83 ec 0c             	sub    $0xc,%esp
8010a073:	68 1e ad 10 80       	push   $0x8010ad1e
8010a078:	e8 e9 64 ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P))
8010a07d:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a080:	8b 00                	mov    (%eax),%eax
8010a082:	83 e0 01             	and    $0x1,%eax
8010a085:	85 c0                	test   %eax,%eax
8010a087:	75 0d                	jne    8010a096 <copyuvm+0x6e>
      panic("copyuvm: page not present");
8010a089:	83 ec 0c             	sub    $0xc,%esp
8010a08c:	68 38 ad 10 80       	push   $0x8010ad38
8010a091:	e8 d0 64 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
8010a096:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a099:	8b 00                	mov    (%eax),%eax
8010a09b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a0a0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
8010a0a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a0a6:	8b 00                	mov    (%eax),%eax
8010a0a8:	25 ff 0f 00 00       	and    $0xfff,%eax
8010a0ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
8010a0b0:	e8 50 8f ff ff       	call   80103005 <kalloc>
8010a0b5:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010a0b8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010a0bc:	74 6a                	je     8010a128 <copyuvm+0x100>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
8010a0be:	83 ec 0c             	sub    $0xc,%esp
8010a0c1:	ff 75 e8             	pushl  -0x18(%ebp)
8010a0c4:	e8 9f f3 ff ff       	call   80109468 <p2v>
8010a0c9:	83 c4 10             	add    $0x10,%esp
8010a0cc:	83 ec 04             	sub    $0x4,%esp
8010a0cf:	68 00 10 00 00       	push   $0x1000
8010a0d4:	50                   	push   %eax
8010a0d5:	ff 75 e0             	pushl  -0x20(%ebp)
8010a0d8:	e8 4c cc ff ff       	call   80106d29 <memmove>
8010a0dd:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
8010a0e0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
8010a0e3:	83 ec 0c             	sub    $0xc,%esp
8010a0e6:	ff 75 e0             	pushl  -0x20(%ebp)
8010a0e9:	e8 6d f3 ff ff       	call   8010945b <v2p>
8010a0ee:	83 c4 10             	add    $0x10,%esp
8010a0f1:	89 c2                	mov    %eax,%edx
8010a0f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a0f6:	83 ec 0c             	sub    $0xc,%esp
8010a0f9:	53                   	push   %ebx
8010a0fa:	52                   	push   %edx
8010a0fb:	68 00 10 00 00       	push   $0x1000
8010a100:	50                   	push   %eax
8010a101:	ff 75 f0             	pushl  -0x10(%ebp)
8010a104:	e8 81 f8 ff ff       	call   8010998a <mappages>
8010a109:	83 c4 20             	add    $0x20,%esp
8010a10c:	85 c0                	test   %eax,%eax
8010a10e:	78 1b                	js     8010a12b <copyuvm+0x103>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
8010a110:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010a117:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a11a:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010a11d:	0f 82 30 ff ff ff    	jb     8010a053 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
8010a123:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a126:	eb 17                	jmp    8010a13f <copyuvm+0x117>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
8010a128:	90                   	nop
8010a129:	eb 01                	jmp    8010a12c <copyuvm+0x104>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
8010a12b:	90                   	nop
  }
  return d;

bad:
  freevm(d);
8010a12c:	83 ec 0c             	sub    $0xc,%esp
8010a12f:	ff 75 f0             	pushl  -0x10(%ebp)
8010a132:	e8 10 fe ff ff       	call   80109f47 <freevm>
8010a137:	83 c4 10             	add    $0x10,%esp
  return 0;
8010a13a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010a13f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010a142:	c9                   	leave  
8010a143:	c3                   	ret    

8010a144 <uva2ka>:

// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010a144:	55                   	push   %ebp
8010a145:	89 e5                	mov    %esp,%ebp
8010a147:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010a14a:	83 ec 04             	sub    $0x4,%esp
8010a14d:	6a 00                	push   $0x0
8010a14f:	ff 75 0c             	pushl  0xc(%ebp)
8010a152:	ff 75 08             	pushl  0x8(%ebp)
8010a155:	e8 90 f7 ff ff       	call   801098ea <walkpgdir>
8010a15a:	83 c4 10             	add    $0x10,%esp
8010a15d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010a160:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a163:	8b 00                	mov    (%eax),%eax
8010a165:	83 e0 01             	and    $0x1,%eax
8010a168:	85 c0                	test   %eax,%eax
8010a16a:	75 07                	jne    8010a173 <uva2ka+0x2f>
    return 0;
8010a16c:	b8 00 00 00 00       	mov    $0x0,%eax
8010a171:	eb 29                	jmp    8010a19c <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
8010a173:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a176:	8b 00                	mov    (%eax),%eax
8010a178:	83 e0 04             	and    $0x4,%eax
8010a17b:	85 c0                	test   %eax,%eax
8010a17d:	75 07                	jne    8010a186 <uva2ka+0x42>
    return 0;
8010a17f:	b8 00 00 00 00       	mov    $0x0,%eax
8010a184:	eb 16                	jmp    8010a19c <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
8010a186:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010a189:	8b 00                	mov    (%eax),%eax
8010a18b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a190:	83 ec 0c             	sub    $0xc,%esp
8010a193:	50                   	push   %eax
8010a194:	e8 cf f2 ff ff       	call   80109468 <p2v>
8010a199:	83 c4 10             	add    $0x10,%esp
}
8010a19c:	c9                   	leave  
8010a19d:	c3                   	ret    

8010a19e <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010a19e:	55                   	push   %ebp
8010a19f:	89 e5                	mov    %esp,%ebp
8010a1a1:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
8010a1a4:	8b 45 10             	mov    0x10(%ebp),%eax
8010a1a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
8010a1aa:	eb 7f                	jmp    8010a22b <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
8010a1ac:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a1af:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010a1b4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010a1b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a1ba:	83 ec 08             	sub    $0x8,%esp
8010a1bd:	50                   	push   %eax
8010a1be:	ff 75 08             	pushl  0x8(%ebp)
8010a1c1:	e8 7e ff ff ff       	call   8010a144 <uva2ka>
8010a1c6:	83 c4 10             	add    $0x10,%esp
8010a1c9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010a1cc:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010a1d0:	75 07                	jne    8010a1d9 <copyout+0x3b>
      return -1;
8010a1d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010a1d7:	eb 61                	jmp    8010a23a <copyout+0x9c>
    n = PGSIZE - (va - va0);
8010a1d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a1dc:	2b 45 0c             	sub    0xc(%ebp),%eax
8010a1df:	05 00 10 00 00       	add    $0x1000,%eax
8010a1e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010a1e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a1ea:	3b 45 14             	cmp    0x14(%ebp),%eax
8010a1ed:	76 06                	jbe    8010a1f5 <copyout+0x57>
      n = len;
8010a1ef:	8b 45 14             	mov    0x14(%ebp),%eax
8010a1f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010a1f5:	8b 45 0c             	mov    0xc(%ebp),%eax
8010a1f8:	2b 45 ec             	sub    -0x14(%ebp),%eax
8010a1fb:	89 c2                	mov    %eax,%edx
8010a1fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010a200:	01 d0                	add    %edx,%eax
8010a202:	83 ec 04             	sub    $0x4,%esp
8010a205:	ff 75 f0             	pushl  -0x10(%ebp)
8010a208:	ff 75 f4             	pushl  -0xc(%ebp)
8010a20b:	50                   	push   %eax
8010a20c:	e8 18 cb ff ff       	call   80106d29 <memmove>
8010a211:	83 c4 10             	add    $0x10,%esp
    len -= n;
8010a214:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a217:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010a21a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010a21d:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
8010a220:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010a223:	05 00 10 00 00       	add    $0x1000,%eax
8010a228:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
8010a22b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010a22f:	0f 85 77 ff ff ff    	jne    8010a1ac <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
8010a235:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010a23a:	c9                   	leave  
8010a23b:	c3                   	ret    
