/*
 * FreeRTOS_mb_hooks.c
 *
 *  Created on: 30.03.2017
 *      Author: pavlenko_av
 */
#include "xtmrctr.h"
#include "xparameters.h"

#include <FreeRTOS.h>
#include "task.h"

#include "FreeRTOS_mb_hooks.h"

static XTmrCtr xTickTimerInstance;

/*-----------------------------------------------------------*/

/* This is an application defined callback function used to install the tick
interrupt handler.  It is provided as an application callback because the kernel
will run on lots of different MicroBlaze and FPGA configurations - not all of
which will have the same timer peripherals defined or available.  This example
uses the Dual Timer 0.  If that is available on your hardware platform then this
example callback implementation may not require modification.   The name of the
interrupt handler that must be installed is vPortTickISR(), which the function
below declares as an extern. */
void vApplicationSetupTimerInterrupt( void )
{
portBASE_TYPE xStatus;
const unsigned char ucTickTimerCounterNumber = ( unsigned char ) 0U;
const unsigned char ucRunTimeStatsCounterNumber = ( unsigned char ) 1U;
//const unsigned long ulCounterValue = ( ( XPAR_TMRCTR_1_CLOCK_FREQ_HZ / configTICK_RATE_HZ ) - 1UL );
const unsigned long ulCounterValue = ( ( XPAR_TMRCTR_0_CLOCK_FREQ_HZ / configTICK_RATE_HZ ) - 1UL );
extern void vPortTickISR( void *pvUnused );

	/* Initialise the timer/counter. */
	//xStatus = XTmrCtr_Initialize( &xTickTimerInstance, XPAR_TMRCTR_1_DEVICE_ID );
    xStatus = XTmrCtr_Initialize( &xTickTimerInstance, XPAR_TMRCTR_0_DEVICE_ID );

	if( xStatus == XST_SUCCESS )
	{
		/* Install the tick interrupt handler as the timer ISR.
		*NOTE* The xPortInstallInterruptHandler() API function must be used for
		this purpose. */
		//xStatus = xPortInstallInterruptHandler( XPAR_INTC_0_TMRCTR_1_VEC_ID, vPortTickISR, NULL );
		xStatus = xPortInstallInterruptHandler( XPAR_INTC_0_TMRCTR_0_VEC_ID, vPortTickISR, NULL );
	}

	if( xStatus == pdPASS )
	{
		/* Enable the timer interrupt in the interrupt controller.
		*NOTE* The vPortEnableInterrupt() API function must be used for this
		purpose. */
		//vPortEnableInterrupt( XPAR_INTC_0_TMRCTR_1_VEC_ID );
		vPortEnableInterrupt( XPAR_INTC_0_TMRCTR_0_VEC_ID );

		/* Configure the timer interrupt handler.  This installs the handler
		directly, rather than through the Xilinx driver.  This is done for
		efficiency. */
		XTmrCtr_SetHandler( &xTickTimerInstance, ( void * ) vPortTickISR, NULL );

		/* Set the correct period for the timer. */
		XTmrCtr_SetResetValue( &xTickTimerInstance, ucTickTimerCounterNumber, ulCounterValue );

		/* Enable the interrupts.  Auto-reload mode is used to generate a
		periodic tick.  Note that interrupts are disabled when this function is
		called, so interrupts will not start to be processed until the first
		task has started to run. */
		XTmrCtr_SetOptions( &xTickTimerInstance, ucTickTimerCounterNumber, ( XTC_INT_MODE_OPTION | XTC_AUTO_RELOAD_OPTION | XTC_DOWN_COUNT_OPTION ) );

		/* Start the timer. */
		XTmrCtr_Start( &xTickTimerInstance, ucTickTimerCounterNumber );




		/* The second timer is used as the time base for the run time stats.
		Auto-reload mode is used to ensure the timer does not stop. */
		XTmrCtr_SetOptions( &xTickTimerInstance, ucRunTimeStatsCounterNumber, XTC_AUTO_RELOAD_OPTION );

		/* Start the timer. */
		XTmrCtr_Start( &xTickTimerInstance, ucRunTimeStatsCounterNumber );
	}

	/* Sanity check that the function executed as expected. */
	configASSERT( ( xStatus == pdPASS ) );

	/* Setup Profiler Timer Interrupts 	 */
	//vPortEnableInterrupt( XPAR_INTC_0_TMRCTR_1_VEC_ID );
	vPortEnableInterrupt( XPAR_INTC_0_TMRCTR_0_VEC_ID );
}
/*-----------------------------------------------------------*/

/* This is an application defined callback function used to clear whichever
interrupt was installed by the the vApplicationSetupTimerInterrupt() callback
function.  It is provided as an application callback because the kernel will run
on lots of different MicroBlaze and FPGA configurations - not all of which will
have the same timer peripherals defined or available.  This example uses the
dual timer 0.  If that is available on your hardware platform then this example
callback implementation will not require modification provided the example
definition of vApplicationSetupTimerInterrupt() is also not modified. */
void vApplicationClearTimerInterrupt( void )
{
unsigned long ulCSR;

	/* Clear the timer interrupt */
	//ulCSR = XTmrCtr_GetControlStatusReg( XPAR_TMRCTR_1_BASEADDR, 0 );
    ulCSR = XTmrCtr_GetControlStatusReg( XPAR_TMRCTR_0_BASEADDR, 0 );
	//XTmrCtr_SetControlStatusReg( XPAR_TMRCTR_1_BASEADDR, 0, ulCSR );
    XTmrCtr_SetControlStatusReg( XPAR_TMRCTR_0_BASEADDR, 0, ulCSR );
}
/*-----------------------------------------------------------*/

void vApplicationIdleHook( void )
{
	//const TickType_t xToggleRate = pdMS_TO_TICKS( 1000UL );
	//static TickType_t xLastToggle = 0, xTimeNow;
	//
	//	xTimeNow = xTaskGetTickCount();
	//
	//	/* As there is not Timer task, toggle the LED 'manually'.  Doing this from
	//	the Idle task will also provide visual feedback of the processor load. */
	//	if( ( xTimeNow - xLastToggle ) >= xToggleRate )
	//	{
	//		HAL_GPIO_TogglePin( GPIOG, GPIO_PIN_6 );
	//		xLastToggle += xToggleRate;
	//	}
}
/*-----------------------------------------------------------*/
void vApplicationMallocFailedHook( void )
{
	/* Called if a call to pvPortMalloc() fails because there is insufficient
	free memory available in the FreeRTOS heap.  pvPortMalloc() is called
	internally by FreeRTOS API functions that create tasks, queues, software
	timers, and semaphores.  The size of the FreeRTOS heap is set by the
	configTOTAL_HEAP_SIZE configuration constant in FreeRTOSConfig.h. */
	vAssertCalled( __FILE__, __LINE__ );
}
/*-----------------------------------------------------------*/
void vAssertCalled( const char *pcFile, uint32_t ulLine )
{
//
//	taskDISABLE_INTERRUPTS();
//	{
//		while( 1 )
//		{
//			__asm volatile( "NOP" );
//		}
//	}
//	taskENABLE_INTERRUPTS();
	volatile uint32_t ul = 0;
	volatile const char *pcLocalFileName = pcFile; /* To prevent pcFileName being optimized away. */
	volatile uint32_t ulLocalLine = ulLine; /* To prevent ulLine being optimized away. */

	/* Prevent compile warnings about the following two variables being set but
		not referenced.  They are intended for viewing in the debugger. */
	( void ) pcLocalFileName;
	( void ) ulLocalLine;

	/* If this function is entered then a call to configASSERT() failed in the
		FreeRTOS code because of a fatal error.  The pcFileName and ulLine
		parameters hold the file name and line number in that file of the assert
		that failed.  Additionally, if using the debugger, the function call stack
		can be viewed to find which line failed its configASSERT() test.  Finally,
		the debugger can be used to set ul to a non-zero value, then step out of
		this function to find where the assert function was entered. */
	taskENTER_CRITICAL();
//	reset_led(0);
	{
		while( ul == 0 )
		{
			__asm volatile( "NOP" );
		}
	}
	taskEXIT_CRITICAL();
}
/*-----------------------------------------------------------*/
void vApplicationStackOverflowHook( TaskHandle_t pxTask, char *pcTaskName )
{
	( void ) pcTaskName;
	( void ) pxTask;
	char c = pcTaskName[0];

	while(c != 0)
	{
		c = *(pcTaskName++);
		xil_printf("%c", c);
	}


	taskDISABLE_INTERRUPTS();

	for( ;; );
}
/*-----------------------------------------------------------*/
void vApplicationTickHook( void )
{
	/* Call the ST HAL tick function. */
	//	HAL_IncTick();
}
