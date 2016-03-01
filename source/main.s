.section .init
.globl _start
_start:

;Prepare to turn the Pi LED on
ldr r0,=0x20200000  ;load the hex number into the r0 register of the CPU, the address of the GPIO controller
mov r1,#1           ;put the number 1 into the r1 register
lsl r1,#18          ;logical shift left the value in r1 by 18 binary places (bloody hell this is complicated...)
str r1,[r0,#4]      ;add 4 to the GPIO controller address, r0, and store the value of r1 in that location

;Turn the Pi LED on
turnOn$:
mov r1,#1           ;put the number 1 in the r1 register       
lsl r1,#16          ;logical shift left the value in r1 by 16 binary places
str r1,[r0,#40]     ;write the result of the lsl out to the GPIO address at 40, which turns the led 'on' (actually off!)

;Now wait, before turning it off
mov r2,#0x3F0000
wait1$:
  sub r2,#1
  cmp r2,#0
  bne wait1$

;now turn the LED off
str r1,[r0,#28]

;wait again...
mov r2,#0x3F0000
wait2$:
  sub r2,#1
  cmp r2,#0
  bne wait2$

;Turn it back on!
b turnOn$

;Loop indefinitely
loop$: 
b loop$             ;basically causes an infinite loop here. (LED will remain on)
