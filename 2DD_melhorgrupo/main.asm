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
			ldi r17,0b00000000;

			ret						; Indica o fim da funçao e vai pra a linha assegir de Call inic

;---------------------------Programa Principal--------------------------
main:
		ldi		r16,0xff			;Deste modo escreve na ram de baixo para cima .  spl e sph servem para escrever o endereço 0x10ff num sistema em que so temos 8bits. 
		out		spl,r16
		ldi		r16,0x10
		out		sph,r16

		call	inic				; É como se fosse uma funçao vai para a primeira linha do inic  


						
ciclo:
		in		r17,PINA			;le PORTA para r16
		mov		r16,r17
				
		cpi		r17,0b00000001		; Compara o que esta em r16 com o valor que colocamos  se for igual salta a linha.						;						
		breq	inver2
		
		cpi		r17,0b00000010		
		breq	inver2
		
		cpi		r17,0b00000100		
		breq	inver2									
			
		cpi		r17,0b00001000		
		breq	inver2	
				
		cpi		r17,0b0010000		
		breq	clear
												
		jmp		ciclo			

clear:	
		ldi		r16,0b00000000 ;  apaga todos os leds serve para trocar o togle 
		out		PORTC,r16
		
		jmp		ciclo
		


Inver2:
		
		swap	r16 ; troca os primeiros 4 bits pelos ultimos 	

		bst		r16,4	;faz load do bit do r para T
		bld		r16,3	; escreve o bit de T em r18	

		bst		r16,5	
		bld		r16,2

		bst		r16,6	
		bld		r16,1

		
		bst		r16,7	
		bld		r16,0

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


		