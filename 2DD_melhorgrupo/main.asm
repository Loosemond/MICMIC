;
; 2DD_melhorgrupo.asm
;
; Created: 27/09/2017 08:30:19
; Author : IEEE
;


; Replace with your application code
.include <m128def.inc>

;.cseg ; reset de vector
;.org 0x0 ;defina a o sitio na memoria
		jmp main ;começa o programa na func main 
;.cseg
;.org 0x46 ; estamos a deixar espaço para adicionarmos mais codigo antes da execução do prog
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
		andi	r16,0b00000001		; ??	
		cpi		r16,0b00000001		; Compara o que esta em r16 com o valor que colocamos  se for igual salta a linha.

		brne	fim					;

		cbi		PORTC,3				; Coloca o porta A3 em 0
		cbi		PORTC,4

		jmp		ciclo

fim:	
		sbi		PORTC,3 ; Coloca a porta A3  a 1
		sbi		PORTC,4 ;
		
		

		
			 
