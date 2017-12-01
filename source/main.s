; Raspberry Pi OS.
; This is based on the example OS by Alex Chadwick,
; University of Cambridge.

; Released under the creative commons license.

; This is the main function that executes when the 
; Raspberry Pi is turned on. 

; .globl is a directive to the assembler to tell it
; to export this symbol to the elf file. By convention;
; _start is used for the entry point.
.section .init
.globl _start
_start:

; Branch to the actual main section of the code
b main

;Section used to place the init section (above)
;to the default load address at 8000_16
.section .text
main:
  ; set the stack point to 0x8000
  mov sp,#0x8000

;Prepare to turn the Pi LED on
;ldr r0,=0x20200000  ;load the hex number into the r0 register of the CPU, the address of the GPIO controller
;mov r1,#1           ;put the number 1 into the r1 register
;lsl r1,#18          ;logical shift left the value in r1 by 18 binary places (bloody hell this is complicated...)
;str r1,[r0,#4]      ;add 4 to the GPIO controller address, r0, and store the value of r1 in that location

;Replaced above with:
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

; This code will load the pattern into r4
; and load 0 into r5. r5 will be the sequence
; position, so we can keept track of how much 
; of the pattern we have displayed.
ptrn .req r4
ldr ptrn,=pattern
ldr ptrn,[ptrn]
seq .req r5
mov seq,#0

; puts a non-zero into r1 if there is a 1 in
; the current part of the pattern
mov r1,#1
lsl r1,seq
and r1,ptrn

;Loop indefinitely
loop$: 
b loop$            
;basically causes an infinite loop here.
;(LED will remain on)

; Data
; to differentiate between data and code, we put
; all the data in a different section underneath
; our code above. In real operating systems, it 
; is important to know which parts of the code 
; can be executed, and which parts cannot (data)
; At the machine code level, there is fundamentally
; no difference between data and executable code, 
; so we design operating systems to make this 
; distinction for us.
.section .data
; Align ensures that all the following data will 
; be placed at an address which is apower of the 
; number that follows. So in thiss case we are
; saying that we want all our data placed in 
; a memory address that is a multiple of four.
; 2^2 = 4
; This is important to do because the ldr instruction
; used to read memory only works at addresses that
; are multiples of four. 
.align 2
pattern:
; the /int command copies the value that follows it
; directly to the output. This particular data
; is the morse code pattern for SOS: ...---...
  .int 0b11111111101010100010001000101010				  
