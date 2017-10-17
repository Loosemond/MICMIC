;

; 2DD_melhorgrupo.asm

;

; Created: 27/09/2017 08:30:19

; Author : IEEE

;





; Replace with your application code

.include <m128def.inc>





.def		display	= r19

.def		contador = r18	; muda o nome

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

		jmp main ;começa o programa na func main 

.cseg

.org 0x46 ; estamos a deixar espaço para adicionarmos mais codigo antes da execução do prog

table:

.db	zero,um,dois,tres,quatro,cinco,seis,sete,oito,nove

;------------------------------Inicialização----------------------------

inic:		

			ldi	zl,low(table*2)

			ldi zh,high(table*2)

			ldi	r22,0b00000000

			ldi r16,0b11000000;			

			ldi	r17,0b11111111

			ldi	r28,0b10111111

			ldi	r29,0b01111111

			out DDRD,r16		;define que parte é entrada e saida 1 é saida 	

			out	DDRC,r17		

			out DDRA,r17

			out	PORTC,r17  ;desliga os leds do display

			out	PORTD,r16

			out PORTA,r28

			

				

			ldi	contador,0b00001001	;nove

			

			ret					; Indica o fim da funçao e vai pra a linha assegir de Call inic



;---------------------------Programa Principal--------------------------

main:

			

			ldi		r16,0xff			;Deste modo escreve na ram de baixo para cima .  spl e sph servem para escrever o endereço 0x10ff num sistema em que so temos 8bits. 

			out		spl,r16

			ldi		r16,0x10

			out		sph,r16

			call	inic				; É como se fosse uma funçao vai para a primeira linha do inic  						

			jmp		numerosv2



cicloini0:	

			call	delaym	

			cpse	contador,r22

			jmp		ciclo	

			out		PORTA,r29
			
kapa:		
call	delaymax
out		PORTC,r17

			
			
			sbis	PIND,1
			jmp		sai
			call	delaymax
			call	numerosv2
			
		

			sbis	PIND,1
			jmp		sai
			jmp		kapa
			

ciclo:		

			sbis	PIND,0

			jmp		entra																	; se for igual vai para seq

			

			sbis	PIND,1

			jmp		sai						



			jmp		ciclo 

			

entra:		

			;bset	1

			cpi		contador,0b00000000 ; se nao houver carros 

			breq	ciclo			;se for igual salta

			call	delaym				;vai esperar 1ms e verifiacr outravez se o butao foi carregado

			sbis	PIND,0

			jmp		entra

					

			dec		contador

			jmp		numerosv2			

			jmp		cicloini0

					

sai:		

			cpi		contador,0b00001001

			breq	ciclo				;se for igual salta			

			call		delaym				;vai esperar 1ms e verifiacr outravez se o butao foi carregado

			sbis		PIND,1

			jmp		sai



			inc		contador

			out		PORTA,r28	

			jmp		numerosv2

					

			jmp		cicloini0					



numerosv2:	

						
			
			add		zl,contador		;soma o numero que se vai querer colocar no display 			

			lpm		display,z		;vai ao local da memoria e carrega o o valor que la estiver

			out		PORTC,display	;

			ldi		zl,low(table*2) ; COLOCA O APONTADOR DA MEMORIA EM ZERO	

			jmp		cicloini0	







delaym:						; da um atraso 

			push	r20

			push	r21

			push	r22



			ldi		r22,0		;z 14

cciclo0:		ldi		r21,14		;y

cciclo1:		ldi		r20,20	;x

cciclo2:		dec		r20

			brne	cciclo2

			dec		r21

			brne	cciclo1

			dec		r22

			brne	cciclo0

			pop		r22

			pop		r21

			pop		r20

			ret	


delaymax:						; da um atraso 

			push	r20

			push	r21

			push	r22



			ldi		r22,0		;z 0

ciclo0:		ldi		r21,200		;y 200

ciclo1:		ldi		r20,100		;x	100

ciclo2:		dec		r20

			brne	ciclo2

			dec		r21

			brne	ciclo1

			dec		r22

			brne	ciclo0

			pop		r22

			pop		r21

			pop		r20

			ret	

