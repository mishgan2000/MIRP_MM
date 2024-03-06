#include <stdint.h>;
#include <stdio.h>;
#include "xparameters.h";

#define ddd *((volatile uint32_t *)(XPAR_MIKE_IP_0_BASEADDR + 32))
int main(void){
uint32_t temp = 0, c0 = 0, c1 = 0, c2 = 0, c3 = 0;
uint8_t i;
	while(1){

		temp = (ddd & 0xFF);
		if(temp == 111)
			//c0++;
			for(i = 0; i < 111; i++) {}
		else if(temp == 222)
			//c1++;
			for(i = 0; i < 222; i++) {}
		else if(temp == 255)
			//c2++;
			for(i = 0; i < 30; i++) {}
		else if(temp == 256)
			//c3++;
			for(i = 0; i < 40; i++) {}


	}
}
