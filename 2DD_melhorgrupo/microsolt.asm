;

; 2DD_melhorgrupo.asm

;

; Created: 27/09/2017 08:30:19

; Author : IEEE

;





; Replace with your application code

.include <m128def.inc>

.def		cnt_int= r20

.def		temp	= r25

.def		display	= r19

.def		contador = r18	; muda o nome

.equ		tempo1 =5

.equ		zero	= 0xC0

.equ		um		= 0xf9

.equ		dois	= 0xa4

.equ		tres	= 0xb0

.equ		quatro	= 0x99

.equ		cinco	= 0x92

.equ		seis	= 0x82

.equ		sete	= 0xf8

.equ		oito	= 0x80

.equ		nove	= 0x90





.cseg ; reset de vector

.org 0x0 ;defina a o sitio na memoria

		jmp main ;come�a o programa na func main 
.org	0x02
		jmp int_int0
.org	0x04
		jmp	int_int1

.org	0x1E
		jmp int_tc0
.cseg

.org 0x46 ; estamos a deixar espa�o para adicionarmos mais codigo antes da execu��o do prog

table:

.db	zero,um,dois,tres,quatro,cinco,seis,sete,oito,nove

;------------------------------Inicializa��o----------------------------

inic:		
			;interrup----------------------------
			ldi	temp,0b11000000
			out	ddrd,temp
			out portd,temp

			ldi	temp,0b00001010	;fanlco ascendente
			sts	eicra,temp		;store direct to dat space

			ldi	temp,0b00000011	; activa os interupts 
			out	eimsk,temp

			sei					;activa os interrupts
			
			;timers--------------------------------
			

			ldi temp,124  ;1ms
			out ocr0,temp		; � o valor que maximo que o contador conta

			ldi	cnt_int,tempo1	;contador de 5ms

			clr temp  ; se tiver as 0 esta parado
			out tccr0,temp

			in r16,TIMSK	;activa a interrup�ao do tc0
			ori r16,0b00000010
			out timsk,r16
 

			;---------------------------------------



			ldi	zl,low(table*2)
			ldi zh,high(table*2)
			ldi	r22,9
			ldi r16,0b11000000;	0 quer dizer input e 1 out		
			ldi	r17,0b11111111
			ldi	r28,0b11111111
			ldi	r29,0b01111111
			out DDRD,r16		;define que parte � entrada e saida 1 � saida 	
			out	DDRC,r17		
			out DDRA,r17
			out	PORTC,r17  ;desliga os leds do display
			out	PORTD,r16  ; 0 desliga os pull ups  � preciso defenir os 2 ultimos bits como 11 para acender o display da esquerda
			out PORTA,r28
			ldi r29,0b00000000
			ldi	contador,0b00000000	;nove

			ret					; Indica o fim da fun�ao e vai pra a linha assegir de Call inic



;---------------------------Programa Principal--------------------------



main:		

			ldi		r16,0xff			;Deste modo escreve na ram de baixo para cima .  spl e sph servem para escrever o endere�o 0x10ff num sistema em que so temos 8bits. 
			out		spl,r16
			ldi		r16,0x10
			out		sph,r16
			call	inic				; � como se fosse uma fun�ao vai para a primeira linha do inic  						
			





cicloini0:	

			
			
		
			jmp		cicloini0


numerosv2:			
			add		zl,contador		;soma o numero que se vai querer colocar no display 			
			lpm		display,z		;vai ao local da memoria e carrega o o valor que la estiver
			out		PORTC,display	;
			ldi		zl,low(table*2) ; COLOCA O APONTADOR DA MEMORIA EM ZERO	
			ret	



int_int0:
	
			ldi temp,0b00001101
			out tccr0,temp
			
			
			
			
			out			PORTA,r29

			
			reti



int_int1:
		
			ldi temp,0
			out tccr0,temp ; vamos querer o temporisador a trabalhar na mesma 
			; temos de fazer piscar usnado um delay 3 s
			;sbiw x decrementa uma word 
			


			out			PORTA,r17
			reti


int_tc0:
			dec		cnt_int
			brne	f_int			; verifica se � 0
			ldi		cnt_int,tempo1

			call	numerosv2

			cpi		contador,9
			breq	reset
			

			inc		contador
			sei
			jmp		cicloini0
			;set					;activa a flag t escrever a qui o codigo

f_int:		
			reti

reset:		ldi	contador,0
			reti