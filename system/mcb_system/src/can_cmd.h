/*
 * can_cmd.h
 *
 *  Created on: 03.04.2017
 *      Author: pavlenko_av
 */

#ifndef CAN_CMD_H_
#define CAN_CMD_H_

#include <FreeRTOS.h>
#include "task.h"
#include "queue.h"

#include "io-mrte.h"

void cmd_decoder( t_mega2_rxdatablock *pmega );

#endif /* CAN_CMD_H_ */
