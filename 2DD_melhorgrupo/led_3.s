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
;------------------------------Inicialização----------------------------
inic:		ldi r16,0b11000000;			
			ldi	r17,0b11111111
			
			out DDRD,r16		;define que parte é entrada e saida 1 é saida 	
			out	DDRC,r17		
			out DDRA,r17
			out	PORTC,r17  ;desliga os leds do display
			out	PORTD,r16
			out PORTA,r17
				
			ldi	contador,0b00001001	;nove
			
			ret					; Indica o fim da funçao e vai pra a linha assegir de Call inic

;---------------------------Programa Principal--------------------------
main:
		
			ldi		r16,0xff			;Deste modo escreve na ram de baixo para cima .  spl e sph servem para escrever o endereço 0x10ff num sistema em que so temos 8bits. 
			out		spl,r16
			ldi		r16,0x10
			out		sph,r16


			call	inic				; É como se fosse uma funçao vai para a primeira linha do inic  


			
					

			jmp		numeros

cicloini:	sbrc	r16,0
			sbrc	r16,1
			jmp		cicloini2
cicloini2:	call    delaym	
			sbrc	r16,0
			sbrc	r16,1
			jmp		ciclo
ciclo:		

			in		r16,PIND
			sbrs	r16,0
			jmp		entra																	; se for igual vai para seq
			
			sbrs	r16,1
			jmp		sai						

			jmp		ciclo 
			

			
entra:		cpi		contador,0b00000000
			breq	ciclo				;se for igual salta
			
			;call		delaym				;vai esperar 1ms e verifiacr outravez se o butao foi carregado
			in		r16,PINA
			sbrs	r16,0
			jmp		ciclo
					
			dec		contador
			jmp		numeros			
			jmp		cicloini
					
sai:		cpi		contador,0b00001001
			breq	ciclo				;se for igual salta
			
			;call		delaym				;vai esperar 1ms e verifiacr outravez se o butao foi carregado
			in		r16,PINA
			sbrs	r16,1
			jmp	ciclo

			inc		contador
			jmp		numeros			
			jmp		cicloini					

numeros:	
			cpi		contador,0
			breq	numero0	
			cpi		contador,1
			breq	numero1
			cpi		contador,2
			breq	numero2	
			cpi		contador,3
			breq	numero3	
			cpi		contador,4
			breq	numero4	
			cpi		contador,5
			breq	numero5	
			cpi		contador,6
			breq	numero6	
			cpi		contador,7
			breq	numero7	
			cpi		contador,8
			breq	numero8	
			cpi		contador,9
			breq	numero9	

numero0:	ldi		display,zero
			out		PORTC,display
			jmp		ciclo	

numero1:	ldi		display,um
			out		PORTC,display
			jmp		ciclo	

numero2:	ldi		display,dois
			out		PORTC,display
			jmp		ciclo	

numero3:	ldi		display,tres
			out		PORTC,display
			jmp		ciclo	

numero4:	ldi		display,quatro
			out		PORTC,display
			jmp		ciclo	

numero5:	ldi		display,cinco
			out		PORTC,display
			jmp		ciclo	

numero6:	ldi		display,seis
			out		PORTC,display
			jmp		ciclo	

numero7:	ldi		display,sete
			out		PORTC,display
			jmp		ciclo	

numero8:	ldi		display,oito
			out		PORTC,display
			jmp		ciclo	

numero9:	ldi		display,nove
			out		PORTC,display
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


