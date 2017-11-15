;

; 2DD_melhorgrupo.asm

;

; Created: 27/09/2017 08:30:19

; Author : IEEE

;





; Replace with your application code

.include <m128def.inc>
.def		leds	=r1
.def		timer2 = r24
.def		timer3 = r23
.def		cnt_int= r20
.def		flag=r3
.def		temp	= r25

.def		display	= r19

.def		contador = r18	; muda o nome

.equ		tempo1 =3;5

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
.equ		c_segH	=0x0f ;representa a variavel que contem os segundos
.equ		c_segL	=0x00
.equ		c_digiL =0x0f	;vai guardar o numero de fazes que falata parar de rodar o digito !
.equ		tempo_timer2=200

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

			ldi	temp,0b00000001	; activa os interupts 
			out	eimsk,temp

							;activa os interrupts
			
			;timers--------------------------------
			

			ldi 	temp,208  ;1ms mudar para 124  se repetir 208 3 vezes tb da 5ms
			out 	ocr0,temp		; é o valor que maximo que o contador conta

			ldi	cnt_int,tempo1	;contador de 5ms

			;clr 	temp  ; se tiver as 0 esta parado
			;out 	tccr0,temp

			in 	r16,TIMSK	;activa a interrupçao do tc0
			ori 	r16,0b00000010
			out 	timsk,r16
			
			
 			ldi	temp,0b00001101
			out	tccr0,temp
			
			;------RAM--------------------------------------------
reset_ram:		ldi	zl,low(table*2)
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
			ldi	r17,0b11111111
			out 	DDRD,r16			;define que parte é entrada e saida 1 é saida 	
			out	DDRC,r17		
			out 	DDRA,r17
			out	PORTC,r17  			;desliga os leds do displa
			
			out	PORTD,r16  			; 0 desliga os pull ups  é preciso defenir os 2 ultimos bits como 11 para acender o display da esquerda
			out 	PORTA,r17
			ldi 	r17,0b00000000
			ldi	contador,0b00000000	
			ldi 	timer2,tempo_timer2
			;ldi	timer3,delay
			ldi 	r16,0b00000001
			mov	r3,r16					
				
			ret					; Indica o fim da funçao e vai pra a linha assegir de Call inic


main:			;--------iniciaçao 1-----------

			ldi		r16,0xff		;Deste modo escreve na ram de baixo para cima .  spl e sph servem para escrever o endereço 0x10ff num sistema em que so temos 8bits. 
			out		spl,r16
			ldi		r16,0x10
			out		sph,r16
			call		inic			; É como se fosse uma funçao vai para a primeira linha do inic  
			sei			
  ;---------------------------Programa Principal--------------------------			
cicloini0:		
			mov 		r21,flag
			cpi		r21,0b10000000
			breq		main
			jmp		cicloini0
			;-------------------------------------
			
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
			;--------------------
fimmmmmmmmmmmmmm:	ldi		r16,0b10000000
			mov		flag,r16 
			pop		r16		
			reti
int_int0:		;----------interupçao do butao 0------
			push		r16
			mov		r16,flag
			cpi		r16,0b01000000
			breq		fimmmmmmmmmmmmmm
			cbr		r16,0b00000001		;apaga o bit 0 e activa o modo1		
			mov		flag,r16	
			ldi		r16,0b00000010		; activa o interrupt do int_int1 e esativa a deste
			out		eimsk,r16
			pop		r16		
			reti
int_int1:		;------------interrupçao do butao 1----									
			push		r16
			;push		r26
			;push		r27
			ldi		r16,0b00000000		; desativa as interrupts
			out		eimsk,r16
			mov		r16,flag
			sbr		r16,0b00000001 ;se 0b00000001 para de contar
			sbr		r16,0b00000010; assim para de ir para o modo 1
			mov		flag,r16		;activa a flag1				
			call		parar_dig		;remover talvez nao pq o primeiro para logo do os outros 2 é que demoram mais	
			ldi		r16,0b00000000	;desativa todas as interrupts
			out		eimsk,r16
			;vvvvv vai guardar e dividir o tempo vvvvv  
			;mov		timer2
			ldi		xh,c_segH		;vai apontar para o endereço que contem a variavel que conta o tempo em segundos
			ldi		xl,c_segL		;^^
			ld		r16,x+			;guarda o valor num registo
			cpi		r16,2			;aqui defino o tempo minimo <----t_min
			brlo		mt_rapido			;caso calhe o tempo ser menor que 8 (tentar 4) ele vai forçar 8
volta:			lsr		r16			;divide o tempo em dois
			st		x+,r16			;vai incrementar o ponteiro e depois guarda o valor do r16
			lsr		r16			;divide por 2 outra vez = a dividir por 4
			st		x,r16			;gaurada noutro espaço da memoria
			ldi		xh,c_segH		;vou forçar o ponteiro nesta posiçao para mais a frente poder eterar 
			ldi		xl,c_digiL		;assim tenho a certesa que nao paro mais de 2 vezes! 
			ldi		r16,2
			st		x,r16			;2 pois ja parei uma vez
			ldi		xl,c_segL		;^^ foi por isso que nao fiz push/pop desta vez
			inc		xl			;pois so quero os valores que sao divididos nao o inicial
			ldi		r16,0b11111110			;serve para ligar os leds
			mov		leds,r16
			out		porta,r16
			;pop		r27
			;pop		r26
			pop		r16
			reti
mt_rapido:		ldi		r16,8
			jmp		volta
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
int_tc0:		;---------timer0-------
			dec		cnt_int
			brne		f_int			; verifica se é 0
			ldi		cnt_int,tempo1		;rest ao contador de 5ms
			call		numerosv3		;mostra os numeros
			push		r22
			mov		r22,flag
			sbrs		r22,0			;verifica se ja carregamos no butao para começar
			call		modo1			; deste modo posso adicionar mais codigo 
			sbrc		r22,1			;verifica se carregei no stop
			call		modo2					 ;verificar se carreguei no outro butao!
			pop		r22					
f_int:			reti

segundo:		;-------codigo que conta segundos-----------------;0 incrementa 1 decrementa ->bit 2(a contar de 0) na flag(r3)
			push		r16
			push		r27 			;é o endereço x
			push		r26			;x
			
			ldi		xh,c_segH		;vai apontar para o endereço que contem a variavel que conta o tempo em segundos
			ldi		xl,c_segL
			ld		r16,x			;guarda o valor num registo
			mov		r26,flag		; r26 agora contem as flags tou a reutilizar registos pois assim poupo ciclos(devido ao push e pop) e ..registos
			sbrs		r26,2			;vai verificar se é para incrementar ou nao	caso o bit seja 0 ele vai incrementar e saltar o passo de decrementar mais a frente
			inc		r16			;incrementa pois assim conto os segundos que passaram
			sbrc		r26,2			;caso o bit teja a 1 quer dizer que é para decrementar e que seu skip ao inc
			dec		r16
			;breq		fim_contagem		;caso o contador va a 0 (verificar se isto ta correto) pois se der 0 ele vai saltar. e nunca vai ser 0 se incrementar
			ldi		r26,c_segL		;tenho de voltar a carregar pois escrevi a falg por cima
			st		x,r16			;finalmente grava o valor 
			
			pop		r26
			pop		r27
			pop		r16
			ret
								
Modo1:			dec		timer2			;este vai contar 1s
			breq		increm			;a cada 1 segundo vai saltar para a funçao segundo
			call		incre			;vai rolar os numeros				
			ret
increm:			;vai contar o tempo que o utilizador demorou a contar
			push		r16
			;---quero ter a certesa que vou incremnetar			
			mov		r16,flag			
			cbr		r16,0b00000100	; india que é para incrementar		
			mov		flag,r16
			ldi		timer2,tempo_timer2
			pop		r16							
			call		segundo			
			ret					;tem de tar aqui pois venho do modo1
			   
Modo2:			call		incre
			dec		timer2			;este vai contar 1s
			breq		decrem			;a cada 1 segundo vai saltar para a funçao segundo
			
			ret
decrem:			ldi		timer2,tempo_timer2;reset ao timer
			push		r16			
			ld		r16,x
			dec		r16
			breq		contador_digitos			;caso r16(tempo) chege a 0 vai parar o digito
			st		x,r16			;tenho de guardar senao isto nunca parava
			;pop		r17
			pop		r16
			ret
contador_digitos:	;vai saber quantos digitos faltam parar		
			
			inc		xl			;vai buscar o valor do tempo seguinte
			push		xl
			mov		r16,leds		;leds
			lsl		r16			;leds
			out		porta,r16
			mov		leds,r16
			call		parar_dig		;para de rolar o digito actual			
			ldi		xl,c_digiL		;vai ver quantos faltam
			ld		r16,x
			dec		r16
			breq		modo2_fim
			st		x+,r16				
			pop		xl
			pop		r16
			
			ret
modo2_fim:		;------aqui vaiter o codigo que vai fazer parar tudo			
			mov		r16,flag			
			;sbr		r16,0b00000001		;desativa o modo 1
			;cbr		r16,0b00000010
			ldi		r16,0b01000000
			mov		flag,r16			
			
			ldi		r16,0b00000001		; activa a interrupt do butao 0 
			out		eimsk,r16
			pop		xl
			pop		r16
			;call		reset_ram
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