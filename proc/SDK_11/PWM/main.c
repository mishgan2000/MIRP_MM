#include <stdint.h>;
#include <stdio.h>;
#include "xparameters.h";

uint32_t DIP_Read = 100;
uint32_t *Duty_Cycle;
//Duty_Cycle = *(uint32_t *)( XPAR_AXI_PWM_0_BASEADDR);//XPAR_AXI_PWM_0_BASEADDR

int main(void){
	Duty_Cycle = (uint32_t *)( XPAR_AXI_PWM_0_BASEADDR);//XPAR_AXI_PWM_0_BASEADDR
	*(Duty_Cycle) = DIP_Read << 8;
	 printf("hello");
	while(1){



	}
}


