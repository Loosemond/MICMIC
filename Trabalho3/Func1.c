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

volatile USARTRX_st rxUSART={0,0,0,0}; // inicializar varíavel
char transmit_buffer[10];

const unsigned char digitos[] = {0xc0, 0xf9 ,0xa4 ,0xb0 , 0x99 , 0x92 ,0x82 ,0xf8 ,0x80 ,0x90,0xff,0xBF};
volatile unsigned char dado,dado2;
volatile unsigned int _5ms,_500ms,var_disp;
unsigned int display[3];
volatile unsigned int flag,sentido,inverter[]={0,0},receber;
unsigned char switches,pc_in;

volatile unsigned int _5ms;

/////Prototipo das funções//////
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
//-------------USART--------------
	UBRR1H=0; //0b0001
	UBRR1L=207; //0b10100000;
	UCSR1A=(1<<U2X1);
	UCSR1B=(1<<RXCIE1)|(1<<RXEN1)|(1<<TXEN1); //recepção, transmissão e interrupção recepção
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
				sprintf(transmit_buffer,"Tecla: %c/r\n", rxUSART.receiver_buffer);
				send_message(transmit_buffer);
			}
			rxUSART.receive=0;
		} 
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
	
	_5ms=0;
	inverter[0]=0;
	flag = 0;
	dado = 0;
	
	PORTC = digitos[dado];
	unsigned char SysStatus=0;//0-ready 1-running 2-results
	SysStatus=1;
	unsigned char DisplayStatus=1;
    /* Replace with your application code */
    while (1) 
    {
		//receive();
		
		if (rxUSART.receive == 1) //verifica se existe novos dados recebidos
		{
			if (rxUSART.error == 1) //verificar se existe erro
			{
				//para tratar erros
				rxUSART.error = 0;
			}
			else
			{
				pc_in = rxUSART.receiver_buffer;
				sprintf(transmit_buffer,"Tecla: %c/r\n", rxUSART.receiver_buffer);
				send_message(transmit_buffer);
			}
		}
		
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
		switches = PINA & 0b00111111;
		switch(switches)
		{
			case 0b00111110:
			escolhe_dig(25);
			OCR2=255*0.25;
			inverter[0]=2;
			//TCCR02 = 0b00001111;
			break;
			
			case 0b00111101:
			escolhe_dig(50);
			inverter[0]=2;
			OCR2=255*0.5;
			break;	
			case 0b00111011:
			escolhe_dig(70);
			OCR2=255*0.7;
			inverter[0]=2;
			break;
			case 0b00110111:
			escolhe_dig(90);
			OCR2=255*0.9;
			inverter[0]=2;
			break;
			case 0b00101111:
			if (sentido==0 && inverter[0]==0)
			{
				inverter[0]=1; // serve para n se carregar mais que uma vez no butao 
				inverter[1]=100;
				display[2]=11;
				sentido=1;
				PORTB=0b00000000; //parar
				break;
			}
			if(sentido==1 && inverter[0]==0)
			{
				inverter[0]=1; 
				inverter[1]=100;
				display[2]=10;
				PORTB=0b00000000; //parar
				sentido=0;
			}
			break;
			
			case 0b00011111:     // escrever codigo para ter um delay de modo a n se poder iniciar logo a marcha !!!!!!!!!!
			display[0]=10;
			display[1]=10;
			display[2]=10;
			//escolhe_dig(12);
			//display[]=10;
			PORTB=0b00000000;
			sentido=0;
			//inverter[0]=2 //para dar reset ao sentido de rotação do motor 
			break;
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
}

ISR(USART1_RX_vect)
{
	rxUSART.status = UCSR1A; //guardar flags
	
	if ( rxUSART.status & ((1<<FE1) | (1<<DOR1) | (1>> UPE1))) //verificar erros na recepção
		rxUSART.error = 1;
	rxUSART.receiver_buffer = UDR1;
	rxUSART.receive = 1; 
}
