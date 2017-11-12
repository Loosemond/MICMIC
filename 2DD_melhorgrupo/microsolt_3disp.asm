;

; 2DD_melhorgrupo.asm

;

; Created: 27/09/2017 08:30:19

; Author : IEEE

;





; Replace with your application code

.include <m128def.inc>
.def		timer2 = r24
.def		timer3 = r23
.def		cnt_int= r20
.def		flag=r3
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

							;activa os interrupts
			
			;timers--------------------------------
			

			ldi temp,4  ;1ms mudar para 124
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
			;------RAM--------------------------------------------
			ldi	zl,low(table*2)
			ldi 	zh,high(table*2)
			;ldi xh,high(1) ;3segundos
			;ldi xl,low(1)
			ldi	xl,01 ; o x representa o contador!
			ldi	xh,0x10
			ldi	yl,0x20	; o y representa o ecra
			ldi	yh,0x10

			ldi 	r19,0b11000000  ;mudar para  11
			st  	y+,r19  ; vai guardar qual display tou a usar serve para ter a ordem certa.
			ldi 	r19,0b10000000;10
			;ldi	r19,0
			st  	y+,r19
			ldi 	r19,0b01000000 ;01
			st 	y+,r19
			;--------local onde guardo o valor que apresento em cada digito
			ldi	yl,0x20 ;reset ao ponteiro y
			ldi	r19,0			
			st	x+,r19	;fica tudo a zero
			st	x+,r19
			st	x+,r19			
			;---------Memoria que indica se é para incrementar ou nao
			ldi	xl,0x1d
			ldi	r19,1 ; 1 representa que é para incrementar
			st	x+,r19
			st	x+,r19
			ldi	r19,1
			st	x,r19
			
			;--------
			ldi	xl,00 ; reset do ponteiro

			;-----------------------------------------------------------------------
			ldi	r22,9
			ldi 	r16,0b11100000;	0 quer dizer input e 1 out		MUDAR PARA 11000000
			ldi	r17,0b11111111
			;ldi	r28,0b11111111
			ldi	r17,0b01111111
			out 	DDRD,r16		;define que parte é entrada e saida 1 é saida 	
			out	DDRC,r17		
			out 	DDRA,r17
			out	PORTC,r17  ;desliga os leds do displa
			
			out	PORTD,r16  ; 0 desliga os pull ups  é preciso defenir os 2 ultimos bits como 11 para acender o display da esquerda
			out 	PORTA,r17
			ldi 	r17,0b00000000
			ldi	contador,0b00000000	
			ldi 	timer2,delay
			ldi	timer3,delay
			ldi 	r16,0b00000001
			mov	r3,r16
			
		
			sei	
			ret					; Indica o fim da funçao e vai pra a linha assegir de Call inic



;---------------------------Programa Principal--------------------------



main:		

			ldi		r16,0xff			;Deste modo escreve na ram de baixo para cima .  spl e sph servem para escrever o endereço 0x10ff num sistema em que so temos 8bits. 
			out		spl,r16
			ldi		r16,0x10
			out		sph,r16
			call		inic				; É como se fosse uma funçao vai para a primeira linha do inic  						
			
cicloini0:	
			
			jmp		cicloini0
			;jmp		int_int0
numerosv3:		
			push		r16
			push		r22
			ldi		r22,0x20			
tag2:			cpi		yl,0x23
			breq		reset5
tag1:			LD		r16,y+
			OUT		PORTD,r16
			;------------
			sub		yl,r22 ; assim so uso um apontador
			LD		contador,y
			add		zl,contador		;soma o numero que se vai querer colocar no display 			
			lpm		display,z		;vai ao local da memoria e carrega o o valor que la estiver
			out		PORTC,display	;
			ldi		zl,low(table*2) ; COLOCA O APONTADOR DA MEMORIA EM ZERO	
			add		yl,r22
		
			pop		r22
			pop		r16
			ret	
int_int0:	
			push		r16
			mov		r16,flag
			
			cbr		r16,0b00000001			
			mov		flag,r16	
			pop		r16		
			reti

int_int1:
		
			;ldi temp,0
			
			
			push		r16
			mov		r16,flag
			sbr		r16,0b00000001
			mov		flag,r16
			pop		r16
			reti

int_tc0:	
			dec		cnt_int
			brne		f_int			; verifica se é 0
			ldi		cnt_int,tempo1
			
			call		numerosv3	
			push		r22
			mov		r22,flag
			sbrs		r22,0
			call		incre			 
			pop		r22		
			;brtc	salto1 ; caso nao tenha carregado para parar vai para o salto 1
			;dec     timer2
			;brne	reset3
			reti
			;set					;activa a flag t escrever a qui o codigo

salto1:		
			;-------------incrementa---------------
incre:			;pop		r22;VEM DE TRAS
			push		r16
			push		r17
			push		r18
			ldi		r18,0			;serve para n ter de escrever um codigo especial para o brne
			;---Verifica se é para incrementar			
			ldi		r17,0x4	;vai servir para apontar para o sitio certo pois eu estou a apontar para 0x20 mas quero apontar para 0x1c
			sub		yl,r17			
			ld		r16,y

			cpi		r16,1	
			brne		skip0
			;----------
			;ldi		r17,4
			ldi		r18,0x1c	;quero apontar  para 0x00	
			sub		yl,r18			
			ld		r16,y
			inc		r16
			cpi		r16,10
			breq		increreset			
tag3:			st		y,r16
skip0:			add		r17,r18		; deste modo asseguro que acabom com o apontador em 0x20 pois se saltar so preciso de sumar 4 (r18 vai ser 0 logo isto da)			
			add		yl,r17
			pop		r18
			pop		r17
			pop		r16			
			ret

increreset: 		ldi		r16,0
			jmp		tag3


			
			;-------------------------------------------

f_int:		
			reti



reset5:		
			;st		y,r22   ;rest do apontador
			ldi		yl,0x20
			jmp		tag1

reset:			ldi		contador,0
			reti
reset6:

reset2:			ldi		contador,0
			ldi		xh,high(6) ;3segundos por 600
			ldi		xl,low(6)
			call		numerosv3
			reti

reset3:			push 		contador
			ldi		 contador,10		
			call 		numerosv3
			pop		contador
			dec 		timer3
			brne 		reset3
			reti
			
reset4:			ldi 		timer3,delay
			ldi 		timer2,delay
			reti
