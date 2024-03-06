
#include <FreeRTOS.h>
#include "queue.h"
#include "semphr.h"
#include "task.h"

#include "can_opc.h"

typedef portBASE_TYPE (*on_can_send_message_hook_ptr)(const canmsg_t * p_can_data);

void can_init(void);
portBASE_TYPE can_send_msg(canmsg_t * p_can_data, const TickType_t t_wait);
unsigned int can_send_queue_free_bytes(void);
portBASE_TYPE can_recieve_msg(canmsg_t * p_can_data, u32 timeout);
portBASE_TYPE can_queu_recieved_msg(canmsg_t * p_can_data, u32 timeout);
void inc_can_err_counter(void);
u32 can_get_err_counter(void);
int can_set_filter(u8 ch, u32 arbcode, u8 frame, u8 mode);
int can_set_any_filter(u8 ch);
//void CAN_on(void);
//void CAN_off(void);
//bool is_CAN_on(void);
//bool is_CAN_started(U32 ctrl);
void CAN_tx_start(u32 ctrl); //TODO
void CAN_tx_stop(u32 ctrl); //TODO
void CAN_reset(void);
void set_on_can_send_message_hook(on_can_send_message_hook_ptr hook);
///*----------------------------------------------------------------------------
// * end of file
// *---------------------------------------------------------------------------*/
