/*
 * Copyright (c) 2009-2012 Xilinx, Inc.  All rights reserved.
 *
 * Xilinx, Inc.
 * XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS" AS A
 * COURTESY TO YOU.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION AS
 * ONE POSSIBLE   IMPLEMENTATION OF THIS FEATURE, APPLICATION OR
 * STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS IMPLEMENTATION
 * IS FREE FROM ANY CLAIMS OF INFRINGEMENT, AND YOU ARE RESPONSIBLE
 * FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE FOR YOUR IMPLEMENTATION.
 * XILINX EXPRESSLY DISCLAIMS ANY WARRANTY WHATSOEVER WITH RESPECT TO
 * THE ADEQUACY OF THE IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO
 * ANY WARRANTIES OR REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE
 * FROM CLAIMS OF INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.
 *
 */

//#include <stdio.h>
#include "platform.h"
#include "xparameters.h"
#include "xil_types.h"
#include "xtmrctr.h"
#include "xil_io.h"

/* FreeRTOS includes. */
#include <FreeRTOS.h>
#include "task.h"
#include "timers.h"
#include "queue.h"
#include "semphr.h"

/* Prototypes for the standard FreeRTOS callback/hook functions implemented
within this file. */
#include "FreeRTOS_mb_hooks.h"

/* Device operation */
#include "io-mrte.h"
#include "can_cmd.h"

//void print(char *str);

//=================
// Priorities at which the tasks are created
#define INIT_TASK_PRIORITY		( tskIDLE_PRIORITY )
#define MRTE_TASKS_PRIORITY 	( tskIDLE_PRIORITY+1 )


static void prvInitTask(void *pvParameters);
void Xil_Assert_To_JtagUart(const char *File, int Line);

int main()
{
	init_platform();

	configASSERT(xTaskCreate(prvInitTask,	"Init",	configMINIMAL_STACK_SIZE,	NULL, INIT_TASK_PRIORITY, NULL));

	vTaskStartScheduler();

	while(1)
	{

	}

}

static void prvInitTask(void *pvParameters)
{
	// Инициализация процесса индикации
	//======================
	init_mrte_tasks(MRTE_TASKS_PRIORITY);

	for( ;; )
	{
		vTaskDelay(500);
	}

	// Код должен быть организован так, чтобы в случае выхода (break) из указанного
	// выше бесконечного цикла задачи, задача должна быть удалена ПРЕЖДЕ чем
	// управление достигнет конца этой функции. Параметр NULL, переданный
	// vTaskDelete(), показывает, что должна быть удалена вызывающая (эта, которая
	// работает) задача.
	vTaskDelete(NULL);
}