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

.equ		tempo1 =5;5

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

.equ        	ap	= 0xff
.equ		m_p1	= 0x1b
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
			

			ldi 	temp,124  ;1ms mudar para 124
			out 	ocr0,temp		; é o valor que maximo que o contador conta

			ldi	cnt_int,tempo1	;contador de 5ms

			;clr 	temp  ; se tiver as 0 esta parado
			;out 	tccr0,temp

			in 	r16,TIMSK	;activa a interrupçao do tc0
			ori 	r16,0b00000010
			out 	timsk,r16
			
			
 			ldi	temp,0b00001101
			out	tccr0,temp
			;bset		6
			;timer2
			;ldi	temp,0x09
			;out	ocrbl,temp
			;ldi	temp,0x3D
			;out	ocrbh,temp
			;clr 	temp  ;
			;out 	tccrnb,temp
			
			;in 	r16,TIMSK	;activa a interrupçao do tc0
			;ori 	r16,0b00000010
			;out 	timsk,r16
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
			ldi	yl,0x20 			;reset ao ponteiro y
			ldi	r19,0			
			st	x+,r19				;fica tudo a zero
			ldi	r19,10				;deste modo os displays ficam desligados
			st	x+,r19
			st	x+,r19			
			;---------Memoria que indica se é para incrementar ou nao
			ldi	xl,0x1d
			ldi	r19,1 				; 1 representa que é para incrementar
			st	x+,r19
			ldi	r19,0				;deste modo so incrementa o 1o
			st	x+,r19			
			st	x,r19
			;----------programa1(parar_dig)---------
			ldi	xl,m_p1
			ldi	r19,0x1d
			st	x,r19
			;---------------------------------------
			ldi	xl,00 				; reset do ponteiro

			;-----------------------------------------------------------------------
			ldi	r22,9
			ldi 	r16,0b11100000			;0 quer dizer input e 1 out		MUDAR PARA 11000000
			ldi	r17,0b11111111
			;ldi	r28,0b11111111
			ldi	r17,0b01111111
			out 	DDRD,r16			;define que parte é entrada e saida 1 é saida 	
			out	DDRC,r17		
			out 	DDRA,r17
			out	PORTC,r17  			;desliga os leds do displa
			
			out	PORTD,r16  			; 0 desliga os pull ups  é preciso defenir os 2 ultimos bits como 11 para acender o display da esquerda
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

			ldi		r16,0xff		;Deste modo escreve na ram de baixo para cima .  spl e sph servem para escrever o endereço 0x10ff num sistema em que so temos 8bits. 
			out		spl,r16
			ldi		r16,0x10
			out		sph,r16
			call		inic			; É como se fosse uma funçao vai para a primeira linha do inic  						
			
cicloini0:				
			jmp		cicloini0
			
numerosv3:		;--------display----------------------
			push		r16
			push		r22
			ldi		r22,0x20			
			cpi		yl,0x23
			breq		reset5
tag1:			LD		r16,y+
			OUT		PORTD,r16
			;----
			sub		yl,r22 			; assim so uso um apontador
			LD		contador,y
			add		zl,contador		;soma o numero que se vai querer colocar no display 			
			lpm		display,z		;vai ao local da memoria e carrega o o valor que la estiver
			out		PORTC,display		;
			ldi		zl,low(table*2) 	; COLOCA O APONTADOR DA MEMORIA EM ZERO	
			add		yl,r22		
			pop		r22
			pop		r16
			ret	
reset5:			ldi		yl,0x20
			jmp		tag1			
			;----------------------------------------
int_int0:	
			push		r16
			mov		r16,flag
			
			cbr		r16,0b00000001			
			mov		flag,r16	
			pop		r16		
			reti
int_int1:											
			push		r16			
			mov		r16,flag
			sbr		r16,0b00000010 ;se 0b00000001 para de contar		
			mov		flag,r16		;activa a flag1				
			call		parar_dig		
			pop		r16
			reti

parar_dig:		;---------------para um digito e mete outro a rolar---------
			push		r16
			push		r17
			push		r18
			mov		r18,yl						
			ldi		yl,m_p1			;m_p1 é onde guardo a posiçao da memoria que quero ler neste programa ou seja é uma variavel	
			ld		r16,y			;guardo um valor no r17			
			mov		yl,r16			;carrega o valor que estava guardado no m_p1 que era a posiçao de memoria guardada			
			ldi		r16,0			;desativa a contagem
			st		y+,r16			;aqui vai escrever de modo a que o display actual pare de contar e o seguinte se ligue e que começe a contar
			ldi		r16,1			;activa a contagem
			ldi		r17,0x20		;preciso de outro registo pois o cpse so compara se tiver 2 registos e como so da skip a uma linha nao dava pois preciso de fazer o ldi do r16 antes de fazer o ld
			cpse		yl,r17			;Aqui verifico se ja parei o 3 digito se sim entao nao é preciso escrever mais nada alias se deixar escrever ele vai escrever por cima da memoria que indica qual display representa o digito1
			st		y,r16			;indica que vai incrementar
			mov		r16,yl			;guardo a posiçao actual num registo
			ldi		yl,m_p1			;aponto para a variavel m_p1
			st		y,r16			;gravo na varivel m_p1 a posiçao em que fiquei neste cilco
			mov		yl,r18			;volata a apontar para a posiçao que tinha antes de entrar neste programa 
			pop		r18
			pop		r17
			pop		r16
			ret
			;-----------------------------------------------------------
int_tc0:	
			dec		cnt_int
			brne		f_int			; verifica se é 0
			ldi		cnt_int,tempo1		;rest ao contador de 5ms			
			call		numerosv3		;mostra os numeros
			push		r22
			mov		r22,flag
			sbrs		r22,0			;verifica se ja carregamos no butao para começar
			call		modo1					 
			pop		r22					
f_int:			reti
								
Modo1:			
			call		incre					
			ret
			;-------------incrementa---------------
incre:			;pop		r22;VEM DE TRAS
			push		r16
			push		r17
			push		r18
			ldi		r18,0			;serve para n ter de escrever um codigo especial para o brne
			;---Verifica se é para incrementar			
			ldi		r17,0x4			;vai servir para apontar para o sitio certo pois eu estou a apontar para 0x20 mas quero apontar para 0x1c
			sub		yl,r17			
			ld		r16,y

			cpi		r16,1	
			brne		skip0
			;----------
			;ldi		r17,4
			ldi		r18,0x1c		;quero apontar  para 0x00	
			sub		yl,r18			
			ld		r16,y
			inc		r16
			cpi		r16,10
			brge		increreset		; deste modo garanto que fasso reset ao numero mesmo que este seja maior que 10		
tag3:			st		y,r16
skip0:			add		r17,r18			; deste modo asseguro que acabo com o apontador em 0x20 pois se saltar so preciso de sumar 4 (r18 vai ser 0 logo isto da)			
			add		yl,r17
			pop		r18
			pop		r17
			pop		r16			
			ret

increreset: 		ldi		r16,0
			jmp		tag3			
			;-------------------------------------------