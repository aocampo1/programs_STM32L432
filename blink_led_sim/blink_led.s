;******************** (C) COPYRIGHT 2020 REEX - FES Aragon, UNAM ***************
;* File Name          : blink_led.s
;* Author             : Ocampo
;* Date               : 23-Oct-2020
;* Description        : A simple code to blink LEDs on NUCLEO-L432KC
;*                      - Initialization carried out for GPIO-B pins PB0 to PB3 (connected to LEDs)
;*                      - Blink interval delay implemented in software
;*******************************************************************************

DELAY_INTERVAL	EQU	0x124F80
;**************************

;STM32L43xxx reference manual RM0394, p.64
RCC_AHB2ENR		EQU	0x4002104C	;Clock control for AHB2 p.214-215

;GPIO-B control registers
GPIOB_MODER		EQU	0x48000400	;set GPIO pin mode as Input/Output/Analog
GPIOB_OTYPER	EQU	0x48000404	;Set GPIO pin type as push-pull or open drain
GPIOB_OSPEEDR	EQU 0x48000408	;Set GPIO pin switching speed
GPIOB_PUPDR		EQU	0x4800040C	;Set GPIO pin pull-up/pull-down
GPIOB_ODR		EQU	0x48000414	;GPIO pin output data
;***************************

	AREA	MyCodigo, CODE, READONLY
	ENTRY ; Mark first instruction to execute
	EXPORT __main
		
__main
	; Enable GPIO clock
	LDR		R1, =RCC_AHB2ENR	;Pseudo-load address in R1
	LDR		R0, [R1]			;Copy contents at address in R1 to R0
	ORR 	R0, #0x00000002		;Bitwise OR entire word in R0, result in R0
	STR		R0, [R1]			;Store R0 contents to address in R1

	; Set mode as output p.263
	LDR		R1, =GPIOB_MODER	;Two bits per pin so bits 0 to 3 control pins 0 to 3
	LDR		R0, [R1]			
	ORR 	R0, #0x00000055		;Mode bits set to '01' makes the pin mode as output
	AND		R0, #0xFFFFFF55		;OR and AND both operations for 2 bits
	STR		R0, [R1]

	; Set type as push-pull	(Default)
	LDR		R1, =GPIOB_OTYPER	;Type bit '0' configures pin for push-pull
	LDR		R0, [R1]
	AND 	R0, #0xFFFFFFF0	
	STR		R0, [R1]
	
	; Set Speed slow
	LDR		R1, =GPIOB_OSPEEDR	;Two bits per pin so bits 0 to 3 control pins 0 to 3
	LDR		R0, [R1]
	AND 	R0, #0xFFFFFF00		;Speed bits set to '00' configures pin for slow speed
	STR		R0, [R1]	
	
	; Set pull-up
	LDR		R1, =GPIOB_PUPDR	;Two bits per pin so bits 0 to 3 control pins 0 to 3
	LDR		R0, [R1]
	AND		R0, #0xFFFFFF00		;Clear bits to disable pullup/pulldown
	STR		R0, [R1]
;***************************
turnON
	; Set output high
	LDR		R1, =GPIOB_ODR
	LDR		R0, [R1]
	ORR 	R0, #0x0000000F
	STR		R0, [R1]
    BL  	delay ; Call subroutine delay	
turnOFF
	; Set output low
	LDR		R1, =GPIOB_ODR
	LDR		R0, [R1]
	AND		R0, #0xFFFFFFF0
	STR		R0, [R1]	
    BL  	delay ; Call subroutine delay
	; loop
	B		turnON

; Subrutina delay
delay
	LDR		R2,=DELAY_INTERVAL
ret
	CBZ		R2, delayDone
	SUBS	R2, R2, #1
	B		ret
delayDone
	MOV 	pc,lr ; Return
	
	END