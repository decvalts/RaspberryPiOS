; First, get the address of the system timer.
.globl GetSystemTimerBase
GetSystemTimerBase:
ldr r0,=0x20003000
mov pc,lr

; return the current counter value in registers r1 and r0
.globl GetTimeStamp
GetTimeStamp:
push {lr}
bl GetSystemTimerBase
ldrd r0,r1,[r0,#4]
pop {pc}

; get the counter method when the method started 
delay .req r2
mov delay,r0
push {lr}
bl GetTimeStamp
start .req r3
mov start,r0

; compute the difference between the counter value and 
; the value we just took.
loop$:
  bl GetTimeStamp
  elapsed .req r1
  sub elapsed,r0,start
  cmp elapsed,delay
  .unreq elapsed
  bls loop$
