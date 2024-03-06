/*
 * can_config.c
 *
 *  Created on: 16.03.2018
 *      Author: pavlenko_av
 */
#include "can_config.h"

//(u8 presc, u8 tseg1, u8 tseg2, u8 sjw); // T_baud = T_cpu * (2*(presc+1)) * ( (1+tseg1) + (1+tseg2) + 1)
can_config_type can_config_data = {
		.baud = {
			.presc = 3,
			.tseg1 = 6,
			.tseg2 = 1,
//			.tseg1 = 5,
//			.tseg2 = 2,
			.sjw = 2
		},
		.CAN_No_SendObjects = 2200,
		.CAN_No_ReceiveObjects = 2200,
		.CANTX_TIMEOUT = 0,
		.CANRX_TIMEOUT = 100
};
