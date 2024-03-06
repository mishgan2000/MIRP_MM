/*
 * FreeRTOS_mb_hooks.h
 *
 *  Created on: 03.05.2017
 *      Author: pavlenko_av
 */

#ifndef FREERTOS_MB_HOOKS_H_
#define FREERTOS_MB_HOOKS_H_

void vApplicationMallocFailedHook( void );
void vApplicationIdleHook( void );
void vApplicationStackOverflowHook( TaskHandle_t pxTask, char *pcTaskName );
void vApplicationTickHook( void );

#endif /* FREERTOS_MB_HOOKS_H_ */
