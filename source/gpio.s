.globl GetGpioAddress
; make this block available to all other parts of the code
GetGpioAddress:
ldr r0,=0x20200000    ;load the GPIO address into memory
mov pc,lr             ;copy the value in lr to pc

.globl SetGpioFunction
SetGpioFunction:
cmp r0,#53            ;check that r0 value is <=53
cmpls r1,#7           ;check that r1<=7
; the ls suffix above tells cmp to execute only if
; previous cmp function was true (less than)
movhi pc,lr
; similarly hi means mov only executes if previous
; comparison is higher

push {lr}         ;copy value of lr onto the top of stack
mov r2,r0
bl GetGpioAddress ;sets value of lr to next instruction 
                  ;then branches to GetGpioAddress

functionLoop$:
  cmp r2,#9         ;compares pin number to 9
  subhi r2,#10      ;if higher, subtract 10
  addhi r0,#4       ;if higher, add 4 to GPIO address
  bhi functionLoop$ ;run the check again

;r2 will now contain a number from 0-9
;r0 will contain address in GPIO controller
;This would be the same as GPIO Controller Address + 4 × (GPIO Pin Number ÷ 10)


add r2, r2,lsl #1   ;multiplication by 3 (in disguise...)
lsl r1,r2           ;shift function value left by r2 no of places
str r1,[r0]         ;store the new value
pop {pc}            ;copies the value that was in lr into pc

.globl SetGpio
SetGpio:
pinNum .req r0     ;gives an alias to ro 'pinNum'
pinVal .req r1

;Fucntion for checking we are given a valid pin number
cmp pinNum,#53
movhi pc,lr        ;preserve lr by pushing it to the stack
push {lr}
mov r2,pinNum      ;move pin number to r2
.unreq pinNum      ;this removes the alias from r0
pinNum .req r2
bl GetGpioAddress
gpioAddr .req r0

;CHECK WHICH SET OF 4 BYTES WE ARE IN
pinBank .req r3
lsr pinBank,pinNum,#5
lsl pinBank,#2
add gpioAddr,pinBank   ;gpioAddr will be 20200000_16 if pin 0-31
                       ; or 20200004_16 if pin is 32-53
.unreq pinBank

;GENERATE A NUMBER WITH THE CORRECT BIT SET
and pinNum,#31     ;boolean compare
setBit .req r3
mov setBit,#1
lsl setBit,pinNum
.unreq pinNum

;For the GPIO controller to to turn a pin on or off, it must 
;have a number with a bit set in the place of the remainder
;of the given pin's number divided by 32. To set pin 16, a
; number is needed with the 16th bit as 1. To set pin 45, a 
;number is needed with the 13th bit as 1, since 45/32 is 1
; remainder 13.

;CODE TO END THE METHOD
teq pinVal,#0                ;checks if the pinVal == 0
.unreq pinVal
streq setBit,[gpioAddr,#40]
strne setBit,[gpioAddr,#28]
.unreq setBit
.unreq gpioAddr
pop {pc}

;We turn the pin off if the value is zero and on if nonzero
;teq (test equal to) is similar to cmp (compare) but does not
;not work out which number is bigger. 

;If pinVal is 0, we store the setBit at 40 away from the GPIO
;address, which turns the pin off. Otherwise it is stored at
;28 which turns the pin on. At the end we can return by popping
; pc, which sets it to the value that we stored when we pushed
; the link register.







