;
; 2DD_melhorgrupo.asm
;
; Created: 27/09/2017 08:30:19
; Author : IEEE
;


; Replace with your application code
.include <m128def.inc>

.cseg ; reset de vector
.org 0x0 ;defina a o sitio na memoria
		jmp main ;começa o programa na func main 
.cseg
.org 0x46 ; estamos a deixar espaço para adicionarmos mais codigo antes da execução do prog
;------------------------------Inicialização----------------------------
inic:		ldi r16,0b11111111;
			ldi	r18,0b00000001
			ldi	r19,0b00000000
			out DDRC,r16		;DDRC índica nos que é o PORTC	
			out	PORTC,r16
			out DDRA,r19
			ret					; Indica o fim da funçao e vai pra a linha assegir de Call inic

;---------------------------Programa Principal--------------------------
main:
		
			ldi		r16,0xff			;Deste modo escreve na ram de baixo para cima .  spl e sph servem para escrever o endereço 0x10ff num sistema em que so temos 8bits. 
			out		spl,r16
			ldi		r16,0x10
			out		sph,r16


			call	inic				; É como se fosse uma funçao vai para a primeira linha do inic  
			

cicloini:		
			ldi		r16,0b11111111	; limpa os leds - faz reset
			out		PORTC,r16
			
ciclo:
			in		r17,PINA			;le PORTA para r16 ve se o botao foi carregado
			cpi		r17,0b11111110
			breq	seq

			jmp		ciclo ; fecha o cilco

seq:		
			call	delay					
			out		PORTC,r16
			
			in		r28,PINA
			cpi		r28,0b11011111
			breq	cicloini ; verifica se se carregou no botao para parar caso sim vai pra o inicio e limpa os leds

			lsl		r16
			brcc	clear	;verifica se o carry é 0 caso seja vai dar rest aos leds 		
			jmp		seq


clear:
			ldi		r16,0b11111111	; serve de reset para repetir a sequencia
			jmp		seq
delay:						; da um atraso 
			push	r20
			push	r21
			push	r22

			ldi		r22,21
ciclo0:		ldi		r21,255
ciclo1:		ldi		r20,248
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