.syntax unified
.cpu cortex-m4
.thumb
/* dont include this: .fpu softvfp  since we dont use linker,
the modification done by assembler messes with our program*/

.word 0x20010000
.word Reset_Handler

.text
.global Reset_Handler

Reset_Handler:
    /* gpioc clock enable */
    ldr r0, =0x40023830 /* RCC->AHB1ENR */
    ldr r1, [r0]        /* Load the value */
    orr r1, r1, #0x04   /* RCC->AHB1ENR |= GPIOCEN set 3rd bit to one */
    str r1, [r0]        /* store the value */

    /* set led pin 13 as output*/
    ldr r0, =0x40020800 /* address of gpio port mode register GPIOC->MODER*/
    ldr r1, [r0]
    /* 0 at 27th bit, 1 at 26th bit to enable led pin */
    bic r1, r1, #(1 << 27)
    orr r1, r1, #(1 << 26)
    str r1, [r0]

    ldr r0, =0x40020814 /* GPIOC->ODR address (output data register) */

Loop:
    /* set 13 high, led off */
    ldr r1, [r0]
    orr r1, r1, #(1 << 13)
    str r1, [r0]

    /* looping delay value */
    ldr r2, =1000000
Delay1:
    subs r2, r2, #1
    bne Delay1

    /* set 13 low, led on */
    ldr r1, [r0]
    bic r1, r1, #(1 << 13)
    str r1, [r0]

    ldr r2, =1000000
Delay2:
    subs r2, r2, #1
    bne Delay2

    b Loop

