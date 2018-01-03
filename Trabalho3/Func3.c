/*
 * GccApplication1.c
 *
 * Created: 22/11/2017 07:34:12
 * Author : DEE
 */ 

#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdio.h>
#include <stdint.h>
typedef struct USARTRX
{
	char receiver_buffer;
	unsigned char status;			//reserve 1 byte
	unsigned char receive:	1;		//reserva 1 bit
	unsigned char error:	1;
}USARTRX_st;

volatile USARTRX_st rxUSART={0,0,0,0}; // inicializar varíavel
char transmit_buffer[40];

const unsigned char digitos[] = {0xc0, 0xf9 ,0xa4 ,0xb0 , 0x99 , 0x92 ,0x82 ,0xf8 ,0x80 ,0x90,0xff,0xBF};
volatile unsigned char dado,dado2;
volatile unsigned int _5ms,_500ms,var_disp,velo;
uint32_t velo_2;
unsigned int display[3],modo_digital;
volatile unsigned int flag,sentido,inverter[]={0,0},receber;
unsigned char switches,pc_in;

volatile unsigned int _5ms;

/////Prototipo das funções//////
void send_message(char *buffer);
void teclado(char pc_in);
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
	if (numero<10) {display[1]=10;}
	if (numero<=99)
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
	UBRR1H=0b0001; //0b0001
	UBRR1L=0b10100000; //0b10100000;
	UCSR1A=(1<<U2X1);
	UCSR1B=(1<<RXCIE1)|(1<<RXEN1)|(1<<TXEN1); //recepção, transmissão e interrupção recepção
	UCSR1C=0b00000110;
//---------Conversor--------------

ADMUX = 0b00000000; // AREF, ajustado direita, canal 0
ADCSRA = 0b10000111; // ADEN, 1/128
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

int ler_AD(void)
{
	unsigned char leituraL, leituraH;
	
	ADCSRA = ADCSRA | 0b01000000; //(ADSC = 1)  avisa que é para ler o valor
	
	while ((ADCSRA & (1<<ADSC)) !=0); //esperar ADSC=0 // espera que o valor seja lido
	leituraL= ADCL;		// guarada o valor
	leituraH = ADCH;
	return (leituraH<<8) + leituraL;
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

void instrucoes(void)
{	
	sprintf(transmit_buffer," Modo digital\r\n");
	send_message(transmit_buffer);
	transmit_buffer[0]=12; //limpa a consola
	send_message(transmit_buffer);
	sprintf(transmit_buffer,"Teclas 1,2,3,4 mudam a velocidade \r\n");
	send_message(transmit_buffer);
	sprintf(transmit_buffer,"i - Inverte \r\n");
	send_message(transmit_buffer);
	sprintf(transmit_buffer,"c - Mostra o duty cicle \r\n");
	send_message(transmit_buffer);
	sprintf(transmit_buffer,"p - Para o motor \r\n");
	send_message(transmit_buffer);
	sprintf(transmit_buffer,"a,d - Trocam de modo \r\n");
	send_message(transmit_buffer);
}

void modo_analogico(void)
{
	sprintf(transmit_buffer," Modo Analogico\r\n");
	send_message(transmit_buffer);
	transmit_buffer[0]=12; //limpa a consola
	send_message(transmit_buffer);

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
	modo_digital=1;
	SysStatus=1;
	unsigned char DisplayStatus=1;
    /* Replace with your application code */
	instrucoes();
    while (1) 
    {
		if (modo_digital==0)
		{
			velo_2 = ler_AD();
			velo_2 =(velo_2*100)/1023;
			OCR2=2.55*velo_2;
			escolhe_dig(velo_2);
			inverter[0]=2;
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
// 		sprintf(transmit_buffer,"%u\r\n", velo_2);
// 		send_message(transmit_buffer);
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
// 				sprintf(transmit_buffer,"%c\r\n", pc_in);
// 				send_message(transmit_buffer);

				if (pc_in=='d'){modo_digital=1;instrucoes();}
				if (pc_in=='a'){modo_digital=0;modo_analogico();}			
				if (modo_digital==1){teclado(pc_in);}// codigo responsavel por intrepertar as teclas			
			}
			rxUSART.receive=0;
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

void teclado(char pc_in)
{
	switch(pc_in)
	{
		case 49:
		escolhe_dig(25);
		velo=25;
		OCR2=255*0.25;
		inverter[0]=2;
		//TCCR02 = 0b00001111;
		break;
		
		case 50:
		escolhe_dig(50);
		velo=50;
		inverter[0]=2;
		OCR2=255*0.5;
		break;
		
		case 51:
		velo=70;
		escolhe_dig(70);
		OCR2=255*0.7;
		inverter[0]=2;
		break;
		
		case 52:
		velo=90;
		escolhe_dig(90);
		OCR2=255*0.9;
		inverter[0]=2;
		break;
		
		case 105:
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
		
		case 112:     // escrever codigo para ter um delay de modo a n se poder iniciar logo a marcha !!!!!!!!!!
		display[0]=10;
		display[1]=10;
		display[2]=10;
		velo=0;
		//escolhe_dig(12);
		//display[]=10;
		PORTB=0b00000000;
		sentido=0;// faco reset ao sentido
		//inverter[0]=2 //para dar reset ao sentido de rotação do motor
		break;
		
		case 99:
		//velo=(OCR2/255)*100;
		if (sentido==0)
		sprintf(transmit_buffer,"Duty Cycle: %d\r\n",velo );
		else
		sprintf(transmit_buffer,"Duty Cycle:-%d\r\n",velo );
		send_message(transmit_buffer);
		break;
		
	}

}