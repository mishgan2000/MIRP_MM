

#include <stdio.h>
#include "platform.h"
#include "xil_types.h"
#include "xil_assert.h"
//#include "xgpio.h"

#include <FreeRTOS.h>
#include "task.h"
#include "timers.h"
#include "queue.h"
#include "semphr.h"
//#include "FreeRTOS_mb_hooks.h"

//void print(char *str);
#define INIT_TASK_PRIORITY	( tskIDLE_PRIORITY )

//#define MIKE_STACK_SIZE     (1024U)
#define MIKE_STACK_SIZE     (256U)

void mike_task_1(void *pvParameters){

	while(1){
		printf("Hello task 1!");

	}
	vTaskDelete(NULL);
}
void mike_task_2(void *pvParameters){

	while(1){
		printf("Hello task 2!");

	}
	vTaskDelete(NULL);
}

int main()
{
    init_platform();
    microblaze_enable_interrupts();
    //xTaskCreate( mike_task, "Mike_Task", MIKE_STACK_SIZE, NULL, ( tskIDLE_PRIORITY + 1 ), NULL );
    xTaskCreate( mike_task_1, "Mike_Task_1", 1000, NULL, 1, NULL );
    xTaskCreate( mike_task_2, "Mike_Task_2", 1000, NULL, 2, NULL );
    vTaskStartScheduler();
    //print("Hello World\n\r");
    while(1)
    {
    		//
    }
    return 0;
}
