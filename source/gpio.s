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
movhi pc,lr
push {lr}
mov r2,pinNum
.unreq pinNum
pinNum .req r2
bl GetGpioAddress
gpioAddr .req r0


