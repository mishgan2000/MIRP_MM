
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
#include "can_cmd_defs.h"
#include "can_freertos.h"
//#include "FreeRTOS_mb_hooks.h"
void mt_1(void *pvParameters);
void mt_2(void *pvParameters);
void mt_3(void *pvParameters);

//void print(char *str);

#define LED_DEV_ID      XPAR_GPIO_0_DEVICE_ID   //LED ID
#define LED_Channel   1

// Priorities at which the tasks are created
#define INIT_TASK_PRIORITY		( tskIDLE_PRIORITY )
#define MRTE_TASKS_PRIORITY 	( tskIDLE_PRIORITY+1 )
#define PT_MSMT_TASK_PRIORITY	( tskIDLE_PRIORITY+1 )
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

    //xTaskCreate( mt_1, ( const char * )"MT_1", 256, NULL, MRTE_TASKS_PRIORITY, NULL );
    init_mrte_tasks(MRTE_TASKS_PRIORITY);

    vTaskStartScheduler();

    while(1)
    {
    		//
    }
    return 0;
}

void mt_1(void *pvParameters){
	static t_mrte_msg_buff * 	p_mrte_buff = NULL;
	static TX_Com_buf_type *	TX_Com_buf_ponter;
	static u8 base_tlm_counter;
	static u8 ext_tlm_counter;
	static u8 osc_tlm_counter;

	u8 z = 0;
	for(z = 0; z < 100; z++){}

	for(;;){
		//vTaskDelay(1);
		flash ^= 0x01;
		TX_Com_buf_ponter = (TX_Com_buf_type*) &p_mrte_buff->buff->data.dU8[0];
		p_mrte_buff->len = 7;
		TX_Com_buf_ponter->CmdCode = COMMAND_GET_BASE_TLM;
		TX_Com_buf_ponter->CmdMarker = base_tlm_counter++;
		TX_Com_buf_ponter->Timer = 0x1234;

		//while(request_mrte_send(CAN_SEND_ASYNC, p_mrte_buff) == pdFALSE);
		//XGpio_DiscreteWrite(&led_gpio, LED_Channel, flash);
		//vTaskDelay(100);
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