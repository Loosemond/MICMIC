;

; 2DD_melhorgrupo.asm

;

; Created: 27/09/2017 08:30:19

; Author : IEEE

;





; Replace with your application code

.include <m128def.inc>




.def		meme		= r20
;.def		displayA	= r19
;.def		displayB	= r19
;.def		displayC	= r19
;.def		displayD	= r19

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
			;configurar os ponteiros da ram
			ldi	xl,00 ; o x representa o contador!
			ldi	xh,0x10
			ldi yl,0x04 ;representa o display
			ldi yh,0x10

			ldi	r22,0b00000000
			ldi r16,0b11110000;	0 quer dizer input e 1 out		
			ldi	r17,0b11111111
			ldi	r28,0b10111111
			ldi	r29,0b01111111
			out DDRD,r16		;define que parte é entrada e saida 1 é saida 	
			out	DDRC,r17		
			out DDRA,r17
			out	PORTC,r17  ;desliga os leds do display
			out	PORTD,r16  ; 0 desliga os pull ups  é preciso defenir os 2 ultimos bits como 11 para acender o display da esquerda
			out PORTA,r28
			ldi	meme,4
			ldi	contador,0b00001001	;nove
			ldi r29,9
			st	X+,r29
			st	X+,r29
			st	x+,r29
			st	x+,r29
			ldi	xl,00
			ret					; Indica o fim da funçao e vai pra a linha assegir de Call inic



;---------------------------Programa Principal--------------------------

main:		

			ldi		r16,0xff				;Deste modo escreve na ram de baixo para cima .  spl e sph servem para escrever o endereço 0x10ff num sistema em que so temos 8bits. 
			out		spl,r16
			ldi		r16,0x10
			out		sph,r16
			call	inic					; É como se fosse uma funçao vai para a primeira linha do inic  						
			

clini:		;jmp		fim					;linha so de teste
			ldi		contador,9
			cpi		meme,0					;verifica se ja se escolheu todos os numeros
			breq	FIM

ciclo:
			call	numerosv3

			brts	salto					;se a falg tiver limpa
			sbis	PIND,0					;verifi o botao
			jmp		STOP
salto:		sbic	PIND,0					;verifica se larguei o butao
			clt								;limpa a flag

			cpi		contador,0				;verificar se o contador chega a 0
			breq	clear
					
spot1:		st		x+,contador				;como meme = 4  quando sumar 4 vezes xl vai ficar 04 pois xl começa em 00
			cp		xl,meme					;verificar quando é que escreveu na memoria de todos os ecras
			breq	clear2	
			jmp		spot1	


																			
clo1:		dec		contador				;decresce
			jmp		ciclo
clear:
			ldi		contador,10				;da reset ao contador
			jmp		clo1

clear2:		ldi		xl,0					;da reset ao ponteiro da ram
			jmp		clo1

STOP:		dec		meme					;decrementa meme para poder selecionar um numero
			set								;ativa a t falg
			jmp		clini
			

FIM:		push	r16
			push	r17
			push	meme
			ldi		xl,0
			ldi		meme,4
			LD		r16,X+
check:		dec		meme
			cpi		meme,0
			breq	WIN
			LD		r17,X+
			cp		r16,r17
			breq	check

			pop		meme
			pop		r17
			pop		r16

			ldi		meme,4
loopF:		sbis	PIND,1
			jmp		clini
			call	numerosv3		; falta escrever algo para o ecra de preferencia dora do loop e talvez por um delay antes de se poder fazer restart
			jmp		loopf				; usar o temporisador dedicado para o delay




numerosv3:		; vai mostrar os numeros por ordem
			push	r16	
			push	contador
			ldi		r16,0b00010000
			clc		;limpa o carry		
nloop:		brcs	ndone
			out		PORTD,r16
			LD		contador,X+

			add		zl,contador		;soma o numero que se vai querer colocar no display 			
			lpm		contador,z		;vai ao local da memoria e carrega o o valor que la estiver
			out		PORTC,contador
			;call	delaym	;
			ldi		zl,low(table*2) ; COLOCA O APONTADOR DA MEMORIA EM ZERO	

			lsl		r16
			jmp		nloop

ndone:		ldi		xl,0
			pop		contador
			pop		r16
			ret	



win:		push	r20
			ldi		r21,0b00000000
			ldi		meme,4
			ldi		xl,0		
spot2:		st		x+,r21					;esta parte serve para escrever o que mostrar no ecra mudando a ram
			cp		xl,meme					
			brne	spot2	
			call	numerosv3
			jmp		loopf					;loop fial