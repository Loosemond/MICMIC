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
inic:		ldi r16,0b11111111;		vai servir para configurar as saidas e as entradas, temos de escrever todas a portas do PORTA  de uma vez so dai temos 8.
			out DDRA,r16 ;			aqui é que se passa os valor em r16 para o PORTA ????

			;ldi r16,0b11111111; Vai indicar que os led tao desligados pois 1 representa off
			out DDRC,r16		;DDRC índica nos que é o PORTC


			ret						; Indica o fim da funçao e vai pra a linha assegir de Call inic

;---------------------------Programa Principal--------------------------
main:
		ldi		r16,0xff			;Deste modo escreve na ram de baixo para cima .  spl e sph servem para escrever o endereço 0x10ff num sistema em que so temos 8bits. 
		out		spl,r16
		ldi		r16,0x10
		out		sph,r16

		call	inic				; É como se fosse uma funçao vai para a primeira linha do inic  


						
ciclo:
		in		r16,PINA			;le PORTA para r16
		;andi	r16,0b00000001		; ??	
		;cpi		r16,0b00000001		; Compara o que esta em r16 com o valor que colocamos  se for igual salta a linha.

		;brne	fim					;


		;ldi		r16,0b00001000 ;  Liga o led 3 e o 4
		lsl		r16 ;vai para a esquerda 
		lsl		r16
		lsl		r16
		lsl		r16
		out		PORTC,r16
		;mov		r17,r16	; move os r

		
		call	inver
		add		r16,r18
		out		PORTC,r16
		;ror		r17	;roda para a direita
		;add		r16,r17
		
		;out		PORTC,r16
		;ldi		r18,0b01000000
		;out		PORTC,r18
		;ror		r18
		;asr		r18
		;out		PORTC,r18

		jmp		ciclo

fim:	
		ldi		r16,0b00000000 ;  apaga todos os leds
		out		PORTC,r16
		
		jmp		ciclo
		



Inver:	
		ldi		r18,0b00000000
		bst		r16,0	;faz load do bit do r para T
		bld		r18,7	; escreve o bit de T em r18	
				
		bst		r16,1	
		bld		r18,6

		bst		r16,2	
		bld		r18,5

		bst		r16,3	
		bld		r18,4

		bst		r16,4	
		bld		r18,3

		bst		r16,5	
		bld		r18,2

		bst		r16,6	
		bld		r18,1

		bst		r16,7	
		bld		r18,0

		ret

inver2:
		