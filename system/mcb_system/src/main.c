#include <string.h>
#include <stdio.h>

#include "xtmrctr.h"
#include "microblaze_exceptions_g.h"

#include "xparameters.h"
#include "xiic_l.h"
#include "xil_cache.h"

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

#include "fpga.h"
#include "leds.h"
#include "mirp.h"
#include "can_cmd.h"
#include "can_cmd_defs.h"
#include "can_freertos.h"
//#include <sys/timer.h>
//#include "FreeRTOS_mb_hooks.h"
void timecounter_task(void *pvParameters);
void sleep(unsigned long int c);

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
#define RTC_8654						0x51
#define LM92CIM_ADR						(0x48 | 0)

XGpio    led_gpio; // LED instance
uint8_t flash = 0x00;
static canmsg_t	candata;
DevInfo info;

DDS_param_type DDS_param;
struct MirpBaseTelem MirpTelem;
struct MirpExtendedTelem MirpExtTelem;

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
    configASSERT(xTaskCreate( timecounter_task, 	"TimeCounter", 	4096, NULL, 1, NULL ));

    vTaskStartScheduler();

    while(1)
    {
    		//
    }
    return 0;
}
// ---------------------------------------------------------
void timecounter_task(void *pvParameters){
	static int rc, tor_cnt;
	static unsigned char tmp[8];
	InitCoefs(); // Init TOR
	read_eeprom_calibr_mem(); // ������ ���������� �� eeprom

	tor_cnt=0;

	info.serial_num = read_SN();
	while(1){
		// read temperature
		rc = XIic_Recv(XPAR_IIC_0_BASEADDR, LM92CIM_ADR, (u8*)&tmp[0], 2, XIIC_STOP);
		if (rc == 2)
		{
			MirpTelem.Temperature = (float)((((short*)&tmp[0])[0]) >> 3) * COEFT_TEMP;
			MirpExtTelem.Temperature = (float)((((short*)&tmp[0])[0]) >> 3) * COEFT_TEMP;
		}else{
			MirpTelem.Temperature = 0xFFFF;
			MirpExtTelem.Temperature = 0xFFFF;
		}
		if(DDS_param.update_DDS > 0 ) set_DDS_param(DDS_param.freq,DDS_param.voltage); DDS_param.update_DDS = 0;
		if(tor_cnt>=60)
		{
			tor_cnt=0;
			TOR();
		}else{
			tor_cnt++;
		}
		toggle_led(0);
    vTaskDelay(1000);
	}
}
// ---------------------------------------------------------



void sleep(unsigned long int c){
   unsigned int cc = 0, cb;
   for(cc = 0; cc < 500; cc++){
	   for(cb = 0; cb < (c * 10); cb++){}
   }

}
