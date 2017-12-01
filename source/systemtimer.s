; First, get the address of the system timer.
.globl GetSystemTimerBase
GetSystemTimerBase:
  ldr r0,=0x20003000
  mov pc,lr

; return the current counter value in registers r1 and r0
; r1 is the most significant 32 bits
.globl GetTimeStamp
GetTimeStamp:
  push {lr}
  bl GetSystemTimerBase
  ldrd r0,r1,[r0,#4]
  pop {pc}

; Function that waits a specified number of seconds before
; returning. Duration to wait is in r0. 
.globl Wait
Wait:
  delay .req r2
  mov delay,r0
  push {lr}
  bl GetTimeStamp
  start .req r3
  mov start,r0

; compute the difference between the counter value and 
; the value we just took.
; This code works by waiting until the requested amount
; of time has elapsed. Then it takes a reading from the
; counter, subtracts the initial value from the reading,
; and then compares the result to the requrested delay.
; If the time elapsed is less than that requested, it 
; branches back to loop$.
  loop$:
    bl GetTimeStamp
    elapsed .req r1
    sub elapsed,r0,start
    cmp elapsed,delay
    .unreq elapsed
    bls loop$

  ; Finally we can return from the function
  .unreq delay
  .unreq start
  pop {pc}


