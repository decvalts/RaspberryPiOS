.section .init
.globl _start
_start:

bmain

;Section used to place the init section (above)
;to the default load address at 8000_16
.section .text
main:
mov sp,#0x8000

;Prepare to turn the Pi LED on
;ldr r0,=0x20200000  ;load the hex number into the r0 register of the CPU, the address of the GPIO controller
;mov r1,#1           ;put the number 1 into the r1 register
;lsl r1,#18          ;logical shift left the value in r1 by 18 binary places (bloody hell this is complicated...)
;str r1,[r0,#4]      ;add 4 to the GPIO controller address, r0, and store the value of r1 in that location

;Replace above with:
pinNum .req r0
pinFunc .req r1
mov pinNum,#16
mov pinFunc,#1
bl SetGpioFunction
.unreq pinNum
.unreq pinFunc
;to enable output to the OK LED. This works by 
;calling the Setgpiofunction with the pin num 16
;and the pin function code 1.

;Turn the Pi LED on
;This can now be replaced
;turnOn$:
;mov r1,#1           ;put the number 1 in the r1 register       
;lsl r1,#16          ;logical shift left the value in r1 by 16 binary places
;str r1,[r0,#40]     ;write the result of the lsl out to the GPIO address at 40, which turns the led 'on' (actually off!)

;New code to turn on OK LED
;It will turn off GPIO pin 16, and therefore
;turn on the LED.
pinNum .req r0
pinVal .req r1
mov pinNum,#16
mov pinVal,#0
bl SetGpio
.unreq pinNum
.unreq pinVal

;Now wait, before turning it off
mov r2,#0x3F0000
wait1$:
  sub r2,#1
  cmp r2,#0
  bne wait1$

;now turn the LED off
;Old Code:
;str r1,[r0,#28]
;New code uses pinval:
mov pinVal,#1

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
b loop$            
;basically causes an infinite loop here.
;(LED will remain on)


