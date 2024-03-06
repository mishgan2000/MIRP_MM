/*
 * can_config.h
 *
 *  Created on: 16.03.2018
 *      Author: pavlenko_av
 */

#ifndef CAN_CONFIG_H_
#define CAN_CONFIG_H_

#include "xil_types.h"
#include "FreeRTOS.h"


typedef struct{
	u8 presc;
	u8 tseg1;
	u8 tseg2;
	u8 sjw;
} can_baud_config_type;

typedef struct{
	const can_baud_config_type	baud;
	const UBaseType_t			CAN_No_SendObjects;
	const UBaseType_t			CAN_No_ReceiveObjects;
	const TickType_t			CANTX_TIMEOUT;
	const TickType_t			CANRX_TIMEOUT;
} can_config_type;

extern can_config_type can_config_data;

#endif /* CAN_CONFIG_H_ */
