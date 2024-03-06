/*
 * main.c
 *
 *  Created on: Jan 24, 2024
 *      Author: MYunoshev
 */
#include <stdint.h>;
#include <stdio.h>;
#include "xparameters.h";

#define ddd *((volatile uint32_t *)(XPAR_MIKE_IP_0_BASEADDR))
int main(void){
uint32_t temp = 0;
uint8_t i;
	while(1){

		temp = ddd;
		if(temp) for(i = 0; i < 100; i++) {}

	}
}
