
#include <string.h>
#include <stdio.h>

#include "xtmrctr.h"
#include "microblaze_exceptions_g.h"

#include "platform.h"
#include "xil_types.h"
#include "xil_assert.h"
#include "xgpio.h"

#include <FreeRTOS.h>
#include "task.h"
#include "timers.h"
#include "queue.h"
#include "semphr.h"
#include "croutine.h"

#include "can_cmd.h"
#include "can_freertos.h"
//#include "FreeRTOS_mb_hooks.h"
void mt_1(void *pvParameters);
void mt_2(void *pvParameters);
void mt_3(void *pvParameters);

//void print(char *str);

#define LED_DEV_ID      XPAR_GPIO_0_DEVICE_ID   //LED ID
#define LED_Channel   1
//#define INIT_TASK_PRIORITY	( tskIDLE_PRIORITY )
//#define MIKE_STACK_SIZE     (1024U)
//#define MIKE_STACK_SIZE     (256U)
XGpio    led_gpio; // LED instance
uint8_t flash = 0x00;
static canmsg_t	candata;

int main()
{
    init_platform();
    XGpio_Initialize(&led_gpio, LED_DEV_ID);
    XGpio_SetDataDirection(&led_gpio, LED_Channel, 0x00);
    XGpio_DiscreteWrite(&led_gpio, LED_Channel, 0x0);

    //vApplicationSetupTimerInterrupt();
//    my_timer_continuos_start();
    microblaze_enable_interrupts();
    microblaze_enable_exceptions();

    //can_init();

    //for( u8 i=0; i<8; i++ ) {candata.data.dU8[i] = i;}
    candata.data.dU8[0] = 0;
    candata.data.dU8[1] = 1;
    candata.data.dU8[2] = 2;
    candata.data.dU8[3] = 3;
    candata.data.dU8[4] = 4;
    candata.data.dU8[5] = 5;
    candata.data.dU8[6] = 6;
    candata.data.dU8[7] = 7;
    candata.arbcode = 0x11;
    candata.dlc = 8;
    //can_send_msg(&candata, 0);


    xTaskCreate( mt_1, ( const char * )"MT_1", 256, NULL, 1, NULL );
    xTaskCreate( mt_2, ( const char * )"MT_2", 256, NULL, 1, NULL );
    xTaskCreate( mt_3, ( const char * )"MT_2", 256, NULL, 1, NULL );
    vTaskStartScheduler();

    while(1)
    {
    		//
    }
    return 0;
}

void mt_1(void *pvParameters){
	//volatile unsigned long ul;
	for(;;){
		//vTaskDelay(1);
		flash ^= 0x01;
		XGpio_DiscreteWrite(&led_gpio, LED_Channel, flash);
		vTaskDelay(100);
	}
	vTaskDelete(NULL);
}
void mt_2(void *pvParameters){
	//volatile unsigned long ul;
	for(;;){
		//printf("hello");
		//vTaskDelay(1);
		flash ^= 0x02;
		XGpio_DiscreteWrite(&led_gpio, LED_Channel, flash);
		vTaskDelay(100);
		//flash ^= 0x02;
		//XGpio_DiscreteWrite(&led_gpio, LED_Channel, flash);
		//for( ul = 0; ul < 4000L; ul++ )	{	}
	}
	vTaskDelete(NULL);
}

void mt_3(void *pvParameters){
	//volatile unsigned long ul;
	for(;;){
		//vTaskDelay(1);
		flash ^= 0x04;
		XGpio_DiscreteWrite(&led_gpio, LED_Channel, flash);
		vTaskDelay(100);
	}
	vTaskDelete(NULL);
}
