/*
 * GccApplication1.c
 *
 * Created: 22/11/2017 07:34:12
 * Author : DEE
 */ 

#include <avr/io.h>
#include <avr/interrupt.h>

const unsigned char digitos[] = {0xc0, 0xf9 ,0xa4 ,0xb0 , 0x99 , 0x92 ,0x82 ,0xf8 ,0x80 ,0x90,0xff,0xBF};
volatile unsigned char dado,dado2;
volatile unsigned int _5ms,_500ms,var_disp,display[] ={10,10,10};
volatile unsigned int flag,sentido,inverter[]={0,0};
unsigned char switches;

volatile unsigned int _5ms;

void port_select(display){
	switch(display){
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

void escolhe_dig(unsigned char numero){
	if (numero<99){
		int contador=0;
		while (numero > 0) {
			int digit = numero % 10;
			display[contador]=digit;
			contador+=1;
			numero/= 10;
		}
		
	}
	
}


//void port_select2(display){
//	if(display==0){PORTA=0b11000000;}
//	if(display==1){PORTA=0b10000000;}
//	if(display==2){PORTA=0b01000000;}
//}
void inic(void){
	DDRB = 0b11000000;
	OCR2 = 128
	TCCR2 = 0b01100011; // phase correct
	
	 
	DDRA = 0b11000000;
	PORTA = 0b11000000;
	DDRC = 0xff;
	PORTC = 0xff;
	
	
	OCR0 =77;//77
	TCCR0 = 0b00000000;
	TIMSK |= 0b00000010;// deve ser das interrupts
	TCCR0 = 0b00001111;
	var_disp=0;
	SREG |= 0x80;
	sentido=0; // 0 quer dizer que vai rodar par o sentido dos ponteiros de relogio 

}

void incre(void){
	while(PINA != 0b11111101){
		
		if (dado < 9){
			dado+=1;
			
			}else{
			dado = 0;
		}
	}
}



int main(void)
{
	inic();
	
	_5ms=0;
	inverter[0]=0;
	flag = 0;
	dado = 0;
	
	//PORTC = digitos[dado];
	unsigned char SysStatus=0;//0-ready 1-running 2-results
	SysStatus=1;
	unsigned char DisplayStatus=1;
    /* Replace with your application code */
    while (1) 
    {
		switches = PINA & 0b00111111;
		switch(switches){
			case 0b00111110:
			escolhe_dig(25);
			//TCCR02 = 0b00001111;
			break;
			
			case 0b00111101:
			escolhe_dig(50);
			break;	
			case 0b00111011:
			escolhe_dig(70);
			break;
			case 0b00110111:
			escolhe_dig(90);
			break;
			case 0b00101111:
			if (sentido==0 & inverter[0]==0){
				inverter[0]=1; // serve para n se carregar mais que uma vez no butao 
				inverter[1]=50;
				display[2]=11;
				sentido=1;
				break;
			}
			if(sentido==1 & inverter[0]==0){
				inverter[0]=1; 
				inverter[1]=50;
				display[2]=10;
				sentido=0;}
			
			break;
			
			case 0b00011111:
			display[0]=10;
			display[1]=10;
			display[2]=10;
			//escolhe_dig(12);
			//display[]=10;
			sentido=0;
			break;
		}
		
		
		
		if(_5ms==1 )
		{
			_5ms=0;
			if (SysStatus == 1){
				if (dado < 9){
					dado+=1;
					
					}else{
					dado = 0;
			}
							

			if(DisplayStatus==1)
				port_select(var_disp);
				PORTC = digitos[display[var_disp]]; // aqui mostra o display
	
		}	
    }
}
}



ISR(TIMER0_COMP_vect)
{
	_5ms=1;
	var_disp+=1;
	if (var_disp==3){
		var_disp=0;
	}
	
	if (inverter[0]==1){
		inverter[1]-=1;
		if (inverter[1]==0){inverter[0]=0;}
	}
	

}

