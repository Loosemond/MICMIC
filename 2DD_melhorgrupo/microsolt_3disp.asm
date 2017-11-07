;

; 2DD_melhorgrupo.asm

;

; Created: 27/09/2017 08:30:19

; Author : IEEE

;





; Replace with your application code

.include <m128def.inc>
.def		timer2 = r23
.def		timer3 = r24
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

.equ        ap	= 0xff

.equ		delay	=200 ;mudar para 100

.cseg ; reset de vector

.org 0x0 ;defina a o sitio na memoria

		jmp main ;começa o programa na func main 
.org	0x02
		jmp int_int0
.org	0x04
		jmp	int_int1

.org	0x1E
		jmp int_tc0
.cseg

.org 0x46 ; estamos a deixar espaço para adicionarmos mais codigo antes da execução do prog

table:

.db	zero,um,dois,tres,quatro,cinco,seis,sete,oito,nove,ap

;------------------------------Inicialização----------------------------

inic:		
			;interrupt----------------------------
			ldi	temp,0b11000000
			out	ddrd,temp
			out portd,temp

			ldi	temp,0b00001010	;fanlco ascendente
			sts	eicra,temp		;store direct to dat space

			ldi	temp,0b00000011	; activa os interupts 
			out	eimsk,temp

			sei					;activa os interrupts
			
			;timers--------------------------------
			

			ldi temp,24  ;1ms mudar para 124
			out ocr0,temp		; é o valor que maximo que o contador conta

			ldi	cnt_int,tempo1	;contador de 5ms

			clr temp  ; se tiver as 0 esta parado
			out tccr0,temp

			in r16,TIMSK	;activa a interrupçao do tc0
			ori r16,0b00000010
			out timsk,r16
 			ldi		temp,0b00001101
			out		tccr0,temp
			bset		6

			;---------------------------------------



			ldi	zl,low(table*2)
			ldi zh,high(table*2)
			;ldi xh,high(1) ;3segundos
			;ldi xl,low(1)
			ldi	xl,00 ; o x representa o contador!
			ldi	xh,0x10
			ldi	yl,0x20
			ldi	yh,0x10

			ldi r19,0b11000000
			st  y+,r19  ; vai guardar qual display tou a usar serve para ter a ordem certa.
			ldi r19,0b10000000
			st  y+,r19
			ldi r19,0b01000000
			st  y+,r19
			ldi	yl,0x20 ;reset ao ponteiro y
			

			ldi	r22,9
			ldi r16,0b11000000;	0 quer dizer input e 1 out		
			ldi	r17,0b11111111
			ldi	r28,0b11111111
			ldi	r29,0b01111111
			out DDRD,r16		;define que parte é entrada e saida 1 é saida 	
			out	DDRC,r17		
			out DDRA,r17
			out	PORTC,r17  ;desliga os leds do displa
			
			out	PORTD,r16  ; 0 desliga os pull ups  é preciso defenir os 2 ultimos bits como 11 para acender o display da esquerda
			out PORTA,r28
			ldi r29,0b00000000
			ldi	contador,0b00000000	
			ldi timer2,delay
			ldi	timer3,delay

			ret					; Indica o fim da funçao e vai pra a linha assegir de Call inic



;---------------------------Programa Principal--------------------------



main:		

			ldi		r16,0xff			;Deste modo escreve na ram de baixo para cima .  spl e sph servem para escrever o endereço 0x10ff num sistema em que so temos 8bits. 
			out		spl,r16
			ldi		r16,0x10
			out		sph,r16
			call	inic				; É como se fosse uma funçao vai para a primeira linha do inic  						
			
cicloini0:	
			
			jmp		cicloini0

numerosv2:		
			push	r24
			push	r22
			ldi		r22,0x20
			ldi		yl,0x20
			;vai mudar o display que mostramos :)	
			cpi		yl,0x21
			breq	reset5
tag1:		LD		r24,y+
			OUT		PORTD,r24
			out		PORTB,r24
			;------------
			add		zl,contador		;soma o numero que se vai querer colocar no display 			
			lpm		display,z		;vai ao local da memoria e carrega o o valor que la estiver
			out		PORTC,display	;
			ldi		zl,low(table*2) ; COLOCA O APONTADOR DA MEMORIA EM ZERO	
			pop		r22
			pop		r24
			ret	
int_int0:
			bclr	6 ; limpa a flag
			
			out			PORTA,r29			
			reti

int_int1:
		
			;ldi temp,0
			;out tccr0,temp ; vamos querer o temporisador a trabalhar na mesma 
			; temos de fazer piscar usnado um delay 3 s
			;sbiw x decrementa uma word 
			bset		6 ; activa a flag
			out			PORTA,r17
			reti

int_tc0:
			dec		cnt_int
			brne	f_int			; verifica se é 0
			ldi		cnt_int,tempo1

			call	numerosv2			
			brtc	salto1 ; caso nao tenha carregado para parar vai para o salto 1
			;dec     timer2
			;brne	reset3
			reti
			;set					;activa a flag t escrever a qui o codigo

salto1:		inc		contador

			cpi		contador,10
			breq	reset
			reti

f_int:		
			reti

reset5:		
			st		y,r22   ;rest do apontador
			jmp		tag1

reset:		ldi		contador,0
			reti

reset2:		ldi		contador,0
			ldi		xh,high(6) ;3segundos por 600
			ldi		xl,low(6)
			call	numerosv2
			reti

reset3:		push contador
			ldi	 contador,10		
			call numerosv2
			pop	contador
			dec timer3
			brne reset3
			reti
			
reset4:		ldi timer3,delay
			ldi timer2,delay
			reti
