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



typedef enum{
	can_dev_cmd = 0
} te_dev_cmd_type;

typedef struct{
	te_dev_cmd_type	cmd;
	t_mrte_msg_buff	*	pbuf;
} ts_dev_cmd_queue;

void init_plt_tlm_task(UBaseType_t task_priority);
void cmd_decoder( t_mega2_rxdatablock *pmega );
//void init_dev_cmd_interface(UBaseType_t task_priority);

#endif /* CAN_CMD_H_ */
