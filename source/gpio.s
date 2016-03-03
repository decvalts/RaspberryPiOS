.globl GetGpioAddress ;make this block available to all other parts of the code
GetGpioAddress:
ldr r0,=0x20200000    ;load the GPIO address into memory
mov pc,lr             ;copy the value in lr to pc

.globl SetGpioFunction
SetGpioFunction:
cmp r0,#53
cmpls r1,#7
movhi pc,lr

push {lr}
mov r2,r0
bl GetGpioAddress
