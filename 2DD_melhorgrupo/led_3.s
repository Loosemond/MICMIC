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
			
			out DDRD,r16		;define que parte é entrada e saida 1 é saida 	
			out	DDRC,r17		
			out DDRA,r17
			out	PORTC,r17  ;desliga os leds do display
			out	PORTD,r16
			out PORTA,r22
			
				
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

cicloini:	sbrc	r16,0
			sbrc	r16,1
			jmp		cicloini2
cicloini2:	call    delaym	
			sbrc	r16,0
			sbrc	r16,1
			jmp		ciclo
ciclo2
ciclo:		

			;in		r16,PIND
			sbis	PIND,1
			jmp		entra																	; se for igual vai para seq
			
			sbis	PIND,2
			jmp		sai						

			jmp		ciclo 
			

			
entra:		cpi		contador,0b00000000
			breq	ciclo				;se for igual salta
			
			;call		delaym				;vai esperar 1ms e verifiacr outravez se o butao foi carregado
			sbic	PIND,1
			jmp		ciclo
					
			dec		contador
			jmp		numerosv2			
			jmp		cicloini
					
sai:		cpi		contador,0b00001001
			breq	ciclo				;se for igual salta
			
			;call		delaym				;vai esperar 1ms e verifiacr outravez se o butao foi carregado
			sbic		PIND,2
			jmp		ciclo

			inc		contador
			jmp		numerosv2			
			jmp		cicloini					

numerosv2:	
						
			add		zl,contador		;soma o numero que se vai querer colocar no display 			
			lpm		display,z		;vai ao local da memoria e carrega o o valor que la estiver
			out		PORTC,display	;
			ldi		zl,low(table*2) ; COLOCA O APONTADOR DA MEMORIA EM ZERO	
			jmp		ciclo	



delaym:						; da um atraso 
			push	r20
			push	r21
			push	r22

			ldi		r22,240		;z 14
ciclo0:		ldi		r21,190		;y
ciclo1:		ldi		r20,190		;x
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


delaymax:						; da um atraso 
			push	r20
			push	r21
			push	r22

			ldi		r22,21
ciclo20:		ldi		r21,255
ciclo21:		ldi		r20,248
ciclo22:		dec		r20
			
			brne	ciclo2
			
		


			dec		r21
			brne	ciclo1

			

			dec		r22
	
			brne	ciclo0

			pop		r22
			pop		r21
			pop		r20
			ret	


