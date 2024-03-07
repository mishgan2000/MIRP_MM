#include <stdint.h>;
#include <stdio.h>;
#include "xparameters.h";
#include "xgpio.h"
#include "crc.h"

void CalcCRC16(uint8_t c);
void delay(uint32_t del);

uint32_t DIP_Read = 100;
uint16_t temp = 0;
uint32_t *to_fpga;
uint16_t i = 0;
uint8_t t;
uint8_t dataByte[18];
//Duty_Cycle = *(uint32_t *)( XPAR_AXI_PWM_0_BASEADDR);//XPAR_AXI_PWM_0_BASEADDR
#define ddd *((volatile uint32_t *)(XPAR_AXI_PWM_0_BASEADDR))/*)*///XPAR_MY_CAN_LITE_0_BASEADDR

#define LED_DEV_ID      XPAR_GPIO_0_DEVICE_ID   //LED ID
#define LED_Channel   1

uint16_t adr, ax, ay, az, hx, hy, hz, v, temper, crc_2;
uint8_t crc_h, crc_l, j;
XGpio   led_gpio; // LED instance

int main(void){
	to_fpga = (uint32_t *)( XPAR_AXI_PWM_0_BASEADDR);//XPAR_AXI_PWM_0_BASEADDR
	temp = 0;

	XGpio_Initialize(&led_gpio, LED_DEV_ID);
	//XGpio_SetDataDirection(&led_gpio, LED_Channel, 0xC0);
	XGpio_SetDataDirection(&led_gpio, LED_Channel, 0xF8);


	while(1){
		adr = 0;
		XGpio_DiscreteWrite(&led_gpio, LED_Channel, 0x07);
		adr = (1 << 15) + 1;
		//adr += 1;
        j = 0;
		for(i = 0; i < 9; i++){
			*(to_fpga) = adr;
			*(to_fpga) = adr;
			temp = ddd;
			dataByte[j++] = (temp >> 8) & 0xFF;
			dataByte[j++] = temp & 0xFF;
			adr++;
		}
		adr &= ~(0x8000);
		*(to_fpga) = adr;
		*(to_fpga) = adr;
		XGpio_DiscreteWrite(&led_gpio, LED_Channel, 0x00);
//		*(to_fpga) = adr;
//		*(to_fpga) = adr;
//		dataByte[0] = (ddd >> 8)
//		//ax = ddd;
//		adr++;
//		*(to_fpga) = adr;
//		*(to_fpga) = adr;
//		//ay = ddd;
//		adr++;
//		*(to_fpga) = adr;
//		*(to_fpga) = adr;
//		//az = ddd;
//		adr ++;
//		*(to_fpga) = adr;
//		*(to_fpga) = adr;
//		//hx = ddd;
//		adr++;
//		*(to_fpga) = adr;
//		*(to_fpga) = adr;
//		//hy = ddd;
//		adr++;
//		*(to_fpga) = adr;
//		*(to_fpga) = adr;
//		//hz = ddd;
//		adr ++;
//		*(to_fpga) = adr;
//		*(to_fpga) = adr;
//		//temper = ddd;
//		adr++;
//		*(to_fpga) = adr;
//		*(to_fpga) = adr;
//		//v = ddd;
//		adr++;
//		*(to_fpga) = adr;
//		*(to_fpga) = adr;
//		//crc_2 = ddd;

        crc_h = dataByte[16];
        crc_l = dataByte[17];
        crc = 0;
		for (i = 0; i < 16; i++){
		   CalcCRC16(dataByte[i]);
		}
		if((((crc >> 8) & 0xFF) == crc_h)&&((crc & 0xFF) == crc_l))
			delay(1);
		else
			delay(2);
		//if((crc & 0xFF) == crc_l)
		//			delay(1);


		//*(to_fpga) = 1;
		//*(to_fpga) = 1;
		//*(to_fpga) = 1;
		//for(i = 0; i < 65535; i++){
		//		*(to_fpga) = i;
				//*(to_fpga) = i;
              //  delay(1);
		temp = 0;
        temp = ddd;
        if((temp & 2) == 0)
        	delay(1);
        //t = (temp >> 8) & 0xff;
        //if(t != temp)
        //	delay(1);
        //else
        //	delay(2);

		//}

	}
}
// ---------------------------------------------
void CalcCRC16(uint8_t c){
	uint16_t a;
	uint8_t	b;

	b = (crc ^ c) & 0xFF;
	a = crc16tab[b];
	//crc = ((uint16_t)((crc >> 8) ^ crc16tab[ (crc ^ c) & 0xFF ]));
	crc = ((uint16_t)((crc >> 8) ^ a));
}
//--------------------------------------------

void delay(uint32_t del){
   uint32_t a;
   for(a = 0; a < del; a++){

   }

}