
#include <FreeRTOS.h>
#include "queue.h"
#include "semphr.h"
#include "task.h"

#include "can_opc.h"


void can_init(void);
portBASE_TYPE can_send_msg(canmsg_t * p_can_data);
portBASE_TYPE can_recieve_msg(canmsg_t * p_can_data, u32 timeout);

//void CAN_on(void);
//void CAN_off(void);
//bool is_CAN_on(void);
//bool is_CAN_started(U32 ctrl);
void CAN_tx_start(u32 ctrl); //TODO
void CAN_tx_stop(u32 ctrl); //TODO
///*----------------------------------------------------------------------------
// * end of file
// *---------------------------------------------------------------------------*/
