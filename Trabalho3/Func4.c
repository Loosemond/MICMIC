/*
 * GccApplication1.c
 *
 * Created: 22/11/2017 07:34:12
 * Author : DEE
 */ 

#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdio.h>

typedef struct USARTRX
{
	char receiver_buffer;
	unsigned char status;			//reserve 1 byte
	unsigned char receive:	1;		//reserva 1 bit
	unsigned char error:	1;
}USARTRX_st;

volatile USARTRX_st rxUSART={0,0,0,0}; // inicializar var�avel
char transmit_buffer[35];

const unsigned char digitos[] = {0xc0, 0xf9 ,0xa4 ,0xb0 , 0x99 , 0x92 ,0x82 ,0xf8 ,0x80 ,0x90,0xff,0xBF};
volatile unsigned char dado,dado2;
volatile unsigned int _5ms,_500ms,var_disp,timer_motor;
unsigned char velo;
unsigned int display[3];
volatile unsigned int flag,sentido,inverter[]={0,0},receber;
unsigned char switches,pc_in;
const unsigned char motorpp[] = {0b00000001,0b00001001,0b00001000,0b00001100,0b00000100,0b00000110,0b00000010,0b00000011};
volatile unsigned int _5ms;
unsigned int passo,increm,posicao,direcaopp,reset_pos; // guarda o passo atual do motor
int flush = 0;
/////Prototipo das fun��es//////
void send_message(char *buffer);
////////////////////////////////

void port_select(unsigned int display)
{
	switch(display)
	{
		case 0:
		PORTA = 0b11000000;
		break;
		case 1:
		PORTA = 0b10000000;
		break;
		case 2:
		PORTA = 0b01000000;
		break;
	}
}

void escolhe_dig(unsigned char numero)
{
	if (numero<99)
	{	
		int contador=0;
		while (numero > 0) 
		{
			int digit = numero % 10;
			display[contador]=digit;
			contador+=1;
			numero/= 10;
		}
	}
}

/*void port_select2(display)
{
	if(display==0){PORTA=0b11000000;}
	if(display==1){PORTA=0b10000000;}
	if(display==2){PORTA=0b01000000;}
}*/

void instrucoes(void)
{
	sprintf(transmit_buffer," Motor passo a passo\r\n");
	send_message(transmit_buffer);
	transmit_buffer[0]=12; //limpa a consola
	send_message(transmit_buffer);
	sprintf(transmit_buffer,"Teclas:\r\n1- Half step  \r\n");
	send_message(transmit_buffer);
	sprintf(transmit_buffer,"2- Full step \r\n");
	send_message(transmit_buffer);
	sprintf(transmit_buffer,"R e L - Rotacao direita e esquerda \r\n");
	send_message(transmit_buffer);
	sprintf(transmit_buffer,"Z- Posicao 0 \r\n");
	send_message(transmit_buffer);
	sprintf(transmit_buffer,"S- Definir Z \r\n");
	send_message(transmit_buffer);
}


void inic(void)
{
	DDRB = 0b11100000;
	OCR2 = 128; //consegues regular a velocidade do motor
	TCCR2 = 0b01100011; // phase correct
	
	PORTB=0b00000000; //motor parado
	 
	DDRA = 0b11000000;
	PORTA = 0b11000000;
	DDRC = 0xff;
	PORTC = 0xff;
//----------motorPP--------------
	DDRE= 0b00001111;
//-------------USART--------------
	UBRR1H=0b0001; //0b0001
	UBRR1L=0b10100000; //0b10100000;
	UCSR1A=(1<<U2X1);
	UCSR1B=(1<<RXCIE1)|(1<<RXEN1)|(1<<TXEN1); //recep��o, transmiss�o e interrup��o recep��o
	UCSR1C=0b00000110;
//--------------------------------	
	OCR0 =77;//77
	//TCCR0 = 0b00000000;
	TIMSK |= 0b00000010;// deve ser das interrupts
	TCCR0 = 0b00001111;
	var_disp=0;
	SREG |= 0x80;
	sentido=0; // 0 quer dizer que vai rodar par o sentido dos ponteiros de relogio 
	display[0]=10;
	display[1]=10;
	display[2]=10;
//--------------------------
	flush=0; //responcavel por desativar a input do pc
	reset_pos=0;
}

void incre(void)
{
	while(PINA != 0b11111101)
	{
		
		if (dado < 9)
		{
			dado+=1;
			
		} else
			{
			dado = 0;
			}
	}
}

void receive(void)
{
		if (rxUSART.receive == 1) //verifica se existe novos dados recebidos
		{
			if (rxUSART.error == 1) //verificar se existe erro
			{
				//procedimento para tratar erros
				rxUSART.error = 0;
			} 
			else
			{
				pc_in = rxUSART.receiver_buffer;
				sprintf(transmit_buffer," %c/r", rxUSART.receiver_buffer);
				send_message(transmit_buffer);
			}
			rxUSART.receive=0;
		} 
}


int rodar_motorpp(int increm,int passo,int direcaopp)  // vai indicar que passo � que o motor tem de fazer 
{	
	if (direcaopp==1){

		if (passo == 7 && increm== 1){passo=0;}
		else if (passo == 7 && increm == 2){passo=1;}
		else if (passo == 6 && increm == 2 ){passo=1;}
		else
		{
			passo = passo + increm;
		}

	}else
	{	
		if (passo == 1 && increm == 2){passo=7;}
		else if (passo==0){passo= 7-increm;}	
		else {passo-=increm;}	
	}
	
	PORTE = motorpp[passo];
	return passo;
}

int posi_reset(int posicao) // vai verificar para que lado tem de rodar 
{
	int auto_rotate;
	if (posicao>20)
	{
		auto_rotate=0;
	}
	if (posicao<20)
	{
		auto_rotate=1;
	}
	return auto_rotate;
}

void send_message(char *buffer)
{
	unsigned char i=0;
	while(buffer[i]!='\0')
	{
		while((UCSR1A & 1<<UDRE1)==0);
		UDR1=buffer[i];
		i++;
	}
}

int main(void)
{
	inic();
	instrucoes();
	posicao=20;
	_5ms=0;
	inverter[0]=0;
	flag = 0;
	dado = 0;
	timer_motor=5;
	PORTC = digitos[dado];
	unsigned char SysStatus=0;//0-ready 1-running 2-results
	SysStatus=1;
	unsigned char DisplayStatus=1;
	sentido=0;
	passo=0; // soponho que o motor come�a no passo 0 		
    /* Replace with your application code */
	increm=2;// 1 half step 2 full
    while (1) 
    {
		//receive();
		
		if(inverter[0]==2)
		{
			inverter[0]=0;
			switch(sentido)
			{
				case 0:
				PORTB=0b01000000;  //esquerda <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< verificar o sntido
				break;
				case 1:
				PORTB=0b00100000; // direita
				break;
			}
		}
		
		if (rxUSART.receive == 1) //verifica se existe novos dados recebidos
		{
			if (rxUSART.error == 1) //verificar se existe erro
			{
				//para tratar erros
				rxUSART.error = 0;
			}
			else
			{	
				if (flush==0){
					pc_in = rxUSART.receiver_buffer;
				}
				
				//sprintf(transmit_buffer,"%c\r\n", rxUSART.receiver_buffer);
				//send_message(transmit_buffer);
				
				switch(pc_in)
				{
					case 'r' :
					if (timer_motor==5 && posicao<40){
						if (increm!=1 && posicao==39)
						{
							direcaopp=1;
							posicao+=1;
							timer_motor=0;
							passo=rodar_motorpp(increm,passo,direcaopp);
							
						}else{
							direcaopp=1;
							posicao+=increm;
							timer_motor=0;
							passo=rodar_motorpp(increm,passo,direcaopp);

						}
							//sprintf(transmit_buffer," %d  \r\n", posicao);
							//send_message(transmit_buffer);
					}
					
					break;
					
					case 'l':
					if (timer_motor==5 && posicao>0){
						
						if (increm!=1 && posicao==1)
						{
							
							direcaopp=0;
							posicao-=1;
							timer_motor=0;
							passo=rodar_motorpp(increm,passo,direcaopp);
							
							}else{
							direcaopp=0;
							posicao-=increm;
							timer_motor=0;
							passo=rodar_motorpp(increm,passo,direcaopp);
						}
							//sprintf(transmit_buffer," %d \r\n", posicao);
							//send_message(transmit_buffer);

					}
					break;
					
					case 's':
					posicao=20;
					break;
					
					case '2':
					increm=2;
					break;
					
					case '1':
					increm=1;
					break;

					case 'z':
					
					flush=1; // para a leitura de input
					reset_pos=1;
					//sprintf(transmit_buffer," %d \r\n", posicao);
					//send_message(transmit_buffer);
					break;
					
				}
				
			}
			rxUSART.receive=0;
		}
		

		if (reset_pos==1 && timer_motor==5 && posicao!=20)
		{
	
			if (posicao==19 || posicao==21){increm=1;}
			else{increm=2;}
			
			direcaopp=posi_reset(posicao);
			if (direcaopp==0){posicao-=increm;}
				else{posicao+=increm;}
				
			timer_motor=0;
			passo=rodar_motorpp(increm,passo,direcaopp);
		}else if (reset_pos==1 && posicao==20)
		{
			flush=0;
			reset_pos=0;
		}
		
		if(_5ms==1 )
		{
			_5ms=0;
			if (SysStatus == 1)
			{
				if (dado < 9)
				{
					dado+=1;
					
				}else
					{
					dado = 0;
					}
							

			if(DisplayStatus==1)
			{
				port_select(var_disp);
				PORTC = digitos[display[var_disp]]; // aqui mostra o display
			}
			}	
		}
	}
}



ISR(TIMER0_COMP_vect)
{
	_5ms=1;
	var_disp+=1;
	if (var_disp==3)
	{
		var_disp=0;
	}
	
	if (inverter[0]==1)
	{
		inverter[1]-=1;
		if (inverter[1]==0){inverter[0]=2;}
	}
	
	//timer do motor 
	if (timer_motor<5) // vai de 0 a 5
	{
		timer_motor+=1; // vai incrementar o timer 
	}
}

ISR(USART1_RX_vect)
{
	rxUSART.status = UCSR1A; //guardar flags
	
	if ( rxUSART.status & ((1<<FE1) | (1<<DOR1) | (1>> UPE1))) //verificar erros na recep��o
		rxUSART.error = 1;
	rxUSART.receiver_buffer = UDR1;
	rxUSART.receive = 1; 
}

